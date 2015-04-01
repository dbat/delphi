unit AbsRW;
{
  Copyright (c) 2004, aa, Inge DR. & Adrian Hafizh.
  Property of PT SOFTINDO Jakarta.
  All rights reserved.

  mailto:aa|AT|softindo|DOT|net,  http://delphi.softindo.net

  This software is free for any purposes, distribution licensed
  under the terms of BSD License, see COPYING.

  absolute read/write hard-disk, must be an admin on winnt family

  Version: 1.0.0
  Dated: 2004.02.04

  quote:
  once ever i proudly sought that i was too smart to think (something) simple,
  then i shamely realized that i'm not smart enough to think simple.
  sigh, i'm getting older.
}

{$D-}
interface
uses Windows;

type
  TAbsRWMethod = (rwAuto, rwINT13H, rwINT21H, rwINT25H, rwINT26H, rwNTFile);
  TAbsOperation = (opNone, opRead, opWrite);
  TBlockMode = (bmSector, bmTrack);
  //TValidDrive = 'a'..'z';
  TValidHardDiskNo = 0..7;

const
  INVALID_RESULT = Cardinal(-1);

//function AbsoluteRead(const Buffer: pointer = nil; const Drive: TvalidHardDiskNo = 0;
//  const RWMethod: TAbsRWMethod = rwAuto; const StartSector: dword = 0;
//  SectorsCount: dword = 1): Cardinal;
//function AbsoluteWrite(const Buffer: pointer = nil; const Drive: TvalidHardDiskNo = 0;
//  const RWMethod: TAbsRWMethod = rwAuto; const StartSector: dword = 1;
//  SectorsCount: dword = 1): Cardinal;
//function AbsoluteReadWrite(const Buffer: pointer = nil; const Drive: TvalidHardDiskNo = 0;
//  const Operation: TAbsOperation = opRead; const RWMethod: TAbsRWMethod = rwAuto;
//  const StartSector: dword = 0; SectorsCount: dword = 1): Cardinal;

function AbsoluteRead(const Buffer: pointer = nil; const StartSector: dword = 0; SectorsCount:
  dword = 1; const Drive: TvalidHardDiskNo = 0; const RWMethod: TAbsRWMethod = rwAuto): Cardinal;

function AbsoluteWrite(const Buffer: pointer = nil; const StartSector: dword = 1; SectorsCount:
  dword = 1; const Drive: TvalidHardDiskNo = 0; const RWMethod: TAbsRWMethod = rwAuto): Cardinal;

function AbsoluteReadWrite(const Buffer: pointer = nil; const Operation: TAbsOperation = opRead;
  const StartSector: dword = 0; SectorsCount: dword = 1; const Drive: TvalidHardDiskNo = 0;
  const RWMethod: TAbsRWMethod = rwAuto): Cardinal;

function abs_hex(const Buffer: pointer; const Count: integer;
  const linebreak: boolean = TRUE): string;
function abs_ascii(const Buffer: pointer; const Count: integer): string;
function abs_aschex(const Buffer: pointer; const Count: integer): string;

//var
//  abs_ReadWrite: function(const hDrive: THandle; Drive: byte; StartSector: dword; SectorsCount: word; Buf: pointer): Cardinal;

const
  SECTOR_SIZE = $200;

implementation
uses IOCTL;

var
  CheckFlags: Cardinal;

function abs_Read(const Drive: TvalidHardDiskNo = 0; const RWMethod: TAbsRWMethod = rwAuto; const StartSector: dword = 0; SectorsCount: dword = 1; const Buffer: pointer = nil): Cardinal; forward;
function abs_Write(const Drive: TvalidHardDiskNo = 0; const RWMethod: TAbsRWMethod = rwAuto; const StartSector: dword = 1; SectorsCount: dword = 1; const Buffer: pointer = nil): Cardinal; forward;
function abs_RW(const Buffer: pointer = nil; const Drive: TvalidHardDiskNo = 0; const Operation: TAbsOperation = opRead; const RWMethod: TAbsRWMethod = rwAuto; const StartSector: dword = 0; SectorsCount: dword = 1): Cardinal; forward;

// to plays around, if you want to change the order of arguments...
// ie. to AbsoluteRead(const Drive: TvalidHardDiskNo = 0; const RWMethod: TAbsRWMethod = rwAuto; const StartSector: dword = 0; SectorsCount: dword = 1; const Buffer: pointer = nil): Cardinal;
// some prefer to Buffer as the first arguments, the other likes Drive for default :-$
// dont forget to copy/replace declarations to the top

function AbsoluteRead(const Buffer: pointer = nil; const StartSector: dword = 0; SectorsCount: dword = 1; const Drive: TvalidHardDiskNo = 0; const RWMethod: TAbsRWMethod = rwAuto): Cardinal;
begin
  Result := abs_Read(Drive, RWMethod, StartSector, SectorsCount, Buffer);
end;

function AbsoluteWrite(const Buffer: pointer = nil; const StartSector: dword = 1; SectorsCount: dword = 1; const Drive: TvalidHardDiskNo = 0; const RWMethod: TAbsRWMethod = rwAuto): Cardinal;
begin
  Result := abs_write(Drive, RWMethod, StartSector, SectorsCount, Buffer);
end;

function AbsoluteReadWrite(const Buffer: pointer = nil; const Operation: TAbsOperation = opRead; const StartSector: dword = 0; SectorsCount: dword = 1; const Drive: TvalidHardDiskNo = 0; const RWMethod: TAbsRWMethod = rwAuto): Cardinal;
begin
  Result := abs_RW(Buffer, Drive, Operation, RWMethod, StartSector, SectorsCount);
end;

function abs_RW(const Buffer: pointer = nil; const Drive: TvalidHardDiskNo = 0; const Operation: TAbsOperation = opRead; const RWMethod: TAbsRWMethod = rwAuto; const StartSector: dword = 0; SectorsCount: dword = 1): Cardinal;
begin
  case Operation of
    opRead: Result := abs_Read(Drive, RWMethod, StartSector, SectorsCount, Buffer);
    opWrite: Result := abs_Write(Drive, RWMethod, StartSector, SectorsCount, Buffer);
    else
      Result := 0;
  end;
end;

var
  Win32Platform: Cardinal = INVALID_RESULT;

const
  VWIN32_DIOC_DIOS_IOCTL = 1;           //Performs the specified MS-DOS device I/O control function
  VWIN32_DIOC_DIOS_INT25 = 2;           //(Interrupt 21h Function 4400h through 4411h).
  VWIN32_DIOC_DIOS_INT26 = 3;
  VWIN32_DIOC_DIOS_INT13 = 4;           //Performs Interrupt 13h commands.
  VWIN32_DIOC_DIOS_DRIVEINFO = 6;
  CARRY_FLAG = 1;

type
  TDIOCRegisters = packed record
    EBX, EDX, ECX, EAX,
      EDI, ESI, Flags: dword;
  end;

  TDiskIO = packed record
    StartSector: dword;
    Sectors: word;
    Buffer: dword;
  end;

  TRWBlock = packed record
    SpecFunc: byte;                     //db  ?  ;special functions (must be zero)
    Head: word;                         //dw  ?  ;head to read/write
    Cylinder: word;                     //dw  ?  ;cylinder to read/write
    FirstSector: word;                  //dw  ?  ;first sector to read/write
    Sectors: word;                      //dw  ?  ;number of sectors to read/write
    Buffer: dword;                      //dd  ?  ;address of buffer for read/write data
  end;

  TDisk_Addr_pkt = packed record
    PacketSize: byte;                   //db     16       ; size of packet in bytes
    Reserved: byte;                     //db      0       ; reserved, must be 0
    BlockCount: word;                   //dw      ?       ; number of blocks to transfer
    BufferAddress: dword;               //dd      ?       ; address of transfer buffer
    BlockStart: comp;                   //dq      ?       ; starting absolute block number
  end;

  //var
  //  cb: dword;
  //  B: array[0..1024 * 8 - 1] of Char;
const
  CARRY_SET = $8000;
  DRIVE_C = $80;
  INT13H_READ = $0200;
  IOCTL_GENERIC = $440D;
  IOCTL_OSR2 = $4800;
  IOCTL_LOCK = $004B;
  IOCTL_UNLOCK = $006B;
  IOCTL_EXT_ABS_DISKACCESS = $7305;
  IOCTL_BLOCK_DEVICE = $4400;
  IOCTL_READ_TRACK = $4861;
  IOCTL_DATA_NORMALFILE = $6001;

const
  PARALEN = $10;
  CR_ = #13;
  LF_ = #10;
  CRLF = CR_ + LF_;
  SPACE = ' ';
  DOT = '.';
  DASH = '-';

function abs_hex(const Buffer: pointer; const Count: integer; const linebreak: boolean = TRUE): string;
// make a single string of hex from untyped buffer.
// beware that Count value MUST be valid!
// do not expect too much, this routine would deliberately accepts
// ANY value, even if you stubbornly give them a Count of equal with MaxInt!
// oh yes. this one is lightning speed :)
// note: this routine will superfluously adds SPACE, and also CR+LF if
//   meets paragraph boundary, its calling routine responsibility to trims it.
const
  MIDS = SPACE + DASH;
  BYTEVAL = length('00H');
  SPARALEN = PARALEN * BYTEVAL + length(MIDS) + length(LF_);
var
  i: integer;
  //  p: pChar;          //when i couldn't work with Delphi's String handling routines
  //  len: integer;
begin
  ///  len := (Count div PARALEN + 1) * SPARALEN + SizeOf(Cardinal); // allocate to paragraph boundary
  //  getmem(p, len);
  //  Cardinal(Pointer(p)^) := len;
  //  inc(p, SizeOf(Cardinal));
  if LineBreak then begin
    i := ((Count div PARALEN) * SPARALEN) + ((Count mod PARALEN) * BYTEVAL);
    if Count mod PARALEN > 4 then
      inc(i, length(MIDS));
  end
  else
    i := Count * BYTEVAL;
  SetLength(Result, (i));
  asm
    mov ecx, Count
    or ecx, ecx
    jle @@end
    push esi; push edi

    //lea esi, Buf       // deadly wrong! for every times i just couldn't figured out
    //lea edi, p         // whether should i used LEA or MOV in Delphi :((

    mov esi, Buffer
    //mov edi, p
    mov eax, Result
    //mov eax, @Result   // it "sami-mawon", keneh-keneh kehed, burp...
    mov edi, [eax]       // damn, ugh!

    mov dx, $10          // paragraph counter
    cld                  // just in case
  @@Loop:
    lodsb                // load byte to AL
    mov ah, al           // copy to AH for second nibble translation

    shr al, 4            // extract high nibble
    add al, 90h          // special hex conversion sequence
    daa                  // using ADDs and DAA's
    adc al, 40h
    daa
    cld
    stosb
    mov al, ah           // repeat conversion for low nibble
    and al, 0Fh
    add al, 90h
    daa
    adc al, 40h
    daa
    stosb

    mov al, SPACE        // prepare space to be written
    cmp LineBreak, 1     // with formatting?
    jnz @@2
    dec dx               // step down paragraph counter
    jnz @@1              // is a 1 paragraph has been completely written?
    mov dx, PARALEN      // jump if not, if yes then restore counter
    mov al, CR_          // replace AL with carriage-return & line-feed pair
    stosb                //
    mov al, LF_          //

    @@1:
    cmp dl, PARALEN shr 1// middle paragraph
    jnz @@2
    mov al, SPACE
    stosb
    mov al, '-'
    stosb
    mov al, SPACE

    @@2:
    stosb                // write AL
    loop @@Loop          // keep going until done

    //xor al, al         // pcharz
    //stosb              // not needed anymore

    pop edi; pop esi
    @@end:
  end;
  //Result[length(Result)]:='$';
  //Result := string(pChar(p));
  //Dec(p, SizeOf(Cardinal));
  ///FreeMem(p, Cardinal(Pointer(p)^));
end;

function abs_ascii(const Buffer: pointer; const Count: integer): string;
type
  THugeChars = array[1..high(Cardinal) div 2] of Char;
const
  SPARALEN = PARALEN + length(CRLF);
var
  i, j: integer;
begin
  Result := CRLF;                       // for count = 0
  SetLength(Result, Count + Count div PARALEN * length(CRLF));
  j := 0;
  for i := 1 to Count do begin
    if THugeChars(Buffer^)[i] >= SPACE then
      Result[i + j] := THugeChars(Buffer^)[i];
    if THugeChars(Buffer^)[i] >= SPACE then
      Result[i + j] := THugeChars(Buffer^)[i]
    else
      Result[i + j] := DOT;
    if i mod PARALEN = 0 then begin
      inc(j);
      Result[i + j] := CR_;
      inc(j);
      Result[i + j] := LF_;
    end;
  end;
  //Result := trimright(Result); //we dont have sysutils //remove trailing CRLF if any
end;

function abs_aschex(const Buffer: pointer; const Count: integer): string;
// function ascii & hex in one pass;
const
  MIDS = SPACE + DASH;
  SEPARATOR = SPACE + SPACE + SPACE;    // it should be 4 but 1 SPACE occupied by BYTEVAL
  BYTEVAL = length('000H');
  SPARALEN = (PARALEN * BYTEVAL) + length(MIDS) + length(SEPARATOR) + length(CR_ + LF_);
begin
  SetLength(Result, (Count div PARALEN + ord(Count mod Paralen > 0)) * SPARALEN);
  asm
    mov ecx, Count
    or ecx, ecx
    jle @@end
    push esi; push edi

    //lea esi, Buf       // deadly wrong! for every times i just couldn't figured out
    //lea edi, p         // whether should i used LEA or MOV in Delphi :((

    mov esi, Buffer
    //mov edi, p
    mov eax, Result
    //mov eax, @Result   // it "sami-mawon", keneh-keneh kehed, burp...
    mov edi, [eax]       // damn, ugh!

    mov dx, $10          // paragraph counter
    cld                  // just in case
  @@Loop:
    lodsb                // load byte to AL
    mov ah, al           // copy to AH for second nibble translation

    shr al, 4            // extract high nibble
    add al, 90h          // special hex conversion sequence
    daa                  // using ADDs and DAA's
    adc al, 40h
    daa
    cld
    stosb
    mov al, ah           // repeat conversion for low nibble
    and al, 0Fh
    add al, 90h
    daa
    adc al, 40h
    daa
    stosb

    mov al, SPACE        // prepare space to be written
    //cmp LineBreak, 1     // with formatting?
    //jnz @@2
    dec dx               // step down paragraph counter
    jnz @@1              // is a 1 paragraph has been completely written?
    mov edx, PARALEN      // jump if not, if yes then restore counter

    mov eax, $20202020   // 4 space
    stosd

    push cx              // store counter
    mov cx, dx           // write ascii
    sub si, cx           // recall 16 byte
  @@Loop2:
    lodsb
    cmp al, SPACE        // character control (below space)
    ja @@a               // replaced by dot
    mov al, DOT
    @@a:
    stosb
    loop @@Loop2
    pop cx               // restore counter

    mov al, CR_          // replace AL with carriage-return & line-feed pair
    stosb                //
    mov al, LF_          //

    @@1:
    cmp dl, PARALEN shr 1// is this middle of paragraph?
    jnz @@2

    mov al, SPACE
    stosb
    cmp cx, 1            // are bytes exhausted?
    jz @@3               // dont replace space with dash
    mov al, DASH
    @@3:
    stosb
    mov al, SPACE

    @@2:
    stosb                // write AL
    loop @@Loop          // keep going until done

    cmp dl, PARALEN      // a paragraph boundary?
    jz @@done

    mov cx, dx
    shl cx, 1
    add cx, dx
    add cx, 3
    cmp dx, 8
    jbe @@skip
    add cx, 2
    @@skip:
    mov al, SPACE
    rep stosb

    mov cx, PARALEN
    sub cx, dx
    sub si, cx

  @@Loop3:
    lodsb
    cmp al, SPACE        // character control (below space)
    ja @@b               // replaced by dot
    mov al, DOT
    @@b:
    stosb
    loop @@Loop3

    mov cx, dx
    mov al, SPACE
    rep stosb

    mov al, CR_          //
    stosb                //
    mov al, LF_          //
    stosb                //


    @@done:
    pop edi; pop esi
    @@end:
  end;
end;

function HardDriveHandle(const HardDiskNo: integer = 0): THandle;
begin
  Result := CreateFile(pChar('\\.\PhysicalDrive' + Char(ord(Char('0')) + HardDiskNo and 3)),
    GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, nil,
    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL or FILE_FLAG_DELETE_ON_CLOSE, 0);
end;

function GetDriveHandle(const HardDiskNo: integer = 0): THandle;
begin
  case Win32Platform of
    VER_PLATFORM_WIN32_WINDOWS:
      Result := CreateFile('\\.\VWin32', GENERIC_READ or GENERIC_WRITE,
        FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING,
        FILE_ATTRIBUTE_NORMAL or FILE_FLAG_DELETE_ON_CLOSE, 0);
    VER_PLATFORM_WIN32_NT:
      Result := CreateFile(pChar('\\.\PhysicalDrive' + Char(ord(Char('0')) +
        HardDiskNo and 3)), GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or
        FILE_SHARE_WRITE, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL or
        FILE_FLAG_DELETE_ON_CLOSE, 0);
    else
      Result := INVALID_HANDLE_VALUE;
  end; ///case///
end;

function LockPhysVolume(const hDrive: THandle; Level: dword): BOOL;
var
  regs: TDIOCRegisters;
  cb: dword;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    Result := TRUE
  else begin
    regs.ESI := $0;
    regs.EDI := $0;                     //unnecessary?
    regs.Flags := CARRY_SET;            //set carry flag
    regs.EAX := IOCTL_GENERIC;          //Generic IOCTL function
    regs.EBX := Level shl 8 or DRIVE_C;
    regs.ECX := IOCTL_OSR2 or IOCTL_LOCK; //CH=$48:OSR2, CL=$4B:LOCK Physical Volume
    regs.EDX := $2;                     //write/map still enabled
    Result := DeviceIOControl(hDrive, VWIN32_DIOC_DIOS_IOCTL, @regs, SizeOf(regs), @regs, SizeOf(regs), cb, nil);
  end;
end;

function UnLockPhysVolume(const hDrive: THandle; Level: dword): BOOL;
var
  regs: TDIOCRegisters;
  cb: dword;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    Result := TRUE
  else begin
    regs.ESI := $0;
    regs.EDI := $0;                     //unnecessary?
    regs.Flags := CARRY_SET;            //set carry flag
    regs.EAX := IOCTL_GENERIC;          //Generic IOCTL function
    regs.EBX := Level shl 8 or DRIVE_C;
    regs.ECX := IOCTL_OSR2 or IOCTL_UNLOCK; //CH=$48:OSR2, CL=$6B:UNLOCK Physical Volume
    regs.EDX := $2;                     //write/map still enabled
    Result := DeviceIOControl(hDrive, VWIN32_DIOC_DIOS_IOCTL,
      @regs, SizeOf(regs), @regs, SizeOf(regs), cb, nil);
  end;
end;

function LockPhysVolume3(const hDrive: THandle): BOOL;
begin
  Result := LockPhysVolume(hDrive, 1) and LockPhysVolume(hDrive, 2) and
    LockPhysVolume(hDrive, 3);
end;

function UnLockPhysVolume3(const hDrive: THandle): BOOL;
begin
  Result := UnlockPhysVolume(hDrive, 3) and UnLockPhysVolume(hDrive, 2) and
    UnLockPhysVolume(hDrive, 1);
end;

function FSCTLLock(const hDrive: THandle): BOOL;
var
  cb: dword;
begin
  Result := DeviceIOControl(hDrive, FSCTL_LOCK_VOLUME, nil, 0, nil, 0, cb, nil);
end;

function FSCTLUnlock(const hDrive: THandle): BOOL;
var
  cb: dword;
begin
  Result := DeviceIOControl(hDrive, FSCTL_UNLOCK_VOLUME, nil, 0, nil, 0, cb, nil);
end;

function abs_INT21ReadSectors(const hDrive: THandle; Drive: byte; StartSector: dword; SectorsCount: word; Buf: pointer): Cardinal;
var
  regs: TDIOCRegisters;
  dio: TDiskIO;
begin
  dio.StartSector := StartSector;
  dio.Sectors := SectorsCount;
  dio.Buffer := dword(Buf);

  fillchar(regs, SizeOf(regs), 0);
  regs.EAX := IOCTL_EXT_ABS_DISKACCESS; // Ext_Abs_Disk_Read_Write
  regs.EBX := dword(@dio);
  regs.ECX := INVALID_RESULT;           // -1;
  regs.EDX := Drive + 3;                //  1-based INT21H-7305H, starts from A, 1=A, 2=B, 3=C

  CheckFlags := regs.Flags;
  if DeviceIOControl(hDrive, VWIN32_DIOC_DIOS_DRIVEINFO, @regs, SizeOf(regs), @regs, SizeOf(regs), Result, pOverlapped(0))
    and not BOOL(regs.Flags and CARRY_FLAG) then
    //Result := 0;
end;

function abs_INT21WriteSectors(const hDrive: THandle; Drive: byte; StartSector: dword; SectorsCount: word; Buf: pointer): Cardinal;
var
  regs: TDIOCRegisters;
  dio: TDiskIO;
  LockOK: Boolean;
begin
  LockOK := LockPhysVolume3(hDrive);
  if LockOK then begin
    dio.StartSector := StartSector;
    dio.Sectors := SectorsCount;
    dio.Buffer := dword(Buf);

    fillchar(regs, SizeOf(regs), 0);
    regs.EAX := IOCTL_EXT_ABS_DISKACCESS; // Ext_Abs_Disk_Read_Write
    regs.EBX := dword(@dio);
    regs.ECX := INVALID_RESULT;         //-1;
    regs.EDX := Drive + 3;              //  1-based INT21H-7305H, starts from A, 1=A, 2=B, 3=C
    regs.ESI := IOCTL_DATA_NORMALFILE;  // Normal file data

    //if Result then
    //  Result := Result and (not BOOL(regs.Flags and CARRY_FLAG));
    CheckFlags := regs.Flags;
    if DeviceIOControl(hDrive, VWIN32_DIOC_DIOS_DRIVEINFO, @regs, SizeOf(regs), @regs, SizeOf(regs), Result, pOverlapped(0))
      and not BOOL(regs.Flags and CARRY_FLAG) then
      //Result := 0;
  end
  else
    Result := INVALID_RESULT;
end;

function abs_INT25ReadLogicalSectors(const hDrive: THandle; Drive: byte; StartSector: dword; SectorsCount: word; Buf: pointer): Cardinal;
//INT25H-26H DID NOT WORK WITH FAT32
var
  regs: TDIOCRegisters;
  dio: TDiskIO;
begin
  dio.StartSector := StartSector;
  dio.Sectors := SectorsCount;
  dio.Buffer := dword(Buf);

  fillchar(regs, SizeOf(regs), 0);
  regs.EAX := Drive + 2;                // Logical, zero based 0=A, 1=B, 2=C; ???
  ;                                     //   we *ASSUME* that 2 = C = HardDisk0, and 3 = D = HardDisk1
  regs.EBX := dword(@dio);
  regs.ECX := $FFFF;                    // use DISKIO structure

  //if Result then
  //  Result := Result and (not BOOL(regs.Flags and CARRY_FLAG));
  if DeviceIOControl(hDrive, VWIN32_DIOC_DIOS_INT25, @regs, SizeOf(regs), @regs, SizeOf(regs), Result, pOverlapped(0))
    and not BOOL(regs.Flags and CARRY_FLAG) then
    //Result := 0;
end;

function abs_INT26WriteLogicalSectors(const hDrive: THandle; Drive: byte; StartSector: dword; SectorsCount: word; Buf: pointer): Cardinal;
//INT25H-26H DID NOT WORK WITH FAT32
var
  regs: TDIOCRegisters;
  dio: TDiskIO;
begin
  dio.StartSector := StartSector;
  dio.Sectors := SectorsCount;
  dio.Buffer := dword(Buf);

  fillchar(regs, SizeOf(regs), 0);
  regs.EAX := Drive + 2;                // idem...
  regs.EBX := dword(@dio);              //
  regs.ECX := $FFFF;

  //if Result then
  //  Result := Result and (not BOOL(regs.Flags and CARRY_FLAG));
  CheckFlags := regs.Flags;
  if DeviceIOControl(hDrive, VWIN32_DIOC_DIOS_INT26, @regs, SizeOf(regs), @regs, SizeOf(regs), Result, pOverlapped(0))
    and BOOL(regs.Flags and CARRY_FLAG) then
    //Result := 0;
end;

function abs_INT13ReadAbsSectors(const hDrive: THandle; Drive: byte; StartSector: dword; SectorsCount: word; Buf: pointer): Cardinal;
// still does not work yet :(
{
  INT13H; AH = 02h (read)
   AL = number of sectors to read (must be nonzero)
   CH = low eight bits of cylinder number
   CL = sector number 1-63 (bits 0-5)
        high two bits of cylinder (bits 6-7, hard disk only)
   DH = head number
   DL = drive number (bit 7 set for hard disk)
   ES:BX -> data buffer
}
var
  regs: TDIOCRegisters;
  dio: TDiskIO;
  pak: TDisk_Addr_pkt;
begin
  dio.StartSector := StartSector;
  dio.Sectors := SectorsCount;
  dio.Buffer := dword(Buf);

  fillchar(pak, SizeOf(pak), 0);
  pak.PacketSize := 16;                 //must be (at least) 16
  pak.BlockCount := sectorsCount;
  pak.BufferAddress := dword(Buf);
  pak.BlockStart := StartSector;

  fillchar(regs, SizeOf(regs), 0);

  if SectorsCount > 0 then              // AH and AL had to be validate
    regs.EAX := INT13H_READ + SectorsCount //mov AH,02 ; mov AL,Sectors
  else
    regs.EAX := INT13H_READ + 1;        //mov AH,02 ; mov AL,Sectors
  if StartSector > 0 then
    regs.ECX := StartSector             //CL Sector Number
  else
    regs.ECX := 1;                      //CH Cylinder Number, wiped off
  regs.EDX := DRIVE_C + Drive;          //DH = head no - cleared off
  regs.EBX := dword(Buf);               //dword(@dio);

  //if Result then
  //  Result := Result and (not BOOL(regs.Flags and CARRY_FLAG));
  CheckFlags := regs.Flags;
  if DeviceIOControl(hDrive, VWIN32_DIOC_DIOS_INT13, @regs, SizeOf(regs), @regs, SizeOf(regs), Result, pOverlapped(0))
    and BOOL(regs.Flags and CARRY_FLAG) then
    //Result := 0;
end;

function abs_INT13WriteAbsSectors(const hDrive: THandle; Drive: byte; StartSector: dword; SectorsCount: word; Buf: pointer): Cardinal;
// this too..
var
  regs: TDIOCRegisters;
  dio: TDiskIO;
begin
  dio.StartSector := StartSector;
  dio.Sectors := SectorsCount;
  dio.Buffer := dword(Buf);

  fillchar(regs, SizeOf(regs), 0);

  regs.EAX := DRIVE_C + Drive;
  regs.EBX := dword(@dio);
  regs.ECX := $FFFF;

  CheckFlags := regs.Flags;
  //if Result then
  //  Result := Result and (not BOOL(regs.Flags and CARRY_FLAG));
  if DeviceIOControl(hDrive, VWIN32_DIOC_DIOS_INT13, @regs, SizeOf(regs), @regs, SizeOf(regs), Result, pOverlapped(0))
    and boolean(regs.Flags and CARRY_FLAG) then
    //Result := 0;
end;
{
// unfinished business...
function abs_ReadTrack(const hDrive: THandle; Drive: byte; StartSector: dword; SectorsCount: word; Buf: pointer): Cardinal;
var
  regs: TDIOCRegisters;
  Block: TRWBlock;
begin
  Block.SpecFunc := 0;
  Block.Head := 0;
  Block.Cylinder := 0;
  Block.FirstSector := StartSector;
  Block.Sectors := SectorsCount;
  Block.Buffer := dword(Buf);

  fillchar(regs, SizeOf(regs), 0);
  regs.EAX := IOCTL_BLOCK_DEVICE;       // IOCTL for Block Device
  regs.EBX := Drive;
  regs.ECX := IOCTL_READ_TRACK;         // Read Track Win95 OSR2
  regs.EDX := dword(@Block);            // DTA

  //if Result then
  //  Result := Result and (not BOOL(regs.Flags and CARRY_FLAG));
  if DeviceIOControl(hDrive, VWIN32_DIOC_DIOS_IOCTL, @regs, SizeOf(regs), @regs, SizeOf(regs), Result, pOverlapped(0))
    and BOOL(regs.Flags and CARRY_FLAG) then
    //Result := 0;
end;

function abs_WriteTrack(const hDrive: THandle; Drive: byte; StartSector: dword; SectorsCount: word; Buf: pointer): Cardinal;
begin
  //unfinished?
  Result := INVALID_RESULT;
end;
}

function abs_NTRead(const hDrive: THandle; Drive: byte; StartSector: dword; SectorsCount: dword; Buf: pointer): Cardinal;
begin
  Result := SetFilePointer(hDrive, StartSector * SECTOR_SIZE, nil, FILE_BEGIN);
  if Result <> INVALID_RESULT then
    if FSCTLLock(hDrive) then begin
      ReadFile(hDrive, Buf^, SectorsCount * SECTOR_SIZE, Result, POverlapped(0));
      FSCTLUnlock(hDrive);
    end;
end;

function abs_NTWrite(const hDrive: THandle; Drive: byte; StartSector: Int64; SectorsCount: Int64; Buf: pointer): Cardinal;
begin
  Result := SetFilePointer(hDrive, StartSector * SECTOR_SIZE, nil, FILE_BEGIN);
  if Result <> INVALID_RESULT then
    if FSCTLLock(hDrive) then begin
      WriteFile(hDrive, Buf^, SectorsCount * SECTOR_SIZE, Result, POverlapped(0));
      FSCTLUnlock(hDrive);
    end;
end;

function GetWin32Platform: integer;
var
  OSVersionInfo: TOSVersionInfo;
begin
  OSVersionInfo.dwOSVersionInfoSize := SizeOf(OSVersionInfo);
  if GetVersionEx(OSVersionInfo) then
    Result := OSVersionInfo.dwPlatformId
  else
    Result := ERROR_APP_WRONG_OS;
end;

function abs_Read(const Drive: TvalidHardDiskNo = 0; const RWMethod: TAbsRWMethod = rwAuto; const StartSector: dword = 0; SectorsCount: dword = 1; const Buffer: pointer = nil): Cardinal;
var
  hDrive: THandle;
  Buf: pointer;
  LockOK: Boolean;
begin
  Result := INVALID_RESULT;
  hDrive := GetDriveHandle(Drive);
  if hDrive <> INVALID_HANDLE_VALUE then begin
    try
      if Buffer <> nil then
        Buf := Buffer
      else
        getMem(buf, SectorsCount * SECTOR_SIZE);
      try
        LockOK := LockPhysVolume3(hDrive);
        if LockOK then begin
          try
            case RWMethod of
              rwINT13H: Result := abs_INT13ReadAbsSectors(hDrive, Drive, StartSector, SectorsCount, Buf);
              rwINT21H: Result := abs_INT21ReadSectors(hDrive, Drive, StartSector, SectorsCount, Buf);
              rwINT25H, rwINT26H: Result := abs_INT25ReadLogicalSectors(hDrive, Drive, StartSector, SectorsCount, Buf);
              rwNTFile: Result := abs_NTRead(hDrive, Drive, StartSector, SectorsCount, Buf);
              else begin
                  if Win32Platform = VER_PLATFORM_WIN32_NT then
                    Result := abs_NTRead(hDrive, Drive, StartSector, SectorsCount, Buf)
                  else begin
                    Result := abs_INT25ReadLogicalSectors(hDrive, Drive, StartSector, SectorsCount, Buf);
                    if Result = INVALID_RESULT then
                      Result := abs_INT21ReadSectors(hDrive, Drive, StartSector, SectorsCount, Buf);
                    if Result = INVALID_RESULT then
                      Result := abs_INT13ReadAbsSectors(hDrive, Drive, StartSector, SectorsCount, Buf);
                    if Result = INVALID_RESULT then
                      Result := abs_NTRead(hDrive, Drive, StartSector, SectorsCount, Buf);
                  end;
                end;
            end
          finally
            UnLockPhysVolume3(hDrive);
          end
        end
      finally
        if Buffer = nil then
          freemem(Buf);
      end;
    finally
      CloseHandle(hDrive);
    end;
  end;
  //ShowMsgOK(blocks(bin(Result), 4))
end;

function abs_Write(const Drive: TvalidHardDiskNo = 0; const RWMethod: TAbsRWMethod = rwAuto; const StartSector: dword = 1; SectorsCount: dword = 1; const Buffer: pointer = nil): Cardinal;
var
  hDrive: THandle;
  Buf: pointer;
  LockOK: Boolean;
begin
  Result := INVALID_RESULT;
  hDrive := GetDriveHandle(Drive);
  if hDrive <> INVALID_HANDLE_VALUE then begin
    try
      if Buffer <> nil then
        Buf := Buffer
      else
        getMem(Buf, SectorsCount * SECTOR_SIZE);
      try
        LockOK := LockPhysVolume3(hDrive);
        if LockOK then begin
          try
            case RWMethod of
              rwINT13H: Result := abs_INT13WriteAbsSectors(hDrive, Drive, StartSector, SectorsCount, Buf);
              rwINT21H: Result := abs_INT21WriteSectors(hDrive, Drive, StartSector, SectorsCount, Buf);
              rwINT25H, rwINT26H: Result := abs_INT26WriteLogicalSectors(hDrive, Drive, StartSector, SectorsCount, Buf);
              rwNTFile: Result := abs_NTWrite(hDrive, Drive, StartSector, SectorsCount, Buf);
              else begin                //rwAuto
                  if Win32Platform = VER_PLATFORM_WIN32_NT then
                    Result := abs_NTWrite(hDrive, Drive, StartSector, SectorsCount, Buf)
                  else begin
                    Result := abs_INT13WriteAbsSectors(hDrive, Drive, StartSector, SectorsCount, Buf);
                    if Result = INVALID_RESULT then
                      Result := abs_INT21WriteSectors(hDrive, Drive, StartSector, SectorsCount, Buf);
                    if Result = INVALID_RESULT then
                      Result := abs_INT26WriteLogicalSectors(hDrive, Drive, StartSector, SectorsCount, Buf);
                    if Result = INVALID_RESULT then
                      Result := abs_NTWrite(hDrive, Drive, StartSector, SectorsCount, Buf);
                  end
                end;
            end;
          finally
            UnLockPhysVolume3(hDrive);
          end;
        end
      finally
        if Buffer = nil then
          freemem(Buf);
      end;
    finally
      CloseHandle(hDrive);
    end;
  end;
end;

initialization;
  Win32Platform := GetWin32Platform;

end.


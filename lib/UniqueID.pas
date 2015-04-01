unit UniqueID;
{
  library to get various unique client's hardware identifier
  - BIOS
  - Hard-Disk
  - Network Card

  works under Win32, non-privileged account

  Copyright 2005-2007, aa, Adrian H. & Ray AF.
  aa@softindo.net
  http://www.google.com/search?q=aa+delphi

  Private property of PT Softindo, JAKARTA.
  All rights reserved.

  Credits/References:
    BIOSHelp by Nico Bendlin <nicode@gmx.net>
    IsAdmin (unknown author) from torry.net's tips/tricks
    DMTF Specification 2.4, July 2004. http://www.dmtf.org
}

interface

{ helper routines }
function isAdmin: boolean;
function isWinNT: boolean;

{ helper routines }
//- not used here -
function isWin9X: boolean;
function WinVersion: int64; // high: majorVersion; low: minorVersion
function WinVersionMajor: integer;
function WinVersionMinor: integer;
function WinBuildNumber: integer;
function WinPlatformID: integer;
function WinCSDVersion: string;

{ helper routine: convert TGUID to Hex-string }
function GUIDtoHex(const GUID: TGUID): string;

{ get Universal Unique Identifier of CPU }
function getCPUID: TGUID; // tguid
function getCPUIDHex: string; // hexadecimal string

{ Dump all SMBIOS structures (including Table Entry Point)         }
{ Result is Dump size;                                             }
{ note: arg Dump must be a valid pointer, initialized first or nil }
function getSMBIOSInfo(var Buffer: pointer): integer;

{ Get Manufacturer Serial Number, Firmware Rev and Model Number of }
{ either first or all disks; in 68 bytes/chars unformatted string  }
{ note:                                                            }
{ this implementation ONLY get Manufacturer Serial Number, Result  }
{ string also trimmed, which should NEVER be done if more than one }
{ information requested                                            }
{ see further description below                                    }

function GetHardDiskInfo(const FindAll: boolean = FALSE;
  const ListDelimiter: string = ^J): string;

{ Get Network Card Device Info }
type
  TNICInfoType = (nitDeviceNumber, nitMacAddress, nitIPAdress, nitIPNetMask);
  NICInfoTypes = set of TNICInfoType;

function ReadNICDeviceInfo(const InfoType: TNICInfoType;
  const NICIndex: integer = 0): string; overload;
function ReadNICDeviceInfo(const InfoType: NICInfoTypes;
  const NICIndex: integer = 0; const ListDelimiter: string = ^j): string; overload;

implementation
uses Windows;

{ helper routines }

const
{$IFOPT J-}{$DEFINE J_OFF}{$J+}{$ENDIF}
  OSVerInfo: TOSVersionInfo = (dwOSVersionInfoSize: dword(-1));
{$IFDEF J_OFF}{$J-}{$ENDIF}

procedure __initWinVer;
begin
  with OSVerInfo do
    if dwOSVersionInfoSize <> dword(-1) then
      exit
    else
      dwOSVersionInfoSize := sizeof(OSVerInfo);
  GetVersionEx(OSVerInfo);
end;

function isWinNT: boolean;
asm
  call __initWinVer;
  mov edx,OSVerInfo.dwPlatformID; xor eax,eax;
  cmp edx,VER_PLATFORM_WIN32_NT; sete al
end;

function isWin9X: boolean; asm call isWinNT; xor eax,1 end;

function WinVersion: int64;
asm
  call __initWinVer;
  mov eax,OSVerInfo.dwMajorVersion
  mov edx,OSVerInfo.dwMinorVersion
end;

function WinVersionMajor: integer; asm jmp WinVersion end;
function WinVersionMinor: integer; asm call WinVersion; xchg eax,edx end;
function WinBuildNumber: integer; asm call __initWinVer; mov eax,OSVerInfo.dwBuildNumber end;
function WinPlatformID: integer; asm call __initWinVer; mov eax,OSVerInfo.dwPlatformID end;

function WinCSDVersion: string;
begin
  __initWinVer;
  Result := string(PChar(@OSVerInfo.szCSDVersion));
end;

function isAdmin: Boolean;
const
  //ERROR_NO_TOKEN = 1008;
  SECURITY_BUILTIN_DOMAIN_RID = $00000020;
  DOMAIN_ALIAS_RID_ADMINS = $00000220;
  SECURITY_NT_AUTHORITY: TSIDIdentifierAuthority = (Value: (0, 0, 0, 0, 0, 5));
const
  INVALID = INVALID_HANDLE_VALUE xor $19091969 or 1;
{$IFOPT J-}{$DEFINE J_OFF}{$J+}{$ENDIF}
  fIsAdmin: cardinal = INVALID;
{$IFDEF J_OFF}{$J-}{$ENDIF}
var
  i: integer;
  bSuccess: longbool;
  hAccessToken: THandle;
  ptgGroups: PTokenGroups;
  dwInfoBufferSize: DWORD;
  pSIDAdministrators: PSID;
begin
  Result := boolean(fIsAdmin);
  if fIsAdmin <> INVALID then exit;
  if not isWinNT then exit;
  fIsAdmin := 0;
  //Result := FALSE;
  bSuccess := OpenThreadToken(GetCurrentThread, TOKEN_QUERY, TRUE, hAccessToken);
  if not bSuccess then begin
    if GetLastError = ERROR_NO_TOKEN then
      bSuccess := OpenProcessToken(GetCurrentProcess, TOKEN_QUERY, hAccessToken);
  end;
  if bSuccess then begin
    getMem(ptgGroups, 1024);
    bSuccess := GetTokenInformation(hAccessToken, TokenGroups,
      ptgGroups, 1024, dwInfoBufferSize);
    CloseHandle(hAccessToken);
    if bSuccess then begin
      AllocateAndInitializeSID(SECURITY_NT_AUTHORITY, 2,
        SECURITY_BUILTIN_DOMAIN_RID, DOMAIN_ALIAS_RID_ADMINS,
        0, 0, 0, 0, 0, 0, pSIDAdministrators);
{$IFOPT R+}{$DEFINE R_ON}{$R-}{$ENDIF}
      for i := 0 to ptgGroups.GroupCount - 1 do
        if EqualSID(pSIDAdministrators, ptgGroups.Groups[i].SID) then begin
          //Result := TRUE;
          fIsAdmin := 1;
          Break;
        end;
{$IFDEF R_ON}{$R+}{$ENDIF}
      FreeSID(pSIDAdministrators);
    end;
    freeMem(ptgGroups);
  end;
  Result := boolean(fIsAdmin);
end;

//internal/private 16 Bit DOS dumper
{ internal routines }

function _mkDOSDumper(const Filename: string): boolean;
const
  MZHeader: array[1..8] of integer = (
    $01195A4D, 1, 2, $FFFF, $400, $E8, 0, 0
    );

  //SMDumper1: array[1..$100 div 4 - 1] of dword = (
  //  // scans lo to hi; 0000 to ffffh
  //  $26A9850D, $3836BAA2, $B932AB10, $3737B4B9,
  //  $18171890, $85069817, $3CB837A1, $3433B4B9,
  //  $B194103A, $18191014, $98169A18, $2090161B,
  //  $30B4B932, $30A41037, $343D34B3, $B0850697,
  //  $37B9A030, $3734BA33, $B71737B2, $06853A32,
  //  $B0B9AA85, $849D32B3, $BAA226A9, $1F103836,
  //  $B634B310, $E0189232, $A25A6D98, $B910E6A1,
  //  $12684489, $BAC11E41, $00805D05, $10E684DA,
  //  $ACF598D8, $6F477B18, $77406D46, $507F4008,
  //  $ED477739, $2A458245, $08634181, $AF9AF53B,
  //  $A6F940A9, $BAE804AF, $456498F5, $41AB7AA6,
  //  $79448877, $F1620056, $F2422F7D, $1058EB3A,
  //  $90E6A05A, $45832645, $2245842A, $87F04185,
  //  $47067060, $E6A05A6C, $75E01890, $E6A65A00,
  //  $D0D1AD10, $C3FAE2AB, $68006668, $C93100E1,
  //  $B10101BF, $FCFE8970, $C3
  //  );

  SMDumper2: array[1..$100 div 4 - 1] of dword = (
    // scans hi to lo; ffffh to 0000 ; better/faster
    $26A9850D, $3836BAA2, $B932AB10, $3737B4B9,
    $18171890, $85069817, $3CB837A1, $3433B4B9,
    $B194103A, $18191014, $98169A18, $2090161B,
    $30B4B932, $30A41037, $343D34B3, $B0850697,
    $37B9A030, $3734BA33, $B71737B2, $06853A32,
    $B0B9AA85, $849D32B3, $BAA226A9, $1F103836,
    $B634B310, $E0189232, $A25A6D98, $B910E6A1,
    $12684489, $BAC11E41, $00805D05, $10E684DA,
    $ACF598D8, $6F477B18, $77406D46, $507F4008,
    $ED477739, $2A458245, $08774181, $AF9AF53A,
    $A6F940A9, $BAE804AF, $456498F5, $41AB0AA6,
    $79448863, $F1620056, $F2422F7D, $1058EB3A,
    $90E6A05A, $45932645, $2245942A, $87F04195,
    $47067060, $E6A05A6C, $75E01890, $E6A65A00,
    $D0D1AD10, $C3FAE2AB, $68006668, $C93100E1,
    $B10101BF, $FCFE8970, $C3
    );
var
  h: thandle;
  cb: cardinal;
begin
  Result := FALSE;
  h := CreateFile(PChar(Filename), GENERIC_WRITE, FILE_SHARE_READ, nil,
    CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
  if h <> INVALID_HANDLE_VALUE then try
    Result := WriteFile(h, MZHeader, SizeOf(MZHeader), cb, nil);
    Result := Result and WriteFile(h, SMDumper2, SizeOf(SMDumper2), cb, nil);
    if not Result then
      DeleteFile(PChar(Filename));
  finally
    CloseHandle(h);
  end;
end;

function _execDOSDumper(const exec, dump: string; Timeout: DWORD): Boolean;
var
  ComSpec: string;
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
  ErrorMode: Cardinal;
begin
  Result := FALSE;
  SetLength(ComSpec, MAX_PATH + 1);
  SetLength(ComSpec, GetEnvironmentVariable('ComSpec', PChar(@ComSpec[1]), MAX_PATH));
  if Length(ComSpec) < 1 then Exit;
  fillChar(StartInfo, SizeOf(TStartupInfo), 0);
  StartInfo.cb := SizeOf(TStartupInfo);
  StartInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartInfo.wShowWindow := SW_HIDE;
  ErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS or SEM_NOGPFAULTERRORBOX or
    SEM_NOALIGNMENTFAULTEXCEPT or SEM_NOOPENFILEERRORBOX);
  try
    // delphindo formatter is buggy stupid :((
    ComSpec := ComSpec + ' /C ' + exec + ' '#62' ' + Dump;
    if CreateProcess(nil, PChar(ComSpec), nil, nil,
      FALSE, HIGH_PRIORITY_CLASS, nil, nil, StartInfo, ProcInfo) then try
      Result := not (WaitForSingleObject(ProcInfo.hProcess, Timeout) = WAIT_TIMEOUT);
      if not Result then
        TerminateProcess(ProcInfo.hProcess, STATUS_TIMEOUT);
    finally
      CloseHandle(ProcInfo.hThread);
      CloseHandle(ProcInfo.hProcess);
    end;
  finally
    SetErrorMode(ErrorMode);
  end;
end;

function SMDump16(var Buffer: pointer): integer;
const
  timeout: integer = 5000;
var
  tmp: array[0..MAX_PATH] of Char;
  dmp: array[0..MAX_PATH] of Char;
  exe: array[0..MAX_PATH] of Char;
  h: THandle;
  cb: Cardinal;
  Size: integer;
begin
  Result := 0;
  if GetTempPath(MAX_PATH, tmp) > 0 then
    GetShortPathName(tmp, tmp, MAX_PATH)
  else
    lstrcpy(tmp, '.');
  if GetTempFileName(tmp, '~rdmp', 0, dmp) > 0 then try
    LStrCpy(exe, dmp);
    LStrCat(exe, '.exe'); // Win9x requires .exe extension
    if _mkDOSDumper(exe) then try
      if _execDOSDumper(exe, dmp, timeout) then begin
        h := CreateFile(dmp, GENERIC_READ, FILE_SHARE_READ or
          FILE_SHARE_WRITE, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
        if h <> INVALID_HANDLE_VALUE then try
          Size := getfileSize(h, nil);
          ReallocMem(Buffer, Size);
          if (Size > 0) and ReadFile(h, Buffer^, Size, cb, nil) and
            (cb = cardinal(Size)) then
            Result := Size
        finally
          CloseHandle(h);
        end;
      end;
    finally
      DeleteFile(exe);
    end;
  finally
    DeleteFile(dmp);
  end;
end;

// Generic locator:

function C0000_Dump(const CBase: pointer; const Size: integer; var Buffer: pointer): integer;
// C000:0000h dumper; CBase must contain data of at segment C000:0000H
// (to be synced with SMBIOS entry point)
// Size at least 1 page (4096 bytes), paragraph folded (16 bytes).
asm
  test eax,eax; jnz @@Start; ret
@@Start:
  push ebx; mov ebx,Buffer
  push esi; mov esi,CBase
  and Size,not 15; xor ecx,ecx;// min. paragraph boundary!
  cmp Size,1000h; jb @@done
  add edx,esi; //xor ecx,ecx
  @@LSeek:
    mov eax,[edx-10h]; sub edx,10h;
    cmp edx,esi; jb @@done
    cmp eax,'_MS_'; // NOT '_SM_' !!!
    jnz @@LSeek

  movzx ecx,[edx+5];
  xor eax,eax;
  @@ck: mov al,[edx+ecx-1]; add ah,al; dec ecx; jnz @@ck
  test ah,ah; jnz @@LSeek

  @@found:
    add esi,edx+18h; // struct0 address
    movzx ecx,word [edx+16h]; // count
    sub esi,0c0000h; // c000:0000 offset
    push ecx; add ecx,20h;
    push edx; mov edx,ecx;
    mov eax,ebx;
    call System.@ReallocMem
    xor ecx,ecx; pop ebx;
    mov cl,20h/4
    @@LCp: mov edx,[ebx]; add ebx,4
           mov [eax],edx; add eax,4
           dec ecx; jnz @@LCp
    mov ecx,[esp];
    shr ecx,2; jz @@mvb
    @@L4: mov edx,[esi]; add esi,4
          mov [eax],edx; add eax,4
          dec ecx; jnz @@L4
    @@mvb: mov ecx,[esp]; and ecx,3; jz @@LCdone
    @@L1: mov dl,[esi]; inc esi
          mov [eax],dl; inc eax
          dec ecx; jnz @@L1
    @@LCdone:
    pop ecx; add ecx,20h

  @@done: mov eax,ecx
  pop esi; pop ebx;
end;

function SMDump9x(var Buffer: pointer): integer;
const
  C0000h: cardinal = $0C0000;
var
  CSeg: pointer absolute C0000h;
begin
  try
    Result := C0000_Dump(CSeg, $10000 * 4, Buffer);
  except
    Result := SMDump16(Buffer);
  end;
end;

type
  NTSTATUS = Integer;
  PUnicodeString = ^TUnicodeString;
  TUnicodeString = packed record
    Length: Word;
    MaximumLength: Word;
    Buffer: PWideChar;
  end;
  PObjectAttributes = ^TObjectAttributes;
  TObjectAttributes = record
    Length: ULONG;
    RootDirectory: THandle;
    ObjectName: PUnicodeString;
    Attributes: ULONG;
    SecurityDescriptor: PSecurityDescriptor;
    SecurityQualityOfService: PSecurityQualityOfService;
  end;
  TfnZwOpenSection = function(out Section: THandle; Access: ACCESS_MASK;
    Attributes: PObjectAttributes): NTSTATUS; stdcall;
  TfnRTLNTStatusToDOSError = function(Status: NTSTATUS): DWORD; stdcall;

const
  PhysMemDevName = '\Device\PhysicalMemory';
  PhysMemName: TUnicodeString = (
    Length: Length(PhysMemDevName) * SizeOf(WideChar);
    MaximumLength: Length(PhysMemDevName) * SizeOf(WideChar) + SizeOf(WideChar);
    Buffer: PhysMemDevName;
    );
  PhysMemMask: ACCESS_MASK = SECTION_MAP_READ;
  PhysMemAttr: TObjectAttributes = (
    Length: SizeOf(TObjectAttributes);
    RootDirectory: 0;
    ObjectName: @PhysMemName;
    Attributes: $00000040; // OBJ_CASE_INSENSITIVE
    SecurityDescriptor: nil;
    SecurityQualityOfService: nil;
    );
var
  ZwOpenSection: TfnZwOpenSection;
  NTStatusToDOS: TfnRTLNtStatusToDOSError;

function SMDumpAdmin(var Buffer: pointer): integer;
const
  ROMBase = $C0000;
  ROMSize = $10000 * 4;
var
  h: thandle;
  View: pointer;
  hmod: HMODULE;
  Status: NTSTATUS;
begin
  Result := 0;
  HMod := GetModuleHandle('ntdll.dll');
  if HMod = 0 then
    SetLastError(ERROR_CALL_NOT_IMPLEMENTED)
  else begin
    if not Assigned(ZwOpenSection) then
      ZwOpenSection := GetProcAddress(HMod, 'ZwOpenSection');
    if not Assigned(NTStatusToDOS) then
      NTStatusToDOS := GetProcAddress(HMod, 'RtlNtStatusToDosError');
    if not Assigned(ZwOpenSection) or not Assigned(NTStatusToDOS) then
      SetLastError(ERROR_CALL_NOT_IMPLEMENTED)
    else begin
      Status := ZwOpenSection(h, PhysMemMask, @PhysMemAttr);
      //if Status >= 0 then try
      if Status <> -1 then try
        View := MapViewOfFile(h, PhysMemMask, 0, Cardinal(ROMBase), ROMSize);
        if View <> nil then try
          Result := C0000_Dump(View, ROMSize, Buffer);
        finally
          UnmapViewOfFile(View);
        end;
      finally
        CloseHandle(h);
      end
      else
        SetLastError(NTStatusToDOS(Status));
    end;
  end;
end;

{ public functions }

function getSMBIOSInfo(var Buffer: pointer): integer;
var
  VerInfo: TOSVersionInfo;
begin
  VerInfo.dwOSVersionInfoSize := sizeof(VerInfo);
  GetVersionEx(VerInfo);
  if VerInfo.dwPlatformId <> VER_PLATFORM_WIN32_NT then
    Result := SMDump9x(Buffer)
  //else if isAdmin then
  //  Result := SMDumpAdmin(Buffer)
  else
    Result := SMDump16(Buffer)
end;

function getCPUID: TGUID;
asm
  push ebx; xor ecx,ecx;
  mov ebx,Result; push ecx;
  mov eax+00,ecx; mov eax+04,ecx;
  mov eax+08,ecx; mov eax+12,ecx;

  mov eax,esp; call getSMBIOSInfo;
  mov edx,[esp]; add eax,edx
  add edx,20h;

  @@scan01: xor ecx,ecx; cmp edx,eax; jnb @@done
  mov cl,[edx]; cmp ecx,1; jz @@got1
  mov cl,[edx+1]; add edx,ecx;

  @@scan2z: mov cx,[edx]; add edx,2;
  test ecx,ecx; jnz @@scan2z
  jmp @@scan01

  @@got1:
    mov eax,[edx+8+00]; mov ecx,[edx+8+04];
    mov [ebx+0+00],eax; mov [ebx+0+04],ecx
    mov eax,[edx+8+08]; mov ecx,[edx+8+12];
    mov [ebx+0+08],eax; mov [ebx+0+12],ecx

  @@done:
  pop eax; call System.@FreeMem;
  mov eax,ebx; pop ebx;
end;

const
  hex: array[0..16] of char = '0123456789ABCDEF';

function GUIDtoHex(const GUID: TGUID): string;
asm
  push esi; mov esi,eax;
  mov eax,edx; call System.@LStrClr
  push 16*2; pop edx; call System.@LStrSetLength;
  push 16; pop ecx;
  push ebx; mov ebx,[eax];
  xor eax,eax; xor edx,edx;
  @@Loop:
    mov al,[esi]; shr eax,04;
    mov dl,[esi]; and edx,15; add esi,1;
    mov al,eax+hex; mov dl,edx+hex
    mov [ebx],al; mov [ebx+1],dl; add ebx,2
    sub ecx,1; jnz @@Loop
  pop ebx; pop esi;
end;

function getCPUIDHex: string;
const
  GUID: TGUID = ();
asm
  push eax; lea eax,GUID; call getCPUID;
  pop edx; jmp GUIDtoHex
end;

{
  GetHardDiskInfo: unformatted harddisk Info

  Copyright 2005-2007, aa, Adrian H. & Ray AF.
  aa@softindo.net
  http://www.google.com/search?q=aa+delphi

  Private property of PT Softindo, JAKARTA.
  All rights reserved.

  Credits/references:
    IDEInfo2 by Alex Konshin, alexk@mtgroup.ru
    THDDInfo by Artem V. Parlyuk, artsoft@nm.ru, http://artsoft.nm.ru
    MSDN, IOCTL.

  Returns fixed length table of
    Serial Number:	20 chars
    Firmware Rev.:	 8 chars
    Model Number:	  40 chars
                    --------
                    68 chars

  Caution: Result is unformatted. spaces might appear in either side
  as result of our PC below:

        |Serial Number       |FirmRev.|Model Number                            |
  ------|--------------------|--------|----------------------------------------|
  Disk0 |Y3MADY9E            |YAR51EW0|Maxtor 6Y120M0                          |
  Disk1 |     WD-WCAMR2088490|08.05J08|WDC WD3200JD-22KLB0                     |
  ------|--------------------|--------|----------------------------------------|
        |12345678901234567890|12345678|9012345678901234567890123456789012345678|

}

function GetHardDiskInfo(const FindAll: boolean = FALSE;
  const ListDelimiter: string = ^J): string;
type
  TSrbIOControl = packed record
    HeaderLength: ULONG;
    Signature: array[0..7] of Char;
    Timeout, ControlCode, ReturnCode, Length: ULONG;
  end;
  SRB_IO_CONTROL = TSrbIOControl;
  PSrbIOControl = ^TSrbIOControl;

  TIDERegs = packed record
    bFeaturesReg: byte; // Used for specifying SMART "commands".
    bSectorCountReg: byte; // IDE sector count register
    bSectorNumberReg: byte; // IDE sector number register
    bCylLowReg: byte; // IDE low order cylinder value
    bCylHighReg: byte; // IDE high order cylinder value
    bDriveHeadReg: byte; // IDE drive/head register
    bCommandReg: byte; // Actual IDE command.
    bReserved: byte; // reserved for future use.  Must be zero.
  end;
  IDEREGS = TIDERegs;
  PIDERegs = ^TIDERegs;

  TSendCmdInParams = packed record
    cBufferSize: DWORD; // Buffer size in bytes
    irDriveRegs: TIDERegs; // Structure with drive register values.
    bDriveNumber: byte; // Physical drive number to send command to (0,1,2,3).
    bReserved: array[0..2] of byte; // Reserved for future expansion.
    dwReserved: array[0..3] of DWORD; // For future use.
    bBuffer: array[0..0] of byte; // Input buffer.
  end;
  SENDCMDINPARAMS = TSendCmdInParams;
  PSendCmdInParams = ^TSendCmdInParams;

type
  TDriverStatus = packed record
    bDriverError: byte; // Error code from driver, or 0 if no error.
    bIDEStatus: byte; // Contents of IDE Error register.
                                     // Only valid when bDriverError is SMART_IDE_ERROR.
    bReserved: array[0..1] of byte; // Reserved for future expansion.
    dwReserved: array[0..1] of DWORD; // Reserved for future expansion.
  end;
  DRIVERSTATUS = TDriverStatus;
  PDriverStatus = ^TDriverStatus;
  LPDriverStatus = TDriverStatus;
  _DRIVERSTATUS = TDriverStatus;

type
  TSendCmdOutParams = packed record
    cBufferSize: DWORD; // Size of bBuffer in bytes
    DriverStatus: TDriverStatus; // Driver status structure.
    bBuffer: array[0..0] of byte; // Buffer of arbitrary length in which
                                     // to store the data read from the drive.
  end;
  SENDCMDOUTPARAMS = TSendCmdOutParams;
  PSendCmdOutParams = ^TSendCmdOutParams;
  LPSendCmdOutParams = PSendCmdOutParams;
  _SENDCMDOUTPARAMS = TSendCmdOutParams;

type
  TIDSector = packed record
    wGenConfig: word;
    wNumCyls, wReserved, wNumHeads: word;
    wBytesPerTrack, wBytesPerSector, wSectorsPerTrack: word;
    wVendorUnique: array[0..2] of Word;
    sSerialNumber: array[0..19] of Char;
    wBufferType, wBufferSize, wECCSize: word;
    sFirmwareRev: array[0..7] of Char;
    sModelNumber: array[0..39] of Char;
    wMoreVendorUnique, wDoubleWordIO, wCapabilities: word;
    wReserved1, wPIOTiming, wDMATiming: word;
    wBS: word;
    wNumCurrentCyls, wNumCurrentHeads, wNumCurrentSectorsPerTrack: word;
    ulCurrentSectorCapacity: ULONG;
    wMultSectorStuff: word;
    ulTotalAddressableSectors: ULONG;
    wSingleWordDMA, wMultiWordDMA: word;
    bReserved: array[0..127] of byte;
  end;
  PIDSector = ^TIDSector;

const
  IDENTIFY_BUFFER_SIZE = 512;
  IOCTL_SCSI_MINIPORT = $0004D008;
  IOCTL_SCSI_MINIPORT_IDENTIFY = $001B0501;
  DFP_RECEIVE_DRIVE_DATA = $0007C088;

  //-------------------------------------------------------------
  // SmartIdentifyDirect
  //
  // FUNCTION: Send an IDENTIFY command to the drive bDriveNum = 0-3
  // bIDCmd = IDE_ID_FUNCTION or IDE_ATAPI_ID
  //
  // Note: work only with IDE device handle.

  function SmartIdentifyDirect(hDevice: THandle; bDriveNum: byte;
    bIDCmd: byte; var IDSector: TIDSector; var IDSectorSize: LongInt): BOOL;
  const
    BufferSize = sizeof(TSendCmdOutParams) + IDENTIFY_BUFFER_SIZE - 1;
  var
    SCIP: TSendCmdInParams;
    Buffer: array[0..BufferSize - 1] of byte;
    SCOP: TSendCmdOutParams absolute Buffer;
    dwBytesReturned: DWORD;
  begin
    FillChar(SCIP, sizeof(TSendCmdInParams) - 1, #0);
    FillChar(Buffer, BufferSize, #0);
    dwBytesReturned := 0;
    IDSectorSize := 0;
    // Set up data structures for IDENTIFY command.
    with SCIP do begin
      cBufferSize := IDENTIFY_BUFFER_SIZE;
      bDriveNumber := bDriveNum;
      with irDriveRegs do begin
        bFeaturesReg := 0;
        bSectorCountReg := 1;
        bSectorNumberReg := 1;
        bCylLowReg := 0;
        bCylHighReg := 0;
        bDriveHeadReg := $A0 or ((bDriveNum and 1) shl 4);
        // the command below can either be IDE identify or ATAPI identify.
        bCommandReg := bIDCmd;
      end;
    end;
    Result := DeviceIOControl(hDevice, DFP_RECEIVE_DRIVE_DATA, @SCIP,
      sizeof(TSendCmdInParams) - 1, @SCOP, BufferSize, dwBytesReturned, nil);
    if Result = TRUE then begin
      IDSectorSize := dwBytesReturned - sizeof(TSendCmdOutParams) + 1;
      if IDSectorSize <= 0 then
        IDSectorSize := 0
      else
        System.Move(SCOP.bBuffer, IDSector, IDSectorSize);
    end;
  end;

  //-------------------------------------------------------------
  // Same as above, except:
  //  - work only NT;
  //  - work with cotroller or device handle.
  // Note: Administrator priveleges are not required to open controller handle.

  function SmartIdentifyMiniport(hDevice: THandle; bTargetID: byte;
    bIDCmd: byte; var IDSector: TIDSector; var IDSectorSize: LongInt): BOOL;
  const
    DataLength = sizeof(TSendCmdInParams) - 1 + IDENTIFY_BUFFER_SIZE;
    BufferLength = sizeof(SRB_IO_CONTROL) + DataLength;
  var
    cbBytesReturned: DWORD;
    pData: PSendCmdInParams;
    Buffer: array[0..BufferLength] of byte;
    srbControl: TSrbIoControl absolute Buffer;
  begin
    // fill in srbControl fields
    FillChar(Buffer, BufferLength, #0);
    srbControl.HeaderLength := sizeof(SRB_IO_CONTROL);
    System.Move('SCSIDISK', srbControl.Signature, 8);
    srbControl.Timeout := 2;
    srbControl.Length := DataLength;
    srbControl.ControlCode := IOCTL_SCSI_MINIPORT_IDENTIFY;
    pData := PSendCmdInParams(PChar(@Buffer) + sizeof(SRB_IO_CONTROL));
    with pData^ do begin
      cBufferSize := IDENTIFY_BUFFER_SIZE;
      bDriveNumber := bTargetID;
      with irDriveRegs do begin
        bFeaturesReg := 0;
        bSectorCountReg := 1;
        bSectorNumberReg := 1;
        bCylLowReg := 0;
        bCylHighReg := 0;
        bDriveHeadReg := $A0 or ((bTargetID and 1) shl 4);
        // the command below can either be IDE identify or ATAPI identify.
        bCommandReg := bIDCmd;
      end;
    end;
    Result := DeviceIOControl(hDevice, IOCTL_SCSI_MINIPORT, @Buffer,
      BufferLength, @Buffer, BufferLength, cbBytesReturned, nil);
    if Result = TRUE then begin
      IDSectorSize := cbBytesReturned - sizeof(SRB_IO_CONTROL) -
        sizeof(TSendCmdOutParams) + 1;
      if IDSectorSize <= 0 then
        IDSectorSize := 0
      else begin
        if IDSectorSize > IDENTIFY_BUFFER_SIZE then
          IDSectorSize := IDENTIFY_BUFFER_SIZE;
        System.Move(PSendCmdOutParams(pData)^.bBuffer, IDSector, IDSectorSize);
      end;
    end;
  end;

type
{$ALIGN ON} // MUST be aligned!
  TSCSIBusData = record
    NumberOfLogicalUnits, InitiatorBusID: byte;
    InquiryDataOffset: ULONG;
  end;
  SCSI_BUS_DATA = TSCSIBusData;
  PSCSIBusData = ^TSCSIBusData;
type
{$ALIGN ON} // MUST be aligned!
  TSCSIAdapterBusInfo = record
    NumberOfBuses: byte;
    BusData: array[0..0] of SCSI_BUS_DATA;
  end;
  SCSI_ADAPTER_BUS_INFO = TSCSIAdapterBusInfo;
  PSCSIAdapterBusInfo = ^TSCSIAdapterBusInfo;
{$ALIGN OFF}
type
{$ALIGN ON} // MUST be aligned!
  TSCSIInquiryData = record
    PathID, TargetID, Lun: Byte;
    DeviceClaimed: Boolean;
    InquiryDataLength, NextInquiryDataOffset: ULONG;
    InquiryData: array[0..0] of byte;
  end;
  SCSI_INQUIRY_DATA = TSCSIInquiryData;
  PScsiInquiryData = ^TSCSIInquiryData;
{$ALIGN OFF}

  function GetSCSIInquiryData(hDevice: THandle;
    var InquiryData: TSCSIAdapterBusInfo; var dwSize: DWORD): BOOL;
  const
    FILE_DEVICE_CONTROLLER = $00000004;
    FILE_ANY_ACCESS = 0;
    METHOD_BUFFERED = 0;
    IOCTL_SCSI_BASE = FILE_DEVICE_CONTROLLER;
    IOCTL_SCSI_GET_INQUIRY_DATA = (IOCTL_SCSI_BASE shl 16) or
      (FILE_ANY_ACCESS shl 14) or ($0403 shl 2) or (METHOD_BUFFERED);
  begin
    FillChar(InquiryData, dwSize, #0);
    Result := DeviceIOControl(hDevice, IOCTL_SCSI_GET_INQUIRY_DATA,
      nil, 0, @InquiryData, dwSize, dwSize, nil);
  end;
  //-------------------------------------------------------------

type
  TSCSIPortNum = 0..$7;
  TDriveNum = TSCSIPortNum;
  //TBusDataNum = TSCSIPortNum;

  function ExtractHDInfo(IDSector: TIDSector): string;

    procedure SwapBytes(var Data; Size: integer);
    asm
      shr Size,1; jz @@Stop
      shr Size,1; push ebx; jz @@L2
      @@L4: mov bx,[Data]; mov cx,[eax+2];
            mov [Data],bh; mov [eax+2],ch
            mov [eax+1],bl; mov [eax+3],cl
            lea eax,eax+4; dec Size; jnz @@L4
      @@L2: mov bx,[Data]; jnb @@done;
            mov [Data],bh; mov [eax+1],bl
      @@done: pop ebx;
      @@Stop:
    end;

    function trimmed(const S: string): string; // const Delimiter: char): string;
    const
      Delimiter = ' ';
    var
      i, Len: integer;
    begin
      i := 1;
      Len := Length(S);
      while (i <= Len) and (S[i] <= Delimiter) do inc(i);
      if i > Len then Result := ''
      else begin
        while S[Len] <= Delimiter do dec(Len);
        Result := Copy(S, i, Len - i + 1);
      end;
    end;

  begin
    Result := '';
    with IDSector do begin // FIXED TABLE!
      SwapBytes(sSerialNumber, sizeof(sSerialNumber)); // 20 chars
      //SwapBytes(sFirmwareRev, sizeof(sFirmwareRev));   //  8 chars
      //SwapBytes(sModelNumber, sizeof(sModelNumber));   // 40 chars
                                                       // -------- +

      Result := sSerialNumber; // + sFirmwareRev + sModelNumber;
      // NEVER DO trim if more than one info requested
      Result := trimmed(Result);

      //
      //  Result := Result + 'cyl:' + intohex(wNumCyls, 4);
      //  Result := Result + ' rsv:' + intohex(wReserved, 4);
      //  Result := Result + ' hds:' + intohex(wNumHeads, 4);
      //  Result := Result + ' b/t:' + intohex(wBytesPerTrack, 4);
      //  Result := Result + ' b/s:' + intohex(wBytesPerSector, 4);
      //  Result := Result + ' s/t:' + intohex(wSectorsPerTrack, 4);
      //  Result := Result + ' s/t:' + intohex(wSectorsPerTrack, 4);
      //  Result := Result + ^j;
      //
      //  Result := Result + ' CYL:' + intohex(wNumCurrentCyls, 4);
      //  Result := Result + ' HDS:' + intohex(wNumCurrentHeads, 4);
      //  Result := Result + ' S/T:' + intohex(wNumCurrentSectorsPerTrack, 4);
      //

      //  Result := sSerialNumber + sFirmwareRev + sModelNumber;
      //Result := Result + '-';
      //for i := length(Result) downto 1 do
      //  if not (Result[i] in ['0'..'9', 'A'..'Z', 'a'..'z']) then
      //  delete(Result, i, 1);

    end;
  end;

  procedure CatDelimit(var S: string; const AddStr: string; const delimiter: string = ',');
  begin
    if S = '' then
      S := AddStr
    else if AddStr <> '' then
      S := S + delimiter + AddStr
  end;

var
  Continued: boolean;

  function DirectIdentify(DriveNum: TDriveNum = 0): string;
  const
    IDE_ID_FUNCTION = $EC;
  var
    hDevice: THandle;
    nIDSectorSize: LongInt;
    Buffer: array[0..IDENTIFY_BUFFER_SIZE - 1] of byte;
    IDSector: TIDSector absolute Buffer;
  begin
    Result := '';
    if not IsWinNT then
      hDevice := CreateFile('\\.\SMARTVSD', 0, 0, nil, CREATE_NEW, 0, 0)
    else
      hDevice := CreateFile(PChar('\\.\PhysicalDrive' +
        char(DriveNum + ord('0'))), //intoStr(DriveNum)),
        GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE,
        nil, OPEN_EXISTING, 0, 0);
    if hDevice = INVALID_HANDLE_VALUE then begin
      // ShutDown(wrReboot); // :))
    end
    else begin
      FillChar(Buffer, sizeof(Buffer), #0);
      try
        if SmartIdentifyDirect(hDevice, DriveNum, IDE_ID_FUNCTION,
          IDSector, nIDSectorSize) then
          Result := ExtractHDInfo(IDSector);
      finally
        CloseHandle(hDevice);
      end;
    end;
    Continued := (Result = '') or FindAll;
  end;

  function EnumSCSIPortNo(iPort: TSCSIPortNum = 0; const FindAll: boolean = FALSE): string;
  const
    BufferSize = 2048;
    IDE_ID_FUNCTION = $EC; // Returns ID sector for ATA.
  var
    i: integer;
    hDevice: THandle;
    pData: PSCSIInquiryData;
    dwSize, nOffset: DWORD;
    Buffer: array[0..BufferSize - 1] of byte;
    SCSIData: TSCSIAdapterBusInfo absolute Buffer;
    nIDSectorSize: LongInt;
    IDBuffer: array[0..IDENTIFY_BUFFER_SIZE - 1] of byte;
    IDSector: TIDSector absolute IDBuffer;

  begin
    Result := '';
    hDevice := CreateFile(PChar('\\.\SCSI' + char(iPort + ord('0')) + ':'),
      GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE,
      nil, OPEN_EXISTING, 0, 0);
    if hDevice <> INVALID_HANDLE_VALUE then begin
      dwSize := BufferSize;
      try
        dwSize := BufferSize;
        if GetSCSIInquiryData(hDevice, SCSIData, dwSize) then
          for i := 0 to SCSIData.NumberOfBuses - 1 do begin
            if not Continued then
              break;
            if (SCSIData.BusData[i].NumberOfLogicalUnits > 0) then begin
              nOffset := SCSIData.BusData[i].InquiryDataOffset;
              while Continued and (nOffset <> 0) do begin
                pData := {SmartIO.} PSCSIInquiryData(PChar(@SCSIData) + nOffset);
                if SmartIdentifyMiniport(hDevice, pData^.TargetID,
                  IDE_ID_FUNCTION, IDSector, nIDSectorSize) then begin
                  //if iBusData = i then
                  CatDelimit(Result, ExtractHDInfo(IDSector), ListDelimiter);
                  Continued := (Result = '') or FindAll;
                end
                else begin
                  // no-serialnum (usually a CD-ROM, not a hard-disk))
                end;
                nOffset := pData^.NextInquiryDataOffset;
              end;
            end;
          end;
      finally
        CloseHandle(hDevice);
      end;
    end;
  end;

var
  i: integer;
begin
  Result := '';
  Continued := TRUE;
  if not IsWinNT or IsAdmin then
    for i := 0 to high(TDriveNum) do begin
      CatDelimit(Result, DirectIdentify(i), ListDelimiter);
      if not Continued then
        break;
    end
  else
    for i := 0 to high(TDriveNum) do begin
      CatDelimit(Result, EnumSCSIPortNo(i, FindAll), ListDelimiter);
      if not Continued then
        break;
    end;
end;

{
  Copyright 2005-2007, aa, Adrian H. & Ray AF.
  aa@softindo.net
  http://www.google.com/search?q=aa+delphi

  Private property of PT Softindo, JAKARTA.
  All rights reserved.

  Credits/references:
}

const
  MAX_ADAPTER_ADDRESS_LENGTH = 8;
  MAX_ADAPTER_NAME_LENGTH = 256;
  MAX_ADAPTER_DESCRIPTION_LENGTH = 128;
type
  //TNICInfoType = (nicDeviceNumber, nicMacAddress, nicIPAdress, nicIPNetMask);
  TIPAddressString = array[0..15] of char;
  PIPAddrString = ^TIPAddrString;
  TIPAddrString = record
    Next: PIPAddrString;
    IPAddress: TIPAddressString;
    IPNetMask: TIPAddressString;
    Context: integer;
  end;
  PIPAdapterInfo = ^TIPAdapterInfo;
  TIPAdapterInfo = record
    Next: PIPAdapterInfo;
    ComboIndex: integer;
    AdapterName: array[0..MAX_ADAPTER_NAME_LENGTH + 3] of char;
    Description: array[0..MAX_ADAPTER_DESCRIPTION_LENGTH + 3] of char;
    AddressLength: integer;
    Address: array[1..MAX_ADAPTER_ADDRESS_LENGTH] of byte;
    Index: integer;
    _Type: integer;
    DHCPEnabled: integer;
    CurrentIPAddress: PIPAddrString;
    IPAddressList: TIPAddrString;
    GatewayList: TIPAddrString;
    DHCPServer: TIPAddrString;
    HaveWINS: LongBool;
    PrimaryWINSServer: TIPAddrString;
    SecondaryWINSServer: TIPAddrString;
    LeaseObtained: integer;
    LeaseExpires: integer;
  end;

function GetAdaptersInfo(AdapterInfo: PIPAdapterInfo; var BufLen: integer): integer; stdcall;
  external 'iphlpapi.dll' name 'GetAdaptersInfo';

function MACtoHex(const eax: pointer): string;
asm
  push esi; mov esi,eax;
  mov eax,edx; call System.@LStrClr
  push 6*2+5; pop edx; call System.@LStrSetLength;
  push 6; pop ecx;
  push ebx; mov ebx,[eax];
  xor eax,eax; xor edx,edx;
  @@Loop:
    mov al,[esi]; shr eax,04;
    mov dl,[esi]; and edx,15; add esi,1;
    mov al,eax+hex; mov dl,edx+hex
    mov [ebx],al; mov [ebx+1],dl;
    mov byte[ebx+2],':'; add ebx,3
    sub ecx,1; jnz @@Loop
  mov byte[ebx-1],0
  pop ebx; pop esi;
end;

function ReadNICDeviceInfo(const InfoType: NICInfoTypes; const NICIndex: integer = 0; const ListDelimiter: string = ^j): string;
var
  Buf, AdapterInfo: PIPAdapterInfo;
  BufSize, i: integer;
  t: TNICInfoType;
begin
  Result := '';
  BufSize := 1024 * 5;
  getmem(Buf, BufSize);
  if GetAdaptersInfo(Buf, BufSize) = ERROR_SUCCESS then begin
    AdapterInfo := Buf;
    if NICIndex > 0 then
      for i := 0 to NICIndex - 1 do begin
        AdapterInfo := AdapterInfo^.Next;
        if AdapterInfo = nil then break;
      end;
    if AdapterInfo <> nil then
      for t := low(t) to high(t) do
        if t in InfoType then begin
          if Result <> '' then Result := Result + ListDelimiter;
          case t of
            nitDeviceNumber: Result := Result + AdapterInfo^.AdapterName;
            nitMacAddress: Result := Result + MACToHex(@AdapterInfo^.Address);
            nitIPAdress: Result := Result + AdapterInfo^.IPAddressList.IPAddress;
            nitIPNetMask: Result := Result + AdapterInfo^.IPAddressList.IPNetMask;
          end;
        end;
  end;
  freemem(Buf);
  if Buf <> nil then Buf := nil;
end;

function ReadNICDeviceInfo(const InfoType: TNICInfoType; const NICIndex: integer = 0): string;
begin
  Result := ReadNICDeviceInfo([InfoType], NICIndex);
end;

//aa, http://www.google.com/search?q=aa+delphi
end.


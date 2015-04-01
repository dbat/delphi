unit ACommon;
{$I QUIET.INC}
{.$WEAKPACKAGEUNIT ON}
{$J-} //no-writeableconst
{.$D-}//no-debug
{
  Copyright (c) 2004, aa, Inge DR. & Adrian Hafizh.
  Property of PT SOFTINDO Jakarta.
  All rights reserved.

  mail,to:@[zero_inge]AT@-y.a,h.o.o.@DOTcom,
  mail,to:@[aa]AT@-s.o.f.t,i.n.d.o.@DOTnet
  http://delphi.softindo.net

  A collection of unusual but quite common (sometimes desperately needed) routines

  Description : See comments

  Custom dependency :
    unit ACConsts, not required, the main purpose actually to replace TRUE with YES :)
    unit ChPos, quite essential, now separated for ease of maintenance
    unit OrdNums, fast ordinal to string conversion
    unit fDirfunc, file/directory handling routines

  Compiler: D5, maybe works also on D4, but not D3 (because of default args value)

  Note: MOVED snippet section should not be used, left for historical purposes only

  I'm using 1280x1024 19" Monitor, sory if the lines become too long :)

  This software is free for any purposes, distribution licensed
  under the terms of BSD License, see COPYING.

  Version: 1.0.5.3
  Dated: 2004.04.21
  LastUpdated: 2005.07.15
}
{.$DEFINE MSWINDOWS}
interface
uses
{$IFDEF LINUX}
{$ERROR Sorry, we do not know much about her. (we are FreeBSD geeks)}
{$ENDIF LINUX}
  ACConsts; //, SysConst;

function GetVersionInfo(const Filename: string; const DigitOnly: Boolean = FALSE): string;

procedure _Err(const ErrorNumber: integer); //; const msg: string);
function _trimStr(const S: string): string;
function trimStr_(const S: string): string;
function trimStr(const S: string): string;
function trimmed(const S: string; const Delimiter: char): string;
function trimNumerics(const S: string): string; // strip non-numeric (left-right only, not in the middle)
function trimHexDigits(const S: string): string; // strip non-hexdigit (left-right only, not in the middle)`

//~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ MOVED TO SEPARATED UNIT: ORDNUMS
//~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ function Bin(const I: Int64; const NumOfBits: byte = 32): shortstring;
//~ // makes a binary (bits) string from a value
//~ function Hexs(const byte: byte; const uppercase: boolean = YES): string; overload;
//~ function Hexs(const word: word; const uppercase: boolean = YES): string; overload;
//~ function Hexs(const integer: integer; const uppercase: boolean = YES): string; overload;
//~ function Hexs(const I: int64; const uppercase: boolean = YES): string; overload;
//~ function Hexs(const Buffer: pointer; const BufferLength: integer;
//~   const Delimiter: Char = #0; const Uppercase: boolean = YES): string; overload;
//~ function Hexs(const Buffer: pointer; const BufferLength: integer;
//~   const Uppercase: boolean; const Delimiter: Char = #0): string; overload;
//~ // pretty formatted hexa number
//~
//~ function IntoHex(const I: Integer; const Digits: byte = sizeof(integer) * 2; UpperCase: boolean = YES): string; register overload;
//~ function IntoHex(const I: Int64; const Digits: byte = sizeof(int64) * 2; UpperCase: boolean = YES): string; register overload;
//~ //function IntoHex(const I: Int64; const Digits: integer = 0; UpperCase: boolean = YES): string; register overload;
//~
//~ function IntoStr(const I: integer; const digits: integer = 0): string; //overload;
//~ //function IntOf(const S: string; const IsHex: Boolean = FALSE; const DefaultValue: integer = 0): integer; overload;
//~ //function Int64Of(const S: string; const IsHex: Boolean = FALSE; const DefaultValue: Int64 = 0): Int64; overload;
//~ //function IntOf(const S: string; const DefaultValue: integer; const IsHex: Boolean = FALSE): integer; overload;
//~ //function Int64Of(const S: string; const DefaultValue: Int64; const IsHex: Boolean = FALSE): Int64; overload;
//~ function Str2Int(const S: string; const IsHex: Boolean = FALSE; const DefaultValue: integer = 0): integer; overload;
//~ function Str2Int64(const S: string; const IsHex: Boolean = FALSE; const DefaultValue: Int64 = 0): Int64; overload;
//~ function Str2Int(const S: string; const DefaultValue: integer; const IsHex: Boolean = FALSE): integer; overload;
//~ function Str2Int64(const S: string; const DefaultValue: Int64; const IsHex: Boolean = FALSE): Int64; overload;
//~ // just a speedy wrapper for Inttostr, IntToHex and StrToInt
//~ // IsHex is only an auto prepend '$' hex-specifier,
//~ // so do not call IsHex = TRUE, if the S has already had '$'

//procedure ChangeByteOrder(var Data; Size: integer);
procedure SwapBytes(var Data; Size: integer);
// swap byte of word (used by get-hd-manufacturer's-serial-number)

//~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ BLOCKS: MOVED TO ORDNUMS UNIT
//~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ function Blocks(const S: string; const BlockLen: integer = 3;
//~   const delimiter: string = SPACE; const LeftWise: Boolean = FALSE): string; overload;
//~ function Blocks(const I: integer; const BlockLen: integer = 3;
//~   const delimiter: string = SPACE; const LeftWise: Boolean = FALSE): string; overload;
//~ block string formatting, distribute string in blocks of BlockLen length,
//~ customizable block length and delimiter, leftwise or rightwise
//~ e.g. 1234567890 -> 123 456 789 0  (length = 3 (default), delim = A SPACE, leftwise)
//~      1234567890 -> 1 234 567 890  (length = 3 (default), delim = A SPACE, righwise)

function KBCtrl_Pressed: Boolean;
function KBShift_Pressed: Boolean;
function KBAlt_Pressed: Boolean;

procedure CatDelimit(var S: string; const AddedString: string; const delimiter: string = COMMA);
procedure CatDelimitw(var W: widestring; const AddedString: widestring; const delimiter: widestring = Char_COMMA);
// concatenate/append with delimiter, (the last item has no delimiter)

function CatDelimited(const S: string; const AddedString: string; const delimiter: string = COMMA): string;
function CatDelimitedw(const W: widestring; const AddedString: widestring; const delimiter: widestring = COMMA): widestring;
// same as above, sometimes it be more convenient with a function

function OrdString(const S: string; const HexStyle: boolean = YES;
  const HexSymbolPrefix: string = '$'; const CharSymbolPrefix: string = '#'): string;
function OrdWideString(const W: widestring; const HexStyle: boolean = YES;
  const HexSymbolPrefix: string = '$'; const CharSymbolPrefix: string = '#'): string;
// convert string (characters) to it's equivalent pascal source code
// e.g. '1' mapped to #$31, '2' to #$32, and so on..., hex or dec mode
// using internal convertor so it should be much faster than formatstr
// final Result could be as 'x41x64x72x69x61x6Ex20x48x61x66x69x7Ax68'
// for 'Adrian Hafizh' :)

function ExtractDelimited(const S: string; const Position: integer = 1; const Delimiter: string = CRLF): string; overload;
// get a chunk from string, based on position and delimiter
// such as (common uses) to extract a specific line from the text (delimiter = CR-LF)
// the longstring delimiter version is not an efficient procedure that the position should
// be limited by type WORD (max 65535)
// use the char method instead if delimiter length is 1 (a char), she is fast

function Beautify(const I: cardinal; subject: string = 'file'; const ZeroAsDigit: boolean = FALSE): string; overload;
function Beautify(const I: cardinal; const ZeroAsDigit: boolean; subject: string = 'file'): string; overload;
// number = 0 as 'no', number > 1 ~> plural subject as: file =>files, directory => directories

function SimpleEncrypt(const S: string; Key0: Cardinal = __AAMAGIC0__;
  const Key1: Cardinal = __AAMAGIC1__; const Key2: Cardinal = __AAMAGIC2__): string;
function SimpleDecrypt(const S: string; Key0: Cardinal = __AAMAGIC0__;
  const Key1: Cardinal = __AAMAGIC1__; const Key2: Cardinal = __AAMAGIC2__): string;
// simple string encrypt/decryptor

function getGCD(const X, Y: Cardinal): Cardinal; assembler;
// Get Greatest Common Divisor 32 bit only!

//function iCompare(const S1, S2: string): integer;
// substract strings i.e. compare string, // without case sensitivity // from borland

//~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ MOVED TO SEPARATED UNIT: CHPOS
//~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ function SameText(const S1, S2: string; const IgnoreCase: boolean = YES): boolean;
//
// function CharPos_Old2(const Ch: Char; const S: string; const StartPos: integer; const IgnoreCase: boolean = FALSE): integer; overload;
// function CharPos_Old2(const Ch: Char; const S: string; const IgnoreCase: boolean = FALSE; const StartPos: integer = 1): integer; overload;
// function CharCount_Old2(const Ch: Char; const S: string; const StartPos: integer; const IgnoreCase: boolean = FALSE): integer; overload;
// function CharCount_Old2(const Ch: Char; const S: string; const IgnoreCase: boolean = FALSE; const StartPos: integer = 1): integer; overload;
// (*Real*) Fast-CharPos

//~ function CharPos(const Ch: Char; const S: string;
//~   const IgnoreCase: boolean = FALSE; const StartPos: integer = 1;
//~   const BackPos: boolean = FALSE): integer; register overload
//~ function CharPos(const Ch: Char; const S: string;
//~   const StartPos: integer; const IgnoreCase: boolean = FALSE;
//~   const BackPos: boolean = FALSE): integer; register overload
//~ function CharCount(const Ch: Char; const S: string; const StartPos: integer;
//~   const IgnoreCase: boolean = FALSE): integer; register overload
//~ function CharCount(const Ch: Char; const S: string; const IgnoreCase: boolean = FALSE;
//~   const StartPos: integer = 1): integer; register overload
//~
//~ function RepPos(const Ch: Char; const S: string; const RepCount: integer;
//~   const StartPos: integer = 1; const IgnoreCase: boolean = FALSE): integer;
//~ // used only for monotoned/repeated chars as 'cccc','xxxxxx'
//~ // function _RepPos(const Ch: Char; const S: string; const StartPos: integer;
//~ // const RepCount: integer; const IgnoreCase: boolean): integer;
//~
//~ function UPPERSTR(const S: string): string;
//~ function lowerStr(const S: string): string;

//====================================================================
// error number to string conversion
function ErrStr(const ErrNo: Cardinal; const ShowErrNo: Boolean = YES;
  const AlwaysShowMessage: Boolean = YES): string;
// if (AlwaysShowMessage is set to YES), then if the message
// to be shown is not available (it did happen sometimes),
// then Result is a string "the message is not available".
// if set to FALSE then Result is simply an empty string.

function LastErrStr(const ShowErrNo: boolean = YES): string;
// ErrStr is essential routines to translate error number to string
// LastErr is basically just a macro which calls & translate GetLastError to string

// various showmessage replacement
function ShowmsgOK(const text: string; title: string = ''): word; // hOwner: Cardinal = 0): word;
function ShowmsgError(const text: string; title: string = ''): word; overload; // hOwner: Cardinal = 0): word;
function ConfirmYN(const text: string; title: string = ''): word; // hOwner: Cardinal = 0): word;
function ConfirmCritical(const text: string; title: string = '';
  const DefaultIsYES: boolean = FALSE): word; // hOwner: Cardinal = 0): word;
// confirmation - check Result against idYES or idNO

// error result showmessage
function ShowLastErr(title: string = ''; const ShowErrNo: boolean = YES;
  const AlwaysShowMessage: Boolean = YES): word; overload; // hOwner: Cardinal = 0): word;
function ShowmsgError(const ErrNo: integer; title: string = '';
  const ShowErrNo: boolean = YES; const AlwaysShowMessage: Boolean = YES): word; overload; // hOwner: Cardinal = 0): word;

//====================================================================

procedure freemnil(var P);
// free memory and nullify them

//type TPoint = record X, Y: longint; end;
//function GetCaptionAtPoint(CursorPos: TPoint): string;
function GetCaptionAtPoint(PosX, PosY: Longint): string;
// get caption/text under cursor, do not forget to call ScreenToClient if its intended

function WaitForFinish(CommandLine: string; ShowMode: integer = 0; TimeOut: integer = 5000): integer;
// execute a program and wait until its work is done

type
  TWinRebootKind = (wrLogOff, wrShutDown, wrReboot, wrPowerOff);

procedure ShutDown(const RebootKind: TWinRebootKind);
// Shutdown window, selectable mode

function GetCPUSpeed: Double;
function GetHDVolumeInfo(const LogicalDrive: Char = 'C'): integer;
// Get Hardisk Volume Serial number

function __GetHDSN(const FindAll: boolean = FALSE; const ListDelimiter: string = ^J): string;
// Manufacturer's Hard-Disk Serial Number, the one that physically burned onto harddisk
// and (nearly) impossible to be changed, except by a special, professional engineer device
// credit of Alex Konshin, alexk@mtgroup.ru,

function GetHDSerialNumber(const PhysicalDriveNo: integer = 0;
  const MSG_ON_ERROR: string = '1nv4l1d5n'): string; overload;
// wrapper for _GetHDSN

//test...
function _IDESN(const Alphaized: boolean; const truncate9: boolean = TRUE;
  const INVALID_MSG: string = 'INVALID-SN'): string;

function DumpBIOS(const Address: cardinal; const DumpSize: integer; const Buffer: pointer): boolean;
{Based on BIOSHelper by Nico Bendlin <nicode@gmx.net>}

// remember, of segment $E000:0000 start address MUST be written as $E0000 (NOT $E000}
// 1 Block is 4096 bytes, lowest block: 0, highest block: 255
// Buffer MUST be in 4KB fold of DumpSize. Dumpsize = 0 means All blocks
// ie., if DumpSize = 0 then Buffer MUST be as large as 256 Blocks or 1MB !

// note: do not rely on F000:0000 as base address to search SMI BIOS
// some braindamaged manufacturer (actually designer) will happily
// violate the conventions (sometimes even of standards), such as my
// HP/Compaq ZV5000 notebook puts SMBIOS structure at segment area E000:0000
// and donot forget to always check the result/output, the older toshiba
// given me (with regards to our customer) unexpected bad experience when
// she formatted BIOS date delimited with absurd (maybe in japanesse?) chars.

//if you are not working with MBCS (windows Japanese, Chinese, Korean etc.)
//you can remove/comment the define below
{$DEFINE USING_MBCS}
{$UNDEF USING_MBCS}

//~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ MOVED TO SEPARATED UNIT: fDirFunc / FileFunc
//~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ //MBCS only affect these two functions here
//~ //function LastDelimiter(const Delimiters, S: string): integer;
//~ //function IsPathDelimiter(const S: string; Index: integer): Boolean;
//~ //reinventing the wheel, no-need more explanations
//~ function ExtractFileExt(const Filename: string): string;
//~ function ChangeFileExt(const Filename, Extension: string): string;
//~ function ExtractFileDir(const Filename: string): string;
//~ function ExtractFilename(const Filename: string): string;
//~ function ExtractFilePath(const Filename: string): string; // backslash appended
//~ function IncludeTrailingBackslash(const S: string): string; forward;
//~ function ExcludeTrailingBackslash(const S: string): string; forward;
//~ function FileExists(const Filename: string): Boolean;
//~ function CreateDir(const Dir: string): Boolean;
//~ function DeleteFile(Filename: string): boolean; overload;
//~ function FileGetSize(const Filename: string): Int64; // +
//~ function DirectoryExists(const Name: string): Boolean; // +
//~ function CreateDirTree(DirTree: string): Boolean; // +
//~ function DeleteFiles(const PathMask: string): integer; // +
//~ function RenameFile(SrcFilename, DestFilename: string): boolean; overload;
//~ //procedure RenameFiles(SearchMask, TargetMask: string); overload;
//~
//~ function GetBakFilename(const Filename: string; const NewExtension: string = '.';
//~   const CounterDigits: integer = 3; const AutoPrependExtensionWithDot: Boolean = YES): string;
//~ // for maintaining backup file, extension increased by 1 if it has already exist
//~ // e.g FILE.BAK0, FILE.BAK1, FILE.BAK2... and on, up to FILE.BAK-2147483647
//~ // Constistent with borland convention Extension SHOULD BE prepended with/including '.'
//~ // or either to the Filename itself the modification will be taken place
//~ // this way argument AutoPrependExtensionWithDot default to TRUE
//~ function MakeBackupFilename(const Filename: string; const BackupExtension: string = '';
//~   const BackupSubDir: string = '' {'backup'}): string;

function IsWinNT: Boolean;
function IsAdmin: Boolean;

type
  TWorkStationInfo = (wiUserName, wiComputerName, wiDomainName);
  WorkStationInfos = set of TWorkStationInfo;

function _UserName: AnsiString;
function _ComputerName: AnsiString;
function _DomainName: AnsiString;

// iprefer to use these instead...
function GetWorkstationInfo(const infokind: TWorkstationInfo = wiUserName): string; overload;
// retrieve all, tabdelimited by default
function GetWorkstationInfo(const infokinds: WorkstationInfos = [wiUserName, wiComputerName, wiDomainName];
  const delimiter: char = CHAR_TAB): string; overload;

// function CRC32
// note that in this CRC32 implementation we did not inversed (with the operator: NOT)
// the first/initial and neither is last/result value, which should be done upon production.
// we give the user some freedom to alter the crc32 initial & result value, and even
// to build your own propietary CRC32 table with your own magic polynomial number.
// these functions below concern only on processing the intermediate crc32 value.
//
// to be conformed with the common implementation of CRC32, the initial value should
// be inversed (from 0 to -1 or $ffffffff) and so is the last result after checksuming.
//
// the function GetCRC32 OfFile below does not inverse the result (since it could be
// done afterwise by simply NOT'ing it), however it did inverse the initial value to
// adhere the standard (otherwise the standard crc32 value would be unrecoverable).

//notused:function GetCRC32Of(const b: byte; const initCRC32Value: Cardinal = 0): Cardinal; overload;
function GetCRC32Of(const Buffer: pointer; const Size: integer; const initCRC32Value: Cardinal = 0): Cardinal; overload;
function GetCRC32Of(const Filename: string): Cardinal; overload;

//get CRC32, standard, compatible with many/most popular application such as mcafee scan, winzip etc.

procedure BuildCRC32Table(const Polynomial: Integer = integer(__CRC32Poly__); const Init: integer = 0);
//old:procedure BuildCRC32Table(const p: pointer; const Polynomial: Cardinal = __CRC32Poly; const Init: Cardinal = 0);
//in case you want to initialize a new CRC32Table with your own polynomial magic-number
//you may also change initial number (elemen-0) of CRC32 table. ordinally it is left 0 or -1

// find Reversed CRC32.
// beware! it takes much-much time, and no practical use :)
//
// actually i almost entirely forgotten now what was this function is trying to do
// maybe it finds a SINGLE backstep of specified value by the given polynomial?
// or whether it will get the initial value of the given polynomial?
// i only remember that it did works (despite it's no usefulness & time consuming fault)
function GetRevCRC32(const X: integer = 0; CRC32Poly: integer = integer($EDB88320)): integer;

// getRevCRC32 0 returns $0 ???
// getRevCRC32 -1; result = $F0958FD9
// getRevCRC32 $EDB88320 returns $80
// getRevCRC32 $80 returns $8000
// getRevCRC32 $77073096 returns 1
// getRevCRC32 $3903B3C2 returns $E3
//
// oh- I see.. it finds the index/position of specified value (X) in the table
// of that given (polynomial) value
// you see- it is useless...
//

//~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ MOVED TO SEPARATED UNIT: fDirFunc / FileFunc
//~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ function SimpleBrowseDirectory(const RootDir: string = ''; //unfinished
//~   const Title: string = 'Browse Folder...'): string;
//~ // deprecated, it's quite complex and consumes significant amount of resources.
//~ // full-capability features separated to stand-alone unit (dbrowser)

//***IMPLEMENTATION***

implementation
uses ChPos, Ordinals, fDfuncs, Shower;

const
{$J+}
  CommonHandle: integer = 0;
{$J-}

procedure freemnil(var P);
begin
  freemem(pointer(p));
  pointer(p) := nil;
end;

function Min(a, b: integer): integer; asm
  cmp a, b; jle @end
    mov a, b
  @end:
end;

function Max(a, b: integer): integer; asm
  cmp a, b; jge @end
    mov a, b
  @end:
end;

//procedure ChangeByteOrder(var Data; Size: integer);
//asm
//    mov ecx, Size
//    shr ecx, 1
//  @loop:
//    dec ecx; jl @end
//    mov dx, [eax]
//    xchg dh, dl
//    mov [eax], dx
//    lea eax, eax +2
//    jmp @loop
//  @end:
//end;

procedure SwapBytes(var Data; Size: integer);
asm
  shr Size,1; jz @@Stop
  shr Size,1; push ebx; jz @@L2
  @@L4: mov bx,[Data]; mov cx,[eax+2];
        mov [eax],bh; mov [eax+2],ch
        mov [eax+1],bl; mov [eax+3],cl
        lea eax,eax+4; dec Size; jnz @@L4
  @@L2: mov bx,[eax]; jnb @@done;
        mov [eax],bh; mov [eax+1],bl
  @@done: pop ebx;
  @@Stop:
end;

procedure CatDelimit(var S: string; const AddedString: string; const delimiter: string = ',');
begin
  if S = '' then S := AddedString
  else if AddedString <> '' then
    S := S + delimiter + AddedString
end;

procedure CatDelimitw(var W: widestring; const AddedString: widestring; const delimiter: widestring = ',');
begin
  if W = '' then W := AddedString
  else if AddedString <> '' then
    W := W + delimiter + AddedString
end;

function CatDelimited(const S: string; const AddedString: string; const delimiter: string = ','): string;
begin
  Result := S;
  CatDelimit(Result, AddedString, delimiter);
end;

function CatDelimitedw(const W: widestring; const AddedString: widestring; const delimiter: widestring = ','): widestring;
begin
  Result := W;
  CatDelimitw(Result, AddedString, delimiter);
end;

const
  STNUMERIC = ['0'..'9'];
const
  STHEXDIGIT = STNUMERIC + ['A'..'F', 'a'..'f'];

function trimHexDigits(const S: string): string;
var
  i, Len: integer;
begin
  i := 1;
  Len := Length(S);
  while (i <= Len) and not (S[i] in STHEXDIGIT) do
    inc(i);
  if i > Len then
    Result := ''
  else begin
    while not (S[Len] in STHEXDIGIT) do
      dec(Len);
    Result := Copy(S, i, Len - i + 1);
  end;
end;

function trimNumerics(const S: string): string;
var
  i, Len: integer;
begin
  i := 1;
  Len := Length(S);
  while (i <= Len) and not (S[i] in STNUMERIC) do
    inc(i);
  if i > Len then
    Result := ''
  else begin
    while not (S[Len] in STNUMERIC) do
      dec(Len);
    Result := Copy(S, i, Len - i + 1);
    //SetLength(Result, Len - i + 1);
  end;
end;

function trimStr(const S: string): string;
var
  i, Len: integer;
begin
  i := 1;
  Len := Length(S);
  while (i <= Len) and (S[i] <= ' ') do inc(i);
  if i > Len then Result := ''
  else begin
    while S[Len] <= ' ' do dec(Len);
    Result := Copy(S, i, Len - i + 1);
  end;
end;

function trimmed(const S: string; const Delimiter: char): string;
var
  i, Len: integer;
begin
  i := 1;
  Len := Length(S);
  while (i <= Len) and (S[i] = Delimiter) do inc(i);
  if i > Len then
    Result := ''
  else begin
    while S[Len] = Delimiter do dec(Len);
    Result := Copy(S, i, Len - i + 1);
  end;
end;

function _trimStr(const S: string): string;
// trim_left
var
  i, L: integer;
begin
  i := 1;
  L := Length(S);
  while (i <= L) and (S[i] <= ' ') do inc(i);
  if i > L then Result := ''
  else begin
    while S[L] <= ' ' do dec(L);
    Result := Copy(S, i, L - i + 1);
  end;
end;

function trimStr_(const S: string): string;
// trim_right
var
  i: integer;
begin
  i := Length(S);
  while (i > 0) and (S[i] <= ' ') do dec(i);
  Result := Copy(S, 1, i);
end;

function Beautify(const i: cardinal; subject: string = 'file'; const ZeroAsDigit: boolean = FALSE): string; overload;
const
  UPOFFSET = $20;
  SPACE = ' ';
  WHY = 'Y';
  AY = 'I';
  ii = 'i';
  _s = 's';
  _e = 'e';
  ie = ii + _e;
  es = _e + _s;
  PLURALIES: set of Char = [AY, WHY];
  SINGULARIES: set of Char = ['H', 'S', 'O'];
var
  Ch: Char;
begin
  if (i = 0) and not ZeroAsDigit then
    Result := 'no'
  else
    Result := IntoStr(i);
  subject := trimStr(subject);
  if (subject) <> '' then begin
    if i > 1 then begin
      Ch := subject[length(subject)];
      if upcase(Ch) in PLURALIES then
        subject := copy(subject, 1, length(subject) - 1) + ie
      else if upcase(Ch) in SINGULARIES then
        subject := subject + _e;
      subject := subject + _s;
      if ord(Ch) < ord('a') then
        subject := upperStr(subject);
    end;
    Result := Result + SPACE + subject
  end;
end;

function Beautify(const i: cardinal; const ZeroAsDigit: boolean; subject: string = 'file'): string; overload;
begin
  Result := beautify(i, Subject, ZeroAsDigit);
end;

function OrdString(const S: string; const HexStyle: boolean = YES;
  const HexSymbolPrefix: string = '$'; const CharSymbolPrefix: string = '#'): string;
var
  i: integer;
begin
  Result := '';
  if HexStyle then
    for i := 1 to length(S) do
      Result := Result + CharSymbolPrefix + HexSymbolPrefix + IntoHex(ord(S[i]), 2) //inttoHex(ord(S[i]), 2)
  else
    for i := 1 to length(S) do
      Result := Result + CharSymbolPrefix + IntoStr(ord(S[i]))

end;

function OrdWideString(const W: widestring; const HexStyle: boolean = YES;
  const HexSymbolPrefix: string = '$'; const CharSymbolPrefix: string = '#'): string;
var
  i: integer;
begin
  Result := '';
  if HexStyle then
    for i := 1 to length(W) do
      Result := Result + CharSymbolPrefix + HexSymbolPrefix + IntoHex(ord(W[i]), 4) //inttoHex(ord(S[i]), 2)
  else
    for i := 1 to length(W) do
      Result := Result + CharSymbolPrefix + IntoStr(ord(W[i]))

end;
{$RANGECHECKS OFF}
{$OVERFLOWCHECKS OFF}
const
  _Key0 = $19091969;
  _Key1 = $22101969;
  _Key2 = $09022004;

function SimpleEncrypt(const S: string; Key0: Cardinal; const Key1, Key2: Cardinal): string;
const
  PIX = trunc(PI * 1E18);
var
  i: integer;
begin
  Result := '';
  for i := 1 to Length(S) do begin
    Result := Result + Char(byte(S[i]) xor (Key0 shr 8));
    Key0 := (byte(Result[i]) + Key0) * Key1 + Key2;
  end;
end;

function SimpleDecrypt(const S: string; Key0: Cardinal; const Key1, Key2: Cardinal): string;
const
  PIX = trunc(PI * 1E18);
var
  i: integer;
begin
  Result := '';
  for i := 1 to Length(S) do begin
    Result := Result + Char(byte(S[i]) xor (Key0 shr 8));
    Key0 := (byte(S[i]) + Key0) * Key1 + Key2;
  end;
end;
{.$RANGECHECKS ON}
{.$OVERFLOWCHECKS ON}

type
  //TByteSegment = array[word] of byte;
  TBytePage = array[0..8191] of byte;
  PCRC32Table = ^TCRC32Table;
  TCRC32Table = array[byte] of Cardinal;

{$J+}
const
  lpCRC32Table: PCRC32Table = nil; //^TCRC32Table = nil;
  //CRC32Table: TCRC32Table;
  //  pCRC32Table: ^TCRC32Table = nil;
  //TableHasBeenBuilt: Boolean = FALSE;
{$J-}

procedure BuildCRC32Table(const Polynomial: integer = integer(__CRC32Poly__); const Init: integer = 0);
//procedure BuildCRC32Table(const p: pointer; const Polynomial: Cardinal = __CRC32Poly; const Init: Cardinal = 0);
var
  C: integer;
  n, k: integer;
begin
  if lpCRC32Table = nil then
    GetMem(lpCrc32Table, sizeof(TCRC32Table));
  //if not TableHasBeenBuilt then begin
  for n := 0 to high(byte) do begin
    C := (n);
    for k := 0 to (8 - 1) do
      if odd(C) then
        C := Polynomial xor (C shr 1)
      else
        C := C shr 1;
    PCRC32Table(lpCRC32Table)^[n] := C;
    //CRC32Table[n] := C;
  end;
  if Init <> 0 then
    PCRC32Table(lpCRC32Table)^[0] := Init;
  //CRC32Table[0] := Init;
//end;
end;

//function GetCRC32Of(const b: byte; const initCRC32Value: Cardinal = 0): Cardinal; overload;
//begin
//  if initCRC32Value = 0 then
//    Result := Cardinal(not (initCRC32Value))
//  else
//    //Result := (CRC32Value shr 8) xor (CRC32Table[b xor (CRC32Value and Cardinal($FF))])
//    Result := (initCRC32Value shr 8) xor (pCRC32Table^[b xor (initCRC32Value and Cardinal($FF))])
//end;

function GetCRC32Of(const Buffer: pointer; const Size: integer; const initCRC32Value: Cardinal = 0): Cardinal; overload;
var
  i: integer;
  B: ^TBytePage; //^TByteSegment;
begin
  B := Buffer;
  Result := initCRC32Value;
  for i := 0 to Size - 1 do
{$IFOPT R+}{$R-}{$DEFINE RANGECHECKS}{$ENDIF}
    //Result := (Result shr 8) xor (CRC32Table[B^[i] xor (Result and Cardinal($FF))])
    Result := (Result shr 8) xor (PCRC32Table(lpCRC32Table)^[B^[i] xor (Result and Cardinal($FF))])
{$IFDEF RANGECHECKS}{$R+}{$UNDEF RANGECHECKS}{$ENDIF}
end;

function GetCRC32Of(const Filename: string {; const Init: Cardinal = 0}): Cardinal; overload;
const
{$WRITEABLECONST ON}
  TableHasBuilt: Boolean = FALSE;
{$WRITEABLECONST OFF}

  //  procedure CalcCRC32(p: pointer; n: integer; var CRCVal: Cardinal);
  //  var
  //    i: word;
  //    B: ^TByteSegment;
  //  begin
  //    B := p;
  //    for i := 0 to n - 1 do
  //      //CRCVal := (CRCval shr 8) xor (pCRC32Table^[TbyteSegment(p^)[i] xor (CRCval and $000000FF)])
  //      //more clearly...
  //      CRCVal := (CRCval shr 8) xor (pCRC32Table^[B^[i] xor (CRCval and Cardinal($FF))])
  //  end;

var
  i: integer;
  B: ^TBytePage; //^TByteSegment;
  //fs: tfileStream;
  h: integer;
begin
  Result := Cardinal(not (0)); // $FFFFFFFF;
  h := fHandleOpenReadOnly(filename);
  if integer(h) <> -1 then begin
    //fs := tFileStream.Create(Filename, fmOpenRead or fmShareDenyNone);
    GetMem(B, sizeof(B^));
    try
      repeat
        //i := fs.Read(B^, SizeOf(B^));
        //Application.ProcessMessages;
        i := fHandleRead(h, B^, sizeof(B^));
        Result := GetCRC32Of(B, i, Result);
      until i = 0;
    finally
      //fs.Free;
      FreeMem(B);
      fDfuncs.fHandleClose(h);
    end;
  end;
end;

function GetRevCRC32(const X: integer = 0; CRC32Poly: integer = integer(__CRC32Poly__)): integer;
// find Reversed CRC32
// const Poly = IntCRC32Poly;
var
  c, i, k: integer;
begin
  i := 0;
  Result := 0;
  while Cardinal(i) < High(Cardinal) do begin
    inc(i);
    C := i;
    for k := 0 to (8 - 1) do
      if odd(C) then
        C := CRC32Poly xor (C shr 1)
      else
        C := C shr 1;
    if integer(C) = X then begin
      Result := i;
      break;
    end;
  end;
end;

function ExtractDelimited(const S: string; const Position: integer = 1; const Delimiter: string = CRLF): string; overload;
  function ExtractDelimitedByChar(const S: string; const Position: integer = 1; const Delimiter: char = ^I): string; overload;
  var
    l, i, n: integer;
  begin
    i := CharPos(Delimiter, S);
    if i < 1 then
      Result := S
    else if Position = 1 then
      Result := copy(S, 1, i - 1)
    else begin
      n := 1;
      repeat
        inc(n);
        l := i + 1;
        i := CharPos(Delimiter, S, l);
      until (i = 0) or (n = Position);
      if n = Position then begin
        if i = 0 then
          i := length(S) + 1;
        Result := copy(S, l, i - l);
      end;
    end;
  end;

  function ExtractDelimitedByStr(const S: string; const Position: word = 1; const Delimiter: string = CRLF): string; overload;
    function StringPos(const SubStr, S: string; const StartPos: integer = 1): integer;
    var
      tmp: string;
    begin
      Result := charpos(SubStr[1], S, StartPos);
      if Result > 0 then begin
        tmp := copy(S, Result, MAXINT);
        Result := pos(S, SubStr) + Result - 1;
      end
      else
        Result := 0;
    end;
  var
    l, i, n, m: integer;
  begin
    i := StringPos(Delimiter, S);
    if i < 1 then
      Result := S
    else if Position = 1 then
      Result := copy(S, 1, i - 1)
    else begin
      n := 1;
      m := length(Delimiter);
      repeat
        inc(n);
        l := i + m;
        i := StringPos(Delimiter, S, l);
      until (i = 0) or (n = Position);
      if n = Position then begin
        if i = 0 then
          i := length(S) + 1;
        Result := copy(S, l, i - l);
      end;
    end;
  end;
var
  l, m: integer;
begin
  if (S = '') or (Delimiter = '') or (Position < 1) then
    Result := S
  else begin
    l := length(S);
    m := length(Delimiter);
    if l <= m then
      Result := S
    else begin
      if m = 1 then
        Result := ExtractDelimitedByChar(S, Position, Delimiter[1])
      else
        Result := ExtractDelimitedByStr(S, {dword}(Position), Delimiter)
    end;
  end;
end;

// ****************************************************************************** //
// ****************************************************************************** //

// ************************************* //
// *** END OF INDEPENDENT PROCEDURES *** //
// ************************************* //

const
  shell32 = 'shell32.dll';
  kernel32 = 'kernel32.dll';
  user32 = 'user32.dll';

type
  DWORD = LongWord; {$EXTERNALSYM DWORD}
  BOOL = LongBool; {$EXTERNALSYM BOOL}
  UINT = LongWord; {$EXTERNALSYM UINT}
  ULONG = Cardinal; {$EXTERNALSYM ULONG}
  HWND = type LongWord; {$EXTERNALSYM HWND}
  WPARAM = LongInt; {$EXTERNALSYM WPARAM}
  LPARAM = LongInt; {$EXTERNALSYM LPARAM}
  LRESULT = LongInt; {$EXTERNALSYM LRESULT}

  LONGLONG = Int64;
  //  TLargeInteger = Int64;

  PByte = ^Byte;
  PDWORD = ^DWORD; {$EXTERNALSYM PDWORD}
  LPDWORD = PDWORD; {$EXTERNALSYM LPDWORD}

  PLargeInteger = ^TLargeInteger;
  TLargeInteger = record
    case integer of
      0: (LowPart: DWORD; HighPart: LongInt);
      1: (QuadPart: LONGLONG);
  end;

  THandle = LongWord;
  PHandle = ^THandle;
  HLOCAL = THandle; {$EXTERNALSYM HLOCAL}

const
  VK_SHIFT = $10; {$EXTERNALSYM VK_SHIFT}
  VK_CONTROL = 17; {$EXTERNALSYM VK_CONTROL}
  VK_MENU = 18; {$EXTERNALSYM VK_MENU}

type
  PKeyboardState = ^TKeyboardState;
  TKeyboardState = array[0..255] of byte;

function GetKeyboardState(var KeyState: TKeyboardState): BOOL; stdcall;
  external user32 name 'GetKeyboardState'; {$EXTERNALSYM GetKeyboardState}

function KBCTRL_Pressed: Boolean;
var
  State: TKeyboardState;
begin
  GetKeyboardState(State);
  Result := ((State[VK_CONTROL] and 128) <> 0);
end;

function KBSHIFT_Pressed: Boolean;
var
  State: TKeyboardState;
begin
  GetKeyboardState(State);
  Result := ((State[VK_SHIFT] and 128) <> 0);
end;

function KBALT_Pressed: Boolean;
var
  State: TKeyboardState;
begin
  GetKeyboardState(State);
  Result := ((State[VK_MENU] and 128) <> 0);
end;

//uses ShlObj;

const
  { For finding a folder to start document searching: }
  BIF_RETURNONLYFSDIRS = $0001; {$EXTERNALSYM BIF_RETURNONLYFSDIRS}
  { For starting the Find Computer: }
  BIF_DONTGOBELOWDOMAIN = $0002; {$EXTERNALSYM BIF_DONTGOBELOWDOMAIN}
  BIF_STATUSTEXT = $0004; {$EXTERNALSYM BIF_STATUSTEXT}
  BIF_RETURNFSANCESTORS = $0008; {$EXTERNALSYM BIF_RETURNFSANCESTORS}
  BIF_EDITBOX = $0010; {$EXTERNALSYM BIF_EDITBOX}
  BIF_VALIDATE = $0020; {$EXTERNALSYM BIF_VALIDATE} { insist on valid result (or CANCEL) }
  BIF_BROWSEFORCOMPUTER = $1000; { Browsing for Computers. }{$EXTERNALSYM BIF_BROWSEFORCOMPUTER}
  BIF_BROWSEFORPRINTER = $2000; { Browsing for Printers }{$EXTERNALSYM BIF_BROWSEFORPRINTER}
  BIF_BROWSEINCLUDEFILES = $4000; { Browsing for Everything }{$EXTERNALSYM BIF_BROWSEINCLUDEFILES}

type
  BFFCALLBACK = function(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): integer stdcall;
  TFNBFFCallBack = type BFFCALLBACK; {$EXTERNALSYM BFFCALLBACK}

  { TItemIDList -- List if item IDs (combined with 0-terminator) }
  //simplified
  PItemIDList = ^TItemIDList;
  TItemIDList = record
    cb: word; { Size of the ID (including cb itself) }
    abID: array[0..0] of byte; { The item ID (variable length) }
  end;

  TBrowseInfo = record
    hwndOwner: HWND;
    pidlRoot: PItemIDList;
    pszDisplayName: PAnsiChar; { Return display name of item selected. }
    lpszTitle: PAnsiChar; { text to go in the banner over the tree. }
    ulFlags: UINT; { Flags that control the return stuff }
    lpfn: TFNBFFCallBack;
    lParam: LPARAM; { extra info that's passed back in callbacks }
    iImage: integer; { output var: where to return the Image index. }
  end;

function SHBrowseForFolder(var lpbi: TBrowseInfo): PItemIDList; stdcall;
  external Shell32 name 'SHBrowseForFolderA';

function BrowseCallBack(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): integer; stdcall;
begin //not yet finished
  Result := 0;
end;

function SimpleBrowseDirectory(const RootDir, Title: string): string;
var
  DirName: array[byte] of Char;
  pb: TBrowseInfo;

begin
  fillchar(pb, sizeof(pb), #0);
  //pb.hwndOwner := CommonHandle;
  pb.hwndOwner := 0;
  pb.pszDisplayName := DirName;
  pb.lpszTitle := pChar(Title);
  pb.ulFlags := BIF_RETURNONLYFSDIRS or BIF_DONTGOBELOWDOMAIN or
    BIF_RETURNFSANCESTORS or BIF_STATUSTEXT;
  pb.lpfn := @BrowseCallBack;
  ShBrowseForFolder(pb);
  Result := string(DirName);
end;

type
  PLUIDAndAttributes = ^TLUIDAndAttributes;
  TLUIDAndAttributes = packed record
    Luid: TLargeInteger;
    Attributes: DWORD;
  end;

  PTokenPrivileges = ^TTokenPrivileges;
  TTokenPrivileges = record
    PrivilegeCount: DWORD;
    Privileges: array[0..0] of TLUIDAndAttributes;
  end;

const
  advapi32 = 'advapi32.dll';

const
  TOKEN_ADJUST_PRIVILEGES = $0020; {$EXTERNALSYM TOKEN_ADJUST_PRIVILEGES}
  TOKEN_QUERY = $0008; {$EXTERNALSYM TOKEN_QUERY}
  SE_PRIVILEGE_ENABLED = $00000002; {$EXTERNALSYM SE_PRIVILEGE_ENABLED}

function GetCurrentProcess: THandle; stdcall;
  external kernel32 name 'GetCurrentProcess'; {$EXTERNALSYM GetCurrentProcess}

function ExitWindowsEx(uFlags: UINT; dwReserved: DWORD): BOOL; stdcall;
  external kernel32 name 'ExitWindowsEx'; {$EXTERNALSYM ExitWindowsEx}

function OpenProcessToken(ProcessHandle: THandle; DesiredAccess: DWORD; var TokenHandle: THandle): BOOL; stdcall;
  external advapi32 name 'OpenProcessToken'; {$EXTERNALSYM OpenProcessToken}

function AdjustTokenPrivileges(TokenHandle: THandle; DisableAllPrivileges: BOOL;
  const NewState: TTokenPrivileges; BufferLength: DWORD;
  var PreviousState: TTokenPrivileges; var ReturnLength: DWORD): BOOL; stdcall; overload;
  external advapi32 name 'AdjustTokenPrivileges'; {$EXTERNALSYM AdjustTokenPrivileges}

function AdjustTokenPrivileges(TokenHandle: THandle; DisableAllPrivileges: BOOL;
  const NewState: TTokenPrivileges; BufferLength: DWORD;
  PreviousState: PTokenPrivileges; var ReturnLength: DWORD): BOOL; stdcall; overload;
  external advapi32 name 'AdjustTokenPrivileges'; {$EXTERNALSYM AdjustTokenPrivileges}

function LookupPrivilegeValue(lpSystemName, lpName: PChar; var lpLuid: TLargeInteger): BOOL; stdcall;
  external advapi32 name 'LookupPrivilegeValueA'; {$EXTERNALSYM LookupPrivilegeValue}

const
  EWX_LOGOFF = 0; {$EXTERNALSYM EWX_LOGOFF}
  EWX_SHUTDOWN = 1; {$EXTERNALSYM EWX_SHUTDOWN}
  EWX_REBOOT = 2; {$EXTERNALSYM EWX_REBOOT}
  EWX_FORCE = 4; {$EXTERNALSYM EWX_FORCE}
  EWX_POWEROFF = 8; {$EXTERNALSYM EWX_POWEROFF}
  EWX_FORCEIFHUNG = $10; {$EXTERNALSYM EWX_FORCEIFHUNG}

  RebootKinds: array[TWinRebootKind] of Cardinal =
  (EWX_LOGOFF, EWX_SHUTDOWN, EWX_REBOOT, EWX_POWEROFF);

type
  TOSVersionInfo = record
    dwOSVersionInfoSize: DWORD;
    dwMajorVersion: DWORD;
    dwMinorVersion: DWORD;
    dwBuildNumber: DWORD;
    dwPlatformId: DWORD;
    szCSDVersion: array[0..127] of AnsiChar; { Maintenance string for PSS usage }
  end;

function GetVersion: DWORD; stdcall; external kernel32 name 'GetVersion'; {$EXTERNALSYM GetVersion}

function GetVersionEx(var lpVersionInformation: TOSVersionInfo): BOOL; stdcall; external kernel32 name 'GetVersionExA'; {$EXTERNALSYM GetVersionEx}

function CloseHandle(hObject: THandle): BOOL; stdcall; external kernel32 name 'CloseHandle'; {$EXTERNALSYM CloseHandle}

function Win32Platform: integer;
const
{$IFDEF J_OFF}{$J-}{$ENDIF}
  fWin32Platform: Cardinal = high(Cardinal);
{$IFDEF J_OFF}{$J-}{$ENDIF}
var
  os: TOSVersionInfo;
begin
  if fWin32Platform = high(Cardinal) then begin
    os.dwOSVersionInfoSize := sizeof(os);
    GetVersionEx(os);
    Result := os.dwPlatformID;
  end
  else
    Result := integer(fWin32Platform);
end;

function IsWinNT: boolean;
const
  VER_PLATFORM_WIN32_NT = 2; //{$EXTERNALSYM VER_PLATFORM_WIN32_NT}
begin
  Result := Win32Platform = VER_PLATFORM_WIN32_NT;
end;

procedure ShutDown(const RebootKind: TWinRebootKind);
const
  OpeningToken = '''OpenProcessToken''';
  AdjustingToken = '''AdjustTokenPrivileges''';
  ShutDownPrivilege = 'SeShutdownPrivilege';
  Err_Proceed = _Error_ + 'proceeding';

  function SetupShutDownPrivilege(Enabled: boolean): boolean;
  const
    Error_: string = Err_proceed;
    {OpeningToken: string = '''OpenProcessToken''';
    AdjustingToken: string = '''AdjustTokenPrivileges''';
    ShutDownPrivilege: pChar = 'SeShutdownPrivilege';}
  var
    prev, new: TTokenPrivileges;
    h: THandle;
    Length: Cardinal;
  begin
    Result := FALSE;
    //if not OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, h) then
    //  raise exception.Create(Error_ + OpeningToken);
    if OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, h) then begin
      try
        New.PrivilegeCount := 1;
        if LookupPrivilegeValue(nil, pChar(ShutDownPrivilege), New.Privileges[0].LUID) then begin
          if Enabled then
            New.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED
          else
            New.Privileges[0].Attributes := 0;
          Length := 0;
          if AdjustTokenPrivileges(h, FALSE, New, sizeof(Prev), Prev, Length) then
            Result := YES
          else
            //raise exception.Create(Error_ + AdjustingToken);
        end;
      finally
        CloseHandle(h);
      end;
    end;
  end;

var
  ShutDownFlag: Cardinal;
begin
  ShutDownFlag := RebootKinds[RebootKind] or EWX_FORCE or EWX_FORCEIFHUNG;
  if not IsWinNT then
    ExitWindowsEx(ShutDownFlag, 0)
  else begin
    try
      if SetupShutDownPrivilege(YES) then
        ExitWindowsEx(ShutDownFlag, 0);
    finally
      SetupShutDownPrivilege(OFF);
    end;
  end;
end;

function GetPriorityClass(hProcess: THandle): DWORD; stdcall;
  external kernel32 name 'GetPriorityClass'; {$EXTERNALSYM GetPriorityClass}

function SetPriorityClass(hProcess: THandle; dwPriorityClass: DWORD): BOOL; stdcall;
  external kernel32 name 'SetPriorityClass'; {$EXTERNALSYM SetPriorityClass}

function GetThreadPriority(hThread: THandle): integer; stdcall;
  external kernel32 name 'GetThreadPriority'; {$EXTERNALSYM GetThreadPriority}

function SetThreadPriority(hThread: THandle; nPriority: integer): BOOL; stdcall;
  external kernel32 name 'SetThreadPriority'; {$EXTERNALSYM SetThreadPriority}

function GetCurrentThread: THandle; stdcall;
  external kernel32 name 'GetCurrentThread'; {$EXTERNALSYM GetCurrentThread}

procedure Sleep(dwMilliseconds: DWORD); stdcall;
  external kernel32 name 'Sleep'; {$EXTERNALSYM Sleep}
const
  INFINITE = DWORD($FFFFFFFF); { Infinite timeout }{$EXTERNALSYM INFINITE}
  NORMAL_PRIORITY_CLASS = $00000020; {$EXTERNALSYM NORMAL_PRIORITY_CLASS}
  IDLE_PRIORITY_CLASS = $00000040; {$EXTERNALSYM IDLE_PRIORITY_CLASS}
  HIGH_PRIORITY_CLASS = $00000080; {$EXTERNALSYM HIGH_PRIORITY_CLASS}
  REALTIME_PRIORITY_CLASS = $00000100; {$EXTERNALSYM REALTIME_PRIORITY_CLASS}
  THREAD_BASE_PRIORITY_LOWRT = 15; { value that gets a thread to LowRealtime-1 }{$EXTERNALSYM THREAD_BASE_PRIORITY_LOWRT}
  THREAD_PRIORITY_TIME_CRITICAL = THREAD_BASE_PRIORITY_LOWRT; {$EXTERNALSYM THREAD_PRIORITY_TIME_CRITICAL}

function GetCPUSpeed: Double;
const
  DelayTime = 1000; // measurement time in ms
var
  TimerHi, TimerLo: DWORD;
  PriorityClass, Priority: integer;
begin
  PriorityClass := GetPriorityClass(GetCurrentProcess);
  Priority := GetThreadPriority(GetCurrentThread);

  SetPriorityClass(GetCurrentProcess, REALTIME_PRIORITY_CLASS);
  SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_TIME_CRITICAL);

  Sleep(10);
  asm
    dw 310Fh // rdtsc
    mov TimerLo, eax
    mov TimerHi, edx
  end;
  Sleep(DelayTime);
  asm
    dw 310Fh // rdtsc
    sub eax, TimerLo
    sbb edx, TimerHi
    mov TimerLo, eax
    mov TimerHi, edx
  end;

  SetThreadPriority(GetCurrentThread, Priority);
  SetPriorityClass(GetCurrentProcess, PriorityClass);

  Result := TimerLo / (1000.0 * DelayTime);
end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  MOVED to ShowErr unit
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
const
  EXCEPTION_NONCONTINUABLE = 1; {$EXTERNALSYM EXCEPTION_NONCONTINUABLE}

procedure RaiseException(Code: DWORD = $DEADF0E; Flags: DWORD = EXCEPTION_NONCONTINUABLE;
  ArgCount: DWORD = 0; Arguments: pointer = nil); stdcall;
  external kernel32 name 'RaiseException'; {$EXTERNALSYM RaiseException}

procedure _Err(const ErrorNumber: integer); //; const msg: string);
begin
  RaiseException(ErrorNumber, EXCEPTION_NONCONTINUABLE, 0, nil); //PChar('Cannot Continue'));
end;
//
// function FormatMessage(dwFlags: DWORD; lpSource: Pointer;
//   dwMessageId: DWORD; dwLanguageId: DWORD; lpBuffer: PChar;
//   nSize: DWORD; Arguments: Pointer): DWORD; stdcall;
//   external kernel32 name 'FormatMessageA'; {$EXTERNALSYM FormatMessage}
//
// function LocalFree(hMem: HLOCAL): HLOCAL; stdcall;
//   external kernel32 name 'LocalFree'; {$EXTERNALSYM LocalFree}
//
// function TrimRight(const S: string): string;
// var
//   i: integer;
// begin
//   i := Length(S);
//   while (i > 0) and (S[i] <= ' ') do
//     Dec(i);
//   Result := Copy(S, 1, i);
// end;
//
// function ErrStr(const ErrNo: Cardinal; const ShowErrNo: Boolean = YES;
//   const AlwaysShowMessage: Boolean = YES): string;
// const
//   nomessage = 'Error message is not available';
// const
//   FORMAT_MESSAGE_ALLOCATE_BUFFER = $100; //{$EXTERNALSYM FORMAT_MESSAGE_ALLOCATE_BUFFER}
//   FORMAT_MESSAGE_FROM_STRING = $400; //{$EXTERNALSYM FORMAT_MESSAGE_FROM_STRING}
//   FORMAT_MESSAGE_FROM_HMODULE = $800; //{$EXTERNALSYM FORMAT_MESSAGE_FROM_HMODULE}
//   FORMAT_MESSAGE_FROM_SYSTEM = $1000; //{$EXTERNALSYM FORMAT_MESSAGE_FROM_SYSTEM}
//   FORMAT_MESSAGE_ARGUMENT_ARRAY = $2000; //{$EXTERNALSYM FORMAT_MESSAGE_ARGUMENT_ARRAY}
// var
//   buf: pChar;
// begin
//   SetLength(Result, FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM {or FORMAT_MESSAGE_FROM_HMODULE} or
//     FORMAT_MESSAGE_ALLOCATE_BUFFER, nil, ErrNo, 0, @buf, high(Word), nil));
//   if AlwaysShowMessage and (Result = '') then
//     Result := nomessage
//   else
//     move(buf^, Result[1], length(Result));
//   if ShowErrNo then
//     Result := _Error_ + 'no. ' + IntoHex(ErrNo, 2) + ' (' + IntoStr(ErrNo) + ')' + CR2 + Result;
//   LocalFree(Cardinal(buf));
//   Result := trimStr(Result);
// end;
//

function GetLastError: DWORD; stdcall; external kernel32 name 'GetLastError'; {$EXTERNALSYM GetLastError}
//
// function LastErrStr(const ShowErrNo: boolean = YES {LastErr is always show something}): string;
// begin
//   Result := ErrStr(GetLastError, ShowErrNo);
// end;
//
// //function ShowMsgYN(const title, text: string; const owner: integer = 0;
// //  const DefaultYes: Boolean = YES): word; forward;
//
// function MessageBoxEx(hWnd: HWND; lpText, lpCaption: PChar; uType: UINT; wLanguageId: Word): integer; stdcall;
//   external user32 name 'MessageBoxExA'; {$EXTERNALSYM MessageBoxEx}
//
// type
//   TMsgKind = (mtWarning, mtError, mtInformation, mtConfirmation);
//
// function _ShowMsg(const MsgKind: TMsgKind; title, text: string; const DefBtnYES: boolean): word; // hOwner: cardinal): word;
// const
//   { MessageBox() Flags }
//   MB_OK = $00000000; // {$EXTERNALSYM MB_OK}
//   MB_YESNO = $00000004; // {$EXTERNALSYM MB_YESNO}
//
//   MB_ICONHAND = $00000010; // {$EXTERNALSYM MB_ICONHAND}
//   MB_ICONQUESTION = $00000020; // {$EXTERNALSYM MB_ICONQUESTION}
//   MB_ICONEXCLAMATION = $00000030; // {$EXTERNALSYM MB_ICONEXCLAMATION}
//   MB_ICONASTERISK = $00000040; // {$EXTERNALSYM MB_ICONASTERISK}
//   MB_USERICON = $00000080; // {$EXTERNALSYM MB_USERICON}
//   MB_ICONWARNING = MB_ICONEXCLAMATION; // {$EXTERNALSYM MB_ICONWARNING}
//   MB_ICONERROR = MB_ICONHAND; // {$EXTERNALSYM MB_ICONERROR}
//   MB_ICONINFORMATION = MB_ICONASTERISK; // {$EXTERNALSYM MB_ICONINFORMATION}
//   MB_ICONSTOP = MB_ICONHAND; // {$EXTERNALSYM MB_ICONSTOP}
//
//   MB_DEFBUTTON1 = $00000000; // {$EXTERNALSYM MB_DEFBUTTON1}
//   MB_DEFBUTTON2 = $00000100; // {$EXTERNALSYM MB_DEFBUTTON2}
//   MB_APPLMODAL = $00000000; // {$EXTERNALSYM MB_APPLMODAL}
//   MB_SYSTEMMODAL = $00001000; // {$EXTERNALSYM MB_SYSTEMMODAL}
//   MB_TASKMODAL = $00002000; // {$EXTERNALSYM MB_TASKMODAL}
//   MB_SETFOREGROUND = $00010000; // {$EXTERNALSYM MB_SETFOREGROUND}
//   MB_TOPMOST = $00040000; // {$EXTERNALSYM MB_TOPMOST}
//
//   Default_mbSet = mb_systemmodal + mb_SetForeGround + mb_TopMost;
//
// const
//   titles: array[TMsgKind] of string = ('Error!', 'Information', 'Confirmation', 'Caution!');
//   Default_mb = mb_systemmodal + mb_SetForeGround + mb_TopMost;
//   mbSets: array[TMsgKind] of cardinal = (mb_IconExclamation or mb_DefButton2, mb_IconStop, 0, mb_IconQuestion);
//   dash = CHAR_DASH;
// var
//   mbSet: cardinal;
// begin
//   mbSet := Default_mbSet or mbSets[MsgKind];
//   if MsgKind in [mtWarning, mtConfirmation] then begin
//     mbSet := mbSet or mb_YesNo;
//     if not DefBtnYES then mbSet := mbSet or MB_DEFBUTTON2;
//   end;
//   //if hOwner = 0 then
//   //hOwner := CommonHandle;
//   if title = dash then
//     title := titles[MsgKind];
//   Result := MessageBoxEx(0 {hOwner}, pchar(text), pchar(title), mbSet, 0);
// end;
//
// function ShowLastErr(title: string = ''; const ShowErrNo: boolean = TRUE;
//   const AlwaysShowMessage: Boolean = TRUE): word; overload; // hOwner: Cardinal = 0): word;
// begin
//   Result := _Showmsg(mtError, title, ErrStr(GetLastError, ShowErrNo, AlwaysShowMessage), FALSE); //, hOwner);
// end;
//
// function ShowmsgError(const ErrNo: integer; title: string = '';
//   const ShowErrNo: boolean = TRUE; const AlwaysShowMessage: Boolean = TRUE): word; overload; // hOwner: Cardinal = 0): word;
// begin
//   Result := _Showmsg(mtError, title, ErrStr(ErrNo, ShowErrNo, AlwaysShowMessage), FALSE); //, hOwner);
// end;
//
// function ShowMsgError(const text: string; title: string = ''): word; overload; // hOwner: Cardinal = 0): word;
// begin
//   Result := _ShowMsg(mtError, title, Text, FALSE); //, hOwner);
// end;
//
// function ShowMsgOK(const text: string; title: string = ''): word; // hOwner: Cardinal = 0): word;
// begin
//   Result := _ShowMsg(mtInformation, title, Text, FALSE); //, hOwner);
// end;
//
// function ConfirmYN(const text: string; title: string = ''): word; // hOwner: Cardinal = 0): word;
// begin
//   Result := _ShowMsg(mtConfirmation, title, Text, FALSE); //, hOwner);
// end;
//
// function ConfirmCritical(const text: string; title: string = ''; DefaultIsYES: boolean = FALSE): word; // hOwner: Cardinal = 0): word;
// begin
//   Result := _ShowMsg(mtWarning, title, Text, DefaultIsYES); //, hOwner);
// end;
//====================================================================
// error number to string conversion

function ErrStr(const ErrNo: Cardinal; const ShowErrNo: Boolean = YES;
  const AlwaysShowMessage: Boolean = YES): string;
// if (AlwaysShowMessage is set to YES), then if the message
// to be shown is not available (it did happen sometimes),
// then Result is a string "the message is not available".
// if set to FALSE then Result is simply an empty string.
begin
  Result := Shower.ErrStr(ErrNo, ShowErrNo, AlwaysShowMessage)
end;

function LastErrStr(const ShowErrNo: boolean = YES): string;
// ErrStr is essential routines to translate error number to string
// LastErr is basically just a macro which calls & translate GetLastError to string
begin
  Result := Shower.LastErrStr(ShowErrNo)
end;

// various showmessage replacement

function ShowmsgOK(const text: string; title: string = ''): word; // hOwner: Cardinal = 0): word;
begin
  Result := Shower.ShowmsgOK(text, title)
end;

function ShowmsgError(const text: string; title: string = ''): word; overload; // hOwner: Cardinal = 0): word;
begin
  Result := Shower.ShowmsgError(text, title)
end;

function ConfirmYN(const text: string; title: string = ''): word; // hOwner: Cardinal = 0): word;
begin
  Result := Shower.ConfirmYN(text, title)
end;

function ConfirmCritical(const text: string; title: string = '';
  const DefaultIsYES: boolean = FALSE): word; // hOwner: Cardinal = 0): word;
// confirmation - check Result against idYES or idNO
begin
  Result := Shower.ConfirmCritical(text, title, DefaultIsYES)
end;

// error result showmessage

function ShowmsgError(const ErrNo: integer; title: string = '';
  const ShowErrNo: boolean = YES; const AlwaysShowMessage: Boolean = YES): word; overload; // hOwner: Cardinal = 0): word;
begin
  Result := Shower.ShowmsgError(ErrNo, title, ShowErrNo, AlwaysShowMessage)
end;

function ShowLastErr(title: string = ''; const ShowErrNo: boolean = YES;
  const AlwaysShowMessage: Boolean = YES): word; overload; // hOwner: Cardinal = 0): word;
begin
  Result := Shower.ShowLastErr(title, ShowErrNo, AlwaysShowMessage)
end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  MOVED to Shower unit
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

type
  PStartupInfo = ^TStartupInfo;
  TStartupInfo = record
    cb: DWORD;
    lpReserved: Pointer;
    lpDesktop: Pointer;
    lpTitle: Pointer;
    dwX: DWORD;
    dwY: DWORD;
    dwXSize: DWORD;
    dwYSize: DWORD;
    dwXCountChars: DWORD;
    dwYCountChars: DWORD;
    dwFillAttribute: DWORD;
    dwFlags: DWORD;
    wShowWindow: word;
    cbReserved2: word;
    lpReserved2: PByte;
    hStdInput: THandle;
    hStdOutput: THandle;
    hStdError: THandle;
  end;

  PProcessInformation = ^TProcessInformation;
  TProcessInformation = record
    hProcess: THandle;
    hThread: THandle;
    dwProcessID: DWORD;
    dwThreadID: DWORD;
  end;

  PSecurityAttributes = ^TSecurityAttributes;
  TSecurityAttributes = record
    nLength: DWORD;
    lpSecurityDescriptor: Pointer;
    bInheritHandle: BOOL;
  end;

const
  SW_HIDE = 0;
  ERROR_SUCCESS = 0;
  MAX_PATH = 260;
  STATUS_TIMEOUT = $00000102;
  STARTF_USESHOWWINDOW = 1;
  CREATE_NEW_CONSOLE = $00000010;

function CreateProcess(lpApplicationName: PChar; lpCommandLine: PChar;
  lpProcessAttributes, lpThreadAttributes: PSecurityAttributes;
  bInheritHandles: BOOL; dwCreationFlags: DWORD; lpEnvironment: Pointer;
  lpCurrentDirectory: PChar; const lpStartupInfo: TStartupInfo;
  var lpProcessInformation: TProcessInformation): BOOL; stdcall;
  external kernel32 name 'CreateProcessA'; {$EXTERNALSYM CreateProcess}

function TerminateProcess(hProcess: THandle; uExitCode: UINT): BOOL; stdcall;
  external kernel32 name 'TerminateProcess'; {$EXTERNALSYM CreateProcess}

function WaitForSingleObject(hHandle: THandle; dwMilliseconds: DWORD): DWORD; stdcall;
  external kernel32 name 'WaitForSingleObject'; {$EXTERNALSYM WaitForSingleObject}

function GetExitCodeProcess(hProcess: THandle; var lpExitCode: DWORD): BOOL; stdcall;
  external kernel32 name 'GetExitCodeProcess'; {$EXTERNALSYM GetExitCodeProcess}

function WindowFromPoint(PosX, PosY: longint): HWND; stdcall;
  external user32 name 'WindowFromPoint'; {$EXTERNALSYM WindowFromPoint}

function WaitForFinish(CommandLine: string; ShowMode: integer = 0; TimeOut: integer = 5000): integer;
var
  //AppName: array[byte] of Char;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
begin
  //StrPCopy(AppName, Filename);
  //FillChar(AppName, sizeof(AppName), #0);
  //move(CommandLine[1], AppName[0], Length(CommandLine));
  FillChar(StartupInfo, sizeof(StartupInfo), #0);
  StartupInfo.cb := sizeof(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := ShowMode;
  if not CreateProcess(nil, pChar(CommandLine), nil, nil, FALSE, CREATE_NEW_CONSOLE or
    NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, ProcessInfo) then
    Result := -1
  else begin
    Result := WaitforSingleObject(ProcessInfo.hProcess, TimeOut);
    if Result = STATUS_TIMEOUT then
      TerminateProcess(ProcessInfo.hProcess, STATUS_TIMEOUT);
    GetExitCodeProcess(ProcessInfo.hProcess, Cardinal(Result));
    CloseHandle(ProcessInfo.hProcess);
    CloseHandle(ProcessInfo.hThread);
  end;
end;

function SendMessage(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
  external user32 name 'SendMessageA'; {$EXTERNALSYM SendMessage}

function GetCaptionAtPoint(PosX, PosY: Longint): string;
const
  WM_GETTEXT = $000D; //{$EXTERNALSYM WM_GETTEXT}
  WM_GETTEXTLENGTH = $000E; //{$EXTERNALSYM WM_GETTEXTLENGTH}
var
  textlength: integer;
  Text: PChar;
  Handle: HWND;
begin
  Result := ''; //Empty
  Handle := WindowFromPoint(PosX, PosY);
  if Handle = 0 then
    Exit;
  textlength := SendMessage(Handle, WM_GETTEXTLENGTH, 0, 0);
  if textlength <> 0 then begin
    getmem(Text, textlength + 1);
    SendMessage(Handle, WM_GETTEXT, textlength + 1, integer(Text));
    Result := Text;
    freemem(Text);
  end;
end;

function GetVolumeInformation(lpRootPathName: PChar;
  lpVolumeNameBuffer: PChar; nVolumeNameSize: DWORD; lpVolumeSerialNumber: PDWORD;
  var lpMaximumComponentLength, lpFileSystemFlags: DWORD;
  lpFileSystemNameBuffer: PChar; nFileSystemNameSize: DWORD): BOOL; stdcall;
  external kernel32 name 'GetVolumeInformationA'; {$EXTERNALSYM GetVolumeInformation}

function GetHDVolumeInfo(const LogicalDrive: Char = 'C'): integer;
var
  SerialNum, a, b: dword;
  Buffer: array[0..255] of Char;
begin
  Result := 0;
  try
    if GetVolumeInformation(pChar(LogicalDrive + ':\'), Buffer,
      sizeof(Buffer), @SerialNum, a, b, nil, 0) then
      Result := SerialNum;
  except
    Result := -1;
  end;
end;

function GetHDSerialNumber(const PhysicalDriveNo: integer = 0;
  const MSG_ON_ERROR: string = '1nv4l1d5n'): string;
begin
  Result := ExtractDelimited(__GetHDSN(YES, ^J), PhysicalDriveNo + 1, ^J);
  if Result = '' then
    Result := MSG_ON_ERROR
end;

type
  POverlapped = ^TOverlapped;
  TOverlapped = record
    Internal: DWORD;
    InternalHigh: DWORD;
    Offset: DWORD;
    OffsetHigh: DWORD;
    hEvent: THandle;
  end;

  //~ function CreateFile(lpFilename: PChar; dwDesiredAccess, dwShareMode: Cardinal;
  //~   lpSecurityAttributes: pointer {PSecurityAttributes}; dwCreationDisposition,
  //~   dwFlagsAndAttributes: Cardinal; hTemplateFile: Cardinal): Cardinal; stdcall;
  //~   external kernel32 name 'CreateFileA'; {$EXTERNALSYM CreateFile}

function DeviceIOControl(hDevice: THandle; dwIoControlCode: DWORD; lpInBuffer: Pointer;
  nInBufferSize: DWORD; lpOutBuffer: Pointer; nOutBufferSize: DWORD;
  var lpBytesReturned: DWORD; lpOverlapped: POverlapped): BOOL; stdcall;
  external kernel32 name 'DeviceIoControl'; {$EXTERNALSYM DeviceIOControl}

function __GetHDSN(const FindAll: boolean = FALSE; const ListDelimiter: string = ^J): string;
const
  INVALID_HANDLE_VALUE = DWORD(-1); //{$EXTERNALSYM INVALID_HANDLE_VALUE}
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
    bIDEStatus: byte; // Contents of IDE Error register. Only valid when bDriverError is SMART_IDE_ERROR.
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
    bBuffer: array[0..0] of byte; // Buffer of arbitrary length in which to store the data read from the drive.
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

  function SmartIdentifyDirect(hDevice: THandle; bDriveNum: byte; bIDCmd: byte; var IDSector: TIDSector; var IDSectorSize: LongInt): BOOL;
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
        bCommandReg := bIDCmd; // The command can either be IDE identify or ATAPI identify.
      end;
    end;
    Result := DeviceIOControl(hDevice, DFP_RECEIVE_DRIVE_DATA, @SCIP,
      sizeof(TSendCmdInParams) - 1, @SCOP, BufferSize, dwBytesReturned, nil);
    if Result = YES then begin
      IDSectorSize := dwBytesReturned - sizeof(TSendCmdOutParams) + 1;
      if IDSectorSize <= 0 then
        IDSectorSize := 0
      else
        System.Move(SCOP.bBuffer, IDSector, IDSectorSize);
    end;
  end;

  //-------------------------------------------------------------
  // Same as above but
  //  - work only NT;
  //  - work with cotroller or device handle.
  // Note: Administrator priveleges are not required to open controller handle.

  function SmartIdentifyMiniport(hDevice: THandle; bTargetId: byte; bIDCmd: byte;
    var IDSector: TIDSector; var IDSectorSize: LongInt): BOOL;
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
      bDriveNumber := bTargetId;
      with irDriveRegs do begin
        bFeaturesReg := 0;
        bSectorCountReg := 1;
        bSectorNumberReg := 1;
        bCylLowReg := 0;
        bCylHighReg := 0;
        bDriveHeadReg := $A0 or ((bTargetId and 1) shl 4);
        bCommandReg := bIDCmd; // The command can either be IDE identify or ATAPI identify.
      end;
    end;
    Result := DeviceIOControl(hDevice, IOCTL_SCSI_MINIPORT, @Buffer,
      BufferLength, @Buffer, BufferLength, cbBytesReturned, nil);
    if Result = YES then begin
      IDSectorSize := cbBytesReturned - sizeof(SRB_IO_CONTROL) - sizeof(TSendCmdOutParams) + 1;
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
  begin
    Result := '';
    with IDSector do begin
      SwapBytes(sSerialNumber, sizeof(sSerialNumber));
      SwapBytes(sFirmwareRev, sizeof(sFirmwareRev));
      SwapBytes(sModelNumber, sizeof(sModelNumber));
      Result := sSerialNumber + sFirmwareRev + sModelNumber;

      // Result := Result + 'cyl:' + intohex(wNumCyls, 4);
      // Result := Result + ' rsv:' + intohex(wReserved, 4);
      // Result := Result + ' hds:' + intohex(wNumHeads, 4);
      // Result := Result + ' b/t:' + intohex(wBytesPerTrack, 4);
      // Result := Result + ' b/s:' + intohex(wBytesPerSector, 4);
      // Result := Result + ' s/t:' + intohex(wSectorsPerTrack, 4);
      // Result := Result + ' s/t:' + intohex(wSectorsPerTrack, 4);
      // Result := Result + ^j;
      //
      // Result := Result + ' CYL:' + intohex(wNumCurrentCyls, 4);
      // Result := Result + ' HDS:' + intohex(wNumCurrentHeads, 4);
      // Result := Result + ' S/T:' + intohex(wNumCurrentSectorsPerTrack, 4);

      //Result := sSerialNumber + sFirmwareRev + sModelNumber;
      //Result := Result + '-';
      //for i := length(Result) downto 1 do
      //  if not (Result[i] in ['0'..'9', 'A'..'Z', 'a'..'z']) then
      //  delete(Result, i, 1);
    end;
  end;

const
  _NONE_ = 0;
  CREATE_NEW = 1; //{$EXTERNALSYM CREATE_NEW}
  GENERIC_READ = DWORD($80000000); //{$EXTERNALSYM GENERIC_READ}
  GENERIC_WRITE = $40000000; //{$EXTERNALSYM GENERIC_WRITE}
  OPEN_READWRITE = GENERIC_READ or GENERIC_WRITE;
  FILE_SHARE_READ = $00000001; //{$EXTERNALSYM FILE_SHARE_WRITE}
  FILE_SHARE_WRITE = $00000002; //{$EXTERNALSYM FILE_SHARE_WRITE}
  SHARE_READWRITE = FILE_SHARE_READ or FILE_SHARE_WRITE;
  OPEN_EXISTING = 3; //{$EXTERNALSYM OPEN_EXISTING}

var
  Continued: boolean;

  function DirectIdentify(DriveNum: TDriveNum = 0): string;
  var
    hDevice: THandle;
    nIdSectorSize: LongInt;
    Buffer: array[0..IDENTIFY_BUFFER_SIZE - 1] of byte;
    IDSector: TIDSector absolute Buffer;
  const
    IDE_ID_FUNCTION = $EC;
  begin
    Result := '';
    if not IsWinNT then
      //hDevice := CreateFile('\\.\SMARTVSD', 0, 0, nil, CREATE_NEW, 0, 0)
      hDevice := fDfuncs.fHandleOpen('\\.\SMARTVSD', fmOpenQuery, fcCreateNew, faNone)
    else
      //hDevice := CreateFile(PChar('\\.\PhysicalDrive' + intoStr(DriveNum)),
      //  GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE,
      //  nil, OPEN_EXISTING, 0, 0)
      hDevice := fDfuncs.fHandleOpen('\\.\PhysicalDrive' + intoStr(DriveNum),
        fmOpenReadWrite or fmShareDenyNone, fcOpenExisting, faNone)
        ;

    if hDevice = INVALID_HANDLE_VALUE then begin
      // ShutDown(wrReboot);
    end
    else begin
      FillChar(Buffer, sizeof(Buffer), #0);
      try
        if SmartIdentifyDirect(hDevice, DriveNum, IDE_ID_FUNCTION, IdSector, nIdSectorSize) then
          Result := ExtractHDInfo(IDSector);
      finally
        fDfuncs.fHandleClose(hDevice);
      end;
    end;
    Continued := (Result = '') or FindAll;
  end;

  function EnumSCSIPortNo(iPort: TSCSIPortNum = 0; const FindAll: boolean = FALSE): string;
  const
    BufferSize = 2048;
  const
    IDE_ID_FUNCTION = $EC; // Returns ID sector for ATA.
  var
    hDevice: THandle;
    i: integer;
    pData: PSCSIInquiryData;
    dwSize, nOffset: DWORD;
    Buffer: array[0..BufferSize - 1] of byte;
    SCSIData: TSCSIAdapterBusInfo absolute Buffer;

    nIDSectorSize: LongInt;
    IDBuffer: array[0..IDENTIFY_BUFFER_SIZE - 1] of byte;
    IDSector: TIDSector absolute IDBuffer;
  begin
    Result := '';
    //hDevice := CreateFile(PChar('\\.\SCSI' + intoStr(iPort) + ':'), GENERIC_READ or GENERIC_WRITE,
    //  FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
    hDevice := fDfuncs.fHandleOpen('\\.\SCSI' + intoStr(iPort) + ':',
      fmOpenReadWrite or fmShareDenyNone, fcOpenExisting, faNone);
    //  FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
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
                if SmartIdentifyMiniport(hDevice, pData^.TargetId,
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
        fDfuncs.fHandleClose(hDevice);
      end;
    end;
  end;

var
  i: integer;
begin
  Result := '';
  Continued := YES;
  if not IsWinNT or IsAdmin then
    for i := 0 to high(TDriveNum) do begin
      CatDelimit(Result, DirectIdentify(i), ListDelimiter);
      if not Continued then
        break;
    end
  else begin
    for i := 0 to high(TDriveNum) do begin
      CatDelimit(Result, EnumSCSIPortNo(i, FindAll), ListDelimiter);
      if not Continued then
        break;
    end;
  end;
end;

function _IDESN(const Alphaized: boolean; const truncate9: boolean = TRUE;
  const INVALID_MSG: string = 'INVALID-SN'): string;
//test...
  function Alphaize(S: string): string;
  const
    Ord_OFFSET = ord('A') - ord('0'); // 17? CMIIW
    //NINE = 9;
  var
    i: integer;
    //L: integer;
  begin
    //for i := length(S) downto 1 do
    //  if not (S[i] in ALPHANUMERIC) then
    //    delete(S, i, 1);
    //
    //L := length(S);
    //
    //if L = 0 then Result := INVALID_MSG + '0'
    //else begin
    //  Result := upperStr(S);
    //  //if Alphaized then begin
    //    if L < NINE then
    //      for i := L + 1 to NINE do
    //        Result := Result + intoStr(i);
    //
    //    for i := 1 to length(S) do
    //      if (Result[i] in NUMERIC) then
    //        Result[i] := char(ord(Result[i]) + Ord_OFFSET);
    //  //end;
    //  Result := copy(Result, 1, 9);
    Result := upperStr(S);
    for i := 1 to length(S) do
      if (Result[i] in NUMERIC) then
        Result[i] := char(ord(Result[i]) + Ord_OFFSET);
    //end;
  end;

  //notes:
  //  wVendorUnique: array[0..2] of Word;
  //  sSerialNumber: array[0..19] of Char;
  //  wBufferType, wBufferSize, wECCSize: word;
  //  sFirmwareRev: array[0..7] of Char;
  //  sModelNumber: array[0..39] of Char;
const
  //WRONG!NEVERDOTHIS! SN_LEN = 20 - 1; //left-1 for 0-ASCIIZ
  SN_LEN = 20; // wrong -> // - 1; //left-1 for 0-ASCIIZ

begin
  Result := trimStr(Copy(__GetHDSN, 1, SN_LEN));
  if Result = '' then
    Result := INVALID_MSG
  else begin
    if truncate9 then begin
      Result := Copy(Result, 1, 9);
      if length(Result) < 9 then begin
      end;
    end;
    if Alphaized then
      Result := Alphaize(Result);
  end;
end;

function GetUserNameA(lpBuffer: PChar; var nSize: DWORD): BOOL; stdcall;
  external advapi32 name 'GetUserNameA'; {$EXTERNALSYM GetUserNameA}

function GetComputerNameA(lpBuffer: PAnsiChar; var nSize: DWORD): BOOL; stdcall;
  external kernel32 name 'GetComputerNameA'; {$EXTERNALSYM GetComputerNameA}

function GetWorkstationInfo(const infokind: TWorkstationInfo = wiUserName): string;
const
  MAX_NAMELENGTH = 64;
var
  c: Cardinal;
  success: boolean;
begin
  if infokind = wiDomainName then
    Result := _DomainName
  else begin
    c := MAX_NAMELENGTH;
    setLength(Result, c);
    if infokind = wiUserName then
      success := GetUserNameA(pChar(Result), c)
    else
      success := GetComputerNameA(pChar(Result), c);
    if not success then
      Result := UNKNOWN;
  end;
end;

function GetWorkstationInfo(const infokinds: WorkstationInfos = [wiUserName, wiComputerName, wiDomainName];
  const delimiter: char = CHAR_TAB): string; overload;
var
  wi: TWorkStationInfo;
begin
  Result := '';
  for wi := low(wi) to high(wi) do
    CatDelimit(Result, GetWorkStationInfo(wi), delimiter)
end;

function _ComputerName: string;
const
  MAX_COMPUTERNAME_LENGTH = 32;
var
  c: Cardinal;
begin
  c := MAX_COMPUTERNAME_LENGTH + 1;
  setLength(Result, c);
  if getComputerNameA(pChar(Result), c) then
    Result := string(pChar(Result))
  else
    Result := UNKNOWN;
end;

function _UserName: string;
const
  MAX_COMPUTERNAME_LENGTH = 64;
var
  c: Cardinal;
begin
  c := MAX_COMPUTERNAME_LENGTH + 1;
  setLength(Result, c);
  if getUserNameA(pChar(Result), c) then
    Result := string(pChar(Result))
  else
    Result := UNKNOWN;
end;

type
  HINST = type LongWord;
  HMODULE = HINST; { HMODULEs can be used in place of HINSTs }
  LPCSTR = PANSIChar;
  FARPROC = Pointer;

function LoadLibrary(lpLibFilename: PAnsiChar): HMODULE; stdcall;
  external kernel32 name 'LoadLibraryA'{$EXTERNALSYM LoadLibrary}

function FreeLibrary(hLibModule: HMODULE): BOOL; stdcall;
  external kernel32 name 'FreeLibrary'; {$EXTERNALSYM FreeLibrary}

function GetProcAddress(hModule: HMODULE; lpProcName: LPCSTR): FARPROC; stdcall;
  external kernel32 name 'GetProcAddress'; {$EXTERNALSYM GetProcAddress}

type
  HKEY = type LongWord;
  //  PHKEY = ^HKEY;

const
  HKEY_CLASSES_ROOT = DWORD($80000000); {$EXTERNALSYM HKEY_CLASSES_ROOT}
  HKEY_CURRENT_USER = DWORD($80000001); {$EXTERNALSYM HKEY_CURRENT_USER}
  HKEY_LOCAL_MACHINE = DWORD($80000002); {$EXTERNALSYM HKEY_LOCAL_MACHINE}
  HKEY_USERS = DWORD($80000003); {$EXTERNALSYM HKEY_USERS}
  HKEY_PERFORMANCE_DATA = DWORD($80000004); {$EXTERNALSYM HKEY_PERFORMANCE_DATA}
  HKEY_CURRENT_CONFIG = DWORD($80000005); {$EXTERNALSYM HKEY_CURRENT_CONFIG}
  HKEY_DYN_DATA = DWORD($80000006); {$EXTERNALSYM HKEY_DYN_DATA}

  HKCR = HKEY_CLASSES_ROOT;
  HKCU = HKEY_CURRENT_USER;
  HKLM = HKEY_LOCAL_MACHINE;

  HKU = HKEY_USERS;
  HKPD = HKEY_PERFORMANCE_DATA;
  HKCC = HKEY_CURRENT_CONFIG;
  HKDN = HKEY_DYN_DATA;

function RegCloseKey(hKey: HKEY): Longint; stdcall;
  external advapi32 name 'RegCloseKey'; {$EXTERNALSYM RegCloseKey}

function RegOpenKey(hKey: HKEY; lpSubKey: PChar; var phkResult: HKEY): Longint; stdcall;
  external advapi32 name 'RegOpenKeyA'; {$EXTERNALSYM RegOpenKey}

function RegOpenKeyEx(hKey: HKEY; lpSubKey: PAnsiChar;
  ulOptions: DWORD; samDesired: DWORD; var phkResult: HKEY): Longint; stdcall;
  external advapi32 name 'RegOpenKeyExA'; {$EXTERNALSYM RegOpenKeyEx}

function RegQueryValue(hKey: HKEY; lpSubKey: PChar; lpValue: PChar;
  var lpcbValue: Longint): Longint; stdcall;
  external advapi32 name 'RegQueryValueA'; {$EXTERNALSYM RegQueryValue}

function RegQueryValueEx(hKey: HKEY; lpValueName: PAnsiChar; lpReserved: Pointer;
  lpType: PDWORD; lpData: PByte; lpcbData: PDWORD): Longint; stdcall;
  external advapi32 name 'RegQueryValueExA'; {$EXTERNALSYM RegQueryValueEx}

function _DomainName: AnsiString;
type
  WKSTA_INFO_100 = record
    wki100_platform_id: integer;
    wki100_computername: PWideChar;
    wki100_langroup: PWideChar;
    wki100_ver_major: integer;
    wki100_ver_minor: integer;
  end;

  WKSTA_USER_INFO_1 = record
    wkui1_username: PChar;
    wkui1_logon_domain: PChar;
    wkui1_logon_server: PChar;
    wkui1_oth_domains: PChar;
  end;

type
  //Win9X ANSI prototypes from RADMIN32.DLL and RLOCAL32.DLL
  TWin95_NetUserGetInfo = function(ServerName, UserName: PChar; Level: DWORD; var BfrPtr: Pointer): integer; stdcall;
  TWin95_NetApiBufferFree = function(BufPtr: Pointer): integer; stdcall;
  TWin95_NetWkstaUserGetInfo = function(Reserved: PChar; Level: integer; var BufPtr: Pointer): integer; stdcall; //

  //WinNT UNICODE equivalents from NETAPI32.DLL
  TWinNT_NetWkstaGetInfo = function(ServerName: PWideChar; level: integer; var BufPtr: Pointer): integer; stdcall;
  TWinNT_NetApiBufferFree = function(BufPtr: Pointer): integer; stdcall;

var
  Win95_NetUserGetInfo: TWin95_NetUserGetInfo;
  Win95_NetApiBufferFree: TWin95_NetApiBufferFree;
  Win95_NetWkstaUserGetInfo: TWin95_NetWkstaUserGetInfo; //?

  WinNT_NetWkstaGetInfo: TWinNT_NetWkstaGetInfo;
  WinNT_NetApiBufferFree: TWinNT_NetApiBufferFree;

  WSNT: ^WKSTA_INFO_100;
  WS95: ^WKSTA_USER_INFO_1;

  EC: DWORD;
  hNETAPI: THandle;

  KEY: HKEY;
  n: integer;

const
  radmin32 = 'radmin32.dll';
  netapi32 = 'netapi32.dll';

const
  KNET: string = 'System\CurrentControlSet\Services\VxD\VNETSUP';
  VWorkGroup: string = 'Workgroup';
  KEY_READ = $20019;

begin
  Result := '';
  hNETAPI := 0;
  try
    if IsWinNT then begin
      hNETAPI := LoadLibrary(netapi32);
      //because of different dll, here we're dynamically load the library
      if hNETAPI <> 0 then begin
        @WinNT_NetWkstaGetInfo := GetProcAddress(hNETAPI, 'NetWkstaGetInfo');
        @WinNT_NetApiBufferFree := GetProcAddress(hNETAPI, 'NetApiBufferFree');

        EC := WinNT_NetWkstaGetInfo(nil, 100, Pointer(WSNT));
        if EC = 0 then begin
          Result := WideCharToString(WSNT^.wki100_langroup);
          WinNT_NetApiBufferFree(Pointer(WSNT));
        end;
      end;
    end
    else begin
      hNETAPI := LoadLibrary(radmin32);
      //because of different dll, here we're dynamically load the library
      if hNETAPI <> 0 then begin
        @Win95_NetApiBufferFree := GetProcAddress(hNETAPI, 'NetApiBufferFree');
        @Win95_NetUserGetInfo := GetProcAddress(hNETAPI, 'NetUserGetInfoA');
        @Win95_NetWkstaUserGetInfo := GetProcAddress(hNETAPI, 'NetWkstaUserGetInfoA');

        EC := Win95_NetWkstaUserGetInfo(nil, 1, Pointer(WS95)); //?
        if EC = 0 then begin
          Result := WS95^.wkui1_logon_domain;
          Win95_NetApiBufferFree(Pointer(WS95));
        end
      end
      else begin
        if RegOpenKeyEx(HKLM, pChar(KNET), KEY_READ, 0, KEY) = 0 then begin
          n := high(byte);
          setlength(Result, n);
          if RegQueryValueEx(KEY, pChar(VWorkGroup), nil, nil, @Result[1], @n) <> 0 then
            Result := ''
          else
            Result := string(pChar(Result));
          RegCloseKey(KEY);
        end;
      end;
    end;
  finally
    if hNETAPI <> 0 then
      FreeLibrary(hNETAPI);
  end;
end;

type
  TSIDIdentifierAuthority = record
    Value: array[0..5] of byte;
  end;

  TTokenInformationClass = (TokenICPad, TokenUser, TokenGroups, TokenPrivileges,
    TokenOwner, TokenPrimaryGroup, TokenDefaultDacl, TokenSource, TokenType,
    TokenImpersonationLevel, TokenStatistics);

function AllocateAndInitializeSID(const pIdentifierAuthority: TSIDIdentifierAuthority;
  nSubAuthorityCount: byte; nSubAuthority0, nSubAuthority1: DWORD;
  nSubAuthority2, nSubAuthority3, nSubAuthority4: DWORD;
  nSubAuthority5, nSubAuthority6, nSubAuthority7: DWORD;
  var pSID: Pointer): BOOL; stdcall;
  external advapi32 name 'AllocateAndInitializeSid'; {$EXTERNALSYM AllocateAndInitializeSid}

function OpenThreadToken(ThreadHandle: THandle; DesiredAccess: DWORD;
  OpenAsSelf: BOOL; var TokenHandle: THandle): BOOL; stdcall;
  external advapi32 name 'OpenThreadToken'; {$EXTERNALSYM OpenThreadToken}

function GetTokenInformation(TokenHandle: THandle;
  TokenInformationClass: TTokenInformationClass; TokenInformation: Pointer;
  TokenInformationLength: DWORD; var ReturnLength: DWORD): BOOL; stdcall;
  external advapi32 name 'GetTokenInformation'; {$EXTERNALSYM GetTokenInformation}

function EqualSID(pSID1, pSID2: Pointer): BOOL; stdcall;
  external advapi32 name 'EqualSid'; {$EXTERNALSYM EqualSID}

function FreeSID(pSID: Pointer): Pointer; stdcall;
  external advapi32 name 'FreeSid'; {$EXTERNALSYM FreeSID}

const
  ERROR_NO_TOKEN = 1008;
  SECURITY_BUILTIN_DOMAIN_RID = $00000020;
  DOMAIN_ALIAS_RID_ADMINS = $00000220;
  SECURITY_NT_AUTHORITY: TSIDIdentifierAuthority = (Value: (0, 0, 0, 0, 0, 5));

type
  PSID = pointer;

  TSIDAndAttributes = record
    SID: PSID;
    Attributes: DWORD;
  end;

  pTokenGroups = ^TTokenGroups;
  TTokenGroups = record
    GroupCount: DWORD;
    Groups: array[0..0] of TSIDAndAttributes;
  end;

function IsAdmin: Boolean;
const
  INVALID = INVALID_HANDLE_VALUE and $19091969;
{$IFOPT J-}{$DEFINE J_OFF}{$J+}{$ENDIF}
  fIsAdmin: cardinal = INVALID;
{$IFDEF J_OFF}{$J-}{$ENDIF}
var
  hAccessToken: THandle;
  ptgGroups: PTokenGroups;
  dwInfoBufferSize: DWORD;
  pSIDAdministrators: PSID;
  x: integer;
  bSuccess: BOOL;
begin
  Result := boolean(fIsAdmin);
  if fIsAdmin <> INVALID then exit;
  if not IsWinNT then exit;
  //Result := FALSE;
  fIsAdmin := 0;
  bSuccess := OpenThreadToken(GetCurrentThread, TOKEN_QUERY, YES,
    hAccessToken);
  if not bSuccess then begin
    if GetLastError = ERROR_NO_TOKEN then
      bSuccess := OpenProcessToken(GetCurrentProcess, TOKEN_QUERY,
        hAccessToken);
  end;
  if bSuccess then begin
    GetMem(ptgGroups, 1024);
    bSuccess := GetTokenInformation(hAccessToken, TokenGroups,
      ptgGroups, 1024, dwInfoBufferSize);
    CloseHandle(hAccessToken);
    if bSuccess then begin
      AllocateAndInitializeSID(SECURITY_NT_AUTHORITY, 2,
        SECURITY_BUILTIN_DOMAIN_RID, DOMAIN_ALIAS_RID_ADMINS,
        0, 0, 0, 0, 0, 0, pSIDAdministrators);
{$IFOPT R+}{$DEFINE R_ON}{$R-}{$ENDIF}
      for x := 0 to ptgGroups.GroupCount - 1 do
        if EqualSID(pSIDAdministrators, ptgGroups.Groups[x].SID) then begin
          fIsAdmin := 1;
          //Result := YES;
          Break;
        end;
{$IFDEF R_ON}{$R+}{$ENDIF}
      FreeSID(pSIDAdministrators);
    end;
    FreeMem(ptgGroups);
  end;
  Result := boolean(fIsAdmin);
end;

function MakeDumper(Address: Pointer; Size: integer; const Executable: string): boolean;
type
  TBIOSDumper = packed record
    init: integer;
    Base, Count: word; //Count of Blocks (4KB per-Block)
    DATA: packed array[0..high(byte) - sizeof(int64)] of byte;
  end;

const
{$J+}
  Prime1 = 29; Prime2 = 2846863;
  BIOSDumper: TBIOSDumper = (
{$J-}
    init: Prime1 * Prime2; Base: 0; Count: 0; //Count of Blocks (4KB per-Block)
    DATA: ($60, $40, $B9, $D3, $00, $BE, $1D, $01,
    $89, $36, $00, $01, $D1, $E8, $56, $68, $F0, $01, $75, $01, $C3, $D5, $DB, $19,
    $13, $A3, $9D, $99, $59, $83, $91, $9D, $A5, $3F, $C7, $E9, $D9, $DF, $C9, $E3,
    $3F, $AB, $C9, $E3, $E5, $D1, $DD, $DB, $3F, $61, $5B, $5F, $5B, $6B, $19, $13,
    $85, $DD, $DF, $F1, $E3, $D1, $CD, $CF, $E7, $3F, $4F, $C5, $51, $3F, $63, $5F,
    $5F, $67, $57, $3F, $81, $C7, $E3, $D1, $C1, $DB, $3F, $8F, $C1, $CB, $D1, $F3,
    $CF, $19, $13, $C1, $C1, $7F, $E5, $DD, $CB, $E7, $D1, $DB, $C7, $DD, $5B, $DB,
    $C9, $E7, $19, $13, $19, $13, $A9, $E5, $C1, $CD, $C9, $73, $11, $83, $91, $9D,
    $A5, $3F, $7B, $3F, $CB, $D1, $D7, $C9, $DB, $C1, $D9, $C9, $47, $C1, $7F, $9F,
    $B6, $67, $87, $90, $99, $41, $E3, $31, $A3, $AF, $48, $03, $58, $03, $E9, $21,
    $1B, $3C, $15, $2B, $FF, $02, $00, $83, $04, $67, $12, $99, $42, $5F, $02, $D5,
    $76, $7B, $0F, $02, $16, $FC, $41, $FF, $02, $72, $14, $FD, $06, $90, $58, $A2,
    $9F, $66, $8C, $54, $C4, $F0, $15, $2B, $07, $02, $15, $1B, $0B, $01, $66, $B5,
    $85, $66, $80, $67, $1F, $C0, $1C, $B3, $66, $A4, $16, $90, $82, $BF, $04, $99,
    $41, $C1, $E4, $96, $FC, $8C, $FC, $91, $EA, $D5, $66, $80, $67, $98, $99, $41,
    $8B, $FE, $AC, $FE, $C0, $D0, $D8, $AA, $49, $7F, $F7, $C3, $69, $19, $09, $19)
    );

var
  handle: thandle;
begin
  Result := FALSE;
  BIOSDumper.Base := integer(Address) div 16;
  BIOSDumper.Count := (Size + 4095) div 4096;

  Handle := fDfuncs.fHandleOpen(Executable, fmOpenWrite or fmShareDenyWrite, fcCreateAlways, faNormal);
  if Handle <> thandle(-1) then try
    if fHandleWrite(Handle, BIOSDumper, sizeof(BIOSDUmper)) <> sizeof(BIOSDUmper) then
      DeleteFile(PChar(Executable))
    else Result := TRUE;
  finally
    CloseHandle(Handle);
  end;
end;

function GetEnvironmentVariableA(lpName, Buffer: PChar; Size: DWORD): DWORD; stdcall;
  external kernel32 name 'GetEnvironmentVariableA';

function SetErrorMode(uMode: UINT): UINT; stdcall;
  external kernel32 name 'SetErrorMode';

function DumpBIOS(const Address: cardinal; const DumpSize: integer; const Buffer: pointer): boolean;
// remember (for DOS programmer),
//   Start Addres of segment $E000:0000, MUST be written as $E0000 (NOT $E000)
// 1 Block is 4096 bytes, lowest block: 0, highest block: 255
// Buffer MUST be in 4KB fold of DumpSize. Dumpsize = 0 means All blocks
// ie., if DumpSize = 0 then Buffer MUST be as large as 256 Blocks or 1MB!
var
  dump, dumper, ComSpec: string;
begin
  Result := FALSE;
  dumper := tempPath(TRUE, TRUE) + '~rdmp.exe';
  dump := fdFuncs.tempFilename(TRUE);
  if makedumper(pointer(Address), DumpSize, dumper) then try
    SetLength(ComSpec, MAX_PATH + 1);
    SetLength(ComSpec, GetEnvironmentVariableA('ComSpec', PChar(ComSpec), MAX_PATH));
    if ComSpec <> '' then try
      Result := WaitforFinish(ComSpec + ' /c ' + dumper + ' > ' + dump) = ERROR_SUCCESS;
      fDfuncs.ReadBufferFrom(dump, Buffer, DumpSize);
    finally
      DeleteFile(dumper);
    end;
  finally
    DeleteFile(dump);
  end;
end;

const
  version = 'version.dll';

function GetFileVersionInfoSize(lptstrFilename: PChar; var zero: integer): integer; stdcall;
  external version name 'GetFileVersionInfoSizeA';

function GetFileVersionInfo(Filename: PChar; handle, vSize: integer; Data: Pointer): longbool; stdcall;
  external version name 'GetFileVersionInfoA';

function VerQueryValue(Block: Pointer; SubBlock: PChar; var Buffer: Pointer; var vSize: integer): longbool; stdcall;
  external version name 'VerQueryValueA';

function GetVersionNumber(const ExeName: string; var Version, Build: cardinal): Boolean;
type
  DWORD = longword;
  PVSFixedFileInfo = ^TVSFixedFileInfo;
  TVSFixedFileInfo = packed record
    Signature: DWORD; //         { e.g. $feef04bd }
    StrucVersion: DWORD; //      { e.g. $00000042 = "0.42" }
    FileVersionMS: DWORD; //     { e.g. $00030075 = "3.75" }
    FileVersionLS: DWORD; //     { e.g. $00000031 = "0.31" }
    ProductVersionMS: DWORD; //  { e.g. $00030010 = "3.10" }
    ProductVersionLS: DWORD; //  { e.g. $00000031 = "0.31" }
    FileFlagsMask: DWORD; //     { = $3F for version "0.42" }
    FileFlags: DWORD; //         { e.g. VFF_DEBUG | VFF_PRERELEASE }
    FileOS: DWORD; //            { e.g. VOS_DOS_WINDOWS16 }
    FileType: DWORD; //          { e.g. VFT_DRIVER }
    FileSubtype: DWORD; //       { e.g. VFT2_DRV_KEYBOARD }
    FileDateMS: DWORD; //        { e.g. 0 }
    FileDateLS: DWORD; //        { e.g. 0 }
  end;
var
  VerInfoSize: integer;
  VerInfo: Pointer;
  VerValueSize: integer;
  VerValue: PVSFixedFileInfo;
  zero: integer;
begin
  VerInfoSize := GetFileVersionInfoSize(PChar(ExeName), zero);
  Result := VerInfoSize > 0;
  if Result = TRUE then begin
    GetMem(VerInfo, VerInfoSize);
    try
      GetFileVersionInfo(PChar(ExeName), 0, VerInfoSize, VerInfo);
      VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
      with VerValue^ do begin
        Version := FileVersionMS;
        Build := FileVersionLS;
      end;
    finally
      FreeMem(VerInfo, VerInfoSize);
    end
  end
end;

function GetVersionInfo(const Filename: string; const DigitOnly: Boolean = FALSE): string;
//begin
//  Result := VersionInfo.VersionInfoText(Filename, DigitOnly);
//end;
//function VersionInfoText(const Filename: string; const DigitOnly: Boolean = FALSE): string;
const
  DOT = '.';
type
  tint = packed record
    lo, hi: word;
  end;
var
  Version, Build: Cardinal;
  v1, v2, v3, B: string;
begin
  if GetVersionNumber(Filename, Version, Build) = TRUE then begin
    Str(tint(Version).hi, v1);
    Str(tint(Version).lo, v2);
    Str(tint(Build).hi, v3);
    Str(tint(Build).lo, B);
    Result := v1 + DOT + v2 + DOT + v3;
    if DigitOnly then
      Result := Result + DOT + B
    else
      Result := 'Version ' + Result + ' (build ' + B + ')'
  end
  else
    if DigitOnly then
      Result := '0.0.0.0'
    else
      Result := 'Unknown';
end;

function getGCD(const X, Y: Cardinal): Cardinal; assembler;
asm  jmp @@01
@@00:mov ecx,edx; xor edx,edx
     div ecx; mov eax,ecx
@@01:and edx,edx; jne @@00
end;

initialization
  BuildCRC32Table;
  CommonHandle := MainInstance;

finalization
  if lpCRC32Table <> nil then
    freemem(lpCRC32Table);
end.


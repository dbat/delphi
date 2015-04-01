unit fdFuncs;
{$I QUIET.INC}
{$WEAKPACKAGEUNIT ON}
{.$DEFINE FDF_DEBUG}
{$J-} //no-writeableconst
{$R-} //no-rangechecking
{$Q-} //no-overflowchecking
{.$D-}//no-debug
{.$DEFINE USING_MBCS}
//MBCS only affects these two functions here
//function LastDelimiter(const Delimiters, S: string): integer;
//function IsPathDelimiter(const S: string; Index: integer): Boolean;
{
  Copyright (c) 2004, aa, Inge DR. & Adrian Hafizh.
  Property of PT SOFTINDO Jakarta.
  All rights reserved.

  (this format should stop spammer-bot, to be stripped are:
   at@, brackets[], comma,, overdots., and dash-
   DO NOT strip underscore_)

  mail,to:@[zero_inge]AT@-y.a,h.o.o.@DOTcom,
  mail,to:@[aa]AT@-s.o.f.t,i.n.d.o.@DOTnet
  http://delphi.softindo.net

  Version: 1.0.1.0
  Dated: 2004.10.11
  LastUpdated: 2006.01.01

  bugfix: fixed CloseHandle when it used to be FindCloseFile
}

interface

//reinventing the wheel, no-need more explanations
//greedy means match the first dot in filename (not the last one) when the filename has more than 1 dot
function ExtractFileExt(const Filename: string; const greedy: boolean = FALSE): string;
function ChangeFileExt(const Filename, Extension: string; const greedy: boolean = FALSE): string;

function ExtractFileDir(const Filename: string): string; // WITHOUT trailing backslash
function ExtractFilePath(const Filename: string): string; // backslash appended
function ExtractFileName(const Filename: string): string;
function ExtractFileDrive(const Filename: string): string;
function ExtractBasename(const Filename: string; const greedy: boolean = FALSE): string;

function tempPath(const ShortPathName: boolean = FALSE; CreateIfNotExists: boolean = FALSE): string;
function tempFilename(const prefix: string = ''; counter: integer = 0; path: string = '';
  const ShortPathName: boolean = FALSE): string; overload;
function tempFilename(const ShortPathName: boolean; const prefix: string = '';
  counter: integer = 0; path: string = ''): string; overload;

//function IncludeTrailingBackslash(const S: string): string; forward;
//function ExcludeTrailingBackslash(const S: string): string; forward;
function Backslashed(const Pathname: string): string;
function Unbackslashed(const Pathname: string): string;
function isdblBackslashed(const Pathname: string): boolean;
// isdblBackslashed check whether Pathname is an UNC pathname
function getDriveChar(const Pathname: string; const AsDriveNum: boolean = FALSE): Char;
// getDriveChar result 'A'..'Z','\' or #0 for invalid/default drive
// UNC pathname will result '\' as drive letter or 28 as drive number

function FileExists(const Filename: string): Boolean;
function DirectoryExists(const Name: string): Boolean; // +
//function FilemaskExists(const Filemask: string; const asFile, asDir: boolean): Boolean;

function isAbsolutePath(const Pathname: string): boolean;

function CreateDir(const Dir: string): Boolean;
function CreateDirTree(DirTree: string): Boolean; // +

function DeleteFile(const Filename: string): boolean; overload;
function RenameFile(const SrcFilename, DestFilename: string): boolean; overload;
function CopyFile(const SrcFilename, DestFilename: string;
  const OverwriteExisting: boolean = TRUE): boolean; overload;

function DeleteFiles(const PathMask: string): integer; // +
function MoveFiles(const PathMask, DestDir: string): integer; overload;
function CopyFiles(const PathMask, DestDir: string): integer; overload;

function FileGetDate(const Filename: string): Integer; //eger; // +
function FileSetDate(const Filename: string; const FileDate: integer): Integer; overload; //eger; // +
function NTFileSetDate(const Filename: string; const FileDate: integer): Integer; overload; //eger; // +

function FileGetAttribute(const Filename: string): Integer; overload; //eger; // +
function FileSetAttribute(const Filename: string; const attribute: integer): boolean; overload; //eger; // +

function GetFileSize(const Filename: string): Int64; //eger; // +
function GetLongFileSize(const Filename: string): Int64; // +

//function FileDateToDateTime(const FileDate:integer): double;
//function DateTimeToFileDate(const DateTime:double): integer;
//function fhandleOpenReadGetSize(const Filename: string; var handle: integer): Int64; // +

function fhandleFileGetDate(Handle: Integer): Integer;
function fhandleFileSetDate(Handle: Integer; FileDate: Integer): Integer;
function fHandleRead(Handle: integer; var Buffer; Count: integer): integer;
function fHandleWrite(Handle: integer; var Buffer; Count: integer): integer;
function fHandleSetPos(Handle, Offset, Origin: Integer): Integer;
function fHandleSetLongPos(Handle, Offset: int64; Origin: Integer): Integer;
function fhandleGetLongSize(handle: integer): int64;

function fHandleOpenReadOnly(const Filename: string): integer;
function fHandleOpenReadWrite(const Filename: string): integer;

function ExpandFileName(const FileName: string): string;
function ExpandUNCFileName(const FileName: string): string;

function ReadStringFrom(const FileName: string; unixing: boolean = FALSE): string;
function WriteStringTo(const FileName: string; const S: string; const MakeBackupIfAlreadyExist: boolean): integer;

function ReadBufferFrom(const FileName: string; const Buffer: pointer; BufferSize: integer = 0): integer;
function WriteBufferTo(const FileName: string; const Buffer: pointer; BufferSize: integer;
  const MakeBackupIfAlreadyExist: boolean): integer;

//function StringReadFrorm(const FileName: string): string;
//function BufferSaveTo(const FileName: string; const Buffer; const MakeBackup: boolean): integer;

function fHandleOpen(const Filename: string; const OpenModes, CreationMode, Attributes: Longword): integer;
procedure fHandleClose(Handle: integer);

//make backup (copy) of specified file
function MakeBackupFilename(const Filename: string; const BackupExtension: string = '';
  const BackupSubDir: string = '' {'backup'}): string;

//get backup filename
function GetBakFilename(const Filename: string; const NewExtension: string = '.';
  const CounterDigits: integer = 3; const AutoPrependExtensionWithDot: Boolean = TRUE): string;

// procedure InitSysLocale; forward;
// you should call this first when Regional Language changed // not likely

function SimpleBrowseDirectory(const RootDir: string = ''; const Title: string = 'Browse Folder...'): string;
// deprecated, it's quite complex and consumes significant amount of resources.
// full-capability features separated to stand-alone unit (dbrowser)

function CatDir(const Root: string = ''; Dir: string = ''; Sub: string = ''): string;
function CatPath(const Root: string = ''; const Dir: string = ''; const Sub: string = ''): string;

function isRootPath(const Pathname: string; out DrvNum: integer): boolean; overload;
function isRootPath(const Pathname: string): boolean; overload;
function isRootChild(const Pathname: string; out DrvNum: integer): boolean; overload;
function isRootChild(const Pathname: string): boolean; overload;

procedure MakeManifestFile(const AppName: string);

const
  // Borrowed from SysUtils
    { Open Mode }
  fmOpenRead = $0000;
  fmOpenWrite = $0001;
  fmOpenReadWrite = $0002;
  fmOpenQuery = $0003;

  fmShareCompat = $0000;
  fmShareExclusive = $0010;
  fmShareDenyWrite = $0020;
  fmShareDenyRead = $0030;
  fmShareDenyNone = $0040;

  { Creation Mode }
  //CREATE_NONE = 0; {$EXTERNALSYM CREATE_NONE}
  //CREATE_NEW = 1; {$EXTERNALSYM CREATE_NEW}
  //CREATE_ALWAYS = 2; {$EXTERNALSYM CREATE_ALWAYS}
  //OPEN_EXISTING = 3; {$EXTERNALSYM OPEN_EXISTING}
  //OPEN_ALWAYS = 4; {$EXTERNALSYM OPEN_ALWAYS}
  //TRUNCATE_EXISTING = 5; {$EXTERNALSYM TRUNCATE_EXISTING}

  fcCreateNone = 0; //none specified //$000;//CREATE_NONE;
  fcCreateNew = 1; //fail if already existed //$0100;//CREATE_NEW;
  fcCreateAlways = 2; //create, overwrite if already existed //$0200;//CREATE_ALWAYS;
  fcOpenExisting = 3; //open-only, fail if not already existed //$0300;//OPEN_EXISTING;
  fcOpenAlways = 4; //open file, create if not exist //$0400;//OPEN_ALWAYS;
  fcTruncateExisting = 5; //truncate existing file 0-size, fail if not already existed //$0500;//TRUNCATE_EXISTING;

  { File attribute constants }
  faNone = $0;
  faReadOnly = $00000001;
  faHidden = $00000002;
  faSysFile = $00000004;
  faVolumeID = $00000008;
  faDirectory = $00000010;
  faArchive = $00000020;
  faAnyFile = $0000003F;
  faNormal = $00000080;

  fPosFromBeginning = 0;
  fPosFromCurrent = 1;
  fPosFromEnd = 2;

  INVALID_HANDLE_VALUE = LONGWORD(-1); {$EXTERNALSYM INVALID_Handle_VALUE}

implementation
uses
{$IFDEF USING_MBCS}MBCSdlm, {$ENDIF}
  ACConsts, Ordinals, Shower; //, SysUtils;

function LastDelimiter(const Delimiters, S: string): Integer; forward;
function IsPathDelimiter(const S: string; Index: Integer): Boolean; forward;

function isRootPath(const Pathname: string; out DrvNum: integer): boolean; overload;
var // Result: wether UNCFullPath is a root, return DrvNum > 0 if it is
  S, D: string;
begin
  Result := FALSE;
  DrvNum := ord(getDriveChar(Pathname, TRUE));
  if DrvNum > 0 then begin
    S := unbackSlashed(Pathname);
    D := extractFileDrive(Pathname);
    result := length(S) = length(D);
  end;
end;

function isRootChild(const Pathname: string; out DrvNum: integer): boolean; overload;
var // Result: wether UNCFullPath is a child of root, return DrvNum > 0 if it is
  S, D, E: string;
  L: integer;
begin
  Result := FALSE;
  DrvNum := ord(getDriveChar(Pathname, TRUE));
  if DrvNum > 0 then begin
    S := unbackSlashed(Pathname);
    D := ExtractFileDrive(S);
    L := length(D);
    // check whether S itself is a root
    if L <> length(S) then begin
      E := ExtractFileDir(S);
      E := unbackslashed(E);
      // extractfiledir must be root
      Result := (L = length(E));
    end;
  end;
end;

function isRootPath(const Pathname: string): boolean; overload;
asm push edx; mov edx, esp; call isRootPath; pop edx end;

function isRootChild(const Pathname: string): boolean; overload;
asm push edx; mov edx, esp; call isRootChild; pop edx end;

function dblBackslashed(const S: string): boolean;
asm // identical functionality with: copy(S, 1, 2) = '\\', but MUCH faster
  test eax, eax; jnz @1; ret
  @1: cmp dword[eax-4], 2; jl @3
  @2: cmp word[eax],'\\'
  @3: mov eax,0; sete al
end;

function getDriveChar(const Pathname: string; const AsDriveNum: boolean = FALSE): Char; asm
// result 'A'..'Z','\' or #0 for invalid/default drive
// UNC path will result '\' as drive letter or 28 as number
    test eax, eax; jnz @1; ret
    @1: cmp dword[eax-4],2; jl @000
    @2: movzx eax,word[eax]
        cmp ah,':'; je @val
        cmp ax,'\\'; je @drv
    @000: xor eax, eax; ret
    @val: cmp al,'z'; ja @000  // validation
          and al, not 20h      // make it uppercase
          cmp al,'A'; jb @000
    @drv: test AsDriveNum,TRUE; jz @done
          sub al, 'A'-1     // convert to numeric representation
    @done: xor ah,ah        // clear also flags
end;

function isdblBackslashed(const Pathname: string): boolean; asm
// identical functionality with: copy(S, 1, 2) = '\\', but MUCH faster
  test eax, eax; jnz @1; ret
  @1: cmp dword[eax-4], 2; jl @3
  @2: cmp word[eax],'\\'
  @3: mov eax,0; sete al
end;

function isAbsolutePath(const Pathname: string): boolean; asm
  test eax, eax; jnz @1; ret
  @1: cmp dword[eax-4],2; jl @end
  @2: movzx eax,word[eax]
      cmp ah,':'; je @end
      cmp ax,'\\'
  @end: mov eax,0; sete al
end;

function CatDir(const Root: string = ''; Dir: string = ''; Sub: string = ''): string;
begin
  if Sub <> '' then Sub := unbackSlashed(Sub);
  if Dir <> '' then Dir := unbackSlashed(Dir);

  Result := unbackSlashed(Root);

  if Result = '' then
    Result := Dir
  else
    if Dir <> '' then
      Result := backSlashed(Result) + Dir;

  if Result = '' then
    Result := Sub
  else
    if Sub <> '' then
      Result := backSlashed(Result) + Sub;
end;

function CatPath(const Root: string = ''; const Dir: string = ''; const Sub: string = ''): string;
begin
  Result := CatDir(Root, Dir, Sub);
  if Result <> '' then
    Result := backSlashed(Result)
end;

function isAbsolutePath_old(const fn: string): boolean;
var
  l: integer;
begin
  l := length(fn);
  Result := ((l > 0) and (fn[1] = '\')) or ((l > 1) and (fn[2] = ':'))
end;

function ExtractFileDrive(const Filename: string): string;
var
  i, j: integer;
begin
  if (Length(Filename) >= 2) and (Filename[2] = ':') then
    Result := Copy(Filename, 1, 2)
  else if (Length(Filename) >= 2) and (Filename[1] = '\') and
    (Filename[2] = '\') then begin
    j := 0;
    i := 3;
    while (i < Length(Filename)) and (j < 2) do begin
      if Filename[i] = '\' then
        inc(j);
      if j < 2 then
        inc(i);
    end;
    if Filename[i] = '\' then
      dec(i);
    Result := Copy(Filename, 1, i);
  end
  else
    Result := '';
end;

function ExtractFilename(const Filename: string): string;
var
  i: Integer;
begin
  i := LastDelimiter('\:', Filename);
  Result := Copy(Filename, i + 1, MaxInt);
end;

//function ExtractFilePath(const Filename: string): string;
//var
//  i: integer;
//begin
//  i := LastDelimiter('\:', Filename);
//  Result := Copy(Filename, 1, i);
//end;
//
//function ExtractFileDir(const Filename: string): string;
//var
//  i: Integer;
//begin
//  i := LastDelimiter('\:', Filename);
//  if (i > 1) and (Filename[i] = '\') and not (Filename[i - 1] in ['\', ':']) then
//    dec(i);
//  //(ByteType(Filename, i-1) = mbTrailByte)) then dec(i);
//  Result := Copy(Filename, 1, I);
//end;

function ExtractBasename(const Filename: string; const greedy: boolean = FALSE): string;
// extract filename ONLY without extension
// greedy: longest filename, shortest extension
// applicapble only if filename contains many dots (extension delimiters)
var
  i: integer;
begin
  Result := ExtractFileName(FileName);
  if greedy then
    i := pos('.', Result)
  else
    i := LastDelimiter('.', Result);
  if i <> 0 then
    Result := Copy(Result, 1, i - 1);
end;

function ExtractFileExt(const Filename: string; const greedy: boolean = FALSE): string;
var
  i, j, k: integer;
begin
  i := LastDelimiter('.\:', Filename);
  if (i > 0) and (Filename[i] = '.') then begin
    if greedy then begin
      j := LastDelimiter('\:', Filename);
      k := pos('.', copy(FileName, j + 1, MaxInt));
      if k > 0 then i := j + k
    end;
    Result := Copy(Filename, i, MaxInt);
  end
  else
    Result := '';
end;

function ChangeFileExt(const Filename, Extension: string; const greedy: boolean = FALSE): string;
var
  i, j, k: integer;
begin
  i := LastDelimiter('.\:', Filename);
  if (i = 0) or (Filename[i] <> '.') then i := MaxInt
  else if greedy then begin
    j := LastDelimiter('\:', Filename);
    k := pos('.', copy(FileName, j + 1, MaxInt));
    if k > 0 then i := j + k
  end;
  Result := Copy(Filename, 1, i - 1) + Extension;
end;

type
  THandle = Longword;
  DWORD = Longword; {$EXTERNALSYM DWORD}
  BOOL = longbool; {$EXTERNALSYM BOOL}

const
  FA_DIRECTORY = $10;
  MAX_PATH = 260; {$EXTERNALSYM MAX_PATH}
  _INVALID_ = INVALID_HANDLE_VALUE;

type
  PFileTime = ^TFileTime;
  TFileTime = record
    LowDateTime, HighDateTime: DWORD;
  end;

  //PWin32FindData = ^TWin32FindData;
  TWin32FindData = record
    FileAttributes: DWORD;
    CreationTime: TFileTime;
    LastAccessTime: TFileTime;
    LastWriteTime: TFileTime;
    FileSizeHigh: DWORD;
    FileSizeLow: DWORD;
    Reserved, Reserved1: DWORD;
    Filename: array[0..MAX_PATH - 1] of char;
    AlternateFilename: array[0..13] of char;
  end;

const
  kernel32 = 'kernel32.dll';

function FindFirstFile(lpFilename: PChar; var lpFindFileData: TWIN32FindData): THandle; stdcall; external kernel32 name 'FindFirstFileA'; {$EXTERNALSYM FindFirstFile}
function FindNextFile(hFindFile: THandle; var lpFindFileData: TWIN32FindData): BOOL; stdcall; external kernel32 name 'FindNextFileA'; {$EXTERNALSYM FindNextFile}
function FindCloseFile(hFindFile: THandle): BOOL; stdcall; external kernel32 name 'FindClose'; {$EXTERNALSYM FindCloseFile}
function FileTimeToLocalFileTime(const lpFileTime: TFileTime; var lpLocalFileTime: TFileTime): BOOL; stdcall; external kernel32 name 'FileTimeToLocalFileTime'; {$EXTERNALSYM FileTimeToLocalFileTime}
function FileTimeToDOSDateTime(const lpFileTime: TFileTime; var lpFatDate, lpFatTime: Word): BOOL; stdcall; external kernel32 name 'FileTimeToDosDateTime'; {$EXTERNALSYM FileTimeToDosDateTime}
function DOSDateTimeToFileTime(wFatDate, wFatTime: Word; var lpFileTime: TFileTime): BOOL; stdcall; external kernel32 name 'DosDateTimeToFileTime'; {$EXTERNALSYM DosDateTimeToFileTime}
function SetFileTime(hFile: THandle; lpCreationTime, lpLastAccessTime, lpLastWriteTime: PFileTime): BOOL; stdcall; external kernel32 name 'SetFileTime'; {$EXTERNALSYM SetFileTime}
function LocalFileTimeToFileTime(const lpLocalFileTime: TFileTime; var lpFileTime: TFileTime): BOOL; stdcall; external kernel32 name 'LocalFileTimeToFileTime'; {$EXTERNALSYM LocalFileTimeToFileTime}
function GetFullPathNameA(lpFileName: PAnsiChar; nBufferLength: DWORD; lpBuffer: PAnsiChar; var lpFilePart: PAnsiChar): DWORD; stdcall; external kernel32 name 'GetFullPathNameA'; {$EXTERNALSYM GetFullPathNameA}
function GetFileTime(hFile: THandle; lpCreationTime, lpLastAccessTime, lpLastWriteTime: PFileTime): BOOL; stdcall; external kernel32 name 'GetFileTime'; {$EXTERNALSYM GetFileTime}
function GetLastError: DWORD; stdcall; external kernel32 name 'GetLastError'; {$EXTERNALSYM GetLastError}

function ExpandFileName(const FileName: string): string;
const
  MAX_PATH = 260;
var
  FName: PChar;
  Buffer: array[0..MAX_PATH - 1] of Char;
begin
  SetString(Result, Buffer, GetFullPathNameA(PChar(FileName), SizeOf(Buffer), Buffer, FName));
end;

type
  LongRec = packed record
    Lo, Hi: word;
  end;

  Int64Rec = packed record
    Lo, Hi: DWORD;
  end;

type
  TFilename = string;
  TSearchRec = record
    Time: integer;
    Size: integer;
    Attr: integer;
    Name: TFilename;
    ExcludeAttr: integer;
    FindHandle: THandle;
    FindData: TWin32FindData;
  end;

  //procedure FindClose(var F: TSearchRec);
  //begin
  //  if F.FindHandle <> INVALID_Handle_VALUE then begin
  //    FindCloseFile(F.FindHandle);
  //    F.FindHandle := INVALID_Handle_VALUE;
  //  end;
  //end;

//function FileAge(const Filename: string): integer;
//const  FILE_ATTRIBUTE_DIRECTORY = $00000010; // {$EXTERNALSYM FILE_ATTRIBUTE_DIRECTORY}
//var
//  Handle: THandle;
//  FindData: TWin32FindData;
//  LocalFileTime: TFileTime;
//begin
//  Handle := FindFirstFile(PChar(Filename), FindData);
//  if Handle <> INVALID_Handle_VALUE then begin
//    FindCloseFile(Handle);
//    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then begin
//      FileTimeToLocalFileTime(FindData.ftLastWriteTime, LocalFileTime);
//      if FileTimeToDosDateTime(LocalFileTime, LongRec(Result).Hi,
//        LongRec(Result).Lo) then
//        Exit;
//    end;
//  end;
//  Result := -1;
//end;
//
//function FileExists(const Filename: string): Boolean;
//begin
//  Result := FileAge(Filename) <> -1;
//end;

// =====================================================================================
// DateTime functions
// =====================================================================================
//
//procedure ConvertError(ResString: PResStringRec); local;
//begin
//  //raise EConvertError.CreateRes(ResString);
//end;
//
//function IsLeapYear(Year: Word): Boolean;
//begin
//  Result := (Year mod 4 = 0) and ((Year mod 100 <> 0) or (Year mod 400 = 0));
//end;
//
//type
//  PDayTable = ^TDayTable;
//  TDayTable = array[1..12] of Word;
//
//  // The MonthDays array can be used to quickly find the number of days in a month:
//  // MonthDays[IsLeapYear(Y), M]
//
//const
//  DateDelta = 693594; // Days between 1/1/0001 and 12/31/1899
//  UnixDateDelta = 25569; //Days between TDateTime basis (12/31/1899) and Unix time_t basis (1/1/1970)
//
//  MonthDays: array[Boolean] of TDayTable =
//  ((31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31),
//    (31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31));
//
//function TryEncodeDate(Year, Month, Day: Word; out Date: TDateTime): Boolean;
//var
//  I: Integer;
//  DayTable: PDayTable;
//begin
//  Result := False;
//  DayTable := @MonthDays[IsLeapYear(Year)];
//  if (Year >= 1) and (Year <= 9999) and (Month >= 1) and (Month <= 12) and
//    (Day >= 1) and (Day <= DayTable^[Month]) then begin
//    for I := 1 to Month - 1 do Inc(Day, DayTable^[I]);
//    I := Year - 1;
//    Date := I * 365 + I div 4 - I div 100 + I div 400 + Day - DateDelta;
//    Result := True;
//  end;
//end;
//
//function EncodeDate(Year, Month, Day: Word): TDateTime;
//begin
//  if not TryEncodeDate(Year, Month, Day, Result) then
//    Result := -1;
//  //ConvertError(@SDateEncodeError);
//end;
//
//const
//  HoursPerDay = 24;
//  MinsPerHour = 60;
//  SecsPerMin = 60;
//  MSecsPerSec = 1000;
//  MinsPerDay = HoursPerDay * MinsPerHour;
//  SecsPerDay = MinsPerDay * SecsPerMin;
//  MSecsPerDay = SecsPerDay * MSecsPerSec;
//
//function TryEncodeTime(Hour, Min, Sec, MSec: Word; out Time: TDateTime): Boolean;
//begin
//  Result := False;
//  if (Hour < HoursPerDay) and (Min < MinsPerHour) and (Sec < SecsPerMin) and (MSec < MSecsPerSec) then begin
//    Time := (Hour * (MinsPerHour * SecsPerMin * MSecsPerSec) +
//      Min * (SecsPerMin * MSecsPerSec) +
//      Sec * MSecsPerSec +
//      MSec) / MSecsPerDay;
//    Result := True;
//  end;
//end;
//
//function EncodeTime(Hour, Min, Sec, MSec: Word): TDateTime;
//begin
//  if not TryEncodeTime(Hour, Min, Sec, MSec, Result) then
//    fillChar(Result, sizeof(Result), -1);
//  //ConvertError(@STimeEncodeError);
//end;
//
//function FileDateToDateTime(FileDate: Integer): Double;
//begin
//  Result :=
//    EncodeDate(
//    LongRec(FileDate).Hi shr 9 + 1980,
//    LongRec(FileDate).Hi shr 5 and 15,
//    LongRec(FileDate).Hi and 31) +
//    EncodeTime(
//    LongRec(FileDate).Lo shr 11,
//    LongRec(FileDate).Lo shr 5 and 63,
//    LongRec(FileDate).Lo and 31 shl 1, 0);
//end;
//
//const
//  FMSecsPerDay: Single = MSecsPerDay;
//  IMSecsPerDay: Integer = MSecsPerDay;
//
//function datetimetotimestamp(datetime: tdatetime): ttimestamp;
//asm
//  push ebx
//  {$ifdef pic}
//  push eax
//  call getgot
//  mov ebx,eax
//  pop eax
//  {$else}
//  xor ebx,ebx
//  {$endif}
//  mov ecx,eax
//  fld datetime
//  fmul [ebx].fmsecsperday
//  sub esp,8
//  fistp qword ptr [esp]
//  fwait
//  pop eax
//  pop edx
//  or edx,edx
//  jns @@1
//  neg edx
//  neg eax
//  sbb edx,0
//  div [ebx].imsecsperday
//  neg eax
//  jmp @@2
//  @@1: div [ebx].imsecsperday
//  @@2: add eax,datedelta
//  mov [ecx].ttimestamp.time,edx
//  mov [ecx].ttimestamp.date,eax
//  pop ebx
//end;
//
//procedure DivMod(Dividend: Integer; Divisor: Word; var Result, Remainder: Word);
//asm
//  push ebx; mov ebx,edx
//  mov edx,eax; shr edx,16
//  div bx
//  mov ebx,remainder
//  mov [ecx],ax; mov [ebx],dx
//  pop ebx
//end;
//
//procedure DecodeTime(const DateTime: TDateTime; var Hour, Min, Sec, MSec: Word);
//var
//  MinCount, MSecCount: Word;
//begin
//  DivMod(DateTimeToTimeStamp(DateTime).Time, SecsPerMin * MSecsPerSec, MinCount, MSecCount);
//  DivMod(MinCount, MinsPerHour, Hour, Min);
//  DivMod(MSecCount, MSecsPerSec, Sec, MSec);
//end;
//
//function DateTimeToFileDate(DateTime: TDateTime): Integer;
//var
//  Year, Month, Day, Hour, Min, Sec, MSec: Word;
//begin
//  DecodeDate(DateTime, Year, Month, Day);
//  if (Year < 1980) or (Year > 2107) then Result := 0 else begin
//    DecodeTime(DateTime, Hour, Min, Sec, MSec);
//    LongRec(Result).Lo := (Sec shr 1) or (Min shl 5) or (Hour shl 11);
//    LongRec(Result).Hi := Day or (Month shl 5) or ((Year - 1980) shl 9);
//  end;
//end;
// =====================================================================================
// =====================================================================================

function FileExists(const filename: string): boolean;
const
  FILE_ATTRIBUTE_DIRECTORY = $00000010; // {$EXTERNALSYM FILE_ATTRIBUTE_DIRECTORY}
var
  ff: THandle;
  FindData: TWin32FindData;
begin
  ff := FindFirstFile(PChar(Filename), FindData);
  Result := ff <> INVALID_Handle_VALUE;
  if Result then begin
    FindCloseFile(ff);
    Result := (FindData.FileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0
  end
end;

function fhandleFileGetDate(Handle: Integer): Integer;
var
  FileTime, LocalFileTime: TFileTime;
begin
  if GetFileTime(THandle(Handle), nil, nil, @FileTime) and
    FileTimeToLocalFileTime(FileTime, LocalFileTime) and
    FileTimeToDosDateTime(LocalFileTime, LongRec(Result).Hi,
    LongRec(Result).Lo) then Exit;
  Result := -1;
{$IFDEF FDF_DEBUG}Shower.ShowmsgError(LastErrStr); {$ENDIF FDF_DEBUG}
end;

function fhandleFileSetDate(Handle: Integer; FileDate: Integer): Integer;
//function fhandleFileSetDate(Handle: Integer; DOSDateTime: Integer): Integer;
var
  LocalFileTime, FileTime: TFileTime;
begin
  if DosDateTimeToFileTime(LongRec(FileDate).Hi, LongRec(FileDate).Lo, LocalFileTime) and
    LocalFileTimeToFileTime(LocalFileTime, FileTime) and SetFileTime(Handle, nil, nil, @FileTime) then
    Result := 0
  else begin
    Result := GetLastError;
{$IFDEF FDF_DEBUG}Shower.ShowmsgError(Result); {$ENDIF FDF_DEBUG}
  end;
end;

function FileGetDate(const FileName: string): Integer;
const
  FILE_ATTRIBUTE_DIRECTORY = $00000010; // {$EXTERNALSYM FILE_ATTRIBUTE_DIRECTORY}
var
  Handle: THandle;
  FindData: TWin32FindData;
  LocalFileTime: TFileTime;
begin
  Handle := FindFirstFile(PChar(FileName), FindData);
  if Handle <> INVALID_HANDLE_VALUE then begin
    FindCloseFile(Handle);
    //if (FindData.FileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then begin
    FileTimeToLocalFileTime(FindData.LastWriteTime, LocalFileTime);
    if FileTimeToDosDateTime(LocalFileTime, LongRec(Result).Hi,
      LongRec(Result).Lo) then Exit;
    //end;
  end;
  Result := -1;
{$IFDEF FDF_DEBUG}Shower.ShowmsgError(LastErrStr); {$ENDIF FDF_DEBUG}
end;

function FileSetDate(const Filename: string; const FileDate: integer): Integer; overload; //eger; // +
//function FileSetDate(const FileName: string; const DOSDateTime: Integer): Integer;
var
  f: THandle;
begin
  //f := fhandleOpenReadWrite(FileName);
  f := fHandleOpen(Filename, fmOpenReadWrite or fmShareDenyNone, fcOpenExisting, faNormal);
  if (f = THandle(-1)) then begin
    Result := GetLastError;
{$IFDEF FDF_DEBUG}Shower.ShowmsgError(Result); {$ENDIF FDF_DEBUG}
  end
  else begin
    Result := fhandleFileSetDate(f, FileDate);
    fHandleClose(f);
  end;
end;

function NTFileSetDate(const Filename: string; const FileDate: integer): Integer; overload; //eger; // +
//function FileSetDate(const FileName: string; const DOSDateTime: Integer): Integer;
const
  FILE_FLAG_BACKUP_SEMANTICS = $2000000; //{$EXTERNALSYM FILE_FLAG_BACKUP_SEMANTICS}
var
  f: THandle;
begin
  //f := fhandleOpenReadWrite(FileName);
  f := fHandleOpen(Filename, fmOpenReadWrite or fmShareDenyNone, fcOpenExisting, FILE_FLAG_BACKUP_SEMANTICS);
  if (f = THandle(-1)) then begin
    Result := GetLastError;
{$IFDEF FDF_DEBUG}Shower.ShowmsgError(Result); {$ENDIF FDF_DEBUG}
  end
  else begin
    Result := fhandleFileSetDate(f, FileDate);
    fHandleClose(f);
  end;
end;

//function ExtractFileDir(const Filename: string): string; forward;
//function Backslashed(const S: string): string; forward;
//function Unbackslashed(const S: string): string; forward;
//function CreateDir(const Dir: string): Boolean; forward;
//procedure DeleteFile(Filename: string); overload; forward;
//procedure RenameFile(SrcFilename, DestFilename: string); overload; forward;

function GetTempPathA(nBufferLength: DWORD; lpBuffer: PChar): DWORD; stdcall; external kernel32 name 'GetTempPathA';

function GetShortPathNameA(lpszLongPath: PAnsiChar; lpszShortPath: PAnsiChar; cchBuffer: DWORD): DWORD; stdcall;
  external kernel32 name 'GetShortPathNameA';

function GetTempFileNameA(lpPathName, lpPrefixString: PChar; uUnique: integer; lpTempFileName: PChar): integer; stdcall;
  external kernel32 name 'GetTempFileNameA';

function tempPath(const ShortPathName: boolean = FALSE; CreateIfNotExists: boolean = FALSE): string;
var
  temp: string;
begin
  setlength(temp, MAX_PATH);
  GetTempPathA(MAX_PATH, pChar(temp));
  if ShortPathName then
    GetShortPathNameA(pChar(temp), pChar(temp), MAX_PATH);
  Result := pChar(temp); //trim nul
  if not DirectoryExists(Result) then
    if CreateIfNotExists then
      CreateDirTree(Result)
    else Result := '';
end;

function tempFilename(const prefix: string = ''; counter: integer = 0; path: string = '';
  const ShortPathName: boolean = FALSE): string;
var
  temp: string;
begin
  temp := path;
  if temp = '' then temp := tempPath;
  if not DirectoryExists(temp) then temp := '.';
  temp := temp + #0;
  setlength(temp, MAX_PATH);
  GetTempFileNameA(pChar(temp), pchar(prefix), counter, pChar(temp));
  if ShortPathName then
    GetShortPathNameA(pChar(temp), pChar(temp), MAX_PATH);
  Result := pChar(temp); //trim nul
end;

function tempFilename(const ShortPathName: boolean; const prefix: string = '';
  counter: integer = 0; path: string = ''): string; overload;
begin
  Result := tempFilename(prefix, counter, path, ShortPathName);
end;

//see also function MakeBackupFilename

function GetBakFilename(const Filename: string; const NewExtension: string = '.';
  const CounterDigits: integer = 3; const AutoPrependExtensionWithDot: Boolean = YES): string;
const
  DOT = CHAR_DOT;
var
  i: Cardinal;
  Dir, fn, e, ext: string;
begin
  if (NewExtension = '') then
    ext := ExtractFileExt(Filename)
  else begin
    ext := NewExtension;
    if (ext[1] <> DOT) and AutoPrependExtensionWithDot then
      ext := DOT + ext;
  end;
  i := 0;
  if CounterDigits < 1 then
    e := ext
  else
    e := ext + intoStr(i, CounterDigits);
  Dir := ExtractFilePath(Filename);
  fn := ExtractFilename(Filename);
  if FileExists(Dir + fn) then
    fn := ChangeFileExt(fn, e);
  while FileExists(Dir + fn) do begin
    fn := ChangeFileExt(fn, ext + IntoStr(i, CounterDigits)); //format('%.1u', [i]));
    if i >= high(Cardinal) then
      ;
    //pending: raise exception.Create('too many tries');
    inc(i);
  end;
  Result := fn;
end;

//see also function GetBakFilename

function MakeBackupFilename(const Filename: string; const BackupExtension: string = '';
  const BackupSubDir: string = '' {'backup'}): string;
var
  Dir, DirSub, fname, bakname, _ext: string;
begin
  if not FileExists(Filename) then
    Result := Filename
  else begin
    fname := ExtractFilename(Filename);
    if BackupExtension <> '' then
      _ext := BackupExtension
    else
      _ext := ExtractFileExt(GetBakFilename(Filename));
    //ext := ExtractFileExt(Filename);
    Dir := ExtractFileDir(Filename);
    if (Dir <> '') and (BackupSubDir <> '') then
      DirSub := Backslashed(Dir) + BackupSubDir
    else
      DirSub := Dir + BackupSubDir;
    if (DirSub <> '') then
      DirSub := Backslashed(DirSub);
    bakname := DirSub + ChangeFileExt(fname, '') + _ext;
    if (DirSub <> '') and not DirectoryExists(DirSub) then
      CreateDirTree(DirSub);
    if FileExists(bakname) then
      DeleteFile(PChar(bakname));
    if not FileExists(bakname) then
      RenameFile(PChar(Filename), bakname);
    Result := bakname;
  end;
end;

function CreateFile(Filename: PChar; DesiredAccess, ShareMode: Longword;
  SecurityAttributes: pointer {PSecurityAttributes}; CreationDisposition,
  FlagsAndAttributes: Longword; hTemplateFile: integer): integer; stdcall;
  external kernel32 name 'CreateFileA'; {$EXTERNALSYM CreateFile}

function CloseHandle(Handle: THandle): Longbool; stdcall;
  external kernel32 name 'CloseHandle'; {$EXTERNALSYM CloseHandle}

procedure fHandleClose(Handle: integer);
begin
  CloseHandle(THandle(Handle));
end;

function ReadFile(hFile: THandle; var Buffer; nNumberOfBytesToRead: DWORD;
  var lpNumberOfBytesRead: DWORD; lpOverlapped: pointer {POverlapped}): BOOL; stdcall;
  external kernel32 name 'ReadFile'; {$EXTERNALSYM ReadFile}

function fHandleRead(Handle: integer; var Buffer; Count: integer): integer;
begin
  if not ReadFile(THandle(Handle), Buffer, Count, Longword(Result), nil) then begin
    Result := -1;
{$IFDEF FDF_DEBUG}Shower.ShowmsgError(LastErrStr); {$ENDIF FDF_DEBUG}
  end;
end;

function WriteFile(hFile: THandle; const Buffer; nNumberOfBytesToWrite: DWORD;
  var lpNumberOfBytesWritten: DWORD; lpOverlapped: pointer {POverlapped}): BOOL; stdcall;
  external kernel32 name 'WriteFile'; {$EXTERNALSYM WriteFile}

function fHandleWrite(Handle: integer; var Buffer; Count: integer): integer;
begin
  if not WriteFile(THandle(Handle), Buffer, Count, Longword(Result), nil) then begin
    Result := -1;
{$IFDEF FDF_DEBUG}Shower.ShowmsgError(LastErrStr); {$ENDIF FDF_DEBUG}
  end;
end;

function fHandleOpen(const Filename: string; const OpenModes, CreationMode, Attributes: Longword): integer;
const
  GENERIC_READ = DWORD($80000000);
  GENERIC_WRITE = $40000000;
  //GENERIC_EXECUTE = $20000000; // GENERIC_ALL = $10000000;
  FILE_SHARE_READ = $00000001;
  FILE_SHARE_WRITE = $00000002;
  AccessMode: array[0..3] of Longword = (GENERIC_READ, GENERIC_WRITE, GENERIC_READ or GENERIC_WRITE, 0);
  ShareMode: array[0..4] of Longword = (0, 0, FILE_SHARE_READ, FILE_SHARE_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE);
begin
  Result := integer(CreateFile(PChar(Filename), AccessMode[OpenModes and 3],
    ShareMode[(OpenModes and $F0) shr 4], nil, CreationMode, Attributes, 0));
end;

function fHandleOpenReadOnly(const Filename: string): integer;
begin
  Result := fHandleOpen(Filename, fmOpenRead or fmShareDenyNone, fcOpenExisting, faNormal);
end;

function fHandleOpenReadWrite(const Filename: string): integer;
begin
  Result := fHandleOpen(Filename, fmOpenReadWrite or fmShareDenyWrite, fcOpenExisting, faNormal);
end;

function SetFilePointer(hFile: THandle; lDistanceToMove: Longint;
  lpDistanceToMoveHigh: Pointer; dwMoveMethod: DWORD): DWORD; stdcall;
  external kernel32 name 'SetFilePointer'; {$EXTERNALSYM SetFilePointer}

function fHandleSetPos(Handle, Offset, Origin: Integer): Integer;
begin
  Result := SetFilePointer(THandle(Handle), Offset, nil, Origin);
end;

function fHandleSetLongPos(Handle, Offset: int64; Origin: Integer): Integer;
begin
  Result := SetFilePointer(THandle(Handle), Offset, @int64Rec(Offset).hi, Origin);
end;

function fHandleGetFileSize(hFile: Longword; lpFileSizeHigh: Pointer): Cardinal; stdcall;
  external kernel32 name 'GetFileSize'; {$EXTERNALSYM fHandleGetFileSize}

function fhandleGetLongSize(handle: integer): int64;
begin
  Int64Rec(Result).Lo := fhandleGetFileSize(handle, @Int64Rec(Result).Hi);
end;

function fhandleOpenReadGetSize(const Filename: string; var handle: integer): Int64;
begin
  handle := fHandleOpenReadOnly(Filename);
  if handle = integer(_INVALID_) then begin
    Result := -1;
{$IFDEF FDF_DEBUG}Shower.ShowmsgError(LastErrStr); {$ENDIF FDF_DEBUG}
  end
  else begin
    Int64Rec(Result).Lo := fhandleGetFileSize(handle, @Int64Rec(Result).Hi);
    // CloseHandle(h);
  end;
end;

function GetFileSize(const FileName: string): int64; //eger {Int64};
var
  Data: TWin32FindData;
begin
  Result := FindFirstFile(PChar(FileName), Data);
  if Result <> integer(INVALID_HANDLE_VALUE) then begin
    FindCloseFile(Result);
    if not ((Data.FileAttributes and FA_DIRECTORY) = 0) then begin
      Result := -1;
{$IFDEF FDF_DEBUG}Shower.ShowmsgError(LastErrStr); {$ENDIF FDF_DEBUG}
    end
    else begin
      int64Rec(Result).Hi := Data.FileSizeHigh;
      int64Rec(Result).Lo := Data.FileSizeLow;
    end;
  end;
end;

function GetLongFileSize(const FileName: string): Int64;
var
  Data: TWin32FindData;
begin
  Result := FindFirstFile(PChar(FileName), Data);
  if Result <> INVALID_HANDLE_VALUE then begin
    FindCloseFile(Result);
    if not ((Data.FileAttributes and FA_DIRECTORY) = 0) then begin
      Result := -1;
{$IFDEF FDF_DEBUG}Shower.ShowmsgError(LastErrStr); {$ENDIF FDF_DEBUG}
    end
    else begin
      int64Rec(Result).Hi := Data.FileSizeHigh;
      int64Rec(Result).Lo := Data.FileSizeLow;
      //Result := Data.FileSizeLow;
    end;
  end;
end;

function SetFileAttributes(lpFileName: PChar; dwFileAttributes: DWORD): BOOL; stdcall;
  external kernel32 name 'SetFileAttributesA'; {$EXTERNALSYM SetFileAttributes}

function GetFileAttributes(lpFilename: PChar): Cardinal; stdcall;
  external kernel32 name 'GetFileAttributesA'; {$EXTERNALSYM GetFileAttributes}

function FileGetAttribute(const Filename: string): Integer;
begin
  Result := GetFileAttributes(PChar(Filename));
end;

function FileSetAttribute(const Filename: string; const Attribute: integer): boolean;
begin
  Result := SetFileAttributes(PChar(Filename), Attribute);
end;

function DirectoryExists(const Name: string): Boolean; //const faDirectory = $00000010;
var
  AttributeFlags: integer;
begin
  AttributeFlags := GetFileAttributes(PChar(Name));
  Result := (AttributeFlags <> -1) and (faDirectory and AttributeFlags <> 0);
{$IFDEF FDF_DEBUG}if not Result then Shower.ShowmsgError(LastErrStr); {$ENDIF FDF_DEBUG}
end;

{$IFDEF USING_MBCS}

function Backslashed(const S: string): string;
begin
  Result := S;
  if not IsPathDelimiter(Result, Length(Result)) then
    Result := Result + '\';
end;

function Unbackslashed(const S: string): string;
begin
  Result := S;
  if IsPathDelimiter(Result, Length(Result)) then
    SetLength(Result, Length(Result) - 1);
end;

{$ELSE IF NOT USING_MBCS} //much faster
const
  BACKSLASH = '\';

function Backslashed(const Pathname: string): string;
// buggy-buggy-buggy...
//asm
//  //@cheap_xchg: push eax; mov eax,edx; pop edx
//  @cheap_xchg: push Result; mov edx,eax; mov eax,[esp]
//  test edx,edx; jz @push_1
//  @1: call System.@LStrAsG
//  mov eax, [esp]; mov ecx,[eax]; mov edx,[ecx-4]
//  cmp byte[ecx+edx-1],BACKSLASH; je @quit
//  @push_1:push edx
//  inc edx; call System.@LStrSetLength
//  @pop_1:pop edx
//  @done: mov eax,[eax]; mov byte[eax+edx],BACKSLASH
//  @quit: pop Result
begin
  Result := Pathname;
  if Result[length(Result)] <> BACKSLASH then
    Result := Result + BACKSLASH;
end;

function Unbackslashed(const Pathname: string): string; asm
  //@cheap_xchg: push eax; mov eax,edx; pop edx
  @cheap_xchg: push Result; mov edx,eax; mov eax,[esp]
  test edx,edx; jz @SetLen
  @1: call System.@LStrAsG
  mov eax, [esp]; mov ecx,[eax]; mov edx,[ecx-4]
  cmp byte[ecx+edx-1],BACKSLASH; jne @quit
  dec edx
  @SetLen: call System.@LStrSetLength
  mov eax,[eax]
  @quit: pop Result
end;

{$ENDIF USING_MBCS}

function ExtractFilePath(const Filename: string): string;
var
  i: integer;
begin
  i := LastDelimiter('\:', Filename);
  Result := Copy(Filename, 1, i);
end;

function ExtractFileDir(const Filename: string): string;
var
  i: Integer;
begin
  i := LastDelimiter('\:', Filename);
  if (i > 1) and (Filename[i] = '\') and not (Filename[i - 1] in ['\', ':']) then
    dec(i);
  //(ByteType(Filename, i-1) = mbTrailByte)) then dec(i);
  Result := Copy(Filename, 1, I);
end;

function CreateDirectory(lpPathName: PChar; lpSecurityAttributes: pointer): BOOL; stdcall;
  external kernel32 name 'CreateDirectoryA'; {$EXTERNALSYM CreateDirectory}

function CreateDir(const Dir: string): Boolean;
begin
  Result := CreateDirectory(PChar(Dir), nil);
end;

function CreateDirTree(DirTree: string): Boolean;
const
  MINLEN = 2;
  SPECIALCHARS = ['/', '\', ':', '*', '?', '<', '>'];
  CONTROLCHARS = [#0..pred(' ')];
begin
  Result := YES;
  //insanity checks
  if Length(DirTree) = 0 then exit;
  if (Length(DirTree) > 1) and (DirTree[1] in SPECIALCHARS + CONTROLCHARS) then exit;
  if DirTree = '\\' then exit;
  if (length(DirTree) = 2) and (DirTree[2] = ':') then exit;
  //raise Exception.CreateRes(@SCannotCreateDir);
  //raise Exception.Create(Err_fCreate);
  DirTree := Unbackslashed(DirTree);
  //if (Length(DirTree) > MINLEN) and not
  if not DirectoryExists(DirTree) and (ExtractFilePath(DirTree) <> DirTree) then
    // avoid 'xyz:\' problem.
    Result := CreateDirTree(ExtractFilePath(DirTree)) and CreateDir(DirTree);
end;

function FindMatchingFile(var F: TSearchRec): integer;
var
  LocalFileTime: TFileTime;
begin
  with F do begin
    while FindData.FileAttributes and ExcludeAttr <> 0 do
      if not FindNextFile(FindHandle, FindData) then begin
        Result := GetLastError;
        Exit;
      end;
    FileTimeToLocalFileTime(FindData.LastWriteTime, LocalFileTime);
    FileTimeToDosDateTime(LocalFileTime, LongRec(Time).Hi, LongRec(Time).Lo);
    Size := FindData.FileSizeLow;
    Attr := FindData.FileAttributes;
    Name := FindData.Filename;
  end;
  Result := 0;
end;

function findFirst(const Path: string; Attr: integer; var F: TSearchRec): integer;
const
  faSpecial = faHidden or faSysFile or faVolumeID or faDirectory;
begin
  F.ExcludeAttr := not Attr and faSpecial;
  F.FindHandle := FindFirstFile(PChar(Path), F.FindData);
  if F.FindHandle <> INVALID_Handle_VALUE then begin
    Result := FindMatchingFile(F);
    if Result <> 0 then
      FindCloseFile(cardinal(@F));
  end
  else
    Result := GetLastError;
end;

function DeleteFile(Filename: PChar): BOOL; stdcall; overload;
  external kernel32 name 'DeleteFileA'; {$EXTERNALSYM DeleteFile}

function CopyFile(SrcFilename, DestFilename: PChar; FailIfExist: BOOL): BOOL; stdcall; overload;
  external kernel32 name 'CopyFileA'; {$EXTERNALSYM CopyFile}

function RenameFile(SrcFilename, DestFilename: PChar): BOOL; stdcall; overload;
  external kernel32 name 'MoveFileA'; {$EXTERNALSYM RenameFile}

function DeleteFile(const Filename: string): boolean; overload;
begin
  Result := DeleteFile(PChar(Filename));
end;

function CopyFile(const SrcFilename, DestFilename: string;
  const OverwriteExisting: boolean = TRUE): boolean; overload;
begin
  Result := CopyFile(PChar(SrcFilename), PChar(DestFileName), not OverwriteExisting);
end;

function RenameFile(const SrcFilename, DestFilename: string): boolean; overload;
begin
  Result := RenameFile(PChar(SrcFilename), PChar(DestFilename));
end;

function FindNext(var F: TSearchRec): integer;
begin
  if FindNextFile(F.FindHandle, F.FindData) then
    Result := FindMatchingFile(F)
  else
    Result := GetLastError;
end;

{
procedure Deletefiles(const PathMask: string);
var
  SDir: string;
  SFile: string;
  sRec: TSearchRec;
  found: word;
begin
  SDir := ExtractFileDir(PathMask);
  SFile := ExtractFileName(PathMask);
  found := findfirst(PathMask, 0, SRec);
  while found = 0 do begin
    DeleteFile(SDir + '\' + SRec.Name);
    found := FindNext(SRec);
  end;
  FindClose(srec);
end;                                                  windows
}

function DeleteFiles(const PathMask: string): integer;
var
  SPath: string;
  shrek: TSearchRec;
  found: integer;
begin
  Result := 0;
  SPath := ExtractFilePath(PathMask);
  found := findfirst(PathMask, 0, shrek);
  if found = 0 then begin
    while found = 0 do begin
      inc(Result);
      DeleteFile(pChar(SPath + shrek.Name));
      found := findnext(shrek);
    end;
    findCloseFile(cardinal(@shrek));
  end;
end;

function CopyFiles(const PathMask, DestDir: string): integer; overload;
var
  SourcePath, DestPath: string;
  shrek: TSearchRec;
  found: integer;
begin
  Result := 0;
  SourcePath := ExtractFilePath(PathMask); //Backslashed(SourceDir);
  DestPath := Backslashed(DestDir);
  found := findfirst(PathMask, 0, shrek);
  if found = 0 then begin
    while found = 0 do begin
      inc(Result);
      CopyFile(pChar(SourcePath + Shrek.name), pChar(DestPath + Shrek.Name), FALSE);
      found := findnext(shrek);
    end;
    findCloseFile(cardinal(@shrek));
  end;
end;

function MoveFiles(const PathMask, DestDir: string): integer; overload;
var
  SourcePath, DestPath: string;
  shrek: TSearchRec;
  found: integer;
begin
  Result := 0;
  SourcePath := ExtractFilePath(PathMask);
  DestPath := Backslashed(DestDir);
  found := findfirst(PathMask, 0, shrek);
  if found = 0 then begin
    while found = 0 do begin
      inc(Result);
      RenameFile(pChar(SourcePath + Shrek.name), pChar(DestPath + Shrek.Name));
      found := findnext(shrek);
    end;
    findCloseFile(cardinal(@shrek));
  end;
end;

{$IFDEF USING_MBCS}

function LastDelimiter(const Delimiters, S: string): integer;
begin
  Result := MBCSdlm.LastDelimiter(Delimiters, S);
end;

function IsPathDelimiter(const S: string; Index: integer): Boolean;
begin
  Result := MBCSdlm.IsPathDelimiter(S, Index);
end;

{$ELSE IFNDEF USING_MBCS}

function LastDelimiter(const Delimiters, S: string): integer;
var
  i, j: integer;
begin
  Result := 0;
  for i := length(S) downto 1 do
    for j := 1 to length(Delimiters) do
      if S[i] = Delimiters[j] then begin
        Result := i;
        exit; //break; // do not use break (under inner loop)
      end;
end;

function IsPathDelimiter(const S: string; Index: integer): Boolean;
begin
  Result := (Index > 0) and (Index <= Length(S)) and (S[Index] = '\')
    //and (ByteType(S, Index) = mbSingleByte);
end;
{$ENDIF}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~  MOVED TO unit MBCSdlm
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ type
//~   UINT = Longword; {$EXTERNALSYM UINT}
//~   LCID = DWORD; {$EXTERNALSYM LCID}
//~   LANGID = Word; {$EXTERNALSYM LANGID}
//~
//~   TSysLocale = packed record
//~     DefaultLCID: LCID;
//~     PriLangID: LANGID;
//~     SubLangID: LANGID;
//~     FarEast: Boolean;
//~     MiddleEast: Boolean;
//~   end;
//~
//~ var
//~   SysLocale: TSysLocale = (DefaultLCID: 0);
//~   LeadBytes: set of char = [];
//~
//~ type
//~   TMBCSByteType = (mbSingleByte, mbLeadByte, mbTrailByte);
//~
//~ function ByteTypeTest(P: PChar; Index: Integer): TMbcsByteType;
//~ var
//~   I: Integer;
//~   //LeadBytes: set of char;
//~ begin
//~   Result := mbSingleByte;
//~   //LeadBytes := WinGlobal.LeadBytes;
//~   if (P = nil) or (P[Index] = #$0) then Exit;
//~   if (Index = 0) then begin
//~     if P[0] in LeadBytes then Result := mbLeadByte;
//~   end
//~   else begin
//~     I := Index - 1;
//~     while (I >= 0) and (P[I] in LeadBytes) do dec(I);
//~     if ((Index - I) mod 2) = 0 then Result := mbTrailByte
//~     else if P[Index] in LeadBytes then Result := mbLeadByte;
//~   end;
//~ end;
//~
//~ function ByteType(const S: string; Index: Integer): TMbcsByteType;
//~ begin
//~   Result := mbSingleByte;
//~   if {WinGlobal.} SysLocale.FarEast then
//~     Result := ByteTypeTest(PChar(S), Index - 1);
//~ end;
//~
//~ // from SysUtils
//~ { StrScan returns a pointer to the first occurrence of Chr in Str. If Chr
//~   does not occur in Str, StrScan returns NIL. The null terminator is
//~   considered to be part of the string. }
//~
//~ function StrScan(const Str: PChar; Chr: Char): PChar; assembler;
//~ // due to low performance do not use for long-string (string with great length)
//~ // use only for small string such as Filename / path name
//~ asm
//~     push edi
//~     push eax
//~     mov edi, str
//~     mov ecx, 0ffffffffh
//~     xor al, al
//~     repne scasb
//~     not ecx
//~     pop edi
//~     mov al, chr
//~     repne scasb
//~     mov eax, 0
//~     jne @@1
//~     mov eax, edi
//~     dec eax
//~   @@1: pop edi
//~ end;
//~
//~ //procedure InitSysLocale; forward;
//~
//~ function LastDelimiter(const Delimiters, S: string): Integer;
//~ var
//~   P: PChar;
//~ begin
//~   if SysLocale.DefaultLCID = 0 then InitSysLocale;
//~   Result := Length(S);
//~   P := PChar(Delimiters);
//~   while Result > 0 do begin
//~     if (S[Result] <> #0) and (StrScan(P, S[Result]) <> nil) then
//~       if (ByteType(S, Result) = mbTrailByte) then
//~         dec(Result)
//~       else Exit;
//~     dec(Result);
//~   end;
//~ end;
//~
//~ function IsPathDelimiter(const S: string; Index: Integer): Boolean;
//~ begin
//~   if SysLocale.DefaultLCID = 0 then InitSysLocale;
//~   Result := (Index > 0) and (Index <= Length(S)) and (S[Index] = '\')
//~     and (ByteType(S, Index) = mbSingleByte);
//~ end;
//~
//~ const
//~   MAX_LEADBYTES = 12; {$EXTERNALSYM MAX_LEADBYTES} // 5 ranges, 2 bytes ea., 0 term.
//~   MAX_DEFAULTCHAR = 2; {$EXTERNALSYM MAX_DEFAULTCHAR} // whether single or double byte
//~
//~ type
//~   TCPInfo = record
//~     MaxCharSize: UINT; { max length (bytes) of a char }
//~     DefaultChar: array[0..MAX_DEFAULTCHAR - 1] of Byte; { default character }
//~     LeadByte: array[0..MAX_LEADBYTES - 1] of Byte; { lead byte ranges }
//~   end;
//~
//~ const
//~   user32 = 'user32.dll';
//~
//~ function GetSystemMetrics(nIndex: Integer): Integer; stdcall; external user32 name 'GetSystemMetrics'; {$EXTERNALSYM GetSystemMetrics}
//~ function GetThreadLocale: LCID; stdcall; external kernel32 name 'GetThreadLocale'; {$EXTERNALSYM GetThreadLocale}
//~ function GetCPInfo(CodePage: UINT; var lpCPInfo: TCPInfo): BOOL; stdcall; external kernel32 name 'GetCPInfo'; {$EXTERNALSYM GetCPInfo}
//~
//~ procedure InitSysLocale;
//~ const
//~   LANG_ENGLISH = $09;
//~   SUBLANG_ENGLISH_US = $01;
//~
//~   SM_DBCSENABLED = 42; //{$EXTERNALSYM SM_DBCSENABLED}
//~   SM_MIDEASTENABLED = 74; //{$EXTERNALSYM SM_MIDEASTENABLED}
//~
//~   CP_ACP = 0; //{$EXTERNALSYM CP_ACP} // ANSI code page
//~   //CP_OEMCP = 1; {$EXTERNALSYM CP_OEMCP} // OEM  code page
//~   //CP_MACCP = 2; {$EXTERNALSYM CP_MACCP} // MAC  code page
//~
//~ var
//~   DefaultLCID: LCID;
//~   DefaultLangID: LANGID;
//~   AnsiCPInfo: TCPInfo;
//~   i: Integer;
//~   b: Byte;
//~ begin
//~   { Set default to English (US). }
//~   SysLocale.DefaultLCID := $0409;
//~   SysLocale.PriLangID := LANG_ENGLISH;
//~   SysLocale.SubLangID := SUBLANG_ENGLISH_US;
//~
//~   DefaultLCID := GetThreadLocale;
//~   if DefaultLCID <> 0 then SysLocale.DefaultLCID := DefaultLCID;
//~
//~   DefaultLangID := Word(DefaultLCID);
//~   if DefaultLangID <> 0 then begin
//~     SysLocale.PriLangID := DefaultLangID and $3FF;
//~     SysLocale.SubLangID := DefaultLangID shr 10;
//~   end;
//~
//~   SysLocale.MiddleEast := GetSystemMetrics(SM_MIDEASTENABLED) <> 0;
//~   SysLocale.FarEast := GetSystemMetrics(SM_DBCSENABLED) <> 0;
//~   if not SysLocale.FarEast then Exit;
//~
//~   GetCPInfo(CP_ACP, AnsiCPInfo);
//~   with AnsiCPInfo do begin
//~     i := 0;
//~     while (i < MAX_LEADBYTES) and ((LeadByte[i] or LeadByte[i + 1]) <> 0) do begin
//~       for b := LeadByte[i] to LeadByte[i + 1] do
//~         Include(LeadBytes, Char(b));
//~       inc(i, 2);
//~     end;
//~   end;
//~ end;
//~

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`
// Read/Write String from/to File
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`

function ReadStringFrom(const FileName: string; unixing: boolean = FALSE): string;
var
  h: THandle;
  sz: integer;
begin
  Result := '';
  if FileExists(filename) then begin
    h := fHandleOpenReadOnly(filename);
    if h <> _INVALID_ then begin
      try
        sz := fHandleGetFileSize(h, nil);
        if sz > 0 then begin
          SetLength(Result, sz);
          fHandleSetPos(h, 0, fPosFromBeginning);
          if fHandleRead(h, Result[1], sz) < 0 then
            Result := '';
        end;
      finally
        fHandleClose(h);
      end;
    end;
  end;
end;

function WriteStringTo(const FileName: string; const S: string; const MakeBackupIfAlreadyExist: boolean): integer;
var
  h: THandle;
  Buffer: string;
begin
  Result := -1;
  if S <> '' then begin
    if FileExists(filename) then
      if MakeBackupIfAlreadyExist then
        MakeBackupFilename(filename);
    h := fHandleOpen(FileName, fmOpenReadWrite, fcCreateAlways, faNormal);
    if h <> _INVALID_ then begin
      try
        Buffer := S;
        Result := fHandleWrite(h, Buffer[1], length(S));
      finally
        fHandleClose(h);
      end;
    end
    else
{$IFDEF FDF_DEBUG}Shower.ShowmsgError(LastErrStr); {$ENDIF FDF_DEBUG}
  end;
end;

{$Q-}
{$R-}

function ReadBufferFrom(const FileName: string; const Buffer: pointer; BufferSize: integer = 0): integer;
type
  pBuffer = ^TBuffer;
  tBuffer = array[0..0] of byte;
var
  h: THandle;
begin
  Result := -1;
  if FileExists(filename) then begin
    h := fHandleOpenReadOnly(filename);
    if h <> _INVALID_ then begin
      try
        fHandleSetPos(h, 0, fPosFromBeginning);
        Result := fHandleRead(h, pBuffer(Buffer)^, BufferSize)
      finally
        fHandleClose(h);
      end;
    end
    else
{$IFDEF FDF_DEBUG}Shower.ShowmsgError(LastErrStr); {$ENDIF FDF_DEBUG}
  end;
end;

function WriteBufferTo(const FileName: string; const Buffer: pointer; BufferSize: integer;
  const MakeBackupIfAlreadyExist: boolean): integer;
type
  pBuffer = ^TBuffer;
  tBuffer = array[0..0] of byte;
var
  h: THandle;
  //Buffer: string;
begin
  Result := -1;
  if BufferSize > 0 then begin
    if FileExists(filename) then
      if MakeBackupIfAlreadyExist then
        MakeBackupFilename(filename);
    h := fHandleOpen(FileName, fmOpenReadWrite, fcCreateAlways, faNormal);
    if h <> _INVALID_ then begin
      try
        //Buffer := S;
        Result := fHandleWrite(h, pBuffer(Buffer)^, BufferSize);
      finally
        fHandleClose(h);
      end;
    end
    else
{$IFDEF FDF_DEBUG}Shower.ShowmsgError(LastErrStr); {$ENDIF FDF_DEBUG}
  end;
end;

procedure MakeManifestFile(const AppName: string);
const
  _Manifest = '.Manifest';
  ApplicationManifest =
    ''^j +
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'^j +
    '<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">'^j +
    ^i'<assemblyIdentity'^j +
    ^i^i'processorArchitecture="*"'^j +
    ^i^i'version="5.1.0.0"'^j +
    ^i^i'type="win32"'^j +
    ^i^i'name="Microsoft.Windows.Shell.shell32"'^j +
    ^i^i'/>'^j +
    ^i'<description>Windows Shell</description>'^j +
    ^i'<dependency>'^j +
    ^i^i'<dependentAssembly>'^j +
    ^i^i^i'<assemblyIdentity'^j +
    ^i^i^i^i'type="win32"'^j +
    ^i^i^i^i'name="Microsoft.Windows.Common-Controls"'^j +
    ^i^i^i^i'version="6.0.0.0"'^j +
    ^i^i^i^i'publicKeyToken="6595b64144ccf1df"'^j +
    ^i^i^i^i'language="*"'^j +
    ^i^i^i^i'processorArchitecture="*"'^j +
    ^i^i^i^i'/>'^j +
    ^i^i'</dependentAssembly>'^j +
    ^i'</dependency>'^j +
    '</assembly>'^j +
    '';

var
  fx: string;
begin
  fx := AppName + _Manifest;
  if not FileExists(fx) then WriteStringTo(fx, ApplicationManifest, FALSE);
end;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`
// FILE / DIR BROWSER
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`
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
  HWND = type LongWord;
  WPARAM = longint; {$EXTERNALSYM WPARAM}
  UINT = Longword; {$EXTERNALSYM UINT}
  LPARAM = longint; {$EXTERNALSYM LPARAM}
  //LRESULT = Longint;

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

const
  shell32 = 'shell32.dll';

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
  pb.hwndOwner := 0; //CommonHandle;
  pb.pszDisplayName := DirName;
  pb.lpszTitle := pChar(Title);
  pb.ulFlags := BIF_RETURNONLYFSDIRS or BIF_DONTGOBELOWDOMAIN or
    BIF_RETURNFSANCESTORS or BIF_STATUSTEXT;
  pb.lpfn := @BrowseCallBack;
  ShBrowseForFolder(pb);
  Result := string(DirName);
end;

type
  TOSVersionInfo = record
    dwOSVersionInfoSize: DWORD;
    dwMajorVersion: DWORD;
    dwMinorVersion: DWORD;
    dwBuildNumber: DWORD;
    dwPlatformId: DWORD;
    szCSDVersion: array[0..127] of AnsiChar; { Maintenance string for PSS usage }
  end;

function GetVersionEx(var lpVersionInformation: TOSVersionInfo): BOOL; stdcall; external kernel32 name 'GetVersionExA';

function Win98SE_Up: boolean;
const
  VER_PLATFORM_WIN32_WINDOWS = 1;
var
  Win32Platform: integer;
  Win32MajorVersion: integer;
  Win32MinorVersion: integer;
  Win32BuildNumber: integer;
  Win32CSDVersion: string;

  procedure InitPlatformId;
  var
    OSVersionInfo: TOSVersionInfo;
  begin
    OSVersionInfo.dwOSVersionInfoSize := SizeOf(OSVersionInfo);
    if GetVersionEx(OSVersionInfo) then
      with OSVersionInfo do begin
        Win32Platform := dwPlatformId;
        Win32MajorVersion := dwMajorVersion;
        Win32MinorVersion := dwMinorVersion;
        if Win32Platform = VER_PLATFORM_WIN32_WINDOWS then
          Win32BuildNumber := dwBuildNumber and $FFFF
        else
          Win32BuildNumber := dwBuildNumber;
        Win32CSDVersion := szCSDVersion;
      end;
  end;
begin
  InitPlatformId;
  Result := (Win32Platform <> VER_PLATFORM_WIN32_WINDOWS) or (Win32MajorVersion > 4)
end;

type
  TNetResource = packed record
    dwScope: DWORD;
    dwType: DWORD;
    dwDisplayType: DWORD;
    dwUsage: DWORD;
    lpLocalName: PAnsiChar;
    lpRemoteName: PAnsiChar;
    lpComment: PAnsiChar;
    lpProvider: PAnsiChar;
  end;
  PNetResource = ^TNetResource;

  TRemoteNameInfo = packed record
    lpUniversalName: PAnsiChar;
    lpConnectionName: PAnsiChar;
    lpRemainingPath: PAnsiChar;
  end;
  PRemoteNameInfo = ^TRemoteNameInfo;

const
  mpr = 'mpr.dll';

function WNetGetUniversalName(lpLocalPath: PChar; dwInfoLevel: DWORD; lpBuffer: Pointer; var lpBufferSize: DWORD): DWORD; stdcall;
  external mpr name 'WNetGetUniversalNameA';

function WNetOpenEnum(dwScope, dwType, dwUsage: DWORD; lpNetResource: PNetResource; var lphEnum: THandle): DWORD; stdcall;
  external mpr name 'WNetOpenEnumA';

function WNetEnumResource(hEnum: THandle; var lpcCount: DWORD; lpBuffer: Pointer; var lpBufferSize: DWORD): DWORD; stdcall;
  external mpr name 'WNetEnumResourceA';

function WNetCloseEnum(hEnum: THandle): DWORD; stdcall; external mpr name 'WNetCloseEnum';

function GetUniversalName(const FileName: string): string;

const
  UNIVERSAL_NAME_INFO_LEVEL = 1; NO_ERROR = 0;
  RESOURCE_CONNECTED = 1; RESOURCETYPE_DISK = 1;
  ERROR_MORE_DATA = 234; { dderror }
type
  PNetResourceArray = ^TNetResourceArray;
  TNetResourceArray = array[0..MaxInt div SizeOf(TNetResource) - 1] of TNetResource;
var
  I, BufSize, NetResult: Integer;
  Count, Size: LongWord;
  Drive: Char;
  NetHandle: THandle;
  NetResources: PNetResourceArray;
  RemoteNameInfo: array[0..1023] of Byte;

begin
  Result := FileName;
  //if (Win32Platform <> VER_PLATFORM_WIN32_WINDOWS) or (Win32MajorVersion > 4) then begin
  if Win98SE_up then begin
    Size := SizeOf(RemoteNameInfo);
    if WNetGetUniversalName(PChar(FileName), UNIVERSAL_NAME_INFO_LEVEL,
      @RemoteNameInfo, Size) <> NO_ERROR then Exit;
    Result := PRemoteNameInfo(@RemoteNameInfo).lpUniversalName;
  end else begin
    { The following works around a bug in WNetGetUniversalName under Windows 95 }
    Drive := UpCase(FileName[1]);
    if (Drive < 'A') or (Drive > 'Z') or (Length(FileName) < 3) or
      (FileName[2] <> ':') or (FileName[3] <> '\') then
      Exit;
    if WNetOpenEnum(RESOURCE_CONNECTED, RESOURCETYPE_DISK, 0, nil, NetHandle) <> NO_ERROR then Exit;
    try
      BufSize := 50 * SizeOf(TNetResource);
      GetMem(NetResources, BufSize);
      try
        while True do begin
          Count := $FFFFFFFF;
          Size := BufSize;
          NetResult := WNetEnumResource(NetHandle, Count, NetResources, Size);
          if NetResult = ERROR_MORE_DATA then begin
            BufSize := Size;
            ReallocMem(NetResources, BufSize);
            Continue;
          end;
          if NetResult <> NO_ERROR then Exit;
          for I := 0 to Count - 1 do
            with NetResources^[I] do
              if (lpLocalName <> nil) and (Drive = UpCase(lpLocalName[0])) then begin
                Result := lpRemoteName + Copy(FileName, 3, Length(FileName) - 2);
                Exit;
              end;
        end;
      finally
        FreeMem(NetResources, BufSize);
      end;
    finally
      WNetCloseEnum(NetHandle);
    end;
  end;
end;

{ ExpandUNCFileName expands the given filename to a fully qualified filename.
  This function is the same as ExpandFileName except that it will return the
  drive portion of the filename in the format '\\<servername>\<sharename> if
  that drive is actually a network resource instead of a local resource.
  Like ExpandFileName, embedded '.' and '..' directory references are removed.
}

function ExpandUNCFileName(const FileName: string): string;
begin
  { First get the local resource version of the file name }
  Result := ExpandFileName(FileName);
  if (Length(Result) >= 3) and (Result[2] = ':') and (Upcase(Result[1]) >= 'A') and (Upcase(Result[1]) <= 'Z') then
    Result := GetUniversalName(Result);
end;

procedure extractpath(const Fullname: string; var Drivename, Pathname, Filename: string);
var
  S: string;
begin
  S := ExpandUNCFileName(S);
  if S = '' then getDir(0, S);
  Drivename := S[1];

end;

end.


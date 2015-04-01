unit miscwin;
interface
type
  thandle = integer;
  dword = cardinal;
  bool = longbool;

const
  GENERIC_READ = dword($80000000); {$EXTERNALSYM GENERIC_READ}
  GENERIC_WRITE = $40000000; {$EXTERNALSYM GENERIC_WRITE}
  FILE_SHARE_READ = $00000001; {$EXTERNALSYM FILE_SHARE_READ}
  FILE_SHARE_WRITE = $00000002; {$EXTERNALSYM FILE_SHARE_WRITE}
  FILE_ATTRIBUTE_NORMAL = $00000080; {$EXTERNALSYM FILE_ATTRIBUTE_NORMAL}
  CREATE_NEW = 1; {$EXTERNALSYM CREATE_NEW}
  CREATE_ALWAYS = 2; {$EXTERNALSYM CREATE_ALWAYS}
  OPEN_EXISTING = 3; {$EXTERNALSYM OPEN_EXISTING}
  OPEN_ALWAYS = 4; {$EXTERNALSYM OPEN_ALWAYS}
  TRUNCATE_EXISTING = 5; {$EXTERNALSYM TRUNCATE_EXISTING}
  PAGE_NOACCESS = 1; {$EXTERNALSYM PAGE_NOACCESS}
  PAGE_READONLY = 2; {$EXTERNALSYM PAGE_READONLY}
  PAGE_READWRITE = 4; {$EXTERNALSYM PAGE_READWRITE}
  PAGE_WRITECOPY = 8; {$EXTERNALSYM PAGE_WRITECOPY}
  SECTION_QUERY = 1; {$EXTERNALSYM SECTION_QUERY}
  SECTION_MAP_WRITE = 2; {$EXTERNALSYM SECTION_MAP_WRITE}
  SECTION_MAP_READ = 4; {$EXTERNALSYM SECTION_MAP_READ}
  SECTION_MAP_EXECUTE = 8; {$EXTERNALSYM SECTION_MAP_EXECUTE}

  OF_READ = 0; {$EXTERNALSYM OF_READ}
  OF_WRITE = 1; {$EXTERNALSYM OF_WRITE}
  OF_READWRITE = 2; {$EXTERNALSYM OF_READWRITE}
  OF_SHARE_COMPAT = 0; {$EXTERNALSYM OF_SHARE_COMPAT}
  OF_SHARE_EXCLUSIVE = $10; {$EXTERNALSYM OF_SHARE_EXCLUSIVE}
  OF_SHARE_DENY_WRITE = $20; {$EXTERNALSYM OF_SHARE_DENY_WRITE}
  OF_SHARE_DENY_READ = 48; {$EXTERNALSYM OF_SHARE_DENY_READ}
  OF_SHARE_DENY_NONE = $40; {$EXTERNALSYM OF_SHARE_DENY_NONE}

const
{ SysUtils File open modes }
  fmOpenRead = OF_READ;
  fmOpenWrite = OF_WRITE;
  fmOpenReadWrite = OF_READWRITE;
  fmShareCompat = OF_SHARE_COMPAT;
  fmShareExclusive = OF_SHARE_EXCLUSIVE;
  fmShareDenyWrite = OF_SHARE_DENY_WRITE;
  fmShareDenyRead = OF_SHARE_DENY_READ;
  fmShareDenyNone = OF_SHARE_DENY_NONE;

function FileTime(const FileName: string): integer;
function FileSize(const FileName: string): integer {Int64};
function FileOpen(const FileName: string; Mode: cardinal): integer;
function CreateFile(FileName: PChar; Access, Share: cardinal; Security: pointer; Disposition, Flags: cardinal; Template: integer): integer; stdcall;
function CloseHandle(handle: integer): longbool; stdcall;
function SetfPos(handle: integer; OffsetLow: longint; OffSetHigh: pointer; Movement: cardinal): cardinal; stdcall; forward;
function SetEOF(handle: integer): longbool; stdcall;
function CreateFileMapping(handle: integer; Attributes: pointer; flProtect, MaxSizeHigh, MaxSizeLow: cardinal; FileName: PChar): integer; stdcall;
function MapViewOfFile(handle: integer; Access: cardinal; OffHigh, OffLow, Length: cardinal): PChar; stdcall;
function FlushViewOfFile(const Base: Pointer; Length: cardinal): longbool; stdcall;
function UnmapViewOfFile(Base: Pointer): longbool; stdcall;
//function CharUpperBuff(var Buffer; Length: integer): integer; stdcall;
//function CharLowerBuff(var Buffer; Length: integer): integer; stdcall;
//procedure RaiseException(Code: Cardinal = $DEAD; Flags: Cardinal = 1; ArgCount: Cardinal = 0; Arguments: pointer = nil); stdcall;
implementation
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  Windows Routines 1 ~ Windows SysChar & Exception
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
///
const
  kernel32 = 'kernel32.dll';
  user32 = 'user32.dll';
  PAGESIZE = $100;
  MAXBYTE = PAGESIZE -1;

function CharUpperBuff(var Buffer; Length: integer): integer; stdcall; external user32 name 'CharUpperBuffA'; {$EXTERNALSYM CharUpperBuff}
function CharLowerBuff(var Buffer; Length: integer): integer; stdcall; external user32 name 'CharLowerBuffA'; {$EXTERNALSYM CharLowerBuff}
procedure RaiseException(Code: Cardinal = $DEAD; Flags: Cardinal = 1; ArgCount: Cardinal = 0; Arguments: pointer = nil); stdcall; external kernel32 name 'RaiseException'; {$EXTERNALSYM RaiseException}
///

procedure WinUpLo(var UPCASETABLE, locasetable);
begin
  asm
    push ecx; mov ecx, MAXBYTE
  @@Loop:
    mov byte ptr UPCASETABLE[ecx], cl
    mov byte ptr locasetable[ecx], cl
    dec ecx; jge @@Loop
    pop ecx
  end;
  CharUpperBuff(UPCASETABLE, high(byte) + 1);
  CharLowerBuff(locasetable, high(byte) + 1);
end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  Windows Routines 2 ~ File-handling routines
//  All of these busy stuffs below are necessary only for file-based
//  sample implementation. you might get rid all of them instead!
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//type
//  dword = cardinal;
//  thandle = integer;

const
  MAX_PATH = 260; {$EXTERNALSYM MAX_PATH}
  INVALID_HANDLE_VALUE = -1; {$EXTERNALSYM INVALID_HANDLE_VALUE}
  FA_DIRECTORY = $10;
type
  PFileTime = ^TFileTime;
  TFileTime = packed record
    LowDateTime, HighDateTime: dword;
  end;

  PFindData = ^TFindData;
  TFindData = packed record
    FileAttributes: dword;
    CreationTime: TFileTime;
    LastAccessTime: TFileTime;
    LastWriteTime: TFileTime;
    FileSizeHigh, FileSizeLow: dword;
    Reserved0, Reserved1: dword;
    FileName: array[0..MAX_PATH - 1] of AnsiChar;
    AlternateFileName: array[0..13] of AnsiChar;
  end;

type
  TFileName = string;
  TSearchRec = packed record
    Time, Size, Attr: integer;
    Name: TFileName;
    ExcludeAttr: integer;
    FindHandle: THandle;
    FindData: TFindData;
  end;

type
  LongRec = packed record
    Lo, Hi: Word;
  end;
  Int64Rec = packed record
    Lo, Hi: dword;
  end;

  PSystemTime = ^TSystemTime;
  TSystemTime = packed record
    year, month, DOW: word;
    day, hour, min, sec, ms: Word;
  end;
///
function FindFirst(FileName: PChar; var Data: TFindData): THandle; stdcall; external kernel32 name 'FindFirstFileA';  {$EXTERNALSYM FindFirst}
function FindNext(FindFile: THandle; var Data: TFindData): longbool; stdcall; external kernel32 name 'FindNextFileA'; {$EXTERNALSYM FindNext}
function FindClose(FindFile: THandle): longbool; stdcall; external kernel32 name 'FindClose'; {$EXTERNALSYM FindClose}
function ftimeLocal(const FileTime: TFileTime; var LocalTime: TFileTime): longbool; stdcall; external kernel32 name 'FileTimeToLocalFileTime'; {$EXTERNALSYM ftimeLocal}
function ftimeDOS(const FileTime: TFileTime; var FATDate, FATTime: Word): longbool; stdcall; external kernel32 name 'FileTimeToDosDateTime'; {$EXTERNALSYM ftimeDOS}
function ftimeSystem(const lpFileTime: TFileTime; var lpSystemTime: TSystemTime): longbool; stdcall; external kernel32 name 'FileTimeToSystemTime'{$EXTERNALSYM ftimeSystem}
///

function FileTime(const FileName: string): integer;
var
  Data: TFindData;
  Time: TFileTime;
begin
  Result := FindFirst(PChar(FileName), Data);
  if Result <> INVALID_HANDLE_VALUE then begin
    FindClose(Result);
    if (Data.FileAttributes and FA_DIRECTORY) = 0 then begin
      ftimeLocal(Data.LastWriteTime, Time);
      if not ftimeDOS(Time, LongRec(Result).Hi, LongRec(Result).Lo) then
        Result := INVALID_HANDLE_VALUE;
    end;
  end;
end;

function FileSize(const FileName: string): integer {Int64};
var
  Data: TFindData;
begin
  Result := FindFirst(PChar(FileName), Data);
  if Result <> INVALID_HANDLE_VALUE then begin
    FindClose(Result);
    if not ((Data.FileAttributes and FA_DIRECTORY) = 0) then
      Result := -1
    else begin
      //int64Rec(Result).Hi := Data.FileSizeHigh;
      //int64Rec(Result).Lo := Data.FileSizeLow;
      Result := Data.FileSizeLow;
    end;
  end;
end;
///
function CreateFile(FileName: PChar; Access, Share: dword; Security: pointer; Disposition, Flags: dword; Template: THandle): THandle; stdcall; external kernel32 name 'CreateFileA'; {$EXTERNALSYM CreateFile}
function CloseHandle(handle: THandle): longbool; stdcall; external kernel32 name 'CloseHandle'; {$EXTERNALSYM CloseHandle}
function SetfPos(handle: THandle; OffsetLow: longint; OffSetHigh: pointer; Movement: dword): dword; stdcall; external kernel32 name 'SetFilePointer';{$EXTERNALSYM SetfPos}
function SetEOF(handle: THandle): longbool; stdcall; external kernel32 name 'SetEndOfFile'; {$EXTERNALSYM SetEOF}
function CreateFileMapping(handle: THandle; Attributes: pointer; flProtect, MaxSizeHigh, MaxSizeLow: dword; FileName: PChar): THandle; stdcall; external kernel32 name 'CreateFileMappingA'; {$EXTERNALSYM CreateFileMapping}
function MapViewOfFile(handle: THandle; Access: dword; OffHigh, OffLow, Length: dword): PChar; stdcall; external kernel32 name 'MapViewOfFile'; {$EXTERNALSYM MapViewOfFile}
function FlushViewOfFile(const Base: Pointer; Length: dword): longbool; stdcall; external kernel32 name 'FlushViewOfFile';{$EXTERNALSYM FlushViewOfFile}
function UnmapViewOfFile(Base: Pointer): longbool; stdcall; external kernel32 name 'UnmapViewOfFile';{$EXTERNALSYM UnmapViewOfFile}
///

function FileOpen(const FileName: string; Mode: LongWord): integer;
const
  AccessMode: array[0..2] of longword = (
    GENERIC_READ, GENERIC_WRITE, GENERIC_READ or GENERIC_WRITE);
  ShareMode: array[0..4] of longword = (0, 0,
    FILE_SHARE_READ, FILE_SHARE_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE);
begin
  Result := integer(CreateFile(PChar(FileName), AccessMode[Mode and 3],
    ShareMode[(Mode and $F0) shr 4], nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0));
end;

end.


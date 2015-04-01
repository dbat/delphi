unit cxfvmap;
{$WEAKPACKAGEUNIT ON}
{$J-} //no-writeableconst
{$R-} //no-rangechecking
{$Q-} //no-overflowchecking
{.$D-} //no-debug
{
// this unit should be used only by cxpos
// ====================================================================
//  Copyright (c) 2004, aa, Adrian H., Ray AF. & Inge DR.
//  Property of PT SOFTINDO Jakarta.
//  All rights reserved.
// ====================================================================
//
//  (this format should stop spammer-bot, to be stripped are:
//   at@, brackets[], comma,, overdots., and dash-
//   do not strip underscore_)
//
//  mail,to:@[zero_inge]AT@-y.a,h.o.o.@DOTcom,
//  mail,to:@[aa]AT@-s.o.f.t,i.n.d.o.@DOTnet
//  http://delphi.softindo.net
//
}

interface

type
  tcxmapOperation = (cxmRead, cxmWrite, cxmRewrite);

procedure CloseView(var filehandle, maphandle: integer; var ViewBase: pointer);

function OpenView(const Filename: string; var filehandle, maphandle: integer;
  const mapOperation: tcxmapOperation = cxmRead): pointer;

procedure FlushView(const filehandle: integer; var maphandle: integer;
  var ViewBase: pointer; const ViewCopy: pointer; const Length: integer;
  const Truncated: boolean);

function GetFileSize(const FileName: string): integer {Int64}; forward; overload;
function GetLongFileSize(const FileName: string): Int64; forward; overload;
function GetFileTime(const FileName: string): integer; forward; overload;
function SetFileTime(const FileName: string; const FileTime: integer): integer; forward; overload;
function fileexists(const filename: string): boolean; forward; overload;

{.$DEFINE USING_MBCS}
implementation

{$IFDEF USING_MBCS}
uses MBCSdlm;
function LastDelimiter(const Delimiters, S: string): integer;
begin
  Result := MBCSdlm.LastDelimiter(Delimiters, S);
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
{$ENDIF NOT USING_MBCS}

type
  thandle = integer;
  DWORD = longword;

const
  ZERO = 0;
  VOID = nil;

const
  INVALID_RETURN_VALUE = integer(pred(ZERO));
  INVALID_HANDLE = INVALID_RETURN_VALUE;
  INVALID = INVALID_RETURN_VALUE;
  INVALID_MAP = ZERO; // invalid map returns 0, not -1
  INVALID_VIEW = VOID;

const // owned also by somone else
  FILE_BEGIN = ZERO; {$EXTERNALSYM FILE_BEGIN}
  //FILE_CURRENT = 1; {$EXTERNALSYM FILE_CURRENT}
  //FILE_END = 2; {$EXTERNALSYM FILE_END}
  PAGE_READONLY = 2; {$EXTERNALSYM PAGE_READONLY}
  PAGE_READWRITE = 4; {$EXTERNALSYM PAGE_READWRITE}
  SECTION_MAP_READ = 4; {$EXTERNALSYM SECTION_MAP_READ}
  SECTION_MAP_WRITE = 2; {$EXTERNALSYM SECTION_MAP_WRITE}
  GENERIC_READ = dword($80000000); {$EXTERNALSYM GENERIC_READ}
  GENERIC_WRITE = $40000000; {$EXTERNALSYM GENERIC_WRITE}
  FILE_SHARE_READ = $00000001; {$EXTERNALSYM FILE_SHARE_READ}
  FILE_SHARE_WRITE = $00000002; {$EXTERNALSYM FILE_SHARE_WRITE}
  FILE_ATTRIBUTE_NORMAL = $00000080; {$EXTERNALSYM FILE_ATTRIBUTE_NORMAL}
  OPEN_EXISTING = 3; {$EXTERNALSYM OPEN_EXISTING}
  FILE_FLAG_SEQUENTIAL_SCAN = $8000000; {$EXTERNALSYM FILE_FLAG_SEQUENTIAL_SCAN}

const // our custom constants
  GENERIC_READWRITE = GENERIC_READ or GENERIC_WRITE;
  FILE_SHARE_READWRITE = FILE_SHARE_READ or FILE_SHARE_WRITE;
  SECTION_MAP_READWRITE = SECTION_MAP_READ or SECTION_MAP_WRITE;
  SEEKMETHOD_FILE_BEGIN = FILE_BEGIN;

  DEFAULT_OFFSET_HIGH = ZERO;
  DEFAULT_OFFSET_LOW = ZERO;
  DEFAULT_MAXSIZE_HIGH = ZERO;
  DEFAULT_MAXSIZE_LOW = ZERO;
  DEFAULT_NUMBEROFBYTES = ZERO;
  DEFAULT_SEC_ATTRIBUTES = VOID;
  DEFAULT_SA = DEFAULT_SEC_ATTRIBUTES;
  DEFAULT_SEEKMETHOD = SEEKMETHOD_FILE_BEGIN;
  DEFAULT_OPENMODE = GENERIC_READ;
  DEFAULT_SHAREMODE = FILE_SHARE_READWRITE;
  DEFAULT_MAPMODE = SECTION_MAP_READ;
  DEFAULT_MAP_ACCESS = DEFAULT_MAPMODE;
  DEFAULT_PAGE_ACCESS = PAGE_READONLY;
  DEFAULT_CREATION_MODE = OPEN_EXISTING;
  DEFAULT_FLAG = FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN;
  DEFAULT_LENGTH = ZERO;
  DEFAULT_TEMPLATE = ZERO;

function CloseHandle(handle: thandle): longbool; stdcall; forward;
function CreateFile(FileName: PChar; OpenMode: DWORD = DEFAULT_OPENMODE;
  ShareMode: DWORD = DEFAULT_SHAREMODE; SecAttrib: pointer = DEFAULT_SA;
  CreationMode: DWORD = DEFAULT_CREATION_MODE; Flags: DWORD = DEFAULT_FLAG;
  Template: thandle = DEFAULT_TEMPLATE): thandle; stdcall; forward;
function SetfPos(handle: thandle; OffsetLow: integer = ZERO; OffsetHigh: integer = ZERO;
  SeekMethod: integer = DEFAULT_SEEKMETHOD): integer; stdcall; forward;
function SetEOF(handle: integer): longbool; stdcall; forward;
function CreateFileMapping(handle: thandle; SecAttrib: pointer = DEFAULT_SA;
  PageAccess: integer = DEFAULT_PAGE_ACCESS; MaxSizeHigh: integer = DEFAULT_MAXSIZE_HIGH;
  MaxSizeLow: integer = DEFAULT_MAXSIZE_LOW; MapName: PChar = VOID): thandle; stdcall; forward;
function MapViewOfFile(handle: thandle; MapAccess: integer = DEFAULT_MAP_ACCESS;
  OffsetHigh: integer = DEFAULT_OFFSET_HIGH; OffsetLow: integer = DEFAULT_OFFSET_LOW;
  Length: integer = DEFAULT_LENGTH): PChar; stdcall; forward;
function FlushViewOfFile(const Base: Pointer; const Length: integer = 0): longbool; stdcall; forward;
function UnmapViewOfFile(Base: Pointer): longbool; stdcall; forward

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// borrowed routines from unit chpos
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
procedure xMove(const Src; var Dest; Count: integer);
asm
  push esi; push edi
  mov esi, Src; mov edi, Dest
  mov ecx, Count; mov eax, ecx
  sar ecx, 2; js @@end
  push eax; jz @@recall
  @@LoopDWord:
    mov eax, [esi]; lea esi, esi +4
    mov [edi], eax; lea edi, edi +4
    dec ecx; jg @@LoopDWord
  @@recall: pop ecx
    and ecx, 03h; jz @@LoopDone
  @@LoopByte:
    mov al, [esi]; lea esi, esi +1
    mov [edi], al; lea edi, edi +1
    dec ecx; jg @@LoopByte
  @@LoopDone:
  @@end:
    pop edi; pop esi
end;

function ExtractFilename(const Filename: string): string;
var
  i: Integer;
begin
  i := LastDelimiter('\:', Filename);
  Result := Copy(Filename, i + 1, MaxInt);
end;

procedure FlushView(const filehandle: integer; var maphandle: integer;
  var ViewBase: pointer; const ViewCopy: pointer; const Length: integer;
  const Truncated: boolean);
  // here is a tricky business,
  // Rewrite MUST have a valid ViewBase and map handle to be closed
begin
  //Result := ViewBase;
  if length <> INVALID then begin
    if ViewCopy <> ViewBase then begin
      unmapViewOfFile(ViewBase);
      CloseHandle(maphandle);
      maphandle := CreateFileMapping(filehandle, DEFAULT_SA, PAGE_READWRITE,
        DEFAULT_MAXSIZE_HIGH, Length); //USE LENGTH!
      if maphandle = INVALID_MAP then
      else begin
        ViewBase := MapViewOfFile(maphandle, SECTION_MAP_READWRITE);
        if ViewBase <> INVALID_VIEW then begin
        {ChPos.}xMove(ViewCopy^, ViewBase^, Length);
          SysFreeMem(ViewCopy);
        end;
      end;
    end;
    FlushViewOfFile(ViewBase);
  end;
  unmapViewOfFile(ViewBase);
  CloseHandle(maphandle);
  if (length <> INVALID) and Truncated then begin
    // must be done after map & View closed!
    SetfPos(filehandle, Length);
    SetEOF(filehandle);
  end;
  CloseHandle(filehandle);
end;

function cxfOpen(const FileName: string; operation: tcxmapOperation): integer;
var
  AccessMode: DWORD;
  ShareMode: DWORD;
begin
  if operation = cxmRead then begin
    AccessMode := GENERIC_READ;
    ShareMode := FILE_SHARE_READWRITE;
  end else begin
    AccessMode := GENERIC_READWRITE;
    ShareMode := FILE_SHARE_READWRITE; //FILE_SHARE_READ
  end;
  Result := CreateFile(PChar(FileName), AccessMode, ShareMode); //,
end;

procedure CloseView(var filehandle, maphandle: integer; var ViewBase: pointer);
begin
  if ViewBase <> INVALID_VIEW then begin
    unmapViewOfFile(ViewBase);
    ViewBase := INVALID_VIEW; // maybe already done by OS?
  end;
  if maphandle <> INVALID_HANDLE then begin
    CloseHandle(maphandle);
    maphandle := INVALID_HANDLE; // maybe already done by OS?
  end;
  if filehandle <> INVALID_HANDLE then begin
    CloseHandle(filehandle);
    maphandle := INVALID_HANDLE; // maybe already done by OS?
  end;
end;

function OpenView(const Filename: string; var filehandle, maphandle: integer;
  const mapOperation: tcxmapOperation = cxmRead): pointer;
var
  MapAccess, PageAccess: DWORD;
begin
  Result := VOID;
  if mapOperation = cxmRead then begin
    MapAccess := SECTION_MAP_READ;
    PageAccess := PAGE_READONLY;
  end
  else begin
    MapAccess := SECTION_MAP_READWRITE;
    PageAccess := PAGE_READWRITE;
  end;
  filehandle := cxfOpen(FileName, mapOperation);
  if filehandle <> INVALID_HANDLE then begin
    SetfPos(filehandle);
    maphandle := CreateFileMapping(filehandle, DEFAULT_SA, PageAccess);
    if maphandle = INVALID_MAP then begin
      CloseHandle(filehandle);
      filehandle := INVALID_HANDLE; //maybe shoudnt?
    end
    else
      Result := MapViewOfFile(maphandle, MapAccess);
  end;
end;




// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  Windows Routines 1 ~ Windows SysChar & Exception
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
const
  kernel32 = 'kernel32.dll';
  user32 = 'user32.dll';

// //
// function CharUpperBuff(var Buffer; Length: integer): integer; stdcall;
//   external user32 name 'CharUpperBuffA'; {$EXTERNALSYM CharUpperBuff}
// function CharLowerBuff(var Buffer; Length: integer): integer; stdcall;
//   external user32 name 'CharLowerBuffA'; {$EXTERNALSYM CharLowerBuff}
// procedure RaiseException(Code: integer = $DEADF00; Flags: integer = 1;
//   ArgCount: integer = 0; Arguments: pointer = nil); stdcall;
//   external kernel32 name 'RaiseException'; {$EXTERNALSYM RaiseException}
// //

//~ procedure WinUpLo;
//~ begin
//~   asm
//~     push ecx; mov ecx, MAXBYTE
//~   @@Loop:
//~     mov byte ptr UPCASETABLE[ecx], cl
//~     mov byte ptr locasetable[ecx], cl
//~     dec ecx; jge @@Loop
//~     pop ecx
//~   end;
//~   CharUpperBuff(UPCASETABLE, high(byte) + 1);
//~   CharLowerBuff(locasetable, high(byte) + 1);
//~ end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  Windows Routines 2 ~ File-handling routines
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

const
  MAX_PATH = 260; {$EXTERNALSYM MAX_PATH}
  INVALID_HANDLE_VALUE = INVALID_RETURN_VALUE; {$EXTERNALSYM INVALID_HANDLE_VALUE}
  FA_DIRECTORY = $10;

type
  TFileTime = Int64;

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
    FindHandle: thandle;
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
function FindFirst(FileName: PChar; var Data: TFindData): thandle; stdcall;
  external kernel32 name 'FindFirstFileA'; {$EXTERNALSYM FindFirst}
function FindNext(FindFile: thandle; var Data: TFindData): longbool; stdcall;
  external kernel32 name 'FindNextFileA'; {$EXTERNALSYM FindNext}
function FindClose(FindFile: thandle): longbool; stdcall;
  external kernel32 name 'FindClose'; {$EXTERNALSYM FindClose}
function GetFileTime(handle: thandle;  Create, Access, Write: TFileTime): longbool;
  stdcall; overload; external kernel32 name 'GetFileTime'; {$EXTERNALSYM GetFileTime}
function SetFileTime(handle: thandle; Create, Access, Write: TFileTime): longbool;
  stdcall; overload; external kernel32 name 'SetFileTime'; {$EXTERNALSYM SetFileTime}
function fTime2Local(const FileTime: TFileTime; var LocalTime: TFileTime): longbool; stdcall;
  external kernel32 name 'FileTimeToLocalFileTime'; {$EXTERNALSYM fTime2Local}
function fTime2DOS(const FileTime: TFileTime; var FATDate, FATTime: Word): longbool; stdcall;
  external kernel32 name 'FileTimeToDosDateTime'; {$EXTERNALSYM fTime2DOS}
function Local2fTime(const LocalTime: TFileTime; var FileTime: TFileTime): longbool; stdcall;
  external kernel32 name 'LocalFileTimeToFileTime'; {$EXTERNALSYM Local2fTime}
function DOS2fTime(FATDate, FATTime: word; var FileTime: TFileTime): longbool; stdcall;
  external kernel32 name 'DosDateTimeToFileTime'; {$EXTERNALSYM DOS2fTime}
function ftimeSystem(const FileTime: TFileTime; var SystemTime: TSystemTime): longbool; stdcall;
  external kernel32 name 'FileTimeToSystemTime'{$EXTERNALSYM ftimeSystem}
///

function fileexists(const filename: string): boolean;
const
  FILE_ATTRIBUTE_DIRECTORY = $00000010; // {$EXTERNALSYM FILE_ATTRIBUTE_DIRECTORY}
var
  ff: THandle;
  FindData: TFindData;
begin
  ff := FindFirst(PChar(Filename), FindData);
  Result := ff <> INVALID_Handle_VALUE;
  if Result then begin
    FindClose(ff);
    Result := (FindData.FileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0
  end
end;

function GetFileSize(const FileName: string): integer {Int64};
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

function GetLongFileSize(const FileName: string): Int64;
var
  Data: TFindData;
begin
  Result := FindFirst(PChar(FileName), Data);
  if Result <> INVALID_HANDLE_VALUE then begin
    FindClose(Result);
    if not ((Data.FileAttributes and FA_DIRECTORY) = 0) then
      Result := -1
    else begin
      int64Rec(Result).Hi := Data.FileSizeHigh;
      int64Rec(Result).Lo := Data.FileSizeLow;
      //Result := Data.FileSizeLow;
    end;
  end;
end;

function GetFileTime(const handle: thandle): Int64; overload
begin
  Result := INVALID_RETURN_VALUE;
  if not GetFileTime(handle, 0, 0, Result) then
    Result := INVALID_RETURN_VALUE;
end;

procedure SetFileTime(const handle: thandle; const FileTime: Int64); overload
begin
  SetFileTime(handle, 0, 0, FileTime);
end;

function GetFileTime(const FileName: string): integer; overload;
var
  Data: TFindData;
  Local: TFileTime;
begin
  Result := FindFirst(PChar(FileName), Data);
  if Result <> INVALID_HANDLE_VALUE then begin
    FindClose(Result);
    if (Data.FileAttributes and FA_DIRECTORY) = 0 then begin
      ftime2Local(Data.LastWriteTime, Local);
      if not ftime2DOS(Local, LongRec(Result).Hi, LongRec(Result).Lo) then
        Result := INVALID_HANDLE_VALUE;
    end;
  end;
end;

function SetFileTime(const FileName: string; const FileTime: integer): integer; overload;
var
  Local, fTime: TFileTime;
  handle: integer;
begin
  handle := cxfOpen(FileName, cxmRead);
  if (handle <> INVALID_HANDLE_VALUE) and
    DOS2fTime(longrec(FileTime).Hi, longrec(FileTime).Lo, Local) and
    Local2fTime(Local, fTime) then begin
    SetFileTime(handle, 0, 0, fTime);
    CloseHandle(handle);
    Result := 0;
  end
  else
    Result := INVALID_HANDLE_VALUE
end;

///
function CreateFile(FileName: PChar; OpenMode, ShareMode: DWORD; SecAttrib: pointer;
  CreationMode, Flags: DWORD; Template: thandle): thandle; stdcall;
  external kernel32 name 'CreateFileA'; {$EXTERNALSYM CreateFile}
function CloseHandle(handle: thandle): longbool; stdcall;
  external kernel32 name 'CloseHandle'; {$EXTERNALSYM CloseHandle}
function SetfPos(handle: thandle; OffsetLow, OffsetHigh, SeekMethod: integer): integer;
  stdcall; external kernel32 name 'SetFilePointer'; {$EXTERNALSYM SetfPos}
function SetEOF(handle: thandle): longbool; stdcall;
  external kernel32 name 'SetEndOfFile'; {$EXTERNALSYM SetEOF}
function CreateFileMapping(handle: thandle; SecAttrib: pointer;
  PageAccess, MaxSizeHigh, MaxSizeLow: integer; MapName: PChar): thandle; stdcall;
  external kernel32 name 'CreateFileMappingA'; {$EXTERNALSYM CreateFileMapping}
function MapViewOfFile(handle: thandle; MapAccess: integer;
  OffsetHigh, OffsetLow, Length: integer): PChar; stdcall;
  external kernel32 name 'MapViewOfFile'; {$EXTERNALSYM MapViewOfFile}
function FlushViewOfFile(const Base: Pointer; const Length: integer): longbool; stdcall;
  external kernel32 name 'FlushViewOfFile'; {$EXTERNALSYM FlushViewOfFile}
function UnmapViewOfFile(Base: Pointer): longbool; stdcall;
  external kernel32 name 'UnmapViewOfFile'; {$EXTERNALSYM UnmapViewOfFile}
///

end.


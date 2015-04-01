unit MBCSFileFuncs;
{$WEAKPACKAGEUNIT ON}
{$J-} //no-writeableconst
{$R-} //no-rangechecking
{$Q-} //no-overflowchecking
{.$D-} //no-debug
// just an interface wrap fdirfunc's function
// MBCS functions is expected to be slow anyway

interface
function ExtractFileExt(const Filename: string): string;
function ChangeFileExt(const Filename, Extension: string): string;
function ExtractFileDir(const Filename: string): string;
function ExtractFilename(const Filename: string): string;
function ExtractFilePath(const Filename: string): string; // backslash appended
function IncludeTrailingBackslash(const S: string): string; forward;
function ExcludeTrailingBackslash(const S: string): string; forward;
function FileGetSize(const Filename: string): Int64;
function FileExists(const Filename: string): Boolean;
function DirectoryExists(const Name: string): Boolean;
function CreateDir(const Dir: string): Boolean;
function CreateDirTree(DirTree: string): Boolean;
function DeleteFile(Filename: string): boolean; overload;
function DeleteFiles(const PathMask: string): integer;
function RenameFile(SrcFilename, DestFilename: string): boolean; overload;

//function IncludeTrailingBackslash(const S: string): string;
//function ExcludeTrailingBackslash(const S: string): string;
//function LastDelimiter(const Delimiters, S: string): Integer;
//function IsPathDelimiter(const S: string; Index: Integer): Boolean;

implementation
uses fdirfunc, MBCSFuncs; // for LastDelimiter

function LastDelimiter(const Delimiters, S: string): Integer;
begin
  Result := MBCSFuncs.LastDelimiter(Delimiters, S);
end;

function IsPathDelimiter(const S: string; Index: Integer): Boolean;
begin
  Result := MBCSFuncs.IsPathDelimiter(S, Index);
end;

function IncludeTrailingBackslash(const S: string): string;
begin
  Result := S;
  if not IsPathDelimiter(Result, Length(Result)) then Result := Result + '\';
end;

function ExcludeTrailingBackslash(const S: string): string;
begin
  Result := S;
  if IsPathDelimiter(Result, Length(Result)) then
    SetLength(Result, Length(Result) - 1);
end;

function ExtractFileExt(const Filename: string): string;
begin Result := fdirfunc.ExtractFileExt(filename); end;

function ChangeFileExt(const Filename, Extension: string): string;
begin Result := '';
end;
function ExtractFileDir(const Filename: string): string;
begin Result := '';
end;
function ExtractFilename(const Filename: string): string;
begin Result := '';
end;
function ExtractFilePath(const Filename: string): string; // backslash appended
begin Result := '';
end;
//function IncludeTrailingBackslash(const S: string): string;
//begin Result := '';
//end;
//function ExcludeTrailingBackslash(const S: string): string;
//begin Result := '';
//end;
function FileExists(const Filename: string): Boolean;
begin Result := Low(Result);
end;
function CreateDir(const Dir: string): Boolean;
begin Result := Low(Result);
end;
function DeleteFile(Filename: string): boolean; overload;
begin Result := Low(Result);
end;
function FileGetSize(const Filename: string): Int64; // +
begin Result := Low(Result);
end;
function DirectoryExists(const Name: string): Boolean; // +
begin Result := Low(Result);
end;
function CreateDirTree(DirTree: string): Boolean; // +
begin Result := Low(Result);
end;
function DeleteFiles(const PathMask: string): integer; // +
begin Result := Low(Result);
end;

function RenameFile(SrcFilename, DestFilename: string): boolean; overload;
begin Result := fdirfunc.RenameFile(SrcFileName, DestFilename); end;


end.


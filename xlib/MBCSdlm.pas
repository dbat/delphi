unit MBCSdlm;
{$WEAKPACKAGEUNIT ON}
{$J-} //no-writeableconst
{$R-} //no-rangechecking
{$Q-} //no-overflowchecking
{.$D-}//no-debug
{.$DEFINE USING_MBCS}// still could be turned off here
// this unit only serves 2 routines which mbcs-enabled
//
// LastDelimiter(const Delimiters, S: string): Integer;
//    returns index of the last delimiter (from given charset)
//    found in file/path-name string
//
// IsPathDelimiter(const S: string; Index: Integer): Boolean;
//    checks whether char at specified index is backslash
//
{
//  contacts:
//  (this format should stop idiot spammer-bots, to be stripped are:
//   at@, brackets[], comma,, overdots., and dash-
//   DO NOT strip underscore_)
//
//  @[zero_inge]AT@-y.a,h.o.o.@DOTcom,  ~ should be working
//                                      (as long as yahoo still online)
//  or
//
//  @[aa]AT@-s.o.f.t,i.n.d.o.@DOTnet  ~ not work
//    http://delphi.formasi.com       ~ maybe no longer work
//    http://delphi.softindo.net      ~ not even yet work
//
//  authors address:
//    Jl. Lima Benua No.23, Ciputat 15411,
//    Banten, INDONESIA
//
//  company address:
//    PT SOFTINDO
//    Jl. Bangka II No.1A,
//    Jakarta 12720, INDONESIA.
}

// mbcs stands for multi-byte-characters-sytem
// used by various laguage such as japan, korea & china
// if you are not a northern asian people, or you never heard
// anything about mbcs, then its not likely you need it
//
// mbcs is sloow in nature, never use it if not absolutely necessary
// particularly, NEVER use this against lengthly string (say, > 64K)
// use only for file/directory-name check (max-length less than 1K)


interface
function LastDelimiter(const Delimiters, S: string): Integer; forward;
function IsPathDelimiter(const S: string; Index: Integer): Boolean; forward;

//function StrScan(const Str: PChar; Chr: Char): PChar; forward;
// due to low performance do not use for long-string (string with great length)
// use only for small string such as Filename / path name

type
  TMBCSByteType = (mbSingleByte, mbLeadByte, mbTrailByte);
function ByteType(const S: string; Index: Integer): TMbcsByteType;
function StrByteType(Str: PChar; Index: Cardinal): TMbcsByteType;

implementation
const
  BACKSLASH = '\';

{$IFNDEF USING_MBCS}
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
  Result := (Index > 0) and (Index <= Length(S)) and (S[Index] = BACKSLASH)
   //and (ByteType(S, Index) = mbSingleByte);
end;

function ByteType(const S: string; Index: Integer): TMbcsByteType;
begin
  Result := Low(Result);
end;

function StrByteType(Str: PChar; Index: Cardinal): TMbcsByteType;
begin
  Result := Low(Result);
end;

{$ELSE IFDEF USING_MBCS}
type
  UINT = Longword; {$EXTERNALSYM UINT}
  DWORD = longword; {$EXTERNALSYM DWORD}
  BOOL = longbool; {$EXTERNALSYM BOOL}
  LCID = DWORD; {$EXTERNALSYM LCID}
  LANGID = Word; {$EXTERNALSYM LANGID}

  TSysLocale = packed record
    DefaultLCID: LCID;
    PriLangID: LANGID;
    SubLangID: LANGID;
    FarEast: Boolean;
    MiddleEast: Boolean;
  end;

var
  SysLocale: TSysLocale = (DefaultLCID: 0);
  LeadBytes: set of char = [];

//type
//  TMBCSByteType = (mbSingleByte, mbLeadByte, mbTrailByte);

function ByteTypeTest(P: PChar; Index: Integer): TMbcsByteType;
var
  I: Integer;
  //LeadBytes: set of char;
begin
  Result := mbSingleByte;
  //LeadBytes := WinGlobal.LeadBytes;
  if (P = nil) or (P[Index] = #$0) then Exit;
  if (Index = 0) then begin
    if P[0] in LeadBytes then Result := mbLeadByte;
  end
  else begin
    I := Index - 1;
    while (I >= 0) and (P[I] in LeadBytes) do
      dec(I);
    if ((Index - I) mod 2) = 0 then
      Result := mbTrailByte
    else if P[Index] in LeadBytes then
      Result := mbLeadByte;
  end;
end;

function ByteType(const S: string; Index: Integer): TMbcsByteType;
begin
  Result := mbSingleByte;
  if {WinGlobal.} SysLocale.FarEast then
    Result := ByteTypeTest(PChar(S), Index - 1);
end;

function StrByteType(Str: PChar; Index: Cardinal): TMbcsByteType;
begin
  Result := mbSingleByte;
  if SysLocale.FarEast then
    Result := ByteTypeTest(Str, Index);
end;

// from SysUtils
{ StrScan returns a pointer to the first occurrence of Chr in Str. If Chr
  does not occur in Str, StrScan returns NIL. The null terminator is
  considered to be part of the string. }

function StrScan(const Str: PChar; Chr: Char): PChar; assembler;
// due to low performance do not use for long-string (string with great length)
// use only for small string such as Filename / path name
asm
    push edi
    push eax
    mov edi, str
    mov ecx, 0ffffffffh
    xor al, al
    repne scasb
    not ecx
    pop edi
    mov al, chr
    repne scasb
    mov eax, 0
    jne @@1
    mov eax, edi
    dec eax
  @@1: pop edi
end;

procedure InitSysLocale; forward;

function LastDelimiter(const Delimiters, S: string): Integer;
var
  P: PChar;
begin
  if SysLocale.DefaultLCID = 0 then InitSysLocale;
  Result := Length(S);
  P := PChar(Delimiters);
  while Result > 0 do begin
    if (S[Result] <> #0) and (StrScan(P, S[Result]) <> nil) then
      if (ByteType(S, Result) = mbTrailByte) then
        dec(Result)
      else
        Exit;
    dec(Result);
  end;
end;

function IsPathDelimiter(const S: string; Index: Integer): Boolean;
begin
  if SysLocale.DefaultLCID = 0 then InitSysLocale;
  Result := (Index > 0) and (Index <= Length(S)) and (S[Index] = BACKSLASH)
    and (ByteType(S, Index) = mbSingleByte);
end;

const
  MAX_LEADBYTES = 12; {$EXTERNALSYM MAX_LEADBYTES} // 5 ranges, 2 bytes ea., 0 term.
  MAX_DEFAULTCHAR = 2; {$EXTERNALSYM MAX_DEFAULTCHAR} // whether single or double byte

type
  TCPInfo = record
    MaxCharSize: UINT; { max length (bytes) of a char }
    DefaultChar: array[0..MAX_DEFAULTCHAR - 1] of Byte; { default character }
    LeadByte: array[0..MAX_LEADBYTES - 1] of Byte; { lead byte ranges }
  end;

const
  user32 = 'user32.dll';
  kernel32 = 'kernel32.dll';

function GetSystemMetrics(nIndex: Integer): Integer; stdcall; external user32 name 'GetSystemMetrics'; {$EXTERNALSYM GetSystemMetrics}
function GetThreadLocale: LCID; stdcall; external kernel32 name 'GetThreadLocale'; {$EXTERNALSYM GetThreadLocale}
function GetCPInfo(CodePage: UINT; var lpCPInfo: TCPInfo): BOOL; stdcall; external kernel32 name 'GetCPInfo'; {$EXTERNALSYM GetCPInfo}

procedure InitSysLocale;
const
  LANG_ENGLISH = $09;
  SUBLANG_ENGLISH_US = $01;

  SM_DBCSENABLED = 42; //{$EXTERNALSYM SM_DBCSENABLED}
  SM_MIDEASTENABLED = 74; //{$EXTERNALSYM SM_MIDEASTENABLED}

  CP_ACP = 0; //{$EXTERNALSYM CP_ACP} // ANSI code page
  //CP_OEMCP = 1; {$EXTERNALSYM CP_OEMCP} // OEM  code page
  //CP_MACCP = 2; {$EXTERNALSYM CP_MACCP} // MAC  code page

var
  DefaultLCID: LCID;
  DefaultLangID: LANGID;
  AnsiCPInfo: TCPInfo;
  i: Integer;
  b: Byte;
begin
  { Set default to English (US). }
  SysLocale.DefaultLCID := $0409;
  SysLocale.PriLangID := LANG_ENGLISH;
  SysLocale.SubLangID := SUBLANG_ENGLISH_US;

  DefaultLCID := GetThreadLocale;
  if DefaultLCID <> 0 then SysLocale.DefaultLCID := DefaultLCID;

  DefaultLangID := Word(DefaultLCID);
  if DefaultLangID <> 0 then begin
    SysLocale.PriLangID := DefaultLangID and $3FF;
    SysLocale.SubLangID := DefaultLangID shr 10;
  end;

  SysLocale.MiddleEast := GetSystemMetrics(SM_MIDEASTENABLED) <> 0;
  SysLocale.FarEast := GetSystemMetrics(SM_DBCSENABLED) <> 0;
  if not SysLocale.FarEast then Exit;

  GetCPInfo(CP_ACP, AnsiCPInfo);
  with AnsiCPInfo do begin
    i := 0;
    while (i < MAX_LEADBYTES) and ((LeadByte[i] or LeadByte[i + 1]) <> 0) do begin
      for b := LeadByte[i] to LeadByte[i + 1] do
        Include(LeadBytes, Char(b));
      inc(i, 2);
    end;
  end;
end;
{$ENDIF NOT USING_MBCS}

end.


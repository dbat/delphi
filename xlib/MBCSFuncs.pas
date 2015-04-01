unit MBCSFuncs; // mbcs
{$WEAKPACKAGEUNIT ON}
{$J-} //no-writeableconst
{$R-} //no-rangechecking
{$Q-} //no-overflowchecking
{.$D-} //no-debug

interface

function LastDelimiter(const Delimiters, S: string): Integer;
function IsPathDelimiter(const S: string; Index: Integer): Boolean;

implementation
//uses WinGlobs;

type
  UINT = longword; {$EXTERNALSYM UINT}
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
  SysLocale: TSysLocale;
  LeadBytes: set of char;

type
  TMBCSByteType = (mbSingleByte, mbLeadByte, mbTrailByte);

function ByteTypeTest(P: PChar; Index: Integer): TMbcsByteType;
var
  i: Integer;
  //LeadBytes: set of char;
begin
  Result := mbSingleByte;
  //LeadBytes := WinGlobal.LeadBytes;
  if (P = nil) or (P[Index] = #$0) then Exit;
  if (Index = 0) then begin
    if P[0] in LeadBytes then Result := mbLeadByte;
  end
  else begin
    i := Index - 1;
    while (i >= 0) and (P[i] in LeadBytes) do Dec(i);
    if ((Index - i) mod 2) = 0 then Result := mbTrailByte
    else if P[Index] in LeadBytes then Result := mbLeadByte;
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
  if {WinGlobal.} SysLocale.FarEast then
    Result := ByteTypeTest(Str, Index);
end;

// from SysUtils
{ StrScan returns a pointer to the first occurrence of Chr in Str. If Chr
  does not occur in Str, StrScan returns NIL. The null terminator is
  considered to be part of the string. }

function StrScan(const Str: PChar; Chr: Char): PChar; assembler;
// due to low performance do not use for long-string (string with great length)
// use only for small string such as filename / path name
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

function LastDelimiter(const Delimiters, S: string): Integer;
var
  P: PChar;
begin
  Result := Length(S);
  P := PChar(Delimiters);
  while Result > 0 do
  begin
    if (S[Result] <> #0) and (StrScan(P, S[Result]) <> nil) then
      if (ByteType(S, Result) = mbTrailByte) then
        Dec(Result)
      else
        Exit;
    Dec(Result);
  end;
end;

function IsPathDelimiter(const S: string; Index: Integer): Boolean;
begin
  Result := (Index > 0) and (Index <= Length(S)) and (S[Index] = '\')
    and (ByteType(S, Index) = mbSingleByte);
end;

function IsDelimiter(const Delimiters, S: string; Index: Integer): Boolean;
begin
  Result := False;
  if (Index <= 0) or (Index > Length(S)) or (ByteType(S, Index) <> mbSingleByte) then exit;
  Result := StrScan(PChar(Delimiters), S[Index]) <> nil;
end;

const
  user32 = 'user32.dll';
  kernel32 = 'kernel32.dll';

function CompareString(Locale: LCID; dwCmpFlags: DWORD; lpString1: PChar; cchCount1: Integer; lpString2: PChar; cchCount2: Integer): Integer; stdcall; external kernel32 name 'CompareStringA'; {$EXTERNALSYM CompareString}
function CharUpperBuff(lpsz: PAnsiChar; cchLength: DWORD): DWORD; stdcall; external user32 name 'CharUpperBuffA'; {$EXTERNALSYM CharUpperBuff}
function CharLowerBuff(lpsz: PAnsiChar; cchLength: DWORD): DWORD; stdcall; external user32 name 'CharLowerBuffA'; {$EXTERNALSYM CharLowerBuff}
function CharLower(lpsz: PChar): PChar; stdcall; external user32 name 'CharLowerA'; {$EXTERNALSYM CharLower}
function CharUpper(lpsz: PChar): PChar; stdcall; external user32 name 'CharUpperA'; {$EXTERNALSYM CharUpper}

function AnsiUpperCase(const S: string): string;
var
  Len: Integer;
begin
  Len := Length(S);
  SetString(Result, PChar(S), Len);
  if Len > 0 then CharUpperBuff(Pointer(Result), Len);
end;

function AnsiLowerCase(const S: string): string;
var
  Len: Integer;
begin
  Len := Length(S);
  SetString(Result, PChar(S), Len);
  if Len > 0 then CharLowerBuff(Pointer(Result), Len);
end;

const
  SORT_DEFAULT = $0; {$EXTERNALSYM SORT_DEFAULT} // sorting default
  NORM_IGNORECASE = 1; {$EXTERNALSYM NORM_IGNORECASE} // ignore case

  LANG_NEUTRAL = 0; {$EXTERNALSYM LANG_NEUTRAL}
  SUBLANG_DEFAULT = $01; {$EXTERNALSYM SUBLANG_DEFAULT} // user default
  //SUBLANG_SYS_DEFAULT = $02; {$EXTERNALSYM SUBLANG_SYS_DEFAULT} // system default


  //LANG_SYSTEM_DEFAULT = (SUBLANG_SYS_DEFAULT shl 10) or LANG_NEUTRAL; {$EXTERNALSYM LANG_SYSTEM_DEFAULT}
  LANG_USER_DEFAULT = (SUBLANG_DEFAULT shl 10) or LANG_NEUTRAL; {$EXTERNALSYM LANG_USER_DEFAULT}
  //LOCALE_SYSTEM_DEFAULT = (SORT_DEFAULT shl 16) or LANG_SYSTEM_DEFAULT; {$EXTERNALSYM LOCALE_SYSTEM_DEFAULT}
  LOCALE_USER_DEFAULT = (SORT_DEFAULT shl 16) or LANG_USER_DEFAULT; {$EXTERNALSYM LOCALE_USER_DEFAULT}

function AnsiCompareStr(const S1, S2: string): Integer;
begin
  Result := CompareString(LOCALE_USER_DEFAULT, 0, PChar(S1), Length(S1),
    PChar(S2), Length(S2)) - 2;
end;

function AnsiSameStr(const S1, S2: string): Boolean;
begin
  Result := CompareString(LOCALE_USER_DEFAULT, 0, PChar(S1), Length(S1),
    PChar(S2), Length(S2)) = 2;
end;

function AnsiCompareText(const S1, S2: string): Integer;
begin
  Result := CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, PChar(S1),
    Length(S1), PChar(S2), Length(S2)) - 2;
end;

function AnsiSameText(const S1, S2: string): Boolean;
begin
  Result := CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, PChar(S1),
    Length(S1), PChar(S2), Length(S2)) = 2;
end;

function AnsiStrComp(S1, S2: PChar): Integer;
begin
  Result := CompareString(LOCALE_USER_DEFAULT, 0, S1, -1, S2, -1) - 2;
end;

function AnsiStrIComp(S1, S2: PChar): Integer;
begin
  Result := CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, S1, -1,
    S2, -1) - 2;
end;

function AnsiStrLComp(S1, S2: PChar; MaxLen: Cardinal): Integer;
begin
  Result := CompareString(LOCALE_USER_DEFAULT, 0,
    S1, MaxLen, S2, MaxLen) - 2;
end;

function AnsiStrLIComp(S1, S2: PChar; MaxLen: Cardinal): Integer;
begin
  Result := CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE,
    S1, MaxLen, S2, MaxLen) - 2;
end;

function AnsiStrLower(Str: PChar): PChar;
begin
  CharLower(Str);
  Result := Str;
end;

function AnsiStrUpper(Str: PChar): PChar;
begin
  CharUpper(Str);
  Result := Str;
end;

function AnsiLowerCaseFileName(const S: string): string;
var
  i, L: Integer;
begin
  if {WinGlobal.} SysLocale.FarEast then begin
    L := Length(S);
    SetLength(Result, L);
    i := 1;
    while i <= L do begin
      Result[i] := S[i];
      if S[i] in {WinGlobal.} LeadBytes then begin
        Inc(i);
        Result[i] := S[i];
      end
      else if Result[i] in ['A'..'Z'] then Inc(Byte(Result[i]), 32);
      Inc(i);
    end;
  end
  else Result := AnsiLowerCase(S);
end;

function AnsiUpperCaseFileName(const S: string): string;
var
  i, L: Integer;
begin
  if {WinGlobal.} SysLocale.FarEast then begin
    L := Length(S);
    SetLength(Result, L);
    i := 1;
    while i <= L do begin
      Result[i] := S[i];
      if S[i] in {WinGlobal.} LeadBytes then begin
        Inc(i);
        Result[i] := S[i];
      end
      else if Result[i] in ['a'..'z'] then Dec(Byte(Result[i]), 32);
      Inc(i);
    end;
  end
  else Result := AnsiUpperCase(S);
end;

function StrLen(const Str: PChar): Cardinal; assembler;
{ StrLen returns the number of characters in Str, not counting the null terminator }
// genuine SysUtils, use only for small string
asm
  mov edx, edi
  mov edi, eax
  mov ecx, 0ffffffffh
  xor al, al
  repne scasb
  mov eax, 0fffffffeh
  sub eax, ecx
  mov edi, edx
end;

function StrPos(const Str1, Str2: PChar): PChar; assembler;
{ StrPos returns a pointer to the first occurrence of Str2 in Str1. If
  Str2 does not occur in Str1, StrPos returns NIL. }
// genuine SysUtils, use only for small string
asm
    push edi; push esi
    push ebx
    or eax, eax
    je @@2
    or edx, edx
    je @@2
    mov ebx, eax
    mov edi, edx
    xor al, al
    mov ecx, 0ffffffffh
    repne scasb
    not ecx
    dec ecx
    je @@2
    mov esi, ecx
    mov edi, ebx
    mov ecx, 0ffffffffh
    repne scasb
    not ecx
    sub ecx, esi
    jbe @@2
    mov edi, ebx
    lea ebx, [esi-1]
  @@1: mov esi, edx
    lodsb
    repne scasb
    jne @@2
    mov eax, ecx
    push edi
    mov ecx, ebx
    repe cmpsb
    pop edi
    mov ecx, eax
    jne @@1
    lea eax, [edi-1]
    jmp @@3
  @@2: xor eax, eax
  @@3: pop ebx
    pop esi; pop edi
end;

function AnsiStrPos(Str, SubStr: PChar): PChar;
var
  L1, L2: Cardinal;
  ByteType: TMbcsByteType;
begin
  Result := nil;
  if (Str = nil) or (Str^ = #0) or (SubStr = nil) or (SubStr^ = #0) then Exit;
  L1 := StrLen(Str);
  L2 := StrLen(SubStr);
  Result := StrPos(Str, SubStr);
  while (Result <> nil) and ((L1 - Cardinal(Result - Str)) >= L2) do
  begin
    ByteType := StrByteType(Str, Integer(Result - Str));
    if (ByteType <> mbTrailByte) and
      (CompareString(LOCALE_USER_DEFAULT, 0, Result, L2, SubStr, L2) = 2) then Exit;
    if (ByteType = mbLeadByte) then Inc(Result);
    Inc(Result);
    Result := StrPos(Result, SubStr);
  end;
  Result := nil;
end;

function AnsiPos(const Substr, S: string): Integer;
var
  P: PChar;
begin
  Result := 0;
  P := AnsiStrPos(PChar(S), PChar(SubStr));
  if P <> nil then
    Result := Integer(P) - Integer(PChar(S)) + 1;
end;

function AnsiCompareFileName(const S1, S2: string): Integer;
begin
  Result := AnsiCompareStr(AnsiLowerCaseFileName(S1), AnsiLowerCaseFileName(S2));
end;

function AnsiStrScan(Str: PChar; Chr: Char): PChar;
begin
  Result := StrScan(Str, Chr);
  while Result <> nil do
  begin
    case StrByteType(Str, Integer(Result - Str)) of
      mbSingleByte: Exit;
      mbLeadByte: Inc(Result);
    end;
    Inc(Result);
    Result := StrScan(Result, Chr);
  end;
end;

function AnsiStrRScan(Str: PChar; Chr: Char): PChar;
begin
  Str := AnsiStrScan(Str, Chr);
  Result := Str;
  if Chr <> #$0 then
  begin
    while Str <> nil do
    begin
      Result := Str;
      Inc(Str);
      Str := AnsiStrScan(Str, Chr);
    end;
  end
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
      Inc(i, 2);
    end;
  end;
end;



end.


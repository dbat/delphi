{$WEAKPACKAGEUNIT ON}
unit AHSeek;

interface

type
  TFastStr = class(Tobject)
  private
    fFound: longbool;
    fString, fSubStr: string;
    fCurrentPos, fCount: integer;
    fStrLen, fSubStrLen, fLimit, fOutRange: integer;
    iCaseTable: array[char] of char;
    IndexTable: array[char] of integer;
    procedure makelocase; register;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Init(const SubStr: string; const IgnoreCase: Boolean = FALSE); overload;
    procedure Init(const SubStr: string; const S: string; const IgnoreCase: Boolean = FALSE); overload;
    function Pos(const S: string; const StartPos: integer = 1): integer;
    function FindFirst(const StartPos: integer = 1): integer; overload;
    function FindFirst(const S: string; const StartPos: integer = 1): integer; overload;
    function FindNext: integer;
    function WordIndex(const S: string; const IndexTable: integer = 1; const StartPos: integer = 1): integer;
    function WordCount(const S: string; const StartIndex: integer = 1; const StartPos: integer = 1): integer;
    function iPos(const Str: string; const StartPos: integer = 1): integer;
    function iFindFirst(const StartPos: integer = 1): integer; overload;
    function iFindFirst(const S: string; const StartPos: integer = 1): integer; overload;
    function iFindNext: integer;
    function iWordIndex(const S: string; const IndexTable: integer = 1; const StartPos: integer = 1): integer;
    function iWordCount(const S: string; const StartIndex: integer = 1; const StartPos: integer = 1): integer;
  public
    property Count: integer read fCount;
    property Position: integer read fCurrentPos;
    property Found: longbool read fFound;
  end;

implementation

constructor TFastStr.Create;
begin
  inherited Create;
  fSubStr := ''; fString := '';
  fStrLen := 0; fSubStrLen := 0;
  fLimit := 0; fOutRange := 0;
  fCurrentPos := 0; fCount := 0; fFound := FALSE;
  makelocase;
end;

destructor TFastStr.Destroy;
begin
  inherited Destroy;
end;

//procedure TFastStr.makeup; var i: byte; // nice but slower
//type
//  TSysCharset = set of char;
//const
//  CHARCASEBIT = 5;
//  GREEK_UPCASECHARS = [#$C0..#$DF]; // you may set set this as empty []
//  GREEK_IGNORECASE = [#$C0..#$FF]; // if greek characters doesn't count
//  UPCASECHARS: TSysCharSet = ['A'..'Z'] + GREEK_UPCASECHARS;
//asm
//  @@Start:
//    mov ecx, 100H -1
//    mov edx, eax
//  @Loop:
//    mov byte ptr edx.iCaseTable[ecx], cl
//    bt dword ptr [UPCASECHARS], cl
//    jnb @goon
//    mov eax, ecx
//    btc eax, CHARCASEBIT
//    mov byte ptr edx.iCaseTable[eax], cl
//    @goon:
//    dec ecx
//    jge @Loop
//  @@Stop:
//end;
//

procedure TFastStr.makelocase; // ugly but faster
asm
  @@Start:
    mov edx, eax
    xor eax, eax
    mov ecx, eax

   mov cl, 'Z' - 'A'
  @LoopA:
    lea eax, ecx + 'A' + 20H
    mov byte ptr edx.iCaseTable[eax], al
    mov byte ptr edx.iCaseTable[eax  -20H], al
    dec cl
    jge @LoopA

    mov cl, 0E0H
  @LoopGreek:
    mov eax, ecx
    mov byte ptr edx.iCaseTable[eax], al
    mov byte ptr edx.iCaseTable[eax -20H], al
    inc cl
    ja @LoopGreek

  @fillblank:
    mov cl, 'A'
  @Loop1:
    dec cx
    mov byte ptr edx.iCaseTable[ecx], cl
    jg @Loop1

    mov cl, 'a' - 'Z' -1
   @Loop2:
    lea eax, ecx + 'Z'
    mov byte ptr edx.iCaseTable[eax], al
    dec cl
    jg @Loop2

    mov cl, 0C0H - 'z' -1
   @Loop3:
    lea eax, ecx + 'z'
    mov byte ptr edx.iCaseTable[eax], al
    dec ecx
    jg @Loop3

  @@Stop:
end;

procedure TFastStr.Init(const SubStr: string; {const S: string = ''; } const IgnoreCase: Boolean = FALSE); //overload;
var
  i: integer;
  Ch: char;
begin
  fSubStr := SubStr; fSubStrLen := Length(fSubStr);
  fOutRange := fSubStrLen + 1;
  fLimit := fSubStrLen div 2;
  for ch := #0 to #255 do
    IndexTable[Ch] := fOutRange;
  if not IgnoreCase then begin
    for i := 1 to fSubStrLen do
      IndexTable[fSubStr[i]] := fOutRange - i;
  end
  else begin
    for i := 1 to fSubStrLen do
      IndexTable[iCaseTable[fSubStr[i]]] := fOutRange - i;
  end;
end;

procedure TFastStr.Init(const SubStr: string; const S: string; const IgnoreCase: Boolean = FALSE);
begin
  fString := S; fStrLen := length(fString);
  Init(SubStr, IgnoreCase);
end;

function TFastStr.FindFirst(const StartPos: integer = 1): integer;
begin
  Result := 0; fCount := 0; fFound := FALSE;
  //fStrLen := Length(fString);
  fCurrentPos := StartPos - 1;
  if fStrLen - StartPos >= fSubStrLen then begin
    fCurrentPos := StartPos - 1;
    Result := FindNext;
  end;
end;

function TFastStr.FindFirst(const S: string; const StartPos: integer = 1): integer;
begin
  fString := S; fStrLen := Length(fString);
  Result := FindFirst(StartPos);
end;

function TFastStr.FindNext: integer;
var
  i, j, k: integer;
  //fStrLen: integer;
begin
  Result := 0; fFound := FALSE;
  k := fCurrentPos;
  fCurrentPos := 0;
  //fStrLen := Self.fStrLen;
  inc(k, fSubStrLen);
  while k <= fStrLen do begin
    //i := fSubStrLen;
    if (fSubStr[fSubStrLen] <> fString[k]) then
      inc(k, IndexTable[fString[k + 1]])
    else begin
      i := fSubStrLen;
      j := k;
      repeat dec(i);
        dec(j);
      until (i = 0) or (fSubStr[i] <> fString[j]);
      if i = 0 then begin
        fFound := TRUE;
        inc(Self.fCount);
        Result := k + fSubStrLen + 1;
        Self.fCurrentPos := Result;
        break;
      end
      else if (i < fLimit) then
        inc(k, fOutRange)
      else
        inc(k, IndexTable[fString[j + 1]]);
    end;
  end;
end;

function TFastStr.Pos(const S: string; const StartPos: integer = 1): integer;
var
  i, j, k: integer;
  fStrLen: integer;
begin
  Result := 0;
  fStrLen := Length(S);
  if fStrLen - StartPos >= fSubStrLen then begin
    k := StartPos - 1;
    inc(k, fSubStrLen);
    while k <= {length(S) } fStrLen do begin
      //i := fSubStrLen;
      if (fSubStr[fSubStrLen] <> S[k]) then
        inc(k, IndexTable[S[k + 1]])
      else begin
        i := fSubStrLen;
        j := k;
        repeat dec(i); dec(j);
        until (i = 0) or (fSubStr[i] <> S[j]);
        if i = 0 then begin
          Result := k - fSubStrLen + 1;
          break;
        end
        else if (i < fLimit) then
          inc(k, fOutRange)
        else
          inc(k, IndexTable[S[j + 1]]);
      end;
    end;
  end;
end;

function TFastStr.WordIndex(const S: string; const IndexTable: integer = 1; const StartPos: integer = 1): integer;
begin
  Result := FindFirst(S, StartPos);
  if Result > 0 then
    while fFound and (fCount < IndexTable) do
      Result := FindNext
end;

function TFastStr.WordCount(const S: string; const StartIndex: integer = 1; const StartPos: integer = 1): integer;
begin
  fCount := 0;
  if FindFirst(S, StartPos) > 0 then
    repeat until FindNext < 1;
  Result := fCount;
end;

function TFastStr.iFindFirst(const StartPos: integer = 1): integer;
begin
  Result := 0; fCount := 0; fFound := FALSE;
  fCurrentPos := StartPos - 1;
  if fStrLen - StartPos >= fSubStrLen then begin
    fCurrentPos := StartPos - 1;
    Result := iFindNext;
  end;
end;

function TFastStr.iFindFirst(const S: string; const StartPos: integer = 1): integer;
begin
  fString := S; fStrLen := Length(fString);
  Result := iFindFirst(StartPos);
end;

function TFastStr.iFindNext: integer;
var
  i, j, k: integer;
  //fStrLen: integer;
begin
  Result := 0; fFound := FALSE;
  k := fCurrentPos; fCurrentPos := 0;
  //fStrLen := Self.fStrLen;
  inc(k, fSubStrLen);
  while k <= fStrLen do begin
    //i := fSubStrLen;
    if (iCaseTable[fSubStr[fSubStrLen]] <> iCaseTable[fString[k]]) then
      //inc(k, IndexTable[iCaseTable[Text[k + 1]]])
      inc(k, IndexTable[iCaseTable[fString[k + 1]]])
    else begin
      i := fSubStrLen;
      j := k;
      repeat dec(i);
        dec(j);
      until (i = 0) or (iCaseTable[fSubStr[i]] <> iCaseTable[fString[j]]);
      if i = 0 then begin
        fFound := TRUE;
        inc(Self.fCount);
        Result := k - fSubStrLen + 1;
        Self.fCurrentPos := Result;
        break;
      end
      else if i < fLimit then
        inc(k, fOutRange)
      else
        inc(k, IndexTable[iCaseTable[fString[j + 1]]]);
    end;
  end;
end;

function TFastStr.iWordIndex(const S: string; const IndexTable: integer = 1; const StartPos: integer = 1): integer;
begin
  Result := iFindFirst(S, StartPos);
  if Result > 0 then
    while fFound and (fCount < IndexTable) do
      Result := iFindNext
end;

function TFastStr.iWordCount(const S: string; const StartIndex: integer = 1; const StartPos: integer = 1): integer;
begin
  fCount := 0;
  if iFindFirst(S, StartPos) > 0 then
    repeat until iFindNext < 1;
  Result := fCount;
end;

function TFastStr.iPos(const Str: string; const StartPos: integer = 1): integer;
var
  i, j, k: integer;
  fStrLen: integer;
begin
  Result := 0;
  fStrLen := Length(Str);
  if fStrLen - StartPos >= fSubStrLen then begin
    k := StartPos - 1;
    inc(k, fSubStrLen);
    while k <= fStrLen do begin
      i := fSubStrLen;
      if (iCaseTable[fSubStr[i]] <> iCaseTable[Str[k]]) then
        inc(k, IndexTable[iCaseTable[Str[k + 1]]])
      else begin
        j := k;
        repeat
          dec(i);
          dec(j);
        until (i = 0) or (iCaseTable[fSubStr[i]] <> iCaseTable[Str[j]]);
        if i = 0 then begin
          Result := k - fSubStrLen + 1;
          break;
        end
        else if (i < fLimit) then
          inc(k, fOutRange)
        else
          inc(k, IndexTable[iCaseTable[Str[j + 1]]]);
      end;
    end;
  end;
end;

end.


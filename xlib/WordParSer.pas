unit wordparser;


interface

uses SysUtils;

function WordCount(const S: string; const Delimiters: TSysCharSet): integer; overload
function DelimitersCount(const S: string; const Delimiters: TSysCharSet): integer; overload;
{ WordCount given a set of word delimiters, returns number of words in S. }

function WordCount(const S: string; const Delimiter: Char): integer; overload;
function DelimitersCount(const S: string; const Delimiter: Char): integer; overload;

function WordPosition(const n: integer; const S: string; const Delimiters: TSysCharSet): integer; overload;
function WordPosition(const n: integer; const S: string; const Delimiter: Char): integer; overload;
{ Given a set of word delimiters, returns start position of N'th word in S. }

function ExtractWord(n: integer; const S: string; const Delimiters: TSysCharSet): string; overload;
function ExtractWordPos(n: integer; const S: string; const Delimiters: TSysCharSet; var Pos: integer): string; overload;
{ ExtractWord, ExtractWordPos and ExtractDelimited given a set of word
  delimiters, return the N'th word in S. }
function ExtractWord(n: integer; const S: string; const Delimiter: Char): string; overload;
function ExtractWordPos(n: integer; const S: string; const Delimiter: Char; var GotPos: integer): string; overload;

implementation


function WordCount(const S: string; const Delimiters: TSysCharSet): integer;
var
  SLen, I: Cardinal;
begin
  Result := 0;
  I := 1;
  SLen := Length(S);
  while I <= SLen do begin
    while (I <= SLen) and (S[I] in Delimiters) do
      Inc(I);
    if I <= SLen then Inc(Result);
    while (I <= SLen) and not (S[I] in Delimiters) do
      Inc(I);
  end;
end;

function DelimitersCount(const S: string; const Delimiters: TSysCharSet): integer;
var
  I: Cardinal;
begin
  Result := 0;
  for i := 1 to length(S) do
    if S[I] in Delimiters then
      inc(Result)
end;

function WordCount(const S: string; const Delimiter: Char): integer;
var
  SLen, I: Cardinal;
begin
  Result := 0;
  I := 1;
  SLen := Length(S);
  while I <= SLen do begin
    while (I <= SLen) and (S[I] = Delimiter) do
      Inc(I);
    if I <= SLen then Inc(Result);
    while (I <= SLen) and (S[I] <> Delimiter) do
      Inc(I);
  end;
end;

function DelimitersCount(const S: string; const Delimiter: Char): integer;
var
  I: Cardinal;
begin
  Result := 0;
  for i := 1 to length(S) do
    if S[I] = Delimiter then
      inc(Result)
end;

function WordPosition(const n: integer; const S: string;  const Delimiters: TSysCharSet): integer;
var
  Count, I: integer;
begin
  Count := 0;
  I := 1;
  Result := 0;
  while (I <= Length(S)) and (Count <> n) do begin
    { skip over delimiters }
    while (I <= Length(S)) and (S[I] in Delimiters) do
      Inc(I);
    { if we're not beyond end of S, we're at the start of a word }
    if I <= Length(S) then Inc(Count);
    { if not finished, find the end of the current word }
    if Count <> n then
      while (I <= Length(S)) and not (S[I] in Delimiters) do
        Inc(I)
    else
      Result := I;
  end;
end;

function WordPosition(const n: integer; const S: string; const Delimiter: Char): integer;
var
  Count, I: integer;
begin
  Count := 0;
  I := 1;
  Result := 0;
  while (I <= Length(S)) and (Count <> n) do begin
    { skip over delimiters }
    while (I <= Length(S)) and (S[I] = Delimiter) do
      Inc(I);
    { if we're not beyond end of S, we're at the start of a word }
    if I <= Length(S) then Inc(Count);
    { if not finished, find the end of the current word }
    if Count <> n then
      while (I <= Length(S)) and (S[I] <> Delimiter) do
        Inc(I)
    else
      Result := I;
  end;
end;

function ExtractWord(n: integer; const S: string;
  const Delimiters: TSysCharSet): string;
var
  I: integer;
  Len: integer;
begin
  Len := 0;
  I := WordPosition(n, S, Delimiters);
  if I <> 0 then
    { find the end of the current word }
    while (I <= Length(S)) and not (S[I] in Delimiters) do begin
      { add the I'th character to result }
      Inc(Len);
      SetLength(Result, Len);
      Result[Len] := S[I];
      Inc(I);
    end;
  SetLength(Result, Len);
end;

function ExtractWord(n: integer; const S: string; const Delimiter: Char): string;
var
  I: integer;
  Len: integer;
begin
  Len := 0;
  I := WordPosition(n, S, Delimiter);
  if I <> 0 then
    { find the end of the current word }
    while (I <= Length(S)) and (S[I] <> Delimiter) do begin
      { add the I'th character to result }
      Inc(Len);
      SetLength(Result, Len);
      Result[Len] := S[I];
      Inc(I);
    end;
  SetLength(Result, Len);
end;

function ExtractWordPos(n: integer; const S: string; const Delimiters: TSysCharSet; var Pos: integer): string;
var
  I, Len: integer;
begin
  Len := 0;
  I := WordPosition(n, S, Delimiters);
  Pos := I;
  if I <> 0 then
    { find the end of the current word }
    while (I <= Length(S)) and not (S[I] in Delimiters) do begin
      { add the I'th character to result }
      Inc(Len);
      SetLength(Result, Len);
      Result[Len] := S[I];
      Inc(I);
    end;
  SetLength(Result, Len);
end;

function ExtractWordPos(n: integer; const S: string; const Delimiter: Char; var GotPos: integer): string;
var
  I, Len: integer;
begin
  Len := 0;
  I := WordPosition(n, S, Delimiter);
  GotPos := I;
  if I <> 0 then
    { find the end of the current word }
    while (I <= Length(S)) and (S[I] <> Delimiter) do begin
      { add the I'th character to result }
      Inc(Len);
      SetLength(Result, Len);
      Result[Len] := S[I];
      Inc(I);
    end;
  SetLength(Result, Len);
end;


end.

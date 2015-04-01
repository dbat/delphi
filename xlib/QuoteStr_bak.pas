unit quotestr_bak;

interface
type
  TSysCharSet = set of Char;

const
  DEFAULT_ESCAPECHAR = '\';
  DEFAULT_SINGELQUOTE = '''';
  DEFAULT_DOUBLEQUOTE = '"';
  DEFAULT_WHITESPACES = [' ', #9];

function StripDoubleQuotes(const DoubleQuotedStr: string; const FirstPairOnly: Boolean = FALSE;
  const EscapeChar: Char = DEFAULT_ESCAPECHAR; const DoubleQuoteChar: Char = DEFAULT_DOUBLEQUOTE): string;

//function GetEndPosDblQuotedWhitespaced(const S: string; const StartPos: integer = 1;
//  const EscapeChar: Char = DEFAULT_ESCAPECHAR; const DoubleQuoteChar: Char = DEFAULT_DOUBLEQUOTE;
//  const WhiteSpaces: TSysCharSet = DEFAULT_WHITESPACES): integer;
//note. this function will skip prepending whitespaces,

function ExtractDblQuotedStr(const DoubleQuotedStr: string; BlockPhraseToGet: integer = 1;
  const StripDblQuotesPairs: Boolean = FALSE; const StripFirstPairOnly: Boolean = FALSE;
  const EscapeChar: Char = DEFAULT_ESCAPECHAR; const DoubleQuoteChar: Char = DEFAULT_DOUBLEQUOTE;
  const WhiteSpaces: TSysCharset = DEFAULT_WHITESPACES): string;

function Interpret(const SourceStr: string; const EscapeChar: Char = DEFAULT_ESCAPECHAR): string;
//interprets escaped expression of char, currently applied to:
//  \xNumber     ordinal number of char (hex string)
//  \Number      ordinal number of char (decimal string)
//  \Char        The char itself (must not be a number, respectively)

function CountDblQuotedStr(const DoubleQuotedStr: string; //BlockPosToGet: integer = 1;
  const StripDblQuotesPairs: Boolean = FALSE; const StripFirstPairOnly: Boolean = FALSE;
  const EscapeChar: Char = DEFAULT_ESCAPECHAR; const DoubleQuoteChar: Char = DEFAULT_DOUBLEQUOTE;
  const WhiteSpaces: TSysCharset = DEFAULT_WHITESPACES): integer;

implementation
const
  YES = TRUE;

function StripDoubleQuotes(const DoubleQuotedStr: string; const FirstPairOnly: Boolean = FALSE;
  const EscapeChar: Char = DEFAULT_ESCAPECHAR; const DoubleQuoteChar: Char = DEFAULT_DOUBLEQUOTE): string;
var
  i, j, offset: integer;
  escaped: boolean;
  indbq: Boolean;
begin
  Result := DoubleQuotedStr;
  if length(DoubleQuotedStr) > 1 then begin
    escaped := FALSE;
    indbq := FALSE;
    //i := 1;
    j := length(DoubleQuotedStr);
    offset := 0;
    for i := 1 to j do begin
      if (EscapeChar <> #0) then begin
        if DoubleQuotedStr[i] = EscapeChar then begin
          escaped := not escaped;
          continue;
        end
        else if escaped then begin
          escaped := FALSE;
          continue;
        end;
      end;

      if (DoubleQuotedStr[i] = DoubleQuoteChar) then begin
        if not indbq then begin
          indbq := TRUE;
          delete(Result, i - offset, 1);
          inc(offset);
          if length(Result) < 1 then break;
        end
        else begin
          if (i > 1) then begin
            indbq := FALSE;
            delete(Result, i - offset, 1);
            inc(offset);
          end;
          if FirstPairOnly or (length(Result) < 1) then break;
        end;
      end;
    end;
  end;
end;

function GetEndPosDblQuotedWhitespaced(const S: string; const StartPos: integer = 1;
  const EscapeChar: Char = DEFAULT_ESCAPECHAR; const DoubleQuoteChar: Char = DEFAULT_DOUBLEQUOTE;
  const WhiteSpaces: TSysCharSet = DEFAULT_WHITESPACES): integer;
//note. this function will skip prepending whitespaces,
var
  i: integer;
  escaped: boolean;
  insq: Boolean;
  indbq: Boolean;
begin
  Result := 0;
  if length(S) > 0 then begin
    escaped := FALSE;
    indbq := FALSE;
    insq := FALSE;
    //i := StartPos;
    //while S[i] in WhiteSpaces do
    //  inc(i);
    //for i := i to length(S) do begin

    for i := StartPos to length(S) do begin

      if S[i] = '''' then
        insq := not insq;

      if (EscapeChar <> #0) then begin
        if S[i] = EscapeChar then begin
          escaped := not escaped;
          continue;
        end
        else if escaped then begin
          escaped := FALSE;
          continue;
        end;
      end;

      if (S[i] = DoubleQuoteChar) then indbq := not indbq;

      if (S[i] in WhiteSpaces) and not indbq then begin
        Result := i;
        break;
      end;
    end;
  end;
end;

function CountDblQuotedStr(const DoubleQuotedStr: string; //BlockPosToGet: integer = 1;
  const StripDblQuotesPairs: Boolean = FALSE; const StripFirstPairOnly: Boolean = FALSE;
  const EscapeChar: Char = DEFAULT_ESCAPECHAR; const DoubleQuoteChar: Char = DEFAULT_DOUBLEQUOTE;
  const WhiteSpaces: TSysCharset = DEFAULT_WHITESPACES): integer;
var
  i: integer;
begin
  Result := 0; i := 0;
  while (i < Length(DoubleQuotedStr)) and (DoubleQuotedStr[i + 1] in WhiteSpaces) do
    inc(i);
  if i < Length(DoubleQuotedStr) then
    repeat
      inc(Result);
      i := GetEndPosDblQuotedWhitespaced(DoubleQuotedStr, i + 1, EscapeChar, DoubleQuoteChar, WhiteSpaces);
      while (i < Length(DoubleQuotedStr)) and (DoubleQuotedStr[i + 1] in WhiteSpaces) do
        inc(i);
    until i < 1;
end;

function ExtractDblQuotedStr(const DoubleQuotedStr: string; BlockPhraseToGet: integer = 1;
  const StripDblQuotesPairs: Boolean = FALSE; const StripFirstPairOnly: Boolean = FALSE;
  const EscapeChar: Char = DEFAULT_ESCAPECHAR; const DoubleQuoteChar: Char = DEFAULT_DOUBLEQUOTE;
  const WhiteSpaces: TSysCharset = DEFAULT_WHITESPACES): string;
var
  i, k, t: integer;
begin
  Result := '';
  if BlockPhraseToGet > 0 then begin
    k := 0; t := 1;
    repeat
      inc(k);
      i := GetEndPosDblQuotedWhitespaced(DoubleQuotedStr, t, EscapeChar, DoubleQuoteChar, WhiteSpaces);
      if (i > 0) then begin
        if (k = BlockPhraseToGet) then begin
          Result := Copy(DoubleQuotedStr, t, i - t);
          break;
        end;
        while (i < Length(DoubleQuotedStr)) and (DoubleQuotedStr[i + 1] in WhiteSpaces) do
          inc(i);
        t := i + 1;
      end
      else if k = BlockPhraseToGet then
        Result := Copy(DoubleQuotedStr, t, length(DoubleQuotedStr));
    until (k = BlockPhraseToGet) or (i < 1);
  end;
  if StripDblQuotesPairs then
    Result := StripDoubleQuotes(Result, StripFirstPairOnly, EscapeChar, DoubleQuoteChar)
end;

function Interpret(const SourceStr: string; const EscapeChar: Char = DEFAULT_ESCAPECHAR): string;
{$IFOPT R+}
{$DEFINE R_ACTIVE}
{$R-}
{$ENDIF}
  function StrToIntDef0(Number: string; const NumIsHex: Boolean = FALSE): integer;
  var
    ErrCode: integer;
  begin
    if NumIsHex then
      Number := '$0' + Number;
    Val(Number, Result, ErrCode);
    if ErrCode <> 0 then Result := 0;
  end;
{$IFDEF R_ACTIVE}
{$R+}
{$UNDEF R_ACTIVE}
{$ENDIF}

const
  DIGITS_DEC = ['0'..'9'];
  DIGITS_HEX = DIGITS_DEC + ['A'..'F', 'a'..'f'];
var
  sn: string;
  i, n: integer;
begin
  Result := SourceStr;
  i := 0;
  repeat
    if (i >= length(Result)) then break;
    inc(i);
    if (Result[i] = EscapeChar) then begin
      if length(Result) > i then begin
        delete(Result, i, 1);
        case Result[i] of
          'x', 'X':
            if length(Result) > i then begin
              delete(Result, i, 1);
              sn := '';
              //WRONG-ORDER!! and (Result[i] in BQH) and (length(Result) >= i) do begin
              while (length(Result) >= i) and (Result[i] in DIGITS_HEX) do begin
                if strtointDef0(sn + Result[i], YES) > high(byte) then break;
                sn := sn + Result[i];
                delete(Result, i, 1);
              end;
              n := StrToIntDef0(sn, YES);
              insert(Char(n), Result, i);
            end;
          '0'..'9': begin
              sn := '';
              //WRONG_ORDER!! while (Result[i] in BQN) and (length(Result) >= i) do begin
              while (length(Result) >= i) and (Result[i] in DIGITS_DEC) do begin
                if strtointDef0(sn + Result[i]) > high(byte) then break;
                sn := sn + Result[i];
                delete(Result, i, 1);
              end;
              n := strtointDef0(sn);
              insert(Char(n), Result, i);
            end;
          else //case;
        end;
      end;
    end;
  until i >= length(Result);
end;

end.


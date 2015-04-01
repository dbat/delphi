unit QuoteStr;
{.$WEAKPACKAGEUNIT ON}
{$J-}                                   //no-writeableconst
{$R-}                                   //no-rangechecking
{$Q-}                                   //no-overflowchecking
{.$D-}//no-debug
{
  unit quoted-string/command-line parser & interpreter
  version: 1.0.0.1
  date: 2004-10-24
  rev1: 2004-11-06
  rev2: 2005-05-07 (limit escaped hex to 2 chars and dec to 3 chars to avoid common ambiguities 


}
{
  Copyright (c) 2004, aa, Adrian H., Ray AF. & Inge DR.
  Property of PT SOFTINDO Jakarta.
  All rights reserved.

  mailto:aa|AT|softindo|DOT|net,
  http://delphi.softindo.net
}
interface
type
  TSysCharSet = set of Char;
  TQuoteStyle = (qsDefault, qsDOS, qsUNIX);
  //                    qsDefault       qsDOS         qsUNIX
  // ESCAPECHAR           \              NULL             \
  // SINGLEQUOTE          NULL           NULL             '
  // DOUBLEQUOTE          "              "              "
  // WHITESPACES        [' ', #9]      [' ', #9]      [' ', #9]

const
  DEFAULT_ESCAPECHAR = '\';
  DEFAULT_SINGLEQUOTE = #0;
  DEFAULT_DOUBLEQUOTE = '"';
  DEFAULT_WHITESPACES = [' ', #9];
  DEFAULT_ESCAPECHAR_DOS = #0;
  DEFAULT_SINGLEQUOTE_UNIX = '''';

function StripDoubleQuotes(const DoubleQuotedStr: string;
  const FirstPairOnly: Boolean = FALSE;
  const EscapeChar: Char = DEFAULT_ESCAPECHAR;
  const SingleQuoteChar: Char = DEFAULT_SINGLEQUOTE;
  const DoubleQuoteChar: Char = DEFAULT_DOUBLEQUOTE): string;
// note StripDoubleQuotes usually applied through the whole arguments
// of the single command line at once, thus it may give different result
// if applied to partially/extracted argument one by one

//function GetEndPosDblQuotedWhitespaced(const S: string; const StartPos: integer = 1;
//  const EscapeChar: Char = DEFAULT_ESCAPECHAR; const DoubleQuoteChar: Char = DEFAULT_DOUBLEQUOTE;
//  const WhiteSpaces: TSysCharSet = DEFAULT_WHITESPACES): integer;
//note. this function will not skip prepending whitespaces,

function ExtractDblQuotedStr(const DoubleQuotedStr: string;
  const BlockPhraseToGet: integer = 1;
  const StripDblQuotesPairs: Boolean = TRUE;
  const StripFirstPairOnly: Boolean = FALSE;
  const EscapeChar: Char = DEFAULT_ESCAPECHAR;
  const SingleQuoteChar: Char = DEFAULT_SINGLEQUOTE;
  const DoubleQuoteChar: Char = DEFAULT_DOUBLEQUOTE;
  const WhiteSpaces: TSysCharset = DEFAULT_WHITESPACES): string; overload;

function ExtractDblQuotedStr(const DoubleQuotedStr: string;
  const BlockPhraseToGet: integer = 1;
  const QuoteStyle: TQuoteStyle = qsDefault;
  const StripDblQuotesPairs: Boolean = TRUE;
  const StripFirstPairOnly: Boolean = FALSE): string; overload;

function CountDblQuotedStr(const DoubleQuotedStr: string;
  const EscapeChar: Char = DEFAULT_ESCAPECHAR;
  const SingleQuoteChar: Char = DEFAULT_SINGLEQUOTE;
  const DoubleQuoteChar: Char = DEFAULT_DOUBLEQUOTE;
  const WhiteSpaces: TSysCharset = DEFAULT_WHITESPACES): integer; overload;

function CountDblQuotedStr(const DoubleQuotedStr: string;
  const QuoteStyle: TQuoteStyle = qsDefault): integer; overload;

function Interpret(const SourceStr: string; const SingleQuoteChar: Char = DEFAULT_SINGLEQUOTE;
  const EscapeChar: Char = DEFAULT_ESCAPECHAR): string; overload;
//interprets escaped expression of char, currently applied to:
//  \xNumber     ordinal number of char (hex string)
//  \Number      ordinal number of char (decimal string)
//  \Char        The char itself (must not be a number, respectively)

implementation
const
  YES = TRUE;

function StripDoubleQuotes(const DoubleQuotedStr: string; const FirstPairOnly: Boolean = FALSE;
  const EscapeChar: Char = DEFAULT_ESCAPECHAR; const SingleQuoteChar: Char = DEFAULT_SINGLEQUOTE;
  const DoubleQuoteChar: Char = DEFAULT_DOUBLEQUOTE): string;
var
  i, j, offset: integer;
  escaped: boolean;
  insq: Boolean;
  indbq: Boolean;
begin
  Result := DoubleQuotedStr;
  if length(DoubleQuotedStr) > 1 then begin
    escaped := FALSE;
    indbq := FALSE;
    insq := FALSE;
    //i := 1;
    j := length(DoubleQuotedStr);
    offset := 0;
    for i := 1 to j do begin

      if (DoubleQuotedStr[i] = SingleQuoteChar) and (SingleQuoteChar <> #0) then
        insq := not insq;

      if insq then continue;

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
  const SingleQuoteChar: Char = DEFAULT_SINGLEQUOTE;
  const WhiteSpaces: TSysCharSet = DEFAULT_WHITESPACES): integer;
//note. this function will not skip prepending whitespaces,
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

      if (S[i] = SingleQuoteChar) and (SingleQuoteChar <> #0) then
        insq := not insq;

      if insq then continue;

      if (EscapeChar <> #0) then begin
        if (S[i] = EscapeChar) then begin
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
  const EscapeChar: Char = DEFAULT_ESCAPECHAR;
  const SingleQuoteChar: Char = DEFAULT_SINGLEQUOTE;
  const DoubleQuoteChar: Char = DEFAULT_DOUBLEQUOTE;
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
      i := GetEndPosDblQuotedWhitespaced(DoubleQuotedStr, i + 1,
        EscapeChar, DoubleQuoteChar, SingleQuoteChar, WhiteSpaces);
      if (i > 0) then                   //DO NOT REMOVE THIS!
        while (i < Length(DoubleQuotedStr)) and (DoubleQuotedStr[i + 1] in WhiteSpaces) do
          inc(i);
    until i < 1;
end;

function ExtractDblQuotedStr(const DoubleQuotedStr: string;
  const BlockPhraseToGet: integer = 1;
  const StripDblQuotesPairs: Boolean = TRUE;
  const StripFirstPairOnly: Boolean = FALSE;
  const EscapeChar: Char = DEFAULT_ESCAPECHAR;
  const SingleQuoteChar: Char = DEFAULT_SINGLEQUOTE;
  const DoubleQuoteChar: Char = DEFAULT_DOUBLEQUOTE;
  const WhiteSpaces: TSysCharset = DEFAULT_WHITESPACES): string;
var
  i, k, t: integer;
begin
  Result := '';
  if BlockPhraseToGet > 0 then begin
    k := 0; t := 1;
    repeat
      inc(k);
      i := GetEndPosDblQuotedWhitespaced(DoubleQuotedStr, t,
        EscapeChar, DoubleQuoteChar, SingleQuoteChar, WhiteSpaces);
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
    Result := StripDoubleQuotes(Result, StripFirstPairOnly, EscapeChar, SingleQuoteChar, DoubleQuoteChar)
end;

// WRAPPER

function CountDblQuotedStr(const DoubleQuotedStr: string; //BlockPosToGet: integer = 1;
  const QuoteStyle: TQuoteStyle = qsDefault): integer; overload;
var
  Escape, SQuote: Char;
begin
  Escape := DEFAULT_ESCAPECHAR;
  SQuote := DEFAULT_SINGLEQUOTE;
  case QuoteStyle of
    qsDOS: Escape := DEFAULT_ESCAPECHAR_DOS;
    qsUNIX: SQuote := DEFAULT_SINGLEQUOTE_UNIX;
  end;
  Result := CountDblQuotedStr(DoubleQuotedStr, Escape, SQuote, DEFAULT_DOUBLEQUOTE)
end;

function ExtractDblQuotedStr(const DoubleQuotedStr: string;
  const BlockPhraseToGet: integer = 1;
  const QuoteStyle: TQuoteStyle = qsDefault;
  const StripDblQuotesPairs: Boolean = TRUE;
  const StripFirstPairOnly: Boolean = FALSE): string; overload;
var
  Escape, SQuote: Char;
begin
  Escape := DEFAULT_ESCAPECHAR;
  SQuote := DEFAULT_SINGLEQUOTE;
  case QuoteStyle of
    qsDOS: Escape := DEFAULT_ESCAPECHAR_DOS;
    qsUNIX: SQuote := DEFAULT_SINGLEQUOTE_UNIX;
  end;
  Result := ExtractDblQuotedStr(DoubleQuotedStr, BlockPhraseToGet, StripDblQuotesPairs,
    StripFirstPairOnly, Escape, SQuote, DEFAULT_DOUBLEQUOTE);
end;

// IMPLEMENTATION

function Interpret(const SourceStr: string; const SingleQuoteChar: Char = DEFAULT_SINGLEQUOTE;
  const EscapeChar: Char = DEFAULT_ESCAPECHAR): string; overload;
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
  inquote: Boolean;
begin
  Result := SourceStr;
  i := 1; inquote := FALSE;
  repeat
    if (i > length(Result)) then break;
    if (Result[i] = SingleQuoteChar) and (SingleQuoteChar <> #0) then begin
      //inquote := not (inquote);
      //delete(Result, i, 1);

     // remove all consecutive single-quote pairs
      while (i <= length(Result)) and (Result[i] = SingleQuoteChar) do begin
        inquote := not inquote;
        if not inquote or (i < length(Result)) then
          delete(Result, i, 1)
        else
          inc(i);
      end;
    end;
    if (i > length(Result)) then break;
    if (Result[i] = EscapeChar) and not inquote then begin
      if length(Result) > i then begin
        delete(Result, i, 1);
        case Result[i] of
          'x', 'X':
            if (length(Result) > i) and (Result[i + 1] in DIGITS_HEX) then begin
              delete(Result, i, 1);
              sn := '';
              //WRONG-ORDER!! and (Result[i] in BQH) and (length(Result) >= i) do begin
              //while (length(Result) >= i) and (Result[i] in DIGITS_HEX) do begin
              while (length(Result) >= i) and (Result[i] in DIGITS_HEX) and (length(sn) < 2) do begin
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
              //while (length(Result) >= i) and (Result[i] in DIGITS_DEC) do begin
              while (length(Result) >= i) and (Result[i] in DIGITS_DEC) and (length(sn) < 3) do begin
                if strtointDef0(sn + Result[i]) > high(byte) then break;
                sn := sn + Result[i];
                delete(Result, i, 1);
              end;
              n := strtointDef0(sn);
              insert(Char(n), Result, i);
            end;
        else                            //case;
        end;
      end;
    end;
    inc(i);
  until i > length(Result);
end;

end.


unit ChposK;

interface
type

  TCharSet = set of char;
  TCharsetIndexTable = packed array[char] of integer; // CXGlobal

  //TCharClass = (chClassCntrl, chClassBlank, chClassDigit, chClassUpper, chClassLower, chClassPunct,
  //  chClassSpace, chClassAlpha, chClassAlNum, chClassPrint, chClassGraph, chClassxDigit);

  //sorted alphabetically instead... (except custom)
  TCharsetClass = (chsAlNum, chsAlpha, chsBlank, chsCntrl, chsDigit, chsGraph,
    chsLower, chsPrint, chsPunct, chsSpace, chsUpper, chsXDigit,
    //Custom charsets - currently all equal with alphanum
    chsCntrlSpace, chsHiBitSet, chsMath1, chsMath2 // fold upto 16 elements
    );

const
  TAB = ^i; //CR_ = ^j; VT_ = ^k; FF_ = ^l;
  LF_ = ^m;
  SPACE = ' ';

  DEFAULT_CHARSET_CNTRL = [low(char)..pred(SPACE)];
  DEFAULT_CHARSET_BLANK = [SPACE, TAB];
  DEFAULT_CHARSET_SPACE = [TAB..LF_, SPACE];
  DEFAULT_CHARSET_DIGIT = ['0'..'9'];
  DEFAULT_CHARSET_UPPER = ['A'..'Z'];
  DEFAULT_CHARSET_LOWER = ['a'..'z'];

  DEFAULT_CHARSET_ALPHA = DEFAULT_CHARSET_UPPER + DEFAULT_CHARSET_LOWER;
  DEFAULT_CHARSET_ALNUM_LO = DEFAULT_CHARSET_DIGIT + DEFAULT_CHARSET_LOWER;
  DEFAULT_CHARSET_ALNUM_UP = DEFAULT_CHARSET_DIGIT + DEFAULT_CHARSET_UPPER;
  DEFAULT_CHARSET_ALNUM = DEFAULT_CHARSET_DIGIT + DEFAULT_CHARSET_ALPHA;

  DEFAULT_CHARSET_PUNCT1 = [succ(SPACE)..Pred('0'), succ('9')..pred(pred('A'))]; // not including @[\]^_`{|}~
  DEFAULT_CHARSET_PUNCT2 = [pred('A'), succ('Z')..pred('a'), succ('z')..char(high(Shortint) - 1)];
  DEFAULT_CHARSET_PUNCT = DEFAULT_CHARSET_PUNCT1 + DEFAULT_CHARSET_PUNCT2;

  DEFAULT_CHARSET_GRAPH = DEFAULT_CHARSET_ALNUM + DEFAULT_CHARSET_PUNCT; // 127 chars except space & controls
  DEFAULT_CHARSET_PRINT = DEFAULT_CHARSET_GRAPH + [SPACE]; // all 127 chars exclude controls

  DEFAULT_CHARSET_XDIGIT_LO = DEFAULT_CHARSET_DIGIT + ['a'..'f'];
  DEFAULT_CHARSET_XDIGIT_UP = DEFAULT_CHARSET_DIGIT + ['A'..'F'];
  DEFAULT_CHARSET_XDIGIT = DEFAULT_CHARSET_DIGIT + ['a'..'f', 'A'..'F'];

  //Custom charsets
  DEFAULT_CHARSET_CNTRLSPACE = DEFAULT_CHARSET_CNTRL + DEFAULT_CHARSET_BLANK;
  DEFAULT_CHARSET_IDENTIFIER = DEFAULT_CHARSET_ALNUM + ['_'];
  //mathsymbol note: including comma & dot
  DEFAULT_CHARSET_MATHSYMBOL1 = DEFAULT_CHARSET_DIGIT + ['%', '('..'/'];
  DEFAULT_CHARSET_MATHSYMBOL2 = DEFAULT_CHARSET_MATHSYMBOL1 + ['[', ']', '<'..'>'];
  DEFAULT_CHARSET_HIBITSET = [#127..high(char)];

  DEFAULT_CHARSET_CUSTOM1 = DEFAULT_CHARSET_CNTRLSPACE;
  DEFAULT_CHARSET_CUSTOM2 = DEFAULT_CHARSET_HIBITSET;
  DEFAULT_CHARSET_CUSTOM3 = DEFAULT_CHARSET_MATHSYMBOL1;
  DEFAULT_CHARSET_CUSTOM4 = DEFAULT_CHARSET_MATHSYMBOL2;

var
  ChposIndexTables: array[TCharsetClass] of TCharsetIndexTable;

procedure buildChposIndexTables;
procedure buildIndexTable(var Table: TCharsetIndexTable; const Charset: TCharset);
procedure buildIndexTable_Inverse(var Table: TCharsetIndexTable; const Charset: TCharset);

implementation
uses windows;

const
  DefaultCharsetClass: array[TCharsetClass] of TCharSet = (
    // should be sync'd with actual TCharClass values
    DEFAULT_CHARSET_ALNUM, DEFAULT_CHARSET_ALPHA, DEFAULT_CHARSET_BLANK,
    DEFAULT_CHARSET_CNTRL, DEFAULT_CHARSET_DIGIT, DEFAULT_CHARSET_GRAPH,
    DEFAULT_CHARSET_LOWER, DEFAULT_CHARSET_UPPER, DEFAULT_CHARSET_PRINT,
    DEFAULT_CHARSET_PUNCT, DEFAULT_CHARSET_SPACE, DEFAULT_CHARSET_XDIGIT,
    DEFAULT_CHARSET_CUSTOM1, DEFAULT_CHARSET_CUSTOM2, DEFAULT_CHARSET_CUSTOM3, DEFAULT_CHARSET_CUSTOM4
    );

procedure buildIndexTable(var Table: TCharsetIndexTable; const Charset: TCharset);
var
  Ch: char;
begin
  fillchar(Table, sizeOf(Table), 0);
  for Ch := Low(Ch) to high(Ch) do
    if Ch in Charset then
      Table[Ch] := 1;
end;

procedure buildIndexTable_Inverse(var Table: TCharsetIndexTable; const Charset: TCharset);
var
  Ch: char;
begin
  fillchar(Table, sizeOf(Table), 0);
  for Ch := Low(Ch) to high(Ch) do
    if not (Ch in Charset) then
      Table[Ch] := 1;
end;

procedure buildChposIndexTables;
var
  ch: char;
  cc: TCharsetClass;
begin
  for cc := low(cc) to high(cc) do
    fillchar(ChposIndexTables[cc], sizeof(TCharsetIndexTable), #0);

  for cc := low(cc) to high(cc) do
    for ch := low(ch) to high(ch) do
      if ch in DefaultCharsetClass[cc] then
        ChposIndexTables[cc, ch] := 1;
end;

initialization
  buildChposIndexTables;

end.




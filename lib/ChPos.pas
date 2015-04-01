unit ChPos; //cxpos
{$WEAKPACKAGEUNIT ON}
{$J-} //no-writeableconst
{$R-} //no-rangechecking
{$Q-} //no-overflowchecking
{.$D-}//no-debug

{$I COMPILERS.INC}
{$IFDEF DELPHI_6}
{$WARN SYMBOL_PLATFORM OFF}
{$WARN UNIT_PLATFORM OFF}
{$ENDIF}
{$IFDEF DELPHI_7}
{$WARN SYMBOL_PLATFORM OFF}
{$WARN UNIT_PLATFORM OFF}
{$WARN UNSAFE_CAST OFF}
{$WARN UNSAFE_CODE OFF}
{$WARN UNSAFE_TYPE OFF}
{$ENDIF}

// *fast* charpos unit
// extracted originally from unit cxpos ver 2.0.1.5
// search/pos character centrist (works also for repeated char)
// intended for extensive, heavy use
//
// ====================================================================
//  Copyright (c) 2005-2006, Adrian H. & Ray A.F.
//  Copyright (c) 2004, D.Sofyan, Adrian H. & Inge DR.
//  Property of PT SOFTINDO Jakarta.
//  All rights reserved.
// ====================================================================
//
//  mailto: aa\\AT|s.o.f.t,i.n.d.o\|DOT-net,
//  mailto (dont strip underbar): zero_inge\AT/\y.a,h.o.o|\DOT\\com
//  http://delphi.softindo.net
//

// CHANGES:
// =======
// 1.0.4.0 (2006.01.01)
// too many similar repeated pattern, it will be much easier
// to wrote all of this in macro assembler :(

// 1.0.4.0 (2006.01.01)
// reorganized, may break old code:
//   indexed WordCount
//   indexed CharPos
//   Charset CharPos
//   inverted / complement Class CharPos
//

// 1.0.3.3 (2005.10.12)
// PChar and WChar/doublechars routines will be eventually declined.

// 1.0.3.3 (2005.05.11)
// added: default StartPos argument for trim family, beware, any matching
//        delimiter will cut the preceding string unconditionally.
// added: Default Character Classes, +several supporting functions
// notes: BT (bit test) for testing a set construct, is 4-13 times more
//        expensive than a simple compare, using TCharIndexTable should
//        be faster (despite of its inconvenience)

// 1.0.3.2c (2005.03.10)
// added: dirty variants of upper/lowercase function: UpperCased & LowerCased
// added: Charset variants of trim functions
//
// SameBuffer (CompareMem) needs rework

// 1.0.3.2b
// fixed bug on wcharpos (_cwordpos)

// 1.0.3.2a
// internal

// 1.0.3.2
// fixed bug on _iCompare & _piCompare // a bad-bad.. bug
// extend several charpos functions to accept characters class
// (using TCharIndexTable, indexed character set; for speed;
//  use InitIndexTable to initialize it);
//
// 1.0.3.0
// fixed bug on _cCompare & _pcCompare
//
// please read this Backwise search notes:
//   CAUTION:
//   Under Backwise search, StartPos means the starting position
//   of the search. Normally it should be equal with the END of
//   the string to be searched on (the LENGTH of target string),
//   whereas the Result of Backwise search is a normal pos, ie.
//   counted from the first char of the original target String
//   (NOT backward-counted)
//   You *must* supply the proper StartPos value manually, eg.
//   as length(S).
//   --------------------------------------------------------------
//   it do *NOT* set default to length(S), rather to 1 (as in
//   the normal search).
//   --------------------------------------------------------------
//   The function will start the search from the StartPos value
//   given, if this value is less than the length of the string,
//   then it will ignore the characters after that position
//   (it behaves as override for the length of the string,
//   except when the StartPos value is greater than the length
//   of target string, the function will be failed anyway, ie.
//   if StartPos > length(S) the Search result is always zero)

interface
uses ChPosK; //chpos Constants

// note: since the normal search (with or without case sensitivity)
// is much more commonly used than the backwise search, so we put
// the "Backwise" argument last

function CharPos(const Ch: Char; const S: string; const IgnoreCase: boolean = FALSE;
  const StartPos: integer = 1; const Backwise: boolean = FALSE): integer; register overload

function CharPos(const Ch: Char; const S: string; const StartPos: integer;
  const IgnoreCase: boolean = FALSE; const Backwise: boolean = FALSE): integer; register overload

function CharCount(const Ch: Char; const S: string; const StartPos: integer;
  const IgnoreCase: boolean = FALSE; const Backwise: boolean = FALSE): integer; register overload

function CharCount(const Ch: Char; const S: string; const IgnoreCase: boolean = FALSE;
  const StartPos: integer = 1; const Backwise: boolean = FALSE): integer; register overload

//backwise version

function BackCharPos(const Ch: Char; const S: string; const IgnoreCase: boolean;
  const BackFromPos: integer): integer; register overload

function BackCharPos(const Ch: Char; const S: string; const BackFromPos: integer;
  const IgnoreCase: boolean = FALSE): integer; register overload

function BackCharCount(const Ch: Char; const S: string; const BackFromPos: integer;
  const IgnoreCase: boolean = FALSE): integer; register overload

function BackCharCount(const Ch: Char; const S: string; const IgnoreCase: boolean;
  const BackFromPos: integer): integer; register overload

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// sometimes it is more useful to find a pair of chars
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// here WChar means a pair of Chars (double-chars)

function WCharPos(const firstChar, secondChar: Char; const S: string;
  const IgnoreCase: boolean = FALSE; const StartPos: integer = 1): integer; register overload

function WCharPos(const firstChar, secondChar: Char; const S: string;
  const StartPos: integer; const IgnoreCase: boolean = FALSE): integer; register overload

function WCharPos(const CharsPair, S: string; const IgnoreCase: boolean = FALSE;
  const StartPos: integer = 1): integer; register overload

function WCharPos(const CharsPair, S: string; const StartPos: integer;
  const IgnoreCase: boolean = FALSE): integer; register overload

function WCharCount(const firstChar, secondChar: Char; const S: string;
  const IgnoreCase: boolean = FALSE; const StartPos: integer = 1): integer; register overload

function WCharCount(const firstChar, secondChar: Char; const S: string;
  const StartPos: integer; const IgnoreCase: boolean = FALSE): integer; register overload

function WCharCount(const CharsPair, S: string; const IgnoreCase: boolean = FALSE;
  const StartPos: integer = 1): integer; register overload

function WCharCount(const CharsPair, S: string; const StartPos: integer;
  const IgnoreCase: boolean = FALSE): integer; register overload

function UpperStr(const S: string): string; //overload;
function LowerStr(const S: string): string; //overload;
//procedure UpperStr(var Buffer; const Length: integer); overload;
//procedure LowerStr(var Buffer; const Length: integer); overload;
procedure UpperBuff(var Buffer; const Length: integer);
procedure LowerBuff(var Buffer; const Length: integer);

// Dirty (and fast) version of upper/lowercase
function Uppercased(const S: string): string;
function Lowercased(const S: string): string;

// function trimStr(const S: string): string; overload;
// note: startpos argument will truncate the string before startpos value
function trimStr(const S: string; const StartPos: integer = 1): string; overload;
function trimSLeft(const S: string; const StartPos: integer = 1): string; overload;
function trimSRight(const S: string): string; overload;
function trimStr(const S: string; const Delimiter: Char; const StartPos: integer = 1): string; overload;
function trimSLeft(const S: string; const Delimiter: Char; const StartPos: integer = 1): string; overload;
function trimSRight(const S: string; const Delimiter: Char): string; overload;

type
  //TChPosCharset = set of Char; // equal with TSysCharset
  TChposCharset = ChposK.TCharset;
  TCharClass = ChposK.TCharsetClass;
  // TCharClass = ChposK.TCharClass; // not work??? you have to EXPLICITLY put: uses ChPosK unit.

// note: startpos argument will effectively truncate the string before startpos value
function trimStr(const S: string; const Delimiters: TChPosCharset; const StartPos: integer = 1): string; overload;
function trimSLeft(const S: string; const Delimiters: TChPosCharset; const StartPos: integer = 1): string; overload;
function trimSRight(const S: string; const Delimiters: TChPosCharset): string; overload;

// note: startpos argument will effectively truncate the string before startpos value
// these ones will trim / removes chars which are NOT included in the Words Class
// (actually just an Inverted [and optionally faster] version of trimS with object Charset)
function trimStr(const Words: TCharClass; const S: string; const StartPos: integer = 1): string; overload;
function trimSLeft(const Words: TCharClass; const S: string; const StartPos: integer = 1): string; overload;
function trimSRight(const Words: TCharClass; const S: string): string; overload;

//these routines are IDENTICAL with trimStrs
//function trimmed(const S: string; const StartPos: integer = 1): string; overload;
//function trimmed(const S: string; const Delimiter: Char; const StartPos: integer = 1): string; overload;
//function trimmed(const S: string; const Delimiters: TChPosCharset; const StartPos: integer = 1): string; overload;
//function trimmed(const S: string; const Words: TCharClass): string; overload;

// function trimStrLen(const S: string; const StartPos: integer = 1): integer; overload;
// function trimSLeftLen(const S: string; const StartPos: integer = 1): integer; overload;
// function trimSRightLen(const S: string): integer; overload;
//
// function trimStrLen(const S: string; const Delimiter: Char; const StartPos: integer = 1): integer; overload;
// function trimSLeftLen(const S: string; const Delimiter: Char; const StartPos: integer = 1): integer; overload;
// function trimSRightLen(const S: string; const Delimiter: Char): integer; overload;
//
// function trimStrLen(const S: string; const Delimiters: TChPosCharset; const StartPos: integer = 1): integer; overload;
// function trimSLeftLen(const S: string; const Delimiters: TChPosCharset; const StartPos: integer = 1): integer; overload;
// function trimSRightLen(const S: string; const Delimiters: TChPosCharset): integer; overload;
//
// function trimStrLen(const S: string; const Words: TCharClass; const StartPos: integer = 1): integer; overload;
// function trimSLeftLen(const S: string; const Words: TCharClass; const StartPos: integer = 1): integer; overload;
// function trimSRightLen(const S: string; const Words: TCharClass): integer; overload;

type
  TTrimStrOption = (tsoTrimLeft, tsoTrimRight, tsoInvert);
  TTrimStrOptions = set of TTrimStrOption;
  //

// note: startpos argument will effectively truncate the string before startpos value
// these routines will only get/check the length of the result string
// and avoid copying string when (occasionaly) we just want to only check
// for (usually) an empty string or tobe matched against some specific length constraints
function gettrimdLen(const S: string; var StartPos: integer; const Options: TTrimStrOptions = [tsoTrimLeft, tsoTrimRight]): integer; overload;
function gettrimdLen(const S: string; const Delimiter: Char; var StartPos: integer; const Options: TTrimStrOptions = [tsoTrimLeft, tsoTrimRight]): integer; overload;
function gettrimdLen(const S: string; const Delimiters: TChPosCharset; var StartPos: integer; const Options: TTrimStrOptions = [tsoTrimLeft, tsoTrimRight]): integer; overload;

// note: startpos argument will effectively truncate the string before startpos value
function trimmedLen(const S: string; const Options: TTrimStrOptions; StartPos: integer = 1): integer; overload;
function trimmedLen(const S: string; const Delimiter: Char; const Options: TTrimStrOptions; StartPos: integer = 1): integer; overload;
function trimmedLen(const S: string; const Delimiters: TChPosCharset; const Options: TTrimStrOptions; StartPos: integer = 1): integer; overload;

// note: startpos argument will effectively truncate the string before startpos value
function trimS(const S: string; const Options: TTrimStrOptions = [tsoTrimLeft, tsoTrimRight]; StartPos: integer = 1): string; overload;
function trimS(const S: string; const Delimiter: Char; const Options: TTrimStrOptions = [tsoTrimLeft, tsoTrimRight]; StartPos: integer = 1): string; overload;
function trimS(const S: string; const Delimiters: TChPosCharset; const Options: TTrimStrOptions = [tsoTrimLeft, tsoTrimRight]; StartPos: integer = 1): string; overload;

// note: startpos argument will effectively truncate the string before startpos value
// words (inverted) char
// (actually just an Inverted [and optionally faster] version of trimS with object Charset)
function gettrimdLen(const Words: TCharClass; const S: string; var StartPos: integer; const Options: TTrimStrOptions = [tsoTrimLeft, tsoTrimRight]): integer; overload;
function trimmedLen(const Words: TCharClass; const S: string; const Options: TTrimStrOptions; StartPos: integer = 1): integer; overload;
function trimS(const Words: TCharClass; const S: string; const Options: TTrimStrOptions = [tsoTrimLeft, tsoTrimRight]; StartPos: integer = 1): string; overload;

function SameText(const S1, S2: string; const IgnoreCase: boolean = TRUE): boolean;
function SameBuffer(const P1, P2; const Length: integer; const IgnoreCase: boolean = TRUE): boolean; forward;
procedure XMove(const Source; var Dest; const Count: integer); register assembler; forward

// used only for monotoned/repeated chars as 'cccc','xxxxxx'
// function _RepPos(const Ch: Char; const S: string; const StartPos: integer;
//  const RepCount: integer; const IgnoreCase: boolean): integer;
function RepPos(const Ch: Char; const S: string; const RepCount: integer;
  const StartPos: integer = 1; const IgnoreCase: boolean = FALSE): integer;

function PRepPos(const Ch: Char; const P: PChar; const StartPos: cardinal;
  const PLength: cardinal; const RepCount: integer;
  const IgnoreCase: boolean): integer; register overload
function _RepPos(const Ch: Char; const S: string; const StartPos: integer;
  const RepCount: integer; const IgnoreCase: boolean): integer;

// implementation samples
// returns position of N-th occurrence of specified char (same rule also for ChPairAtIndex below)
function CharAtIndex(const Index: integer; const Ch: Char; const S: string;
  const IgnoreCase: boolean = FALSE; const StartPos: integer = 1;
  const Backwise: boolean = FALSE): integer; register overload
// Index is 1-based, 0 means error (either S is blank or StartPos is out-of-range)
// function CharAtIndex(const Index: integer; const Ch: Char; const S: string;
//   const IgnoreCase: boolean = FALSE; const StartPos: integer = 1;
//   const Backwise: boolean = FALSE): integer; register overload
function BackwiseCharAtIndex(const Index: integer; const Ch: Char; const S: string;
  const BackFromPos: integer; const IgnoreCase: boolean = FALSE): integer; register overload

function WordAtIndex(const Index: integer; const S: string; const delimiter: Char; //= ' ';
  const StartPos: integer = 1; const IgnoreCase: boolean = FALSE; const Backwise: boolean = FALSE): string;
// Index is 1-based, 0 means error (either S is blank or StartPos is out-of-range)
// function WordAtIndex(const Index: integer; const S: string; const delimiter: Char = ' ';
function BackwiseWordAtIndex(const Index: integer; const S: string; const delimiter: Char; //= ' ';
  const BackFromPos: integer; const IgnoreCase: boolean = FALSE): string;

function fetchWord(const S: string; var StartPos: integer; const Delimiter: char): string; overload;
// get a word and update StartPos to the next word position (immediately AFTER delimiter position)
// also returns 0 for the last word
// useful for fast fetch of delimited string (since its not restart search from the first position
// for each iteration). just remember to initialize StartPos = 1 at first iteration.

function WordCount(const S: string; const delimiter: Char {= ' '}; const StartPos: integer = 1;
  const Backwise: boolean = FALSE; const IgnoreCase: boolean = FALSE): integer; overload;
// actually it is not quite a word count, but count of substring with delimited by one
// particular char, used for array or list of known formatted string with specific delimiter
// such as CSV (comma separated Values) or tab/space separated values etc.
// no harm for other (non formatted, arbitrary text), just doesn't make sense
// maybe ignoreCase better be turned off since delimiter should be case-sensitive anyway
// 2005.05.30
// (deprecated, now its simply equal with CharCount +1, except for an empty string which
// returns 0, we dont know whether this is appropriate, since an empty string still is
// containing a string, despite of blank)
// Default Delimiter commented since it's very easy to be overlooked
// note: IgnoreCase applies to Delimiter NOT to word to be searched for
// caution: consecutive delimiters do NOT count as 1, rather they delimit an empty string,
// for instance, a string with only SPACE (as delimiter) counted as 2 words (of empty strings),
// (it seems weird, but this exact behaviour is consistent and predictable)
function BackwiseWordCount(const S: string; const delimiter: Char; const BackFromPos: integer;
  const IgnoreCase: boolean = FALSE): integer; overload;

function WordIndexOf(const SubStr, S: string; const Delimiter: char;
  const LengthToBeCompared: integer = MaxInt; const ignoreCaseSubStr: boolean = TRUE;
  const StartPos: integer = 1; const Backwise: boolean = FALSE;
  const ignoreCaseDelimiter: boolean = FALSE): integer;
// note: IgnoreCaseSubStr applies to SubStr to be searched for
//       IgnoreCaseDelimiter applies to Delimiter
function BackwiseWordIndexOf(const SubStr, S: string; const Delimiter: char;
  const BackFromPos: integer; const LengthToBeCompared: integer = MaxInt;
  const ignoreCaseSubStr: boolean = TRUE; const ignoreCaseDelimiter: boolean = FALSE): integer;

//function PosCRLF(const S: string; const StartPos: integer = 1): integer;
//function UNIXed(const CRLFText: string): string;
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// test...
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// **********************************************************
// CharPos routines with Index table / CharClass table lookup
// **********************************************************
// added new routines for Charset Object (2006.1.1)
// if available use table or CharClass instead of CharSet
// they are much faster (by factor 4 to 9, instruction TEST vs. BT)

type
  //  //TCharIndexTable = packed array[char] of integer; // CXGlobal
  TCharsetIndexTable = ChposK.TCharsetIndexTable;

procedure InitIndexTable(var IndexTable: TCharsetIndexTable; const Charset: TChPosCharset);
procedure InitIndexTable_Inverse(var IndexTable: TCharsetIndexTable; const Charset: TChPosCharset);

// TCharsetIndexTable specifies the word/non-word character by marking the table
// at their respective ordinal position. used for finding Class of chars.
// such as: elemen[SPACE] := 0 ~> if SPACE is not counted as a word's character
//
// initialization example:
// var
//   Ch:Char;
//   CharTable:TCharsetIndexTable;
// const
//   ALPHANUMERIC = ['0'..'9', 'A'..'Z', 'a'..'z'];
// ...
//   fillchar(CharsTable, sizeOf(CharsTable), 0);
//   for Ch := Low(Ch) to high(Ch) do
//     if Ch in ALPHANUMERIC then
//       CharsTable[Ch] := 1;
// ...
//
// then CharPos will find the first occurence of ALPHANUMERIC (any of them)
// ignorecase is not treated specially, since comparison will be done against table/class,
// not to a particular char, it's up to the caller to build the proper char table/class

//
function CharPos(const S: string; const table: TCharsetIndexTable; const StartPos: integer = 1; const Backwise: boolean = FALSE): integer; overload;
function CharPos(const S: string; const Charset: TChPosCharset; const StartPos: integer = 1; const Backwise: boolean = FALSE): integer; overload;
function CharPos(const S: string; const CharClass: TCharClass; const StartPos: integer = 1; const Backwise: boolean = FALSE): integer; overload;

function BackCharPos(const S: string; const table: TCharsetIndexTable; const BackFromPos: integer): integer; overload;
function BackCharPos(const S: string; const Charset: TChPosCharset; const BackFromPos: integer): integer; overload;
function BackCharPos(const S: string; const CharClass: TCharClass; const BackFromPos: integer): integer; overload;

// find position of char which is NOT in the table/CharClass (inverted version of charpos)
function InvCharPos(const S: string; const table: TCharsetIndexTable; const StartPos: integer = 1; const Backwise: boolean = FALSE): integer; overload;
function InvCharPos(const S: string; const CharClass: TCharClass; const StartPos: integer = 1; const Backwise: boolean = FALSE): integer; overload;
function InvCharPos(const S: string; const Charset: TChPosCharset; const StartPos: integer = 1; const Backwise: boolean = FALSE): integer; overload;

function BackInvCharPos(const S: string; const table: TCharsetIndexTable; const BackFromPos: integer): integer; overload;
function BackInvCharPos(const S: string; const CharClass: TCharClass; const BackFromPos: integer): integer; overload;
function BackInvCharPos(const S: string; const Charset: TChPosCharset; const BackFromPos: integer): integer; overload;

// this actually is written later
function InvCharPos(const S: string; const Ch: Char; const StartPos: integer = 1; const Backwise: boolean = FALSE): integer; overload;
function BackInvCharPos(const S: string; const Ch: Char; const BackFromPos: integer): integer; overload;

// get position of n-th (index) character found in the string
//function CharAtIndex_old1(const table: TCharsetIndexTable; const S: string; const StartPos: integer { = 1}; const Index: integer): integer; overload;
//function CharAtIndex_old1(const CharClass: TCharClass; const S: string; const StartPos: integer { = 1}; const Index: integer): integer; overload;
//function CharAtIndex_old1(const Charset: TChPosCharset; const S: string; const StartPos: integer { = 1}; const Index: integer): integer; overload;

function CharAtIndex(const CharsetIndexTable: TCharsetIndexTable; const S: string; const Index: integer; const StartPos: integer): integer; overload;
function CharAtIndex(const CharsetClass: TCharClass; const S: string; const Index: integer; const StartPos: integer): integer; overload;
function CharAtIndex(const Charset: TChPosCharset; const S: string; const Index: integer; const StartPos: integer): integer; overload;

function CharCount(const CharsetIndexTable: TCharsetIndexTable; const S: string; const StartPos: integer = 1): integer; overload;
function CharCount(const CharsetClass: TCharsetClass; const S: string; const StartPos: integer = 1): integer; overload;
function CharCount(const Charset: TChposCharset; const S: string; const StartPos: integer = 1): integer; overload;

//wordcount is usually given supplied delimiters, hence the default at argument 1
function WordCount(const S: string; const delimitersTable: TCharsetIndexTable; const StartPos: integer = 1): integer; overload;
function WordCount(const S: string; const delimitersCharClass: TCharClass; const StartPos: integer = 1): integer; overload;

//function WordCount(const WordTable: TCharsetIndexTable; const S: string; const StartPos: integer = 1): integer; overload;
//function WordCount(const WordClass: TCharClass; const S: string; const StartPos: integer = 1): integer; overload;

// we just realize that they are quite a useful functions; hence we add a character class extension for them
// DelimitersTable table is complement of WordTable table, so we may call at our convenience

// RECALL! fetchword will get a word and update StartPos to the NEXT word position
// (immediately AFTER delimiter position, or 0 if it fails, or the last chunk (delimiter not found))
// useful for fast fetch of delimited string (since its not restart search from the first position
// for each iteration). just remember to initialize StartPos = 1 at first iteration.

function fetchWord(const S: string; var StartPos: integer; const Delimiters: TChposCharset): string; overload;
function fetchWord(const S: string; var StartPos: integer; const DelimitersTable: TCharsetIndexTable): string; overload;
function fetchWord(const S: string; const WordTable: TCharsetIndexTable; var StartPos: integer): string; overload;
// WordClass is predetermined set of CharClass
function fetchWord(const S: string; const WordClass: TCharClass; var StartPos: integer): string; overload;

// pack words (replace all non-words-characters by single char/delimiter)
// consecutive non-word characters will produce a single delimiter only
function PackWords(const WordTable: TCharsetIndexTable; const S: string; const delimiter: char): string; overload;
function PackWords(const WordClass: TCharClass; const S: string; const delimiter: char): string; overload;
function PackWords(const WordCharset: TChPosCharset; const S: string; const delimiter: char): string; overload;

function PackWordsUppercase(const WordTable: TCharsetIndexTable; const S: string; const delimiter: char): string; overload;
function PackWordsUppercase(const WordClass: TCharClass; const S: string; const delimiter: char): string; overload;
function PackWordsUppercase(const WordCharset: TChPosCharset; const S: string; const delimiter: char): string; overload;

function Strip(const S: string; const table: TCharsetIndexTable; const StartPos: integer = 1): string; overload;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// miscellaneous
// obsolete, use character check above/below/equal instead
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//function ControlCharPos(const S: string; const StartPos: integer = 1): integer;
function HiBitCharPos(const S: string; const StartPos: integer = 1): integer;
function HiBitCharCount(const S: string; const StartPos: integer = 1): integer;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Low level-routines. NOT overloaded anymore to avoid ambiguities
//  Naming convention:
//  a. Object to be searched for
//     (none): char (actually "_" or "p")
//     x : Indexed / predefined char class
//     e : Charset
//
//  b. Source/target search
//     _ or (none) : string
//     p : pChar (deprecated / no-longer maintained)
//
//  c. method
//     (none): normal
//     v : Inverted, search for non-matched object
//
//  d. Direction
//     (none) : normal/forward
//     b : backwise
//
//  e. Case option (only applied for object = char)
//     c : case-sensitive
//     i : ignorecase (non-sensitive)
//

///finalized
function pcCharPos(const Ch: Char; const P: PChar; const StartPos, PLength: cardinal): integer register assembler; //overload forward
function piCharPos(const Ch: Char; const P: PChar; const StartPos, PLength: cardinal): integer register assembler; //overload forward
function pcWCharPos(const Word: Word; const P: PChar; const StartPos, PLength: cardinal): integer register assembler; //overload forward
function piWCharPos(const Word: Word; const P: PChar; const StartPos, PLength: cardinal): integer register assembler; //overload forward

{$DEFINE DEBUG} // to make them globally accessible
{$IFDEF DEBUG}
//pchar version no longer supported
function pbcCharPos(const Ch: Char; const P: PChar; const StartPos, PLength: cardinal): integer register assembler; //overload forward
function pbiCharPos(const Ch: Char; const P: PChar; const StartPos, PLength: cardinal): integer register assembler; //overload forward
function pcCharCount(const Ch: Char; const P: PChar; const StartPos, PLength: cardinal): integer register assembler; //overload forward
function piCharCount(const Ch: Char; const P: PChar; const StartPos, PLength: cardinal): integer register assembler; //overload forward
function pcCompare(const P1, P2; const L1, L2: integer): integer; //forward;
function piCompare(const P1, P2; const L1, L2: integer): integer; //forward;

//test
function _cCharPosOK(const Ch: Char; const S: string; const StartPos: integer = 1): integer; register assembler; //overload forward
function _iCharPosOK(const Ch: Char; const S: string; const StartPos: integer = 1): integer register assembler; //overload forward
function _bcCharPosOK(const Ch: Char; const S: string; const StartPos: integer = {0} 1): integer register assembler; //overload forward
function _cCharCountOK(const Ch: Char; const S: string; const StartPos: integer = 1): integer register assembler; //overload forward
function _cCharCount_2(const Ch: Char; const S: string; const StartPos: integer = 1): integer register assembler; //overload forward
function _iCharCountOK(const Ch: Char; const S: string; const StartPos: integer = 1): integer register assembler; //overload forward

function _cCharPos(const Ch: Char; const S: string; const StartPos: integer = 1): integer register assembler; //overload forward
function _iCharPos(const Ch: Char; const S: string; const StartPos: integer = 1): integer register assembler; //overload forward
//not too useful:
//function _vcCharPos(const Ch: Char; const S: string; const StartPos: integer = 1): integer register assembler; //overload forward
//charpos equal or above/below
function _cCharPosEqAbove(const Ch: Char; const S: string; const StartPos: integer = 1): integer register assembler; //overload forward
function _cCharPosEqBelow(const Ch: Char; const S: string; const StartPos: integer = 1): integer register assembler; //overload forward

function _bcCharPos(const Ch: Char; const S: string; const StartPos: integer = {0} 1): integer register assembler; //overload forward
function _biCharPos(const Ch: Char; const S: string; const StartPos: integer = 0): integer register assembler; //overload forward
//not too useful:
//function _vbcCharPos(const Ch: Char; const S: string; const StartPos: integer = {0} 1): integer register assembler; //overload forward
//backwise charpos equal or above/below
function _bcCharPosEqAbove(const Ch: Char; const S: string; const StartPos: integer = {0} 1): integer register assembler; //overload forward
function _bcCharPosEqBelow(const Ch: Char; const S: string; const StartPos: integer = {0} 1): integer register assembler; //overload forward

function _cCharCount(const Ch: Char; const S: string; const StartPos: integer = 1): integer register assembler; //overload forward
function _iCharCount(const Ch: Char; const S: string; const StartPos: integer = 1): integer register assembler; //overload forward
//charcount equal or above/below
function _cCharCountEqAbove(const Ch: Char; const S: string; const StartPos: integer = 1): integer register assembler; //overload forward
function _cCharCountEqbelow(const Ch: Char; const S: string; const StartPos: integer = 1): integer register assembler; //overload forward

function _cCompare(const S1, S2: string): integer; //forward;
function _iCompare(const S1, S2: string): integer; //forward;

// tryout: experimental-stage3 status:OK
// returns position of N-th occurrence of char
function _cCharIndexPos(const Ch: Char; const S: string; const StartPos: integer { = 1}; const Index: integer): integer;
function _iCharIndexPos(const Ch: Char; const S: string; const StartPos: integer { = 1}; const Index: integer): integer;
function _cCharIndexPosEqAbove(const Ch: Char; const S: string; const StartPos: integer { = 1}; const Index: integer): integer;
function _cCharIndexPosEqBelow(const Ch: Char; const S: string; const StartPos: integer { = 1}; const Index: integer): integer;

// tryout: experimental-stage2 status:OK
function _bcCharIndexPos(const Ch: Char; const S: string; const StartPos: integer { = 1}; const Index: integer): integer;
function _biCharIndexPos(const Ch: Char; const S: string; const StartPos: integer { = 1}; const Index: integer): integer;
function _bcCharIndexPosEqAbove(const Ch: Char; const S: string; const StartPos: integer { = 1}; const Index: integer): integer;
function _bcCharIndexPosEqBelow(const Ch: Char; const S: string; const StartPos: integer { = 1}; const Index: integer): integer;

// tryout: experimental-stage2 status:OK
function _bcCharCount(const Ch: Char; const S: string; const StartPos: integer = 1): integer register assembler; //overload forward
function _biCharCount(const Ch: Char; const S: string; const StartPos: integer = 1): integer register assembler; //overload forward
function _bcCharCountEqAbove(const Ch: Char; const S: string; const StartPos: integer = 1): integer register assembler; //overload forward
function _bcCharCountEqBelow(const Ch: Char; const S: string; const StartPos: integer = 1): integer register assembler; //overload forward

function _cWordPos(const Word: Word; const S: ANSIString; const StartPos: integer = 1): integer;
function _cWordCount(const Word: Word; const S: ANSIString; const StartPos: integer = 1): integer;
function _icWordPos(const Word: Word; const S: ANSIString; const StartPos: integer = 1): integer;
function _icWordCount(const Word: Word; const S: ANSIString; const StartPos: integer = 1): integer;

//indexed CharPos
function _xCharPos(const table: TCharsetIndexTable; const S: string; const StartPos: integer = 1): integer; assembler;
function bxCharPos(const table: TCharsetIndexTable; const S: string; const StartPos: integer = 1): integer; assembler;
//Charset CharPos
function _eCharPos(const Charset: TChposCharset; const S: string; const StartPos: integer): integer; assembler;
function beCharPos(const Charset: TChposCharset; const S: string; const StartPos: integer): integer; assembler;

//inverted/complement indexed CharPos
function vxCharPos(const table: TCharsetIndexTable; const S: string; const StartPos: integer): integer; assembler;
function vbxCharPos(const table: TCharsetIndexTable; const S: string; const StartPos: integer): integer; assembler;

//inverted/complement Charset CharPos
function veCharPos(const Charset: TChPosCharset; const S: string; const StartPos: integer): integer; assembler;
function vbeCharPos(const Charset: TChPosCharset; const S: string; const StartPos: integer): integer; assembler;

{$ENDIF DEBUG}
implementation
uses CXGlobal; //, StrUtils;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  ChPos ~ String version
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//do-not-remove
//function _cCharPos_old(const Ch: Char; const S: string;
//const StartPos: integer = 1): integer; assembler asm
//  @@Start: push esi; test S, S; jz @@zero // check S length
//    mov esi, S.SzLen
//    cmp StartPos, esi; jle @@begin
//  @@zero: xor eax, eax; jmp @@Stop
//  @@begin: push S
//    sub StartPos, esi; add S, esi
//  @_Loop:
//    cmp al, byte ptr S[StartPos-1]; je @@found
//    inc StartPos; jle @_Loop
//  @@notfound: xor eax, eax; jmp @@end
//  @@found: sub S, [esp]; lea eax, S + StartPos
//  @@end: pop S
//  @@Stop: pop esi
//end;
//

function _cCharPosOK(const Ch: Char; const S: string; const StartPos: integer = 1): integer; assembler asm
   // using simpler base-index should be faster
   // or at least pairing enabled
   @@Start: test S, S; jz @@zero // check S length
     or StartPos, StartPos; jg @@begin //still need to be checked
   @@zero: xor eax, eax; ret //jmp @@Stop
   @@begin: push esi
     lea esi, S + StartPos -1
     sub StartPos, S.SzLen; jg @@notfound
   @@Loop:
     cmp al, [esi]; lea esi, esi +1; je @@found
     inc StartPos; jle @@Loop
   @@notfound: mov esi, S
   @@found: sub esi, S; mov eax, esi
   @@end: pop esi
   @@Stop:
end;

function _cCharPos(const Ch: Char; const S: string; const StartPos: integer = 1): integer; assembler asm
// unroll loop. ugly, but considerably faster (~twice)
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; ret //jmp @@Stop
  @@begin: push esi
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; jg @@notfound
  @@Loop:
    cmp al, [esi  ]; je @@found0
    cmp al, [esi+1]; je @@found1
    cmp al, [esi+2]; je @@found2
    cmp al, [esi+3]; je @@found3
    //...and so on if you wish

    lea esi,esi+4; add StartPos, 4
    jle @@Loop; jmp @@notfound

  @@found3: inc esi; inc StartPos
  @@found2: inc esi; inc StartPos
  @@found1: inc esi; inc StartPos
  @@found0: inc esi; inc StartPos
  dec StartPos; jle @@found

  @@notfound: mov esi, S
  @@found: sub esi, S; mov eax, esi
  @@end: pop esi
  @@Stop:
end;

function _cCharPosEqAbove(const Ch: Char; const S: string; const StartPos: integer = 1): integer; assembler asm
// unroll loop. ugly, but considerably faster (~twice)
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; ret //jmp @@Stop
  @@begin: push esi
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; jg @@notfound
  @@Loop:
    cmp al, [esi  ]; jae @@found0
    cmp al, [esi+1]; jae @@found1
    cmp al, [esi+2]; jae @@found2
    cmp al, [esi+3]; jae @@found3
    //...and so on if you wish

    lea esi,esi+4; add StartPos, 4
    jle @@Loop; jmp @@notfound

  @@found3: inc esi; inc StartPos
  @@found2: inc esi; inc StartPos
  @@found1: inc esi; inc StartPos
  @@found0: inc esi; inc StartPos
  dec StartPos; jle @@found

  @@notfound: mov esi, S
  @@found: sub esi, S; mov eax, esi
  @@end: pop esi
  @@Stop:
end;

function _cCharPosEqBelow(const Ch: Char; const S: string; const StartPos: integer = 1): integer; assembler asm
// unroll loop. ugly, but considerably faster (~twice)
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; ret //jmp @@Stop
  @@begin: push esi
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; jg @@notfound
  @@Loop:
    cmp al, [esi  ]; jb @@found0
    cmp al, [esi+1]; jb @@found1
    cmp al, [esi+2]; jb @@found2
    cmp al, [esi+3]; jb @@found3
    //...and so on if you wish

    lea esi,esi+4; add StartPos, 4
    jle @@Loop; jmp @@notfound

  @@found3: inc esi; inc StartPos
  @@found2: inc esi; inc StartPos
  @@found1: inc esi; inc StartPos
  @@found0: inc esi; inc StartPos
  dec StartPos; jle @@found

  @@notfound: mov esi, S
  @@found: sub esi, S; mov eax, esi
  @@end: pop esi
  @@Stop:
end;

function _cCharPos2(const Ch: Char; const S: string; const StartPos: integer = 1): integer; assembler asm
// unroll loop. ugly, but considerably faster (~twice)
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; ret //jmp @@Stop
  @@begin: push esi
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; jg @@notfound

  @@Loop:
    cmp al, [esi  ]; je @@found0
    cmp al, [esi+1]; je @@found1
    cmp al, [esi+2]; je @@found2
    cmp al, [esi+3]; je @@found3
    //...and so on if you wish

    lea esi,esi+4; add StartPos, 4
    jle @@Loop; jmp @@notfound

  @@found3: inc esi; inc StartPos
  @@found2: inc esi; inc StartPos
  @@found1: inc esi; inc StartPos
  @@found0: inc esi; inc StartPos
  dec StartPos; jle @@found

  @@notfound: mov esi, S
  @@found: sub esi, S; mov eax, esi
  @@end: pop esi
  @@Stop:
end;

//not too useful:

function _vcCharPosOK(const Ch: Char; const S: string; const StartPos: integer = 1): integer; assembler asm
   // using simpler base-index should be faster
   // or at least pairing enabled
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; ret //jmp @@Stop
  @@begin: push esi
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; jg @@notfound
  @_Loop:
    cmp al, [esi]; lea esi, esi +1; jne @@found
    inc StartPos; jle @_Loop
  @@notfound: mov esi, S
  @@found: sub esi, S; mov eax, esi
  @@end: pop esi
  @@Stop:
end;

//not too useful:

function _vcCharPos(const Ch: Char; const S: string; const StartPos: integer = 1): integer; assembler asm
// unroll loop. ugly, but considerably faster (~twice)
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; ret //jmp @@Stop
  @@begin: push esi
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; jg @@notfound
  @@Loop:
    cmp al, [esi  ]; jne @@found0
    cmp al, [esi+1]; jne @@found1
    cmp al, [esi+2]; jne @@found2
    cmp al, [esi+3]; jne @@found3
    //...and so on if you wish

    lea esi,esi+4; add StartPos, 4
    jle @@Loop; jmp @@notfound

  @@found3: inc esi; inc StartPos
  @@found2: inc esi; inc StartPos
  @@found1: inc esi; inc StartPos
  @@found0: inc esi; inc StartPos
  dec StartPos; jle @@found

  @@notfound: mov esi, S
  @@found: sub esi, S; mov eax, esi
  @@end: pop esi
  @@Stop:
end;

//do-not-remove
//function _iCharPos_old(const Ch: Char; const S: string;
//const StartPos: integer { = 1}): integer; assembler asm
//  @@Start: push ebx; test S, S; jz @@zero // check S length
//    or StartPos, StartPos; jle @@zero // still need to be checked
//    mov ebx, S.szLen
//    cmp StartPos, ebx; jle @@Open
//  @@zero: xor eax, eax; jmp @@Stop
//  @@Open: //movzx eax, &Ch
//    //mov al, &Ch
//    and eax, MAXBYTE
//    push edi
//    lea edi, locasetable
//  @@begin: push esi; push S
//    sub StartPos, ebx; add S, ebx
//    lea esi, S + StartPos -1
//    mov al, edi[eax]
//    cmp al, byte ptr UPCASETABLE[eax]; je @_LoopNC
//    mov bl, al
//  @_Loop:
//    mov al, byte ptr S[StartPos-1];
//    cmp bl, edi[eax]; je @@found
//    inc StartPos; jle @_Loop
//    jmp @@notfound
//  @_LoopNC:
//    cmp al, byte ptr S[StartPos-1]; je @@found
//    inc StartPos; jle @_LoopNC
//  @@notfound: xor eax,eax; jmp @@end
//  @@found: sub S, [esp]; lea eax, S + StartPos
//  @@end: pop S; pop esi
//  @@Close: pop edi
//  @@Stop: pop ebx
//end;

function _iCharPosOK(const Ch: Char; const S: string;
const StartPos: integer { = 1}): integer; assembler asm
  @@Start: push ebx; test S, S; jz @@zero // check S length
    or StartPos, StartPos; jle @@zero // still need to be checked
    mov ebx, S.szLen
    cmp StartPos, ebx; jle @@Open
  @@zero: xor eax, eax; jmp @@Stop
  @@Open: //movzx eax, &Ch
    //mov al, &Ch
    and eax, MAXBYTE
    push edi; lea edi, locasetable
  @@begin: push esi; push S
    sub StartPos, ebx; add S, ebx
    lea esi, S + StartPos -1
    mov al, edi[eax]
    cmp al, byte ptr UPCASETABLE[eax];
    je @_LoopNC
    mov bl, al
  @_Loop:
    //mov al, byte ptr S[StartPos-1];
    mov al, [esi]; lea esi, esi +1
    cmp bl, edi[eax]; je @@found
    inc StartPos; jle @_Loop
    jmp @@notfound
  @_LoopNC:
    //cmp al, byte ptr S[StartPos-1]; je @@found
    cmp al, [esi]; lea esi, esi +1; je @@found
    inc StartPos; jle @_LoopNC
  @@notfound: xor eax,eax; jmp @@end
  @@found: sub S, [esp]; lea eax, S + StartPos
  @@end: pop S; pop esi
  @@Close: pop edi
  @@Stop: pop ebx
end;

function _iCharPos(const Ch: Char; const S: string;
const StartPos: integer { = 1}): integer; assembler asm
// unroll loop. ugly, but considerably faster (~47%)
  @@Start: push ebx; test S, S; jz @@zero // check S length
    or StartPos, StartPos; jle @@zero // still need to be checked
    mov ebx, S.szLen
    cmp StartPos, ebx; jle @@Open
  @@zero: xor eax, eax; jmp @@Stop
  @@Open: and eax, MAXBYTE
    push edi; lea edi, locasetable
  @@begin: push esi; push S
    sub StartPos, ebx; add S, ebx
    lea esi, S + StartPos -1
    mov al, edi[eax]
    cmp al, byte ptr UPCASETABLE[eax]
    je @@Loop_CaseSensitive
    mov bl, al

  @@Loop_noCase:
    mov al, [esi  ]; cmp bl, edi[eax]; je @@ncfound0
    mov al, [esi+1]; cmp bl, edi[eax]; je @@ncfound1
    mov al, [esi+2]; cmp bl, edi[eax]; je @@ncfound2
    mov al, [esi+3]; cmp bl, edi[eax]; je @@ncfound3

    lea esi,esi+4; add StartPos, 4
    jle @@Loop_noCase; jmp @@notfound

    @@ncfound3: inc esi; inc StartPos
    @@ncfound2: inc esi; inc StartPos
    @@ncfound1: inc esi; inc StartPos
    @@ncfound0: inc esi; inc StartPos
    jle @@found; jmp @@notfound

  @@Loop_CaseSensitive:
    cmp al, [esi  ]; je @@csfound0
    cmp al, [esi+1]; je @@csfound1
    cmp al, [esi+2]; je @@csfound2
    cmp al, [esi+3]; je @@csfound3
    //...and so on if you wish

    lea esi,esi+4; add StartPos, 4
    jle @@Loop_CaseSensitive; jmp @@notfound

  @@csfound3: inc esi; inc StartPos
  @@csfound2: inc esi; inc StartPos
  @@csfound1: inc esi; inc StartPos
  @@csfound0: inc esi; inc StartPos
  dec StartPos; jle @@found

  @@notfound: xor eax,eax; jmp @@end
  @@found: sub S, [esp]; lea eax, S + StartPos -1

  @@end: pop S; pop esi
  @@Close: pop edi
  @@Stop: pop ebx
end;

//Backwise

//do-not-remove
//function _bcCharPos_old(const Ch: Char; const S: string;
//const StartPos: integer = {0} 1): integer; assembler asm
//  @@Start: push esi; test S, S; jz @@zero // check S length
//    mov esi, S.SzLen
//    cmp StartPos, esi; jle @@begin
//  @@zero: xor eax, eax; jmp @@Stop
//  @@begin: push S
//    sub StartPos, esi; add S, esi
//  @_Loop:
//    cmp al, byte ptr S[StartPos-1]; je @@found
//    dec StartPos; jg @_Loop
//    xor eax,eax; jmp @@end
//  @@found: sub S, [esp]; lea eax, S + StartPos
//  @@end: pop S
//  @@Stop: pop esi
//end;

// function _bcCharPosOK(const Ch: Char; const S: string;
// const StartPos: integer = {0} 1): integer; assembler asm
//   // using simpler base-index should be faster
//   // or at least pairing enabled
//   @@Start: test S, S; jz @@zero // check S length
//     or StartPos, StartPos; jg @@begin
//   @@zero: xor eax, eax; ret //jmp @@Stop
//   @@begin: push esi
//     lea esi, S + StartPos -1
//     //alt: sub StartPos, S.SzLen; jg @@notfound
//     cmp StartPos, S.SzLen; jg @@notfound
//   @_Loop:
//     cmp al, [esi]; je @@found
//     lea esi, esi -1; dec StartPos; jg @_Loop
//   @@notfound: mov StartPos, 0
//   @@found: mov eax, StartPos
//   @@end: pop esi
//   @@Stop:
// end;

function _bcCharPosOK(const Ch: Char; const S: string;
const StartPos: integer = {0} 1): integer; assembler asm
  // using simpler base-index should be faster
  // or at least pairing enabled
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin
  @@zero: xor eax, eax; ret //jmp @@Stop
  @@begin: push esi
    lea esi, S + StartPos -1
    //alt: sub StartPos, S.SzLen; jg @@notfound
    cmp StartPos, S.SzLen; jg @@notfound
  @_Loop:
    cmp al, [esi]; je @@found
    lea esi, esi -1; dec StartPos; jg @_Loop
  @@notfound: mov StartPos, 0
  @@found: mov eax, StartPos
  @@end: pop esi
  @@Stop:
end;

function _bcCharPos(const Ch: Char; const S: string;
const StartPos: integer = {0} 1): integer; assembler asm
// unroll loop. ugly, but considerably faster (~38%)
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin
  @@zero: xor eax, eax; ret //jmp @@Stop
  @@begin: push esi
    lea esi, S + StartPos -1
    //alt: sub StartPos, S.SzLen; jg @@notfound
    cmp StartPos, S.SzLen; jg @@notfound

  @@Loop:
    cmp al, [esi  ]; je @@found0
    cmp al, [esi-1]; je @@found1
    cmp al, [esi-2]; je @@found2
    cmp al, [esi-3]; je @@found3
    //...and so on if you wish

    lea esi,esi-4; sub StartPos, 4
    jg @@Loop; jmp @@notfound

  @@found3: {dec esi;} dec StartPos
  @@found2: {dec esi;} dec StartPos
  @@found1: {dec esi;} dec StartPos
  @@found0: {dec esi;} dec StartPos
  jge @@found

  @@notfound: mov StartPos, -1
  @@found: lea eax, StartPos +1
  @@end: pop esi
  @@Stop:
end;

function _bcCharPosEqAbove(const Ch: Char; const S: string;
const StartPos: integer = {0} 1): integer; assembler asm
// unroll loop. ugly, but considerably faster (~38%)
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin
  @@zero: xor eax, eax; ret //jmp @@Stop
  @@begin: push esi
    lea esi, S + StartPos -1
    //alt: sub StartPos, S.SzLen; jg @@notfound
    cmp StartPos, S.SzLen; jg @@notfound

  @@Loop:
    cmp al, [esi  ]; jae @@found0
    cmp al, [esi-1]; jae @@found1
    cmp al, [esi-2]; jae @@found2
    cmp al, [esi-3]; jae @@found3
    //...and so on if you wish

    lea esi,esi-4; sub StartPos, 4
    jg @@Loop; jmp @@notfound

  @@found3: {dec esi;} dec StartPos
  @@found2: {dec esi;} dec StartPos
  @@found1: {dec esi;} dec StartPos
  @@found0: {dec esi;} dec StartPos
  jge @@found

  @@notfound: mov StartPos, -1
  @@found: lea eax, StartPos +1
  @@end: pop esi
  @@Stop:
end;

function _bcCharPosEqBelow(const Ch: Char; const S: string;
const StartPos: integer = {0} 1): integer; assembler asm
// unroll loop. ugly, but considerably faster (~38%)
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin
  @@zero: xor eax, eax; ret //jmp @@Stop
  @@begin: push esi
    lea esi, S + StartPos -1
    //alt: sub StartPos, S.SzLen; jg @@notfound
    cmp StartPos, S.SzLen; jg @@notfound

  @@Loop:
    cmp al, [esi  ]; jbe @@found0
    cmp al, [esi-1]; jbe @@found1
    cmp al, [esi-2]; jbe @@found2
    cmp al, [esi-3]; jbe @@found3
    //...and so on if you wish

    lea esi,esi-4; sub StartPos, 4
    jg @@Loop; jmp @@notfound

  @@found3: {dec esi;} dec StartPos
  @@found2: {dec esi;} dec StartPos
  @@found1: {dec esi;} dec StartPos
  @@found0: {dec esi;} dec StartPos
  jge @@found

  @@notfound: mov StartPos, -1
  @@found: lea eax, StartPos +1
  @@end: pop esi
  @@Stop:
end;

//not too useful:

function _vbcCharPosOK(const Ch: Char; const S: string;
const StartPos: integer = {0} 1): integer; assembler asm
  // using simpler base-index should be faster
  // or at least pairing enabled
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin
  @@zero: xor eax, eax; ret //jmp @@Stop
  @@begin: push esi
    lea esi, S + StartPos -1
    //alt: sub StartPos, S.SzLen; jg @@notfound
    cmp StartPos, S.SzLen; jg @@notfound
  @_Loop:
    cmp al, [esi]; jne @@found
    lea esi, esi -1; dec StartPos; jg @_Loop
  @@notfound: mov StartPos, 0
  @@found: mov eax, StartPos
  @@end: pop esi
  @@Stop:
end;

function _vbcCharPos(const Ch: Char; const S: string;
const StartPos: integer = {0} 1): integer; assembler asm
// unroll loop. ugly, but considerably faster (~??%)
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin
  @@zero: xor eax, eax; ret //jmp @@Stop
  @@begin: push esi
    lea esi, S + StartPos -1
    //alt: sub StartPos, S.SzLen; jg @@notfound
    cmp StartPos, S.SzLen; jg @@notfound

  @@Loop:
    cmp al, [esi  ]; jne @@found0
    cmp al, [esi-1]; jne @@found1
    cmp al, [esi-2]; jne @@found2
    cmp al, [esi-3]; jne @@found3
    //...and so on if you wish

    lea esi,esi-4; sub StartPos, 4
    jg @@Loop; jmp @@notfound

  @@found3: {dec esi;} dec StartPos
  @@found2: {dec esi;} dec StartPos
  @@found1: {dec esi;} dec StartPos
  @@found0: {dec esi;} dec StartPos
  jge @@found

  @@notfound: mov StartPos, -1
  @@found: lea eax, StartPos +1
  @@end: pop esi
  @@Stop:
end;

//do-not-remove
//function _biCharPos_old(const Ch: Char; const S: string;
//const StartPos: integer { = 1}): integer; assembler asm
//  @@Start: push ebx; test S, S; jz @@zero // check S length
//    or StartPos, StartPos; jle @@zero
//    mov ebx, S.szLen
//    cmp StartPos, ebx; jle @@Open
//  @@zero: xor eax, eax; jmp @@Stop
//  @@Open: //movzx eax, &Ch
//    //mov al, &Ch
//    and eax, MAXBYTE
//    push edi
//    lea edi, locasetable
//  @@begin: push esi; push S
//    sub StartPos, ebx; add S, ebx
//    lea esi, S + StartPos -1
//    mov al, edi[eax]
//    cmp al, byte ptr UPCASETABLE[eax]; je @_LoopNC
//    mov bl, al
//  @_Loop:
//    mov al, byte ptr S[StartPos-1];
//    cmp bl, edi[eax]; je @@found
//    lea esi, esi -1; dec StartPos; jg @_Loop
//    jmp @@notfound
//  @_LoopNC:
//    cmp al, byte ptr S[StartPos-1]; je @@found
//    lea esi, esi -1; dec StartPos; jg @_LoopNC
//  @@notfound: xor eax,eax; jmp @@end
//  @@found: sub S, [esp]; lea eax, S + StartPos
//  @@end: pop S; pop esi
//  @@Close: pop edi
//  @@Stop: pop ebx
//end;

function _biCharPos(const Ch: Char; const S: string;
const StartPos: integer { = 1}): integer; assembler asm
  @@Start: push ebx; test S, S; jz @@zero // check S length
    or StartPos, StartPos; jle @@zero
    mov ebx, S.szLen
    cmp StartPos, ebx; jle @@Open
  @@zero: xor eax, eax; jmp @@Stop
  @@Open: //movzx eax, &Ch
    //mov al, &Ch
    and eax, MAXBYTE
    push edi
    lea edi, locasetable
  @@begin: push esi//old:; push S
    //old: sub StartPos, ebx; add S, ebx
    lea esi, S + StartPos -1
    mov al, edi[eax]
    cmp al, byte ptr UPCASETABLE[eax]; je @_LoopNC
    mov bl, al
  @_Loop:
    //old: mov al, byte ptr S[StartPos-1];
    mov al, [esi]; cmp bl, edi[eax]; je @@found
    lea esi, esi -1; dec StartPos; jg @_Loop
    jmp @@notfound
  @_LoopNC:
    //old: cmp al, byte ptr S[StartPos-1]; je @@found
    cmp al, [esi]; je @@found;
    lea esi, esi -1; dec StartPos; jg @_LoopNC
  @@notfound: xor eax,eax; jmp @@end
  @@found: mov eax, StartPos//old: sub S, [esp]; lea eax, S + StartPos
  @@end: {old: pop S; }pop esi
  @@Close: pop edi
  @@Stop: pop ebx
end;

function _cCharCountOK(const Ch: Char; const S: string; const StartPos: integer { = 1}): integer; assembler asm
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin // still need to be checked
  @@zero: xor eax, eax; ret
  @@begin: push esi
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; mov S, 0; jg @@done
    @_Loop:
      cmp al, [esi]; lea esi, esi +1; jne @_
      ; inc S
    @_: inc StartPos; jle @_Loop
  @@done: mov eax, S
  @@end: pop esi
  @@EXIT:
end;

function _cCharCount(const Ch: Char; const S: string; const StartPos: integer { = 1}): integer; assembler asm
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin // still need to be checked
  @@zero: xor eax, eax; ret
  @@begin: push esi
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; mov S, 0; jg @@done
    @_Loop:
      cmp al, [esi]; lea esi, esi +1; jne @_
      ; inc S
    @_: inc StartPos; jle @_Loop
  @@done: mov eax, S
  @@end: pop esi
  @@EXIT:
end;

function _cCharCountEqAbove(const Ch: Char; const S: string; const StartPos: integer { = 1}): integer; assembler asm
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin // still need to be checked
  @@zero: xor eax, eax; ret
  @@begin: push esi
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; mov S, 0; jg @@done
    @_Loop:
      cmp al, [esi]; lea esi, esi +1; jnae @_
      ; inc S
    @_: inc StartPos; jle @_Loop
  @@done: mov eax, S
  @@end: pop esi
  @@EXIT:
end;

function _cCharCountEqBelow(const Ch: Char; const S: string; const StartPos: integer { = 1}): integer; assembler asm
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin // still need to be checked
  @@zero: xor eax, eax; ret
  @@begin: push esi
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; mov S, 0; jg @@done
    @_Loop:
      cmp al, [esi]; lea esi, esi +1; jnbe @_
      ; inc S
    @_: inc StartPos; jle @_Loop
  @@done: mov eax, S
  @@end: pop esi
  @@EXIT:
end;

function _cCharCount_2(const Ch: Char; const S: string; const StartPos: integer { = 1}): integer; assembler asm
// unroll loop. ugly, but considerably faster (this one is NOT)
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin // still need to be checked
  @@zero:  xor eax, eax; ret
  @@begin: push esi

    lea esi, S + StartPos -1
    //sub StartPos, S.SzLen; mov S, 0; jg @@done
    sub StartPos, S.SzLen; mov S,0; jg @@done
    dec startPos; neg StartPos
    push ebx; xor ebx, ebx
    push StartPos; and StartPos, not 3; jz @@s3

    @@Loop:
      cmp al, [esi  ]; sete bl; add S, ebx
      cmp al, [esi+1]; sete bl; add S, ebx
      cmp al, [esi+2]; sete bl; add S, ebx
      cmp al, [esi+3]; sete bl; add S, ebx
    add esi, 4; sub StartPos, 4; jg @@Loop

    @@s3: pop StartPos; and StartPos, 3; jz @@quit
      cmp al, [esi  ]; sete bl; add S, ebx; dec StartPos; jle @@quit
      cmp al, [esi+1]; sete bl; add S, ebx; dec StartPos; jle @@quit
      cmp al, [esi+2]; sete bl; add S, ebx; dec StartPos; jle @@quit
      cmp al, [esi+3]; sete bl; add S, ebx; dec StartPos; jle @@quit

    @@quit: pop ebx

  @@done: mov eax, S
  @@end: pop esi
  @@EXIT:
end;

function _iCharCountOK(const Ch: Char; const S: string;
const StartPos: integer { = 1}): integer; assembler asm
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin // still need to be checked
  @@zero:
    xor eax, eax; jmp @@EXIT
  @@begin: push esi; push edi; push ebx
    and eax, MAXBYTE
    lea edi, locasetable
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; mov S, 0; jg @@done
    mov bl, edi + eax
    cmp bl, byte ptr UPCASETABLE[eax]; je @_LoopNC
    @_Loop:
      mov al, [esi]; lea esi, esi +1
      cmp bl, edi + eax
      jne @_; inc S
    @_:inc StartPos; jle @_Loop; jmp @@done
    @_LoopNC:
      cmp al, [esi]; lea esi, esi +1; jne @e
      ; inc S
    @e: inc StartPos; jle @_LoopNC
    @@done: mov eax, S
  @@end: pop ebx; pop edi; pop esi
  @@EXIT:
end;

function _iCharCount(const Ch: Char; const S: string;
const StartPos: integer { = 1}): integer; assembler asm
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin // still need to be checked
  @@zero:
    xor eax, eax; jmp @@EXIT
  @@begin: push esi; push edi; push ebx
    and eax, MAXBYTE
    lea edi, locasetable
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; mov S, 0; jg @@done
    mov bl, edi + eax
    cmp bl, byte ptr UPCASETABLE[eax]; je @_LoopNC
    @_Loop:
      mov al, [esi]; lea esi, esi +1
      cmp bl, edi + eax
      jne @_; inc S
    @_:inc StartPos; jle @_Loop; jmp @@done
    @_LoopNC:
      cmp al, [esi]; lea esi, esi +1; jne @e
      ; inc S
    @e: inc StartPos; jle @_LoopNC
    @@done: mov eax, S
  @@end: pop ebx; pop edi; pop esi
  @@EXIT:
end;

function _bcCharCount(const Ch: Char; const S: string;
  const StartPos: integer { = 1}): integer;
assembler asm
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@Start
  @@zero:  xor eax, eax; jmp @@EXIT
  @@Start: push esi
    lea esi, S + StartPos -1
    //sub StartPos, S.SzLen; mov S,0; jg @@found
    cmp StartPos, S.SzLen; mov S, 0; jg @@done
    @_Loop:
      cmp al, [esi]; lea esi, esi -1; jne @_
      ; inc S
    @_: dec StartPos; jg @_Loop
  @@done: mov eax, S
  @@Stop: pop esi
  @@EXIT:
  end;

function _bcCharCountEqAbove(const Ch: Char; const S: string;
  const StartPos: integer { = 1}): integer;
assembler asm
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@Start
  @@zero:  xor eax, eax; jmp @@EXIT
  @@Start: push esi
    lea esi, S + StartPos -1
    //sub StartPos, S.SzLen; mov S,0; jg @@found
    cmp StartPos, S.SzLen; mov S, 0; jg @@done
    @_Loop:
      cmp al, [esi]; lea esi, esi -1; jnae @_
      ; inc S
    @_: dec StartPos; jg @_Loop
  @@done: mov eax, S
  @@Stop: pop esi
  @@EXIT:
  end;

function _bcCharCountEqBelow(const Ch: Char; const S: string;
  const StartPos: integer { = 1}): integer;
assembler asm
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@Start
  @@zero:  xor eax, eax; jmp @@EXIT
  @@Start: push esi
    lea esi, S + StartPos -1
    //sub StartPos, S.SzLen; mov S,0; jg @@found
    cmp StartPos, S.SzLen; mov S, 0; jg @@done
    @_Loop:
      cmp al, [esi]; lea esi, esi -1; jnbe @_
      ; inc S
    @_: dec StartPos; jg @_Loop
  @@done: mov eax, S
  @@Stop: pop esi
  @@EXIT:
  end;

function _biCharCount(const Ch: Char; const S: string;
const StartPos: integer { = 1}): integer; assembler asm
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin // still need to be checked
  @@zero:
    xor eax, eax; jmp @@EXIT
  @@begin: push esi; push edi; push ebx
    and eax, MAXBYTE
    lea edi, locasetable
    lea esi, S + StartPos -1
    //sub StartPos, S.SzLen; mov S, 0; jg @_found
    cmp StartPos, S.SzLen; mov S, 0; jg @@done
    mov bl, edi + eax
    cmp bl, byte ptr UPCASETABLE[eax]; je @_LoopNC
    @_Loop:
      mov al, [esi]; lea esi, esi -1
      cmp bl, edi + eax; jne @_
      ; inc S
    @_:dec StartPos; jg @_Loop; jmp @@done
    @_LoopNC:
      cmp al, [esi]; lea esi, esi -1; jne @e
      ; inc S
    @e: dec StartPos; jg @_LoopNC
    @@done: mov eax, S
  @@end: pop ebx; pop edi; pop esi
  @@EXIT:
end;

function _cCharIndexPos(const Ch: Char; const S: string;
const StartPos: integer { = 1}; const Index: integer): integer; assembler asm
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi; push S
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; jg @@notfound
    mov S, Index; dec S; jl @@notfound
  @_Loop:
    cmp al, [esi]; lea esi, esi +1; jne @_//je @@found
    dec S; jl @@found
  @_:inc StartPos; jle @_Loop
  @@notfound: mov esi, [esp]
  @@found: sub esi, [esp]; mov eax, esi
  @@end: pop S; pop esi
  @@Stop:
end;

function _cCharIndexPosEqAbove(const Ch: Char; const S: string;
const StartPos: integer { = 1}; const Index: integer): integer; assembler asm
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi; push S
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; jg @@notfound
    mov S, Index; dec S; jl @@notfound
  @_Loop:
    cmp al, [esi]; lea esi, esi +1; jnae @_//je @@found
    dec S; jl @@found
  @_:inc StartPos; jle @_Loop
  @@notfound: mov esi, [esp]
  @@found: sub esi, [esp]; mov eax, esi
  @@end: pop S; pop esi
  @@Stop:
end;

function _cCharIndexPosEqBelow(const Ch: Char; const S: string;
const StartPos: integer { = 1}; const Index: integer): integer; assembler asm
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi; push S
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; jg @@notfound
    mov S, Index; dec S; jl @@notfound
  @_Loop:
    cmp al, [esi]; lea esi, esi +1; jnbe @_//je @@found
    dec S; jl @@found
  @_:inc StartPos; jle @_Loop
  @@notfound: mov esi, [esp]
  @@found: sub esi, [esp]; mov eax, esi
  @@end: pop S; pop esi
  @@Stop:
end;

function _iCharIndexPos(const Ch: Char; const S: string;
const StartPos: integer { = 1}; const Index: integer): integer; assembler asm
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jle @@zero // still need to be checked
  @@warning_esi_pushed: push esi
    lea esi, S + StartPos -1
    sub StartPos, S.szLen; jle @@begin
  @@Warning_esi_poped: pop esi // orphaned pop
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: //movzx eax, &Ch
    {old: push esi;} push edi; push S
    lea edi, locasetable
    //mov al, &Ch
    and eax, MAXBYTE
    mov S, Index; dec S; jl @@notfound

    mov al, edi[eax]
    cmp al, byte ptr UPCASETABLE[eax]; je @_LoopNC
    mov bl, al
  @_Loop:
    //old: mov al, byte ptr S[StartPos-1];
    mov al, [esi]; lea esi, esi +1
    cmp bl, edi[eax]; jne @_//je @@found
    dec S; jl @@found
  @_:inc StartPos; jle @_Loop; jmp @@notfound
  @_LoopNC:
    //old: cmp al, byte ptr S[StartPos-1]; je @@found
    cmp al, [esi]; lea esi, esi +1; jne @e//je @@found
    dec S; jl @@found
  @e:inc StartPos; jle @_LoopNC
  @@notfound: mov [esp], esi
  @@found: sub esi, [esp]; mov eax, esi
  @@end: pop S; pop edi; pop esi
  @@Stop: //pop ebx
end;

function _bcCharIndexPos(const Ch: Char; const S: string;
const StartPos: integer { = 1}; const Index: integer): integer; assembler asm
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi; push S
    lea esi, S + StartPos -1
    //alt: sub StartPos, S.SzLen; jg @@notfound
    cmp StartPos, S.SzLen; jg @@notfound
    mov S, Index; dec S; jl @@notfound
  @_Loop:
    cmp al, [esi]; jne @_//je @@found
    dec S; jl @@found
  @_:dec StartPos; lea esi, esi -1; jg @_Loop
  @@notfound: mov esi, [esp]; dec esi
  @@found: sub esi, [esp]; lea eax, esi +1
  @@end: pop S; pop esi
  @@Stop:
end;

function _bcCharIndexPosEqAbove(const Ch: Char; const S: string;
const StartPos: integer { = 1}; const Index: integer): integer; assembler asm
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi; push S
    lea esi, S + StartPos -1
    //alt: sub StartPos, S.SzLen; jg @@notfound
    cmp StartPos, S.SzLen; jg @@notfound
    mov S, Index; dec S; jl @@notfound
  @_Loop:
    cmp al, [esi]; jnae @_//je @@found
    dec S; jl @@found
  @_:dec StartPos; lea esi, esi -1; jg @_Loop
  @@notfound: mov esi, [esp]; dec esi
  @@found: sub esi, [esp]; lea eax, esi +1
  @@end: pop S; pop esi
  @@Stop:
end;

function _bcCharIndexPosEqBelow(const Ch: Char; const S: string;
const StartPos: integer { = 1}; const Index: integer): integer; assembler asm
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi; push S
    lea esi, S + StartPos -1
    //alt: sub StartPos, S.SzLen; jg @@notfound
    cmp StartPos, S.SzLen; jg @@notfound
    mov S, Index; dec S; jl @@notfound
  @_Loop:
    cmp al, [esi]; jnbe @_//je @@found
    dec S; jl @@found
  @_:dec StartPos; lea esi, esi -1; jg @_Loop
  @@notfound: mov esi, [esp]; dec esi
  @@found: sub esi, [esp]; lea eax, esi +1
  @@end: pop S; pop esi
  @@Stop:
end;

function _biCharIndexPos(const Ch: Char; const S: string;
const StartPos: integer { = 1}; const Index: integer): integer; assembler asm
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jle @@zero // still need to be checked
  @@warning_esi_pushed: push esi
    lea esi, S + StartPos -1
    //sub StartPos, S.szLen; jle @@begin
    cmp StartPos, S.szLen; jle @@begin
  @@Warning_esi_poped: pop esi // orphaned pop
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: //movzx eax, &Ch
    {old: push esi;} push edi; push S
    lea edi, locasetable
    //mov al, &Ch
    and eax, MAXBYTE
    mov S, Index; dec S; jl @@notfound

    mov al, edi[eax]
    cmp al, byte ptr UPCASETABLE[eax]; je @_LoopNC
    mov bl, al
  @_Loop:
    //old: mov al, byte ptr S[StartPos-1];
    mov al, [esi]; cmp bl, edi[eax]; jne @_//je @@found
    dec S; jl @@found;
    @_:dec StartPos; ; lea esi, esi -1;jg @_Loop; jmp @@notfound
  @_LoopNC:
    //old: cmp al, byte ptr S[StartPos-1]; je @@found
    cmp al, [esi]; jne @e//je @@found
    dec S; jl @@found
    @e:dec StartPos; lea esi, esi -1; jg @_LoopNC
  @@notfound: mov esi, [esp]; dec esi
  @@found: sub esi, [esp]; lea eax, esi +1
  @@end: pop S; pop edi; pop esi
  @@Stop: //pop ebx
end;

function _RepPos(const Ch: Char; const S: string; const StartPos: integer;
const RepCount: integer; const IgnoreCase: boolean): integer; assembler asm
  @@Start: push esi; or S, S; je @@zero
    test StartPos, StartPos; jle @@zero
    cmp StartPos, S.szLen; jle @begin
  @@zero: xor eax, eax; jmp @@Stop
  @begin: push esi; push edi; push ebx
    mov esi, S
    push esi            // save original address
    // mov al, &Ch
    and eax, MAXBYTE
    mov edi, esi
    lea esi, esi + StartPos -1
    add edi, edi.szLen
    mov ecx, RepCount
    dec ecx
    mov edx, ecx; sub edi, ecx
    test IgnoreCase, 1; jnz @@CaseInsensitive

    @@CaseSensitive:
    @_Repeat:
      cmp esi, edi; jg @@notfound  // note!
      cmp al, esi[edx]; jne @_skip
    @_Loop:
      dec ecx; jl @@found
      cmp al, esi[ecx]; je @_Loop
    @_forward:
      lea esi, esi + ecx +1; mov ecx, edx
      jmp @_Repeat
    @_skip:
      lea esi, esi + edx +1; jmp @_Repeat

    @@CaseInsensitive:
      xor ebx, ebx
      mov bl, byte ptr locasetable[eax]
      cmp bl, byte ptr UPCASETABLE[eax]
      je @@CaseSensitive

    @_iRepeat:
      cmp esi, edi; jg @@notfound
      mov al, esi[edx]
      cmp bl, byte ptr locasetable[eax]; jne @_iSkip
    @_iLoop:
      dec ecx; jl @@found
      mov al, esi[ecx]
      cmp bl, byte ptr locasetable[eax]; je @_iLoop
    @_iForward:
      lea esi, esi + ecx +1; mov ecx, edx
      jmp @_iRepeat
    @_iSkip:
      lea esi, esi + edx +1; jmp @_iRepeat

  @@notfound: lea eax, esi +1; mov [esp], eax
  @@found: pop edi; sub esi, edi; lea eax, esi +1
  @@end: pop ebx; pop edi; pop esi
  @@Stop: pop esi
end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// implementation
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function CharPos(const Ch: Char; const S: string;
  const StartPos: integer; const IgnoreCase: boolean = FALSE;
  const Backwise: boolean = FALSE): integer;
begin
  if Backwise then //Result := BackCharPos(Ch, S, StartPos, IgnoreCase)
    if IgnoreCase then
      Result := _biCharPos(Ch, S, StartPos)
    else
      Result := _bcCharPos(Ch, S, StartPos)
  else
    if IgnoreCase then
      Result := _iCharPos(Ch, S, StartPos)
    else
      Result := _cCharPos(Ch, S, StartPos)
end;

function CharPos(const Ch: Char; const S: string;
  const IgnoreCase: boolean = FALSE; const StartPos: integer = 1;
  const Backwise: boolean = FALSE): integer;
begin
  //Result := CharPos(Ch, S, StartPos, IgnoreCase, Backwise)
  if Backwise then
    if IgnoreCase then
      Result := _biCharPos(Ch, S, StartPos)
    else
      Result := _bcCharPos(Ch, S, StartPos)
  else
    if IgnoreCase then
      Result := _iCharPos(Ch, S, StartPos)
    else
      Result := _cCharPos(Ch, S, StartPos)
end;

function BackCharPos(const Ch: Char; const S: string;
  const IgnoreCase: boolean; const BackFromPos: integer): integer;
begin
  if IgnoreCase then
    Result := _biCharPos(Ch, S, BackFromPos)
  else
    Result := _bcCharPos(Ch, S, BackFromPos)
end;

function BackCharPos(const Ch: Char; const S: string;
  const BackFromPos: integer; const IgnoreCase: boolean = FALSE): integer;
begin
  //Result := BackCharPos(Ch, S, BackFromPos, IgnoreCase)
  if IgnoreCase then
    Result := _biCharPos(Ch, S, BackFromPos)
  else
    Result := _bcCharPos(Ch, S, BackFromPos)
end;

function RepPos(const Ch: Char; const S: string; const RepCount: integer;
  const StartPos: integer = 1; const IgnoreCase: boolean = FALSE): integer;
begin
  if RepCount < 2 then
    Result := CharPos(Ch, S, StartPos, IgnoreCase)
  else
    Result := _RepPos(Ch, S, StartPos, RepCount, IgnoreCase);
end;

function CharCount(const Ch: Char; const S: string;
  const StartPos: integer; const IgnoreCase: boolean = FALSE;
  const Backwise: boolean = FALSE): integer;
begin
  if Backwise then //Result := BackCharCount(Ch, S, StartPos, IgnoreCase)
    if IgnoreCase then
      Result := _biCharCount(Ch, S, StartPos)
    else
      Result := _bcCharCount(Ch, S, StartPos)
  else if IgnoreCase then
    Result := _iCharCount(Ch, S, StartPos)
  else
    Result := _cCharCount(Ch, S, StartPos)
end;

function CharCount(const Ch: Char; const S: string;
  const IgnoreCase: boolean = FALSE; const StartPos: integer = 1;
  const Backwise: boolean = FALSE): integer;
begin
  //Result := CharCount(Ch, S, StartPos, IgnoreCase, Backwise);
  if Backwise then
    if IgnoreCase then
      Result := _biCharCount(Ch, S, StartPos)
    else
      Result := _bcCharCount(Ch, S, StartPos)
  else if IgnoreCase then
    Result := _iCharCount(Ch, S, StartPos)
  else
    Result := _cCharCount(Ch, S, StartPos)
end;

function BackCharCount(const Ch: Char; const S: string;
  const BackFromPos: integer; const IgnoreCase: boolean = FALSE): integer;
begin
  if IgnoreCase then
    Result := _biCharCount(Ch, S, BackFromPos)
  else
    Result := _bcCharCount(Ch, S, BackFromPos)
end;

function BackCharCount(const Ch: Char; const S: string;
  const IgnoreCase: boolean; const BackFromPos: integer): integer;
begin
  //Result := BackCharCount(Ch,S,BackFromPos, Ignorecase);
  if IgnoreCase then
    Result := _biCharCount(Ch, S, BackFromPos)
  else
    Result := _bcCharCount(Ch, S, BackFromPos)
end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  expos ~ PChar version
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//do-not-remove
//function pcCharPos_old(const Ch: Char; const P: PChar;
//const StartPos, PLength: cardinal): integer; assembler asm //untested!
//  @@Start: push esi; test P, P; jz @@notfound
//    // additional test for integer:
//    // test StartPos, StartPos; jle @@zero
//    mov esi, PLength
//    cmp StartPos, esi; jbe @@begin // jle for integer
//    xor eax, eax; jmp @@Stop
//  @@begin:
//    sub StartPos, esi; add esi, P
//    @Loop:
//      cmp al, byte ptr esi[StartPos -1]; je @@found
//      inc StartPos; jnz @Loop
//      //last-char to be checked
//      inc StartPos; cmp al, byte ptr esi[StartPos -1]; je @@found
//  @@notfound: xor eax, eax; jmp @@end
//  @@found: sub esi, P; lea eax, esi + StartPos
//  @@end:
//  @@Stop: pop esi
//end;

function pcCharPos(const Ch: Char; const P: PChar;
const StartPos, PLength: cardinal): integer; assembler asm
  // using simpler base-index should be faster
  // or at least pairing enabled
  @@begin: push esi
    lea esi, P + StartPos -1
    sub StartPos, PLength; ja @@notfound // jg for integer?
  @_Loop:
    cmp al, [esi]; lea esi, esi +1; je @@found
    inc StartPos; jle @_Loop
  @@notfound: xor eax, eax; jmp @@end
  @@found: mov eax, esi; sub eax, P
  @@end: pop esi
end;

function piCharPos(const Ch: Char; const P: PChar;
const StartPos, PLength: cardinal): integer; assembler asm
  @@begin: push esi; push edi; push ebx
    and eax, MAXBYTE
    lea edi, locasetable
    lea esi, P + StartPos -1
    sub StartPos, PLength; ja @_notfound // jg for integer?
    mov bl, edi + eax
    cmp bl, byte ptr UPCASETABLE[eax]; je @_LoopNC
    @_Loop:
      mov al, [esi]; lea esi, esi +1
      cmp bl, edi + eax; je @@found
      inc StartPos; jle @_Loop
      jmp @_notfound
    @_LoopNC:
      cmp al, [esi]; lea esi, esi +1; je @@found
      inc StartPos; jle @_LoopNC
    @_notfound: xor eax, eax; jmp @@end
  @@found: mov eax, esi; sub eax, P
  @@end: pop ebx; pop edi; pop esi
end;

function pbcCharPos(const Ch: Char; const P: PChar;
const StartPos, PLength: cardinal): integer; assembler asm
  @@begin: push esi
    and eax, MAXBYTE
    lea esi, P + StartPos -1
    cmp StartPos, PLength; ja @_notfound // jg for integer
    @_Loop:
      cmp al, [esi]; lea esi, esi -1; je @@found
      sub StartPos, 1; jnb @_Loop
    @_notfound: xor eax, eax; jmp @@end
  @@found: lea eax, StartPos +1//mov eax, esi; sub eax, P
  @@end: pop esi
end;

function pbiCharPos(const Ch: Char; const P: PChar;
const StartPos, PLength: cardinal): integer; assembler asm
  @@begin: push esi; push edi; push ebx
    and eax, MAXBYTE
    lea edi, locasetable
    lea esi, P + StartPos -1
    cmp StartPos, PLength; ja @_notfound // jg for integer
    mov bl, edi + eax
    cmp bl, byte ptr UPCASETABLE[eax]; je @_LoopNC
    @_Loop:
      mov al, [esi]; lea esi, esi +1
      cmp bl, edi + eax; je @@found
      sub StartPos, 1; jnb @_Loop
      jmp @_notfound
    @_LoopNC:
      cmp al, [esi]; lea esi, esi -1; je @@found
      sub StartPos, 1; jnb @_LoopNC
    @_notfound: xor eax, eax; jmp @@end
  @@found: lea eax, StartPos +1//mov eax, esi; sub eax, P
  @@end: pop ebx; pop edi; pop esi
end;

function pcCharCount(const Ch: Char; const P: PChar;
const StartPos, PLength: cardinal): integer; assembler asm
  @@begin: push esi
    lea esi, P + StartPos -1
    xor P, P
    sub StartPos, PLength; ja @@found//jg @@found
    @_Loop:
      cmp al, [esi]; lea esi, esi +1; jne @_
      ; lea P, P+1
    @_: inc StartPos; jle @_Loop
  @@found: mov eax, P
  @@end: pop esi
end;

function piCharCount(const Ch: Char; const P: PChar;
const StartPos, PLength: cardinal): integer; assembler asm
  @@begin: push esi; push edi; push ebx
    and eax, MAXBYTE
    lea edi, locasetable
    lea esi, P + StartPos -1
    xor P, P
    sub StartPos, PLength; ja @_found//jg @_found
    mov bl, edi + eax
    cmp bl, byte ptr UPCASETABLE[eax]; je @_LoopNC
    @_Loop:
      mov al, [esi]; lea esi, esi +1
      cmp bl, edi + eax; jne @_
      ; lea P, P +1
      @_:inc StartPos; jle @_Loop; jmp @_found
    @_LoopNC:
      cmp al, [esi]; lea esi, esi +1
      jne @e; lea P, P+1
      @e: inc StartPos; jle @_LoopNC
    @_found: mov eax, P
  @@end: pop ebx; pop edi; pop esi
end;

function PRepPos(const Ch: Char; const P: PChar; const StartPos: cardinal;
  const PLength: cardinal; const RepCount: integer;
const IgnoreCase: boolean): integer; register overload assembler asm
  @@Start: or P, P; je @@zero
    test StartPos, StartPos; jle @@zero  // StartPos = 0?
    cmp StartPos, PLength; jle @begin    // StartPos >= Length(S) ?

  @@zero: xor eax, eax; jmp @@Stop
  @begin: push esi; push edi; push ebx
    mov esi, P
    push esi            // save original address
    //mov al, &Ch
    and eax, MAXBYTE
    mov edi, esi
    lea esi, esi + StartPos -1
    add edi, PLength
    mov ecx, RepCount
    dec ecx
    mov edx, ecx; sub edi, ecx
    test IgnoreCase, 1; jnz @@CaseInsensitive

    @@CaseSensitive:
    @_Repeat:
      cmp esi, edi; jg @@notfound  // note!
      cmp al, esi[edx]; jne @_skip
    @_Loop:
      dec ecx; jl @@found
      cmp al, esi[ecx]; je @_Loop
    @_forward:
      lea esi, esi + ecx +1; mov ecx, edx
      jmp @_Repeat
    @_skip:
      lea esi, esi + edx +1; jmp @_Repeat

    @@CaseInsensitive:
      xor ebx, ebx
      mov bl, byte ptr locasetable[eax]
      cmp bl, byte ptr UPCASETABLE[eax]
      je @@CaseSensitive

    @_iRepeat:
      cmp esi, edi; jg @@notfound
      mov al, esi[edx]
      cmp bl, byte ptr locasetable[eax]; jne @_iSkip
    @_iLoop:
      dec ecx; jl @@found
      mov al, esi[ecx]
      cmp bl, byte ptr locasetable[eax]; je @_iLoop
    @_iForward:
      lea esi, esi + ecx +1; mov ecx, edx
      jmp @_iRepeat
    @_iSkip:
      lea esi, esi + edx +1; jmp @_iRepeat

  @@notfound: lea eax, esi +1; mov [esp], eax
  @@found: pop edi; sub esi, edi; lea eax, esi +1
  @@end: pop ebx; pop edi; pop esi
  @@Stop:
end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Chars Pair / Double Chars routines
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//function _cWordPos_old2(const Word: Word; const S: ANSIString;
//const StartPos: integer = 1): integer; assembler asm
//  @@Start: test S, S; jz @@zero // check S length
//    or StartPos, StartPos; jg @@begin //still need to be checked
//  @@zero: xor eax, eax; jmp @@Stop
//  @@begin: push esi
//    lea esi, S + StartPos -1
//    sub StartPos, S.SzLen; jge @@notfound
//  @_Loop: // better play safe here
//    cmp al, [esi]; lea esi, esi +1; je @@found1
//    inc StartPos; jl @_Loop; jmp @@notfound
//  @@found1:
//    cmp ah, [esi]; je @@found; lea esi, esi +1
//    add StartPos, 2; jl @_Loop
//  @@notfound: mov esi, S
//  @@found: sub esi, S; mov eax, esi
//  @@end: pop esi
//  @@Stop:
//end;

//function _cWordCount_old2(const Word: Word; const S: ANSIString;
//const StartPos: integer = 1): integer; assembler asm
//  @@Start: test S, S; jz @@zero // check S length
//    or StartPos, StartPos; jg @@begin //still need to be checked
//  @@zero: xor eax, eax; jmp @@Stop
//  @@begin: push esi
//    lea esi, S + StartPos -1
//    sub StartPos, S.SzLen; mov S, 0; jge @@done
//  @_Loop: // better play safe here
//    cmp al, [esi]; lea esi, esi +1; je @@found1
//    inc StartPos; jl @_Loop; jmp @@done
//  @@found1:
//    cmp ah, [esi]; lea esi, esi +1; jne @@_
//    ; inc S
//    @@_:add StartPos, 2; jl @_Loop
//  @@done: mov eax, S
//  @@end: pop esi
//  @@Stop:
//end;

//function _cWordPosbug1(const Word: Word; const S: ANSIString;
//const StartPos: integer = 1): integer; assembler asm
//  @@Start: test S, S; jz @@zero // check S length
//    or StartPos, StartPos; jg @@begin //still need to be checked
//  @@zero: xor eax, eax; jmp @@Stop
//  @@begin: push esi
//    lea esi, S + StartPos -1
//    sub StartPos, S.SzLen; jge @@notfound
//  @_Loop: // better play safe here
//    cmp al, [esi]; lea esi, esi +1; je @@found1
//    inc StartPos; jl @_Loop; jmp @@notfound
//  @@found1:
//    cmp ah, [esi]; lea esi, esi +1; je @@found
//    add StartPos, 2; jl @_Loop
//  @@notfound: mov esi, S; inc esi
//  @@found: sub esi, S; lea eax, esi -1
//  @@end: pop esi
//  @@Stop:
//end;

//function _cWordPos_old3_OK(const Word: Word; const S: ANSIString;
//const StartPos: integer = 1): integer; assembler asm
//  @@Start: test S, S; jz @@zero // check S length
//    or StartPos, StartPos; jg @@begin //still need to be checked
//  @@zero: xor eax, eax; jmp @@Stop
//  @@begin: push esi
//    lea esi, S + StartPos -1
//    sub StartPos, S.SzLen; jge @@notfound
//  @_Loop: // better play safe here
//    cmp al, [esi]; lea esi, esi +1; je @@found1
//    inc StartPos; jl @_Loop; jmp @@notfound
//  @@found1:
//    cmp ah, [esi]; je @@found
//    inc StartPos; jl @_Loop
//  @@notfound: mov esi, S;// inc esi
//  @@found: sub esi, S; mov eax, esi
//  @@end: pop esi
//  @@Stop:
//end;

function _cWordPos(const Word: Word; const S: ANSIString;
const StartPos: integer = 1): integer; assembler asm
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; ret //jmp @@Stop
  @@begin: push esi
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; jge @@notfound
    //rol ax,8
  @_Loop:
    cmp ax, [esi]; lea esi, esi +1; je @@found
    inc StartPos; jl @_Loop
  @@notfound: mov esi, S
  @@found: sub esi, S; mov eax, esi
  @@end: pop esi
  @@Stop:
end;

//function _cWordCount_bug1(const Word: Word; const S: ANSIString;
//const StartPos: integer = 1): integer; assembler asm
//  @@Start: test S, S; jz @@zero // check S length
//    or StartPos, StartPos; jg @@begin //still need to be checked
//  @@zero: xor eax, eax; jmp @@Stop
//  @@begin: push esi
//    lea esi, S + StartPos -1
//    sub StartPos, S.SzLen; mov S, 0; jge @@done
//  @_Loop: // better play safe here
//    cmp al, [esi]; lea esi, esi +1; je @@found1
//    inc StartPos; jl @_Loop; jmp @@done
//  @@found1:
//    cmp ah, [esi]; lea esi, esi +1; jne @@_
//    ; inc S
//    @@_:add StartPos, 2; jl @_Loop
//  @@done: mov eax, S
//  @@end: pop esi
//  @@Stop:
//end;

//function _cWordCount_old3_OK(const Word: Word; const S: ANSIString;
//const StartPos: integer = 1): integer; assembler asm
//  @@Start: test S, S; jz @@zero // check S length
//    or StartPos, StartPos; jg @@begin //still need to be checked
//  @@zero: xor eax, eax; jmp @@Stop
//  @@begin: push esi
//    lea esi, S + StartPos -1
//    sub StartPos, S.SzLen; mov S, 0; jge @@done
//  @_Loop: // better play safe here
//    cmp al, [esi]; lea esi, esi +1; je @@found1
//    inc StartPos; jl @_Loop; jmp @@done
//  @@found1:
//    cmp ah, [esi]; jne @@_
//    ; inc S
//    @@_:inc StartPos; jl @_Loop
//  @@done: mov eax, S
//  @@end: pop esi
//  @@Stop:
//end;

function _cWordCount(const Word: Word; const S: ANSIString;
const StartPos: integer { = 1}): integer; assembler asm
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin // still need to be checked
  @@zero:
    xor eax, eax; jmp @@EXIT
  @@begin: push esi
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; mov S, 0; jge @@done
    //rol ax,8
    @_Loop:
      cmp ax, [esi]; lea esi, esi +1; jne @_
      ; inc S
    @_: inc StartPos; jl @_Loop
  @@done: mov eax, S
  @@end: pop esi
  @@EXIT:
end;

//function _icWordPos_bug1(const Word: Word; const S: ANSIString;
//const StartPos: integer = 1): integer; assembler asm
//  @@Start: push ebx; test S, S; jz @@zero // check S length
//    or StartPos, StartPos; jg @@begin //still need to be checked
//  @@zero: xor eax, eax; jmp @@Stop
//  @@begin: push edi; push esi
//  lea esi, S + StartPos -1
//  sub StartPos, S.SzLen; jge @@notfound
//    lea edi, locasetable
//    xor ebx, ebx
//    mov bl, ah
//    mov bh, edi[ebx]
//    and eax, MAXBYTE
//    mov bl, edi[eax]
//  @@test1:
//    cmp bl, eax[UPCASETABLE]; jne @@_LoopCC
//  @@test2:
//    mov al, bh
//    cmp bh, eax[UPCASETABLE]; jne @@_LoopCC
//    mov eax, ebx
//  @@_LoopNC:
//    cmp al, [esi]; lea esi, esi +1; je @@foundNC
//    inc StartPos; jl @@_LoopNC; jmp @@notfound
//  @@foundNC:
//    cmp ah, [esi]; lea esi, esi +1; je @@found;
//    add StartPos, 2; jl @@_LoopNC; jmp @@notfound
//  @@_LoopCC: // better play safe here
//    mov al, [esi]; lea esi, esi +1
//    cmp bl, edi[eax]; je @@foundCC;
//    inc StartPos; jl @@_LoopCC; jmp @@notfound
//  @@foundCC:
//    mov al, [esi]; lea esi, esi +1
//    cmp bh, edi[eax]; je @@found;
//    add StartPos, 2; jl @@_LoopCC
//  @@notfound: mov esi, S; inc esi
//  @@found: sub esi, S; lea eax, esi-1
//  @@end: pop esi; pop edi
//  @@Stop: pop ebx
//end;

function _icWordPos(const Word: Word; const S: ANSIString;
const StartPos: integer = 1): integer; assembler asm
  @@Start: push ebx; test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push edi; push esi
  lea esi, S + StartPos -1
  sub StartPos, S.SzLen; jge @@notfound
    lea edi, locasetable
    xor ebx, ebx
    mov bl, ah
    mov bh, edi[ebx]
    and eax, MAXBYTE
    mov bl, edi[eax]
  @@test1:
    cmp bl, byte ptr eax[UPCASETABLE]; jne @@_LoopCC
  @@test2:
    mov al, bh
    cmp bh, byte ptr eax[UPCASETABLE]; jne @@_LoopCC
    mov eax, ebx
  @@_LoopNC:
    cmp al, [esi]; lea esi, esi +1; je @@foundNC
    inc StartPos; jl @@_LoopNC; jmp @@notfound
  @@foundNC:
    cmp ah, [esi]; je @@found;
    inc StartPos; jl @@_LoopNC; jmp @@notfound
  @@_LoopCC: // better play safe here
    mov al, [esi]; lea esi, esi +1
    cmp bl, edi[eax]; je @@foundCC;
    inc StartPos; jl @@_LoopCC; jmp @@notfound
  @@foundCC:
    mov al, [esi];
    cmp bh, edi[eax]; je @@found;
    inc StartPos; jl @@_LoopCC
  @@notfound: mov esi, S; //inc esi //botch! :(
  @@found: sub esi, S; mov eax, esi
  @@end: pop esi; pop edi
  @@Stop: pop ebx
end;

//function _icWordCount_bug1(const Word: Word; const S: ANSIString;
//const StartPos: integer = 1): integer; assembler asm
//  @@Start: push ebx; test S, S; jz @@zero // check S length
//    or StartPos, StartPos; jg @@begin //still need to be checked
//  @@zero: xor eax, eax; jmp @@Stop
//  @@begin: push edi; push esi
//  lea esi, S + StartPos -1
//  sub StartPos, S.SzLen; mov S, 0; jge @@done
//    lea edi, locasetable
//    xor ebx, ebx
//    mov bl, ah
//    mov bh, edi[ebx]
//    and eax, MAXBYTE
//    mov bl, edi[eax]
//  @@test1:
//    cmp bl, eax[UPCASETABLE]; jne @@_LoopCC
//  @@test2:
//    mov al, bh
//    cmp bh, eax[UPCASETABLE]; jne @@_LoopCC
//    mov eax, ebx
//  @@_LoopNC:
//    cmp al, [esi]; lea esi, esi +1; je @@foundNC
//    inc StartPos; jl @@_LoopNC; jmp @@done
//  @@foundNC:
//    cmp ah, [esi]; lea esi, esi +1; jne @@_NC; inc S
//  @@_NC:add StartPos, 2; jl @@_LoopNC; jmp @@done
//  @@_LoopCC:
//    mov al, [esi]; lea esi, esi +1
//    cmp bl, edi[eax]; je @@foundCC
//    inc StartPos; jl @@_LoopCC; jmp @@done
//  @@foundCC:
//    mov al, [esi]; lea esi, esi +1
//    cmp bh, edi[eax]; jne @@_CC; inc S
//    @@_CC:add StartPos, 2; jl @@_LoopCC
//  //@@notfound: mov esi, S
//  //@@found: sub esi, S; mov eax, esi
//  @@done: mov eax, S
//  @@end: pop esi; pop edi
//  @@Stop: pop ebx
//end;

function _icWordCount(const Word: Word; const S: ANSIString;
const StartPos: integer = 1): integer; assembler asm
  @@Start: push ebx; test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push edi; push esi
  lea esi, S + StartPos -1
  sub StartPos, S.SzLen; mov S, 0; jge @@done
    lea edi, locasetable
    xor ebx, ebx
    mov bl, ah
    mov bh, edi[ebx]
    and eax, MAXBYTE
    mov bl, edi[eax]
  @@test1:
    cmp bl, byte ptr eax[UPCASETABLE]; jne @@_LoopCC
  @@test2:
    mov al, bh
    cmp bh, byte ptr eax[UPCASETABLE]; jne @@_LoopCC
    mov eax, ebx
  @@_LoopNC:
    cmp al, [esi]; lea esi, esi +1; je @@foundNC
    inc StartPos; jl @@_LoopNC; jmp @@done
  @@foundNC: cmp ah, [esi]; jne @@_NC; inc S
  @@_NC:inc StartPos; jl @@_LoopNC; jmp @@done
  @@_LoopCC:
    mov al, [esi]; lea esi, esi +1
    cmp bl, edi[eax]; je @@foundCC
    inc StartPos; jl @@_LoopCC; jmp @@done
  @@foundCC:
    mov al, [esi];
    cmp bh, edi[eax]; jne @@_CC; inc S
    @@_CC:inc StartPos; jl @@_LoopCC
  //@@notfound: mov esi, S
  //@@found: sub esi, S; mov eax, esi
  @@done: mov eax, S
  @@end: pop esi; pop edi
  @@Stop: pop ebx
end;

// doublebyte

//function pcWCharPos_bug1(const Word: Word; const P: PChar; const StartPos,
//PLength: cardinal): integer register; assembler asm //overload forward
//  //@@Start: test S, S; jz @@zero // check S length
//  //  or StartPos, StartPos; jg @@begin //still need to be checked
//  //@@zero: xor eax, eax; jmp @@Stop
//  @@begin: push esi
//    and eax, MAXWORD
//    lea esi, P + StartPos -1
//    sub StartPos, PLength; jge @@notfound
//  @_Loop: // better play safe here
//    cmp al, [esi]; lea esi, esi +1; je @@found1
//    inc StartPos; jl @_Loop; jmp @@notfound
//  @@found1:
//    cmp ah, [esi]; lea esi, esi +1; je @@found
//    add StartPos, 2; jl @_Loop
//  @@notfound: xor eax, eax; jmp @@end//mov esi, S; inc esi
//  @@found: sub esi, P; lea eax, esi -1
//  @@end: pop esi
//  @@Stop:
//end;

function pcWCharPos(const Word: Word; const P: PChar; const StartPos,
PLength: cardinal): integer register; assembler asm //overload forward
  @@Start: test P, P; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi
    lea esi, P + StartPos -1
    sub StartPos, PLength; jge @@notfound
  @_Loop: // better play safe here
    cmp al, [esi]; lea esi, esi +1; je @@found1
    inc StartPos; jl @_Loop; jmp @@notfound
  @@found1:
    cmp ah, [esi]; je @@found
    inc StartPos; jl @_Loop
  @@notfound: xor eax, eax; jmp @@end
  @@found: sub esi, P; mov eax, esi
  @@end: pop esi
  @@Stop:
end;

//function piWCharPos_bug1(const Word: Word; const P: PChar; const StartPos,
//PLength: cardinal): integer register; assembler asm //overload forward
//  @@begin: push ebx; push edi; push esi
//  lea esi, P + StartPos -1
//  sub StartPos, PLength; jge @@notfound
//    lea edi, locasetable
//    xor ebx, ebx
//    mov bl, ah
//    mov bh, edi[ebx]
//    and eax, MAXBYTE
//    mov bl, edi[eax]
//  @@test1:
//    cmp bl, eax[UPCASETABLE]; jne @@_LoopCC
//  @@test2:
//    mov al, bh
//    cmp bh, eax[UPCASETABLE]; jne @@_LoopCC
//    mov eax, ebx
//  @@_LoopNC:
//    cmp al, [esi]; lea esi, esi +1; je @@foundNC
//    inc StartPos; jl @@_LoopNC; jmp @@notfound
//  @@foundNC:
//    cmp ah, [esi]; lea esi, esi +1; je @@found;
//    add StartPos, 2; jl @@_LoopNC; jmp @@notfound
//  @@_LoopCC: // better play safe here
//    mov al, [esi]; lea esi, esi +1
//    cmp bl, edi[eax]; je @@foundCC;
//    inc StartPos; jl @@_LoopCC; jmp @@notfound
//  @@foundCC:
//    mov al, [esi]; lea esi, esi +1
//    cmp bh, edi[eax]; je @@found;
//    add StartPos, 2; jl @@_LoopCC
//  @@notfound: mov esi, P; inc esi
//  @@found: sub esi, P; lea eax, esi-1
//  @@end: pop esi; pop edi; pop ebx
//end;

function piWCharPos(const Word: Word; const P: PChar; const StartPos,
PLength: cardinal): integer register; assembler asm //overload forward
  @@begin: push ebx; push edi; push esi
  lea esi, P + StartPos -1
  sub StartPos, PLength; jge @@notfound
    lea edi, locasetable
    xor ebx, ebx
    mov bl, ah
    mov bh, edi[ebx]
    and eax, MAXBYTE
    mov bl, edi[eax]
  @@test1:
    cmp bl, byte ptr eax[UPCASETABLE]; jne @@_LoopCC
  @@test2:
    mov al, bh
    cmp bh, byte ptr eax[UPCASETABLE]; jne @@_LoopCC
    mov eax, ebx
  @@_LoopNC:
    cmp al, [esi]; lea esi, esi +1; je @@foundNC
    inc StartPos; jl @@_LoopNC; jmp @@notfound
  @@foundNC:
    cmp ah, [esi]; je @@found
    inc StartPos; jl @@_LoopNC; jmp @@notfound
  @@_LoopCC: // better play safe here
    mov al, [esi]; lea esi, esi +1
    cmp bl, edi[eax]; je @@foundCC;
    inc StartPos; jl @@_LoopCC; jmp @@notfound
  @@foundCC:
    mov al, [esi];
    cmp bh, edi[eax]; je @@found;
    inc StartPos; jl @@_LoopCC
  @@notfound: mov esi, P; //inc esi //booogie! :(((
  @@found: sub esi, P; mov eax, esi
  @@end: pop esi; pop edi; pop ebx
end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  move, compare & conversion routines
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//
// procedure XMove(const Src; var Dest; Count: integer); assembler asm
// // effective only for bulk transfer, moving 4 bytes at the speed of 1,
// // pairing enabled, no AGI-stalls, no magic (expect degradation, if
// // either Src or Dest or worst:  both are not 4 bytes aligned)
//     push esi; push edi
//     mov esi, Src; mov edi, Dest
//     mov ecx, Count; mov eax, ecx
//     sar ecx, 2; js @@end
//     push eax; jz @@recall
//   @@LoopDWord:
//     mov eax, [esi]; lea esi, esi +4
//     mov [edi], eax; lea edi, edi +4
//     dec ecx; jg @@LoopDWord
//   @@recall: pop ecx
//     and ecx, 03h; jz @@LoopDone
//   @@LoopByte:
//     mov al, [esi]; lea esi, esi +1
//     mov [edi], al; lea edi, edi +1
//     dec ecx; jg @@LoopByte
//   @@LoopDone:
//   @@end: pop edi; pop esi
// end;

procedure XMove(const Source; var Dest; const Count: Integer); assembler asm
//originated from fastCode (John O'Harrow) fast! Move
  cmp eax,edx; je @@exit;
  cmp ecx,20h; ja @@move;   //caution! also of (Count < 0)
  sub ecx,08h; jg @@QQ;     //1Q+1 to 3Q
  jmp ecx*4+20h+@@dbJmp;    //upto 1Q
@@QQ: fild qword[eax]; fild qword[eax+ecx];  //load firstQ/lastQ
  cmp ecx,08h; jle @@2Q; fild qword[eax+8];  //load 2nd*Q
  cmp ecx,10h; jle @@3Q;
  fild qword[eax+10h]; fistp qword[edx+10h]; //load/save 3rd*Q
@@3Q: fistp qword[edx+08h];                  //save 2nd*Q
@@2Q: fistp qword[edx+ecx]; fistp qword[edx];//save lastQ/firstQ
@@exit: ret; mov eax,eax
@@dbJmp: dd @@exit, @@1, @@2, @@3, @@4, @@5, @@6, @@7, @@8
@@fmove: push edx; fild qword[eax];          //firstQ
  lea eax,[eax+ecx-8]; lea ecx,[ecx+edx-8];
  push ecx; neg ecx; fild qword[eax];        //lastQ
  lea ecx,[ecx+edx+8]; pop edx;              //Q-aligned
  @@LoopQ1: fild qword[eax+ecx]; fistp qword[edx+ecx];
    add ecx,8; jl @@LoopQ1;
  fistp qword[edx];                          //lastQ
  pop edx; fistp qword[edx]; ret;            //firstQ
@@move: jg @@gmove; ret                      //(Count < 0)
@@gmove: cmp eax,edx; ja @@fmove;
  sub edx,ecx; cmp eax,edx;
  lea edx,[edx+ecx]; jna @@fmove;
  sub ecx,8; push ecx;                       //backward
  fild qword[eax+ecx]; fild qword[eax];      //LAST-Q/firstQ
  add ecx,edx; and ecx,not 7; sub ecx,edx;   //Q-aligned
  @@LoopQBack: fild qword[eax+ecx]; fistp qword[edx+ecx];
    sub ecx,8; jg @@LoopQBack;
  pop ecx; fistp qword[edx]; fistp qword[edx+ecx]; //FIRST-Q/lastQ
@@done: ret
@@1: mov  cl,[eax]; mov [edx], cl; ret;
@@2: mov  cx,[eax]; mov [edx], cx; ret;
@@4: mov ecx,[eax]; mov [edx],ecx; ret;
@@3: mov  cx,[eax]; mov  al,[eax+2]; mov [edx], cx; mov [edx+2], al; ret;
@@5: mov ecx,[eax]; mov  al,[eax+4]; mov [edx],ecx; mov [edx+4], al; ret;
@@6: mov ecx,[eax]; mov  ax,[eax+4]; mov [edx],ecx; mov [edx+4], ax; ret;
@@7: mov ecx,[eax]; mov eax,[eax+3]; mov [edx],ecx; mov [edx+3],eax; ret;
@@8: fild [eax].qword; fistp [edx].qword;
//@@exit:
end;

//do-not-remove
//function iCompare_old(const S1, S2: string): integer; assembler asm
//  @@Start: push esi; push edi; push ebx
//    mov esi, eax; mov edi, edx
//    xor ebx, ebx
//    or eax, eax; je @@zeroS1
//    mov eax, eax.SzLen
//  @@zeroS1:
//    or edx, edx; je @@zeroS2
//    mov edx, edx.SzLen
//  @@zeroS2:
//    mov ecx, eax
//    cmp ecx, edx; jbe @@2
//    mov ecx, edx
//  @@2: dec ecx; jl @@done
//  @@3:
//    mov bl, [esi]; lea esi, esi +1
//    cmp bl, [edi]; lea edi, edi +1
//    je @@2
//    mov bl, byte ptr LOCASETABLE[ebx]
//    cmp bl, [edi -1]; je @@3
//    xor eax, eax; mov al, [esi-1]
//    xor edx, edx; mov dl, [edi-1]
//  @@done:
//    sub eax, edx
//    pop ebx; pop edi; pop esi
//  @@Stop:
//end;

function _cCompare(const S1, S2: string): integer; assembler asm //
// efficient for long string
  @@Start: push esi; push edi; push ebx
    mov esi, S1; mov edi, S2

    test S1, S1; jz @_DoneAXLen; mov eax, S1.SzLen; @_DoneAXLen:
    test S2, S2; jz @_DoneDXLen; mov edx, S2.SzLen; @_DoneDXLen:

    mov ecx, eax; cmp ecx, edx; jbe @_prep
    mov ecx, edx

  @_prep: push ecx; shr ecx, 2; jz @_single

  @_Loop4: dec ecx; jl @_single
    mov ebx, [edi]; lea edi, edi +4
    cmp ebx, [esi]; lea esi, esi +4
    je @_Loop4

    //mov eax, [esi]; mov edx, ebx; jmp @_atremain //bug!
    mov eax, [esi-4]; mov edx, ebx; jmp @_atremain //fixed

  @_Loopremain: ror eax, 8; ror edx, 8
  @_atremain: cmp al, dl; je @_Loopremain
  @_remdone:
    and eax, $ff; and edx, $ff
    pop ecx; jmp @@done

  @_single: pop ecx; and ecx, 3; jz @@done

  @_Loop1: dec ecx; jl @@done
    mov bl, [esi]; lea esi, esi +1
    cmp bl, [edi]; lea edi, edi +1
    je @_Loop1

    xor eax, eax; mov al, bl
    //xor edx, edx; mov dl, [edi] //bug!
    xor edx, edx; mov dl, [edi-1] //fixed

  @@done:
    sub eax, edx
    pop ebx; pop edi; pop esi
  @@Stop:
end;

function _iCompare(const S1, S2: string): integer; assembler asm //
  //call System.@LStrCmp
  @@Start: push esi; push edi; push ebx; push ebp
    mov esi, S1; mov edi, S2
    xor ebx, ebx; test S1, S1; je @_Zero1

    mov eax, S1.SzLen
  @_Zero1: test edx, edx; je @_Zero2
    mov edx, S2.SzLen
  //@_Zero2: mov ecx, eax; cmp ecx, edx; jbe @@2
  //  mov ecx, edx
  //@@2: dec ecx; jl @@done
  @_Zero2: mov ecx, 0;
    mov ebp, eax; cmp ebp, edx; jbe @@2
    mov ebp, edx
  @@2: dec ebp; jl @@done
  @Loop3:
    mov bl, [esi]; mov cl, [edi];
    lea esi, esi +1; lea edi, edi +1
    mov bl, byte ptr locasetable[ebx]
    mov cl, byte ptr locasetable[ecx]
    cmp bl, cl; je @@2  //fixed
    xor eax, eax; mov al, bl
    //xor edx, edx; mov dl, [edi] //bug!
    xor edx, edx; mov dl, [edi-1] //fixed
    @@done:
    sub eax, edx
    pop ebp; pop ebx; pop edi; pop esi
  @@Stop:
end;

function pcCompare(const P1, P2; const L1, L2: integer): integer; assembler asm //
// efficient for large buffer
  @@Start: push esi; push edi; push ebx
    mov esi, P1; mov edi, P2

    test P1, P1; je @_doneAX; mov eax, L1//eax.SzLen
  @_doneAX:
    test P2, P2; je @_doneDX; mov edx, L2//edx.SzLen
  @_doneDX:
    mov ecx, eax; cmp ecx, edx; jbe @_prep

    mov ecx, edx
  @_prep: push ecx; shr ecx, 2; jz @_single

  @_Loop4: dec ecx; jl @_single
    mov ebx, [edi]; lea edi, edi +4
    cmp ebx, [esi]; lea esi, esi +4
    je @_Loop4

    //mov eax, [esi]; mov edx, ebx; jmp @_atremain //bug!
    mov eax, [esi-4]; mov edx, ebx; jmp @_atremain //fixed

  @_Loopremain: ror eax, 8; ror edx, 8
  @_atremain: cmp al, dl; je @_Loopremain

    and eax, $ff; and edx, $ff
    pop ecx; jmp @@done

  @_single: pop ecx; and ecx, 3; jz @@done

  @_Loop1: dec ecx; jl @@done
    mov bl, [esi]; lea esi, esi +1
    cmp bl, [edi]; lea edi, edi +1
    je @_Loop1

    xor eax, eax; mov al, bl
    //xor edx, edx; mov dl, [edi] //bug!
    xor edx, edx; mov dl, [edi-1] //fixed

  @@done:
    sub eax, edx
    pop ebx; pop edi; pop esi
  @@Stop:
end;

function piCompare(const P1, P2; const L1, L2: integer): integer; assembler asm //
  @@Start: push esi; push edi; push ebx; push ebp
    mov esi, P1; mov edi, P2
    xor ebx, ebx; test eax, eax; je @_Zero1
    mov eax, L1//eax.SzLen
  @_Zero1: test P2, P2; je @_Zero2
    mov edx, L2//edx.SzLen
  //@_Zero2: mov ecx, eax; cmp ecx, edx; jbe @@2
  //  mov ecx, edx
  //@@2: dec ecx; jl @@done
  @_Zero2: mov ecx, 0;
    mov ebp, eax; cmp ebp, edx; jbe @@2
    mov ebp, edx
  @@2: dec ebp; jl @@done
  @Loop3:
    mov bl, [esi]; mov cl, [edi];
    lea esi, esi +1; lea edi, edi +1
    mov bl, byte ptr locasetable[ebx]
    mov cl, byte ptr locasetable[ecx]
    cmp bl, cl; je @@2  //fixed
    xor eax, eax; mov al, bl
    //xor edx, edx; mov dl, [edi] //bug!
    xor edx, edx; mov dl, [edi-1] //fixed
  @@done:
    sub eax, edx
    pop ebp; pop ebx; pop edi; pop esi
  @@Stop:
end;

procedure CaseStr(var S: string; const CharsTable); assembler asm
  @@Start:
    mov S, [S] // S is a VAR! normalize.
    or S, S; jz @@Stop
    push esi; push edi
    push ecx
    mov esi, S
    mov edi, CharsTable
    mov ecx, esi.SzLen
    xor eax, eax
  @@Loop:
    dec ecx; jl @@end
    mov al, esi[ecx]
    cmp al, edi[eax]
    je @@Loop
    mov al, edi[eax]
    mov esi[ecx], al
    jmp @@Loop
  @@end:
    pop ecx
    pop edi; pop esi
  @@Stop:
end;

procedure transBuffer(var Buffer; const Length: integer; const CharsTable); assembler asm
  @@Start:
    mov Buffer, [Buffer] // Buffer is a VAR! normalize.
    or Buffer, Buffer; jz @@Stop
    push esi; push edi
    push ecx
    mov esi, Buffer
    mov edi, CharsTable
    mov ecx, Length//esi.SzLen
    xor eax, eax
  @@Loop:
    dec ecx; jl @@end
    mov al, esi[ecx]
    cmp al, edi[eax]
    je @@Loop
    mov al, edi[eax]
    mov esi[ecx], al
    jmp @@Loop
  @@end:
    pop ecx
    pop edi; pop esi
  @@Stop:
end;

function Uppercased(const S: string): string; assembler asm
// Result = EDX
  test eax, eax; jz @@end
  push esi; push edi
    mov esi, S

    mov eax, Result               // where the result will be stored
    call System.@LStrClr          // cleared for ease
    mov edx, esi.szLen            // how much length of str requested
    call System.@LStrSetLength    // result: new allocation pointer in EAX
    mov edi, [eax]                // eax contains the new allocated pointer
                                  // we got the storage as well at once
    mov edx, 'az'                 // DX=$617A -> DH=$61, DL=$7A
    mov ecx, esi.szLen
    dec ecx                       // 0-wise
    @@Loop:
      mov al, esi+ecx
      cmp al, dl; ja @@store
      cmp al, dh; jb @@store
      sub al, $20
    @@store: mov edi+ecx, al
      dec ecx; jge @@loop         //

    mov eax, edi                  // Result
  pop edi; pop esi
  @@end:
end;

function LowerCased(const S: string): string; assembler asm
// Result = EDX
  test eax, eax; jz @@end
  push esi; push edi
    mov esi, S

    mov eax, Result               // where the result will be stored
    call System.@LStrClr          // cleared for ease
    mov edx, esi.szLen            // how much length of str requested
    call System.@LStrSetLength    // result: new allocation pointer in EAX
    mov edi, [eax]                // eax contains the new allocated pointer
                                  // we got the storage as well at once
    mov edx, 'AZ'                 // DX=$415A -> DH=$41, DL=$5A
    mov ecx, esi.szLen
    dec ecx                       // 0-wise
    @@Loop:
      mov al, esi+ecx
      cmp al, dl; ja @@store
      cmp al, dh; jb @@store
      or al, $20
    @@store: mov edi+ecx, al
      dec ecx; jge @@loop

    mov eax, edi                  // Result
  pop edi; pop esi
  @@end:
end;

//******************************************************************
// additional ~ inverted, find any char except the one is specified
// this actually is written later
//******************************************************************
// find position of char which is NOT in the table/CharClass (inverted version of charpos)

function InvCharPos(const S: string; const Ch: Char; const StartPos: integer = 1; const Backwise: boolean = FALSE): integer; overload;
begin
  if backwise then
    Result := _vbcCharPos(Ch, S, StartPos)
  else
    Result := _vcCharPos(Ch, S, StartPos)
end;

function BackInvCharPos(const S: string; const Ch: Char; const BackFromPos: integer): integer; overload;
begin
  Result := _vbcCharPos(Ch, S, BackFromPos)
end;

//*********************************************
// Indexed / CharClass / Charset Object Search
//*********************************************

//--------------------
// primitive routines
//--------------------

function _xCharPos(const table: TCharsetIndexTable; const S: string; const StartPos: integer): integer;
//indexed CharPos
assembler asm
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi; push edi; push ebx
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; jg @@notfound
    mov edi, table; xor eax, eax; mov ebx, 1
  @_Loop:
    mov al, [esi]; test [edi+eax*4], ebx
    lea esi, esi +1; jnz @@found // NZ = found; ZF = notfound
    inc StartPos; jle @_Loop
  @@notfound: mov esi, S
  @@found: sub esi, S; mov eax, esi
  @@end: pop ebx; pop edi; pop esi
  @@Stop:
end;

function bxCharPos(const table: TCharsetIndexTable; const S: string; const StartPos: integer): integer;
//indexed backPos
assembler asm
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi; push edi; push ebx
    lea esi, S + StartPos -1
    cmp StartPos, S.SzLen; jg @@notfound
    mov edi, table; xor eax, eax; mov ebx, 1
  @_Loop:
    mov al, [esi]; test [edi+eax*4], ebx
    lea esi, esi -1; jnz @@found // NZ = found; ZF = notfound
    dec StartPos; jg @_Loop
  @@notfound: mov StartPos, 0
  @@found: mov eax, StartPos
  @@end: pop ebx; pop edi; pop esi
  @@Stop:
end;

function vxCharPos(const table: TCharsetIndexTable; const S: string; const StartPos: integer): integer;
//find position of char which is NOT in the table
assembler asm
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi; push edi; push ebx
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; jg @@notfound
    mov edi, table; xor eax, eax; mov ebx, 1
  @_Loop:
    mov al, [esi]; test [edi+eax*4], ebx
    lea esi, esi +1; jz @@found // inverted! NZ = found; ZF = notfound
    inc StartPos; jle @_Loop
  @@notfound: mov esi, S
  @@found: sub esi, S; mov eax, esi
  @@end: pop ebx; pop edi; pop esi
  @@Stop:
end;

function vbxCharPos(const table: TCharsetIndexTable; const S: string; const StartPos: integer): integer; overload;
//find position of char which is NOT in the table
assembler asm
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi; push edi; push ebx
    lea esi, S + StartPos -1
    cmp StartPos, S.SzLen; jg @@notfound
    mov edi, table; xor eax, eax; mov ebx, 1
  @_Loop:
    mov al, [esi]; test [edi+eax*4], ebx
    lea esi, esi -1; jz @@found // inverted! NZ = found; ZF = notfound
    dec StartPos; jg @_Loop
  @@notfound: mov StartPos, 0
  @@found: mov eax, StartPos
  @@end: pop ebx; pop edi; pop esi
  @@Stop:
end;

function _eCharPos(const Charset: TChPosCharset; const S: string; const StartPos: integer): integer;
//Charset CharPos
assembler asm
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi; push edi; push ebx
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; jg @@notfound
    mov edi, Charset; xor eax, eax; //mov ebx, 1
  @_Loop:
    mov al, [esi]; bt [edi], ax
    lea esi, esi +1; jc @@found // CF = found; NC = notfound
    inc StartPos; jle @_Loop
  @@notfound: mov esi, S
  @@found: sub esi, S; mov eax, esi
  @@end: pop ebx; pop edi; pop esi
  @@Stop:
end;

function beCharPos(const Charset: TChPosCharset; const S: string; const StartPos: integer): integer;
//indexed backPos
assembler asm
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi; push edi; push ebx
    lea esi, S + StartPos -1
    cmp StartPos, S.SzLen; jg @@notfound
    mov edi, Charset; xor eax, eax; //mov ebx, 1
  @_Loop:
    mov al, [esi]; bt [edi], ax
    lea esi, esi -1; jc @@found // CF = found; NC = notfound
    dec StartPos; jg @_Loop
  @@notfound: mov StartPos, 0
  @@found: mov eax, StartPos
  @@end: pop ebx; pop edi; pop esi
  @@Stop:
end;

function veCharPos(const Charset: TChPosCharset; const S: string; const StartPos: integer): integer;
//find position of char which is NOT in the table
assembler asm
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi; push edi; push ebx
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; jg @@notfound
    mov edi, Charset; xor eax, eax; //mov ebx, 1
  @_Loop:
    mov al, [esi]; bt [edi], ax
    lea esi, esi +1; jnc @@found // inverted! CF = found; NC = notfound
    inc StartPos; jle @_Loop
  @@notfound: mov esi, S
  @@found: sub esi, S; mov eax, esi
  @@end: pop ebx; pop edi; pop esi
  @@Stop:
end;

function vbeCharPos(const Charset: TChPosCharset; const S: string; const StartPos: integer): integer;
//find position of char which is NOT in the table
assembler asm
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi; push edi; push ebx
    lea esi, S + StartPos -1
    cmp StartPos, S.SzLen; jg @@notfound
    mov edi, Charset; xor eax, eax; //mov ebx, 1
  @_Loop:
    mov al, [esi]; bt [edi], ax
    lea esi, esi -1; jnc @@found // inverted! CF = found; NC = notfound
    dec StartPos; jg @_Loop
  @@notfound: mov StartPos, 0
  @@found: mov eax, StartPos
  @@end: pop ebx; pop edi; pop esi
  @@Stop:
end;

// -----------------------------------------------------------------------
//  interface charpos routines for indexed/charclass (predefined charset)
// -----------------------------------------------------------------------

function CharPos(const S: string; const table: TCharsetIndexTable; const StartPos: integer; const Backwise: boolean): integer;
begin
  if Backwise then
    Result := bxCharPos(table, S, StartPos)
  else
    Result := _xCharPos(table, S, StartPos)
end;

function CharPos(const S: string; const CharClass: TCharClass; const StartPos: integer; const Backwise: boolean): integer;
begin
  if Backwise then
    Result := bxCharPos(ChposK.ChposIndexTables[CharClass], S, StartPos)
  else
    Result := _xCharPos(ChposK.ChposIndexTables[CharClass], S, StartPos);
end;

function BackCharPos(const S: string; const table: TCharsetIndexTable; const BackFromPos: integer): integer;
begin
  Result := bxCharPos(table, S, BackFromPos)
end;

function BackCharPos(const S: string; const CharClass: TCharClass; const BackFromPos: integer): integer;
begin
  Result := bxCharPos(ChposK.ChposIndexTables[CharClass], S, BackFromPos)
end;

function InvCharPos(const S: string; const table: TCharsetIndexTable; const StartPos: integer = 1; const Backwise: boolean = FALSE): integer; overload;
//find position of char which is NOT in the CharClass
begin
  if Backwise then
    Result := vbxCharPos(table, S, StartPos)
  else
    Result := vxCharPos(table, S, StartPos);
end;

function InvCharPos(const S: string; const CharClass: TCharClass; const StartPos: integer = 1; const Backwise: boolean = FALSE): integer; overload;
//find position of char which is NOT in the CharClass
begin
  if Backwise then
    Result := vbxCharPos(ChposK.ChposIndexTables[CharClass], S, StartPos)
  else
    Result := vxCharPos(ChposK.ChposIndexTables[CharClass], S, StartPos);
end;

function BackInvCharPos(const S: string; const table: TCharsetIndexTable; const BackFromPos: integer): integer;
begin
  Result := vbxCharPos(table, S, BackFromPos)
end;

function BackInvCharPos(const S: string; const CharClass: TCharClass; const BackFromPos: integer): integer;
begin
  Result := vbxCharPos(ChposK.ChposIndexTables[CharClass], S, BackFromPos)
end;

// ----------------------------------------------------
// interface charpos routines for customizable charset
// ----------------------------------------------------

function CharPos(const S: string; const Charset: TChPosCharset; const StartPos: integer; const Backwise: boolean): integer; overload
begin
  if Backwise then
    Result := beCharPos(Charset, S, StartPos)
  else
    Result := _eCharPos(Charset, S, StartPos)
end;

function BackCharPos(const S: string; const Charset: TChPosCharset; const BackFromPos: integer): integer;
begin
  Result := beCharPos(Charset, S, BackFromPos)
end;

function InvCharPos(const S: string; const Charset: TChPosCharset; const StartPos: integer = 1; const Backwise: boolean = FALSE): integer; overload;
//find position of char which is NOT in the CharClass
begin
  if Backwise then
    Result := vbeCharPos(Charset, S, StartPos)
  else
    Result := veCharPos(Charset, S, StartPos);
end;

function BackInvCharPos(const S: string; const Charset: TChPosCharset; const BackFromPos: integer): integer;
begin
  Result := vbeCharPos(Charset, S, BackFromPos)
end;

//=============================================

function Strip(const S: string; const table: TCharsetIndexTable;
const StartPos: integer = 1): string; assembler asm
  xor eax, eax; jmp @@Stop
// unfinished- do not use!
  test S, S; jz @zero
  or StartPos, StartPos; jle @zero
  cmp StartPos, S-4; jle @Start // S-4 never be negative. did they?
  @zero: xor eax, eax; ret 4

@Start:
  push esi; push edi
  mov esi, S
  mov eax, Result
  push ecx; push edx
  call System.@LStrClr
  mov edx, esi-4
  call System.@LStrSetLength
  mov ecx, [esp]
  dec ecx
  pop ecx
  pop edi; pop esi
  @@Stop:
end;

function CharCount(const CharsetIndexTable: TCharsetIndexTable;
  const S: string; const StartPos: integer = 1): integer; overload;
assembler asm
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin // still need to be checked
  @@zero:
    xor eax, eax; jmp @@EXIT
  @@begin: push esi; push edi; push ebx
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; mov S, 0; jg @@done
    mov edi, CharsetIndexTable; xor eax, eax; mov ebx, 1
    @_Loop:
      mov al, [esi]; test [edi+eax*4], ebx
      lea esi, esi +1; jz @_ // ZF = notfound; NZ = found
      ; inc S
    @_: inc StartPos; jle @_Loop
  @@done: mov eax, S
  @@end: pop ebx; pop edi; pop esi
  @@EXIT:
  end;

function CharCount(const Charset: TChPosCharset; const S: string;
  const StartPos: integer = 1): integer; overload;
//function CharClassCount(const table: TCharsetIndexTable; const S: string; const StartPos: integer = 1): integer;
assembler asm
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin // still need to be checked
  @@zero:
    xor eax, eax; jmp @@EXIT
  @@begin: push esi; push edi; push ebx
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; mov S, 0; jg @@done
    mov edi, Charset; xor eax, eax; //mov ebx, 1
    @_Loop:
      mov al, [esi]; bt [edi], ax
      lea esi, esi +1; adc S, 0 // CF = found; NC = notfound
      //; inc S
    @_: inc StartPos; jle @_Loop
  @@done: mov eax, S
  @@end: pop ebx; pop edi; pop esi
  @@EXIT:
end;

function CharCount(const CharsetClass: TCharClass; const S: string;
  const StartPos: integer): integer; overload;
begin
  Result := CharCount(ChposK.ChposIndexTables[CharsetClass], S, StartPos);
end;

// get position of n-th (index) character found in the string
//function CharAtIndex_old1(const table: TCharsetIndexTable; const S: string; const StartPos: integer { = 1}; const Index: integer): integer; overload assembler asm
//  @@Start: test S, S; jz @@zero // check S length
//    or StartPos, StartPos; jg @@begin //still need to be checked
//  @@zero: xor eax, eax; jmp @@Stop
//  @@begin: push esi; push edi; push ebx; push S
//    lea esi, S + StartPos -1
//    sub StartPos, S.SzLen; jg @@notfound
//    mov S, Index; dec S; jl @@notfound
//    mov edi, table; xor eax, eax; mov ebx, 1
//  @_Loop:
//    mov al, [esi]; test [edi+eax*4], ebx
//    lea esi, esi +1; jz @_// ZF = notfound; NZ = found
//    dec S; jl @@found
//  @_:inc StartPos; jle @_Loop
//  @@notfound: mov esi, [esp]
//  @@found: sub esi, [esp]; mov eax, esi
//  @@end: pop S; pop ebx; pop edi; pop esi
//  @@Stop:
//end;
//
//function CharAtIndex_old1(const Charset: TChPosCharset; const S: string; const StartPos: integer { = 1}; const Index: integer): integer; overload assembler asm
//  @@Start: test S, S; jz @@zero // check S length
//    or StartPos, StartPos; jg @@begin //still need to be checked
//  @@zero: xor eax, eax; jmp @@Stop
//  @@begin: push esi; push edi; push ebx; push S
//    lea esi, S + StartPos -1
//    sub StartPos, S.SzLen; jg @@notfound
//    mov S, Index; dec S; jl @@notfound
//    mov edi, Charset; xor eax, eax; //mov ebx, 1
//  @_Loop:
//    mov al, [esi]; bt [edi], ax
//    lea esi, esi +1; //jnc @_// CF = found; NC = notfound
//    //dec S; jl @@found
//    sbb S,0; jl @@found
//  @_:inc StartPos; jle @_Loop
//  @@notfound: mov esi, [esp]
//  @@found: sub esi, [esp]; mov eax, esi
//  @@end: pop S; pop ebx; pop edi; pop esi
//  @@Stop:
//end;
//

function CharAtIndex(const CharsetIndexTable: TCharsetIndexTable; const S: string;
const Index: integer; const StartPos: integer): integer; assembler asm
  @@Start: test S, S; jz @@zero // check S length
    test Index, Index; jle @@zero
    test StartPos, -1; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi; mov esi, S
    push edi; push ebx; mov ebx, StartPos
    push S; mov edx, ebx
    sub edx, esi.SzLen; jg @_notfound
    lea esi, esi+ebx-1
    mov edi, CharsetIndexTable; xor eax, eax; xor ebx, ebx
  @@Loop:
    mov al, [esi]; movzx ebx, byte[edi+eax*4]
    neg ebx; lea esi, esi+1
    sbb Index, 0; jz @@found
    inc edx; jle @@Loop
  @_notfound:  mov esi, [esp]
  @@found: mov eax, esi; pop S; sub eax, S
  @@end: pop ebx; pop edi
  @@out: pop esi
  @@Stop:
end;

function CharAtIndex(const Charset: TChPosCharset; const S: string;
const Index: integer; const StartPos: integer): integer; assembler asm
  @@Start: test S, S; jz @@zero // check S length
    test Index, Index; jle @@zero
    test StartPos, -1; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi; mov esi, S
    push edi; push ebx; mov ebx, StartPos
    push S; mov edx, ebx
    sub edx, esi.SzLen; jg @_notfound
    lea esi, esi+ebx-1
    mov edi, Charset; xor eax, eax; //xor ebx, ebx
  @@Loop:
    mov al, [esi]; bt [edi], ax
    //neg ebx;
    lea esi, esi+1
    sbb Index, 0; jz @@found
    inc edx; jle @@Loop
  @_notfound:  mov esi, [esp]
  @@found: mov eax, esi; pop S; sub eax, S
  @@end: pop ebx; pop edi
  @@out: pop esi
  @@Stop:
end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// implementation & samples
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function UPPERSTR(const S: string): string;
begin
  Result := S;
  //SetLength(Result, length(S));
  UniqueString(Result);
  CaseStr(Result, UPCASETABLE);
end;

function lowerstr(const S: string): string;
begin
  Result := S;
  //SetLength(Result, length(S));
  UniqueString(Result);
  CaseStr(Result, locasetable);
end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// OLD-OLD trimmer routines
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
//function trimStr(const S: string): string;
//var
//  i, Len: integer;
//begin
//  i := 1;
//  Len := Length(S);
//  while (i <= Len) and (S[i] <= ' ') do
//    inc(i);
//  if i > Len then
//    Result := ''
//  else begin
//    while S[Len] <= ' ' do
//      dec(Len);
//    Result := Copy(S, i, Len - i + 1);
//  end;
//end;
//
//function trimStr(const S: string; const Delimiters: TChPosCharset): string; //overload;
//var
//  i, Len: integer;
//begin
//  i := 1;
//  Len := Length(S);
//  while (i <= Len) and (S[i] in Delimiters) do
//    inc(i);
//  if i > Len then
//    Result := ''
//  else begin
//    while S[Len] in Delimiters do
//      dec(Len);
//    Result := Copy(S, i, Len - i + 1);
//  end;
//end;
//
//function trimStr(const S: string; const Delimiters: TChPosCharset; StartPos: integer = 1): string; //overload;
//var
//  Len: integer;
//begin
//  Len := Length(S);
//  while (StartPos <= Len) and (S[StartPos] in Delimiters) do
//    inc(StartPos);
//  if StartPos > Len then
//    Result := ''
//  else begin
//    while S[Len] in Delimiters do
//      dec(Len);
//    Result := Copy(S, StartPos, Len - StartPos + 1);
//  end;
//end;
//
//function trimmed(const S: string; const Delimiter: Char; StartPos: integer = 1): string; //overload;
//var
//  Len: integer;
//begin
//  Len := Length(S);
//  while (StartPos <= Len) and (S[StartPos] = Delimiter) do
//    inc(StartPos);
//  if StartPos > Len then
//    Result := ''
//  else begin
//    while S[Len] = Delimiter do
//      dec(Len);
//    Result := Copy(S, StartPos, Len - StartPos + 1);
//  end;
//end;
//
//function trimmed(const S: string; const Delimiters: TChPosCharset; StartPos: integer = 1): string; //overload;
//var
//  Len: integer;
//begin
//  Len := Length(S);
//  while (StartPos <= Len) and (S[StartPos] in Delimiters) do
//    inc(StartPos);
//  if StartPos > Len then
//    Result := ''
//  else begin
//    while S[Len] in Delimiters do
//      dec(Len);
//    Result := Copy(S, StartPos, Len - StartPos + 1);
//  end;
//end;
//
//function trimSLeft(const S: string; StartPos: integer = 1): string; //overload;
//var
//  L: integer;
//begin
//  L := Length(S);
//  while (StartPos <= L) and (S[StartPos] <= ' ') do
//    inc(StartPos);
//  if StartPos > L then
//    Result := ''
//  else begin
//    while S[L] <= ' ' do
//      dec(L);
//    Result := Copy(S, StartPos, L - StartPos + 1);
//  end;
//end;
//
//function trimSLeft(const S: string; const Delimiters: TChPosCharset; StartPos: integer = 1): string; //overload;
//var
//  L: integer;
//begin
//  L := Length(S);
//  while (StartPos <= L) and (S[StartPos] in Delimiters) do
//    inc(StartPos);
//  if StartPos > L then
//    Result := ''
//  else begin
//    while S[L] in Delimiters do
//      dec(L);
//    Result := Copy(S, StartPos, L - StartPos + 1);
//  end;
//end;
//
//function trimSRight(const S: string): string;
//var
//  i: integer;
//begin
//  i := Length(S);
//  while (i > 0) and (S[i] <= ' ') do
//    dec(i);
//  Result := Copy(S, 1, i);
//end;
//
//function trimSRight(const S: string; const Delimiters: TChPosCharset): string; //overload;
//var
//  i: integer;
//begin
//  i := Length(S);
//  while (i > 0) and (S[i] in Delimiters) do
//    dec(i);
//  Result := Copy(S, 1, i);
//end;
//
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// function trimStr(const S: string; const StartPos: integer = 1): string;
// // this routine is IDENTICAL with trimmed
// // note: startpos argument will effectively truncate the string before startpos value
// var
//   i, j: integer;
// begin
//   Result := '';
//   if S <> '' then begin
//     i := ChPos.vxCharPos(ChposK.ChposIndexTables[chsCntrlSpace], S, StartPos);
//     if i > 0 then begin
//       j := ChPos.vbxCharPos(ChposK.ChposIndexTables[chsCntrlSpace], S, Length(S));
//       Result := copy(S, i, j - i + 1)
//     end;
//   end;
// end;
//
// function trimStr(const S: string; const Delimiter: Char; const StartPos: integer = 1): string; //overload;
// // this routine is IDENTICAL with trimmed
// // note: startpos argument will effectively truncate the string before startpos value
// var
//   i, j: integer;
// begin
//   Result := '';
//   if S <> '' then begin
//     i := ChPos._vcCharPos(Delimiter, S, StartPos);
//     if i > 0 then begin
//       j := ChPos._vbcCharPos(Delimiter, S, Length(S));
//       Result := copy(S, i, j - i + 1)
//     end;
//   end;
// end;
//
// function trimStr(const S: string; const Delimiters: TChPosCharset; const StartPos: integer = 1): string; //overload;
// this routine is IDENTICAL with trimmed
// note: startpos argument will effectively truncate the string before startpos value
// var
//   i, j: integer;
// begin
//   Result := '';
//   if S <> '' then begin
//     i := ChPos.veCharPos(Delimiters, S, StartPos);
//     if i > 0 then begin
//       j := ChPos.vbeCharPos(Delimiters, S, Length(S));
//       Result := copy(S, i, j - i + 1)
//     end;
//   end;
// end;
//
// function trimStr(const Words: TCharClass; const S: string; const StartPos: integer = 1): string; //overload;
// // this routine is IDENTICAL with trimmed
// // note: startpos argument will effectively truncate the string before startpos value
// var
//   i, j: integer;
// begin
//   Result := '';
//   if S <> '' then begin
//     i := ChPos._xCharPos(ChposK.ChposIndexTables[Words], S, StartPos);
//     if i > 0 then begin
//       j := ChPos.bxCharPos(ChposK.ChposIndexTables[Words], S, Length(S));
//       Result := copy(S, i, j - i + 1)
//     end;
//   end;
// end;
//
//function trimmed(const S: string; const StartPos: integer = 1): string; overload;
//// this routine is IDENTICAL with trimStr
//// note: startpos argument will effectively truncate the string before startpos value
//var
//  i, j: integer;
//begin
//  Result := '';
//  if S <> '' then begin
//    i := ChPos.vxCharPos(ChposK.ChposIndexTables[chsCntrlSpace], S, StartPos);
//    if i > 0 then begin
//      j := ChPos.vbxCharPos(ChposK.ChposIndexTables[chsCntrlSpace], S, Length(S));
//      Result := copy(S, i, j - i + 1)
//    end;
//  end;
//end;
//
//function trimmed(const S: string; const Delimiter: Char; const StartPos: integer = 1): string; overload;
//// this routine is IDENTICAL with trimStr
//// note: startpos argument will effectively truncate the string before startpos value
//var
//  i, j: integer;
//begin
//  Result := '';
//  if S <> '' then begin
//    i := ChPos._vcCharPos(Delimiter, S, StartPos);
//    if i > 0 then begin
//      j := ChPos._vbcCharPos(Delimiter, S, Length(S));
//      Result := copy(S, i, j - i + 1)
//    end;
//  end;
//end;
//
//function trimmed(const S: string; const Delimiters: TChPosCharset; const StartPos: integer = 1): string; overload;
//// this routine is IDENTICAL with trimStr
//// note: startpos argument will effectively truncate the string before startpos value
//var
//  i, j: integer;
//begin
//  Result := '';
//  if S <> '' then begin
//    i := ChPos.veCharPos(Delimiters, S, StartPos);
//    if i > 0 then begin
//      j := ChPos.vbeCharPos(Delimiters, S, Length(S));
//      Result := copy(S, i, j - i + 1)
//    end;
//  end;
//end;
//
//function trimmed(const S: string; const Words: TCharClass; const StartPos: integer = 1): string; overload;
//// this routine is IDENTICAL with trimStr
//// note: startpos argument will effectively truncate the string before startpos value
//var
//  i, j: integer;
//begin
//  Result := '';
//  if S <> '' then begin
//    i := ChPos._xCharPos(ChposK.ChposIndexTables[Words], S, StartPos);
//    if i > 0 then begin
//      j := ChPos.bxCharPos(ChposK.ChposIndexTables[Words], S, Length(S));
//      Result := copy(S, i, j - i + 1)
//    end;
//  end;
//end;
//
// function trimSLeft(const S: string; const StartPos: integer = 1): string; //overload;
// // note: startpos argument will effectively truncate the string before startpos value
// var
//   i: integer;
// begin
//   Result := '';
//   if S <> '' then begin
//     i := ChPos.vxCharPos(ChposK.ChposIndexTables[chsCntrlSpace], S, StartPos);
//     if i > 0 then
//       Result := copy(S, i, MAXINT)
//   end;
// end;
//
// function trimSLeft(const S: string; const Delimiter: Char; const StartPos: integer = 1): string; overload;
// // note: startpos argument will effectively truncate the string before startpos value
// var
//   i: integer;
// begin
//   Result := '';
//   if S <> '' then begin
//     i := ChPos._vcCharPos(Delimiter, S, StartPos);
//     if i > 0 then begin
//       Result := copy(S, i, MAXINT)
//     end;
//   end;
// end;
//
// function trimSLeft(const S: string; const Delimiters: TChPosCharset; const StartPos: integer = 1): string; //overload;
// // note: startpos argument will effectively truncate the string before startpos value
// var
//   i: integer;
// begin
//   Result := '';
//   if S <> '' then begin
//     i := ChPos.veCharPos(Delimiters, S, StartPos);
//     if i > 0 then
//       Result := copy(S, i, MAXINT)
//   end;
// end;
//
// function trimSLeft(const Words: TCharClass; const S: string; const StartPos: integer = 1): string; //overload;
// // this routine is IDENTICAL with trimmed
// // note: startpos argument will effectively truncate the string before startpos value
// var
//   i: integer;
// begin
//   Result := '';
//   if S <> '' then begin
//     i := ChPos._xCharPos(ChposK.ChposIndexTables[Words], S, StartPos);
//     if i > 0 then begin
//       Result := copy(S, i, MAXINT)
//     end;
//   end;
// end;
//
// function trimSRight(const S: string): string; //overload;
// var
//   j: integer;
// begin
//   Result := '';
//   if S <> '' then begin
//     j := ChPos.vbxCharPos(ChposK.ChposIndexTables[chsCntrlSpace], S, length(S));
//     if j > 0 then
//       Result := copy(S, 1, j)
//   end;
// end;
//
// function trimSRight(const S: string; const Delimiter: Char): string; //overload;
// // note: startpos argument will effectively truncate the string before startpos value
// var
//   j: integer;
// begin
//   Result := '';
//   if S <> '' then begin
//     j := ChPos._vbcCharPos(Delimiter, S, Length(S));
//     if j > 0 then begin
//       Result := copy(S, 1, j)
//     end;
//   end;
// end;
//
// function trimSRight(const S: string; const Delimiters: TChPosCharset): string; //overload;
// var
//   j: integer;
// begin
//   Result := '';
//   if S <> '' then begin
//     j := ChPos.vbeCharPos(Delimiters, S, length(S));
//     if j > 0 then
//       Result := copy(S, 1, j)
//   end;
// end;
//
// function trimSRight(const Words: TCharClass; const S: string): string; //overload;
// // this routine is IDENTICAL with trimmed
// // note: startpos argument will effectively truncate the string before startpos value
// var
//   j: integer;
// begin
//   Result := '';
//   if S <> '' then begin
//     j := ChPos.bxCharPos(ChposK.ChposIndexTables[Words], S, Length(S));
//     if j > 0 then
//       Result := copy(S, 1, j)
//   end;
// end;
//
// // get/check only length
//
// function trimStrLen(const S: string; const StartPos: integer = 1): integer; //overload;
// // note: startpos argument will effectively truncate the string before startpos value
// var
//   i, j: integer;
// begin
//   Result := 0;
//   if S <> '' then begin
//     i := ChPos.vxCharPos(ChposK.ChposIndexTables[chsCntrlSpace], S, StartPos);
//     if i > 0 then begin
//       j := ChPos.vbxCharPos(ChposK.ChposIndexTables[chsCntrlSpace], S, Length(S));
//       Result := j - i + 1
//     end;
//   end;
// end;
//
// function trimSLeftLen(const S: string; const StartPos: integer = 1): integer; //overload;
// // note: startpos argument will effectively truncate the string before startpos value
// var
//   i: integer;
// begin
//   Result := 0;
//   if S <> '' then begin
//     i := ChPos.vxCharPos(ChposK.ChposIndexTables[chsCntrlSpace], S, StartPos);
//     if i > 0 then
//       Result := Length(S) - i + 1
//   end;
// end;
//
// function trimSRightLen(const S: string): integer; //overload;
// begin
//   if S = '' then Result := 0
//   else Result := ChPos.vbxCharPos(ChposK.ChposIndexTables[chsCntrlSpace], S, length(S));
// end;
//
// function trimStrLen(const S: string; const Delimiter: Char; const StartPos: integer = 1): integer; //overload;
// // note: startpos argument will effectively truncate the string before startpos value
// var
//   i, j: integer;
// begin
//   Result := 0;
//   if S <> '' then begin
//     i := ChPos._vcCharPos(Delimiter, S, StartPos);
//     if i > 0 then begin
//       j := ChPos._vbcCharPos(Delimiter, S, Length(S));
//       Result := j - i + 1 //copy(S, i, j - i + 1)
//     end;
//   end;
// end;
//
// function trimSLeftLen(const S: string; const Delimiter: Char; const StartPos: integer = 1): integer; //overload;
// // note: startpos argument will effectively truncate the string before startpos value
// var
//   i: integer;
// begin
//   Result := 0;
//   if S <> '' then begin
//     i := ChPos._vcCharPos(Delimiter, S, StartPos);
//     if i > 0 then begin
//       //j := ChPos._vbcCharPos(Delimiter, S, Length(S));
//       Result := length(S) - i + 1 //copy(S, i, j - i + 1)
//     end;
//   end;
// end;
//
// function trimSRightLen(const S: string; const Delimiter: Char): integer; //overload;
// // note: startpos argument will effectively truncate the string before startpos value
// begin
//   if S = '' then Result := 0
//   else Result := ChPos._vbcCharPos(Delimiter, S, Length(S));
// end;
//
// function trimStrLen(const S: string; const Delimiters: TChPosCharset; const StartPos: integer = 1): integer; //overload;
// // note: startpos argument will effectively truncate the string before startpos value
// var
//   i, j: integer;
// begin
//   Result := 0;
//   if S <> '' then begin
//     i := ChPos.veCharPos(Delimiters, S, StartPos);
//     if i > 0 then begin
//       j := ChPos.vbeCharPos(Delimiters, S, Length(S));
//       Result := j - i;
//     end;
//   end;
// end;
//
// function trimSLeftLen(const S: string; const Delimiters: TChPosCharset; const StartPos: integer = 1): integer; //overload;
// // note: startpos argument will effectively truncate the string before startpos value
// var
//   i: integer;
// begin
//   Result := 0;
//   if S <> '' then begin
//     i := ChPos.veCharPos(Delimiters, S, StartPos);
//     if i > 0 then
//       Result := Length(S) - i + 1
//   end;
// end;
//
// function trimSRightLen(const S: string; const Delimiters: TChPosCharset): integer; //overload;
// begin
//   if S = '' then Result := 0
//   else Result := ChPos.vbeCharPos(Delimiters, S, length(S));
// end;
//
// function trimStrLen(const S: string; const Words: TCharClass; const StartPos: integer = 1): integer; //overload;
// // note: startpos argument will effectively truncate the string before startpos value
// var
//   i, j: integer;
// begin
//   Result := 0;
//   if S <> '' then begin
//     i := ChPos._xCharPos(ChposK.ChposIndexTables[Words], S, StartPos);
//     if i > 0 then begin
//       j := ChPos.bxCharPos(ChposK.ChposIndexTables[Words], S, Length(S));
//       Result := j - i + 1 //copy(S, i, j - i + 1)
//     end;
//   end;
// end;
//
// function trimSLeftLen(const S: string; const Words: TCharClass; const StartPos: integer = 1): integer; //overload;
// // note: startpos argument will effectively truncate the string before startpos value
// var
//   i: integer;
// begin
//   Result := 0;
//   if S <> '' then begin
//     i := ChPos._xCharPos(ChposK.ChposIndexTables[Words], S, StartPos);
//     if i > 0 then begin
//       //j := ChPos.bxCharPos(ChposK.ChposIndexTables[Words], S, Length(S));
//       Result := length(S) - i + 1 //copy(S, i, j - i + 1)
//     end;
//   end;
// end;
//
// function trimSRightLen(const S: string; const Words: TCharClass): integer; //overload;
// // note: startpos argument will effectively truncate the string before startpos value
// begin
//   if S = '' then Result := 0
//   else Result := ChPos.bxCharPos(ChposK.ChposIndexTables[Words], S, Length(S));
// end;
//
// // ~~~~~~~~~~~~~~~~
// // end OLD trimmers
// // ~~~~~~~~~~~~~~~~
//
// function trimS_OK1(const S: string; const Options: TTrimStrOptions; const StartPos: integer = 1): string; overload;
// var
//   i, j: integer;
// begin
//   Result := '';
//   if S <> '' then begin
//     if (Options - [tsoInvert]) = [] then Result := S
//     else begin
//       if not (tsoTrimLeft in Options) then i := 1
//       else
//         if tsoInvert in Options then
//           i := ChPos._xCharPos(ChposK.ChposIndexTables[chsCntrlSpace], S, StartPos)
//         else
//           i := ChPos.vxCharPos(ChposK.ChposIndexTables[chsCntrlSpace], S, StartPos);
//       if not (tsoTrimRight in Options) then j := MAXINT
//       else
//         if tsoInvert in Options then
//           j := ChPos.bxCharPos(ChposK.ChposIndexTables[chsCntrlSpace], S, Length(S))
//         else
//           j := ChPos.vbxCharPos(ChposK.ChposIndexTables[chsCntrlSpace], S, Length(S));
//       Result := copy(S, i, j - i + 1)
//     end;
//   end;
// end;
//
// function trimS_OK1(const S: string; const Delimiter: Char; const Options: TTrimStrOptions; const StartPos: integer = 1): string; overload;
// var
//   i, j: integer;
// begin
//   Result := '';
//   if S <> '' then begin
//     if (Options - [tsoInvert]) = [] then Result := S
//     else begin
//       if not (tsoTrimLeft in Options) then i := 1
//       else
//         if tsoInvert in Options then
//           i := ChPos._cCharPos(Delimiter, S, StartPos)
//         else
//           i := ChPos._vcCharPos(Delimiter, S, StartPos);
//       if not (tsoTrimRight in Options) then j := MAXINT
//       else
//         if tsoInvert in Options then
//           j := ChPos._bcCharPos(Delimiter, S, Length(S))
//         else
//           j := ChPos._vbcCharPos(Delimiter, S, Length(S));
//       Result := copy(S, i, j - i + 1)
//     end;
//   end;
// end;
//
// function trimS_OK1(const S: string; const Delimiters: TChPosCharset; const Options: TTrimStrOptions; const StartPos: integer = 1): string; overload;
// var
//   i, j: integer;
// begin
//   Result := '';
//   if S <> '' then begin
//     if (Options - [tsoInvert]) = [] then Result := S
//     else begin
//       if not (tsoTrimLeft in Options) then i := 1
//       else
//         if tsoInvert in Options then
//           i := ChPos._eCharPos(Delimiters, S, StartPos)
//         else
//           i := ChPos.veCharPos(Delimiters, S, StartPos);
//       if not (tsoTrimRight in Options) then j := MAXINT
//       else
//         if tsoInvert in Options then
//           j := ChPos.beCharPos(Delimiters, S, Length(S))
//         else
//           j := ChPos.vbeCharPos(Delimiters, S, Length(S));
//       Result := copy(S, i, j - i + 1)
//     end;
//   end;
// end;
//
// function trimS_OK1(const Words: TCharClass; const S: string; const Options: TTrimStrOptions; const StartPos: integer = 1): string; overload;
// var
//   i, j: integer;
// begin
//   Result := '';
//   if S <> '' then begin
//     if (Options - [tsoInvert]) = [] then Result := S
//     else begin
//       if not (tsoTrimLeft in Options) then i := 1
//       else
//         if tsoInvert in Options then
//           i := ChPos.vxCharPos(ChposK.ChposIndexTables[Words], S, StartPos)
//         else
//           i := ChPos._xCharPos(ChposK.ChposIndexTables[Words], S, StartPos);
//       if not (tsoTrimRight in Options) then j := MAXINT
//       else
//         if tsoInvert in Options then
//           //j := ChPos._bcCharPos(Delimiter, S, Length(S))
//           j := ChPos.vbxCharPos(ChposK.ChposIndexTables[Words], S, Length(S))
//         else
//           //j := ChPos._vbcCharPos(Delimiter, S, Length(S));
//           j := ChPos.bxCharPos(ChposK.ChposIndexTables[Words], S, Length(S));
//       Result := copy(S, i, j - i + 1)
//     end;
//   end;
// end;
//
// //stop-press!
// //========================================================
// // reorganizing code like this had only got a little gain
// // the compiler had really done a great optimization code
// //========================================================
// const
//   TSO_LEFT = 1 shl ord(tsoTrimLeft); // 1;
//   TSO_RIGHT = 1 shl ord(tsoTrimRight); //2;
//   TSO_LEFTRIGHT = TSO_LEFT or TSO_RIGHT; //3;
//   TSO_INVERT = 1 shl ord(tsoInvert); //4;
//   TSO_LEFTINVERT = TSO_LEFT or TSO_INVERT; //5;
//   TSO_RIGHTINVERT = TSO_RIGHT or TSO_INVERT; //6;
//   TSO_LEFTRIGHTINVERT = TSO_LEFT or TSO_RIGHT or TSO_INVERT; //7;
//
// function trimSx(const S: string; const Options: TTrimStrOptions; const StartPos: integer = 1): string; overload;
// var
//   i, j: integer;
//   opt: byte;
// begin
//   Result := '';
//   if S <> '' then begin
//     opt := byte(options);
//     if opt and not TSO_INVERT = 0 then Result := S
//     else begin
//       if TSO_LEFT and opt = 0 then i := 1
//       else
//         if (TSO_INVERT and opt) > 0 then
//           i := ChPos._xCharPos(ChposK.ChposIndexTables[chsCntrlSpace], S, StartPos)
//         else
//           i := ChPos.vxCharPos(ChposK.ChposIndexTables[chsCntrlSpace], S, StartPos);
//       if (opt and TSO_RIGHT) = 0 then j := MAXINT
//       else
//         if (TSO_INVERT and opt) > 0 then
//           j := ChPos.bxCharPos(ChposK.ChposIndexTables[chsCntrlSpace], S, Length(S))
//         else
//           j := ChPos.vbxCharPos(ChposK.ChposIndexTables[chsCntrlSpace], S, Length(S));
//       if opt = 0 then exit; //debug to keep opt value
//       Result := copy(S, i, j - i + 1)
//     end;
//   end;
// end;
//
// function trimStrOK2(const S: string; const Options: TTrimStrOptions; const StartPos: integer = 1): string; overload;
// var
//   i, j: integer;
// begin
//   Result := '';
//   if S <> '' then begin
//     if (Options - [tsoInvert]) = [] then Result := S
//     else begin
//       if not (tsoTrimLeft in Options) then i := 1
//       else
//         if tsoInvert in Options then
//           i := ChPos._xCharPos(ChposK.ChposIndexTables[chsCntrlSpace], S, StartPos)
//         else
//           i := ChPos.vxCharPos(ChposK.ChposIndexTables[chsCntrlSpace], S, StartPos);
//       if not (tsoTrimRight in Options) then j := MAXINT
//       else
//         if tsoInvert in Options then
//           j := ChPos.bxCharPos(ChposK.ChposIndexTables[chsCntrlSpace], S, Length(S))
//         else
//           j := ChPos.vbxCharPos(ChposK.ChposIndexTables[chsCntrlSpace], S, Length(S));
//       Result := copy(S, i, j - i + 1)
//     end;
//   end;
// end;
//
// function trimStrOK2(const S: string; const Delimiter: Char; const Options: TTrimStrOptions; const StartPos: integer = 1): string; overload;
// var
//   i, j: integer;
// begin
//   Result := '';
//   if S <> '' then begin
//     if (Options - [tsoInvert]) = [] then Result := S
//     else begin
//       if not (tsoTrimLeft in Options) then i := 1
//       else
//         if tsoInvert in Options then
//           i := ChPos._cCharPos(Delimiter, S, StartPos)
//         else
//           i := ChPos._vcCharPos(Delimiter, S, StartPos);
//       if not (tsoTrimRight in Options) then j := MAXINT
//       else
//         if tsoInvert in Options then
//           j := ChPos._bcCharPos(Delimiter, S, Length(S))
//         else
//           j := ChPos._vbcCharPos(Delimiter, S, Length(S));
//       Result := copy(S, i, j - i + 1)
//     end;
//   end;
// end;
//
// function trimStrOK2(const S: string; const Delimiters: TChPosCharset; const Options: TTrimStrOptions; const StartPos: integer = 1): string; overload;
// var
//   i, j: integer;
// begin
//   Result := '';
//   if S <> '' then begin
//     if (Options - [tsoInvert]) = [] then Result := S
//     else begin
//       if not (tsoTrimLeft in Options) then i := 1
//       else
//         if tsoInvert in Options then
//           i := ChPos._eCharPos(Delimiters, S, StartPos)
//         else
//           i := ChPos.veCharPos(Delimiters, S, StartPos);
//       if not (tsoTrimRight in Options) then j := MAXINT
//       else
//         if tsoInvert in Options then
//           j := ChPos.beCharPos(Delimiters, S, Length(S))
//         else
//           j := ChPos.vbeCharPos(Delimiters, S, Length(S));
//       Result := copy(S, i, j - i + 1)
//     end;
//   end;
// end;
//
// function trimStrOK2(const Words: TCharClass; const S: string; const Options: TTrimStrOptions; const StartPos: integer = 1): string; overload;
// var
//   i, j: integer;
// begin
//   Result := '';
//   if S <> '' then begin
//     if (Options - [tsoInvert]) = [] then Result := S
//     else begin
//       if not (tsoTrimLeft in Options) then i := 1
//       else
//         if tsoInvert in Options then
//           i := ChPos.vxCharPos(ChposK.ChposIndexTables[Words], S, StartPos)
//         else
//           i := ChPos._xCharPos(ChposK.ChposIndexTables[Words], S, StartPos);
//       if not (tsoTrimRight in Options) then j := MAXINT
//       else
//         if tsoInvert in Options then
//           //j := ChPos._bcCharPos(Delimiter, S, Length(S))
//           j := ChPos.vbxCharPos(ChposK.ChposIndexTables[Words], S, Length(S))
//         else
//           //j := ChPos._vbcCharPos(Delimiter, S, Length(S));
//           j := ChPos.bxCharPos(ChposK.ChposIndexTables[Words], S, Length(S));
//       Result := copy(S, i, j - i + 1)
//     end;
//   end;
// end;
//
// //==========================================================================

// ************************************************************
// NEW trimmers, refining all trimStr routines
// ************************************************************

function gettrimdLen(const S: string; var StartPos: integer; const Options: TTrimStrOptions): integer;
var
  j, L: integer;
begin
  Result := 0;
  if S <> '' then begin
    L := length(S);
    if (Options - [tsoInvert]) = [] then Result := L
    else begin
      if not (tsoTrimLeft in Options) then StartPos := 1
      else
        if tsoInvert in Options then
          StartPos := ChPos._xCharPos(ChposK.ChposIndexTables[chsCntrlSpace], S, StartPos)
        else
          StartPos := ChPos.vxCharPos(ChposK.ChposIndexTables[chsCntrlSpace], S, StartPos);

      //if StartPos = 0 then it MUST be empty anyway
      if StartPos > 0 then begin
        if not (tsoTrimRight in Options) then j := L
        else
          if tsoInvert in Options then
            j := ChPos.bxCharPos(ChposK.ChposIndexTables[chsCntrlSpace], S, L)
          else
            j := ChPos.vbxCharPos(ChposK.ChposIndexTables[chsCntrlSpace], S, L);
        Result := j - StartPos + 1 //copy(S, i, j - i + 1)
      end;
    end;
  end;
end;

function gettrimdLen(const S: string; const Delimiter: Char; var StartPos: integer; const Options: TTrimStrOptions): integer;
var
  j, L: integer;
begin
  Result := 0;
  if S <> '' then begin
    L := length(S);
    if (Options - [tsoInvert]) = [] then Result := L
    else begin
      if not (tsoTrimLeft in Options) then StartPos := 1
      else
        if tsoInvert in Options then
          StartPos := ChPos._cCharPos(Delimiter, S, StartPos)
        else
          StartPos := ChPos._vcCharPos(Delimiter, S, StartPos);

      //if StartPos = 0 then it MUST be empty anyway
      if StartPos > 0 then begin
        if not (tsoTrimRight in Options) then j := L
        else
          if tsoInvert in Options then
            j := ChPos._bcCharPos(Delimiter, S, L)
          else
            j := ChPos._vbcCharPos(Delimiter, S, L);
        Result := j - StartPos + 1 //copy(S, StartPos, j - StartPos + 1)
      end;
    end;
  end;
end;

function gettrimdLen(const S: string; const Delimiters: TChPosCharset; var StartPos: integer; const Options: TTrimStrOptions): integer;
var
  j, L: integer;
begin
  Result := 0;
  if S <> '' then begin
    L := length(S);
    if (Options - [tsoInvert]) = [] then Result := L
    else begin
      if not (tsoTrimLeft in Options) then StartPos := 1
      else
        if tsoInvert in Options then
          StartPos := ChPos._eCharPos(Delimiters, S, StartPos)
        else
          StartPos := ChPos.veCharPos(Delimiters, S, StartPos);

      //if StartPos = 0 then it MUST be empty anyway
      if StartPos > 0 then begin
        if not (tsoTrimRight in Options) then j := L
        else
          if tsoInvert in Options then
            j := ChPos.beCharPos(Delimiters, S, L)
          else
            j := ChPos.vbeCharPos(Delimiters, S, L);
        Result := j - StartPos + 1 //copy(S, StartPos, j - StartPos + 1)
      end;
    end;
  end;
end;

function gettrimdLen(const Words: TCharClass; const S: string; var StartPos: integer; const Options: TTrimStrOptions): integer;
var
  j, L: integer;
begin
  Result := 0;
  if S <> '' then begin
    L := length(S);
    if (Options - [tsoInvert]) = [] then Result := L
    else begin
      if not (tsoTrimLeft in Options) then StartPos := 1
      else
        if tsoInvert in Options then
          StartPos := ChPos.vxCharPos(ChposK.ChposIndexTables[Words], S, StartPos)
        else
          StartPos := ChPos._xCharPos(ChposK.ChposIndexTables[Words], S, StartPos);

      //if StartPos = 0 then it MUST be empty anyway
      if StartPos > 0 then begin
        if not (tsoTrimRight in Options) then j := L
        else
          if tsoInvert in Options then
            j := ChPos.vbxCharPos(ChposK.ChposIndexTables[Words], S, L)
          else
            j := ChPos.bxCharPos(ChposK.ChposIndexTables[Words], S, L);
        Result := j - StartPos + 1 //copy(S, StartPos, j - StartPos + 1)
      end;
    end;
  end;
end;

function trimmedLen(const S: string; const Options: TTrimStrOptions; StartPos: integer): integer; overload;
begin
  Result := gettrimdLen(S, StartPos, Options);
end;

function trimmedLen(const S: string; const Delimiter: Char; const Options: TTrimStrOptions; StartPos: integer): integer; overload;
begin
  Result := gettrimdLen(S, Delimiter, StartPos, Options);
end;

function trimmedLen(const S: string; const Delimiters: TChPosCharset; const Options: TTrimStrOptions; StartPos: integer): integer; overload;
begin
  Result := gettrimdLen(S, Delimiters, StartPos, Options);
end;

function trimmedLen(const Words: TCharClass; const S: string; const Options: TTrimStrOptions; StartPos: integer): integer; overload;
begin
  Result := gettrimdLen(Words, S, StartPos, Options);
end;

function trimS(const S: string; const Options: TTrimStrOptions = [tsoTrimLeft, tsoTrimRight]; StartPos: integer = 1): string; overload;
var
  LenResult: integer;
begin
  LenResult := gettrimdLen(S, StartPos, Options);
  if LenResult = 0 then Result := ''
  else Result := copy(S, StartPos, LenResult)
end;

function trimS(const S: string; const Delimiter: Char; const Options: TTrimStrOptions = [tsoTrimLeft, tsoTrimRight]; StartPos: integer = 1): string; overload;
var
  LenResult: integer;
begin
  LenResult := gettrimdLen(S, Delimiter, StartPos, Options);
  if LenResult = 0 then Result := ''
  else Result := copy(S, StartPos, LenResult)
end;

function trimS(const S: string; const Delimiters: TChPosCharset; const Options: TTrimStrOptions = [tsoTrimLeft, tsoTrimRight]; StartPos: integer = 1): string; overload;
var
  LenResult: integer;
begin
  LenResult := gettrimdLen(S, Delimiters, StartPos, Options);
  if LenResult = 0 then Result := ''
  else Result := copy(S, StartPos, LenResult)
end;

function trimS(const Words: TCharClass; const S: string; const Options: TTrimStrOptions = [tsoTrimLeft, tsoTrimRight]; StartPos: integer = 1): string; overload;
var
  LenResult: integer;
begin
  LenResult := gettrimdLen(Words, S, StartPos, Options);
  if LenResult = 0 then Result := ''
  else Result := copy(S, StartPos, LenResult)
end;

//trimStr wrappers

function trimStr(const S: string; const StartPos: integer = 1): string;
begin
  Result := trimS(S);
end;

function trimSLeft(const S: string; const StartPos: integer = 1): string;
begin
  Result := trimS(S, [tsoTrimLeft]);
end;

function trimSRight(const S: string): string;
begin
  Result := trimS(S, [tsoTrimRight]);
end;

function trimStr(const S: string; const Delimiter: Char; const StartPos: integer = 1): string;
begin
  Result := trimS(S, Delimiter);
end;

function trimSLeft(const S: string; const Delimiter: Char; const StartPos: integer = 1): string;
begin
  Result := trimS(S, Delimiter, [tsoTrimLeft]);
end;

function trimSRight(const S: string; const Delimiter: Char): string;
begin
  Result := trimS(S, Delimiter, [tsoTrimRight]);
end;

// note: startpos argument will effectively truncate the string before startpos value

function trimStr(const S: string; const Delimiters: TChPosCharset; const StartPos: integer = 1): string;
begin
  Result := trimS(S, Delimiters);
end;

function trimSLeft(const S: string; const Delimiters: TChPosCharset; const StartPos: integer = 1): string;
begin
  Result := trimS(S, Delimiters, [tsoTrimLeft]);
end;

function trimSRight(const S: string; const Delimiters: TChPosCharset): string;
begin
  Result := trimS(S, Delimiters, [tsoTrimRight]);
end;

// note: startpos argument will effectively truncate the string before startpos value
// these ones will trim / removes chars which are NOT included in the Words Class
// (actually just an Inverted [and optionally faster] version of trimS with object Charset)

function trimStr(const Words: TCharClass; const S: string; const StartPos: integer = 1): string;
begin
  Result := trimS(WordS, S);
end;

function trimSLeft(const Words: TCharClass; const S: string; const StartPos: integer = 1): string;
begin
  Result := trimS(Words, S, [tsoTrimLeft]);
end;

function trimSRight(const Words: TCharClass; const S: string): string;
begin
  Result := trimS(Words, S, [tsoTrimRight]);
end;

// ************************************************************
// end NEW trimmers
// ************************************************************

function SameText(const S1, S2: string; const IgnoreCase: boolean = TRUE): boolean;
begin
  if IgnoreCase then
    Result := _iCompare(S1, S2) = 0
  else
    Result := _cCompare(S1, S2) = 0
end;

function SameBuffer(const P1, P2; const Length: integer;
  const IgnoreCase: boolean = TRUE): boolean;
begin
  Result := pointer(P1) = pointer(P2);
  if not Result then
    if IgnoreCase then
      Result := piCompare(P1, P2, Length, Length) = 0
    else
      Result := pcCompare(P1, P2, Length, Length) = 0
end;

procedure UPPERBUFF(var Buffer; const Length: integer);
//procedure UPPERSTR(var Buffer; const Length: integer);
begin
  //Result := S;
  //SetLength(Result, length(S));
  //UniqueString(Result);
  transBuffer(Buffer, Length, UPCASETABLE);
end;

procedure lowerbuff(var Buffer; const Length: integer);
//procedure lowerstr(var Buffer; const Length: integer);
begin
  //Result := S;
  //SetLength(Result, length(S));
  //UniqueString(Result);
  transBuffer(Buffer, Length, locasetable);
end;

function CharAtIndex(const Index: integer; const Ch: Char; const S: string; const IgnoreCase: boolean = FALSE;
  const StartPos: integer = 1; const Backwise: boolean = FALSE): integer; register overload
begin
  if Backwise then
    if IgnoreCase then
      Result := _biCharIndexPos(Ch, S, StartPos, Index)
    else
      Result := _bcCharIndexPos(Ch, S, StartPos, Index)
  else if IgnoreCase then
    Result := _iCharIndexPos(Ch, S, StartPos, Index)
  else
    Result := _cCharIndexPos(Ch, S, StartPos, Index)
end;

function BackwiseCharAtIndex(const Index: integer; const Ch: Char; const S: string;
  const BackFromPos: integer; const IgnoreCase: boolean = FALSE): integer; register overload
begin
  if IgnoreCase then
    Result := _biCharIndexPos(Ch, S, BackFromPos, Index)
  else
    Result := _bcCharIndexPos(Ch, S, BackFromPos, Index)
end;

function WordAtIndex(const Index: integer; const S: string; const delimiter: Char; //= ' ';
  const StartPos: integer = 1; const IgnoreCase: boolean = FALSE; const Backwise: boolean = FALSE): string;
// function WordAtIndex(const Index: integer; const S: string; const delimiter: Char = ' ';
// const StartPos: integer = 1; const Backwise: boolean = FALSE; const IgnoreCase: boolean = FALSE): string;
// no outrange/wordcount checking!!! WordAtIndex(200000, 'abc', anychar) will result: 'abc'
// note 2004.10.05: outrange check now fixed.
var
  n1, n2: integer;
begin
  if (Index < 1) then // simple outrange checks: or (Index > length(S)) then
    Result := ''
  else begin
    if not Backwise then begin
      if Index = 1 then begin
        n2 := CharAtIndex(Index, delimiter, S, IgnoreCase, StartPos, Backwise);
        if n2 = 0 then
          n2 := length(S) + 1;
        Result := Copy(S, StartPos, n2 - StartPos);
      end
      else begin
        n1 := CharAtIndex(Index - 1, delimiter, S, IgnoreCase, StartPos, Backwise);
        if n1 < 1 then
          Result := ''
        else begin
          inc(n1);
          n2 := CharAtIndex(Index, delimiter, S, IgnoreCase, StartPos, Backwise);
          if n2 = 0 then
            n2 := length(S) + 1;
          Result := Copy(S, n1, n2 - n1);
        end;
      end;
    end
    else begin
      //Backwise doesnot yet checked further for an outrange wordcount
      if index = 1 then
        n1 := StartPos + 1
      else
        n1 := CharAtIndex(Index - 1, delimiter, S, IgnoreCase, StartPos, Backwise);
      n2 := CharAtIndex(Index, delimiter, S, IgnoreCase, StartPos, Backwise) + 1;
      // //if n2 < 1 then n2 := length(S) + 1; //!
      Result := Copy(S, n2, n1 - n2);
    end;
  end
end;

function BackwiseWordAtIndex(const Index: integer; const S: string; const delimiter: Char; //= ' ';
  const BackFromPos: integer; const IgnoreCase: boolean = FALSE): string;
var
  n1, n2: integer;
begin
  if (Index < 1) then Result := ''
  else begin
    //Backwise doesnot yet checked further for an outrange wordcount
    if index = 1 then
      n1 := BackFromPos + 1
    else
      n1 := BackwiseCharAtIndex(Index - 1, delimiter, S, BackFromPos, IgnoreCase);
    n2 := BackwiseCharAtIndex(Index, delimiter, S, BackFromPos, IgnoreCase) + 1;
    // //if n2 < 1 then n2 := length(S) + 1; //!
    Result := Copy(S, n2, n1 - n2);
  end;
end;
// function WordCount_old(const S: string; const delimiter: Char = ' '; const StartPos: integer = 1; const Backwise: boolean = FALSE; const IgnoreCase: boolean = FALSE): integer;
// var
//   Len, n: integer;
// begin
//   Len := length(S);
//   if (StartPos < 1) or (StartPos > Len) then Result := 0
//   else begin
//   //if (StartPos > 0) and (Len >= StartPos) then begin
//     Result := CharCount(delimiter, S, StartPos, IgnoreCase, Backwise);
//     n := Len - StartPos + 1;
//     if S[StartPos] = delimiter then
//       dec(Result);
//     if Backwise then
//       if S[1] <> delimiter then
//         inc(Result)
//       else
//         if S[n] <> delimiter then
//           inc(Result)
//   end;
// end;

function WordCount(const S: string; const delimiter: Char {= ' '}; const StartPos: integer = 1;
  const Backwise: boolean = FALSE; const IgnoreCase: boolean = FALSE): integer;
begin
  if S = '' then
    Result := 0
  else
    Result := CharCount(delimiter, S, StartPos, IgnoreCase, Backwise) + 1;
end;

function BackwiseWordCount(const S: string; const delimiter: Char; const BackFromPos: integer;
  const IgnoreCase: boolean = FALSE): integer; overload;
begin
  if S = '' then
    Result := 0
  else
    Result := BackCharCount(delimiter, S, BackFromPos, IgnoreCase) + 1;
end;

function fetchWord(const S: string; var StartPos: integer; const Delimiter: char): string;
var
  L, p: integer;
begin
  L := length(S);
  Result := '';
  if StartPos > L then
    StartPos := 0
  else if StartPos > 0 then begin
    p := ChPos.CharPos(Delimiter, S, StartPos);
    if p = 0 then begin
      if StartPos = 1 then
        Result := S
      else
        Result := copy(S, StartPos, L);
      StartPos := 0;
    end
    else begin
      Result := copy(S, StartPos, p - StartPos);
      StartPos := p + 1;
    end
  end;
end;

function WordIndexOf(const SubStr, S: string; const Delimiter: char;
  const LengthToBeCompared: integer = MaxInt; const ignoreCaseSubStr: boolean = TRUE;
  const StartPos: integer = 1; const Backwise: boolean = FALSE;
  const ignoreCaseDelimiter: boolean = FALSE): integer;

function min(const a, b: integer): integer; assembler asm
    cmp a, b; jle @end
    mov a, b;
    @end:
  end;

var
  i: integer;
  CS, CSubStr: string;
  M: integer;
begin
  Result := -1;
  if (S <> '') and (SubStr <> '') and (LengthToBeCompared > 0) then begin
    M := min(Length(SubStr), LengthToBeCompared);
    if (length(S) >= M) then begin
      CS := S;
      CSubStr := copy(SubStr, 1, M);
      if ignoreCaseSubStr then begin
        CS := UPPERSTR(CS);
        CSubStr := UPPERSTR(CSubStr);
      end;
      for i := 1 to WordCount(CS, Delimiter, StartPos, Backwise, IgnoreCaseDelimiter) do
        if copy(WordAtIndex(i, CS, Delimiter, StartPos, ignoreCaseDelimiter, Backwise), 1, M) = CSubStr then begin
          Result := i;
          break;
        end;
    end;
  end;
end;

function BackwiseWordIndexOf(const SubStr, S: string; const Delimiter: char;
  const BackFromPos: integer; const LengthToBeCompared: integer = MaxInt;
  const ignoreCaseSubStr: boolean = TRUE; const ignoreCaseDelimiter: boolean = FALSE): integer;
function min(const a, b: integer): integer; assembler asm
    cmp a, b; jle @end
    mov a, b;
    @end:
  end;

var
  i: integer;
  CS, CSubStr: string;
  M: integer;
begin
  Result := -1;
  if (S <> '') and (SubStr <> '') and (LengthToBeCompared > 0) then begin
    M := min(Length(SubStr), LengthToBeCompared);
    if (length(S) >= M) then begin
      CS := S;
      CSubStr := copy(SubStr, 1, M);
      if ignoreCaseSubStr then begin
        CS := UPPERSTR(CS);
        CSubStr := UPPERSTR(CSubStr);
      end;
      for i := 1 to BackwiseWordCount(CS, Delimiter, BackFromPos, IgnoreCaseDelimiter) do
        if copy(BackwiseWordAtIndex(i, CS, Delimiter, BackFromPos, ignoreCaseDelimiter), 1, M) = CSubStr then begin
          Result := i;
          break;
        end;
    end;
  end;
end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// miscellaneous
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function WCharPos(const firstChar, secondChar: Char; const S: string;
  const IgnoreCase: boolean = FALSE; const StartPos: integer = 1): integer; register overload
var
  I: integer;
begin
  I := ord(secondChar) shl 8 or ord(firstChar);
  if IgnoreCase then
    Result := _icwordPos(I, S, StartPos)
  else
    Result := _cwordPos(I, S, StartPos)
end;

function WCharPos(const firstChar, secondChar: Char; const S: string;
  const StartPos: integer; const IgnoreCase: boolean = FALSE): integer; register overload
var
  I: integer;
begin
  I := ord(secondChar) shl 8 or ord(firstChar);
  if IgnoreCase then
    Result := _icwordPos(I, S, StartPos)
  else
    Result := _cwordPos(I, S, StartPos)
end;

function WCharPos(const CharsPair, S: string; const IgnoreCase: boolean = FALSE;
  const StartPos: integer = 1): integer; register overload
var
  I: integer;
begin
  I := 0;
  if CharsPair <> '' then
    move(CharsPair[1], I, sizeOf(word));
  if IgnoreCase then
    Result := _icwordPos(I, S, StartPos)
  else
    Result := _cwordPos(I, S, StartPos)
end;

function WCharPos(const CharsPair, S: string; const StartPos: integer;
  const IgnoreCase: boolean = FALSE): integer; register overload
var
  I: integer;
begin
  I := 0;
  if CharsPair <> '' then
    move(CharsPair[1], I, sizeOf(word));
  if IgnoreCase then
    Result := _icwordPos(I, S, StartPos)
  else
    Result := _cwordPos(I, S, StartPos)
end;

function WCharCount(const firstChar, secondChar: Char; const S: string;
  const IgnoreCase: boolean = FALSE; const StartPos: integer = 1): integer; register overload
var
  I: integer;
begin
  I := ord(secondChar) shl 8 or ord(firstChar);
  if IgnoreCase then
    Result := _icwordCount(I, S, StartPos)
  else
    Result := _cwordCount(I, S, StartPos)
end;

function WCharCount(const firstChar, secondChar: Char; const S: string;
  const StartPos: integer; const IgnoreCase: boolean = FALSE): integer; register overload
var
  I: integer;
begin
  I := ord(secondChar) shl 8 or ord(firstChar);
  if IgnoreCase then
    Result := _icwordCount(I, S, StartPos)
  else
    Result := _cwordCount(I, S, StartPos)
end;

function WCharCount(const CharsPair, S: string; const IgnoreCase: boolean = FALSE;
  const StartPos: integer = 1): integer; register overload
var
  I: integer;
begin
  I := 0;
  if CharsPair <> '' then
    move(CharsPair[1], I, sizeOf(word));
  if IgnoreCase then
    Result := _icwordCount(I, S, StartPos)
  else
    Result := _cwordCount(I, S, StartPos)
end;

function WCharCount(const CharsPair, S: string; const StartPos: integer;
  const IgnoreCase: boolean = FALSE): integer; register overload
var
  I: integer;
begin
  I := 0;
  if CharsPair <> '' then
    move(CharsPair[1], I, sizeOf(word));
  if IgnoreCase then
    Result := _icwordCount(I, S, StartPos)
  else
    Result := _cwordCount(I, S, StartPos)
end;

procedure InitIndexTable(var IndexTable: TCharsetIndexTable; const Charset: TChPosCharset);
begin
  ChposK.buildIndexTable(IndexTable, Charset);
end;

procedure InitIndexTable_Inverse(var IndexTable: TCharsetIndexTable; const Charset: TChPosCharset);
begin
  ChposK.buildIndexTable_Inverse(IndexTable, Charset);
end;

// get position of n-th (index) character found in the string
//function CharAtIndex_old1(const CharClass: TCharClass; const S: string; const StartPos: integer; const Index: integer): integer; overload;
//begin
//  Result := CharAtIndex_old1(ChposK.ChposIndexTables[CharClass], S, StartPos, Index);
//end;

function CharAtIndex(const CharsetClass: TCharClass; const S: string; const Index: integer; const StartPos: integer): integer; overload;
begin
  Result := CharAtIndex(ChposK.ChposIndexTables[CharsetClass], S, Index, StartPos);
end;

function WordCount(const S: string; const delimitersTable: TCharsetIndexTable; const StartPos: integer = 1): integer;
begin
  if S = '' then Result := 0
  else Result := CharCount(delimitersTable, S, StartPos) + 1;
end;

function WordCount(const S: string; const delimitersCharClass: TCharClass; const StartPos: integer = 1): integer; overload;
begin
  if S = '' then Result := 0
  else Result := CharCount(ChposK.ChposIndexTables[delimitersCharClass], S, StartPos) + 1;
end;

function fetchWord(const S: string; var StartPos: integer; const Delimiters: TChposCharset): string; overload;
var
  L, p: integer;
begin
  L := length(S);
  Result := '';
  if StartPos > L then
    StartPos := 0
  else if StartPos > 0 then begin
    p := ChPos._eCharPos(Delimiters, S, StartPos);
    if p = 0 then begin
      if StartPos = 1 then
        Result := S
      else
        Result := copy(S, StartPos, L);
      StartPos := 0;
    end
    else begin
      Result := copy(S, StartPos, p - StartPos);
      StartPos := p + 1;
    end
  end;
end;

function fetchWord(const S: string; const WordTable: TCharsetIndexTable; var StartPos: integer): string;
// caution! table is of chars which are considered as word, not delimiters
var
  L, p: integer;
begin
  L := length(S);
  Result := '';
  if StartPos > L then
    StartPos := 0
  else if StartPos > 0 then begin
    p := ChPos.vxCharPos(WordTable, S, StartPos);
    if p = 0 then begin
      if StartPos = 1 then
        Result := S
      else
        Result := copy(S, StartPos, L);
      StartPos := 0;
    end
    else begin
      Result := copy(S, StartPos, p - StartPos);
      StartPos := p + 1;
    end
  end;
end;

function fetchWord(const S: string; var StartPos: integer; const DelimitersTable: TCharsetIndexTable): string;
// caution! table is delimiters set, not chars which are considered as word
var
  L, p: integer;
begin
  L := length(S);
  Result := '';
  if StartPos > L then
    StartPos := 0
  else if StartPos > 0 then begin
    p := ChPos._xCharPos(DelimitersTable, S, StartPos);
    if p = 0 then begin
      if StartPos = 1 then
        Result := S
      else
        Result := copy(S, StartPos, L);
      StartPos := 0;
    end
    else begin
      Result := copy(S, StartPos, p - StartPos);
      StartPos := p + 1;
    end
  end;
end;

function fetchWord(const S: string; const WordClass: TCharClass; var StartPos: integer): string; overload;
// caution! predetermined class is of chars which are considered as word, not delimiters
begin
  Result := fetchWord(S, ChposK.ChposIndexTables[WordClass], StartPos);
end;

function PackWords(const WordTable: TCharsetIndexTable; const S: string; const Delimiter: char): string;
var
  i, k, Len, decLen: integer;
  Buf: pChar;
begin
  Result := S;
  if S <> '' then begin
    Len := length(S);
    decLen := Len - 1;
    if (Len > 0) then begin
      getmem(Buf, len);
      try
        XMove(S[1], buf[0], len);
        i := 1; k := 0;
        repeat
          while (i <= Len) and (WordTable[S[i]] = 0) do
            inc(i);
          while (i <= len) and (WordTable[S[i]] <> 0) do begin
            Buf[k] := S[i];
            inc(i); inc(k);
          end;
          if k < decLen then begin
            buf[k] := Delimiter;
            inc(k);
          end;
        until i > Len;
        while (k > 0) and (buf[k - 1] = Delimiter) do
          dec(k);
        SetLength(Result, k);
        XMove(buf[0], Result[1], k);
      finally
        freemem(buf);
      end;
    end;
  end;
end;

function PackWordsUpperCase(const WordTable: TCharsetIndexTable; const S: string; const delimiter: char): string;
var
  i, k, Len: integer;
  Buf: pChar;
begin
  Result := S;
  if S <> '' then begin
    Len := length(S);
    if (Len > 0) then begin
      getmem(Buf, len);
      try
        XMove(S[1], buf[0], len);
        i := 1; k := 0;
        repeat
          while (i <= Len) and (WordTable[S[i]] = 0) do
            inc(i);
          while (i <= len) and (WordTable[S[i]] <> 0) do begin
            Buf[k] := S[i];
            inc(i); inc(k);
          end;
          if k < i - 1 then begin
            buf[k] := Delimiter;
            inc(k);
          end;
        until i > Len;
        while (k > 0) and (buf[k - 1] = Delimiter) do
          dec(k);
        SetLength(Result, k);
        XMove(buf[0], Result[1], k);
      finally
        freemem(buf);
      end;
    end;
  end;
end;

function PackWords(const WordCharset: TChPosCharset; const S: string; const delimiter: char): string;
var
  i, k, Len, decLen: integer;
  Buf: pChar;
  table: TCharsetIndexTable;
begin
  Result := S;
  if S <> '' then begin
    InitIndexTable(table, WordCharset);
    Len := length(S);
    decLen := Len - 1;
    if (Len > 0) then begin
      getmem(Buf, len);
      try
        XMove(S[1], buf[0], len);
        i := 1; k := 0;
        repeat
          while (i <= Len) and (table[S[i]] = 0) do
            inc(i);
          while (i <= len) and (table[S[i]] <> 0) do begin
            Buf[k] := S[i];
            inc(i); inc(k);
          end;
          if k < decLen then begin
            buf[k] := Delimiter;
            inc(k);
          end;
        until i > Len;
        while (k > 0) and (buf[k - 1] = Delimiter) do
          dec(k);
        SetLength(Result, k);
        XMove(buf[0], Result[1], k);
      finally
        freemem(buf);
      end;
    end;
  end;
end;

function PackWordsUppercase(const WordCharset: TChPosCharset; const S: string; const delimiter: char): string;
var
  i, k, Len: integer;
  Buf: pChar;
  table: TCharsetIndexTable;
begin
  Result := S;
  if S <> '' then begin
    Len := length(S);
    InitIndexTable(table, WordCharset);
    if (Len > 0) then begin
      getmem(Buf, len);
      try
        XMove(S[1], buf[0], len);
        i := 1; k := 0;
        repeat
          while (i <= Len) and (table[S[i]] = 0) do
            inc(i);
          while (i <= len) and (table[S[i]] <> 0) do begin
            Buf[k] := S[i];
            inc(i); inc(k);
          end;
          if k < i - 1 then begin
            buf[k] := Delimiter;
            inc(k);
          end;
        until i > Len;
        while (k > 0) and (buf[k - 1] = Delimiter) do
          dec(k);
        SetLength(Result, k);
        XMove(buf[0], Result[1], k);
      finally
        freemem(buf);
      end;
    end;
  end;
end;

function PackWords(const WordClass: TCharClass; const S: string; const Delimiter: char): string; overload;
begin
  Result := packWords(ChposK.ChposIndexTables[WordClass], S, Delimiter);
end;

function PackWordsUppercase(const WordClass: TCharClass; const S: string; const Delimiter: char): string; overload;
begin
  Result := packWordsUppercase(ChposK.ChposIndexTables[WordClass], S, Delimiter);
end;

{
function packWord(const table: TCharsetIndexTable; const S: string; const StartPos: integer; const delimiter: char): string;
//const DELIMITER = ' ';
asm
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi; push edi; push ebx
    lea esi, S + StartPos -1
    mov ebx, table  // put them here, mov ebx, eax
    sub StartPos, S.SzLen; mov eax, 0; jg @@end
    push ecx                  // ecx = StartPos
    mov eax, Result           // where the result will be stored
    call System.@LStrClr      // cleared for ease
    mov edx, [ESP]            // [esp] is prior ecx value (negative)
    neg edx                   // how much length of str requested
    call System.@LStrSetLength// result: new allocation pointer in EAX
    mov S, [eax]            // eax contains the new allocated pointer -Differ-
    mov edi, [eax]
    mov Result, edi
    pop ecx                   // ecx = StartPos
    xor eax, eax
  @_Loop:
    mov al, [esi]; mov [edi], al
    lea edi, edi +1
    mov eax, ebx + eax*4
    test eax, 1
    lea esi, esi +1; jnz @_ //
    mov al, Delimiter
    cmp [edi-1], al; jnz @_
    dec edi
    mov [edi], al
  @_: inc StartPos; jle @_Loop
    mov eax, Result
    mov edx, eax.SzLen
    sub edi, eax
    cmp edi, edx; jz @@end
    lea eax, Result
    call System.@LStrSetLength
  @@end: pop ebx; pop edi; pop esi
  @@Stop:
end;
}

const
  HIBIT = $7F;
  SPACE = ' ';

  // function AlphaNumCharPos(const S: string; const StartPos: integer; const table): integer;
  // assembler asm
  //   @@Start: test S, S; jz @@zero // check S length
  //     or StartPos, StartPos; jg @@begin //still need to be checked
  //   @@zero: xor eax, eax; jmp @@Stop
  //   @@begin: push esi; push ebx
  //     lea esi, S + StartPos -1
  //     sub StartPos, S.SzLen; jg @@notfound
  //     mov ebx, table
  //     xor ecx, ecx
  //   @_Loop:
  //     mov cl, byte ptr[esi]
  //     cmp byte ptr[esi], SPACE
  //     lea esi, esi +1; jb @@found
  //     inc StartPos; jle @_Loop
  //   @@notfound: mov esi, S
  //   @@found: sub esi, S; mov eax, esi
  //   @@end: pop ebx; pop esi
  //   @@Stop:
  //   end;

//function ControlCharPosOK(const S: string; const StartPos: integer): integer; assembler asm
//  @@Start: test S, S; jz @@zero // check S length
//    or StartPos, StartPos; jg @@begin //still need to be checked
//  @@zero: xor eax, eax; jmp @@Stop
//  @@begin: push esi
//    lea esi, S + StartPos -1
//    sub StartPos, S.SzLen; jg @@notfound
//  @_Loop:
//    cmp byte ptr[esi], SPACE
//    lea esi, esi +1; jb @@found
//    inc StartPos; jle @_Loop
//  @@notfound: mov esi, S
//  @@found: sub esi, S; mov eax, esi
//  @@end: pop esi
//  @@Stop:
//end;
//
//function HiBitCharPosOK(const S: string; const StartPos: integer): integer;
//assembler asm
//  @@Start: test S, S; jz @@zero // check S length
//    or StartPos, StartPos; jg @@begin //still need to be checked
//  @@zero: xor eax, eax; jmp @@Stop
//  @@begin: push esi
//    lea esi, S + StartPos -1
//    sub StartPos, S.SzLen; jg @@notfound
//  @_Loop:
//    cmp byte ptr[esi], hibit
//    lea esi, esi +1; ja @@found
//    inc StartPos; jle @_Loop
//  @@notfound: mov esi, S
//  @@found: sub esi, S; mov eax, esi
//  @@end: pop esi
//  @@Stop:
//  end;

function ControlCharPos(const S: string; const StartPos: integer): integer; asm
// unroll loop. ugly, but considerably faster (~twice)
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; ret //jmp @@Stop
  @@begin: push esi
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; jg @@notfound
  @@Loop:
    cmp byte[esi  ], SPACE; jb @@found0
    cmp byte[esi+1], SPACE; jb @@found1
    cmp byte[esi+2], SPACE; jb @@found2
    cmp byte[esi+3], SPACE; jb @@found3
    //...and so on if you wish

    lea esi,esi+4; add StartPos, 4
    jle @@Loop; jmp @@notfound

  @@found3: inc esi; inc StartPos
  @@found2: inc esi; inc StartPos
  @@found1: inc esi; inc StartPos
  @@found0: inc esi; inc StartPos
  dec StartPos; jle @@found

  @@notfound: mov esi, S
  @@found: sub esi, S; mov eax, esi
  @@end: pop esi
  @@Stop:
end;

function HiBitCharPos(const S: string; const StartPos: integer): integer; asm
// unroll loop. ugly, but considerably faster (~twice)
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; ret //jmp @@Stop
  @@begin: push esi
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; jg @@notfound
  @@Loop:
    cmp byte[esi  ], hibit; ja @@found0
    cmp byte[esi+1], hibit; ja @@found1
    cmp byte[esi+2], hibit; ja @@found2
    cmp byte[esi+3], hibit; ja @@found3
    //...and so on if you wish

    lea esi,esi+4; add StartPos, 4
    jle @@Loop; jmp @@notfound

  @@found3: inc esi; inc StartPos
  @@found2: inc esi; inc StartPos
  @@found1: inc esi; inc StartPos
  @@found0: inc esi; inc StartPos
  dec StartPos; jle @@found

  @@notfound: mov esi, S
  @@found: sub esi, S; mov eax, esi
  @@end: pop esi
  @@Stop:
end;

function ControlCharCount(const S: string; const StartPos: integer = 1): integer;
assembler asm
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; mov S, 0; jg @@done
  @_Loop:
    cmp byte ptr[esi], SPACE
    lea esi, esi +1; jnb @_
    ;inc S
  @_: inc StartPos; jle @_Loop
  @@done: mov eax, S
  @@end: pop esi
  @@Stop:
  end;

function HiBitCharCount(const S: string; const StartPos: integer = 1): integer;
assembler asm
  @@Start: test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; mov S, 0; jg @@done
  @_Loop:
    cmp byte ptr[esi], hibit
    lea esi, esi +1; jna @_
    ;inc S
  @_: inc StartPos; jle @_Loop
  @@done: mov eax, S
  @@end: pop esi
  @@Stop:
  end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// test...
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

const
  _CR = ^m; // $0D
  _LF = ^j; // $0A
  _CRLF = ord(_CR) or (ord(_LF) shr 8); // $0A$0D

function PosCRLF(const S: string; const StartPos: integer = 1): integer;
begin
  //Result := _cWordPos(WideChar(_CRLF), S, StartPos);
  Result := _cWordPos(_CRLF, S, StartPos);
end;

type
  par = ^tar;
  tar = array[0..0] of Char;

function UNIXed(const CRLFText: string): string;
// strip CR from CRLF, CRLF to LF only (unix style)
var
  i, j, k, L: integer;
  Buf: Par;
  S: string;
begin
  Result := CRLFText;
  L := Length(CRLFText);
  if L > 0 then begin
    getMem(Buf, L);
    try
      j := 0; k := 0;
      for i := 1 to ChPos.WordCount(CRLFText, ^m) do begin
        inc(k);
        S := ChPos.WordAtIndex(1, CRLFText, ^m, k);
        L := length(S);
        move(S[1], Buf^[j], L);
        inc(j, L); inc(k, L);
      end;
      if j > 0 then begin
        SetLength(Result, j);
        move(Buf^[0], Result[1], j);
      end;
    finally
      freemem(Buf);
    end;
  end;
end;

// should be faster - untested yet, no time

function UNIXed2(const CRLFText: string): string;
// strip CR from CRLF, CRLF to LF only (unix style)
var
  i, j, k, L: integer;
  Buf: Par;
begin
  Result := CRLFText;
  L := Length(CRLFText);
  if L > 0 then begin
    getMem(Buf, L);
    try
      i := PosCRLF(CRLFText);
      if i > 0 then begin
        j := 1; k := 0;
        while i > 0 do begin
          L := i - j;
          move(CRLFText[j], Buf^[k], L);
          inc(k, L); Buf^[k] := ^j; inc(k);
          j := i + 2;
          i := PosCRLF(CRLFText, j);
        end;
        L := length(CRLFText) - j;
        move(CRLFText[j], Buf^[k], L);

        inc(j, L);
        SetLength(Result, j);
        move(Buf^[0], Result[1], j);
      end;
    finally
      freemem(Buf);
    end;
  end;
end;

function MACed(const CRLFText: string): string;
// strip LF from CRLF, CRLF to CR only (MAC style)
var
  i, j, k, L: integer;
  Buf: Par;
begin
  Result := CRLFText;
  L := Length(CRLFText);
  if L > 0 then begin
    getMem(Buf, L);
    try
      j := 1; k := 0;
      i := PosCRLF(CRLFText);
      if i > 1 then begin
        repeat
          L := i - j - 1; // ecxluding the last-char
          move(CRLFText[j], Buf^[k], L);
          inc(k, L);
          j := i;
          i := PosCRLF(CRLFText, j + 1);
        until i < 1;
      end;
      if j > 1 then begin
        SetLength(Result, j);
        move(Buf^[0], Result[1], j);
      end;
    finally
      freemem(Buf);
    end;
  end;
end;

end.


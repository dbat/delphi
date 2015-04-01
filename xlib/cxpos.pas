unit cxpos;
{$WEAKPACKAGEUNIT ON}
{$I QUIET.INC}
//txSearch.fpPos(
{.$DEFINE DEBUG}// turned off upon release
{
// ====================================================================
//  Copyright (c) 2004, aa, Adrian H., Ray AF. & Inge DR.
//  Property of PT SOFTINDO Jakarta.
//  All rights reserved.
// --------------------------------------------------------------------
//  LICENSE: conditional freeware
//  LICENSE CONDITION:
//    You have granted permission by the authors to alter *any* lines
//    of this document source except Copyright and License Notice :)
// ====================================================================
//
//  unit cxpos, a class extension (+sample implementations) of
//  expos (extended pos), the extremely high performance unit
//  of SubString/Pattern Search & Replace,
//  using the new, proposed Sofyan-Hafizh BoundCheck algorithm,
//  plus assembler (x86) tricks in an advanced delphi programming
//
//  target compiler: Delphi5
//  target CPU: intel 486+ compatible
//              (PentiumTick works only in Pentium+)
//
//  hyperbolic hype:
//  this is the fastest implementation of pattern search algorithm,
//  the replace function is *at-least* 25 times faster than the
//  standard delphi's StringReplace on a very light task, and raised
//  exponentially according to the weight (1000-3000++ times faster
//  on heavy duties ones). note: the number is NOT in percent.
//
//  important notes:
//    the pattern mentioned here is NOT a regular pattern or mask
//    such as "ab*" or "p?q", instead is a sequence of arbitrary
//    characters (bytes) ie. a string as it is, WITHOUT no more
//    interpretation (other than case sensitivity).

//  ===================================================================
//  version: 2.0.4.0
//  Last update: 2006.01.01
//  ===================================================================

//  based on expos Version: 1.0.2.7 (discontinued) by the same authors,
//  (get the expos instead for fully documented source code)
//  We must confess that we have written this implementation with no
//  sense of object-oriented programming in mind.
//  extension:
//    using classes to be thread safe
//    full featured Replace function/procedure
//    added pchar version for raw handling memory/filesize > 2GB
//    added file-based sample implementation
//    moved character centric function to chpos
//    ++
// ====================================================================
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
// ====================================================================
//
}
//
{
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// credits, benchmark & algorithm ~ excerpted from expos version...
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{
   ------------------------------------------------------------------
   This code is formatted by Egbert Van Nese's DelforEx Version 2.4
   (still the best, despite its botch handling caret character)
   ------------------------------------------------------------------
   and we also started to love using GXExpert http://www.gexpert.org
   ------------------------------------------------------------------
}
{
  ...
  benchmark:
    the thanks goes to Peter Morrise's fastStrings unit (ver-3.2)
    and Martin Waldenburg's mwTSearch class (ver-2.0), also Angus
    Johnson's Search component (ver-2.2), whose ideas (and misses)
    has been examined for the advantages to this unit.

    the TmTSearch by Martin Waldenburg appears to be the fastest
    compared to the others, with an exception as described below.

    the Search component by Angus Johnson is the slowest, however
    we admit that it is the best that we could get in pure pascal.

    the fastrings unit by Peter Morris performance took place
    between the two's above (only a bit slower than the 1st),
    and considered to be the most matured one with many folks
    included within the development.

    this unit is quite lot faster than the other's implementations.
    for a common search, (ie. case-sensitive, length > 1, arbitrary
    characters with some are duplicated), she cuts at least 30~40%
    of the processing time. yet if that is not enough, then by the
    insensitive search, charpos and the *ultimate* case & repeated-
    chars detection integrated in this unit, she could be much far
    beyond. (the last one in effect squashes at *minimum* 3X faster!).

    (that is just a benchmark. of course, it's not fair to
    comparing their implementations with single algorithm
    alone with this acrobatic-mixed algorithm).

  algorithm:
    this unit make use of an algorithm similar to boyer-moore's,
    maximize the efficiency based on understanding of the length-
    integrity-check. the core algorithm is basically similar to
    the algorithm applied by Martin Waldenburg. while martin's
    implementation was faster compared with the other two, she had
    still (at least one obvious) gotcha that she failed to catch
    for a repeated-chars, such as 'EEEE' on (N div 2) * N position,
    where N is the length of pattern to find. when she forced to
    give the correct result (the jump altered, as suggested by
    Martin himself), the performance will degrades significantly
    down to that of Boyer-Moore's implementation by faststrings
    unit of Peter Morrise. note however, it means that the
    altered one is not based on her algorithm anymore.

    nevertheless, even the slowest, still is considered better
    than a *fast* one but with defect.

    actually the algorithm that he had used was (perhaps) broken
    (unfortunaltely we have no access to the source doc itself,
    but according to our examination) it had a subtle flaw
    to pick an arbitrarily anchor index (half-pattern length,
    as she called it, we named it boundcheck).
    Generally her matching algorithm works ONLY for non-repeated
    chars, ie. no duplicate characters found in the SubStr/pattern
    to be matched.

    (for more details please read on our analysis paper about this
    indexed-character-based matching algorithm).
  ...

  excerption end.         Reference: Intel's Pentium Developer's Manual
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
}
{
// ====================================================================
// USAGE:
// ====================================================================

  1. add in unit clause:
       uses cxpos;

  2. declare variable of txSearch:
       var
         tx: txSearch;

  3. create an instance of txSearch:
       tx := txSearch.Create;

     note that there are character based search functions
     which already available & do not need an object creation.
     (CharPos & CharCount)

  4. initialize pattern and case option, ie. tells the program
     what substring to be searched for, and whether capitalization
     is important or not. this procedure could be previously done
     at creation stage or delayed later until actual search/replace
     soon to be proceed.

     we called the initialization at creation as noted above as an
     IMPLICIT initialization and the later as EXPLICIT intialization.

     this explicit initialization is quite tight though, the state
     (pattern and case-option) would not be changed if it could be
     detected that the pattern to be matched would never be found
     anyway.

     creation and initialization at once:
       tx := txSearch.Create('Some substrings to be searched for');
       tx := txSearch.Create('another pattern', TRUE); // default = FALSE

     note that once initialized, all subsequent search will be
     using the new/current initialization state

  5. do the actual search:

       i:= tx.Pos(BigString); // default = start from 1
       i:= tx.Pos(BigString, 1969); // start from position 1969

     as mentioned above, we may delay initialization until
     actual search, this also required if we change/start a new
     pattern to be searched for (or change its case option):

       i := tx.pos(BigString, 'pattern', TRUE, 1969)
       i := tx.pos(BigString, 'pattern2') // default = start from 1

  6. miscellaneous sample implementation,
       function StrCount, returns count of the pattern
       function StrCountInfile, returns count of the pattern within a file
       function StrReplace, returns the string of Search/Replace
       procedure ReplaceStr, simply a StrReplace function wrapper
       FindFirst/Next/Close, search within a file
       FileReplace, replace within a file

  7. function prototypes
     a.for searching a pattern
         function(SubStr, S, StartPos, IgnoreCase)

     b.for searching pattern within a file
         FindInfile(SubStr, FileName, StartPos, IgnoreCase, KeepPriorState)

     c.for search and replace:
         function(S, SubStr, Replacement, StartPos, IgnoreCase, ReplaceAll)

     d.for search and replace within a file
       (actually with the same order and types as above):
         function(FileName, SubStr, Replacement, StartPos, IgnoreCase, ReplaceAll)

       required arguments are S (or FileName) and SubStr, the remaining
       arguments ar optional with default values:
         StartPos = 1
         IgnoreCase = FALSE
         CloseFind = FALSE (close file after file-search proceed)
         ReplaceAll = TRUE

       when initialization has been done, either by calling function
       with complete arguments as above or by explicitly call Init then
       subsequent calls should be without: SubStr & IgnoreCase option

       a'.for searching a pattern:
            function(S, StartPos)

       b'.for searching pattern within a file
           FindFirst(FileName, StartPos)
           FindFrom(StartPos, CloseFind)
           FindNext(CloseFind)
           FindClose

       c'.for search and replace:
           function(S, Replacement, StartPos, ReplaceAll)

       d'.for search and replace within a file
           function(FileName, Replacement, StartPos, ReplaceAll)

       for searching within a file, there is special group of functions
       (for our convenience), namely findFirst, findNext and findClose.
       the findFirst function works as b'. above:

         CloseFind option means to reset the find-state
         (filename, handles, size, position, etc.) of the
         opened file. the state will not be changed, if the
         program could detect earlier that the pattern to be
         matched would not ever been found anyway.

         the same rules also applied for replace in file, for
         example, if we tried to proceed a 0-size file, or the
         file size < pattern-length, or replace by the same pattern
         (with case sensitive on), the program will not dumbly
         continued our request. since file processing is always
         expensive, the program will avoid them as she could.

       actually the findfirst is not limited only to the first
       occurence of pattern, since the StartPos could be given
       in anywhere, whereas the findNext is always get the next
       occurence of pattern (if any) of the previous findFirst
       result.

       those group of functions should have been properly
       initialized before they are used.

       use FindInfile instead to initialize the pattern &
       case-option.

       if KeepPriorState options set to TRUE then the previous
       find-state of the findfirst family (if any) will be
       preserved (this one-shot feature is useful if you have
       to intterupt the ongoing process of findfirst function
       family without disturbing them), otherwise (if it set
       to FALSE) then the previous find-state will be closed
       and changed according to the find-state of successful
       FindInfile (if FindInfile  fails, the previous
       find-state wouldn't be changed).

  -  there are two forms of search: against a String or pointer.
     use the pointer form to search in memory, file buffer, pchar etc.

  -  File-based replace, effective for a very large file, and the most
     important is- when the filesize is expected not to be changed,
     ie. when the length of pattern to be searched is equal with its
     replacement, then it should be much faster than utilizing temporary
     string & filestream.

     using direct file access, beside of speed gain, also means we do
     not have to allocate temporary buffer (thus wasting memory) by
     the same amount of file size, this especially much worth when the
     file is large enough.

  -  stop.
}
{
// ====================================================================
   COPYRIGHT NOTICE:

      usage of this program, or part of it, in any purposes, must
      aknowledge the original authors as mentioned above.

   ...
   we mean it.
// ====================================================================
}
//  =======
//  CHANGES
//  =======

{
   version: 2.0.3.2
   ================
   1. Singular pattern detection bug fixed
   2. Case-sensitive detection bug fixed
   3. Add special treatment for a single chars-pair

   Notes:
   We found that BoundCheck supposed to be Sub-Optimal (rather than Super-
   Optimal) for small string. It best for special case (such as substr to
   be found is long enough and its composed by varies enough characters),
   for it wasted too much clocks for calculating Index-Values (at least with
   additional 5-6 instructions per cycle), suppressing its efficiency.
   The speed superiority we have got here is NOT a credit of BoundCheck
   but rather of assembler tweaking plus various mixed detection algorithm.
   Curently, the BoundCheck at first ordinal position is the (only) state
   that additional speed we might get will be fair enough compared to the
   cost of calculating Index-Values.

   version: 2.0.3.1
   ================
   here are only quick-fix not to mention for a final (efficient) release
   important note:
   1. bug-fix for version 2.0.3.0 (inbound-scanning previously done from
      low to high ordinal position (for ease), that was simply violates
      the very principle rule of range-bound, duh...)
   2. singular pattern recognizer false detection. since we have not yet
      figured out why, we suspend this feature, open for comment/reports
   3. the same initialization (substr & case) resulting in different state,
      we can not yet even to reproduce this bug, open for comment/reports
   As our motto:
      The slowest one still is better than even the fastest with some bug

   version: 2.0.3.0
   ================
   Documenting revision changes starting from version 2.0.3.0?
   Better late than never :)

   actually, since the old code rarely deleted (they only commented)
   we could track the change after that.

   most important changes were:
     - separation of char-based primitive routines to chpos unit
         charpos now also supports backpos direction search
     - separation of file-handling operation to cxfvmap unit
         (we intended to pick a cryptic name to avoid usage
         of that very specific unit outside cxpos)
     - SpeedTest demo (benchmark)
     - Ressurection of expos (the original, direct ancestor of cxpos)
}
{$J-} //no-writeableconst
{$R-} //no-rangechecking
{$Q-} //no-overflowchecking
{.$D-}//no-debug
{.$WARNINGS OFF}// shut-up! :)
{$HINTS ON}
interface
//type
//  txFileName = string[240];
type
  THandle = integer;
  DWORD = longword;

  txSearch = class
  private
{$IFDEF DEBUG}public
{$ENDIF}
    fPattern: string;
    fPatLen: integer;
    fPatLen_1: integer;
    //fnegPatLen_1: integer;
    //fpPattern: pointer {PChar};
    fBoundCheck: integer;
    //fMidBound: boolean;
    fOneChars: integer;
    fFirstIndex, fLastIndex: integer;
    fIgnoreCase: boolean;
    fSingular: boolean;
    //fPerfectSeq: boolean;
    fIndex: packed array[char] of integer; // Jump table (1024 bytes)
  private
    function GetIndexValue(const Ch: Char): integer;
    //function fpPos_buggy1(const P: pointer {PChar};
    //  const StartPos, PLength: integer): integer;
{$IFDEF DEBUG2}
    //public
    //  function fpPosPlain(const P: pointer {PChar};
    //    const StartPos, PLength: integer): integer;
{$ENDIF}
  private
    function fpPos(const P: pointer {PChar};
      const StartPos, PLength: integer): integer;
    function CharPos(const Ch: Char; const S: string; const StartPos: integer;
      const IgnoreCase: boolean = FALSE): integer; overload;
    function CharPos(const Ch: Char; const S: string;
      const IgnoreCase: boolean = FALSE;
      const StartPos: integer = 1): integer; overload;
    function SameInitState(const FileName, SubStr: string;
      const IgnoreCase: boolean): boolean; overload;
    function SameInitState(const SubStr: string;
      const IgnoreCase: boolean): boolean; overload;
    //function fprefFind(const FileName, SubStr, ReplaceWith: string;
    //  const IgnoreCase: boolean): boolean; overload;
    function PreInitStr(const S, SubStr, ReplaceWith: string;
      const IgnoreCase: boolean): boolean; overload;
    function PreInitFile(const FileName, SubStr, ReplaceWith: string;
      const IgnoreCase: boolean): boolean; overload;

  protected
{$IFDEF DEBUG}public{$ENDIF}
    property BoundCheck: integer read fBoundCheck;
    property IndexValues[const Ch: Char]: integer read GetIndexValue;
  public
    constructor Create; overload;
    constructor Create(const SubStr: string;
      const IgnoreCase: boolean = FALSE); overload;
    destructor Destroy; override;
    function Init(const SubStr: string;
      const IgnoreCase: boolean = FALSE): boolean;
    function PentiumTick: Int64; // only for pentium+!
    //***Apparently NOT work with D7***
    //property Pattern: string read fPattern; //DEBUG
    //property PatternLength: integer read fPatLen; //DEBUG
  public
{$IFDEF DEBUG}
    function PatternIndexValues(const HexStyle: boolean = TRUE): string; virtual;
{$ENDIF DEBUG}
    function Pos(const SubStr, S: string; const StartPos: integer = 1;
      const IgnoreCase: boolean = FALSE): integer; overload;
    function Pos(const S: string; const StartPos: integer = 1): integer; overload;
    function Pos(const P: pointer {PChar}; const PLength: integer;
      const StartPos: integer = 1): integer; overload;
    // ==============================
    // sample implementation follows:
    // ==============================
  private
    //function fpReplaced(const P: PChar; const SubStr, ReplaceWith: string;
    //  StartPos, PLength {, ReplaceCount}: integer; const IgnoreCase,
    //  inPlace: boolean): string; overload;
    //function fpReplaced(const P: pointer {PChar}; const ReplaceWith: string;
    //  StartPos, PLength {, ReplaceCount}: integer;
    //  const inPlace: boolean): string; overload;
    //function fReplaced(const S, SubStr, ReplaceWith: string; StartPos: integer;
    //  IgnoreCase: boolean {; ReplaceCount: integer}): string; overload;
    function OneReplacement(const S, ReplaceWith: string;
      const StartPos: integer): string;
    function fReplaced(const S: string; const ReplaceWith: string = '';
      const StartPos: integer = 1;
      const ReplaceAll: boolean = TRUE): string; overload;
    function ffReplaced(var P: pointer {PChar}; const ReplaceWith: string;
      const StartPos, PLength: integer; const ReplaceAll: boolean): integer;
    // beware, ffReplaced function returns INVALID_RETURN_VALUE on fails
    // (not 0 as usual, since 0 is a valid return value here)
  public
    function Count(const SubStr, S: string; const StartPos: integer = 1;
      const IgnoreCase: boolean = FALSE): integer; overload;
    function Count(const SubStr, S: string; const IgnoreCase: boolean;
      const StartPos: integer = 1): integer; overload;
    function Count(const S: string;
      const StartPos: integer = 1): integer; overload;
    function StrReplace(const S: string; const ReplaceWith: string = '';
      const StartPos: integer = 1;
      const ReplaceAll: boolean = TRUE): string; overload;
    function StrReplace(const S, SubStr: string; const ReplaceWith: string = '';
      const StartPos: integer = 1; const IgnoreCase: boolean = FALSE;
      const ReplaceAll: boolean = TRUE): string; overload;
    procedure Replace(var S: string; const ReplaceWith: string = '';
      const StartPos: integer = 1; const ReplaceAll: boolean = TRUE); overload;
    procedure Replace(var S: string; const SubStr: string;
      const ReplaceWith: string = ''; const StartPos: integer = 1;
      const IgnoreCase: boolean = FALSE;
      const ReplaceAll: boolean = TRUE); overload;
  private
    // file-based sample implementation:
    fFileName: string;
    fFileHandle, fMapHandle: THandle;
    fViewBase: pointer {PChar};
    fSize, fPos: integer;
    procedure ResetFileState;
    function InfileOpen(const FileName: string; const StartPos: integer;
      const Promote: boolean): integer;
  public
    function InfilePos(const SubStr, FileName: string;
      const StartPos: integer = 1; const IgnoreCase: boolean = FALSE;
      const KeepPriorState: boolean = FALSE): integer;
    function FindFirst(const FileName: string;
      const StartPos: integer = 1): integer;
    //const CloseFind: boolean = FALSE): integer;
    function FindNext(const CloseFind: boolean = FALSE): integer;
    function FindFrom(const StartPos: integer;
      const CloseFind: boolean = FALSE): integer;
    function FindClose: boolean;
    function InfileCount(const SubStr, FileName: string; const StartPos: integer = 1;
      const IgnoreCase: boolean = FALSE): integer; overload;
    function InfileCount(const SubStr, FileName: string; const IgnoreCase: boolean;
      const StartPos: integer = 1): integer; overload;
    function InfileCount(const FileName: string;
      const StartPos: integer = 1): integer; overload;
  public
    function InfileReplace(const Filename, SubStr, ReplaceWith: string;
      const StartPos: integer = 1; const IgnoreCase: boolean = FALSE;
      const ReplaceAll: boolean = TRUE;
      const RetainFileTime: boolean = FALSE): integer; overload;
    function InfileReplace(const Filename: string; const ReplaceWith: string = '';
      const StartPos: integer = 1; const ReplaceAll: boolean = TRUE;
      const RetainFileTime: boolean = FALSE): integer; overload;
  end;
  //end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ MOVED to ChPos unit
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ // quite independent functions, in case you do not want to create
//~ // an instance of txSearch just for finding / counting a single char
//~ function CharPos(const Ch: Char; const S: string; const StartPos: integer;
//~   const IgnoreCase: boolean = FALSE;
//~   const BackPos: boolean = FALSE): integer; register overload
//~ function CharPos(const Ch: Char; const S: string;
//~   const IgnoreCase: boolean = FALSE; const StartPos: integer = 1;
//~   const BackPos: boolean = FALSE): integer; register overload
//~ function CharCount(const Ch: Char; const S: string; const StartPos: integer;
//~   const IgnoreCase: boolean = FALSE): integer; register overload
//~ function CharCount(const Ch: Char; const S: string; const IgnoreCase: boolean = FALSE;
//~   const StartPos: integer = 1): integer; register overload
//~
//additional helper functions. might be placed below implementation if you'd like to
//~ function SameText(const S1, S2: string;
//~   const IgnoreCase: boolean = TRUE): boolean; forward;
//~ function SameBuffer(const P1, P2; const L1, L2: integer;
//~   const IgnoreCase: boolean = TRUE): boolean; forward;
//~ procedure xMove(const Src; var Dest; Count: integer); register assembler; forward
//~ function IntoStr(const I: integer): string; forward
//~ function IntoHex(const I: Int64; const Digits: byte = sizeof(byte)): string
//~   register assembler; forward
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ MOVED to ChPos unit
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ function UPPERSTR(const S: string): string;
//~ function lowerstr(const S: string): string;
//~ procedure UPPERBUFF(var Buffer; const Length: integer);
//~ procedure lowerbuff(var Buffer; const Length: integer);
//~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ MOVED to cxGlobal unit
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ const
//~   INVALID_RETURN_VALUE = -1;

// // these stuffs actually should not be here
// function GetFileSize(const FileName: string): integer {Int64}; forward; overload;
// function GetFileTime(const FileName: string): integer; forward; overload;
// function SetFileTime(const FileName: string; const FileTime: integer): integer; forward; overload;

implementation
uses CxGlobal, ChPos, cxfvmap;

//uses cxposwin;
//uses patdecod, miscwin; // DEBUG
//uses ACommon; // DEBUG

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ MOVED to ChPos unit
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ /// the PChar version could handle length upto 4.2G.
//~ function pcCharPos(const Ch: Char; const P: PChar; const StartPos,
//~   PLength: dword): integer register assembler; overload forward
//~ function piCharPos(const Ch: Char; const P: PChar; const StartPos,
//~   PLength: dword): integer register assembler; overload forward
//~ function _cCharPos(const Ch: Char; const S: string;
//~   const StartPos: integer = 1): integer register assembler; overload forward
//~ function _iCharPos(const Ch: Char; const S: string;
//~   const StartPos: integer = 1): integer register assembler; overload forward
//~
//~ function pbcCharPos(const Ch: Char; const P: PChar;
//~   const StartPos, PLength: dword): integer register assembler; overload forward
//~ function pbiCharPos(const Ch: Char; const P: PChar;
//~   const StartPos, PLength: dword): integer register assembler; overload forward
//~ function _bcCharPos(const Ch: Char; const S: string;
//~   const StartPos: integer = {0} 1): integer register assembler; overload forward
//~ function _biCharPos(const Ch: Char; const S: string;
//~   const StartPos: integer = 0): integer register assembler; overload forward
//~
//~ function pcCharCount(const Ch: Char; const P: PChar;
//~   const StartPos, PLength: dword): integer register assembler; overload forward
//~ function piCharCount(const Ch: Char; const P: PChar;
//~   const StartPos, PLength: dword): integer register assembler; overload forward
//~ function _cCharCount(const Ch: Char; const S: string;
//~   const StartPos: integer = 1): integer register assembler; overload forward
//~ function _iCharCount(const Ch: Char; const S: string;
//~   const StartPos: integer = 1): integer register assembler; overload forward
//~ ///

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ MOVED to cxGlobal unit
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ // from System Unit
//~ type
//~   StrRec = packed record
//~     AllocSize, RefCount, Length: integer;
//~   end;
//~
//~ const
//~   Sz_ = sizeof(StrRec);
//~   szLen = -Sz_ + sizeof(integer) + sizeof(integer);
//~   YES = TRUE;
//~   CPUID = $A20F;
//~   RDTSC = $310F;
//~   MAXBYTE = high(byte);
//~   PAGESIZE = MAXBYTE + 1;
//~
//~ var
//~   UPCASETABLE, locasetable: array[char] of char;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ MOVED to ChPos unit
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ function {txSearch} CharPos(const Ch: Char; const S: string;
//~   const StartPos: integer; const IgnoreCase: boolean = FALSE;
//~   const BackPos: boolean = FALSE): integer;
//~ begin
//~   if not BackPos then begin
//~     if IgnoreCase then
//~       Result := _iCharPos(Ch, S, StartPos)
//~     else
//~       Result := _cCharPos(Ch, S, StartPos)
//~   end
//~   else begin
//~     if IgnoreCase then
//~       Result := _biCharPos(Ch, S, StartPos)
//~     else
//~       Result := _bcCharPos(Ch, S, StartPos)
//~   end;
//~ end;
//~
//~ function {txSearch} CharPos(const Ch: Char; const S: string;
//~   const IgnoreCase: boolean = FALSE; const StartPos: integer = 1
//~   ; const BackPos: boolean = FALSE): integer;
//~ begin
//~   Result := ChPos.CharPos(Ch, S, StartPos, IgnoreCase, BackPos)
//~ end;
//~
//~ function {txSearch} CharCount(const Ch: Char; const S: string;
//~   const StartPos: integer; const IgnoreCase: boolean = FALSE): integer;
//~ begin
//~   if IgnoreCase then
//~     Result := _iCharCount(Ch, S, StartPos)
//~   else
//~     Result := _cCharCount(Ch, S, StartPos)
//~ end;
//~
//~ function {txSearch} CharCount(const Ch: Char; const S: string;
//~   const IgnoreCase: boolean = FALSE; const StartPos: integer = 1): integer;
//~ begin
//~   Result := cxpos.CharCount(Ch, S, StartPos, IgnoreCase)
//~ end;
//~

const
  INVALID = INVALID_RETURN_VALUE;

procedure txSearch.ResetFileState;
begin
  fFileName := BLANK; fViewBase := VOID;
  fFileHandle := INVALID; fSize := INVALID;
  fMapHandle := ZERO; fPos := ZERO;
end;

constructor txSearch.Create;
begin
  inherited;
  fPattern := BLANK; {fpPattern := VOID;} fOneChars := zero;
  fPatLen := ZERO; fPatLen_1 := ZERO; {fnegPatLen_1 := ZERO;} fBoundCheck := ZERO;
  fIgnoreCase := FALSE; fSingular := FALSE;
  //file-based sample implementation:
  Self.ResetFileState;
end;

constructor txSearch.Create(const SubStr: string;
  const IgnoreCase: boolean = FALSE);
begin
  Self.Create;
  Init(SubStr, IgnoreCase);
end;

destructor txSearch.Destroy;
begin
  Self.FindClose;
  inherited;
end;

function txSearch.Pos(const S: string; const StartPos: integer = 1):
  integer;
begin
  if S = '' then
    Result := 0
  else
    Result := Self.fpPos(pointer(S), StartPos,
      integer(pointer(integer(S) - 4)^));
end;

function txSearch.Pos(const SubStr, S: string; const StartPos: integer = 1;
  const IgnoreCase: boolean = FALSE): integer;
begin
  if not SameInitState(SubStr, IgnoreCase) then
    Init(SubStr, IgnoreCase);
  Result := Self.Pos(S, StartPos)
end;

function txSearch.Pos(const P: pointer {PChar}; const PLength: integer;
  const StartPos: integer = 1): integer;
begin
  if PLength < 1 then
    Result := 0
  else
    Result := Self.fpPos(P, StartPos, PLength)
end;

function txSearch.CharPos(const Ch: Char; const S: string; const
  StartPos: integer; const IgnoreCase: boolean = FALSE): integer;
begin
  Result := Self.CharPos(Ch, S, StartPos, IgnoreCase);
end;

function txSearch.CharPos(const Ch: Char; const S: string; const
  IgnoreCase: boolean = FALSE; const StartPos: integer = 1): integer;
begin
  Result := Self.CharPos(Ch, S, StartPos, IgnoreCase);
end;

function txSearch.Count(const S: string;
  const StartPos: integer = 1): integer; register
var
  i, SLen: integer;
begin
  Result := 0;
  i := Pos(S, StartPos);
  if i > 0 then begin
    SLen := length(S);
    while i > 0 do begin
      inc(Result);
      i := fpPos(pointer(S), i + fPatLen, SLen);
    end;
  end;
end;

function txSearch.Count(const SubStr: string; const S: string;
  const StartPos: integer = 1; const IgnoreCase: boolean = FALSE): integer; register
begin
  case length(SubStr) of
    1: Result := CharCount(SubStr[1], S, IgnoreCase, StartPos);
    2: Result := WCharCount(SubStr, S, IgnoreCase, StartPos);
  else begin
      if not SameInitState(SubStr, IgnoreCase) then
        Init(SubStr, IgnoreCase);
      Result := Self.Count(S, StartPos)
    end
  end;
end;

function txSearch.Count(const SubStr: string; const S: string;
  const IgnoreCase: boolean; const StartPos: integer = 1): integer; register
begin
  Result := Self.Count(SubStr, S, StartPos, IgnoreCase);
end;

function txSearch.StrReplace(const S: string; const ReplaceWith: string = '';
  const StartPos: integer = 1; const ReplaceAll: boolean = TRUE): string;
begin // OK
  // dont bother to check S or SubStr here, the called function will do it very well
  if (fPattern = ReplaceWith) and not fIgnoreCase then
    Result := S
  else if ReplaceAll then
    Result := fReplaced(S, ReplaceWith, StartPos {, ReplaceCount})
  else
    Result := OneReplacement(S, ReplaceWith, StartPos)
end;

function txSearch.OneReplacement(const S, ReplaceWith: string;
  const StartPos: integer): string;
var
  i: integer;
begin
  i := Pos(S, StartPos);
  if i < 1 then
    Result := S
  else
    Result := copy(Result, 1, i - 1) + copy(Result, i + fPatLen, MaxInt);
end;

function txSearch.GetIndexValue(const Ch: Char): integer;
begin
  Result := fIndex[Ch];
end;

function txSearch.PreInitStr(const S, SubStr, ReplaceWith: string;
  const IgnoreCase: boolean): boolean;
begin
  Result := (S <> '') and (SubStr <> '') and (length(S) >= length(SubStr)) and
    ((SubStr <> ReplaceWith) or IgnoreCase)
end;

function txSearch.StrReplace(const S, SubStr: string;
  const ReplaceWith: string = ''; const StartPos: integer = 1;
  const IgnoreCase: boolean = FALSE;
  const ReplaceAll: boolean = TRUE): string; register
begin
  // catch as early as possible to avoid useless initialization
  // comparing with BLANK is efficient. dont remove
  if not PreInitStr(S, SubStr, ReplaceWith, IgnoreCase) then
    Result := S
  else begin
    if not SameInitState(SubStr, IgnoreCase) then
      Init(SubStr, IgnoreCase);
    Result := {Self.} StrReplace(S, ReplaceWith, StartPos, ReplaceAll);
  end;
end;

procedure txSearch.Replace(var S: string; const ReplaceWith: string = '';
  const StartPos: integer = 1; const ReplaceAll: boolean = TRUE);
begin
  S := {Self.} StrReplace(S, ReplaceWith, StartPos, ReplaceAll);
end;

procedure txSearch.Replace(var S: string; const SubStr: string;
  const ReplaceWith: string = ''; const StartPos: integer = 1;
  const IgnoreCase: boolean = FALSE; const ReplaceAll: boolean = TRUE);
begin
  // not yet optimized, simply calls StrReplace
  S := {Self.} StrReplace(S, SubStr, ReplaceWith, StartPos, IgnoreCase, ReplaceAll);
end;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  This mess MOVED to separated unit: cxfvmap
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ const
//~ // Borrowed from SysUtils
//~   { Open Mode }
//~   fmOpenRead = $0000;
//~   fmOpenWrite = $0001;
//~   fmOpenReadWrite = $0002;
//~   fmOpenQuery = $0003;
//~
//~   fmShareCompat = $0000;
//~   fmShareExclusive = $0010;
//~   fmShareDenyWrite = $0020;
//~   fmShareDenyRead = $0030;
//~   fmShareDenyNone = $0040;
//~
//~   { Creation Mode }
//~   //CREATE_NONE = 0; {$EXTERNALSYM CREATE_NONE}
//~   //CREATE_NEW = 1; {$EXTERNALSYM CREATE_NEW}
//~   //CREATE_ALWAYS = 2; {$EXTERNALSYM CREATE_ALWAYS}
//~   //OPEN_EXISTING = 3; {$EXTERNALSYM OPEN_EXISTING}
//~   //OPEN_ALWAYS = 4; {$EXTERNALSYM OPEN_ALWAYS}
//~   //TRUNCATE_EXISTING = 5; {$EXTERNALSYM TRUNCATE_EXISTING}
//~
//~   fcCreateNone = 0; //none specified //$000;//CREATE_NONE;
//~   fcCreateNew = 1; //fail if already existed //$0100;//CREATE_NEW;
//~   fcCreateAlways = 2; //create, overwrite if already existed //$0200;//CREATE_ALWAYS;
//~   fcOpenExisting = 3; //open-only, fail if not already existed //$0300;//OPEN_EXISTING;
//~   fcOpenAlways = 4; //open file, create if not exist //$0400;//OPEN_ALWAYS;
//~   fcTruncateExisting = 5; //truncate existing file 0-size, fail if not already existed //$0500;//TRUNCATE_EXISTING;
//~
//~   { File attribute constants }
//~   faNone = $0;
//~   faReadOnly = $00000001;
//~   faHidden = $00000002;
//~   faSysFile = $00000004;
//~   faVolumeID = $00000008;
//~   faDirectory = $00000010;
//~   faArchive = $00000020;
//~   faAnyFile = $0000003F;
//~   faNormal = $00000080;
//~
//~   fPosFromBeginning = 0;
//~   fPosFromCurrent = 1;
//~   fPosFromEnd = 2;
//~
//~ ///these are needed only for file-based sample implementation
//~ //function FileSize(const FileName: string): integer {Int64}; forward;
//~ //function FileTime(const FileName: string): integer; forward;
//~ function fhandleOpen(const FileName: string; Mode: dword): integer; forward;
//~ function CreateFile(FileName: PChar; Access, Share: dword; Security: pointer; //windows
//~   Disposition, Flags: dword; Template: integer): integer; stdcall; forward
//~ function fhandleClose(handle: integer): longbool; stdcall; forward;
//~ function SetfPos(handle: integer; OffsetLow: LongInt; OffSetHigh: pointer;
//~   Movement: dword): dword; stdcall; forward;
//~ function SetEOF(handle: integer): longbool; stdcall; forward;
//~ function CreateFileMapping(handle: integer; SecAttributes: pointer; MapMode,
//~   MaxSizeHigh, MaxSizeLow: dword; FileName: PChar): integer; stdcall; forward
//~ function MapViewOfFile(handle: integer; Access: dword;
//~   OffHigh, OffLow, Length: dword): PChar; stdcall; forward
//~ function FlushViewOfFile(const Base: Pointer; Length: dword): longbool; stdcall; forward
//~ function UnmapViewOfFile(Base: Pointer): longbool; stdcall; forward
//~ ///
//~                           //windows

//~ function GetFileSize(const FileName: string): integer {Int64}; forward; overload;
//~ function GetFileTime(const FileName: string): integer; forward; overload;
//~ function SetFileTime(const FileName: string; const FileTime: integer): integer; forward; overload;

//procedure RaiseException(Code: dword = $DEADF00; Flags: dword = 1;
//  ArgCount: dword = 0; Arguments: pointer = nil) stdcall; forward

//  ~~~~~~~~~~~~~~~~~~~
//  OLD messy function
//  ~~~~~~~~~~~~~~~~~~~
//  function txSearch.fFindOpen(const FileName: string; const StartPos: integer;
//    const Promote: boolean): integer;
//  const
//    OF_READ = 0; //{$EXTERNALSYM OF_READ}
//    OF_SHARE_DENY_NONE = $40; //{$EXTERNALSYM OF_SHARE_DENY_NONE}
//    PAGE_READONLY = 2; //{$EXTERNALSYM PAGE_READONLY}
//    SECTION_MAP_READ = 4; //{$EXTERNALSYM SECTION_MAP_READ}
//    //fmOpenRead = OF_READ;
//    //fmShareDenyNone = OF_SHARE_DENY_NONE;
//  const
//    BACKSLASH = '\';
//    DESIRED_ACCESS = SECTION_MAP_READ;
//    FILEOFFSET_HIGH = ZERO;
//    FILEOFFSET_LOW = ZERO;
//    MAXSIZE_HIGH = ZERO;
//    MAXSIZE_LOW = ZERO;
//    NUMBEROFBYTES = ZERO;
//    ATTRIBUTES = VOID;
//    INVALID_MAP = ZERO; // ***inavlid map file returns 0, not -1
//  var
//    i, fSize, filehandle, maphandle: integer;
//    ViewBase: pointer;
//    mapname: string;
//  begin
//    Result := 0;
//    filehandle := fhandleOpen(Filename, fmOpenRead or fmShareDenyNone);
//    if filehandle > 0 then begin
//      fSize := cxfvmap.getFileSize(FileName);
//      SetfPos(filehandle, 0, VOID, 0);
//      i := _bcCharPos(BACKSLASH, FileName, length(FileName));
//      if i > 1 then mapname := copy(Filename, i + 1, MaxInt)
//      else mapname := FileName;
//      maphandle := CreateFileMapping(filehandle, ATTRIBUTES,
//        PAGE_READONLY, MAXSIZE_HIGH, MAXSIZE_LOW, PChar(mapname));
//      if maphandle > INVALID_MAP then begin
//        ViewBase := MapViewOfFile(maphandle, DESIRED_ACCESS,
//          FILEOFFSET_HIGH, FILEOFFSET_LOW, NUMBEROFBYTES);
//        if ViewBase <> VOID then begin
//          Result := fpPos(ViewBase, StartPos, fSize);
//          if (Result > 0) and Promote then begin
//            Self.FindClose;
//            fFileName := FileName;
//            ffSize := fSize;
//            ffilehandle := filehandle;
//            fxmaphandle := maphandle;
//            fViewBase := ViewBase;
//            ffPos := Result;
//          end
//          else begin
//            unmapViewOfFile(ViewBase);
//            fhandleClose(maphandle);
//            fhandleClose(filehandle);
//          end
//        end
//      end
//    end;
//  end;

function txSearch.InfileOpen(const FileName: string; const StartPos: integer;
  const Promote: boolean): integer;
var
  Size, filehandle, maphandle: integer;
  ViewBase: pointer;
begin
  Result := 0;
  ViewBase := cxfvmap.OpenView(FileName, filehandle, maphandle);
  if ViewBase <> VOID then begin
    Size := cxfvmap.GetFileSize(Filename);
    Result := fpPos(ViewBase, StartPos, Size);
    if (Result > 0) and Promote then begin
      Self.FindClose;
      fFileName := FileName;
      fSize := Size;
      fFileHandle := filehandle;
      fMapHandle := maphandle;
      fViewBase := ViewBase;
      fPos := Result;
    end
    else
      cxfvmap.CloseView(filehandle, maphandle, ViewBase);
  end
end;

function txSearch.FindClose: boolean;
begin
  Result := fFileName = BLANK;
  try
    //unmapViewOfFile(fViewBase);
    //fhandleClose(ffmaphandle);
    //fhandleClose(ffilehandle);
    cxfvmap.CloseView(ffilehandle, fmaphandle, fViewBase);
    Self.ResetFileState;
  except
    Result := FALSE;
  end;
end;

function txSearch.FindFirst(const Filename: string;
  const StartPos: integer = 1): integer; //const CloseFind: boolean = FALSE): integer;
begin
  if cxfvmap.GetFileSize(FileName) < length(fPattern) then
    Result := 0
  else
    Result := InfileOpen(FileName, StartPos, TRUE);
  fPos := Result;
end;

function txSearch.FindNext(const CloseFind: boolean = FALSE): integer;
begin
  Result := fPos;
  if Result > 0 then
    Result := FindFrom(Result + fPatLen, CloseFind);
end;

function txSearch.FindFrom(const StartPos: integer;
  const CloseFind: boolean = FALSE): integer;
begin
  if fViewBase <> nil then begin
    Result := fpPos(fViewBase, StartPos, fSize)
  end
  else
    Result := 0;
  if CloseFind then
    Self.FindClose
  else
    fPos := Result;
end;

function txSearch.InfilePos(const SubStr, Filename: string;
  const StartPos: integer = 1; const IgnoreCase: boolean = FALSE;
  const KeepPriorState: boolean = FALSE): integer;
var
  fSize: integer;
begin
  if SameInitState(FileName, SubStr, IgnoreCase) then
    Result := FindFrom(StartPos)
  else begin
    Result := 0;
    fSize := cxfvmap.GetFileSize(FileName);
    if (fSize < 1) or (fSize < length(SubStr)) then
    else begin
      if not SameInitState(SubStr, IgnoreCase) then
        Init(SubStr, IgnoreCase);
      Result := InfileOpen(FileName, StartPos, not KeepPriorState);
    end
  end
end;

function txSearch.InfileCount(const FileName: string;
  const StartPos: integer = 1): integer;
begin
  Result := 0;
  if Self.FindFirst(FileName, StartPos) > 0 then begin
    inc(Result);
    while FindNext > 0 do
      inc(Result);
    Self.FindClose;
  end;
end;

function txSearch.InfileCount(const SubStr, FileName: string;
  const StartPos: integer = 1; const IgnoreCase: boolean = FALSE): integer;
begin
  Result := 0;
  if Self.InfilePos(SubStr, FileName, StartPos, IgnoreCase, FALSE) > 0 then begin
    inc(Result);
    while FindNext > 0 do
      inc(Result);
    Self.FindClose;
  end;
end;

function txSearch.InfileCount(const SubStr, FileName: string;
  const IgnoreCase: boolean; const StartPos: integer = 1): integer;
begin
  Result := Self.InfileCount(SubStr, FileName, StartPos, IgnoreCase);
end;

//function GetfTime(handle: integer; Create, Access, Write: int64): longbool;
//  stdcall; forward; overload;
//function SetfTime(handle: integer; Create, Access, Write: int64): longbool;
//  stdcall; forward; overload;
//function GetFileTime(const handle: integer): Int64; forward; overload;
//procedure SetFileTime(const handle: integer; const FileTime: Int64); forward; overload;

//  ~~~~~~~~~~~~~~~~~~~
//  OLD messy function
//  ~~~~~~~~~~~~~~~~~~~
//  function txSearch.ReplaceInfile(const Filename: string;
//    const ReplaceWith: string = ''; const StartPos: integer = 1;
//    const ReplaceAll: boolean = TRUE; const RetainFileTime: boolean = FALSE): integer;
//  // direct write to memory mapped file, most effective for very large file,
//  //   particularly if SubStr to be searched for and Replacement are-
//  //   equal in length, (thus filesize would not be changed)
//  var
//    i, fSize, filehandle, maphandle: integer;
//    //fTime: Int64;
//    ViewBase, ViewCopy: pointer;
//    mapname: string;
//
//  const
//    OF_READWRITE = 2; //{$EXTERNALSYM OF_READWRITE}
//    OF_SHARE_DENY_NONE = $40; //{$EXTERNALSYM OF_SHARE_DENY_NONE}
//    PAGE_READWRITE = 4; //{$EXTERNALSYM PAGE_READWRITE}
//    SECTION_MAP_WRITE = 2; //{$EXTERNALSYM SECTION_MAP_WRITE}
//    SECTION_MAP_READ = 4; //{$EXTERNALSYM SECTION_MAP_READ}
//    //fmOpenReadWrite = OF_READWRITE;
//    //fmShareDenyNone = OF_SHARE_DENY_NONE;
//  const
//    BACKSLASH = '\';
//    DESIRED_ACCESS = SECTION_MAP_READ or SECTION_MAP_WRITE;
//    FILEOFFSET_HIGH = ZERO;
//    FILEOFFSET_LOW = ZERO;
//    NUMBEROFBYTES = ZERO;
//    INVALID_MAP = ZERO; // ***inavlid map file returns 0, not -1
//  begin
//    Result := INVALID;
//    fSize := cxfvmap.getFileSize(Filename);
//    if (fSize > 0) and (fSize >= fPatLen) and ((fPattern <> ReplaceWith) or
//      fIgnoreCase) then begin
//      // the same rules to catch  useless tries apply. this doublechecking might seem ovefluous,
//      // but better than clobbered initialization when it would be failed anyway at last
//      filehandle := fhandleOpen(Filename, fmOpenReadWrite or fmShareDenyNone);
//      //fTime := GetFileTime(filehandle);
//      if filehandle > 0 then begin
//        SetfPos(filehandle, 0, nil, 0);
//        i := _bcCharPos(BACKSLASH, FileName, length(FileName)); //may not works on mbcs
//        if i > 1 then
//          mapname := copy(Filename, i + 1, MaxInt)
//        else
//          mapname := FileName;
//        maphandle := CreateFileMapping(filehandle, nil,
//          PAGE_READWRITE, 0, 0, PChar(mapname));
//        if maphandle <> INVALID_MAP then begin
//          //ViewBase := MapViewOfFile(maphandle,
//          //  SECTION_MAP_READ or SECTION_MAP_WRITE, 0, 0, 0);
//          ViewBase := MapViewOfFile(maphandle, DESIRED_ACCESS,
//            FILEOFFSET_HIGH, FILEOFFSET_LOW, NUMBEROFBYTES);
//          if ViewBase <> nil then begin
//            ViewCopy := ViewBase;
//            Result := ffReplaced(ViewCopy, ReplaceWith,
//              StartPos, fSize, ReplaceAll);
//            if Result <> INVALID then begin
//              if ViewCopy <> ViewBase then begin
//                unmapViewOfFile(ViewBase);
//                fhandleClose(maphandle);
//                maphandle := CreateFileMapping(filehandle, nil,
//                  PAGE_READWRITE, 0, Result, PChar(mapname));
//                if maphandle <> INVALID_MAP then begin
//                  ViewBase := MapViewOfFile(maphandle, DESIRED_ACCESS,
//                    FILEOFFSET_HIGH, FILEOFFSET_LOW, NUMBEROFBYTES);
//                  if ViewBase <> nil then begin
//                    ChPos.xMove(ViewCopy^, ViewBase^, Result);
//                    SysFreeMem(ViewCopy);
//                  end;
//                end;
//              end;
//              FlushViewOfFile(ViewBase, 0);
//            end;
//            unmapViewOfFile(ViewBase);
//          end;
//          fhandleClose(maphandle);
//        end;
//        if (Result <> INVALID) and (fPatLen > length(ReplaceWith)) then begin
//          // must be done after map & View closed!
//          SetfPos(filehandle, Result, nil, 0);
//          SetEOF(filehandle);
//        end;
//        //if RetainFileTime then SetFileTime(filehandle, fTime);
//        fhandleClose(filehandle);
//      end;
//    end;
//  end;

function txSearch.InfileReplace(const Filename: string;
  const ReplaceWith: string = ''; const StartPos: integer = 1;
  const ReplaceAll: boolean = TRUE; const RetainFileTime: boolean = FALSE): integer;
// direct write to memory mapped file, most effective for very large file,
//   particularly if SubStr to be searched for and Replacement are-
//   equal in length, (thus filesize would not be changed)
var
  fSize, filehandle, maphandle: integer;
  ViewBase, ViewCopy: pointer;
begin
  Result := INVALID_RETURN_VALUE; // note that invalid result is -1, NOT 0
  fSize := cxfvmap.getFileSize(Filename);
  if (fSize > 0) and (fSize >= fPatLen) and ((fPattern <> ReplaceWith) or
    fIgnoreCase) then begin
    // the same rules to catch  useless tries apply. this doublechecking might seem ovefluous,
    // but better than clobbered initialization when it would be failed anyway at last
    ViewBase := cxfvmap.OpenView(Filename, filehandle, maphandle, cxmWrite);
    if ViewBase <> VOID then begin
      ViewCopy := ViewBase;
      Result := ffReplaced(ViewCopy, ReplaceWith, StartPos, fSize, ReplaceAll);
      cxfvmap.FlushView(filehandle, maphandle, ViewBase, ViewCopy, Result,
        fPatLen > length(ReplaceWith));
    end;
  end;
end;

function txSearch.PreInitFile(const FileName, SubStr, ReplaceWith: string;
  const IgnoreCase: boolean): boolean;
var
  fSize: integer;
begin
  Result := (SubStr <> '') and
    (not SameText(SubStr, ReplaceWith, FALSE) or IgnoreCase);
  if Result = TRUE then begin
    fSize := cxfvmap.GetFileSize(FileName);
    Result := (fSize > 0) and (fSize >= length(SubStr))
  end;
end;

function txSearch.InfileReplace(const Filename, SubStr, ReplaceWith: string;
  const StartPos: integer = 1; const IgnoreCase: boolean = FALSE;
  const ReplaceAll: boolean = TRUE; const RetainFileTime: boolean = FALSE): integer;
begin
  if not PreInitFile(Filename, SubStr, ReplaceWith, IgnoreCase) then
    Result := INVALID
  else begin
    if not SameInitState(SubStr, IgnoreCase) then
      Init(SubStr, IgnoreCase);
    Result := InfileReplace(Filename, ReplaceWith,
      StartPos, ReplaceAll, RetainFileTime);
  end
end;

function txSearch.SameInitState(const SubStr: string;
  const IgnoreCase: boolean): boolean;
begin
  Result := (fPattern <> '') and (SubStr <> '') and (IgnoreCase = fIgnoreCase);
  if Result = TRUE then
    Result := SameText(fPattern, SubStr, IgnoreCase)
end;

function txSearch.SameInitState(const FileName, SubStr: string;
  const IgnoreCase: boolean): boolean;
begin
  Result := (fViewBase <> nil) and SameText(FileName, fFileName);
  if Result = TRUE then
    Result := SameInitState(SubStr, IgnoreCase);
end;

{
 Implementation Of BoundCheck Algorithm

 Initialization of Index-Table

 In this implementation we use the index-Value also as the shift distance (the
 shift taken when non-matched ocurred). The Index-Values will be built in
 reversed order according to their ordinal position in the pattern (counted down
 from the last-character), so the specified HIGHEST actually is the last
 character in pattern, with Index-Value = 0, and the specified LOWEST (unknown
 at first, computed as we build the Index-Table), is the least (negative) Index-
 Value. We will further call the position of the LOWEST as the BoundCheck.

 Since the last character's Index-Value should always be 0, we will initialized
 it properly with Index-Value/shift distance by the OUTRANGE (length of pattern),
 only if it has no TWINS brother, otherwise their TWINS Index-Value will take
 precedence.

 Note that for counting the shift distance, we will get the absolute (positive)
 value of the Index-value, and for convenience, in fact we also store the Index-
 Value in the Index-Table with their absolute (positive) form.

 Example: SubStrings
  |---|---|---|---|---|---|---|---|---|---|------------
  |-9 |-8 |-7 |-6 |-5 |-4 |-3 |-2 |-1 | 0 |
  |---|---|---|---|---|---|---|---|---|---| Char-Case
  | S | u | b | S | t | r | i | n | g | s |
  |---|---|---|---|---|---|---|---|---|---|------------
  |-6 |-8 |-7 |-6 |-5 |-4 |-3 |-2 |-1 |-10| Sensitive
  |---|---|---|---|---|---|---|---|---|---|------------
  |-6 |-8 |-7 |-6 |-5 |-4 |-3 |-2 |-1 |-6 | Insensitive
  |---|---|---|---|---|---|---|---|---|---|------------
      LOWEST                         HIGHEST
       (B)

 Example: NumberOfEmployee
  |---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|------------
  |-15|-14|-13|-12|-11|-10|-9 |-8 |-7 |-6 |-5 |-4 |-3 |-2 |-1 | 0 |
  |---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---| Char-Case
  | N | u | m | b | e | r | O | f | E | m | p | l | o | y | e | e |
  |---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|------------
  |-15|-14|-6 |-12|-1 |-10|-9 |-8 |-7 |-6 |-5 |-4 |-3 |-2 |-1 |-1 | Sensitive
  |---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|------------
  |-15|-14|-6 |-12|-1 |-10|-3 |-8 |-1 |-6 |-5 |-4 |-3 |-2 |-1 |-1 | Insensitive
  |---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|------------
  LOWEST                                                     HIGHEST
   (B)

 B = BoundCheck position/value

 Right-to-Left Scanning

 In this implementation we do the Right-to-Left scanning, that is the scanning
 will be initialized from Last to First character of the chunk, this will bring
 some consideration of basic rules which will behave differently if we did it
 contrawise.
 
 As noted in the specification, we could reject the whole chunk when the mismatch
 found within then RANGE-BOUND, note that they work only if there are not any
 firstly characters had ever been appeared yet, --one special condition we have
 sure that met is when the BoundCheck is equal with the first ordinal position of
 the pattern, ie. the LOWEST is also the first char. Otherwise, When BoundCheck
 is not at the first ordinal position of the pattern, then the firstly characters
 to be considered with are any characters (thus also Index-Values) between the
 first ordinal position (included) and the BoundCheck position. We should then
 get the highest Index Value among them to be checked against fetched character
 to determine whether the whole chunk might be rejected (on comparison fail) or
 rather skipped by distance indicated by mismatched character.
}
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// lets the party begin...
// sorry for inconvenience in our asm style writing
// that because (of) we love pascal very much
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function txSearch.Init(const SubStr: string;
const IgnoreCase: boolean = FALSE): boolean; register assembler asm
  @@Start:
    mov Self.fBoundCheck, 0
    test SubStr, SubStr; jnz @_nextcheck
    @_zero: push 0; jmp @_chardone
    @_nextcheck:
    mov Self.fOneChars, 0
    mov Self.fIgnoreCase, IgnoreCase
    cmp dword ptr SubStr.szLen, 1; jg @@begin
    mov dl, byte ptr [SubStr]
    mov byte ptr Self.fOneChars, dl
    sete cl; and ecx, 1
    mov Self.fPatLen, ecx
    push ecx
    neg ecx; mov Self.fBoundCheck, ecx
    test Self.fIgnoreCase, cl; jz @_chardone
    and edx, MAXBYTE
    mov dl, byte ptr locasetable[edx]
    mov byte ptr Self.fOneChars, dl
    cmp dl, byte ptr UPCASETABLE[edx]; jne @_chardone
    mov Self.fIgnoreCase, FALSE
    @_chardone:
    lea eax, Self.fPattern
    call System.@LStrClr
    pop ecx; mov Self, ecx; jmp @@Stop

  @@begin:
    push esi; push edi; push ebx
    mov ebx, Self
    push edx
    lea eax, Self.fPattern
    call System.@LStrClr
    pop edx
    call System.@LStrLAsg
    call System.UniqueString
    mov esi, eax
    mov eax, eax.szLen
    mov ebx.fPatLen, eax
    lea edi, ebx.fIndex; mov ecx, PAGESIZE; rep stosd

    lea ecx, eax -1
    mov ebx.fPatLen_1, ecx
    //mov ebx.fnegPatLen_1, ecx
    //neg ebx.fnegPatLen_1
    //lea eax, esi + ecx
    //mov ebx.fpPattern, eax
    //allow single char init?
    //or ecx, ecx
    //jz @@initindex_done
    xor eax, eax; xor edx, edx

    test ebx.fIgnoreCase, -TRUE
    jnz @_IgnoreCaseCheck

  @@CaseSensitive:
    lea edi, ebx.fIndex
    @_LoopSense:
      mov al, esi + edx
      mov edi + eax*4, ecx
      inc edx
    dec ecx; jg @_LoopSense
    jmp @@initindex_done

    @_IgnoreCaseCheck:
    push ebx
    lea ebx, UPCASETABLE
    lea edi, locasetable

    @_Loopcasetest: //lodsb
      mov al, esi + ecx;
      mov al, edi + eax
      mov dl, ebx + eax
      cmp al, dl; je @_aftercase
      jmp @_BadMidJump
    @_aftercase:
    dec ecx; jge @_Loopcasetest

    pop ebx
    mov byte ptr ebx.fIgnoreCase, 0
    // as i always said: never use bad mid confusing jump!!!
    // AX,DX,CX WERE DESTROYED YOU FOOL!!!!!!!!!!!
    xor edx, edx           //!!!!!!!!!!!!!!!!!
    xor eax, eax           //!!!!!!!!!!!!!!!!!
    mov ecx, ebx.fPatLen_1 //!!!!!!!!!!!!!!!!!
    jmp @@CaseSensitive

    @_LoopLocased: //lodsb
      mov al, esi + ecx; mov al, edi + eax
    @_BadMidJump:
      mov esi + ecx , al
    dec ecx; jge @_LoopLocased

  @@IgnoreCase:
    mov ebx, [esp]
    mov ecx, ebx.fPatLen_1
    mov esi, ebx.fPattern
    lea edi, ebx.fIndex
    lea ebx, UPCASETABLE
    xor edx, edx
    @_LoopNonsense: // :)
      mov al, esi + edx
      mov edi + eax*4, ecx
      mov al, ebx + eax
      mov edi + eax*4, ecx
    inc edx; dec ecx; jg @_LoopNonSense
    pop ebx
    jmp @@initindex_done

  @@initindex_done:

  @@initOneChars:
    mov al, [esi]
    mov byte ptr ebx.fOneChars +1, al

    mov edx, edi + eax*4
    mov ebx.fFirstIndex, edx
    mov ebx.fBoundCheck, edx

    mov ecx, ebx.fPatLen_1
    mov al, esi + ecx
    mov byte ptr ebx.fOneChars, al
    mov edx, edi + eax*4
    mov ebx.fLastIndex, edx

  @@GetPerfectSequence:
  //  cmp edx, 1; ja @_skiprepeated
  //
  //  cmp edx, ebx.fBoundCheck
  //  sete byte ptr ebx.fSingular; jz @@done
  //
  //  @_skiprepeated:
  //  cmp ebx.fPatLen, edx
  //  sete ebx.fPerfectSeq; jne @@GetBoundCheck
  //
  //  @_PerfectCheck:
  //
  //  @_Loopperfect: lodsb
  //  cmp ecx, edi + eax*4; je @_keeptry
  //  mov ebx.fPerfectSeq, FALSE
  //  jmp @_perfectcheck_done
  //  @_keeptry: dec ecx; jg @_Loopperfect
  //  @_perfectcheck_done:

  mov esi, ebx.fPattern
  mov ecx, ebx.fPatLen_1 //already done
  //mov byte ptr ebx.fMidBound, FALSE

  @@GetBoundCheck:
    mov edx, 1
    lea esi, esi + ecx
    and ecx, MAXBYTE; jz @_getDone
    sub esi, ecx
    @_getLoop:
      lodsb
      mov edx, edi + eax*4
      cmp edx, ecx; je @_getDone
      dec ecx; jnz @_getLoop
    @_getDone:
    mov ebx.fBoundCheck, edx
  @@done:
    //cmp edx, fPatLen_1
    //setne byte ptr ebx.fMidBound
    neg ebx.fBoundCheck
    setl al
  @@end:
    pop ebx; pop edi; pop esi
  @@Stop:
end;

//

//function pRepPos(const Ch: Char; const P: PChar; const StartPos: dword = 1;
//  const PLength: dword = 0; const RepCount: integer = 1;
//  const IgnoreCase: boolean = FALSE): integer; register assembler overload forward
//
//function _RepPos(const Ch: Char; const S: string; const StartPos: integer;
//  const RepCount: integer; const IgnoreCase: boolean): integer;
//  register assembler overload forward
//  //

function txSearch.fpPos(const P: pointer {PChar}; const StartPos,
PLength: integer): integer; register assembler asm
  @@Start: push ebx; push esi
    test P, -TRUE; jz @@zero
    mov esi, PLength
    cmp StartPos, esi; ja @@zero
    //test StartPos, StartPos; js @@zero
    test StartPos, StartPos; jle @@zero
    test Self.fBoundCheck, -TRUE; jz @@zero
    cmp Self.fPatLen, 2; jle @@CCharPos
{.$IFNDEF BUG_INIT_SINGULAR} // fixed
    test Self.fSingular, -TRUE; jnz @@Singular //must be fixed beforewise on init above!
{.$ENDIF} // fixed
    jmp @@begin
  @@zero: xor eax, eax; jmp @@Stop
  @@Singular:
    push esi
    push Self.fPatLen
    xor ebx, ebx
    mov bl, Self.fIgnoreCase
    push ebx
    mov eax, Self.fOneChars
    call ChPos.pRepPos; jmp @@Stop
  @@CCharPos: push esi; jne @@SingleChar
    test Self.fIgnoreCase, -TRUE
    mov eax, Self.fOneChars; xchg al, ah; // must be switched
    jnz @_wcharnocase
    @_wcharcasens: call pcWCharPos; jmp @@Stop
    @_wcharnocase: call piWCharPos; jmp @@Stop
  @@SingleChar:
    test Self.fIgnoreCase, -TRUE
    mov eax, Self.fOneChars; jnz @_charnocase
    @_charcasens: call pcCharPos; jmp @@Stop
    @_charnocase: call piCharPos; jmp @@Stop

  @@begin: push edi
    lea edi, P + esi -1      // edi = pointer to last-char
    lea esi, P + StartPos -1 // esi = last-char of chunk
    mov ebx, Self
    push ebp; push P
    mov ebp, edi             // ebp = pointer to last-char
    //~~mov edi, ebx.fpPattern   // edi = pointer to pattern tail
    mov edi, ebx.fPattern
    mov ecx, ebx.fPatLen_1   // ecx = pattern length -1
    //~~add esi, ecx
    sub ebp, ecx             // dont ever think to use local var
    xor eax, eax
    {$IFDEF BOUNDCHECK}
    add ecx, ebx.fBoundCheck
    je @@qBoundSearch
    {$ENDIF}

  @@BoundSearch:
    test ebx.fIgnoreCase, -TRUE
    jnz @@CaseInsensitive

  @@CaseSensitive:
    @@BoundSeek:
      mov ecx, ebx.fPatLen_1;
      mov edx, ebx.fOneChars
    @@Rebound:
      cmp esi, ebp; ja @@NOTFOUND

    @@AdrianLoop:
      cmp dl, [esi+ecx]
      je @@IngeBound
      mov al, [esi+ecx]
      //and eax, $ff  // for Unicode only, ASCII char Index Value
                      // wil never exceed high byte
      add esi, dword ptr ebx.fINDEX[eax*4]
      //jmp @@Rebound
      cmp esi, ebp; jbe @@AdrianLoop; jmp @@NOTFOUND

    @@IngeBound:
      cmp dh, [esi]
      je @@NextChar
      //inc esi; jmp @@Rebound
      lea esi, esi +1
      cmp esi, ebp; jbe @@AdrianLoop; jmp @@NOTFOUND

    @@NextChar:
      //sub ecx, 1; jbe @@prepareFound // dont use dec to get CF
      //dec ecx; jg @@InBound // we are not expecting substr > 2GB anyway
      //mov edx, esi; jmp @@prepareFound
      dec ecx; jle @@Found1

    @@InBound:
      mov al, [esi+ecx]
      cmp al, [edi+ecx]
      je @@NextChar

      //add esi, dword ptr ebx.fINDEX[eax*4] // does NOT always work
      inc esi
      jmp @@BoundSeek

  @@CaseInsensitive:
    @@iBoundSeek:
      mov ecx, ebx.fPatLen_1;
      mov edx, ebx.fOneChars
    @@iRebound:
      cmp esi, ebp; ja @@NOTFOUND

    @@iAdrianLoop:
      mov al, [esi+ecx]
      cmp dl, byte ptr locasetable[eax]
      je @@iIngeBound
      add esi, dword ptr ebx.fINDEX[eax*4]
      //jmp @@iRebound
      cmp esi, ebp; jbe @@iAdrianLoop; jmp @@NOTFOUND

    @@iIngeBound:
      mov al, [esi]
      cmp dh, byte ptr locasetable[eax]
      je @@iNextChar
      //add esi, dword ptr ebx.fIndex[eax*4]
      //inc esi; jmp @@iRebound
      lea esi, esi +1
      cmp esi, ebp; jbe @@iAdrianLoop; jmp @@NOTFOUND

    @@iNextChar:
      //dec ecx; jg @@iInBound
      //mov edx, esi; jmp @@prepareFound
      dec ecx; jle @@Found1

    @@iInBound:
      mov al, [esi+ecx]
      mov al, byte ptr locasetable[eax]
      cmp al, [edi+ecx]
      je @@iNextChar

      //add esi, dword ptr ebx.fINDEX[eax*4] // does NOT always work
      inc esi
      jmp @@iBoundSeek

// Quick BoundCheck //

  @@qBoundSearch:
    test ebx.fIgnoreCase, -TRUE
    jnz @@CaseInsensitive

  @@qCaseSensitive:
    @@qBoundSeek:
      mov ecx, ebx.fPatLen_1;
      mov edx, ebx.fOneChars
    @@qRebound:
      cmp esi, ebp; ja @@NOTFOUND

    @@qAdrianLoop:
      cmp dl, [esi+ecx]
      je @@qIngeBound
      mov al, [esi+ecx]
      //and eax, $ff  // for Unicode only, ASCII char Index Value
                      // wil never exceed high byte
      add esi, dword ptr ebx.fINDEX[eax*4]
      //jmp @@qRebound
      cmp esi, ebp; jbe @@qAdrianLoop; jmp @@NOTFOUND

    @@qIngeBound:
      cmp dh, [esi]
      je @@qNextChar
      //inc esi; jmp @@qRebound
      lea esi, esi +1
      cmp esi, ebp; jbe @@qAdrianLoop; jmp @@NOTFOUND

    @@qNextChar:
      dec ecx; jle @@Found1

    @@qInBound:
      mov al, [esi+ecx]
      cmp al, [edi+ecx]
      je @@qNextChar
      //add esi, dword ptr ebx.fINDEX[eax*4]
      //jmp @@qBoundSeek

      mov edx, ebx.fPatLen_1
      mov eax, dword ptr ebx.fINDEX[eax*4]
      cmp eax, edx; ja @@DropChunk
      sub ecx, edx  // current pos, reversed, to be match with Index-Value
      cmp ecx, eax; jle @@Shift1
    @@DropChunk:
      add esi, ebx.fPatLen; xor eax, eax; jmp @@qBoundSeek
    @@Shift1:
      lea esi, esi+eax; xor eax, eax; jmp @@qBoundSeek

  @@qCaseInsensitive:
    @@qiBoundSeek:
      mov ecx, ebx.fPatLen_1;
      mov edx, ebx.fOneChars
    @@qiRebound:
      cmp esi, ebp; ja @@NOTFOUND

    @@qiAdrianLoop:
      mov al, [esi+ecx]
      cmp dl, byte ptr locasetable[eax]
      je @@qiIngeBound
      add esi, dword ptr ebx.fINDEX[eax*4]
      //jmp @@qiRebound
      cmp esi, ebp; jbe @@qiAdrianLoop; jmp @@NOTFOUND

    @@qiIngeBound:
      mov al, [esi]
      cmp dh, byte ptr locasetable[eax]
      je @@qiNextChar
      //add esi, dword ptr ebx.fIndex[eax*4]
      //inc esi; jmp @@qiRebound
      lea esi, esi +1
      cmp esi, ebp; jbe @@qiAdrianLoop; jmp @@NOTFOUND

    @@qiNextChar:
      dec ecx; jle @@Found1

    @@qiInBound:
      mov al, [esi+ecx]
      mov al, byte ptr locasetable[eax]
      cmp al, [edi+ecx]
      je @@qiNextChar
      //add esi, dword ptr ebx.fINDEX[eax*4]
      //jmp @@qiBoundSeek

      mov edx, ebx.fPatLen_1
      mov eax, dword ptr ebx.fINDEX[eax*4]
      cmp eax, edx; ja @@iDropChunk
      sub ecx, edx  // current pos, reversed, to be match with Index-Value
      cmp ecx, eax; jle @@Shift1
    @@iDropChunk:
      add esi, ebx.fPatLen; xor eax, eax; jmp @@qiBoundSeek
    @@iShift1:
      lea esi, esi+eax; xor eax, eax; jmp @@qiBoundSeek

  @@preparefound: mov esi, edx
  @@found1: inc esi; jmp @@FOUND
  @@NotFound: mov [esp], esi
  @@FOUND: mov eax, esi; pop edi; sub eax, edi
  @@end: pop ebp; pop edi
  @@Stop: pop esi; pop ebx
end;

{$IFDEF DEBUG2}

//~ function txSearch.fpPosPlain(const P: pointer {PChar}; const StartPos,
//~ PLength: integer): integer; register assembler asm
//~   @@Start: push ebx; push esi
//~     test P, -TRUE; jz @@zero
//~     mov esi, PLength
//~     cmp StartPos, esi; ja @@zero
//~     //test StartPos, StartPos; js @@zero
//~     test Self.fBoundCheck, -TRUE; jz @@zero
//~     cmp Self.fPatLen, 1; je @@SingleChar
//~ {.$IFNDEF BUG_INIT_SINGULAR} // fixed
//~     test Self.fSingular, -TRUE; jnz @@Singular //must be fixed beforewise on init above!
//~ {.$ENDIF} // fixed
//~     jmp @@begin
//~   @@zero: xor eax, eax; jmp @@Stop
//~   @@Singular:
//~     push esi
//~     push Self.fPatLen
//~     xor ebx, ebx
//~     mov bl, Self.fIgnoreCase
//~     push ebx
//~     mov eax, Self.fOneChars
//~     call ChPos.pRepPos; jmp @@Stop
//~   @@SingleChar:
//~     push esi; test Self.fIgnoreCase, -TRUE
//~     mov eax, Self.fOneChars; jnz @_charnocase
//~     @_charcasens: call pcCharPos; jmp @@Stop
//~     @_charnocase: call piCharPos; jmp @@Stop
//~
//~   @@begin: push edi
//~     lea edi, P + esi -1      // edi = pointer to last-char
//~     lea esi, P + StartPos -1 // esi = last-char of chunk
//~     mov ebx, Self
//~     push ebp; push P
//~     mov ebp, edi             // ebp = pointer to last-char
//~     //~~mov edi, ebx.fpPattern   // edi = pointer to pattern tail
//~     mov edi, ebx.fPattern
//~     mov ecx, ebx.fPatLen_1   // ecx = pattern length -1
//~     //~~add esi, ecx
//~     sub ebp, ecx             // we must not using local var
//~     xor eax, eax
//~
//~   @@BoundSearch:
//~     test ebx.fIgnoreCase, -TRUE
//~     jnz @@CaseInsensitive
//~
//~   @@CaseSensitive:
//~     @@BoundSeek:
//~       mov ecx, ebx.fPatLen_1;
//~       mov edx, ebx.fOneChars
//~     @@Rebound:
//~       cmp esi, ebp; ja @@NOTFOUND
//~
//~     @@AdrianLoop:
//~       cmp dl, [esi+ecx]
//~       je @@IngeBound
//~       mov al, [esi+ecx]
//~       //and eax, $ff  // for Unicode only, ASCII char Index Value
//~                       // wil never exceed high byte
//~       add esi, dword ptr ebx.fINDEX[eax*4]
//~       //jmp @@Rebound
//~       cmp esi, ebp; jbe @@AdrianLoop; jmp @@NOTFOUND
//~
//~     @@IngeBound:
//~       cmp dh, [esi]
//~       je @@NextChar
//~       //inc esi; jmp @@Rebound
//~       lea esi, esi +1
//~       cmp esi, ebp; jbe @@AdrianLoop; jmp @@NOTFOUND
//~
//~     @@NextChar:
//~       //sub ecx, 1; jbe @@prepareFound // dont use dec to get CF
//~       //dec ecx; jg @@InBound // we are not expecting substr > 2GB anyway
//~       //mov edx, esi; jmp @@prepareFound
//~       dec ecx; jle @@Found1
//~
//~     @@InBound:
//~       mov al, [esi+ecx]
//~       cmp al, [edi+ecx]
//~       je @@NextChar
//~
//~       add esi, dword ptr ebx.fINDEX[eax*4]
//~       jmp @@BoundSeek
//~
//~   @@CaseInsensitive:
//~     @@iBoundSeek:
//~       mov ecx, ebx.fPatLen_1;
//~       mov edx, ebx.fOneChars
//~     @@iRebound:
//~       cmp esi, ebp; ja @@NOTFOUND
//~
//~     @@iAdrianLoop:
//~       mov al, [esi+ecx]
//~       cmp dl, byte ptr locasetable[eax]
//~       je @@iIngeBound
//~       add esi, dword ptr ebx.fINDEX[eax*4]
//~       //jmp @@iRebound
//~       cmp esi, ebp; jbe @@iAdrianLoop; jmp @@NOTFOUND
//~
//~     @@iIngeBound:
//~       mov al, [esi]
//~       cmp dh, byte ptr locasetable[eax]
//~       je @@iNextChar
//~       //add esi, dword ptr ebx.fIndex[eax*4]
//~       //inc esi; jmp @@iRebound
//~       lea esi, esi +1
//~       cmp esi, ebp; jbe @@iAdrianLoop; jmp @@NOTFOUND
//~
//~     @@iNextChar:
//~       //dec ecx; jg @@iInBound
//~       //mov edx, esi; jmp @@prepareFound
//~       dec ecx; jle @@Found1
//~
//~     @@iInBound:
//~       mov al, [esi+ecx]
//~       mov al, byte ptr locasetable[eax]
//~       cmp al, [edi+ecx]
//~       je @@iNextChar
//~
//~       add esi, dword ptr ebx.fINDEX[eax*4]
//~       jmp @@iBoundSeek
//~
//~   @@preparefound: mov esi, edx
//~   @@found1: inc esi; jmp @@FOUND
//~   @@NotFound: mov [esp], esi
//~   @@FOUND: mov eax, esi; pop edi; sub eax, edi
//~   @@end: pop ebp; pop edi
//~   @@Stop: pop esi; pop ebx
//~ end;

{$ENDIF DEBUG2}

//~ function txSearch.fpPos_buggy1(const P: pointer {PChar}; const StartPos,
//~ PLength: integer): integer; register assembler asm
//~   @@Start: push ebx; push esi
//~     test P, -TRUE; jz @@zero
//~     mov esi, PLength
//~     cmp StartPos, esi; ja @@zero
//~     //test StartPos, StartPos; js @@zero
//~     test Self.fBoundCheck, -TRUE; jz @@zero
//~     cmp Self.fPatLen, 1; je @@SingleChar
//~ {$IFNDEF BUG_INIT_SINGULAR}
//~     //test Self.fSingular, -TRUE; jnz @@Singular //must be fixed beforewise on init above!
//~ {$ENDIF}
//~     jmp @@begin
//~   @@zero: xor eax, eax; jmp @@Stop
//~   @@Singular:
//~     push esi
//~     push Self.fPatLen
//~     xor ebx, ebx
//~     mov bl, Self.fIgnoreCase
//~     push ebx
//~     mov eax, Self.fOneChars
//~     call ChPos.pRepPos; jmp @@Stop
//~   @@SingleChar:
//~     push esi; test Self.fIgnoreCase, -TRUE
//~     mov eax, Self.fOneChars; jnz @_charnocase
//~     @_charcasens: call pcCharPos; jmp @@Stop
//~     @_charnocase: call piCharPos; jmp @@Stop
//~
//~   @@begin: push edi
//~     lea edi, P + esi -1
//~     lea esi, P + StartPos -1
//~     mov ebx, Self
//~     push ebp; push P
//~     mov ebp, edi
//~     mov edi, ebx.fpPattern
//~     mov ecx, ebx.fPatLen_1
//~     add esi, ecx
//~     xor eax, eax
//~
//~   @@BoundSearch:
//~     test ebx.fIgnoreCase, -TRUE
//~     jnz @@CaseInsensitive
//~
//~   @@CaseSensitive:
//~     @@BoundSeek:
//~       cmp esi, ebp; ja @@NOTFOUND
//~       mov ecx, ebx.fnegPatLen_1
//~       mov edx, ebx.fOneChars
//~
//~     @@AdrianLoop:
//~       mov al, [esi]  // get the last char (first-reversed) of chunk
//~       cmp al, dl; je @@IngeBound // compare with the last-char of pattern
//~       add esi, dword ptr ebx.fINDEX[eax*4]
//~       cmp esi, ebp; jbe @@AdrianLoop
//~       jmp @@NotFound
//~
//~     @@IngeBound:
//~       mov al, esi + ecx // get the first char (last-reversed) of chunk
//~       cmp al, dh; je @@NextChar // compare with the first-char of pattern
//~       // this may lead to false equality!
//~       //add esi, dword ptr ebx.fIndex[eax*4] // is it save???
//~       lea esi, esi +1
//~       cmp esi, ebp; jbe @@AdrianLoop
//~       jmp @@NotFound
//~
//~     @@NextChar:
//~       neg ecx   // reverse counter
//~       mov edx, ebx.fBoundCheck // get BoundCheck Value
//~
//~     @@InBound:
//~       // this will not work as expected!
//~       // comparisun must be RIGHT to LEFT (last to first), NOT contrawise!
//~       inc edx; jge @@OutBound
//~       mov al, esi + edx
//~       cmp al, edi + edx; je @@InBound
//~       mov eax, dword ptr ebx.fINDEX[eax*4]
//~       cmp ecx, eax; jb @@BoundSkip
//~       add eax, edx; jle @@BoundSkip
//~       lea esi, esi + eax
//~       xor eax, eax; jmp @@BoundSeek
//~       @@BoundSkip:
//~       lea esi, esi + ecx +1
//~       xor eax, eax; jmp @@BoundSeek
//~
//~     @@OutBound:
//~       mov edx, esi
//~       sub edx, ecx
//~       add ecx, ebx.fBoundCheck
//~       jz @@preparefound
//~       mov edi, ebx.fPattern
//~
//~     @@OutLoop:
//~       mov al, edx + ecx
//~       cmp al, edi + ecx
//~       jne @@SkipRest
//~       dec ecx; jg @@OutLoop
//~       jmp @@preparefound
//~
//~     @@SkipRest:
//~       mov al, [esi]
//~       mov edi, ebx.fpPattern
//~       mov ecx, ebx.fPatLen_1
//~       add esi, dword ptr ebx.fIndex[eax*4]
//~       jmp @@BoundSeek
//~
//~   @@CaseInsensitive:
//~     @@iBoundSeek:
//~       cmp esi, ebp; ja @@NOTFOUND
//~       mov ecx, ebx.fnegPatLen_1
//~       mov edx, ebx.fOneChars
//~
//~     @@iAdrianLoop:
//~       mov al, [esi]
//~       cmp dl, byte ptr locasetable[eax]
//~       je @@iIngeBound
//~       add esi, dword ptr ebx.fINDEX[eax*4]
//~       cmp esi, ebp; jbe @@iAdrianLoop
//~       jmp @@NotFound
//~
//~     @@iIngeBound:
//~       mov al, esi + ecx
//~       cmp dh, byte ptr locasetable[eax]
//~       je @@iNextChar
//~       //add esi, dword ptr ebx.fIndex[eax*4]
//~       lea esi, esi +1
//~       cmp esi, ebp; jbe @@iAdrianLoop
//~       jmp @@NotFound
//~
//~     @@iNextChar:
//~       neg ecx; mov edx, ebx.fBoundCheck
//~
//~     @@iInBound:
//~       inc edx
//~       jge @@iOutBound
//~       mov al, esi + edx
//~       mov al, byte ptr locasetable[eax]
//~       cmp al, edi + edx; je @@iInBound
//~       mov eax, dword ptr ebx.fINDEX[eax*4]
//~       cmp ecx, eax; jbe @@iBoundSkip
//~       add eax, edx; jle @@iBoundSkip
//~       lea esi, esi + eax
//~       xor eax, eax; jmp @@iBoundSeek
//~       @@iBoundSkip:
//~       lea esi, esi + ecx +1
//~       xor eax, eax; jmp @@iBoundSeek
//~
//~
//~     @@iOutBound:
//~       mov edx, esi; sub edx, ecx
//~       add ecx, ebx.fBoundCheck; jz @@preparefound
//~       mov edi, ebx.fPattern
//~
//~     @@iOutLoop:
//~       mov al, edx + ecx
//~       mov al, byte ptr locasetable[eax]
//~       cmp al, edi + ecx; jne @@iSkipRest
//~       dec ecx; jg @@iOutLoop
//~       jmp @@preparefound
//~
//~     @@iSkipRest:
//~       mov al, [esi]
//~       mov edi, ebx.fpPattern
//~       mov ecx, ebx.fPatLen_1
//~       add esi, dword ptr ebx.fIndex[eax*4]
//~       jmp @@iBoundSeek
//~
//~   @@preparefound: mov esi, edx
//~   @@found1: inc esi; jmp @@FOUND
//~   @@NotFound: mov [esp], esi
//~   @@FOUND: mov eax, esi; pop edi; sub eax, edi
//~   @@end: pop ebp; pop edi
//~   @@Stop: pop esi; pop ebx
//~ end;

function txSearch.fReplaced(const S: string; const ReplaceWith: string = '';
  const StartPos: integer = 1; const ReplaceAll: boolean = TRUE): string;
var
  i, j, k, RLen, SLen: integer;
  Chars: dword;
  // metrics:
  //   LODS, LODSB, LODSW, LODSD:  2-clocks x count
  //   STOS, STOSB, STOSW, STOSD:  3-clocks x count,
  //      add 9-clocks for REP (6-clocks only if ECX zero)
  //   MOVS, MOVSB, MOVSW, MOVSB:  4-clocks x count,
  //      add 13-clocks for REP (6-clocks only if ECX zero)
  //   note that the clocks are equals on ANY operand size
  //   (byte, word and dword are no different)
  //   all of the string instructions above are not paired

  //   MOV: 1-clock, but we have to manually inc ESI and EDI,
  //        READ:2 + WRITE:2, total 4-clocks
  //   if we use ECX as counter then we have AGI-stall problem
  //   (if ECX also used as the offset-address in the next-three
  //   instructions away), add 1-clock delay, no possible pairing

procedure StrMov(Count: integer); assembler asm
    // (Src = S[j], Dest: Result[k])
    // copying S[j] COUNT bytes to Result[k], afterwhile, j and k increased by COUNT
    // 0-based, do not forget it!
    // j = starting pointer to copy, k = starting pointer to write
    // if using String/pchar parameters, (as it do in xMove function),
    // the compiler keep calling unnecessary System.Uniquestring
    @@Start: push esi; push edi
      mov esi, S
      mov edi, Result; mov edi, [edi]
      add esi, j; add edi, k
      or Count, Count; jle @@movLoopDone
      add j, Count; add k, Count
      mov ecx, Count
      push ecx; shr ecx, 2; jz @@movRecall
    @@movLoopDW:
      mov eax, [esi]
      lea esi, esi +4
      mov [edi], eax
      lea edi, edi +4
      dec ecx; jg @@movLoopDW
   @@movRecall:
      pop ecx; and ecx, 03h; jz @@movLoopDone
    @@movLoopByte:
      mov al, [esi]; lea esi, esi +1
      mov [edi], al; lea edi, edi +1
      dec ecx; jg @@movLoopByte
    @@movLoopDone:
    @@Stop: pop edi; pop esi
  end;

procedure StrMovCat_Upto(JustBeforePos: integer); assembler asm // EXCLUDING EndPos itself
    // (Src = S[j], Dest: Result[k])
    // copying S[j] upto (and before) S[EndPos] to Result[k],
    // then also appends Replacement String to Result
    // afterwhile, j and k increased by COUNT of bytes moved
    // j & k is 0-based, EndPos is 1-based :)
    // j = starting pointer to copy, k = starting pointer to write
    // j increased by COUNT + length of SearchString (j := j + Count + SLen)
    // k increased by COUNT + length of ReplacementString (k := k + Count + RLen)
    @@Start:
      push esi; push edi
      mov edi, Result
      mov esi, S; mov edi, [edi]
      add esi, j; add edi, k
      lea ecx, JustBeforePos -1
      sub ecx, j; jle @@movLoopDone
      add j, ecx; add k, ecx
      push ecx
      shr ecx, 2; jz @@movRecall
    @@movLoopDW:
      //mov eax, [esi]; lea esi, esi +4
      //mov [edi], eax; lea edi, edi +4
      //dec ecx; jg @@movLoopDW
      mov eax, [esi]   // take advantages of 1-clock mov (for dword size),
      lea esi, esi +4  // instruction pairing (the one after read),
      mov [edi], eax   // and avoid AGI-stall, by composing the
      lea edi, edi +4  // instructions in such a way that modifying
      dec ecx          // base registers (esi, edi) is more than 3
      jg @@movLoopDW   // instructions away before actually using them
   @@movRecall:
      pop ecx
      and ecx, 03h; jz @@movLoopDone
    @@movLoopByte:
      mov al, [esi]; lea esi, esi +1
      mov [edi], al; lea edi, edi +1
      dec ecx; jg @@movLoopByte

    @@movLoopDone:
      mov ecx, RLen
      or ecx, ecx; jle @@CatLoopDone
      mov esi, ReplaceWith
      add k, ecx
      shr ecx, 2; jz @@catRecall
    @@catLoopDW:
      mov eax, [esi]; lea esi, esi +4
      mov [edi], eax; lea edi, edi +4
      dec ecx; jg @@catLoopDW
   @@catRecall:

      mov ecx, RLen
      and ecx, 03h; jz @@catLoopDone
    @@catLoopByte:
      mov al, [esi]; lea esi, esi +1
      mov [edi], al; lea edi, edi +1
      dec ecx; jg @@catLoopByte
    @@catLoopDone:
    @@end:
      mov esi, SLen; add j, esi
      pop edi; pop esi
    @@Stop:
  end;

procedure CopyBytes; assembler asm
    @@Start: push esi; push edi
    @@do: push ebx
      mov ebx, Self
      mov eax, i
      mov ecx, SLen
      mov esi, Result; mov esi, [esi]
      cmp ecx, 4; ja @LongString; je @L4
      cmp ecx, 2; je @L2; jb @L1; ja @@Weird

    @L1:
      lea edi, esi + eax -1
      lea ecx, eax +1
      mov eax, Chars; mov [edi], al
      //dec ReplaceCount; jz @@done
      mov edx, S; push dword ptr edx.szLen
      mov eax, ebx; call txSearch.fpPos
      or eax, eax; jnz @L1
      ; jmp @@done

    @L2:
      lea edi, esi + eax -1
      lea ecx, eax +2
      mov eax, Chars; mov [edi], ax
      //dec ReplaceCount; jz @@done
      mov edx, S; push dword ptr edx.szLen
      mov eax, ebx; call txSearch.fpPos
      or eax, eax; jnz @L2
      ; jmp @@done

    @@Double: cmp ecx, 4; jne @@Weird

    @L4:
      lea edi, esi + eax -1
      lea ecx, eax +4
      mov eax, Chars; mov [edi], eax
      //dec ReplaceCount; jz @@done
      mov edx, S; push dword ptr edx.szLen
      mov eax, ebx; call txSearch.fpPos
      or eax, eax; jnz @L4
      ; jmp @@done

    @@Weird:
    @L3:
      lea edi, esi + eax -1
      lea ecx, eax +3
      mov eax, Chars; mov [edi], ax
      mov al, byte ptr Chars[2]; mov edi[2], al
      //dec ReplaceCount; jz @@done
      mov edx, S; push dword ptr edx.szLen
      mov eax, ebx; call txSearch.fpPos
      or eax, eax; jnz @L3
      ; jmp @@done

    @LongString: push esi
    @LongLoop:
      mov edi, [esp]
      push eax
      lea edi, edi + eax -1
      mov esi, ReplaceWith
      mov ecx, esi.szLen

      push ecx; shr ecx, 2

    @dwordLoop:
      mov eax, [esi]
      lea esi, esi +4
      mov [edi], eax
      lea edi, edi +4
      dec ecx; jnz @dwordLoop
      pop ecx; and ecx, 3; jz @filldone

    @byteLoop:
      mov al, [esi]; inc esi
      mov [edi], al; inc edi
      dec ecx; jnz @byteLoop

    @filldone:
      pop ecx; add ecx, RLen
      //dec ReplaceCount; jz @@done
      mov edx, S; push dword ptr edx.szLen
      mov eax, ebx; call txSearch.fpPos
      or eax, eax; jnz @LongLoop

    @@LongStringDone: pop esi
    @@done: pop ebx
    @@Stop: pop edi; pop esi
  end;

var
  StringLength, ResultLen: integer;
const
  TWICE = 2;
  TEST: integer = 1;
begin
  i := Pos(S, StartPos);
  if i < 1 then
    Result := S
  else begin // i >= 1
    j := 0;
    StringLength := integer(pointer(integer(S) - 4)^);
    //SLen := integer(pointer(integer(SubStr) - 4)^);
    SLen := fPatLen;
    RLen := Length(ReplaceWith);
    if SLen = RLen then begin
      Chars := 0;
      Result := S; UniqueString(Result);
      if SLen <= sizeof(Chars) then
        Chars := integer(pointer(ReplaceWith)^);
      CopyBytes;
    end
    else begin // SLen <> RLen
      k := 0; Result := 'RLen <> SLen';
      if SLen > RLen then begin
        SetLength(Result, StringLength);
        while (i > 0) {and (ReplaceCount > 0)} do begin
          StrMovCat_Upto(i);
          i := Pos(S, j + 1);
          //dec(ReplaceCount);
        end;
      end
      else begin // SLen < RLen
        Result := 'RLen > SLen';
        ResultLen := (StringLength * TWICE) mod (MaxInt div 2);
        setlength(Result, ResultLen);
        while (i > 0) {and (ReplaceCount > 0)} do begin
          if (ResultLen < k + i - j - 1) then begin
            ResultLen := ResultLen + StringLength;
            setlength(Result, ResultLen);
          end;
          StrMovCat_Upto(i);
          i := Pos(S, j + 1);
          //dec(ReplaceCount);
        end;
        if (ResultLen < k + StringLength - j - 1) then
          setlength(Result, k + StringLength - j);
      end;
      StrMov(StringLength - j);
      SetLength(Result, k);
    end;
  end;
end;

function txSearch.ffReplaced(var P: pointer; const ReplaceWith: string;
  const StartPos, PLength: integer; const ReplaceAll: boolean): integer;
// beware, ffReplaced function returns INVALID_RETURN_VALUE on fails
// (not 0 as usual, since 0 is a valid return value here)
var
  i, j, k, RLen, SLen: integer;
  PSource, pResult: pointer;
  Chars: dword;
  StringLength: integer;

procedure StrMov(Count: integer); assembler asm
    @@Start: push esi; push edi
      mov esi, PSource
      mov edi, pResult; //mov edi, [edi]
      add esi, j; add edi, k
      or Count, Count; jle @@movLoopDone
      add j, Count; add k, Count
      mov ecx, Count
      push ecx; shr ecx, 2; jz @@movRecall
    @@movLoopDW:
      mov eax, [esi]
      lea esi, esi +4
      mov [edi], eax
      lea edi, edi +4
      dec ecx; jg @@movLoopDW
   @@movRecall:
      pop ecx; and ecx, 03h; jz @@movLoopDone
    @@movLoopByte:
      mov al, [esi]; lea esi, esi +1
      mov [edi], al; lea edi, edi +1
      dec ecx; jg @@movLoopByte
    @@movLoopDone:
    @@Stop: pop edi; pop esi
  end;

procedure StrMovCat_Upto(JustBeforePos: integer); assembler asm
    @@Start:
      push esi; push edi
      mov edi, pResult
      mov esi, PSource; //mov edi, [edi]
      add esi, j; add edi, k
      lea ecx, JustBeforePos -1
      sub ecx, j; jle @@movLoopDone
      add j, ecx; add k, ecx
      push ecx
      shr ecx, 2; jz @@movRecall
    @@movLoopDW:
      mov eax, [esi]; lea esi, esi +4
      mov [edi], eax; lea edi, edi +4
      dec ecx; jg @@movLoopDW
   @@movRecall:
      pop ecx
      and ecx, 03h; jz @@movLoopDone
    @@movLoopByte:
      mov al, [esi]; lea esi, esi +1
      mov [edi], al; lea edi, edi +1
      dec ecx; jg @@movLoopByte

    @@movLoopDone:
      mov ecx, RLen
      or ecx, ecx; jle @@CatLoopDone
      mov esi, ReplaceWith
      add k, ecx
      shr ecx, 2; jz @@catRecall
    @@catLoopDW:
      mov eax, [esi]; lea esi, esi +4
      mov [edi], eax; lea edi, edi +4
      dec ecx; jg @@catLoopDW
   @@catRecall:

      mov ecx, RLen
      and ecx, 03h; jz @@catLoopDone
    @@catLoopByte:
      mov al, [esi]; lea esi, esi +1
      mov [edi], al; lea edi, edi +1
      dec ecx; jg @@catLoopByte
    @@catLoopDone:
    @@end:
      mov esi, SLen; add j, esi
      pop edi; pop esi
    @@Stop:
  end;

procedure CopyBytes; assembler asm
    @@Start: push esi; push edi
    @@do: push ebx
      mov ebx, Self
      mov eax, i
      mov ecx, SLen
      mov esi, pResult; //mov esi, [esi]
      cmp ecx, 4; ja @LongString; je @L4
      cmp ecx, 2; je @L2; jb @L1; ja @@Weird

    @L1:
      lea edi, esi + eax -1
      lea ecx, eax +1
      mov eax, Chars; mov [edi], al
      //dec ReplaceCount; jz @@done
      mov edx, PSource; //push dword ptr edx.szLen
      //mov edx, [edx]
      push dword ptr StringLength
      mov eax, ebx; call txSearch.fpPos
      or eax, eax; jnz @L1
      ; jmp @@done

    @L2:
      lea edi, esi + eax -1
      lea ecx, eax +2
      mov eax, Chars; mov [edi], ax
      //dec ReplaceCount; jz @@done
      mov edx, PSource; //push dword ptr edx.szLen
      //mov edx, [edx]
      push dword ptr StringLength
      mov eax, ebx; call txSearch.fpPos
      or eax, eax; jnz @L2
      ; jmp @@done

    @@Double: cmp ecx, 4; jne @@Weird

    @L4:
      lea edi, esi + eax -1
      lea ecx, eax +4
      mov eax, Chars; mov [edi], eax
      //dec ReplaceCount; jz @@done
      mov edx, PSource; //push dword ptr edx.szLen
      //mov edx, [edx]
      push dword ptr StringLength
      mov eax, ebx; call txSearch.fpPos
      or eax, eax; jnz @L4
      ; jmp @@done

    @@Weird:
    @L3:
      lea edi, esi + eax -1
      lea ecx, eax +3
      mov eax, Chars; mov [edi], ax
      mov al, byte ptr Chars[2]; mov edi[2], al
      //dec ReplaceCount; jz @@done
      mov edx, PSource; //push dword ptr edx.szLen
      //mov edx, [edx]
      push dword ptr StringLength
      mov eax, ebx; call txSearch.fpPos
      or eax, eax; jnz @L3
      ; jmp @@done

    @LongString: push esi
    @LongLoop:
      mov edi, [esp]
      push eax
      lea edi, edi + eax -1
      mov esi, ReplaceWith
      mov ecx, esi.szLen

      push ecx; shr ecx, 2

    @dwordLoop:
      mov eax, [esi]
      lea esi, esi +4
      mov [edi], eax
      lea edi, edi +4
      dec ecx; jnz @dwordLoop
      pop ecx; and ecx, 3; jz @filldone

    @byteLoop:
      mov al, [esi]; inc esi
      mov [edi], al; inc edi
      dec ecx; jnz @byteLoop

    @filldone:
      pop ecx; add ecx, RLen
      //dec ReplaceCount; jz @@done
      mov edx, PSource; //push dword ptr edx.szLen
      //mov edx, [edx]
      push dword ptr StringLength
      mov eax, ebx; call txSearch.fpPos
      or eax, eax; jnz @LongLoop

    @@LongStringDone: pop esi
    @@done: pop ebx
    @@Stop: pop edi; pop esi
  end;

var
  ResultLen: integer;
const
  TWICE = 2;
  TEST: integer = 1;
begin
  //  if (P = nil) or (SubStr = '') or ((SubStr = ReplaceWith) and
  //    not
  //    IgnoreCase) then
  //    Result := INVALID //0 //integer(P)
  //  else begin
  //    Init(SubStr, IgnoreCase);
  i := Pos(P, PLength, StartPos);
  if i < 1 then
    Result := INVALID
  else begin // i >= 1
    j := 0;
    PSource := P;
    StringLength := PLength;
    //SLen := integer(pointer(integer(SubStr) - 4)^);
    SLen := fPatLen;
    RLen := Length(ReplaceWith);
    //if {inPlace and}(SLen >= RLen) then
    pResult := P;
    if not ReplaceAll then begin
      k := 0;
      if SLen >= RLen then begin
        if SLen > RLen then
          StrMovCat_Upto(i)
        else begin
          Chars := 0;
          if SLen <= sizeof(Chars) then
            Chars := integer(pointer(ReplaceWith)^);
          j := i - 1; k := j;
          inc(integer(PSource), j);
          inc(integer(pResult), k);
          xMove(PSource^, pResult^, SLen);
          j := StringLength; k := j;
        end;
      end
      else begin
        Result := StringLength + SLen - RLen;
        pResult := SysGetMem(Result);
        StrMovCat_Upto(i)
      end;
      StrMov(StringLength - j);
      Result := k;
    end
    else begin
      if SLen = RLen then begin
        Chars := 0;
        if SLen <= sizeof(Chars) then
          Chars := integer(pointer(ReplaceWith)^);
        CopyBytes;
        Result := StringLength;
      end
      else begin // SLen <> RLen
        k := 0; //Result := 'RLen <> SLen';
        if SLen > RLen then begin
          while (i > 0) {and (ReplaceCount > 0)} do begin
            StrMovCat_Upto(i);
            i := Pos(P, StringLength, j + 1);
            //dec(ReplaceCount);
          end;
        end
        else begin // SLen < RLen
          ResultLen := (StringLength * TWICE) mod (MaxInt shr 1);
          pResult := SysGetMem(ResultLen);
          while (i > 0) {and (ReplaceCount > 0)} do begin
            if (ResultLen < k + i - j - 1) then begin
              ResultLen := (ResultLen + StringLength) mod (MaxInt shr 1);
              pResult := SysReallocMem(pResult, ResultLen);
            end;
            StrMovCat_Upto(i);
            i := Pos(P, StringLength, j + 1);
            //dec(ReplaceCount);
          end;
          if (ResultLen < k + StringLength - j - 1) then
            //  setlength(Result, k + StringLength - j);
            pResult := SysReallocMem(pResult, ResultLen);
        end;
        StrMov(StringLength - j);
        Result := k;
      end;
    end;
  end;
  P := pResult;
  //  end;
end;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ MOVED to ChPos unit
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ //  expos ~ String version
//~ // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~
//~ function _cCharPos(const Ch: Char; const S: string;
//~   const StartPos: integer = 1): integer; assembler asm
//~   //~@@Start: push esi
//~   //~  test S, S; jz @@zero // check S length
//~   //~  mov esi, S.SzLen
//~   //~  cmp StartPos, esi; jle @@begin
//~   //~@@zero: xor eax, eax; jmp @@Stop
//~   //~@@begin: push S
//~   //~  sub StartPos, esi; add S, esi
//~   //~@_Loop:
//~   //~  cmp al, byte ptr S[StartPos-1]; je @@found
//~   //~  inc StartPos; jle @_Loop
//~   //~  xor eax,eax; jmp @@end
//~   //~@@found: sub S, [esp]; lea eax, S + StartPos
//~   //~@@end: pop S
//~   //~@@Stop: pop esi
//~
//~   // using simpler base-index should be faster
//~   // or at least pairing enabled
//~   @@Start:
//~     test S, S; jz @@zero // check S length
//~     or StartPos, StartPos; jg @@begin //still need to be checked
//~   @@zero: xor eax, eax; jmp @@Stop
//~   @@begin: push esi
//~     lea esi, S + StartPos -1
//~     sub StartPos, S.SzLen; jg @@notfound
//~   @_Loop:
//~     cmp al, [esi]; lea esi, esi +1; je @@found
//~     inc StartPos; jle @_Loop
//~   @@notfound: mov esi, S
//~   @@found: sub esi, S; mov eax, esi
//~   @@end: pop esi
//~   @@Stop:
//~ end;
//~
//~ function _iCharPos(const Ch: Char; const S: string;
//~   const StartPos: integer { = 1}): integer; assembler asm
//~   @@Start: push ebx
//~     test S, S; jz @@zero // check S length
//~     or StartPos, StartPos; jle @@zero //still need to be checked
//~     mov ebx, S.szLen
//~     cmp StartPos, ebx; jle @@Open
//~   @@zero: xor eax, eax; jmp @@Stop
//~   @@Open: //movzx eax, &Ch
//~     mov al, &Ch
//~     and eax, MAXBYTE
//~     push edi
//~     lea edi, locasetable
//~   @@begin: push esi; push S
//~     sub StartPos, ebx; add S, ebx
//~     lea esi, S + StartPos -1
//~     mov al, edi[eax]
//~     cmp al, byte ptr UPCASETABLE[eax]; je @_LoopNC
//~     mov bl, al
//~   @_Loop:
//~     //mov al, byte ptr S[StartPos-1];
//~     mov al, [esi]; lea esi, esi +1
//~     cmp bl, edi[eax]; je @@found
//~     inc StartPos; jle @_Loop
//~     jmp @@notfound
//~   @_LoopNC:
//~     //cmp al, byte ptr S[StartPos-1]; je @@found
//~     cmp al, [esi]; lea esi, esi +1; je @@found
//~     inc StartPos; jle @_LoopNC
//~   @@notfound: xor eax,eax; jmp @@end
//~   @@found: sub S, [esp]; lea eax, S + StartPos
//~   @@end: pop S; pop esi
//~   @@Close: pop edi
//~   @@Stop: pop ebx
//~ end;
//~
//~ function _bcCharPos(const Ch: Char; const S: string;
//~   const StartPos: integer = {0} 1): integer; assembler asm
//~   //~@@Start: push esi
//~   //~  test S, S; jz @@zero // check S length
//~   //~  mov esi, S.SzLen
//~   //~  cmp StartPos, esi; jle @@begin
//~   //~@@zero: xor eax, eax; jmp @@Stop
//~   //~@@begin: //push S
//~   //~  {sub StartPos, esi; add S, esi}
//~   //~@_Loop:
//~   //~  cmp al, byte ptr S[StartPos-1]; je @@found
//~   //~  dec StartPos; jnz @_Loop
//~   //~  xor eax,eax; jmp @@end
//~   //~@@found: mov eax, StartPos//sub S, [esp]; lea eax, S + StartPos
//~   //~@@end: //pop S
//~   //~@@Stop: pop esi
//~
//~   // using simpler base-index should be faster
//~   // or at least pairing enabled
//~   @@Start:
//~     test S, S; jz @@zero // check S length
//~     or StartPos, StartPos; jg @@begin //still need to be checked
//~   @@zero: xor eax, eax; jmp @@Stop
//~   @@begin: push esi
//~     lea esi, S + StartPos -1
//~     //sub StartPos, S.SzLen; jg @@notfound
//~     cmp StartPos, S.SzLen; jg @@notfound
//~   @_Loop:
//~     cmp al, [esi]; je @@found; lea esi, esi -1
//~     dec StartPos; jg @_Loop
//~   @@notfound: lea esi, S -1
//~   @@found: sub esi, S; lea eax, esi +1
//~   @@end: pop esi
//~   @@Stop:
//~ end;
//~
//~ function _biCharPos(const Ch: Char; const S: string;
//~   const StartPos: integer { = 1}): integer; assembler asm
//~   @@Start: push ebx
//~     test S, S; jz @@zero // check S length
//~     or StartPos, StartPos; jle @@zero //still need to be checked
//~     mov ebx, S.szLen
//~     cmp StartPos, ebx; jle @@Open
//~   @@zero: xor eax, eax; jmp @@Stop
//~   @@Open: //movzx eax, &Ch
//~     mov al, &Ch
//~     and eax, MAXBYTE
//~     push edi
//~     lea edi, locasetable
//~   @@begin: push esi//push S
//~     {sub StartPos, ebx; add S, ebx}
//~     lea esi, S + StartPos -1
//~     mov al, edi[eax]
//~     cmp al, byte ptr UPCASETABLE[eax]; je @_LoopNC
//~     mov bl, al
//~   @_Loop:
//~     //mov al, byte ptr S[StartPos-1];
//~     mov al, [esi]; lea esi, esi -1
//~     cmp bl, edi[eax]; je @@found
//~     dec StartPos; jnz @_Loop
//~     jmp @@notfound
//~   @_LoopNC:
//~     //cmp al, byte ptr S[StartPos-1]; je @@found
//~     cmp al, [esi]; lea esi, esi -1; je @@found
//~     dec StartPos; jnz @_LoopNC
//~   @@notfound: xor eax,eax; jmp @@end
//~   @@found: mov eax, StartPos//sub S, [esp]; lea eax, S + StartPos
//~   @@end: //pop S
//~   @@Close: pop edi
//~   @@Stop: pop ebx
//~ end;
//~
//~ function _cCharCount(const Ch: Char; const S: string;
//~   const StartPos: integer { = 1}): integer; assembler asm
//~     test S, S; jz @@zero // check S length
//~     or StartPos, StartPos; jg @@begin //still must be checked
//~   @@zero:
//~     xor eax, eax; jmp @@EXIT
//~   @@begin: push esi
//~     lea esi, S + StartPos -1
//~     sub StartPos, S.SzLen; mov S, 0; jg @@found
//~     @_Loop:
//~       cmp al, [esi]; lea esi, esi +1; jne @_
//~       ; inc S
//~     @_: inc StartPos; jle @_Loop
//~   @@found: mov eax, S
//~   @@end: pop esi
//~   @@EXIT:
//~ end;
//~
//~ function _iCharCount(const Ch: Char; const S: string;
//~   const StartPos: integer { = 1}): integer; assembler asm
//~     test S, S; jz @@zero // check S length
//~     or StartPos, StartPos; jg @@begin //still must be checked
//~   @@zero:
//~     xor eax, eax; jmp @@EXIT
//~   @@begin: push esi; push edi; push ebx
//~     and eax, MAXBYTE
//~     lea edi, locasetable
//~     lea esi, S + StartPos -1
//~     sub StartPos, S.SzLen; mov S, 0; jg @_found
//~     mov bl, edi + eax
//~     cmp bl, byte ptr UPCASETABLE[eax]; je @_LoopNC
//~     @_Loop:
//~       mov al, [esi]; lea esi, esi +1
//~       cmp bl, edi + eax; jne @_
//~       ; inc S
//~     @_:inc StartPos; jle @_Loop; jmp @_found
//~     @_LoopNC:
//~       cmp al, [esi]; lea esi, esi +1; jne @e
//~       ; inc S
//~     @e: inc StartPos; jle @_LoopNC
//~     @_found: mov eax, S
//~   @@end: pop ebx; pop edi; pop esi
//~   @@EXIT:
//~ end;
//~
//~ function _RepPos(const Ch: Char; const S: string; const StartPos: integer;
//~   const RepCount: integer; const IgnoreCase: boolean): integer; assembler asm
//~   @@Start: push esi
//~     or S, S; je @@zero
//~     test StartPos, StartPos; jle @@zero
//~     cmp StartPos, S.szLen; jle @begin
//~   @@zero: xor eax, eax; jmp @@Stop
//~   @begin: push esi; push edi; push ebx
//~     mov esi, S
//~     push esi            // save original address
//~     mov al, &Ch
//~     and eax, MAXBYTE
//~     mov edi, esi
//~     lea esi, esi + StartPos -1
//~     add edi, edi.szLen
//~     mov ecx, RepCount
//~     dec ecx
//~     mov edx, ecx; sub edi, ecx
//~     test IgnoreCase, 1; jnz @@CaseInsensitive
//~
//~     @@CaseSensitive:
//~     @_Repeat:
//~       cmp esi, edi; jg @@notfound  // note!
//~       cmp al, esi[edx]; jne @_skip
//~     @_Loop:
//~       dec ecx; jl @@found
//~       cmp al, esi[ecx]; je @_Loop
//~     @_forward:
//~       lea esi, esi + ecx +1; mov ecx, edx
//~       jmp @_Repeat
//~     @_skip:
//~       lea esi, esi + edx +1; jmp @_Repeat
//~
//~     @@CaseInsensitive:
//~       xor ebx, ebx
//~       mov bl, byte ptr locasetable[eax]
//~       cmp bl, byte ptr UPCASETABLE[eax]
//~       je @@CaseSensitive
//~
//~     @_iRepeat:
//~       cmp esi, edi; jg @@notfound
//~       mov al, esi[edx]
//~       cmp bl, byte ptr locasetable[eax]; jne @_iSkip
//~     @_iLoop:
//~       dec ecx; jl @@found
//~       mov al, esi[ecx]
//~       cmp bl, byte ptr locasetable[eax]; je @_iLoop
//~     @_iForward:
//~       lea esi, esi + ecx +1; mov ecx, edx
//~       jmp @_iRepeat
//~     @_iSkip:
//~       lea esi, esi + edx +1; jmp @_iRepeat
//~
//~   @@notfound: lea eax, esi +1; mov [esp], eax
//~   @@found: pop edi; sub esi, edi; lea eax, esi +1
//~   @@end: pop ebx; pop edi; pop esi
//~   @@Stop: pop esi
//~ end;
//~
//~ // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ //  expos ~ PChar version
//~ // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~
//~ function pcCharPos(const Ch: Char; const P: PChar;
//~   const StartPos, PLength: dword): integer; assembler asm
//~   @@begin: push esi
//~     and eax, MAXBYTE
//~     lea esi, P + StartPos -1
//~     sub StartPos, PLength; ja @_notfound
//~     @_Loop:
//~       cmp al, [esi]; lea esi, esi +1; je @@found
//~       inc StartPos; jle @_Loop
//~     @_notfound: xor eax, eax; jmp @@end
//~   @@found: mov eax, esi; sub eax, P
//~   @@end: pop esi
//~ end;
//~
//~ function piCharPos(const Ch: Char; const P: PChar;
//~   const StartPos, PLength: dword): integer; assembler asm
//~   @@begin: push esi; push edi; push ebx
//~     and eax, MAXBYTE
//~     lea edi, locasetable
//~     lea esi, P + StartPos -1
//~     sub StartPos, PLength; ja @_notfound
//~     mov bl, edi + eax
//~     cmp bl, byte ptr UPCASETABLE[eax]; je @_LoopNC
//~     @_Loop:
//~       mov al, [esi]; lea esi, esi +1
//~       cmp bl, edi + eax; je @@found
//~       inc StartPos; jle @_Loop
//~       jmp @_notfound
//~     @_LoopNC:
//~       cmp al, [esi]; lea esi, esi +1; je @@found
//~       inc StartPos; jle @_LoopNC
//~     @_notfound: xor eax, eax; jmp @@end
//~   @@found: mov eax, esi; sub eax, P
//~   @@end: pop ebx; pop edi; pop esi
//~ end;
//~
//~ function pbcCharPos(const Ch: Char; const P: PChar;
//~   const StartPos, PLength: dword): integer; assembler asm
//~   @@begin: push esi
//~     and eax, MAXBYTE
//~     lea esi, P + StartPos -1
//~     cmp StartPos, PLength; ja @_notfound
//~     @_Loop:
//~       cmp al, [esi]; lea esi, esi -1; je @@found
//~       sub StartPos, 1; jnb @_Loop
//~     @_notfound: xor eax, eax; jmp @@end
//~   @@found: lea eax, StartPos +1//mov eax, esi; sub eax, P
//~   @@end: pop esi
//~ end;
//~
//~ function pbiCharPos(const Ch: Char; const P: PChar;
//~   const StartPos, PLength: dword): integer; assembler asm
//~   @@begin: push esi; push edi; push ebx
//~     and eax, MAXBYTE
//~     lea edi, locasetable
//~     lea esi, P + StartPos -1
//~     cmp StartPos, PLength; ja @_notfound
//~     mov bl, edi + eax
//~     cmp bl, byte ptr UPCASETABLE[eax]; je @_LoopNC
//~     @_Loop:
//~       mov al, [esi]; lea esi, esi +1
//~       cmp bl, edi + eax; je @@found
//~       sub StartPos, 1; jnb @_Loop
//~       jmp @_notfound
//~     @_LoopNC:
//~       cmp al, [esi]; lea esi, esi -1; je @@found
//~       sub StartPos, 1; jnb @_LoopNC
//~     @_notfound: xor eax, eax; jmp @@end
//~   @@found: lea eax, StartPos +1//mov eax, esi; sub eax, P
//~   @@end: pop ebx; pop edi; pop esi
//~ end;
//~
//~ function pcCharCount(const Ch: Char; const P: PChar;
//~   const StartPos, PLength: dword): integer; assembler asm
//~   @@begin: push esi
//~     lea esi, P + StartPos -1
//~     xor P, P
//~     sub StartPos, PLength; jg @@found
//~     @_Loop:
//~       cmp al, [esi]; lea esi, esi +1; jne @_
//~       ; lea P, P+1
//~     @_: inc StartPos; jle @_Loop
//~   @@found: mov eax, P
//~   @@end: pop esi
//~ end;
//~
//~ function piCharCount(const Ch: Char; const P: PChar;
//~   const StartPos, PLength: dword): integer; assembler asm
//~   @@begin: push esi; push edi; push ebx
//~     and eax, MAXBYTE
//~     lea edi, locasetable
//~     lea esi, P + StartPos -1
//~     xor P, P
//~     sub StartPos, PLength; jg @_found
//~     mov bl, edi + eax
//~     cmp bl, byte ptr UPCASETABLE[eax]; je @_LoopNC
//~     @_Loop:
//~       mov al, [esi]; lea esi, esi +1
//~       cmp bl, edi + eax; jne @_
//~       ; lea P, P +1
//~       @_:inc StartPos; jle @_Loop; jmp @_found
//~     @_LoopNC:
//~       cmp al, [esi]; lea esi, esi +1
//~       jne @e; lea P, P+1
//~       @e: inc StartPos; jle @_LoopNC
//~     @_found: mov eax, P
//~   @@end: pop ebx; pop edi; pop esi
//~ end;
//~
//~ function pRepPos(const Ch: Char; const P: PChar; const StartPos: dword;
//~   const PLength: dword; const RepCount: integer;
//~   const IgnoreCase: boolean): integer; register overload assembler asm
//~   @@Start:
//~     or P, P; je @@zero
//~     test StartPos, StartPos; jle @@zero  // StartPos = 0?
//~     cmp StartPos, PLength; jle @begin    // StartPos >= Length(S) ?
//~
//~   @@zero: xor eax, eax; jmp @@Stop
//~   @begin: push esi; push edi; push ebx
//~     mov esi, P
//~     push esi            // save original address
//~     mov al, &Ch
//~     and eax, MAXBYTE
//~     mov edi, esi
//~     lea esi, esi + StartPos -1
//~     add edi, PLength
//~     mov ecx, RepCount
//~     dec ecx
//~     mov edx, ecx; sub edi, ecx
//~     test IgnoreCase, 1; jnz @@CaseInsensitive
//~
//~     @@CaseSensitive:
//~     @_Repeat:
//~       cmp esi, edi; jg @@notfound  // note!
//~       cmp al, esi[edx]; jne @_skip
//~     @_Loop:
//~       dec ecx; jl @@found
//~       cmp al, esi[ecx]; je @_Loop
//~     @_forward:
//~       lea esi, esi + ecx +1; mov ecx, edx
//~       jmp @_Repeat
//~     @_skip:
//~       lea esi, esi + edx +1; jmp @_Repeat
//~
//~     @@CaseInsensitive:
//~       xor ebx, ebx
//~       mov bl, byte ptr locasetable[eax]
//~       cmp bl, byte ptr UPCASETABLE[eax]
//~       je @@CaseSensitive
//~
//~     @_iRepeat:
//~       cmp esi, edi; jg @@notfound
//~       mov al, esi[edx]
//~       cmp bl, byte ptr locasetable[eax]; jne @_iSkip
//~     @_iLoop:
//~       dec ecx; jl @@found
//~       mov al, esi[ecx]
//~       cmp bl, byte ptr locasetable[eax]; je @_iLoop
//~     @_iForward:
//~       lea esi, esi + ecx +1; mov ecx, edx
//~       jmp @_iRepeat
//~     @_iSkip:
//~       lea esi, esi + edx +1; jmp @_iRepeat
//~
//~   @@notfound: lea eax, esi +1; mov [esp], eax
//~   @@found: pop edi; sub esi, edi; lea eax, esi +1
//~   @@end: pop ebx; pop edi; pop esi
//~   @@Stop:
//~   end;
//~
//~ // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ //  move, compare & conversion routines
//~ // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~
//~ function cCompare(const S1, S2: string): integer; forward;
//~ function iCompare(const S1, S2: string): integer; forward;
//~ function pcCompare(const P1, P2; const L1, L2: integer): integer; forward;
//~ function piCompare(const P1, P2; const L1, L2: integer): integer; forward;
//~
//~ function SameText(const S1, S2: string; const IgnoreCase: boolean = TRUE): boolean;
//~ begin
//~   if IgnoreCase then
//~     Result := iCompare(S1, S2) = 0
//~   else
//~     Result := cCompare(S1, S2) = 0
//~ end;
//~
//~ function SameBuffer(const P1, P2; const L1, L2: integer;
//~   const IgnoreCase: boolean = TRUE): boolean;
//~ begin
//~   if IgnoreCase then
//~     Result := piCompare(P1, P2, L1, L2) = 0
//~   else
//~     Result := pcCompare(P1, P2, L1, L2) = 0
//~ end;
//~
//~ procedure xMove(const Src; var Dest; Count: integer); assembler asm
//~ // effective only for bulk transfer
//~     push esi; push edi
//~     mov esi, Src; mov edi, Dest
//~     mov ecx, Count; mov eax, ecx
//~     sar ecx, 2; js @@end
//~     push eax; jz @@recall
//~   @@LoopDWord:
//~     mov eax, [esi]; lea esi, esi +4
//~     mov [edi], eax; lea edi, edi +4
//~     dec ecx; jg @@LoopDWord
//~   @@recall: pop ecx
//~     and ecx, 03h; jz @@LoopDone
//~   @@LoopByte:
//~     mov al, [esi]; lea esi, esi +1
//~     mov [edi], al; lea edi, edi +1
//~     dec ecx; jg @@LoopByte
//~   @@LoopDone:
//~   @@end:
//~     pop edi; pop esi
//~ end;
//~
//~ function iCompare_old(const S1, S2: string): integer; assembler asm
//~   @@Start:
//~     push esi; push edi; push ebx
//~     mov esi, eax; mov edi, edx
//~     xor ebx, ebx
//~     or eax, eax; je @@zeroS1
//~     mov eax, eax.SzLen
//~   @@zeroS1:
//~     or edx, edx; je @@zeroS2
//~     mov edx, edx.SzLen
//~   @@zeroS2:
//~     mov ecx, eax
//~     cmp ecx, edx; jbe @@2
//~     mov ecx, edx
//~   @@2: dec ecx; jl @@done
//~   @@3:
//~     mov bl, [esi]; lea esi, esi +1
//~     cmp bl, [edi]; lea edi, edi +1
//~     je @@2
//~     mov bl, byte ptr LOCASETABLE[ebx]
//~     cmp bl, [edi -1]; je @@3
//~     xor eax, eax; mov al, [esi-1]
//~     xor edx, edx; mov dl, [edi-1]
//~   @@done:
//~     sub eax, edx
//~     pop ebx; pop edi; pop esi
//~   @@Stop:
//~ end;
//~
//~ function cCompare(const S1, S2: string): integer; assembler asm
//~ // efficient for long string
//~   @@Start:
//~     push esi; push edi; push ebx
//~     mov esi, S1; mov edi, S2
//~     or S1, S1; je @_Zero1
//~
//~     mov eax, S1.SzLen
//~   @_Zero1: or S2, S2; je @_Zero2
//~     mov edx, S2.SzLen
//~   @_Zero2: mov ecx, eax; cmp ecx, edx; jbe @_prep
//~
//~     mov ecx, edx
//~   @_prep: push ecx; shr ecx, 2; jz @_single
//~
//~   @_Loop4: dec ecx; jl @_single
//~     mov ebx, [edi]; lea edi, edi +4
//~     cmp ebx, [esi]; lea esi, esi +4
//~     je @_Loop4
//~
//~     mov eax, [esi]; mov edx, ebx; jmp @_atremain
//~
//~   @_Loopremain: ror eax, 8; ror edx, 8
//~   @_atremain: cmp al, dl; je @_Loopremain
//~
//~     and eax, $ff; and edx, $ff
//~     pop ecx; jmp @@done
//~
//~   @_single: pop ecx; and ecx, 3; jz @@done
//~
//~   @_Loop1: dec ecx; jl @@done
//~     mov bl, [esi]; lea esi, esi +1
//~     cmp bl, [edi]; lea edi, edi +1
//~     je @_Loop1
//~
//~     xor eax, eax; mov al, bl
//~     xor edx, edx; mov dl, [edi]
//~
//~   @@done:
//~     sub eax, edx
//~     pop ebx; pop edi; pop esi
//~   @@Stop:
//~ end;
//~
//~ function iCompare(const S1, S2: string): integer; assembler asm
//~   @@Start:
//~     push esi; push edi; push ebx
//~     mov esi, S1; mov edi, S2
//~     xor ebx, ebx; or S1, S1; je @_Zero1
//~
//~     mov eax, S1.SzLen
//~   @_Zero1: or edx, edx; je @_Zero2
//~     mov edx, S2.SzLen
//~   @_Zero2: mov ecx, eax; cmp ecx, edx; jbe @@2
//~
//~     mov ecx, edx
//~   @@2: dec ecx; jl @@done
//~   @Loop3:
//~     mov bl, [esi]; lea esi, esi +1
//~     mov bl, byte ptr locasetable[ebx]
//~     cmp bl, [edi]; lea edi, edi +1
//~     je @Loop3
//~     xor eax, eax; mov al, bl
//~     xor edx, edx; mov dl, [edi]
//~   @@done:
//~     sub eax, edx
//~     pop ebx; pop edi; pop esi
//~   @@Stop:
//~ end;
//~
//~ function pcCompare(const P1, P2; const L1, L2: integer): integer; assembler asm
//~ // efficient for large buffer
//~   @@Start:
//~     push esi; push edi; push ebx
//~     mov esi, P1; mov edi, P2
//~     or P1, P1; je @_Zero1
//~
//~     mov eax, L1//eax.SzLen
//~   @_Zero1: or P2, P2; je @_Zero2
//~     mov edx, L2//edx.SzLen
//~   @_Zero2: mov ecx, eax; cmp ecx, edx; jbe @_prep
//~
//~     mov ecx, edx
//~   @_prep: push ecx; shr ecx, 2; jz @_single
//~
//~   @_Loop4: dec ecx; jl @_single
//~     mov ebx, [edi]; lea edi, edi +4
//~     cmp ebx, [esi]; lea esi, esi +4
//~     je @_Loop4
//~
//~     mov eax, [esi]; mov edx, ebx; jmp @_atremain
//~
//~   @_Loopremain: ror eax, 8; ror edx, 8
//~   @_atremain: cmp al, dl; je @_Loopremain
//~
//~     and eax, $ff; and edx, $ff
//~     pop ecx; jmp @@done
//~
//~   @_single: pop ecx; and ecx, 3; jz @@done
//~
//~   @_Loop1: dec ecx; jl @@done
//~     mov bl, [esi]; lea esi, esi +1
//~     cmp bl, [edi]; lea edi, edi +1
//~     je @_Loop1
//~
//~     xor eax, eax; mov al, bl
//~     xor edx, edx; mov dl, [edi]
//~
//~   @@done:
//~     sub eax, edx
//~     pop ebx; pop edi; pop esi
//~   @@Stop:
//~ end;
//~
//~ function piCompare(const P1, P2; const L1, L2: integer): integer; assembler asm
//~   @@Start:
//~     push esi; push edi; push ebx
//~     mov esi, P1; mov edi, P2
//~     xor ebx, ebx; or eax, eax; je @_Zero1
//~
//~     mov eax, L1//eax.SzLen
//~   @_Zero1: or P2, P2; je @_Zero2
//~     mov edx, L2//edx.SzLen
//~   @_Zero2: mov ecx, eax; cmp ecx, edx; jbe @@2
//~
//~     mov ecx, edx
//~   @@2: dec ecx; jl @@done
//~   @Loop3:
//~     mov bl, [esi]; lea esi, esi +1
//~     mov bl, byte ptr locasetable[ebx]
//~     cmp bl, [edi]; lea edi, edi +1
//~     je @Loop3
//~     xor eax, eax; mov al, bl
//~     xor edx, edx; mov dl, [edi]
//~   @@done:
//~     sub eax, edx
//~     pop ebx; pop edi; pop esi
//~   @@Stop:
//~ end;
//~
//~ procedure CaseStr(var S: string; const CharsTable); assembler asm
//~   @@Start:
//~     mov S, [S] // S is a VAR! normalize.
//~     or S, S; jz @@Stop
//~     push esi; push edi
//~     push ecx
//~     mov esi, S
//~     mov edi, CharsTable
//~     mov ecx, esi.SzLen
//~     xor eax, eax
//~   @@Loop:
//~     dec ecx; jl @@end
//~     mov al, esi[ecx]
//~     cmp al, edi[eax]
//~     je @@Loop
//~     mov al, edi[eax]
//~     mov esi[ecx], al
//~     jmp @@Loop
//~   @@end:
//~     pop ecx
//~     pop edi; pop esi
//~   @@Stop:
//~ end;
//~
//~ function UPPERSTR(const S: string): string;
//~ begin
//~   Result := S;
//~   //SetLength(Result, length(S));
//~   UniqueString(Result);
//~   CaseStr(Result, UPCASETABLE);
//~ end;
//~
//~ function lowerstr(const S: string): string;
//~ begin
//~   Result := S;
//~   //SetLength(Result, length(S));
//~   UniqueString(Result);
//~   CaseStr(Result, locasetable);
//~ end;
//~
//~ procedure TransBuffer(var Buffer; const Length: integer; const CharsTable); assembler asm
//~   @@Start:
//~     mov Buffer, [Buffer] // Buffer is a VAR! normalize.
//~     or Buffer, Buffer; jz @@Stop
//~     push esi; push edi
//~     push ecx
//~     mov esi, Buffer
//~     mov edi, CharsTable
//~     mov ecx, Length//esi.SzLen
//~     xor eax, eax
//~   @@Loop:
//~     dec ecx; jl @@end
//~     mov al, esi[ecx]
//~     cmp al, edi[eax]
//~     je @@Loop
//~     mov al, edi[eax]
//~     mov esi[ecx], al
//~     jmp @@Loop
//~   @@end:
//~     pop ecx
//~     pop edi; pop esi
//~   @@Stop:
//~ end;
//~
//~ procedure UPPERBUFF(var Buffer; const Length: integer);
//~ begin
//~   //Result := S;
//~   //SetLength(Result, length(S));
//~   //UniqueString(Result);
//~   TransBuffer(Buffer, Length, UPCASETABLE);
//~ end;
//~
//~ procedure lowerbuff(var Buffer; const Length: integer);
//~ begin
//~   //Result := S;
//~   //SetLength(Result, length(S));
//~   //UniqueString(Result);
//~   TransBuffer(Buffer, Length, locasetable);
//~ end;
//~

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ MOVED to cxGlobal unit
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ procedure makemeUpNDown;
//~ // manual maps (overwritten)
//~ // UP  ~ LO  diff/offset
//~ // ----------------------
//~ // D7h ~ D7h ~> 0
//~ // DFh ~ DFh ~> 0
//~ // F7h ~ F7h ~> 0
//~ // 8Ah ~ 9Ah ~> 10h (16)
//~ // 8Ch ~ 9Ch ~> 10h (16)
//~ // 8Eh ~ 9Eh ~> 10h (16)
//~ // 9Fh ~ FFh ~> 60H (96)
//~ //   overwritten: DFh in upcase table
//~ const
//~   HICASEBIT = 5; HICASEOFFSET = 1 shl HICASEBIT;
//~   MIDOFFSET = $10; LASTOFFSET = $60;
//~
//~   procedure makelo(const CharsTable); assembler asm
//~   // ugly but much faster
//~     @@Start:
//~       push eax; push ecx; push edx
//~       //lea EDX, locasetable
//~       mov edx, CharsTable
//~       xor eax, eax; mov ecx, eax
//~
//~       mov cl, 'Z' - 'A'
//~     @LoopA:
//~       lea eax, ecx + 'A' + HICASEOFFSET
//~       mov EDX[eax], al
//~       mov EDX[eax -HICASEOFFSET], al
//~       dec cl; jge @LoopA
//~
//~       mov cl, 0E0H
//~     @LoopGreek:
//~       mov eax, ecx; mov EDX[eax], al
//~       mov EDX[eax -HICASEOFFSET], al
//~       inc cl; ja @LoopGreek
//~
//~     @fillblank: mov cl, 'A'
//~     @Loop1: dec cx; mov EDX[ecx], cl; jg @Loop1
//~
//~       mov cl, 'a' - 'Z' -1
//~      @Loop2:
//~       lea eax, ecx + 'Z'; mov EDX[eax], al
//~       dec cl; jg @Loop2
//~
//~       mov cl, 0C0H - 'z' -1
//~      @Loop3:
//~       lea eax, ecx + 'z'; mov EDX[eax], al
//~       dec ecx; jg @Loop3
//~
//~     @@manual_maps:
//~       @_nolocase:
//~         mov al, $D7; mov EDX[eax], al
//~         mov al, $F7; mov EDX[eax], al
//~         mov al, $DF; mov EDX[eax], al
//~       @_midlo:
//~         mov al, $9A; mov EDX[eax-MIDOFFSET], al
//~         mov al, $9C; mov EDX[eax-MIDOFFSET], al
//~         mov al, $9E; mov EDX[eax-MIDOFFSET], al
//~       @_lastlo:
//~         mov al, $FF; mov EDX[eax-LASTOFFSET], al
//~
//~       pop edx; pop ecx; pop eax
//~     @@Stop:
//~   end;
//~
//~   procedure makeup(const CharsTable); assembler asm
//~     @@Start:
//~       push eax; push ecx; push edx
//~       //lea EDX, UPCASETABLE
//~       mov edx, CharsTable
//~       xor eax, eax; mov ecx, eax
//~
//~      mov cl, 'Z' - 'A'
//~     @LoopA:
//~       lea eax, ecx + 'A'
//~       mov EDX[eax], al
//~       mov EDX[eax +HICASEOFFSET], al
//~       dec cl; jge @LoopA
//~
//~       mov cl, 0E0H
//~     @LoopGreek:
//~       lea eax, ecx -HICASEOFFSET
//~       mov EDX[eax], al
//~       mov EDX[eax +HICASEOFFSET], al
//~       inc cl; ja @LoopGreek
//~
//~     @fillblank: mov cl, 'A'
//~     @Loop1: dec cx; mov EDX[ecx], cl; jg @Loop1
//~
//~       mov cl, 'a' - 'Z' -1
//~      @Loop2:
//~       lea eax, ecx + 'Z'; mov EDX[eax], al
//~       dec cl; jg @Loop2
//~
//~       mov cl, 0C0H - 'z' -1
//~      @Loop3:
//~       lea eax, ecx + 'z'; mov EDX[eax], al
//~       dec ecx; jg @Loop3
//~
//~     @@manual_maps:
//~       @_noupcase:
//~         mov al, $D7; mov EDX[eax], al
//~         mov al, $F7; mov EDX[eax], al
//~         mov al, $DF; mov EDX[eax], al
//~       @_midup:
//~         mov al, $8A; mov EDX[eax+MIDOFFSET], al
//~         mov al, $8C; mov EDX[eax+MIDOFFSET], al
//~         mov al, $8E; mov EDX[eax+MIDOFFSET], al
//~       @_lastup:
//~         mov al, $9F; mov EDX[eax+LASTOFFSET], al
//~
//~       pop edx; pop ecx; pop eax
//~     @@Stop:
//~   end;
//~
//~ begin
//~   makeup(UPCASETABLE);
//~   makelo(locasetable); // :)
//~ end;
//~

{$IFDEF DEBUG}
{$I CXDEBUG.INC}

function txSearch.PatternIndexValues(const HexStyle: boolean = TRUE): string;
const
  BLANK = ''; SPACE = ' '; UNDERBAR = '_';
var
  i: integer;
  Indexes: WideString;
  longStr: boolean;
begin
  if fPatLen = 1 then
    Result := intostr(fPatLen)
  else begin
    Result := ''; Indexes := '';
    for i := 1 to fPatLen do
      Indexes := Indexes + widechar(fIndex[fPattern[i]]);
    if Indexes <> '' then begin
      longStr := fPatLen > ord(high(char));
      if LongStr then
        Result := OrdWideString(Indexes, HexStyle, SPACE, BLANK)
      else
        Result := OrdString(Indexes, HexStyle, SPACE, BLANK);
      Result := Copy(Result, 2, MaxInt);
    end;
  end;
end;
{$ENDIF DEBUG}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ MOVED to cxDebug.inc
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~
//~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~  Helper routines (used for querying Index Values)
//~  excerpted from aCommon unit by the same authors
//~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ function IntoStr(const I: integer): string; forward;
//~ function IntoHex(const I: Int64; const Digits: byte = sizeof(byte)): string;
//~   register; assembler; forward;
//~ function OrdString(const S: string; const HexStyle: boolean = TRUE;
//~   const HexSymbolPrefix: string = '$'; const CharSymbolPrefix: string = '#'): string; forward;
//~ function OrdWideString(const W: widestring; const HexStyle: boolean = TRUE;
//~   const HexSymbolPrefix: string = '$'; const CharSymbolPrefix: string = '#'): string; forward;
//~
//~ function txSearch.PatternIndexValues(const HexStyle: boolean = TRUE): string;
//~ const
//~   BLANK = ''; SPACE = ' ';
//~ var
//~   i: integer;
//~   Indexes: WideString;
//~ begin
//~   if fPatLen = 1 then
//~     Result := intostr(fPatLen)
//~   else begin
//~     Result := ''; Indexes := '';
//~     for i := 1 to fPatLen do
//~       Indexes := Indexes + widechar(fIndex[fPattern[i]]);
//~     if Indexes <> '' then begin
//~       if fPatLen > ord(high(char)) then
//~         Result := OrdWideString(Indexes, HexStyle, SPACE, BLANK)
//~       else
//~         Result := OrdString(Indexes, HexStyle, SPACE, BLANK);
//~       Result := Copy(Result, 2, MaxInt);
//~     end;
//~   end;
//~ end;
//~
//~ function IntoStr(const I: integer): string;
//~ begin
//~   Str(I, Result);
//~ end;
//~
//~ function IntoHex(const I: Int64; const Digits: byte = sizeof(byte)): string; register;
//~ // This helper function excerpted from aCommon unit
//~ // Copyright (c) 2004, D.Sofyan & Adrian Hafizh
//~ // please get the latest version
//~ // this one actually is obsoleted, never used
//~ const
//~   DIGITSQUAD = sizeof(Int64);
//~ var
//~   S: ShortString;
//~ asm
//~   @@Start:
//~     push esi; push edi
//~     push Result
//~     lea esi, I
//~     inc Digits; shr Digits, 1
//~
//~     mov al, Digits
//~     and eax, 0ffh
//~     mov edi, DIGITSQUAD
//~     cmp eax, edi; ja @_checkdone
//~
//~     @_checkdigit:
//~     mov ecx, 4; mov edx, [esi+4]
//~
//~     @_Loop1: rol edx, 8
//~     or dl, dl; jnz @_checkdone
//~     dec edi; cmp edi, eax; jb @_recall
//~     dec ecx; jnz @_Loop1
//~
//~     mov edx, [esi]
//~     @_Loop2: rol edx, 8
//~     or dl, dl; jnz @_checkdone
//~     dec edi; jz @_recall
//~     cmp edi, eax; jge @_Loop2
//~
//~     @_recall: inc edi
//~     @_checkdone: mov eax, edi; lea edi, S
//~
//~     mov ecx, eax; add esi, eax
//~     dec esi; shl eax, 1
//~     cld; stosb
//~
//~   @@Loop:
//~     std; lodsb
//~     mov ah, al; shr al, 04h
//~     add al, 90h; daa
//~     adc al, 40h; daa
//~     cld; stosb
//~     mov al, ah; and al, 0Fh
//~     add al, 90h; daa
//~     adc al, 40h; daa
//~     stosb
//~     dec ecx; jnz @@Loop
//~
//~     lea edx, S; pop eax
//~     call System.@LStrFromString
//~     pop edi; pop esi
//~   @@Stop:
//~ end;
//~
//~ function OrdString(const S: string; const HexStyle: boolean = TRUE;
//~   const HexSymbolPrefix: string = '$'; const CharSymbolPrefix: string = '#'): string;
//~ // This helper function excerpted from aCommon unit
//~ // Copyright (c) 2004, D.Sofyan & Adrian Hafizh
//~ // please get the latest version
//~ var
//~   i: integer;
//~ begin
//~   Result := '';
//~   if HexStyle then
//~     for i := 1 to Length(S) do
//~       Result := Result + CharSymbolPrefix + HexSymbolPrefix + IntoHex(ord(S[i]), 2)
//~   else
//~     for i := 1 to Length(S) do
//~       Result := Result + CharSymbolPrefix + IntoStr(ord(S[i]))
//~
//~ end;
//~
//~ function OrdWideString(const W: widestring; const HexStyle: boolean = TRUE;
//~   const HexSymbolPrefix: string = '$'; const CharSymbolPrefix: string = '#'): string;
//~ var
//~   i: integer;
//~ begin
//~   Result := '';
//~   if HexStyle then
//~     for i := 1 to Length(W) do
//~       Result := Result + CharSymbolPrefix + HexSymbolPrefix + IntoHex(ord(W[i]), 4)
//~   else
//~     for i := 1 to Length(W) do
//~       Result := Result + CharSymbolPrefix + IntoStr(ord(W[i]))
//~
//~ end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  CPU Identification
//  excerpted from aCPUID component, by the same authors
//  unless PentiumTick, none have been implemented yet
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function _getCPUClass: integer; // part of of them belongs to Intel
const
  AC_Mask = $40000; // bit-18
  PSN_Mask = $200000; // bit-21
  cpu_ERR = 0; // Reserved
  cpu_386 = 3; // Old CPU
  cpu_486 = 4; // 486 without Processor Serial Number Support
  cpu_586 = 5; // 486+ with PSN Support Disabled
  cpu_PSN = 6; // 486+ with PSN Support Enabled
asm
  @@check_80386:
    pushfd                // push original EFLAGS
    pop eax               // get original EFLAGS
    mov ecx, eax          // save original EFLAGS
    xor eax, AC_mask      // flip AC bit in EFLAGS
    push eax              // save new EFLAGS value on stack
    popfd                 // replace current EFLAGS value
    pushfd                // get new EFLAGS
    pop eax               // store new EFLAGS in EAX
    xor eax, ecx          // can’t toggle AC bit, processor=80386
    mov eax, cpu_386      // turn on 80386 processor flag
    jz @@end              // jump if 80386 processor
    push ecx
    popfd                 // restore AC bit in EFLAGS first
  @@check_80486:
                          // Checks ability to set/clear ID flag (Bit 21) in EFLAGS
                          // (indicating the presence of cpuID instruction)
    mov eax, ecx          // get original EFLAGS
    xor eax, PSN_mask     // flip bit-21 (ID) in EFLAGS
    push eax              // save new EFLAGS value
    popfd                 // replace current EFLAGS value
    pushfd                // get new EFLAGS
    pop eax               // store new EFLAGS in EAX
    push ecx              // restore back
    popfd                 // original flags - intel's slipped here ;-(
    xor eax, ecx          // compare ID bit,
    mov eax, cpu_486      // 486 without PSN support
    je @@end              // cannot toggle ID bit
    mov eax, cpu_586      // Processor Serial Number Supported
    and ecx, PSN_Mask     // PSN Enabled?
    jz @@end
    mov eax, cpu_PSN      // Yes, PSN Enabled
  @@end:                  // done.
end;
{.$STACKFRAMES ON}
const
  _cpuType: byte = 0;
type
  CPURegisters = packed record
    EAX, EBX, ECX, EDX: dword
  end;

function _execCPUID(const nLevel: integer; var Registers): integer;
const
  _cpuTypeBit = 12;
  _PSNBitMask = $200000;
asm
  @@Begin:
//    cmp nLevel, 3            // Cyrix workaround:
//    jnz @@CyrixPass          // PSN-bit mus be enabled
//    pushfd                   // no way to turn it back (off) ;)
//    pop EAX                  // if you want to do so
//    or EAX, _PSNBitMask      // pushfd at begin and popfd at end
//    push EAX                 // beware of lost of flow-control
//    popfd
//  @@CyrixPass:
//    cmp nLevel, 2
//    jnz @@Synchronized
//  @@MPCheck:                 // Multi Processor Check Synchronicity
//                             // Differentiate only primary & non-primary
//    mov eax, 1
//    dw CPUID                 // execute service 1 call
//    shr eax, _cpuTypeBit     // extract cpuType
//    and al, 3                // validate bit-0 and bit-1
//    cmp al, _cpuType         // compare wih previous result
//    mov _cpuType, al         // save current value
//    loopnz @@MPCheck
//  @@Synchronized:
//    mov eax, nLevel
//    dw cpuID
//    //push eax
//    //mov eax, [&EAX]; pop dword ptr [eax]
//    //mov eax, [&EBX]; mov [eax], ebx
//    //mov eax, [&EDX]; mov [eax], edx
//    //mov eax, [&ECX]; mov [eax], ecx
//    //mov eax, [&EAX]; mov eax, [eax]
//    push eax
//    mov eax, Registers
//    mov eax.CPURegisters.&EBX, ebx
//    mov eax.CPURegisters.&ECX, ecx
//    mov eax.CPURegisters.&EDX, edx
//    pop dword ptr [eax]
//    mov eax, [eax]
//    cmp nLevel, 0            // is it a level 0 Query?
//    ja @@End
//    push eax                 // save eax result
//    shr eax, _cpuTypeBit     // extract cpuType
//    and al, 3                // validate bit-0 and bit-1
//    mov _cpuType, al
//    pop eax
  @@End:
end;
{.$STACKFRAMES OFF}

function txsearch.PentiumTick: Int64; assembler;
const
  CPUID = $A20F;
  RDTSC = $310F;
asm
@@Start:
 {$IFDEF DELPHI_6_UP}
 rdtsc
 {$ELSE}
 dw rdtsc
 {$ENDIF}
end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  Windows Routines 1 ~ Windows SysChar & Exception
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//const
//  kernel32 = 'kernel32.dll';
//  user32 = 'user32.dll';
//
// //
// function CharUpperBuff(var Buffer; Length: integer): integer; stdcall;
//   external user32 name 'CharUpperBuffA'; {$EXTERNALSYM CharUpperBuff}
// function CharLowerBuff(var Buffer; Length: integer): integer; stdcall;
//   external user32 name 'CharLowerBuffA'; {$EXTERNALSYM CharLowerBuff}
// procedure RaiseException(Code: dword = $DEADF00; Flags: dword = 1;
//   ArgCount: dword = 0; Arguments: pointer = nil); stdcall;
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

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ MOVED to separate unit: cxfvmap
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ //  Windows Routines 2 ~ File-handling routines
//~ //  All of these busy stuffs below are necessary only for file-based
//~ //  sample implementation. you might get rid all of them instead!
//~ // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ type
//~   thandle = integer;
//~
//~ const
//~   MAX_PATH = 260; {$EXTERNALSYM MAX_PATH}
//~   INVALID_HANDLE_VALUE = -1; {$EXTERNALSYM INVALID_HANDLE_VALUE}
//~   FA_DIRECTORY = $10;
//~ type
//~   //PFileTime = ^TFileTime;
//~   //TFileTime = packed record
//~   //  LowDateTime, HighDateTime: dword;
//~   //end;
//~   TFileTime = Int64;
//~
//~   PFindData = ^TFindData;
//~   TFindData = packed record
//~     FileAttributes: dword;
//~     CreationTime: TFileTime;
//~     LastAccessTime: TFileTime;
//~     LastWriteTime: TFileTime;
//~     FileSizeHigh, FileSizeLow: dword;
//~     Reserved0, Reserved1: dword;
//~     FileName: array[0..MAX_PATH - 1] of AnsiChar;
//~     AlternateFileName: array[0..13] of AnsiChar;
//~   end;
//~
//~ type
//~   TFileName = string;
//~   TSearchRec = packed record
//~     Time, Size, Attr: integer;
//~     Name: TFileName;
//~     ExcludeAttr: integer;
//~     FindHandle: THandle;
//~     FindData: TFindData;
//~   end;
//~
//~ type
//~   LongRec = packed record
//~     Lo, Hi: Word;
//~   end;
//~   Int64Rec = packed record
//~     Lo, Hi: dword;
//~   end;
//~
//~   PSystemTime = ^TSystemTime;
//~   TSystemTime = packed record
//~     year, month, DOW: word;
//~     day, hour, min, sec, ms: Word;
//~   end;
//~
//~ ///
//~ function FindFirst(FileName: PChar; var Data: TFindData): THandle; stdcall;
//~   external kernel32 name 'FindFirstFileA'; {$EXTERNALSYM FindFirst}
//~ function FindNext(FindFile: THandle; var Data: TFindData): longbool; stdcall;
//~   external kernel32 name 'FindNextFileA'; {$EXTERNALSYM FindNext}
//~ function FindClose(FindFile: THandle): longbool; stdcall;
//~   external kernel32 name 'FindClose'; {$EXTERNALSYM FindClose}
//~ function GetFileTime(handle: THandle;  Create, Access, Write: TFileTime): longbool;
//~   stdcall; overload; external kernel32 name 'GetFileTime'; {$EXTERNALSYM GetFileTime}
//~ function SetFileTime(handle: THandle; Create, Access, Write: TFileTime): longbool;
//~   stdcall; overload; external kernel32 name 'SetFileTime'; {$EXTERNALSYM SetFileTime}
//~ function fTime2Local(const FileTime: TFileTime;
//~   var LocalTime: TFileTime): longbool; stdcall;
//~   external kernel32 name 'FileTimeToLocalFileTime'; {$EXTERNALSYM fTime2Local}
//~ function fTime2DOS(const FileTime: TFileTime;
//~   var FATDate, FATTime: Word): longbool; stdcall;
//~   external kernel32 name 'FileTimeToDosDateTime'; {$EXTERNALSYM fTime2DOS}
//~ function Local2fTime(const LocalTime: TFileTime;
//~   var FileTime: TFileTime): longbool; stdcall;
//~   external kernel32 name 'LocalFileTimeToFileTime'; {$EXTERNALSYM Local2fTime}
//~ function DOS2fTime(FATDate, FATTime: Word;
//~   var FileTime: TFileTime): longbool; stdcall;
//~   external kernel32 name 'DosDateTimeToFileTime'; {$EXTERNALSYM DOS2fTime}
//~ function ftimeSystem(const FileTime: TFileTime;
//~   var SystemTime: TSystemTime): longbool; stdcall;
//~   external kernel32 name 'FileTimeToSystemTime'{$EXTERNALSYM ftimeSystem}
//~ ///
//~
//~ function GetFileSize(const FileName: string): integer {Int64};
//~ var
//~   Data: TFindData;
//~ begin
//~   Result := FindFirst(PChar(FileName), Data);
//~   if Result <> INVALID_HANDLE_VALUE then begin
//~     FindClose(Result);
//~     if not ((Data.FileAttributes and FA_DIRECTORY) = 0) then
//~       Result := -1
//~     else begin
//~       //int64Rec(Result).Hi := Data.FileSizeHigh;
//~       //int64Rec(Result).Lo := Data.FileSizeLow;
//~       Result := Data.FileSizeLow;
//~     end;
//~   end;
//~ end;
//~
//~ function GetFileTime(const handle: THandle): Int64; overload
//~ begin
//~   Result := INVALID;
//~   if not GetFileTime(handle, 0, 0, Result) then
//~     Result := INVALID;
//~ end;
//~
//~ procedure SetFileTime(const handle: THandle; const FileTime: Int64); overload
//~ begin
//~   SetFileTime(handle, 0, 0, FileTime);
//~ end;
//~
//~ function GetFileTime(const FileName: string): integer; overload;
//~ var
//~   Data: TFindData;
//~   Local: TFileTime;
//~ begin
//~   Result := FindFirst(PChar(FileName), Data);
//~   if Result <> INVALID_HANDLE_VALUE then begin
//~     FindClose(Result);
//~     if (Data.FileAttributes and FA_DIRECTORY) = 0 then begin
//~       ftime2Local(Data.LastWriteTime, Local);
//~       if not ftime2DOS(Local, LongRec(Result).Hi, LongRec(Result).Lo) then
//~         Result := INVALID_HANDLE_VALUE;
//~     end;
//~   end;
//~ end;
//~
//~ function SetFileTime(const FileName: string; const FileTime: integer): integer; overload;
//~ var
//~   Local, fTime: TFileTime;
//~   handle: integer;
//~ begin
//~   handle := fhandleOpen(FileName, 0);
//~   if (handle <> INVALID_HANDLE_VALUE) and
//~     DOS2fTime(longrec(FileTime).Hi, longrec(FileTime).Lo, Local) and
//~     Local2fTime(Local, fTime) then begin
//~     SetFileTime(handle, 0, 0, fTime);
//~     fhandleClose(handle);
//~     Result := 0;
//~   end
//~   else
//~     Result := INVALID_HANDLE_VALUE
//~ end;
//~
//~ ///
//~ function CreateFile(FileName: PChar; Access, Share: dword; Security: pointer;
//~   Disposition, Flags: dword; Template: THandle): THandle; stdcall;
//~   external kernel32 name 'CreateFileA'; {$EXTERNALSYM CreateFile}
//~ function fhandleClose(handle: THandle): longbool; stdcall;
//~   external kernel32 name 'CloseHandle'; {$EXTERNALSYM fhandleClose}
//~ function SetfPos(handle: THandle; OffsetLow: LongInt; OffSetHigh: pointer;
//~   Movement: dword): dword; stdcall;
//~   external kernel32 name 'SetFilePointer'; {$EXTERNALSYM SetfPos}
//~ function SetEOF(handle: THandle): longbool; stdcall;
//~   external kernel32 name 'SetEndOfFile'; {$EXTERNALSYM SetEOF}
//~ function CreateFileMapping(handle: THandle; SecAttributes: pointer;
//~   MapMode, MaxSizeHigh, MaxSizeLow: dword; FileName: PChar): THandle; stdcall;
//~   external kernel32 name 'CreateFileMappingA'; {$EXTERNALSYM CreateFileMapping}
//~ function MapViewOfFile(handle: THandle; Access: dword;
//~   OffHigh, OffLow, Length: dword): PChar; stdcall;
//~   external kernel32 name 'MapViewOfFile'; {$EXTERNALSYM MapViewOfFile}
//~ function FlushViewOfFile(const Base: Pointer; Length: dword): longbool; stdcall;
//~   external kernel32 name 'FlushViewOfFile'; {$EXTERNALSYM FlushViewOfFile}
//~ function UnmapViewOfFile(Base: Pointer): longbool; stdcall;
//~   external kernel32 name 'UnmapViewOfFile'; {$EXTERNALSYM UnmapViewOfFile}
//~ ///
//~
//~
//~ function fhandleOpen(const FileName: string; Mode: LongWord): integer;
//~ const
//~   GENERIC_READ = dword($80000000); //{$EXTERNALSYM GENERIC_READ}
//~   GENERIC_WRITE = $40000000; //{$EXTERNALSYM GENERIC_WRITE}
//~   FILE_SHARE_READ = $00000001; //{$EXTERNALSYM FILE_SHARE_READ}
//~   FILE_SHARE_WRITE = $00000002; //{$EXTERNALSYM FILE_SHARE_WRITE}
//~   FILE_ATTRIBUTE_NORMAL = $00000080; //{$EXTERNALSYM FILE_ATTRIBUTE_NORMAL}
//~
//~   //CREATE_NEW = 1; //{$EXTERNALSYM CREATE_NEW}
//~   //CREATE_ALWAYS = 2; //{$EXTERNALSYM CREATE_ALWAYS}
//~   OPEN_EXISTING = 3; //{$EXTERNALSYM OPEN_EXISTING}
//~   //OPEN_ALWAYS = 4; //{$EXTERNALSYM OPEN_ALWAYS}
//~   //TRUNCATE_EXISTING = 5; //{$EXTERNALSYM TRUNCATE_EXISTING}
//~   //PAGE_NOACCESS = 1; //{$EXTERNALSYM PAGE_NOACCESS}
//~   PAGE_READONLY = 2; //{$EXTERNALSYM PAGE_READONLY}
//~   PAGE_READWRITE = 4; //{$EXTERNALSYM PAGE_READWRITE}
//~   //PAGE_WRITECOPY = 8; //{$EXTERNALSYM PAGE_WRITECOPY}
//~   //SECTION_QUERY = 1; //{$EXTERNALSYM SECTION_QUERY}
//~   SECTION_MAP_WRITE = 2; //{$EXTERNALSYM SECTION_MAP_WRITE}
//~   SECTION_MAP_READ = 4; //{$EXTERNALSYM SECTION_MAP_READ}
//~   //SECTION_MAP_EXECUTE = 8; //{$EXTERNALSYM SECTION_MAP_EXECUTE}
//~
//~   OF_READ = 0; //{$EXTERNALSYM OF_READ}
//~   OF_WRITE = 1; //{$EXTERNALSYM OF_WRITE}
//~   OF_READWRITE = 2; //{$EXTERNALSYM OF_READWRITE}
//~   //OF_SHARE_COMPAT = 0; //{$EXTERNALSYM OF_SHARE_COMPAT}
//~   //OF_SHARE_EXCLUSIVE = $10; //{$EXTERNALSYM OF_SHARE_EXCLUSIVE}
//~   //OF_SHARE_DENY_WRITE = $20; //{$EXTERNALSYM OF_SHARE_DENY_WRITE}
//~   //OF_SHARE_DENY_READ = 48; //{$EXTERNALSYM OF_SHARE_DENY_READ}
//~   OF_SHARE_DENY_NONE = $40; //{$EXTERNALSYM OF_SHARE_DENY_NONE}
//~ const
//~   AccessMode: array[0..2] of longword = (
//~     GENERIC_READ, GENERIC_WRITE, GENERIC_READ or GENERIC_WRITE);
//~   ShareMode: array[0..4] of longword = (
//~     0, 0, FILE_SHARE_READ, FILE_SHARE_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE);
//~ begin
//~   Result := integer(CreateFile(PChar(FileName), AccessMode[Mode and 3],
//~     ShareMode[(Mode and $F0) shr 4], nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0));
//~ end;
//

{
  Happy new year,

  I tried D7 with enthusiasm, after reading what's new for a brief then
  i install them in a little hurry +pick arbitrary sample project from my store,
  and guess what?... my code (with my favorite lucida console, 8-pt) looks
  pretty ugly, the characters are separated too far away, i dont believe it,
  it drives me mad, because (after many tries, it seems to me that) no way
  i could change it (the way it displayed in the old Delphi).

  well, since i'm, deeply in my heart is an artist, not a programmer or such,
  (i wrote, prepared, treated, and loved to see my code as a poem) i don't
  like that D7's ugly font-rendering style, i thrown away that new delphi,
  crushed the cd, and back to my old-pleasant-code-editor-looking D5.

  yes, maybe it just a matter of taste, but wasn't for that we're actually living for?
  dont buy D7, believe me...

}

{
  the D7 Help is less helpful than D5's, whenever I clicked F1 or Ctrl-F1,
  in D5 almost everytime I just got what I'd expected, whereas D7 gives me
  (too) many junks which I'd rather goto MSDN (or even Google or Wiki) for
  that kind of information.
}
{
  ups- sorry for irritating commentary above. pardon, pardon.. :)P
  I finally got a work around for that annoying problem. I've got to squeeze
  my favorite Lucida Console Advance-Width from 1200+ pix to 1080 pix (yes- we
  are *creating* new font here. name it Lucida Squized, then.

  No MMX, SSE & 3DNow! in Delphi5, not even RDTSC.
  Now it's time to say goodbye to her :(. (grief..)
}

//initialization
//  makemeUpNDown; // faster
//  WinUplo;
end.


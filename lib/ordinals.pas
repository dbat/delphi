unit Ordinals; // previously Ordnums unit
{$I QUIET.INC}
{$WEAKPACKAGEUNIT ON}
{$A+,J-}
//{.$D-} //no-debug
//{.$G+} //imported data on
//{.$J-} //no-writeableconst

{
  Fast & (not too) primitive ordinal number conversion
  (byte, shortint, smallint, word, dword, integer, int64)
  strictly speaking (out of random routines) this is a 'not real' unit

  Copyright (c) 2005-2006, aa & family :)
  Copyright (c) 2005, Adrian H & Ray AF
  Copyright (c) 2004, Adrian H., Ray AF. & Inge DR.
  Property of PT SOFTINDO Jakarta.
  All rights reserved.

  //mailto: aa<@AT>bitsmart<@DOT>com -> NO LONGER WORK
  mailto: aa<@AT>softindo<@DOT>net
  http://delphi.softindo.net

  Compiler: D5(?), D7, D9, maybe works also on D4, but not D3 (because of default args value)
  + derived from other source:
    - fastcode (InttoStr & Int64toStr)
    - ReverseBits from russian's QString by Andrew Dryazgov & Sergey G. Shcherbakov
    - pseudo random generator (Agner Fog, http://www.agner.org).
    - fastcode (fillchar, move, int64Div)
    - uInt64Div: form Norbert Juffa (asm gems), modified for delphi

  //...DELETE THIS INSULTING TEXT UPON UPLOAD...
  //
  //  :insult1:
  //  I dont like D7 code editor, the font-rendering too sparsed I had to get
  //  a font editor and CREATE MY OWN font to replace my favorite lucida console,
  //  so it displayed as tight as it did in old D5.
  //
  //  the D7 Help is less helpful than D5's, whenever I clicked F1 or Ctrl-F1, in D5
  //  almost everytime I just got what I'd expected, whereas D7 gives me (too) many junks
  //  which I'd rather goto MSDN (or even Google or Wiki) for that kind of information.
  //
  //  The MOST ANNOYING, very-very-very irritating, maybe the worst thing ever
  //  introduced by delphi is that 'smart ass' code-editor (error detector?),
  //  which constantly blaming for an error- she couldn't invoke the code completion & such.
  //  that b!^(# automatically pops up everytime, even when i turned off the
  //  code-completion features; no matter whether i explicitly open or close that
  //  message view, everytime i typed an advanced space, that f^(&!*@ b!^(#  keeps
  //  appears and disappearing (flip-flop) makes the screen flickers.
  //  also when i teared (undocked) it out and put it somewhere, it will then
  //  blown up and change the focus to herself!!! what A....
  //  (I then instantly felt an urge to kill that error message inventor).
  //
  //  note: It's eventually turned out later to me that these $#$@%!<~%&%#! behaviour
  //  was actually produced by GExpert's (along with another 'smart asses' options
  //  such as showing font property in object editor by their actual font).
  //  never again i turned that 'smart-creative-imaginative-sucker' Code-Proofreader on.
  //  (fortunately the source-code is available).

  //  Others are good, pretty much better than D5 (still Delphi is the best), I've
  //  been waiting for that customizable Code-Completion Width/Height, yet only the new
  //  complete set of asm ops alone was the unavoidable reason for me to switch to D7.
  //  (I'm not considering D6 or D8, ever not I liked Delphi's even number release)
  //
  //  :insult1a:
  //  its really an idiot idea to attach delphi as a default debuger which *automatically*
  //  bring delphi out when some application crash (of course with complete loading
  //  trillion tons of components palletes/packages- whoa database, web-shit and raper!),
  //  definitely will not give any help at all, it just like try to fix electronic circuit
  //  with hammer and screwdriver. it will fighting with MS Dev Studio debugger too
  //  (and even with another Delphi's version)
  //  if ever i want to debug kernel, i will use softice, not such a vb-pleased debugger :(
  //
  //  :insult2:
  //  to my best experience, many of 'acting smart' features really are
  //  in fact annoying and stupid. // just like this text :)
  //
  //  :insult3:
  //  .NET is suck, i never get a good reason why I have to use it (do you?)
  //
  //  :insult4:
  //  branch prediction is performance killer!
  //  intel's somewhat flawed branch-prediction makes programmers lives'
  //  much more difficult than it had to, which tends (sometimes at all costs)
  //  to avoid branches and write absurdly ridiculous, strugling xor, adc,
  //  sbb and such against bitmask.. to an uncomprehensible codes.
  //  (with costly shift/rotate +/-carry routines in a brain-damaged designed
  //  processor: P4 [whose performance 1/3rd of that of P3] --oughto be a works of
  //  monkey trained engineers,-- it's not even worth the pain)
  //
  //  get 2-3 clock gains for hits and 12-50 penalty for misses
  //  is hardly a choice, if at all. something which Intel's
  //  stupid branch prediction (designer) even missed to predict.
  //  (as what agner had noted that P1 design may predict for an
  //   *unconditional* jump to *never* be taken)
  //
  //  branch conversion to "difficult to read" code surely good for
  //  educative purposes, but when it recommended by intel itself to
  //  avoid branch (yes it did), it sounds to me like an ignorance,
  //  yet stupidly arrogant (any arrogancy is always stupid).
  //  (again, this comment itself is a good example of this kind of stupidity)
  //
  //  btw, conditional jumps, as they had a meaning and meant to be,
  //  are indeed  "conditional", [we would never make them "conditional"
  //  --just take a direct jump, if we have already known their target, would we?]
  //  they *inherently* are unpredictable, only god knows their destinations.
  //  (you know, anyshit who wanna be a god will ultimately yields out a devilish result).
  //

  //  just for you to remember:

  //  fortune, before its extinction, known to be a fragile solitair;
  //  whereas troubles (something that no matter how small portion of it
  //  would be more than enough), hardly ever come alone.

  //  remember that what we've had least expected is generally happens
  //  (and it is usually the worst).

  //  extreme optimist:
  //  do you think you have a bad day:
  //  troubles everywhere, anywhere-- everything you do going amiss?
  //  take it easy, dont worry too much; tomorrow, everything will be amuch worse!

  //  happy coding...
}
{ ===============================================================
  CHANGES

  Version: 1.0.0.10, LastUpdated: 2005.11.09
    add: uniqCharList get unique chars list from string; result: string
    add: uniqIntList get unique integers list from tintegers; result: tintegers
    enhanced: tickers: ticks and tictac; overloaded, gives second scaled
    changed: BigInt stuff moved to separate unit: BigIntX

  Version: 1.0.0.9b, LastUpdated: 2005.11.09
    :BigInt in progress:

      add: HextoIntX: convert hexadecimal string to BigInt
      add: intXSet: fill with byte val, slightly faster than fastcode's fillchar
           never use for other purpose! this one specific for BigInt (8-bytes fold)
           intXSetMMX much faster than intXSet, but requires mmx
      add: intXFill: fill with dword (4 bytes) pattern (useful for Div by reciprocal)
      add: intXFill8: fill with qword (8 bytes) pattern (useful for Div by reciprocal)
           note: intXFill and intXFill8 are slower than intXSet (using integer op of fpu)
      add: intXshl, intXshr: shif left/right, given negative count then ShifLeft
           will behave as ShiftRight and vice versa. (uses fastcode's fillchar & move)
      changed: improved intXDivQ, now accept full range of unsigned int64
      add: int64Div (fastCode) and uInt64DivMod (unsigned int64)
      add: intXMulQ; multiply with unsigned int64;
           (havent checked yet, ought to be slower than simple intXMul)

  Version: 1.0.0.9a, LastUpdated: 2005.11.04
    add: uIntOf, unsigned int/int64 only, 3 times (at least) faster than StrToInt64
    :BigInt in progress:
      add: intXmulD, int128MulD and int256MulD, specific (faster) routines
      add: StrtoIntX: convert string (decimal digits only) to BigInt
      add: IntXSmallestFit: get smallest fit BigInt type for a value
      add: bit-shift --slooow... intXDivMod, provided as the last resort
           int128DivMod, intXtoStr, DivMod128
           DivMod = BigInt div BigInt => BigInt:Quotient, BigInt:Remainder
      changed: align 8 now default; many routines using floating point transfer
      changed: extend BigInt type to its (unapplicable) limit: int8G (requires 1GB)
      changed: int128DivD, int128DivQ
      changed: new intXDivD, old renamed to intXDivDr

  Version: 1.0.0.9, LastUpdated: 2005.10.17
    add: extra argument: Leading Char (normally '0') for intoStr
    change: using full unsigned int64 has proven to improve randomness
            (entropy, pi's monte-carlo & chi-square test) for 64KB sample
            (breaks compatibility, generated sequence will be different with previous one)
    change: extended randCycle, full combination of cycle flow (24 alternatives)
            A-B-C-D, A-B-D-C,... thru D-C-B-A (24 combinations = 4!);
    :BigInt in progress:
    new: tBigInteger types, currently up (but not limited) to 1024-bits,
         the major limitation is (what else?) div routines, the acceptable
         divisor max. is 1/4 of int64 wide (upto 03ff-ffff-ffff-ffff).
         (compared against GNU's bc result for int64K wide).
         all BigInt's routines are named with intX:
           intXMul, multiply: BigInt * BigInt
           intXDivD, divide: BigInt / Double-Word (integer)
           intXDivQ, divide: BigInt / Quad-Word (int64)
         intXtoStr: convert BigInt type to decimal string

  Version: 1.0.0.8d, LastUpdated: 2005.10.11
    add: GUIDtoStr/StrtoGUID, Sysutils' equivalent
    fix: blocks suffix, which found when implementing GUIDtoStr :)
    changed: add '-' to global OrdDelimiters, since without it StrtoGUID will always fail

  Version: 1.0.0.8c, LastUpdated: 2005.09.3
    fix: FP environment at Random Initialization MUST well,-- initialized first (by: fInit)
         (about 3% XP system on our customer produce different result without it)

  Version: 1.0.0.8b, LastUpdated: 2005.09.2
    note: what a mess :(
    added: 3-digits Fold argument in octn, to support Ordinals Type Editor
    added: uintostr for Int64 (inttostr for unsigned int64)
    note: random generator is too expensive, will be replaced by a cheaper one
          (though agner said that it had a very good quality of randomness,
          sufficient enough even for large Monte-Carlo calculations)

  Version: 1.0.0.8a, LastUpdated: 2005.09.1
    changed: using two separated routines instead (more convenient):
           //----------------------------------------------------------------
             - hexb: buffer dump (read from first byte to the end)
             - hexn: buffer as hex number (internally reversed, read from the last)
                     in effect interprets buffer as a (Big-Endian) hex number

             the two's above accept args: (char) Delimiter, xsLowercase and xsByteSwap
             note that Delimiter = #0 (default value) means NOT-delimited at all

             example: @Int64, value : $0123456789ABCDEF
                            (all delimited with space)
             hexb               EF CD AB 89 67 45 23 01
             hexb (ByteSwap)    FE DC BA 98 76 54 32 10

             hexn               01 23 45 67 89 AB CD EF
             hexn (ByteSwap)    10 32 54 76 98 BA DC FE
           //----------------------------------------------------------------
    changed: also bins become binb and binn (paralel with hex- above)
    changed: octb and octn works in paralel with above, octs remains.

  Version: 1.0.0.8, LastUpdated: 2005.09.0
     changed: hexs redesigned completely; now using THexStyles argument
              (xsLowercase, xsReverse, xsSwapByte)

  Version: 1.0.0.7, LastUpdated: 2005.08.0
    fix: bug 0 intoStr, using: ( >0 ) when it used to be: ( >= 0 )
    changed: bins(Buffer), uniform simple dword instr should be faster
             (also fixed bug in old version which erroneously using SHL in place of SHR)
             todo: making/stating the most convenient way to access bins
    add/changed: add new "octs" routine; previous "octs" changed to "octs_b"
    add: Reverse Bits (from QString by Andrew Dryazgov & Sergey G. Shcherbakov)
    add: Reverse string to support big/little-endian convert (notably "octb/octn" & "octs")
         dword per-move, arranged to avoid AGI-stall, (but unwatched for unaligned dword).
    add: bintoi, bintoi64, binary-string (bin, hex and octal) to integer conversion routines
    changed: new hexs for buffers seems to be OK, (and correct). prior versions
             (for int, byte word etc) are deprecated and will at last be declined.

  Version: 1.0.0.6, LastUpdated: 2005.06.0
    Remove dependency to system (Str & StrLong, slow conversion of integer
    to string), replaced/rearrange with code winner from www.fastcode.dk (author: John O'Harrow)
    added: uintostr, unsigned cardinal to string conversion (cardinal version only,
           derived from fastcode, much faster than using Int64 converter, when
           value to be converted is greater than maxint (2147483647)).

  Version: 1.0.0.5b, LastUpdated: 2005.05.0
    published: getBitsWide, get bits wide of specified value
    added: Shuffle function, flexible range min..max inclusive
    changed: regarding above, change name: RandShuffle to RandCycle,
            (in fact it is actually "cycled" or "Rolled", not "shuffled")
    added: RandomizeEx function, just a simple wrapper of RDTSC
    added: DivMod64, get int64 dividend and quotient / modulo at once

  Version: 1.0.0.5, LastUpdated: 2005.04.1
    added: ROR & ROL ~ why aren't they built-in in the System unit? :(
    add/changed: bin to bins (as in hexs), now better & works also with buffer
    add: octs (bins and hexs complement)
    add/moved from ACommon unit: Blocks (in pure pascal!)
    fixed: bins (negative value should not have to always be widened to 64-bits)
    add: shld/shrd now functional, slightly different (extended) from asm instruction
    fixed: slippery bug min/max for int64

    bug report, please...
}

 {
  Carry flag adc/sbb Quick-Reference
  by: aa, PT Softindo, Jakarta, 2004.

  - sbb REG,0 = dec REG if carry;
      result CF always clear, unless (REG = 0) AND (carry)
  - adc REG,0 = inc REG if carry;
      result CF always clear, unless (REG = -1) AND (carry)
  - sbb REG,-1 = inc REG if not carry;
      result CF always set, unless (REG = -1) AND (NOT carry)
  - adc REG,-1 = dec REG if not carry;
      result CF always set, unless (REG = 0) AND (NOT carry)

  sbb REG,REG = set REG as bitmask (-1) if carry, else clear (zero).
  sbb REG,REG + not REG = set REG as bitmask (-1) if not carry, else clear.
  salc (db D6h) = set AL as bitmask (FFh) if carry, else clear. no flags affected.

  ------------------------------------------------
                    Before_____     After______
   Operation        CF      REG     CF      REG
  ------------------------------------------------
    sbb REG,0       SET      0      SET      -1
    sbb REG,0       CLEAR    0      CLEAR     0
    sbb REG,0       X      N<>0     CLEAR   N-1

    adc REG,0       SET     -1      SET      0
    adc REG,0       CLEAR   -1      CLEAR    -1
    adc REG,0       X     N<>-1     CLEAR   N+1

    sbb REG,-1      SET     -1      SET      -1
    sbb REG,-1      CLEAR   -1      CLEAR    0
    sbb REG,-1      SET   N<>-1     SET       N
    sbb REG,-1      CLEAR N<>-1     SET     N+1

    adc REG,-1      SET      0      SET      0
    adc REG,-1      CLEAR    0      CLEAR    -1
    adc REG,-1      SET    N<>0     SET       N
    adc REG,-1      CLEAR  N<>0     SET     N-1
  ------------------------------------------------

  - sbb REG,0 = dec REG if carry
      if (REG = 0) then carry flag will NOT change (retained)
      else carry-flag will be clear (either retained or cleared)

      only if (REG = 0) AND (carry) then carry flag will be set/carry/retained
      else carry-flag will be clear (either retained or cleared)

  - adc REG,0 = inc REG if carry
      if (REG = -1) then carry flag will NOT change (retained)
      else carry-flag will be clear (either retained or cleared)

      only if (REG = -1) AND (carry) then carry flag will be set/carry/retained
      else carry-flag will be clear (either retained or cleared)

  - sbb REG,-1 = inc REG if not carry
      only if (REG = -1) AND (NOT carry); then carry flag will be clear/retained; zero; even
      else carry-flag will be set (either retained or modified)

  - adc REG,-1 = dec REG if not carry
      only if (REG = 0) AND (NOT carry) then carry flag will be clear/retained; signed; even
      else carry-flag will be set (either retained or modified)
 }

interface

{ rdtsc is actually identical with QueryPerformanceCounter minus overhead,
  hence it gives 1/10-th smoother granularity. QueryPerformanceFrequency
  may also be used as usual (they both essentially are equivalent).

  get ticks Count; equal with uptime (how long computer has been running)
  result is in clock cycles, useful for raw performance monitoring.
  use tickNS to get in (micro! not milli) seconds resolution
  do not mix the argument of ticks and tickms }

function ticks: int64; overload;

// count ticks elapsed from previous ticks
function ticks(const previoustick_cycles: int64): int64; overload;

// get ticks Count (in micro-second 1/1000000 second);
// do not mix the argument of tickms and ticks
function tictac: int64; overload;

// count times elapsed from previous tickms
function tictac(const previoustick_microseconds: int64): int64; overload;

const // from ACConsts
  YES = TRUE;
  SPACE = ' ';
  __CRC32Poly__ = $EDB88320; // widely used CRC32 Polynomial
  __AAMAGIC0__ = $19091969; // my birthdate
  __AAMAGIC1__ = $22101969; // my wife's birthdate
  __AAMAGIC2__ = $09022004; // my (first) son's birthdate
  //__AAMAGIC3__ = $04012006; // my second son's
  //__AAMAGIC4__ = $05072008; // my third child's/daughter (wow it's SHE!)

  sp_EAX = 4 * 7; sp_ECX = 4 * 6; sp_EDX = 4 * 5; sp_EBX = 4 * 4;
  sp_tmp = 4 * 3; sp_EBP = 4 * 2; sp_ESI = 4 * 1; sp_EDI = 4 * 0;

type
  //TInts = ACConsts.TInts;
  //TArInts = ACConsts.TArInts;
  //TStrs = ACConsts.TStrs;

  {$IFNDEF Delphi6_up}
  TBoundArray = array of integer; //uncomment this for D5 and below
  {$ENDIF}

  TIntegers = TBoundArray;
  uInt64 = {type} int64;

  r64 = packed record
    case Integer of
      0: (Lo, Hi: Cardinal);
      1: (Cardinals: array[0..1] of Cardinal);
      2: (Words: array[0..3] of Word);
      3: (Bytes: array[0..7] of Byte);
  end;

  fp80 = packed record // 80 bits extended floating point
    S: r64; // significand
    exp: word; // biased 163784
  end;

  tHexStyle = (
    xsLowerCase, // you now it; default = FALSE, means Uppercase
    xsReverse, // BigEndian vs Little Endian (as a whole)
    xsSwapByte, // properly stated: swap-nibbles at every byte-boundaries
    xsBlockWise // unimplemented, Reverse at every block-boundaries
    );
  tHexStyles = set of tHexStyle;

  //type TBytesWide = (bwByte, bwWord, bwInteger, bwInt64, bwInt256, bwBigInt, bwVeryBigInt, bwHugeInt);

// ====================================================================
// TEST AREA, TEST AREA, TEST AREA, TEST AREA, TEST AREA, TEST AREA,
// --------------------------------------------------------------------
//var
//  _TIntegersTypeInfo: pointer absolute typeInfo(TBoundArray);

function tablehex: pchar;

function hexs_countspace(const Buffer; const BufLen: integer; const BlockLen: integer;
  const Delimiter: char = ' '; const HexStyles: THexStyles = []): integer; overload;

//function Int64uStr(const I: Int64; const Digits: byte = 0): string;
//function I64uStr(x64: Int64): string;

// --------------------------------------------------------------------
// END TEST AREA
//================================================================================

// ====================================================================
// NOT USED ANYWAY
// --------------------------------------------------------------------

function setBit(const BitNo, I: integer): integer; overload;
function ResetBit(const BitNo, I: integer): integer; overload;
function ToggleBit(const BitNo, I: integer): integer; overload;
function isBitSet(const BitNo, I: integer): Boolean; overload;

function setBit(const BitNo: integer; const I: Int64): Int64; overload;
function ResetBit(const BitNo: integer; const I: Int64): Int64; overload;
function ToggleBit(const BitNo: integer; const I: Int64): Int64; overload;
function isBitSet(const BitNo: integer; const I: Int64): boolean; overload;

// --------------------------------------------------------------------
// END NOT USED ANYWAY
//================================================================================

procedure ReverseBits(const Buffer; BitCount: cardinal);

//(yet another) reverse a string, using dword per move (thanks to bswap)
function Reverse(const S: string): string;

// count bits set; found at bit-twiddling-hacks (Sean Eron Anderson)
// originally in C; enhanced to int64
// traced back to UNIX/C prophets: Ritchie & Kernighan
function bitCount(const I: integer): integer;
function bitCount64(const I: int64): integer;

// without loop. to avoid absurdly expensive branch mispredict
function bitCount2(const I: integer): integer;

// get bits wide of a number (locate the highest bit of specified number), 1-based.
// will use preferredbitswide instead if the highest bit is LOWER than given preferredBitsWide
// return pos of one and only bit which is set in an int64 (power 2), else return neg
function bitscantest(const I: int64): integer;
function getBitsWide(const I: Int64; const preferredBitsWide: integer = 0): integer; overload;
// for P2 above; bsr is fast enough
function getBitsWideP2(const I: Int64): integer; overload;

//BSF and BSR replacement
function bitScanRev(const I: integer): integer;
function bitScanForward(const I: integer): integer;

// makes a binary (bits) string from a value
// at this time, no formatting provided. use function "blocks" instead
// binb works as bytes dump, whereas binn will interprets the whole  Buffer as a value
function binb(const Buffer; const BufferLength: integer): string;
function binn(const Buffer; const BufferLength: integer): string;

// makes an octal string from buffer as a one contiguous bits
function octb(const Buffer; const BufferLength: integer): string; overload;

// interprets octal buffer as an octal value
function octn(const Buffer; const BufferLength: integer; const Fold3digits: boolean = FALSE): string;

// makes an octal string from a value byte-per-byte rather than continuous
function octs(const Buffer; const BufferLength: integer; const Delimiter: Char = #0): string; overload;
{
// in the ordinary usage, the data/buffer always seen as group of bytes not of bits.
// that was not the case in the octal format, the next or previous bits in 3 bytes
// group will contains one or two bits remains of the octal value.
//
// the other ordinals routines (hexsb and binb) also interpret buffer as bytes
// that is actually the "wrong" sight of bits order; for intstance, the value
// 12h or 1100-0010b actually stored as 21 or 0100-0011 in memory (big-endian)
//
// the octb routine did contrawise with hex/bin. since it is not possible to
// truncate data per-byte which might be broken on the middle of an octal value
//
// in the consequence of that, the octn result (interpret as value) would be
// no different with a reversed string of octb result.
//
// the simple difference between "octb/octn" and "octs" is by example,
// of value 256 ($0100),  octn result = 400, whereas octs result = 1000 (001 000)
// the practical uses of octs is, for instance, converting IP digit number from an integer,
// whereas octb/octn is used for.. i dont know, it simply a base-8 number converter :)
//
}
// pretty formatted hexa number
function hexb(const Buffer; const BufLen: integer = 0;
  const HexStyles: THexStyles = []; const Delimiter: char = #0): string;

function hexn(const Buffer; const BufLen: integer = 0;
  const HexStyles: THexStyles = []; const Delimiter: char = #0): string;

function hexs(const Buffer; const BufLen: integer; const HexStyles: THexStyles;
  const Delimiter: char): string; overload;
{
// bintoi & bintoi64, string to integer conversion routines for binary, octal
// and hex number with suffix "b", "o" and "h" respectively, so we could say:
// "111 0001 1011b", or "000111 0001-1011_b", or "07 - 11H". all are equals
// since the middle delimiters are treated as nondestructive whitespaces (ignored)
// as in:  "+---11o" (octal) = "-1-0-0---1 b"  = -9.
//
// You may change default delimiters (charset) at run time by assigning
// a new value to the global variable: "ordDelimiters", currently are:
// HYPEN (see notes below), COLON, SPACE and ANY control characters.
// (most likely to be out-of-sync with this text. see the actual value
//  of GlobalVar "ordDelimiters" instead).
//
// note: preceding series of DASHes/HYPENs (also PLUSes) will be
//       interpreted as multiplied negative/positive sign.
//       The PLUS sign in the middle of numbers is an error
//
// note: "octs" function works as byte-per-byte translator e.g.
//       12345 = $3039 (means: $30, $39) = "060071" (means: 060, 071);
//       whereas in bintoi, 12345 should be written as: "30071o"
//       = 3*(8*8*8)  +  0*(8*8)  +  0*(8*8)  +  7*8  +  1  = 30071_o
//
//       another example of "octs" output: 1234567 = $12D687 ($12, $D6, $87) = "22326207"
//       in bintoi should be written as: "4553207_o"
//       = 4(8^6) + 5(8^5) + 5(8^4) + 3(8^3) + 2(8^2) + 0*8 + 7
//
// on conversion error, the errCode contains value > 0
//   high byte:
//     01h: blank string
//     02h: too small a string
//     03h: invalid suffix (other than upper/lower 'B','O' and 'H')
//     04h: not a number
//     05h,06h,07h: invalid character in bin/oct/hex string respectively
//   low byte: if applicable, indicates the position of error.
//
// note:
//   no overflow error checks, the function will happily interpret any
//   syntaxly correct string such as "+---01234567-890ABCDEF-01234567-890ABCDEF-.....01234567h"
//   anyhow it will gives the proper least-fit integer value: "19088743" ($01234567),
//   or "-8526495043095935641" ($890ABCDEF01234567) for int64 value
//
}
//bintoi for integer and int64
function bintoi(const S: string; out errCode: integer): integer; overload;
function bintoi64(const S: string; out errCode: integer): Int64; overload;
{
// simple wrapper, on conversion error the result value will be
// the lowest int number: $80000000 (integer) or $8000000000000000 (int64)
//
// as always, do not put these declarations before/above called routines,
// since they are blindly stupid assembler routines, who does not give
// a damn about number of arguments, they call whichever comes first in
// the declaration order
}
function bintoi(const S: string): integer; overload;
function bintoi64(const S: string): Int64; overload;
{
// just a speedy wrapper for Inttostr, IntToHex and StrToInt
// function intoStr(const I: cardinal; const Digits: integer = 8): string; overload;
//
// note that the CARDINAL type will be treated by the compiler as int64
// since high(cardinal) > high(integer), therefore if you are not specifying Digits,
// for cardinal type argument, it is default to Int64's digit size (16 chars width)
//
// as a rule of thumb, always specifies Digits (length) for cardinal type argument
//
// IsHex is just an auto prepend '$' hex-specifier,
// so do not call IsHex = YES, if the S has already had '$'
//
// intoHex/intoStr/uintoStr argument:Digits, specifies how many digits (instead of how many bytes)
// it could be an odd number upto 255 digits, zero-left padded, auto-expanded (if less than digits-required)
}
function intoHex(const I: integer; const Digits: byte = sizeof(integer) * 2; UpperCase: boolean = YES): string; overload //register;
function intoHex(const I: Int64; const Digits: byte = sizeof(Int64) * 2; UpperCase: boolean = YES): string; overload //register;
function intoStr(const I: integer; const Digits: integer = 0; const LeadingZero: char = '0'): string; overload;
function intoStr(const I: Int64; const Digits: integer = 0; const LeadingZero: char = '0'): string; overload;

function uintoStr(const I: Integer): string; overload; // unsigned intostr, derived from fastCode
function uintoStr(const I: uInt64): string; overload; // unsigned intostr, derived from fastCode

// get unsigned integer from String; reverse function of inttoStr
function uIntOf(const S: string): uInt64;
//function uIntOf2(const S: string): int64;
// triple+ faster than standard StrToInt64, but this one accepts only positive
// decimal digits (no sign allowed), and has not any fancy error message,

// StrToIntDef clones, do not expect too much
function IntOf(const S: string; const DefaultValue: integer = 0): integer; //overload
function IntOfF(const S: string; const DefaultValue: integer = 0): integer; //overload
function Int64Of(const S: string; const DefaultValue: int64 = 0): int64; //overload
function Int64OfF(const S: string; const DefaultValue: integer = 0): Int64; // lightweight version

function Str2Int(const S: string; const IsHex: Boolean = FALSE; const DefaultValue: integer = 0): integer; overload;
function Str2Int(const S: string; const DefaultValue: integer; const IsHex: Boolean = FALSE): integer; overload;
function Str2Int64(const S: string; const IsHex: Boolean = FALSE; const DefaultValue: Int64 = 0): Int64; overload;
function Str2Int64(const S: string; const DefaultValue: Int64; const IsHex: Boolean = FALSE): Int64; overload;

// minmax functions // better use minmaxmid unit
// hadtobe changed in names ~ toomany abuse name of min/max
function _Min(const a, b: integer): integer; overload //register;
function _Max(const a, b: integer): integer; overload //register;
function UMin(const a, b: integer): cardinal; overload //register; //unsigned integer
function UMax(const a, b: integer): cardinal; overload //register; //unsigned integer
function _Min(const a, b: Int64): Int64; overload //register; //unsigned integer
function _Max(const a, b: Int64): Int64; overload //register; //unsigned integer
function uMin(const a, b: Int64): Int64; register; overload //unsigned int64
function uMax(const a, b: Int64): Int64; register; overload //unsigned int64

function MinMax(const a, b: integer): integer; overload;
// not useful unless you called this from asm
// min in eax, max in edx, ecx preserved.

// ROL & ROR family, which should have been included in the System unit
function rol(const I: integer): integer; overload //register;
function ror(const I: integer): integer; overload //register;
function rol(const I: Int64): Int64; overload //register;
function ror(const I: Int64): Int64; overload //register;

function rol(const I: integer; const ShiftCount: integer): integer; overload //register;
function ror(const I: integer; const ShiftCount: integer): integer; overload //register;
function rol(const I: Int64; const ShiftCount: integer): Int64; overload //register;
function ror(const I: Int64; const ShiftCount: integer): Int64; overload //register;

procedure lol; //-)

// and why aren't shlr & shld either? :)
procedure shld(var A: integer; const B: integer); overload //register;
procedure shrd(var A: integer; const B: integer); overload //register;
procedure shld(var A: Int64; const B: Int64); overload //register;
procedure shrd(var A: Int64; const B: Int64); overload //register;

// unlike (better than) asm shld/shrd, this routines will shift the second argument
// into the first argument until *all* of them are zeroed (up to 64 shifts)
procedure shld(var A: integer; const B: integer; const ShiftCount: byte); overload //register;
procedure shrd(var A: integer; const B: integer; const ShiftCount: byte); overload //register;

// unlike (better than) asm shld/shrd, this routines will shift the second argument
// into the first argument until *all* of them are zeroed (up to 128 shifts)
procedure shld(var A: Int64; const B: Int64; const ShiftCount: byte); overload //register;
procedure shrd(var A: Int64; const B: Int64; const ShiftCount: byte); overload //register;
{
// note:
//   the optimization by the compiler will lead to integer version of ROL/ROR
//   if the value of I is within the range of integer (you should typecasted it to Int64).
//
//  // priorly ShiftCount is of type byte, now changed to integer,
//  // this note is no longer applicable; this only for remainder,
//  // on the similar circumtance, this comment is still valid though.
//  // obsolete:  BEWARE if you (on slippery) supplied an integer type
//  // obsolete:  (NOT byte) of ShiftCount, EVEN if I is type of int64,
//  // obsolete:  the compiler will take an integer version of ROL/ROR.
//  // obsolete:  (you MUST explicitly typecasted it to byte)
//
//   to avoid confusion, rol for int64 idname might better be changed to (ie.) rol64 instead
//

// get Quotient and Remainder at once // for D4 below change "out" with "var"
// function DivMod64(const Dividend, Divisor: Int64; out Quotient: Int64): Int64;

// block string formatting, distribute string in blocks of BlockLen length,
// customizable block length and delimiter, leftwise or rightwise, e.g.:
//
//   1234567890 -> 123 456 789 0  (length = 3 (default), delim = A SPACE, leftwise)
//   1234567890 -> 1 234 567 890  (length = 3 (default), delim = A SPACE, righwise)
//
// Prefix and Suffix length are number of firstly/lastly characters to be
// ignored in formatting
//
// note: to format Buffer as hex use Hexs function instead!
//
// originally i used blocks to format money, that way it is default to 3.
// now i feel urge to change them to 4 to format integer which currently
// i intensively working on. after-all, this in fact is an ORDINALS unit, isn't it?
// any comments for this?
}
function Blocks(const S: string; const delimiter: string = SPACE; const BlockLen: integer = 4;
  const LeftWise: Boolean = FALSE; //const Interval: integer = 1;
  const SkipPrefixLength: integer = 0; const SkipSuffixLength: integer = 0): string; overload;
function Blocks(const I: integer; const delimiter: string = SPACE; const BlockLen: integer = 4;
  const LeftWise: Boolean = FALSE; //const Interval: integer = 1;
  const SkipPrefixLength: integer = 0; const SkipSuffixLength: integer = 0): string; overload;
function Blocks(const I: int64; const delimiter: string = SPACE; const BlockLen: integer = 4;
  const LeftWise: Boolean = FALSE; //const Interval: integer = 1;
  const SkipPrefixLength: integer = 0; const SkipSuffixLength: integer = 0): string; overload;

// many often i just want to change the blocklength
function Blocks(const S: string; const BlockLen: integer; const delimiter: string = SPACE;
  const LeftWise: Boolean = FALSE; //const Interval: integer = 1;
  const SkipPrefixLength: integer = 0; const SkipSuffixLength: integer = 0): string; overload;
function Blocks(const I: integer; const BlockLen: integer; const delimiter: string = SPACE;
  const LeftWise: Boolean = FALSE; //const Interval: integer = 1;
  const SkipPrefixLength: integer = 0; const SkipSuffixLength: integer = 0): string; overload;

//sample implementation
function isValidGUIDStr(const S: string): boolean;
function GUIDtoStr(const GUID: TGUID): string;

{$IFNDEF Delphi6_up}
type
  TRuntimeError = (reNone, reOutOfMemory, reInvalidPtr, reDivByZero,
    reRangeError, reIntOverflow, reInvalidOp, reZeroDivide, reOverflow,
    reUnderflow, reInvalidCast, reAccessViolation, rePrivInstruction,
    reControlBreak, reStackOverflow,
  { reVar* used in Variants.pas }
    reVarTypeCast, reVarInvalidOp,
    reVarDispatch, reVarArrayCreate, reVarNotArray, reVarArrayBounds,
    reAssertionFailed,
    reExternalException, { not used here; in SysUtils }
    reIntfCastError, reSafeCallError
    {$IFDEF LINUX}
    , reQuit, reCodesetConversion
    {$ENDIF}
    );
  {$ENDIF}

procedure SysError(errorCode: TRuntimeError);

//still sample implementation
function StrToGUID(const S: string; const RaisedError: TRuntimeError = reInvalidCast): TGUID;

// - RANDOM -
// These pseudo random function will generates a reproductable result (ie. the same
// sequence of numbers) by the same RandSeed numbers or the same RandomInit argument.

// see notes below
function Rand64: Int64; overload

// Max for Rand64u taken as unsigned int64
function Rand64u(const Max: int64): Int64; overload
function Rand(const Max: cardinal = high(cardinal)): cardinal; overload //register;
function Rand(const Min, Max: integer): integer; overload //register;
function RandEx: Extended;

//test...
function __RandCycle(var X; const CycleFlow: integer = 0): int64;

// remember to call this function first (and feed it in your own exotic magic numbers)
// usually the argument is time-tick value; to produce an unpredictable numbers sequence
//procedure RandInit(const I: integer = __AAMAGIC0__); register
procedure RandInit(const I: int64 = int64(__AAMAGIC1__) shl 31 or __AAMAGIC0__); register

// All right then, you lazy... We give you Randomize function here at last :(
procedure RandomizeEx;
{
// Shuffle: generate array of non repeatable integers of specified range in min..max (inclusive)
// the min/max value may be negative as long as min..max range (inclusive) does not exceed
// 4 GB boundary, no error checking, since the array itself would not even permit that huge.
// note that this function is NOT including initialization of random / randomize (neither did-
// the other random functions), it will gives a repeatable sequence when given the same init value
}
// function _Shuffle(Range: integer): TInts;
function Shuffle(const Max: integer): TIntegers; overload;
function Shuffle(const Min, Max: integer): TIntegers; overload;

{ fastCode projects (Dennis C. & John O'Harrow)       }
{ used by intXshl & intXshr                           }
procedure fastMove(const Source; var Dest; Count: Integer);
procedure fastFillChar(var Dest; const Count: Integer; const Value: char);

{
// __move0, based on fastCode fastMove; destroys only ecx
procedure __move0(const esi; var edi; ecx: Integer);
// __move1 -> destroys: ecx,edx; preserved: eax,esi,edi
procedure __move1(const esi; var edi; ecx: Integer);
// __move2 -> destroys: ecx,eax; preserved: edx,esi,edi
procedure __move2(const esi; var edi; ecx: Integer);
}

function Int64Div(var X, Y: Int64): Int64; // signed int64

//fast uint64DivMod, original code of Norbert Juffa's (asm gems)
{ result is Modulo; var Dividend replaced by Quotient }
function uInt64Mod(var Dividend: uInt64; const Divisor: uInt64): uInt64;

{ result is Quotient; var Dividend replaced by Modulo }
function uInt64Div(var Dividend: uInt64; const Divisor: uInt64): uInt64;

{ get Unique chars list from string }
function UniqCharList(const S: string): string;

{ get Unique integers list from array of integer }
function UniqIntList(const Integers: TIntegers): TIntegers;

const
  {$J+}
  RandseedEx: array[0..4] of integer = (__AAMAGIC0__, __AAMAGIC1__, __AAMAGIC2__, integer(__CRC32Poly__), -1);
  // note that all of the magic numbers above will be trashed anyway upon init
  // presented just in case you forgot to call randomizeEx function

  //threadvar
  ordDelimiters: set of char = [#0..' ', ':', '.', '_', '-'];
  {$J-}

const
  BitsperByte = 8;
  BitsperWord = sizeof(word) * BitsPerByte;
  BitsperInt = sizeof(integer) * BitsPerByte;
  BitsperInt64 = sizeof(Int64) * BitsPerByte;
  MAXORD = high(cardinal);

implementation
//uses SysUtils;

//========================================================================

const
  _cpuid = $A20F; _rdtsc = $310F; // compatibility with delphi 5 older
  ticks_hz: double = 0;
  _1M: single = 1E6; // microsecond divisor

function GetticksHz(var lpFrequency: int64): longbool; stdcall;
  external 'kernel32.dll' name 'QueryPerformanceFrequency';

function ticks: int64; asm
  //call __getCPUIDtime
  //sub eax,ecx; sbb edx,0;
  dw _rdtsc
end;

function ticks(const previoustick_cycles: int64): int64;
asm
  //call __getCPUIDtime
  //sub eax,ecx; mov ecx,previoustick_cycles.r64.lo
  //sbb edx,0; sub eax,ecx;
  //mov ecx,previoustick_cycles.r64.hi;
  //sbb edx,ecx;
  dw _rdtsc
  mov ecx,previoustick_cycles.r64.lo
  sub eax,ecx; mov ecx,previoustick_cycles.r64.hi
  sbb edx,ecx
end;

function tictac: int64;
asm
  mov ecx,ticks_hz.dword;
  test ecx,ecx; jnz @@Count
    push offset ticks_hz; call getticksHz;
    fld _1M; fild ticks_hz.qword;
    fdiv; fstp ticks_hz;
  @@Count:
  dw _rdtsc; push edx; push eax;
  fild [esp].r64; fmul ticks_hz
  fistp [esp].r64;
  pop eax; pop edx;
end;

function tictac(const previoustick_microseconds: int64): int64;
asm
  mov ecx,ticks_hz.dword;
  test ecx,ecx; jnz @@Count
    push offset ticks_hz; call getticksHz;
    fld _1M; fild qword ptr ticks_hz;
    fdivp; fstp ticks_hz;
  @@Count:
  dw _rdtsc; push edx; push eax;
  fild previoustick_microseconds;
  fild [esp].r64; fmul ticks_hz;
  fxch; fsub; fistp [esp].r64;
  pop eax; pop edx;
end;

// serialized.

function __getticks: int64;
const
  _cpuidrdtsc = $310FA20F; // db 0fh,0a2h,0fh,031h
  cpuid_time: integer = 0;
  slack = 5; // approx. excess cycles at 1st-call
asm
  push ebx; dd _cpuidrdtsc;
  mov ebx,cpuid_time;
  test ebx,ebx; jz @@init
  sub eax,ebx; pop ebx;
  sbb edx,0; ret
@@init:
  push offset ticks_hz; call GetTicksHz;
  fild qword ptr ticks_hz;
  fdivr _1M; fstp ticks_hz
  push esi; push 3; pop esi; jmp @@Loop
  @@rdtsc: xor eax,eax; dd _cpuidrdtsc; ret;
  @@Loop: call @@rdtsc; dec esi; jnl @@Loop;
  xor esi,eax; call @@rdtsc;
  add esi,eax; add eax,slack;
  mov cpuid_time,esi; pop esi;
  adc edx,0; pop ebx;
end;

function tictacs: int64; overload;
asm
  call __getticks; push edx; push eax;
  fild [esp].r64; fmul ticks_hz
  fistp [esp].r64;
  pop eax; pop edx;
end;

function tictacs(const previoustick_microseconds: int64): int64; overload;
asm
  call __getticks; push edx; push eax;
  fild previoustick_microseconds;
  fild [esp].r64;
  fmul ticks_hz; //fxch
  fsubr; fistp [esp].r64;
  pop eax; pop edx;
end;
{
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Notes:
//   Min-Max functions excerpted from unit MinMaxMid
//   (produced by the same authors)
//   please get the recent version
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
}

function _Min(const a, b: integer): integer; overload asm
  //xor ecx,ecx; sub eax,edx;
  //setl cl; mov eax,eax;
  //sub ecx,1;
  //and eax,ecx; add eax,edx;
  xor ecx,ecx;
  sub edx,eax
  setge cl; // the only difference
  sub ecx,1
  and edx,ecx
  add eax,edx
end;

function _Max(const a, b: integer): integer; overload asm
  //damn wrong!
  //xor ecx,ecx; sub eax,edx;
  //setg cl; mov eax,eax;
  //sub ecx,1;
  //and eax,ecx; add eax,edx;
  xor ecx,ecx;
  sub edx,eax
  setl cl; // the only difference
  sub ecx,1
  and edx,ecx;
  add eax,edx
end;

function MinMax(const a, b: integer): integer; overload asm
// not useful unless you called this from asm
// min in eax, max in edx, ecx preserved.
  push ebx
  push ecx
  xor ecx,ecx;
  xor ebx,ebx;
  sub edx,eax
  setl cl; // the only difference
  setge bl // the only difference
  sub ecx,1
  sub ebx,1
  push edx
  and edx,ecx;
  pop ecx
  push eax
  and ecx,ebx
  add eax,edx;
  pop edx
  add edx,ecx
  pop ecx
  pop ebx
end;

function UMin(const a, b: integer): cardinal; overload asm
	sub b,a; sbb ecx,ecx
	and b,ecx; add a,b
end;

function UMax(const a, b: integer): cardinal; overload asm
   xor ecx,ecx
   sub a,b; adc ecx,-1
   and a,ecx; add a,b
end;

function uMin(const a, b: Int64): Int64; overload asm
  mov eax,a.dword; mov edx,b.dword;
  xor ecx,ecx; sub eax,edx;
  mov eax,a.dword+4; mov edx,b.dword+4;
  sbb eax,edx; setnb cl;
  mov eax,ecx*8+a.dword; mov edx,ecx*8+a.dword+4;
end;

function uMax(const a, b: Int64): Int64; overload asm
  mov eax,a.dword; mov edx,b.dword;
  xor ecx,ecx; sub eax,edx;
  mov eax,a.dword+4; mov edx,b.dword+4;
  sbb eax,edx; setb cl;
  mov eax,ecx*8+a.dword; mov edx,ecx*8+a.dword+4;
end;

// minint64 actually is identical in structure with maxint64

function _Min(const a, b: Int64): Int64; overload asm
  mov eax,a.dword; mov edx,b.dword;
  xor ecx,ecx; sub eax,edx;
  mov eax,a.dword+4; mov edx,b.dword+4;
  sbb eax,edx; setg cl;
  mov eax,ecx*8+a.dword; mov edx,ecx*8+a.dword+4;
end;

// maxint64 actually is identical in structure with minint64

function _Max(const a, b: Int64): Int64; overload asm
  mov eax,a.dword; mov edx,b.dword;
  xor ecx,ecx; sub eax,edx;
  mov eax,a.dword+4; mov edx,b.dword+4;
  sbb eax,edx; setl cl;
  mov eax,ecx*8+a.dword; mov edx,ecx*8+a.dword+4;
end;

//~~~~~~~~~~~~~~~~~~~~~~
// end minmax functions
//~~~~~~~~~~~~~~~~~~~~~~

procedure lol; asm end; //-)

//~~~~~~~~~~~~~~~~~~~~~~
// ROL/ROR
//~~~~~~~~~~~~~~~~~~~~~~

function rol(const I: integer): integer; overload asm rol I, 1 end;

function rol(const I: Int64): Int64; overload asm
    mov edx, I.r64.hi  // using register is faster than directly accessing memory
    mov eax, I.r64.lo // in Pentium they could also be run parallelized
    shl eax, 1; rcl edx, 1
    jnc @done; or eax, 1
  @done: //popfd
end;

function ror(const I: integer): integer; overload asm ror I, 1 end;

function ror(const I: Int64): Int64; overload asm
    mov edx, I.r64.hi  // using register is faster than directly accessing memory
    mov eax, I.r64.lo //  in Pentium they could also be run parallelized
    shr edx, 1; rcr eax, 1
    jnc @done; or edx, 1 shl 31
  @done: //popfd
end;

function rol(const I: Int64; const ShiftCount: integer): Int64; overload register asm
    mov ecx, ShiftCount // as Intel says, upon shift this value will be taken MODULO 32
    mov edx, I.r64.hi   // using register is faster than directly accessing memory
    mov eax, I.r64.lo   // in Pentium they could also be run parallelized
    and ecx, $3f; jz @exit
    cmp cl, 32; jb @begin
    //xchg eax, edx     // avoid LOCK prefixed xchg instruction
    mov eax, edx        // simple move should be faster & pairing enable
    mov edx, I.r64.lo //
    jz @exit
  @begin:
    push ebx; mov ebx, eax
    shld eax, edx, cl
    shld edx, ebx, cl
  @done: pop ebx
  @exit:
end;

function ror(const I: Int64; const ShiftCount: integer): Int64; overload register asm
    mov ecx, ShiftCount // as Intel says, upon shift this value will be taken MODULO 32
    mov edx, I.r64.hi  // using register is faster than directly accessing memory
    mov eax, I.r64.lo // in Pentium they could also be run parallelized
    and ecx, $3f; jz @exit
    cmp cl, 32; jb @begin
    //xchg eax, edx   // avoid LOCK prefixed xchg instruction
    mov eax, edx      // simple move should be faster & pairing enable
    mov edx, I.r64.lo //
    jz @exit
  @begin:
    push ebx; mov ebx, edx
    shrd edx, eax, cl
    shrd eax, ebx, cl
  @done: pop ebx
  @exit:
end;

function rol(const I: integer; const ShiftCount: integer): integer; overload register asm
  mov ecx, ShiftCount; rol I, cl
end;

function ror(const I: integer; const ShiftCount: integer): integer; overload register asm
  mov ecx, ShiftCount; ror I, cl
end;

procedure shld(var A: integer; const B: integer); overload register asm shld [A], B, 1 end;

procedure shld(var A: integer; const B: integer; const ShiftCount: byte); overload register asm
  //mov cl, ShiftCount
  cmp cl, 3fh; jbe @1
  mov dword[A], 0; jmp @end
@1: test cl, cl; jz @end
  cmp cl, 20h; jb @B
  mov [A], B; xor B, B
@B: shld [A], B, ShiftCount
  @end:
end;

procedure shld(var A: Int64; const B: Int64); overload register asm
// A in [eax]; B in stack (not in register);
  mov edx, A.r64.lo
  shld A.r64.hi, edx, 1
  mov ecx, B.r64.hi
  shl edx, 1
  or ecx, ecx; jns @end; or edx, 1
  @end: mov A.r64.lo, edx
end;

procedure shrd(var A: integer; const B: integer); overload register asm shrd [A], B, 1 end;

procedure shrd(var A: integer; const B: integer; const ShiftCount: byte); overload register asm
//mov cl, ShiftCount
  cmp cl, 3fh; jbe @1
  mov dword[A], 0; jmp @end
@1: test cl, cl; jz @end
  cmp cl, 20h; jb @B
  mov [A], B; xor B, B
@B: shrd [A], B, ShiftCount
  @end:
end;

procedure shrd(var A: Int64; const B: Int64); overload register asm
  // A in [eax]; B in stack (not in register);
  mov edx, A.r64.hi
  shrd A.r64.lo, edx, 1
  mov ecx, B.r64.lo
  shr edx, 1
  test ecx, 1; jz @end; or edx, 1 shl 31
  @end: mov A.r64.hi, edx
end;

procedure _shld(var A: Int64; const B: Int64; const ShiftCount: byte); overload register asm
  // A in [eax]; B in stack (not in register);
  mov cl, ShiftCount
  cmp cl, $3f; jbe @1
  xor edx, edx
  mov A.r64.hi, edx
  mov A.r64.lo, edx
  jmp @end
@1: test cl, cl; jz @end
  push ebx
  mov ebx, B.r64.hi
  mov edx, A.r64.lo
  cmp cl, 32; jb @A

  mov A.r64.hi, edx
  mov A.r64.lo, ebx
  jz @E //shift = 32
@2:
  mov edx, ebx  // edx := B.r64.hi
  mov ebx, B.r64.lo
@A:
  shld A.r64.hi, edx, cl
  shld edx, ebx, cl
  mov A.r64.lo, edx
@E: pop ebx
  @end:
end;

procedure _shrd(var A: Int64; const B: Int64; const ShiftCount: byte); overload register asm
  // A in [eax]; B in stack (not in register);
  mov cl, ShiftCount
  cmp cl, $3f; jbe @1
   xor edx, edx
   mov A.r64.hi, edx
   mov A.r64.lo, edx
   jmp @end
@1: test cl, cl; jz @end
  push ebx
  mov ebx, B.r64.lo
  mov edx, A.r64.hi
  cmp cl, 32; jb @A

  mov A.r64.lo, edx
  mov A.r64.hi, ebx
  jz @E //shift = 32
@2:
  mov edx, ebx  // edx := B.r64.lo
  mov ebx, B.r64.hi
@A:
  shrd A.r64.lo, edx, cl
  shrd edx, ebx, cl
  mov A.r64.hi, edx

@E: pop ebx
  @end:
end;

procedure shld(var A: Int64; const B: Int64; const ShiftCount: byte); overload //register;
begin
  if ShiftCount > 127 then
    A := 0
  else if ShiftCount > 63 then
    A := B shl (ShiftCount and 63)
  else
    _shld(A, B, ShiftCount);
end;

procedure shrd(var A: Int64; const B: Int64; const ShiftCount: byte); overload //register;
begin
  if ShiftCount > 127 then
    A := 0
  else if ShiftCount > 63 then
    A := B shr (ShiftCount and 63)
  else
    _shrd(A, B, ShiftCount);
end;
{
// check the highest bit was made because BSR may takes upto 72 clocks!
// this doesnt (always) have to be faster, but hey, at least i try :)
//function getBitsWide(const I: Int64; const preferredBitsWide: integer = 0): integer; assembler asm
//  mov ecx, preferredBitsWide
//  xor eax, eax; mov al, 64
//    test  I.r64.hi, -1; jnz @@check; shr al, 1   // 32
//  mov edx, I.r64.lo
//    test edx, 0ffff0000h; jnz @@check; shr al, 1 // 16
//    test edx, 0ff00h; jnz @@check; shr al, 1     // 8
//    test edx, 0f0h; jnz @@check; shr al, 1       // 4
//    test edx, 1100b; jnz @@check; shr al, 1      // 2
//    test edx, 10b; jnz @@check; shr al, 1        // 1
//  @@check: cmp ecx, eax; jl @@end
//  @@userSize: mov eax, ecx
//  @@end: //and eax, $ff
//end;
}

//get bits wide, use given preferred-count instead if it less
//(yep, this also comes with getmax function, remove after @@done if you dont need it)
function getBitsWide(const I: Int64; const preferredBitsWide: integer = 0): integer; assembler asm
// Int64 constant passed via stack, result in eax,
//mov eax,preferredBitsWide
  push 0; fild I; fstp dword ptr[esp]
  pop edx; sar edx,32-1-8; // get exponent
  lea edx,edx-$80+2; jg @@done; // just substract with 126 if positive
  add dl, $80+2-1; sbb edx,edx; // revert; +127; will be carry if it was originally zero
  xor edx,-2; and edx, 64 or 1; // -1 xor -2 = 1, otherwise force to 64
  @@done: xor ecx,ecx;      // get max.value
  sub eax,edx; adc ecx,-1;  // ecx = zero if eax > edx
  and eax,ecx; mov eax,edx; //
end;

function _bsr(const I: Int64): integer; assembler asm
// Int64 constant passed via stack, result in eax,
  push 0;
  fild I;
  fstp dword ptr[esp]
  pop edx;
  sar edx,32-1-8; // get exponent
  lea edx,edx-$80+2; // just substract with 126 if positive
  jg @@done;
  add dl,$80+2-1;
  sbb edx,edx; // revert; +127; will be carry if it was originally zero
  xor edx,-2;
  and edx,64 or 1; // -1 xor -2 = 1, otherwise force to 64
  @@done:
end;

// for P2 and above; bsr is fast enough
function getBitsWideP2(const I: Int64): integer; assembler asm
  bsr edx,edx; bsr eax,eax;
  // if edx = 0 then result := eax else Result := edx+32
  cmp edx,1; sbb ecx,ecx;
  add edx,32; and eax,ecx;
  not ecx; and edx,ecx
  or eax,edx
end;

function bitCount(const I: integer): integer; asm
  mov edx,eax; cmp eax,1;
  sbb eax,eax;
  @@Loop: add eax,1; //
    lea ecx,edx-1;   // no agi stall, since
    and ecx,edx;     // modifies ecx, forced to next pipeline
  jnz @@Loop;        // executed paralel with prev instruction
end;

function bitCount64(const I: int64): integer; asm
  mov edx,I.dword+4; cmp edx,1;
  sbb eax,eax;
  @@Loop1: add eax,1; lea ecx,edx-1; and ecx,edx; jnz @@Loop1;
  mov edx,I.dword+0; cmp edx,1;
  sbb eax,0;
  @@Loop2: add eax,1; lea ecx,edx-1; and ecx,edx; jnz @@Loop2;
end;

function bitCount2(const I: integer): integer;
asm
  mov edx,eax; shr eax,1;
  mov ecx,33333333h; and eax,55555555h
  sub edx,eax;

  mov eax,edx; shr edx,2
  and eax,ecx; and edx,ecx

  add eax,edx; mov edx,eax
  shr eax,4; mov ecx,01010101h
  and eax,0f0f0f0fh;
  add eax,edx; xor edx,edx
  mul ecx; shr eax,24
end;

function bitScantest(const I: int64): integer; //ordinals
// Int64 constant passed via stack, result in eax,
// return highest bit set in an int64 (sqrt power of 2);
// if the bit is one and only bit which is set, return positive value,
// else returns negative value of it's perfect power of 2 range, sub -1 for sign
// const dbg: integer = 0;
asm
//   inc dbg;
  push 1; pop eax; xor edx,edx;
  sub eax,I.r64.lo; sbb edx,I.r64.hi; jb @@begin
@@err: neg eax; jmp @@end
@@begin: push ebx; push 0; add esp,-8;
   fild qword ptr I; fstp tbyte ptr[esp];
   pop ecx; pop edx; pop eax
{
   // note: generic way to check whether hi-bit is set.
   // shift the block left; the block value then MUST be = 1
   // (the Least Significant Bit = 1, other bits = 0)
   // ie. decrementing the least dword and then keep or'ing
   // all dwords in block must eventually gives result of 0
   // only LSB and MSB need to be rolled, though
}
   xor ebx,ebx; //clc
   rcl edx,1; rcl ecx,1; // shift left the block
   rcl edx,1; adc ecx,0; // missed 3 workaround
   //cmp ax,1; sbb ecx,0;  // ecx should be: 1 to 0; invalidate if 0
   cmp ax,0C03Eh; sete bl; // overflow workaround
   add ax,8000h; sbb edx,0; // invalidate negative value
   and eax,$ff; dec ecx; // and ultimately decrement
   inc al; add edx,ebx; or ecx,edx;
   xor edx,edx; cmp edx,ecx; // set cary if ecx > 0
   sbb edx,edx; xor eax,edx // return neg if result is not of power of 2
   pop ebx
@@end:
end;

function __bsr64(I: int64): integer; asm
  mov eax,I.r64.lo; or eax,I.r64.hi;
  jz @@end
  fild I; fstp I;
  mov eax,I.r64.hi
  shr eax,4*5; sub eax,3ffh; //exponent/bias
@@end:
end;

function __bsf64(I: int64): integer; asm
  mov eax,I.r64.lo; mov edx,I.r64.hi;
  mov ecx,eax; or ecx,edx;
  jz @@end
  neg edx; neg eax; sbb edx,0
  and I.r64.lo,eax; and I.r64.hi,edx
  fild I; fstp I;
  mov eax,I.r64.hi;
  shr eax,4*5; sub eax,3ffh; //exponent/bias
@@end:
end;

function bitScanRev(const I: integer): integer; asm
  test eax,eax; jz @@end
  push 0; push eax
  fild qword ptr [esp]
  fstp qword ptr [esp]
  mov eax,[esp+4]
  lea esp,esp+8
  shr eax,4*5; sub eax,3ffh; //exponent/bias
@@end:
end;

function bitScanForward(const I: integer): integer; asm
  test eax,eax; jz @@end
  push 0; push eax
  neg eax; and [esp],eax
  fild qword ptr [esp]
  fstp qword ptr [esp]
  mov eax,[esp+4]
  lea esp,esp+8
  shr eax,4*5; sub eax,3ffh; //exponent/bias
@@end:
end;
{
// LStrClearAndSetLength - a simple routine to clear and allocate a new string.
// At last, after tired of calling the same sequence of System's routines.
// it should have been one of the routine i've made first. :(, better than never.
//function __LStrCLSet_D5(var S; const Length): string;//PChar; overload asm
////-------------------------------------------------------------------------------
//// update notes: 2006.00.00
//// not portable! this routine make use of internal Delphi5 mem-manager mechanism
//// not (always) work well on D7
////-------------------------------------------------------------------------------
//// * no register destroyed, result EAX points to the first char *
//     push ecx; push edx; push eax
//     mov edx, [eax]; test edx, edx; je @nil
//     mov dword[eax], 0; lea eax, [edx-8]
//     mov edx, dword[edx-8]; test edx, edx; jl @nil // neg refCount = constant string
//     nop // to avoid AGI-stall
//LOCK dec dword[eax]; jnz @nil  // dec refCount, (dont free if it still used by another S)
//     call System.@FreeMem      // this call zeroes eax, ecx & edx
//@nil: xor eax, eax
//     mov edx, [esp+4]
//     test edx, edx; jz @done
//     add edx, +4 +4 +1         // ask for more +9 = sizeof(refCnt + refLen + asciiz#0)
//     mov eax, [esp]
//     call System.@GetMem       // result in eax; ecx=eax
//     mov edx, [esp+4]
//     add eax, 8                // shift offset to the first char position
//     mov dword[eax-4], edx     // length of the string
//     mov dword[eax-8], 1       // put RefCount
//     mov byte[eax+edx], 0      // asciiz trailing#0
//@done: pop edx; mov [edx], eax // temp edx of original eax alias S
//     ;                         // put @S[1] alias PChar(S) there
//     //  mov eax, edx // turn it back to owner (or you may left it returning PChar(S)
//     // i think returning PChar will be more useful, we may forego since the var S now
//     // has been properly initialized; this way we dont have to dereference S furthermore
//     pop edx; pop ecx        //
//end;
}

function __LStrCLSet(var S; const Length): PChar; overload asm
// * preserve edx, ecx. result EAX points to the first char *
// this one is slower than above, but more portable (using system routines)
  push ecx; push edx; call System.@LStrClr
  mov edx,[esp]; call System.@LStrSetLength
  mov eax,[eax]; pop edx; pop ecx
end;

const
  Shiftable: set of byte = [1, 2, 4, 8, 16, 32, 64, 128];

procedure __CountSeparators(const eax; BufLen: integer; BlockLen: byte); assembler asm
  // Result in edx; ecx trimmed to byte
  and ecx, 0ffh; cmp ecx, BufLen; jg @tst // if BlockLen >= BufLen, BlockLen zeroed
  xor ecx, ecx
  @tst: test ecx, ecx; jnz @begin // if BlockLen 0; none any separator exists
  //cmovz edx, ecx
  xor edx, edx; ret
  @begin: lea BufLen, BufLen-1;
    // the formula for counting spaces-between is: Buflen-1 div BlockLen
    // (BufLen dec-by-1 to eliminate the overfluous space of modulo-0 result)
    jpe @_div // since 0 has been filtered out. in no way it might be an even-bit's byte
    cmp cl, 5; ja @_more; je @_div
    shr cl, 1; jmp @_count
  @_more: bt dword[Shiftable], ecx; jnc @_div; bsf ecx, ecx
  @_count: shr BufLen, cl; inc ch; shl ch, cl; shr ch, 8; ret
  @_div: push eax; mov eax, edx
     xor edx, edx; div ecx; pop eax; ret //; jmp @end
    //mov eax, BufLen; mov edx, PReciprocalInt
    //mul dword[edx+ecx*4]; jmp @end
  @end:
end;

function __LStrSetL_NOTUSED_NONPORTABLE(var S; const Length): PChar; assembler asm
  push ecx; push ebx; push esi
  mov ebx, eax; mov esi, Length
  mov eax, [ebx]
  sub eax, 8
  add Length, 9
  push eax
  mov eax, esp
  call System.@ReallocMem // <-- non portable
  pop eax
  add eax, 8
  mov [ebx], eax
  mov [eax-4], esi
  mov byte[eax+esi], 0
  pop esi; pop ebx; pop ecx
end;

function Reverse(const S: string): string; assembler asm
    test S, S; jg @@Start; ret
  @@Start: push esi; push edi
    mov esi, S; mov eax, @Result

    call System.@LStrClr
    mov edx, [esi-4]; push edx
    call System.@LStrSetLength
    mov ecx, [esp]; mov edi, [eax]
    lea edi, edi+ecx-4
    shr ecx, 2; jz @small
  @Loop:
    mov eax, [esi]; bswap eax; lea esi, esi+4
    mov dword[edi], eax; lea edi, edi-4
    dec ecx; jg @loop
  @small: pop ecx; and ecx, 3
    lea edi, edi+4; jz @done
  @loop2: dec edi
   mov al, byte[esi]; inc esi
   mov byte[edi], al
   dec ecx; jg @loop2

  @done: mov eax, edi

  @end: pop edi; pop esi
  @@Stop:
end;

{
  CountSpaceNeeded algorithm:
  ---------------------------
  note that all options, are quite interdependent with each other,
  thus they are eventuallly will be all tested.

  special cases:
    if delimiter = #0 then output format is undelimited (no separator)
    if blockLen < 1 blockLen will be set to 1 if Delimiter <> #0,
      otherwise for xsBlockWise BlockLen will be set equal with BufLen
      (which also means undelimited)
    if blockLen > bufLen then blockLen will be set equal with bufLen
      (which also means undelimited)

  known:
    BufLen (static)
    BlockLen (modifiable)

  calculated:
    calc: SeparatorCount = (BufLen-1) div BlockLen
    calc: BlockCount = SeparatorCount +1

  calculation procedure
    case xsBlockWise:
      BufLen = ? (static)
      BlockLen = ? (modifiable)
      SeparatorCount = ? (calculate)
      BlockCount = ? (calculate)
      calc: BlockSize = BlockLen * 2
      calc: BlockSpaceNeeded = BlockCount * BlockSize
      calc: SpaceNeeded = BlockSpaceNeeded + SeparatorCount
    esac
    case not xsBlockWise:
      BufLen = ? (static)
      SeparatorCount = ? (calculate)
      calc: SpaceNeeded = BufLen * 2 + SeparatorCount
    esac
  end calculation procedure

  special case1:
    if BLockLen < 1 then
       case xsBlockWise:
         if Delimiter = #0 then
           forced: BlockLen = BufLen
           forced: BlockCount = 1;
           SeparatorCount = 0
         -> SpaceNeeded = 1 * BufLen * 2 + SeparatorCount
         else
           forced: BlockLen = 1
           forced: BlockCount = BufLen;
           SeparatorCount = BufLen - 1
         -> SpaceNeeded = BufLen * 1 * 2 + SeparatorCount
         fi
       esac
       case not xsBlockWise:
         forced: BlockLen = 1
         if Delimiter = #0 then
           SeparatorCount = 0
         else
           SeparatorCount = BufLen -1
         fi
         -> SpaceNeeded = BufLen * 2 + SeparatorCount
       esac
       calc: SpaceNeeded = BufLen * 2 + SeparatorCount
       exit
    fi

  special case2:
    if Delimiter == #0 then
      forced: SeparatorCount = 0
      case BlockWise:
        BlockCount = ?
        BlockSize = BlockLen * 2
        calc: BlockSpaceNeeded = BlockCount * BlockSize
        calc: SpaceNeeded = BlockCount * BlockSize + 0
      esac
      case not xsBlockWise:
        -> SpaceNeeded = BufLen * 2 + 0;
        calc: SpaceNeeded = Buflen * 2
        exit
      esac
    fi
}

procedure __CountSpaceNeeded;
asm
{
  usage:
    calculates the spaces needed by specified
    BufLen, hexStyles and Delimiter

  see also: CountSpaceNeeded algorithm above

  input:
    -> bl: Delimiter bh: HexStyles {xsBlockWise)
    -> edx: BufLen
    -> ecx: BlockLen

  ouput:
    <- ecx: Validated BlockLen
    <- edx: Count Space Needed
    <- edi: Buflen (original value of edx)
    <- eax: separators count
            (valid only if Delimiter <> #0)
    <- bl=0: modified only if BlockLen forced
             to be equal with BufLen

  registers modified: eax, edx, ecx, edi, bl
}

  mov edi, edx; lea eax,edx-1; shl edx,1
  cmp ecx,edi; jb @tst1; mov ecx,edi; mov bl, 0; jmp @LSetDone

  @tst1: cmp ecx, 1; jg @tst_dlm; je @_adl
    xor ecx, ecx; inc cl //; jmp @_adl
    test bl, bl; jnz @_adx
    test bh, 1 shl xsBlockWise; jz @LSetDone
    mov ecx,edi; jmp @LSetDone

  @tst_dlm: test bl, bl; jnz @SetLn
  test bh, 1 shl xsBlockWise; jz @LSetDone

  @SetLn:
    cmp ecx, 80h; je @_shift; ja @_div; jnp @_div
    cmp ecx, 1 shl 2 +1; je @_div; ja @_shift
    push ecx; shr ecx, 1; jnz @_count
  @LSet2p: pop ecx; jmp @_adx

  @_shift: bt dword[Shiftable], ecx; jnc @_div
  @_shiftable: push ecx; bsf ecx, ecx
  @_count: shr eax, cl
    test bh, 1 shl xsBlockWise; jz @LSet2p
    lea edx, eax+1;
    shl edx, cl; shl edx, 1
    pop ecx; jmp @_adl

  @_div: xor edx, edx; div ecx // eax = mid-separators count
    test bh, 1 shl xsBlockWise; jnz @_dm
      lea edx, edi*2+eax; jmp @LSetDone
  @_dm: push eax
    inc eax                   // block count
    lea edx, [ecx*2]          // block size (blocklen*2 //+1space)
    mul edx; mov edx, eax; pop eax
  @_adl: test bl, bl; jz @LSetDone
  @_adx: add edx, eax; jmp @LSetDone
  @LSetDone:
end;

function hexs_countspace(const Buffer; const BufLen: integer; const BlockLen: integer;
const Delimiter: char; const HexStyles: THexStyles): integer; overload asm
  @Start: test Buffer, Buffer; jz @Stop
  test BufLen, -1; jg @begin
  @e:xor eax, eax; jmp @Stop
  //@begin: pushad; pushad //AX=28; DX=24; CX=20; BX=16; SP=12; BP=8; SI=4; DI=0
  @begin: push esi; push edi; push ebx
  xor ebx, ebx; mov bl, Delimiter; mov bh, HexStyles
  mov esi, Buffer; //mov edi, BufLen
  call __CountSpaceNeeded
  mov eax,edx
  @end: pop ebx; pop edi; pop esi
  @Stop:
end;

const
  TABLE_HEXDIGITS: packed array[0..31] of char = '0123456789ABCDEF0123456789abcdef';

function tablehex: pchar;
asm
  lea eax,table_hexdigits
end;
{ not-used:
//  // interprets buffer as one big hex number (read from last byte as in big endian mode)
//  // this is option xsReversed in THexStyle, (note that the default option is not Reversed)
//  // not directly used/implemented. used as a building block for hexs_n.
//  // see also: hexs_b & hexn
//  function hexs_n(const Buffer: pointer = nil; const BufLen: integer = 0;
//  const Lowercase: boolean = FALSE): string; asm
//    test Buffer, Buffer; jz @Stop
//    test BufLen, -1; jg @begin
//    xor eax, eax; jmp @Stop;
//    @begin: push esi; push edi; push ebx
//      mov esi, Buffer; xor ebx, ebx
//      mov bl, LowerCase; and bl,1; shl bl, 4
//      lea ebx, ebx+TABLE_HEXDIGITS
//      lea ecx, edx-1; shl edx, 1
//      mov eax, Result; call __LStrCLSet
//      mov edi, eax
//      xor eax, eax; xor edx, edx
//    @Loop:
//      mov al, esi+ecx; mov dl, al
//      and dl,0fh; mov dl, ebx+edx
//      shr al,04h; mov al, ebx+eax
//      mov [edi], al; mov [edi+1], dl
//      lea edi, edi+2;
//    dec ecx; jge @Loop // difference with hexs_b
//    @end: pop ebx; pop edi; pop esi
//    @Stop:
//  end;
//
//  // interprets buffer as one big hex number (read from last byte as in big endian mode)
//  // this is option xsReversed in THexStyle, (note that the default option is not Reversed)
//  // not directly used/implemented. used as a building block for hexs_n.
//  // see also: hexs_b & hexn
//  function hexs_nswap(const Buffer: pointer = nil; const BufLen: integer = 0;
//  const Lowercase: boolean = FALSE): string; asm
//    test Buffer, Buffer; jz @Stop
//    test BufLen, -1; jg @begin
//    xor eax, eax; jmp @Stop;
//    @begin: push esi; push edi; push ebx
//      mov esi, Buffer; xor ebx, ebx
//      mov bl, LowerCase; and bl,1; shl bl, 4
//      lea ebx, ebx+TABLE_HEXDIGITS
//      lea ecx, edx-1; shl edx, 1
//      mov eax, Result; call __LStrCLSet
//      mov edi, eax
//      xor eax, eax; xor edx, edx
//    @Loop:
//      mov al, esi+ecx; mov dl, al
//      and dl,0fh; mov dl, ebx+edx
//      shr al,04h; mov al, ebx+eax
//      mov [edi], dl; mov [edi+1], al // the only difference with noswap
//      lea edi, edi+2;
//    dec ecx; jge @Loop // difference with hexs_b
//    @end: pop ebx; pop edi; pop esi
//    @Stop:
//  end;
//
//  // read and interprets buffer byte-per-byte (read from the first byte).
//  // this is the default mode in THexStyles (xsReversed = FALSE)
//  // not directly used/implemented. used as a building block for hexs_b.
//  // see also: hexs_n & hexb
//  function hexs_b(const Buffer: pointer = nil; const BufLen: integer = 0;
//  const Lowercase: boolean = FALSE): string; asm
//    test Buffer, Buffer; jz @Stop
//    test BufLen, -1; jg @begin
//    xor eax, eax; jmp @Stop;
//    @begin: push esi; push edi; push ebx
//      mov esi, Buffer; xor ebx, ebx
//      mov bl, LowerCase; and bl,1; shl bl, 4
//      lea ebx, ebx+TABLE_HEXDIGITS
//      lea ecx, edx-1; shl edx, 1
//      mov eax, Result; call __LStrCLSet
//      mov edi, eax
//      xor eax, eax; xor edx, edx
//      lea esi, esi+ecx; neg ecx // different with hexs_n
//    @Loop:
//      mov al,esi+ecx; mov dl, al
//      and dl,0fh; mov dl, ebx+edx
//      shr al,04h; mov al, ebx+eax
//      mov [edi], al; mov [edi+1], dl //different with Swap
//      lea edi, edi+2;
//      inc ecx; jle @Loop // different with hexs_n
//    @end: pop ebx; pop edi; pop esi
//    @Stop:
//  end;
//
//  // read and interprets buffer byte-per-byte (read from the first byte).
//  // this is the default mode in THexStyles (xsReversed = FALSE)
//  // not directly used/implemented. used as a building block for hexs_b.
//  // see also: hexs_n & hexb
//  function hexs_bswap(const Buffer: pointer = nil; const BufLen: integer = 0;
//  const Lowercase: boolean = FALSE): string; asm
//    test Buffer, Buffer; jz @Stop
//    test BufLen, -1; jg @begin
//    xor eax, eax; jmp @Stop;
//    @begin: push esi; push edi; push ebx
//      mov esi, Buffer; xor ebx, ebx
//      mov bl, LowerCase; and bl,1; shl bl, 4
//      lea ebx, ebx+TABLE_HEXDIGITS
//      lea ecx, edx-1; shl edx, 1
//      mov eax, Result; call __LStrCLSet
//      mov edi, eax
//      xor eax, eax; xor edx, edx
//      lea esi, esi+ecx; neg ecx // different with hexs_n
//    @Loop:
//      mov al,esi+ecx; mov dl, al
//      and dl,0fh; mov dl, ebx+edx
//      shr al,04h; mov al, ebx+eax
//      mov [edi], dl; mov [edi+1], al //the only difference with noswap
//      lea edi, edi+2;
//      inc ecx; jle @Loop // different with hexs_n
//    @end: pop ebx; pop edi; pop esi
//    @Stop:
//  end;
}

{
// primitive. for higher conversion level, use hexs instead;
// hexb (along with hexn) provides a building block for _hexa conversion.
// supported THexStyle options are: xsLowerCase & xsSwapByte (other options are ignored)
}

function hexb(const Buffer; const BufLen: integer = 0;
  const HexStyles: THexStyles = []; const Delimiter: char = #0): string;
asm
  test Buffer, Buffer; jz @Stop; test BufLen, -1; jg @begin
  xor eax, eax; jmp @Stop;
  @begin: push esi; push edi; push ebx
    mov esi, Buffer; xor ebx, ebx
    movzx eax, HexStyles; mov ah, Delimiter; push eax
    test al, 1 shl xsLowerCase; setnz bl; shl bl, 4
    lea ebx, ebx+TABLE_HEXDIGITS
    lea ecx, edx-1; lea edx, [edx*2]
    test ah, ah; jz @LSet; add edx, ecx
    @LSet: mov eax, Result; call __LStrCLSet
    mov edi, eax; pop eax; xor edx, edx
     lea esi, esi+ecx; neg ecx
     test al, 1 shl xsSwapByte; jnz @Swapped
  @NoSwap: test ah, ah; jnz @nsLoopD; xor eax, eax
   @nsLoop:
    mov al, [esi+ecx]; mov dl, al
    and dl,0fh; mov dl, ebx+edx
    shr al,04h; mov al, ebx+eax
    mov [edi], al; mov [edi+1], dl  // the only difference with Swap :)
    lea edi, edi+2;
    inc ecx; jle @nsLoop; jmp @done
   @nsLoopD:
    mov dl, [esi+ecx]; shr dl,04h; mov al, ebx+edx
    mov dl, [esi+ecx]; and dl,0fh; mov dl, ebx+edx
    mov [edi], al; mov [edi+1], dl; mov [edi+2], ah // the only difference with noSwap :)
    lea edi, edi+3;
    inc ecx; jle @nsLoopD
    mov byte[edi-1],0; jmp @done
  @Swapped: test ah, ah; jnz @swLoopD; xor eax, eax
   @swLoop:
    mov al, [esi+ecx]; mov dl, al
    and dl,0fh; mov dl, ebx+edx
    shr al,04h; mov al, ebx+eax
    mov [edi], dl; mov [edi+1], al // the only difference with noSwap :)
    lea edi, edi+2;
    inc ecx; jle @swLoop; jmp @done
   @swLoopD:
    mov dl, [esi+ecx]; shr dl,04h; mov al, ebx+edx
    mov dl, [esi+ecx]; and dl,0fh; mov dl, ebx+edx
    mov [edi], dl; mov [edi+1], al; mov [edi+2], ah // the only difference with NoSwap :)
    lea edi, edi+3;
    inc ecx; jle @swLoopD
    mov byte[edi-1],0; jmp @done
  @done:
  @end: pop ebx; pop edi; pop esi
  @Stop:
end;
{
// primitive. for higher conversion level, use hexs instead;
// hexn (along with hexb) provides a building block for _hexa conversion.
// supported THexStyle options are: xsLowerCase & xsSwapByte (other options are ignored)
}

function hexn(const Buffer; const BufLen: integer = 0;
  const HexStyles: THexStyles = []; const Delimiter: char = #0): string;
asm
  test Buffer, Buffer; jz @Stop
  test BufLen, -1; jg @begin
  xor eax, eax; jmp @Stop;
   @begin: push esi; push edi; push ebx
    mov esi, Buffer; xor ebx, ebx
    movzx eax, HexStyles; mov ah, Delimiter; push eax
    test al, 1 shl xsLowerCase; setnz bl; shl bl, 4
    lea ebx, ebx+TABLE_HEXDIGITS
    lea ecx, edx-1; lea edx, [edx*2]
    test ah, ah; jz @LSet; add edx, ecx
    @LSet: mov eax, Result; call __LStrCLSet
    mov edi,eax; pop eax; xor edx, edx
     //lea esi, esi+ecx; neg ecx
     test al, 1 shl xsSwapByte; jnz @Swapped
   @NoSwap: test ah, ah; jnz @nsLoopD;
   xor eax, eax
   @nsLoop:
    mov al, [esi+ecx]; mov dl, al
    and dl,0fh; mov dl, ebx+edx
    shr al,04h; mov al, ebx+eax
    mov [edi], al; mov [edi+1], dl
    lea edi, edi+2;
  dec ecx; jge @nsLoop; jmp @done
   @nsLoopD:
    mov dl, [esi+ecx]; shr dl,04h; mov al, ebx+edx
    mov dl, [esi+ecx]; and dl,0fh; mov dl, ebx+edx
    mov [edi], al; mov [edi+1], dl; mov [edi+2], ah
    lea edi, edi+3;
  dec ecx; jge @nsLoopD
  mov byte[edi-1],0; jmp @done
   @Swapped: test ah, ah; jnz @swLoopD;
   xor eax, eax
   @swLoop:
    mov al, [esi+ecx]; mov dl, al
    and dl,0fh; mov dl, ebx+edx
    shr al,04h; mov al, ebx+eax
    mov [edi], dl; mov [edi+1], al // the only difference with noSwap :)
    lea edi, edi+2;
  dec ecx; jge @swLoop; jmp @done
   @swLoopD:
    mov dl, [esi+ecx]; shr dl,04h; mov al, ebx+edx
    mov dl, [esi+ecx]; and dl,0fh; mov dl, ebx+edx
    mov [edi], dl; mov [edi+1], al; mov [edi+2], ah // the only difference with NoSwap :)
    lea edi, edi+3;
  dec ecx; jge @swLoopD
  mov byte[edi-1],0; jmp @done
   @done:
   @end: pop ebx; pop edi; pop esi
  @Stop:
end;
{
// INC ECX = 41h  JGE = 7Dh  JG = 7Fh
// DEC ECX = 49h  JLE = 7Eh  JL = 7Ch

// hexs contains all of the functionalities of hexn and hexb
// plus option to switch between those two modes;
// implemented features (THexStyle options): xsLowerCase, xsSwapByte & xsReverse
}

function hexs(const Buffer; const BufLen: integer; const HexStyles: THexStyles;
  const Delimiter: char): string; overload;
asm
  test Buffer, Buffer; jz @Stop
  test BufLen, -1; jg @begin
  xor eax, eax; jmp @Stop

  @begin: push esi; push edi; push ebx
    mov esi, Buffer; xor ebx, ebx
    movzx eax, Delimiter; mov ah, HexStyles; push eax

    test ah, 1 shl xsLowerCase; setnz bl; shl bl, 4
    lea ebx, ebx+TABLE_HEXDIGITS
    lea ecx, edx-1; shl edx, 1
    test al, al; jz @SetLength
    add edx, ecx

    @SetLength: mov eax, Result; call __LStrCLSet
    mov edi, eax; mov ebp, ecx

    pop ecx; test ch, 1 shl xsReverse; jnz @prepare

      lea esi, esi+ebp; neg ebp

    @prepare: xor eax, eax; xor edx, edx

    @Loop:
      mov al, [esi+ebp]; mov dl, al
      and dl, 0fh; mov dl, ebx+edx
      shr al, 04h; mov al, ebx+eax

      test ch, 1 shl xsSwapByte; jz @nos

      @swp: mov [edi], dl; mov [edi+1], al; jmp @1_ // swap byte/nibble
      @nos: mov [edi], al; mov [edi+1], dl; jmp @1_ // no-swap

      @1_: test cl, cl; jz @2_
        mov [edi+2], cl; lea edi, edi+1
      @2_: lea edi, edi+2

      //test ebp, ebp; jz @done; jl @inc // not a "branch-prediction friendly"
      test ch, 1 shl xsReverse; jz @inc  // reverse means last to first <contrawise> dump Buffer

    @dec: dec ebp; jge @Loop; jmp @Lastb // reverse
    @inc: inc ebp; jle @loop; jmp @Lastb // dump

    @Lastb: test cl, cl; jz @Done
    ; mov byte[edi-1], 0

  @Done:

  @end: pop ebx; pop edi; pop esi
  @Stop:
end;
{ not-used:
//  // hexs contains all of the functionalities of hexn and hexb plus option to switch
//  // between those two modes; makes supported features: xsLowerCase, xsSwapByte & xsReverse
//  function _hexa(const Buffer: pointer; const BufLen: integer; const HexStyles: THexStyles;
//  const Delimiter: char): string; overload; asm
//    test Buffer, Buffer; jz @Stop
//    test BufLen, -1; jg @begin
//    xor eax, eax; jmp @Stop;
//
//    @begin: push esi; push edi; push ebx
//      mov esi, Buffer; xor ebx, ebx
//      movzx eax, HexStyles; mov ah, Delimiter; push eax
//      test al, 1 shl xsLowerCase; setnz bl; shl bl, 4
//      lea ebx, ebx+TABLE_HEXDIGITS
//      lea ecx, edx-1; lea edx, edx*2
//      test ah, ah; jz @LSet; add edx, ecx
//      @LSet: mov eax, Result; call __LStrCLSet
//      mov edi, eax; pop eax; xor edx, edx
//
//      test al, 1 shl xsReverse jnz @Reversed
//
//      lea esi, esi+ecx; neg ecx
//
//      test al, 1 shl xsSwapByte; jnz @Swapped
//    @NoSwap: test ah, ah; jnz @nsLoopD; xor eax, eax
//      @nsLoop:
//        mov al, [esi+ecx]; mov dl, al
//        and dl,0fh; mov dl, ebx+edx
//        shr al,04h; mov al, ebx+eax
//        mov [edi], al; mov [edi+1], dl
//        lea edi, edi+2;
//      inc ecx; jle @nsLoop; jmp @done // the only difference with reversed Direction
//
//      @nsLoopD:
//        mov dl, [esi+ecx]; shr dl,04h; mov al, ebx+edx
//        mov dl, [esi+ecx]; and dl,0fh; mov dl, ebx+edx
//        mov [edi], al; mov [edi+1], dl; mov [edi+2], ah
//        lea edi, edi+3;
//      inc ecx; jle @nsLoopD // the only difference with reversed Direction
//      mov byte[edi-1],0; jmp @done
//
//    @Swapped: test ah, ah; jnz @swLoopD; xor eax, eax
//
//      @swLoop:
//        mov al, [esi+ecx]; mov dl, al
//        and dl,0fh; mov dl, ebx+edx
//        shr al,04h; mov al, ebx+eax
//        mov [edi], dl; mov [edi+1], al // the only difference with noSwap :)
//        lea edi, edi+2;
//      inc ecx; jle @swLoop; jmp @done // the only difference with reversed Direction
//
//      @swLoopD:
//        mov dl, [esi+ecx]; shr dl,04h; mov al, ebx+edx
//        mov dl, [esi+ecx]; and dl,0fh; mov dl, ebx+edx
//        mov [edi], dl; mov [edi+1], al; mov [edi+2], ah // the only difference with NoSwap :)
//        lea edi, edi+3;
//      inc ecx; jle @swLoopD
//      mov byte[edi-1],0; jmp @done
//
//    @Reversed: test al, 1 shl xsSwapByte; jnz @rSwapped
//
//    @rNoSwap: test ah, ah; jnz @rnsLoopD; xor eax, eax
//
//      @rnsLoop:
//        mov al, [esi+ecx]; mov dl, al
//        and dl,0fh; mov dl, ebx+edx
//        shr al,04h; mov al, ebx+eax
//        mov [edi], al; mov [edi+1], dl
//        lea edi, edi+2;
//      dec ecx; jge @rnsLoop; jmp @rdone // the only difference with non-reversed Direction
//
//      @rnsLoopD:
//        mov dl, [esi+ecx]; shr dl,04h; mov al, ebx+edx
//        mov dl, [esi+ecx]; and dl,0fh; mov dl, ebx+edx
//        mov [edi], al; mov [edi+1], dl; mov [edi+2], ah
//        lea edi, edi+3;
//      dec ecx; jge @rnsLoopD // the only difference with non-reversed Direction
//      mov byte[edi-1],0; jmp @rdone
//
//    @rSwapped: test ah, ah; jnz @rswLoopD; xor eax, eax
//
//      @rswLoop:
//        mov al, [esi+ecx]; mov dl, al
//        and dl,0fh; mov dl, ebx+edx
//        shr al,04h; mov al, ebx+eax
//        mov [edi], dl; mov [edi+1], al // the only difference with noSwap :)
//        lea edi, edi+2;
//      dec ecx; jge @rswLoop; jmp @rdone // the only difference with non-reversed Direction
//
//      @rswLoopD:
//        mov dl, [esi+ecx]; shr dl,04h; mov al, ebx+edx
//        mov dl, [esi+ecx]; and dl,0fh; mov dl, ebx+edx
//        mov [edi], dl; mov [edi+1], al; mov [edi+2], ah // the only difference with NoSwap :)
//        lea edi, edi+3;
//      dec ecx; jge @rswLoopD // the only difference with non-reversed Direction
//      mov byte[edi-1],0; jmp @rdone
//
//    @done:
//    @rdone:
//
//    @end: pop ebx; pop edi; pop esi
//    @Stop:
//  end;
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Blocks. Moved in from ACommon unit
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Blocks(const S: string; const delimiter: string = SPACE; const BlockLen: integer = 4;
  const LeftWise: Boolean = FALSE; //const Interval: integer = 1;
  const SkipPrefixLength: integer = 0; const SkipSuffixLength: integer = 0): string; overload;
const
  MINBLOCKLEN: integer = 1;
var
  i, j, k, l, r: integer;
  prefix, suffix: string;
begin
  l := length(S);
  k := SkipPrefixLength + SkipSuffixLength;
  if (delimiter = '') or (l <= 1) or (SkipPrefixLength < 0) or
    (SkipSuffixLength < 0) or (l - k <= 1) then
    Result := S
  else begin
    if SkipPrefixLength > 0 then
      prefix := copy(S, 1, SkipPrefixLength);
    if SkipSuffixLength > 0 then
      //suffix := copy(S, l - k + 1, SkipSuffixLength); // bug!
      suffix := copy(S, l - SkipSuffixLength + 1, SkipSuffixLength);
    Result := copy(S, SkipPrefixLength + 1, l - k);
    j := _Max(word(BlockLen), MINBLOCKLEN); // max.65535

    l := length(Result);
    i := l div j;
    if (l mod j = 0) then
      dec(i);

    if LeftWise then
      for r := i downto 1 do
        insert(delimiter, Result, (r * j) + 1)
    else begin
      for r := i downto 1 do
        insert(delimiter, Result, length(Result) - (r * j) + 1);
    end;

    if SkipPrefixLength > 0 then Result := prefix + Result;
    if SkipSuffixLength > 0 then Result := Result + suffix;
  end;
end;

function Blocks(const I: integer; const delimiter: string = SPACE; const BlockLen: integer = 4;
  const LeftWise: Boolean = FALSE; //const Interval: integer = 1;
  const SkipPrefixLength: integer = 0; const SkipSuffixLength: integer = 0): string; overload;
begin
  Result := blocks(IntoStr(I), delimiter, BlockLen, LeftWise, SkipPrefixLength, SkipSuffixLength);
end;

function Blocks(const I: int64; const delimiter: string = SPACE; const BlockLen: integer = 4;
  const LeftWise: Boolean = FALSE; //const Interval: integer = 1;
  const SkipPrefixLength: integer = 0; const SkipSuffixLength: integer = 0): string; overload;
begin
  Result := blocks(IntoStr(I), delimiter, BlockLen, LeftWise, SkipPrefixLength, SkipSuffixLength);
end;

function Blocks(const S: string; const BlockLen: integer; const delimiter: string = SPACE;
  const LeftWise: Boolean = FALSE; //const Interval: integer = 1;
  const SkipPrefixLength: integer = 0; const SkipSuffixLength: integer = 0): string; overload;
begin
  Result := blocks(S, delimiter, BlockLen, LeftWise, SkipPrefixLength, SkipSuffixLength);
end;

function Blocks(const I: integer; const BlockLen: integer; const delimiter: string = SPACE;
  const LeftWise: Boolean = FALSE; //const Interval: integer = 1;
  const SkipPrefixLength: integer = 0; const SkipSuffixLength: integer = 0): string; overload;
begin
  Result := blocks(IntoStr(I), delimiter, BlockLen, LeftWise, SkipPrefixLength, SkipSuffixLength);
end;

const
  //zero = CHAR_ZERO; //'0'; //
  //dash = CHAR_DASH; //'-'; //
  zero = '0';
  dash = '-';

function IntToStr_JOH_IA32_4(Value: integer): string; forward;
function IntToStr64_JOH_IA32_4(Value: Int64): string; forward;

function intoStr(const I: integer; const Digits: integer = 0; const LeadingZero: char = '0'): string; overload;
var
  n: integer;
begin
  Result := IntToStr64_JOH_IA32_4(I);
  n := length(Result);
  if digits > n then begin
    if I >= 0 then
      //Result := StringOfchar(zero, digits - n) + Result
      Result := StringOfchar(LeadingZero, digits - n) + Result
    else
      //Result := dash + StringOfChar(zero, digits - n) + Copy(Result, 2, n);
      Result := dash + StringOfChar(LeadingZero, digits - n) + Copy(Result, 2, n);
  end;
end;

function _intoStr64(const I: Int64; const Digits: integer = 0; const LeadingZero: char = '0'): string; overload;
var
  n: integer;
begin
  //Str(I: 0, Result); // replaced by fastcode
  Result := IntToStr64_JOH_IA32_4(I);
  n := length(Result);
  if digits > n then begin
    if I >= 0 then
      //Result := StringOfchar(zero, digits - n) + Result
      Result := StringOfchar(LeadingZero, digits - n) + Result
    else
      //Result := dash + StringOfChar(zero, digits - n) + Copy(Result, 2, n);
      Result := dash + StringOfChar(LeadingZero, digits - n) + Copy(Result, 2, n);
  end;
end;

function intoStr(const I: Int64; const Digits: integer = 0; const LeadingZero: char = '0'): string; overload; asm
// Int64 constant passed via stack, here eax = Digits and edx = @Result
// note: cardinal type WILL BE treated as Int64, since (high cardinal) > (high integer)
// to overcome this either cast argument to integer, or specify width explicitly
  push ebx
    mov ebx,dword[I.r64.hi]
    test ebx,ebx; jz @testCard0 // MSB = 0, test for cardinality
    cmp ebx,-1; jne @I64 // if MSB = -1, test for sign-extended
  @testSignex:
    mov ebx, dword[I.r64.lo]
    test ebx,ebx; js @I32  // if LSB also negative, call faster I32 instead
    jmp @I64
  @testCard0:
    mov ebx,dword[I.r64.lo]
    test ebx,ebx; jns @I32 // if LSB positive, call faster I32 instead
    //jmp @I64
  @I64:
    PUSH dword[I.r64.hi]; PUSH dword[I.r64.lo]
    call _intoStr64
    jmp @end
  @I32:
    push Result
    movzx ecx, LeadingZero
    mov edx, Digits
    mov eax, dword[I.r64.lo]
    call intoStr
  @end:
  pop ebx
end;

function uIntOf_f(const S: string): int64;
const
  decimals: packed array[0..10] of single =
  (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
asm
  xor edx,edx; test S,S; jz @@Stop
@@begin://pushad
  push esi; mov esi,eax; xor eax,eax;
  push edi; push ebx; mov edi,esi-4;
  cmp edi,20; ja @@err; xor ebx,ebx;
  @@L1:
    mov bl,[esi]; inc esi;
    test bl,bl; jz @@done
    lea eax,eax*4+eax;
    sub bl,'0'; shl eax,1;
    cmp bl,9; ja @@err
    add eax,ebx
    cmp eax,1999999Ah; jb @@L1

  push edx; push eax;

@@cw_store:
  push 0;
  fnstcw word ptr[esp]; //save fpu control word
  pop bx;
  mov word ptr[esp],bx; // get and resave
  or bh, 1111b;         //set rounding = integer, precision = 64bit
  push bx;
  fldcw word ptr[esp];  // get new control word

  xor ebx,ebx
  fld dword ptr decimals+4*10
  fild qword ptr esp+4

  @@L2:
    mov bl,[esi]; inc esi;
    test bl,bl; jz @@done2
    sub bl,'0';
    cmp bl,9; ja @@err
    fmul dword ptr decimals+ebx
    fadd dword ptr decimals+ebx
    jmp @@L2

@@done2: fnstsw ax; sahf

@@cw_recall:
  fldcw [esp+2];
  pop ebx;              //restore control word
  //mov ecx,eax; mov edi,edx;
  //shl eax,1; rcl edx,1;
  //shl eax,1; rcl edx,1;
  //add eax,ecx; adc edx,edi;
  //shl eax,1; rcl edx,1;
  //add eax,ebx; adc edx,0; ja @@L2//jb @@err
@@err: mov eax,reRangeError; call SysError //call System.error;
@@done: pop ebx; pop edi; pop esi
@@Stop:;
end;

function uIntOf(const S: string): uInt64;
asm
  xor edx,edx; test S,S; jz @@Stop
@@begin://pushad
  push esi; mov esi,eax; xor eax,eax;
  push edi; push ebx; mov edi,esi-4;
  cmp edi,20; ja @@err; xor ebx,ebx;
  @@L1:
    mov bl,[esi]; inc esi;
    test bl,bl; jz @@done
    lea eax,eax*4+eax;
    sub bl,'0'; shl eax,1;
    cmp bl,9; ja @@err
    add eax,ebx
    cmp eax,1999999Ah; jb @@L1
  @@L2:
    mov bl,[esi]; inc esi;
    test bl,bl; jz @@done
    sub bl,'0';
    cmp bl,9; ja @@err
    mov ecx,eax; mov edi,edx;
    //shl eax,1; rcl edx,1;
    //shl eax,1; rcl edx,1;
    shld edx,eax,2; shl eax,2
    add eax,ecx; adc edx,edi;
    shl eax,1; rcl edx,1;
    add eax,ebx; adc edx,0; ja @@L2//jb @@err
@@err: mov eax,reRangeError; call SysError //call System.error;
@@done: pop ebx; pop edi; pop esi
@@Stop:;
end;

function IntOf(const S: string; const DefaultValue: integer = 0): integer; // lightweight version
var
  e: integer;
begin
  val(S, Result, e);
  if e <> 0 then Result := DefaultValue;
end;

function Int64Of(const S: string; const DefaultValue: int64 = 0): int64; // lightweight version
var
  e: integer;
begin
  val(S, Result, e);
  if e <> 0 then Result := DefaultValue;
end;

function IntOfF(const S: string; const DefaultValue: integer = 0): integer; // lightweight version
var
  d: double;
  e: integer;
begin
  val(S, d, e);
  if e <> 0 then
    Result := DefaultValue
  else
    Result := trunc(d)
end;

function Int64OfF(const S: string; const DefaultValue: integer = 0): Int64; // lightweight version
var
  d: double;
  e: integer;
begin
  val(S, d, e);
  if e <> 0 then
    Result := DefaultValue
  else
    Result := trunc(d)
end;

function Str2Int64(const S: string; const IsHex: Boolean = FALSE; const DefaultValue: Int64 = 0): Int64; overload;
var
  e: integer;
begin
  if IsHex then begin
    if (S <> '') and (S[1] <> '$') then
      Val('$0' + S, Result, e)
    else
      Val(S, Result, e)
  end
  else
    Val(S, Result, e);
  if e <> 0 then
    Result := DefaultValue;
end;

function Str2Int(const S: string; const IsHex: Boolean = FALSE; const DefaultValue: integer = 0): integer; overload;
var
  e: integer;
begin
  //Result := StringToInt64(S, IsHex, DefaultValue);
  if IsHex then
    Val('$0' + S, Result, e)
  else
    Val(S, Result, e);
  if e <> 0 then
    Result := DefaultValue;
end;

function Str2Int(const S: string; const DefaultValue: integer; const IsHex: Boolean = FALSE): integer; overload;
begin
  Result := Str2Int(S, isHex, DefaultValue);
end;

function Str2Int64(const S: string; const DefaultValue: Int64; const IsHex: Boolean = FALSE): Int64; overload;
begin
  Result := Str2Int64(S, isHex, DefaultValue);
end;

function Digitize(const S: string; const Digits: integer; Negative: boolean = FALSE; UpperCase: boolean = YES): string;
type
  TNegative = boolean;
  TUpperCase = boolean;
const
  ev = 'f';
  //zero = CHAR_ZERO;
  //space = CHAR_SPACE;
  UPPING = not ord(space);
  fills: array[TUpperCase, TNegative] of char = ((zero, ev), (zero, char(ord(ev) and UPPING)));

  function firstNonZero: integer;
  var
    fill: char;
  begin
    if S = '' then Result := 0
    else if Negative then Result := 1
    else begin
      fill := fills[UpperCase, Negative];
      for Result := 1 to length(S) do
        if S[Result] <> fill then
          break
    end;
  end;

var
  L: integer;
begin
  Result := S;
  if Digits > 0 then begin
    L := length(S);
    if Digits < L then
      Result := copy(S, _min(L - Digits + 1, firstNonZero), L)
    else if Digits > L then
      Result := stringofchar(fills[UpperCase, Negative], Digits - L) + S
  end;
end;

function IntoHex(const I: integer; const Digits: byte = sizeof(integer) * 2; UpperCase: boolean = YES): string; overload //register;
// LEGACY_CODE: (used for sample implementation only)
// argument:Digits specifies how many digits (NOT of how many bytes)
var
  b: integer;
begin
  b := 4;
  if i >= 0 then
    if i <= high(byte) then
      b := 1
    else if i <= high(word) then
      b := 2;
  if UpperCase then
    Result := hexn(i, b)
  else
    Result := hexn(i, b, [xsLowerCase]);
  Result := Digitize(Result, Digits, i < 0, UpperCase);
end;

function IntoHex(const I: Int64; const Digits: byte = sizeof(Int64) * 2; UpperCase: boolean = YES): string; overload //register;
// LEGACY_CODE: (used for sample implementation only)
// argument:Digits specifies how many digits (NOT of how many bytes)
var
  hs: THexStyles;
begin
  hs := [];
  if not UpperCase then
    include(hs, xsLowerCase);
  //if r64(I).hi<>0 then
  if (I < Low(integer)) or (I > high(integer)) then
    Result := Digitize(hexn(i, sizeof(Int64), hs), Digits, i < 0)
  else
    Result := intoHex(integer(i), Digits, UpperCase)
end;

function isValidGUIDStr(const S: string): boolean;
const
  //        12345678901234567890123456789012345678
  Sample = '{00000002-0000-0000-C000-000000000046}';
  SampLen = length(sample);
  C12 = 12; C8 = 8; C4 = 4;
  PHexChars: pointer = nil;
//  HexChars: array[char] of Char = (dup 100h);
asm
    mov eax,S; push ebx
    test eax,eax; jnz @@begin
  @@zero: xor eax,eax; jmp @@end
  @@begin: cmp dword[S-4],Samplen; jne @@zero
    xor ecx,ecx; xor edx,edx; xor ebx,ebx;
    mov dh,eax+01-1; mov bl,eax+10-1; mov cl,eax+15-1;
    mov dl,eax+38-1; mov bh,eax+25-1; mov ch,eax+20-1;

    xor edx,'{}'; xor ecx,'--'; xor ebx,'--';
    or edx,ebx; or ebx,SampLen-1-C12-1;
    or edx,ecx; jnz @@zero

    //cmp byte ptr[eax], '{'; jne @@zero
    //cmp byte ptr[eax+10-1], '-'; jne @@zero
    //cmp byte ptr[eax+15-1], '-'; jne @@zero
    //cmp byte ptr[eax+20-1], '-'; jne @@zero
    //cmp byte ptr[eax+25-1], '-'; jne @@zero
    //cmp byte ptr[eax+38-1], '}'; jne @@zero

    add eax,ebx

  @@fillValidHexChars: //xor ecx,ecx
    //test byte ptr HexChars+'0',-1; jnz @@test
    mov ebx,PHexChars;
    test ebx,ebx; jnz @@test
    push eax;
      call System.SysGetMem
      mov ebx,eax; mov PHexChars,eax
      push 256/8; pop ecx; fldz;
      @@flz: fst qword ptr ebx+ecx*8-8;
      dec ecx; jnz @@flz; fstp st
    pop eax;

    lea edx,ebx+'0'; xor ecx,10
    @@Loop_n: dec ecx; mov byte ptr edx+ecx,1; jnz @@Loop_n;

    lea edx,ebx+'A'; xor ecx,'F'-'A'+1
    @@Loop_u: dec ecx; mov byte ptr edx+ecx,1; jnz @@Loop_u

    lea edx,ebx+'a'; xor ecx,'f'-'a'+1
    @@Loop_l: dec ecx; mov byte ptr edx+ecx,1; jnl @@Loop_l

    xor edx,edx; xor ecx,ecx

  @@test:
    xor ecx,C12
    @@LoopC12: mov dl, byte ptr eax+ecx
    cmp byte ptr ebx+edx,1; jne @@zero
    dec ecx; jnz @@LoopC12

    xor ecx,3

    @@LC4: push ecx; sub eax,C4+1; mov cl,C4
    @@LoopC4: mov dl, byte ptr eax+ecx
        cmp byte ptr ebx+edx,1; jne @@zeroC4
        dec ecx; jg @@LoopC4
        pop ecx; dec ecx; jg @@LC4
        jmp @@LC4done
        @@zeroC4: pop ecx; jmp @@zero
    @@LC4done:

    sub eax,C8+1; mov cl,C8
    @@LoopC8: mov dl, byte ptr eax+ecx
    cmp byte ptr ebx+edx,1; jnz @@zero
    dec ecx; jg @@LoopC8
    or eax,-1
    @@end: pop ebx
end;

function GUIDtoStr(const GUID: TGUID): string;
begin
  Result := hexs(GUID, 16, [], #0);
  Result := blocks(Result, '-', 4, TRUE, 4, 11);
  Result := '{' + Result + '}';
end;

procedure SysError(errorCode: TRuntimeError);
begin
  {$IFDEF Delphi6_up}
  System.Error(errorCode);
  {$ELSE}
  halt(ord(errorCode));
  {$ENDIF}
end;

function StrToGUID(const S: string; const RaisedError: TRuntimeError = reInvalidCast): TGUID;
  procedure InvalidGUID;
  begin
    if RaisedError <> reNone then
      SysError(RaisedError);
  end;

  procedure SwapInt64Bytes(var n: int64);
  asm
    mov ecx,dword ptr[n+0]; mov edx,dword ptr[n+4];
    bswap ecx;{                        } bswap edx;
    mov dword ptr[n+4],ecx; mov dword ptr[n+0],edx;
  end;

type
  r64 = packed record
    Lo: Longword;
    case integer of
      0: (Hi: Longword);
      1: (LoWord, HiWord: word);
  end;
var
  n1, n2: int64;
begin

  if not isValidGUIDStr(S) then begin
    InvalidGUID;
    exit;
  end;

  n1 := bintoi64(copy(S, 02, 8 + 1 + 4 + 1 + 4) + 'H');
  n2 := bintoi64(copy(S, 21, 4 + 1 + 12) + 'H');

  SwapInt64Bytes(n1);
  SwapInt64Bytes(n2);

  Result.D1 := r64(n1).lo;
  result.D2 := r64(n1).LoWord;
  result.D3 := r64(n1).HiWord;
  move(n2, Result.D4, 8);
end;
{
//System hints
//procedure _StrLong(Val, Width: Longint; var S: ShortString);
//procedure _LStrSetLength{var Str: ANSIString; NewLength: integer);
//procedure _LStrFromString(var Dest: ANSIString; const Source: ShortString);
//procedure _LStrOfCharCc: Char; count: integer): ANSIString;

//procedure  _NewAnsiString{Length: Longint);

//procedure UniqueString(var Str: string);
//procedure _LStrAsg{var Dest: ANSIString; Source: ANSIString);
//procedure _LStrLAsg{var Dest: ANSIString; Source: ANSIString);
}

function octn(const Buffer; const BufferLength: integer; const Fold3digits: boolean = FALSE): string;
overload register assembler asm
  @@start:
    or eax, eax; jz @@Stop     // insanity checks
    or edx, edx; jg @@Begin    // can not exceed 2GB
    xor eax, eax; jmp @@Stop
  @@Begin: push esi; push edi; push ebx
    mov esi, Buffer; mov ebx, BufferLength
    and ecx, 1; mov edi, ecx; jnz @3Fold
  @unfold:// using precise digits count
    lea eax, [ebx*8+2]              // 8n + 2
    mov ecx, 55555555h+1; mul ecx   // = div 3
    jmp @SetL
  @3Fold: // using 3-digits fold
    lea eax, [ebx*8+8]              // 8n + 8
    mov ecx, 1C71C71Ch+1; mul ecx   // = div 9
    mov eax, edx
    xor ecx, ecx; mov cl, 3; mul ecx
    mov edx, eax
  @SetL: mov eax, Result; call __LStrCLSet
    test edi, edi; mov edi, eax; jz @Prep_
    mov word[edi], '00';
  @Prep_:
    mov eax, edi-4; lea edi, edi+eax-1
    dec ebx; lea esi, esi+ebx; neg ebx
    @byte1: mov al, [esi+ebx]//lodsb;
      mov ah,al; movzx edx,al
      shr ah,3; shr dl,6
      and eax,0707h; or ax,'00'; //stosw
      mov [edi],al; mov [edi-1],ah; lea edi, edi-2
      //dec ebx; jge @byte2
      inc ebx; jle @byte2
      mov al,dl
      and al,07h; or al,'0'; //stosb
      mov [edi], al; lea edi,edi-1
      jmp @@Done
    @byte2: mov al, [esi+ebx]//lodsb;
      mov ah,al; mov dh,al
      shL al,2; or dl,al
      shr dh,1; rol edx,16
      mov dl,ah; shr dl,4
      test ah,ah; setl dh
      //dec ebx; jge @byte3
      inc ebx; jle @byte3
      rol edx,16; mov eax,edx;
      and eax,07070707h; or eax,'0000'; //stosd
      bswap eax; mov [edi-3], eax; lea edi,edi-4
      jmp @@Done
    @byte3: mov al, [esi+ebx]//lodsb;
      mov ah,al
      shl al,1; or dh,al; rol edx,16
      and edx,07070707h; or edx,'0000'
      bswap edx; mov [edi-3], edx; lea edi,edi-4
      //mov [edi],edx; lea edi,edi+4
      mov al,ah; shr al,2; shr ah,5
      and ax,0707h; or ax,'00'; //stosw
      mov [edi],al; mov [edi-1],ah; lea edi, edi-2
      //dec ebx; jge @byte1
      inc ebx; jle @byte1
  @@Done: //pop eax
  @@End: pop ebx; pop edi; pop esi
  @@Stop:
  end;

function octb(const Buffer; const BufferLength: integer): string;
overload register assembler asm
  @@start:
    or eax, eax; jz @@Stop     // insanity checks
    or edx, edx; jg @@Begin    // can not exceed 2GB
    xor eax, eax; jmp @@Stop
  @@Begin: push esi; push edi; push ebx
    mov esi, Buffer; mov ebx, BufferLength
    mov eax, Result; push eax
    call System.@LStrClr       // cleared first to avoid invalid ptr assignment
    lea eax, [ebx*8+2]
    mov ecx,  55555556h; mul ecx // = div 3
    pop eax; call System.@LStrSetLength
    mov edi, [eax]; push eax;
    dec ebx; lea esi, esi+ebx; neg ebx
    @byte1: mov al, [esi+ebx]//lodsb;
      mov ah,al; movzx edx,al
      shr ah,3; shr dl,6
      and eax,0707h; or ax,'00'; stosw
      //dec ebx; jge @byte2
      inc ebx; jle @byte2
      mov al,dl
      and al,07h; or al,'0'; stosb
      jmp @@Done
    @byte2: mov al, [esi+ebx]//lodsb;
      mov ah,al; mov dh,al
      shL al,2; or dl,al
      shr dh,1; rol edx,16
      mov dl,ah; shr dl,4
      test ah,ah; setl dh
      //dec ebx; jge @byte3
      inc ebx; jle @byte3
      rol edx,16; mov eax,edx;
      and eax,07070707h; or eax,'0000'; stosd
      jmp @@Done
    @byte3: mov al, [esi+ebx]//lodsb;
      mov ah,al
      shl al,1; or dh,al; rol edx,16
      and edx,07070707h; or edx,'0000'
      mov [edi],edx; lea edi,edi+4
      mov al,ah; shr al,2; shr ah,5
      and ax,0707h; or ax,'00'; stosw
      //dec ebx; jge @byte1
      inc ebx; jle @byte1
  @@Done: pop eax
  @@End: pop ebx; pop edi; pop esi
  @@Stop:
  end;

function octb(const I: Int64; const Delimiter: string = ''): string; overload;
begin
  Result := Reverse(blocks(octb(I, 8), Delimiter));
end;

function octb(const I: integer; const Delimiter: string = ''): string; overload;
begin
  Result := Reverse(blocks(octb(I, 4), Delimiter));
end;

function octs(const Buffer; const BufferLength: integer; const Delimiter: Char = #0): string;
overload register assembler asm
{ LEGACY_CODE
  to add space every 3 digits, uncomments +space: below
  use blocks function for more flexibility }
  @@start:
    or eax, eax; jz @@Stop     // insanity checks
    or edx, edx; jg @@Begin    // can not exceed 2GB
    xor eax, eax; jmp @@Stop
  @@Begin: push esi; push edi; push ebx
    mov esi, Buffer
    mov ebx, BufferLength
    mov eax, Result

    push ecx
    call System.@LStrClr       // cleared first to avoid invalid ptr assignment
    lea edx, [ebx*2+ebx]
    mov ecx, [esp]
    test cl, -1; jz @_dlm
    add edx, ebx
    //+ add edx, ebx; push edx     //+space:
    @_dlm:
    call System.@LStrSetLength // edx will be destroyed!
    //+ pop edx                    //+space:
    pop ecx
    mov edi, [eax];
    push eax
    test cl, -1; jnz @@Loop4

  @@Loop3: lodsb; mov ah, al
      and al, $07; or al, '0'; stosb
      mov al, ah; shr al, 3; shr ah, 6
      and ax, $0707; or ax, '00'; stosw
      //+ mov al, '.'; stosb //+space:
    dec ebx; jg @@Loop3; jmp @@_ok
  @@Loop4: lodsb; mov ah, al
      and al, $07; or al, '0'; stosb
      mov al, ah; shr al, 3; shr ah, 6
      and ax, $0707; or ax, '00'; stosw
      //+ mov al, '.'; stosb //+space:
      mov al, cl; stosb
    dec ebx; jg @@Loop4; jmp @@_ok
  @@_ok:
    pop eax
    test cl, -1; jz @@End
    //+ dec edx //+space
    //+ call System.@LStrSetLength //+space, remove trailing dot
    dec edx
    call System.@LStrSetLength //+space, remove trailing dot

  @@End: pop ebx; pop edi; pop esi
  @@Stop:
  end;

function binn(const Buffer; const BufferLength: integer): string;
overload register assembler asm
  @@Start:
    or Buffer, Buffer; jz @@Stop     // insanity checks
    or BufferLength, BufferLength; jg @@begin // may not exceed 2GB
    xor eax, eax; ret
  @@Begin: push esi; push edi; push ebx
    push Result
    mov ebx,edx; shl edx, 3 // save BufLen, request BufLen * 8
    mov esi,Buffer; mov eax,Result;

    //call __LStrCLSet; mov edi, eax
    push edx; call System.@LStrClr
    pop edx; call System.@LStrSetLength
    mov edi,[eax];

    lea ecx,ebx-1;  // i'd rather using ecx for loss 1 clock
    @@Loop: mov al, [esi+ecx]//lodsb;
      { // OLD:
      // CPU loves uniform instructions
      shr al,1; setc bh; //rol ebx, 8
      shr al,1; setc bl; rol ebx, 16
      shr al,1; setc bh; //rol ebx, 8
      shr al,1; setc bl; //rol ebx, 8

      shr al,1; setc dh; //rol edx, 8
      shr al,1; setc dl; rol edx, 16
      shr al,1; setc dh; //rol edx, 8
      shr al,1; setc dl; //rol edx, 8

      or ebx, '0000'; or edx, '0000'

      mov[edi], edx; mov [edi+4], ebx
      }

      // best:
      test al,al; sets bl;
      test al,1 shl 6; setnz bh;
      test al,1 shl 5; setnz dl;
      test al,1 shl 4; setnz dh;
      or bx,'00'; or dx,'00';
      mov [edi+0],bx; mov [edi+2],dx

      test al,1 shl 3; setnz bl;
      test al,1 shl 2; setnz bh;
      test al,1 shl 1; setnz dl;
      test al,1 shl 0; setnz dh;
      or bx,'00'; or dx,'00';
      mov [edi+4],bx; mov [edi+6],dx

      { // not better:
      xor ebx,ebx; xor edx,edx;
      shl al,1; adc bl,bl
      shl al,1; adc bh,bh
      shl al,1; adc dl,dl
      shl al,1; adc dh,dh
      or bx,'00'; or dx,'00';
      mov [edi+0],bx; mov [edi+2],dx;

      xor ebx,ebx; xor edx,edx;
      shl al,1; adc bl,bl
      shl al,1; adc bh,bh
      shl al,1; adc dl,dl
      shl al,1; adc dh,dh
      or bx,'00'; or dx,'00';
      mov [edi+4],bx; mov [edi+6],dx
      }

      lea edi, [edi+8]
    dec ecx; jge @@Loop;

    pop eax // Result
  @@end: pop ebx; pop edi; pop esi
  @@Stop:
  end;

function binb(const Buffer; const BufferLength: integer): string;
overload register assembler asm
  @@Start:
    or Buffer, Buffer; jz @@Stop     // insanity checks
    or BufferLength, BufferLength; jg @@begin // may not exceed 2GB
    xor eax, eax; ret
  @@Begin: push esi; push edi; push ebx
    push Result
    mov ebx,edx; shl edx,3 // save BufLen, request BufLen * 8
    mov esi,Buffer; mov eax,Result;
    // call __LStrCLSet; mov edi,eax
    push edx; call System.@LStrClr
    pop edx; call System.@LStrSetLength
    mov edi,[eax];

    mov ecx,ebx  // i'd rather using ecx for loss 1 clock
    lea esi,esi+ecx; neg ecx;
  @@Loop: mov al,esi[ecx]//lodsb;
    { // OLD:
      // CPU loves uniform instructions
      shr al,1; setc bh; //rol ebx, 8
      shr al,1; setc bl; rol ebx, 16
      shr al,1; setc bh; //rol ebx, 8
      shr al,1; setc bl; //rol ebx, 8

      shr al,1; setc dh; //rol edx, 8
      shr al,1; setc dl; rol edx, 16
      shr al,1; setc dh; //rol edx, 8
      shr al,1; setc dl; //rol edx, 8

      or ebx, '0000'; or edx, '0000'

      mov[edi], edx; mov [edi+4], ebx
    }
      test al,al; sets bl;
      test al,1 shl 6; setnz bh;
      test al,1 shl 5; setnz dl;
      test al,1 shl 4; setnz dh;
      or bx,'00'; or dx,'00';
      mov [edi+0],bx; mov [edi+2],dx

      test al,1 shl 3; setnz bl;
      test al,1 shl 2; setnz bh;
      test al,1 shl 1; setnz dl;
      test al,1 shl 0; setnz dh;
      or bx,'00'; or dx,'00';
      mov [edi+4],bx; mov [edi+6],dx

      lea edi, [edi+8]
    inc ecx; jl @@Loop

    pop eax // Result
  @@end: pop ebx; pop edi; pop esi
  @@Stop:
  end;

const
  DECIMAL_DIGIT = ['0'..'9'];
  NUMERIC = DECIMAL_DIGIT;

  HEXLOCASE = NUMERIC + ['a'..'f'];
  HEXUPCASE = NUMERIC + ['A'..'F'];

  HEXDIGITS = HEXLOCASE + HEXUPCASE;

  hexCharset: set of char = HEXDIGITS;
  ordSuffix: set of char = ['b', 'B', 'h', 'H', 'o', 'O'];

function bintoi(const S: string; out errCode: integer): integer; overload assembler asm
  mov dword[errCode], 10h
  test S, S; jz @@err1
  mov ecx, [S-4]
  cmp ecx, 2; jl @@err2
  movzx ecx, byte[S+ecx-1]
  bt dword[ordSuffix], ecx; jc @@Start

@@err3: add dword[errCode], 10h
@@err2: add dword[errCode], 10h
@@err1: ret

@@Start:
  push esi; push edi; push ebx; push errCode
  lea esi, S-2; mov edi, S-4
  xor eax, eax; xor ebx, ebx; xor edx, edx

  or cl, 20h // oops.. i forgot :(

@loop_0:
  inc esi; dec edi
  cmp byte[esi+1], '+'; jz @loop_0
  cmp byte[esi+1], '-'; jne @getLoop
  xor bl, 1; jmp @loop_0

@getLoop: test edi, edi; mov dl, 4; jz @@err10
  cmp cl, 'h'; je @hLoop
  cmp cl, 'o'; je @oLoop

@bLoop: inc esi; dec edi; jl @ntos_ah
  mov dl, [esi]
  cmp dl, '0'; je @bcount
  cmp dl, '1'; je @bcount
  bt dword[ordDelimiters], dx; jb @bLoop
  mov dl, 5; jmp @@err10

@bCount: sub dl, '0'
  lea eax, [eax*2+edx]; jmp @bLoop

@oLoop: inc esi; dec edi; jl @ntos_ah
  mov dl, [esi]
  cmp dl, '0'; jb @ck2
  cmp dl, '7'; jbe @ocount

@ck2: bt dword[ordDelimiters], dx; jb @oLoop
  mov dl, 6; jmp @@err10

@oCount: sub dl, '0'
  lea eax, [eax*8+edx]; jmp @oLoop

@hLoop: inc esi; dec edi; jl @ntos_ah
  mov dl, [esi]
  bt dword[HexCharset], dx; jb @hCount
  bt dword[ordDelimiters], dx; jb @hLoop
  mov dl, 7; jmp @@err10

@hCount:
  cmp dl, '9'; jbe @base0
  or dl, 20h
  sub dl, 'a'-'0'-10

@base0:
  sub dl, '0'
  shl eax, 4; add eax, edx
  jmp @hLoop

@@err10: shl edx,8; add edx, esi
mov ebx, [esp]; mov [ebx], edx; jmp @end

@ntos_ah:
  and ebx, 1; neg ebx
  xor eax, ebx
  sub eax, ebx
  mov ebx, [esp]; mov dword[ebx], 0
@end: pop ebx; pop ebx; pop edi; pop esi
end;

function bintoi64(const S: string; out errCode: integer): Int64; overload assembler asm
  mov dword[errCode], 10h
  test S, S; jz @@err1
  mov ecx, [S-4]
  cmp ecx, 2; jl @@err2
  movzx ecx, byte[S+ecx-1]
  bt dword[ordSuffix], ecx; jc @@Start

@@err3: add dword[errCode], 10h
@@err2: add dword[errCode], 10h
@@err1: ret

@@Start:
  push esi; push edi; push ebx; push errCode
  lea esi, S-2; mov edi, S-4
  xor eax, eax; xor edx, edx; xor ebx, ebx

  or cl, 20h // oops.. i forgot :(

@loop_0:
  inc esi; dec edi
  cmp byte[esi+1], '+'; jz @loop_0
  cmp byte[esi+1], '-'; jne @getLoop
  xor bl, 1; jmp @loop_0

@getLoop: test edi,edi; mov bh, 4h; jz @@err10
  cmp cl, 'h'; je @hLoop
  cmp cl, 'o'; je @oLoop

@bLoop: inc esi; dec edi; jl @ntos_ah
  mov cl, [esi]
  cmp cl, '0'; je @bcount
  cmp cl, '1'; je @bcount
  bt dword[ordDelimiters], dx; jb @bLoop
  mov bh, 5h; jmp @@err10

@bCount: sub cl, '0'
  shl edx, 1; shl eax,1
  adc edx, 0; or eax, ecx; jmp @bLoop

@oLoop: inc esi; dec edi; jl @ntos_ah
  mov cl, [esi]
  cmp cl, '0'; jb @ck2
  cmp cl, '7'; jbe @ocount

@ck2: bt dword[ordDelimiters], cx; jb @oLoop
  mov bh, 6h; jmp @@err10

@oCount: sub cl, '0'
  shld edx, eax, 3; lea eax, [eax*8+ecx]; jmp @oLoop

@hLoop: inc esi; dec edi; jl @ntos_ah
  mov cl, [esi]
  bt dword[HexCharset], cx; jb @hCount
  bt dword[ordDelimiters], cx; jb @hLoop
  mov bh, 7h; jmp @@err10

@hCount: cmp cl, '9'; jbe @base0
  or cl, 20h; sub cl, 'a'-'0'-10

@base0: sub cl, '0'
  shld edx, eax, 4; shl eax, 4
  or eax, ecx; jmp @hLoop

@@err10: movzx edx, bh; shl edx,8; add edx, esi
mov ecx, [esp]; mov [ecx], ebx; jmp @end

@ntos_ah: xor ecx, ecx; and ebx, 1
  mov ebx, [esp]; mov [ebx], ecx; jz @end
  neg eax; adc edx,0; neg edx

@end: pop ebx; pop ebx; pop edi; pop esi
@@Stop:
end;

function bintoi(const S: string): integer; overload assembler asm
  push edx; mov edx, esp // local variable for errCode
  call bintoi
  pop edx
  test edx, edx; jz @done
  mov eax, 1 shl 31
 @done:
end;

function bintoi64(const S: string): Int64; overload assembler asm
  push edx; mov edx, esp // local variable for errCode
  call bintoi64
  pop ecx
  test ecx, ecx; jz @done
  xor eax, eax
  mov edx, 1 shl 31
 @done:
end;

function setBit(const BitNo, I: integer): integer; overload;
begin
  Result := I or (1 shl BitNo);
end;

function isBitSet(const BitNo, I: integer): Boolean; overload;
begin
  Result := (I and (1 shl BitNo)) <> 0;
end;

function ResetBit(const BitNo, I: integer): integer; overload;
begin
  Result := I and ((1 shl BitNo) xor -1);
end;

function ToggleBit(const BitNo, I: integer): integer; overload;
begin
  Result := I xor (1 shl BitNo);
end;

function setBit(const BitNo: integer; const I: Int64): Int64; overload;
begin
  Result := I or (Int64(1) shl BitNo);
end;

function isBitSet(const BitNo: integer; const I: Int64): boolean; overload;
begin
  Result := (I and (Int64(1) shl BitNo)) <> 0;
end;

function ResetBit(const BitNo: integer; const I: Int64): Int64; overload;
begin
  Result := I and ((Int64(1) shl BitNo) xor Int64(-1));
end;

function ToggleBit(const BitNo: integer; const I: Int64): Int64; overload;
begin
  Result := I xor (Int64(1) shl BitNo);
end;

const
  RevBits: array[byte] of byte = (
    $00, $80, $40, $C0, $20, $A0, $60, $E0, $10, $90, $50, $D0, $30, $B0, $70, $F0,
    $08, $88, $48, $C8, $28, $A8, $68, $E8, $18, $98, $58, $D8, $38, $B8, $78, $F8,
    $04, $84, $44, $C4, $24, $A4, $64, $E4, $14, $94, $54, $D4, $34, $B4, $74, $F4,
    $0C, $8C, $4C, $CC, $2C, $AC, $6C, $EC, $1C, $9C, $5C, $DC, $3C, $BC, $7C, $FC,
    $02, $82, $42, $C2, $22, $A2, $62, $E2, $12, $92, $52, $D2, $32, $B2, $72, $F2,
    $0A, $8A, $4A, $CA, $2A, $AA, $6A, $EA, $1A, $9A, $5A, $DA, $3A, $BA, $7A, $FA,
    $06, $86, $46, $C6, $26, $A6, $66, $E6, $16, $96, $56, $D6, $36, $B6, $76, $F6,
    $0E, $8E, $4E, $CE, $2E, $AE, $6E, $EE, $1E, $9E, $5E, $DE, $3E, $BE, $7E, $FE,
    $01, $81, $41, $C1, $21, $A1, $61, $E1, $11, $91, $51, $D1, $31, $B1, $71, $F1,
    $09, $89, $49, $C9, $29, $A9, $69, $E9, $19, $99, $59, $D9, $39, $B9, $79, $F9,
    $05, $85, $45, $C5, $25, $A5, $65, $E5, $15, $95, $55, $D5, $35, $B5, $75, $F5,
    $0D, $8D, $4D, $CD, $2D, $AD, $6D, $ED, $1D, $9D, $5D, $DD, $3D, $BD, $7D, $FD,
    $03, $83, $43, $C3, $23, $A3, $63, $E3, $13, $93, $53, $D3, $33, $B3, $73, $F3,
    $0B, $8B, $4B, $CB, $2B, $AB, $6B, $EB, $1B, $9B, $5B, $DB, $3B, $BB, $7B, $FB,
    $07, $87, $47, $C7, $27, $A7, $67, $E7, $17, $97, $57, $D7, $37, $B7, $77, $F7,
    $0F, $8F, $4F, $CF, $2F, $AF, $6F, $EF, $1F, $9F, $5F, $DF, $3F, $BF, $7F, $FF
    );

  {
    Picked from QStrings (almost a verbatim copy other than style)
    Copyright (2000-2003) Andrew Dryazgov (ndrewdr@newmail.ru) and
    (2000) Sergey G. Shcherbakov (mover@mail.ru, mover@rada.gov.ua)
  }

procedure ReverseBits(const Buffer; BitCount: cardinal); assembler asm
  push ebx; push esi; push edi
  mov ebx,edx
  shr ebx,3; and BitCount,7; jz @int
  push Buffer; mov edi,Buffer
  inc ebx; xor ecx,ecx; mov cl,8
  sub cl,dl; xor BitCount,BitCount
  push ebx
@mod: xor eax,eax; mov al,byte[edi]
  shl eax,cl; or eax,edx
  mov byte[edi],al
  xor edx,edx; mov dl,ah
  inc edi; dec ebx; jnz @mod
  pop ebx; pop Buffer
@int: lea ecx,[eax+ebx-1]
@Loop: cmp eax,ecx; jge @@done
  movzx esi,byte[eax]
  movzx edi,byte[ecx]
  mov dh,byte[RevBits+esi]
  mov byte[ecx],dh
  mov dl,byte[RevBits+edi]
  mov byte[eax],dl
  inc eax; dec ecx; jmp @Loop
@@done: pop edi; pop esi; pop ebx
end;

// ~~~~~~~~~~~~~~~~~~~~~~~
// Pseudo-random generator
// ~~~~~~~~~~~~~~~~~~~~~~~
{.$DEFINE DEBUG_RANDOM}
// the __RandCycle is the very heart of random generator
// there are 4 cardinal storages (+1 scratch) whose forms
// upto 24 possible combination of number-flow (128 bits)

function __RandCycle(var X; const CycleFlow: integer = 0): int64;
const // accessed by esp offset (not ebp)
  f0: integer = $13FB; //5115;
  f1: integer = $06F0; //1776;
  f2: integer = $05D4; //1492;
  f3: integer = $7DD4FFC7; //2111111111;
  ret_ = $FF89E5FF;
asm
  push esi; push edi; push ebx; push ebp
  mov edi,X;
  push 23; pop eax; // find min
	sub edx,eax; sbb ecx,ecx
	and ecx,edx; add eax,ecx
  mov ebp,offset @@begin; push eax;
  mov ebx,[edi+4*1]; mov ecx,[edi+4*2];
  mov edx,[edi+4*3]; lea esi,eax*8+@@jmptable_push;
  mov eax,[edi+4*0]; jmp esi; nop
  @@jmptable_push:
  dd 'RQSP',ret_,'QRSP',ret_,'RSQP',ret_,'SRQP',ret_,'QSRP',ret_,'SQRP',ret_;
  dd 'RQPS',ret_,'QRPS',ret_,'RPQS',ret_,'PRQS',ret_,'QPRS',ret_,'PQRS',ret_;
  dd 'RSPQ',ret_,'SRPQ',ret_,'RPSQ',ret_,'PRSQ',ret_,'SPRQ',ret_,'PSRQ',ret_;
  dd 'QSPR',ret_,'SQPR',ret_,'QPSR',ret_,'PQSR',ret_,'SPQR',ret_,'PSQR',ret_;
  @@begin:
  mov eax,f3; mul dword[esp+3*4];       ;// X[n-4]
  mov ecx,eax; mov eax,[esp+2*4];  ;// X[n-3]
  mov esi,edx; mov [esp+3*4],eax;
  mul f2;
  add ecx,eax; mov eax,[esp+1*4];  ;// X[n-2]
  adc esi,edx; mov [esp+2*4],eax;
  mul f1;
  add ecx,eax; mov eax,[esp+0*4];  ;// X[n-1]
  adc esi,edx; mov [esp+1*4],eax;
  mul f0;
  add eax,ecx; adc edx,esi;
  mov esi,[esp+4*4]; add eax,[edi+4*4];
  rcl edx,0     ;//adc edx,0;
  mov [esp+0*4],eax; mov [edi+4*4],edx;
  mov ebp,offset @@done;
  lea esi,esi*8+@@jmptable_pop; jmp esi;
  @@jmptable_pop: //already aligned 4
  dd 'X[YZ',ret_,'X[ZY',ret_,'XY[Z',ret_,'XYZ[',ret_,'XZ[Y',ret_,'XZY[',ret_;
  dd '[XYZ',ret_,'[XZY',ret_,'[YXZ',ret_,'[YZX',ret_,'[ZXY',ret_,'[ZYX',ret_;
  dd 'YX[Z',ret_,'YXZ[',ret_,'Y[XZ',ret_,'Y[ZX',ret_,'YZX[',ret_,'YZ[X',ret_;
  dd 'ZX[Y',ret_,'ZXY[',ret_,'Z[XY',ret_,'Z[YX',ret_,'ZYX[',ret_,'ZY[X',ret_;
@@done: pop esi
  mov [edi+4*0],eax; mov [edi+4*1],ebx;
  mov [edi+4*2],ecx; mov [edi+4*3],edx;
  pop ebp; pop ebx; pop edi; pop esi
end;

function __RandCycle64(var X; const CycleFlow: integer = 0): int64;
const // accessed by esp offset (not ebp)
  f0: integer = $13FB; //5115;
  f1: integer = $06F0; //1776;
  f2: integer = $05D4; //1492;
  f3: integer = $7DD4FFC7; //2111111111;
  ret_ = $FF89E5FF;
asm
  push esi; push edi; push ebx; push ebp
  mov edi,X;
  push 23; pop eax; // find min
	sub edx,eax; sbb ecx,ecx
	and ecx,edx; add eax,ecx
  mov ebp,offset @@begin; push eax;
  mov ebx,[edi+4*1]; mov ecx,[edi+4*2];
  mov edx,[edi+4*3]; lea esi,eax*8+@@jmptable_push;
  mov eax,[edi+4*0]; jmp esi; nop
  @@jmptable_push:
  dd 'RQSP',ret_,'QRSP',ret_,'RSQP',ret_,'SRQP',ret_,'QSRP',ret_,'SQRP',ret_;
  dd 'RQPS',ret_,'QRPS',ret_,'RPQS',ret_,'PRQS',ret_,'QPRS',ret_,'PQRS',ret_;
  dd 'RSPQ',ret_,'SRPQ',ret_,'RPSQ',ret_,'PRSQ',ret_,'SPRQ',ret_,'PSRQ',ret_;
  dd 'QSPR',ret_,'SQPR',ret_,'QPSR',ret_,'PQSR',ret_,'SPQR',ret_,'PSQR',ret_;
  @@begin:

  mov eax,f3; mul dword[esp+3*4];       ;// X[n-4]
  mov ecx,eax; mov eax,[esp+2*4];  ;// X[n-3]
  mov esi,edx; mov [esp+3*4],eax;
  mul f2;
  add ecx,eax; mov eax,[esp+1*4];  ;// X[n-2]
  adc esi,edx; mov [esp+2*4],eax;
  mul f1;
  add ecx,eax; mov eax,[esp+0*4];  ;// X[n-1]
  adc esi,edx; mov [esp+1*4],eax;
  mul f0;
  add eax,ecx; adc edx,esi;
  mov esi,[esp+4*4]; add eax,[edi+4*4];
  rcl edx,0     ;//adc edx,0;
  mov [esp+0*4],eax; mov [edi+4*4],edx;

  mov eax,f3; mul dword[esp+3*4];       ;// X[n-4]
  mov ecx,eax; mov eax,[esp+2*4];  ;// X[n-3]
  mov esi,edx; mov [esp+3*4],eax;
  mul f2;
  add ecx,eax; mov eax,[esp+1*4];  ;// X[n-2]
  adc esi,edx; mov [esp+2*4],eax;
  mul f1;
  add ecx,eax; mov eax,[esp+0*4];  ;// X[n-1]
  adc esi,edx; mov [esp+1*4],eax;
  mul f0;
  add eax,ecx; adc edx,esi;
  mov esi,[esp+4*4]; add eax,[edi+4*4];
  rcl edx,0     ;//adc edx,0;
  mov [esp+0*4],eax; mov [edi+4*4],edx;

  mov ebp,offset @@done;
  lea esi,esi*8+@@jmptable_pop; jmp esi;
  @@jmptable_pop: //already aligned 4
  dd 'X[YZ',ret_,'X[ZY',ret_,'XY[Z',ret_,'XYZ[',ret_,'XZ[Y',ret_,'XZY[',ret_;
  dd '[XYZ',ret_,'[XZY',ret_,'[YXZ',ret_,'[YZX',ret_,'[ZXY',ret_,'[ZYX',ret_;
  dd 'YX[Z',ret_,'YXZ[',ret_,'Y[XZ',ret_,'Y[ZX',ret_,'YZX[',ret_,'YZ[X',ret_;
  dd 'ZX[Y',ret_,'ZXY[',ret_,'Z[XY',ret_,'Z[YX',ret_,'ZYX[',ret_,'ZY[X',ret_;
@@done: pop esi
  mov [edi+4*0],eax; mov [edi+4*1],ebx;
  mov [edi+4*2],ecx; mov [edi+4*3],edx;
  pop ebp; pop ebx; pop edi; pop esi
end;

function RandCycle: Int64; register asm
  lea eax, RandSeedEx; xor edx,edx;
  call __RandCycle
end;

function Rand64: Int64; register overload asm
  lea eax, RandSeedEx; xor edx,edx;
  call __RandCycle64
end;

function Rand64u(const Max: int64): Int64; overload register
// Max for Rand64u taken as unsigned int64
const
  _80e = 2.0 * $4000000000000000;
  _100e = 2.0 * _80e;
  fixSign: array[-1..0] of single = (0, _100e);
  f80e: single = _80e;
  //f100e: single = _100e;
  f100r: single = 1 / _100e;
asm
  lea eax, RandSeedEx; xor edx,edx; call __RandCycle64
  push edx; push eax;
  mov eax,edx; mov edx,Max.r64.hi
  sar eax,31; sar edx,31; //get sign
  neg eax; neg edx;
  fld f100r; fild Max; fadd dword ptr fixSign[edx*4]; // add 100 if negative
  fild qword ptr [esp]; fadd dword ptr fixSign[eax*4]; // add 100 if negative
  fmul; fmul; fCom f80e; fnstsw ax; // get high int64
  xor edx,edx; and ah,1; sete dl;
  fsub dword ptr fixSign[edx*4]; // sub 100 if overflow
  fistp qword ptr [esp]
  pop eax; pop edx;
end;

function Rand(const Max: cardinal): cardinal; register asm
  test eax,eax; jnz @begin; ret
@begin: push Max
  lea eax, RandSeedEx; xor edx,edx
  call __RandCycle; pop edx
  mul edx; mov eax,edx
end;

function __llmul(const XLo, XHi: integer; const X: int64): int64;
//  Param 1(EAX:EDX), Param 2([ESP+8]:[ESP+4])  ; before reg pushing
asm
  //push edx; push eax;
  push XHi; push XLo
  // Param2 : [ESP+16]:[ESP+12]  (hi:lo)
  // Param1 : [ESP+4]:[ESP]      (hi:lo)

  //mov eax,esp+16; mul dword[esp+00]
  mov eax,X.r64.hi; mul dword[esp+0] //XHi:X.High * XLo
  mov ecx,eax

  //mov eax,esp+04; mul dword[esp+12]
  mov eax,esp+4; mul X.r64.lo //XHi * X.Low
  add ecx,eax

  //mov eax,esp+00; mul eax,esp+12
  mov eax,esp+0; mul X.r64.lo //XLo * X.Low
  add edx,ecx

  pop ecx; pop ecx
  //ret 8
end;

function Rand(const Min, Max: integer): integer; register asm
// Result range in Min..Max inclusif
// Min-Max range must not exceed cardinal boundary minus 1 (max range = 4294967295)
  sub max, min; jns @_
    xor eax, eax; ret  // zeronize
  @_: inc max          // difference = (max - min) +1
  push min; push max   // ...save
  lea eax, RandSeedEx; xor edx,edx
  call __RandCycle     // get R
  pop edx; pop ecx     // ..restore
  mul edx              // multiply R by difference (truncated)
  lea eax,edx+ecx
end;

{
  original version,
  RandomDbl PROC NEAR
  public RandomDbl
    CALL    RandomBit           ; random bits
    mov     EDX, EAX            ; fast conversion to float
    SHR     EAX, 12
    OR      EAX, 3FF00000H
    SHL     EDX, 20
    mov     dword[TEMP+4], EAX
    mov     dword[TEMP], EDX
    FLD1
    FLD     Qword[TEMP]         ; partial memory stall here
    FSUBR
    RET
  RandomDbl ENDP
}

function RandEx: Extended; register; // also result sign in cx!!!
const
  _1: packed array[boolean] of single = (1, -2);
  _S: packed array[boolean] of word = ($3FFF, $BFFF);
asm
  fnInit; call RandCycle;
  xor ecx,ecx;
{$IFNDEF RANDINT64_ALWAYS_POSITIVE}
  mov edx,dword ptr [RandSeedEx+4];
  cmp edx,MaxInt; setnbe cl;
{$ENDIF}
{$IFDEF DEBUG_RANDOM}
  jb @@1
    or ecx,ecx
  @@1:
{$ENDIF DEBUG_RANDOM}
  fld dword ptr _1[ecx*4];           // -2 if signed
  or edx,1 shl 31                    //  normalized (msb significand = 1)
  movzx ecx, word ptr _S[ecx*2]
  mov Result.fp80.S.lo,eax
  mov Result.fp80.S.hi,edx
  mov Result.fp80.exp, cx            //  3fffh or 0Bfffh
  fLd Result                         //  1 < Result < 2  or  -2 < Result < -1
  fSubrp                             //  after sub, now 0 < Result < 1
  fStp Result                        //  store back, pop!
end;

//procedure RandInit(const I: integer = __AAMAGIC0__); register

procedure RandInit(const I: int64 = int64(__AAMAGIC1__) shl 31 or __AAMAGIC0__); register
const
  PRIME0 = 7;
  //PRIME1 = $01C8E80D; // 29943821 : 1 1100 1000 1110 1000 0000 1101 ~ 1 11001000 11101000 00010101
  PRIME1: integer = $01C8E80D; // 29943821 : 1 1100 1000 1110 1000 0000 1101 ~ 1 11001000 11101000 00010101
  // original value was 29943829 (01C8E815)
  e: extended = 0; // use extended to allow broader range of generated number
asm
  //fInit
  push edi; lea edi,RandSeedEx ;
  //push 6; // damned obscure bug! destroys table_hexdigits :(
  push 5; pop ecx;
  xor eax,eax; rep stosd
  mov eax,dword ptr I; mov edx,dword ptr I+4;
  push 4; pop edi
  @LFill:
    mul PRIME1; dec eax; sbb edx,0
    mov dword ptr [RandSeedEx+edi*4],eax;
    //imul eax, PRIME1
    //dec eax; mov X[edi*4], eax
    dec edi; jge @LFill

  mov edi, PRIME0
  @@LRand: call RandEx ;
    shr ecx,15; shl ecx,31; //randEx result sign in cx!!!
{$IFDEF DEBUG_RANDOM}
    jz @@d1
      or ecx,ecx
    @@d1:
{$ENDIF DEBUG_RANDOM}
    fstp e // note: for consistency, never directly alter X in RandEx
    mov eax, e.fp80.S.lo; //xor X, eax
    mov edx,e.fp80.S.hi; or edx,ecx;
    xor dword ptr [RandSeedEx],eax;
    xor dword ptr [RandSeedEx+4], edx;
    dec edi; jnz @@LRand
  pop edi
end;

//const _CPUID = $A20F; _RDTSC = $310F;

procedure RandomizeEx; assembler asm db 0fh,31h //rdtsc;
 push edx; push eax; call RandInit
end;
{
//function _Shuffle(Range: integer): TInts;
//var
//  i, n, m: integer;
//begin
//  setlength(Result, Range);
//  dec(Range);
//  for i := 0 to Range do
//    Result[i] := i;
//  if (Range > 0) then begin
//    for i := 0 to Range - 1 do begin // I = domain
//      n := RandomInt(i + 1, Range); // N = codomain
//      m := Result[i];
//      Result[i] := Result[n];
//      Result[n] := m;
//    end;
//  end;
//end;
}

function Shuffle(const Min, Max: integer): TIntegers;
// function Shuffle(const Max: integer; const Min: integer = 0): TIntegers;
// caution! shuffle range values are Min to Max INCLUSIVE!
// thus, for example: Shuffle(1000), will have 1001 elements!
var
  i, n, m: integer;
  Range: integer;
begin
  Range := Max - Min + 1;
  setlength(Result, Range);
  dec(Range);
  for i := 0 to Range do
    Result[i] := i;
  if (Range > 0) then begin
    for i := 0 to Range - 1 do begin // I = domain
      n := Rand(i + 1, Range); // N = codomain
      //exchage result[i] and result[n]
      m := Result[i];
      Result[i] := Result[n];
      Result[n] := m;
    end;
    if (Min <> 0) then
      for i := 0 to Range do
        Result[i] := Result[i] + Min
  end;
end;

function Shuffle(const Max: integer): TIntegers;
begin
  Result := Shuffle(0, Max);
end;

{ this is a fast inttostr by John O'Harrow, (you know who),
  with clever tricks, producing 2 digits in one cycle
  using reciprocal value $51eb851f (cardinal / 0.32)       }
const
  deca: packed array[0..100] of array[boolean] of Char = (
    '00', '01', '02', '03', '04', '05', '06', '07', '08', '09',
    '10', '11', '12', '13', '14', '15', '16', '17', '18', '19',
    '20', '21', '22', '23', '24', '25', '26', '27', '28', '29',
    '30', '31', '32', '33', '34', '35', '36', '37', '38', '39',
    '40', '41', '42', '43', '44', '45', '46', '47', '48', '49',
    '50', '51', '52', '53', '54', '55', '56', '57', '58', '59',
    '60', '61', '62', '63', '64', '65', '66', '67', '68', '69',
    '70', '71', '72', '73', '74', '75', '76', '77', '78', '79',
    '80', '81', '82', '83', '84', '85', '86', '87', '88', '89',
    '90', '91', '92', '93', '94', '95', '96', '97', '98', '99', #0#0
    );
  d01 = 10;
  d02 = 100;
  d03 = 1000;
  d04 = 10000;
  d05 = 100000;
  d06 = 1000000;
  d07 = 10000000;
  d08 = 100000000;
  d09 = 1000000000;
  d10 = 10000000000;
  _032 = $51EB851F;

const
  PMinInt64: pchar = '-9223372036854775808';

function IntToStr_JOH_IA32_4(Value: integer): string; assembler asm
  push ebx; push edi; push esi
  mov ebx, eax; mov edi, edx                //value / result address
  sar ebx, 31                               //0 = positive, -1 = negative
  xor eax, ebx; sub eax, ebx                //abs(value)
  mov edx, 10                               //default digit count
  cmp eax, d04; jae @@5orMoreDigits
  cmp eax, d02; jae @@3or4Digits
  cmp eax, d01; mov dl, 2; jmp @@SetLength  //1 or 2 digits
@@3or4Digits:
  cmp eax, d03; mov dl, 4; jmp @@SetLength  //3 or 4 digits
@@5orMoreDigits:
  cmp eax, d06; jae @@7orMoreDigits
  cmp eax, d05; mov dl, 6; jmp @@SetLength  //5 or 6 digits
@@7orMoreDigits:
  cmp eax, d08; jae @@9or10Digits
  cmp eax, d07; mov dl, 8; jmp @@SetLength  //7 or 8 digits
@@9or10Digits: cmp eax, d09                 //9 or 10 digits
@@SetLength:
  sbb edx, ebx                          //digits including sign character
  mov ecx, [edi]                        //result
  mov esi, edx                          //digits including sign character
  test ecx, ecx; je @@Alloc             //result not already allocated}
  cmp dword[ecx-8], 1; jne @@Alloc      //reference count <> 1
  cmp edx, [ecx-4]; je @@SizeOk         //existing length = required length
@@Alloc:
  push eax                       //abs(value)
  mov eax, edi
  call system.@LStrSetLength     //create result string}
  pop eax                        //abs(value)
@@SizeOk:
  mov edi, [edi]                 //@Result
  add esi, ebx                   //digits excluding sign character
  mov byte[edi], '-'             //store '-' (DASH) (may be overwritten)
  sub edi, ebx                   //destination of 1st digit
  sub esi, 2                     //digits (excluding sign character) minus 2
  jle @@FinalDigits              //1 or 2 digits
  mov ecx, _032                  //multiplier for division by 100

@@Loop:
  mov ebx, eax                   //dividend
  mul ecx; shr edx, 5            //dividend div 100
  mov eax, edx                   //set next dividend
  lea edx, [edx*4+edx];
  lea edx, [edx*4+edx];
  shl edx, 2                     //dividend div 100 mul 100
  sub ebx, edx                   //dividend mod 100
  sub esi, 2
  //movzx ebx, word[deca+ebx*2]
  //mov [edi+esi+2], bx
  mov ebx, dword[deca+ebx*2]
  mov [edi+esi+2], bl; mov [edi+esi+3], bh
  jg @@Loop                      //loop until 1 or 2 digits remaining

@@FinalDigits:
  jnz @@LastDigit
  //movzx eax, word[deca+eax*2]
  //mov [edi], ax                //save final 2 digits
  mov eax, dword[deca+eax*2]
  mov [edi], al; mov [edi+1], ah
  jmp @@Done
@@LastDigit:
  add al , '0'                   //ascii adjustment
  mov [edi], al                  //save the final digit
@@Done: pop esi; pop edi; pop ebx
end;

const
  //JOH_IA32_4_MinInt64s: string = '-9223372036854775808';
  d10_hi = $02; d10_lo = $0540BE400;
  d11_hi = $017; d11_lo = $04876E800;
  d12_hi = $0E8; d12_lo = $0D4A51000;
  d13_hi = $0918; d13_lo = $04E72A000;
  d14_hi = $05AF3; d14_lo = $0107A4000;
  d15_hi = $038D7E; d15_lo = $0A4C68000;
  d16_hi = $02386F2; d16_lo = $06FC10000;
  d17_hi = $01634578; d17_lo = $05D8A0000;
  d18_hi = $0DE0B6B3; d18_lo = $0A7640000;
  d19_hi = $08AC72304; d19_lo = $089E80000;

function IntToStr64_JOH_IA32_4(Value: Int64): string; overload asm
  mov ecx, Value.r64.lo//[ebp+8]  //Low integer of value
  mov edx, Value.r64.hi//[ebp+12] //High integer of value
  test ecx, ecx; jnz @@CheckValue
  cmp edx, 1 shl 31; jnz @@CheckValue
  //mov edx, SMinInt64; call system.@LStrAsg; jmp @@Exit
  mov ecx, 20; mov edx, PMinInt64; call system.@LStrFromPCharLen; jmp @@Exit

@@CheckValue: push ebx; xor ebp, ebp//clear sign flag (ebp already pushed)}
  mov ebx, ecx                      //low part of int64
  test edx, edx; jnl @@AbsValue
  mov ebp, 1                        //ebp 1 = negative, 0 = positive
  neg ecx; adc edx, 0; neg edx
@@AbsValue:                         //edx:ecx = abs(value)
  test edx, edx; jnz @@Large
  test ecx, ecx; js @@Large
  mov edx, eax; mov eax, ebx        //@Result
  call IntToStr_JOH_IA32_4          //call fast integer inttostr function
  pop ebx

@@Exit: pop ebp; ret 8               //restore stack and exit

@@Large: push edi; push esi;
  mov edi, eax; xor ebx, ebx; xor eax, eax

@@Test15:                            //test for 15 or more digits
  cmp edx, d14_hi; jne @@Check15     //1e14
  cmp ecx, d14_lo

@@Check15: jb @@Test13

@@Test17:                            //test for 17 or more digits
  cmp edx, d16_hi; jne @@Check17     //1e16
  cmp ecx, d16_lo

@@Check17: jb @@Test15or16

@@Test19:                            //test for 19 digits
  cmp edx, d18_hi; jne @@Check19     //1e18
  cmp ecx, d18_lo

@@Check19:jb @@Test17or18
  mov al, 19; jmp @@SetLength

@@Test17or18: mov bl, 18             //17 or 18 digits
  cmp edx, d17_hi; jne @@SetLen      //1e17
  cmp ecx, d17_lo; jmp @@SetLen

@@Test15or16: mov bl, 16             //15 or 16 digits
  cmp edx, d15_hi; jne @@SetLen      //1e15
  cmp ecx, d15_lo; jmp @@SetLen

@@Test13:                            //test for 13 or more digits
  cmp edx, d12_hi; jne @@Check13     //1e12
  cmp ecx, d12_lo

@@Check13: jb @@Test11

@@Test13or14: mov bl, 14             //13 or 14 digits
  cmp edx, d13_hi; jne @@SetLen      //1e13
  cmp ecx, d13_lo;jmp @@SetLen

@@Test11: {10, 11 or 12 Digits}
  cmp edx, d10_hi; jne @@Check11     //1e10
  cmp ecx, d10_lo

@@Check11: mov bl, 11;
  jb @@SetLen {10 Digits}

@@Test11or12: mov bl, 12             //11 or 12 digits
  cmp edx, d11_hi; jne @@SetLen      //1e11
  cmp ecx, d11_lo

@@SetLen: sbb eax, 0; add eax, ebx   //adjust for odd/even digit count}

@@SetLength:                         //abs(value) in edx:ecx, digits in eax
  push ecx; push edx                 //save abs(value)}
  lea edx, [eax+ebp]                 //digits needed including sign character
  mov ecx, [edi]                     //@Result
  mov esi, edx                       //digits needed including sign character

  test ecx, ecx; je @@Alloc          //result not already allocated
  cmp dword[ecx-8], 1; jne @@Alloc   //reference count <> 1
  cmp edx, [ecx-4]; je @@SizeOk      //existing length = required length

@@Alloc:
  push eax; mov eax, edi             //abs(value)
    call system.@LStrSetLength       //create result string
  pop eax                            //abs(value)
@@SizeOk:
  mov edi, [edi]                     //@Result
  sub esi, ebp                       //digits needed excluding sign character
  mov byte[edi], '-'                 //store '-' character (may be overwritten)
  add edi, ebp                       //destination of 1st digit
  pop edx; pop eax                   //restore abs(value)

  cmp esi, 17;
    jl @@LessThan17Digits            //digits < 17
    je @@SetDigit17                  //digits = 17
  cmp esi, 18; je @@SetDigit18       //digits = 18

@@SetDigit19: mov cl, '0' - 1;
  mov ebx, d18_lo; mov ebp, d18_hi   //1e18
@@CalcDigit19:
  add ecx, 1; sub eax, ebx; sbb edx, ebp; jnc @@CalcDigit19
  add eax, ebx; adc edx, ebp; mov [edi], cl; add edi, 1
@@SetDigit18: mov cl, '0' - 1;
  mov ebx, d17_lo; mov ebp, d17_hi   //1e17
@@CalcDigit18:
  add ecx, 1; sub eax, ebx; sbb edx, ebp; jnc @@CalcDigit18
  add eax, ebx; adc edx, ebp; mov [edi], cl; add edi, 1
@@SetDigit17: mov cl, '0' - 1;
  mov ebx, d16_lo; mov ebp, d16_hi   //1e16
@@CalcDigit17:
  add ecx, 1; sub eax, ebx; sbb edx, ebp; jnc @@CalcDigit17
  add eax, ebx; adc edx, ebp;
  mov [edi], cl; add edi, 1          //update destination
  mov esi, 16                        //set 16 digits left

@@LessThan17Digits:                  //process next 8 digits
  mov ecx, d08; div ecx              //edx:eax = abs(value) = dividend

  mov ebp, eax; mov ebx, edx         //dividend div 100000000
  mov eax, edx; mov edx, _032        //dividend mod 100000000
  mul edx; shr edx, 5                //dividend div 100
  mov eax, edx                       //set next dividend
  lea edx, [edx*4+edx]
  lea edx, [edx*4+edx]
  shl edx, 2                         //dividend div 100 mul 100
  sub ebx, edx                       //remainder (0..99)
  movzx ebx, word[deca+ebx*2]
  shl ebx, 16
  mov edx, _032; mov ecx, eax        //dividend
  mul edx; shr edx, 5                //dividend div 100
  mov eax, edx
                                     //dividend div 100 mul 100
  lea edx, [edx*4+edx];
  lea edx, [edx*4+edx];
  shl edx, 2

  sub ecx, edx                       //remainder (0..99)
  or bx, word[deca+ecx*2]

  mov [edi+esi-4], ebx               //store 4 digits
  mov ebx, eax; mov edx, _032
  mul edx; shr edx, 5                //edx := dividend div 100
  lea eax, [edx*4+edx];
  lea eax, [eax*4+eax]
  shl eax, 2                         //edx = dividend div 100 * 100
  sub ebx, eax                       //remainder (0..99)
  movzx ebx, word[deca+ebx*2]
  movzx ecx, word[deca+edx*2]
  shl ebx, 16; or ebx, ecx
                                     //mov ebx, dword[deca+ebx*2]
                                     //mov ecx, dword[deca+edx*2]
                                     //shl ebx, 16; mov bx, cx
  mov [edi+esi-8], ebx               //store 4 digits
  mov eax, ebp                       //remainder
  sub esi, 10                        //digits left -2
  jz @@Last2Digits
@@SmallLoop:                         //process remaining digits
  mov edx, _032; mov ebx, eax        //dividend
  mul edx; shr edx, 5                //edx := dividend div 100
  mov eax, edx                       //set next dividend
  lea edx, [edx*4+edx]
  lea edx, [edx*4+edx]
  shl edx, 2                         //edx = dividend div 100 mul 100
  sub ebx, edx                       //remainder (0..99)}
  sub esi, 2
  movzx ebx, word[deca+ebx*2]
                                     //mov ebx, dword[deca+ebx*2]
  mov [edi+esi+2], bx
  jg @@SmallLoop                     //repeat until less than 2 digits remaining
  jz @@Last2Digits
  add al, '0'; mov [edi], al         //save final digit
  jmp @@Done
@@Last2Digits:
  movzx eax, word[deca+eax*2]
                                     //mov eax, dword[deca+eax*2]
  mov [edi], ax                      //save final 2 digits
@@Done: pop esi; pop edi; pop ebx
end;

function uintostr(const I: Integer): string; overload assembler asm
  push ebx; push edi; push esi
  mov ebx, eax; mov edi, edx                //value / result address
  //sar ebx, 31                             //0 = positive, -1 = negative
  //xor eax, ebx; sub eax, ebx              //abs(value)
  //xor ebx,ebx
  mov edx, 10                               //default digit count
  cmp eax, d04; jae @@5orMoreDigits
  cmp eax, d02; jae @@3or4Digits
  cmp eax, d01; mov dl, 2; jmp @@SetLength  //1 or 2 digits
@@3or4Digits:
  cmp eax, d03; mov dl, 4; jmp @@SetLength  //3 or 4 digits
@@5orMoreDigits:
  cmp eax, d06; jae @@7orMoreDigits
  cmp eax, d05; mov dl, 6; jmp @@SetLength  //5 or 6 digits
@@7orMoreDigits:
  cmp eax, d08; jae @@9or10Digits
  cmp eax, d07; mov dl, 8; jmp @@SetLength  //7 or 8 digits
@@9or10Digits: cmp eax, d09                 //9 or 10 digits
@@SetLength:
  sbb edx, 0                                //digits including sign character
  mov ecx, [edi]                            //@Result
  mov esi, edx                              //digits including sign character
  test ecx, ecx; je @@Alloc                 //result not already allocated
  cmp dword[ecx-8], 1; jne @@Alloc          //reference count <> 1
  cmp edx, [ecx-4]; je @@SizeOk             //existing length = required length
@@Alloc:
  push eax; mov eax, edi                    //abs(value)
  call system.@LStrSetLength                //create result string
  pop eax                                   //abs(value)
@@SizeOk:
  mov edi, [edi]                            //@Result}
  //add esi, ebx                              //digits excluding sign character
  //mov byte[edi], '-'                        //store '-' character (may be overwritten)
  //sub edi, ebx                              //destination of 1st digit
  sub esi, 2; jle @@FinalDigits             //digits (excluding sign character) -2
  mov ecx, _032                             //multiplier for division by 100

@@Loop:
  mov ebx, eax                              //dividend
  mul ecx; shr edx, 5                       //dividend div 100
  mov eax, edx                              //set next dividend
  lea edx, [edx*4+edx];
  lea edx, [edx*4+edx];
  shl edx, 2                                //dividend div 100 mul 100
  sub ebx, edx                              //dividend mod 100
  sub esi, 2
  movzx ebx, word[deca+ebx*2]
  //mov ebx, dword[deca+ebx*2]
  mov [edi+esi+2], bx; jg @@Loop            //loop until 1 or 2 digits remaining

@@FinalDigits: jnz @@LastDigit
  movzx eax, word[deca+eax*2]
  //mov eax, dword[deca+eax*2]
  mov [edi], ax; jmp @@Done                 //save final 2 digits
@@LastDigit: add al, '0'; mov [edi], al     //save the final digit
@@Done: pop esi; pop edi; pop ebx
end;

//unsigned int64, also based heavily on JOH's work

function uintostr(const I: uInt64): string; overload asm
  mov ecx,I.r64.lo; mov edx,I.r64.hi;
  //test edx,edx; jnz @@begin
  //mov edx,eax; mov eax,ecx
  //call uintoStr; jmp @@exit
@@begin:
  test ecx, ecx; jnz @@CheckValue
  cmp edx, 1 shl 31; jnz @@CheckValue
  //mov edx, SMinInt64; call system.@LStrAsg; jmp @@Exit
  //mov edx, SMinInt64; call system.@LStrFromPChar; jmp @@Exit
  mov ecx, 20; mov edx, PMinInt64;
  call system.@LStrFromPCharLen; jmp @@Exit

@@CheckValue: push ebx; xor ebp, ebp //clear sign flag (ebp already pushed)
  mov ebx, ecx                       //low part of int64
  //test edx, edx; jnl @@AbsValue
  //mov ebp, 1                         //ebp 1 = negative, 0 = positive
  //neg ecx; adc edx, 0; neg edx
@@AbsValue:                          //edx:ecx = abs(value)
  test edx, edx; jnz @@Large
  //test ecx, ecx; js @@Large
  mov edx, eax; mov eax, ebx         //@Result
  //call IntToStr_JOH_IA32_4           //call fast integer inttostr function
  //the 32bit version of uintostr declaration MUST be put over/above int64's
  call uintostr; pop ebx
@@Exit: pop ebp; ret 8               //restore stack and exit

@@Large: push edi; push esi;
  mov edi, eax; xor ebx, ebx; xor eax, eax
@@Test15: cmp edx, d14_hi; jne @@Check15; cmp ecx, d14_lo
@@Check15: jb @@Test13
@@Test17: cmp edx, d16_hi; jne @@Check17; cmp ecx, d16_lo
@@Check17: jb @@Test15or16
@@Test19: cmp edx, d18_hi; jne @@Check19; cmp ecx, d18_lo
@@Check19:jb @@Test17or18
  //mov al, 19; jmp @@SetLength
  mov bl, 20;
  cmp edx, d19_hi; jne @@SetLen
  cmp eax, d19_lo; jmp @@SetLen

@@Test17or18: mov bl, 18             //17 or 18 digits
  cmp edx, d17_hi; jne @@SetLen      //1e17
  cmp ecx, d17_lo; jmp @@SetLen

@@Test15or16: mov bl, 16             //15 or 16 digits
  cmp edx, d15_hi; jne @@SetLen      //1e15
  cmp ecx, d15_lo; jmp @@SetLen

@@Test13:                            //test for 13 or more digits
  cmp edx, d12_hi; jne @@Check13     //1e12
  cmp ecx, d12_lo

@@Check13: jb @@Test11

@@Test13or14: mov bl, 14             //13 or 14 digits
  cmp edx, d13_hi; jne @@SetLen      //1e13
  cmp ecx, d13_lo; jmp @@SetLen

@@Test11: //10, 11 or 12 Digits
  cmp edx, d10_hi; jne @@Check11     //1e10
  cmp ecx, d10_lo

@@Check11: mov bl, 11; jb @@SetLen   //10 digits

@@Test11or12: mov bl, 12             //11 or 12 digits
  cmp edx, d11_hi; jne @@SetLen      //1e11
  cmp ecx, d11_lo

@@SetLen: sbb eax, 0; add eax, ebx   //adjust for odd/even digit count

@@SetLength:                         //abs(value) in edx:ecx, digits in eax
  push ecx; push edx                 //save abs(value)
  //lea edx, [eax+ebp]               //digits needed (including sign character)
  mov edx, eax
  mov ecx, [edi]; mov esi, edx       //digits needed (including sign character)

  test ecx, ecx; je @@Alloc          //result not already allocated
  cmp dword[ecx-8], 1; jne @@Alloc   //reference count <> 1
  cmp edx, [ecx-4]; je @@SizeOk      //existing length = required length

@@Alloc:
  push eax; mov eax, edi             //abs(value)
  call system.@LStrSetLength         //create result string
  pop eax                            //abs(value)
@@SizeOk:
  mov edi, [edi]                     //@result
  //sub esi, ebp                       //digits needed (excluding sign character)
  //mov byte[edi], '-'                 //store '-' character (may be overwritten)
  //add edi, ebp                       //destination of 1st digit
  pop edx; pop eax                   //restore abs(value)

  cmp esi, 17;
    jl @@LessThan17Digits            //digits < 17
    je @@SetDigit17                  //digits = 17

  cmp esi, 19;
    jl @@SetDigit18  //Digits = 18
    je @@SetDigit19  //Digits = 19

@@SetDigit20:  mov cl, '0' - 1;
  mov ebx, d19_lo; mov ebp, d19_hi           //1e19
@@CalcDigit20:
  add ecx, 1; sub eax, ebx; sbb edx, ebp; jnc @@CalcDigit20
  add eax, ebx; adc edx, ebp; mov [edi], cl; add edi, 1

@@SetDigit19: mov cl, '0' - 1;
  mov ebx, d18_lo; mov ebp, d18_hi            //1e18
@@CalcDigit19:
  add ecx, 1; sub eax, ebx; sbb edx, ebp; jnc @@CalcDigit19
  add eax, ebx; adc edx, ebp; mov [edi], cl; add edi, 1

@@SetDigit18: mov cl, '0' - 1;
  mov ebx, d17_lo; mov ebp, d17_hi            //1e17
@@CalcDigit18:
  add ecx, 1; sub eax, ebx; sbb edx, ebp; jnc @@CalcDigit18
  add eax, ebx; adc edx, ebp; mov [edi], cl; add edi, 1

@@SetDigit17: mov cl, '0' - 1;
  mov ebx, d16_lo; mov ebp, d16_hi            //1e16
@@CalcDigit17: add ecx, 1; sub eax, ebx; sbb edx, ebp; jnc @@CalcDigit17

  add eax, ebx; adc edx, ebp;
  mov [edi], cl; add edi, 1     //update destination
  mov esi, 16                   //set 16 digits left

@@LessThan17Digits:             //process next 8 digits
  mov ecx, d08; div ecx         //edx:eax = abs(value) = dividend
  mov ebp, eax; mov ebx, edx    //dividend div 100000000
  mov eax, edx; mov edx, _032   //dividend mod 100000000
  mul edx; shr edx, 5           //dividend div 100
  mov eax, edx                  //set next dividend
  lea edx, [edx*4+edx]
  lea edx, [edx*4+edx]
  shl edx, 2                    //dividend div 100 * 100
  sub ebx, edx                  //remainder (0..99)
  movzx ebx, word[deca+ebx*2]
  shl ebx, 16; mov edx, _032
  mov ecx, eax                  //dividend
  mul edx; shr edx, 5           //dividend div 100
  mov eax, edx
  lea edx, [edx*4+edx]
  lea edx, [edx*4+edx]
  shl edx, 2                    //dividend div 100 * 100
  sub ecx, edx                  //remainder (0..99)
  or bx, word[deca+ecx*2]

  mov [edi+esi-4], ebx          //store 4 digits
  mov ebx, eax; mov edx, _032
  mul edx; shr edx, 5           //edx := dividend div 100
  lea eax, [edx*4+edx];
  lea eax, [eax*4+eax]
  shl eax, 2                    //edx = dividend div 100 mul 100
  sub ebx, eax                  //remainder (0..99)
  movzx ebx, word[deca+ebx*2]
  movzx ecx, word[deca+edx*2]
  shl ebx, 16; or ebx, ecx
  //mov ebx, dword[deca+ebx*2]  // i thought using dword access (msb zeroed already)
  //mov ecx, dword[deca+edx*2]  // rather than movzx would be faster
  //shl ebx, 16; mov bx, cx     // to my suprise- that was not true.
                                // why? i really dont know

  mov [edi+esi-8], ebx          //store 4 digits
  mov eax, ebp                  //remainder
  sub esi, 10                   //digits left -2
  jz @@Last2Digits
@@SmallLoop:                    //process remaining digits
  mov edx, _032; mov ebx, eax   //dividend
  mul edx; shr edx, 5           //edx := dividend div 100
  mov eax, edx                  //set next dividend
  lea edx, [edx*4+edx]
  lea edx, [edx*4+edx]
  shl edx, 2                    //edx = dividend div 100 mul 100
  sub ebx, edx                  //remainder (0..99)
  sub esi, 2
  movzx ebx, word[deca+ebx*2]
  //mov ebx, dword[deca+ebx*2]
  mov [edi+esi+2], bx
  jg @@SmallLoop                //repeat until less than 2 digits remaining
  jz @@Last2Digits
  add al, '0'; mov [edi], al    //save final digit
  jmp @@Done
@@Last2Digits:
  movzx eax, word[deca+eax*2]
  //mov eax, dword[deca+eax*2]
  mov [edi], ax                 //save final 2 digits
@@Done: pop esi; pop edi; pop ebx
end;

procedure fastMove(const Source; var Dest; Count: Integer); assembler asm
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

procedure __move1(const esi; var edi; ecx: Integer); assembler asm
// based on fastCode fastMove
// internal use! // source: esi, destination: edi
// destroys: ecx,edx, preserved: eax,esi,edi
  cmp esi,edi; jz @@exit;
  cmp ecx,20h; ja @@move;   //caution! also of (Count < 0)
  sub ecx,08h; jg @@QQ;     //1Q+1 upto 3Q
  jmp ecx*4+20h+@@dbJmp;    //upto 1Q
@@QQ: fild qword[esi]; fild qword[esi+ecx];  //firstQ/lastQ
  cmp ecx,08; jle @@2Q; fild qword[esi+8];   //2nd*Q?
  cmp ecx,10h; jle @@3Q;
  fild qword[esi+10h]; fistp qword[edi+10h]; //3rd*Q
@@3Q: fistp qword[edi+08h];                  //2nd*Q
@@2Q: fistp qword[edi+ecx];                  //lastQ
@@1Q: fistp qword[edi]; ret                  //1st*Q
@@move: jng @@exit; mov edx,edi; //skip neg
  cmp esi,edi; ja @@fmove;
  sub edx,ecx; cmp esi,edx;
  lea edx,edx+ecx; jna @@fmove;
  fild qword[esi+ecx-8]; fild qword[esi];   //LAST-Q/firstQ
  sub ecx,8; push ecx;                      //backward
  add ecx,edx; and ecx,not 7; sub ecx,edx;  //Q-aligned
  @@LoopQBack: fild qword[esi+ecx]; fistp qword[edx+ecx];
     sub ecx,8; jg @@LoopQBack; pop ecx;
  fistp qword[edi]; fistp qword[edi+ecx]; ret;  //FIRST-Q/lastQ
@@fmove:
  push eax; lea eax,esi+ecx-8;
  lea ecx,ecx+edx-8; push ecx;
  neg ecx; add ecx,edx;
  pop edx; add ecx,8; //Q-aligned
  fild qword[esi]; fild qword[eax];         //firstQ/lastQ
  @@LoopQ1: fild qword[eax+ecx]; fistp qword[edx+ecx];
    add ecx,8; jl @@LoopQ1; pop eax;
  fistp qword[edx]; fistp qword[edi]; ret //lastQ/firstQ
@@dbJmp: dd @@exit, @@1, @@2, @@3, @@4, @@5, @@6, @@7, @@8
@@1: mov  cl,[esi]; mov [edi], cl; ret
@@2: mov  cx,[esi]; mov [edi], cx; ret
@@4: mov ecx,[esi]; mov [edi],ecx; ret
@@3: mov  dx,[esi]; mov  cl,[esi+2]; mov [edi], dx; mov [edi+2], cl; ret
@@5: mov edx,[esi]; mov  cl,[esi+4]; mov [edi],edx; mov [edi+4], cl; ret
@@6: mov edx,[esi]; mov  cx,[esi+4]; mov [edi],edx; mov [edi+4], cx; ret
@@7: mov edx,[esi]; mov ecx,[esi+3]; mov [edi],edx; mov [edi+3],ecx; ret
@@8: fild [esi].qword; fistp [edi].qword; //ret
@@exit:
end;

procedure __move2(const esi; var edi; ecx: Integer); assembler asm
// based on fastCode fastMove
// internal use! // source: esi, destination: edi
// destroys: ecx,eax, preserved: edx,esi,edi
  cmp esi,edi; jz @@exit;
  cmp ecx,20h; ja @@move;   //caution! also of (Count < 0)
  sub ecx,08h; jg @@QQ;     //1Q+1 upto 3Q
  jmp ecx*4+20h+@@dbJmp;    //upto 1Q
@@QQ: fild qword[esi]; fild qword[esi+ecx];  //firstQ/lastQ
  cmp ecx,08; jle @@2Q; fild qword[esi+8];   //2nd*Q?
  cmp ecx,10h; jle @@3Q;
  fild qword[esi+10h]; fistp qword[edi+10h]; //3rd*Q
@@3Q: fistp qword[edi+08h];                  //2nd*Q
@@2Q: fistp qword[edi+ecx];                  //lastQ
@@1Q: fistp qword[edi]; ret                  //1st*Q
@@move: jng @@exit; mov eax,edi; //skip neg
  cmp esi,edi; ja @@fmove;
  sub eax,ecx; cmp esi,eax;
  lea eax,eax+ecx; jna @@fmove;
  fild qword[esi+ecx-8]; fild qword[esi];   //LAST-Q/firstQ
  sub ecx,8; push ecx;                      //backward
  add ecx,eax; and ecx,not 7; sub ecx,eax;  //Q-aligned
  @@LoopQBack: fild qword[esi+ecx]; fistp qword[eax+ecx];
     sub ecx,8; jg @@LoopQBack; pop ecx;
  fistp qword[edi]; fistp qword[edi+ecx]; ret;  //FIRST-Q/lastQ
@@fmove:
  push edx; lea edx,esi+ecx-8;
  lea ecx,ecx+eax-8; push ecx;
  neg ecx; add ecx,eax;
  pop eax; add ecx,8; //Q-aligned
  fild qword[esi]; fild qword[edx];         //firstQ/lastQ
  @@LoopQ1: fild qword[edx+ecx]; fistp qword[eax+ecx];
    add ecx,8; jl @@LoopQ1; pop edx;
  fistp qword[eax]; fistp qword[edi]; ret //lastQ/firstQ
@@dbJmp: dd @@exit, @@1, @@2, @@3, @@4, @@5, @@6, @@7, @@8
@@1: mov  cl,[esi]; mov [edi], cl; ret
@@2: mov  cx,[esi]; mov [edi], cx; ret
@@4: mov ecx,[esi]; mov [edi],ecx; ret
@@3: mov  ax,[esi]; mov  cl,[esi+2]; mov [edi], ax; mov [edi+2], cl; ret
@@5: mov eax,[esi]; mov  cl,[esi+4]; mov [edi],eax; mov [edi+4], cl; ret
@@6: mov eax,[esi]; mov  cx,[esi+4]; mov [edi],eax; mov [edi+4], cx; ret
@@7: mov eax,[esi]; mov ecx,[esi+3]; mov [edi],eax; mov [edi+3],ecx; ret
@@8: fild [esi].qword; fistp [edi].qword; //ret
@@exit:
end;

procedure __move0(const esi; var edi; ecx: Integer); assembler asm
// based on fastCode fastMove
// internal use! // source: esi, destination: edi
// destroys: ecx, preserved: eax,edx,esi,edi
  cmp esi,edi; jz @@exit;
  cmp ecx,20h; ja @@move;   //caution! also of (Count < 0)
  sub ecx,08h; jg @@QQ;     //1Q+1 upto 3Q
  jmp ecx*4+20h+@@dbJmp;    //upto 1Q
@@QQ: fild qword[esi]; fild qword[esi+ecx];  //firstQ/lastQ
  cmp ecx,08; jle @@2Q; fild qword[esi+8];   //2nd*Q?
  cmp ecx,10h; jle @@3Q;
  fild qword[esi+10h]; fistp qword[edi+10h]; //3rd*Q
@@3Q: fistp qword[edi+08h];                  //2nd*Q
@@2Q: fistp qword[edi+ecx];                  //lastQ
@@1Q: fistp qword[edi]; ret                  //1st*Q
@@move: jng @@exit; //skip neg
  push edx; mov edx,edi; cmp esi,edi; ja @@fmove;
  sub edx,ecx; cmp esi,edx;
  lea edx,edx+ecx; jna @@fmove;
  fild qword[esi+ecx-8]; fild qword[esi];   //LAST-Q/firstQ
  sub ecx,8; push ecx;                      //backward
  add ecx,edx; and ecx,not 7; sub ecx,edx;  //Q-aligned
  @@LoopQBack: fild qword[esi+ecx]; fistp qword[edx+ecx];
     sub ecx,8; jg @@LoopQBack;
  pop ecx; pop edx;
  fistp qword[edi]; fistp qword[edi+ecx]; ret;  //FIRST-Q/lastQ
@@fmove:
  push eax; lea eax,esi+ecx-8;
  lea ecx,ecx+edx-8; push ecx;
  neg ecx; add ecx,edx;
  pop edx; add ecx,8; //Q-aligned
  fild qword[esi]; fild qword[eax];         //firstQ/lastQ
  @@LoopQ1: fild qword[eax+ecx]; fistp qword[edx+ecx];
    add ecx,8; jl @@LoopQ1;
  fistp qword[edx]; pop eax; pop edx;
  fistp qword[edi]; ret //lastQ/firstQ
@@dbJmp: dd @@exit, @@1, @@2, @@3, @@4, @@5, @@6, @@7, @@8
@@1: mov  cl,[esi]; mov [edi], cl; ret
@@2: mov  cx,[esi]; mov [edi], cx; ret
@@4: mov ecx,[esi]; mov [edi],ecx; ret
@@3: push edx; mov  dx,[esi]; mov  cl,[esi+2]; mov [edi], dx; pop edx; mov [edi+2], cl; ret
@@5: push edx; mov edx,[esi]; mov  cl,[esi+4]; mov [edi],edx; pop edx; mov [edi+4], cl; ret
@@6: push edx; mov edx,[esi]; mov  cx,[esi+4]; mov [edi],edx; pop edx; mov [edi+4], cx; ret
@@7: push edx; mov edx,[esi]; mov ecx,[esi+3]; mov [edi],edx; pop edx; mov [edi+3],ecx; ret
@@8: fild [esi].qword; fistp [edi].qword; //ret
@@exit:
end;

procedure fastFillChar(var Dest; const Count: Integer; const Value: char); overload asm
//fastCode (John O'Harrow) fast! fillChar
  cmp edx,32; mov ch,cl; jl @@Small
  mov [eax  ],cx; mov [eax+2],cx
  mov [eax+4],cx; mov [eax+6],cx
  sub edx,10h; fld qword ptr [eax]
  fst qword ptr [eax+edx]; fst qword ptr [eax+edx+8]
  mov ecx,eax; and ecx,7; sub ecx,8
  sub eax,ecx; add edx,ecx;
  add eax,edx; neg edx
@@Loop:
  fst qword ptr [eax+edx]; fst qword ptr [eax+edx+8];
  add edx,10h; jl @@Loop
  fstp st; ret; lea ecx,ecx+0
@@Small: test edx,edx; jle @@Done
  mov [eax+edx-1],cl
  and edx,not 1; neg edx
  lea edx,[@@SmallFill + 60 + edx * 2]
  jmp edx; mov eax,eax
@@SmallFill:
  mov [eax+28],cx; mov [eax+26],cx
  mov [eax+24],cx; mov [eax+22],cx
  mov [eax+20],cx; mov [eax+18],cx
  mov [eax+16],cx; mov [eax+14],cx
  mov [eax+12],cx; mov [eax+10],cx
  mov [eax+ 8],cx; mov [eax+ 6],cx
  mov [eax+ 4],cx; mov [eax+ 2],cx
  mov [eax   ],cx; ret;//alignment
@@Done:
end;

function Int64Div(var X, Y: Int64): Int64; //fastCode
asm
 fnstcw esp-16; mov cx,esp-16;
 or cx,1111b shl 8; mov esp-8,cx
 fldcw word ptr esp-8
 fild qword ptr X.0; fild qword ptr Y.0
 fdivp; mov ecx,esp
 and ecx,not 7; fistp qword ptr ecx-8
 //wait //no-need
 fldcw word ptr esp-16 //restore controlword
 mov eax,ecx-8; mov edx,ecx-4
end;

function uInt64DivMod(var Dividend: uInt64; const Divisor: uInt64): uInt64;
// caution! result is quotient; var Dividend REPLACED by modulo
{ // Original code: Norbert Juffa (ref. by: John Eckerdal's asm Gems)
 input:  edx:eax = dividend; ecx:ebx = divisor
 output: edx:eax = quotient; ecx:ebx = remainder
}
asm
@@Start: push esi; push edi; push ebx
  mov ebx,Divisor.r64.lo; mov ecx,Divisor.r64.hi
  mov ebp,eax
  mov edx,ebp.r64.hi; mov eax,ebp.r64.lo;
@@begin:
  test ecx,ecx; jnz @@big_div ;// divisor > 2^32-1 ?
  cmp edx,ebx; jb @@one_div   ;// only one division needed ? (ecx = 0)
  mov ecx,eax; mov eax,edx    ;// save dividend-lo in ecx; get dividend-hi
  xor edx,edx; div ebx        ;// zero extend it into edx:eax; quotient-hi in eax
  xchg eax,ecx                ;// ecx = quotient-hi, eax =dividend-lo
@@one_div:
  div ebx; mov ebx,edx        ;// eax = quotient-lo; ebx = remainder-lo
  mov edx,ecx; xor ecx,ecx    ;// edx = quotient-hi(quotient in edx:eax)
  jmp @@end                   ;// ecx = remainder-hi (rem. in ecx:ebx)
@@big_div:
  push edx; push eax          ;// save dividend
  mov esi,ebx; mov edi,ecx    ;// divisor now in edi:ebx and ecx:esi
  shr edx,1;rcr eax,1         ;// shift right divisor
  ror edi,1;rcr ebx,1         ;//   and dividend by 1 bit
  bsr ecx,ecx                 ;// ecx = number of remaining shifts
  shrd ebx,edi,cl             ;// scale down divisor and
  shrd eax,edx,cl             ;//   dividend such that divisor
  shr edx,cl                  ;//    less than 2^32 (i.e. fits in ebx)
  rol edi,1                   ;// restore original divisor (edi:esi)
  div ebx; pop ebx            ;// compute quotient // get dividend lo-word
  mov ecx,eax                 ;// save quotient
  imul edi,eax                ;// quotient * divisor hi-word (low only)
  mul esi                     ;// quotient * divisor lo-word
  add edx,edi                 ;// edx:eax = quotient * divisor
  sub ebx,eax                 ;// dividend-lo - (quot.*divisor)-lo
  mov eax,ecx; pop ecx        ;// get quotient; restore dividend hi-word
  sbb ecx,edx                 ;// subtract divisor * quot. from dividend
  sbb edx,edx                 ;// 0 if remainder > 0, else FFFFFFFFh
  and esi,edx; and edi,edx    ;// nothing to add back if remainder positive
  add ebx,esi; adc ecx,edi    ;// correct remaider and quotient if necessary
  add eax,edx; xor edx,edx    ;// clear hi-word of quot (eax<=FFFFFFFFh)
@@end:
  //mov ebp.r64.lo,eax; mov ebp.r64.hi,edx
  //mov eax,ebx; mov edx,ecx
  mov ebp.r64.lo,ebx; mov ebp.r64.hi,ecx
@@Stop: pop ebx; pop edi; pop esi
end;

function BCDAdd(const A, B: int64): int64;
// another Juffa's trick (ref. by: Paul Hsieh asm. Lab)
const
  hex = $66666666; oct = $88888888;
asm
  push esi;
  mov eax,A.r64.lo; mov edx,A.r64.hi;
  mov ecx,B.r64.lo; mov ebp,B.r64.hi;
  mov esi,eax     ;// x
  lea edi,eax+hex ;// x + 0x66666666
  xor esi,ecx     ;// x ^ y
  add eax,ecx     ;// x + y
  shr esi,1       ;// t1 = (x ^ y) >> 1
  add edi,ecx     ;// x + y + 0x66666666
  sbb ecx,ecx     ;// capture carry
  rcr edi,1       ;// t2 = (x + y + 0x66666666) >> 1
  xor esi,edi     ;// t1 ^ t2
  and esi,oct     ;// t3 = (t1 ^ t2) & 0x88888888
  add eax,esi     ;// x + y + t3
  shr esi,2       ;// t3 >> 2
  sub eax,esi     ;// x + y + t3 - (t3 >> 2)
  //
  sub edx,ecx     ;// propagate carry
  mov esi,edx     ;// x
  lea edi,edx+hex ;// x + 0x66666666
  xor esi,ebp     ;// x ^ y
  add edx,ebp     ;// x + y
  shr esi,1       ;// t1 = (x ^ y) >> 1
  add edi,ebp     ;// x + y + 0x66666666
  //? sbb esi,esi   ;// capture carry
  rcr edi,1       ;// t2 = (x + y + 0x66666666) >> 1
  xor esi,edi     ;// t1 ^ t2
  and esi,oct     ;// t3 = (t1 ^ t2) & 0x88888888
  add edx,esi     ;// x + y + t3
  shr esi,2       ;// t3 >> 2
  sub edx,esi     ;// x + y + t3 - (t3 >> 2)
  pop esi
end;

function uInt64Div(var Dividend: uInt64; const Divisor: uInt64): uInt64;
// result is quotient; var Dividend REPLACED by modulo
asm jmp uInt64DivMod end;

function uInt64Mod(var Dividend: uInt64; const Divisor: uInt64): uInt64;
// result is modulo; var Dividend REPLACED by quotient
asm
  push esi; mov esi,eax
  mov edx,Divisor.r64.hi; mov ecx,Divisor.r64.lo
  push edx; push ecx; call uInt64DivMod
  //xchg edx,[ecx+4]; xchg eax,[ecx]
  mov ecx,eax; mov eax,[esi  ]; mov [esi  ],ecx;
  mov ecx,edx; mov edx,[esi+4]; mov [esi+4],ecx;
  pop esi
end;

function UniqCharList(const S: string): string; asm
  push esi; mov esi,S;
  push edi; mov edi,Result;
  mov eax,Result; call System.@LStrClr
  test esi,esi; jz @@ends;

  mov edx,[esi-4]; push edx;
  call System.@LStrSetLength

  mov edi,[edi]; xor edx,edx;
  pop ecx; mov eax,[esi-4];
  mov dl,[esi]; add esi,ecx;
  mov [edi],dl; sub ecx,1;
  setne dl; jz @@ends;

  neg ecx; push ebx; push eax;
  @@Loop: push edi;
    mov ebx,edx; mov al,[esi+ecx];
    @@ckpos: mov ah,[edi]; add edi,1; cmp ah,al; jz @@posnx;
      sub edx,1; jnz @@ckpos;
      mov [edi],al; inc ebx;
    @@posnx: pop edi; mov edx,ebx; inc ecx; jnz @@Loop

  pop ebx; lea eax,esp-4; sub ebx,edx; jz @@done
  push edi; call System.@LStrSetLength; pop edi;

  @@done: pop ebx;
  @@ends: pop edi; pop esi;
end;

function UniqIntList(const Integers: TIntegers): TIntegers;
var
  _typeInfo: pointer absolute typeInfo(TIntegers);
asm
  push esi; mov esi,Integers;
  push edi; mov edi,Result;
  mov eax,Result; mov edx,_typeInfo;
  call System.@DynArrayClear
  test esi,esi; jz @@ends;

  mov edx,[esi-4]; push 1; pop ecx;
  push edx; mov edx,_typeInfo
  call System.@DynArraySetLength

  mov edi,[edi]; pop ecx; // also adjust stack
  mov edx,[esi]; mov eax,ecx;
  mov [edi],edx; xor edx,edx
  sub ecx,1; setne dl; jz @@ends;

  push ebp; push ebx;
  lea esi,esi+ecx*4+4; neg ecx;
  push eax; xor ebx,ebx;
  @@Loop: push edi;
    mov ebx,edx; mov eax,[esi+ecx*4];
    @@ckpos: mov ebp,[edi]; add edi,4; cmp ebp,eax; jz @@posnx;
      sub edx,1; jnz @@ckpos;
      mov [edi],eax; inc ebx;
    @@posnx: pop edi; mov edx,ebx; inc ecx; jnz @@Loop

  pop ebx; lea eax,esp-4;
  sub ebx,edx; jz @@done

  push edi; push 1; pop ecx;
  push edx; mov edx,_typeInfo;
  call System.@DynArraySetLength;
  add esp,8 // must be manually popped

  @@done: pop ebx; pop ebp;
  @@ends: pop edi; pop esi;
end;

// ====================================================================
// EXPERIMENT AREA; TRY AND ERROR, AND ERROR, AND ERROR, AND ERROR,....
// --------------------------------------------------------------------

const
  HIBIT = $80;
  //SPACE = ' ';
  BANG = ord(succ(SPACE));

function __findNonWhiteSpace(const S: string): integer;
const
  k1 = cardinal(not 0) div 255 * (127 - ord(SPACE));
  k2 = cardinal(int64(cardinal(not 0) div 255) * HIBIT);
asm
  test eax,eax; jz @@Stop
  mov ecx,[eax-4]; push ebx;
  push ecx; xor ecx,ecx
  @@Loop:
    mov ebx,[eax]; add eax,4;
    mov edx,ebx; add ebx,k1
    or edx,ebx; add ecx,4;
    and edx,k2; jz @@Loop;

  bsf eax,edx;
  shr eax,3; sub ecx,4;
  // 0 = -4;                                            c
  // 1 = -3;
  // 2 = -2;
  // 3 = -1;
  add eax,ecx; pop ecx;

  // Length MUST be > pos
  cmp eax,ecx; sbb ecx,ecx
  and eax,ecx; sub eax,ecx; // add 1 if valid (not zero)

  pop ebx;
  @@Stop:
end;

function __findWhiteSpace(const S: string): integer;
const
  k1 = cardinal(not 0) div 255 * BANG;
  k2 = cardinal(int64(cardinal(not 0) div 255) * HIBIT);
asm
  test eax,eax; jz @@Stop
  mov ecx,[eax-4]; push ebx;
  push ecx; xor ecx,ecx
  @@Loop:
    mov ebx,[eax]; add eax,4;
    mov edx,ebx; not ebx;
    sub edx,k1; and ebx,k2;
    add ecx,4; and edx,ebx;
  jz @@Loop;

  bsf eax,edx;
  shr eax,3; sub ecx,4;
  // 0 = -4;
  // 1 = -3;
  // 2 = -2;
  // 3 = -1;
  add eax,ecx; pop ecx;

  // Length MUST be > pos
  cmp eax,ecx; sbb ecx,ecx
  and eax,ecx; sub eax,ecx; // add 1 if valid (not zero)

  pop ebx;
  @@Stop:
end;

// --------------------------------------------------------------------
// END EXPERIMENT AREA
// ====================================================================
end.


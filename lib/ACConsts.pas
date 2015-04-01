unit ACConsts;
{$G+}
{$I QUIET.INC}
{
  Copyright (c) 2004, aa, Inge DR. & Adrian Hafizh.
  Property of PT SOFTINDO Jakarta.
  All rights reserved.

  mailto: aa\\AT@|s.o.f.t,i.n.d.o|DOT-net,
  mailto (dont strip underbar): zero_inge\AT/\y.a,h.o.o\@DOT\\com
  http://delphi.softindo.net

  Version: 2.0.0
  Dated: 2005.12.01
  significant change: uses Types (D7+)
}

{$DEFINE USES_TYPES}
{.$DEFINE USES_SYSUTILS_6UP}// not everyone in everywhere using the omnipotent sysutils

{ These types mess do not affect functionality, for example, this unit using System.TBoundArray
  as baseclass for TIntegers, you can always force typecast them to SysUtils.PIntegerArray or
  Types.IntegerDynArray without any harm (unless as so intented by your code, of course.) }

{$J-} // these are truly constants sortpack
interface
{$IFDEF Delphi6_up}{$IFDEF USES_TYPES}uses Types; {$ENDIF}{$ENDIF}
const
  CR_ = #10;
  LF_ = #13;
  CRLF = #13#10;
  CR2 = #10#10;
  CRLF2 = CRLF + CRLF;
  CHAR_TAB = #9;
  CHAR_COLON = ':';
  CHAR_DOT = '.';
  CHAR_DASH = '-';
  CHAR_SLASH = '/';
  CHAR_BACKSLASH = '\';
  CHAR_STAR = '*';
  CHAR_SPACE = ' ';
  CHAR_ZERO = '0';
  CHAR_COMMA = ',';
  QT = ''''; QT2 = ''''''; // used by stupid SQ-isit?-L

  COMMA = CHAR_COMMA;
  SPACE = CHAR_SPACE;
  COMMASPACE = CHAR_COMMA + CHAR_SPACE;
  COLONSPACE = CHAR_COLON + CHAR_SPACE;

  DEFAULT_DELIMITER = COMMA;

  TAB = CHAR_TAB;
  TAB2 = TAB + TAB;
  TABCT = TAB + CHAR_COLON + TAB;
  TABCS = TAB + CHAR_COLON + CHAR_SPACE;

  ESCAPE = #27;
  BKSPACE = #8;
  BACKSPACE = BKSPACE;

  //CR2: string[2] = CR_ + CR_;
  //TAB2: string[2] = TAB + TAB;
  //CRLF2: string[4] = CRLF + CRLF;

  YES = TRUE;
  NAY = not TRUE;
  OFF = not TRUE;
  // OOH = not YES; NOO = OOH; //that means OOH-NOO equal with NAY

  IYA = TRUE;
  Enggak = not IYA;
  GAK = Enggak;

  DECIMAL_DIGIT = ['0'..'9'];
  NUMERIC = DECIMAL_DIGIT;

  HEXLOCASE = NUMERIC + ['a'..'f'];
  HEXUPCASE = NUMERIC + ['A'..'F'];

  HEXDIGITS = HEXLOCASE + HEXUPCASE;

  ALPHALOCASE = ['a'..'z'];
  ALPHAUPCASE = ['A'..'Z'];

  ALPHABET = ALPHALOCASE + ALPHAUPCASE;
  ALPHANUMERIC = ALPHABET + NUMERIC;

  COMMON_NAVIGATIONKEYS = [BACKSPACE, TAB, CR_, LF_, ESCAPE];

  DEFAULT_BLOCKDIGITS = 5;
  DEFAULT_DELIMITERS = [',', '.', '-', ' ', ':', '/', '=']; //[',', '.', '-', ' ',':','/'];

  //var
  //  __DELIMITERS: set of char = DEFAULT_DELIMITERS;
  //  __HEXNUM_UPPERCASE: string[16] = '0123456789ABCDEF';
  //  __HEXNUM_LOWERCASE: string[16] = '0123456789abcdef';

  __CRC32Poly__ = $EDB88320; // widely used CRC32 Polynomial
  __AAMAGIC0__ = $19091969; // my birthdate
  __AAMAGIC1__ = $22101969; // my wife's birthdate
  __AAMAGIC2__ = $09022004; // my (first) son's birthdate
  __AAMAGIC3__ = $04012006; // my second son's
  __AAKEY1__ = int64(__AAMAGIC1__) shl 32 or __AAMAGIC0__;
  __AAKEY2__ = int64(__CRC32Poly__) shl 32 or __AAMAGIC2__;
  _1K = 1024;
  _1M = _1K * _1K;

  _Error_ = 'Error ';
  Elipsis = '...';
  Unknown = 'Unknown';

type
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

  TChar_AlphaUpCase = 'A'..'Z';
  TChar_AlphaLoCase = 'a'..'z';
  TChar_Numeric = '0'..'9';
  TChar_HexLoCase = 'a'..'f';
  TChar_HexUpCase = 'A'..'F';
  TChar_Control = #0..#$1F;

  TKeyVal = packed record
    Key, Value: integer;
  end;

  TWords = packed array of word;
  TArWords = packed array of TWords;
  {$IFNDEF Delphi6_up}
  TBoundArray = packed array of integer; //uncomment this for D5 and below
  {$ENDIF}

  {$IFDEF USES_TYPES}
  TIntegers = Types.TIntegerDynArray;
  TInts = Types.TIntegerDynArray;
  TInts64 = Types.TInt64DynArray;
  TStrs = Types.TStringDynArray;
  TBools = Types.TBooleanDynArray;
  {$ELSE}
  TIntegers = TBoundArray;
  TInts = TBoundArray;
  TInts64 = packed array of int64;
  TStrs = packed array of string;
  TBools = packed array of boolean;
  {$ENDIF}

  TArInts = packed array of TIntegers;
  TKeyVals = packed array of TKeyVal;

  PPointers = ^TPointers;
  TPointers = array[0..0] of pointer;
  TPtrs = TPointers;
  TPtrPairs = TInts64;
  //TIntPtrs = packed array of ^integer;
  //TInt64Ptrs = packed array of ^int64;
  //TStrPtrs = packed array of ^string;

  PInt64Array = ^Int64Array;
  PIntegerArray = ^IntegerArray;
  IntegerArray = array[Word] of integer;
  Int64Array = array[Word] of int64;
  PCardinal = ^Cardinal;

  {$IFNDEF USES_SYSUTILS_6UP}
  PWordArray = ^TWordArray;
  {$IFDEF USES_TYPES}TWordArray = Types.TWordDynArray;
  {$ELSE}TWordArray = packed array[0..16 * _1K - 1] of Word;
  {$ENDIF}

  PByteArray = ^TByteArray;
  {$IFDEF USES_TYPES}TByteArray = Types.TByteDynArray;
  {$ELSE}TByteArray = packed array[0..32 * _1K - 1] of Byte;
  {$ENDIF}

  PInteger = ^Integer;
  PInt64 = ^Int64;
  PWord = ^Word;
  PByte = ^Byte;

  PCurrency = ^Currency;
  PDouble = ^Double;
  PSingle = ^Single;
  PExtended = ^Extended;
  {$ENDIF}
const
  MaxCardinal = 4294967295; // high(Cardinal), 10 digits
  MaxInt64 = 9223372036854775807; // high(Int64), 19 digits
  MaxCardinal64S = '18446744073709551615'; // unsigned Int64, 20 digits
  MaxInt64x = $7FFFFFFFFFFFFFFF;
  EXTPI = 3.141592653589793238462643383279502884197169399375105820974944592307;
  _1e19 = $8AC7230489E80000; // -8446744073709551616
  //_1e18 = $0DE0B6B3A7640000;
  //SMinInt64: string = '-9223372036854775808';

procedure ClearStrs(var Strs: TStrs);
procedure ClearArInts(var ArInts: TArInts);

{ caution setlenZ do preserve any previous content! }
{ only extra length will be initialized zero        }
procedure SetlenZ(var Ints: TInts; NewLength: integer); overload;
procedure SetlenZ(var KeyVals: TKeyVals; NewLength: integer); overload;

function IntsPos(const I: integer; const Ints: TInts): integer;
function IntsPosEx(const I: integer; const Ints: TInts; const StartPos: integer = 0): integer;
function IntsCat(const Ints1, Ints2: TInts): TInts;

procedure IntsAdd(var Ints: TInts; I: Integer); overload;
procedure IntsAdd(var Ints: TInts; I: Integer; const MinValue: Integer); overload;
//procedure IntsAdd(var Ints: TInts; I: Integer; const MinValue: Integer = -MaxInt - 1; MaxValue: integer = MaxInt);
procedure IntsAdd(var Ints: TInts; I: Integer; const MinValue: Integer; MaxValue: integer); overload;

type
  TMatchElementType = (metAny, metFirst, metLast, metNearest);
  // if there are more than one matched items, TMatchElementType controls
  //   which one of them would be taken as result
  //
  // - metFirst seeks the first index of matched item in the sorted-list
  // - metLast seeks the last index of matched item in the sorted-list
  // - metAny gives the first item found by this routine, but not necessarily
  //   as the first-item (the lowest index of matched items)
  // - metNearest
  //
  // if there is only one item that matched (as in the unique list),
  // those three will give equal results

  // TCompareFunction
  TCompareConstAB = function(const A, B): integer;

function _IndexOf(const Value: integer; var SortedInts: Tints;
  const MatchFor: TMatchElementType = metAny): integer; overload;

function _IndexOf(const Value; var SortedInts: TInts; const Compare: TCompareConstAB;
  const MatchFor: TMatchElementType = metAny): integer; overload;

function _findValue(const PList: PPointers; const Value; out gotIndex: integer;
  const firstIndex, LastIndex: integer; const Compare: TCompareConstAB;
  const MatchFor: TMatchElementType = metAny): boolean;
// note: in any case if Result = FALSE then gotIndex will point to:
// 1. the first value greater than the value to be searched for (X), or
// 2. the last value lower than X, if (1) is not available

// means that if all PList elements are less than [Value] then
// Result will FALSE and gotIndex = LastIndex+1 (out of index),
// and if all PList elements are greater than [Value] then Result
// will FALSE and gotIndex = 0 (index of the first greater Value)

implementation
{$ALIGN ON}
const
  TABLE_HEXDIGITS: packed array[0..31] of char = '0123456789ABCDEF0123456789abcdef';
  TABLE_HEXDIGITS2: packed array[0..1023] of char = '0123456789ABCDEF0123456789abcdef';

  // MUST be power of 2 of range 256 to 32K ($100..$8000);
  RECIPROCAL_INT_ELEMENTS = $400;

type
  TReciprocalInt = packed array[0..RECIPROCAL_INT_ELEMENTS - 1] of cardinal;
  TReciprocalInt64 = packed array[0..RECIPROCAL_INT_ELEMENTS - 1] of Int64;

var // these are actually global constants
  //ReciprocalInt64: packed array[0..RECIPROCAL_INT_ELEMENTS - 1] of int64;
  //ReciprocalInt: packed array[0..RECIPROCAL_INT_ELEMENTS - 1] of cardinal;
  PReciprocalInt: ^TReciprocalInt;
  PReciprocalInt64: ^TReciprocalInt64;

  //implementation

procedure ClearStrs(var Strs: TStrs);
var
  i: integer;
begin
  for i := 0 to high(Strs) do
    Strs[i] := '';
  setlength(Strs, 0);
end;

procedure ClearArInts(var ArInts: TArInts);
var
  i: integer;
begin
  for i := 0 to high(ArInts) do
    setlength(ArInts[i], 0);
  setlength(ArInts, 0);
end;

procedure SetLenZ(var Ints: TInts; NewLength: integer);
var
  i: integer;
begin
  i := length(Ints);
  setlength(Ints, newLength);
  if i < newLength then
    for i := i to newLength - 1 do
      Ints[i] := 0;
end;

procedure SetLenZ(var KeyVals: TKeyVals; NewLength: integer);
var
  i: integer;
begin
  i := length(KeyVals);
  setlength(KeyVals, newLength);
  if i < newLength then
    for i := i to newLength - 1 do
      TInts64(KeyVals)[i] := 0;
end;

function IntsPos(const I: integer; const Ints: TInts): integer; assembler asm
  test Ints, Ints; jnz @begin
  mov eax, -1; ret
  @begin: push esi; xor esi, esi
    mov ecx, [Ints-4]
  @Loop: cmp [Ints+esi*4], eax; je @found
    inc esi; dec ecx; jg @Loop
  @notfound: mov esi, -1
  @found: mov eax, esi
  @end: pop esi
end;

function IntsPosEx(const I: integer; const Ints: TInts; const StartPos: integer = 0): integer; assembler asm
  test Ints, Ints; jz @zero
  or StartPos, StartPos; jge @begin
  @zero: mov eax, -1; ret
  @begin: push esi; mov esi, StartPos
    sub StartPos, [Ints-4]; jge @notfound
  @Loop: cmp [Ints+esi*4], eax; je @found
    inc esi; inc ecx; jl @Loop
  @notfound: mov esi, -1
  @found: mov eax, esi
  @end: pop esi
end;

procedure _bri(const Buffer; const Int64Size: boolean); assembler asm
  test eax, eax; jnz @@Start; ret
@@Start: push edi; push ebx; mov edi, [eax]
  mov eax, 1 shl 31; xor ecx, ecx
  and edx, 1               // make sure it's either 0 or 1
  //lea edx, edx*4+4       // how many bytes
  //lea edx, edx*8-1       // how many bits (in-excess of 1)
  mov edx, -1
  mov [edi], ecx; mov [edi+4], eax
  mov [edi+8], edx; mov [edi+12], edx
  mov [edi+16], ecx; mov [edi+20], eax
  jnz @@1; mov [edi], eax; mov [edi+4], edx; mov [edi+8], eax

@@1: setnz cl
  lea eax, [ecx*4]           //equ above
  lea eax, eax*8+31          //equ above
  ; push eax
  fld1; fst st(1); fadd st, st
  fild dword[esp]
  ; pop eax
  fld st(1); fscale
  fsub st, st(3)             //dec-by-one
  fstp st(1)

@preLoop: xor ebx, ebx; mov bl, 3
    @Loop:
    //                    // BEFORE              |  AFTER
    //1: high(I) div n    // st0  st1  st2  st3  |  st0  st1  st2  st3
       fld st(2)          //  X    n    1    -   |   1    X    n    1
       fadd st, st(2)     //  1    X    n    1   |  n+1   X    n    1
       fst st(2)          // n+1   X    n    1   |  n+1   X   n+1   1
       fdivr st, st(1)    //

    //2: high(I) added by (n-1) before divided by n
    //  fld st(2)
    //  fadd st, st(2)
    //  fst st(2)
    //  fld
    //  fadd
    //  fdiv st, st(2)

    //fistp qword[esp]; mov eax, [esp]; mov edx, [esp+4]
    //test cl,1; jnz @8
    //  @4: mov edi+ebx*4, eax; jmp @Loope
    //  @8: mov edi+ebx*8, eax; mov edi+ebx*8+4, edx

    test cl,1; jnz @8
      @4: fistp dword ptr[edi+ebx*4]; jmp @Loope
      @8: fistp qword ptr[edi+ebx*8]

    @Loope: inc ebx;  test bh, RECIPROCAL_INT_ELEMENTS shr 8; jz @Loop
    fstp st(1); fstp st(1); ffree st
  @@Stop: pop ebx; pop edi
end;

procedure _buildReciprocalInt;
begin
  getmem(PReciprocalInt, sizeof(PReciprocalInt^));
  getmem(PReciprocalInt64, sizeof(PReciprocalInt64^));
  //fillchar(PReciprocalInt^, sizeof(PReciprocalInt^), $11);
  //fillchar(PReciprocalInt64^, sizeof(PReciprocalInt64^), $11);
  _bri(PReciprocalInt, FALSE);
  _bri(PReciprocalInt64, TRUE);
end;

procedure _buildhexcharset; assembler asm
  xor ecx, ecx
  @loop1: mov eax, ecx; mov ah, al
    shr al, 04h; and ah, 0fh
    cmp al, 9; jbe @upAL; add al, 'A'-'0'-10
    @upAL: add al, '0'
    cmp ah, 9; jbe @upAH; add ah, 'A'-'0'-10
    @upAH: add ah, '0'
    mov word [TABLE_HEXDIGITS2+ecx*2], ax
  inc cl; jnz @loop1

  @loop2: mov eax, ecx; mov ah, al
    shr al, 04h; and ah, 0fh
    cmp al, 9; jbe @loAL; add al, 'a'-'0'-10
    @loAL: add al, '0'
    cmp ah, 9; jbe @loAH; add ah, 'a'-'0'-10
    @loAH: add ah, '0'
    mov word [TABLE_HEXDIGITS2+ecx*2+512], ax
  inc cl; jnz @loop2

end;

procedure XMove(const Src; var Dest; Count: integer); assembler asm
// effective only for bulk transfer, moving 4 bytes at the speed of 1,
// pairing enabled, no AGI-stalls
    push esi; push edi
    mov esi, Src; mov edi, Dest
    mov ecx, Count; mov eax, ecx
    sar ecx, 2; js @@end
    push eax; jz @@recall
  @@LoopDWord:
    mov eax, [esi]; lea esi, esi +4
    mov [edi], eax; lea edi, edi +4
    dec ecx; jg @@LoopDWord
  @@recall: pop ecx
    and ecx, 03h; jz @@LoopDone
  @@LoopByte:
    mov al, [esi]; lea esi, esi +1
    mov [edi], al; lea edi, edi +1
    dec ecx; jg @@LoopByte
  @@LoopDone:
  @@end: pop edi; pop esi
end;

function IntsCat(const Ints1, Ints2: TInts): TInts;
begin
end;

procedure IntsAdd(var Ints: TInts; I: Integer); overload;
var
  n: cardinal;
begin
  n := length(Ints);
  setlength(Ints, n + 1);
  Ints[n] := I;
end;

procedure IntsAdd(var Ints: TInts; I: Integer; const MinValue: Integer); overload;
var
  n: cardinal;
begin
  if (I >= MinValue) then begin
    n := length(Ints);
    setlength(Ints, n + 1);
    Ints[n] := I;
  end;
end;

procedure IntsAdd(var Ints: TInts; I: Integer; const MinValue: Integer; MaxValue: integer); overload;
var
  n: cardinal;
begin
  if (I >= MinValue) and (I <= MaxValue) then begin
    n := length(Ints);
    setlength(Ints, n + 1);
    Ints[n] := I;
  end;
end;

// sample locate

// by this algorithm, greater value is COMPARED FIRST, which produces an
// unobvious impact, that is, any final NOTFOUND index will point to:
// 1. the first value greater than the value to be searched for (X), or
// 2. the last value lower than X, if (1) is not available

// to prevent endless-loop.
// - index-range/block must be checked first against 1 (single element)
// - i and j loop check should NOT include equality
// - top-limit (j) is NOT decreased at the end of loop
// - midval point to the first half of search block, NOT the second one,
//     means k := (i+j) div 2, NOT k := (i+j+1) div 2

// end value of loop (both i or j) should be assigned to result (in this
// context is: k) so it will always be available on any arbitrary exit.

function _IndexOf(const Value: integer; var SortedInts: TInts;
  const MatchFor: TMatchElementType = metAny): integer; overload;
var
  i, j, k: integer;
  n: integer;
begin
  Result := -1;
  j := high(TInts(SortedInts));
  if j < 1 then begin
    if (j = 0) and (TInts(SortedInts)[0] = integer(Value)) then
      Result := 0;
  end
  else begin
    i := 0;
    while i < j do begin
      k := (i + j) div 2;
      n := TInts(SortedInts)[k];
      if n = integer(Value) then begin
        if MatchFor = metFirst then begin
          j := k; // i is index of value below
          while i < j do begin
            k := (i + j) div 2;
            if TInts(SortedInts)[k] = integer(Value) then j := k
            else i := k + 1 // any differences must be < value
          end;
          Result := j;
        end
        else if MatchFor = metLast then begin
          i := k; // j is index of value above
          while i < j do begin
            k := (i + j + 1) div 2; // to match high should be +1
            if TInts(SortedInts)[k] = integer(Value) then i := k
            else j := k - 1 // any differences must be > value
          end;
          Result := i;
        end
        else // metAny
          Result := k;
        break;
      end
      else if integer(Value) > n then begin
        inc(k); i := k // + 1 // shift up bottom-index
      end
      else
        j := k //- 1 // shift-down top-index
    end;
  end;
end;

// sample locate with custom compare

function _IndexOf(const Value; var SortedInts: TInts; const Compare: TCompareConstAB;
  const MatchFor: TMatchElementType = metAny): integer; overload;
var
  i, j, k: integer;
  r: integer;
begin
  Result := -1;
  j := high(TInts(SortedInts));
  if j < 1 then begin
    if Compare(Value, TInts(SortedInts)[0]) = 0 then
      Result := 0;
  end
  else begin
    i := 0;
    while i <= j do begin
      k := (i + j) div 2;
      r := Compare(Value, TInts(SortedInts)[k]);
      if r = 0 then begin
        if MatchFor = metFirst then begin
          j := k;
          while i < j do begin
            k := (i + j) div 2;
            if Compare(Value, TInts(SortedInts)[k]) = 0 then j := k
            else i := k + 1 // any differences must be less than value
          end;
          Result := j;
        end
        else if MatchFor = metLast then begin
          i := k;
          while i < j do begin
            k := (i + j + 1) div 2; // to match high should be +1
            if Compare(Value, TInts(SortedInts)[k]) = 0 then i := k
            else j := k - 1 // any differences must be greater than value
          end;
          Result := i;
        end
        else // metAny
          Result := k;
        break;
      end
      else if r > 0 then begin
        inc(k); i := k
      end
      else j := k
    end;
  end
end;

function _findValue(const PList: PPointers; const Value; out gotIndex: integer;
  const firstIndex, LastIndex: integer; const Compare: TCompareConstAB;
  const MatchFor: TMatchElementType = metAny): boolean;
//note: if all PList elements are less than Value then
//        Result will FALSE and gotIndex = LastIndex+1 (out of index)
//      if all PList elements are greater than Value then
//        Result will FALSE and gotIndex = 0 (index of the first greater Value)
const
  NOTFOUND = -MAXINT - 1;
var
  i, j, k: integer;
  r: integer; // compare function
begin
  Result := FALSE;
  if firstIndex >= LastIndex then begin
    gotIndex := LastIndex;
    if firstIndex = LastIndex then begin
      r := compare(Value, PList^[gotIndex]);
      if r > 0 then inc(gotIndex)
      else Result := r = 0;
    end;
  end
  else begin
    gotIndex := NOTFOUND;
    i := firstIndex; j := LastIndex;
    k := -1; r := -1;
    while i < j do begin
      k := (i + j) div 2;
      r := Compare(Value, PList^[k]); // compare function
      if r = 0 then begin
        gotIndex := k;
        Result := TRUE;
        case matchFor of
          metFirst: if k > firstIndex then begin
              j := k; // iii assumed to be an index of value below (or invalid)
              while i < j do begin
                k := (i + j) div 2;
                //if Value = (PList^[k])^.ddeRoot then
                r := Compare(Value, PList^[k]); // compare function
                if r = 0 then
                  j := k
                else
                  i := k + 1 // any differences must be < value
              end;
              gotIndex := j;
            end;
          metLast: if k < lastIndex then begin
              i := k; // jjj assumed to be an index of value above (or invalid)
              while i < j do begin
                k := (i + j + 1) div 2;
                //if Value = (PList^[k])^.ddeRoot then
                r := Compare(Value, PList^[k]); // compare function
                if r = 0 then
                  i := k
                else
                  j := k - 1 // any differences must be > value
              end;
              gotIndex := i;
            end;
        else ; // [metNearest, metAny]
        end;
        break;
      end
      else if r > 0 then begin
        inc(k); i := k // + 1
      end
      else
        j := k
    end;
    if not Result then begin
      if (k = LastIndex) and (r > 0) then inc(k);
      gotIndex := k;
    end;
  end;
end;

procedure init;
begin
  _buildhexcharset;
  _buildReciprocalInt
end;

initialization init;

end.


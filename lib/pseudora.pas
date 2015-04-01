unit pseudora;
{$WEAKPACKAGEUNIT ON}
{$J-} //no-writeableconst
{$R-} //no-rangechecking
{$Q-} //no-overflowchecking
{.$D-}//no-debug
{
  Random unit

  Copyright (c) 2004, aa, Inge DR. & Adrian Hafizh.
  Property of PT SOFTINDO Jakarta.
  All rights reserved.

  http://delphi.softindo.net

  Version: 1.0.0.0
  LastUpdated: 2005.03.1
}

interface

// initialize pseudo-random generator
procedure RadoInit(const I: integer = 19091969); register

function RadoExt: Extended; register
function RadoInt64: int64; register overload

// random result: from 0 to Max-1, thus giving value below 2 is no sense
// (see also difference with Min-Max below)
function RadoInt(const Max: cardinal): cardinal; register overload

// random result: from Min (inclusive) to Max (inclusive)
function RadoInt(const Min, Max: integer): integer; register overload

// rabin-miller primality test, stolen from JEDI :)
function IsPrime(const N: cardinal): Boolean;

{
type
  TRandInfo = packed record
    case integer of
      1: (b0, b1, b2, b3, b4, b5, b6, b7, b8, b9,
        b10, b11, b12, b13, b14, b15, b16, b17, b18, b19: byte);
      2: (w0, w1, w2, w3, w4, w5, w6, w7, w8, w9: word);
      3: (I0, I1, I2, I3, I4: integer);
      4: (X0, X1: int64; y: integer);
      5: (Data: packed array[0..19] of char);
  end;

const
  RandSeedEx: TRandInfo = (X0: 0; X1: 0; y: 0);
}

function floatHuge: extended;
function floatTiny: extended;

const
  RandseedEx: array[0..4] of integer = (19091969, 22101969, 09022004, 10022006, -1);

implementation

var
  factors: array[boolean] of int64 = ($13FB7DD4FFC7, 7627861919189 - 1);
  X: integer absolute RandSeedEx;
  f: integer absolute factors;

// The random functions is originated from Uniform Random Number Generator.
// Copyrighted by Agner Fog, http://www.agner.org/random. Licensed under GNU GPL.
// (we did small fix of floating issue, promote double to extended, rearrange seed
// to accomodate direct int64 result, refine min/max range, etc. Delphi's specific)
function Shuffle: int64; register asm
  push edi

  mov eax, f.0; mul X.$10             // x4
  mov ecx, eax; mov eax, X.$C         // x3

  mov edi, edx

  mov X.$10, eax; mul f.8
  add ecx,eax; mov eax, X.8           // x2

  adc edi, edx

  mov X.$C, eax; mul f.$C
  add ecx, eax; mov eax, X.0          // x0

  adc edi, edx

  mov X.8, eax; mul f.4

  add eax, ecx; adc edx, edi
  add eax, X.4; adc edx, 0

  mov X.0, eax; mov X.4, edx

  pop edi
end;

function RadoInt64: int64; register asm call Shuffle end;
function RadoInt(const Max: cardinal): cardinal; register asm
  test Max, -1; jnz @begin; ret
@begin: push Max; call Shuffle; pop edx
  mul edx; mov eax, edx
end;

function RadoInt(const Min, Max: integer): integer; register asm
// Min-Max range should not exceed cardinal boundary minus 1
// (max difference = 4294967295)
  sub max, min; jns @_
    xor eax, eax; ret  // zeronize
  @_: inc max          // difference = (max - min) +1
  push min; push max   // ...save
  call Shuffle         // get R
  pop edx; pop ecx     // ..restore
  mul edx              // multiply R by difference (truncated)
  lea eax, edx + ecx
end;

type
  ext = packed record
    lo, hi: integer;
    exp: word;
  end;

function RadoExt: Extended; register asm
  call Shuffle        // edx:eax
  or edx, 1 shl 31    // normalized bit-63 in edx
  mov Result.ext.lo, eax
  mov Result.ext.hi, edx
  mov Result.ext.exp, 3fffh
  fLd1               // load 1.0, since...
  fLd Result         // 1 < Result < 2
  fSubRP             // after sub, now 0 < Result < 1
  fStP Result        // store back
  wait
end;

{ Original version
  RandomDbl PROC NEAR
  public RandomDbl
    CALL    RandomBit            ; random bits
    MOV     EDX, EAX             ; fast conversion to float
    SHR     EAX, 12
    OR      EAX, 3FF00000H
    SHL     EDX, 20
    MOV     DWORD PTR [TEMP+4], EAX
    MOV     DWORD PTR [TEMP], EDX
    FLD1
    FLD     QWORD PTR [TEMP]     ; partial memory stall here
    FSUBR
    RET
  RandomDbl ENDP
}

procedure RadoInit(const I: integer = 19091969); register
const
  PRIME0 = 7;
  PRIME1 = $01C8E80D; // 29943821 : 1 1100 1000 1110 1000 0000 1101 ~ 1 11001000 11101000 00010101
  ex: extended = 0; // use extended *not* double
asm
  push edi; mov edi, 4
  @LFill:
    imul eax, PRIME1
    dec eax; mov X[edi*4], eax
    dec edi; jge @LFill

  mov edi, PRIME0
  @@LRand: call RadoExt
    fstp ex // note: for consistency, never directly alter X in RadoExt
    mov eax, ex.ext.lo; xor X, eax
    //warn: we might not use edx, since it has been convoluted.
    //      (the highest bit is always 1)
    //mov edx, e.ext.hi; mov X.4, edx
    dec edi; jnz @@LRand
  pop edi
end;

// lets play around with extended format
function float_HugePlus: extended; register asm
  //  $7FFE FFFF FFFF FFFF FFFF  //  +1.18973149535723176 e+4932
  mov dword ptr result, -1
  mov dword ptr result+4, -1
  mov word ptr result+8, $7ffe
end;

function float_HugeMinus: extended; register asm
  //  $FFFE FFFF FFFF FFFF FFFF  //  -1.18973149535723176 e+4932
  mov dword ptr result, -1
  mov dword ptr result+4, -1
  mov word ptr result+8, $fffe
end;

function float_TinyPlus: extended; register asm
  //  $0001 8000 0000 0000 0000  //  +3.36210314311209351 e-4932
  mov dword ptr result, 0
  mov dword ptr result+4, 1 shl 31
  mov word ptr result+8, 1
end;

function float_TinyMinus: extended; register asm
  //  $8001 8000 0000 0000 0000  //  -3.36210314311209351 e-4932
  mov dword ptr result, 0
  mov dword ptr result+4, 1 shl 31
  mov word ptr result+8, $8001
end;

// just an alias for float_HugePlus
function floatHuge: extended; register asm
  //  $7FFE FFFF FFFF FFFF FFFF  //  +1.18973149535723176 e+4932
  call float_HugePlus
end;

// just an alias for float_TinyPlus
function floatTiny: extended; register asm
  //  $0001 8000 0000 0000 0000  //  +3.36210314311209351 e-4932
  call float_TinyPlus
end;

//PI_float=$4000-c90f-daa2-2168-c235
//===================================================================
{ JCL's Rabin-Miller Strong Primality Test}
function isPrime(const N: cardinal): boolean; register asm
  test eax, 1; jnz @@1       // consider odd number only
  cmp eax, 2; sete al; ret   // prime even number is only 2

  @@1: cmp eax, 73; jbe @@c

  push esi; push edi; push ebx; push ebp

  push eax                   // save n as param for @@5
  lea ebp, [eax - 1]         // m == n -1, exponent
  mov ecx, 32                // calc remaining bits of m and shift m'
  mov esi, ebp

  @@2: dec ecx; shl esi, 1; jnc @@2

  push ecx; push esi         // save bits and m' as params for @@5

  cmp eax, 08a8d7fh; jae @@3 // n >= 9080191 ??

  // now if (n < 9080191) and spp(31, n) and spp(73, n) then n is prime
  mov eax, 31; call @@5; jc @@4

  mov eax, 73; push offset @@4; jmp @@5

  // now if (n < 4759123141) and spp(2, n) and spp(7, n) and spp(61, n) then n is prime
  @@3:
  mov eax, 2; call @@5; jc @@4
  mov eax, 7; call @@5; jc @@4
  mov eax, 61; call @@5

  @@4: setnc al; add esp, 4 * 3
  pop ebp; pop ebx; pop edi; pop esi; ret // emergency exit

  // do a strong pseudo prime test
  @@5: mov ebx, [esp + 12]   // n on stack
  mov ecx, [esp + 8]         // remaining bits
  mov esi, [esp + 4]         // m'
  mov edi, eax               // t = b, temp. base

  @@6: dec ecx
  mul eax; div ebx; mov eax, edx
  shl esi, 1; jnc @@7

  mul edi; div ebx
  and esi, esi; mov eax, edx

  @@7: jnz @@6
  cmp eax, 1; je @@a         // b^((n -1)(2^s)) mod n == 1 mod n ??

  @@8: cmp eax, ebp; je @@a  // b^((n -1)(2^s)) mod n == -1 mod n ??

  dec ecx; jng @@9           // second part to 2^s

  mul eax; div ebx
  cmp edx, 1; mov eax, edx; jne @@8

  @@9: stc
  @@a: ret
  @@b: db 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73

  @@c: mov edx, offset @@b; mov ecx, 19
  @@d: cmp al, [edx + ecx]; je @@e

  dec ecx; jnl @@d
  @@e: sete al
end;

end.


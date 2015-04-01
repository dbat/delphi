unit XRandom; //EXAC RANDOM GENERATOR
{$I QUIET.INC}

interface
uses ACConsts;
// - RANDOM -
// These pseudo random function will generates a predictive reproductable result (the same
// sequence of numbers) by the same RandSeed numbers or the same RandomInit argument.

// see notes below
function XRand64: int64;
function XRandEx: Extended;
function XRand(const Max: cardinal = high(cardinal)): cardinal; register overload
function XRand(const Min, Max: integer): integer; register overload

// remember to call this function first (and feed it in with your own exotic magic numbers)
// usually the argument is time-tick value; to produce an unpredictable numbers sequence
procedure XRandInit(const I: integer = __AAMAGIC0__); register

// All right then, you lazy... We give you Randomize function here at last :(
procedure XRandomizeEx;

// Shuffle: generate array of non repeatable integers of specified range in min..max (inclusive)
// the min/max value may be negative as long as min..max range (inclusive) does not exceed
// 2 GB boundary, no error checking, since the array itself would not even permit that huge.
// note that this function is NOT including initializing random (randomize), as the other
// random functions did, they will give a repeatable sequence if given the same init value
//function _Shuffle(Range: integer): TInts;
//function XShuffle(const Max: integer; const Min: integer = 0): TInts;
function Shuffle(const Max: integer): TIntegers; overload;
function XShuffle(const Min, Max: integer): TIntegers; overload;

const
{$J+}
  XRandSeedEx: array[0..4] of integer =
  (__AAMAGIC0__, __AAMAGIC1__, __AAMAGIC2__, integer(__CRC32Poly__), -1);
  // note that all of those magic numbers above will be trashed anyway upon init
  // presented just in case you forgot to call randomizeEx function
{$J-}

implementation
// ~~~~~~~~~~~~~~~~~~~~~~~
// Pseudo-random generator
// ~~~~~~~~~~~~~~~~~~~~~~~
var
  factors: array[boolean] of int64 = ($13FB7DD4FFC7, 7627861919189 - 1);
  X: integer absolute XRandSeedEx;
  f: integer absolute factors;

function RandCycle: int64; register asm
  push edi

  mov eax, f.0; mul X.16              // x4
  mov ecx, eax; mov eax, X.12         // x3
    mov edi, edx
  mov X.16, eax; mul f.8
  add ecx,eax; mov eax, X.8           // x2
    adc edi, edx
  mov X.12, eax; mul f.12
  add ecx, eax; mov eax, X.0          // x0
    adc edi, edx
  mov X.8, eax; mul f.4
    add eax, ecx; adc edx, edi
    add eax, X.4; adc edx, 0
  mov X.0, eax; mov X.4, edx          // x1

  pop edi
end;

function XRand64: int64; register asm call RandCycle end;

function XRand(const Max: cardinal): cardinal; register asm
  test Max, -1; jnz @begin; ret
@begin: push Max
  call RandCycle; pop edx
  mul edx; mov eax, edx
end;

function XRand(const Min, Max: integer): integer; register asm
// Result range in Min..Max inclusif
// Min-Max range should not exceed cardinal boundary minus 1
// (max difference = 4294967295)
  sub max, min; jns @_
    xor eax, eax; ret  // zeronize
  @_: inc max          // difference = (max - min) +1
  push min; push max   // ...save
  call RandCycle     // get R
  pop edx; pop ecx     // ..restore
  mul edx              // multiply R by difference (truncated)
  lea eax, edx + ecx
end;

type
  f80 = packed record // 80 bits extended floating point
    lo, hi: integer;
    exp: word;
  end;

function XRandEx: Extended; register asm
  call RandCycle     //  edx:eax
  or edx, 1 shl 31     //  normalized bit-63 in edx
  mov Result.f80.lo, eax
  mov Result.f80.hi, edx
  //wrong in D7: mov Result.f80.exp, -1 shr 18 // 3fffh
  //in D7 shr'ing -1 will always result in -1
  mov Result.f80.exp, 3fffh
  fLd1                 //  load 1.0, since...
  fLd Result           //  1 < Result < 2
  fSubrP               //  after sub, now 0 < Result < 1
  fStp Result          //  store back, pop!
  wait                 //  be polite, please...
end;

procedure XRandInit(const I: integer = __AAMAGIC0__); register
const
  PRIME0 = 7;
  PRIME1 = $01C8E80D; // 29943821 : 1 1100 1000 1110 1000 0000 1101 ~ 1 11001000 11101000 00010101
  e: extended = 0; // use extended to allow broader range of generated number
asm
  fInit            // this IS MANDATORY!
  push edi; mov edi, 4
  @LFill:
    imul eax, PRIME1
    dec eax; mov X[edi*4], eax
    dec edi; jge @LFill

  mov edi, PRIME0
  @@LRand: call XRandEx
    fstp e // note: for consistency, never directly alter X in RandomExt
    mov eax, e.f80.lo; xor X, eax
    //warn: we should not use edx, since it has been convoluted.
    //(the highest bit is always 1)
    //mov edx, e.ext.hi; mov X.4, edx
    dec edi; jnz @@LRand
  pop edi
end;

const
  CPUID = $A20F;
  RDTSC = $310F;

procedure XRandomizeEx; assembler asm
 {$IFDEF DELPHI_7_UP} // i dont know whether is D6 behave as D7?
 rdtsc
 {$ELSE}
 dw rdtsc
 {$ENDIF}
 call XRandInit
end; //rdtsc

function XShuffle(const Min, Max: integer): TIntegers; overload;
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
      n := XRand(i + 1, Range); // N = codomain
      m := Result[i];
      Result[i] := Result[n];
      Result[n] := m;
    end;
    if (Min <> 0) then
      for i := 0 to Range do
        Result[i] := Result[i] + Min
  end;
end;

function Shuffle(const Max: integer): TIntegers; overload;
begin
  XShuffle(0, Max);
end;

end.


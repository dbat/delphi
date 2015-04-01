unit MinMaxMid;
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
{
  Copyright (c) 2004, aa, Adrian H., Ray AF. & Inge DR.
  Property of PT SOFTINDO Jakarta.
  All rights reserved.

  mailto: aa\\AT@|s.o.f.t,i.n.d.o|DOT-net,
  mailto (dont strip underbar): zero_inge\AT/\y.a,h.o.o\@DOT\\com
  http://delphi.softindo.net

  synopsys:
    primitive function: min, max, mid, tuned for speed.
    get minimum, maximum or middle velue between 3 given values
    of nearly any integer type (including UNSIGNED int64).

  usage:
    Min and Max function need exactly 2 arguments,
    MinOf and MaxOf need at least 2 arguments, optionally 3
    Mid function requires all of 3 arguments

    function WordsMinMax/IntsMinMax returns minimum and
    maximum value from a Word/Integer array. also got an
    advantage in speed (it takes *below* 100ms to get result
    from +32 million elemen on my P4 2.4G)

  note:
    minmax is such a nearly useless library, the compiler itself
    usually producing (often very) good optimization result.

    in this library you may supply 3 values rather than 2,
    (useful if we intend to restrict user input by a specific range)
    this way it gives something more than just speed's gain.

    and we don't need powerful quicksort just to sort less than
    3 items, do we?

  caveat:
    because this unit overload nearly (actually it did) all of the
    ordinal bit wide of both signed/unsigned types with the same name,
    you'd better take a little care on what you will give for arguments.
    especially signed/unsigned type of the same bit wide, notably are
    byte/shortint and word/smallint.

    alternatively (this is what we strongly suggested: change the
    function names according to their respective arguments/result)

    also, ambiguous call error will almost always pops-up, you have
    to write full qualified function name to avoid this as:
    math.min(a, b) or minmaxmid.max(a, b)

  Dated: 2004.10.01

CHANGES
  Version: 1.2.3, last Update: 2005.02.07
  changed: function names: MidOf to (simply) Mid
  changed: function names: min/max to iMin/iMax (signed) or uMin/uMax (unsigned)

}

{
  simple check to see whether some code were written with a good
  programming practice or not, by looking at it's min/max function:

  1. this should be not efficient:
     function max(A, B):integer; pascal; // legacy pascal call
     begin
     if A > B then
       Result := A
     else
       Result := B
     end;

     // Delphi optimization produce the same output as 2.

  2. this is not too efficient:  // A = eax, Result = eax
     function max(A, B:integer):integer;
     asm
       cmp A, B
       JG @end    ; using JG, when B = A, B will be re-copied to A
       mov A, B   ; that's a useless additonal work to be done
       @end:
     end;

  // the delphi's standard math library did that
  // that's why it is called (merely): 'standard'

  3. this is efficient:
     function max(const A, B:integer):integer;
     asm
       cmp A, B
       JGE @end   ; using JGE, we don't bother copying B to A,
       mov A, B   ; when the result will be the same anyway
       @end:
     end;

  4. to avoid branch prediction failure (which is very expensive):
     function max(const A, B: integer): integer;
     asm
       xor ecx, ecx ; clear ecx used as bitmasked flag
       sub B, A     ; get difference. in asm, sub and cmp is identical, except not saved
       setl cl      ; set bitmask = 1/one if (B < A), else 0/zero if (B >= A)
       sub ecx, 1   ; flips bitmask onto ..00000000b (if B < A), else ..11111111b (B >= A)
       and B, ecx   ; difference against bitmask, will be zero if bitmask zero (B < A)
       add A, B     ; add difference to get the final result
     end;

     function min(const A, B: integer): integer;
     asm
       xor ecx, ecx ; clear ecx used as bitmasked flag
       sub B, A     ; get difference. in asm, sub and cmp is identical, except not saved
       setge cl     ; set bitmask = 1/one if (B >= A), else 0/zero if (B < A)
       sub ecx, 1   ; flips bitmask onto ..00000000b (if B >= A), else ..11111111b (B < A)
       and B, ecx   ; difference against bitmask, will be zero if bitmask zero (B > A)
       add A, B     ; add difference to get the final result
     end;


  - well, actually there is another (secret) way, but it needs
    Pentium Pro+. conditional move is said to be friendlier with
    branch prediction than (conventional) conditional jump.

    function max(const A, B: integer): integer;
    asm
      cmp B, A
      cmovg A, B
    end;

}
interface

function uMin(const a, b: Int64): Int64; register overload; //unsigned int64
function uMax(const a, b: Int64): Int64; register overload; //unsigned int64
function uMinOf(const a, b: Int64; const c: Int64 = high(Int64)): Int64; register overload; //unsigned int64
function uMaxOf(const a, b: Int64; const c: Int64 = low(Int64)): Int64; register overload; //unsigned int64
function uMidOf(const a, b, c: Int64): Int64; register overload; //unsigned int64

function iMin(const a, b: Int64): Int64; register; overload;
function iMax(const a, b: Int64): Int64; register; overload;
function MinOf(const a, b: Int64; const c: Int64 = high(Int64)): Int64; register; overload;
function MaxOf(const a, b: Int64; const c: Int64 = low(Int64)): Int64; register; overload;
function Mid(const a, b, c: Int64): Int64; register; overload;

function MinMax(const a, b: integer): integer; assembler; overload;
// not useful unless you called this from asm
// min in eax, max in edx, ecx preserved.

function uMin(const a, b: integer): cardinal; assembler; overload;
function uMax(const a, b: integer): cardinal; assembler; overload;
function uMinOf(const a, b: cardinal; const c: cardinal = high(cardinal)): cardinal; register; assembler; overload;
function uMaxOf(const a, b: cardinal; const c: cardinal = low(cardinal)): cardinal; register; assembler; overload;
function uMidOf(const a, b, c: cardinal): cardinal; register; overload;

function iMin(const a, b: integer): integer; register assembler; overload;
function iMax(const a, b: integer): integer; register assembler; overload;
function MinOf(const a, b: integer; const c: integer = high(integer)): integer; register; assembler; overload;
function MaxOf(const a, b: integer; const c: integer = low(integer)): integer; register; assembler; overload;
function Mid(const a, b, c: integer): integer; register; assembler; overload;

function iMin(const a, b: SmallInt): SmallInt; register; overload;
function iMax(const a, b: SmallInt): SmallInt; register; overload;
function MinOf(const a, b: SmallInt; const c: SmallInt = high(SmallInt)): SmallInt; register; overload;
function MaxOf(const a, b: SmallInt; const c: SmallInt = low(SmallInt)): SmallInt; register; overload;
function Mid(const a, b, c: SmallInt): SmallInt; register; overload;

function uMin(const a, b: word): word; register; overload;
function uMax(const a, b: word): word; register; overload;
function MinOf(const a, b: word; const c: word = high(word)): word; register; overload;
function MaxOf(const a, b: word; const c: word = low(word)): word; register; overload;
function Mid(const a, b, c: word): word; register; overload;

function uMin(const a, b: byte): byte; register; overload;
function uMax(const a, b: byte): byte; register; overload;
function MinOf(const a, b: byte; const c: byte = high(byte)): byte; register; overload;
function MaxOf(const a, b: byte; const c: byte = low(byte)): byte; register; overload;
function Mid(const a, b, c: byte): byte; register; overload;

function iMin(const a, b: ShortInt): ShortInt; register; overload;
function iMax(const a, b: ShortInt): ShortInt; register; overload;
function MinOf(const a, b: ShortInt; const c: ShortInt = high(ShortInt)): ShortInt; register; overload;
function MaxOf(const a, b: ShortInt; const c: ShortInt = low(ShortInt)): ShortInt; register; overload;
function Mid(const a, b, c: ShortInt): ShortInt; register; overload;

function SortUp(var a, b: integer): pointer; overload
function SortDown(var a, b: integer): pointer; overload
function SortUp(var a, b, c: integer): pointer; overload
function SortDown(var a, b, c: integer): pointer; overload

// fast Min/Max for int64. from fastcode.
function fastMin(const a, b: int64): int64;
function fastMax(const a, b: int64): int64;

const
  MaxArrayCapacity = high(integer); //a.k.a MaxInt, MaxLong

type
  //array is, conventionally and historically, 0-based
  THugeByteArray = packed array[0..MaxArrayCapacity - 1] of Byte;
  THugeWordArray = packed array[0..MaxArrayCapacity div SizeOf(Word) - 1] of Word;
  THugeIntegerArray = packed array[0..MaxArrayCapacity div SizeOf(integer) - 1] of integer;
  THugeCardinalArray = packed array[0..MaxArrayCapacity div SizeOf(Cardinal) - 1] of Cardinal;
  THugeInt64Array = packed array[0..MaxArrayCapacity div SizeOf(Int64) - 1] of Int64;

  PHugeByteArray = ^THugeByteArray;
  PHugeWordArray = ^THugeWordArray;
  PHugeIntegerArray = ^THugeIntegerArray;
  PHugeCardinalArray = ^THugeCardinalArray;
  PHugeInt64Array = ^THugeInt64Array;

procedure ArrWordMinMax(var min, max: word; const Size: integer; var WordArray); register; assembler; //top-speed
procedure ArrIntMinMax(var min, max: integer; const Size: integer; var IntegerArray); register; assembler; //second-place

procedure NotTooSlowArrayMinMax(var min, max: Int64; const Size: integer; var Int64Array;
  const withwith {not-used}: Boolean = FALSE); //in pure pascal to be compared

implementation

// word

function uMin(const a, b: word): word; overload asm //begin
  //Result := Min(integer(a), integer(b))
  cmp a, b; jbe @@done
    mov a, b
  @@done:
end;

function uMax(const a, b: word): word; overload asm //begin
  //Result := Max(integer(a), integer(b))
  cmp a, b; jae @@done
    mov a, b
  @@done:
end;

function MinOf(const a, b: word; const c: word = high(word)): word; overload asm //begin
  //Result := MinOf(integer(a), integer(b), integer(c));
  cmp a, b; jbe @@done
    mov a, b
  @@done: cmp a, c; jbe @@end
    mov a, c
  @@end:
end;

function MaxOf(const a, b: word; const c: word = low(word)): word; overload asm //begin
  //Result := MaxOf(integer(a), integer(b), integer(c));
  cmp a, b; jae @@done
    mov a, b
  @@done: cmp a, c; jae @@end
    mov a, c
  @@end:
end;

function Mid(const a, b, c: word): word; overload asm //begin
  //Result := Mid(integer(a), integer(b), integer(c));
  cmp a, b; jbe @@done
    cmp a, c; jbe @@end
      mov a, c
  cmp b, a; jbe @@end
    mov a, b; jmp @@end
  @@done: cmp a, c; jae @@end
    mov a, b
  cmp a, c; jbe @@end
    mov a, c
  @@end:
end;

// SmallInt

function iMin(const a, b: SmallInt): SmallInt; overload asm //begin
  //Result := Min(integer(a), integer(b));
  cmp a, b; jle @@done
    mov a, b
  @@done:
end;

function iMax(const a, b: SmallInt): SmallInt; overload asm //begin
//Result := Max(integer(a), integer(b));
  cmp a, b; jge @@done
    mov a, b
  @@done:
end;

function MinOf(const a, b: SmallInt; const c: SmallInt = high(SmallInt)): SmallInt; overload asm //begin
  //Result := MinOf(integer(a), integer(b), integer(c));
  cmp a, b; jle @@done
    mov a, b
  @@done: cmp a, c; jle @@end
    mov a, c
  @@end:
end;

function MaxOf(const a, b: SmallInt; const c: SmallInt = low(SmallInt)): SmallInt; overload asm //begin
  //Result := MaxOf(integer(a), integer(b), integer(c));
  cmp a, b; jge @@done
    mov a, b
  @@done: cmp a, c; jge @@end
    mov a, c
  @@end:
end;

function Mid(const a, b, c: SmallInt): SmallInt; overload asm //begin
  //Result := Mid(integer(a), integer(b), integer(c));
  cmp a, b; jle @@done
    cmp a, c; jle @@end
      mov a, c
  cmp b, a; jle @@end
    mov a, b; jmp @@end
  @@done: cmp a, c; jge @@end
    mov a, b
  cmp a, c; jle @@end
    mov a, c
  @@end:
end;

// byte

function uMin(const a, b: byte): byte; overload asm //begin
//Result := Min(integer(a), integer(b));
  cmp a, b; jbe @@done
    mov a, b
  @@done:
end;

function uMax(const a, b: byte): byte; overload asm //begin
  //Result := Max(integer(a), integer(b));
  cmp a, b; jae @@done
    mov a, b
  @@done:
end;

function MinOf(const a, b: byte; const c: byte = high(byte)): byte; overload asm //begin
  //Result := MinOf(integer(a), integer(b), integer(c));
  cmp a, b; jbe @@done
    mov a, b
  @@done: cmp a, c; jbe @@end
    mov a, c
  @@end:
end;

function MaxOf(const a, b: byte; const c: byte = low(byte)): byte; overload asm //begin
  //Result := MaxOf(integer(a), integer(b), integer(c));
  cmp a, b; jae @@done
    mov a, b
  @@done: cmp a, c; jae @@end
    mov a, c
  @@end:
end;

function Mid(const a, b, c: byte): byte; overload asm //begin
  //Result := Mid(integer(a), integer(b), integer(c));
  cmp a, b; jbe @@done
    cmp a, c; jbe @@end
      mov a, c
  cmp b, a; jbe @@end
    mov a, b; jmp @@end
  @@done: cmp a, c; jae @@end
    mov a, b
  cmp a, c; jbe @@end
    mov a, c
  @@end:
end;

// ShortInt

function iMin(const a, b: ShortInt): ShortInt; overload asm //begin
//Result := Min(integer(a), integer(b));
  cmp a, b; jle @@done
    mov a, b
  @@done:
end;

function iMax(const a, b: ShortInt): ShortInt; overload asm //begin
  //Result := Max(integer(a), integer(b));
  cmp a, b; jge @@done
    mov a, b
  @@done:
end;

function MinOf(const a, b: ShortInt; const c: ShortInt = high(ShortInt)): ShortInt; overload asm //begin
  //Result := MinOf(integer(a), integer(b), integer(c));
  cmp a, b; jle @@done
    mov a, b
  @@done: cmp a, c; jle @@end
    mov a, c
  @@end:
end;

function MaxOf(const a, b: ShortInt; const c: ShortInt = low(ShortInt)): ShortInt; overload asm //begin
  //Result := MaxOf(integer(a), integer(b), integer(c));
  cmp a, b; jge @@done
    mov a, b
  @@done: cmp a, c; jge @@end
    mov a, c
  @@end:
end;

function Mid(const a, b, c: ShortInt): ShortInt; overload asm //begin
  //Result := Mid(integer(a), integer(b), integer(c));
  cmp a, b; jle @@done
    cmp a, c; jle @@end
      mov a, c
  cmp b, a; jle @@end
    mov a, b; jmp @@end
  @@done: cmp a, c; jge @@end
    mov a, b
  cmp a, c; jle @@end
    mov a, c
  @@end:
end;

function iMin(const a, b: integer): integer; overload asm
  cmp a, b
    jle @@done
  mov a, b
  @@done:
end;

function iMax(const a, b: integer): integer; overload asm
  cmp a, b
    jge @@done
  mov a, b
  @@done:
end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// the integer type, which all code-patterns are based from
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function MinOf(const a, b: integer; const c: integer = high(integer)): integer; overload asm
  cmp a, b
    jle @@done
  mov a, b
  @@done:
  cmp a, c
    jle @@end
  mov a, c
  @@end:
end;

function MaxOf(const a, b: integer; const c: integer = low(integer)): integer; overload asm
  cmp a, b
    jge @@done
  mov a, b
  @@done:
  cmp a, c
    jge @@end
  mov a, c
  @@end:
end;

function Mid(const a, b, c: integer): integer; overload asm
  cmp a, b                //         Y
    jle @@done            //   A>B? ---  A>C? -- B>C? -- B
  cmp a, c                //    | N      |       |
    jle @@end             //    |        A       C
                          //   A>C? -- A
  mov a, c                //    |
  cmp b, a                //    |
    jle @@end             //   B>C? -- C
                          //    |
  mov a, b                //    |
  jmp @@end               //    B
                          //
  @@done:
  cmp a, c;
    jge @@end

  mov a, b
  cmp a, c;
    jle @@end

  mov a, c
  @@end:
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
  cmp a, b; jbe @@done
    mov a, b
  @@done:
end;

function UMax(const a, b: integer): cardinal; overload asm
  cmp a, b; jae @@done
    mov a, b
  @@done:
end;

function UMinOf(const a, b: cardinal; const c: cardinal = high(cardinal)): cardinal; overload asm
  cmp a, b; jbe @@done
    mov a, b
  @@done: cmp a, c; jbe @@end
    mov a, c
  @@end:
end;

function UMaxOf(const a, b: cardinal; const c: cardinal = low(cardinal)): cardinal; overload asm
  cmp a, b; jae @@done
    mov a, b
  @@done: cmp a, c; jae @@end
    mov a, c
  @@end:
end;

function UMidOf(const a, b, c: cardinal): cardinal; overload asm
  cmp a, b; jbe @@done
    cmp a, c; jbe @@end
      mov a, c
  cmp b, a; jbe @@end
    mov a, b; jmp @@end
  @@done: cmp a, c; jae @@end
    mov a, b
  cmp a, c; jbe @@end
    mov a, c
  @@end:
end;

{
comparison A:int64 with B:int64, isLess/orEqual
-----------------------------------------------
  cmp A.Hi, B.Hi
  jnz @@1
  cmp A.Lo, B.Lo
  jnb/e IsNotLess/norEqual   // unsigned cmp
  jmp @@IsLess/orEqual
@@1:
  jnl/e @@IsNotLess/NorEqual // signed cmp
@@IsLess/orEqual:
  (instructions)
@@IsNotLess/norEqual:
  (instructions)

note:
  comparison <  use jnb/jnl
  comparison <= use jnbe/jnle

note:
  do the similar/paralel thing with isMore/orEqual:
  comparison >  use jbe/jle, use jna/jng instead to avoid confusion
  comparison >= use jb/jl, use jnae/jnge instead to avoid confusion

note:
  jna = jbe, jnae = jb = jc
  jng = jle, jnge = jl
}

type
  r64 = packed record
    Lo, hi: integer;
  end;

function uMin(const a, b: int64): int64; overload asm
  mov edx, a.r64.hi; mov eax, a.r64.lo
  cmp edx, b.r64.hi; jbe @@end
  cmp eax, b.r64.Lo; jbe @@end
  mov eax, b.r64.Lo
  mov edx, b.r64.hi
  @@end:
end;

function uMax(const a, b: int64): int64; overload asm
  mov edx, a.r64.hi; mov eax, a.r64.lo
  cmp edx, b.r64.hi; jae @@end
  cmp eax, b.r64.Lo; jae @@end
  mov eax, b.r64.Lo
  mov edx, b.r64.hi
  @@end:
end;

function uMinOf(const a, b: Int64; const c: Int64 = high(Int64)): Int64; overload asm
  @@Start: push ebx
  mov edx, a.r64.hi//dword ptr a+4   // Result in EAX:EDX
  mov eax, a.r64.Lo//dword ptr a     //
  mov ebx, b.r64.hi//dword ptr b+4   //
  mov ecx, c.r64.hi//dword ptr c+4   //
  @begin:
    cmp edx, ebx;
      jb @@done
      jz @@equal
    mov edx, ebx
  @@getLowInt:
    mov eax, b.r64.Lo//dword ptr b
    jmp @@done
  @@equal:
    cmp eax, b.r64.Lo//dword ptr b
      ja @@getLowInt
  @@done:
    cmp edx, ecx
      jb @@end
      jz @@equal2
    mov edx, ecx
  @@getLowInt2:
    mov eax, c.r64.Lo//dword ptr c
    jmp @@end
  @@equal2:
    cmp eax, c.r64.Lo//dword ptr c
    ja @@getLowInt2
  @@end:
  @@Stop: pop ebx
end;

function uMaxOf(const a, b: Int64; const c: Int64 = low(Int64)): Int64; overload asm
  @@Start: push ebx
    mov edx, a.r64.hi//dword ptr a+4   //Result in EAX:EDX
    mov eax, a.r64.Lo//dword ptr a     //
    mov ebx, b.r64.hi//dword ptr b+4   //
    mov ecx, c.r64.hi//dword ptr c+4   //
  @@begin:
    cmp edx, ebx
      ja @@done
      jz @@equal
    mov edx, ebx
  @@getLowInt:
    mov eax, b.r64.Lo//dword ptr b
    jmp @@done
  @@equal:
    cmp eax, b.r64.Lo//dword ptr b
      jb @@getLowInt
  @@done:
    cmp edx, ecx
      ja @@end
      jz @@equal2
    mov edx, ecx
  @@getLowInt2:
    mov eax, c.r64.Lo//dword ptr c
    jmp @@end
  @@equal2:
    cmp eax, c.r64.Lo//dword ptr c
      jb @@getLowInt2
  @@end:
  @@Stop: pop ebx
end;

// reminder...
//         Y
//   A>B? ---  A>C? -- B>C? -- B
//    | N      |       |
//    |        A       C
//   A>C? -- A
//    |
//    |
//   B>C? -- C
//    |
//    |
//    B

function uMidOf(const a, b, c: Int64): Int64; overload asm
  @@Start: push ebx
    mov edx, a.r64.hi//dword ptr a+4   //Result in EAX:EDX
    mov eax, a.r64.Lo//dword ptr a     //
    mov ebx, b.r64.hi//dword ptr b+4   //
    mov ecx, c.r64.hi//dword ptr c+4   //
  @@begin:
    cmp edx, ebx
      jb @@down2
      jz @@eq1
    jmp @@right2
  @@eq1:
    cmp eax, b.r64.Lo//dword ptr b
      jbe @@down2
  @@right2:
    cmp edx, ecx
      jb @@end
      jz @@eq2
    jmp @@right3
  @@eq2:
    cmp eax, c.r64.Lo//dword ptr c
      jbe @@end
  @@right3:
    mov edx, ebx
    mov eax, b.r64.Lo//dword ptr b
    cmp edx, ecx
      ja @@end
      //jnz @@right_end
      jnz @@down_end
    cmp eax, c.r64.Lo//dword ptr c
      jae @@end
    jmp @@down_end
    //@@right_end:
    //mov edx, ecx
    //mov eax, dword ptr c
    //jmp @@end
  @@down2:
    cmp edx, ecx
      ja @@end
      jz @@eq3
    jmp @@down3
  @@eq3:
    cmp eax, c.r64.Lo//dword ptr c
      jae @@end
  @@down3:
    mov edx, ebx
    mov eax, b.r64.Lo//dword ptr b
    cmp edx, ecx
      jb @@end
      jnz @@down_end
    cmp eax, c.r64.Lo//dword ptr c
      jbe @@end
  @@down_end:
    mov edx, ecx
    mov eax, c.r64.Lo//dword ptr c
  @@end:
  @@Stop: pop ebx
end;

// minint64 actually is identical in structure with maxint64
function iMin(const a, b: int64): int64; overload asm
  mov eax, a.r64.lo; mov edx, a.r64.hi
  cmp b.r64.hi, edx; jg @@end; jnz @@less
  cmp b.r64.Lo, eax; jae @@end
  @@less:
    mov eax, b.r64.Lo
    mov edx, b.r64.hi
  @@end:
end;

// maxint64 actually is identical in structure with minint64
function iMax(const a, b: int64): int64; overload asm
  mov edx, a.r64.hi; mov eax, a.r64.lo
  cmp edx, b.r64.hi; jg @@end; jnz @@less
  cmp eax, b.r64.Lo; jae @@end
  @@less:
    mov eax, b.r64.Lo
    mov edx, b.r64.hi
  @@end:
end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ought to be faster Min/Max for int64, //fastcode
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function fastMin(const a, b: int64): int64; overload asm
// Author: John O'Harrow
  xor ecx, ecx
  mov eax, a.r64.hi //[ebp+20]
  cmp eax, b.r64.hi //[ebp+12]
  jne @@setHigh
  mov eax, a.r64.lo //[ebp+16]
  cmp eax, b.r64.lo //[ebp+8]
  setna cl
  mov eax, b.r64.lo[ecx*8] //[ebp+ecx*8+8]
  mov edx, b.r64.hi[ecx*8] //[ebp+ecx*8+12]
  pop ebp; ret 16
@@setHigh:
  setng cl
  mov eax, b.r64.lo[ecx*8] //[ebp+ecx*8+8]
  mov edx, b.r64.hi[ecx*8] //[ebp+ecx*8+12]
end;

function fastMax(const a, b: int64): int64; overload asm
// Author: Alexandr Sharahov
  mov eax, b.r64.lo //[ebp+$08]
  mov edx, b.r64.hi //[ebp+$0C]
  xor ecx, ecx
  cmp eax, a.r64.lo //[ebp+$10]
  sbb edx, a.r64.hi //[ebp+$14]
  setl cl
  mov eax, b.r64.lo[ecx*8] //[ebp+8*ecx+$08]
  mov edx, b.r64.hi[ecx*8] //[ebp+8*ecx+$0C]
end;

function MinOf(const a, b: Int64; const c: Int64 = high(Int64)): Int64; overload asm
  @@Start: push ebx
    mov edx, a.r64.hi//dword ptr a+4   //Result in EAX:EDX
    mov eax, a.r64.Lo//dword ptr a     //
    mov ebx, b.r64.hi//dword ptr b+4   //
    mov ecx, c.r64.hi//dword ptr c+4   //
  @@begin:
    cmp edx, ebx
      jl @@done
      jz @@equal
    mov edx, ebx
  @@getLowInt:
    mov eax, b.r64.Lo//dword ptr b
    jmp @@done
  @@equal:
    cmp eax, b.r64.Lo//dword ptr b
      ja @@getLowInt
  @@done:
    cmp edx, ecx
      jl @@end
      jz @@equal2
    mov edx, ecx
  @@getLowInt2:
    mov eax, c.r64.Lo//dword ptr c
    jmp @@end
  @@equal2:
    cmp eax, c.r64.Lo//dword ptr c
      ja @@getLowInt2 // yes, this is right, a jump-up
  @@end:
  @@Stop: pop ebx
end;

function MaxOf(const a, b: Int64; const c: Int64 = low(Int64)): Int64; overload asm
  @@Start: push ebx
    mov edx, a.r64.hi//dword ptr a+4   //Result in EAX:EDX
    mov eax, a.r64.Lo//dword ptr a     //
    mov ebx, b.r64.hi//dword ptr b+4   //
    mov ecx, c.r64.hi//dword ptr c+4   //
  @@begin:
    cmp edx, ebx
      jg @@doneAB
      jz @@equal
    mov edx, ebx
  @@getLowInt:
    mov eax, b.r64.Lo//dword ptr b
      jmp @@doneAB
  @@equal:
    cmp eax, b.r64.Lo//dword ptr b
    jb @@getLowInt
  @@doneAB:
    cmp edx, ecx
      jg @@end
      jz @@equal2
    mov edx, ecx
  @@getLowInt2:
    mov eax, c.r64.Lo//dword ptr c
    jmp @@end
  @@equal2:
    cmp eax, c.r64.Lo//dword ptr c
      jb @@getLowInt2 // yes, this is right, a jump-up
  @@end:
  @@Stop: pop ebx
end;

// reminder...
//         Y
//   A>B? ---  A>C? -- B>C? -- B
//    | N      |       |
//    |        A       C
//   A>C? -- A
//    |
//    |
//   B>C? -- C
//    |
//    |
//    B

function Mid(const a, b, c: Int64): Int64; overload asm
  @@Start: push ebx
    mov edx, a.r64.hi//dword ptr a+4   //Result in EAX:EDX
    mov eax, a.r64.Lo//dword ptr a     //
    mov ebx, b.r64.hi//dword ptr b+4   //
    mov ecx, c.r64.hi//dword ptr c+4   //
  @@begin:
    cmp edx, ebx
      jl @@down2
      jz @@eq1
    jmp @@right2
  @@eq1:
    cmp eax, b.r64.Lo//dword ptr b
      jbe @@down2
  @@right2:
    cmp edx, ecx
      jl @@end
      jz @@eq2
    jmp @@right3
  @@eq2:
    cmp eax, c.r64.Lo//dword ptr c
      jbe @@end
  @@right3:
    mov edx, ebx
    mov eax, b.r64.Lo//dword ptr b
    cmp edx, ecx
      jg @@end
      //jnz @@right_end
      jnz @@down_end
    cmp eax, c.r64.Lo//dword ptr c
      jae @@end
    jmp @@down_end
    //@@right_end:
    //mov edx, ecx
    //mov eax, dword ptr c
    //jmp @@end
  @@down2:
    cmp edx, ecx
      jg @@end
      jz @@eq3
    jmp @@down3
  @@eq3:
    cmp eax, c.r64.Lo//dword ptr c
      jae @@end
  @@down3:
    mov edx, ebx
    mov eax, b.r64.Lo//dword ptr b
    cmp edx, ecx
      jl @@end
      jnz @@down_end
    cmp eax, c.r64.Lo//dword ptr c
      jbe @@end
  @@down_end:
    mov edx, ecx
    mov eax, c.r64.Lo//dword ptr c
  @@end:
  @@Stop: pop ebx
end;

function SortUp(var a, b: integer): pointer; overload asm
  mov ecx, [eax]
  cmp ecx, [edx]; jle @done
  xchg ecx, [edx]; mov [eax], ecx
  // uncomment the line below to get the result (min. value) of type integer
  // (change also the function result type declaration to integer)
   mov eax, [eax] // +1 clock only (on i486+) actually will do no harm
  @done:
end;

function SortDown(var a, b: integer): pointer; overload asm
  mov ecx, [eax]
  cmp ecx, [edx]; jge @done
  xchg ecx, [edx]; mov [eax], ecx
  // uncomment the line below to get the result (min. value) of type integer
  // (change also the function result type declaration to integer)
   mov eax, [eax] // +1 clock only (on i486+) actually will do no harm
  @done:
end;

function SortUp(var a, b, c: integer): pointer; overload asm
  // possible to tightened evenmore,
  // cmp with [mem] cost 2 clocks
  // xchg costs 3 clocks + LOCK prefix
  // we havent yet using all registers (esi, edi)
  // the compiler would not do like this
  @begin: push ebx; mov ebx, [edx]

  cmp [eax], ebx; jle @doneAB
  xchg [eax], ebx; mov [edx], ebx

  @doneAB: mov ebx, [ecx]
  cmp [eax], ebx; jle @doneAC
  xchg [eax], ebx; mov [ecx], ebx

  @doneAC:
  cmp [edx], ebx; jle @end
  xchg ebx, [edx]; mov [ecx], ebx
  // uncomment the line below to get the result (min. value) of type integer
  // (change also the function result type declaration to integer)
   mov eax, [eax] // +1 clock only (on i486+) actually will do no harm
  @end:pop ebx
end;

function SortDown(var a, b, c: integer): pointer; overload asm
  // see above notes.
  @begin: push ebx; mov ebx, [edx]

  cmp [eax], ebx; jge @doneAB
  xchg [eax], ebx; mov [edx], ebx

  @doneAB: mov ebx, [ecx]
  cmp [eax], ebx; jge @doneAC
  xchg [eax], ebx; mov [ecx], ebx

  @doneAC:
  cmp [edx], ebx; jge @end
  xchg ebx, [edx]; mov [ecx], ebx
  // uncomment the line below to get result (min. value) of type integer
  // (change also the function result type declaration to integer)
   mov eax, [eax] // +1 clock only (on i486+) actually will do no harm
  @end:pop ebx
end;

procedure ArrWordMinMax(var min, max: word; const Size: integer; var WordArray);
assembler asm
  push esi; push ebx

  push eax    //save min offset
  push edx    //save max offset

  mov esi, [WordArray]

  dec ecx
   jb @done            // 0-size
  movzx edx, word ptr [esi]        // save current min.
  lea esi, [esi+2]     //
  movzx ebx, dx           // save current max.
   jz @result          // 1-size

@loop:
  movzx eax, word ptr [esi]
  add esi, 2
  cmp eax, edx
   jb @min
  cmp eax, ebx
   ja @max
  dec ecx
   jnz @loop
   jmp @result

@min:
  mov dx, ax   // save current minimum
  dec ecx
   jnz @loop
   jmp @result

@max:
  mov bx, ax   // Save current maximum
  dec ecx
   jnz @loop

@result:
  pop eax        // max
  mov [eax], bx
  pop eax        // min
  mov [eax], dx

@done: pop ebx; pop esi
  end;

procedure ArrIntMinMax(var min, max: integer; const Size: integer; var IntegerArray);
assembler asm
  push esi; push ebx

  push eax    //save min offset
  push edx    //save max offset

  mov esi, [IntegerArray]

  dec ecx
   jb @done             // 0-size
  mov edx, [esi]        // save current min.
  lea esi, [esi+4]      //
  mov ebx, edx          // save current max.
   jz @result           // 1-size

@loop:
  mov eax, [esi]
  add esi, 4
  cmp eax, edx
   jl @min
  cmp eax, ebx
   jg @max
  dec ecx
   jnz @loop
   jmp @result

@min:
  mov edx, eax   // save current minimum
  dec ecx
   jnz @loop
   jmp @result

@max:
  mov ebx, eax   // Save current maximum
  dec ecx
   jnz @loop

@result:
  pop eax        // max
  mov [eax], ebx
  pop eax        // min
  mov [eax], edx

@done: pop ebx; pop esi
  end;

procedure NotTooSlowArrayMinMax(var min, max: Int64; const Size: integer; var Int64Array;
  const withwith {not-used}: Boolean = FALSE); //in pure pascal to be compared
var
  i: integer;
  tmp: Int64;
begin
  min := PHugeInt64Array(Int64Array)^[low(THugeInt64Array)];
  max := min;
  for i := 0 to Size - 1 do begin
    tmp := PHugeInt64Array(Int64Array)^[i];
    if min > tmp then min := tmp;
    if max < tmp then max := tmp;
  end;
end;

//     hi-order lo-order       hi-order lo-order       hi-order lo-order
// a = [esp+7X] [esp+6X]   b = [esp+5X] [esp+4X]   c = [esp+3X] [esp+2X]
// X = 4
  {
  Distribution1 algorithm1:
            1  2  3  4  5  6
  0         A1 A2 B1 B2 C1 C2
            -----------------
  1<->4     B2       A1
  1<->2     A2 B2
  3<->6           C2       B1
  5<->6                 B1 C1
            -----------------
  result:   A2 B2 C2 A1 B1 C1

  Distribution2 algorithm2:
            1  2  3  4  5  6
  0         A1 A2 B1 B2 C1 C2
            -----------------
  2<->3        B1 A2
  3<->5           C1    A2
  4<->5              A2 B2
            -----------------
  result:   A1 B1 C1 A2 B2 C2
  }

end.


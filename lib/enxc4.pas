{$HINTS OFF}
{$WARNINGS OFF}
{$WEAKPACKAGEUNIT ON}
unit enxc4;
{.$DEFINE DEBUG_CHARMAP}

interface
uses ACConsts;

type
  tenxDirection = (enxEncrypt, enxDecrypt);
  tenxFlags = type Longword;

function enxLR2(const S: string; const eFlags: tEnxFlags = 0): string; overload; //result=ecx
function dexLR2(const S: string; const eFlags: tEnxFlags = 0): string; overload; //result=ecx

function enxLR1(const S: string; const eFlags: tEnxFlags = 0): string; //result=ecx
function dexLR1(const S: string; const eFlags: tEnxFlags = 0): string; //result=ecx

function enxLR0(const S: string; const eFlags: tEnxFlags = 0): string; //result=ecx
function dexLR0(const S: string; const eFlags: tEnxFlags = 0): string; //result=ecx

function enxLR3(const Buffer; const BufLen: integer; const eFlags: tEnxFlags): integer; overload; //result=ecx
function dexLR3(const Buffer; const BufLen: integer; const eFlags: tEnxFlags): integer; overload; //result=ecx

function enxLR2x(const S: string; const eFlags: tEnxFlags = 0): string; overload; //result=ecx
function dexLR2x(const S: string; const eFlags: tEnxFlags = 0): string; overload; //result=ecx

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  enxc4 unit - Pseudo Random Generator
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
type
  // if tenxcharmap order changed; change also jump and max-item value (inverse)
  tenxCharMap = (cmAllChars, cmDec, cmHex, cmAlpha, cmAlpha32, cmBase64);
  tenxCharMapSet = set of tenxCharMap;

const
  DEFAULT_KEY1 = __AAKEY1__;
  DEFAULT_KEY2 = __AAKEY2__;
  DEFAULT_CHARMAPSET = [cmAllChars..cmAlpha32];

function enxRand64: Int64; register; // overload;
function enxRandExt: extended; register; // overload;
function enxRand(const Min, Max: integer): integer; register overload;

function enxShuffle(const Min, Max: integer): TInts;
procedure zeroCharmaps(const mapset: tenxCharMapSet = DEFAULT_CHARMAPSET);
function enxCharMapsShuffle(const enxDirection: tenxDirection = enxEncrypt;
  const mapset: tenxCharMapSet = DEFAULT_CHARMAPSET;
  const key1: int64 = DEFAULT_KEY1; const Key2: int64 = DEFAULT_KEY2): integer;

function initRandSeed(const key1: int64 = DEFAULT_KEY1; const Key2: int64 = DEFAULT_KEY2): integer;

//inverses(with inversed_items = 15) are EQUAL with reversedirs, but slower
procedure inverse(const map: tenxCharmap; const inversed: byte = 15); overload;
procedure inverse(const maps: tenxCharmapSet; const inversed: byte = 15); overload;
procedure inverse(const Buffer; const map: tenxCharmap; const inversed: byte = 15); overload;

//reverseDirs are EQUAL with (and faster than) inverses(with inversed_items = 15)
procedure reverseDir(const map: tenxCharmap); overload;
procedure reverseDir(const Buffer; const map: tenxCharmap); overload;
procedure reverseDir(const maps: tenxCharmapSet); overload;

//====================================================
// WIP only do NOT GLOBALIZE on production phase
//====================================================
type
  tChar4 = packed array[0..3] of char;

var
  enxCharMap: packed array[byte] of tChar4;
  enxBase64CharMap: packed array[1..$40] of tChar4;
  enxAlpha32CharMap: packed array[1..$20] of tChar4;
  enxHexCharMap: packed array[0..$F] of tChar4;
  enxDecCharMap: packed array['0'..'9'] of tChar4;
  enxAlphaCharMap: packed array['A'..'Z'] of tChar4;
//====================================================

implementation
function getCombo4(var Buffer; const BufSize, ComboIndex: integer): integer;
asm
end;

function __newstrInc(const S: string; const eFlags: tenxFlags): string; //result=ecx
asm
  push S; test S,S; jnz @@news
  mov eax,Result; call System.@LStrClr
  jmp @@end
@@news:
  push eFlags; push Result
  mov eax,[eax-4]; inc eax     ;// result length = length(S) +1
  call System.@newansiString
  pop Result; mov [Result],eax
  pop eFlags; mov Result, eax  ;// result now simply a Str (not @Str)
@@end: pop eax
end;

function __newstrDec(const S: string; const eFlags: tenxFlags): string; //result=ecx
asm
  push S; test S,S; jnz @@news
  mov eax,Result; call System.@LStrClr
  jmp @@end
@@news:
  push eFlags; push Result
  mov eax,[eax-4]; dec eax     ;// result length = length(S) -1
  call System.@newansiString
  pop Result; mov [Result],eax
  pop eFlags; mov Result, eax  ;// result now simply a Str (not @Str)
@@end: pop eax
end;

function enxLR2(const S: string; const eFlags: tEnxFlags = 0): string; overload; //result=ecx
//const id: pchar = '-BEGINHERE-'#$19#$09#$19#$69#$90#$90#$90#$90#$90;
asm
  test S,S; jnz @@Begin
  mov eax,Result; call System.@LStrClr
  ret
@@Begin: push esi; push edi; push ebx
  mov esi,S; mov edi,Result; mov ebx,eFlags

  mov eax,S-4; inc eax         ;// result length = length(S) +1
  call System.@newansiString   ;// also in edx = length of string
  mov [edi],eax; mov ecx,[eax-4]
//  lea edi,id;
  mov edi,eax
  dec ecx; push ecx      ;// ecx = length(S)
  //dec ecx              ;// decreased again, offset by -1
@@e_LR2XOR:
  mov dl,esi+ecx     ;//should be #0 at first
  xor dl,cl                    ;//should be=cl at first result
  mov byte[eax+ecx],dl
  dec ecx; jge @@e_LR2XOR      ;// until ecx-1

  pop ecx
  lea eax,eax+ecx
  lea esi,esi+ecx

  xor ebx,ebx; neg ecx; //WILL also set CF, unless (which is impossible here:) zero
@@e_LR2:
  //rcr byte ptr[eax+ecx],1       ;// direct access mem, actually is slower
  mov dl,eax+ecx        ;// will be 0 at cx=0
  not dl; rcl dl,1;
  mov byte[eax+ecx], dl
  inc ecx; jle @@e_LR2

@@end: pop ebx; pop edi;pop esi
end;

function dexLR2(const S: string; const eFlags: tEnxFlags = 0): string; //result=ecx
asm
  test S,S; jnz @@Begin
  mov eax,Result; call System.@LStrClr
  ret
@@Begin: push esi; push edi; push ebx
  mov esi,S; mov edi,Result; mov ebx,eFlags

  mov eax,S-4; dec eax
  call System.@newansiString  // also result edx = length of string
  mov [edi],eax; mov ecx,[eax-4]
  mov edi,eax

  //sub edi,esi
  mov dl,esi+ecx
  //xor dl,cl
  //neg dl  ;// get carry! neg will gives carry if not zero
  //dec ecx;
  push ecx

@@d_LR2:
  mov dl,esi+ecx
  rcr dl,1; not dl
  mov byte[eax+ecx],dl
  dec ecx; jge @@d_LR2

  //pop ecx
  mov ecx,[esp]
@@d_LR2XOR:
  //xor byte ptr[eax+ecx],cl ;// direct access mem, actually is slower
  mov dl,eax+ecx
  xor dl,cl;
  mov byte ptr[eax+ecx],dl
  dec ecx; jge @@d_LR2XOR

  pop ecx; mov byte ptr[eax+ecx],0
  @@end: pop ebx; pop edi;pop esi
end;

function enxLR1(const S: string; const eFlags: tEnxFlags = 0): string; //result=ecx
asm
  test S,S; jnz @@Begin
  mov eax,Result; call System.@LStrClr
  ret
@@Begin: push esi; push edi; push ebx
  mov esi,S; mov edi,Result; mov ebx,eFlags

  mov eax,S-4; inc eax
  call System.@newansiString  // also result edx = length of string
  mov [edi],eax; mov ecx,[eax-4]
  mov edi,eax

  dec ecx;
  lea eax,eax+ecx
  lea esi,esi+ecx

  xor ebx,ebx; neg ecx; //WILL also set CF, unless (which is impossible here:) zero
@@e_LR1:
  mov dl,esi+ecx     ;//should be #0 at last
  //rcr dl,1; not dl; rcl dl,1
  //lea edx,edx+ebx;
  rcr dl,1
  mov byte[eax+ecx],dl
  inc ebx; inc ecx; jle @@e_LR1 ;// loop until length(S) +1

  mov eax,edi
@@end: pop ebx; pop edi;pop esi
end;

function dexLR1(const S: string; const eFlags: tEnxFlags = 0): string; //result=ecx
asm
  test S,S; jnz @@Begin
  mov eax,Result; call System.@LStrClr
  ret
  @@Begin: push esi; push edi; push ebx
  mov esi,S; mov edi,Result; mov ebx,eFlags

  mov eax,S-4; dec eax
  call System.@newansiString ;// also result edx = length of string
  mov [edi],eax; mov ecx,[eax-4]
  //mov edi,eax

  push ecx
@@d_LR1:
  mov dl,esi+ecx
  rcl dl,1
  //lea edx,edx+ecx
  //rcr dl,1; not dl; rcl dl,1
  mov byte[eax+ecx],dl
  dec ecx; jge @@d_LR1

  ;//fixup
  pop ecx; mov byte ptr[eax+ecx],0

@@end: pop ebx; pop edi; pop esi
end;

function enxLR0(const S: string; const eFlags: tEnxFlags = 0): string; //result=ecx
asm
  test S,S; jnz @@Begin
  mov eax,Result; call System.@LStrClr
  ret
@@Begin: push esi; push edi; push ebx
  mov esi,S; mov edi,Result; mov ebx,eFlags

  mov eax,S-4; inc eax
  call System.@newansiString  // also result edx = length of string
  mov [edi],eax; mov ecx,[eax-4]
  mov edi,eax

  dec ecx;
  lea eax,eax+ecx
  lea esi,esi+ecx

  xor ebx,ebx; neg ecx; //WILL also set CF, unless (which is impossible here:) zero
@@e_LR0:
  mov dl,esi+ecx     ;//should be #0 at last
  //rcr dl,1; not dl; rcl dl,1
  not dl; rcr dl,1
  mov byte[eax+ecx],dl
  inc ebx; inc ecx; jle @@e_LR0 ;// loop until length(S) +1

  mov eax,edi
@@end: pop ebx; pop edi;pop esi
end;

function dexLR0(const S: string; const eFlags: tEnxFlags = 0): string; //result=ecx
asm
  test S,S; jnz @@Begin
  mov eax,Result; call System.@LStrClr
  ret
@@Begin: push esi; push edi; push ebx
  mov esi,S; mov edi,Result; mov ebx,eFlags

  mov eax,S-4; dec eax
  call System.@newansiString ;// also result edx = length of string
  mov [edi],eax; mov ecx,[eax-4]
  //mov edi,eax

  push ecx
@@d_LR0:
  mov dl,esi+ecx
  //rcr dl,1; not dl; rcl dl,1
  rcl dl,1; not dl
  mov byte[eax+ecx],dl
  dec ecx; jge @@d_LR0

  ;//fixup
  pop ecx; mov byte[eax+ecx],0

@@end: pop ebx; pop edi;pop esi
end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  enxc4 unit - Pseudo Random Generator
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{
 01.ABCD	07.BACD		13.CABD		19.DABC
 02.ABDC	08.BADC		14.CADB		20.DACB
 03.ACBD	09.BCAD		15.CBAD		21.DBAC
 04.ACDB	10.BCDA		16.CBDA		22.DBCA
 05.ADBC	11.BDAC		17.CDAB		23.DCAB
 06.ADCB	12.BDCA		18.CDBA		24.DCBA
}

const
  abcd_table: array[0..23] of integer = (
    $00010203, $00010302, $00020103, $00020301, $00030102, $00030201,
    $01000203, $01000302, $01020003, $01020300, $01030002, $01030200,
    $02000103, $02000301, $02010003, $02010300, $02030001, $02030100,
    $03000102, $03000201, $03010002, $03010200, $03020001, $03020100);

const
  enxRandseed: packed array[0..2] of int64 = (DEFAULT_KEY1, DEFAULT_KEY2, -1);
  __enxfactors: packed array[0..3] of Integer = (5115, 1776, 1492, 2111111111);

function __RandCycle(var X; const CycleFlow: integer = 0): int64;
const // accessed by esp offset (not ebp)
  f0: integer = $13FB; //5115;
  f1: integer = $06F0; //1776;
  f2: integer = $05D4; //1492;
  f3: integer = $7DD4FFC7; //2111111111;
asm
  push esi; push edi push ebx; push ebp
  mov edi,X;
  push 23; pop eax; // find min
	sub edx,eax; sbb ecx,ecx
	and ecx,edx; add eax,ecx
  mov ebp,offset @@begin; push eax;
  mov ebx,[edi+4*1]; mov ecx,[edi+4*2];
  mov edx,[edi+4*3]; lea esi,eax*8+@@jmptable_push;
  mov eax,[edi+4*0]; jmp esi; nop
  @@jmptable_push:
  db 'RQSPÿå‰ÿQRSPÿå‰ÿRSQPÿå‰ÿSRQPÿå‰ÿQSRPÿå‰ÿSQRPÿå‰ÿ';
  db 'RQPSÿå‰ÿQRPSÿå‰ÿRPQSÿå‰ÿPRQSÿå‰ÿQPRSÿå‰ÿPQRSÿå‰ÿ';
  db 'RSPQÿå‰ÿSRPQÿå‰ÿRPSQÿå‰ÿPRSQÿå‰ÿSPRQÿå‰ÿPSRQÿå‰ÿ';
  db 'QSPRÿå‰ÿSQPRÿå‰ÿQPSRÿå‰ÿPQSRÿå‰ÿSPQRÿå‰ÿPSQRÿå‰ÿ';
  @@begin:
  mov eax,f3; mul [esp+3*4];       ;// X[n-4]
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
  db 'X[YZÿå‰ÿX[ZYÿå‰ÿXY[Zÿå‰ÿXYZ[ÿå‰ÿXZ[Yÿå‰ÿXZY[ÿå‰ÿ';
  db '[XYZÿå‰ÿ[XZYÿå‰ÿ[YXZÿå‰ÿ[YZXÿå‰ÿ[ZXYÿå‰ÿ[ZYXÿå‰ÿ';
  db 'YX[Zÿå‰ÿYXZ[ÿå‰ÿY[XZÿå‰ÿY[ZXÿå‰ÿYZX[ÿå‰ÿYZ[Xÿå‰ÿ';
  db 'ZX[Yÿå‰ÿZXY[ÿå‰ÿZ[XYÿå‰ÿZ[YXÿå‰ÿZYX[ÿå‰ÿZY[Xÿå‰ÿ';
@@done: pop esi
  mov [edi+4*0],eax; mov [edi+4*1],ebx;
  mov [edi+4*2],ecx; mov [edi+4*3],edx;
  pop ebp; pop ebx; pop edi; pop esi
end;

function enxRandCycle_1234: Int64; register
var
  X: integer absolute enxRandSeed[0];
  t: integer absolute __enxfactors[0];
asm
push esi
  mov eax,t[3*4];
  mul X[3*4];                   ;// X[n-4]
  mov ecx,eax; mov eax,X[2*4];  ;// X[n-3]
  mov esi,edx; mov X[3*4],eax;

  mul t[2*4]
  add ecx,eax; mov eax,X[1*4];  ;// X[n-2]
  adc esi,edx; mov X[2*4],eax;

  mul t[1*4]
  add ecx,eax; mov eax,X[0*4];  ;// X[n-1]
  adc esi,edx; mov X[1*4],eax;

  mul t[0*4]
  add eax,ecx; adc edx,esi;
  add eax,X[4*4]; rcl edx,0//adc edx,0;
  mov X[0*4],eax; mov X[4*4],edx;
pop  esi
end;

function enxRandCycle_1324: Int64; register
var
  X: integer absolute enxRandSeed[0];
  t: integer absolute __enxfactors[0];
asm
push esi
  mov eax,t[3*4]; mul X[2*4];   ;// X[n-4]

  mov ecx,eax; mov eax,X[3*4];  ;// X[n-3]
  mov esi,edx; mov X[2*4],eax;

  mul t[2*4]
  add ecx,eax; mov eax,X[0*4];  ;// X[n-2]
  adc esi,edx; mov X[3*4],eax;

  mul t[1*4]
  add ecx,eax; mov eax,X[1*4];  ;// X[n-1]
  adc esi,edx; mov X[0*4],eax;

  mul t[0*4]
  add eax,ecx; adc edx,esi;
  add eax,X[4*4]; rcl edx,0//adc edx,0;
  mov X[1*4],eax; mov X[4*4],edx;
pop  esi
end;

function enxRand64: Int64; register overload asm call enxRandCycle_1234 end;

function enxRand(const Max: cardinal): cardinal; register overload asm
  test Max, -1; jnz @begin; ret
@begin: push Max
  call enxRandCycle_1234; pop edx
  mul edx; mov eax, edx
end;

function enxRandExt: Extended; register overload; // also result sign in cx!!!
const
  _1: packed array[boolean] of single = (1, -2);
  _S: packed array[boolean] of word = ($3FFF, $BFFF);
asm
  fnInit; call enxRandCycle_1234;
  xor ecx,ecx;
{$IFNDEF RANDINT64_ALWAYS_POSITIVE}
  mov edx, dword ptr enxRandSeed.4;
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

function enxRand(const Min, Max: integer): integer; register overload asm
// Result range in Min..Max inclusif
// Min-Max range must not exceed cardinal boundary minus 1
// (max range = 4294967295)
  sub max, min; jns @_
    xor eax, eax; ret  // zeronize
  @_: inc max          // difference = (max - min) +1
  push min; push max   // ...save
  call enxRandCycle_1234     // get R
  pop edx; pop ecx     // ..restore
  mul edx              // multiply R by difference (truncated)
  lea eax, edx+ecx
end;

procedure enxRandInit(const I: int64 = int64(__AAMAGIC1__) shl 31 or __AAMAGIC0__); register
const
  PRIME0 = 7;
  //PRIME1 = $01C8E80D; // 29943821 : 1 1100 1000 1110 1000 0000 1101 ~ 1 11001000 11101000 00010101
  PRIME1: integer = $01C8E80D; // 29943821 : 1 1100 1000 1110 1000 0000 1101 ~ 1 11001000 11101000 00010101
  // original value was 29943829 (01C8E815)
  e: extended = 0; // use extended to allow broader range of generated number
  e19: single = 1E19;
var
  X: integer absolute enxRandSeed[0];
asm
  //fldpi; fld e19
  fInit
  push edi; mov edi, 4
   mov edx,dword ptr I+4
   mov eax,dword ptr I
   //mov X, eax; mov X.4,edx
  @LFill:
    mul PRIME1
    dec eax; //sbb edx,0
    mov dword ptr X[edi*4],eax; //mov X[edi*4+4],eax
    //imul eax, PRIME1
    //dec eax; mov X[edi*4], eax
    dec edi; jge @LFill

  mov edi, PRIME0
  @@LRand: call enxRandExt ;
    shr ecx,15; shl ecx,31; //randEx result sign in cx!!!
{$IFDEF DEBUG_RANDOM}
    jz @@d1
      or ecx,ecx
    @@d1:
{$ENDIF DEBUG_RANDOM}
    fstp e // note: for consistency, never directly alter X in RandEx
    mov eax, e.fp80.S.lo; //xor X, eax
    mov edx,e.fp80.S.hi; or edx,ecx;
    xor X,eax; xor X.4, edx;
    dec edi; jnz @@LRand
  pop edi
end;

function enxShuffle(const Min, Max: integer): TInts;
//function Shuffle(const Max: integer; const Min: integer = 0): TIntegers;
// caution! shuffle range values are Min to Max INCLUSIVE!
// thus, for example: Shuffle(1000), will have had 1001 elements!
var
  i, n, m: integer;
  Range: integer;
begin
  Range := Max - Min;
  setlength(Result, Range + 1);
  for i := 0 to Range do
    Result[i] := i;
  if (Range > 0) then begin
    for i := 0 to Range - 1 do begin // I = domain
      n := enxRand(i + 1, Range); // N = codomain
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

function initRandSeed(const key1: int64 = int64(__AAMAGIC1__) shl 32 or __AAMAGIC0__;
  const Key2: int64 = int64(__CRC32Poly__) shl 32 or __AAMAGIC2__): integer;
begin
  Result := 0;
  fillchar(enxRandSeed, sizeof(enxRandseed), -1);
  if Key1 > 0 then enxRandSeed[0] := Key1;
  if Key2 > 0 then enxRandSeed[1] := Key2;
end;

procedure OrdCharMap(const Buffer; const map: tenxCharmap; const BufLen: integer);
const
  ALPHANUM = ' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_';
  ORD_ALPHA32: packed array['0'..'Z'] of byte = (
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 0, 0, 0, 0, 0, 0, $A, $B, $C, $D, $E, $F,
//  G,       H
    16 - 16, 17 - 1,
//  I        J       K       L       M       N
    18 - 18, 19 - 2, 20 - 2, 21 - 2, 22 - 2, 23 - 2,
//  O        P       Q       R
    24 - 24, 25 - 3, 26 - 3, 27 - 3,
//  S        T       U       V       W       X       Y       Z
    28 - 28, 29 - 4, 30 - 4, 31 - 4, 32 - 4, 33 - 4, 34 - 4, 35 - 4);
asm
  test eax,eax; jz @@Stop
  test ecx,ecx; jle @@Stop
  //mov ecx,eax-4; dec ecx
  movzx edx,map; shl edx,2
  jmp dword ptr @@jmpDir+edx
@@jmpDir:
  dd @@cmAllChars, @@cmDec, @@cmHex, @@cmAlpha, @@cmAlpha32, @@cmBase64

@@cmAllChars: jmp @@done
@@cmDec: push ecx; shr ecx,2; jz @@LDec2
  @@LDec: mov edx,eax+ecx*4-4; sub edx,'0000';
    {$IFDEF DEBUG_CHARMAP}
    cmp edx,09090909h; jbe @@d_dec1;
      and edx,0f0f0f0fh;
      pop ecx; call System.error; jmp @@Stop
    @@d_dec1:
    {$ENDIF DEBUG_CHARMAP}
    mov eax+ecx*4-4,edx; dec ecx; jg @@LDec;
    @@LDec2: pop ecx; and ecx,3 jz @@done
    @@LDec3: mov dl,eax+ecx-1; sub dl,'0';
    {$IFDEF DEBUG_CHARMAP}
    cmp dl,9; jbe @@d_dec2;
      and dl,0fh;
      call System.error; jmp @@Stop
    @@d_dec2:
    {$ENDIF DEBUG_CHARMAP}
    mov byte ptr eax+ecx-1,dl; dec ecx; jg @@LDec3
  jmp @@done
@@cmHex: xor edx,edx
  @@LHex:
    mov dl,byte ptr Buffer+ecx-1;
    mov dl,byte ptr ORD_ALPHA32[edx];
    {$IFDEF DEBUG_CHARMAP}
    cmp dl,0fh; jbe @@d_hex;
      and dl,0fh;
      call System.error; jmp @@Stop
    @@d_hex:
    {$ENDIF DEBUG_CHARMAP}
    mov byte ptr Buffer+ecx-1,dl; dec ecx; jg @@LHex
  jmp @@done
@@cmAlpha: push ecx; shr ecx,2; jz @@LAlpha2
  @@LAlpha: mov edx,eax+ecx*4-4; sub edx,'AAAA';
    {$IFDEF DEBUG_CHARMAP}
    cmp edx,1f1f1f1fh; jbe @@d_alpha1;
      and edx,1f1f1f1fh;
      pop ecx; call System.error; jmp @@Stop
    @@d_alpha1:
    {$ENDIF DEBUG_CHARMAP}
    mov eax+ecx*4-4,edx; dec ecx; jg @@LAlpha;
  @@LAlpha2: pop ecx; and ecx,3 jz @@done
  @@LAlpha3: mov dl,eax+ecx-1; sub dl,'A';
    {$IFDEF DEBUG_CHARMAP}
    cmp dl,1fh; jbe @@d_alpha2;
      and dl,1fh;
      call System.error; jmp @@Stop
    @@d_alpha2:
    {$ENDIF DEBUG_CHARMAP}
    mov byte ptr eax+ecx-1,dl; dec ecx; jg @@LAlpha3
  jmp @@done
@@cmAlpha32: xor edx,edx
  @@LAlpha32:
    mov dl,byte ptr Buffer+ecx-1; sub dl,'0'
    {$IFDEF DEBUG_CHARMAP}
    cmp dl,1fh; jbe @@d_alpha32;
      and dl,1fh;
      call System.error; jmp @@Stop
    @@d_alpha32:
    {$ENDIF DEBUG_CHARMAP}
    mov dl,byte ptr ORD_ALPHA32[edx];
    mov byte ptr Buffer+ecx-1,dl; dec ecx; jg @@LAlpha32
  jmp @@done
@@cmBase64: jmp @@done
@@done:
@@Stop:
end;

procedure IntsToCharMap(const Ints: TInts; const map: tenxCharmap); overload;
//  tenxCharMap = (cmAllChars, cmDec, cmHex, cmAlpha, cmAlpha32, cmBase64);
const
  ALPHANUM = ' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_';
  HEXCHARS: pChar = '0123456789ABCDEF';
  ALPHA32CHARS: PChar = '0123456789ABCDEF6H1JKLMN0PQR5TUVWXYZ';
  ALPHA32DEC: PChar = '';
asm
  test eax,eax; jz @@Stop
  mov ecx,eax-4; dec ecx
  movzx edx,map; shl edx,2
  jmp dword ptr @@jmpDir+edx
@@jmpDir:
  dd @@cmAllChars, @@cmDec, @@cmHex, @@cmAlpha, @@cmAlpha32, @@cmBase64
@@cmAllChars: jmp @@done
@@cmDec: //mov edx,'0000';
  @@LDec: mov edx,eax+ecx*4;
    and edx,0f0f0f0fh; add edx,'0000';
    mov eax+ecx*4,edx; dec ecx; jg @@LDec;
    jmp @@done
@@cmHex: shl ecx,2;
  @@LHex:
    mov dl,byte ptr Ints+ecx;
    and dl,0fh; mov dl,byte ptr HEXCHARS+edx;
    mov byte ptr Ints+ecx,dl; dec ecx; jg @@LHex
  jmp @@done
@@cmAlpha: //mov edx,'AAAA'
  @@LAlpha: mov edx,eax+ecx*4;
  and edx,1f1f1f1fh; add edx,'AAAA';
  mov eax+ecx*4,edx; dec ecx; jg @@LAlpha;
  jmp @@done
@@cmAlpha32: shl ecx,2;
  @@LAlpha32:
    mov dl,byte ptr Ints+ecx;
    and dl,1fh; mov dl,byte ptr ALPHA32CHARS+edx;
    mov byte ptr Ints+ecx,dl; dec ecx; jg @@LHex
  jmp @@done
@@cmBase64: jmp @@done

@@done:
@@Stop:

end;

procedure BufferToCharMap(const Buffer; const map: tenxCharmap; const BufLen: integer); overload;
//  tenxCharMap = (cmAllChars, cmDec, cmHex, cmAlpha, cmAlpha32, cmBase64);
const
  //ALPHANUM = ' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_';
  ALPHA32CHARS: packed array[0..31] of char = '0123456789ABCDEFHJKLMNPQRTUVWXYZ';
  //ALPHA32CHARS: packed array[0..$1f] of char = '0123456789ABCDEF6H1JKLMN0PQR5TUVWXYZ';
  dbg: integer = 0;
asm
  {$IFDEF DEBUG_CHARMAP}
    inc dbg
  {$ENDIF DEBUG_CHARMAP}
  test eax,eax; jz @@Stop
  test ecx,ecx; jl @@Stop
  movzx edx,map; shl edx,2
  jmp dword ptr @@jmpDir+edx
@@jmpDir:
  dd @@cmAllChars, @@cmDec, @@cmHex, @@cmAlpha, @@cmAlpha32, @@cmBase64

@@cmAllChars: jmp @@done
@@cmDec: push ecx; shr ecx,2; jz @@LDec2
  @@LDec: mov edx,eax+ecx*4-4;
    {$IFDEF DEBUG_CHARMAP}
    cmp edx,09090909h; jbe @@d_dec1
      pop ecx;call System.error; jmp @@Stop
    @@d_dec1: and edx,0f0f0f0fh;
    {$ENDIF DEBUG_CHARMAP}
    add edx,'0000'; mov Buffer+ecx*4-4,edx;
    dec ecx; jg @@LDec;
  @@LDec2: pop ecx; and ecx,3 jz @@done
  @@LDec3: mov dl,eax+ecx-1;
    {$IFDEF DEBUG_CHARMAP}
    cmp dl,9; jbe @@d_dec2
      and dl,0fh;
      call System.error; jmp @@Stop
    @@d_dec2:
    {$ENDIF DEBUG_CHARMAP}
    add dl,'0'; mov byte ptr Buffer+ecx-1,dl;
    dec ecx; jg @@LDec3
  jmp @@done
@@cmHex: xor edx,edx
  @@LHex:
    mov dl,byte ptr Buffer+ecx-1;
    {$IFDEF DEBUG_CHARMAP}
    cmp dl,0fh; jbe @@d_hex;
      and dl,0fh;
      call System.error; jmp @@Stop
    @@d_hex:
    {$ENDIF DEBUG_CHARMAP}
    mov dl,byte ptr ALPHA32CHARS+edx;
    mov byte ptr Buffer+ecx-1, dl; dec ecx; jg @@LHex
  jmp @@done
@@cmAlpha: push ecx; shr ecx,2; jz @@LAlpha2
  @@LAlpha: mov edx,eax+ecx*4-4;
    {$IFDEF DEBUG_CHARMAP}
    cmp edx,1f1f1f1fh; jbe @@d_alpha1;
      and edx,1f1f1f1fh;
      pop ecx; call System.error; jmp @@Stop
    @@d_alpha1:
    {$ENDIF DEBUG_CHARMAP}
    add edx,'AAAA'; mov eax+ecx*4-4,edx;
    dec ecx; jg @@LAlpha;
  @@LAlpha2: pop ecx; and ecx,3 jz @@done
  @@LAlpha3: mov dl,eax+ecx-1;
    {$IFDEF DEBUG_CHARMAP}
    cmp dl,1fh; jbe @@d_alpha2;
      and dl,1fh;
      call System.error; jmp @@Stop
    @@d_alpha2:
    {$ENDIF DEBUG_CHARMAP}
    add dl,'A'; mov byte ptr eax+ecx-1,dl;
    dec ecx; jg @@LAlpha3;
  jmp @@done
@@cmAlpha32: xor edx,edx
  @@LAlpha32:
    mov dl,byte ptr Buffer+ecx-1;
    {$IFDEF DEBUG_CHARMAP}
    cmp dl,1fh; jbe @@d_alpha32;
      and dl,1fh;
      call System.error; jmp @@Stop
    @@d_alpha32:
    {$ENDIF DEBUG_CHARMAP}
    mov dl,byte ptr ALPHA32CHARS+edx;
    mov byte ptr Buffer+ecx-1, dl;
    dec ecx; jg @@LAlpha32
  jmp @@done
@@cmBase64: jmp @@done
@@done:
@@Stop:
end;

function enxLR3(const Buffer; const BufLen: integer; const eFlags: tEnxFlags): integer; overload; //result=ecx
asm
  test Buffer,Buffer;jz @@Stop
  test BufLen,BufLen;jl @@Stop
@@Begin: push esi; push edi; push ebx;
  mov esi,Buffer; mov edi,Buffer;
  push eFlags; mov ecx,BufLen;
  lea ebx,enxCharmap; xor eax,eax
@@Loop: lodsb; mov al,[ebx+eax*4+0];
  sub al,cl; mov al,[ebx+eax*4+1];
  xor al,cl; mov al,[ebx+eax*4+2];
  add al,cl; mov al,[ebx+eax*4+3];
  stosb;
  dec ecx; jg @@Loop
  pop eFlags
@@end: pop ebx; pop edi; pop esi
@@Stop:
end;

function dexLR3(const Buffer; const BufLen: integer; const eFlags: tenxFlags): integer; overload; //result=ecx
asm
  test Buffer,Buffer;jz @@Stop
  test BufLen,BufLen;jl @@Stop
@@Begin: push esi; push edi; push ebx;
  mov esi,Buffer; mov edi,Buffer;
  push eFlags; mov ecx,BufLen;
  lea ebx,enxCharmap; xor eax,eax;
@@Loop: lodsb; mov al,[ebx+eax*4+3];
  sub al,cl; mov al,[ebx+eax*4+2];
  xor al,cl; mov al,[ebx+eax*4+1];
  add al,cl; mov al,[ebx+eax*4+0];
  stosb; dec ecx;
  jg @@Loop; pop eFlags;
@@end: pop ebx; pop edi; pop esi
@@Stop:
end;

function enxLR2x(const S: string; const eFlags: tEnxFlags = 0): string; overload; //result=ecx
asm
  test S,S; jnz @@Begin
  mov eax,Result; call System.@LStrClr
  ret
@@Begin: push esi; push edi; push ebx; push eFlags;
  mov esi,S; mov edi,Result; lea ebx,enxCharmap

  mov eax,S-4; inc eax         ;// result length = length(S) +1
  call System.@newansiString   ;// also in edx = length of string
  mov [edi],eax; mov ecx,[eax-4]
  mov edi,eax
  dec ecx; push ecx      ;// ecx = length(S)
  //dec ecx              ;// decreased again, offset by -1
  xor edx,edx
@@e_LR2XOR:
  mov dl,esi+ecx     ;//should be #0 at first
  mov dl,[ebx+edx*4+0]
  xor dl,cl                    ;//should be=cl at first result
  mov byte[eax+ecx],dl
  dec ecx; jge @@e_LR2XOR      ;// until ecx-1

  pop ecx
  lea eax,eax+ecx
  lea esi,esi+ecx

  xor ebx,ebx; neg ecx; //WILL also set CF, unless (which is impossible here:) zero
@@e_LR2:
  //rcr byte ptr[eax+ecx],1       ;// direct access mem, actually is slower
  mov dl,eax+ecx        ;// will be 0 at cx=0
  not dl; rcl dl,1;
  mov byte[eax+ecx], dl
  inc ecx; jle @@e_LR2

@@end: pop eFlags; pop ebx; pop edi;pop esi
end;

function dexLR2x(const S: string; const eFlags: tEnxFlags = 0): string; //result=ecx
asm
  test S,S; jnz @@Begin
  mov eax,Result; call System.@LStrClr
  ret
@@Begin: push esi; push edi; push ebx; push eFlags;
  mov esi,S; mov edi,Result; lea ebx,enxCharmap

  mov eax,S-4; dec eax
  call System.@newansiString  // also result edx = length of string
  mov [edi],eax; mov ecx,[eax-4]
  mov edi,eax

  //sub edi,esi
  movzx edx,esi+ecx
  //xor dl,cl
  //neg dl  ;// get carry! neg will gives carry if not zero
  //dec ecx;
  push ecx

@@d_LR2:
  mov dl,esi+ecx
  rcr dl,1; not dl
  mov byte[eax+ecx],dl
  dec ecx; jge @@d_LR2
  //pop ecx
  mov ecx,[esp]
@@d_LR2XOR:
  //xor byte ptr[eax+ecx],cl ;// direct access mem, actually is slower
  mov dl,eax+ecx
  xor dl,cl;
  mov dl,[ebx+edx*4+0]

  mov byte ptr[eax+ecx],dl
  dec ecx; jge @@d_LR2XOR

  pop ecx; mov byte ptr[eax+ecx],0
  @@end: pop eFlags; pop ebx; pop edi;pop esi
end;

procedure zeroCharmaps(const mapset: tenxCharMapSet = DEFAULT_CHARMAPSET);
begin
  if cmAllChars in mapset then fillchar(enxCharmap, sizeof(enxcharmap), 0);
  if cmDec in mapset then fillchar(enxDecCharmap, sizeof(enxDeccharmap), 0);
  if cmHex in mapset then fillchar(enxHexCharmap, sizeof(enxHexCharmap), 0);
  if cmAlpha32 in mapset then fillchar(enxAlpha32Charmap, sizeof(enxAlpha32Charmap), 0);
  if cmAlpha in mapset then fillchar(enxAlphaCharmap, sizeof(enxAlpha32Charmap), 0);
  if cmBase64 in mapset then fillchar(enxBase64Charmap, sizeof(enxBase64Charmap), 0);
end;

type
  tenxSubCharItemIndex = 0..3;
  tenxSCII = tenxSubCharItemIndex;
  tInversedItems = set of tenxSCII;

procedure inverse(const Buffer; const map: tenxCharmap; const inversed: tInversedItems); overload;
const
  //tenxCharMap = (cmAllChars, cmDec, cmHex, cmAlpha, cmAlpha32, cmBase64);
  maxnxval: packed array[tenxCharMap] of byte = (//255, 9, 15, 25, 31, 63
    sizeof(enxCharMap) div 4 - 1, sizeof(enxDecCharMap) div 4 - 1,
    sizeof(enxHexCharMap) div 4 - 1, sizeof(enxAlphaCharMap) div 4 - 1,
    sizeof(enxAlpha32CharMap) div 4 - 1, sizeof(enxBase64CharMap) div 4 - 1
    );
asm
  test eax,eax; jz @@Stop
@@begin: push esi; push edi; push ebx
  mov esi,Buffer; movzx edi,map; movzx ebx,inversed;
  movzx edx,byte ptr maxnxval+edi; inc edx;
  mov ecx,edx
@@Reverse4:
  shl edx,2; sub esp,edx;
  mov edi,esp; push edi; rep movsd;
  mov edi,esi; pop esi;
  sub edi,edx; push edx;
  shr edx,2; lea ecx,edx-1; xor edx,edx
  push esi; push edi; push ecx
  @@rev0: test bl,0001b; jz @@rev1
    @@L0: mov dl,esi+ecx*4+0; mov edi+edx*4+0,cl; dec ecx; jge @@L0
    mov ecx,[esp]; mov edi,[esp+4]; mov esi,[esp+8]
  @@rev1: test bl,0010b; jz @@rev2
    @@L1: mov dl,esi+ecx*4+1; mov edi+edx*4+1,cl; dec ecx; jge @@L1
    mov ecx,[esp]; mov edi,[esp+4]; mov esi,[esp+8]
  @@rev2: test bl,0100b; jz @@rev3
    @@L2: mov dl,esi+ecx*4+2; mov edi+edx*4+2,cl; dec ecx; jge @@L2
    mov ecx,[esp]; mov edi,[esp+4]; mov esi,[esp+8]
  @@rev3: test bl,1000b; jz @@rev_end
    @@L3: mov dl,esi+ecx*4+3; mov edi+edx*4+3,cl; dec ecx; jge @@L3
  @@rev_end: add esp,4*3
  pop edx; add esp,edx
@@end: pop ebx; pop edi;pop esi;
@@Stop:
end;

procedure inverse(const Buffer; const map: tenxCharmap; const inversed: byte); overload;
var
  invs: tinversedItems;
begin
  move(inversed, invs, 1);
  inverse(Buffer, map, invs);
end;

procedure inverse(const map: tenxCharmap; const inversed: tInversedItems); overload;
begin
  case map of
    cmAllChars: inverse(enxCharMap[low(enxCharMap)], map, inversed);
    cmDec: inverse(enxDecCharMap[low(enxDecCharMap)], map, inversed);
    cmHex: inverse(enxHexCharMap[low(enxHexCharMap)], map, inversed);
    cmAlpha: inverse(enxAlphaCharMap[low(enxAlphaCharMap)], map, inversed);
    cmAlpha32: inverse(enxAlpha32CharMap[low(enxAlpha32CharMap)], map, inversed);
    cmBase64: inverse(enxBase64CharMap[low(enxBase64CharMap)], map, inversed);
  end;
end;

procedure inverse(const map: tenxCharmap; const inversed: byte); overload;
var
  invs: tinversedItems;
begin
  move(inversed, invs, 1);
  inverse(map, invs);
end;

procedure Inverse(const maps: tenxCharmapSet; const inversed: tInversedItems); overload;
var
  map: tenxCharMap;
begin
  for map := low(map) to high(map) do
    if map in maps then
      case map of
        cmAllChars: Inverse(enxCharMap[low(enxCharMap)], map);
        cmDec: Inverse(enxDecCharMap[low(enxDecCharMap)], map);
        cmHex: Inverse(enxHexCharMap[low(enxHexCharMap)], map);
        cmAlpha: Inverse(enxAlphaCharMap[low(enxAlphaCharMap)], map);
        cmAlpha32: Inverse(enxAlpha32CharMap[low(enxAlpha32CharMap)], map);
        cmBase64: Inverse(enxBase64CharMap[low(enxBase64CharMap)], map);
      end
end;

procedure Inverse(const maps: tenxCharmapSet; const inversed: byte); overload;
var
  invs: tinversedItems;
begin
  move(inversed, invs, 1);
  inverse(maps, invs);
end;

{$DEFINE DO_NOT_CHANGE!!!}
procedure reverseDir(const Buffer; const map: tenxCharmap); overload;
// reverseDir default equal with inverse default ([0..3])
asm
{$DEFINE DO_NOT_CHANGE!!!}
  test eax,eax; jz @@Stop
  xor ecx,ecx;
{$DEFINE DO_NOT_CHANGE!!!}
@@begin: push esi; push edi;
  mov esi,Buffer;
  movzx edx,map; shl edx,2
  jmp dword ptr @@jmpDir+edx
{$DEFINE DO_NOT_CHANGE!!!}
@@jmpDir:
  dd @@cmAllChars, @@cmDec, @@cmHex, @@cmAlpha, @@cmAlpha32, @@cmBase64
{$DEFINE DO_NOT_CHANGE!!!}
@@cmAllChars: inc ch; jmp @@Reverse
@@cmDec: mov cl,10; jmp @@Reverse
@@cmHex: mov cl,10h; jmp @@Reverse
@@cmAlpha: mov cl,26; jmp @@Reverse
@@cmAlpha32: mov cl,20h; jmp @@Reverse
@@cmBase64: mov cl,40h; jmp @@Reverse
@@Reverse: lea edx,ecx*4; sub esp,edx;
{$DEFINE DO_NOT_CHANGE!!!}
  mov edi,esp; push edi; rep movsd;
  mov edi,esi; pop esi;
  sub edi,edx; push edx;
  shr edx,2; lea ecx,edx-1; xor edx,edx
{$DEFINE DO_NOT_CHANGE!!!}
  @@L_rev:
    mov dl,esi+ecx*4+0; mov edi+edx*4+0,cl
    mov dl,esi+ecx*4+1; mov edi+edx*4+1,cl
    mov dl,esi+ecx*4+2; mov edi+edx*4+2,cl
    mov dl,esi+ecx*4+3; mov edi+edx*4+3,cl
    dec ecx; jge @@L_rev
    jmp @@done_rev
{$DEFINE DO_NOT_CHANGE!!!}
@@done_rev:  pop edx; add esp,edx
@@end: pop edi;pop esi;
@@Stop:
{$DEFINE DO_NOT_CHANGE!!!}
end;
{$DEFINE DO_NOT_CHANGE!!!}

{$DEFINE DO_NOT_CHANGE!!!}
procedure reverseDir(const map: tenxCharmap); overload;
asm
{$DEFINE DO_NOT_CHANGE!!!}
@@begin: push esi; push edi; xor ecx,ecx;
  movzx edx,map; shl edx,2
  jmp dword ptr @@jmpDir+edx
{$DEFINE DO_NOT_CHANGE!!!}
@@jmpDir:
  dd @@cmAllChars, @@cmDec, @@cmHex, @@cmAlpha, @@cmAlpha32, @@cmBase64
{$DEFINE DO_NOT_CHANGE!!!}
@@cmAllChars: lea esi,enxCharMap; inc ch; jmp @@Reverse
@@cmDec: lea esi,enxDecCharMap; mov cl,10; jmp @@Reverse
@@cmHex: lea esi,enxHexCharMap; mov cl,10h; jmp @@Reverse
@@cmAlpha: lea esi,enxAlphaCharMap; mov cl,26; jmp @@Reverse
@@cmAlpha32: lea esi,enxAlpha32CharMap; mov cl,20h; jmp @@Reverse
@@cmBase64: lea esi,enxBase64CharMap; mov cl,40h; jmp @@Reverse
@@Reverse: mov edx,ecx; shl edx,2; sub esp,edx;
{$DEFINE DO_NOT_CHANGE!!!}
  mov edi,esp; push edi; rep movsd;
  mov edi,esi; pop esi;
  sub edi,edx; push edx;
  shr edx,2; lea ecx,edx-1; xor edx,edx
  @@L_rev:
    mov dl,esi+ecx*4+0; mov edi+edx*4+0,cl
    mov dl,esi+ecx*4+1; mov edi+edx*4+1,cl
    mov dl,esi+ecx*4+2; mov edi+edx*4+2,cl
    mov dl,esi+ecx*4+3; mov edi+edx*4+3,cl
    dec ecx; jge @@L_rev
  pop edx; add esp,edx
{$DEFINE DO_NOT_CHANGE!!!}
@@end: pop edi;pop esi;
@@Stop:
{$DEFINE DO_NOT_CHANGE!!!}
end;
{$DEFINE DO_NOT_CHANGE!!!}

procedure ReverseDir(const maps: tenxCharmapSet); overload;
var
  map: tenxCharMap;
begin
  for map := low(map) to high(map) do
    if map in maps then
      case map of
        cmAllChars: reverseDir(enxCharMap[low(enxCharMap)], map);
        cmDec: reverseDir(enxDecCharMap[low(enxDecCharMap)], map);
        cmHex: reverseDir(enxHexCharMap[low(enxHexCharMap)], map);
        cmAlpha: reverseDir(enxAlphaCharMap[low(enxAlphaCharMap)], map);
        cmAlpha32: reverseDir(enxAlpha32CharMap[low(enxAlpha32CharMap)], map);
        cmBase64: reverseDir(enxBase64CharMap[low(enxBase64CharMap)], map);
      end
end;

procedure reverseDir(const Buffer; const maps: tenxCharmapSet); overload;
var
  map: tenxCharMap;
begin
  for map := low(map) to high(map) do
    if map in maps then
      reverseDir(Buffer, map);
end;

procedure initDir(const map: tenxCharMap); overload;
asm
@@begin: xor ecx,ecx
  movzx edx,map; shl edx,2
  jmp dword ptr @@jmpDir+edx
@@jmpDir:
  dd @@cmAllChars, @@cmDec, @@cmHex, @@cmAlpha, @@cmAlpha32, @@cmBase64
@@cmAllChars: lea edx,enxCharMap; inc ch; jmp @@init
@@cmDec: lea edx,enxDecCharMap; mov cl,10; jmp @@init
@@cmHex: lea edx,enxHexCharMap; mov cl,10h; jmp @@init
@@cmAlpha: lea edx,enxAlphaCharMap; mov cl,26; jmp @@init
@@cmAlpha32: lea edx,enxAlpha32CharMap; mov cl,20h; jmp @@init
@@cmBase64: lea edx,enxBase64CharMap; mov cl,40h; jmp @@init
@@init: dec ecx;
  @@Loop: mov al,cl; mov ah,cl;
    push ax; shl eax,16; pop ax
    mov [edx+ecx*4],eax; dec ecx;jge @@Loop
@@Stop:
end;

procedure initDir(const maps: tenxCharmapSet = DEFAULT_CHARMAPSET); overload;
var
  map: tenxCharMap;
begin
  for map := low(map) to high(map) do
    if map in maps then
      initDir(map);
end;

function enxCharMapsShuffle(const enxDirection: tenxDirection = enxEncrypt;
  const mapset: tenxCharMapSet = DEFAULT_CHARMAPSET;
  const key1: int64 = DEFAULT_KEY1; const Key2: int64 = DEFAULT_KEY2): integer;
var
  i, j, n: integer;
  ints0, ints1: tints;
  map: tenxCharmap;
  P: pChar;
begin
  result := 0; zeroCharmaps(mapset);
  for map := low(map) to high(map) do begin
    if map in mapset then begin
      case map of
        cmAllChars: begin
            //continue;
            P := (@enxCharMap[low(enxCharMap)]);
            n := ord(high(enxCharMap)) - ord(low(enxCharMap));
          end;
        cmHex: begin
            P := (@enxHexCharMap[low(enxHexCharMap)]);
            n := ord(high(enxHexCharMap)) - ord(low(enxHexCharMap));
          end;
        cmDec: begin
            P := (@enxDecCharMap[low(enxDecCharMap)]);
            n := ord(high(enxDecCharMap)) - ord(low(enxDecCharMap));
          end;
        cmAlpha32: begin
            P := (@enxAlpha32CharMap[low(enxAlpha32CharMap)]);
            n := ord(high(enxAlpha32CharMap)) - ord(low(enxAlpha32CharMap));
          end;
        cmAlpha: begin
            P := (@enxAlphaCharMap[low(enxAlphaCharMap)]);
            n := ord(high(enxAlphaCharMap)) - ord(low(enxAlphaCharMap));
          end;
        cmBase64: begin
            continue;
            P := (@enxBase64CharMap[low(enxBase64CharMap)]);
            n := high(enxBase64CharMap) - low(enxBase64CharMap);
          end
      else continue;
      end;
      setlength(ints1, 0);
      setlength(ints1, n + 1);
      initRandSeed(Key1, Key2);
      for i := 1 to sizeof(integer) do begin
        ints0 := enxShuffle(0, n);
        for j := 0 to high(ints0) do
          ints1[j] := ints1[j] shl 8 or ints0[j];
      end;
      move(ints1[0], P^, (n + 1) * sizeof(integer));
      //BufferToCharMap(P^, map, length(ints0) * sizeof(integer));
    end;
  end;
end;

initialization

end.


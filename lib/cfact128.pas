//function GetCombIndex128(const Order, Base: string): r128; overload;
unit cfact128;
{$A+,Z4} // do NOT change!
interface
type

  tfactorialNBase = 0..34; // actually 0 is an invalid factorial base number
  tfactnBits = (fkn32, fkn64, fkn128);
  tCombinationIndex = type string; // string contains position of combination Index
  TIntegers = TBoundArray;
  r128 = packed record
    case integer of
      -9: (_Lo, _Hi: int64);
      -2: (GUID: TGUID);
      -1: (L: Longword);
      00: (b: packed array[0..15] of byte);
      01: (w: packed array[0..07] of word);
      02: (I: packed array[0..03] of integer);
  end;

function bitCount(const I: integer): integer;
function bitCount2(const I: integer): integer;
function bitCount64(const I: int64): integer;
procedure nfactorial2(const N: tfactorialNBase; out Value; const fkBits: tfactnBits); overload;
function nfactorial(const N: tfactorialNBase): int64; overload;
function GetIntMaxNBase(const Value: integer): tfactorialNBase;
function GetInt64MaxNBase(const Value: int64): tfactorialNBase;
function GetInt128MaxNBase(const Value): tfactorialNBase;
procedure int128sub(var A: r128; const B: r128);
procedure int128subD(var A: r128; const I: integer);
function GetCombi64(const Index: Int64): string;

{ get combination order at specified index }
function GetOrder128(const Index: r128; const Base: string): string; overload;

{ get combination index }
function GetCombIndex128(const Order, Base: string): r128; overload;
function GetIndexNo1(const AnOrder, BaseOrder: string): Int64;
function GetIndexNo2(const AnOrder, BaseOrder: string): Int64;

{ get Unique chars list from string }
function UniqCharList(const S: string): string;

{ get Unique integers list from array of integer }
function UniqIntList(const Integers: TIntegers): TIntegers;

{ checks for:                                                         }
{   no duplicated chars in both Value and Base                        }
{   all chars in Value also exist in Base (Base is superset of Value) }
function isValidSubSet(const Order, Base: string): boolean;

implementation
//uses ordinals;
type
  dword = longword;
  r64 = packed record
    case integer of
      -1: (_Lo, _Hi: dword);
      00: (b: packed array[0..7] of byte);
      01: (w: packed array[0..3] of word);
      02: (I: packed array[0..1] of integer);
  end;

const
  maxnBase = high(tfactorialNBase);

  k01 = $00000001; k02 = $00000002; k03 = $00000006; k04 = $00000018;
  k05 = $00000078; k06 = $000002D0; k07 = $000013B0; k08 = $00009D80;
  k09 = $00058980; k10 = $00375F00; k11 = $02611500; k12 = $1C8CFC00;

  k13 = $000000017328CC00; k13_Lo = integer(k13); k13_Hi = k13 shr 32;
  k14 = $000000144C3B2800; k14_Lo = integer(k14); k14_Hi = k14 shr 32;
  k15 = $0000013077775800; k15_Lo = integer(k15); k15_Hi = k15 shr 32;
  k16 = $0000130777758000; k16_Lo = integer(k16); k16_Hi = k16 shr 32;
  k17 = $0001437EEECD8000; k17_Lo = integer(k17); k17_Hi = k17 shr 32;
  k18 = $0016BEECCA730000; k18_Lo = integer(k18); k18_Hi = k18 shr 32;
  k19 = $01B02B9306890000; k19_Lo = integer(k19); k19_Hi = k19 shr 32;
  k20 = $21C3677C82B40000; k20_Lo = integer(k20); k20_Hi = k20 shr 32;

const
  k21H = $0000000000000002; k21L = $C5077D36B8C40000;
  k22H = $000000000000003C; k22L = $EEA4C2B3E0D80000;
  k23H = $0000000000000579; k23L = $70CD7E2933680000;
  k24H = $0000000000008362; k24L = $9343D3DCD1C00000;
  k25H = $00000000000CD4A0; k25L = $619FB0907BC00000;
  k26H = $00000000014D9849; k26L = $EA37EEAC91800000;
  k27H = $00000000232F0FCB; k27L = $B3E62C3358800000;
  k28H = $00000003D925BA47; k28L = $AD2CD59DAE000000;
  k29H = $0000006F99461A1E; k29L = $9E1432DCB6000000;
  k30H = $00000D13F6370F96; k30L = $865DF5DD54000000;
  k31H = $0001956AD0AAE33A; k31L = $4560C5CD2C000000;
  k32H = $0032AD5A155C6748; k32L = $AC18B9A580000000;
  k33H = $0688589CC0E9505E; k33L = $2F2FEE5580000000;
  k34H = $DE1BC4D19EFCAC82; k34L = $445DA75B00000000;

  k21A = dword(k21L); k21B = dword(int64(k21L) shr 32);
  k22A = dword(k22L); k22B = dword(int64(k22L) shr 32);
  k23A = dword(k23L); k23B = dword(int64(k23L) shr 32);
  k24A = dword(k24L); k24B = dword(int64(k24L) shr 32);
  k25A = dword(k25L); k25B = dword(int64(k25L) shr 32);
  k26A = dword(k26L); k26B = dword(int64(k26L) shr 32);
  k27A = dword(k27L); k27B = dword(int64(k27L) shr 32);
  k28A = dword(k28L); k28B = dword(int64(k28L) shr 32);
  k29A = dword(k29L); k29B = dword(int64(k29L) shr 32);
  k30A = dword(k30L); k30B = dword(int64(k30L) shr 32);
  k31A = dword(k31L); k31B = dword(int64(k31L) shr 32);
  k32A = dword(k32L); k32B = dword(int64(k32L) shr 32);
  k33A = dword(k33L); k33B = dword(int64(k33L) shr 32);
  k34A = dword(k34L); k34B = dword(int64(k34L) shr 32);

  k21C = dword(k21H); k21D = dword(int64(k21H) shr 32);
  k22C = dword(k22H); k22D = dword(int64(k22H) shr 32);
  k23C = dword(k23H); k23D = dword(int64(k23H) shr 32);
  k24C = dword(k24H); k24D = dword(int64(k24H) shr 32);
  k25C = dword(k25H); k25D = dword(int64(k25H) shr 32);
  k26C = dword(k26H); k26D = dword(int64(k26H) shr 32);
  k27C = dword(k27H); k27D = dword(int64(k27H) shr 32);
  k28C = dword(k28H); k28D = dword(int64(k28H) shr 32);
  k29C = dword(k29H); k29D = dword(int64(k29H) shr 32);
  k30C = dword(k30H); k30D = dword(int64(k30H) shr 32);
  k31C = dword(k31H); k31D = dword(int64(k31H) shr 32);
  k32C = dword(k32H); k32D = dword(int64(k32H) shr 32);
  k33C = dword(k33H); k33D = dword(int64(k33H) shr 32);
  k34C = dword(k34H); k34D = dword(int64(k34H) shr 32);

  simplefact: array[0..12 + 8 * 2 + 14 * 4] of integer = (
    0, k01, k02, k03, k04, k05, k06, k07, k08, k09, k10, k11, k12,
    k13_lo, k13_hi, k14_lo, k14_hi, k15_lo, k15_hi, k16_lo, k16_hi,
    k17_lo, k17_hi, k18_lo, k18_hi, k19_lo, k19_hi, k20_lo, k20_hi,
    k21A, k21B, k21C, k21D, k22A, k22B, k22C, k22D, k23A, k23B, k23C, k23D,
    k24A, k24B, k24C, k24D, k25A, k25B, k25C, k25D, k26A, k26B, k26C, k26D,
    k27A, k27B, k27C, k27D, k28A, k28B, k28C, k28D, k29A, k29B, k29C, k29D,
    k30A, k30B, k30C, k30D, k31A, k31B, k31C, k31D, k32A, k32B, k32C, k32D,
    k33A, k33B, k33C, k33D, k34A, k34B, k34C, k34D
    );

function nfactorial(const N: tfactorialNBase): int64;
asm
  cmp eax,21; sbb edx,edx;
  and eax,edx; mov ecx,offset simplefact;
  xor edx,edx; cmp eax,13; jnb @@d20
  @@d12: mov eax,[ecx+eax*4]; ret
  @@d20: mov edx,[ecx+eax*8-13*4+4]; mov eax,[ecx+eax*8-13*4];
end;

function GetIntMaxNBase(const Value: integer): tfactorialNBase;
asm
   cmp eax,2; mov edx,eax; ja @@t09;
   {cmp eax,1; sbb eax,0;} ret
   @@t03: cmp edx,k03; sbb eax,-3
   @@t04: cmp edx,k04; sbb eax,-1; ret
   @@t05: cmp edx,k05; jb @@t03; jnz @@t07; or eax,5; ret
   @@t06: cmp edx,k06; sbb eax,-6; ret
   @@t07: cmp edx,k07; jb @@t06; jnz @@t08; or eax,7; ret
   @@t08: cmp edx,k08; sbb eax,-8; ret
   @@t09: xor eax,eax; cmp edx,k09; jb @@t05; jnz @@t11; or eax,9; ret
   @@t10: cmp edx,k10; sbb eax,-10; ret
   @@t11: cmp edx,k11; jb @@t10; jnz @@t12; or eax,11; ret
   @@t12: cmp edx,k12; sbb eax,-12; ret
end;

function GetInt64MaxNBase(const Value: int64): tfactorialNBase;
asm
{$DEFINE DO_NOT_CHANGE}
  pop ebp; pop ecx; pop eax; pop edx;
  push ecx; // return address
  mov ecx,eax;
  test edx,edx; jz GetIntMaxNBase;
  push 0; pop eax; jns @@t17; or eax,20; ret
{$DEFINE DO_NOT_CHANGE}
  //notice different method for first and last check (@@t13 and @@t20)
  //@@t12: or eax,12; ret
  @@t13: cmp edx,K13_hi; jb @@t13S; jne @@t14
         cmp ecx,K13_Lo; @@t13S: sbb eax,-13; ret
  @@t14: cmp edx,K14_hi; jne @@t14S;
         cmp ecx,K14_Lo; @@t14S: sbb eax,-14; ret
  @@t15: cmp edx,K15_hi; jb @@t13; jne @@t16
         cmp ecx,K15_Lo; sbb eax,-15; ret
  @@t16: cmp edx,K16_hi; jne @@t16S
         cmp ecx,K16_Lo; @@t16S: sbb eax,-16; ret
  @@t17: cmp edx,K17_hi; jb @@t15; jne @@t19
         cmp ecx,K17_Lo; sbb eax,-17; ret
  @@t18: cmp edx,K18_Hi; jne @@t18S
         cmp ecx,K18_Lo; @@t18S: sbb eax,-18; ret
  @@t19: cmp edx,K19_hi; jb @@t18; jne @@t20
         cmp ecx,K19_Lo; sbb eax,-19; ret
  @@t20: cmp edx,K20_hi; jne @@t20S
         cmp ecx,K20_Lo; @@t20S: sbb eax,-20; ret
{$DEFINE DO_NOT_CHANGE}
end;

procedure nfactorial2(const N: tfactorialNBase; out Value; const fkBits: tfactnBits);
const
  maxfactnBits = high(tfactnBits);
asm // using simple monotonous instructions
  cmp ecx,maxfactnBits+1; jb @@Start; ret
@@Start: push ebx; xor ebx,ebx
  jmp ecx*4+@@zmp;
  @@zmp: dd @@32bit,@@64bit,@@128bit//,@@256
  //@@256: mov [edx+16],ebx; mov [edx+20],ebx; mov [edx+24],ebx; mov [edx+28],ebx
  @@128bit: mov [edx+08],ebx; mov [edx+12],ebx;
  @@64bit: mov [edx+4],ebx;
  @@32bit: mov [edx],ebx;
    mov ebx,eax; cmp eax,34+1;
    sbb ecx,ecx; add ebx,eax;
    add eax,eax; add ebx,eax;
    add eax,eax; and eax,ecx;
    mov ecx,ebx; lea ebx,ebx+simplefact
    jz @@Stop
  @@t01: sub eax,13*4; jnb @@t13
    mov eax,[ebx]; mov [edx],eax; pop ebx; ret
  @@t13: sub eax,(21-13)*4; jnb @@t21
    mov eax,[ebx+ecx-13*4]; mov ecx,[ebx+ecx-13*4+4]
    mov [edx],eax; mov [edx+4],ecx; pop ebx; ret
  @@t21: add eax,eax; add ebx,13*4+8*8;
         add eax,eax; sub ebx,ecx; add ebx,eax
    mov eax,[ebx]; mov ecx,[ebx+4]
    mov [edx],eax; mov [edx+4],ecx
    mov eax,[ebx+8]; mov ecx,[ebx+12]
    mov [edx+8],eax; mov [edx+12],ecx
@@Stop: pop ebx; //ret
end;

function GetInt128MaxNBase(const Value): tfactorialNBase;
asm
  mov edx,eax+12; mov ecx,eax+8;
  push ecx; or ecx,edx;
  pop ecx; mov esp-8,edx;
  mov edx,eax+4; mov eax,[eax];
  jz GetInt64MaxNBase+$60-$58
  push ebx; mov ebx,edx;
  mov edx,esp-4; // be careful on direct external jump+offset
  push esi; push edi;
  xor esi,esi; mov edi,offset @@ret;
  test edx,edx; jz @@t24; jmp @@t31;

  @@t31: cmp edx,k31D; jb @@t29; jnz @@t33;
  // after here, it MUST be 31 or 30
  cmp eax,k31A; sbb ebx,k31B; sbb ecx,k31C; //sbb edx,k31D;
  sbb esi,-31; jmp edi

// =======================================
// zero edx follows
// =======================================
        @@t21: cmp ecx,k21C; jnz @@t21S; // after here, MUST be 21 or 20
        cmp eax,k21A; sbb ebx,k21B; //sbb ecx,k21C; // msb already compared
        @@t21S: sbb esi,-21; jmp edi

    @@t22: cmp ecx,k22C; jb @@t21; jnz @@t23; // after here, MUST be 22 or 21
    cmp eax,k22A; sbb ebx,k22B; //sbb ecx,k22C; // msb already compared
    sbb esi,-22; jmp edi

        @@t23: cmp ecx,k23C; jnz @@t23S; // after here, MUST be 23 or 22
        cmp eax,k23A; sbb ebx,k23B; //sbb ecx,k23C; // msb already compared
        @@t23S: sbb esi,-23; jmp edi

//=========================================
@@t24: cmp ecx,k24C; jb @@t22; jnz @@t26; // after here, MUST be 24 or 23
cmp eax,k24A; sbb ebx,k24B; //sbb ecx,k24C;
sbb esi,-24; jmp edi
//=========================================

        @@t25: cmp ecx,k25C; jnz @@t25S; // after here, MUST be 25 or 24
        cmp eax,k25A; sbb ebx,k25B; //sbb ecx,k25C; // msb already compared
        @@t25S: sbb esi,-25; jmp edi

    @@t26: cmp ecx,k26C; jb @@t25; jnz @@t27; // after here, MUST be 26 or 25
    cmp eax,k26A; sbb ebx,k26B; //sbb ecx,k26C; // msb already compared
    sbb esi,-26; jmp edi

        @@t27: cmp ecx,k27C; jnz @@t27S; // after here, MUST be 27 or 26
        cmp eax,k27A; sbb ebx,k27B; //sbb ecx,k27C; // msb already compared
        @@t27S: sbb esi,-27; jmp edi

// =======================================
// non-zero edx follows
// =======================================
        @@t28: cmp edx,k28D; jnz @@t28S; // after here, MUST be 28 or 28
        cmp eax,k28A; sbb ebx,k28B; sbb ecx,k28C; //sbb edx,k28D; // msb already compared
        @@t28S: sbb esi,-28; jmp edi

    @@t29: cmp edx,k29D; jb @@t28; jnz @@t30; // after here, MUST be 29 or 28
    cmp eax,k29A; sbb ebx,k29B; sbb ecx,k29C; //sbb edx,k29D; // msb already compared
    sbb esi,-29; jmp edi

        @@t30: cmp edx,k30D; jnz @@t30S; // after here, MUST be 30 or 29
        cmp eax,k30A; sbb ebx,k30B; sbb ecx,k30C; //sbb edx,k30D; // msb already compared
        @@t30S: sbb esi,-30; jmp edi

//  @@t31: cmp edx,k31D; jb @@t29; jnz @@t33;
//  // after here, MUST be 31 or 30
//  cmp eax,k31A; sbb ebx,k31B; sbb ecx,k31C;
//  sbb edx,k31D; sbb esi,-31; jmp edi

        @@t32: cmp edx,k32D; jnz @@t32S; // after here, MUST be 32 or 32
        cmp eax,k32A; sbb ebx,k32B; sbb ecx,k32C; //sbb edx,k32D; // msb already compared
        @@t32S: sbb esi,-32; jmp edi

    @@t33: cmp edx,k33D; jb @@t32; jnz @@t34; // after here, MUST be 33 or 30
    cmp eax,k33A; sbb ebx,k33B; sbb ecx,k33C; //sbb edx,k33D; // msb already compared
    sbb esi,-33; jmp edi

        @@t34: cmp edx,k34D; jnz @@t34S; // after here, MUST be 34 or 33
        cmp eax,k34A; sbb ebx,k34B; sbb ecx,k34C; //sbb edx,k34D; // msb already compared
        @@t34S: sbb esi,-34; jmp edi

  @@ret: mov eax,esi; pop edi; pop esi; pop ebx;
end;

procedure int128sub(var A: r128; const B: r128);
asm
  push esi; push edi; push ecx;
  mov ecx,[edx]; mov esi,[eax];
  mov edi,[eax+4]; sub esi,ecx;
  mov ecx,[edx+4]; mov [eax],esi;
  sbb edi,ecx; mov ecx,[edx+8];
  mov [eax+4],edi; mov esi,[eax+8];
  mov edi,[eax+12]; mov edx,[edx+12]
  sbb esi,ecx; sbb edi,edx;
  mov [eax+8],esi; mov [eax+12],edi
  pop ecx; pop edi; pop esi;
end;

procedure int128subD(var A: r128; const I: integer);
asm
  mov ecx,[eax]; neg edx; jz @@Stop
  add ecx,edx; mov edx,eax+4; mov [eax],ecx;
  sbb edx,0; mov ecx,eax+08; mov eax+4,edx
  sbb ecx,0; mov edx,eax+12; mov eax+8,ecx
  sbb edx,0; mov eax+12,edx
@@Stop:
end;

function GetCombi_old(const Index: Int64; BaseOrder: string = ''): string;
//note that Index is zero based
var
  i, l, n: integer;
  X, R, t: uInt64;
begin
  Result := '';
  R := Index; //dont forget, it's zero -based
  n := GetInt64MaxNBase(r);
  //l := length(BaseOrder);
  //if l < (n + 1) then l := (n + 1);
  //ValidateAnOrder(BaseOrder, l);
  for i := length(BaseOrder) - 1 downto 1 do begin
    //calculate divisor (of next-under-level factorial) and it's remainder
    //X := nfactorial(i);
    //if r >= 0 then n := r div X
    //else begin
    //  //special-case to overcome negative value
    //  t := high(r) mod X + (high(r) + r) mod X + 2 mod X; //2's complement
    //  n := high(r) div X + (high(r) + r) div X + t div X;
    //  r := t;
    //end;

    X := nfactorial(i);
    //n := uInt64Mod(R, X);

    Result := Result + BaseOrder[n + 1];
    delete(BaseOrder, n + 1, 1);
    //r := r mod X;
  end;
  if BaseOrder <> '' then
    Result := Result + BaseOrder;
end;

{.$DEFINE DEBUG}
{$IFDEF DEBUG}
const
  f8f8: int64 = $F8F8F8F8F8F8F8F8;
  aaaa: int64 = $AAAAAAAAAAAAAAAA;
  cccc: int64 = $CCCCCCCCCCCCCCCC;
  x777: int64 = $7777777777777777;
  x404: int64 = $4040404040404040;
  quest: int64 = $3F3F3F3F3F3F3F3F;

{$ENDIF DEBUG}

const
  maxfactLength = 35;
  maxfactLenFold8 = maxfactLength div 8 * 8 + 8;
  maxfactnBits = high(tfactnBits);
  intXSize = 4 shl ord(maxfactnBits);
  intXdword = intXSize div 4;
  intXqword = intXSize div 8;

function GetCombi128(const Value): tCombinationIndex;
const
  //maxfactLen = 35 div 8 * 8 + 8;
  stackBuf = (intXSize * 2 + maxfactLenFold8) div 16 * 16 + 16;
var
  R, X: array[0..intXqword - 1] of int64;
  Order, Base: array[0..maxfactLenFold8 - 1] of char;
const
  varSize = sizeof(R) * 2 + sizeof(Base) * 2;
asm
  or ecx,-1; //init
  mov dword ptr[R],ecx; mov dword ptr[X],ecx;
  mov dword ptr[Order],ecx; mov dword ptr[Base],ecx;
  push esi; mov esi,edx;
  push eax; mov eax,edx;
  call System.@LStrClr;
  mov eax,[esp]; call GetInt128MaxNBase;
  pop edx; test eax,eax;
  lea eax,eax+1; jz @@ends;
{$IFDEF DEBUG}
  push varSize/8; pop ecx
  fild quest; @@ltst0: fld st; fistp qword ptr [ecx*8+Base-8];
  dec ecx; jnz @@ltst0; fstp st;
{$ENDIF DEBUG}
  mov dword ptr[Order-4],eax
  push edx; mov edx,eax;
  push eax; mov eax,esi;
  call System.@lStrSetLength
  pop ecx; mov esi,[eax];
  pop edx; mov eax,ecx;
  push ebx; and ecx,3;
  push edi; //push ebp;

  or ebx,-1; shl ecx,3;
  shl ebx,cl; mov ecx,ebx;

  fild qword ptr edx+0; fild qword ptr [edx+8]; fxch;
  fistp qword ptr R; fistp qword ptr [R+8]

  lea edi,Base
  mov ebx,eax; not ecx;
  shr eax,2; mov edx,04030201h;
  jz @@lb;
  @@ld: mov [edi],edx; add edi,4; add edx,04040404h; dec eax; jnz @@ld
  @@lb: and edx,ecx; mov [edi],edx;

  push esi; jmp @@LoopX; mov eax,eax;
  @@cmptable: dd @@dd1,@@dd2,@@dd3,@@dd4

  @@LoopX: dec ebx; jz @@LoopX_done
    cmp ebx,12; sbb eax,eax; cmp ebx,20; sbb edx,edx;
    cmp ebx,28; sbb eax,0; add eax,edx;
    mov eax,eax*4+@@cmptable+4*4-4; push eax

    movzx eax,bx; lea edx,X;
    push maxfactnBits; pop ecx; call nfactorial2
    xor ecx,ecx;
    @@lCtr:
      mov edx,dword ptr[X+00]; mov edi,dword ptr[R+00]; { update cache }
      jmp [esp];

      @@dd4:
      mov edx,dword ptr[X+12]; mov edi,dword ptr[R+12];
      cmp edi,edx; jb @@Storedt; mov edx,dword ptr[X+8]; mov edi,dword ptr[R+8]; jnz @@lsub;
      cmp edi,edx; jb @@Storedt; mov edx,dword ptr[X+4]; mov edi,dword ptr[R+4]; jnz @@lsub;
      cmp edi,edx; jb @@Storedt; mov edx,dword ptr[X+0]; mov edi,dword ptr[R+0]; jnz @@lsub;
      cmp edi,edx; jb @@Storedt; jnz @@lsub;
      jmp @@equal

      @@dd3:
      mov edx,dword ptr[X+8]; mov edi,dword ptr[R+8];
      cmp edi,edx; jb @@Storedt; mov edx,dword ptr[X+4]; mov edi,dword ptr[R+4]; jnz @@lsub;
      cmp edi,edx; jb @@Storedt; mov edx,dword ptr[X+0]; mov edi,dword ptr[R+0]; jnz @@lsub;
      cmp edi,edx; jb @@Storedt; jnz @@lsub;
      jmp @@equal

      @@dd2:
      mov edx,dword ptr[X+4]; mov edi,dword ptr[R+4];
      cmp edi,edx; jb @@Storedt; mov edx,dword ptr[X+0]; mov edi,dword ptr[R+0]; jnz @@lsub;
      cmp edi,edx; jb @@Storedt; jmp @@lsub;//jnz @@lsub;
      jmp @@equal

      @@dd1:
      cmp edi,edx; jb @@Storedt; jnz @@lsub;
      jmp @@equal

      @@equal: //jmp @@lsub;

      @@lsub:
        mov eax,dword ptr[X+0]; mov edx,dword ptr[X+4];
        mov esi,dword ptr[R+0]; mov edi,dword ptr[R+4];
        sub esi,eax; sbb edi,edx;
        mov dword ptr[R+0],esi; mov dword ptr[R+4],edi;

        mov eax,dword ptr[X+08]; mov edx,dword ptr[X+12];
        mov esi,dword ptr[R+08]; mov edi,dword ptr[R+12];
        sbb esi,eax; sbb edi,edx;
        mov dword ptr[R+08],esi; mov dword ptr[R+12],edi;

      inc ecx; jmp @@lCtr;
    @@storedt: //pop esi;
    lea edi,Base+1; xor eax,eax;
    add edi,ecx; mov al,[ecx+Base];
    movzx edx,word ptr[Order-2]; mov [edx+Order],al;
    mov edx,dword ptr[Order-4]; add edx,0ffffh; { dec lo-word; inc hi-word }
    movzx eax,dx; mov dword ptr[Order-4],edx;
    sub eax,ecx; push eax;
    shr eax,2; jz @@mvt2;
    @@lvb4: mov edx,[edi]; mov [edi-1],edx; add edi,4; sub eax,1; jnz @@lvb4
    @@mvt2: pop eax; and eax,3; jz @@mv_done
    @@mvb2: shr eax,1; jz @@mvb1; mov dx,[edi]; mov [edi-1],dx; lea edi,edi+2
    @@mvb1: jnb @@mv_done; mov dl,[edi]; mov [edi-1],dl; inc edi
    @@mv_done: mov byte ptr [edi-1],0;

    pop eax; jmp @@LoopX

  @@LoopX_done:
  pop edi; lea esi,Order
  xor eax,eax; movzx ecx,word[Order-2];
  mov al,byte ptr[Base]; mov ecx+Order,al
  add ecx,1; mov dword ptr Order-4,ecx
  push ecx; shr ecx,2; jz @@mvb; rep movsd
  @@mvb: pop ecx; and ecx,3; jz @@mve; rep movsb
  @@mve:
  pop edi; pop ebx;
@@ends: pop esi;
@@Stop:
end;

//function GetCombi128(const Value; Base: string): string;
//  cmp ecx,eax; jnb @@len_OK
//    push eax; push esi;
//    mov edx,eax; mov eax,esp;
//    push ecx; call System.@LStrSetLength;
//    pop eax; mov ecx,[esp+4];
//    mov esi,[esp]; sub ecx,eax;
//    add esi,eax; push ecx;
//    push 1; pop edx;
//    xor eax,eax; shr ecx,2;
//    jz @@lcx_b;
//    @@lcx_d:
//      mov [esi],al; mov [esi+1],dl;
//      add al,2; add dl,2;
//      mov [esi+2],al; mov [esi+3],dl;
//      add esi,4; add al,2;
//      add dl,2; sub ecx,1;
//      jnz @@lcx_d;
//    @@lcx_b:
//      pop ecx; and ecx,3;
//      shr ecx,1; jz @@lcx_tb;
//      mov [esi],al; lea eax,eax+2
//      mov [esi+1],dl; lea esi,esi+2;
//    @@lcx_tb: jnb @@lcxdone; mov [esi],al;
//    @@lcxdone: pop esi; pop eax;
//  @@len_OK:
//  mov ebx,eax; mov dword ptr [stack.Order],eax;

  //cmp ecx,eax; jnb @@len_OK
  //  push eax; push esi;
  //  mov edx,eax; mov eax,esp;
  //  push ecx; call System.@LStrSetLength;
  //  pop eax; mov ecx,[esp+4];
  //  mov esi,[esp]; sub ecx,eax;
  //  add esi,eax; push ecx;
  //  push 1; pop edx;
  //  xor eax,eax; shr ecx,2;
  //  jz @@lcx_b;
  //  @@lcx_d:
  //    mov [esi],al; mov [esi+1],dl;
  //    add al,2; add dl,2;
  //    mov [esi+2],al; mov [esi+3],dl;
  //    add esi,4; add al,2;
  //    add dl,2; sub ecx,1;
  //    jnz @@lcx_d;
  //  @@lcx_b:
  //    pop ecx; and ecx,3;
  //    shr ecx,1; jz @@lcx_tb;
  //    mov [esi],al; lea eax,eax+2
  //    mov [esi+1],dl; lea esi,esi+2;
  //  @@lcx_tb: jnb @@lcxdone; mov [esi],al;
  //  @@lcxdone: pop esi; pop eax;
  //@@len_OK:
  //mov ebx,eax; mov dword ptr [stack.Order],eax;

procedure __fastMove(const Source; var Dest; Count: Integer); assembler asm
//from fastCode (John O'Harrow) fast! Move
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

function GetCombIndex64(const Value, Base: string): int64; overload;
asm

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
  mov eax,Result; mov edx,_TypeInfo;
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

function isValidSubSet_OK(const Value, Base: string): boolean;
// no duplicated chars in both Value and Base
// all chars in Value also exist in Base (Base is superset of Value)
var
  chSet: set of char;
asm
  xor ecx,ecx; cmp ecx,edx;
  sbb ecx,ecx; and eax,ecx; jz @@Stop;
  push esi; mov esi,Value
  push edi; lea edi,ChSet
  add ecx,8+1; xor eax,eax; rep stosd;
  mov ecx,[Base-4];
  mov edi,Base; xor edx,edx;
  @@lset: mov al,[edi]; add edi,1; btc dword[chSet],eax; jb @@test_done
          dec ecx; jnz @@lset
  @@lset_done: mov ecx,[esi-4];
  @@vtst: mov al,[esi]; inc esi; btc dword[chSet],eax; jnb @@test_done
          dec ecx; jnz @@vtst
  @@vtst_done: or edx,1;
  @@test_done: movzx eax,dl; neg eax;
  @@ends: pop edi; pop esi;
  @@Stop:
end;

function isValidSubSet(const Order, Base: string): boolean;
// no duplicated chars in Base (but not necessarily did so in Order)
// all chars in Order must also exist in Base (Base is a superset of Order)
// destroys: eax,ecx,edx
asm
  xor ecx,ecx; cmp ecx,edx;
  sbb ecx,ecx; and eax,ecx;
  @@08h: jz @@Stop;
  push esi; push edi;
  lea edi,esp-20h; add esp,-20h;
  mov esi,Order; // here ecx is -1
  add ecx,8+1; xor eax,eax; rep stosd;
  mov ecx,[Base-4];
  mov edi,Base; xor edx,edx;
  @@lset: mov al,[edi]; add edi,1; btc [esp],eax; jb @@test_done
          dec ecx; jnz @@lset
  @@lset_done: mov ecx,[esi-4];
  @@vtst: mov al,[esi]; inc esi; bt [esp],eax; jnb @@test_done
          dec ecx; jnz @@vtst
  @@vtst_done: or edx,1;
  @@test_done: movzx eax,dl; neg eax;
  @@ends: lea esp,esp+20h; pop edi; pop esi;
  @@Stop:
end;

function isValidOrderPair(const Order, Base: string): boolean;
// check lengths; if both are equals then call isValidSubSet
// destroys: eax,ecx; preserved: edx
asm
  xor ecx,ecx; cmp ecx,edx;
  sbb ecx,ecx; and eax,ecx; jz @@Stop;
  push eax; mov eax,eax-4;
  mov ecx,edx-4; sub ecx,eax;
  setnz al; movzx ecx,al
  pop eax; sub ecx,1;
  {and eax,ecx;} jmp isValidSubSet+8-2
  @@Stop:
end;

function isValidOrder_slower(const Value, Base: string): boolean;
asm
  xor ecx,ecx; cmp ecx,edx;
  sbb ecx,ecx; and eax,ecx; jz @@Stop;
  push esi; mov esi,Value;
  push edi; mov edi,Base;
  mov ecx,[esi-4]; mov edx,[edi-4];
  xor eax,eax;
  push ebx; xor ebx,ebx;
  @@Loop1: mov al,[esi]; lea esi,esi+1; push edx;
    @@L2: mov bl,[edi]; lea edi,edi+1; sub bl,al; jz @@L2done;
          sub edx,1; jnz @@L2
    @@L2done: pop edx; test bl,bl; sete bl; jnz @@Loop1done
    sub edi,edx; sub ecx,1; jnz @@Loop1
  @@Loop1done: movzx eax,bl; neg eax//cbw; cwde;
  pop ebx;
  pop edi; pop esi;
@@Stop:
end;

function GetIndexNo1(const AnOrder, BaseOrder: string): Int64;
var
  i, n, L: integer;
  S: string;
  Ch: Char;

  function putElemen(const Ch: Char): integer;
  var
    i, n: integer;
  begin
    if S = '' then S := Ch
    else begin
      n := pos(Ch, BaseOrder);
      for i := 1 to Length(S) do begin
        if pos(S[i], BaseOrder) > n then begin
          insert(Ch, S, pos(S[i], S));
          break;
        end
      end;
      if i > length(S) then
        S := S + Ch;
    end;
    Result := pos(Ch, S);
  end;

begin
  S := ''; Result := 0;
  if not isValidOrderPair(ANOrder, BaseOrder) then exit;
  //ValidateOrderChoice(AnOrder, BaseOrder);
  L := length(AnOrder);
  for i := L downto 1 do begin
    Ch := AnOrder[i];
    n := putElemen(Ch);
    dec(n);
    if n > 0 then //also prevent factor(0);
      Result := Result + nfactorial(L - i) * Int64(n);
  end;
end;

function bitCount(const I: integer): integer;
asm // I and (I-1)
  cmp eax,1; sbb ecx,ecx;
  @@Loop: inc ecx; lea edx,eax-1; and eax,edx; jnz @@Loop;
  mov eax,ecx;
end;

// alternative, no branch, but using mul.
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

function bitCount64(const I: int64): integer;
asm
  push esi; mov edx,I.dword+4;
  push edi; mov eax,I.dword+0;
  push ebx; mov ecx,eax;
  or eax,edx; cmp eax,1;
  sbb eax,eax;
  @@Loop: inc eax;
    mov esi,ecx; mov edi,edx;
    sub esi,1; sbb edi,0;
    and ecx,esi; and edx,edi;
    mov ebx,ecx; or ebx,edx;
  jnz @@Loop
  pop ebx; pop edi; pop esi;
end;

function bitCount128(const R: r128): integer;
asm
  mov ecx,R.dword+0; mov edx,R.dword+4;
  push esi; mov esi,R.dword+08;
  push edi; mov edi,R.dword+12;
  push ebx; push ebp;
  mov eax,ecx; push edi;
  or eax,edi; push esi;
  or eax,esi; push edx;
  or eax,edx; push ecx;
  cmp eax,1; sbb eax,eax;
  @@Loop: inc eax;
    sub ecx,1; sbb edx,0; sbb esi,0; sbb edi,0; mov ebx,ecx;
    and ecx,[esp+00]; mov [esp+00],ebx; mov ebx,[esp+04]; mov ebp,ecx;
    and edx,[esp+04]; mov [esp+04],ebx; mov ebx,[esp+08];  or ebp,edx;
    and esi,[esp+08]; mov [esp+08],ebx; mov ebx,[esp+12];  or ebp,esi;
    and edi,[esp+12]; mov [esp+12],ebx; {              };  or ebp,edi;
  jnz @@Loop;
  mov ebp,[esp+16]; mov ebx,[esp+20]; mov edi,[esp+24]; mov ebx,[esp+28];
  add esp,32;
end;

function haszerobyte64(const I: int64): boolean; asm
// Result := (I - $0101010101010101) and not I and $8080808080808080 <> 0;
  push ebx
  mov eax,I.dword; mov edx,I.dword+4;
  mov ebx,eax; mov ecx,edx;
  sub eax,10101010h; sbb edx,10101010h;
  and ebx,80808080h; and ecx,80808080h;
  and eax,ebx; and edx,ecx;
  or eax,edx; pop ebx;
end;

function haszerobyte(const I: integer): boolean; asm
// Result := boolean((I - $01010101) and not I and $80808080);
  mov edx,eax; not eax;
  sub edx,10101010h; and eax,80808080h;
  and eax,edx;
end;

function isPowerOf2(const I: integer): boolean;
begin //Result := I and (I - 1) = 0;
  Result := boolean(not (I and (I - 1)) and I);
end;

function GetIndexNo2(const AnOrder, BaseOrder: string): Int64;
var
  S: string;
  Ch, Ck: Char;
  m, n, k, q, L, SLen: integer;
  X: int64;
begin
  S := ''; Result := 0; //S`will be equal with baseorder at last
  //ValidateOrderChoice(AnOrder, BaseOrder);
  if not isValidOrderPair(AnOrder, BaseOrder) then exit;
  L := Length(AnOrder);
  Ch := AnOrder[L]; S := Ch;
  if L > 1 then begin
    //Result := pos(Ch, BaseOrder);
    for n := L - 1 downto 1 do begin
      Ch := AnOrder[n];
      m := pos(Ch, BaseOrder);
      k := 0; SLen := length(S);
      repeat
        inc(k);
        Ck := S[k];
      until (k > SLen) or (pos(Ck, BaseOrder) > m);
      insert(Ch, S, k);
      dec(k); // here k will always > 0
      Result := Result + nfactorial(L - n) * Int64(k);
    end;
  end;
  //if S='' then exit;
end;

procedure int128addD(var X: r128; const I: integer);
asm
  mov ecx,[eax]; add ecx,edx;
  mov edx,eax+4; mov [eax],ecx;
  adc edx,0; mov ecx,eax+08;
  mov eax+04,edx; adc ecx,0;
  mov ecx,eax+12; adc edx,0;
  adc ecx,0; mov eax+08,edx;
  mov eax+12,ecx;
end;

function GetIndexNo128(const AnOrder, BaseOrder: string): r128;
var
  S: string;
  Ch, Ck: Char;
  i, m, n, k, q, L, SLen: integer;
  X: int64;
begin
  S := '';
  //ValidateOrderChoice(AnOrder, BaseOrder);
  if not isValidOrderPair(AnOrder, BaseOrder) then exit;
  n := 0;
  Result.I[0] := n; Result.I[1] := n;
  Result.I[2] := n; Result.I[3] := n;
  L := Length(AnOrder);
  Ch := AnOrder[L]; S := Ch;
  if L > 1 then begin
    //Result := pos(Ch, BaseOrder);
    for n := L - 1 downto 1 do begin
      Ch := AnOrder[n];
      m := pos(Ch, BaseOrder);
      k := 0; SLen := length(S);
      repeat
        inc(k);
        Ck := S[k];
      until (k > SLen) or (pos(Ck, BaseOrder) > m);
      insert(Ch, S, k);
      repeat dec(k)

      until k <= 1;

      //dec(k); // here k will always > 0
      //Result := Result + nfactorial(L - n) * Int64(k);
    end;
  end;
end;

function GetCombIndex128_unfinished(const Order, Base: string): r128; overload;
const
  maxnfactLen = 35;
var
  S: string[39];
  CPos: array[byte] of byte;
asm
  //fldz; fst qword[Result]; fstp qword[Result+8];
  push esi; mov esi,Order;
  xor eax,eax; push edi;
  mov ecx+0,eax; mov ecx+04,eax;
  mov ecx+8,eax; mov ecx+12,eax;
  push ebx; mov ebx,Result;
  mov edi,Base; call isValidOrderPair; jz @@ends
  mov ecx,[edi-4]; cmp ecx,maxnfactLen; jnb @@ends;
  cmp ecx,2; jb @@ends
  xor edx,edx; xor eax,eax;
  mov dl,[esi+ecx]; lea esi,esi+ecx-2;
@@lpos:
  mov al,[edi+ecx]; sub ecx,1; mov eax+CPos,cl; jnz @@lpos
  //mov r.L,ecx; mov r.L+4,ecx; mov r.L+8,ecx; mov r.L+12,ecx;
  fldz; fst S.qword; fst S.qword+8; fst S.qword+16
        fst S.qword+24; fstp S.qword+32;
  mov dl,edx+CPos; mov S.byte+4*8+4,1;
  mov ecx,[edi-4]; mov S.byte,dl;
  sub ecx,1; xor edx,edx; xor eax,eax;
  @@lp: mov al,[esi]; sub esi,1;
    sub ecx,1; jz @@lp_done
    xor edi,edi; mov al,eax+CPos;
    @@getk: mov dl,edi+S; add edi,1;
      test edx,edx; jz @@getk_done2
      mov dl,edx+CPos; cmp dl,al;
      jbe @@getk
    @@getk_done1:
      push eax; lea eax,edi+S
      lea edx,edi+S+1; push ecx;
      xor ecx,ecx; mov cl,S.byte+36
      sub ecx,edi; call __fastMove+4
      pop ecx; pop eax;
    @@getk_done2: //jz
      inc S.byte+4*8+4; mov edi+S,al;

  @@lp_done:

  @@ends: pop ebx; pop edi; pop esi;
@@Stop:
end;

{
  function GetSeqIndex(const Order, Base: string; out Index): boolean; overload;
  get Order Index (zero-based sequence number) for given Order and Base string.
  Order and Base must be of the same length and characters set (any char except #0).
  max. Length is 254, no duplicated chars allowed (string is a uniq chars list).
  if Order-Base is not such a valid pair, this routine will return false and clear
  the Index (note that Index = 0 also returned if Order is equal with Base, in this
  case the routine result is true).

  routine flows:
    1. clear result
    2. check Validity; exit if not valid.
    3. for length < 2 return Index := 1 if Order <> Base
    -  clear Charset: set of Char;
    4. proceed last-2 chars of string Order:
       - skip last char since it will always set Index := 0
       - if second-last char Index > last char Index set Index := 1;
       - make charset (set of char of those last-2 chars)
       note: 256 bits of charset divided as 8 dwords, each of 32 bits.
    5. Loop
         N = Counter-up as factorial NBase, start from 2;
         i = current char Index (string Order) => x = bit-index in charset
         include x to
         k = multiplier;
         get k by counting how many bits has been set on bit-indexes below x
         add (N! * k) to Index;
         continue Loop until all string Order exhausted N >= length(Order)
}

function getSeqIndex(const Order, Base: string): r128; overload;
asm
end;

function GetCombIndex128(const Order, Base: string): r128; overload;
const
  maxnfactLen = 35;
  maxnfactLenFold4 = maxnfactLen div 4 * 4 + 4;
  maxnfactLenFold8 = maxnfactLen div 8 * 8 + 8;
type
  TCombiVars = packed record
    CPos: string[127];
    R1, R2: r128;
    CSet: set of char;
    Len, addr: integer;
  end;
var
  S: TCombiVars;
const
  Zero: single = 0;
  N1: int64 = $2F2F2F2F2F2F2F2F;
  N2: int64 = $5858585858585858;
asm
  //fldz; fst qword[Result]; fstp qword[Result+8];
  mov S.Len,-1;
  push esi; mov esi,Order;
  xor eax,eax; push edi;
  mov ecx+0,eax; mov ecx+04,eax;
  mov ecx+8,eax; mov ecx+12,eax;
  mov edi,Base; mov S.addr,ecx
  push ebx; mov ebx,ecx;
  mov eax,esi; call isValidOrderPair; jz @@ends; // all gen.regs are destroyed
  //mov edx,[edi-4]; xor eax,eax;
  //cmp edx,maxnfactLen+1; setnb al;
  //cmp edx,2; jnz @@not2bytes;
  //cmpsb; setne [ebx]; jmp @@ends;
  ////mov ebx,[esp]; mov edi,[esp+4]; mov esi,[esp+8];
  ////lea esp,ebp+4; mov ebp,[ebp]; ret;
  mov edx,[edi-4]; xor eax,eax;
  xor ecx,ecx; cmp edx,3; jnb @@begin
  cmpsb; setne [ebx]; jmp @@ends;

  nop; //lea esp,[esp];
  @@jmpCountD: dd @@BitsD0,@@BitsD1,@@BitsD2,@@BitsD3,@@BitsD4,@@BitsD5,@@BitsD6,@@BitsD7;
  @@jmpMult: dd @@x00,@@x01,@@x03,@@x05,@@x07,@@x09,@@x11,@@x13,@@x15;
             dd @@x17,@@x19,@@x21,@@x23,@@x25,@@x27,@@x29,@@x31,@@x33;
  @@shl_tbl: dd @@save,@@shl1,@@shld;
  //@@not2bytes: sbb eax,0; jnz @@ends;
  //mov Len,edx
  ;//jmp @@ends;jmp @@ends;jmp @@ends;
  ;//push maxnfactLenFold8; pop edx;
  ;//fldz; @@lz: fst qword ptr[edx+S-8]; sub edx,8; jnz @@lz; fstp S.qword;
  ;//fldz; fst r.qword; fstp r.qword+8;

  @@begin:

  //fld Zero; fst CSet.qword; fst CSet.qword+8; fst CSet.qword+16; fstp CSet.qword+24;
  mov S.CSet.dword+00,eax; mov S.CSet.dword+04,eax;
  mov S.CSet.dword+08,eax; mov S.CSet.dword+12,eax;
  mov S.CSet.dword+16,eax; mov S.CSet.dword+20,eax;
  mov S.CSet.dword+24,eax; mov S.CSet.dword+28,eax;
  {.$define debug}
  {$IFDEF DEBUG}
    push ecx; push ebx;
    push type TCombiVars.CPos/8; pop ecx;
    lea ebx,S.CPos-8;
    fld Zero; fchs; @@lcz: fld st; fistp [ebx+ecx*8].qword; dec ecx; jnz @@lcz; fstp st;
    fild n1; fld st; fistp S.R1.qword; fistp S.R1.qword+8;
    pop ebx; pop ecx;
  {$ENDIF DEBUG}

  lea ebx,S.CPos;
  lea edi,edi+edx-1;
  mov cl,[esi+edx-1]; lea esi,esi+edx-2; // cl = last char; esi to second-last char
  //@@getmin: //if (edx > 35) then edx := 35;
  sub edx,maxnfactLen+1; sbb eax,eax;
  and edx,eax; xor eax,eax;
  add edx,maxnfactLen+1;

  add ecx,ebx;

  //@@getmin: //if (ebx > eax) then ebx := eax;
  //  sub eax,ebx; sbb ecx,ecx;
  //  and ecx,eax; add ebx,ecx;


  mov S.Len,edx; @@lpos: mov eax+ebx,dl; mov al,[edi]; sub edi,1; sub edx,1; jnl @@lpos; //excess+1 is no-harm
  mov al,[esi]; mov edi,[edi-4+2]; //al = second-last char
  movzx ecx,[ecx]; // ecx = index of first char
  mov al,[eax+ebx]; mov ebx,S.addr;  // al = index of second-last char
  sub edi,2; add edx,2;
  cmp eax,ecx mov ch,cl; // if second-last char index > last char index; it means +1
  mov edi,edx; setnb [ebx];
  shl edx,cl; mov cl,al;
  shr eax,5;
  shl edi,cl; mov ebx,S.Len;
  shr ecx,5+8; add bx,0ffh;
  sub esi,1; mov S.Len,ebx;
  mov ecx*4+S.CSet,edx;
  mov edx,eax*4+S.CSet;
  or edx,edi;
  mov eax*4+S.CSet,edx;
  @@mainLoop: // N capacity: upto 256
    lea ebx,S.CPos
    xor edx,edx; mov eax,S.Len;
    mov dl,[esi]; add ax,0ffh; //get 3rd char;inc ah; dec al
    test dl,dl; jz @@mainLoop_done;
    xor ecx,ecx; sub esi,1;
    //test al,al; jl @@mainLoop_done;
    mov cl,edx+ebx; xor edx,edx;
    mov S.Len,eax; mov dl,1;
    //movzx ecx,edx+S.CPos; mov edx,1
    shl edx,cl; //NP, bit-position
    //sub ecx,1; //get dword position offset-1
    //adc ecx,0;
    shr ecx,5; mov edi,ecx;
    add ecx,ecx; lea ebx,S.CSet-4;
    add ecx,ecx; mov eax,edi*4+S.CSet;
    add ebx,ecx; or eax,edx;
    //cmp edx,1; jz @@skip
    sub edx,1;
    //cmp edx,1; sbb edx,0
    @@skip: mov ecx+S.CSet,eax;
    and edx,eax; mov eax,edx;
    cmp eax,1; sbb edi,edi; jmp ecx+@@jmpCountD;
    //@@BitsD7: dec edx; inc edi; and eax,edx; mov edx,eax; jnz @@BitsD7; @D7_1ck: mov edx,[ebx]; sub ebx,4; cmp edx,1; jb @D6_1ck; //sbb edi,0
    //@@BitsD6: dec edx; inc edi; and eax,edx; mov edx,eax; jnz @@BitsD6; @D6_1ck: mov edx,[ebx]; sub ebx,4; cmp edx,1; jb @D5_1ck; //sbb edi,0
    //@@BitsD5: dec edx; inc edi; and eax,edx; mov edx,eax; jnz @@BitsD5; @D5_1ck: mov edx,[ebx]; sub ebx,4; cmp edx,1; jb @D4_1ck; //sbb edi,0
    //@@BitsD4: dec edx; inc edi; and eax,edx; mov edx,eax; jnz @@BitsD4; @D4_1ck: mov edx,[ebx]; sub ebx,4; cmp edx,1; jb @D3_1ck; //sbb edi,0
    //@@BitsD3: dec edx; inc edi; and eax,edx; mov edx,eax; jnz @@BitsD3; @D3_1ck: mov edx,[ebx]; sub ebx,4; cmp edx,1; jb @D2_1ck; //sbb edi,0
    //@@BitsD2: dec edx; inc edi; and eax,edx; mov edx,eax; jnz @@BitsD2; @D2_1ck: mov edx,[ebx]; sub ebx,4; cmp edx,1; jb @D1_1ck; //sbb edi,0
    //@@BitsD1: dec edx; inc edi; and eax,edx; mov edx,eax; jnz @@BitsD1; @D1_1ck: mov edx,[ebx]; sub ebx,4; cmp edx,1; jb @D0_1ck; //sbb edi,0
    //@@BitsD0: dec edx; inc edi; and eax,edx; mov edx,eax; jnz @@BitsD0; @D0_1ck:
    @@BitsD7: inc edi; lea edx,eax-1; and eax,edx; jnz @@BitsD7; @D7_1ck: mov eax,[ebx]; sub ebx,4; cmp eax,1; jb @D6_1ck; //sbb edi,0
    @@BitsD6: inc edi; lea edx,eax-1; and eax,edx; jnz @@BitsD6; @D6_1ck: mov eax,[ebx]; sub ebx,4; cmp eax,1; jb @D5_1ck; //sbb edi,0
    @@BitsD5: inc edi; lea edx,eax-1; and eax,edx; jnz @@BitsD5; @D5_1ck: mov eax,[ebx]; sub ebx,4; cmp eax,1; jb @D4_1ck; //sbb edi,0
    @@BitsD4: inc edi; lea edx,eax-1; and eax,edx; jnz @@BitsD4; @D4_1ck: mov eax,[ebx]; sub ebx,4; cmp eax,1; jb @D3_1ck; //sbb edi,0
    @@BitsD3: inc edi; lea edx,eax-1; and eax,edx; jnz @@BitsD3; @D3_1ck: mov eax,[ebx]; sub ebx,4; cmp eax,1; jb @D2_1ck; //sbb edi,0
    @@BitsD2: inc edi; lea edx,eax-1; and eax,edx; jnz @@BitsD2; @D2_1ck: mov eax,[ebx]; sub ebx,4; cmp eax,1; jb @D1_1ck; //sbb edi,0
    @@BitsD1: inc edi; lea edx,eax-1; and eax,edx; jnz @@BitsD1; @D1_1ck: mov eax,[ebx]; sub ebx,4; cmp eax,1; jb @D0_1ck; //sbb edi,0
    @@BitsD0: inc edi; lea edx,eax-1; and eax,edx; jnz @@BitsD0; @D0_1ck: //mov eax,[ebx]; sub ebx,4; cmp eax,1; jb @Dx_1ck; //sbb edi,0

    mov ebx,S.addr; test edi,edi; jz @@mainLoop

    xor eax,eax; lea edx,S.R1
    push maxfactnBits; pop ecx
    mov al,S.Len.byte+1; //inc eax
      call nfactorial2;
    push esi; push ebx;

    //after this; only applied to int128
    mov eax,S.R1.dword+0; mov edx,S.R1.dword+04;
    mov ebx,S.R1.dword+8; mov esi,S.R1.dword+12;

    //triplets = ord(I > N) - ord(I < N); // -1, 0, or +1
    bsf ecx,edi; push ebx; xor ebx,ebx;
      cmp ecx,1; //jb @@save; jnz @@shld
      seta bl; sbb ebx,0; // -1, 0, or +1
      jmp ebx*4+@@shl_tbl+4; nop; nop;
    @@shl1:
      shl eax,1; pop ebx;
      rcl edx,1; rcl ebx,1; rcl esi,1;
      shr edi,1; push ebx; jmp @@save;
    @@shld:
      shr edi,cl; pop ebx;
      shld esi,ebx,cl; shld ebx,edx,cl;
      shld edx,eax,cl; shl eax,cl; push ebx;
    @@save: pop ebx;
      mov S.R1.dword+12,esi; mov S.R1.dword+8,ebx;
      mov S.R1.dword+04,edx; mov S.R1.dword+0,eax;
    @@cked: mov ecx,ebx; cmp edi,34-5; sbb ebx,ebx;
    and ebx,edi; inc ebx;
    shr ebx,1; jmp ebx*4+@@jmpMult


    //OK---------------------------------------------------------------------
    @@x21: {debug: OK} mov eax,eax;
           add eax,eax; adc edx,edx; adc ecx,ecx; adc esi,esi;
           //add eax,eax; adc edx,edx; adc ecx,ecx; adc esi,esi;
           //add eax,S.R1.dword+0; adc edx,S.R1.dword+04;
           //adc ecx,S.R1.dword+8; adc esi,S.R1.dword+12; jmp @@x05;
           //neg ebx; jmp ebx*4+@@jmpMult+4*11+4*3; //jmp ebx*4+@@jmpMult-4*8

    @@x19: {debug: OK} mov eax,eax;
           //add eax,eax; adc edx,edx; push eax; push edx;
           //adc ecx,ecx; adc esi,esi; push ecx; push esi;
           //add eax,S.R1.dword+00; adc edx,S.R1.dword+04;
           //mov S.R1.dword+00,eax; mov S.R1.dword+04,edx;
           //adc ecx,S.R1.dword+08; adc esi,S.R1.dword+12;
           //mov S.R1.dword+08,ecx; mov S.R1.dword+12,esi;
           //mov eax,esp+12; mov edx,esp+8; mov ecx,esp+4; mov esi,[esp];
           //add esp,16; jmp @@x09;
           neg ebx;
           add eax,eax; adc edx,edx; adc ecx,ecx; adc esi,esi;
           add eax,S.R1.dword+0; adc edx,S.R1.dword+04;
           adc ecx,S.R1.dword+8; adc esi,S.R1.dword+12; //jmp @@x07;
           jmp ebx*4+@@jmpMult+4*10+4*4; //jmp ebx*4+@@jmpMult-4*6

    //OK---------------------------------------------------------------------
    @@x31: {debug: OK} mov eax,eax; // 32n - r
           //push eax; push edi;
           //xor edi,edi; push 0; neg eax; sbb edi,edx;
           //mov S.R1.dword+0,eax; mov S.R1.dword+04,edi;
           //mov eax,[esp]; mov edi,[esp]; sbb eax,ecx; sbb edi,esi;
           //mov S.R1.dword+8,eax; mov S.R1.dword+12,edi;
           //mov edi,[esp+4]; mov eax,[esp+8]; add esp,12; jmp @@x33

    @@x23: {debug: OK} mov eax,eax; // 24n - r
           //push eax; push edi;
           //xor edi,edi; push 0; neg eax; sbb edi,edx;
           //mov S.R1.dword+0,eax; mov S.R1.dword+04,edi;
           //mov eax,[esp]; mov edi,[esp]; sbb eax,ecx; sbb edi,esi;
           //mov S.R1.dword+8,eax; mov S.R1.dword+12,edi;
           //mov edi,[esp+4]; mov eax,[esp+8]; add esp,12; //jmp @@x25
           //jmp ebx*4+@@jmpMult+4

    @@x15: {debug: OK} mov eax,eax; // 16n - r
           //add eax,eax; adc edx,edx; adc ecx,ecx; adc esi,esi;
           //add eax,S.R1.dword+0; adc edx,S.R1.dword+04;
           //mov S.R1.dword+0,eax; mov S.R1.dword+04,edx;
           //adc ecx,S.R1.dword+8; adc esi,S.R1.dword+12;
           //mov S.R1.dword+8,ecx; mov S.R1.dword+12,esi; jmp @@x05;
           push eax; push edi;
           xor edi,edi; push 0; neg eax; sbb edi,edx;
           mov S.R1.dword+0,eax; mov S.R1.dword+04,edi;
           mov eax,[esp]; mov edi,[esp]; sbb eax,ecx; sbb edi,esi;
           mov S.R1.dword+8,eax; mov S.R1.dword+12,edi;
           mov edi,[esp+4]; mov eax,[esp+8]; add esp,12; //jmp @@x17
           jmp ebx*4+@@jmpMult+4

    @@x29: {debug: OK} mov eax,eax; //jmp @@lmul
           add eax,eax; adc edx,edx; push eax; push edx;
           adc ecx,ecx; adc esi,esi; push ecx; push esi;
           add eax,eax; adc edx,edx; adc ecx,ecx; adc esi,esi;
           add eax,S.R1.dword+00; adc edx,S.R1.dword+04;
           mov S.R1.dword+00,eax; mov S.R1.dword+04,edx;
           adc ecx,S.R1.dword+08; adc esi,S.R1.dword+12;
           mov S.R1.dword+08,ecx; mov S.R1.dword+12,esi;
           add eax,eax; adc edx,edx; adc ecx,ecx; adc esi,esi;
           jmp @@_7a

    @@x11: {debug: OK} mov eax,eax; //10n +r
           push eax; push edx; add eax,eax; adc edx,edx;
           push ecx; push esi; adc ecx,ecx; adc esi,esi;
           add eax,eax; adc edx,edx; adc ecx,ecx; adc esi,esi;
           jmp @@_7a;
    //@@x10: add eax,eax; adc edx,edx; adc ecx,ecx; adc esi,esi;
    //       mov S.R1.dword+0,eax; mov S.R1.dword+04,edx; mov S.R1.dword+8,ecx; mov S.R1.dword+12,esi; jmp @@x05;
    //OK---------------------------------------------------------------------
    //@@x49: add eax,eax; adc edx,edx; adc ecx,ecx; adc esi,esi; jmp @@x25
    @@x25: {24n +r}  add eax,eax; adc edx,edx; adc ecx,ecx; adc esi,esi; jmp @@x13
    @@x13: {12n +r}  add eax,eax; adc edx,edx; adc ecx,ecx; adc esi,esi; jmp @@x07
    @@x07: {6n +r}   push eax; push edx; add eax,eax; adc edx,edx;
                     push ecx; push esi; adc ecx,ecx; adc esi,esi;
    @@_7a: {2n+2s+r} add eax,esp+12; adc edx,esp+8; adc ecx,esp+4; adc esi,[esp];
                     add esp,16; jmp @@x03;
    //OK??---------------------------------------------------------------------
    @@x27: {debug: OK} mov eax,eax; //3n,3r -> 24n + 3r
           add eax,eax; adc edx,edx; adc ecx,ecx; adc esi,esi;
           add eax,S.R1.dword+0; adc edx,S.R1.dword+04;
           mov S.R1.dword+0,eax; mov S.R1.dword+04,edx;
           adc ecx,S.R1.dword+8; adc esi,S.R1.dword+12;
           mov S.R1.dword+8,ecx; mov S.R1.dword+12,esi;
           jmp @@x09
    //OK---------------------------------------------------------------------
    @@x33: {32n +r} add eax,eax; adc edx,edx; adc ecx,ecx; adc esi,esi; jmp @@x17;
    @@x17: {16n +r} add eax,eax; adc edx,edx; adc ecx,ecx; adc esi,esi; jmp @@x09;
    @@x09: {8n +r}  add eax,eax; adc edx,edx; adc ecx,ecx; adc esi,esi; jmp @@x05;
    @@x05: {4n +r}  add eax,eax; adc edx,edx; adc ecx,ecx; adc esi,esi; jmp @@x03;
    //@@x12: add eax,eax; adc edx,edx; adc ecx,ecx; adc esi,esi; jmp @@x06;
    //@@x06: add eax,eax; adc edx,edx; adc ecx,ecx; adc esi,esi;
    //       mov S.R1.dword+0,eax; mov S.R1.dword+04,edx;
    //       mov S.R1.dword+8,ecx; mov S.R1.dword+12,esi; jmp @@x03;
    @@x03: {2n} add eax,eax; adc edx,edx; adc ecx,ecx; adc esi,esi; {2n +r}
    @@_3a: {+r} pop ebx; add eax,S.R1.dword+0; adc edx,S.R1.dword+04; {+r}
                         adc ecx,S.R1.dword+8; adc esi,S.R1.dword+12;
    jmp @@addstore;
    //@@x08: add eax,eax; adc edx,edx; adc ecx,ecx; adc esi,esi; jmp @@x04;
    //@@x04: pop ebx; add eax,eax; adc edx,edx; adc ecx,ecx; adc esi,esi; jmp @@x02;
    //@@x02: pop ebx; add eax,eax; adc edx,edx; adc ecx,ecx; adc esi,esi; jmp @@addstore;
    @@x01: pop ebx; jmp @@addstore;
    @@x00:
    @@lmul: mov ebx,edx;
      mul edi;
      push eax; mov eax,ebx; mov ebx,edx;
      mul edi;
      add eax,ebx;
      adc edx,0; push eax; mov eax,ecx; mov ebx,edx;
      mul edi;
      add eax,ebx;
      adc edx,0; mov ecx,eax; mov eax,esi; mov ebx,edx;
      mul edi;
      add eax,ebx; {adc edx,0}; mov esi,eax;
      mov ebx,esp+8; mov edx,[esp];
      mov eax,esp+4; add esp,+12;

    //@@lmul: dec edi; jz @@addstore
    //  adc eax,S.R1.dword+0; adc edx,S.R1.dword+04;
    //  adc ecx,S.R1.dword+8; adc esi,S.R1.dword+12;
    //  jmp @@lmul;

  @@addstore:
    add eax,ebx+0; adc edx,ebx+04; mov ebx+0,eax; mov ebx+04,edx
    adc ecx,ebx+8; adc esi,ebx+12; mov ebx+8,ecx; mov ebx+12,esi
    pop esi; jmp @@mainLoop

  @@mainLoop_done:

  @@ends: pop ebx; pop edi; pop esi;
@@Stop:
end;

{
  function GetOrder(const Index; const Base: string): string; overload;
  compose appropriate char list (combination) for a given Index;
  Base string elements need not have to be unique or even valid,
  since the getOrder function does not care about them, it only
  checks for minimum length required for given Index, any excess
  will be simply cropped and reappended to the result string
  (in this version actually is the Base string's tail that will
  be proceed [as actual Base], the excess will reinserted at front
  of the result string).

  routine flows:
    1. clear the result string;
    2. get maxNBase (next-under-level N factorial), the Base string
       length must be at least N+1; exit if it is not.
    3. copy Base to Result;
       (copy also Index to to temp if necessary, in case of Index is
        a non modifiable const)
    4. copy actualBase, either head or tail of Base of length N+1
       (this version copies Base tail, N+1 chars to the end of Base)
    5, position the result pointer as appropriate;
       this version put the pointer at position length(Result)-(N+1)
       of the result string.
    6. Counter initalized at N+1;
       Start of Loop: decrease Counter;
       while Counter > 0 do the following:
       - get N factorial (referred later as X)
       - calculate Quotient and Remainder of Index divided by X
       - Remainder reassigned to Index (or its temp storage)
       - Quotient used as position of target char from actualBase:
         pick and remove char at position Q from actualBase, then
         append this char to the result string;
         (after this length of actualBase is decreased, while length
         of result string is increased);
       - continue the loop from the start
    7. at loop done; the last char still remains, it must be picked
       manually from actualBase and appended to the result string.
    8. done. do cleanup as necessary.
}

function GetOrder128(const Index: r128; const Base: string): string; overload;
type
  TLocalVar = packed record
    R, X: r128;
    Base: array[0..maxfactLenFold8 - 1] of char;
    Order: pointer;
    OrdLen, factnBits: integer;
  end;
var
  S: TLocalVar;
const
  dwordOfN: array[0..maxfactLength] of byte = (0, //0
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, //12
    1, 1, 1, 1, 1, 1, 1, 1, //20
    2, 2, 2, 2, 2, 2, 2, //27
    3, 3, 3, 3, 3, 3, 3, //34
    4
    );
asm
  push esi; mov esi,edx;
  push edi; mov edi,ecx; // result
  push ebx; mov ebx,eax;
    call GetInt128MaxNBase
  fild qword ptr [ebx]; fild qword ptr [ebx+8]; fxch;
  fistp qword ptr [S.R]; fistp qword ptr [S.R+8];
  inc eax; mov edx,[esi-4];
  push edx; mov ebx,eax; // edx = length(S); ebx = maxnBase;
  mov eax,edi; call System.@LStrClr;
  mov edx,[esp]; call System.@LStrSetLength;
  mov edi,[eax]; mov eax,esi;
  pop ecx; test ecx,ecx; jz @@ends

  mov eax,ecx; call __move1; // eax = length(S); preserved
  cmp ebx,eax; ja @@ends;   // maxnBase > length(S) ?

  //@@getmin: //if (ebx > eax) then ebx := eax;
  //  sub eax,ebx; sbb ecx,ecx;
  //  and ecx,eax; add ebx,ecx;

  {HEAD}
  //lea edx,S.Base; mov ecx,ebx
  //mov eax,esi; call __fastMove;

  {TAIL}
  mov eax,[esi-4]; lea edx,S.Base;
  sub eax,ebx; mov ecx,ebx;
  add edi,eax; add eax,esi;
  call __fastMove;

  xor ecx,ecx; mov cl,maxfactnBits;
  mov S.factnBits,ecx; //mov byte ptr [S.factnBits],maxfactnBits;
  mov S.OrdLen,ebx;

  jmp @@LoopX; mov eax,eax;
  @@cmptable: dd @@dd1,@@dd2,@@dd3,@@dd4,@@dd4;//,@@dd4,@@dd4
  @@LoopX:
    xor eax,eax; mov al,ebx+dwordOfN
    dec ebx; jz @@LoopX_end
    push edi;
    mov eax,eax*4+@@cmptable; push eax
    mov eax,ebx; lea edx,S.X;
    mov ecx,S.factnBits; call nfactorial2
    xor ecx,ecx;
    @@lCtr:
      mov eax,S.X.L; mov edx,S.R.L; { update cache }
      jmp [esp];

    @@dd4:
      mov eax,S.X.L+12; mov edx,S.R.L+12;
      cmp edx,eax; jb @@Storedt; mov eax,S.X.L+8; mov edx,S.R.L+8; jnz @@lsub;
      cmp edx,eax; jb @@Storedt; mov eax,S.X.L+4; mov edx,S.R.L+4; jnz @@lsub;
      cmp edx,eax; jb @@Storedt; mov eax,S.X.L+0; mov edx,S.R.L+0; jnz @@lsub;
      cmp edx,eax; jb @@Storedt; jnz @@lsub;
      jmp @@equal

    @@dd3:
      mov eax,S.X.L+8; mov edx,S.R.L+8;
      cmp edx,eax; jb @@Storedt; mov eax,S.X.L+4; mov edx,S.R.L+4; jnz @@lsub;
      cmp edx,eax; jb @@Storedt; mov eax,S.X.L+0; mov edx,S.R.L+0; jnz @@lsub;
      cmp edx,eax; jb @@Storedt; jnz @@lsub;
      jmp @@equal

    @@dd2:
      mov eax,S.X.L+4; mov edx,S.R.L+4;
      cmp edx,eax; jb @@Storedt; mov eax,S.X.L+0; mov edx,S.R.L+0; jnz @@lsub;
      cmp edx,eax; jb @@Storedt; jmp @@lsub;//jnz @@lsub;
      jmp @@equal

    @@dd1: cmp edx,eax; jb @@Storedt; jnz @@lsub;
      jmp @@equal

      @@equal: //jmp @@lsub;
      @@lsub:
        mov eax,S.X.L+0; mov edx,S.X.L+4;
        mov esi,S.R.L+0; mov edi,S.R.L+4;
        sub esi,eax; sbb edi,edx;
        mov S.R.L+0,esi; mov S.R.L+4,edi;

        mov eax,S.X.L+08; mov edx,S.X.L+12;
        mov esi,S.R.L+08; mov edi,S.R.L+12;
        sbb esi,eax; sbb edi,edx;
        mov S.R.L+08,esi; mov S.R.L+12,edi;

      inc ecx; jmp @@lCtr;
    @@storedt:
    pop eax; lea esi,ecx+S.Base+1;
    pop edi; xor eax,eax;
    //mov al,ecx+S.Base; //mov [edi],al; add edi,1;
    mov edx,S.OrdLen; add edx,0ffffh; { dec lo-word; inc hi-word }
    movzx eax,dx; mov S.OrdLen,edx;
    mov dl,[esi-1]; sub eax,ecx;
    mov [edi],dl; add edi,1
    push eax; shr eax,2; jz @@mvt2;
    @@lvb4: mov edx,[esi]; mov [esi-1],edx; add esi,4; sub eax,1; jnz @@lvb4
    @@mvt2: pop eax; and eax,3; jz @@mv_done
    @@mvb2: shr eax,1; jz @@mvb1; mov dx,[esi]; mov [esi-1],dx; lea esi,esi+2
    @@mvb1: jnb @@mv_done; mov dl,[esi]; mov [esi-1],dl; inc esi
    @@mv_done: mov byte ptr [esi-1],'X';
  jmp @@LoopX

  @@LoopX_end:
    mov al,byte ptr [S.Base];
    mov [edi],al
  @@ends: pop ebx; pop edi; pop esi
end;

function GetCombi64(const Index: Int64): string;
const
  stackBuf = 128;
asm
  call System.@LStrClr;
  push esi; mov esi,eax;
    mov eax,Index.r64._lo; mov edx,Index.r64._hi
    call GetInt64MaxNBase+$60-$58
  test eax,eax; jz @@ends
@@Start: //jmp @@ends
  mov edx,eax; push eax;
  mov eax,esi; call System.@lStrSetLength
  pop ecx; mov esi,[eax];
  mov eax,ecx; push ebx;
  and ecx,3; or ebx,-1;
  shl ecx,3; push edi;
  shl ebx,cl; //push ebp;
  mov ecx,ebx; add esp,-StackBuf;   //lea edi,Base;
  mov ebx,eax; mov edi,esp;   //add ebx,ebx;
  not ecx; mov edx,03020100h; //add ebx,ebx;
  shr eax,2; jz @@lb;
  @@ld: mov [edi],edx; add edi,4; add edx,04040404h; dec eax; jnz @@ld
  @@lb: and edx,ecx; mov [edi],edx;

  mov edi,Index.r64._hi; mov ebp,Index.r64._lo

  xor eax,eax; xor ecx,ecx;
  mov al,bl; mov cl,bl
  add eax,eax; add ecx,ecx
  add eax,eax; add ecx,ecx
  sub ecx,13*4; add eax,offset simplefact
  cmp bl,13; sbb edx,edx;
  not edx; and ecx,edx;
  and edx,[eax+ecx+4]; mov eax,[eax+ecx];

  xor ecx,ecx;
  @@lctr: sub ebp,eax; sbb edi,edx; inc ecx; jnb @@lctr
  add ebp,eax; adc edi,edx; dec ecx;

  sub esp,-stackBuf; //pop ebp;
  pop edi; pop ebx;
@@ends: pop esi;
@@Stop:
end;

function GetOrder64(const Index: Int64): string;
const
  stackBuf = 128;
asm
  call System.@LStrClr;
  push esi; mov esi,eax;
    mov eax,Index.r64._lo; mov edx,Index.r64._hi
    call GetInt64MaxNBase+$60-$58
  test eax,eax; jz @@ends
@@Start: //jmp @@ends
  mov edx,eax; push eax;
  mov eax,esi; call System.@lStrSetLength
  pop ecx; mov esi,[eax];
  mov eax,ecx; push ebx;
  and ecx,3; or ebx,-1;
  shl ecx,3; push edi;
  shl ebx,cl; //push ebp;
  mov ecx,ebx; add esp,-StackBuf;   //lea edi,Base;
  mov ebx,eax; mov edi,esp;   //add ebx,ebx;
  not ecx; mov edx,03020100h; //add ebx,ebx;
  shr eax,2; jz @@lb;
  @@ld: mov [edi],edx; add edi,4; add edx,04040404h; dec eax; jnz @@ld
  @@lb: and edx,ecx; mov [edi],edx;

  mov edi,Index.r64._hi; mov ebp,Index.r64._lo

  xor eax,eax; xor ecx,ecx;
  mov al,bl; mov cl,bl
  add eax,eax; add ecx,ecx
  add eax,eax; add ecx,ecx
  sub ecx,13*4; add eax,offset simplefact
  cmp bl,13; sbb edx,edx;
  not edx; and ecx,edx;
  and edx,[eax+ecx+4]; mov eax,[eax+ecx];

  xor ecx,ecx;
  @@lctr: sub ebp,eax; sbb edi,edx; inc ecx; jnb @@lctr
  add ebp,eax; adc edi,edx; dec ecx;

  sub esp,-stackBuf; //pop ebp;
  pop edi; pop ebx;
@@ends: pop esi;
@@Stop:
end;

end.


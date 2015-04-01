unit dbzCrypt;
{$WEAKPACKAGEUNIT ON}
{
  Copyright (c) 2004, aa, Adrian H. & Inge DR.
  Property of PT SOFTINDO Jakarta.
  All rights reserved.

  mailto:aa|AT|softindo|DOT|net,
  http://delphi.softindo.net

  Version: 1.0.0.000
  Dated: 2005.01.01
  LastRev: 2007.01.01
  LastRev: 2008.05.01 - using new algorithm ID capacity now upto 16581375 (~16M)
}
{
 indexed Nonzero encrypt. include additional index infomation
 in the encrypted string. need additional 4 bytes as index
 (encrypted string will be 4 characters longer than original)
 useful to retain field index/order

 note:
   since index will be hi-stripped, 3 bytes wide, then max. value
   of index is: 128*128*128-1 = 2097151 (roughly 2 million) --obsolete
   should be enough for most of database                    --obsolete
   (it could be up to 268435455 if you're not using random salt-key)
 + 2007.0.0: (untested!) added NZidEncrypt64/NZidDecrypt64  #deprecated
             to overcome 2M limitation as noticed above.    #deprecated
 -------------------------------------------------------------------------
 * 2008.05.01: implementation of natural (non-zero positive) integer number
               (see article attached)
               now max.ID (3 bytes) capacity upto: 255*255*255 = 16,581,375
               and thus CRID64 NZidEncrypt64/NZidDecrypt64 is deprecated,
               i think 16M just quite enough, i'm not planning to index for
               a monster database as google or wiki's
 * 2008.08.03: optimize 64bits rol1/ror1 by avoiding branch/jump
}

interface
type
  THexString = string; //mod32's string xor32

function XOR32(const S: string): string;

function XOR32encrypt(const Str: string): THexString; // encrypt TO hexStr
function XOR32decrypt(const HexStr: THexString): string; // decrypt FROM hexStr

// encrypt S without containing #0 in the result, useful for pchar
// or database string field which does not accept #0 within string
function NZDecrypt(const S: string): string;
function NZEncrypt(const S: string): string;

function NZDecryptOfHexStr(const HexStr: THexString): string;
function NZEncryptToHexStr(const Str: string): THexString;

function NZidDecrypt(const S: string): string;
function NZidEncrypt(const S: string; const ID: integer = 0): string;

function NZidDecryptOfHexStr(const HexStr: THexString): string;
function NZidEncryptToHexStr(const Str: string; const ID: integer = 0): THexString;

// NZ_PIX will be used as key seed generator
function HexStrtoStr(const HexStr: string): string;
function StrtoHexStr(const Str: string): string;

const
  NZ_PIX: int64 = trunc(PI * 1E18);
  MAX_NZID = high(byte) * high(byte) * high(byte) * cardinal(high(byte)); // max capacity of nzid

function asmInttoNZN(const I: cardinal; const base: byte = 255): integer;
function asmNZNtoInt(const NZN: cardinal): integer; overload; // constant base = 255
function asmNZNtoInt(const NZN: cardinal; const base: byte): integer; overload;

implementation
//uses Ordinals;
type
  r64 = packed record
    case Integer of
      0: (Lo, Hi: Cardinal);
      1: (Cardinals: array[0..1] of Cardinal);
      2: (Words: array[0..3] of Word);
      3: (Bytes: array[0..7] of Byte);
  end;

function rol1(const I: integer): integer; overload asm rol I, 1 end;

function rol_OLD(const I: Int64): Int64; overload asm
    mov edx, I.r64.hi  // using register is faster than directly accessing memory
    mov eax, I.r64.lo // in Pentium they could also be run parallelized
    shl eax, 1; rcl edx, 1
    jnc @done; or eax, 1
  @done: //popfd
end;

function rol1(const I: Int64): Int64; overload asm
    mov edx, I.r64.hi  // using register is faster than directly accessing memory
    mov eax, I.r64.lo // in Pentium they could also be run parallelized
    shl eax, 1; rcl edx, 1
    adc eax,0; //jnc @done; or eax, 1
  @done: //popfd
end;

function ror1(const I: integer): integer; overload asm ror I, 1 end;

function ror_OLD(const I: Int64): Int64; overload asm
    mov edx, I.r64.hi  // using register is faster than directly accessing memory
    mov eax, I.r64.lo //  in Pentium they could also be run parallelized
    shr edx, 1; rcr eax, 1
    jnc @done; or edx, 1 shl 31 
    //sbb ecx,ecx; and ecx, 1 shl 31; or edx,ecx; 
  @done: //popfd
end;

function ror1(const I: Int64): Int64; overload asm
    mov eax, I.r64.lo; mov edx, I.r64.hi;
    shr eax,1; // get carry
    mov eax, I.r64.lo; // get back
    rcr edx, 1; rcr eax, 1;
  @done: //popfd
end;

function rolex(const I: Int64; const ShiftCount: integer): Int64; overload register asm
  mov edx, I.r64.hi; mov ecx, ShiftCount;
  mov eax, I.r64.lo; and ecx, $3f;
  jz @exit;
  cmp cl, 32;
  jb @begin;
    mov eax, edx; mov edx, I.r64.lo;
    jz @exit;
  @begin: push ebx; mov ebx, eax;
    shld eax, edx, cl;
    shld edx, ebx, cl;
  @done: pop ebx
  @exit:
end;

function rorex(const I: Int64; const ShiftCount: integer): Int64; overload register asm
  mov edx, I.r64.hi; mov ecx, ShiftCount;
  mov eax, I.r64.lo; and ecx, $3f;
  jz @exit;
  cmp cl, 32;
  jb @begin;
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

function rolex(const I: integer; const ShiftCount: integer): integer; overload register asm
  mov ecx, ShiftCount; rol I, cl
end;

function rorex(const I: integer; const ShiftCount: integer): integer; overload register asm
  mov ecx, ShiftCount; ror I, cl
end;

function asmInttoNZN(const I: cardinal; const base: byte = 255): integer;
const AllOnes = $01010101;
asm
  test eax, not 0ffh; jnz @@0
  add eax,AllOnes; ret;
@@0: movzx ecx,dl; //sanitize
  //cmp eax,ecx; ja @@1
  //sbb edx,edx; and eax,edx
  //sete ah; add eax,AllOnes; ret;
@@1: xor edx,edx; push edx; // Result
  div ecx; mov [esp],dl;
  cmp eax,ecx; ja @@2
  sbb edx,edx; and eax,edx
  sete dl;
  mov [esp+1],al; mov [esp+2],dl;
  jmp @@normalize
@@2: xor edx,edx; div ecx;
  mov [esp+1],dl;
  cmp eax,ecx; ja @@3
  sbb edx,edx; and eax,edx
  sete ah; mov [esp+2],ax;
  jmp @@normalize
@@3: xor edx,edx; div ecx;
  mov [esp+2],dl; mov [esp+3],al;
@@normalize:
  pop eax; add eax,AllOnes;
end;

function asmNZNtoInt(const NZN: cardinal; const base: byte): integer; overload;
const AllOnes = $01010101;
asm
  sub eax,AllOnes;
  jnz @@0; ret
@@0:
  push ebx; push eax;
  movzx ebx,al; movzx ecx,dl;
  test ah,ah; jz @@1;
  movzx eax,ah; mul ecx;
  add ebx,eax;
@@1:
  movzx eax,[esp+2];
  test eax,eax; jz @@2
  push eax;
  mov eax,ecx; mul ecx;
  pop edx; mul edx;
  add ebx,eax;
@@2:
  movzx eax,[esp+3];
  test eax,eax; jz @@3
  push eax;
  mov eax,ecx; mul ecx; mul ecx;
  pop edx; mul edx;
  add ebx,eax
@@3:
  pop eax; mov eax,ebx;
  pop ebx;
end;

{ when base is constant = 255, we could replace mul with cheaper shift/sub }

function div255(const I: cardinal): byte;
asm
end;

function mod255(const I: cardinal): byte;
asm
 movzx edx,al; movzx ecx,ah
 bswap eax
 add ecx,edx; movzx edx,ah
 movzx eax,al; add edx,ecx
 add eax,edx; add al,ah
 xor ah,ah
end;

function asmNZNtoInt(const NZN: cardinal): integer; overload; // constant base = 255
const AllOnes = $01010101;
const m1 = $FF; m2 = $FE01; m3 = $00FD02FF;
const m2neg = $1FF; //   // = 200 - 1
const m3neg = $0002FD01; // = 30000 - 2FF = 30000 - 300 + 1
                         //               = 3 * (10000 - 100) + 1
                         //               = 3 * 100 * (100 - 1) + 1
asm
{ the branch prediction failure's penalty is absurdly high }
{ we'd better let all inst. pass rather than jcc           }
  sub eax,AllOnes; //jnz @@begin; ret
  //test eax, not $ff; jnz @@begin; ret
@@0:
  push ebx; mov ebx,eax;
  movzx edx,ah; sub ebx,edx;

  shr eax,16; jz @@end
  movzx ecx,al; movzx edx,al;
  shl ecx,8+1; sub ecx,edx;

  sub ebx,ecx;
  and eax,not 0ffh; jz @@end;

  mov ecx,eax; movzx edx,ah;
  shl ecx,8; sub ebx,edx;

  sub ecx,eax; mov eax,ecx;
  add ecx,ecx; add ecx,eax;
  sub ebx,ecx;

@@end: mov eax,ebx; pop ebx;
end;

// StrToHexStr and HexStrToStr functions are made to remove dependency to
// bigshit ordinals unit (also made by us). if you are using ordinals unit
// then this stupid little craps are not needed. use much-much-much more capable
// ordinals.hexs routines instead;

function StrtoHexStr(const Str: string): string;
// returns HexString (byte-per-byte in hexdigits) representation of string
const hexdigit = '0123456789ABCDEF';
var
  i, b: integer;
begin
  Result := '';
  for i := 1 to length(Str) do begin
    b := ord(Str[i]);
    Result := result +
      hexdigit[(b shr 4) and $0F + 1] + hexdigit[b and $0F + 1];
  end;
end;

function HexStrtoStr(const HexStr: THexString): string;
  // convert array of each 2 hex digits ['0'..'9','a'..'f', 'A'..'F']
  // pairs to their respective character counterpart (make them a string)
  // (any invalid hex digits will be skipped)
  // length should be an even number, unpaired last digit
  // (if length is an odd number), will also be skipped.
const HEXDIGITS = ['0'..'9', 'A'..'F', 'a'..'f'];

  function StrToIntDef(const S: string; Default: Integer): Integer;
  var E: Integer;
  begin
    Val(S, Result, E);
    if E <> 0 then Result := Default;
  end;

var
  i, n: integer;
  vHex, sn: string;
begin
  vHex := ''; //(Validated HexStr)
  for i := 1 to length(HexStr) do
    if HexStr[i] in HEXDIGITS then
      vHex := vHex + HexStr[i];
  Result := '';
  for i := 0 to length(vHex) div 2 - 1 do begin
    sn := '$' + copy(vHex, i * 2 + 1, 2);
    n := strToIntDef(sn, 0);
    Result := Result + char(n);
  end;
end;

function XOR32(const S: string): string;
var
  i: integer;
begin
  i := length(S);
  setLength(Result, i);
  for i := 1 to i do
    Result[i] := char(ord(s[i]) xor (i and $1F));
end;

function XOR32encrypt(const Str: string): THexString; begin // encrypt TO hexStr
  Result := StrtoHexStr(XOR32(Str));
end;

function XOR32decrypt(const HexStr: THexString): string; begin // decrypt FROM hexStr
  Result := XOR32(HexStrtoStr(HexStr));
end;

function NZEncrypt(const S: string): string;
var
  i, l: integer;
  Key: integer; //64;
  b: byte;
begin
  l := length(S);
  setlength(Result, l);
  if l > 0 then begin
    Key := l * NZ_PIX;
    for i := l downto 1 do begin
      b := ord(S[i]);
      if b <> byte(Key) then b := b xor (Key);
      Key := rolex(Key, (b or 1));
      Result[l - i + 1] := char(b);
    end;
  end;
end;

function NZDecrypt(const S: string): string;
var
  i, l: integer;
  Key: integer; //int64;
  b0, b: byte;
begin
  l := length(S);
  setlength(Result, l);
  if l > 0 then begin
    Key := l * NZ_PIX;
    for i := 1 to l do begin
      b0 := ord(S[i]);
      if b0 = byte(Key) then b := Key // do NOT forget byte(Key) typecast!
      else b := b0 xor Key;
      Key := rolex(Key, (b0 or 1));
      Result[l - i + 1] := char(b);
    end;
  end;
end;

function NZEncryptToHexStr(const Str: string): string;
begin
  Result := StrtoHexStr(NZEncrypt(Str));
end;

function NZDecryptOfHexStr(const HexStr: string): string;
begin
  Result := NZDecrypt(HexStrtoStr(HexStr));
end;

type
  TCrIDType = type integer; // decoded: (Key) + (3 * 7 bits)
                            // max = 128*128*128-1 = 2097151
                            // update: max. now = 255 * 255 * 255 = 16581375
const
  PREFIXLEN = sizeof(TCrIDType);
  PREFIXLEN2 = PREFIXLEN * 2;

// ID use only 3 bytes, the most significant byte of ID will not be used!

function getCrID(const ID: integer; OpenChar: char): integer; overload;
var
  Key: byte;
  function BigEndian3bytes(const I: integer): integer; asm bswap eax; shr eax,8; end; // only 3 bytes used + 2 bits
begin
  repeat Key := random(high(Key) + 1)
  until (byte(key) > 0) and (byte(Key) <> ord(OpenChar));
  Result := asmInttoNZN(ID);
  Result := BigEndian3bytes(Result) or (Key shl 24)
end;

function NZidDecrypt(const S: string): string; {$Q-} // no-overflow-checking
//todo: convert to asm
var
  i, l: integer;
  Key: int64;
  b0, b: byte;
begin
  l := length(S) - PREFIXLEN;
  if l < 1 then Result := ''
  else begin
    setlength(Result, l);
    move(S[1], I, sizeof(PREFIXLEN));
    Key := I * NZ_PIX;
    RandSeed := Key;
    Key := Key * integer(Random(MaxInt));

    for i := 1 to l do begin
      b0 := ord(S[i + PREFIXLEN]);

      //OK.
      //if (Key and $60) > 0 then
      //  b := b0 xor (Key and $9F)
      //else b := b0 xor Key;

      if b0 = byte(Key) then b := byte(Key) // do NOT forget byte(Key) typecast!
      else b := b0 xor Key;

      Key := rolex(Key, (b0 or 1));
      Result[l - i + 1] := char(b);
    end;
  end;
end;

function NZidEncrypt(const S: string; const ID: integer = 0): string; {$Q-} // no-overflow-checking
var
  i, l, X: integer;
  Key: int64;
  b: byte;
begin
  l := length(S);
  if l < 1 then Result := ''
  else begin
    setlength(Result, l + PREFIXLEN);
    X := getCrID(ID, S[l]);
    Key := X * NZ_PIX;
    RandSeed := Key;
    Key := Key * integer(Random(MaxInt));

//todo: convert to asm
    move(X, Result[1], PREFIXLEN);
    for i := l downto 1 do begin
      b := ord(S[i]);

      //OK.
      //if (Key and $60) > 0 then
      //  b := b xor (Key and $9F)
      //else b := b xor Key;

      //b := b xor Key;
      //if b = 0 then b := Key;

      if b <> byte(Key) then b := b xor (Key);

      Key := rolex(Key, (b or 1));
      Result[l - i + PREFIXLEN + 1] := char(b);
    end;
  end;
end;

function NZidEncryptToHexStr(const Str: string; const ID: integer = 0): THexString;
begin
  Result := StrtoHexStr(NZidEncrypt(Str, ID));
end;

function NZidDecryptOfHexStr(const HexStr: THexString): string;
begin
  Result := NZidDecrypt(HexStrtoStr(HexStr));
end;


end.


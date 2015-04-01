unit cfactnb;
{$A+,Z4} // do not change $Z4!
{$WEAKPACKAGEUNIT ON}
{                                               }
{ unit factorial constants                      }
{ by aa, Copyright 2006, PT Softindo, JAKARTA   }
{ Version 1.0.0.2 - 2006.03.07                  }
{                                               }
interface

type
  tfactnBits = (fkn32, fkn64, fkn128, fkn256, fkn512, fkn1024);//, fkn2048); //, fkn4096, fkn8192, fkn16378);

  // MUST be adjusted with max. tfactnBits Capacity;
  // never give lesser value! it used as hardlimits
  // by stack and many array variables
  tfactorialNBase = 0..300; // actually 0 is an invalid factorial base number

  // high tfactorialNBase value based on tfactnBits:
  // fkn32:12!, fkn64:20!, fkn128:34!, fkn256:57!, fkn512:98!, fkn1024:170!
  // fkn2048:300!, fkn4096:536!, fkn8192:966!, fkn16378:1754!

{ ****************** MUST be called first! ****************** }
procedure BuildFact; // weak-packaged, not auto initialized
{ *********************************************************** }

// get n! Value
function nfactorial(const N: tfactorialNBase; out Value; const fkBits: tfactnBits): boolean; overload;
function nfactorial(const N: tfactorialNBase): int64; overload;

// get highest factorial base number of given Value
function GetIntMaxNBase(const Value: integer): tfactorialNBase; overload;
function GetInt64MaxNBase(const Value: int64): tfactorialNBase; overload;
// for morre than 64 bits
function GetMaxNBase(const Value; const fkBits: tfactnBits): tfactorialNBase; overload;

implementation

const
  highFact = high(tfactorialNBase);
  hightfactnBits = ord(high(tfactnBits));
  hightfactnBits_byteSize = 4 shl hightfactnBits;
  hightfactnBits_dwordSize = 1 shl hightfactnBits;

var
  factmn: pointer = nil;
  // next-pos and zero-trails list
  nposz: array[tfactorialNBase] of integer;
  // most significant dword of N!
  msdfact: array[tfactorialNBase] of integer;
  // highest factorial base number within dwords bound
  dBound: array[0..hightfactnBits_dwordSize - 1] of word;
  //facntypeBound: array[tfactnBits] of word;

procedure BuildFact;
const
  stackSize = 4 shl ord(high(tfactnBits));
  BufSize = stackSize * highFact;
asm

  pushad; push 0;              // overflow caretaker
  push stackSize/8/2; pop esi; // 16 bytes per-loop
  mov eax,factMN; call System.@FreeMem
  mov eax,BufSize;             // give enough mem for ALL nums by WIDEST size
    call System.@GetMem;       // so it need not to be repeatedly reallocated
  mov factmn,eax;
  //lea eax,factmn; xor edx,edx
  //call System.@ReallocMem // realloc once only (truncate)

    mov edi,eax; or eax,-1
    mov ecx,BufSize; push ecx;
    shr ecx,2; rep stosd
    pop ecx; and ecx,3; rep stosb

  mov edi,factmn;

  fldz; @@LoopZ: fst qword [esp-10h]; fst qword [esp-08h];
  sub esp,10h; dec esi; jnz @@LoopZ; fstp st;

  mov ebx,esi; mov ecx,esi;
  inc ebx; mov [edi],esi;
  mov [esp],ebx; shl ebx,8
  mov dword ptr nposz+0,ebx

  @@LOOP: inc ecx
    mov esi,esp; xor edi,edi;
    mov eax,[esp]; test eax,eax; jnz @@muld
    @@testz1: mov eax,[esi+4]; add esi,4; test eax,eax; jz @@testz1
    @@muld: mov eax,[esi]; add esi,4; test eax,eax; jz @@done_muld
      xor edx,edx; mul ecx; add eax,edi; adc edx,0
      mov [esi-4],eax; mov edi,edx; jmp @@muld
    @@done_muld:
      mov [esi-4],edx; sub esi,4
      cmp edx,1; sbb edi,edi
      sub esi,esp; sal edi,2;
      mov eax,[esp]; add edi,esi;
      mov esi,esp; shr edi,2;
      cmp edi,hightfactnBits_dwordSize;
      jnb @@Loop_Done
        xor ebp,ebp; test eax,eax; jnz @@ccr;
      @@testz2: mov eax,[esi+4]; add esi,4; add ebp,4; test eax,eax; jz @@testz2
      @@ccr:
        mov edx,[esp+edi*4];
        //mov edi*2+dBound,cx;      // overwritten all of the time
        mov edi*2+dBound,cx;      // overwritten all of the time

        shl edi,2; inc edi;       // edi: m_length = length without zero (0-offset)
        mov ecx*4+msdfact,edx;
        bsf eax,eax; bsr edx,edx;
        shr eax,3; shr edx,3;     // eax:zero-count mod 4; edx: length mod 4 bytes
        add eax,ebp; add edi,edx; // ebp:zero-count * 4
        mov edx,factmn; sub edi,eax;
        shr ebx,8; mov ebp,edi;
        mov edi,ebx; add ebx,ebp;
        shl ebx,8; mov esi,esp;
        add edi,edx; add esi,eax;
        mov ecx*4+nposz,ebx;      // ax: next-pos = current-pos + m_length
        mov ecx*4+nposz,al;       // al; zero count mod 256
        mov bl,al;                // eax/bl: zero count
        //mov ebx,ecx
        push ecx; mov ecx,ebp
        shr ecx,2; rep movsd
        mov ecx,ebp; and ecx,3; rep movsb
        pop ecx;
    //inc ecx;
    jmp @@LOOP
  @@Loop_Done:
    mov edx,ebx; lea eax,factmn;
    shr edx,8; //shl edx,2;
    call System.@ReallocMem // realloc once only (truncate)

  add esp,stackSize+4; popad
end;

function nfactorial(const N: tfactorialNBase; out Value; const fkBits: tfactnBits): boolean;
asm
@@Start: mov [edx],0;
  push eax; push 1; pop eax
  sub ecx,eax; jb @@flz0;
  shl eax,cl; shl ecx,4;
  fldz; @@fillz: fst qword ptr[edx+eax*8-8]; dec eax; jnz @@fillz; fstp st;
  @@flz0: pop eax;
  //movzx ecx,word ptr ecx*8+dBound-1
  movzx ecx,word ptr ecx+dBound-2; inc ecx;
  cmp eax,ecx; sbb ecx,ecx;
  movzx eax,ax; and eax,ecx;
  jnz @@begin; ret; // return 0 if not allowed by max limit of given type

@@begin:

  push ebx; mov ebx,eax*4+nposz;
  movzx ecx,bl; mov eax,eax*4+nposz-4;
  add edx,ecx; sub ebx,eax;
  shr eax,8; mov ecx,ebx;
  mov ebx,factmn; shr ecx,8
  add eax,ebx; mov ebx,ecx

@@bign: shr ecx,3; jz @@7bytes

@@Loop8: // may be not aligned
  fild qword ptr [eax]; add eax,8//lea eax,eax+8//add eax,8
  fistp qword ptr [edx]; add edx,8//lea edx,edx+8//add edx,8
  sub ecx,1; jnz @@Loop8

@@7bytes: mov ecx,ebx; and ecx,7; pop ebx;
@@jump: jmp ecx*4+@@7bytesJump; nop //mov edi,edi
@@7bytesJump: dd @@end,@@1,@@2 ,@@3,@@4,@@5,@@6,@@7
  @@1: mov cl,[eax]; mov [edx],cl; jmp @@end
  @@2: mov cx,[eax]; mov [edx],cx; jmp @@end
  @@3: mov cx,[eax]; mov al,[eax+2]; mov [edx],cx; mov [edx+2],al; jmp @@end
  @@4: mov ecx,[eax]; mov [edx],ecx; jmp @@end
  @@5: mov ecx,[eax]; mov al,[eax+4]; mov [edx],ecx; mov [edx+4],al; jmp @@end
  @@6: mov ecx,[eax]; mov ax,[eax+4]; mov [edx],ecx; mov [edx+4],ax; jmp @@end
  @@7: mov ecx,[eax]; mov eax,[eax+3]; mov [edx],ecx; mov [edx+3],eax; jmp @@end
@@end: or eax,-1
@@Stop:
end;

function nfactorial(const N: tfactorialNBase): int64; overload;
asm
  push 0; push 0;
  cmp eax,21; sbb edx,edx;
  and eax,edx; jz @@end
  lea eax,eax*4+nposz; xor edx,edx; // prefer compact
  mov ecx,[eax]; mov eax,[eax-4];   // length-0, length-1
  mov dl,cl;                        // skip zero bytes
  sub ecx,eax; mov eax,factmn;      // calculate length
  shr ecx,8; add eax,ecx
  @@jump: jmp ecx*4+@@Jumptable;    // would not exceed 6 digits
  @@Jumptable: dd @@end,@@1,@@2,@@3,@@4,@@5,@@6//,@@7
    @@1: mov cl,[eax]; mov [esp+edx],cl; jmp @@end
    @@2: mov cx,[eax]; mov [esp+edx],cx; jmp @@end
    @@3: mov cx,[eax]; mov al,[eax+2]; mov [esp+edx],cx; mov [esp+edx+2],al; jmp @@end
    @@4: mov ecx,[eax]; mov [esp+edx],ecx; jmp @@end
    @@5: mov ecx,[eax]; mov al,[eax+4]; mov [esp+edx],ecx; mov [esp+edx+4],al; jmp @@end
    @@6: mov ecx,[eax]; mov ax,[eax+4]; mov [esp+edx],ecx; mov [esp+edx+4],ax; jmp @@end
    //@@7: mov ecx,[eax]; mov eax,[eax+3]; mov [esp+edx],ecx; mov [esp+edx+3],eax; jmp @@end
  @@end: pop eax; pop edx
end;

function GetIntMaxNBase(const Value: integer): tfactorialNBase; overload;
const
  k01 = $00000001; k02 = $00000002; k03 = $00000006; k04 = $00000018;
  k05 = $00000078; k06 = $000002D0; k07 = $000013B0; k08 = $00009D80;
  k09 = $00058980; k10 = $00375F00; k11 = $02611500; k12 = $1C8CFC00;
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

function GetInt64MaxNBase(const Value: int64): tfactorialNBase; overload;
const
  k13 = $000000017328CC00; k13_Lo = integer(k13); k13_Hi = k13 shr 32;
  k14 = $000000144C3B2800; k14_Lo = integer(k14); k14_Hi = k14 shr 32;
  k15 = $0000013077775800; k15_Lo = integer(k15); k15_Hi = k15 shr 32;
  k16 = $0000130777758000; k16_Lo = integer(k16); k16_Hi = k16 shr 32;
  k17 = $0001437EEECD8000; k17_Lo = integer(k17); k17_Hi = k17 shr 32;
  k18 = $0016BEECCA730000; k18_Lo = integer(k18); k18_Hi = k18 shr 32;
  k19 = $01B02B9306890000; k19_Lo = integer(k19); k19_Hi = k19 shr 32;
  k20 = $21C3677C82B40000; k20_Lo = integer(k20); k20_Hi = k20 shr 32;
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

function GetMaxNBase(const Value; const fkBits: tfactnBits): tfactorialNBase; overload;
const
  sp_EAX = 4 * 7; sp_ECX = 4 * 6; sp_EDX = 4 * 5; sp_EBX = 4 * 4;
  sp_tmp = 4 * 3; sp_EBP = 4 * 2; sp_ESI = 4 * 1; sp_EDI = 4 * 0;
  _Result = sp_eax;
asm
  cmp edx,1; jbe @@Small
  mov ecx,edx; inc dh;
  push ecx; shl dh,cl;
  movzx ecx,dh;
  or edx,-1; @@tzLoop: test [eax+ecx*4-4],edx; jnz @@tzLoop_done; dec ecx; jnz @@tzloop
@@tzLoop_done: cmp ecx,2; pop edx; jnbe @@begin

@@small:
  sbb edx,edx;
  mov ecx,[Value+4]; not edx;
  mov eax,[Value]; and edx,ecx;
  jmp GetInt64MaxNBase+$70-$68

@@begin: pushad; //7ax,cx,5dx,4bx,3tmp,2bp,1si,0di
  mov ebp,ecx*2+dBound-4; //sub ebp,$230022;
  movzx ebx,bp; shr ebp,16;

  inc ebx;  //lo-bound adjust

  mov esp.sp_ecx,ecx;
  lea esi,eax+ecx*4-4;
  lea edx,ebx+ebp+1; shr edx,1;

@@Loop: // edx: midfactn
  mov edi,[esi]; mov ecx,[edx*4+msdfact]
  cmp edi,ecx; jb @@below; jnz @@above

  @@equal:
    lea ebx,edx*4+nposz;
    mov ecx,[ebx]; mov eax,[ebx-4];
    movzx ebp,cl; sub ecx,eax;
    shr eax,8; shr ecx,8;
    // here: eax=posnz; ebp=ztrails; ecx=mlength
    mov edi,factmn; add ecx,ebp; //ecx=fulllength
    sub edi,esi; dec ecx; //adjust; since esi will always -4
    sub esi,4; and ecx,-4;
    add edi,eax; sub ecx,ebp;
    add edi,ecx; sub ecx,4;
    mov ebx,edx; jle @@Cmp4_done;

    @@Cmp4: mov eax,[esi]; mov edx,[esi+edi];
      sub esi,4; cmp eax,edx;
      jnz @@Cmp4_done;
      sub ecx,4; jg @@Cmp4
    @@Cmp4_done: neg ecx; jz @@cmp_done;
      shl ecx,3
      mov eax,[esi]; mov edx,[esi+edi];
      shr eax,cl; shr edx,cl
      cmp eax,edx;
    @@cmp_done: sbb ebx,0;
      mov esp._Result,ebx; popad; ret

  @@below: // edx:current hkn; ebx:lowest-bound
    cmp edx,ebx; ja @@next_below
    cmp edi,ecx; //[edx*4+hknn]
    sbb edx,0;
    mov esp._Result,edx; popad; ret

    @@next_below:
      mov ebp,edx; add edx,ebx
      dec ebp; shr edx,1; jmp @@Loop

  @@above: // edx:current hkn; ebp:highest-bound
    cmp edx,ebp; jb @@next_above
    mov esp._Result,edx; popad; ret

    @@next_above:
      inc edx; mov ebx,edx
      add edx,ebp; shr edx,1; jmp @@Loop
@@end:
end;

// from factlib

const
  HEXADECIMAL_CHAR_STR = '27E6FC859A13B04D';
  FullOrder = '';

function isValidOrder(const S: string): Boolean;
// to make sure there's no same/repeated char
var
  i: integer;
begin
  Result := TRUE;
  for i := 1 to length(S) do begin
    if pos(S[i], S) <> i then begin
      Result := FALSE;
      break;
    end;
  end;
end;

const
  VALID_MAX_N = high(tfactorialNBase);

procedure ValidateAnOrder(var S: string; l: integer; const Expand: Boolean = TRUE);
var
  i: integer;
  Sx: string;
begin
  if l > VALID_MAX_N + 1 then
    l := VALID_MAX_N + 1;
  if (length(S) <> l) or not isValidOrder(S) then begin
    if Expand then
      Sx := S + FullOrder;
    S := '';
    i := 0;
    while (length(S) < l) and (i < length(sx)) do begin
      inc(i);
      if pos(sx[i], S) < 1 then
        S := S + sx[i];
    end;
  end;
end;

function GetCombination(const Index: Int64; BaseOrder: string = HEXADECIMAL_CHAR_STR): string;
//note that Index is zero based
var
  i, l, n: integer;
  X, r, t: Int64;
begin
  Result := '';
  r := Index; //dont forget, it's zero -based
  n := GetInt64MaxNBase(r);
  l := length(BaseOrder);
  if l < (n + 1) then
    l := (n + 1);
  //ValidateAnOrder(BaseOrder, l);
  for i := length(BaseOrder) - 1 downto 1 do begin
    //calculate divisor (of next-under-level factorial) and it's remainder
    X := nfactorial(i);
    if r >= 0 then
      n := r div X
    else begin
      //special-case to overcome negative value
      t := high(r) mod X + (high(r) + r) mod X + 2 mod X; //2's complement
      n := high(r) div X + (high(r) + r) div X + t div X;
      r := t;
    end;
    Result := Result + BaseOrder[n + 1];
    delete(BaseOrder, n + 1, 1);
    r := r mod X;
  end;
  if BaseOrder <> '' then
    Result := Result + BaseOrder;
end;

initialization

end.



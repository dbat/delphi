unit cfactndd;
{$A+,Z4} // do not change $Z4!
{$WEAKPACKAGEUNIT ON}
{                                               }
{ unit factorial constants                      }
{ by aa, Copyright 2006, PT Softindo, JAKARTA   }
{ Version 1.0.0.2 - 2006.03.07                  }
{                                               }
interface

type
  // up to int4096K (limited by ~512K stack from max. 1MB)
  tfactnBits = (fkn32, fkn64, fkn128, fkn256, fkn512, fkn1024);

  // MUST be adjusted with max. tfactnBits Capacity;
  // never give lesser value! it used as hardlimit by stack and many array variables
  tfactorialNBase = 0..170; // actually 0 is an invalid factorial base number
  // hard-limited by zero-trails in nposz: up-to 8193!
  // high tfactorialNBase value based on tfactnBits:
  // fkn32:12!, fkn64:20!, fkn128:34!, fkn256:57!, fkn512:98!, fkn1024:170!
  // fkn2048:300!, fkn4096:536!, fkn8192:966!, fkn16378:1754!

{ ****************** MUST be called first! ****************** }
//procedure dBuildFact; // weak-packaged, not auto initialized
{ *********************************************************** }

// get n! Value
function nfactorial(const N: tfactorialNBase; out Value; const fkBits: tfactnBits): boolean; overload;
function nfactorial(const N: tfactorialNBase): int64; overload;

// get highest factorial base number of given Value
function GetIntMaxNBase(const Value: integer): tfactorialNBase; overload;
function GetInt64MaxNBase(const Value: int64): tfactorialNBase; overload;

// for more than 64 bits
function GetMaxNBase(const Value; const fkBits: tfactnBits): tfactorialNBase; overload;

// check whether chars list in Order is a subset of those in Base
// Order may have duplicated chars, whereas Base is not
function isValidSubSet(const Order, Base: string): boolean;

// check whether Order and Base have an equal length and chars list
// no duplicated chars permitted both in Order and Base
function isValidOrderBasePair(const Order, Base: string): boolean;

implementation
type dword = longword;

const
  highFact = high(tfactorialNBase);
  hightfactnBits = ord(high(tfactnBits));
  hightfactnBits_byteSize = 4 shl hightfactnBits;
  hightfactnBits_dwordSize = 1 shl hightfactnBits;

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

  simplefact: array[0..12 + 8 + 8] of integer = (
    0, k01, k02, k03, k04, k05, k06, k07, k08, k09, k10, k11, k12,
    k13_lo, k13_hi, k14_lo, k14_hi, k15_lo, k15_hi, k16_lo, k16_hi,
    k17_lo, k17_hi, k18_lo, k18_hi, k19_lo, k19_hi, k20_lo, k20_hi
    );

var
  dfactmn: pointer = @simplefact;
  // next-pos and zero-trails list
  dnposz: array[tfactorialNBase] of integer;
  // most significant dword of N!
  msdfact: array[tfactorialNBase] of integer;
  // highest factorial base number within dwords bound
  dBound: array[0..hightfactnBits_dwordSize - 1] of word;
  //facntypeBound: array[tfactnBits] of word;

procedure dBuildFact;
// all registers are preserved
const
  stackSize = 4 shl ord(high(tfactnBits));
  BufSize = stackSize * highFact;
asm
  cmp dfactmn,offset simplefact; jz @@begin; ret
@@begin: xor eax,eax
  pushad; push eax;              // overflow caretaker
  mov dfactmn,eax
  push stackSize/8/2; pop esi; // 16 bytes per-loop
  mov eax,dfactmn; call System.@FreeMem
  mov eax,BufSize;             // give enough mem for ALL nums by WIDEST size
    call System.@GetMem;       // so it need not to be repeatedly reallocated
  mov dfactmn,eax;
  //lea eax,dfactmn; xor edx,edx
  //call System.@ReallocMem // realloc once only (truncate)

    mov edi,eax; or eax,-1
    mov ecx,BufSize; push ecx;
    shr ecx,2; rep stosd
    pop ecx; and ecx,3; rep stosb

  mov edi,dfactmn;

  fldz; @@LoopZ: fst qword [esp-10h]; fst qword [esp-08h];
  sub esp,10h; dec esi; jnz @@LoopZ; fstp st;

  mov ebx,esi; mov ecx,esi;
  inc ebx; mov [edi],esi;
  mov [esp],ebx; shl ebx,8
  mov dword ptr dnposz+0,ebx

  @@LOOP: inc ecx
    mov esi,esp; xor edi,edi;
    mov eax,[esp]; test eax,eax; jnz @@muld
    @@testz1: mov eax,[esi+4]; add esi,4; test eax,eax; jz @@testz1
    @@muld: mov eax,[esi]; add esi,4; test eax,eax; jz @@done_muld
      xor edx,edx; mul ecx; add eax,edi; adc edx,0
      mov [esi-4],eax; mov edi,edx; jmp @@muld
    @@done_muld:
      lea edi,esi-4; mov [esi-4],edx;
      sub edi,esp; mov eax,[esp];
      shr edi,2; cmp edx,1;
      sbb edi,0; mov esi,esp
      cmp edi,hightfactnBits_dwordSize;
      jnb @@Loop_Done
        xor bl,bl; test eax,eax; jnz @@ccr;
      @@testz2: mov eax,[esi+4]; add esi,4; add bl,1; test eax,eax; jz @@testz2
      @@ccr:
        mov edx,[esp+edi*4];
        mov edi*2+dBound,cx; // overwritten all of the time
        inc edi; mov ecx*4+msdfact,edx;
        mov ebp,edi; mov eax,dfactmn; // edi->ebp:mlength
        shl edi,8; xadd ebx,edi;
        movzx esi,bl; shr edi,8;
        shl esi,2; shl edi,2
        add esi,esp; add edi,eax;
        mov ecx*4+dnposz,ebx; push ecx;
        mov ecx,ebp; rep movsd
        pop ecx
    jmp @@LOOP
  @@Loop_Done:
    mov edx,ebx; lea eax,dfactmn;
    shr edx,8; shl edx,2;
    call System.@ReallocMem // realloc once only (truncate)

  add esp,stackSize+4; popad
end;

function nfactorial(const N: tfactorialNBase; out Value; const fkBits: tfactnBits): boolean;
asm
@@Start: mov [edx],0;
  push eax; mov eax,dfactmn
  push 1; cmp eax,offset simplefact; jnz @@clear
  @@build: call dbuildfact; //preserve all registers;
  @@clear: pop eax;
  sub ecx,eax; jb @@flz0;
  shl eax,cl; shl ecx,4;
  fldz; @@flz: fst qword ptr[edx+eax*8-8]; dec eax; jnz @@flz; fstp st;
  @@flz0: pop eax;
  //movzx ecx,word ptr ecx*8+dBound-1
  movzx ecx,word ptr ecx+dBound-2; inc ecx;
  cmp eax,ecx; sbb ecx,ecx;
  movzx eax,ax; and eax,ecx;
  jnz @@begin; ret; // return 0 if not allowed by max limit of given type

@@begin:
  push ebx; mov ebx,eax*4+dnposz;
  movzx ecx,bl; mov eax,eax*4+dnposz-4;
  sub ebx,eax; shr eax,8;
  lea edx,edx+ecx*4; shl eax,2;
  mov ecx,ebx; add eax,dfactmn;
  pop ebx; shr ecx,8+1;
  jz @@done_move
  @@L8: fild qword ptr [eax]; lea eax,eax+8//lea eax,eax+8//add eax,8
        fistp qword ptr [edx]; lea edx,edx+8//lea edx,edx+8//add edx,8
        dec ecx; jnz @@L8
  @@done_move: jnb @@done;
    mov ecx,[eax]; mov [edx],ecx
  @@done: or eax,-1
@@Stop:
end;

function bnfactorial_old(const N: tfactorialNBase): int64; overload;
asm
  push 0; push 0;
  cmp eax,21; sbb edx,edx;
  and eax,edx; jz @@end
  lea eax,eax*4+dnposz; xor edx,edx; // prefer compact
  mov ecx,[eax]; mov eax,[eax-4];    // length-0, length-1
  mov dl,cl;                         // skip zero bytes
  sub ecx,eax; mov eax,dfactmn;      // calculate length
  shr ecx,8; add eax,ecx
  @@jump: jmp ecx*4+@@Jumptable;     // would not exceed 6 digits
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

function _nfactorial(const N: tfactorialNBase): int64; overload;
asm // fast direct approach
  cmp eax,21; sbb ecx,ecx;
  and eax,ecx; mov ecx,dfactmn;
  xor edx,edx; cmp eax,13;
  setnb dl; jmp edx*4+@@jmptable
  @@jmptable: dd @@d12, @@d20
  @@d12: mov eax,[ecx+eax*4]; ret
  @@d20: mov edx,[ecx+eax*8-13*4+4]; mov eax,[ecx+eax*8-13*4];
end;

function nfactorial(const N: tfactorialNBase): int64; overload;
asm // fast direct approach
  cmp eax,21; sbb edx,edx;
  and eax,edx; mov ecx,dfactmn;
  xor edx,edx; cmp eax,13;
  jnb @@d20
  @@d12: mov eax,[ecx+eax*4]; ret
  @@d20: mov edx,[ecx+eax*8-13*4+4]; mov eax,[ecx+eax*8-13*4];
end;

function GetIntMaxNBase(const Value: integer): tfactorialNBase; overload;
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

@@begin: mov edx,dfactmn; pushad; //7ax,cx,5dx,4bx,3tmp,2bp,1si,0di
  //cmp dfactmn,offset simplefact; jnz @@getBound
  cmp edx,offset simplefact; jnz @@getBound
    call dBuildfact
@@getBound:
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
    lea ebx,edx*4+dnposz;
    mov eax,[ebx-4]; mov ecx,[ebx];
    mov edi,dfactmn; sub ecx,eax
    shr eax,8; sub edi,esi;
    shl eax,2; sub esi,4;
    add edi,eax; shr ecx,8;
    lea edi,edi+ecx*4-4
    dec ecx; mov ebx,edx
    @@Cmp: mov eax,[esi]; mov edx,[esi+edi];
      sub esi,4; cmp eax,edx;
      jnz @@Cmp_done;
      sub ecx,1; jnz @@Cmp
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
  mov esi,Order; // here ecx must be -1
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

function isValidOrderBasePair(const Order, Base: string): boolean;
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

initialization

end.



unit BigIntZ;
{$A+,Z4}

interface
type
  dword = longword;
  r64 = packed record
    lo, hi: dword;
  end;

  //TBoundArray = array of integer; // for D5 and before
  //TIntZ = type TBoundArray; // delphi bug!
  TIntZ = TBoundArray;

  //TIntZ = packed record
  //  Dat: ^IntegerArray; Len: integer;
  //end;
  //tIntZ = array of integer;

procedure intZClear(var Z: tintZ); overload;
procedure intZfillb(var Z: tintZ; const B: byte); overload;
procedure intZfill(var Z: tintZ; const I: dword);
procedure intZfill64(var Z: tintZ; const X: int64); overload;
procedure intZfillZ(var Z: tintZ; const Src: tintZ); overload;
procedure intZSet(var Z: tintZ; const S: string); overload;
procedure intZSet(var Z: tintZ; const Source: tintZ); overload;
procedure intZCopy(const Source: tintZ; var Dest: tintZ); overload;
procedure incrz(var Z: tintZ; const I: dword); overload;
procedure decrz(var Z: tintZ; const I: dword); overload;
procedure incrz64(var Z: tintZ; const X: r64); overload;
procedure decrz64(var Z: tintZ; const X: r64); overload;
procedure intZAdd(var A: tintZ; const B: tintZ); overload;
procedure intZSub(var A: tintZ; const B: tintZ); overload;
procedure intZMul(var Z: tintZ; const I: dword); overload;
procedure intZDiv(var Z: tintZ; const I: dword); overload;
procedure intZMul(var Z: tintZ; const Multiplier: tintZ); overload;
procedure intZDiv(var Dividend: tintZ; const Divisor: tintZ); overload;
procedure intZDivMod(var Dividend: tintZ; const Divisor: tintZ; out Modulo: tintZ); overload;
function intZtoStr(const Z: tintZ): string;
function StrToIntZ(const S: string): tintZ;
function HexToIntZ(const S: string): tintZ;

implementation

procedure intZClear(var Z: tintZ); overload;
var
  _typeInfo: pointer absolute typeInfo(tintZ);
asm
  mov edx,_typeInfo; call System.@DynArrayClear
end;

procedure intZfillb(var Z: tintZ; const B: byte); overload;
asm
  mov dh,dl; mov ecx,[eax];
  test ecx,ecx; jz @@Stop;
  test dl,dl; jz intZClear;
  push dx; push dx; mov eax,ecx
  mov ecx,[ecx-4]; pop edx; jmp intZfill+ $43-$30
@@Stop:
end;

procedure intZfill(var Z: tintZ; const I: dword);
asm
  mov ecx,[eax]; test ecx,ecx; jz @@Stop;
  test edx,edx; jz intZClear;
  mov eax,ecx; mov ecx,[ecx-4];
  push edx; push edx;
  add esp,+8; mov [eax],edx;
  mov eax+ecx*4-4,edx; cmp ecx,3; jb @@Stop
  mov [eax+4],edx; mov eax+ecx*4-8,edx;
  lea eax,eax+ecx*4; and eax,not 7;
  shr ecx,2; jz @@Stop
  movq mm0,[esp-8];
  @@L: movq eax-16,mm0; movq eax-8,mm0;
       sub eax,16; sub ecx,1; jnz @@L;
  emms;
  @@Stop:
end;

procedure intZfill64(var Z: tintZ; const X: int64); overload;
asm
  mov ecx,[eax]; mov edx,X.r64.lo;
  test ecx,ecx; jz @@Stop;
  or edx,X.r64.hi; mov edx,ecx; jz intZClear;
  mov eax,X.r64.Lo; mov ecx,[ecx-4];
  push ebx; mov ebx,X.r64.hi;
  push eax; mov [edx],eax;
  push ebx; push eax;
  mov eax,ecx; add esp,12
  and eax,1; neg eax
  mov eax,eax*4+4+X.r64.Lo; cmp ecx,3;
  mov edx+ecx*4-4,eax; jb @@ends
  xor eax,eax; test edx,7;
  setnz al;  mov edx+4,ebx;
  movq mm0,[eax*4+esp-12];
  lea edx,edx+ecx*4; and edx,not 7; shr ecx,2
  @@L: movq[edx-8],mm0; movq[edx-16],mm0;
       sub edx,16; sub ecx,1; jnz @@L; emms
  @@ends: pop ebx
  @@Stop:
end;

procedure intZfillZ(var Z: tintZ; const Src: tintZ); overload;
asm
  //mov ecx,Src.Len; test ecx,ecx; jz intZClear;
end;

procedure intZSet(var Z: tintZ; const S: string); overload;
asm
end;

procedure intZSet(var Z: tintZ; const Source: tintZ); overload;
asm
  mov ecx,[eax]; test ecx,ecx; jz @@Stop;
  test edx,edx; jz intZClear;
  mov eax,ecx; mov ecx,[ecx-4];

{  mov ecx,Source.Len; test ecx,ecx; jz intzClear
  mov Z.Len,ecx; add ecx,ecx
  push esi; add ecx,ecx;
  push edi; mov edi,ecx;
  mov esi,[Source]; mov edx,ecx;
  call System.@reallocMem;
  mov edx,Z.Dat; mov ecx,Z.Len;
  //shr ecx,1; mov eax,esi+edi-4;
  //mov edx+edi-4,eax; pop edi; jz @@done
  @@L: //fild qword ptr esi+ecx*8-8;
       //fistp qword ptr edx+ecx*8-8;
       mov eax,[esi]; add esi,4;
       mov [edx],eax; add edx,4;
       sub ecx,1; jnz @@L
  @@done: pop esi;
}
@@Stop:
end;

procedure intZCopy(const Source: tintZ; var Dest: tintZ); overload;
type
  fp = procedure(var Z: tintZ; const Source: tintZ);
const
  SetZ: fp = intZSet;
asm
  xchg Source,Dest; call SetZ
end;
  //mov ecx,Source; mov Source,Dest
  //mov edx,Dest.Len;
  //test edx,edx; jz intZClear;
  //push esi; push edi;
  //mov eax.tintz.Len,edx; // here eax actually is dest
  //push edx; add edx,edx;
  //add edx,edx; mov esi,ecx.tintz.Data;
  //mov edi,edx;// here ecx actually is source
  //call System.@reallocMem;
  //mov eax,[eax]; mov edx,esi+edi-4;
  //mov eax+edi-4,edx; pop ecx;
  //pop edi; shr ecx,1; jz @@end
  //@@Loop: //mov edx,[esi]; add esi,4;
  //        //mov [eax],edx; add eax,4;
  //        //sub ecx,1; jnz @@Loop
  //        fild qword ptr esi+ecx*8-8;
  //        fistp qword ptr eax+ecx*8-8;
  //        sub ecx,1; jnz @@Loop
  //@@end: pop esi;
//end;

procedure incrz(var Z: tintZ; const I: dword); overload;
asm

end;

procedure decrz(var Z: tintZ; const I: dword); overload;
asm
end;

procedure incrz64(var Z: tintZ; const X: r64); overload;
asm
end;

procedure decrz64(var Z: tintZ; const X: r64); overload;
asm
end;

procedure intZAdd(var A: tintZ; const B: tintZ); overload;
asm
end;

procedure intZSub(var A: tintZ; const B: tintZ); overload;
asm
end;

procedure intZMul(var Z: tintZ; const I: dword); overload;
asm
end;

procedure intZDiv(var Z: tintZ; const I: dword); overload;
asm
end;

procedure intZMul(var Z: tintZ; const Multiplier: tintZ); overload;
asm
end;

procedure intZDiv(var Dividend: tintZ; const Divisor: tintZ); overload;
asm
end;

procedure intZDivMod(var Dividend: tintZ; const Divisor: tintZ; out Modulo: tintZ); overload;
asm
end;

function intZtoStr(const Z: tintZ): string;
asm
end;

function StrToIntZ(const S: string): tintZ;
asm
end;

function HexToIntZ(const S: string): tintZ;
asm
end;

end.


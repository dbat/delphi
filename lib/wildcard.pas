unit wildcard; //12345
{
  unit wildcard
  version: 1.0.0.4
  last update: 2007.01.01

  Copyright 2007, aa, Adrian H., & Ray AF.
  Private property of PT SoftIndo, JAKARTA
  All rights reserved.
}
{
// simple (and fast! of course), non-greedy wildcard match;
// result is char count of matched mask, or zero (FALSE) if no match.
//
// note that match is valid (TRUE or non-zero) only if the whole mask is exhausted,
// partial match of mask is not a match and returns FALSE (0);
//
//   example: '???' against 'abcde'; result is: 3
//            '??Z' against 'abcde'; result is: 0 (last char: 'Z' is matched none)
// mask chars:
//  '?': 1 char
//  '*': 1 or more chars
//  note: one or consecutive '*' before '?' will be treated as one '?'
//  example: '*****?' is identical with '??'
//
// compatibility with traditional C:
//   regex match (boolean TRUE) as traditional C is simply: result = length(S)
//
// new: custom terminator is charset which considered as string terminators (beside #0)
//      to be applied, terminators must be in form of termtable.
//
// new: matchpos/matchxpos: scan string for matches wildcard
//      return pos of first-match and length of matched string
//
}

interface
uses cxGlobal; // upper/lowercase helper

type
  termCharSet = set of char;
  termTable = cxGlobal.TCharsTable;

//function _pmatchs(const mask, S: PChar): integer; // internal, no length checking
//function _pmatchi(const mask, S: PChar): integer; // internal, no length checking

{ core functions }
// mask and S should be an asciiz string; length ignored.
function pmatchs(const mask, S: PChar): integer; // case-sensitive
function pmatchi(const mask, S: PChar): integer; // case-insensitive

{ extended version, using terminators table }
// mask and S should be an asciiz string; length ignored.
function pmatchxs(const mask, S: PChar; const terminators: termTable): integer;
function pmatchxi(const mask, S: PChar; const terminators: termTable): integer;

{ simple interface functions }
function match(const mask, S: string; const CaseSensitive: boolean = FALSE): integer;
function matchx(const mask, S: string; const table: termTable; const CaseSensitive: boolean = FALSE): integer;

{ implementations }
function matchpos(const mask, S: string; out matchLen: integer; const Casesensitive: boolean = FALSE): integer;
function matchxpos(const mask, S: string; out matchLen: integer; const terminators: termTable; const Casesensitive: boolean = FALSE): integer;

function buildterminators(const Charset: TermCharSet; var Table: termTable): integer;

implementation
{$WARNINGS ON}

// make choice: -1, 0, +1
// choice := ord(I > 0) - ord(I < 0);

function buildterminators(const Charset: TermCharSet; var Table: tCharsTable): integer;
asm
  push esi; mov esi,eax;
  xor eax,eax; push edi;
  mov al,-1; mov edi,table;
@@L: mov ecx,eax; shr eax,3;
     mov edx,ecx; and ecx,7;
     movzx eax,[esi+eax]; bt eax,ecx
     sbb ecx,ecx; mov eax,edx;
     not ecx; and ecx,eax;
     mov edi+edx,cl; sub eax,1; jnz @@L
@@done:
  pop edi; pop esi;
end;

function pmatchxs(const mask, S: pchar; const terminators: tCharsTable): integer;
asm
  push esi; mov esi,eax
  or eax,edx; and eax,edx
  and eax,esi; jnz @@Start
  pop esi; ret
@@Start:
  push edi; mov edi,edx;
  push ebx; lea ebx,cxGlobal.UPCASETABLE;
  push ebp; mov ebp,ecx
  push edi; xor edx,edx;
  xor eax,eax;
@@Loop:
  mov al,[esi]; mov dl,[edi];
  mov cl,al; mov ch,[ebp+edx];
  or cl,ch; and cl,ch;
  and cl,al; jz @@Loop_end
  add esi,1; add edi,1;
  //case insensitive: mov dl,[ebx+edx]; mov al,[ebx+eax];
  //xor dl,al; mov cl,al;
  //xor al,'?'; and al,dl; jz @@Loop
  //cmp cl,'*'; mov al,[esi]; jz @@cka;

  cmp al,'?'; jz @@Loop;
  cmp al,dl; jz @@Loop;
  mov cl,al;

  cmp al,'*'; mov al,[esi]; jz @@cka
  sub edi,1; sub esi,1; jmp @@Loop_end;

@@cka: cmp al,cl; jnz @@ckd;
@@Lmask: mov al,[esi+1]; add esi,1; cmp al,cl; jz @@Lmask
@@ckd: mov dl,[edi]; test al,al; jnz @@ckp
@@found: mov dl,[ebp+edx]; test dl,dl; jz @@Loop_end;
@@lfound: mov dl,[edi+1]; add edi,1; mov dl,[ebp+edx];
          test dl,dl; jnz @@Lfound;
jmp @@Loop_end;
@@ckp: //mov cl,al//case-insensitive: mov cl,[ebx+eax]; mov dl,[ebx+edx];
  //mov al,cl; xor cl,'?';
  //xor dl,al; and  dl,cl; jnz @@ckn;
  cmp al,'?'; jz @@nfetch;
  cmp dl,al; jnz @@ckn;
@@nfetch:
  add esi,1; add edi,1; jmp @@Loop
@@ckn: mov ecx,edi
@@ckl: mov dl,[ecx+1]; add ecx,1;
  mov ah,[ebp+edx]; test ah,ah; jz @@Loop_end
  //case-insensitive: mov dl,[ebx+edx];
  xor dl,al; jnz @@ckl
  mov edi,ecx; xor eax,eax; jmp @@Loop
@@Loop_end:
  mov cl,[esi]; pop esi;
  mov edx,esp; add esp,16
  cmp cl,1; sbb eax,eax;
  sub edi,esi; and eax,edi;
@@Stop:
  //mov ebp,[esp-16]; mov ebx,[esp-12];
  //mov edi,[esp-8]; mov esi,[esp-4];
  mov ebp,[edx]; mov ebx,[edx+4];
  mov edi,[edx+8]; mov esi,[edx+12];
@@ret:
end;

function pmatchxi(const mask, S: pchar; const terminators: tCharsTable): integer;
asm
  push esi; mov esi,eax
  or eax,edx; and eax,edx
  and eax,esi; jnz @@Start
  pop esi; ret
@@Start:
  push edi; mov edi,edx;
  push ebx; lea ebx,cxGlobal.UPCASETABLE;
  push ebp; mov ebp,ecx
  push edi; xor edx,edx;
  xor eax,eax;
@@Loop:
  mov al,[esi]; mov dl,[edi];
  mov cl,al; mov ch,[ebp+edx];
  or cl,ch; and cl,ch;
  and cl,al; jz @@Loop_end
  add esi,1; add edi,1;
  mov al,[ebx+eax]; mov dl,[ebx+edx];

  //xor dl,al; mov cl,al;
  //xor al,'?'; and al,dl; jz @@Loop
  //cmp cl,'*'; mov al,[esi]; jz @@cka;

  cmp al,'?'; jz @@Loop;
  cmp al,dl; jz @@Loop;
  mov cl,al;

  cmp al,'*'; mov al,[esi]; jz @@cka;
  sub edi,1; sub esi,1; jmp @@Loop_end;

@@cka: cmp al,cl; jnz @@ckd;
@@Lmask: mov al,[esi+1]; add esi,1; cmp al,cl; jz @@Lmask
@@ckd: mov dl,[edi]; test al,al; jnz @@ckp
@@found: mov dl,[ebp+edx]; test dl,dl; jz @@Loop_end;
@@lfound: mov dl,[edi+1]; add edi,1; mov dl,[ebp+edx];
          test dl,dl; jnz @@Lfound;
jmp @@Loop_end;
@@ckp: mov cl,[ebx+eax]; mov dl,[ebx+edx];
  //mov al,cl; xor cl,'?';
  //xor dl,al; and  dl,cl; jnz @@ckn;
  //add esi,1; add edi,1; jmp @@Loop
  cmp cl,'?'; jz @@nfetch
  cmp dl,cl; mov al,cl; jnz @@ckn
@@nfetch:
  add esi,1; add edi,1; jmp @@Loop
@@ckn: mov ecx,edi
@@ckl: mov dl,[ecx+1]; add ecx,1;
  mov ah,ebp+edx; test ah,ah; jz @@Loop_end
  mov dl,[ebx+edx]; xor dl,al; jnz @@ckl
  mov edi,ecx; xor eax,eax; jmp @@Loop
@@Loop_end:
  mov cl,[esi]; pop esi;
  mov edx,esp; add esp,16;
  cmp cl,1; sbb eax,eax;
  sub edi,esi; and eax,edi;
@@Stop:
  //mov ebp,[esp-16]; mov ebx,[esp-12];
  //mov edi,[esp-8]; mov esi,[esp-4];
  mov ebp,[edx]; mov ebx,[edx+4];
  mov edi,[edx+8]; mov esi,[edx+12];
@@ret:
end;

function _pmatchs(const mask, S: PChar): integer; // internal, no length checking
var UPC: pointer absolute cxGlobal.UPCASETABLE;
asm
@@Start: //esi: mask; edi: S
  push esi; mov esi,eax; xor eax,eax
  push edi; mov edi,edx; xor edx,edx;
  //push ebx; lea ebx,cxGlobal.UPCASETABLE;
  push edi; //add esp,16;
@@Loop:
  mov cl,[esi]; mov dl,[edi];
  mov al,cl; or cl,dl
  and cl,dl; and cl,al; jz @@Loop_end;
  add esi,1; add edi,1;
  //case insensitive: mov dl,[ebx+edx]; mov al,[ebx+eax];
  //xor dl,al; mov cl,al; mov dh,dl
  //xor al,'?'; or dl,al; and dl,dh;
  //mov dh,0
  //and al,dl; jz @@Loop;
  //cmp cl,'*'; mov al,[esi]; jz @@cka;

  cmp al,'?'; jz @@Loop;
  cmp al,dl; jz @@Loop;
  mov cl,al;

  cmp al,'*'; mov al,[esi]; jz @@cka
  sub edi,1; sub esi,1; jmp @@Loop_end;

@@cka: cmp al,cl; jnz @@ckd;
@@Lmask: mov al,[esi+1]; add esi,1; cmp al,cl; jz @@Lmask
@@ckd: test al,al; mov dl,[edi]; jnz @@ckp
@@found: test dl,dl; jz @@Loop_end;
@@Lfound: mov dl,[edi+1]; add edi,1;
          test dl,dl; jnz @@Lfound;
jmp @@Loop_end;
@@ckp: //mov cl,al//mov cl,[ebx+eax]; mov dl,[ebx+edx];
  //mov al,cl; xor cl,'?';
  //xor dl,al; and dl,cl; jnz @@ckn;
  cmp al,'?'; jz @@nfetch
  cmp dl,al; jnz @@ckn
@@nfetch:
  add esi,1; add edi,1; jmp @@Loop
@@ckn: mov ecx,edi
@@ckl: // al would NEVER be zero here..
  mov dl,[ecx+1]; add ecx,1;
  test dl,dl; jz @@Loop_end
  xor dl,al; jnz @@ckl
  mov edi,ecx; jmp @@Loop
@@Loop_end:
  mov cl,[esi]; pop esi;
  //mov edx,esp; add esp,12
  cmp cl,1; sbb eax,eax;
  sub edi,esi; and eax,edi;
@@Stop:
  //mov ebx,[esp-12]; mov edi,[esp-8];
  //mov esi,[esp-4]; //add esp,12; //AGI
  //mov ebx,[edx]; mov edi,[edx+4];
  //mov esi,[edx+8]; //add esp,12; //AGI
  pop edi; pop esi;
@@ret:
end;

function _pmatchi(const mask, S: PChar): integer; // internal, no length checking
var UPC: pointer absolute cxGlobal.UPCASETABLE;
asm
@@Start: //esi: mask; edi: S
  push esi; mov esi,eax; xor eax,eax
  push edi; mov edi,edx; xor edx,edx;
  push ebx; lea ebx,cxGlobal.UPCASETABLE;
  push edi; //add esp,16;
@@Loop:
  mov cl,[esi]; mov dl,[edi];
  mov al,cl; or cl,dl
  and cl,dl; and cl,al; jz @@Loop_end;
@@midl:
  add esi,1; add edi,1;
  mov dl,[ebx+edx]; mov al,[ebx+eax];
  //xor dl,al; mov cl,al;
  //xor al,'?'; and al,dl; jz @@Loop;
  //cmp cl,'*'; mov al,[esi]; jz @@cka;
  cmp al,'?'; jz @@Loop;
  cmp al,dl; jz @@Loop;
  mov cl,al;

  cmp al,'*'; mov al,[esi]; jz @@cka
  sub edi,1; sub esi,1; jmp @@Loop_end;

@@cka: cmp al,cl; jnz @@ckd;
@@Lmask: mov al,[esi+1]; add esi,1; cmp al,cl; jz @@Lmask
@@ckd: test al,al; mov dl,[edi]; jnz @@ckp
// al (mask) is zero
@@found: test dl,dl; jz @@Loop_end;
@@Lfound: mov dl,[edi+1]; add edi,1;
          test dl,dl; jnz @@Lfound;
jmp @@Loop_end;
@@ckp: mov cl,[ebx+eax]; mov dl,[ebx+edx];
  cmp cl,'?'; jz @@nfetch;
  cmp dl,cl; mov al,cl; jnz @@ckn;
@@nfetch:
  add esi,1; add edi,1; jmp @@Loop
@@ckn: mov ecx,edi
@@ckl: // al would NEVER be zero here..
  mov dl,[ecx+1]; add ecx,1;
  test dl,dl; jz @@Loop_end
  mov dl,[ebx+edx]; xor dl,al; jnz @@ckl
  mov edi,ecx; jmp @@Loop
@@Loop_end:
  mov cl,[esi]; pop esi;
  mov edx,esp; add esp,12;
  cmp cl,1; sbb eax,eax;
  sub edi,esi; and eax,edi;

@@Stop:
  //mov ebx,[esp-12]; mov edi,[esp-8];
  //mov esi,[esp-4]; //add esp,12; //AGI
  mov ebx,[edx]; mov edi,[edx+4];
  mov esi,[edx+8]; //add esp,12; //AGI
@@ret:
end;

function pmatchi(const mask, S: PChar): integer;
asm
  mov ecx,eax; or eax,edx;
  and eax,edx; and eax,ecx; jz @@ret
  mov eax,ecx; jmp _pmatchi
  @@ret:
end;

function pmatchs(const mask, S: PChar): integer;
asm
  mov ecx,eax; or eax,edx;
  and eax,edx; and eax,ecx; jz @@ret
  mov eax,ecx; jmp _pmatchs
  @@ret:
end;

function match(const mask, S: string; const CaseSensitive: boolean = FALSE): integer;
asm
 cmp cl,1; sbb ecx,ecx
 jmp ecx*4+@@jmptable+4
 @@jmptable: dd pmatchs, pmatchi
end;

function matchx(const mask, S: string; const table: termTable; const CaseSensitive: boolean = FALSE): integer;
begin
  if CaseSensitive then
    Result := pmatchxs(pointer(mask), pointer(S), table)
  else
    Result := pmatchxi(pointer(mask), pointer(S), table)
end;

function matchpos(const mask, S: string; out matchLen: integer;
  const Casesensitive: boolean = FALSE): integer;
asm
  push esi; mov esi,eax;
  or eax,edx; and eax,edx;
  and eax,esi; mov [matchLen],eax;
  jz @@ends;

  push edi; mov edi,edx;
  push ebx; mov ebx,ecx;
  mov cl,CaseSensitive;
  push ebp; mov ebp,[edx-4];
  add edi,ebp; push edx;
  neg ebp; //push ecx*4+matchs+4
  test cl,cl; jz @@Loops

@@Loopi:
  mov edx,edi; mov eax,esi;
  add edx,ebp; call _pmatchs; jnz @@done
  add ebp,1; jnz @@Loopi;
  jmp @@done

@@Loops:
  mov edx,edi; mov eax,esi;
  add edx,ebp; call _pmatchi; jnz @@done
  add ebp,1; jnz @@Loops;
  jmp @@done

@@done:
  //cmp ebp,1; sbb ebp,-1
  add ebp,1
  pop ecx; mov edx,esp;
  add esp,12; sub edi,ecx;
  mov [ebx],eax; add edi,ebp
  cmp eax,1; sbb eax,eax; and eax,edi
  xor eax,edi; mov ebp,[edx];
  mov ebx,[edx+4]; mov edi,[edx+8];
@@ends: pop esi
end;

function matchxpos(const mask, S: string; out matchLen: integer; const terminators: termTable; const Casesensitive: boolean = FALSE): integer;
asm
  push esi; mov esi,eax;
  or eax,edx; and eax,edx;
  and eax,esi; mov [matchLen],eax;
  jz @@ends;

  push edi; mov edi,edx;
  push ebx; mov ebx,terminators
  push ebp; push ecx;
  mov cl,Casesensitive; mov ebp,[edx-4];
  add edi,ebp; push edx;
  neg ebp; //push ecx*4+matchs+4
  test cl,cl; jz @@Loops

@@Loopi:
  mov edx,edi; mov eax,esi;
  add edx,ebp; mov ecx,ebx;
  call pmatchxs; jnz @@done
  add ebp,1; jnz @@Loopi;
  jmp @@done

@@Loops:
  mov edx,edi; mov eax,esi;
  add edx,ebp; mov ecx,ebx;
  call pmatchxi; jnz @@done
  add ebp,1; jnz @@Loops;
  jmp @@done

@@done:
  //cmp ebp,1; sbb ebp,-1
  add ebp,1
  mov ecx,[esp]; mov ebx,[esp+4];
  mov edx,esp; add esp,20;
  sub edi,ecx; mov [ebx],eax;
  add edi,ebp; cmp eax,1;
  sbb eax,eax; and eax,edi;
  xor eax,edi;
  mov ebp,[edx+8]; mov ebx,[edx+12]; mov edi,[edx+16];
@@ends: pop esi
end;

end.


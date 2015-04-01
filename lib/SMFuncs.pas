unit SMFuncs;
{$WEAKPACKAGEUNIT ON}
{$I SMBIOS.INC}
{/$WARNINGS off}
{/$HINTS off}

interface
uses SMGlobal;

// findEntryPoint returns pointer to SMBIOS EntryPoint structure, or NIL if not found
function findEntryPoint(const Buffer: pointer; const BufLen: integer): pointer;

// _CheckValidEntryPoint returns 0 (nil) if not valid, all registers are preserved,
// (supposed to be called from another asm routines)
function _CheckValidEntryPoint(const EntryPoint: pointer): pointer;

// findOffset gives EntryPoint offset from Buffer if any, otherwise returns -1
function findOffset(const Buffer: pointer; const BufLen: integer): integer;

// findStructure returns pointer to Specific SMBIOS Structure Type
// given TypeID = -1, find EntryPoint instead, return NIL if none valid
function findStructure(const Buffer: pointer; const BufSize: integer;
  const TypeID: integer = -1; const SegBase: word = word(-1)): pointer;

function getSMIDStr(const PHeader: PSMStructHeader; const Index: integer): string;
implementation
//uses SMRec;

const
  _SM_ = $5F4D535F; // 5F,53,4D,5F // _SM_
  _DMI = $494D445F; // 5F,44,4D,49 // _DMI

function getSMIDStr(const PHeader: PSMStructHeader; const Index: integer): string;
const
  TOPINDEX = 63 + 1;
var
  i: integer;
  P: PChar;
begin
  Result := '';
  if (Index > 0) and (Index < TOPINDEX) then begin
    P := pointer(PHeader);
    inc(P, PHeader^.Length);
    for i := 1 to Index - 1 do
      inc(P, length(P) + 1);
    Result := P;
  end;
end;

function findEntryPoint(const Buffer: pointer; const BufLen: integer): pointer;
asm
  test eax,eax; jz @@ret
  cmp edx,14h; jge @@begin
@@zero: xor eax,eax
@@ret: ret
@@begin: push esi;push edi
  xchg eax,edx
  lea edx,eax+edx-1           ;// buffer's tail
  neg eax                     ;// -bufLen min. 14h
@@LOOP: inc eax; jge @@end    ;// ZERO at most, NEVER greater
  cmp dword ptr[eax+edx], _SM_; jne @@LOOP
  cmp dword ptr[eax+edx+10h], _DMI; jne @@LOOP
  cmp byte ptr[eax+edx+14h], '_'; jne @@LOOP

  xor ecx,ecx
  lea esi,eax+edx-1
  movzx edi,byte ptr[eax+edx+5]
@@Loop1: add bl,byte ptr[esi+edi]; dec edi; jg @@Loop1
  test ecx,ecx; jne @@LOOP

  lea edi,edi+0fh; lea esi,eax+edx+0fh
@@Loop2: add bl,byte ptr[esi+edi]; dec edi; jg @@Loop2
  test ecx,ecx; jne @@LOOP
  add eax,edx
@@end:pop edi;pop esi
end;

function findOffset(const Buffer: pointer; const BufLen: integer): integer;
asm
  push eax; call findEntryPoint; pop edx
  or eax,eax; jnz @@done
  sub edx,edx; inc edx
  @@done: sub eax,edx
end;

function _CheckValidEntryPoint(const EntryPoint: pointer): pointer;
asm
  test eax,eax; jz @@ret
  cmp dword ptr[eax],_SM_; jne @@zero
  cmp dword ptr[eax+10h],_DMI; jne @@zero
  cmp byte ptr[eax+14h],'_'; je @@begin
@@zero: xor eax,eax
@@ret:ret
@@begin: push 0;push esi;push edi
  mov esi,eax; sub eax,eax
  movzx edi,byte ptr[esi+5]
  dec edi
@@Loop1: add al,byte ptr[esi+edi]
; dec edi; jge @@Loop1
  test al,al; jnz @@end
  mov dword[esp+8],esi
  add edi,10h; add esi,10h
@@Loop2: add al,byte ptr[esi+edi]
; dec edi; jge @@Loop2
  test al,al; jz @@end
  mov dword[esp+8],0
@@end:pop edi;pop esi;pop eax
end;

const
  //KnownTypeID: set of byte = [0..39, 126, 127];
  //KnownTypeIDChar: set of char = [#0..#39, #126, #127];
  SMSTRUCT_TYPEID_EOF = 127;
  SMSTRUCT_TYPEID_INACTIVE = 126;
  SMSTRUCT_TYPEID_MAXVALID = 39;

type
  tSMSHeader = packed record
    TypeID, Length: byte;
    Handle: word;
  end;

  TEPtable = packed record
    Anchor: array[0..3] of char; //cardinal; // '_SM_' = 5F 53 4D 5F
    Checksum: byte;
    Length: byte;
    Version: word;
    MaxtblSize: word;
    EPRevision: byte;
    FmtArea, inAnchor: packed array[0..4] of char;
    inCksum: byte;
    tblLength: word;
    tblAddress: Cardinal;
    NumOfStruc: word;
    SMRev: byte;
  end;

{
  //pushad-> (TEMP=sp), push(ax,cx,dx,bx,TEMP,bp,si,di)
  //popad-> pop(di,si,bp,TEMP,bx,dx,cx,ax) note: TEMP = inc(sp, 2/4/8)
}

function findStructure(const Buffer: pointer; const BufSize: integer;
  const TypeID: integer = -1; const SegBase: word = word(-1)): pointer;
const
  MAXID = SMSTRUCT_TYPEID_MAXVALID;
asm
  test eax,eax; jz @@stop
  cmp TypeID,MAXID; jbe @@begin ;// 39 and below (not negative)
  inc TypeID; jz @@findEPOnly
@@zero: xor eax,eax   ;// jmp @@stop
@@findEPOnly: call findEntryPoint; jmp @@stop
@@begin: push edi;push esi;push ebx
  mov edi,eax; mov esi,edx; mov ebx,ecx
  call findEntryPoint ;// result EntryPoint in Buffer
  test eax,eax; jz @@end
  movzx edx,word ptr[eax.TEPTable.tblLength]
  ;// edx = Tables tail (absolute address)
  add edx,dword ptr[eax.TEPTable.tblAddress]
  mov eax,dword ptr[eax.TEPTable.tblAddress]

  movzx ecx,SegBase
  shl ecx,4           ;// make segment start Address (x16)
  cmp ecx,eax         ;// SegBase starts below TableAddres?
  jae @@nonsense      ;// equal is not enough

  ;//supposed to be tables length, start form SegBase ~ BufLen
  ;//sub edx,ecx
  ;//cmp edx,esi; jbe @@min
  ;//mov esi,edx; @@min:

  ;//note: ecx=SegBase (absolute) <~equ~> edi=Buffer (heap)
  sub ecx,edi         ;// X - Buffer => Base' (in negative sign)
                      ;//     (diff between absolute & heap memory)
  add edi,esi         ;// edi = buffer tail (heap)

  sub eax,ecx         ;// (sub negative = add) -> eax=table0 in heap/buffer
  sub edx,ecx         ;// edx = Tables tail (in heap)

  cmp edi,edx; jbe @@already_min
  mov edi,edx; @@already_min:
  xor edx,edx; xor ecx,ecx

@@Loop:
  mov bh,byte ptr[eax]
  mov dl,byte ptr[eax+1]  ;//length
  cmp bh,bl; je @@end
  lea eax,eax+edx+2
  cmp bh,MAXID; ja @@nonsense

@forward2:
  test word ptr[eax-2],-1; jz @@checktail
  test word ptr[eax-1],-1; lea eax,eax+1; jz @@checktail

@@scan: inc cl; jz @@nonsense
  test byte ptr[eax], -1; lea eax,eax+1; jnz @@scan
  inc eax; jmp @forward2

@@checktail:
  cmp eax,edi; jb @@loop     ;// equal is not enough

@@nonsense: xor eax,eax
@@end: pop ebx;pop esi;pop edi
@@stop:
end;

end.


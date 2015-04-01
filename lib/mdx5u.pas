unit mdx5u; // no file support
//{$D+}
// sample interface to mdx5.obj
// this is the *real* FAST md4/md5 hashing
// capable checksuming filesize upto 72057594037927935 bytes
// (that is more than 72 'peta' bytes)
//
{
; copyright 2005, aa, Adrian Hafizh & Inge DR.
; Property of PT SOFTINDO Jakarta.
; All rights reserved.
;
; mail,to:@[zero_inge]AT@-y.a,h.o.o.@DOTcom,
; mail,to:@[aa]AT@-s.o.f.t,i.n.d.o.@DOTnet
; http://delphi.softindo.net
}
// see also our *real* FAST cxpos search/replace string

interface
type
  tmdxAlgorithm = (mda4, mda5);
  tmdxSum = type string; // string[16];
  pmdxDigest = ^tmdxDigest;
  tmdxDigest = packed record
    case integer of
      1: (A, B, C, D: Cardinal);
      2: (I64Lo, I64Hi: int64);
      3: (Dump: array[1..16] of char);
  end;

// return string (32 bytes)
function md4Sum(const S: string): tmdxSum; overload;
function md4Sum(const Buffer: pointer; const Length: Longword): tmdxSum; overload;
function md5Sum(const S: string): tmdxSum; overload;
function md5Sum(const Buffer: pointer; const Length: Longword): tmdxSum; overload;

function mdxSum(const S: string; const Algorithm: tmdxAlgorithm): tmdxSum; overload;
function mdxSum(const Buffer: pointer; const Length: Longword; const Algorithm: tmdxAlgorithm): tmdxSum; overload;

// returns mdxDigest (16bytes)
function md4Digest(const S: string): tmdxDigest; overload;
function md4Digest(const Buffer: pointer; const Length: Longword): tmdxDigest; overload;
function md5Digest(const S: string): tmdxDigest; overload;
function md5Digest(const Buffer: pointer; const Length: Longword): tmdxDigest; overload;
function mdxDigest(const Buffer: pointer; const Length: Longword; const Algorithm: tmdxAlgorithm): tmdxDigest; overload;

// totalDataLen must not exceed 7 Peta (72057594037927935) bytes
procedure md4tail(var Digest: tmdxDigest; Buffer: pointer; const BufLen: cardinal; const totalDataLen: int64); overload;
procedure md5tail(var Digest: tmdxDigest; Buffer: pointer; const BufLen: cardinal; const totalDataLen: int64); overload;

procedure mdxinit(var Digest: tmdxDigest);
procedure mdxClear(var Digest: tmdxDigest);

function mdxDigesttoStr(const Digest: tmdxDigest): tmdxSum;

{$L mdx5.obj}
// if your data all fits in Buffer (max.4G), you never need fetch routines.
// use mdxinit followed by mdxtail instead
procedure __mdx5fetch(var Digest: tmdxDigest; const Chunk: pointer); register; external;
procedure __mdx4fetch(var Digest: tmdxDigest; const Chunk: pointer); register; external;

const
  MDXBLOCK = 64;
  MDXBLOCKMASK = MDXBLOCK - 1;

implementation
//uses ordinals; // our nice hex-conversion routine :)
{
; USAGE
; 1. call __mdxinit
;      argument is pointer to 16 bytes MD4/MD5 digest, passed via EAX
; 2. call __mdx5fetch/__mdx4fetch for every integral chunks of 64 bytes
;    do not call it if the length of the chunk is less than 64 bytes
;      arguments are:
;        pointer to 16 bytes MD4/MD5 digest, passed via EAX
;        pointer to 64 bytes data chunk, passed via EDX
;    call after here also any tracking/gauge/progress function you wish
;    do not worry, all registers are preserved here
; 3. call __mdx5finalize/__mdx4finalize for the last chunk whose length
;    less than 64 bytes (including 0 length chunk, if total size is perfectly
;    64 bytes fold or the total length itself was 0)
;      arguments are:
;        pointer to 16 bytes MD4/MD5 digest, passed via EAX
;        pointer to 0-63 bytes data chunk tail (last), passed via EDX
;        Original/Total Data Size/Length in bytes (up to 72057594037927935 bytes)
;          passed via stack as a pair of DWORDs, High Significant dword first (are they?)
;          which is simply an int64 type in Delphi
; 4. done. result in 16 bytes MD4/MD5 digest
;
; update:
:   there is a bug in mdxfinalize routine's arguments passing (mdx5 ver 1.0.0.0r),
;   fixed in version 1.0.0.2. if you are still using old version, here's the workaround
;   (you MUST call function mdxtail, rather than separate fetch and finalize from Delphi)
;
}

{.$L mdx5.obj}
procedure __mdxinit(var Digest: tmdxDigest); register; external;
//procedure __mdx5fetch(var Digest: tmdxDigest; const Chunk: pointer); register; external;
//procedure __mdx4fetch(var Digest: tmdxDigest; const Chunk: pointer); register; external;
procedure __mdx5Finalize(var Digest: tmdxDigest; const endOfChunk: pointer; const ActualLength: int64); register; external;
procedure __mdx4Finalize(var Digest: tmdxDigest; const endOfChunk: pointer; const ActualLength: int64); register; external;
const
  PAGESIZE = MDXBLOCK * MDXBLOCK;
type
  TPageBlock = packed array[1..PAGESIZE] of byte;

{
procedure mdxinit(var Digest: tmdxDigest);
const
  A = $67452301; B = $EFCDAB89;
  C = $98BADCFE; D = $10325476;
begin
  Digest.A := A; Digest.B := B;
  Digest.C := C; Digest.D := D;
end;
}

procedure mdxClear(var Digest: tmdxDigest); asm fldz; fst qword ptr [eax]; fstp qword ptr [eax+8]; end;

procedure mdxinit(var Digest: tmdxDigest);
const
  init: packed array[boolean] of int64 = ($EFCDAB8967452301, $1032547698BADCFE);
asm
  fild qword ptr [init]; fild qword ptr init+8; fxch;
  fistp qword ptr [eax]; fistp qword ptr eax+8;
end;

function mdxDigesttoStr(const Digest: tmdxDigest): tmdxSum;
const
  DigestLen = sizeof(Digest);
  HexChars: pChar = '0123456789ABCDEF';
asm
  push eax; mov eax,edx; call System.@LStrClr;
  push DigestLen*2; pop edx; call System.@LStrSetLength;
  pop edx; push edi; mov edi,[eax];
  push DigestLen; pop ecx;
  push esi; mov esi,HexChars;
  push ebx; lea edi,edi+ecx*2-1;
  sub ecx,1;
  @@Loop:
    movzx eax,[edx+ecx]; mov ebx,eax;
    and eax,$0f; shr ebx,4;
    mov al,esi+eax; mov bl,esi+ebx
    mov [edi],al; mov [edi-1],bl;
    lea edi,edi-2; sub ecx,1;
  jge @@Loop
  pop ebx; pop esi; pop edi;
end;

// workaround for mdx5.obj ver 1.0.0.0r parameter passing bug (fixed in ver 1.0.0.2)
procedure md4tail(var Digest: tmdxDigest; Buffer: pointer;
  const BufLen: cardinal; const totalDataLen: int64); overload;
var
  i: integer;
begin
  for i := 1 to BufLen div MDXBLOCK do begin
    __mdx4fetch(Digest, Buffer);
    inc(integer(Buffer), MDXBLOCK);
  end;
  __mdx4finalize(Digest, Buffer, totalDataLen);
end;

procedure md5tail(var Digest: tmdxDigest; Buffer: pointer;
  const BufLen: cardinal; const totalDataLen: int64); overload;
var
  i: integer;
begin
  for i := 1 to BufLen div MDXBLOCK do begin
    __mdx5fetch(Digest, Buffer);
    inc(integer(Buffer), MDXBLOCK);
  end;
  __mdx5finalize(Digest, Buffer, totalDataLen);
end;

function mdxDigest(const Buffer: pointer; const Length: longword;
  const Algorithm: tmdxAlgorithm): tmdxDigest; overload;
begin
  mdxClear(Result);
  if Buffer <> nil then begin
    __mdxinit(Result);
    if Algorithm = mda5 then
      md5tail(Result, Buffer, length, length)
    else if Algorithm = mda4 then
      md4tail(Result, Buffer, length, length)
  end;
end;

function md4Digest(const S: string): tmdxDigest; overload; begin
  Result := mdxDigest(PChar(S), length(S), mda4)
end;
function md4Digest(const Buffer: pointer; const Length: Longword): tmdxDigest; overload; begin
  Result := mdxDigest(Buffer, Length, mda4)
end;
function md5Digest(const S: string): tmdxDigest; overload; begin
  Result := mdxDigest(PChar(S), length(S), mda5)
end;
function md5Digest(const Buffer: pointer; const Length: Longword): tmdxDigest; overload; begin
  Result := mdxDigest(Buffer, Length, mda4)
end;

function mdxSum(const Buffer: pointer; const Length: longword; const Algorithm: tmdxAlgorithm): tmdxSum; overload; begin
  Result := mdxDigesttoStr(mdxDigest(Buffer, Length, Algorithm))
end;
function mdxSum(const S: string; const Algorithm: tmdxAlgorithm): tmdxSum; overload; begin
  Result := mdxDigesttoStr(mdxDigest(pchar(S), Length(S), Algorithm));
end;
function md5Sum(const Buffer: pointer; const Length: longword): tmdxSum; overload; begin
  Result := mdxDigesttoStr(mdxDigest(Buffer, Length, mda5))
end;
function md5Sum(const S: string): tmdxSum; overload; begin
  Result := md5Sum(pchar(S), Length(S));
end;
function md4Sum(const Buffer: pointer; const Length: longword): tmdxSum; overload; begin
  Result := mdxDigesttoStr(mdxDigest(Buffer, Length, mda5))
end;
function md4Sum(const S: string): tmdxSum; overload; begin
  Result := md5Sum(pchar(S), Length(S));
end;

end.


unit mdx5;
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
// return string[16], you may use tmxDigest instead (make it global)
// as we have said: this only a sample interface.
function md4(const S: string): string; overload;
function md4(const Buffer: pointer; const Length: Longword): string; overload;
function md4file(const filename: string): string; overload;
function md5(const S: string): string; overload;
function md5(const Buffer: pointer; const Length: Longword): string; overload;
function md5file(const filename: string): string; overload;

implementation
uses ordinals; // our nice hex-conversion routine :)

type
  tmdxDigest = packed record
    case integer of
      1: (A, B, C, D: Cardinal);
      2: (I64Lo, I64Hi: int64);
      3: (Dump: array[1..16] of char);
  end;

{$L mdx5.obj}
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
}
procedure __mdxinit(var Digest: tmdxDigest); register; external;
procedure __mdx4fetch(var Digest: tmdxDigest; const Chunk: pointer); register; external;
procedure __mdx4Finalize(var Digest: tmdxDigest; const endChunk: pointer; const ActualLength: int64); register; external;
procedure __mdx5fetch(var Digest: tmdxDigest; const Chunk: pointer); register; external;
procedure __mdx5Finalize(var Digest: tmdxDigest; const endChunk: pointer; const ActualLength: int64); register; external;

const
  MDXBLOCK = 64;
  PAGESIZE = MDXBLOCK * MDXBLOCK;

type
  TPageBlock = packed array[1..PAGESIZE] of byte;
{
procedure mdxinit(var Digest: tmdxDigest);
// identical with __mdxinit
const
  A = $67452301;
  B = $efcdab89;
  C = $98badcfe;
  D = $10325476;
begin
  Digest.A := A;
  Digest.B := B;
  Digest.C := C;
  Digest.D := D;
end;
}
//
// for clarity purpose, md4 & md5 got different interface
//

// ======================================================================
// MD5...
// ======================================================================
procedure md5body(var md5: tmdxDigest; const Block: TPageBlock); overload;
// calculate/transform md5 of a data block of exactly 4096 bytes length
const
  ctr = sizeOf(TPageBlock) div MDXBLOCK;
var
  i: integer;
  p: pointer;
begin
  p := @Block[Low(TPageBlock)];
  for i := 1 to ctr do begin
    __mdx5fetch(md5, p);
    inc(integer(p), MDXBLOCK);
  end
end;

procedure md5tail(var md5: tmdxDigest; const Buffer: pointer; const BufLen: cardinal; //int64;
  const DataLen: int64); overload;
// calculate md5 at end of arbitrary length of data
// actually BufLen could be an int64 wide, but pointer size limited only upto 4G
const
  MDXBLOCKMASK = MDXBLOCK - 1;
var
  i, fold: integer;
  P: pointer;
begin
  P := buffer;
  fold := integer(BufLen shr 6); // div 64
  for i := 1 to fold do begin
    __mdx5fetch(md5, p);
    inc(integer(p), MDXBLOCK);
  end;
  __mdx5finalize(md5, p, DataLen);
end;

function md5(const Buffer: pointer; const Length: longword): string; overload;
var
  md5: tmdxDigest;
begin
  __mdxinit(md5);
  md5tail(md5, Buffer, length, length);
  result := ordinals.Hexs(md5, sizeof(md5), [], #0);
end;

function md5(const S: string): string; overload;
begin
  Result := mdx5.md5(pchar(S), Length(S));
end;

// ======================================================================
// MD4...
// ======================================================================
procedure md4body(var md4: tmdxDigest; const Block: TPageBlock); overload;
// calculate/transform md5 of a data block of exactly 4096 bytes length
const
  ctr = sizeOf(TPageBlock) div MDXBLOCK;
var
  i: integer;
  p: pointer;
begin
  p := @Block[Low(TPageBlock)];
  for i := 1 to ctr do begin
    __mdx4fetch(md4, p);
    inc(integer(p), MDXBLOCK);
  end
end;

procedure md4tail(var md4: tmdxDigest; const Buffer: pointer; const BufLen: cardinal; //int64;
  const DataLen: int64); overload;
// calculate md5 at end of arbitrary length of data
// actually BufLen could be an int64 wide, but pointer size limited only upto 4G
const
  MDXBLOCKMASK = MDXBLOCK - 1;
var
  i, fold: integer;
  P: pointer;
begin
  P := buffer;
  fold := integer(BufLen shr 6); // div 64
  for i := 1 to fold do begin
    __mdx4fetch(md4, p);
    inc(integer(p), MDXBLOCK);
  end;
  __mdx4finalize(md4, p, DataLen);
end;

function md4(const Buffer: pointer; const Length: longword): string; overload;
var
  md4: tmdxDigest;
begin
  __mdxinit(md4);
  md4tail(md4, Buffer, length, length);
  result := ordinals.Hexs(md4, sizeof(md4), [], #0);
end;

function md4(const S: string): string; overload;
begin
  Result := mdx5.md4(pchar(S), Length(S));
end;

// ======================================================================
// user wrapped file handling routines, forward declarations
// ======================================================================
function fHandleOpenReadOnly(const Filename: string): integer; forward;
function fhandleGetLongSize(handle: integer): int64; forward;
function fHandleSetPos(Handle, Offset, Origin: Integer): Integer; forward;
function fHandleRead(Handle: integer; var Buffer; Count: integer): integer; forward;
procedure fHandleClose(Handle: integer); forward;
// ======================================================================

// now after you got the idea, we'd better combined all in one inteface...

type
  tmdxAlgorithm = (mda4, mda5);

function mdxfile(const filename: string; Algorithm: tmdxAlgorithm): string; overload;
const
  INVALID = -1;
  FILE_BEGIN = 0;
var
  mdxbody: procedure(var mdx: tmdxDigest; const Block: TPageBlock);
  mdxtail: procedure(var mdx: tmdxDigest; const Buffer: pointer; const BufLen: cardinal; const DataLen: int64);
var
  mdx: tmdxDigest;
  fsize, fCtr: int64;
  fh: integer;
  Buffer: TPageBlock;
begin
  fh := fHandleOpenReadOnly(filename);
  if fh = INVALID then
    result := ''
  else begin
    fHandleSetPos(fh, 0, FILE_BEGIN);
    fSize := fhandleGetLongSize(fh);
    fCtr := fSize;
    __mdxinit(mdx);
    mdxbody := md5body;
    mdxtail := md5tail;
    if Algorithm = mda4 then begin
      mdxbody := md4body;
      mdxtail := md4tail;
    end;
    while fCtr >= PAGESIZE do begin
      fHandleRead(fh, Buffer, PAGESIZE);
      mdxbody(mdx, Buffer);
      dec(fCtr, PAGESIZE);
    end;
    fHandleRead(fh, Buffer, integer(fCtr));
    fHandleClose(fh);
    mdxtail(mdx, @Buffer, fCtr, fSize);
    result := ordinals.Hexs(mdx, sizeof(mdx), [], #0);
  end;
end;

//...so you can simply call:

function md5file(const filename: string): string; overload;
begin
  Result := mdxfile(filename, mda5);
end;

function md4file(const filename: string): string; overload;
begin
  Result := mdxfile(filename, mda4);
end;

// ======================================================================
// WINDOWS... not needed if you put 'uses windows'
// ======================================================================
const
  kernel32 = 'kernel32.dll';

type
  dword = longword;
  thandle = integer;
  bool = longbool;

function CreateFile(Filename: PChar; DesiredAccess, ShareMode: Longword;
  SecurityAttributes: pointer {PSecurityAttributes}; CreationDisposition,
  FlagsAndAttributes: Longword; hTemplateFile: integer): integer; stdcall;
  external kernel32 name 'CreateFileA'; {$EXTERNALSYM CreateFile}

function CloseHandle(Handle: THandle): Longbool; stdcall;
  external kernel32 name 'CloseHandle'; {$EXTERNALSYM CloseHandle}

function fHandleGetFileSize(hFile: Longword; lpFileSizeHigh: Pointer): Cardinal; stdcall;
  external kernel32 name 'GetFileSize'; {$EXTERNALSYM fHandleGetFileSize}

function SetFilePointer(hFile: THandle; lDistanceToMove: Longint;
  lpDistanceToMoveHigh: Pointer; dwMoveMethod: DWORD): DWORD; stdcall;
  external kernel32 name 'SetFilePointer'; {$EXTERNALSYM SetFilePointer}

function ReadFile(hFile: THandle; var Buffer; nNumberOfBytesToRead: DWORD;
  var lpNumberOfBytesRead: DWORD; lpOverlapped: pointer {POverlapped}): BOOL; stdcall;
  external kernel32 name 'ReadFile'; {$EXTERNALSYM ReadFile}

// ======================================================================
// user wrapped file handling routines implementation/actual codes
// ======================================================================
function fHandleOpen(const Filename: string; const OpenModes, CreationMode, Attributes: Longword): integer;
const
  GENERIC_READ = longword($80000000);
  GENERIC_WRITE = $40000000;
  FILE_SHARE_READ = $00000001;
  FILE_SHARE_WRITE = $00000002;
  AccessMode: array[0..3] of Longword = (GENERIC_READ, GENERIC_WRITE, GENERIC_READ or GENERIC_WRITE, 0);
  ShareMode: array[0..4] of Longword = (0, 0, FILE_SHARE_READ, FILE_SHARE_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE);
begin
  Result := integer(CreateFile(PChar(Filename), AccessMode[OpenModes and 3],
    ShareMode[(OpenModes and $F0) shr 4], nil, CreationMode, Attributes, 0));
end;

function fHandleOpenReadOnly(const Filename: string): integer;
const
  faNormal = $00000080;
  fcOpenExisting = 3; //open-only, fail if not already existed //$0300;//OPEN_EXISTING;
  fmShareCompat = $0000; fmShareExclusive = $0010;
  fmShareDenyWrite = $0020; fmShareDenyRead = $0030; fmShareDenyNone = $0040;
  fmOpenRead = $0000; fmOpenWrite = $0001; fmOpenReadWrite = $0002; fmOpenQuery = $0003;
begin
  Result := fHandleOpen(Filename, fmOpenRead or fmShareDenyNone, fcOpenExisting, faNormal);
end;

procedure fHandleClose(Handle: integer);
begin
  CloseHandle(THandle(Handle));
end;

function fhandleGetLongSize(handle: integer): int64;
type
  I64 = packed record Lo, hi: Longword; end;
begin
  I64(Result).Lo := fhandleGetFileSize(handle, @I64(Result).Hi);
end;

function fHandleSetPos(Handle, Offset, Origin: Integer): Integer;
begin
  Result := SetFilePointer(THandle(Handle), Offset, nil, Origin);
end;

function fHandleRead(Handle: integer; var Buffer; Count: integer): integer;
begin
  if not ReadFile(THandle(Handle), Buffer, Count, Longword(Result), nil) then
    Result := -1;
end;

end.


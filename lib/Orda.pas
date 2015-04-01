unit Orda;
{$I QUIET.INC}

interface
uses ACConsts;
type
  tHexStyle = (hxReverse, hxLowerCase, hxSwapByte, hxBlockWise);
  tHexStyles = set of tHexStyle;

function Blox(const Buffer: pointer; const BufLen: integer; const BlockLen: byte = 0;
  const Delimiter: Char = #0; HexStyles: THexStyles = []): string; overload

function hexs_byte(const Buffer: pointer; const BufLen: integer; const Delimiter: Char = #0;
  const HexStyles: THexStyles = []): string; overload;

function CountSpaces(const BUffer; const BufLen: integer; const BlockLen: byte): integer; overload;
function hexs_countspace(const Buffer: pointer; const BufLen: integer; const BlockLen: byte;
  const Delimiter: char = ' '; const HexStyles: THexStyles = []): integer; overload;

function hexs_ord(const Buffer: pointer; const BufLen: integer; const BlockLen: integer;
  const Delimiter: char; const HexStyles: THexStyles): string; overload;

implementation
const Shiftable: set of byte = [1, 2, 4, 8, 16, 32, 64, 128];
// LStrClearAndSetLength - a simple routine to allocate a new string.
// At last, after tired of calling the same sequence of System's routines.
// it should have been one of the routine i've made first. :(, better than never.
function __LStrCLSet(var S; const Length): {string} PChar; overload asm
// * no register destroyed, result EAX points to the first char *
     push ecx; push edx; push eax
     mov edx, [eax]; test edx, edx; je @nil
     mov dword [eax], 0; lea eax, [edx-8]
     mov edx, dword [edx-8]; test edx, edx; jl @nil // neg refCount = constant string
     nop // to avoid AGI-stall
LOCK dec dword [eax]; jnz @nil  // dec refCount, (dont free it if still used by another S)
     call System.@FreeMem    // this call zeroes eax, ecx & edx
@nil: xor eax, eax
     mov edx, [esp+4]
     test edx, edx; jz @done
     add edx, +4 +4 +1       // ask for more +9 = sizeof(refCnt + refLen + asciiz#0)
     mov eax, [esp]
     call System.@GetMem     // result in eax; ecx=eax
     mov edx, [esp+4]
     add eax, 8              // shift offset to the first char position
     mov dword [eax-4], edx  // length of the string
     mov dword [eax-8], 1    // put RefCount
     mov byte [eax+edx], 0   // asciiz trailing#0
@done: pop edx; mov [edx], eax // temp edx of original eax alias S
     ;                         // put @S[1] alias PChar(S) there
     //  mov eax, edx // turn it back to owner (or you may left it returning PChar(S)
     // i think returning PChar will be more useful, we may forego since the var S now
     // has been properly initialized; this way we dont have to dereference S furthermore
     pop edx; pop ecx        //
end;

function Blox(const Buffer: pointer; const BufLen: integer; const BlockLen: byte = 0;
  const Delimiter: Char = #0; HexStyles: THexStyles = []): string; overload;
begin
  Result := '';
end;

const
  TABLE_HEXDIGITS: packed array[0..31] of char = '0123456789ABCDEF0123456789abcdef';
function hexs_byte(const Buffer: pointer; const BufLen: integer; const Delimiter: Char = #0;
const HexStyles: THexStyles = []): string; overload asm
  test Buffer, Buffer; jz @Stop
  //and BlockLen, 0ffh; jz @e
  test BufLen, -1; jg @Start
  @e: xor eax,eax; jmp @Stop
  @Start: push esi; push edi; push ebx
    xor ebx, ebx; bt dword [HexStyles], hxLowerCase; setc bl
    shl bl, 4; lea ebx, ebx+TABLE_HEXDIGITS
    push BufLen; shl BufLen, 1
    and ecx, 0ffh; push ecx; jz @SetL
    shr Buflen, 1; lea BufLen, BufLen*2+BufLen-1
  @SetL: mov esi, Buffer; mov eax, Result
    call __LStrCLSet; mov edi, eax; xor eax, eax
    bt dword[HexStyles], hxSwapByte; jc @@ByteSwap

    cmp cl,0;  mov ecx, [esp+4]; mov edx, eax; jnz @Ch1
  @Ch0: shr ecx, 1; jz @r1
    @Ch0Loop: mov dl, byte[esi]; mov eax, edx
      and al, 0fh; mov ah, byte[ebx+eax]
      shr dl, 04h; mov al, byte[ebx+edx]; rol eax, 10h

      mov dl, byte[esi+1]; lea esi, esi+2; mov al, dl
      and dl, 0fh; mov ah, byte[ebx+edx]
      mov dl, al; shr dl, 4; mov al, byte[ebx+edx]
      rol eax, 10h; mov dword[edi], eax; lea edi, edi+4
      dec ecx; jg @Ch0Loop; jmp @r1

  @Ch1: shr ecx, 1; jz @r1
    @Ch1Loop: mov dl, byte[esi]; mov eax, edx
      shr al, 04h; mov al, byte[ebx+eax]; ror eax, 8
      and dl, 0fh; mov al, byte[ebx+edx]
      mov ah, byte[esp]; rol eax, 8
      mov dword[edi], eax; lea edi, edi+3

      mov dl, byte[esi+1]; lea esi, esi+2; mov eax, edx
      shr al, 04h; mov al, byte[ebx+eax]; ror eax, 8
      and dl, 0fh; mov al, byte[ebx+edx]
      mov ah, byte[esp]; rol eax, 8
      mov dword[edi], eax; lea edi, edi+3
      dec ecx; jg @Ch1Loop; mov byte[edi-1],0

    @r1: pop ecx; pop edx; test dl,1; jz @done
      mov dl, byte[esi]; mov eax, edx
      shr al, 04h; mov al, byte[ebx+eax]
      and dl, 0fh; mov ah, byte[ebx+edx]
      mov word[edi], ax; jmp @done

  @@ByteSwap:
    cmp cl,0;  mov ecx, [esp+4]; mov edx, eax; jnz @_Ch1
  @_Ch0: shr ecx, 1; jz @_r1
    @_Ch0Loop: mov dl, byte[esi]; mov eax, edx
      and al, 0fh; mov al, byte[ebx+eax]
      shr dl, 4; mov ah, byte[ebx+edx]; rol eax, 10h
      mov dl, byte[esi+1]; lea esi, esi+2; mov al, dl
      shr dl, 4; mov ah, byte[ebx+edx]
      mov dl, al; and dl, 0fh; mov al, byte[ebx+edx]
      rol eax, 10h; mov dword[edi], eax; lea edi, edi+4
      dec ecx; jg @_Ch0Loop; jmp @_r1

  @_Ch1: shr ecx, 1; jz @_r1
    @_Ch1Loop: mov dl, byte[esi]; mov eax, edx
      and al, 0fh; mov al, byte[ebx+eax]; ror eax, 8
      shr dl, 4; mov al, byte[ebx+edx]
      mov ah, byte[esp]; rol eax, 8
      mov dword[edi], eax; lea edi, edi+3

      mov dl, byte[esi+1]; lea esi, esi+2; mov eax, edx
      and al, 0fh; mov al, byte[ebx+eax]; ror eax, 8
      shr dl, 4; mov al, byte[ebx+edx]
      mov ah, byte[esp]; rol eax, 8
      mov dword[edi], eax; lea edi, edi+3
      dec ecx; jg @_Ch1Loop; mov byte[edi-1],0

    @_r1: pop ecx; pop edx; test dl,1; jz @done
      mov dl, byte[esi]; mov eax, edx
      and al, 0fh; mov al, byte[ebx+eax]
      shr dl, 4; mov ah, byte[ebx+edx]
      mov word[edi], ax; jmp @done

  @done: pop ebx; pop edi; pop esi
  @Stop:
end;

function CountSpaces(const BUffer; const BufLen: integer; const BlockLen: byte): integer; overload;
begin
  Result := 0;
end;

function hexs_countspace(const Buffer: pointer; const BufLen: integer; const BlockLen: byte;
const Delimiter: char = ' '; const HexStyles: THexStyles = []): integer; overload asm
  @@Start: test Buffer, Buffer; jz @@Stop
  test BufLen, -1; jg @@begin
  @@e:xor eax, eax; jmp @@Stop
  @@begin: push esi; push edi; push ebx

    mov esi, Buffer; mov edi, BufLen
    mov bl, Delimiter; mov bh, HexStyles
    //bt dword[HexStyles], hxBlockWise; setc bh
    //bt dword[Shiftable], ecx; setc bl
    shl BufLen, 1; //and ecx, 0ffh
    cmp edi, ecx; jbe @d02  // negative BlockLen will always > BufLen
    test Delimiter, -1; jnz @pushc
    test bh, bh; jnz @pushc//jnz @SetL

      //bt dword[HexStyles], hxBlockWise; jc @SetL
    @d02: xor ecx, ecx
    @pushc: test ecx, ecx; jz @SetL; push ecx
      lea eax, [edi-1]; jpe @div
      cmp ecx, 80h; ja @div
      cmp ecx, 1 shl 2 +1; je @div; ja @shift
      shr ecx, 1; jnz @count
      test delimiter, -1; jz @popc
      lea edx, edx+edi-1; jmp @popc

    @shift: bt dword [Shiftable], ecx; jc @shiftable
    @div: xor edx, edx; div ecx // mid-separators count
      test bh, bh; jz @cset
      //bt dword[HexStyles], hxBlockWise; jnc @cset
      inc eax                   // block-count
      lea edx, ecx*2+1          // block size (blocklen*2 +1space)
      cmp Delimiter, -1; jz @cm
      mul edx; lea edx, [eax-1]; jmp @popc
    @cm: dec edx; mul edx; jmp @popc

    @shiftable: bsf ecx, ecx
    @count: shr eax, cl
      test bh, bh; jz @cset
      //bt dword[HexStyles], hxBlockWise; jnc @cset
      lea edx, eax+1
      //cmp Delimiter, 1
      //sbb edx, 0                 // remove if no Delimiter
      shl edx, cl
      lea edx, edx*2+eax; jmp @popc
    @cset: lea edx, edi*2+eax
    @popc: pop ecx

  @SetL: mov ebx, edi//mov eax, Result; call __LStrCLSet; mov edi, eax
  mov eax,edx

  @@end: pop ebx; pop edi; pop esi
  @@Stop:
end;

function hexs_ord(const Buffer: pointer; const BufLen: integer; const BlockLen: integer;
  const Delimiter: char; const HexStyles: THexStyles): string; overload;
begin
  Result := '';
end;

end.


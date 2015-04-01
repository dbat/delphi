unit fileCRC32;
interface
const
  CRC32_STDPOLY = $EDB88320; // widely used CRC32 Polynomial

//function GetCRC32Of(const b: byte; const initCRC32Value: Cardinal = 0): Cardinal; overload;
//function GetCRC32Of(const Buffer: pointer; const Size: integer; const initValue: Cardinal = 0): Cardinal; overload;
function GetCRC32Of(const Filename: string): Cardinal; overload;

// get CRC of parts (start, mid & end) of the file.
// filesize under 4 blocks (4 * CRC32MAX_PAGES) will get real CRC32 hash
const
  BYTES_PER_PAGE = 8192; // never change this!
  CRC32_DEFAULTBLOCKS = 2;
  //broken: boolean = FALSE;

function GetPartCRC32Of(const Filename: string; Blocks: integer = CRC32_DEFAULTBLOCKS): Cardinal; overload;
//function RevCRC32(const X: integer = __CRC32Poly__): Cardinal;$EDB88320
//function GetRevCRC32(const X: integer = 0; const CRC32Poly: integer = integer(CRC32_StdPoly)): integer;
//function Q_CRC32(const Buffer: Pointer; const Size: Cardinal; const InitValue: Cardinal = 0): Cardinal;
//function Q_CRC32(const Buffer: Pointer; const Size: Cardinal): Cardinal;
//function Q_NextCRC32(var CRC32: Cardinal; const Buffer: Pointer; const Size: Cardinal): LongWord;
//procedure BuildCRC32Table(const Polynomial: Integer = __CRC32Poly__; const initValue: Cardinal = 0);

implementation
uses Windows, ACConsts, forms, CCRC32;
//
type
  TBytePage = array[0..8191] of byte;
  //TByteSegment = array[word] of byte;
  //TCRC32Table = array[byte] of Cardinal;

//const
//  IntCRC32Poly = integer(CRC32_StdPoly);
//  CRC32Table: TCRC32Table = (
//    $00000000, $77073096, $EE0E612C, $990951BA, $076DC419, $706AF48F, $E963A535, $9E6495A3,
//    $0EDB8832, $79DCB8A4, $E0D5E91E, $97D2D988, $09B64C2B, $7EB17CBD, $E7B82D07, $90BF1D91,
//    $1DB71064, $6AB020F2, $F3B97148, $84BE41DE, $1ADAD47D, $6DDDE4EB, $F4D4B551, $83D385C7,
//    $136C9856, $646BA8C0, $FD62F97A, $8A65C9EC, $14015C4F, $63066CD9, $FA0F3D63, $8D080DF5,
//    $3B6E20C8, $4C69105E, $D56041E4, $A2677172, $3C03E4D1, $4B04D447, $D20D85FD, $A50AB56B,
//    $35B5A8FA, $42B2986C, $DBBBC9D6, $ACBCF940, $32D86CE3, $45DF5C75, $DCD60DCF, $ABD13D59,
//    $26D930AC, $51DE003A, $C8D75180, $BFD06116, $21B4F4B5, $56B3C423, $CFBA9599, $B8BDA50F,
//    $2802B89E, $5F058808, $C60CD9B2, $B10BE924, $2F6F7C87, $58684C11, $C1611DAB, $B6662D3D,
//    $76DC4190, $01DB7106, $98D220BC, $EFD5102A, $71B18589, $06B6B51F, $9FBFE4A5, $E8B8D433,
//    $7807C9A2, $0F00F934, $9609A88E, $E10E9818, $7F6A0DBB, $086D3D2D, $91646C97, $E6635C01,
//    $6B6B51F4, $1C6C6162, $856530D8, $F262004E, $6C0695ED, $1B01A57B, $8208F4C1, $F50FC457,
//    $65B0D9C6, $12B7E950, $8BBEB8EA, $FCB9887C, $62DD1DDF, $15DA2D49, $8CD37CF3, $FBD44C65,
//    $4DB26158, $3AB551CE, $A3BC0074, $D4BB30E2, $4ADFA541, $3DD895D7, $A4D1C46D, $D3D6F4FB,
//    $4369E96A, $346ED9FC, $AD678846, $DA60B8D0, $44042D73, $33031DE5, $AA0A4C5F, $DD0D7CC9,
//    $5005713C, $270241AA, $BE0B1010, $C90C2086, $5768B525, $206F85B3, $B966D409, $CE61E49F,
//    $5EDEF90E, $29D9C998, $B0D09822, $C7D7A8B4, $59B33D17, $2EB40D81, $B7BD5C3B, $C0BA6CAD,
//    $EDB88320, $9ABFB3B6, $03B6E20C, $74B1D29A, $EAD54739, $9DD277AF, $04DB2615, $73DC1683,
//    $E3630B12, $94643B84, $0D6D6A3E, $7A6A5AA8, $E40ECF0B, $9309FF9D, $0A00AE27, $7D079EB1,
//    $F00F9344, $8708A3D2, $1E01F268, $6906C2FE, $F762575D, $806567CB, $196C3671, $6E6B06E7,
//    $FED41B76, $89D32BE0, $10DA7A5A, $67DD4ACC, $F9B9DF6F, $8EBEEFF9, $17B7BE43, $60B08ED5,
//    $D6D6A3E8, $A1D1937E, $38D8C2C4, $4FDFF252, $D1BB67F1, $A6BC5767, $3FB506DD, $48B2364B,
//    $D80D2BDA, $AF0A1B4C, $36034AF6, $41047A60, $DF60EFC3, $A867DF55, $316E8EEF, $4669BE79,
//    $CB61B38C, $BC66831A, $256FD2A0, $5268E236, $CC0C7795, $BB0B4703, $220216B9, $5505262F,
//    $C5BA3BBE, $B2BD0B28, $2BB45A92, $5CB36A04, $C2D7FFA7, $B5D0CF31, $2CD99E8B, $5BDEAE1D,
//    $9B64C2B0, $EC63F226, $756AA39C, $026D930A, $9C0906A9, $EB0E363F, $72076785, $05005713,
//    $95BF4A82, $E2B87A14, $7BB12BAE, $0CB61B38, $92D28E9B, $E5D5BE0D, $7CDCEFB7, $0BDBDF21,
//    $86D3D2D4, $F1D4E242, $68DDB3F8, $1FDA836E, $81BE16CD, $F6B9265B, $6FB077E1, $18B74777,
//    $88085AE6, $FF0F6A70, $66063BCA, $11010B5C, $8F659EFF, $F862AE69, $616BFFD3, $166CCF45,
//    $A00AE278, $D70DD2EE, $4E048354, $3903B3C2, $A7672661, $D06016F7, $4969474D, $3E6E77DB,
//    $AED16A4A, $D9D65ADC, $40DF0B66, $37D83BF0, $A9BCAE53, $DEBB9EC5, $47B2CF7F, $30B5FFE9,
//    $BDBDF21C, $CABAC28A, $53B39330, $24B4A3A6, $BAD03605, $CDD70693, $54DE5729, $23D967BF,
//    $B3667A2E, $C4614AB8, $5D681B02, $2A6F2B94, $B40BBE37, $C30C8EA1, $5A05DF1B, $2D02EF8D
//    );
//
//var
//  PCRC32Table: ^TCRC32Table absolute CRC32Table;
//
////function Q_CRC32(const Buffer: Pointer; const Size: Cardinal; const InitValue: Cardinal = 0): Cardinal;
//
//function Q_CRC32(const Buffer: Pointer; const Size: Cardinal): Cardinal;
//asm
//  push ebx
//  mov ebx, eax
//  //not ecx
//  //mov eax, ecx
//  mov eax, $FFFFFFFF
//  push esi
//  test edx, edx
//  je @@done
//@@loop:
//  movzx esi, byte ptr [ebx]
//  movzx ecx, al
//  xor ecx, esi
//  shr eax, 8
//  xor eax, dword ptr [ecx*4+CRC32Table]
//  inc ebx
//  dec edx
//  jne @@loop
//@@done: pop esi
//  not eax
//  pop ebx
//end;
//
//function Q_NextCRC32(var CRC32: Cardinal; const Buffer: Pointer; const Size: Cardinal): LongWord;
//asm
//  test ecx, ecx
//  je @@end
//  push ebx
//  push eax
//  mov eax, [eax]
//  not eax
//  push esi
//
//@@loop:
//  movzx esi, byte ptr [edx]
//  movzx ebx, al
//  shr eax, 8
//  xor ebx, esi
//  xor eax, dword ptr [ebx*4 + CRC32Table]
//  inc edx
//  dec ecx
//  jne @@loop
//
//  pop esi
//  pop edx
//  not eax
//  mov [edx], eax
//  pop ebx
//  ret
//@@end: mov eax, [eax]
//end;
//
//function GetCRC32(var initValue: Cardinal; const Buffer: Pointer; const Length: Cardinal): Cardinal;
//asm
//  test ecx, ecx
//  je @@end
//  push ebx
//  push eax
//  mov eax, [eax]
//  not eax
//  push esi
//
//@@loop:
//  movzx esi, byte ptr [edx]
//  xor ebx, ebx
//  mov bl, al
//  shr eax, 8
//  xor ebx, esi
//  xor eax, dword ptr [ebx*4 + CRC32Table]
//  inc edx
//  dec ecx
//  jne @@loop
//
//  pop esi
//  pop edx
//  not eax
//  mov [edx], eax
//  pop ebx
//  ret
//@@end: mov eax, [eax]
// ret
//end;
//
//function asmGetCRC32Of(const Buffer: pointer; const Size: integer; const initValue: Cardinal = 0): Cardinal; overload;
//asm
//  push esi; push edi
//  lea esi, eax+edx+1
//  neg edx; jnz @@goon
//
//@@goon:
//  xor eax, eax; mov al, byte ptr [esi+edx]
//  xor ebx, ebx; mov bl, cl
//  shr ecx, 8
//  xor ebx, eax
//  mov edi, dword ptr [ebx*4+CRC32Table]
//  xor ecx, edi
//  inc edx; je @@end
//
//  @@end: pop edi; pop esi
//end;
//
//procedure BuildCRC32Table(const Polynomial: integer = IntCRC32Poly; const InitValue: Cardinal = 0);
//var
//  C: integer;
//  n, k: integer;
//begin
//  if PCRC32Table = nil then
//    GetMem(PCRC32Table, sizeof(PCRC32Table^));
//  for n := 0 to high(byte) do begin
//    C := n;
//    for k := 0 to (8 - 1) do
//      if odd(C) then
//        C := Polynomial xor (C shr 1)
//      else
//        C := C shr 1;
//    //CRC32Table[n] := C;
//    PCRC32Table^[n] := C;
//  end;
//  if InitValue <> 0 then
//    //CRC32Table[0] := InitValue;
//    PCRC32Table^[0] := InitValue;
//end;
//
//function GetCRC32Of(const b: byte; const initCRC32Value: Cardinal = 0): Cardinal; overload;
//begin
//  if initCRC32Value = 0 then
//    Result := Cardinal(not (initCRC32Value))
//  else
//    //Result := (initCRC32Value shr 8) xor (PCRC32Table^[b xor (initCRC32Value and Cardinal($FF))])
//    Result := (initCRC32Value shr 8) xor (CRC32Table[b xor (initCRC32Value and Cardinal($FF))])
//end;
//
//{$IFOPT R+}{$R-}{$DEFINE RANGECHECKS}{$ENDIF}
//{$IFOPT Q+}{$Q-}{$DEFINE OVERFLOWCHECKS}{$ENDIF}
//
//function GetCRC32Of(initValue: Cardinal; const Buffer: pointer; const Size: integer): Cardinal; overload;
//type
//  tpb = ^TBytePage;
//var
//  i: integer;
//begin
//  Result := initValue;
//  for i := 0 to Size - 1 do
//    Result := (Result shr 8) xor (CRC32Table[tpb(Buffer)^[i] xor (Result and $FF)]);
//end;
//
//function GetCRC32Of(const Buffer: pointer; const Size: integer; const initValue: Cardinal = 0): Cardinal; overload;
//type
//  tpb = ^TBytePage;
//var
//  i: integer;
//  //B: ^TBytePage; //^TByteSegment;
//begin
//  Result := initValue;
//  for i := 0 to Size - 1 do
//    Result := (Result shr 8) xor (CRC32Table[tpb(Buffer)^[i] xor (Result and $FF)]);
//end;
//{$IFDEF RANGECHECKS}{$R+}{$UNDEF RANGECHECKS}{$ENDIF}
//{$IFDEF OVERFLOWCHECKS}{$Q+}{$UNDEF OVERFLOWCHECKS}{$ENDIF}
//
//function GetCRC32Of_OK(const Buffer: pointer; const Size: integer; const initValue: Cardinal = 0): Cardinal; overload;
//var
//  i: integer;
//  B: ^TBytePage; //^TByteSegment;
//begin
//  B := Buffer;
//  Result := initValue;
//  if Result = 0 then Result := cardinal(-1);
//  for i := 0 to Size - 1 do
//    //Result := (Result shr 8) xor (PCRC32Table^[B^[i] xor (Result and Cardinal($FF))])
//{$IFOPT R+}{$R-}{$DEFINE RANGECHECKS}{$ENDIF}
//    Result := (Result shr 8) xor (CRC32Table[B^[i] xor (Result and Cardinal($FF))]);
//{$IFDEF RANGECHECKS}{$R+}{$UNDEF RANGECHECKS}{$ENDIF}
//  //Result := not (Result);
//end;
//
//function GetRevCRC32(const X: integer = 0; const CRC32Poly: integer = IntCRC32Poly): integer;
//// find Reversed CRC32
//// const Poly = IntCRC32Poly;
//var
//  c, i, k: integer;
//begin
//  i := 0;
//  Result := 0;
//  while Cardinal(i) < High(Cardinal) do begin
//    inc(i);
//    C := i;
//    for k := 0 to (8 - 1) do
//      if odd(C) then
//        C := CRC32Poly xor (C shr 1)
//      else
//        C := C shr 1;
//    if integer(C) = X then begin
//      Result := i;
//      break;
//    end;
//  end;
//end;
//

function fHandleOpen(const Filename: string; const OpenModes, CreationMode, Attributes: Longword): integer;
const
  GENERIC_READ = DWORD($80000000);
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
// Borrowed from SysUtils { Open Mode }
  fmOpenRead = $0000;
  fmShareDenyRead = $0030;
  fmShareDenyNone = $0040;
  fcOpenExisting = 3; //open-only, fail if not already existed
  faNormal = $00000080;
begin
  Result := fHandleOpen(Filename, fmOpenRead or fmShareDenyNone, fcOpenExisting, faNormal);
end;

function fHandleRead(Handle: integer; var Buffer; Count: integer): integer;
begin
  if not ReadFile(THandle(Handle), Buffer, Count, Longword(Result), nil) then Result := -1;
end;

type
  r64 = packed record
    lo, hi: integer;
  end;

function GetPartCRC32Of(const Filename: string; Blocks: integer = CRC32_DEFAULTBLOCKS): Cardinal; overload;
function mid(const a, b, c: word): word; overload asm //begin
    //Result := Mid(integer(a), integer(b), integer(c));
    cmp a, b; jbe @@done
      cmp a, c; jbe @@end
        mov a, c
    cmp b, a; jbe @@end
      mov a, b; jmp @@end
    @@done: cmp a, c; jae @@end
      mov a, b
    cmp a, c; jbe @@end
      mov a, c
    @@end:
  end;
const
  _1PAGE = BYTES_PER_PAGE;
  MINBLOCK = 1; //CRC32_DEFAULTBLOCKS;
  MAXBLOCK = 256;
var
  i, n: integer;
  fp, fsize: int64;
  Buf: pointer;
  h: integer;
begin
  h := fHandleOpenReadOnly(filename);
  if h = -1 then Result := Cardinal(-1)
  else begin
    GetMem(Buf, _1PAGE);
    try
      fSize := getfilesize(h, @r64(fSize).hi);
      Result := CCRC32.GetCRC32Of(@fSize, sizeof(fSize), cardinal(not fSize));
      Blocks := mid(Blocks, MINBLOCK, MAXBLOCK);
      if fSize <= int64(Blocks) * _1PAGE * 4 then
        repeat
          Application.ProcessMessages;
          n := fHandleRead(h, Buf^, _1PAGE);
          Result := CCRC32.GetCRC32Of(Buf, n, Result);
        until n = 0
      else begin

        fp := fSize - Blocks * _1PAGE;
        setfilepointer(h, fp, @r64(fp).hi, FILE_BEGIN);
        for i := 1 to Blocks do begin
          Application.ProcessMessages;
          n := fHandleRead(h, Buf^, _1PAGE);
          Result := CCRC32.GetCRC32Of(Buf, n, Result);
        end;

        setfilepointer(h, 0, nil, FILE_BEGIN);
        for i := 1 to Blocks do begin
          Application.ProcessMessages;
          n := fHandleRead(h, Buf^, _1PAGE);
          Result := CCRC32.GetCRC32Of(Buf, n, Result);
        end;

        fp := fSize div 2 - Blocks * _1PAGE;
        setfilepointer(h, fp, @r64(fp).hi, FILE_BEGIN);
        for i := 1 to Blocks * 2 do begin
          Application.ProcessMessages;
          n := fHandleRead(h, Buf^, _1PAGE);
          Result := CCRC32.GetCRC32Of(Buf, n, Result);
        end;
      end;

    finally
      FreeMem(Buf);
      CloseHandle(h);
    end;
  end;
end;

function GetCRC32Of(const Filename: string {; const Init: Cardinal = 0}): Cardinal; overload;
var
  i: integer;
  B: ^TBytePage; //^TByteSegment;
  h: integer;
begin
  h := fHandleOpenReadOnly(filename);
  Result := Cardinal(not (0)); // $FFFFFFFF;
  if integer(h) <> -1 then begin
    GetMem(B, sizeof(B^));
    try
      repeat
        application.processmessages;
        i := fHandleRead(h, B^, sizeof(B^));
        if i > 0 then
          Result := CCRC32.GetCRC32Of(B, i, Result);
      until (i = 0);
      Result := not (Result);
      // below is non-standard implementation. normally it used to be inversed
      // here added filesize as calculation (adapted from md5);
      // i := GetFileSize(h, nil);
      // Result := CCRC32.GetCRC32Of(@i, sizeof(integer), Result);
    finally
      FreeMem(B);
      CloseHandle(h);
    end;
  end;
end;

type
  T19 = 1..19; // MUST be < 255 !!!

const
  NT19 = (high(T19) - low(T19) + 1); // MUST be < 255 !!!
  NT18 = NT19 - 1;
  nins0 = char(NT18) + char(NT19 div 2) + #0;
  nins: string[NT19] = ''; //#00..#18

var
  nineth: array[T19] of int64;

function initnins: string;
var
  i: integer;
  Ch: Char;
begin
  Result := nins0; randomize;
  Ch := Char(random(NT19));
  for i := length(nins0) + 1 to NT19 do begin
    while pos(Ch, Result) > 0 do
      Ch := Char(random(NT19));
    Result := Result + Ch;
  end;
end;

function initnineth(const FileSize: int64): integer; overload;
const
  NT19BUFSIZE = 8192;
  _LO = low(nineth);
  _MID = low(nineth);
  _LAST = _MID + 1;
  _FIRST = _LAST + 1;
  _START = _FIRST + 1;
    //_ST = low(nineth) + 1 + 1 + 1;
var
  i, r: integer;
  x: int64;
  BlockSize: int64;
  midVal, LastVal: int64;
  midBlock, LastBlock: integer;
const
  _midVal: integer = NT19 div 2;
  _lastVal: integer = NT18;
begin
  fillchar(nineth, sizeof(nineth), -1);
  if FileSize <= NT19BUFSIZE * NT18 then
    Result := 1
  else begin
    BlockSize := (FileSize + NT19BUFSIZE - 1) div NT19BUFSIZE; //BlockSize;
    Result := (BlockSize + NT18) div NT19; // Block 19
  end;
  BlockSize := Result * NT19BUFSIZE;

  lastBlock := (FileSize + BlockSize - 1) div BlockSize;
  midBlock := (lastBlock + 1) div 2;

  dec(MidBlock); // 0-wise
  dec(LastBlock); // 0-wise

  lastVal := BlockSize * lastBlock; // 0-wise
  midVal := BlockSize * midBlock; //0-wise

  nineth[_MID] := midVal;
  nineth[_LAST] := lastVal;
  //nineth[_FIRST] := 0;

  if FileSize > BlockSize * 2 then begin
    nineth[_FIRST] := 0;
    for i := _START to high(nineth) do begin
      r := i - _LO + 1; // in case low(nineth) is not equal with 1 / low(nins)
      r := ord(nins[r]);
      if (r = MidBlock) then
        r := ord(nins[1])
      else if (r = LastBlock) then
        r := ord(nins[2]);
      x := Result * r * NT19BUFSIZE;
      if x < FileSize then begin
        nineth[i] := x;
      end;
    end;
  end
  else begin
    if FileSize < LastVal then nineth[_LAST] := 0;
    if FileSize < _MidVal then nineth[_MID] := 0;
  end;
end;

initialization
  nins := initnins;
end.


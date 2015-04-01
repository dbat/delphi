unit bigint;

{
  Copyright (c) 2004, aa, Inge DR. & Adrian Hafizh.
  Property of PT SOFTINDO Jakarta.
  All rights reserved.

  mailto:aa|AT|formasi|DOT|com,  http://delphi.formasi.com

  This software is free for non-commercial purposes,
  licensed under the terms of BSD License, see COPYING.

  Version: 1.0.0
  Dated: 20040204
}

interface

type

  TIntWide = (iwNone, iwByte, iwWord, iwDword, iwQWord, iw128, iw256, iw512, iw1024);

  TInt64Rec = packed record
    //i64Lo, i64Hi: integer;
    case TIntWide of
      iwByte: (bytes: array[0..7] of ShortInt);
      iwWord: (words: array[0..3] of SmallInt);
      //iwDword: (dwords: array[0..1] of LongInt);
      iwDword: (dword0, dword1: LongInt);
  end;

  TInt128Rec = packed record
    //i128Lo, i128Hi: TRecInt64;
    case TIntWide of
      iwByte: (bytes: array[0..15] of ShortInt);
      iwWord: (words: array[0..7] of SmallInt);
      //iwDword: (dwords: array[0..3] of LongInt);
      //iwQword: (qwords: array[0..1] of Int64);
      iwDword: (dword0, dword1, dword2, dword3: LongInt);
      iwQword: (qword0, qword1: Int64);
  end;

  TInt256Rec = packed record
    //i256Lo, i256Hi: TRecInt128;
    case TIntWide of
      iwByte: (bytes: array[0..31] of ShortInt);
      iwWord: (words: array[0..15] of SmallInt);
      //iwDword: (dwords: array[0..7] of LongInt);
      //iwQword: (qwords: array[0..3] of Int64);
      iwDword: (dword0, dword1, dword2, dword3, dword4, dword5, dword6, dword7: LongInt);
      iwQword: (qword0, qword1, qword2, qword3: Int64);
      iw128: (bigints: array[0..1] of TInt128Rec);
  end;

  TInt512Rec = packed record
    //i512Lo, i512Hi: TRecInt256;
    case TIntWide of
      iwByte: (bytes: array[0..63] of ShortInt);
      iwWord: (words: array[0..31] of SmallInt);
      //iwDword: (dwords: array[0..15] of LongInt);
      //iwQword: (qwords: array[0..7] of Int64);
      iwDword: (dword0, dword1, dword2, dword3, dword4, dword5, dword6, dword7,
        dword8, dword9, dwordA, dwordB, dwordC, dwordE, dwordF: LongInt);
      iwQword: (qword0, qword1, qword2, qword3, qword4, qword5, qword6, qword7: Int64);
      iw128: (bigints: array[0..3] of TInt128Rec);
      iw256: (largeints: array[0..1] of TInt256Rec);
  end;

  TInt1024Rec = packed record
    //i1024Lo, i1024Hi: TRecInt512;
    case TIntWide of
      iwByte: (bytes: array[0..127] of ShortInt);
      iwWord: (words: array[0..63] of SmallInt);
      iwDword: (dwords: array[0..31] of LongInt);
      iwQword: (qwords: array[0..15] of Int64);
      iw128: (bigints: array[0..7] of TInt128Rec);
      iw256: (largeints: array[0..3] of TInt256Rec);
      iw512: (hugeints: array[0..1] of TInt512Rec);
  end;

type
  TInt128 = class(TObject)
  private
    fData, fMulDiv: TInt128Rec;
    //fLo, fHi: Int64;
  protected
    fStatusFlags: byte; //SF-ZF-XX-AF-XX-PF-XX-CF
    procedure fNegate(I: TInt128Rec); overload;
    procedure fInverse(I: TInt128Rec); overload;
    procedure fAdd(A: TInt128Rec; const B: TInt128Rec); overload;
    procedure fAdd(A: TInt128Rec; const B: Int64); overload;
    procedure fSub(A: TInt128Rec; const B: TInt128Rec); overload;
    procedure fSub(A: TInt128Rec; const B: Int64); overload;
    procedure fCompare(const A, B: Int64); overload;
    procedure fCompare(const A, B: TInt128Rec); overload;
    //procedure fCompare(const A, B: TInt128); overload;
    //procedure fSub(A: TInt128Rec; const B: TInt128Rec); overload;
  public
    destructor Free;
    constructor Create; overload;
    constructor Create(const I: TInt128); overload;
    constructor Create(const S: string); overload;
    constructor Create(const LowPart, HighPart: Int64); overload;
    property LowPart: Int64 read fData.qword1 write fData.qword1;
    property HighPart: Int64 read fData.qword0 write fData.qword0;
    procedure Assign(const I: TInt128); overload;
    procedure Assign(const S: string); overload;
    procedure Assign(const LowPart, HighPart: Int64); overload;
    procedure Negate; overload;
    procedure Inverse; overload;
    procedure Add(const I: TInt128); overload;
    procedure Add(const I: Int64); overload;
    procedure Sub(const I: TInt128); overload;
    procedure Sub(const I: Int64); overload;
    procedure Compare(const I: TInt128);
    procedure Divide(const I: TInt128);
    procedure DivideBy10;
    procedure Modulo(const I: TInt128);
    procedure Multiply(const I: TInt128);
    function isNegative: Boolean;
    property Negative: Boolean read isNegative;
    function isCarry: Boolean;
    property Carry: Boolean read isCarry;
  end;

implementation

type
  x64 = TInt64Rec;
  x128 = TInt128Rec;
  x256 = TInt256Rec;
  x512 = TInt512Rec;
  x1024 = TInt1024Rec;

const
  sfCarry = $1;
  sfParity = $4;
  sfAuxilary = $10;
  sfZero = $40;
  sfSign = $80;

const
  BITWIDE64 = 64;
  BITWIDE128 = 128;
  BITWIDE256 = 256;
  BITWIDE512 = 512;
  BITWIDE1024 = 1024;

function TInt128.isNegative: Boolean;
begin
  Result := fStatusFlags and sfSign > 0;
end;

function TInt128.isCarry: Boolean;
begin
  Result := fStatusFlags and sfCarry > 0;
end;

destructor TInt128.Free;
begin
  inherited Destroy;
end;

constructor TInt128.Create;
begin
  inherited;
end;

constructor TInt128.Create(const I: TInt128);
begin
  inherited Create;
  Assign(I);
end;

constructor TInt128.Create(const S: string);
begin
  inherited Create;
end;

constructor TInt128.Create(const LowPart, HighPart: Int64);
begin
  Assign(LowPart, HighPart);
end;

procedure TInt128.Assign(const I: TInt128);
begin
  Assign(I.LowPart, I.Highpart);
  fStatusFlags := I.fStatusFlags;
end;

procedure TInt128.Assign(const S: string);
begin
end;

procedure TInt128.Assign(const LowPart, HighPart: Int64); register; assembler;
// EAX = Self; edx = Lowpart[hi]; ecx = HighPart[hi]
asm
  //mov eax, Self          //not needed if asm without begin-end procedure
  push esi; push edi

  mov esi, LowPart.x64.dword0
  mov edi, LowPart.x64.dword1
  mov Self.fData.dword0, esi
  mov Self.fData.dword1, edi

  mov esi, HighPart.x64.dword0
  mov edi, HighPart.x64.dword1
  mov Self.fData.dword2, esi
  mov Self.fData.dword3, edi

  pop edi; pop esi

  push edx; mov edx, Self  // store eax ( = Self) before destroyed by LAHF
  lahf
  mov edx.fStatusFlags, ah
  mov eax, edx
  pop edx
end;

procedure TInt128.fNegate(I: TInt128Rec);
asm
  push edx    // I
  push eax    // Self

  mov eax, I.x128.dword0
  dec eax
  mov I.x128.dword0, eax

  mov eax, I.x128.dword1
  sbb eax, 0
  mov I.x128.dword1, eax

  mov eax, I.x128.dword2
  sbb eax, 0
  mov I.x128.dword2, eax

  mov eax, I.x128.dword3
  sbb eax, 0
  mov I.x128.dword3, eax

  pop edx     // stored eax ( = Self)
  lahf
  mov edx.fStatusFlags, ah
  mov eax, edx
  pop edx
end;

procedure TInt128.fInverse(I: TInt128Rec);
asm
  push edx    // I
  push eax    // Self

  mov eax, I.x128.dword0
  not eax
  mov I.x128.dword0, eax

  mov eax, I.x128.dword1
  not eax
  mov I.x128.dword1, eax

  mov eax, I.x128.dword2
  not eax
  mov I.x128.dword2, eax

  mov eax, I.x128.dword3
  not eax
  mov I.x128.dword3, eax

  pop edx     // stored eax ( = Self)
  lahf
  mov edx.fStatusFlags, ah
  mov eax, edx
  pop edx
end;

procedure TInt128.fAdd(A: TInt128Rec; const B: TInt128Rec);
asm
  push esi; push edi
  // Self = eax, A = edx, B = ecx, DO NOT disturb!
  mov esi, A.x128.dword0
  mov edi, B.x128.dword0
  add esi, edi
  mov A.x128.dword0, esi

  mov esi, A.x128.dword1
  mov edi, B.x128.dword1
  adc esi, edi
  mov A.x128.dword1, esi

  mov esi, A.x128.dword2
  mov edi, B.x128.dword2
  adc esi, edi
  mov A.x128.dword2, esi

  mov esi, A.x128.dword3
  mov edi, B.x128.dword3
  adc esi, edi
  mov A.x128.dword3, esi

  pop edi; pop esi

  // NO status reported
  // push edx; mov edx, Self
  // LAHF
  // mov edx.fStatusFlags, ah
  // mov eax, edx
  // pop edx
end;

procedure TInt128.fAdd(A: TInt128Rec; const B: Int64);
asm
  push esi; push edi
  // Self = eax, A = edx, B = ecx, DO NOT disturb!
  mov esi, A.x128.dword0
  mov edi, B.x64.dword0
  add esi, edi
  mov A.x128.dword0, esi

  mov esi, A.x128.dword1
  mov edi, B.x64.dword1
  adc esi, edi
  mov A.x128.dword1, esi

  mov esi, A.x128.dword2
  adc esi, 0
  mov A.x128.dword2, esi

  mov esi, A.x128.dword3
  adc esi, 0
  mov A.x128.dword3, esi

  pop edi; pop esi

  // NO status reported
  // push edx; mov edx, Self
  // LAHF
  // mov edx.fStatusFlags, ah
  // mov eax, edx
  // pop edx
end;

procedure TInt128.fSub(A: TInt128Rec; const B: TInt128Rec);
asm
  push esi; push edi
  // Self = eax, A = edx, B = ecx, DO NOT disturb!
  mov esi, A.x128.dword0
  mov edi, B.x128.dword0
  sub esi, edi
  mov A.x128.dword0, esi

  mov esi, A.x128.dword1
  mov edi, B.x128.dword1
  sbb esi, edi
  mov A.x128.dword1, esi

  mov esi, A.x128.dword2
  mov edi, B.x128.dword2
  sbb esi, edi
  mov A.x128.dword2, esi

  mov esi, A.x128.dword3
  mov edi, B.x128.dword3
  sbb esi, edi
  mov A.x128.dword3, esi

  pop edi; pop esi

  // NO status reported
  // push edx
  // mov edx, Self; LAHF
  // mov edx.fStatusFlags, ah
  // mov eax, edx
  // pop edx
end;

procedure TInt128.fSub(A: TInt128Rec; const B: Int64);
asm
  push esi; push edi
  // Self = eax, A = edx, B = ecx, DO NOT disturb!
  mov esi, A.x128.dword0
  mov edi, B.x64.dword0
  sub esi, edi
  mov A.x128.dword0, esi

  mov esi, A.x128.dword1
  mov edi, B.x64.dword1
  sbb esi, edi
  mov A.x128.dword1, esi

  mov esi, A.x128.dword2
  sbb esi, 0
  mov A.x128.dword2, esi

  mov esi, A.x128.dword3
  sbb esi, 0
  mov A.x128.dword3, esi

  pop edi; pop esi

  // NO status reported
  // push edx; mov edx, Self
  // LAHF
  // mov edx.fStatusFlags, ah
  // mov eax, edx
  // pop edx
end;

// =================================================================

procedure TInt128.Negate;
asm
  //dec dword ptr eax.fData.dwords[0]
  //sbb dword ptr eax.fData.dwords[1], 0
  //sbb dword ptr eax.fData.dwords[2], 0
  //sbb dword ptr eax.fData.dwords[3], 0

  push edx
  mov edx, Self.fData.dword0
  dec edx
  mov Self.fData.dword0, edx

  mov edx, Self.fData.dword1
  sbb edx, 0
  mov Self.fData.dword1, edx

  mov edx, Self.fData.dword2
  sbb edx, 0
  mov Self.fData.dword2, edx

  mov edx, Self.fData.dword3
  sbb edx, 0
  mov Self.fData.dword3, edx

  mov edx, Self     // store eax ( = Self) before destroyed by LAHF
  lahf
  mov edx.fStatusFlags, ah
  mov eax, edx
  pop edx
end;

procedure TInt128.Inverse;
asm
  push edx
  mov edx, Self.fData.dword0
  not edx
  mov Self.fData.dword0, edx

  mov edx, Self.fData.dword1
  not edx
  mov Self.fData.dword1, edx

  mov edx, Self.fData.dword2
  not edx
  mov Self.fData.dword2, edx

  mov edx, Self.fData.dword3
  not edx
  mov Self.fData.dword3, edx

  mov edx, Self     // store eax ( = Self) before destroyed by LAHF
  lahf
  mov edx.fStatusFlags, ah
  mov eax, edx
  pop edx
end;

procedure TInt128.Add(const I: TInt128);
// eax = Self, ecx = I, DONOT disturb eax and ecx!
asm
  //mov ecx, I     //not needed if asm without begin-end procedure
  //mov eax, Self  //not needed if asm without begin-end procedure

  //mov ecx, dword ptr [ecx.fLo]
  //mov ebx, dword ptr [ecx.fLo +4]
  //add dword ptr eax.fLo, ecx
  //adc dword ptr eax.fLo+4, ebx
  //mov ecx, dword ptr [ecx.fHi]
  //mov ebx, dword ptr [ecx.fHi +4]
  //adc dword ptr eax.fHi, ecx
  //adc dword ptr eax.fHi+4, ebx

  push esi; push edi
  // Self = eax, I = edx, DO NOT disturb!
  mov esi, Self.fData.dword0
  mov edi, I.fData.dword0
  add esi, edi
  mov Self.fData.dword0, esi

  mov esi, Self.fData.dword1
  mov edi, I.fData.dword1
  adc esi, edi
  mov Self.fData.dword1, esi

  mov esi, Self.fData.dword2
  mov edi, I.fData.dword2
  adc esi, edi
  mov Self.fData.dword2, esi

  mov esi, Self.fData.dword3
  mov edi, I.fData.dword3
  adc esi, edi
  mov Self.fData.dword3, esi

  pop edi; pop esi

  push edx; mov edx, Self  // store eax ( = Self) before destroyed by LAHF
  lahf
  mov edx.fStatusFlags, ah
  mov eax, edx
  pop edx
end;

procedure TInt128.Add(const I: Int64);
asm
  //mov ecx, dword ptr I
  //add dword ptr eax.fLo, ecx
  //mov ecx, dword ptr I+4
  //adc dword ptr eax.fLo+4, ecx
  //adc dword ptr eax.fHi, 0
  //adc dword ptr eax.fHi, 0

  push esi; push edi
  // Self = eax, I = edx, DO NOT disturb!
  mov esi, Self.fData.dword0
  mov edi, I.x64.dword0
  add esi, edi
  mov Self.fData.dword0, esi

  mov esi, Self.fData.dword1
  mov edi, I.x64.dword1
  adc esi, edi
  mov Self.fData.dword1, esi

  mov esi, Self.fData.dword2
  adc esi, 0
  mov Self.fData.dword2, esi

  mov esi, Self.fData.dword3
  adc esi, 0
  mov Self.fData.dword3, esi

  pop edi; pop esi

  push edx; mov edx, Self  // store eax ( = Self) before destroyed by LAHF
  lahf
  mov edx.fStatusFlags, ah
  mov eax, edx
  pop edx
end;

procedure TInt128.Sub(const I: TInt128);
asm
  //mov ecx, I     //not needed if asm without begin-end procedure
  //mov eax, Self  //not needed if asm without begin-end procedure

  //mov ecx, dword ptr [ecx.fLo]
  //mov ebx, dword ptr [ecx.fLo +4]
  //sub dword ptr eax.fLo, ecx
  //sbb dword ptr eax.fLo+4, ebx
  //mov ecx, dword ptr [ecx.fHi]
  //mov ebx, dword ptr [ecx.fHi +4]
  //sbb dword ptr eax.fHi, ecx
  //sbb dword ptr eax.fHi+4, ebx

  push esi; push edi
  // Self = eax, I = edx, DO NOT disturb!
  mov esi, Self.fData.dword0
  mov edi, I.fData.dword0
  sub esi, edi
  mov Self.fData.dword0, esi

  mov esi, Self.fData.dword1
  mov edi, I.fData.dword1
  sbb esi, edi
  mov Self.fData.dword1, esi

  mov esi, Self.fData.dword2
  mov edi, I.fData.dword2
  sbb esi, edi
  mov Self.fData.dword2, esi

  mov esi, Self.fData.dword3
  mov edi, I.fData.dword3
  sbb esi, edi
  mov Self.fData.dword3, esi

  pop edi; pop esi

  push edx
  mov edx, Self  // store eax ( = Self) before destroyed by LAHF
  lahf
  mov edx.fStatusFlags, ah
  mov eax, edx
  pop edx
end;

procedure TInt128.Sub(const I: Int64);
asm
  //mov ecx, I     //not needed if asm without begin-end procedure
  //mov eax, Self  //not needed if asm without begin-end procedure

  //mov ecx, dword ptr I
  //sub dword ptr eax.fLo, ecx
  //mov ecx, dword ptr I+4
  //sbb dword ptr eax.fLo+4, ecx
  //sbb dword ptr eax.fHi, 0
  //sbb dword ptr eax.fHi+4, 0

  push esi; push edi
  // Self = eax, I = edx, DO NOT disturb!
  mov esi, Self.fData.dword0
  mov edi, I.x64.dword0
  sub esi, edi
  mov Self.fData.dword0, esi

  mov esi, Self.fData.dword1
  mov edi, I.x64.dword1
  sbb esi, edi
  mov Self.fData.dword1, esi

  mov esi, Self.fData.dword2
  sbb esi, 0
  mov Self.fData.dword2, esi

  mov esi, Self.fData.dword3
  sbb esi, 0
  mov Self.fData.dword3, esi

  pop edi; pop esi

  push edx; mov edx, Self  // store eax ( = Self) before destroyed by LAHF
  lahf
  mov edx.fStatusFlags, ah
  mov eax, edx
  pop edx
end;

procedure TInt128.Divide(const I: TInt128);
// edi:esi:ebx:ebp
asm
  push esi; push edi; push ebx
  push ebp

  mov ebx, I
  mov ebp, fData

  mov ecx, BITWIDE128

  push edx; push eax

  mov esi, I.x128.dword0
  mov Self.fMulDiv.x128.dword0, esi
  mov esi, I.x128.dword1
  mov Self.fMulDiv.x128.dword1, esi
  mov esi, I.x128.dword2
  mov Self.fMulDiv.x128.dword2, esi
  mov esi, I.x128.dword3
  mov Self.fMulDiv.x128.dword3, esi

  or esi, esi
  @@FullOp:
  or esi, esi    // check A.Hi
  jns @@PosOp    // A.Hi positive, goto @PosOp

  neg edx        // change negative sign sequence
  neg eax        // make abs (positivize)
  sbb edx, 0     //

  or edi, 1      // set divisor sign

  @@PosOp:

  shl Self.fMulDiv.x128.dword0, 1
  rcl Self.fMulDiv.x128.dword1, 1
  rcl Self.fMulDiv.x128.dword2, 1
  rcl Self.fMulDiv.x128.dword3, 1
  rcl Self.fData.x128.dword0, 1
  rcl Self.fData.x128.dword1, 1
  rcl Self.fData.x128.dword2, 1
  rcl Self.fData.x128.dword3, 1

  call Compare
  jae @@substract


  @@substract:

  mov eax, ebx.x128.dword0
  mov edx, ebx.x128.dword1
  mov esi, ebx.x128.dword2
  mov edi, ebx.x128.dword3

  mov ebx, I.x128.dword0
  mov Self.fMulDiv.x128.dword0, ebx
  mov ebx, I.x128.dword1
  mov Self.fMulDiv.x128.dword1, ebx
  mov ebx, I.x128.dword2
  mov Self.fMulDiv.x128.dword2, ebx
  mov ebx, I.x128.dword3
  mov Self.fMulDiv.x128.dword3, ebx

  pop eax; pop edx

  pop ebp
  pop ebx; pop edi; pop esi
end;

procedure TInt128.DivideBy10;
asm
  push ecx; push ebx
    mov ecx, BITWIDE128

  @@single:
    or ecx, ecx
    jz @@divdone

  @@double:
    or ecx, ecx
    jz @@divdone

  @@triple:
    test ecx, 0010b
    jz @@single
    test ecx, 0001b
    jz @@double

  @@quadruple:
    cmp ecx, 4
    jb @@triple


  @@divdone:

  pop ebx; pop ecx
end;

procedure TInt128.Modulo(const I: TInt128);
begin
end;

procedure TInt128.Multiply(const I: TInt128);
begin
end;

procedure TInt128.fCompare(const A, B: Int64);
asm

end;

procedure TInt128.fCompare(const A, B: TInt128Rec);
asm
  push esi; push edi; push ebx
  mov esi, A.x128.dword3
  mov edi, B.x128.dword3
  xor ebx, ebx
  or esi, esi; jns @@1
  mov bl, 1     // esi negative
  @@1:
  or edi, edi; jns @@2
  mov bh, 1     // edi negative
  @@2:
  xor bl, bh

  sub esi, edi
  jnz @@done

  mov esi, A.x128.dword2
  mov edi, B.x128.dword2
  sub esi, edi
  jnz @@done

  mov esi, A.x128.dword1
  mov edi, B.x128.dword1
  sub esi, edi
  jnz @@done

  mov esi, A.x128.dword0
  mov edi, B.x128.dword0
  sub esi, edi

  @@done:
    test bl, 1; jz @@end
    cmc
  @@end:
  pop ebx; pop esi; pop edi
  mov edx, Self     // store eax ( = Self) before destroyed by LAHF
  lahf
  mov edx.fStatusFlags, ah
  mov eax, edx
  pop edx
end;

procedure TInt128.Compare(const I: TInt128);
asm
  push esi; push edi; push ebx
  mov esi, Self.fData.x128.dword3
  mov edi, I.fData.dword3
  xor ebx, ebx
  or esi, esi; jns @@1
  mov bl, 1     // esi negative
  @@1:
  or edi, edi; jns @@2
  mov bh, 1     // edi negative
  @@2:
  xor bl, bh

  sub esi, edi
  jnz @@done

  mov esi, Self.fData.dword2
  mov edi, I.fData.dword2
  sub esi, edi
  jnz @@done

  mov esi, Self.fData.dword1
  mov edi, I.fData.dword1
  sub esi, edi
  jnz @@done

  mov esi, Self.fData.dword0
  mov edi, I.fData.dword0
  sub esi, edi

  @@done:
    test bl, 1; jz @@end
    cmc
  @@end:
  pop ebx; pop esi; pop edi
  mov edx, Self     // store eax ( = Self) before destroyed by LAHF
  lahf
  mov edx.fStatusFlags, ah
  mov eax, edx
  pop edx
end;

end.


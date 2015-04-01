unit APrime;
interface
type
  TDynCardinalArray = array of Cardinal{int64};

//function IsPrimeFactor(const F, N: Cardinal): Boolean;
//function PrimeFactors(N: Cardinal): TDynCardinalArray;
function IsPrimeTD(const N: Cardinal{int64}): Boolean;
function IsPrimeRM(const N: Cardinal): Boolean;
function IsPrimeFactor(const F, N: Cardinal{int64}): Boolean;
function PrimeFactors(N: Cardinal{int64}): TDynCardinalArray;

implementation
uses MinMaxMid;
type
  TBits = class(TObject)
  private
    FSize: Integer;
    FBits: Pointer;
    procedure SetSize(Value: Integer);
    procedure SetBit(Index: Integer; Value: Boolean);
    function GetBit(Index: Integer): Boolean;
  public
    destructor Destroy; override;
    function OpenBit: Integer;
    property Bits[Index: Integer]: Boolean read GetBit write SetBit; default;
    property Size: Integer read FSize write SetSize;
  end;

  T__ASet = class(TObject)
  protected
    function GetBit(const Idx: Integer): Boolean; virtual; abstract;
    procedure SetBit(const Idx: Integer; const Value: Boolean); virtual; abstract;
    procedure Clear; virtual; abstract;
    procedure Invert; virtual; abstract;
    function GetRange(const Low, High: Integer; const Value: Boolean): Boolean; virtual; abstract;
    procedure SetRange(const Low, High: Integer; const Value: Boolean); virtual; abstract;
  end;

type
  T__FlatSet = class(T__ASet)
  private
    FBits: TBits;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear; override;
    procedure Invert; override;
    procedure SetRange(const Low, High: Integer; const Value: Boolean); override;
    function GetBit(const Idx: Integer): Boolean; override;
    function GetRange(const Low, High: Integer; const Value: Boolean): Boolean; override;
    procedure SetBit(const Idx: Integer; const Value: Boolean); override;
  end;

const
  BitsPerInt = SizeOf(Integer) * 8;

type
  TBitEnum = 0..BitsPerInt - 1;
  TBitSet = set of TBitEnum;
  PBitArray = ^TBitArray;
  TBitArray = array[0..4096] of TBitSet;

destructor TBits.Destroy;
begin
  SetSize(0);
  inherited Destroy;
end;

procedure TBits.SetSize(Value: Integer);
var
  NewMem: Pointer;
  NewMemSize: Integer;
  OldMemSize: Integer;
begin
  if Value <> Size then begin
    NewMemSize := ((Value + BitsPerInt - 1) div BitsPerInt) * SizeOf(Integer);
    OldMemSize := ((Size + BitsPerInt - 1) div BitsPerInt) * SizeOf(Integer);
    if NewMemSize <> OldMemSize then begin
      //NewMem := nil;
      if NewMemSize <> 0 then begin
        GetMem(NewMem, NewMemSize);
        FillChar(NewMem^, NewMemSize, 0);
      end
      else
        NewMem := nil;
      if OldMemSize <> 0 then begin
        if NewMem <> nil then
          Move(FBits^, NewMem^, Minof(OldMemSize, NewMemSize));
        FreeMem(FBits, OldMemSize);
      end;
      FBits := NewMem;
    end;
    FSize := Value;
  end;
end;

procedure TBits.SetBit(Index: Integer; Value: Boolean);
begin
  if Value then
    Include(PBitArray(FBits)^[Index div BitsPerInt], Index mod BitsPerInt)
  else
    Exclude(PBitArray(FBits)^[Index div BitsPerInt], Index mod BitsPerInt);
end;

function TBits.GetBit(Index: Integer): Boolean;
begin
  Result := Index mod BitsPerInt in PBitArray(FBits)^[Index div BitsPerInt];
end;

function TBits.OpenBit: Integer;
var
  I: Integer;
  B: TBitSet;
  J: TBitEnum;
  E: Integer;
begin
  E := (Size + BitsPerInt - 1) div BitsPerInt - 1;
  for I := 0 to E do
    if PBitArray(FBits)^[I] <> [0..BitsPerInt - 1] then begin
      B := PBitArray(FBits)^[I];
      for J := Low(J) to High(J) do
      begin
        if not (J in B) then begin
          Result := I * BitsPerInt + J;
          if Result >= Size then
            Result := Size;
          Exit;
        end;
      end;
    end;
  Result := Size;
end;

constructor T__FlatSet.Create;
begin
  inherited Create;
  FBits := TBits.Create;
end;

//--------------------------------------------------------------------------------------------------
destructor T__FlatSet.Destroy;
begin
  FBits.Free;
  FBits := nil;
  inherited Destroy;
end;

//--------------------------------------------------------------------------------------------------

procedure T__FlatSet.Clear;
begin
  FBits.Size := 0;
end;

//--------------------------------------------------------------------------------------------------

procedure T__FlatSet.Invert;
var
  I: Integer;
begin
  for I := 0 to FBits.Size - 1 do
    FBits[I] := not FBits[I];
end;

//--------------------------------------------------------------------------------------------------

procedure T__FlatSet.SetRange(const Low, High: Integer; const Value: Boolean);
var
  I: Integer;
begin
  for I := High downto Low do
    FBits[I] := Value;
end;

//--------------------------------------------------------------------------------------------------

function T__FlatSet.GetBit(const Idx: Integer): Boolean;
begin
  Result := FBits[Idx];
end;

//--------------------------------------------------------------------------------------------------

function T__FlatSet.GetRange(const Low, High: Integer; const Value: Boolean): Boolean;
var
  I: Integer;
begin
  if not Value and (High >= FBits.Size) then begin
    Result := FALSE;
    Exit;
  end;
  for I := Low to MinOf(High, FBits.Size - 1) do
    if FBits[I] <> Value then begin
      Result := FALSE;
      Exit;
    end;
  Result := TRUE;
end;

//--------------------------------------------------------------------------------------------------
procedure T__FlatSet.SetBit(const Idx: Integer; const Value: Boolean);
begin
  FBits[Idx] := Value;
end;

//--------------------------------------------------------------------------------------------------
const
  PrimeCacheLimit = 65537;              // 4K lookup table. Note: Sqr(65537) > MaxLongint

var
  PrimeSet: T__FlatSet = nil;
//--------------------------------------------------------------------------------------------------

procedure InitPrimeSet;
var
  I, J, MaxI, MaxJ: Cardinal{int64};
begin
  PrimeSet := T__FlatSet.Create;
  PrimeSet.SetRange(1, PrimeCacheLimit div 2, TRUE);
  PrimeSet.SetBit(0, FALSE);            // 1 is no prime
  MaxI := System.Trunc(System.Sqrt(PrimeCacheLimit));
  I := 3;
  repeat
    if PrimeSet.GetBit(I div 2) then begin
      MaxJ := PrimeCacheLimit div I;
      J := 3;
      repeat
        PrimeSet.SetBit((I * J) div 2, FALSE);
        inc(J, 2);
      until J > MaxJ;
    end;
    inc(I, 2);
  until I > MaxI;
end;

//--------------------------------------------------------------------------------------------------
//function IsPrimeTD(N: Cardinal): Boolean;
function IsPrimeTD(const N: Cardinal{int64}): Boolean;
{ Trial Division Algorithm }
var
  I, MAX: Cardinal;
  R: Extended;
begin
  if N = 2 then begin
    Result := TRUE;
    exit;
  end;
  if (N and 1) = 0 then                 //Zero or even
  begin
    Result := FALSE;
    exit;
  end;
  if PrimeSet = nil then                // initialize look-up table
    InitPrimeSet;
  if N <= PrimeCacheLimit then          // do look-up
  begin
    Result := PrimeSet.GetBit(N div 2)
  end
  else
  begin                                 // calculate
    R := N;
    MAX := Round(System.Sqrt(R));
    if MAX > PrimeCacheLimit then begin
      //raise exception.Create('unexpected value');//E__MathError.CreateResRec(@RsUnexpectedValue);
      Result := FALSE;
      Exit;
    end;
    I := 1;
    repeat
      inc(I, 2);
      if PrimeSet.GetBit(I div 2) then begin
        if N mod I = 0 then begin
          Result := FALSE;
          Exit;
        end;
      end;
    until I >= MAX;
    Result := TRUE;
  end;
end;

//--------------------------------------------------------------------------------------------------
{ Rabin-Miller Strong Primality Test }
function IsPrimeRM(const N: Cardinal): Boolean;
asm
       TEST  EAX,1            // Odd(N) ??
       JNZ   @@1
       CMP   EAX,2            // N == 2 ??
       SETE  AL
       RET
@@1:   CMP   EAX,73
       JBE   @@C
       PUSH  ESI
       PUSH  EDI
       PUSH  EBX
       PUSH  EBP
       PUSH  EAX              // save N as Param for @@5
       LEA   EBP,[EAX - 1]    // M == N -1, Exponent
       MOV   ECX,32           // calc remaining Bits of M and shift M'
       MOV   ESI,EBP
@@2:   DEC   ECX
       SHL   ESI,1
       JNC   @@2
       PUSH  ECX              // save Bits as Param for @@5
       PUSH  ESI              // save M' as Param for @@5
       CMP   EAX,08A8D7Fh     // N >= 9080191 ??
       JAE   @@3
// now if (N < 9080191) and SPP(31, N) and SPP(73, N) then N is prime
       MOV   EAX,31
       CALL  @@5
       JC    @@4
       MOV   EAX,73
       PUSH  OFFSET @@4
       JMP   @@5
// now if (N < 4759123141) and SPP(2, N) and SPP(7, N) and SPP(61, N) then N is prime
@@3:   MOV   EAX,2
       CALL  @@5
       JC    @@4
       MOV   EAX,7
       CALL  @@5
       JC    @@4
       MOV   EAX,61
       CALL  @@5
@@4:   SETNC AL
       ADD   ESP,4 * 3
       POP   EBP
       POP   EBX
       POP   EDI
       POP   ESI
       RET
// do a Strong Pseudo Prime Test
@@5:   MOV   EBX,[ESP + 12]   // N on stack
       MOV   ECX,[ESP +  8]   // remaining Bits
       MOV   ESI,[ESP +  4]   // M'
       MOV   EDI,EAX          // T = b, temp. Base
@@6:   DEC   ECX
       MUL   EAX
       DIV   EBX
       MOV   EAX,EDX
       SHL   ESI,1
       JNC   @@7
       MUL   EDI
       DIV   EBX
       AND   ESI,ESI
       MOV   EAX,EDX
@@7:   JNZ   @@6
       CMP   EAX,1            // b^((N -1)(2^s)) mod N ==  1 mod N ??
       JE    @@A
@@8:   CMP   EAX,EBP          // b^((N -1)(2^s)) mod N == -1 mod N ??
       JE    @@A
       DEC   ECX              // second part to 2^s
       JNG   @@9
       MUL   EAX
       DIV   EBX
       CMP   EDX,1
       MOV   EAX,EDX
       JNE   @@8
@@9:   STC
@@A:   RET
@@B:   DB    3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73
@@C:   MOV   EDX,OFFSET @@B
       MOV   ECX,19
@@D:   CMP   AL,[EDX + ECX]
       JE    @@E
       DEC   ECX
       JNL   @@D
@@E:   SETE  AL
end;

//function IsPrimeTD(N: Cardinal): Boolean; forward;
var
//  IsPrime: function(N: Cardinal): Boolean = IsPrimeTD;
  IsPrime: function(const N: Cardinal{int64}): Boolean = IsPrimeTD;

//--------------------------------------------------------------------------------------------------
//function PrimeFactors(N: Cardinal): TDynCardinalArray;
function PrimeFactors(N: Cardinal{int64}): TDynCardinalArray;
var
  I, L, Max: Cardinal;
  R: Extended;
begin
  SetLength(Result, 0);
  if N <= 1 then
    Exit
  else
  begin
    if PrimeSet = nil then
      InitPrimeSet;
    L := 0;
    R := N;
    R := System.Sqrt(R);
    Max := Round(R);                    // only one factor can be > sqrt (N)
    if N mod 2 = 0 then                 // test even at first
    begin                               // 2 is a prime factor
      Inc(L);
      SetLength(Result, L);
      Result[L - 1] := 2;
      repeat
        N := N div 2;
        if N = 1 then                   // no more factors
          Exit;
      until N mod 2 <> 0;
    end;
    I := 3;                             // test all odd factors
    repeat
      if (N mod I = 0) and IsPrime(I) then begin                             // I is a prime factor
        Inc(L);
        SetLength(Result, L);
        Result[L - 1] := I;
        repeat
          N := N div I;
          if N = 1 then                 // no more factors
            Exit;
        until N mod I <> 0;
      end;
      inc(I, 2);
    until I > Max;
    Inc(L);                             // final factor (> sqrt(N))
    SetLength(Result, L);
    Result[L - 1] := N;
  end;
end;

//--------------------------------------------------------------------------------------------------
//function IsPrimeFactor(const F, N: Cardinal): Boolean;
function IsPrimeFactor(const F, N: Cardinal{int64}): Boolean;
begin
  Result := (N mod F = 0) and IsPrime(F);
end;

{
//--------------------------------------------------------------------------------------------------
function Euclids(const X, Y: Cardinal): Cardinal; assembler;
// Euclid's algorithm
asm
        JMP     @01      // We start with EAX <- X, EDX <- Y, and check to see if Y=0
@00:
        MOV     ECX, EDX // ECX <- EDX prepare for division
        XOR     EDX, EDX // clear EDX for Division
        DIV     ECX      // EAX <- EDX:EAX div ECX, EDX <- EDX:EAX mod ECX
        MOV     EAX, ECX // EAX <- ECX, and repeat if EDX <> 0
@01:
        AND     EDX, EDX // test to see if EDX is zero, without changing EDX
        JNZ     @00      // when EDX is zero EAX has the Result
end;

//--------------------------------------------------------------------------------------------------
function IsRelativePrime(const X, Y: Cardinal): Boolean;
begin
  Result := Euclids(X, Y) = 1;
end;

//--------------------------------------------------------------------------------------------------
type
  TPrimalityTestMethod = (ptTrialDivision, ptRabinMiller);

procedure SetPrimalityTest(const Method: TPrimalityTestMethod);
begin
  case Method of
    ptTrialDivision: IsPrime := IsPrimeTD;
    ptRabinMiller: IsPrime := IsPrimeRM;
  end;
end;
}

end.


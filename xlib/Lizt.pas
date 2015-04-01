unit lizt;

interface

const
  MaxListSize = high(Cardinal) shr 3;

{ TLizt class }

type
  error = class(TObject)
  private
    fMessage: string;
    fHelpContext: integer;
  public
    constructor Create(const msg: string);
    constructor CreateFmt(const msg: string; const args: array of const);
    constructor CreateRes(Ident: integer); overload;
    constructor CreateRes(ResStringRec: PResStringRec); overload;
    constructor CreateResFmt(Ident: integer; const args: array of const); overload;
    constructor CreateResFmt(ResStringRec: PResStringRec; const args: array of const); overload;
    constructor CreateHelp(const msg: string; AHelpContext: integer);
    constructor CreateFmtHelp(const msg: string; const args: array of const; AHelpContext: integer);
    constructor CreateResHelp(Ident: integer; AHelpContext: integer); overload;
    constructor CreateResHelp(ResStringRec: PResStringRec; AHelpContext: integer); overload;
    constructor CreateResFmtHelp(ResStringRec: PResStringRec; const args: array of const; AHelpContext: integer); overload;
    constructor CreateResFmtHelp(Ident: integer; const args: array of const; AHelpContext: integer); overload;
    property HelpContext: integer read fHelpContext write fHelpContext;
    property message: string read fMessage write fMessage;
  end;

  errorClass = class of error;

  eListError = class(error);
  eConvertError = class(error);
  eBitsError = class(error);
  eOutOfMemory = class(error);
  eInvalidPointer = class(error);
  EAbstractError = class(error);

  eInOutError = class(error)
  public
    ErrorCode: Integer;
  end;

  EExternal = class(error)
  public
    ExceptionRecord: pointer; //PExceptionRecord;
  end;


    {(EClass:}eDivByZero = class(error); // EIdent: SDivByZero),
    {(EClass:}eRangeError = class(error); // EIdent: SRangeError),
    {(EClass:}eIntOverflow = class(error); // EIdent: SIntOverflow),
    {(EClass:}eInvalidOp = class(error); // EIdent: SInvalidOp),
    {(EClass:}eZeroDivide = class(error); // EIdent: SZeroDivide),
    {(EClass:}eOverflow = class(error); // EIdent: SOverflow),
    {(EClass:}eUnderflow = class(error); // EIdent: SUnderflow),
    {(EClass:}eInvalidCast = class(error); // EIdent: SInvalidCast),
    {(EClass:}eAccessViolation = class(error); // EIdent: SAccessViolation),
    {(EClass:}ePrivilege = class(error); // EIdent: SPrivilege),
    {(EClass:}eControlC = class(error); // EIdent: SControlC),
    {(EClass:}eStackOverflow = class(error); // EIdent: SStackOverflow),
    {(EClass:}eVariantError = class(error); // EIdent: SInvalidVarCast),
    //{(EClass:} EVariantError = class(error);// EIdent: SInvalidVarOp),
    //{(EClass:} EVariantError = class(error);// EIdent: SDispatchError),
    //{(EClass:} EVariantError = class(error);// EIdent: SVarArrayCreate),
    //{(EClass:} EVariantError = class(error);// EIdent: SVarNotArray),
    //{(EClass:} EVariantError = class(error);// EIdent: SVarArrayBounds),
    {(EClass:}eAssertionFailed = class(error); // EIdent: SAssertionFailed),
    {(EClass:}eExternalException = class(error); // EIdent: SExternalException),
    {(EClass:}eIntfCastError = class(error); // EIdent: SIntfCastError),
    {(EClass:}eSafecallException = class(error); // EIdent: SSafecallException));

{ TBits class }

  TBits = class
  private
    fSize: integer;
    fBits: Pointer;
    procedure error;
    procedure setSize(Value: integer);
    procedure setBit(Index: integer; Value: Boolean);
    function getBit(Index: integer): Boolean;
  public
    destructor Destroy; override;
    function OpenBit: integer;
    property Bits[Index: integer]: Boolean read getBit write setBit; default;
    property Size: integer read fSize write setSize;
  end;

{ TLizt class}
  TLizt = class;

  PPointerList = ^TPointerList;
  TPointerList = array[0..MaxListSize - 1] of Pointer;
  TLiztSortCompare = function(item1, item2: Pointer): integer;
  TLiztNotification = (lnAdded, lnExtracted, lnDeleted);

  TLizt = class(TObject)
  private
    fList: PPointerList;
    fCount: integer;
    fCapacity: integer;
  protected
    function get(Index: integer): Pointer;
    procedure Grow; virtual;
    procedure put(Index: integer; item: Pointer);
    procedure notify(ptr: Pointer; Action: TLiztNotification); virtual;
    procedure setCapacity(NewCapacity: integer);
    procedure setCount(NewCount: integer);
  public
    destructor Destroy; override;
    function add(item: Pointer): integer;
    procedure Clear; virtual;
    procedure delete(Index: integer);
    class procedure error(const msg: string; Data: integer); overload; virtual;
    class procedure error(msg: PResStringRec; Data: integer); overload;
    procedure exchange(Index1, Index2: integer);
    function expand: TLizt;
    function extract(item: Pointer): Pointer;
    function first: Pointer;
    function IndexOf(item: Pointer): integer;
    procedure insert(Index: integer; item: Pointer);
    function Last: Pointer;
    procedure move(CurIndex, NewIndex: integer);
    function remove(item: Pointer): integer;
    procedure pack;
    procedure Sort; overload;
    procedure Sort(Compare: TLiztSortCompare); overload;
    property Capacity: integer read fCapacity write setCapacity;
    property Count: integer read fCount write setCount;
    property items[Index: integer]: Pointer read get write put; default;
    property List: PPointerList read fList;
  end;

implementation

uses MBCSDlm, SysUtils, Windows, Classes;

const
  EXCEPTION_NONCONTINUABLE = 1; { Noncontinuable exception }
{$EXTERNALSYM EXCEPTION_NONCONTINUABLE}
  EXCEPTION_MAXIMUM_PARAMETERS = 15; { maximum number of exception parameters }
{$EXTERNALSYM EXCEPTION_MAXIMUM_PARAMETERS}

type
  DWORD = longword;
  HINST = longword;
  THandle = longword;
  UINT = DWORD;
  HWND = longword;
  PExceptionRecord = ^TExceptionRecord;
  _EXCEPTION_RECORD = record
    ExceptionCode: DWORD;
    ExceptionFlags: DWORD;
    ExceptionRecord: PExceptionRecord;
    ExceptionAddress: Pointer;
    NumberParameters: DWORD;
    ExceptionInformation: array[0..EXCEPTION_MAXIMUM_PARAMETERS - 1] of DWORD;
  end;
{$EXTERNALSYM _EXCEPTION_RECORD}
  TExceptionRecord = _EXCEPTION_RECORD;
  EXCEPTION_RECORD = _EXCEPTION_RECORD;
{$EXTERNALSYM EXCEPTION_RECORD}

var
  OutOfMemory: EOutOfMemory;
  InvalidPointer: EInvalidPointer;

type
  PRaiseFrame = ^TRaiseFrame;
  TRaiseFrame = record
    NextRaise: PRaiseFrame;
    ExceptAddr: Pointer;
    ExceptObject: TObject;
    ExceptionRecord: PExceptionRecord;
  end;

{ Return current exception object }

function ExceptObject: TObject;
begin
  if RaiseList <> nil then
    Result := PRaiseFrame(RaiseList)^.ExceptObject
  else
    Result := nil;
end;

{ Return current exception address }

function ExceptAddr: Pointer;
begin
  if RaiseList <> nil then
    Result := PRaiseFrame(RaiseList)^.ExceptAddr
  else
    Result := nil;
end;

{ Convert physical address to logical address }

function ConvertAddr(Address: Pointer): Pointer; assembler;
asm
        TEST    EAX,EAX         { Always convert nil to nil }
        JE      @@1
        SUB     EAX, $1000      { offset from code start; code start set by linker to $1000 }
@@1:
end;

procedure ConvertErrorFmt(ResString: PResStringRec; const args: array of const); begin
  raise eConvertError.CreateFmt(LoadResString(ResString), args);
end;

type
  pStrData = ^TStrData;
  tStrData = record
    Ident: integer;
    Buffer: PChar;
    BufSize: integer;
    nChars: integer;
  end;

  TEnumModuleFuncLW = function(Instance: Cardinal; Data: Pointer): Boolean;

function LoadString(Instance, ID: Cardinal; Buffer: PChar; MaxBuffer: integer): integer; stdcall;
  external 'user32.dll' name 'LoadStringA';

function EnumStringModules(Instance: Longint; Data: Pointer): Boolean; begin
  with pStrData(Data)^ do begin
    nChars := LoadString(Instance, Ident, Buffer, BufSize);
    Result := nChars = 0;
  end;
end;

function FindStringResource(Ident: integer; Buffer: PChar; BufSize: integer): integer;
var
  StrData: tStrData;
begin
  StrData.Ident := Ident;
  StrData.Buffer := Buffer;
  StrData.BufSize := BufSize;
  StrData.nChars := 0;
  EnumResourceModules(EnumStringModules, @StrData);
  Result := StrData.nChars;
end;

function LoadStr(Ident: integer): string;
var Buffer: array[0..1023] of Char;
begin
  SetString(Result, Buffer, FindStringResource(Ident, Buffer, SizeOf(Buffer)));
end;

resourcestring
  SArgumentMissing = 'No argument for format ''%s''';
  SInvalidFormat = 'format ''%s'' invalid or incompatible with argument';
  SListIndexError = 'List index out of bounds (%d)';
  SListCapacityError = 'List capacity out of bounds (%d)';
  SListCountError = 'List count out of bounds (%d)';

function format(const S: string; args: array of const): string;
const tok = '%'; De = 'D'; eS = 'S';
var
  i, L: integer;
  sx: string;
begin
  i := Pos(tok, S);
  if i < 1 then
    Result := S
  else begin
    L := Length(S);
    if (L > i) and (args[0].VType in [vtInteger, vtString]) then
      if UpCase(S[i + 1]) = De then
        Str(integer(args[0].vInteger), sx)
      else
        sx := args[0].vString^;
    Result := Copy(S, 1, i - 1) + Copy(S, i + 2, L);
  end;
end;

constructor error.Create(const msg: string); begin
  fMessage := msg;
end;

constructor error.CreateFmt(const msg: string; const args: array of const); begin
  fMessage := format(msg, args);
end;

constructor error.CreateRes(Ident: integer); begin
  fMessage := LoadStr(Ident);
end;

constructor error.CreateRes(ResStringRec: PResStringRec); begin
  fMessage := LoadResString(ResStringRec);
end;

constructor error.CreateResFmt(Ident: integer; const args: array of const); begin
  fMessage := format(LoadStr(Ident), args);
end;

constructor error.CreateResFmt(ResStringRec: PResStringRec; const args: array of const); begin
  fMessage := format(LoadResString(ResStringRec), args);
end;

constructor error.CreateHelp(const msg: string; AHelpContext: integer); begin
  fMessage := msg;
  fHelpContext := AHelpContext;
end;

constructor error.CreateFmtHelp(const msg: string; const args: array of const; AHelpContext: integer); begin
  fMessage := format(msg, args);
  fHelpContext := AHelpContext;
end;

constructor error.CreateResHelp(Ident: integer; AHelpContext: integer); begin
  fMessage := LoadStr(Ident);
  fHelpContext := AHelpContext;
end;

constructor error.CreateResHelp(ResStringRec: PResStringRec; AHelpContext: integer); begin
  fMessage := LoadResString(ResStringRec);
  fHelpContext := AHelpContext;
end;

constructor error.CreateResFmtHelp(Ident: integer; const args: array of const; AHelpContext: integer); begin
  fMessage := format(LoadStr(Ident), args);
  fHelpContext := AHelpContext;
end;

constructor error.CreateResFmtHelp(ResStringRec: PResStringRec; const args: array of const; AHelpContext: integer); begin
  fMessage := format(LoadResString(ResStringRec), args);
  fHelpContext := AHelpContext;
end;

{ TBits }

resourcestring
  SBitsIndexError = 'Bits index out of range';

const
  BitsPerInt = SizeOf(integer) * 8;

type
  TBitEnum = 0..BitsPerInt - 1;
  TBitSet = set of TBitEnum;
  PBitArray = ^TBitArray;
  TBitArray = array[0..4096] of TBitSet;

destructor TBits.Destroy;
begin
  setSize(0);
  inherited Destroy;
end;

procedure TBits.error;
begin
  raise EBitsError.CreateRes(@SBitsIndexError);
end;

procedure TBits.setSize(Value: integer);
var
  NewMem: Pointer;
  NewMemSize: integer;
  OldMemSize: integer;

function min(const a, b: integer): integer; asm
    cmp a, b; jle @@end
    mov a, b; @@end:
  end;

begin
  if Value <> Size then begin
    if Value < 0 then error;
    NewMemSize := ((Value + BitsPerInt - 1) div BitsPerInt) * SizeOf(integer);
    OldMemSize := ((Size + BitsPerInt - 1) div BitsPerInt) * SizeOf(integer);
    if NewMemSize <> OldMemSize then begin
      NewMem := nil;
      if NewMemSize <> 0 then begin
        GetMem(NewMem, NewMemSize);
        fillchar(NewMem^, NewMemSize, 0);
      end;
      if OldMemSize <> 0 then begin
        if NewMem <> nil then Move(fBits^, NewMem^, min(OldMemSize, NewMemSize));
        FreeMem(fBits, OldMemSize);
      end;
      fBits := NewMem;
    end;
    fSize := Value;
  end;
end;

procedure TBits.setBit(Index: integer; Value: Boolean); assembler; asm
  cmp Index, Self.fSize; jae @@Size

  @@1:
    mov eax, Self.fBits
    or Value, Value; je @@2
    bts [eax], Index
    ret

  @@2: btr Self[0], Index; ret

  @@Size:
    cmp Index, 0; jl TBits.error
    push Self; push Index; push ecx {Value}
    inc Index; call TBits.setSize
    pop ecx {Value}; pop Index; pop Self
    jmp @@1
end;

function TBits.getBit(Index: integer): Boolean; assembler; asm
  cmp Index, Self.fSize; jae TBits.error
  mov eax, Self.fBits
  bt [eax], Index
  sbb eax, eax
  and eax, 1
end;

function TBits.OpenBit: integer;
var
  i, n: integer;
  b: TBitSet; j: TBitEnum;
begin
  n := (Size + BitsPerInt - 1) div BitsPerInt - 1;
  for i := 0 to n do
    if PBitArray(fBits)^[i] <> [0..BitsPerInt - 1] then begin
      b := PBitArray(fBits)^[i];
      for j := Low(j) to high(j) do begin
        if not (j in b) then begin
          Result := i * BitsPerInt + j;
          if Result >= Size then Result := Size;
          exit;
        end;
      end;
    end;
  Result := Size;
end;

{ TLizt }

destructor TLizt.Destroy; begin
  Clear;
end;

function TLizt.add(item: Pointer): integer; begin
  Result := fCount;
  if Result = fCapacity then Grow;
  fList^[Result] := item;
  inc(fCount);
  if item <> nil then notify(item, lnAdded);
end;

procedure TLizt.Clear; begin
  setCount(0);
  setCapacity(0);
end;

procedure TLizt.delete(Index: integer);
var
  p: Pointer;
begin
  if (Index < 0) or (Index >= fCount) then error(@SListIndexError, Index);
  p := items[Index];
  dec(fCount);
  if Index < fCount then System.move(fList^[Index + 1], fList^[Index], (fCount - Index) * SizeOf(Pointer));
  if p <> nil then notify(p, lnDeleted);
end;

class procedure TLizt.error(const msg: string; Data: integer);
  function ReturnAddr: Pointer; asm mov eax, ebp+4 end;
begin
  raise eListError.CreateFmt(msg, [Data])at ReturnAddr;
end;

class procedure TLizt.error(msg: PResStringRec; Data: integer); begin
  TLizt.error(LoadResString(msg), Data);
end;

procedure TLizt.exchange(Index1, Index2: integer);
var
  item: Pointer;
begin
  if (Index1 < 0) or (Index1 >= fCount) then error(@SListIndexError, Index1);
  if (Index2 < 0) or (Index2 >= fCount) then error(@SListIndexError, Index2);
  item := fList^[Index1];
  fList^[Index1] := fList^[Index2];
  fList^[Index2] := item;
end;

function TLizt.expand: TLizt; begin
  if fCount = fCapacity then Grow;
  Result := Self;
end;

function TLizt.first: Pointer; begin
  Result := get(0);
end;

function TLizt.get(Index: integer): Pointer; begin
  if (Index < 0) or (Index >= fCount) then error(@SListIndexError, Index);
  Result := fList^[Index];
end;

procedure TLizt.Grow;
var
  Delta: integer;
begin
  if fCapacity > 64 then
    Delta := fCapacity div 4
  else if fCapacity > 8 then
    Delta := 16
  else
    Delta := 4;
  setCapacity(fCapacity + Delta);
end;

function TLizt.IndexOf(item: Pointer): integer; begin
  Result := 0;
  while (Result < fCount) and (fList^[Result] <> item) do
    inc(Result);
  if Result = fCount then Result := -1;
end;

procedure TLizt.insert(Index: integer; item: Pointer); begin
  if (Index < 0) or (Index > fCount) then error(@SListIndexError, Index);
  if fCount = fCapacity then Grow;
  if Index < fCount then System.move(fList^[Index], fList^[Index + 1], (fCount - Index) * SizeOf(Pointer));
  fList^[Index] := item;
  inc(fCount);
  if item <> nil then notify(item, lnAdded);
end;

function TLizt.Last: Pointer; begin
  Result := get(fCount - 1);
end;

procedure TLizt.move(CurIndex, NewIndex: integer);
var
  item: Pointer;
begin
  if CurIndex <> NewIndex then begin
    if (NewIndex < 0) or (NewIndex >= fCount) then error(@SListIndexError, NewIndex);
    item := get(CurIndex);
    fList^[CurIndex] := nil;
    delete(CurIndex);
    insert(NewIndex, nil);
    fList^[NewIndex] := item;
  end;
end;

procedure TLizt.put(Index: integer; item: Pointer);
var
  p: Pointer;
begin
  if (Index < 0) or (Index >= fCount) then error(@SListIndexError, Index);
  p := fList^[Index];
  fList^[Index] := item;
  if p <> nil then notify(p, lnDeleted);
  if item <> nil then notify(item, lnAdded);
end;

function TLizt.remove(item: Pointer): integer; begin
  Result := IndexOf(item);
  if Result >= 0 then delete(Result);
end;

procedure TLizt.Pack;
var
  i: integer;
begin
  for i := fCount - 1 downto 0 do
    if items[i] = nil then delete(i);
end;

procedure TLizt.setCapacity(NewCapacity: integer); begin
  if (NewCapacity < fCount) or (NewCapacity > MaxListSize) then error(@SListCapacityError, NewCapacity);
  if NewCapacity <> fCapacity then begin
    ReallocMem(fList, NewCapacity * SizeOf(Pointer));
    fCapacity := NewCapacity;
  end;
end;

procedure TLizt.setCount(NewCount: integer);
var
  i: integer;
begin
  if (NewCount < 0) or (NewCount > MaxListSize) then error(@SListCountError, NewCount);
  if NewCount > fCapacity then setCapacity(NewCount);
  if NewCount > fCount then
    fillchar(fList^[fCount], (NewCount - fCount) * SizeOf(Pointer), 0)
  else
    for i := fCount - 1 downto NewCount do
      delete(i);
  fCount := NewCount;
end;

procedure QuickSort(SorTLizt: PPointerList; L, R: integer; SCompare: TLiztSortCompare);
var
  i, j: integer;
  P, Q: Pointer;
begin
  repeat
    i := L; j := R;
    P := SorTLizt^[(L + R) shr 1];
    repeat
      while SCompare(SorTLizt^[i], P) < 0 do
        inc(i);
      while SCompare(SorTLizt^[j], P) > 0 do
        dec(j);
      if i <= j then begin
        Q := SorTLizt^[i];
        SorTLizt^[i] := SorTLizt^[j];
        SorTLizt^[j] := Q;
        inc(i); dec(j);
      end;
    until i > j;
    if L < j then QuickSort(SorTLizt, L, j, SCompare);
    L := i;
  until i >= R;
end;

function TLiztPlainSort(a, b: Pointer): integer; asm sub eax, edx; end;

procedure TLizt.Sort; begin
  if (fList <> nil) and (Count > 0) then QuickSort(fList, 0, Count - 1, TLiztPlainSort);
end;

procedure TLizt.Sort(Compare: TLiztSortCompare); begin
  if (fList <> nil) and (Count > 0) then QuickSort(fList, 0, Count - 1, Compare);
end;

function TLizt.extract(item: Pointer): Pointer;
var
  i: integer;
begin
  Result := nil;
  i := IndexOf(item);
  if i >= 0 then begin
    Result := item;
    fList^[i] := nil;
    delete(i);
    notify(Result, lnExtracted);
  end;
end;

procedure TLizt.notify(ptr: Pointer; Action: TLiztNotification);
begin
end;

{ Create I/O exception }

resourcestring
  SInOutError = 'I/O error %d';
  SFileNotFound = 'File not found';
  SInvalidFilename = 'Invalid filename';
  STooManyOpenFiles = 'Too many open files';
  SAccessDenied = 'File access denied';
  SEndOfFile = 'Read beyond end of file';
  SDiskFull = 'Disk full';
  SInvalidInput = 'Invalid numeric input';
function CreateInOutError: EInOutError;
type
  TErrorRec = record
    Code: Integer;
    Ident: string;
  end;
const
  ErrorMap: array[0..6] of TErrorRec = (
    (Code: 2; Ident: SFileNotFound),
    (Code: 3; Ident: SInvalidFilename),
    (Code: 4; Ident: STooManyOpenFiles),
    (Code: 5; Ident: SAccessDenied),
    (Code: 100; Ident: SEndOfFile),
    (Code: 101; Ident: SDiskFull),
    (Code: 106; Ident: SInvalidInput));
var
  I: Integer;
  InOutRes: Integer;
begin
  I := Low(ErrorMap);
  InOutRes := IOResult; // resets IOResult to zero
  while (I <= High(ErrorMap)) and (ErrorMap[I].Code <> InOutRes) do
    Inc(I);
  if I <= High(ErrorMap) then
    Result := EInOutError.Create(ErrorMap[I].Ident)
  else
    Result := EInOutError.CreateResFmt(@SInOutError, [InOutRes]);
  Result.ErrorCode := InOutRes;
end;

{ RTL exception handler }

{ RTL error handler }
resourcestring
  SOutOfMemory = 'Out of memory';
  SDivByZero = 'Division by zero';
  SRangeError = 'Range check error';
  SIntOverflow = 'Integer overflow';
  SInvalidOp = 'Invalid floating point operation';
  SZeroDivide = 'Floating point division by zero';
  SOverflow = 'Floating point overflow';
  SUnderflow = 'Floating point underflow';
  SInvalidPointer = 'Invalid pointer operation';
  SInvalidCast = 'Invalid class typecast';
  SAccessViolation = 'Access violation at address %p. %s of address %p';
  SStackOverflow = 'Stack overflow';
  SControlC = 'Control-C hit';
  SPrivilege = 'Privileged instruction';
  SInvalidVarCast = 'Invalid variant type conversion';
  SInvalidVarOp = 'Invalid variant operation';
  SDispatchError = 'Variant method calls not supported';
  SVarArrayCreate = 'Error creating variant array';
  SVarNotArray = 'Variant is not an array';
  SVarArrayBounds = 'Variant array index out of bounds';
  SExternalException = 'External exception %x';
  SAssertionFailed = 'Assertion failed';
  SIntfCastError = 'Interface not supported';
  SSafecallException = 'Exception in safecall method';
  SAssertError = '%s (%s, line %d)';

  SException = 'Exception %s in module %s at %p.'#$0A'%s%s';
  SExceptTitle = 'Application Error';

type
  TExceptRec = record
    eClass: errorClass;
    eIdent: string;
  end;

const
  ExceptMap: array[3..24] of TExceptRec = (
    (EClass: EDivByZero; EIdent: SDivByZero),
    (EClass: ERangeError; EIdent: SRangeError),
    (EClass: EIntOverflow; EIdent: SIntOverflow),
    (EClass: EInvalidOp; EIdent: SInvalidOp),
    (EClass: EZeroDivide; EIdent: SZeroDivide),
    (EClass: EOverflow; EIdent: SOverflow),
    (EClass: EUnderflow; EIdent: SUnderflow),
    (EClass: EInvalidCast; EIdent: SInvalidCast),
    (EClass: EAccessViolation; EIdent: SAccessViolation),
    (EClass: EPrivilege; EIdent: SPrivilege),
    (EClass: EControlC; EIdent: SControlC),
    (EClass: EStackOverflow; EIdent: SStackOverflow),
    (EClass: EVariantError; EIdent: SInvalidVarCast),
    (EClass: EVariantError; EIdent: SInvalidVarOp),
    (EClass: EVariantError; EIdent: SDispatchError),
    (EClass: EVariantError; EIdent: SVarArrayCreate),
    (EClass: EVariantError; EIdent: SVarNotArray),
    (EClass: EVariantError; EIdent: SVarArrayBounds),
    (EClass: EAssertionFailed; EIdent: SAssertionFailed),
    (EClass: EExternalException; EIdent: SExternalException),
    (EClass: EIntfCastError; EIdent: SIntfCastError),
    (EClass: ESafecallException; EIdent: SSafecallException));

const
  STATUS_INTEGER_DIVIDE_BY_ZERO = DWORD($C0000094); {$EXTERNALSYM STATUS_INTEGER_DIVIDE_BY_ZERO}
  STATUS_ARRAY_BOUNDS_EXCEEDED = DWORD($C000008C); {$EXTERNALSYM STATUS_ARRAY_BOUNDS_EXCEEDED}
  STATUS_INTEGER_OVERFLOW = DWORD($C0000095); {$EXTERNALSYM STATUS_INTEGER_OVERFLOW}
  STATUS_FLOAT_INEXACT_RESULT = DWORD($C000008F); {$EXTERNALSYM STATUS_FLOAT_INEXACT_RESULT}
  STATUS_FLOAT_INVALID_OPERATION = DWORD($C0000090); {$EXTERNALSYM STATUS_FLOAT_INVALID_OPERATION}
  STATUS_FLOAT_STACK_CHECK = DWORD($C0000092); {$EXTERNALSYM STATUS_FLOAT_STACK_CHECK}
  STATUS_FLOAT_DIVIDE_BY_ZERO = DWORD($C000008E); {$EXTERNALSYM STATUS_FLOAT_DIVIDE_BY_ZERO}
  STATUS_FLOAT_OVERFLOW = DWORD($C0000091); {$EXTERNALSYM STATUS_FLOAT_OVERFLOW}
  STATUS_FLOAT_UNDERFLOW = DWORD($C0000093); {$EXTERNALSYM STATUS_FLOAT_UNDERFLOW}
  STATUS_FLOAT_DENORMAL_OPERAND = DWORD($C000008D); {$EXTERNALSYM STATUS_FLOAT_DENORMAL_OPERAND}
  STATUS_ACCESS_VIOLATION = DWORD($C0000005); {$EXTERNALSYM STATUS_ACCESS_VIOLATION}
  STATUS_PRIVILEGED_INSTRUCTION = DWORD($C0000096); {$EXTERNALSYM STATUS_PRIVILEGED_INSTRUCTION}
  STATUS_CONTROL_C_EXIT = DWORD($C000013A); {$EXTERNALSYM STATUS_CONTROL_C_EXIT}
  STATUS_STACK_OVERFLOW = DWORD($C00000FD); {$EXTERNALSYM STATUS_STACK_OVERFLOW}

function MapException(P: PExceptionRecord): Byte;
begin
  case P.ExceptionCode of
    STATUS_INTEGER_DIVIDE_BY_ZERO:
      Result := 3;
    STATUS_ARRAY_BOUNDS_EXCEEDED:
      Result := 4;
    STATUS_INTEGER_OVERFLOW:
      Result := 5;
    STATUS_FLOAT_INEXACT_RESULT,
      STATUS_FLOAT_INVALID_OPERATION,
      STATUS_FLOAT_STACK_CHECK:
      Result := 6;
    STATUS_FLOAT_DIVIDE_BY_ZERO:
      Result := 7;
    STATUS_FLOAT_OVERFLOW:
      Result := 8;
    STATUS_FLOAT_UNDERFLOW,
      STATUS_FLOAT_DENORMAL_OPERAND:
      Result := 9;
    STATUS_ACCESS_VIOLATION:
      Result := 11;
    STATUS_PRIVILEGED_INSTRUCTION:
      Result := 12;
    STATUS_CONTROL_C_EXIT:
      Result := 13;
    STATUS_STACK_OVERFLOW:
      Result := 14;
  else
    Result := 22; { must match System.reExternalException }
  end;
end;

function GetExceptionClass(P: PExceptionRecord): errorClass;
var
  ErrorCode: Byte;
begin
  ErrorCode := MapException(P);
  Result := ExceptMap[ErrorCode].EClass;
end;

procedure ErrorHandler(ErrorCode: Integer; ErrorAddr: Pointer);
var
  E: error;
begin
  case ErrorCode of
    1: E := OutOfMemory;
    2: E := InvalidPointer;
    3..24: with ExceptMap[ErrorCode] do
        E := EClass.Create(EIdent);
  else
    E := CreateInOutError;
  end;
  raise E at ErrorAddr;
end;

function StrLCopy(Dest: PChar; const Source: PChar; MaxLen: Cardinal): PChar; assembler;
asm
        PUSH    EDI
        PUSH    ESI
        PUSH    EBX
        MOV     ESI,EAX
        MOV     EDI,EDX
        MOV     EBX,ECX
        XOR     AL,AL
        TEST    ECX,ECX
        JZ      @@1
        REPNE   SCASB
        JNE     @@1
        INC     ECX
@@1:    SUB     EBX,ECX
        MOV     EDI,ESI
        MOV     ESI,EDX
        MOV     EDX,EDI
        MOV     ECX,EBX
        SHR     ECX,2
        REP     MOVSD
        MOV     ECX,EBX
        AND     ECX,3
        REP     MOVSB
        STOSB
        MOV     EAX,EDX
        POP     EBX
        POP     ESI
        POP     EDI
end;

function StrScan(const Str: PChar; Chr: Char): PChar; assembler;
asm
        PUSH    EDI
        PUSH    EAX
        MOV     EDI,Str
        MOV     ECX,0FFFFFFFFH
        XOR     AL,AL
        REPNE   SCASB
        NOT     ECX
        POP     EDI
        MOV     AL,Chr
        REPNE   SCASB
        MOV     EAX,0
        JNE     @@1
        MOV     EAX,EDI
        DEC     EAX
@@1:    POP     EDI
end;

function StrLen(const Str: PChar): Cardinal; assembler;
asm
        MOV     EDX,EDI
        MOV     EDI,EAX
        MOV     ECX,0FFFFFFFFH
        XOR     AL,AL
        REPNE   SCASB
        MOV     EAX,0FFFFFFFEH
        SUB     EAX,ECX
        MOV     EDI,EDX
end;

function AnsiStrScan(Str: PChar; Chr: Char): PChar;
begin
  Result := StrScan(Str, Chr);
  while Result <> nil do begin
    case StrByteType(Str, Integer(Result - Str)) of
      mbSingleByte: Exit;
      mbLeadByte: Inc(Result);
    end;
    Inc(Result);
    Result := StrScan(Result, Chr);
  end;
end;

function AnsiStrRScan(Str: PChar; Chr: Char): PChar;
begin
  Str := AnsiStrScan(Str, Chr);
  Result := Str;
  if Chr <> #$0 then begin
    while Str <> nil do begin
      Result := Str;
      Inc(Str);
      Str := AnsiStrScan(Str, Chr);
    end;
  end
end;

{ Format and return an exception error message }
type
  PMemoryBasicInformation = ^TMemoryBasicInformation;
  _MEMORY_BASIC_INFORMATION = record
    BaseAddress: Pointer;
    AllocationBase: Pointer;
    AllocationProtect: DWORD;
    RegionSize: DWORD;
    State: DWORD;
    Protect: DWORD;
    Type_9: DWORD;
  end;
  TMemoryBasicInformation = _MEMORY_BASIC_INFORMATION; {$EXTERNALSYM _MEMORY_BASIC_INFORMATION}
  MEMORY_BASIC_INFORMATION = _MEMORY_BASIC_INFORMATION; {$EXTERNALSYM MEMORY_BASIC_INFORMATION}

const
  kernel32 = 'kernel32.dll';
  user32 = 'user32.dll';

function VirtualQuery(lpAddress: pointer; var lpBuffer: TMemoryBasicInformation; dwLength: DWORD): DWORD; stdcall;
  external kernel32 name 'VirtualQuery'; {$EXTERNALSYM VirtualQuery}
function GetModuleFileName(hModule: HINST; lpFilename: PAnsiChar; nSize: DWORD): DWORD; stdcall;
  external kernel32 name 'GetModuleFileNameA'; {$EXTERNALSYM GetModuleFileName}

function MessageBox(hWnd: HWND; lpText, lpCaption: PChar; uType: UINT): Integer; stdcall;
  external user32 name 'MessageBoxA'; {$EXTERNALSYM MessageBox}

const
  MAX_PATH = 260; //{$EXTERNALSYM MAX_PATH}
  MEM_COMMIT = $1000; //{$EXTERNALSYM MEM_COMMIT}

function ExceptionErrorMessage(ExceptObject: TObject; ExceptAddr: Pointer;
  Buffer: PChar; Size: Integer): Integer;
var
  MsgPtr: PChar;
  MsgEnd: PChar;
  MsgLen: Integer;
  ModuleName: array[0..MAX_PATH] of Char;
  Temp: array[0..MAX_PATH] of Char;
  Format: array[0..255] of Char;
  Info: TMemoryBasicInformation;
  ConvertedAddress: Pointer;
begin
  VirtualQuery(ExceptAddr, Info, sizeof(Info));
  if (Info.State <> MEM_COMMIT) or
    (GetModuleFilename(THandle(Info.AllocationBase), Temp, SizeOf(Temp)) = 0) then begin
    GetModuleFileName(HInstance, Temp, SizeOf(Temp));
    ConvertedAddress := ConvertAddr(ExceptAddr);
  end
  else
    Integer(ConvertedAddress) := Integer(ExceptAddr) - Integer(Info.AllocationBase);
  StrLCopy(ModuleName, AnsiStrRScan(Temp, '\') + 1, SizeOf(ModuleName) - 1);
  MsgPtr := '';
  MsgEnd := '';
  if ExceptObject is error then begin
    MsgPtr := PChar(error(ExceptObject).Message);
    MsgLen := StrLen(MsgPtr);
    if (MsgLen <> 0) and (MsgPtr[MsgLen - 1] <> '.') then MsgEnd := '.';
  end;
  LoadString(FindResourceHInstance(HInstance),
    PResStringRec(@SException).Identifier, Format, SizeOf(Format));
  StrLFmt(Buffer, Size, Format, [ExceptObject.ClassName, ModuleName,
    ConvertedAddress, MsgPtr, MsgEnd]);
  Result := StrLen(Buffer);
end;

resourcestring
  SReadAccess = 'Read';
  SWriteAccess = 'Write';
  SModuleAccessViolation = 'Access violation at address %p in module ''%s''. %s of address %p';

function GetExceptionObject(P: PExceptionRecord): error;
var
  ErrorCode: Integer;

  function CreateAVObject: error;
  var
    AccessOp: string; // string ID indicating the access type READ or WRITE
    AccessAddress: Pointer;
    MemInfo: TMemoryBasicInformation;
    ModName: array[0..MAX_PATH] of Char;
  begin
    with P^ do begin
      if ExceptionInformation[0] = 0 then
        AccessOp := SReadAccess
      else
        AccessOp := SWriteAccess;
      AccessAddress := Pointer(ExceptionInformation[1]);
      VirtualQuery(ExceptionAddress, MemInfo, SizeOf(MemInfo));
      if (MemInfo.State = MEM_COMMIT) and (GetModuleFileName(THandle(MemInfo.AllocationBase),
        ModName, SizeOf(ModName)) <> 0) then
        Result := EAccessViolation.CreateFmt(sModuleAccessViolation,
          [ExceptionAddress, ModName {ExtractFileName(ModName)}, AccessOp,
          AccessAddress])
      else
        Result := EAccessViolation.CreateFmt(sAccessViolation,
          [ExceptionAddress, AccessOp, AccessAddress]);
    end;
  end;

begin
  ErrorCode := MapException(P);
  case ErrorCode of
    3..10, 12..21:
      with ExceptMap[ErrorCode] do
        Result := EClass.Create(EIdent);
    11: Result := CreateAVObject;
  else
    Result := EExternalException.CreateFmt(SExternalException, [P.ExceptionCode]);
  end;
  if Result is eExternal then begin
    EExternal(Result).ExceptionRecord := P;
    if P.ExceptionCode = $0EEFFACE then
      Result.FMessage := 'C++ Exception'; // do not localize
  end;
end;

{ Display exception message box }

procedure ShowException(ExceptObject: TObject; ExceptAddr: Pointer);
var
  Title: array[0..63] of Char;
  Buffer: array[0..1023] of Char;
begin
  ExceptionErrorMessage(ExceptObject, ExceptAddr, Buffer, SizeOf(Buffer));
  if IsConsole then
    WriteLn(Buffer)
  else begin
    LoadString(FindResourceHInstance(HInstance), PResStringRec(@SExceptTitle).Identifier,
      Title, SizeOf(Title));
    MessageBox(0, Buffer, Title, MB_OK or MB_ICONSTOP or MB_TASKMODAL);
  end;
end;

procedure exceptHandler(ExceptObject: TObject; ExceptAddr: Pointer); far;
begin
  ShowException(ExceptObject, ExceptAddr);
  Halt(1);
end;

{ Assertion error handler }

{ This is complicated by the desire to make it look like the exception     }
{ happened in the user routine, so the debugger can give a decent stack    }
{ trace. To make that feasible, AssertErrorHandler calls a helper function }
{ to create the exception object, so that AssertErrorHandler itself does   }
{ not need any temps. After the exception object is created, the asm       }
{ routine RaiseAssertException sets up the registers just as if the user   }
{ code itself had raised the exception.                                    }

function CreateAssertException(const Message, Filename: string;
  LineNumber: Integer): error;
var
  S: string;
begin
  if Message <> '' then
    S := Message
  else
    S := SAssertionFailed;
  Result := EAssertionFailed.CreateFmt(SAssertError,
    [S, Filename, LineNumber]);
end;

{ This code is based on the following assumptions:                         }
{  - Our direct caller (AssertErrorHandler) has an EBP frame               }
{  - ErrorStack points to where the return address would be if the         }
{    user program had called System.@RaiseExcept directly                  }
procedure RaiseAssertException(const E: error; const ErrorAddr, ErrorStack: Pointer);
asm
        MOV     ESP,ECX
        MOV     [ESP],EDX
        MOV     EBP,[EBP]
        JMP     System.@RaiseExcept
end;

{ If you change this procedure, make sure it does not have any local variables }
{ or temps that need cleanup - they won't get cleaned up due to the way        }
{ RaiseAssertException frame works. Also, it can not have an exception frame.  }
procedure AssertErrorHandler(const Message, Filename: string;
  LineNumber: Integer; ErrorAddr: Pointer);
var
  E: error;
begin
  E := CreateAssertException(Message, Filename, LineNumber);
  RaiseAssertException(E, ErrorAddr, PChar(@ErrorAddr) + 4);
end;

{ Abstract method invoke error handler }
resourcestring
  SAbstractError = 'Abstract Error';
procedure AbstractErrorHandler;
begin
  raise EAbstractError.CreateResFmt(@SAbstractError, ['']);
end;


procedure InitExceptions;
begin
  OutOfMemory := EOutOfMemory.Create(SOutOfMemory);
  InvalidPointer := EInvalidPointer.Create(SInvalidPointer);
  ErrorProc := @ErrorHandler;
  ExceptProc := @ExceptHandler;
  ExceptionClass := error;
  ExceptClsProc := @GetExceptionClass;
  ExceptObjProc := @GetExceptionObject;
  AssertErrorProc := @AssertErrorHandler;
  AbstractErrorProc := @AbstractErrorHandler;
end;

initialization
  InitExceptions;

end.


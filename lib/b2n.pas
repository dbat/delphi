unit b2n;
{$A+,Z4} // DO NOT CHANGE!!!
{ ***************************************************** }
{ Unit binary stream to str  version: 1.0.0.0           }
{                                                       }
{ Copyright (C) 2003,2015, aa                           }
{ Property of PT SOFTINDO, Jakarta                      }
{                                                       }
{ License: Public Domain                                }
{ ***************************************************** }

{
CHANGES:

Version: 1.0.0.0, LastUpdated: 2015.0.0
  moved from bigintx.unit

}

interface
uses chpos;
type
  pintar = System.PIntegerArray;

function toaster(const A; const size: integer): string;

function WaitForSingleObject(hHandle: THandle; dwMilliseconds: longword): longword; stdcall; {$EXTERNALSYM WaitForSingleObject}
function WaitForMultipleObjects(nCount: integer; pHandles: pointer; bWaitAll: boolean; dwMilliseconds: longword): longword; stdcall; {$EXTERNALSYM WaitForMultipleObjects}
function CreateThread(SecurityAttributes: Pointer; StackSize: LongWord; ThreadFunc: TThreadFunc; Parameter: Pointer; CreationFlags: LongWord; var ThreadId: LongWord): Integer; stdcall; {$EXTERNALSYM CreateThread}
function CloseHandle(hanlde: thandle): boolean; stdcall; {$EXTERNALSYM CloseHandle}

implementation
uses ordinals;

//function ThreadWrap(Parameter: Pointer): Integer; stdcall;
//begin
//  result := 0;
//end;
{*
function newThread(SecurityAttributes: Pointer; StackSize: LongWord;
  ThreadFunc: TThreadFunc; Parameter: Pointer; CreationFlags: LongWord;
  var ThreadId: LongWord): Integer;
type
  PThreadRec = ^TThreadRec;
  TThreadRec = record
    Func: TThreadFunc;
    Parameter: Pointer;
  end;

var
  P: PThreadRec;
begin
  New(P);
  P.Func := ThreadFunc;
  P.Parameter := Parameter;
  //IsMultiThread := TRUE;
  Result := CreateThread(SecurityAttributes, StackSize, @System.ThreadWrapper, P,
    CreationFlags, ThreadID);
end;
*}

function _mod5(const n: integer): integer;
asm // all registers preserved
  push edx
  mov edx,$CCCCCCCD
  push eax
  mul edx
  pop eax
  shr edx,2
  lea edx,edx*4+edx
  sub eax,edx
  pop edx
end;

function _mod10(const n: integer): integer;
asm // all registers preserved
  push edx
  mov edx,$CCCCCCCD
  push eax
  mul edx
  pop eax
  shr edx,3
  lea edx,edx*4+edx
  sub eax,edx
  sub eax,edx
  pop edx
end;

function _divmod5(const n: integer): integer;
// 29 bits quotient and low 3 bits remainder
asm // all registers preserved
  push ecx;
  push edx;
  mov edx,$CCCCCCCD
  mov ecx,eax
  mul edx
  shr edx,2
  mov eax,edx
  lea edx,edx*4+edx
  shl eax,1
  sub ecx,edx
  pop edx;
  lea eax,eax*4+ecx
  pop ecx;
end;

function _divmod10(const n: integer): integer;
// 28 bits quotient and low 4 bits remainder
asm // all registers preserved
  push ecx;
  push edx;
  mov edx,$CCCCCCCD
  mov ecx,eax
  mul edx
  shr edx,3
  mov eax,edx
  lea edx,edx*4+edx
  shl eax,1
  sub ecx,edx
  shl eax,1
  sub ecx,edx
  pop edx;
  lea eax,eax*4+ecx
  pop ecx;
end;

function _divmod5b(const n: integer): integer;
// 24 bits quotient and low 8 bits remainder; byte size
asm // all registers preserved
  push ecx;
  push edx;
  mov edx,$CCCCCCCD
  mov ecx,eax
  mul edx
  shr edx,2
  mov eax,edx
  lea edx,edx*4+edx
  shl eax,5
  sub ecx,edx
  pop edx;
  lea eax,eax*8+ecx
  pop ecx;
end;

function _divmod10b(const n: integer): integer;
// 24 bits quotient and low 8 bits remainder; byte size
asm // all registers preserved
  push ecx;
  push edx;
  mov edx,$CCCCCCCD
  mov ecx,eax
  mul edx
  shr edx,3
  mov eax,edx
  lea edx,edx*4+edx
  shl eax,4
  sub ecx,edx
  shl eax,1
  sub ecx,edx
  pop edx;
  lea eax,eax*8+ecx
  pop ecx;
end;

function mul100(const A; const size: integer; const writeover: boolean = false): integer;
// multiply by 100 of ONLY length size, if writeover is not allowed
// most significant dword might be truncated, returned in result
asm
  //test eax,eax; jz @STOP; // tired testing this, up to you to give me nil pointer
  movzx ecx,cl
  push esi;
  push edi;
  push ebx;
  push ecx;
  mov ecx,edx
  mov bl,100
  mov esi,eax
  xor edi,edi
  movzx ebx,bl
@Loop:
  mov eax,[esi]
  mul ebx
  add eax,edi
  mov edi,edx
  adc edx,0;
  sub ecx,1;
  mov [esi],eax
  lea esi,[esi+4]
  jg @Loop
  test edx,edx
  pop ecx;
  jz @done
  test ecx,ecx
  jz @done
  mov [esi],edx
@done: mov eax,edx //topmost dword stored in result
  pop ebx; pop edi; pop esi
@STOP:
end;

function mul100_mr(const A): integer;
// multiply by 100, realloc mem if needed
asm
  //test eax,eax; jz @STOP; // tired testing this, up to you to give me nil pointer
  mov edx,[eax-4]
  push esi;
  push edi;
  shr edx,2;
  push ebx;
  mov bl,100
  lea ecx,edx-1
  mov esi,eax
  movzx ebx,bl
  push ecx;
  xor edi,edi
@Loop:
  mov eax,[esi]
  mul ebx
  add eax,edi
  mov edi,edx
  adc edx,0
  sub ecx,1
  mov [esi],eax
  lea esi,[esi+4]
  jg @Loop
  test edx,edx
  pop ecx
  jz @done
  push edx
  lea ecx,ecx*4+4
  mov eax,esi // esi already past over 4 bytes
  push ecx
  sub eax,ecx
  call System.@ReallocMem
  pop ebx
  pop edx
  mov [esi+ebx], edx
@done: mov eax,edx //topmost dword stored in result
  pop ebx; pop edi; pop esi
@STOP:
end;

function multex(const A; const size: integer; const multiplier: cardinal): longword;
 // multiply buffer by a number, return topmost dword on B after multiplication
 // B length must be be at least 1 item more than indicated by size to accomodate overflow
asm
  push esi; mov esi,A;
  push edi; mov edi,edx;
  push ebx;
  xor ebx,ebx
  @Loop:
    mov eax,[esi]
    mul ecx
    add eax,ebx
    mov ebx,edx
    adc ebx,0
    mov [esi],eax
    add esi,4
    sub edi,1
    jg @Loop
    test ebx,ebx
    jz @done
    //--- acces element above [size-1].
    //--- will thrown nasty error if B[size] is unallocated yet!
    mov eax,[esi]
    add eax,ebx
    mov [esi],eax
    //------------------------------------------
  @done:
  pop ebx;
  pop edi;
  pop esi;
end;

//  min
//	sub b,a; sbb ecx,ecx
//	and b,ecx; add a,b

{*
function _MinMax(const a, b: integer): integer; overload asm
// not useful unless you called this from asm
// min in eax, max in edx, ecx preserved.
  push ebx
  push ecx
  xor ecx,ecx;
  xor ebx,ebx;
  sub edx,eax
  setl cl; // the only difference
  setge bl // the only difference
  sub ecx,1
  sub ebx,1
  push edx
  and edx,ecx;
  pop ecx
  push eax
  and ecx,ebx
  add eax,edx;
  pop edx
  add edx,ecx
  pop ecx
  pop ebx
end;
*}

function _subme(const S, substractor; const size1, size2: integer): integer;
asm
  push esi;
  push edi;
  push ebx
  mov esi,eax
  mov eax,size2
  mov edi,edx
  mov ebx,ecx // save the length of p to be subbed

  xor edx,edx;
  sub eax,ecx // get difference between 2 numbers
  setae dl;   // the only difference
  sub edx,1   // set flag 1 if eax greater/equal than ecx
  and eax,edx // flip bitmask, -1 if less, zero if greater/equal
  add ecx,eax // add diference. added nothing if less.

  sub ebx,ecx // get difference, ..again?
  xor eax,eax
  @Loop1:
    dec ecx;
    jle @Loop2
    mov eax,[esi]
    mov edx,[edi]
    sbb eax,edx
    lea edi,edi+4;
    mov [esi],eax
    lea esi,esi+4;
    jmp @Loop1
  @Loop2:
  jnb @goone
    dec ebx
    jl @goone  // comment this line to skip length check
    mov eax,[esi]
    sbb eax,0
    mov [esi],eax
    lea esi,esi+4
    jmp @Loop2
  @goone:
  pop ebx
  pop edi; pop esi;
end;

function _addme(const A, adder; const size1, size2: integer): integer;
asm
  push esi;
  push edi;
  push ebx
  mov esi,eax
  mov eax,size2
  mov edi,edx
  mov ebx,ecx // save the length of p to be added

  xor edx,edx;
  sub eax,ecx // get difference between 2 numbers
  setae dl;   // the only difference
  sub edx,1   // set flag 1 if eax greater/equal than ecx
  and eax,edx // flip bitmask, -1 if less, zero if greater/equal
  add ecx,eax // add diference. added nothing if less.

  sub ebx,ecx // get difference, ..again?
  xor eax,eax
  @Loop1:
    dec ecx;
    jle @Loop2
    mov eax,[esi]
    mov edx,[edi]
    adc eax,edx
    lea edi,edi+4;
    mov [esi],eax
    lea esi,esi+4;
    jmp @Loop1
  @Loop2:
  jnb @goone
    dec ebx
    jl @goone  // comment this line to skip length check
    mov eax,[esi]
    adc eax,0
    mov [esi],eax
    lea esi,esi+4
    jmp @Loop2
  @goone:
  pop ebx
  pop edi; pop esi;
end;

type
  plrparams = ^tlrparams;
  tlrparams = packed record
    bleft, bright: pinteger;
    length, rounds: integer;
  end;

procedure binc1(const B; const size: integer); assembler;
asm
  test eax,eax;
  mov ecx,edx
  jz @Stop
  xor edx,edx
  cmp edx,1
@Loop:
  mov edx,[eax]
  lea eax,eax+4
  adc edx,0
  dec ecx
  mov [eax-4],edx
  jnb @Stop
  jg @Loop
@Stop:
end;

procedure bdec1(const B; const size: integer); assembler;
asm
  test eax,eax;
  mov ecx,edx
  jz @Stop
  xor edx,edx
  cmp edx,1
@Loop:
  mov edx,[eax]
  lea eax,eax+4
  sbb edx,0
  dec ecx
  mov [eax-4],edx
  jnb @Stop
  jg @Loop
@Stop:
end;

procedure shrr6(const B; const size: integer); assembler;
const
  SHRCOUNT = 6;
asm
  test eax,eax; jz @Stop
  sub edx,1; jl @Stop

  push esi; push edi; push ebx;

  mov esi,edx;
  mov edx,[eax]
  mov ebx,[eax+4]
  shr edx,SHRCOUNT
  mov edi,ebx
  shl ebx,32-SHRCOUNT

  test esi,esi; jz @done2
  or edx,ebx

  @Loop:
    sub esi,1; jz @done;
    mov [eax],edx
    mov edx,edi
    mov ebx,[eax+8]
    shr edx,SHRCOUNT
    mov edi,ebx
    shl ebx,32-SHRCOUNT
    add eax,4
    or edx,ebx
    jmp @Loop

  @done:

   add eax,4
   mov ebx,edx
   mov edx,[eax]
   shr edx,SHRCOUNT
   mov [eax-4],ebx

  @done2: mov [eax],edx
   pop ebx; pop edi; pop esi;
  @Stop:
end;

procedure shrr(const B; const size: integer; const count: byte); overload; assembler;
asm
  test eax,eax; jz @Stop
  sub edx,1; jl @Stop

  push esi; push edi; push ebx;

  movzx ecx,cl
  mov ch,32
  push ecx

  mov esi,edx;
  mov edx,[eax]
  mov ebx,[eax+4]
  shr edx,cl
  mov cl,ch
  mov edi,ebx
  shl ebx,cl

  test esi,esi; jz @done2
  or edx,ebx

  @Loop:
    sub esi,1; jz @done;
    mov [eax],edx
    mov edx,edi
    mov ecx,[esp]
    mov ebx,[eax+8]
    shr edx,cl
    mov cl,ch
    mov edi,ebx
    shl ebx,cl
    add eax,4
    or edx,ebx
    jmp @Loop

  @done:
   mov ecx,[esp]
   add eax,4
   mov ebx,edx
   mov edx,[eax]
   shr edx,cl
   mov [eax-4],ebx

  @done2: mov [eax],edx
   pop ecx; pop ebx;
   pop edi; pop esi;
  @Stop:
end;

function thrl(params: plrparams): integer; // need: length, rounds
  //  top = length - 1;
  //  k5pos = length - rounds * 5 + 5;
  //  if (k5pos < 1) k5pos = (top % 5) + 1;
  //  for (i = top; i >= k5pos + 5; i--) {
  //    for (j = i - 5; j >= k5pos; j -= 5) {
  //  ...
asm
  mov ecx,params.tlrparams.rounds
  push ebx;
  xor ebx,ebx
  cmp ecx,2
  mov edx,params.tlrparams.length
  push esi;
  push edi;
  setle bl
  cmp edx,5
  lea esi,eax+edx*4-4 // esi = top
  mov edi,params.tlrparams.bleft
  setle bh
  mov eax,edx         // eax now length
  test ebx,ebx
  mov ebx,edx
  jnz @Ended

  // k5 = (top1 + 1) - y * 5 + 5;
  // if (k5 < 1) k5 = top1 % 5 + 1;
  //
  // k5pos = length - (rounds - 1) * 5;
  // k5pos = length - rounds * 5 + 5;
  // if (k5pos < 1) k5pos = top % 5 + 1;

  lea ecx,ecx*4+ecx+5 // rounds * 5 + 5
  sub eax,ecx         // length - rounds * 5 + 5
  jg @gogon           // ? (k5pos > 0) ?
    lea eax,edx-1     // top = length -1
    call _mod5        // eax = top % 5
    lea eax,eax+1     // eax = top % 5 + 1
  @gogon:
  lea edi,edi+eax*4+4*5  // edi points to A[k5pos+5]

  //  for (i = top; i >= k5pos + 5; i--) {
  //    for (j = i - 5; j >= k5pos; j -= 5) {

  @Loop1:
    cmp esi,edi
    jl @L1done
    mov eax,[esi]
    push esi
    sub esi,20
    sub edi,20
    xor ebx,ebx
      @Loop2:
        cmp esi,edi
        jl @L2done
        mov edx,[esi]
        sub esi,20
        add eax,edx
        adc ebx,0
      jmp @Loop2
    @L2done:
    pop esi
    test ebx,ebx
    mov [esi],eax
    jz @gone
      mov eax,[esi+4]
      add eax,ebx
      mov [esi+4],eax
      jnc @gone
      push esi
        @Loop3:
          mov eax,[esi+8]
          add esi,4
          add eax,1
          mov [esi+4],eax
        jz @Loop3
      pop esi
    @gone:
    sub esi,4
    add edi,20
    jmp @Loop1
  @L1done:
@Ended:
  pop edi; pop esi; pop ebx;
@Stop:
end;

function thrr(params: plrparams): integer;
//procedure thrr(const A: pintar; const length: integer; const rounds: integer);
// this is a time critical routine, no extensive checking will be done here.
// make sure there's at least 1 dword more allocated memory for overflow.
// rounds is calculated based on the original length NOT by this length.
asm //

  //  for (i = top; i >= 5; i--) {
  //    r = rounds;
  //    for (j = i - 5; j >= 0; j -= 5) {
  //      if (--r < 1) break;

  mov ecx,params.tlrparams.rounds
  push ebx;
  xor ebx,ebx
  cmp ecx,1
  push esi;
  setle bl
  mov edx,params.tlrparams.length
  push edi;
  cmp edx,5
  mov eax,params.tlrparams.bright
  setle bh
  lea esi,eax+edx*4-4
  test ebx,ebx
  mov ebx,ecx
  lea ecx,edx-5
  jnz @Ended

  xor edx,edx

  push ebp;
  push ebx;

  mov [esi+4],edx; // clear topmost dword

  @Loop1:
    sub ecx,1
    mov ebp,[esp]
    jl @done1
    push ecx
    add ecx,5  // have to be raised up back, for inner loop
    xor edx,edx
    mov eax,[esi]
    lea edi,esi-20  // j = i - 5
    push esi
    @Loop2:
      sub ecx,5
      mov ebx,[edi]
      jl @done2
      sub ebp,1
      sub edi,20
      jle @done2
      add eax,ebx
      adc edx,0
      jmp @Loop2
    @done2:
    pop esi
    pop ecx
    test edx,edx
    mov [esi],eax
    jz @done3
      mov eax,[esi+4]
      add eax,edx
      mov [esi+4],eax
      jnc @done3
      push esi
        @Loop3:
          mov eax,[esi+8]
          lea esi,esi+4
          add eax,1
          mov [esi+4],eax
        jz @Loop3 // safe to assume no more carry at the top
      pop esi
    @done3:
    lea esi,esi-4
  jmp @Loop1

  @done1:
  pop ecx;
  pop ebp;

@Ended:
  pop edi; pop esi; pop ebx;
@Stop:
end;

type
  pworkingSpace = ^tworkingSpace;
  tWorkingSpace = record

  end;

type
  tmux = 0..4;
  tbars = packed array[tmux] of pintar;

function mulrcp(const B; const realsize: integer; const bars: tbars): integer; overload;
// we don't know what type B is, it could be anything.
// the realsize in dword (4 bytes) fold. MUST be correctly informed!
const
  CAP32 = $100000000;
  PAT0 = $A3D70A3D;
  PAT1 = $70A3D70A;
  PAT2 = $3D70A3D7;
  PAT3 = $0A3D70A3;
  PAT4 = $D70A3D70;
  PATT = $A3D70A3D70A3D70A;
  rcvmux: array[tmux] of cardinal = (PAT0, PAT1, PAT2, PAT3, PAT4);

  function addstitch(const a, b: pintar; const k5pos: integer): integer; assembler;
  asm
  end;

  function throll(idx: pointer): longword;
  var
    B1: pintar;

  type
    tlr = (left, right);

  const
    rltimeout = 12345; // 12 seconds;

  var
    idright, idleft: cardinal;
    rlhandles: array[tlr] of thandle;
    rolls, rolls5, rcix5, idx5: integer;
    index: longword;
    p, a: pintar;
    dttop1: integer;
    newsize, bigsize: integer;
    params: tlrparams;
    numthr: integer;
    //const
    //  // max value that will not overflows multiplication
    //  rcvmin: array[tmux] of longword = (
    //    CAP32 div PAT0, CAP32 div PAT1,
    //    CAP32 div PAT2, CAP32 div PAT3, CAP32 div PAT4
    //    );
  begin

    index := integer(idx); // top % 5;

    // "top % 5 + 1" is identical with 1-based "(length + 4) % 5"
    // rolls and idx are always calculated *based on the original size*
    // rolls = (size + 4) mod 5 = (top mod 5) + 1

    rolls := (realsize + 4) mod 5; // how many 5th folds, 1-based

    idx5 := index * 5;
    rolls5 := rolls * 5;
    rcix5 := idx5 + rolls5;
    bigsize := rcix5 + realsize + 1; // maxsize. estimation only!

    B1 := bars[index];
    ordinals.fastFillChar(B1^, rcix5, #0);
    PInt64(@B1^[bigsize - 1])^ := 0; // clear topmost 2 dwords
    B1^[bigsize - 1] := 0;
    p := @B1^[idx5];
    ordinals.fastmove(A, p^, realsize * 4);

    p^[realsize] := 0;
    multex(p^, realsize - 1, rcvmux[index]);

    newsize := realsize + 1;
    if p^[realsize] = 0 then begin // multex not overflows
      dec(bigsize);
      dec(newsize);
    end;

    //if rolls > 0 then begin //incorrect! rolls always > 0

    with params do begin
      bleft := @B1^[rcix5];
      bright := @B1^[idx5];
      length := newsize;
      rounds := rolls;
    end;

    if rolls > 1 then begin

      // Illustration:
      // R |roll|rollroll|roll|roll|roll|roll|idx
      // -----------------------------------------
      // 1.                 gfedcba9876543210|
      // 2.            gfedcba9876543210     |
      // 3.       gfedcba9876543210          |
      // 4.  gfedcba9876543210               |
      //    --------------------------------------
      //          gfedcgfedcgfedcba9876543210|
      //               ba987ba9876543210     |
      //                    6543210          |

      newsize := bigsize - rcix5; // from 0 to g inclusive
      p := @(B1^[idx5 + newsize]); // at point R2:c or R3:7
      a := @(pintar(A)[newsize - rolls5]); //R1:c or R1.7

      inc(p); // give a slack for overflow
      ordinals.fastmove(a^, p^, rolls5 * 4); // fills the remaining overlap

      numthr := 1;
      if rolls > 2 then begin
        inc(numthr);
        rlhandles[left] := CreateThread(nil, 0, @thrl, @params, 0, idleft);
      end;
      rlhandles[right] := CreateThread(nil, 0, @thrr, @params, 0, idright);

      WaitForMultipleObjects(numthr, @rlhandles, true, rltimeout);
      CloseHandle(rlhandles[low(tlr)]);
      CloseHandle(rlhandles[high(tlr)]);
    end;
    Result := 0;
  end;

const
  timeout = 123456; // 123+ seconds

//  procedure fxadd(const A: pointer; const B: pointer);
//  begin
//  end;

var
  mx, nx: tmux;
  thrids: array[tmux] of cardinal;
  handles: array[tmux] of thandle;
  top: integer;
begin
  top := realsize - 1;
  nx := high(mx);
  if top < nx then
    nx := top;

  for mx := low(mx) to nx do
    handles[mx] := CreateThread(nil, 0, @throll, pointer(mx), 0, thrids[mx]);

  //handles[mx] := thandle(-1);

  WaitForMultipleObjects(nx, @handles, true, timeout);
  for mx := low(mx) to nx do
    CloseHandle(handles[mx]);

  for mx := nx - 1 downto low(mx) do
    addstitch(bars[nx], bars[mx], 0); // FIXTHIS!

  Result := 0;
end;

function _getRealSize(const p; const size: integer; const getTopInstead: boolean = false): integer; assembler;
asm // length is simply top + 1
  test eax,eax;
  movzx ecx,cl
  jz @Stop // give me null, please..
  and cl,1
  lea eax,eax+edx*4-4
  add edx,1
  sub edx,ecx
@Loop:
  mov ecx,[eax];
  sub edx,1
  //jle @Stop
  test ecx,ecx
  lea eax,eax-4
  jz @Loop
  mov eax,edx
@Stop:
end;

function toaster(const A; const size: integer): string;
const
  deca: packed array[0..100 + 10 + 10] of array[boolean] of Char = (
    '90', '91', '92', '93', '94', '95', '96', '97', '98', '99',
    '00', '01', '02', '03', '04', '05', '06', '07', '08', '09',
    '10', '11', '12', '13', '14', '15', '16', '17', '18', '19',
    '20', '21', '22', '23', '24', '25', '26', '27', '28', '29',
    '30', '31', '32', '33', '34', '35', '36', '37', '38', '39',
    '40', '41', '42', '43', '44', '45', '46', '47', '48', '49',
    '50', '51', '52', '53', '54', '55', '56', '57', '58', '59',
    '60', '61', '62', '63', '64', '65', '66', '67', '68', '69',
    '70', '71', '72', '73', '74', '75', '76', '77', '78', '79',
    '80', '81', '82', '83', '84', '85', '86', '87', '88', '89',
    '90', '91', '92', '93', '94', '95', '96', '97', '98', '99',
    '00', '01', '02', '03', '04', '05', '06', '07', '08', '09',
    #0#0
    );

var
  brx, bry: tbars;
  C, D: pintar;
  realLength, RLx4, mblock: integer;

const
  B: pintar = nil;
  strn: pChar = nil;
  itrev: integer = -1;

  procedure fillstrn(const pstrn: pChar; const num2: integer; const revindex: integer);
  asm
    lea edx,deca+edx*2
    lea eax,ecx*2+eax
    mov edx,[edx]
    mov [eax],dx
  end;

  procedure _init();
  var
    mx: tmux;

  begin
    B := nil;
    realLength := _getRealSize(A, size);
    if realLength < 3 then exit;
    RLx4 := realLength * 4;

    // max estimated working space:
    // 2 x (length + overflow + slack) of 4 bytes dword
    mblock := (realLength * 2 + 2 * 2 + 1) shr 1 shl 3;

    for mx := low(tmux) to high(tmux) do begin
      brx[mx] := nil;
      if realLength - 1 < mx then
        continue;
      GetMem(brx[mx], mblock);
      // zero tail and mid
      //PInt64(@brx[mx]^[mblock - 8])^ := 0;
      //PInt64(@brx[mx]^[mblock div 2])^ := 0;
      //ordinals.fastFillChar(brx[mx]^, mblock, #0);
    end;

    for mx := 0 to 2 do begin
      GetMem(bry[mx], mblock);
      //ordinals.fastFillChar(bry[mx]^, mblock, #0);
    end;

    B := bry[0];
    C := bry[1];
    D := bry[2];

    ordinals.fastMove(A, B^, RLx4);
    itrev := (realLength * 10 + 3) shr 2 shl 2;
    getmem(strn, itrev);
    //ordinals.fastFillChar(strn^, itrev shr 3, ' ');
    PInteger(strn + itrev - 4)^ := 0;
    itrev := itrev shr 1;
  end;

  procedure freemnil(var Obj); // we copied this from sysutils
  var tmp: tObject;
  begin
    tmp := tObject(Obj);
    pointer(Obj) := nil;
    tmp.free;
  end;

  procedure _done();
  var
    mx: tmux;
  begin
    if (B <> nil) then begin
      for mx := low(tmux) to high(tmux) do begin
        freemnil(brx[mx]);
        if mx < 3 then
          freemnil(bry[mx]);
      end;
      freemnil(strn);
    end;
  end;

  function _bin2dec: integer;
  var
    prevLen: integer;
    r: integer;
  begin
    result := 0;
    if realLength < 3 then exit;

    // duplicate B to C and D
    ordinals.fastMove(B^, C^, RLx4);
    ordinals.fastMove(B^, D^, RLx4);

    //ordinals.fastFillChar(D^[RLx4], mblock - RLx4, #0);
    C^[realLength] := 0;
    D^[realLength] := 0;

    mulrcp(D, realLength, brx);

    //truncate
    ordinals.fastMove(D^[RLx4], D^, RLx4 + 8);
    ordinals.fastFillChar(D^[RLx4], RLx4 + 8, #0);

    // update new length
    prevLen := realLength;
    realLength := _getRealSize(A, realLength);
    RLx4 := realLength * 4;

    //shiftright
    shrr6(D^, realLength);

    // save to B for next cycle
    ordinals.fastMove(D^, B^, RLx4);
    //clear topmost 2 dwords
    //PInt64(@B^[realLength])^ := 0;
    B^[realLength] := 0;

    mul100(D^, realLength, FALSE);
    _subme(C^, D^, prevLen, realLength);

    r := C^[0];

    if not r in [0..99] then begin
      if r < 0 then
        binc1(B^, realLength)
      else
        bdec1(B^, realLength);
    end;

    Result := r + 10;

    begin
    end;
  end;
var
  ret: integer;
  p: pChar;
begin
  //size := size and $07FFFFFF; // max pinteger array mask
  //realLength := _getLen(B, size);
  if realLength < 3 then begin
    if realLength < 1 then result := ''
    else if realLength < 2 then result := ordinals.uintoStr(PInteger(@A)^)
    else result := ordinals.uintoStr(PInt64(@A)^);
    exit;
  end;
  while realLength > 2 do begin
    ret := _bin2dec;
    dec(itrev);
    fillstrn(strn, ret, itrev);
  end;

  Result := ordinals.uintoStr(PInt64(@B)^);

  p := strn + itrev;
  Result := Result + string(PChar(p));

  _done;
end;

const
  kernel32 = 'kernel32.dll';

function WaitForSingleObject; external kernel32 name 'WaitForSingleObject';
function WaitForMultipleObjects; external kernel32 name 'WaitForMultipleObjects';
function CloseHandle; external kernel32 name 'CloseHandle';
function CreateThread; external kernel32 name 'CreateThread';

end.


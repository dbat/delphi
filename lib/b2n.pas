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
  tSize = 1..$effffff;

function toaster(const A; const size: tSize): string;

function WaitForSingleObject(hHandle: THandle; dwMilliseconds: longword): longword; stdcall; {$EXTERNALSYM WaitForSingleObject}
function WaitForMultipleObjects(nCount: integer; pHandles: pointer; bWaitAll: boolean; dwMilliseconds: longword): longword; stdcall; {$EXTERNALSYM WaitForMultipleObjects}
function CreateThread(SecurityAttributes: Pointer; StackSize: LongWord; ThreadFunc: TThreadFunc; Parameter: Pointer; CreationFlags: LongWord; var ThreadId: longword): Integer; stdcall; {$EXTERNALSYM CreateThread}
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
  mov edx,$66666667
  push eax
  mul edx
  pop eax
  shr edx,1
  lea edx,edx*4+edx
  sub eax,edx
  pop edx
end;

function _mod10(const n: integer): integer;
asm // all registers preserved
  push edx
  mov edx,$1999999A
  push eax
  mul edx
  pop eax
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
  mov edx,$66666667
  mov ecx,eax
  mul edx
  shr edx,1
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
  mov edx,$66666667
  mov ecx,eax
  mul edx
  shr edx,1
  shr edx,1
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
  mov edx,$66666667
  mov ecx,eax
  mul edx
  shr edx,1
  mov eax,edx
  lea edx,edx*4+edx
  shl eax,4
  sub ecx,edx
  shl eax,1
  pop edx;
  lea eax,eax*8+ecx
  pop ecx;
end;

function _divmod10b(const n: integer): integer;
// 24 bits quotient and low 8 bits remainder; byte size
asm // all registers preserved
  push ecx;
  push edx;
  mov edx,$6666667
  mov ecx,eax
  mul edx
  shr edx,1
  shr edx,1
  mov eax,edx
  lea edx,edx*4+edx
  shl eax,3
  sub ecx,edx
  shl eax,1
  sub ecx,edx
  shl eax,1
  pop edx;
  lea eax,eax*8+ecx
  pop ecx;
end;

function mul100(const A; const size: tSize; const writeover: boolean = false): integer;
// multiply by 100 of ONLY length size, if writeover is not allowed
// most significant dword might be truncated, returned in result
asm
  //test eax,eax; jz @STOP; // tired testing this,
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

function mul100_mr(const A: pintar): integer;
// multiply by 100, realloc mem if needed
asm
  //test eax,eax; jz @STOP; // tired testing this,
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

function multex(const A; const size_1: tSize; const multiplier: cardinal): integer;
 // multiply buffer by a number, return topmost dword on B after
 // multiplication. B length must be be at least 1 item more than
 // indicated by size_1 to accomodate overflow
asm
  push ebx; xor ebx,ebx;
  test edx,edx; jle @ended
  push esi; push edi;
  mov esi,A;
  mov edi,edx;
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
    //--- acces element above [size-1].
    //--- will thrown nasty error if B[size] is unallocated yet!
    mov [esi],ebx
    //------------------------------------------
  @done: pop edi; pop esi;
  @ended: mov eax,ebx; pop ebx;
end;

function multexEx(const A; const size_1: tSize; const multiplier: cardinal;
  const cutOverflow: boolean = false): longword;
 // multiply buffer by a number, return topmost dword on B after
 // multiplication. B length must be be at least 1 item more than
 // indicated by size_1 to accomodate overflow
 // -update: added argument cutOverflow to avoid writing pass over length
 // actually the correct behaviour is to *always* write overflow
 // (even if it is zero) like asm mul xxx will always overwrite edx
asm
  push ebx; xor ebx,ebx
  test edx,edx; jle @ended
  push esi; push edi
  mov esi,A;
  mov edi,edx;
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
  @last:
    movzx edx,cutOverflow
    test edx,edx
    jnz @done
    //--- acces element above [size-1].
    //--- will thrown nasty error if B[size] is unallocated yet!
    mov [esi],eax
    //------------------------------------------
  @done: pop edi; pop esi;
  @ended: mov eax,ebx; pop ebx;
end;

//  min
//	  sub b,a; sbb ecx,ecx
//	  and b,ecx; add a,b
//
//  max
//    xor ecx,ecx
//    sub a,b; adc ecx,-1
//    and a,ecx; add a,b
//
//
//  min           //  max
//  xor ecx,ecx;  //  xor ecx,ecx;
//  sub b,a       //  sub b,a
//  setge cl;     //  setl cl;  // the only difference
//  sub ecx,1;    //  sub ecx,1;
//  and b,ecx     //  and b,ecx;
//  add a,b       //  add a,b

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

function _subme(const S, substractor; const size1, size2: tSize): integer;
asm
  push esi;
  push edi;
  push ebx;
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
    jl @Loop2
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
  pop ebx; pop edi; pop esi;
end;

function _addme(const A, adder; const size1, size2: tSize): integer;
asm
  push esi; push edi; push ebx;
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
    jl @Loop2
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
  pop ebx; pop edi; pop esi;
end;

type
  plrparams = ^tlrparams;
  tlrparams = packed record
    bleft, bright: pinteger;
    length, rolls: integer;
  end;

procedure bincx(const B; const size: tSize; const num: integer); assembler;
asm
  push ebx
  mov ebx,[eax]
  lea eax,eax+4
  dec edx
  add ebx,ecx
  jl @Stop
  mov [eax],ebx
  jnb @Stop
  mov ecx,edx
  @Loop:
    mov edx,[eax]
    lea eax,eax+4
    adc edx,0
    dec ecx
    jl @Stop
    mov [eax-4],edx
    jc @Loop
  @Stop: pop ebx
end;

procedure binc1(const B; const size: tSize); assembler;
asm
  mov ecx,edx
  xor edx,edx
  cmp edx,1
@Loop:
  mov edx,[eax]
  lea eax,eax+4
  adc edx,0
  dec ecx
  jl @Stop
  mov [eax-4],edx
  jc @Loop
@Stop:
end;

procedure bdec1(const B; const size: tSize); assembler;
asm
  mov ecx,edx
  xor edx,edx
  cmp edx,1
@Loop:
  mov edx,[eax]
  lea eax,eax+4
  sbb edx,0
  dec ecx
  jl @Stop
  mov [eax-4],edx
  jc @Loop
@Stop:
end;

procedure _double(const A; const size: tSize); overload;
//no checking - will overwrite only if carry (no zero overwrite if not carry)
asm
  push ebx; push esi;
  mov ebx,[eax]
  mov esi,[eax+4]
  shl ebx,1
@Loop:
  dec edx
  mov ecx,[eax+8]
  jl @Stop
  mov [eax],ebx
  mov ebx,esi
  mov esi,ecx
  lea eax,eax+4
  rcl ebx,1
  jmp @Loop
  setc cl
  jnb @Stop
  movzx ecx,cl
  mov [eax],ecx
@Stop: pop esi; pop ebx;
end;

procedure _double(const A; const size: tSize; const cutOverflow: boolean); overload;
asm
  push ebx; push esi; push edi;
  mov ebx,[eax]
  mov esi,[eax+4]
  shl ebx,1
@Loop:
  dec edx
  mov edi,[eax+8]
  jl @done
  mov [eax],ebx
  mov ebx,esi
  mov esi,edi
  lea eax,eax+4
  rcl ebx,1
  jmp @Loop
  setc bl
  jnc @done
  or cl,bl
  movzx ebx,bl
  jnz @done
  mov [eax],ebx
@done: pop edi; pop esi; pop ebx;
end;

procedure shrr6(const B; const size: tSize); assembler;
const
  SHRCOUNT = 6;
asm
  test eax,eax;
  push ebx; sete bl;
  sub edx,1;
  movzx ebx,bl;
  push esi; setl bh;
  push edi;
  test ebx,ebx;

  jnz @Ended

  mov esi,edx;
  mov edx,[eax];
  mov ebx,[eax+4];
  shr edx,SHRCOUNT
  mov edi,ebx;
  shl ebx,32-SHRCOUNT

  test esi,esi; jz @done2
  or edx,ebx

  @Loop:
    sub esi,1;jz @done;
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
  @Ended: pop edi; pop esi;
   pop ebx;
end;

procedure shrr(const B; const size: tSize; const count: byte); overload; assembler;
asm
  test eax,eax;
  push ebx; sete bl;
  sub edx,1;
  movzx ebx,bl;
  push esi; setl bh;
  push edi;
  test ebx,ebx;

  movzx ecx,cl;
  jnz @Ended
  mov ch,32;
  push ecx;

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
   pop ecx;
@Ended:
   pop edi; pop esi;
   pop ebx;
//  @Stop:
end;

{

  k5pos, calculated after multex (based on new size/length after multex).
  if rolls pass over the length, the k5pos value will never be changed anymore
  the highest value (actually the lowest) is the one right before rolls pass over the length

  we can't based on index/order it's already invalidated by multex
  caution: the rolls is still based on the original length, not the new length after multex

  the rolls value can not be determined by the current stage, it must be suplied

  k5pos = newsize - rolx5
  if k5pos is negative then it rolls pass over the length
  if k5pos is zero then it rolls pass over the length, right after new length

  if k5pos is zero then k5pos value is: 5
  if k5pos is negative then k5pos value is: new.length % 5
  both value can be retrieved as one calculation: (new.length - 1) % 5 + 1

  ----------------------------------------------------------------------------

  "n mod x" is equal with: "(n - 1) mod x + 1", except: 0 become x

  (n + x - 1) mod x is 0-based of 1-based version of "(n - 1) mod x + 1"
  that seems obvious, or perhaps not. anyway, we often found that
  correlation in calculating array length versus index
}

function thrl(params: plrparams): integer; stdcall;
  //  top = length - 1;
  //  rounds = top % 5
  //  k5pos = length - rounds * 5 + 5;
  //  if (k5pos < 1) k5pos = (top % 5) + 1;
  //  for (i = top; i >= k5pos + 5; i--) {
  //    for (j = i - 5; j >= k5pos; j -= 5) {
  //  ...
asm
  mov ecx,params.tlrparams.rolls
  push ebx;
  xor ebx,ebx
  cmp ecx,2
  mov edx,params.tlrparams.length
  push esi;
  push edi;
  setle bl
  cmp edx,5
  lea esi,eax+edx*4-4 // esi = @A[top]
  mov edi,params.tlrparams.bleft
  setle bh
  mov eax,edx         // eax now length
  test ebx,ebx
  mov ebx,edx
  jnz @Ended

  // ((the rounds in code sample here is zero based))
  // k5 = (top1 + 1) - rounds * 5 + 5;
  // if (k5 < 1) k5 = top1 % 5 + 1;
  //
  // k5pos = length - (rounds - 1) * 5;
  // k5pos = length - rounds * 5 + 5;
  // if (k5pos < 1) k5pos = top % 5 + 1;

  lea ecx,ecx*4+ecx   // rolls * 5 // 1-based rounds
  sub eax,ecx         // length - rolls * 5
  jg @gogon           // ? (k5pos > 0) ?
    lea eax,edx-1     // top = length -1
    call _mod5        // eax = top % 5
    lea eax,eax+1     // eax = top % 5 + 1 => k5pos
  @gogon:
  lea edi,edi+eax*4+5*4  // edi points to A[k5pos+5]

  //  for (i = top; i >= k5pos + 5; i--) {
  //    for (j = i - 5; j >= k5pos; j -= 5) {

  @Loop1:
    cmp esi,edi
    jl @L1done
    mov eax,[esi]
    push esi
    sub esi,20
    sub edi,20
    xor edx,edx
      @Loop2:
        cmp esi,edi
        jl @L2done
        mov ebx,[esi]
        sub esi,20
        add eax,ebx
        adc edx,0
      jmp @Loop2
    @L2done:
    pop esi
    mov ebx,[esi+4] // overview next overflow
    test edx,edx    // does edx carry over extra?
    mov [esi],eax   // store back addition summary
    jz @gone
      add edx,ebx      // we've already got values for the current round
      mov eax,[esi+8]  // get even more overview
      mov [esi+4],edx  // save overflow1
      jnc @gone
      push esi
        add esi,8      // jump 2 steps
        @Loop3:
          add eax,1       // already have it 2 steps in advance
          mov edx,[esi+4] // next..
          mov [esi],eax   // save
          mov eax,edx     // roundtable fills cpu ticks
          lea esi,esi+4   // inc counter
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

function thrr(params: plrparams): integer; stdcall;
asm
  mov ecx,params.tlrparams.rolls
  push ebx;
  cmp ecx,1
  mov edx,params.tlrparams.length
  setle bl
  mov eax,params.tlrparams.bright
  cmp edx,5
  movzx ebx,bl
  push esi
  setle bh
  push edi

  lea esi,eax+edx*4-4  // esi point to B[top]
  lea edi,eax+20       // edi point to B[5]
  lea eax,edx-1        // eax = top = length - 1
  test ebx,ebx
  mov edx,$66666667    // 2/5
  jnz @Ended
  mul edx
  sub ecx,1
  shr edx,1

  //min (ecx,edx)
  sub edx,ecx;
  sbb ebx,ebx;
  and edx,ebx;
  add ecx,edx;

  xor edx,edx
  mov [esi+4],edx; // clear topmost dword

  push ecx

  @Loop1:
    cmp esi,edi;
    mov ecx,[esp]
    jl @doneL1
    mov eax,[esi]
    push esi
    sub esi,20
    xor edx,edx
    @Loop2:
      sub ecx,1;
      mov ebx,[esi]
      lea esi,esi-20
      jl @doneL2
      add eax,ebx
      adc edx,0
      jmp @Loop2
    @doneL2:
    pop esi
    mov ebx,[esi+4] // fetch next dword for overflow
    test edx,edx    // overflows?
    mov [esi],eax
    jz @done3
      add edx,ebx     // add overflow with one got already in ebx
      mov eax,[esi+8] // fetch again next dword2 for overflow
      mov [esi+4],edx // put it in
      jnc @done3
      push esi
        add esi,8
        @Loop3:
          add eax,1       // remember we've alredy got this?
          mov edx,[esi+4] // yeah- next offset still 4/8
          mov [esi],eax
          mov eax,edx
          lea esi,esi+4   //
        jz @Loop3 //proceed if carry
      pop esi
    @done3:
    sub esi,4
  jmp @Loop1

  @doneL1:
  pop ecx;
@Ended:
  pop edi; pop esi; pop ebx;
@Stop:

end;

function thrr_old(params: plrparams): integer; stdcall;

// this is a time critical routine, no extensive checking will be done here.
// make sure there's at least 1 dword more allocated memory for overflow.
// rounds is calculated based on the original length NOT by this length.
asm //

  mov ecx,params.tlrparams.rolls
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
  lea esi,eax+edx*4-4  // esi = @B[top]
  test ebx,ebx
  mov ebx,ecx          // ebx now rolls count
  lea ecx,edx-5        // counter = length - 5
  jnz @Ended

  xor edx,edx
  push ebp;
  push ebx;            // save rolls
  mov [esi+4],edx; // clear topmost dword

  //  for (i = top; i >= 5; i--) {
  //    r = rounds;
  //    for (j = i - 5; j >= 0; j -= 5) {
  //      if (--r < 1) break;

  @Loop1:
    sub ecx,1
    mov ebp,[esp]
    jl @done1
    push ecx
    add ecx,5  // have to be raised up back, for inner loop
    xor edx,edx
    mov eax,[esi]
    lea edi,esi-20  // edi => j = i - 5
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
    sub esi,4
  jmp @Loop1

  @done1:
  pop ecx;
  pop ebp;

@Ended:
  pop edi; pop esi; pop ebx;
@Stop:
end;

type
  tmux = 0..4;

type
  pblog = ^tblog;
  tblog = packed record
    order: tmux;
    size: integer;
    Bin, Log: pintar;
  end;

type
  tpair = (left, right);

{**********************************************************}
function throll(blog: pblog): longword;
const
  CAP32 = $100000000;
  PAT0 = $A3D70A3D;
  PAT1 = $70A3D70A;
  PAT2 = $3D70A3D7;
  PAT3 = $0A3D70A3;
  PAT4 = $D70A3D70;
  PATT = $A3D70A3D70A3D70A;
  rcvmux: array[tmux] of cardinal = (PAT0, PAT1, PAT2, PAT3, PAT4);

const
  rltimeout = 12345; // 12 seconds;

type
  tpairhandler = record
    handles: packed array[tpair] of thandle;
    ids: packed array[tpair] of longword;
  end;

var
  lrhandler: tpairhandler;
  rolls, rolx5, rcix5, idx5: integer; //, k5pos: integer;
  index: tmux;
  p, q: pintar;
  newsize, bigsize: integer;
  params: tlrparams;
  numthr: integer;

var
  B: pintar;
  realsize: integer;

begin
  index := blog^.order; // top % 5;
  realsize := blog^.size;
  B := blog^.Log;

  idx5 := index * 5;

  // "top % 5 + 1" is identical with 1-based "(length + 4) % 5"
  // rolls and order are always calculated *based on the original size before multex*
  // the value that should be calculated after multex is k5pos
  //
  // rolls == (size + 4) div 5; // how many 5th folds, 1-based

  // I always forgot:
  // ****************************************************
  // there is no connection between rolls and index/order
  // ****************************************************

  // index/order == (realsize - 1) % 5, or: real_top % 5
  // rolls == (realsize + 4) div 5; //it's div not modulo!
  // rolls == (real_top + 5) div 5; //it's div not modulo!

  rolls := (realsize + 4) div 5;
  rolx5 := rolls * 5;

  rcix5 := idx5 + rolx5; // two blanks prefixes: rolls and order
  bigsize := rcix5 + realsize + 1; // maxsize. estimation only!
  ordinals.fastFillChar(B^, idx5, #0); // clear prefix

  p := @B[bigsize - 1];
  pint64(p)^ := 0; // clear 2 dwords pass over length

  p := @B[idx5];
  ordinals.fastmove(blog.Bin^, p^, realsize * 4);
  //pint64(p[realsize])^ := 0;

  newsize := realsize + 1;
  if multex(p^, realsize, rcvmux[index]) = 0 then begin
    //dec(bigsize);
    dec(newsize);
  end;
  pint64(p[newsize])^ := 0;

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
  if rolls > 1 then begin
    //newsize := bigsize - rcix5; // from 0 to g inclusive
    q := @B[idx5 + newsize]; // at point R2:c or R3:7
    p := @B[newsize - rolx5]; // at point R1:c or R1.7

    inc(p); // give a slack for yet another overflow
    ordinals.fastmove(p^, q^, rolx5 * 4); // fills the remaining overlap

    with params do begin
      bleft := @B^[rcix5];
      bright := @B^[idx5];
      length := newsize;
      rolls := rolls;
    end;

    numthr := 1;
    if rolls > 2 then begin
      inc(numthr);
      //thrl(@params);
      lrhandler.handles[left] := CreateThread(nil, 0, @thrl, @params, 0, lrhandler.ids[left]);
    end;

    //thrr(@params);
    lrhandler.handles[right] := CreateThread(nil, 0, @thrr, @params, 0, lrhandler.ids[right]);

    {*****************************************************************}
    WaitForMultipleObjects(numthr, @lrhandler.handles, true, rltimeout);
    CloseHandle(lrhandler.handles[left]);
    CloseHandle(lrhandler.handles[right]);
    {*****************************************************************}

    //bincx(B[k5pos + 1], size - k5pos, B^[k5pos]);
    //ordinals.fastMove(B[k5pos + 1], B[k5pos], size - k5pos);
  end;

  Result := 0;
end;

function addstitch(const B: pintar; const size: tSize; const k5pos: integer): integer;
begin
  bincx(B[k5pos + 1], size - k5pos, B^[k5pos]);
  ordinals.fastMove(B[k5pos + 1], B[k5pos], size - k5pos);
  Result := 0;
end;

type
  tbars = packed array[tmux] of pintar;

function mulrcp(const B; const realsize: tSize; const bars: tbars): integer; overload;
// we don't know what type B is, it could be anything.
// the realsize is in dword (4 bytes) fold, it MUST be correctly informed!
// expect size > 2, given otherwise will reset state
//
// this function acts as initializer/coordinator only,
// the real work done under separate order threads
const
  timeout = 135790; // 135+ seconds

type
  tmuxhandles = packed array[tmux] of thandle;
  tmuxids = packed array[tmux] of longword;

  tmuxhandlers = packed record
    handles: tmuxhandles;
    ids: tmuxids;
  end;

var
  mx, hix: tmux;
  blogs: array[tmux] of tblog;
  xhandlers: tmuxhandlers;

begin
  Result := -1;
  if realSize < 3 then
    case integer(realSize) of
      0..2: begin
          ordinals.fastfillchar(blogs, sizeof(blogs), #0);
          //ordinals.fastfillchar(xhandlers, sizeof(xhandlers), #0);
          exit;
        end;
    else
      //WaitForMultipleObjects(hix, @xhandlers.handles, true, timeout);
      //for mx := low(mx) to hix do begin
      //  CloseHandle(xhandlers.handles[mx]);
      //end;
      exit;
    end;

  hix := pred(realsize);
  if hix > high(mx) then
    hix := high(mx);

  if blogs[0].Bin = nil then
    for mx := 0 to hix do
      with blogs[mx] do begin
        order := mx;
        size := realSize;
        Bin := @B;
        Log := bars[mx];
      end;

  for mx := low(mx) to hix do begin
    //throll(@blogs[mx]);
    xhandlers.handles[mx] := CreateThread(nil, 0, @throll, @blogs[mx], 0, xhandlers.ids[mx]);
  end;

{*****************************************************************}
  WaitForMultipleObjects(hix, @xhandlers.handles, true, timeout);
  for mx := low(mx) to hix do begin
    CloseHandle(xhandlers.handles[mx]);
  end;
{*****************************************************************}

  Result := 0;
end;

function _getRealSize(const p; const size: tSize; const getTopInstead: boolean = false): integer; assembler;
asm // length is simply top + 1
  test eax,eax; jz @Stop // give me null, please..
  movzx ecx,cl
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

function toaster(const A; const size: tSize): string;
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
    realLength := 0;
    mulrcp(B, realLength, brx); // clean mulrcp state

    realLength := _getRealSize(A, size);
    if realLength < 3 then exit;
    RLx4 := realLength * 4;

    // max estimated working space:
    // 2 x (length + overflow + slack) of 4 bytes dword
    mblock := (realLength * 2 + 2 * 2 + 1) shr 1 shl 3;

    for mx := low(tmux) to high(tmux) do begin
      brx[mx] := nil;
      if mx > pred(realLength) then
        continue;
      GetMem(brx[mx], mblock);
      ordinals.fastFillChar(brx[mx]^, mblock, #0);
    end;

    for mx := 0 to 2 do begin
      GetMem(bry[mx], mblock);
      ordinals.fastFillChar(bry[mx]^, mblock, #0);
    end;

    B := bry[0]; C := bry[1]; D := bry[2];

    ordinals.fastMove(A, B^, RLx4);

    itrev := (realLength * 10 + 3) shr 2 shl 2;

    getmem(strn, itrev);
    //ordinals.fastFillChar(strn^, itrev shr 3, ' ');
    PInteger(strn + itrev - 4)^ := 0;
    itrev := itrev shr 1;
  end;

  procedure _done();
    procedure freemnil(var Obj); // we copied this from sysutils
    var tmp: tObject;
    begin
      tmp := tObject(Obj);
      pointer(Obj) := nil;
      tmp.free;
    end;
  var
    mx: tmux;
  begin
    if (B <> nil) then begin
      for mx := low(tmux) to high(tmux) do begin
        freemnil(brx[mx]);
        if mx < 3 then // B, C and D
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
    ordinals.fastMove(D^[RLx4], D^, mblock - RLx4);
    ordinals.fastFillChar(D^[RLx4], mblock - RLx4, #0);

    // update new length
    prevLen := realLength;
    realLength := _getRealSize(A, realLength);
    RLx4 := realLength * 4;

    //shiftright
    shrr6(D^, realLength);

    // save to B for next cycle
    ordinals.fastMove(D^, B^, RLx4);
    //clear topmost 2 dwords
    //PInt64(B[realLength])^ := 0;
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


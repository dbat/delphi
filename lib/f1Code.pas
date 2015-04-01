unit f1Code;
{$WEAKPACKAGEUNIT ON}

{
 * The Original Code is Fastcode
 * The Initial Developer of the Original Code is Fastcode
}

interface

function f1Pos(const SubStr, Str: string): integer; register; overload;
function f1PosEx(const SubStr, Str: string; Offset: integer = 1): integer; register; overload;
function f1PosIEx(const SubStr, Str: string; Offset: Integer = 1): Integer; register; overload;
function f1CompareText(const S1, S2: string): Integer; register; overload;

procedure f1FillChar(var Dest; const Count: Integer; const Value: char); register; overload;
procedure f1Move(const Source; var Dest; Count: Integer); register; overload;
function f1CompareMem(P1, P2: pointer; Length: integer): boolean; register; overload;

function f1StrComp(const P1, P2: PChar): integer; register; overload;
function f1StrIComp(const P1, P2: PChar): integer; register; overload;
function f1StrLIComp(const Str1, Str2: PChar; MaxLen: Cardinal): Integer; overload;
//function broken_f1StrLIComp(const P1, P2: PChar; MaxLen: Cardinal): integer; register; overload;

implementation
uses CxGLOBAL;                          //upcase table Lookup

function CharPosEx(const Char: Char; const Str: string; Occurrence: Integer = 1; StartPos: Integer = 1): Integer;
assembler asm
  test edx,edx; jz @@NotFoundExit {Exit if SourceString = ''}
  cmp ecx,1; jl @@NotFoundExit {Exit if Occurence < 1}
  mov ebp,StartPos {Safe since EBP automatically saved}
  sub ebp,1; jl @@NotFoundExit {Exit if StartPos < 1}
  push ebx; add ebp,edx
  mov ebx,[edx-4]; add ebx,edx
  sub ebp,ebx; jge @@NotFound {Traps Zero Length Non-Nil String}
@@Loop: cmp al,[ebx+ebp]; je @@Check1
@@Next0: cmp al,[ebx+ebp+1]; je @@Check2
@@Next2: cmp al,[ebx+ebp+2]; je @@Check3
@@Next3: cmp al,[ebx+ebp+3]; je @@Check4
@@Next4: add ebp,4; jl @@Loop
@@NotFound: pop ebx
@@NotFoundExit: xor eax,eax; jmp @@Stop
@@Check4: sub ecx,1; jnz @@Next4; add ebp,3; jge @@NotFound; jmp @@SetResult
@@Check3: sub ecx,1; jnz @@Next3; add ebp,2; jge @@NotFound; jmp @@SetResult
@@Check2: sub ecx,1; jnz @@Next2; add ebp,1; jge @@NotFound; jmp @@SetResult
@@Check1: sub ecx,1; jnz @@Next0; @@SetResult: lea eax,[ebx+ebp+1];
  sub eax,edx; pop ebx
@@Stop:
  end;

function CharPos(const Char: Char; const Str: string; const StartPos: Integer = 1): Integer;
assembler asm
  test edx,edx; jz @@NotFoundExit
  cmp ecx,1; jl @@NotFoundExit
  mov ebp,StartPos {ebp is automatically saved}
  sub ebp,1; jl @@NotFoundExit {exit if StartPos < 1}
  push ebx; add ebp,edx
  mov ebx,[edx-4]; add ebx,edx
  sub ebp,ebx; jge @@NotFound {traps zero length non-nil string}
@@Loop: cmp al,[ebx+ebp]; je @@Check1
@@Next0: cmp al,[ebx+ebp+1]; je @@Check2
@@Next2: cmp al,[ebx+ebp+2]; je @@Check3
@@Next3: cmp al,[ebx+ebp+3]; je @@Check4
@@Next4: add ebp,4; jl @@Loop
@@NotFound: pop ebx
@@NotFoundExit: xor eax,eax; jmp @@Stop
@@Check4: sub ecx,1; jnz @@Next4; add ebp,3; jge @@NotFound; jmp @@SetResult
@@Check3: sub ecx,1; jnz @@Next3; add ebp,2; jge @@NotFound; jmp @@SetResult
@@Check2: sub ecx,1; jnz @@Next2; add ebp,1; jge @@NotFound; jmp @@SetResult
@@Check1: sub ecx,1; jnz @@Next0; @@SetResult: lea eax,[ebx+ebp+1]
  sub eax,edx; pop ebx
@@Stop:
  end;

function f1Pos(const SubStr, Str: string): Integer; overload asm
  push ebx; push esi; add esp,-16
  test eax,eax; jz @NotFound
  test edx,edx; jz @NotFound
  mov ebx,[eax-4]; mov esi,[edx-4]
  cmp esi,ebx; jl @NotFound
  test ebx,ebx; jle @NotFound
  dec ebx; add esi,edx; add edx,ebx
  mov [esp+8],esi; add eax,ebx
  mov [esp+4],edx; neg ebx
  movzx ecx,byte ptr [eax]
  mov [esp],ebx; jnz @FindString

  sub esi,2; mov [esp+12],esi

@FindChar2:
  cmp cl,[edx]; jz @Matched0
  cmp cl,[edx+1]; jz @Matched1
  add edx,2
  cmp edx,[esp+12]; jb @FindChar4
  cmp edx,[esp+8]; jb @FindChar2

@NotFound: xor eax,eax; jmp @Exit

@FindChar4:
  cmp cl,[edx]; jz @Matched0
  cmp cl,[edx+1]; jz @Matched1
  cmp cl,[edx+2]; jz @Matched2
  cmp cl,[edx+3]; jz @Matched3
  add edx,4
  cmp edx,[esp+12]; jb @FindChar4
  cmp edx,[esp+8]; jb @FindChar2
  xor eax,eax; jmp @Exit

@FindString: sub esi,2; mov [esp+12],esi
@FindString2: cmp cl,[edx]; jz @Test0
@NotMatched0: cmp cl,[edx+1]; jz @Test1

@NotMatched1:
  add edx,2
  cmp edx,[esp+12]; jb @FindString4
  cmp edx,[esp+8]; jb @FindString2
  xor eax,eax; jmp @Exit

@FindString4:
  cmp cl,[edx]; jz @Test0
  cmp cl,[edx+1]; jz @Test1
  cmp cl,[edx+2]; jz @Test2
  cmp cl,[edx+3]; jz @Test3
  add edx,4
  cmp edx,[esp+12]; jb @FindString4
  cmp edx,[esp+8]; jb @FindString2
  xor eax,eax; jmp @Exit

@Test3: add edx,2
@Test1: mov esi,[esp]

@Loop1:
  movzx ebx,word ptr [esi+eax]
  cmp bx,word ptr [esi+edx+1]; jnz @NotMatched1
  add esi,2; jl @Loop1

@Matched1:
  add edx,2; xor eax,eax
  cmp edx,[esp+8]; ja @Exit1

@RetCode1: mov eax,edx; sub eax,[esp+4]
@Exit1: add esp,16; pop esi; pop ebx; ret

@Matched3:
  add edx,4; xor eax,eax
  cmp edx,[esp+8]; jbe @RetCode1
  jmp @Exit1

@Matched2: add edx,3; jmp @RetCode0
@Test2: add edx,2
@Test0: mov esi,[esp]

@Loop0:
  movzx ebx,word ptr [esi+eax]
  cmp bx,word ptr [esi+edx]; jnz @NotMatched0
  add esi,2; jl @Loop0

@Matched0: inc edx
@RetCode0: mov eax,edx; sub eax,[esp+4]
@Exit: add esp,16; pop esi; pop ebx
end;

function f1PosEx(const SubStr, Str: string; Offset: integer): integer; overload asm
  test eax,eax; jz @zero
  test edx,edx; jz @zero
  dec ecx; jl @zero
  push esi; push ebx

  mov esi,[edx-4]         //Length(Str)
  mov ebx,[eax-4]         //Length(Substr)
  sub esi,ecx             //effective length of Str
  add edx,ecx             //addr of the first char at starting position
  cmp esi,ebx; jl @Past   //jump if EffectiveLength(Str)<Length(Substr)
  test ebx,ebx; jle @Past //jump if Length(Substr)<=0

  add esp,-12
  add ebx,-1              //Length(Substr)-1
  add esi,edx             //addr of the terminator
  add edx,ebx             //addr of the last char at starting position
  mov [esp+8],esi         //save addr of the terminator
  add eax,ebx             //addr of the last char of Substr
  sub ecx,edx             //-@Str[Length(Substr)]
  neg ebx                 //-(Length(Substr)-1)
  mov [esp+4],ecx         //save -@Str[Length(Substr)]
  mov [esp],ebx           //save -(Length(Substr)-1)
  movzx ecx,byte ptr[eax] //the last char of Substr

@SmallLoop: cmp cl,[edx]; jz @Test0
@AfterTest0: cmp cl,[edx+1]; jz @TestT
@AfterTest1: add edx,8; cmp edx,[esp+8]; jae @EndSmall

@MainLoop:
  cmp cl,[edx-6]; jz @Test6
  cmp cl,[edx-5]; jz @Test5
  cmp cl,[edx-4]; jz @Test4
  cmp cl,[edx-3]; jz @Test3
  cmp cl,[edx-2]; jz @Test2
  cmp cl,[edx-1]; jz @Test1
  cmp cl,[edx]; jz @Test0
  cmp cl,[edx+1]; jz @TestT
  add edx,8; cmp edx,[esp+8]; jb @MainLoop

@EndSmall: add edx,-6; cmp edx,[esp+8]; jb @SmallLoop
@Exit: add esp,12
@Past: pop ebx; pop esi
@zero:  xor eax,eax; ret

@Test6: add edx,-2
@Test4: add edx,-2
@Test2: add edx,-2
@Test0: mov esi,[esp]; test esi,esi; jz @Found0

@Loop0:
  movzx ebx,word ptr [esi+eax]
  cmp bx,word ptr [esi+edx]; jnz @AfterTest0
  cmp esi,-2; jge @Found0
  movzx ebx,word ptr [esi+eax+2]
  cmp bx,word ptr [esi+edx+2]; jnz @AfterTest0
  add esi,4; jl @Loop0

@Found0:
  mov eax,[esp+4]
  add edx,1; add esp,12; add eax,edx
  pop ebx; pop esi; ret

@Test5: add edx,-2
@Test3: add edx,-2
@Test1: add edx,-2
@TestT: mov esi,[esp]; test esi,esi; jz @Found1

@Loop1:
  movzx ebx,word ptr [esi+eax]
  cmp bx,word ptr [esi+edx+1]; jnz @AfterTest1
  cmp esi,-2; jge @Found1
  movzx ebx,word ptr [esi+eax+2]
  cmp bx,word ptr [esi+edx+3]; jnz @AfterTest1
  add esi,4; jl @Loop1

@Found1:
  mov eax,[esp+4]; add edx,2
  cmp edx,[esp+8]; ja @Exit
  add esp,12; add eax,edx
  pop ebx; pop esi
end;

function f1PosIEx(const SubStr, Str: string; Offset: Integer): Integer; overload asm
  push ebp; mov ebp,esp; sub esp,24
  push ebx; push esi; push edi; push ebp
  xor ebx,ebx
  mov [esp+$20],ebx
  mov esi,edx; mov edi,eax
  mov [esp+$1C],ecx
  test ecx,ecx; jle @Exit // (Offset <= 0)?
  test esi,esi; jz @Exit // S = ''
  mov eax,[esi-4]; mov [esp+$10],eax //StrLength := PInteger(Integer(S)-4)^;
  test eax,eax; jle @Exit // (StrLength <= 0)?
  test edi,edi; jz @Exit // (SubStr = '')?
  mov eax,[edi-4]; mov [esp+$14],eax //SubStrLength := PInteger(Integer(SubStr)-4)^;
  test eax,eax; jle @Exit // (SubStrLength <= 0)?

  mov eax,ecx; mov edx,[esp+$10]
  cmp ecx,edx; jnle @Exit // (Offset > StrLength)?

  //if (StrLength - Integer(Offset) + 1 < SubStrLength) then //No room for match
  sub edx,eax; inc edx
  cmp edx,[esp+$14]; jl @Exit
  //SetLength(SubStrUpper,SubStrLength);
  lea eax,[esp+$20]; mov edx,[esp+$14]
  call System.@LStrSetLength

  mov eax,[esp+$20] //pSubStrUpper := PChar(SubStrUpper);

  xor eax,eax //CharNo := 0;
  mov ecx,offset cxGLOBAL.UPCASETABLE // [LookUpTable]
  mov ebx,[esp+$20]; mov ebp,[esp+$14]
@UpperCaseLoopStart:
  //pSubStrUpper[CharNo] := LookUpTable[Ord(SubStr[CharNo+1])];
  movzx edx,byte[edi+eax]; movzx edx,byte[ecx+edx]
  mov [ebx+eax],dl
  inc eax //Inc(CharNo);
  cmp eax,ebp; jl @UpperCaseLoopStart //until(CharNo >= SubStrLength);

  mov eax,[esp+$1C] //I1 := Offset;
  mov ebx,dword ptr cxGLOBAL.UPCASETABLE// [LookUpTable]
  dec esi
  mov ebp,[esp+$20]
@OuterLoopStart:
  //UpperChar := LookUpTable[Ord(S[I1])];
  movzx edx,byte[esi+eax]
  mov ebx,offset cxGLOBAL.UPCASETABLE// [LookUpTable]
  movzx ecx,byte[ebx+edx]
  //if SubStrUpper[1] = UpperChar then
  mov edx,ebp
  cmp cl,byte[edx]; jnz @IfEnd1
  //if I1 + SubStrLength - 1 > StrLength then
  mov edx,[esp+$14]; add edx,eax
  dec edx
  cmp edx,[esp+$10]; jnle @ExitNoMatch
  //if SubStrLength > 1 then
  cmp dword ptr [esp+$14],1; jle @IfEnd2
  mov edx,1 //I2 := 1;
@InnerLoopStart:
  //UpperChar := LookUpTable[Ord(S[I1+I2])];
  lea ecx,[edx+eax]
  movzx ecx,byte[esi+ecx]
  mov ebx,offset cxGLOBAL.UPCASETABLE// [LookUpTable]
  movzx ecx,byte[ebx+ecx]
  //if UpperChar <> SubStrUpper[I2+1] then
  mov ebx,ebp
  cmp cl,[ebx+edx]; jnz @IfEnd1
  inc edx //Inc(I2);
  //if (I2 >= SubStrLength) then
  cmp edx,[esp+$14]; jl @InnerLoopStart
  mov ebx,eax; jmp @Exit //Result := I1;
@IfEnd2: mov ebx,eax; jmp @Exit //Result := I1;

@IfEnd1: inc eax //Inc(I1);
  //until(I1 > StrLength);
  cmp eax,[esp+$10]; jle @OuterLoopStart
@ExitNoMatch: xor ebx,ebx
@Exit: lea eax,[esp+$20]; call System.@LStrClr
  mov eax,ebx
  pop ebp; pop edi; pop esi; pop ebx
  mov esp,ebp; pop ebp
end;

procedure f1FillChar(var Dest; const Count: Integer; const Value: char); overload asm {Size = 153 Bytes}
  cmp edx,32; mov ch,cl; {Copy Value into both Bytes of CX}
  jl @@Small
  {Fill First 8 Bytes}
  mov [eax  ],cx; mov [eax+2],cx
  mov [eax+4],cx; mov [eax+6],cx
  sub edx,16
  fld qword ptr [eax]
  fst qword ptr [eax+edx] {Fill Last 16 Bytes}
  fst qword ptr [eax+edx+8]
  mov ecx,eax; and ecx,7 {8-Byte Align Writes}
  sub ecx,8
  sub eax,ecx; add edx,ecx; add eax,edx
  neg edx
@@Loop:
  fst qword ptr [eax+edx] {Fill 16 Bytes per Loop}
  fst qword ptr [eax+edx+8]
  add edx,16; jl @@Loop
  ffree st(0)
  ret
  nop; nop; nop
@@Small: test edx,edx; jle @@Done
  mov [eax+edx-1],cl {Fill Last Byte}
  and edx, not 1 {No. of Words to Fill}
  neg edx
  lea edx,[@@SmallFill + 60 + edx * 2]
  jmp edx
  nop; nop {Align Jump Destinations}
@@SmallFill:
  mov [eax+28],cx; mov [eax+26],cx
  mov [eax+24],cx; mov [eax+22],cx
  mov [eax+20],cx; mov [eax+18],cx
  mov [eax+16],cx; mov [eax+14],cx
  mov [eax+12],cx; mov [eax+10],cx
  mov [eax+ 8],cx; mov [eax+ 6],cx
  mov [eax+ 4],cx; mov [eax+ 2],cx
  mov [eax   ],cx
  ret {DO NOT REMOVE - This is for Alignment}
@@Done:
end;

procedure f1Move(const Source; var Dest; Count: Integer);
//John O'Harrow fast Move (requires Floating Point Unit)
assembler asm
  cmp eax,edx; je @@Exit {Source = Dest}
  cmp ecx,32; ja @@LargeMove {Count > 32 or Count < 0}
  sub ecx,8; jg @@SmallMove
@@LessThan8BytesMove: jmp dword ptr [@@JumpTable+32+ecx*4]
@@SmallMove: {9..32 Byte Move}
  fild qword ptr [eax] {Load First 8}
  fild qword ptr [eax+ecx] {Load Last 8}
  cmp ecx,8; jle @@Small16
  fild qword ptr [eax+8] {Load Second 8}
  cmp ecx,16; jle @@Small24
  fild qword ptr [eax+16] {Load Third 8}
  fistp qword ptr [edx+16] {Save Third 8}
@@Small24: fistp qword ptr [edx+8] {Save Second 8}
@@Small16:
  fistp qword ptr [edx+ecx] {Save Last 8}
  fistp qword ptr [edx] {Save First 8}
@@Exit: ret
  nop; nop {4-Byte Align JumpTable}
@@JumpTable: {4-Byte Aligned}
dd @@Exit,@@M01,@@M02,@@M03,@@M04,@@M05,@@M06,@@M07,@@M08
@@LargeForwardMove: push edx {4-Byte Aligned}
  fild qword ptr [eax] {First 8}
  lea eax,[eax+ecx-8]; lea ecx,[ecx+edx-8]
  fild qword ptr [eax] {Last 8}
  push ecx; neg ecx
  and edx,-8 {8-Byte Align Writes}
  lea ecx,[ecx+edx+8]
  pop edx
@_ForwardLoop:
  fild qword ptr [eax+ecx]; fistp qword ptr [edx+ecx]
  add ecx,8; jl @_ForwardLoop
  fistp qword ptr [edx] {Last 8}
  pop edx; fistp qword ptr [edx] {First 8}
  ret
@@LargeMove: jng @@LargeDone {Count < 0}
  cmp eax,edx; ja @@LargeForwardMove
  sub edx,ecx; cmp eax,edx; lea edx,[edx+ecx]; jna @@LargeForwardMove
  sub ecx,8 {Backward Move}
  push ecx
  fild qword ptr [eax+ecx] {Last 8}
  fild qword ptr [eax] {First 8}
  add ecx,edx; and ecx,-8 {8-Byte Align Writes}
  sub ecx,edx
@_BackwardLoop:
  fild qword ptr [eax+ecx]; fistp qword ptr [edx+ecx]
  sub ecx,8; jg @_BackwardLoop
  pop ecx
  fistp qword ptr [edx] {First 8}
  fistp qword ptr [edx+ecx] {Last 8}
@@LargeDone: ret
@@M01: movzx ecx, byte[eax]; mov [edx],cl; ret
@@M02:; movzx ecx,word ptr [eax]; mov [edx],cx; ret
@@M03:
  mov cx,[eax]; mov al,[eax+2]
  mov [edx],cx; mov [edx+2],al; ret
@@M04: mov ecx,[eax]; mov [edx],ecx; ret
@@M05:
  mov ecx,[eax]; mov al,[eax+4]
  mov [edx],ecx; mov [edx+4],al; ret
@@M06:
  mov ecx,[eax]; mov ax,[eax+4]
  mov [edx],ecx; mov [edx+4],ax; ret
@@M07:
  mov ecx,[eax]; mov eax,[eax+3]
  mov [edx],ecx; mov [edx+3],eax; ret
@@M08: fild qword ptr [eax]; fistp qword ptr [edx]
end;

//
// CompareText compares S1 and S2 and returns 0 if they are equal.
// If S1 is greater than S2, CompareText returns an integer greater than 0.
// If S1 is less than S2, CompareText returns an integer less than 0.
// CompareText is NOT CASE-SENSITIVE and is not affected by the current locale.
//
function f1CompareText(const S1, S2: string): Integer;
asm
  test eax,eax; jz @nil1
  test edx,edx; jnz @ptr_OK

@nil2: mov eax,[eax-4]; ret
@nil1: test edx,edx; jz @nil0
  sub eax,[edx-4]
@nil0: ret

@ptr_OK: push edi; push ebx
  xor edi,edi; mov ebx,[eax-4]
  mov ecx,ebx; sub ebx,[edx-4]
  adc edi,-1
  push ebx; and ebx,edi
  mov edi,eax
  sub ebx,ecx; jge @len

@Length_OK: sub edi,ebx; sub edx,ebx

@Loop1:
  mov eax,[ebx+edi]
  mov ecx,[ebx+edx]
  cmp eax,ecx; jne @byte0
@Equal: add ebx,4; jl @Loop1

@Len: pop eax; pop ebx; pop edi; ret

@Loop2:
  mov eax,[ebx+edi]
  mov ecx,[ebx+edx]
  cmp eax,ecx; je @Equal

@Byte0: cmp al,cl; je @byte1
  and eax,$FF; and ecx,$FF
  sub eax,'a'; sub ecx,'a'
  cmp al,'z'-'a'; ja @up0a
  sub eax,'a'-'A'
@up0a: cmp cl,'z'-'a'; ja @up0c
  sub ecx,'a'-'A'
@up0c: sub eax,ecx; jnz @done
  mov eax,[ebx+edi]
  mov ecx,[ebx+edx]

@Byte1: cmp ah,ch; je @byte2
  and eax,$FF00; and ecx,$FF00
  sub eax,'a'*256; sub ecx,'a'*256
  cmp ah,'z'-'a'; ja @up1a
  sub eax,('a'-'A')*256
@up1a: cmp ch,'z'-'a'; ja @up1c
  sub ecx,('a'-'A')*256
@up1c: sub eax,ecx; jnz @done
  mov eax,[ebx+edi]
  mov ecx,[ebx+edx]

@Byte2: add ebx,2; jnl @len2
  shr eax,16; shr ecx,16
  cmp al,cl; je @byte3
  and eax,$FF; and ecx,$FF
  sub eax,'a'; sub ecx,'a'
  cmp al,'z'-'a'; ja @up2a
  sub eax,'a'-'A'
@up2a: cmp cl,'z'-'a'; ja @up2c
  sub ecx,'a'-'A'
@up2c: sub eax,ecx; jnz @done
  movzx eax, word ptr[ebx+edi]
  movzx ecx, word ptr[ebx+edx]

@Byte3: cmp ah,ch; je @byte4
  and eax,$FF00; and ecx,$FF00
  sub eax,'a'*256; sub ecx,'a'*256
  cmp ah,'z'-'a'; ja @up3a
  sub eax,('a'-'A')*256
@up3a: cmp ch,'z'-'a'; ja @up3c
  sub ecx,('a'-'A')*256
@up3c: sub eax,ecx; jnz @done

@Byte4: add ebx,2; jl @loop2
@len2: pop eax; pop ebx; pop edi; ret
@done: pop ecx; pop ebx; pop edi
end;

//
// Call StrComp to compare two null-terminated strings, with case sensitivity.
// The return value is indicated in the following table:
//
function f1StrComp(const P1, P2: PChar): integer; overload; asm
  sub eax, edx; jz @ret
@loop:
  movzx ecx,byte ptr[eax+edx]
  cmp cl,[edx]; jne @stop
  test cl,cl; jz @eq
  movzx ecx,byte ptr[eax+edx+1]
  cmp cl,[edx+1]; jne @stop1
  test cl,cl; jz @eq
  movzx ecx,byte ptr[eax+edx+2]
  cmp cl,[edx+2]; jne @stop2
  test cl,cl; jz @eq
  movzx ecx,byte ptr[eax+edx+3]
  cmp cl,[edx+3]; jne @stop3
  add edx,4
  test cl,cl; jz @eq
  movzx ecx,byte ptr[eax+edx]
  cmp cl,[edx]; jne @stop
  test cl,cl; jz @eq
  movzx ecx,byte ptr[eax+edx+1]
  cmp cl,[edx+1]; jne @stop1
  test cl,cl; jz @eq
  movzx ecx,byte ptr[eax+edx+2]
  cmp cl,[edx+2]; jne @stop2
  test cl,cl; jz @eq
  movzx ecx,byte ptr[eax+edx+3]
  cmp cl,[edx+3]; jne @stop3
  add edx,4
  test cl,cl; jnz @loop
@eq: xor eax,eax
@ret: ret
@stop3: add edx,1
@stop2: add edx,1
@stop1: add edx,1
@stop:
  mov eax,ecx
  movzx edx,byte ptr[edx]
  sub eax,edx
end;

//
// Call StrIComp to compare two strings without case sensitivity.
// StrIComp returns a value greater than 0 if Str1 > Str2, less than 0 if Str1 < Str2,
// and returns 0 if the strings are equal except for differences in case.
//
function f1StrIComp(const P1, P2: PChar): integer; overload; asm
  sub eax, edx; jnz @@Start
  ret
@@Start: push ebx; xor ebx,ebx; xor ecx,ecx
@@_loop:
  {;//movzx ecx,byte ptr[eax+edx]} mov cl,byte ptr[eax+edx]
  {;//mov bl,[edx]} cmp cl,[edx]; jne @@0
  test cl,cl; jz @@_eq

  {;//movzx ecx,byte ptr[eax+edx+1]}  mov cl,byte ptr[eax+edx+1]
  {;//mov bl,[edx+1]} cmp cl,[edx+1]; jne @@1
  test cl,cl; jz @@_eq

  {;//movzx ecx,byte ptr[eax+edx+2]} mov cl,byte ptr[eax+edx+2]
  {;//mov bl,[edx+2]} cmp cl,[edx+2]; jne @@2
  test cl,cl; jz @@_eq

  {;//movzx ecx,byte ptr[eax+edx+3]} mov cl,byte ptr[eax+edx+3]
  {;//mov bl,[edx+3]} cmp cl,[edx+3]; jne @@3
  add edx,4
  test cl,cl; jz @@_eq

  {;//movzx ecx,byte ptr[eax+edx]} mov cl,byte ptr[eax+edx]
  {;//mov bl,[edx]} cmp cl,[edx]; jne @@0
  test cl,cl; jz @@_eq

  {;//movzx ecx,byte ptr[eax+edx+1]} mov cl,byte ptr[eax+edx+1]
  {;//mov bl,[edx+1]} cmp cl,[edx+1]; jne @@1
  test cl,cl; jz @@_eq

  {;//movzx ecx,byte ptr[eax+edx+2]} mov cl,byte ptr[eax+edx+2]
  {;//mov bl,[edx+2]} cmp cl,[edx+2]; jne @@2
  test cl,cl; jz @@_eq

  {;//movzx ecx,byte ptr[eax+edx+3]} mov cl,byte ptr[eax+edx+3]
  {;//mov bl,[edx+3]} cmp cl,[edx+3]; jne @@3
  add edx,4
  test cl,cl; jnz @@_loop

@@_eq: xor eax,eax
@@_ret: jmp @@Stop

@@3: add edx,1
@@2: add edx,1
@@1: add edx,1
@@0: mov bl,[edx]
  mov cl,byte ptr[ecx+CxGLOBAL.UPCASETable]
  add edx,1; nop; nop
  cmp cl,byte ptr[ebx+CxGLOBAL.UPCASETable]
  jz @@_loop

@@Done:
  mov eax,ecx
  ;//movzx edx,byte ptr[edx]
  ;//sub eax,edx
  sub eax,ebx
@@Stop:pop ebx
end;

function Broken_f1StrLIComp(const P1, P2: PChar; MaxLen: Cardinal): integer; overload; asm
  sub eax, edx; jz @@ret
  test ecx,ecx; jnz @@Start
  xor eax,eax
@@ret: ret
@@Start: push ebx; push esi
  mov esi,ecx
  xor ebx,ebx; xor ecx,ecx
@@_loop:
  mov cl,byte ptr[eax+edx]
  cmp cl,[edx]; jne @@0
  test cl,cl; jz @@_eq
  sub esi,1; jz @@_eq

  mov cl,byte ptr[eax+edx+1]
  cmp cl,[edx+1]; jne @@1
  test cl,cl; jz @@_eq
  sub esi,1; jz @@_eq

  mov cl,byte ptr[eax+edx+2]
  cmp cl,[edx+2]; jne @@2
  test cl,cl; jz @@_eq
  sub esi,1; jz @@_eq

  mov cl,byte ptr[eax+edx+3]
  cmp cl,[edx+3]; jne @@3
  add edx,4
  test cl,cl; jz @@_eq
  sub esi,1; jnz @@_loop

@@_eq: xor eax,eax
@@_ret: jmp @@Stop

@@3: add edx,1
@@2: add edx,1
@@1: add edx,1
@@0: mov bl,[edx]
  mov cl,byte ptr[ecx+CxGLOBAL.UPCASETable]
  add edx,1; nop; nop
  cmp cl,byte ptr[ebx+CxGLOBAL.UPCASETable]
  jz @@_loop

@@Done:
  mov eax,ecx
  ;//movzx edx,byte ptr[edx]
  ;//sub eax,edx
  sub eax,ebx
@@Stop:pop esi;pop ebx
end;

function f1StrLIComp(const Str1, Str2: PChar; MaxLen: Cardinal): Integer;
asm
  push  ebx
  push  edi
  sub   eax, edx         {Difference between Str1 and Str2}
  jz    @@Exit           {Exit if Str1 = Str2}
  add   ecx, edx         {Last Check Position}
  mov   edi, eax
@@Loop:
  cmp   ecx, edx         {Last Check Position Reached}
  je    @@Zero           {Yes - Return 0}
  movzx eax, [edi+edx]   {Next Char of Str1}
  movzx ebx, [edx]
  cmp   al, bl           {Compare with Next Char of Str2}
  je    @@Same           {Same - Skip Uppercase conversion}
  movzx eax, [eax+CxGLOBAL.UPCASETable] {Uppercase Char1}
  movzx ebx, [ebx+CxGLOBAL.UPCASETable] {Uppercase Char2}
  cmp   al, bl           {Compare Uppercase Characters}
  jne   @@SetResult      {Set Result if Different}
@@Same:
  add   edx, 1           {Prepare for Next Loop}
  test  bl, bl           {Both Chars Null Terminators?}
  jnz   @@Loop           {No - Repeat Loop}
@@Zero:
  xor   eax, eax
  pop   edi
  pop   ebx
  ret                    {Exit with Result = 0}
@@SetResult:             {Difference Found}
  sbb   eax, eax         { 0 if Str1 > Str2, -1 if Str1 < Str2}
  or    al, 1            {+1 if Str1 > Str2, -1 if Str1 < Str2}
@@Exit:
  pop   edi
  pop   ebx
end;

//
// CompareMem performs a binary compare of Length bytes of memory referenced by P1 to that of P2.
// CompareMem returns true if the memory referenced by P1 is identical to that of P2.
//
function f1CompareMem(P1, P2: pointer; Length: integer): boolean; overload; asm
  add eax,ecx; add edx,ecx
  xor ecx,-1
  add eax,-8; add edx,-8
  add ecx,9; push ebx
  jg @Dword
  mov ebx,[eax+ecx]
  cmp ebx,[edx+ecx]; jne @Ret0
  lea ebx,[eax+ecx]
  add ecx,4; and ebx,3
  sub ecx,ebx; jg @Dword
@DwordLoop:
  mov ebx,[eax+ecx]
  cmp ebx,[edx+ecx]; jne @Ret0
  mov ebx,[eax+ecx+4]
  cmp ebx,[edx+ecx+4]; jne @Ret0
  add ecx,8; jg @Dword
  mov ebx,[eax+ecx]
  cmp ebx,[edx+ecx]; jne @Ret0
  mov ebx,[eax+ecx+4]
  cmp ebx,[edx+ecx+4]; jne @Ret0
  add ecx,8; jle @DwordLoop
@Dword:
  cmp ecx,4; jg @Word
  mov ebx,[eax+ecx]
  cmp ebx,[edx+ecx]; jne @Ret0
  add ecx,4
@Word:
  cmp ecx,6; jg @Byte
  movzx ebx,word ptr [eax+ecx]
  cmp bx,[edx+ecx]; jne @Ret0
  add ecx,2
@Byte:
  cmp ecx,7; jg @Ret1
  movzx ebx,byte ptr [eax+7]
  cmp bl,[edx+7]; jne @Ret0
@Ret1:
  mov eax,1; pop ebx
  ret
@Ret0:
  xor eax,eax; pop ebx
end;

// ------------------------------------------------------------------------------
//  64-bit signed division
// ------------------------------------------------------------------------------
//  Dividend = Numerator, Divisor = Denominator
//  Dividend(EAX:EDX), Divisor([ESP+8]:[ESP+4])  ; before reg pushing
//

procedure __lldiv;                      //JOH Version
//  64-bit signed division
//  dividend = numerator, divisor = denominator
//  dividend(eax:edx), divisor([esp+8]:[esp+4])  ; before reg pushing
asm
  push ebx; push esi; push edi
  mov ebx,[esp+16]; mov ecx,[esp+20]
  mov esi,edx; mov edi,ecx
  sar esi,31;
  xor eax,esi; xor edx,esi;
  sub eax,esi; sbb edx,esi
  sar edi,31; xor esi,edi;
  xor ebx,edi; xor ecx,edi
  sub ebx,edi; sbb ecx,edi
  jnz @@bigdivisor
  cmp edx,ebx; jb @@onediv
  mov ecx,eax; mov eax,edx
  xor edx,edx; div ebx
  xchg eax,ecx
@@onediv:
  div ebx; mov edx,ecx
  jmp @setsign
@@bigdivisor:
  sub esp,12
  mov [esp ],eax;
  mov [esp+4],ebx;
  mov [esp+8],edx;
  mov edi,ecx
  shr edx,1; rcr eax,1
  ror edi,1; rcr ebx,1
  bsr ecx,ecx
  shrd ebx,edi,cl;
  shrd eax,edx,cl
  shr edx,cl; rol edi,1
  div ebx; mov ebx,[esp]
  mov ecx,eax; imul edi,eax
  mul dword ptr [esp+4]
  add edx,edi; sub ebx,eax
  mov eax,ecx; mov ecx,[esp+8]
  sbb ecx,edx; sbb eax,0
  xor edx,edx;
  add esp,12
@setsign:
  xor eax,esi; xor edx,esi
  sub eax,esi; sbb edx,esi
@done:
  pop edi; pop esi; pop ebx
  ret 8
end;

procedure f1mMove(const Source; var Dest; Count: Integer);
const
  TABLE9x4 = 36;
  PAGESIZE = 512;
asm
  cmp eax,edx; jng @@check;
@@forwardmove: cmp ecx,TABLE9x4; jg @@fwdnotsmall;
  add eax,ecx;
@@forwardmove2: cmp ecx,0; jle @@done; {for compatibility with delphi's move for count <= 0}
  add edx,ecx; jmp dword ptr [@@fwdjumptable+ecx*4]
@@check: je @@done {for compatibility with delphi's move for source=dest}
@@checkoverlap: add eax,ecx; cmp eax,edx; jg @@backwardcheck; {source/dest overlap}
@@nooverlap: cmp ecx,TABLE9x4; jle @@forwardmove2; {source already incremented by count}
  sub eax,ecx; {restore original source}
@@fwdnotsmall: cmp ecx,PAGESIZE; jge @@fwdlargemove;
  {count > TABLE9x4 and count < PAGESIZE}
  cmp ecx,72; jl @@fwdmovenonmmx; {size at which using mmx becomes worthwhile}
@@fwdmovemmx: push ebx; mov ebx,edx; movq mm0,[eax] {first 8 characters}
  {qword align writes}
  add eax,ecx; add ecx,edx;
  add edx,7; and edx,not 7;
  sub ecx,edx; add edx,ecx;
  {now qword aligned}
  sub ecx,32; neg ecx;
@@fwdloopmmx:
  movq mm1,[eax+ecx-32]; movq mm2,[eax+ecx-24];
  movq mm3,[eax+ecx-16]; movq mm4,[eax+ecx- 8];
  movq [edx+ecx-32],mm1; movq [edx+ecx-24],mm2;
  movq [edx+ecx-16],mm3; movq [edx+ecx- 8],mm4;
  add ecx,32; jle @@fwdloopmmx
  movq [ebx],mm0 {first 8 characters}
  emms; pop ebx;
  neg ecx; add ecx,32;
  jmp dword ptr [@@fwdjumptable+ecx*4]
@@fwdmovenonmmx: push edi; push ebx; push edx;
  mov edi,[eax]
  {dword align reads}
  add edx,ecx; add ecx,eax;
  add eax,3; and eax,not 3;
  sub ecx,eax; add eax,ecx;
  {now dword aligned}
  sub ecx,32; neg ecx;
@@fwdloop:
  mov ebx,[eax+ecx-32]; mov [edx+ecx-32],ebx;
  mov ebx,[eax+ecx-28]; mov [edx+ecx-28],ebx;
  mov ebx,[eax+ecx-24]; mov [edx+ecx-24],ebx;
  mov ebx,[eax+ecx-20]; mov [edx+ecx-20],ebx;
  mov ebx,[eax+ecx-16]; mov [edx+ecx-16],ebx;
  mov ebx,[eax+ecx-12]; mov [edx+ecx-12],ebx;
  mov ebx,[eax+ecx-08]; mov [edx+ecx-08],ebx;
  mov ebx,[eax+ecx-04]; mov [edx+ecx-04],ebx;
  add ecx,32; jle @@fwdloop;
  pop ebx {orig edx}
  mov [ebx],edi; neg ecx
  add ecx,32; pop ebx; pop edi;
  jmp dword ptr [@@fwdjumptable+ecx*4]
@@fwdlargemove: push ebx; mov ebx,ecx;
  test edx,15; jz @@fwdaligned
  {16 byte align destination}
  mov ecx,edx; add ecx,15;
  and ecx,not 15; sub ecx,edx
  add eax,ecx; add edx,ecx
  sub ebx,ecx; {destination now 16 byte aligned}
  call dword ptr [@@fwdjumptable+ecx*4]
@@fwdaligned:
  mov ecx,ebx; and ecx,-16;
  sub ebx,ecx {ebx = remainder}
  push esi; push edi;
  mov esi,eax; mov edi,edx; {esi = source; edi = dest}
  mov eax,ecx; and eax,not 63 {eax = count -> num of bytes to blocks move}
  and ecx,63 {ecx = remaining bytes to move (0..63)}
  add esi,eax; add edi,eax;
  shr eax,3; neg eax; {eax = num of qword's to block move}
@@mmxcopyloop:
  movq mm0,[esi+eax*8+00h]; movq mm1,[esi+eax*8+08h];
  movq mm2,[esi+eax*8+10h]; movq mm3,[esi+eax*8+18h];
  movq mm4,[esi+eax*8+20h]; movq mm5,[esi+eax*8+28h];
  movq mm6,[esi+eax*8+30h]; movq mm7,[esi+eax*8+38h];
  movq [edi+eax*8+00h],mm0; movq [edi+eax*8+08h],mm1;
  movq [edi+eax*8+10h],mm2; movq [edi+eax*8+18h],mm3;
  movq [edi+eax*8+20h],mm4; movq [edi+eax*8+28h],mm5;
  movq [edi+eax*8+30h],mm6; movq [edi+eax*8+38h],mm7;
  add eax,8; jnz @@mmxcopyloop
  emms; {empty mmx state}
  add ecx,ebx; shr ecx,2; rep movsd;
  mov ecx,ebx; and ecx,3; rep movsb;
  pop edi; pop esi; pop ebx; ret;
@@backwardcheck: {overlapping source/dest}
  sub eax,ecx {restore original source}
  cmp ecx,TABLE9x4; jle @@bwdremainder;
@@bwdnotsmall: push ebx;
@@backwardmove:; cmp ecx,72;jl @@bwdmove; {size at which using mmx becomes worthwhile}
@@bwdmovemmx: movq mm0,[eax+ecx-8] {get last qword}
  lea ebx,[edx+ecx]; and ebx,7; {qword align writes}
  sub ecx,ebx; add ebx,ecx; {now qword aligned}
  sub ecx,32
@@bwdloopmmx:
  movq mm1,[eax+ecx+00h]; movq mm2,[eax+ecx+08h];
  movq mm3,[eax+ecx+10h]; movq mm4,[eax+ecx+18h];
  movq [edx+ecx+18h],mm4; movq [edx+ecx+10h],mm3;
  movq [edx+ecx+08h],mm2; movq [edx+ecx+00h],mm1;
  sub ecx,32; jge @@bwdloopmmx;
  movq [edx+ebx-8],mm0; emms; {last qword}
  add ecx,32; pop ebx;
@@bwdremainder: jmp dword ptr [@@bwdjumptable+ecx*4];
@@bwdmove: push edi; push ecx;
  mov edi,[eax+ecx-4]; lea ebx,[edx+ecx];{get last dword}
  and ebx,3; sub ecx,ebx; {dword align writes}
  sub ecx,32;
@@bwdloop:
  mov ebx,[eax+ecx+28]; mov [edx+ecx+28],ebx;
  mov ebx,[eax+ecx+24]; mov [edx+ecx+24],ebx;
  mov ebx,[eax+ecx+20]; mov [edx+ecx+20],ebx;
  mov ebx,[eax+ecx+16]; mov [edx+ecx+16],ebx;
  mov ebx,[eax+ecx+12]; mov [edx+ecx+12],ebx;
  mov ebx,[eax+ecx+08]; mov [edx+ecx+08],ebx;
  mov ebx,[eax+ecx+04]; mov [edx+ecx+04],ebx;
  mov ebx,[eax+ecx+00]; mov [edx+ecx+00],ebx;
  sub ecx,32; jge @@bwdloop
  pop ebx; add ecx,32;
  mov [edx+ebx-4],edi {last dword}
  pop edi; pop ebx;
  jmp dword ptr [@@bwdjumptable+ecx*4]
  nop; nop; nop
@@fwdjumptable:
  dd @@done {removes need to test for zero size move}
  dd @@fwd01,@@fwd02,@@fwd03,@@fwd04,@@fwd05,@@fwd06,@@fwd07,@@fwd08
  dd @@fwd09,@@fwd10,@@fwd11,@@fwd12,@@fwd13,@@fwd14,@@fwd15,@@fwd16
  dd @@fwd17,@@fwd18,@@fwd19,@@fwd20,@@fwd21,@@fwd22,@@fwd23,@@fwd24
  dd @@fwd25,@@fwd26,@@fwd27,@@fwd28,@@fwd29,@@fwd30,@@fwd31,@@fwd32
  dd @@fwd33,@@fwd34,@@fwd35,@@fwd36
@@bwdjumptable:
  dd @@done {removes need to test for zero size move}
  dd @@bwd01,@@bwd02,@@bwd03,@@bwd04,@@bwd05,@@bwd06,@@bwd07,@@bwd08
  dd @@bwd09,@@bwd10,@@bwd11,@@bwd12,@@bwd13,@@bwd14,@@bwd15,@@bwd16
  dd @@bwd17,@@bwd18,@@bwd19,@@bwd20,@@bwd21,@@bwd22,@@bwd23,@@bwd24
  dd @@bwd25,@@bwd26,@@bwd27,@@bwd28,@@bwd29,@@bwd30,@@bwd31,@@bwd32
  dd @@bwd33,@@bwd34,@@bwd35,@@bwd36
  @@fwd36: mov ecx,[eax-36]; mov [edx-36],ecx;
  @@fwd32: mov ecx,[eax-32]; mov [edx-32],ecx;
  @@fwd28: mov ecx,[eax-28]; mov [edx-28],ecx;
  @@fwd24: mov ecx,[eax-24]; mov [edx-24],ecx;
  @@fwd20: mov ecx,[eax-20]; mov [edx-20],ecx;
  @@fwd16: mov ecx,[eax-16]; mov [edx-16],ecx;
  @@fwd12: mov ecx,[eax-12]; mov [edx-12],ecx;
  @@fwd08: mov ecx,[eax-08]; mov [edx-08],ecx;
  @@fwd04: mov ecx,[eax-04]; mov [edx-04],ecx; ret;
  @@fwd35: mov ecx,[eax-35]; mov [edx-35],ecx;
  @@fwd31: mov ecx,[eax-31]; mov [edx-31],ecx;
  @@fwd27: mov ecx,[eax-27]; mov [edx-27],ecx;
  @@fwd23: mov ecx,[eax-23]; mov [edx-23],ecx;
  @@fwd19: mov ecx,[eax-19]; mov [edx-19],ecx;
  @@fwd15: mov ecx,[eax-15]; mov [edx-15],ecx;
  @@fwd11: mov ecx,[eax-11]; mov [edx-11],ecx;
  @@fwd07: mov ecx,[eax-07]; mov [edx-07],ecx;
  @@fwd03: mov  cx,[eax-03]; mov [edx-03], cx;
           mov  cl,[eax-01]; mov [edx-01], cl; ret;
  @@fwd34: mov ecx,[eax-34]; mov [edx-34],ecx;
  @@fwd30: mov ecx,[eax-30]; mov [edx-30],ecx;
  @@fwd26: mov ecx,[eax-26]; mov [edx-26],ecx;
  @@fwd22: mov ecx,[eax-22]; mov [edx-22],ecx;
  @@fwd18: mov ecx,[eax-18]; mov [edx-18],ecx;
  @@fwd14: mov ecx,[eax-14]; mov [edx-14],ecx;
  @@fwd10: mov ecx,[eax-10]; mov [edx-10],ecx;
  @@fwd06: mov ecx,[eax-06]; mov [edx-06],ecx;
  @@fwd02: mov  cx,[eax-02]; mov [edx-02], cx; ret;
  @@fwd33: mov ecx,[eax-33]; mov [edx-33],ecx;
  @@fwd29: mov ecx,[eax-29]; mov [edx-29],ecx;
  @@fwd25: mov ecx,[eax-25]; mov [edx-25],ecx;
  @@fwd21: mov ecx,[eax-21]; mov [edx-21],ecx;
  @@fwd17: mov ecx,[eax-17]; mov [edx-17],ecx;
  @@fwd13: mov ecx,[eax-13]; mov [edx-13],ecx;
  @@fwd09: mov ecx,[eax-09]; mov [edx-09],ecx;
  @@fwd05: mov ecx,[eax-05]; mov [edx-05],ecx;
  @@fwd01: mov  cl,[eax-01]; mov [edx-01], cl; ret;
  @@bwd36: mov ecx,[eax+32]; mov [edx+32],ecx;
  @@bwd32: mov ecx,[eax+28]; mov [edx+28],ecx;
  @@bwd28: mov ecx,[eax+24]; mov [edx+24],ecx;
  @@bwd24: mov ecx,[eax+20]; mov [edx+20],ecx;
  @@bwd20: mov ecx,[eax+16]; mov [edx+16],ecx;
  @@bwd16: mov ecx,[eax+12]; mov [edx+12],ecx;
  @@bwd12: mov ecx,[eax+08]; mov [edx+08],ecx;
  @@bwd08: mov ecx,[eax+04]; mov [edx+04],ecx;
  @@bwd04: mov ecx,[eax   ]; mov [edx   ],ecx; ret;
  @@bwd35: mov ecx,[eax+31]; mov [edx+31],ecx;
  @@bwd31: mov ecx,[eax+27]; mov [edx+27],ecx;
  @@bwd27: mov ecx,[eax+23]; mov [edx+23],ecx;
  @@bwd23: mov ecx,[eax+19]; mov [edx+19],ecx;
  @@bwd19: mov ecx,[eax+15]; mov [edx+15],ecx;
  @@bwd15: mov ecx,[eax+11]; mov [edx+11],ecx;
  @@bwd11: mov ecx,[eax+07]; mov [edx+07],ecx;
  @@bwd07: mov ecx,[eax+03]; mov [edx+03],ecx;
  @@bwd03: mov  cx,[eax+01]; mov [edx+01],cx;
           mov  cl,[eax   ]; mov [edx   ],cl; ret;
  @@bwd34: mov ecx,[eax+30]; mov [edx+30],ecx;
  @@bwd30: mov ecx,[eax+26]; mov [edx+26],ecx;
  @@bwd26: mov ecx,[eax+22]; mov [edx+22],ecx;
  @@bwd22: mov ecx,[eax+18]; mov [edx+18],ecx;
  @@bwd18: mov ecx,[eax+14]; mov [edx+14],ecx;
  @@bwd14: mov ecx,[eax+10]; mov [edx+10],ecx;
  @@bwd10: mov ecx,[eax+06]; mov [edx+06],ecx;
  @@bwd06: mov ecx,[eax+02]; mov [edx+02],ecx;
  @@bwd02: mov  cx,[eax   ]; mov [edx   ],cx; ret
  @@bwd33: mov ecx,[eax+29]; mov [edx+29],ecx;
  @@bwd29: mov ecx,[eax+25]; mov [edx+25],ecx;
  @@bwd25: mov ecx,[eax+21]; mov [edx+21],ecx;
  @@bwd21: mov ecx,[eax+17]; mov [edx+17],ecx;
  @@bwd17: mov ecx,[eax+13]; mov [edx+13],ecx;
  @@bwd13: mov ecx,[eax+09]; mov [edx+09],ecx;
  @@bwd09: mov ecx,[eax+05]; mov [edx+05],ecx;
  @@bwd05: mov ecx,[eax+01]; mov [edx+01],ecx;
  @@bwd01: mov  cl,[eax   ]; mov [edx   ],cl;
@@done:
end;

function f1mCharpos(Ch: char; const Str: ANSIString): integer;
asm
  test edx,edx; jz @@0;
  mov ecx,[edx-4]; cmp ecx,8; jg @@notsmall;
  test ecx,ecx; jz @@0; {exit if length = 0}
@@small:
  cmp al,[edx+0]; jz @@1; sub ecx,1; jz @@0;
  cmp al,[edx+1]; jz @@2; sub ecx,1; jz @@0;
  cmp al,[edx+2]; jz @@3; sub ecx,1; jz @@0;
  cmp al,[edx+3]; jz @@4; sub ecx,1; jz @@0;
  cmp al,[edx+4]; jz @@5; sub ecx,1; jz @@0;
  cmp al,[edx+5]; jz @@6; sub ecx,1; jz @@0;
  cmp al,[edx+6]; jz @@7; sub ecx,1; jz @@0;
  cmp al,[edx+7]; jz @@8;
  @@0: xor eax,eax; ret;
  @@1: mov eax,1; ret; @@2: mov eax,2; ret;
  @@3: mov eax,3; ret; @@4: mov eax,4; ret;
  @@5: mov eax,5; ret; @@6: mov eax,6; ret;
  @@7: mov eax,7; ret; @@8: mov eax,8; ret;

@@notsmall: {length(str) > 8}
  mov ah,al; add edx,ecx; movd mm0,eax;
  punpcklwd mm0,mm0; punpckldq mm0,mm0;
  push ecx; neg ecx;{save length}
@@first8:
  movq mm1,[edx+ecx]; add ecx,8;
  pcmpeqb mm1,mm0; {compare all 8 bytes}
  packsswb mm1,mm1; {pack result into 4 bytes}
  movd eax,mm1; test eax,eax; jnz @@matched; {exit on match at any position}
  cmp ecx,not 7; jge @@last8; {check if next loop would pass string end}
@@align: {align to previous 8 byte boundary}
  lea eax,[edx+ecx]; and eax,7; {eax -> 0 or 4}
  sub ecx,eax;
@@loop:
  movq mm1,[edx+ecx]; add ecx,8;
  pcmpeqb mm1,mm0; {compare all 8 bytes}
  packsswb mm1,mm1; {pack result into 4 bytes}
  movd eax,mm1; test eax,eax;
  jnz @@matched; {exit on match at any position}
  cmp ecx,not 7; {check if next loop would pass string end}
{$ifndef nounroll}; jge @@last8;
  movq mm1,[edx+ecx]; add ecx,8;
  pcmpeqb mm1,mm0; {compare all 8 bytes}
  packsswb mm1,mm1; {pack result into 4 bytes}
  movd eax,mm1; test eax,eax;
  jnz @@matched; {exit on match at any position}
  cmp ecx,not 7; {check if next loop would pass string end}
{$endif}; jl @@loop;
@@last8:
  movq mm1,[edx-8]; {position for last 8 used characters}
  pop edx; {original length}
  pcmpeqb mm1,mm0; {compare all 8 bytes}
  packsswb mm1,mm1; {pack result into 4 bytes}
  movd eax,mm1; test eax,eax;
  jnz @@matched2; {exit on match at any position}
  emms; ret; {finished - not found}
@@matched: {set result from 1st match in edx}
  pop edx; add edx,ecx; {original length + ecx}
@@matched2:
  emms; sub edx,8; {adjust for extra add ecx,8 in loop}
  test al,al; jnz @@matchdone; {match at position 1 or 2}
  test ah,ah; jnz @@match1; {match at position 3 or 4}
  shr eax,16; test al,al; jnz @@match2; {match at position 5 or 6}
  shr eax,08; add edx,06; jmp @@matchdone
@@match2: add edx,4; jmp @@matchdone;
@@match1: shr eax,8; add edx,2; {al <- ah}
@@matchdone: xor eax,2; and eax,3; add eax,edx; {eax <- 1 or 2}
end;

function CharPosShaPas2(Ch: char; const S: AnsiString): integer;
const
  CMinusOnes = -$01010101;
  CSignums = $80808080;
var
  Index, Len, c, d, mask, Sign, Save, SaveEnd: integer;
label
  Small, Middle, Large, Found0, Found1, Found2, Found3;
label
  notFound, match, matchplus1, matchmin1, notMatch, Return;
begin
  c := integer(@PChar(integer(s))[-4]);
  if c = -4 then goto notFound;
  Len := PInteger(c)^;
  if Len > 24 then goto Large;
  Index := 4;
  if Index > Len then goto Small;

  Middle:
  if PChar(c)[Index + 0] = Ch then goto Found0;
  if PChar(c)[Index + 1] = Ch then goto Found1;
  if PChar(c)[Index + 2] = Ch then goto Found2;
  if PChar(c)[Index + 3] = Ch then goto Found3;
  inc(Index, 4);
  if Index <= Len then goto Middle;

  Index := Len + 1;
  if PChar(c)[Len + 1] = Ch then goto Found0;
  if PChar(c)[Len + 2] = Ch then goto Found1;
  if PChar(c)[Len + 3] <> Ch then goto notFound;
  Result := integer(@PChar(Index)[-1]); exit;
  goto Return;                          //drop Index

  Small:
  if Len = 0 then goto notFound; if PChar(c)[Index + 0] = Ch then goto Found0;
  if Len = 1 then goto notFound; if PChar(c)[Index + 1] = Ch then goto Found1;
  if Len = 2 then goto notFound; if PChar(c)[Index + 2] <> Ch then goto notFound;

  Found2: Result := integer(@PChar(Index)[-1]); exit;
  Found1: Result := integer(@PChar(Index)[-2]); exit;
  Found0: Result := integer(@PChar(Index)[-3]); exit;
  notFound: Result := 0; exit;
  goto notFound;                        //kill warning 'Index might not have been initialized'
  Found3: Result := integer(@PChar(Index)[0]); exit;
  goto Return;                          //drop Index

  Large:
  Save := c;
  mask := ord(Ch);
  Index := integer(@PChar(c)[+4]);

  d := mask;
  inc(Len, c);
  SaveEnd := Len;
  mask := (mask shl 8);
  inc(Len, +4 - 16 + 3);

  mask := mask or d;
  Len := Len and (-4);
  d := mask;
  cardinal(Sign) := CSignums;

  mask := mask shl 16;
  c := PIntegerArray(Index)[0];
  mask := mask or d;
  inc(Index, 4);

  c := c xor mask;
  d := integer(@PChar(c)[CMinusOnes]);
  c := c xor (-1);
  c := c and d;
  d := mask;

  if c and Sign <> 0 then goto matchmin1;
  Index := Index and (-4);
  d := d xor PIntegerArray(Index)[0];

  if cardinal(Index) < cardinal(Len) then
    repeat;
      c := integer(@PChar(d)[CMinusOnes]);
      d := d xor (-1);
      c := c and d;
      d := mask;

      d := d xor PIntegerArray(Index)[1];
      if c and Sign <> 0 then goto match;
      c := integer(@PChar(d)[CMinusOnes]);
      d := d xor (-1);
      c := c and d;
      d := PIntegerArray(Index)[2];
      if c and Sign <> 0 then goto matchplus1;
      d := d xor mask;

      c := integer(@PChar(d)[CMinusOnes]);
      d := d xor (-1);
      inc(Index, 12);
      c := c and d;

      //if c and Sign<>0 then goto matchmin1;
      d := mask;
      if c and Sign <> 0 then goto matchmin1;
      d := d xor PIntegerArray(Index)[0];
    until cardinal(Index) >= cardinal(Len);

  Len := SaveEnd;
  while true do begin
    c := integer(@PChar(d)[CMinusOnes]);
    d := d xor (-1);
    c := c and d;
    inc(Index, 4);
    if c and Sign <> 0 then goto matchmin1;
    d := mask;
    if cardinal(Index) <= cardinal(Len) then d := d xor PIntegerArray(Index)[0]
    else begin
      if Len = 0 then goto notMatch;
      d := d xor PIntegerArray(Len)[0];
      Index := Len;
      Len := 0;
    end
  end;

  notMatch: Result := 0; exit;

  matchplus1: inc(Index, 8);
  matchmin1: dec(Index, 4);
  match:
  c := c and Sign;
  dec(Index, integer(Save) + 2);
  if word(c) = 0 then begin
    c := c shr 16; inc(Index, 2);
  end;
  if byte(c) <> 0 then dec(Index);
  Result := Index;
  Return:
end;

end.


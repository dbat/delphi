unit EXACHexs;
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  Helper routines (used for querying Index Values)
//  excerpted from aCommon unit by the same authors
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
interface
const YES = TRUE;

function IntoStr(const I: integer; const digits: byte = 0): string; //overload forward;

function IntoHex(const I: Integer; const Digits: byte = sizeof(integer) * 2;
  UpperCase: boolean = YES): string; register overload //; forward;
function IntoHex(const I: Int64; const Digits: byte = sizeof(int64) * 2;
  UpperCase: boolean = YES): string; register overload //; forward;
function IntoHex_Old(const I: Int64; const Digits: byte = sizeof(byte)): string; register;

function OrdString(const S: string; const HexStyle: boolean = YES;
  const HexSymbolPrefix: string = '$'; const CharSymbolPrefix: string = '#'): string; //forward;
function OrdWideString(const W: widestring; const HexStyle: boolean = YES;
  const HexSymbolPrefix: string = '$'; const CharSymbolPrefix: string = '#'): string; //forward;

implementation
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// This helper function excerpted from aCommon unit
// Copyright (c) 2004, D.Sofyan & Adrian Hafizh
// please get the latest version
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Hexs(const byte: byte; const uppercase: boolean = YES): string; overload; forward;
function Hexs(const word: word; const uppercase: boolean = YES): string; overload; forward;
function Hexs(const integer: integer; const uppercase: boolean = YES): string; overload; forward;
function Hexs(const I: int64; const uppercase: boolean = YES): string; overload; forward;
function Hexs(const Buffer: pointer; const BufferLength: integer;
  const Delimiter: Char = #0; const Uppercase: boolean = YES): string; overload; forward;
function Hexs(const Buffer: pointer; const BufferLength: integer;
  const Uppercase: boolean; const Delimiter: Char = #0): string; overload; forward;

function min(const a, b: integer): integer;
asm
  cmp a, b; jle @end
  mov a, b; @end:
end;
function max(const a, b: integer): integer;
asm
  cmp a, b; jge @end
  mov a, b; @end:
end;

function IntoStr(const I: integer; const digits: byte): string;
const
  zero = '0';
  dash = '-';
var
  n: integer;
begin
  if i = 0 then Result := stringofChar(zero, max(1, digits))
  else begin
    Str(I: 0, Result);
    n := length(Result);
    if digits > n then begin
      if i > 0 then
        Result := StringOfchar(zero, digits - n) + Result
      else
        Result := dash + StringOfChar(zero, digits - n - 1) + copy(Result, 2, n);
    end;
  end;
end;

function IntoHex_Old(const I: Int64; const Digits: byte = sizeof(byte)): string; register;
// This helper function excerpted from aCommon unit
// Copyright (c) 2004, D.Sofyan & Adrian Hafizh
// please get the latest version
// Digits is number of HEXADECIMAL chars representation, should be multiple of 2
// example: IntoHex(1234, 5) = 0004D2 (6 chars anyway)
// This one actually is obsoleted, used for simple conversion only
const
  DIGITSQUAD = sizeof(Int64);
var
  S: ShortString;
asm
   @@Start:
     push esi; push edi
     push Result
     lea esi, I
     and Digits, 11111b
     inc Digits; shr Digits, 1

     mov al, Digits
     and eax, 0ffh
     mov edi, DIGITSQUAD
     cmp eax, edi; ja @_checkdone

     @_checkdigit:
     mov ecx, 4; mov edx, [esi+4] //I.hi

     @_Loop1: rol edx, 8
     or dl, dl; jnz @_checkdone
     dec edi; cmp edi, eax; jb @_recall
     dec ecx; jnz @_Loop1

     mov edx, [esi]
     @_Loop2: rol edx, 8
     or dl, dl; jnz @_checkdone
     dec edi; jz @_recall
     cmp edi, eax; jge @_Loop2

     @_recall: inc edi
     @_checkdone: mov eax, edi; lea edi, S

     mov ecx, eax; add esi, eax
     dec esi; shl eax, 1
     cld; stosb

   @@Loop:
     std; lodsb
     mov ah, al; shr al, 04h
     add al, 90h; daa
     adc al, 40h; daa
     cld; stosb
     mov al, ah; and al, 0Fh
     add al, 90h; daa
     adc al, 40h; daa
     stosb
     dec ecx; jnz @@Loop

     lea edx, S; pop eax
     call System.@LStrFromString
     pop edi; pop esi
   @@Stop:
end;

const
  HEXNUM_UPPERCASE: string = '0123456789ABCDEF';
  HEXNUM_LOWERCASE: string = '0123456789abcdef';

function Hexs(const byte: byte; const uppercase: boolean = YES): string;
asm
  push ebx
  mov ah, uppercase; push eax

  mov eax, Result           // where the result will be stored
  mov edx, 2                // how much length of str requested
  call System.@LStrSetLength// result: new allocation pointer in EAX
  mov edx, [eax]            // eax contains the new allocated pointer
                            // we got the storage as well at once
  mov ebx, HEXNUM_UPPERCASE // init ebx with default value

  pop eax                   // ah = uppercase flag
  test ah, 1                // is uppercase flag = YES?
    jne @skipsetlocase      // nz = YES, then dont bother to kowercase
  mov ebx, HEXNUM_LOWERCASE // uppercase flags = FALSE

  @skipsetlocase:
  mov ah, al                // save copy first

  and al, $f; xlat          // strip high nibbles, translate
  mov edx+1, al             // save to allocated string / last position
  mov al, ah
  shr eax, 3 * 4            // shift 3 nibbles away (high nibble of AH)
  and al, $f; xlat          // strip high nibbles, translate
  mov [edx], al             // save to allocated string / first position

  pop ebx
end;

function Hexs(const word: word; const uppercase: boolean = YES): string; overload;
const WordDigits = 4;
asm
  push ebx
  xchg ah, al; push ax; shl eax, 16; pop ax
  mov al, uppercase; push eax

  mov eax, Result           // where the result will be stored
  mov edx, WordDigits       // how much length of str requested
  call System.@LStrSetLength// result: new allocation pointer in EAX
  mov edx, [eax]            // eax contains the new allocated pointer
                            // we got the storage as well at once
  mov ebx, HEXNUM_UPPERCASE // init ebx with default value
  pop eax                   // al = uppercase flag
  test al, 1                // is uppercase flag = YES?
    jne @skipsetlocase      // nz = YES, then dont bother to kowercase
  mov ebx, HEXNUM_LOWERCASE // uppercase flags = FALSE

  @skipsetlocase:

  mov al, ah                // get the high byte
  and al, $f; xlat          // strip high nibbles, translate
  mov edx+3, al             // save to allocated string / last position

  mov al, ah; shr al, 4     // reget the high byte; get high nibble
  and al, $f; xlat          // strip high nibbles, translate
  mov edx+2, al             // save to allocated string / first position

  shr eax, 16               //
  mov ah, al                // we dont again need ah

  and al, $f; xlat
  mov edx+1, al

  mov al, ah
  shr al, 4
  and al, $f; xlat
  mov [edx], al

  pop ebx
end;

function Hexs(const integer: integer; const uppercase: boolean = YES): string; overload;
const
  IntDigits = 8;
  bswap_eax = $C80F;
begin
  asm
    push ebx
    db $f,$c8                 // bswap eax; $c9=ecx $ca=edx $cb=ebx
    mov integer, eax

    mov eax, Result           // where the result will be stored
    mov edx, IntDigits        // how much length of str requested
    call System.@LStrSetLength// result: new allocation pointer in EAX
    mov edx, [eax]            // eax contains the new allocated pointer
                              // we got the storage as well at once
    mov ebx, HEXNUM_UPPERCASE // init ebx with default value

    test uppercase, 1;        // is uppercase flag = YES?
      jne @skipsetlocase      // nz = YES, then dont bother to kowercase
    mov ebx, HEXNUM_LOWERCASE // uppercase flags = FALSE
    @skipsetlocase:

    mov eax, integer
    mov ecx, IntDigits / 2
    mov ch, al                // initialize

  @Loop:
    shr al, 4
    and al, $f; xlat
    mov [edx], al
    lea edx, edx +1

    mov al, ch
    and al, $f; xlat
    mov [edx], al
    lea edx, edx +1

    shr eax, 8
    mov ch, al
    dec cl
    jnz @Loop

    pop ebx
  end;
end;

function Hexs(const I: int64; const uppercase: boolean = YES): string; overload;
const I64digits = 16;
type
  i64 = packed record
    lo, hi: integer
  end;

begin
  asm
    push ebx
    mov eax, I.i64.lo
    db $f,$c8             // bswap eax
    mov I.i64.lo, eax

    mov eax, I.i64.hi
    db $f,$c8             // bswap eax
    mov I.i64.hi, eax


    mov eax, Result           // where the result will be stored
    mov edx, 16                // how much length of str requested
    call System.@LStrSetLength// result: new allocation pointer in EAX
    mov edx, [eax]            // eax contains the new allocated pointer
    mov ebx, HEXNUM_UPPERCASE // init ebx with default value
    test uppercase, 1;        // is uppercase flag = YES?
      jne @skipsetlocase      // nz = YES, then dont bother to kowercase
    mov ebx, HEXNUM_LOWERCASE // uppercase flags = FALSE

    @skipsetlocase:

    mov eax, I.i64.hi
    mov ecx, 4; mov ch, al

  @Loop1:
    shr al, 4
    and al, $f; xlat
    mov [edx], al
    lea edx, edx +1

    mov al, ch; //shr al, 4
    and al, $f; xlat
    mov [edx], al
    lea edx, edx +1

    shr eax, 8
    mov ch, al
    dec cl
    jnz @Loop1

    mov eax, I.i64.lo
    mov ecx, 4; mov ch, al

  @Loop2:
    shr al, 4
    and al, $f; xlat
    mov [edx], al
    lea edx, edx +1

    mov al, ch; //shr al, 4
    and al, $f; xlat
    mov [edx], al
    lea edx, edx +1

    shr eax, 8
    mov ch, al
    dec cl
    jnz @Loop2

    pop ebx
  end;
end;

function Hexs(const Buffer: pointer; const BufferLength: integer;
  const Delimiter: Char = #0; const Uppercase: boolean = YES): string;
asm
  @@Start:
    or eax, eax; jz @@Stop     // insanity checks
    or edx, edx; jle @@Stop

    push esi; push edi
    mov esi, buffer
    mov edi, bufferlength      // save buflength first!

    shl edx, 1                 // edx = Bufferlength * 2
    and ecx, $ff               // note: ecx IS delimiter
    push ecx                   // save it, will be destroyed by LStrSetLength

    cmp ecx, 0; jz @nolimit    // if delim = #0 then skip increase length
    lea edx, edx+edi           // ~> inc(edx, edi)
    dec edx                    // we don't need trailing delimiter

  @nolimit:
    mov eax, Result            // where the result will be stored
    call System.@LStrSetLength // result: new allocation pointer in EAX
                               // ecx, edx destroyed

    mov ecx, edi               // get bufferlength back

    //mov edi, eax               // WRONG! eax contains the new allocated pointer
                               // we got the storage as well at once
    mov edi, [eax]             // eax contains the new allocated pointer

    pop edx                    // get delimiter back

    push ebx; mov ebx, HEXNUM_UPPERCASE  // get Translation Table
    test Uppercase, 1; jne @skipsetlocase  // is uppercase flag = YES?

    mov ebx, HEXNUM_LOWERCASE // uppercase flags = FALSE

  @skipsetlocase:

    cmp edx, 0
    Jz @@WithoutDelimiter

    dec ecx
    jz @LastByte

    @@WithDelimiter:
      lodsb                    // load byte to AL
      mov ah, al               // copy to AH for second nibble translation

      shr al, 4                // extract high nibble
      xlat; mov [edi], al      // translate and store result
      mov al, ah; and al, $f   // extract low nibble; validate
      xlat; mov edi+1, al      // translate and store result
      mov edi+2, dl            // put delimiter
      lea edi, edi+3           // inc edi by 3
      dec ecx; jg @@WithDelimiter

   @LastByte:
      lodsb                    // load byte to AL
      mov ah, al               // copy to AH for second nibble translation

      shr al, 4                // extract high nibble
      xlat; mov [edi], al      // translate and store result
      mov al, ah; and al, $f   // extract low nibble; validate
      xlat; mov edi+1, al      // translate and store result
      //we donot need these anymore...
      //lea edi, edi+3           // inc edi by 3
      //mov edi+2, dl            // put delimiter
      //dec ecx; jg @@WithDelimiter
      jmp @@Done

    @@WithoutDelimiter:
      lodsb                    // load byte to AL
      mov ah, al               // copy to AH for second nibble translation

      shr al, 4                // extract high nibble
      xlat; mov [edi], al      // translate and store result
      mov al, ah; and al, $f   // extract low nibble; validate
      xlat; mov edi+1, al      // translate and store result
      //mov edi+2, dl            // put delimiter
      //lea edi, edi+3           // inc edi by 3
      lea edi, edi+2           // inc edi only 2 in this block
      dec ecx; jg @@WithoutDelimiter
      jmp @@Done

    @@Done:pop ebx; pop edi; pop esi
  @@Stop:
end;

function Hexs(const Buffer: pointer; const BufferLength: integer;
  const Uppercase: boolean; const Delimiter: Char = #0): string; overload;
begin
  Result := Hexs(Buffer, BufferLength, Delimiter, Uppercase);
end;

function Digitize(const S: string; const Digits: byte; Negative: boolean = FALSE; UpperCase: boolean = YES): string;
type
  TUpperCase = boolean;
  TNegative = boolean;

const
  zero = '0';
  f = 'f';
  space = ' ';
  UPPINg = not ord(space);
  fills: array[TUpperCase, TNegative] of char = ((zero, f), (zero, char(ord(f) and UPPING)));

  function firstNonZero: integer;
  var
    fill: char;
  begin
    if S = '' then
      Result := 0
    else if Negative then Result := 1
    else begin
      fill := fills[UpperCase, Negative];
      for Result := 1 to length(S) do
        if S[Result] <> fill then break
    end;
    //debug:
    //if Result = 0 then
    //  Result := 1;
  end;
var
  L: integer;
begin
  if (Digits < 1) then Result := S
  else begin
    L := length(S);
    if Digits = L then Result := S
    else begin
      if Digits < L then begin
        Result := copy(S, min(L - Digits + 1, firstNonZero), L);
        //debug:
        //if Result = '' then
        //  Result := S;
      end
      else begin
        Result := stringofchar(fills[UpperCase, Negative], Digits - L) + S;
        //debug:
        //if Result = '' then
        //  Result := S;
      end;
    end;
  end;
end;

function IntoHex(const I: Integer; const Digits: byte = sizeof(integer) * 2; UpperCase: boolean = YES): string; register overload;
const
  MaxByte = high(byte);
  MaxWord = high(word);
  //MinShort = low(shortint);  MinSmall = low(SmallInt);
begin
  case i of
    //allowing negative values for byte & word type are rather confusing than useful
    {MinShort}0..MaxByte: Result := hexs(byte(i), UpperCase);
    {MinSmall..MinShort - 1,}Maxbyte + 1..maxword: Result := hexs(word(i), UpperCase);
    //-maxint..(-maxword - 1), maxword + 1..maxint: Result := hexs(i, UpperCase);
    else Result := hexs(i, UpperCase);
  end;
  Result := Digitize(Result, Digits, i < 0, UpperCase);
end;

function IntoHex(const I: Int64; const Digits: byte = sizeof(int64) * 2; UpperCase: boolean = YES): string; register overload;
type
  i64 = packed record
    lo, hi: integer
  end;
begin
  if i64(I).hi = 0 then
    Result := IntoHex(integer(i), Digits, UpperCase)
  else
    Result := Digitize(hexs(i, UpperCase), Digits, i < 0, UpperCase);
end;

function OrdString(const S: string; const HexStyle: boolean = YES;
  const HexSymbolPrefix: string = '$'; const CharSymbolPrefix: string = '#'): string;
var
  i: integer;
begin
  Result := '';
  if HexStyle then
    for i := 1 to length(S) do
      Result := Result + CharSymbolPrefix + HexSymbolPrefix + IntoHex(ord(S[i]), 2) //inttoHex(ord(S[i]), 2)
  else
    for i := 1 to length(S) do
      Result := Result + CharSymbolPrefix + IntoStr(ord(S[i]))

end;

function OrdWideString(const W: widestring; const HexStyle: boolean = YES;
  const HexSymbolPrefix: string = '$'; const CharSymbolPrefix: string = '#'): string;
var
  i: integer;
begin
  Result := '';
  if HexStyle then
    for i := 1 to length(W) do
      Result := Result + CharSymbolPrefix + HexSymbolPrefix + IntoHex(ord(W[i]), 4) //inttoHex(ord(S[i]), 2)
  else
    for i := 1 to length(W) do
      Result := Result + CharSymbolPrefix + IntoStr(ord(W[i]))

end;

end.


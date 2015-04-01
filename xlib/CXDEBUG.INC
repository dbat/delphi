//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  Helper routines (used for querying Index Values)
//  excerpted from aCommon unit by the same authors
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//function IntoStr(const I: integer): string; forward;
//function IntoHex(const I: Int64; const Digits: byte = sizeof(byte)): string; forward;
//function OrdString(const S: string; const HexStyle: boolean = TRUE;
//  const HexSymbolPrefix: string = '$'; const CharSymbolPrefix: string = '#'): string; forward;
//function OrdWideString(const W: widestring; const HexStyle: boolean = TRUE;
//  const HexSymbolPrefix: string = '$'; const CharSymbolPrefix: string = '#'): string; forward;

function min(const a, b: integer): integer; assembler; asm
  cmp a, b; jle @@end;
  mov a, b; @@end:
end;

function max(const a, b: integer): integer; assembler; asm
  cmp a, b; jge @@end;
  mov a, b; @@end:
end;

function IntoStr(const I: integer; const digits: integer = 0): string;
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

function IntoHex_Old(const I: Int64; const Digits: byte = sizeof(byte)): string; register; forward;
function IntoHex(const I: Int64; const Digits: byte = sizeof(byte)): string;
begin
  Result := IntoHex_Old(I, Digits);
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


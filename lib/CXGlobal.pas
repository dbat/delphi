unit CxGlobal;
{
  Version: 1.0.0.0
  Provides global uppercase/lowercase table

  Copyright 2004-2006, aa, Adrian H, & Ray AF
  Private property of PT SoftIndo, JAKARTA
  All rights reserved.

}
{.$WEAKPACKAGEUNIT ON}
{$J-} //no-writeableconst
{$R-} //no-rangechecking
{$Q-} //no-overflowchecking
{.$D-}//no-debug

interface

type
  TCharsTable = array[Char] of Char;
  //TWideCharsTable = array[WideChar] of WideChar;
  //StrRec = packed record
  //  AllocSize, RefCount, Length: Longint;
  //end;

const
  YES = TRUE;
  NAY = not TRUE;
  //StrRecSize = sizeof(StrRec);
  //szLen = -StrRecSize + sizeof(Longint) + sizeof(Longint);
  szLen = -4;
  MAXBYTE = high(byte);
  MAXWORD = high(word);
  PAGESIZE = MAXBYTE + 1;
  CPUID = $A20F;
  RDTSC = $310F;

const
  ZERO = 0;
  BLANK = '';
  VOID = pointer(ZERO);

const
  INVALID_RETURN_VALUE = -1;

var
  UPCASETABLE, locasetable: TCharsTable; //array[char] of char;

implementation

procedure makemeUpNDown;
// manual maps (overwritten)
// UP  ~ LO  diff/offset
// ----------------------
// D7h ~ D7h ~> 0
// DFh ~ DFh ~> 0
// F7h ~ F7h ~> 0
// 8Ah ~ 9Ah ~> 10h (16)
// 8Ch ~ 9Ch ~> 10h (16)
// 8Eh ~ 9Eh ~> 10h (16)
// 9Fh ~ FFh ~> 60H (96)
//   overwritten: DFh in upcase table
const
  HICASEBIT = 5; HICASEOFFSET = 1 shl HICASEBIT;
  MIDOFFSET = $10; LASTOFFSET = $60;

  procedure makelo(const CharsTable); // ugly but much faster
  assembler asm
    @@Start:
      push eax; push ecx; push edx
      //lea EDX, locasetable
      mov edx, CharsTable
      xor eax, eax; mov ecx, eax

      mov cl, 'Z' - 'A'
    @LoopA:
      lea eax, ecx + 'A' + HICASEOFFSET
      mov EDX[eax], al
      mov EDX[eax -HICASEOFFSET], al
      dec cl; jge @LoopA

      mov cl, 0E0H
    @LoopGreek:
      mov eax, ecx; mov EDX[eax], al
      mov EDX[eax -HICASEOFFSET], al
      inc cl; ja @LoopGreek

    @fillblank: mov cl, 'A'
    @Loop1: dec cx; mov EDX[ecx], cl; jg @Loop1

      mov cl, 'a' - 'Z' -1
     @Loop2:
      lea eax, ecx + 'Z'; mov EDX[eax], al
      dec cl; jg @Loop2

      mov cl, 0C0H - 'z' -1
     @Loop3:
      lea eax, ecx + 'z'; mov EDX[eax], al
      dec ecx; jg @Loop3

    @@manual_maps:
      @_nolocase:
        mov al, $D7; mov EDX[eax], al
        mov al, $F7; mov EDX[eax], al
        mov al, $DF; mov EDX[eax], al
      @_midlo:
        mov al, $9A; mov EDX[eax-MIDOFFSET], al
        mov al, $9C; mov EDX[eax-MIDOFFSET], al
        mov al, $9E; mov EDX[eax-MIDOFFSET], al
      @_lastlo:
        mov al, $FF; mov EDX[eax-LASTOFFSET], al

      pop edx; pop ecx; pop eax
    @@Stop:
  end;

  procedure makeup(const CharsTable);
  assembler asm
    @@Start:
      push eax; push ecx; push edx
      //lea EDX, UPCASETABLE
      mov edx, CharsTable
      xor eax, eax; mov ecx, eax

     mov cl, 'Z' - 'A'
    @LoopA:
      lea eax, ecx + 'A'
      mov EDX[eax], al
      mov EDX[eax +HICASEOFFSET], al
      dec cl; jge @LoopA

      mov cl, 0E0H
    @LoopGreek:
      lea eax, ecx -HICASEOFFSET
      mov EDX[eax], al
      mov EDX[eax +HICASEOFFSET], al
      inc cl; ja @LoopGreek

    @fillblank: mov cl, 'A'
    @Loop1: dec cx; mov EDX[ecx], cl; jg @Loop1

      mov cl, 'a' - 'Z' -1
     @Loop2:
      lea eax, ecx + 'Z'; mov EDX[eax], al
      dec cl; jg @Loop2

      mov cl, 0C0H - 'z' -1
     @Loop3:
      lea eax, ecx + 'z'; mov EDX[eax], al
      dec ecx; jg @Loop3

    @@manual_maps:
      @_noupcase:
        mov al, $D7; mov EDX[eax], al
        mov al, $F7; mov EDX[eax], al
        mov al, $DF; mov EDX[eax], al
      @_midup:
        mov al, $8A; mov EDX[eax+MIDOFFSET], al
        mov al, $8C; mov EDX[eax+MIDOFFSET], al
        mov al, $8E; mov EDX[eax+MIDOFFSET], al
      @_lastup:
        mov al, $9F; mov EDX[eax+LASTOFFSET], al

      pop edx; pop ecx; pop eax
    @@Stop:
  end;

begin
  makeup(UPCASETABLE);
  makelo(locasetable); // :)
end;

{.$DEFINE DEBUG}

{$IFDEF DEBUG}
{$DEFINE MSWINDOWS}

function min(const a, b: integer): integer; asm
  xor ecx,ecx; sub edx,eax
  setge cl; sub ecx,1
  and edx,ecx; add eax,edx
end;

function max(const a, b: integer): integer; asm
  xor ecx,ecx; sub edx,eax
  setl cl; sub ecx,1
  and edx,ecx; add eax,edx
end;

procedure WinMakemeUpNDown; forward;

function intoStr(const I: integer; const digits: Integer = 0): string;
const
  zero = '0';
  dash = '-';
var
  n: integer;
begin
  if i = 0 then
    Result := StringOfChar(zero, max(1, digits))
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

procedure CheckCharstable;
var
  UPCHARS, lochars: TCharsTable;
  c: char;
  S: string;
begin
  makemeUpNDown;
  move(UPCASETABLE, UPCHARS, sizeof(UPCHARS));
  move(locasetable, lochars, sizeof(lochars));
  WinMakemeUpNDown;
  S := 'UPCASE';

  for c := low(UPCHARS) to high(UPCHARS) do begin
    if UPCHARS[c] <> UPCASETABLE[c] then
      S := S + ^j + intoStr(ord(UPCHARS[c])) + ^i + intoStr(ord(UPCASETABLE[c]));
  end;

  S := S + ^j + 'LOCASE';
  for c := low(lochars) to high(lochars) do begin
    if lochars[c] <> locasetable[c] then
      S := S + ^j + intoStr(ord(lochars[c])) + ^i + intoStr(ord(locasetable[c]));
  end;

  if s <> '' then
    writeln(S);
end;
{$ENDIF DEBUG}

{$IFDEF MSWINDOWS}
const
  user32 = 'user32.dll';

function BuildUpcase(Table: TCharsTable; Length: integer): integer; stdcall;
  external user32 name 'CharUpperBuffA';

function BuildLocase(Table: TCharsTable; Length: integer): integer; stdcall;
  external user32 name 'CharLowerBuffA';

procedure WinMakemeUpNDown;
  procedure makeseries(const CharsTable);
  asm
    @@Start:
      mov edx, CharsTable
      xor eax, eax
    @Loop:
      mov edx[eax], al
      inc al
      jnz @Loop
    @@Stop:
  end;
begin
  makeseries(UPCASETABLE);
  makeseries(locasetable);
  BuildUpcase(UPCASETABLE, sizeof(UPCASETABLE));
  BuildLocase(locasetable, sizeof(locasetable));
end;
{$ENDIF WINDOWS}

initialization
{$IFDEF DEBUG}
  CheckCharsTable;
{$ELSE}
{$IFDEF MSWINDOWS}
  WinMakemeUpNDown;
{$ELSE IFNDEF MSWINDOWS}
  makemeUpNDown;
{$ENDIF MSWINDOWS}
{$ENDIF}
end.


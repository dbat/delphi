unit OrdStr;

interface
const
  MaxInt64 = high(int64); //9223372036854775807 *2
  MaxUInt64 = 18446744073709551615.0 + 1; // round error adjustment bit-1

function Div10(const I: int64; const r: integer): int64; overload;
function Div10(const I: integer): integer; overload;

function IntoString(const I: integer): string; overload // longstring version, fast
function IntoS(const I: integer): shortstring; overload // shortstring version, faster
function IntToStr_(Value: Integer): string;

implementation
uses minmaxmid;
const
  Int64e00 = round(MaxUInt64 / 1E00); //18 446 744 073 709 551 615;
  Int64e01 = round(MaxUInt64 / 1E01); // 1 844 674 407 370 955 162;
  Int64e02 = round(MaxUInt64 / 1E02); //   184 467 440 737 095 516;
  Int64e03 = round(MaxUInt64 / 1E03); //    18 446 744 073 709 552;
  Int64e04 = round(MaxUInt64 / 1E04); //     1 844 674 407 370 955;
  Int64e05 = round(MaxUInt64 / 1E05); //       184 467 440 737 096;
  Int64e06 = round(MaxUInt64 / 1E06); //        18 446 744 073 710;
  Int64e07 = round(MaxUInt64 / 1E07); //         1 844 674 407 371;
  Int64e08 = round(MaxUInt64 / 1E08); //           184 467 440 737;
  Int64e09 = round(MaxUInt64 / 1E09); //            18 446 744 074;
  Int64e10 = round(MaxUInt64 / 1E10); //             1 844 674 407;
  Int64e11 = round(MaxUInt64 / 1E11); //               184 467 441;
  Int64e12 = round(MaxUInt64 / 1E12); //                18 446 744;
  Int64e13 = round(MaxUInt64 / 1E13); //                 1 844 674;
  Int64e14 = round(MaxUInt64 / 1E14); //                   184 467;
  Int64e15 = round(MaxUInt64 / 1E15); //                    18 447;
  Int64e16 = round(MaxUInt64 / 1E16); //                     1 845;
  Int64e17 = round(MaxUInt64 / 1E17); //                       184;
  Int64e18 = round(MaxUInt64 / 1E18); //                        18;
  Int64e19 = round(MaxUInt64 / 1E19); //                         2;

  KInt64ext: array[0..19] of int64 = (
    Int64e00, Int64e01, Int64e02, Int64e03, Int64e04,
    Int64e05, Int64e06, Int64e07, Int64e08, Int64e09,
    Int64e10, Int64e11, Int64e12, Int64e13, Int64e14,
    Int64e15, Int64e16, Int64e17, Int64e18, Int64e19
    );

  Int64e00Lo = cardinal(Int64e00);
  Int64e01Lo = cardinal(Int64e01);
  Int64e02Lo = cardinal(Int64e02);
  Int64e03Lo = cardinal(Int64e03);
  Int64e04Lo = cardinal(Int64e04);
  Int64e05Lo = cardinal(Int64e05);
  Int64e06Lo = cardinal(Int64e06);
  Int64e07Lo = cardinal(Int64e07);
  Int64e08Lo = cardinal(Int64e08);
  Int64e09Lo = cardinal(Int64e09);
  Int64e10Lo = cardinal(Int64e10);
  Int64e11Lo = cardinal(Int64e11);
  Int64e12Lo = cardinal(Int64e12);
  Int64e13Lo = cardinal(Int64e13);
  Int64e14Lo = cardinal(Int64e14);
  Int64e15Lo = cardinal(Int64e15);
  Int64e16Lo = cardinal(Int64e16);
  Int64e17Lo = cardinal(Int64e17);
  Int64e18Lo = cardinal(Int64e18);
  Int64e19Lo = cardinal(Int64e19);

  KInt64extLo: array[0..19] of cardinal = (
    Int64e00Lo, Int64e01Lo, Int64e02Lo, Int64e03Lo, Int64e04Lo,
    Int64e05Lo, Int64e06Lo, Int64e07Lo, Int64e08Lo, Int64e09Lo,
    Int64e10Lo, Int64e11Lo, Int64e12Lo, Int64e13Lo, Int64e14Lo,
    Int64e15Lo, Int64e16Lo, Int64e17Lo, Int64e18Lo, Int64e19Lo
    );

  Int64e00Hi = cardinal(Int64e00 shr 32);
  Int64e01Hi = cardinal(Int64e01 shr 32);
  Int64e02Hi = cardinal(Int64e02 shr 32);
  Int64e03Hi = cardinal(Int64e03 shr 32);
  Int64e04Hi = cardinal(Int64e04 shr 32);
  Int64e05Hi = cardinal(Int64e05 shr 32);
  Int64e06Hi = cardinal(Int64e06 shr 32);
  Int64e07Hi = cardinal(Int64e07 shr 32);
  Int64e08Hi = cardinal(Int64e08 shr 32);
  Int64e09Hi = cardinal(Int64e09 shr 32);
  Int64e10Hi = cardinal(Int64e10 shr 32);
  Int64e11Hi = cardinal(Int64e11 shr 32);
  Int64e12Hi = cardinal(Int64e12 shr 32);
  Int64e13Hi = cardinal(Int64e13 shr 32);
  Int64e14Hi = cardinal(Int64e14 shr 32);
  Int64e15Hi = cardinal(Int64e15 shr 32);
  Int64e16Hi = cardinal(Int64e16 shr 32);
  Int64e17Hi = cardinal(Int64e17 shr 32);
  Int64e18Hi = cardinal(Int64e18 shr 32);
  Int64e19Hi = cardinal(Int64e19 shr 32);

  KInt64extHi: array[0..19] of cardinal = (
    Int64e00Hi, Int64e01Hi, Int64e02Hi, Int64e03Hi, Int64e04Hi,
    Int64e05Hi, Int64e06Hi, Int64e07Hi, Int64e08Hi, Int64e09Hi,
    Int64e10Hi, Int64e11Hi, Int64e12Hi, Int64e13Hi, Int64e14Hi,
    Int64e15Hi, Int64e16Hi, Int64e17Hi, Int64e18Hi, Int64e19Hi
    );

type
  t1EPos = 1..9;
  t1Efactor = 1..18;

var
  Int1E: array[t1EPos, t1Efactor] of int64;

function powX(Base, factor: extended): extended; overload;
begin
  Result := exp(factor * ln(Base));
end;

function pow10(n: extended): extended; overload;
begin
  Result := powX(10, n);
end;

procedure initInt1E;
var
  p: T1EPos;
  f: T1Efactor;
begin
  for p := low(p) to high(p) do
    for f := low(f) to high(f) do
      Int1E[p, f] := round(p * pow10(f))
end;

function Mod10(const I: int64): int64;
begin
  Result := 0;
end;

type
  TCRow = 0..8;
  TCColumn = 1..12;

const
  RowCount = high(TCRow) - low(TCRow) + 1;
  RowCount_1 = RowCount - 1;
  ColCount = high(TCColumn) - low(TCColumn) + 1;

  r1Ex = high(cardinal) + 1.0; // + 1.0;
  r00 = high(cardinal);
  r01 = cardinal(round(r1Ex / 1E1)); // 429 496 730
  r02 = cardinal(round(r1Ex / 1E2)); //  42 949 673
  r03 = cardinal(round(r1Ex / 1E3)); //1000 //   4 294 967
  r04 = cardinal(round(r1Ex / 1E4)); // + 1; //99.997     429 497
  f5 = 09 +0; fr5 = 1 shl f5; r05 = cardinal(round(r1Ex * fr5 / 1E5)); // + 1; //199.999 //      42 950
  f6 = 15 +4; fr6 = 1 shl f6; r06 = cardinal(round(r1Ex * fr6 / 1E6)); //       4 295
  f7 = 18 +5; fr7 = 1 shl f7; r07 = cardinal(round(r1Ex * fr7 / 1E7)); //         429
  f8 = 25 +1; fr8 = 1 shl f8; r08 = cardinal(round(r1Ex * fr8 / 1E8)); //          43
  f9 = 28 +0; fr9 = 1 shl f9; r09 = cardinal(round(r1Ex * fr9 / 1E9)); //           4
  //f10 = 0; fr10 = 1 shl f10; r10 = cardinal(round(r1Ex * fr10 / 1E10)); //          0

  rC4 = 10000; rC5 = 100000; rC6 = 1000000; rC7 = 10000000; rC8 = 100000000; rC9 = Cardinal(1000000000);
  rColIndex = 10; // column position of reciprocal value in the table, 0-wise
  CTable: packed array(.TCRow, TCColumn.) of cardinal = (
//  (0, 0001, 0002, 0003, 0004, 0005, 0006, 0007, 0008, 0009, r00, 0), // <- NOT-USED ANYWAY
//(*                                                                   //
    (0, 0010, 0020, 0030, 0040, 0050, 0060, 0070, 0080, 0090, r01, 0), // the last columns are-
    (0, 0100, 0200, 0300, 0400, 0500, 0600, 0700, 0800, 0900, r02, 0), // used only for padding
    (0, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, r03, 0), //
    (0, 1*rC4, 2*rC4, 3*rC4, 4*rC4, 5*rC4, 6*rC4, 7*rC4, 8*rC4, 9*rC4, r04, 0),
    (0, 1*rC5, 2*rC5, 3*rC5, 4*rC5, 5*rC5, 6*rC5, 7*rC5, 8*rC5, 9*rC5, r05, 0),
    (0, 1*rC6, 2*rC6, 3*rC6, 4*rC6, 5*rC6, 6*rC6, 7*rC6, 8*rC6, 9*rC6, r06, 0),
    (0, 1*rC7, 2*rC7, 3*rC7, 4*rC7, 5*rC7, 6*rC7, 7*rC7, 8*rC7, 9*rC7, r07, 0),
    (0, 1*rC8, 2*rC8, 3*rC8, 4*rC8, 5*rC8, 6*rC8, 7*rC8, 8*rC8, 9*rC8, r08, 0),
    (0, 1*rC9, 2*rC9, 3*rC9, 4*rC9, 5*000, 6*000, 7*000, 8*000, 9*000, r09, 0)
//*)
    );
{
  Nominal	Double			Extended
  1.000E+0	3FF0 0000 0000 0000	3FFF 8000 0000 0000 0000
  -1.000E+0	BFF0 0000 0000 0000	BFFF 8000 0000 0000 0000
  1.000E+10	4202 A05F 2000 0000	4020 9502 F900 0000 0000
  1.000E+1	4024 0000 0000 0000	4002 A000 0000 0000 0000
  1.000E+0	3FF0 0000 0000 0000	3FFF 8000 0000 0000 0000
  1.000E-1	3FB9 9999 9999 999A	3FFB CCCC CCCC CCCC CCCD
  1.000E-2	3F84 7AE1 47AE 147B	3FF8 A3D7 0A3D 70A3 D70A
  1.000E-3	3F50 624D D2F1 A9FC	3FF5 8312 6E97 8D4F DF3B
  1.000E-4	3F1A 36E2 EB1C 432D	3FF1 D1B7 1758 E219 652C
  1.000E-5	3EE4 F8B5 88E3 68F1	3FEE A7C5 AC47 1B47 8423
  1.000E-6	3EB0 C6F7 A0B5 ED8D	3FEB 8637 BD05 AF6C 69B6
  1.000E-7	3E7A D7F2 9ABC AF48	3FE7 D6BF 94D5 E57A 42BC
  1.000E-8	3E45 798E E230 8C3A	3FE4 ABCC 7711 8461 CEFD
  1.000E-9	3E11 2E0B E826 D695	3FE1 8970 5F41 36B4 A597
  1.000E-10	3DDB 7CDF D9D7 BDBB	3FDD DBE6 FECE BDED D5BF
  1.000E-11	3DA5 FD7F E179 6495	3FDA AFEB FF0B CB24 AAFF
  1.000E-12	3D71 9799 812D EA11	3FD7 8CBC CC09 6F50 88CC
  1.000E-13	3D3C 25C2 6849 7682	3FD3 E12E 1342 4BB4 0E13
  1.000E-14	3D06 849B 86A1 2B9B	3FD0 B424 DC35 095C D80F
  1.000E-15	3CD2 03AF 9EE7 5616	3FCD 901D 7CF7 3AB0 ACD9
  1.000E-16	3C9C D2B2 97D8 89BC	3FC9 E695 94BE C44D E15B
  1.000E-17	3C67 0EF5 4646 D497	3FC6 B877 AA32 36A4 B449
  1.000E-18	3C32 725D D1D2 43AC	3FC3 9392 EE8E 921D 5D07
  1.000E-19	3BFD 83C9 4FB6 D2AC	3FBF EC1E 4A7D B695 61A5
  1.000E-20	3BC7 9CA1 0C92 4223	3FBC BCE5 0864 9211 1AEB
}

function fBase10(const I: integer): integer; overload asm
end;

function Div10(const I: integer): integer; overload asm
  mov edx, 9
  cmp eax, 10; sbb edx, 0//edx //less than 100
  cmp eax, 100; sbb edx, 0//edx //less than 1000
  cmp eax, 1000; sbb edx, 0//edx //less than 10^4
  cmp eax, 10000; sbb edx, 0//edx //less than 10^5
  cmp eax, 100000; sbb edx, 0//edx //less than 10^6
  cmp eax, 1000000; sbb edx, 0//edx //less than 10^7
  cmp eax, 10000000; sbb edx, 0//edx //less than 10^8
  cmp eax, 100000000; sbb edx, 0//edx //less than 10^9
  cmp eax, 1000000000; sbb edx, 0//edx //less than 10^9

  //shl edx, 2
  //shr eax,1
  //and eax, 0fffffff0h
  jmp dword ptr @@branch+edx*4

@@mul00: xor eax,eax; ret
@@mul01: mov edx, r01; mul edx; mov eax, edx; ret
@@mul02: mov edx, r02; mul edx; mov eax, edx; ret
@@mul03: mov edx, r03; mul edx; mov eax, edx; ret
@@mul04: mov edx, r04; mul edx; mov eax, edx; ret
@@mul05: mov edx, r05; mul edx; shr edx, f5; mov eax, edx; ret
@@mul06: mov edx, r06; mul edx; shr edx, f6; mov eax, edx; ret
@@mul07: mov edx, r07; mul edx; shr edx, f7; mov eax, edx; ret
@@mul08: mov edx, r08; mul edx; shr edx, f8; mov eax, edx; ret
@@mul09: mov edx, r09; mul edx; shr edx, f9; mov eax, edx; ret
//@@mul10: mov edx, r10; mul edx; shr edx, f10; mov eax, edx; ret
@@mul11: ret

@@branch:
  dd @@mul00, @@mul01, @@mul02, @@mul03, @@mul04,  @@mul05
  dd @@mul06, @@mul07, @@mul08, @@mul09//, @@mul10,  @@mul11
end;

function Div10(const I: int64; const r: integer): int64; overload asm

end;

function IntoString(const I: integer): string; overload asm
  push esi; push edi; push ebx
  push eax

  mov eax, Result //mov eax, Result
  call System.@LStrClr
  mov edx, 10h
  call System.@LStrSetLength
  mov esi, eax
  mov edi, [eax]

  pop edx
  mov eax, edx
  sar edx, 31  // sign bits in edx
  xor eax, edx  // toggle all bits if negative
  sub eax, edx  // add 1 if negative
  mov byte ptr [edi], '-'
  sub edi, edx  // add 1 if negative

  cmp eax, 10; jb @@r01 // less than 10, single digit will be passed through
  mov ecx, eax
  xor edx, edx

  mov ebx, RowCount-1
  //cmp eax, r09; sbb ebx, 0//edx // single digit already catched
  cmp eax, r08; sbb ebx, 0//edx //less than 100
  cmp eax, r07; sbb ebx, 0//edx //less than 1000
  cmp eax, r06; sbb ebx, 0//edx //less than 10^4
  cmp eax, r05; sbb ebx, 0//edx //less than 10^5
  cmp eax, r04; sbb ebx, 0//edx //less than 10^6
  cmp eax, r03; sbb ebx, 0//edx //less than 10^7
  cmp eax, r02; sbb ebx, 0//edx //less than 10^8
  cmp eax, r01; sbb ebx, 0//edx //less than 10^9

  // below is for ColCount = 12, should be adjusted properly
  // ie, if we use 16 columns (for lazy) simply do shl ebx, 4
  lea ebx, ebx*2+ebx      // ebx * 3
  // shl ebx, 2           // ebx * 4

  // and this is for sizeof integer (4)
  // shl ebx, 2           // ebx * 4

  shl ebx, 4              // let's do it at once instead

@@love:
  mov edx, ebx[CTable+rColIndex*4]//r09
  mul edx
//  sub ecx, ebx[CTable+edx*4]
  sub ecx, dword ptr CTable[ebx+edx*4]
  mov eax, ecx
  or edx, '0'; mov [edi], dl
  lea edi, edi +1
  sub ebx, ColCount*4
  jge @@love //jg if Row-0 counted, jge if it is not

@@r01:
  or eax,'0'; stosb
  mov eax, esi
  sub edi, [esi]
  mov edx, edi
  call System.@LStrSetLength
  pop ebx; pop edi; pop esi
end;
//==============================================

//==============================================
function IntoS(const I: integer): shortstring; overload asm
  push esi; push edi; push ebx
  lea edi, Result+1
  mov esi, Result
  mov dword ptr [Result], '----'

  cdq           // sign bits in edx
  xor eax, edx  // toggle all bits if negative
  sub eax, edx  // add 1 if negative
  sub edi, edx  // add 1 if negative

  cmp eax, 10; jb @@r01 // less than 10, single digit will be passed through
  mov ecx, eax
  xor edx, edx

  mov ebx, RowCount-1
  //cmp eax, r09; sbb ebx, 0//edx // single digit already catched
  cmp eax, r08; sbb ebx, 0//edx //less than 100
  cmp eax, r07; sbb ebx, 0//edx //less than 1000
  cmp eax, r06; sbb ebx, 0//edx //less than 10^4
  cmp eax, r05; sbb ebx, 0//edx //less than 10^5
  cmp eax, r04; sbb ebx, 0//edx //less than 10^6
  cmp eax, r03; sbb ebx, 0//edx //less than 10^7
  cmp eax, r02; sbb ebx, 0//edx //less than 10^8
  cmp eax, r01; sbb ebx, 0//edx //less than 10^9

  // below is for ColCount = 12, should be adjusted properly
  // ie, if we use 16 columns (for lazy) simply do shl ebx, 4
  lea ebx, ebx*2+ebx      // ebx * 3
  // shl ebx, 2           // ebx * 4

  // and this is for sizeof integer (4)
  // shl ebx, 2           // ebx * 4

  shl ebx, 4              // let's do it at once instead

@@love:
  mov edx, dword ptr CTable[ebx+rColIndex*4]//r09
  mul edx
  sub ecx, dword ptr CTable[ebx+edx*4]
  mov eax, ecx
  or edx, '0'; mov [edi], dl
  lea edi, edi +1
  sub ebx, ColCount*4
  jge @@love //jg if Row-0 counted, jge if it is not

@@r01:
  or eax,'0'; stosb

  lea edx, edi-1
  sub edx, esi
  mov [esi], dl
  mov eax, esi  // save result
  pop ebx; pop edi; pop esi
end;

const
  TwoDigitLookup: packed array[0..99] of array[1..2] of Char =
  ('00', '01', '02', '03', '04', '05', '06', '07', '08', '09',
    '10', '11', '12', '13', '14', '15', '16', '17', '18', '19',
    '20', '21', '22', '23', '24', '25', '26', '27', '28', '29',
    '30', '31', '32', '33', '34', '35', '36', '37', '38', '39',
    '40', '41', '42', '43', '44', '45', '46', '47', '48', '49',
    '50', '51', '52', '53', '54', '55', '56', '57', '58', '59',
    '60', '61', '62', '63', '64', '65', '66', '67', '68', '69',
    '70', '71', '72', '73', '74', '75', '76', '77', '78', '79',
    '80', '81', '82', '83', '84', '85', '86', '87', '88', '89',
    '90', '91', '92', '93', '94', '95', '96', '97', '98', '99');

const
  MinInt64: string = '-9223372036854775808';

const
  IntegerPowerOfTen: array[0..9] of Integer =
  (1,
    10,
    100,
    1000,
    10000,
    100000,
    1000000,
    10000000,
    100000000,
    1000000000);

  Int64PowerOfTen: array[9..18] of Int64 =
  (1000000000,
    10000000000,
    100000000000,
    1000000000000,
    10000000000000,
    100000000000000,
    1000000000000000,
    10000000000000000,
    100000000000000000,
    1000000000000000000);

function IntToStr_(Value: Integer): string;
asm
  push   ebx
  push   edi
  push   esi
  mov    ebx, eax                {Value}
  mov    edi, edx                {Result Address}
  sar    ebx, 31                 {0 for +ve Value or -1 for -ve Value}
  xor    eax, ebx
  sub    eax, ebx                {ABS(Value)}
 mov    edx, 10                  {Default Digit Count}
  cmp    eax, 10000              {Calculate Number of Digits within Result}
  jae    @@5orMoreDigits
  cmp    eax, 100
  jae    @@3or4Digits
  cmp    eax, 10
  mov    dl, 2                   {1 or 2 Digits}
  jmp    @@SetLength
@@3or4Digits:
  cmp    eax, 1000
  mov    dl, 4                   {3 or 4 Digits}
  jmp    @@SetLength
@@5orMoreDigits:
  cmp    eax, 1000000
  jae    @@7orMoreDigits
  cmp    eax, 100000
  mov    dl, 6                   {5 or 6 Digits}
  jmp    @@SetLength
@@7orMoreDigits:
  cmp    eax, 100000000
  jae    @@9or10Digits
  cmp    eax, 10000000
  mov    dl, 8                   {7 or 8 Digits}
  jmp    @@SetLength
@@9or10Digits:
  cmp    eax, 1000000000         {9 or 10 Digits}
@@SetLength:
  sbb    edx, ebx                {Digits (Including Sign Character)}
  mov    ecx, [edi]              {Result}
  mov    esi, edx                {Digits (Including Sign Character)}
  test   ecx, ecx
  je     @@Alloc                 {Result Not Already Allocated}
  cmp    dword ptr [ecx-8], 1
  jne    @@Alloc                 {Reference Count <> 1}
  cmp    edx, [ecx-4]
  je     @@SizeOk                {Existing Length = Required Length}
@@Alloc:
  push   eax                     {ABS(Value)}
  mov    eax, edi
  call   system.@LStrSetLength   {Create Result String}
  pop    eax                     {ABS(Value)}
@@SizeOk:
  mov    edi, [edi]              {@Result}
  add    esi, ebx                {Digits (Excluding Sign Character)}
  mov    byte ptr [edi], '-'     {Store '-' Character (May be Overwritten)}
  sub    edi, ebx                {Destination of 1st Digit}
  sub    esi, 2                  {Digits (Excluding Sign Character) - 2}
  jle    @@FinalDigits           {1 or 2 Digits}
  //mov    ecx, $51eb851f          {Multiplier for Division by 100}
                                 // 1374389535 / 4294967296 = 0.32

  mov ecx, 0A3D70A3Dh
@@Loop:
  mov    ebx, eax                {Dividend}
  mul    ecx
  shr    edx, 5+1                  {Dividend DIV 100}
  mov    eax, edx                // eax = edx div 32 {Set Next Dividend}
  lea    edx, [edx*4+edx]        // edx*5
  lea    edx, [edx*4+edx]        // edx*5
  shl    edx, 2                  // edx*4 {Dividend DIV 100 * 100}
  sub    ebx, edx                {Dividend MOD 100}
  sub    esi, 2
  movzx  ebx, word ptr [TwoDigitLookup+ebx*2]
  mov    [edi+esi+2], bx
  jg     @@Loop                  {Loop Until 1 or 2 Digits Remaining}
@@FinalDigits:
  jnz    @@LastDigit
  movzx  eax, word ptr [TwoDigitLookup+eax*2]
  mov    [edi], ax               {Save Final 2 Digits}
  jmp    @@Done
@@LastDigit:
  add    al , '0'                {Ascii Adjustment}
  mov    [edi], al               {Save Final Digit}
@@Done:
  pop    esi
  pop    edi
  pop    ebx
end;

initialization
  initInt1E

end.


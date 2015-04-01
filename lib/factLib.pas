
unit FactLib;
{
  Copyright (c) 2004, aa, Inge DR. & Adrian Hafizh.
  Property of PT SOFTINDO Jakarta.
  All rights reserved.

  mailto:aa|AT|formasi|DOT|com,  http://delphi.formasi.com

  This software is free for non-commercial purposes,

  Version: 1.0.0
  Dated: 20040204

// PERMUTASI
// =========
// ---12345678901234567890123456789---123456789012345678901234567890
// 01:1                            01:1
// 02:2                            02:2
// 03:6                            03:6
// 04:18                           04:24
// 05:78                           05:120
// 06:2D0                          06:720
// 07:13B0                         07:5040
// 08:9D80                         08:40320
// 09:58980                        09:362880
// 0A:375F00                       10:3628800
// 0B:2611500                      11:39916800
// 0C:1C8CFC00                     12:479001600
// 0D:17328CC00                    13:6227020800
// 0E:144C3B2800                   14:87178291200
// 0F:13077775800                  15:1307674368000
// 10:130777758000                 16:20922789888000
// 11:1437EEECD8000                17:355687428096000
// 12:16BEECCA730000               18:6402373705728000
// 13:1B02B9306890000              19:121645100408832000
// 14:21C3677C82B40000             20:2432902008176640000
// ---12345678901234567890123456789---123456789012345678901234567890
// 15:2C5077D36B8C40000            21:51090942171709440000
// 16:3CEEA4C2B3E0D80000           22:1124000727777607680000
// 17:57970CD7E2933680000          23:25852016738884976640000
// 18:83629343D3DCD1C00000         24:620448401733239439360000
// 19:CD4A0619FB0907BC00000        25:15511210043330985984000000
// ---12345678901234567890123456789---123456789012345678901234567890
// ---1234567890123456789012345678901234578901234---12345678901234567890123456789012345678901234567890
// 1A:14D9849EA37EEAC91800000                    26:403291461126605635584000000
// 1B:232F0FCBB3E62C3358800000                   27:10888869450418352160768000000
// 1C:3D925BA47AD2CD59DAE000000                  28:304888344611713860501504000000
// 1D:6F99461A1E9E1432DCB6000000                 29:8841761993739701954543616000000
// 1E:D13F6370F96865DF5DD54000000                30:265252859812191058636308480000000
// 1F:1956AD0AAE33A4560C5CD2C000000              31:8222838654177922817725562880000000
// 20:32AD5A155C6748AC18B9A580000000             32:263130836933693530167218012160000000
// 21:688589CC0E9505E2F2FEE5580000000            33:8683317618811886495518194401280000000
// 22:DE1BC4D19EFCAC82445DA75B00000000           34:295232799039604140847618609643520000000
// ---1234567890123456789012345678901234578901234---12345678901234567890123456789012345678901234567890
// 23:1E5DCBE8A8BC8B95CF58CDE17100000000         35:10333147966386144929666651337523200000000
// 24:44530ACB7BA83A111287CF3B3E400000000        36:371993326789901217467999448150835200000000
// 25:9E0008F68DF506477ADA0F38FFF400000000       37:13763753091226345046315979581580902400000000
// 26:1774015499125EEE9C3C5E4275FE3800000000     38:523022617466601111760007224100074291200000000
// 27:392AC33E351CC7659CD325C1FF9BA8800000000    39:20397882081197443358640281739902897356800000000
// 28:8EEAE81B84C7F27E080FDE64FF05254000000000   40:815915283247897734345611269596115894272000000000
// ---1234567890123456789012345678901234578901234---12345678901234567890123456789012345678901234567890
//

}

{.$D-}
interface
//uses BigMath;

const
  MAX_NTH = $20 + 2;
  VALID_MAX_N = 20 + 12;
  DECIMAL_CHAR_STR = '7689314052';
  HEXADECIMAL_CHAR_STR = '27E6FC859A13B04D';

type
  TMaxOrderRange = 1..MAX_NTH;
  TValidMaxOrderRange = 1..VALID_MAX_N;
  TAnOrderValidateOption = (evShrinkAnOrder, evExtendAnOrder, evShrinkBaseOrder, evExtendBaseOrder);

const
  MAX_N: integer = VALID_MAX_N;

function factors(const I: TValidMaxOrderRange): string;
function factorx(const I: TValidMaxOrderRange; const ZeroTrail: Boolean = FALSE): string;
function factor(const I: TValidMaxOrderRange; const ValidOnly: Boolean = TRUE): Int64;
function GetCombination(const Index: Int64; BaseOrder: string = HEXADECIMAL_CHAR_STR): string;
function GetCombination16(const Index: Int64; BaseOrder: string = HEXADECIMAL_CHAR_STR): string;
function GetCombination10(const Index: integer; BaseOrder: string = DECIMAL_CHAR_STR): string;
function ValidOrder(const Index: Int64; const BaseOrder: string): string;
function QuickSort(const S: string; const Ascending: Boolean = TRUE): string;
function GetIndexNo(AnOrder: string; BaseOrder: string = HEXADECIMAL_CHAR_STR): Int64;
procedure ValidateOrderChoice(var AnOrder: string; var BaseOrder: string;
  EVOption: TAnOrderValidateOption = evExtendBaseOrder);
//function I64uStr(x64: Int64): string;
function GetMaxCoefficient(const Value: Int64; const ValidOnly: Boolean = TRUE): integer;

implementation

uses Ordinals;

var
  List_factorials: array[TMaxOrderRange] of Int64 =
  (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
const
  FullOrder: string[MAX_NTH] = '0123456789ABCDEFGHIJKLMNOPQRSTUV';
  List_Factorials_s: array[TMaxOrderRange] of string = (
    //'1', '2', '6', '24', '120', '720', '5040', '40320', '362880', '3628800',
    //'39916800', '479001600', '6227020800', '87178291200', '1307674368000',
    //'20922789888000', '355687428096000', '6402373705728000', '121645100408832000',
    //'2432902008176640000',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '51090942171709440000', '1124000727777607680000',
    '25852016738884976640000', '620448401733239439360000',
    '15511210043330985984000000', '403291461126605635584000000',
    '10888869450418352160768000000', '304888344611713860501504000000',
    '8841761993739701954543616000000', '265252859812191058636308480000000',
    '8222838654177922817725562880000000', '263130836933693530167218012160000000',
    '8683317618811886495518194401280000000', '295232799039604140847618609643520000000'
    );
  List_Factorials_x: array[TMaxOrderRange] of string = (
    //'0000000000000001', '0000000000000002', '0000000000000006',
    //'0000000000000018', '0000000000000078', '00000000000002D0',
    //'00000000000013B0', '0000000000009D80', '0000000000058980',
    //'0000000000375F00', '0000000002611500', '000000001C8CFC00',
    //'000000017328CC00', '000000144C3B2800', '0000013077775800',
    //'0000130777758000', '0001437EEECD8000', '0016BEECCA730000',
    //'01B02B9306890000', '21C3677C82B40000',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '2C5077D36B8C40000', '3CEEA4C2B3E0D80000', '57970CD7E2933680000',
    '83629343D3DCD1C00000', 'CD4A0619FB0907BC00000', '14D9849EA37EEAC91800000',
    '232F0FCBB3E62C3358800000', '3D925BA47AD2CD59DAE000000',
    '6F99461A1E9E1432DCB6000000', 'D13F6370F96865DF5DD54000000',
    '1956AD0AAE33A4560C5CD2C000000', '32AD5A155C6748AC18B9A580000000',
    '688589CC0E9505E2F2FEE5580000000', 'DE1BC4D19EFCAC82445DA75B00000000'
    );

//function I64uStr(x64: Int64): string;
//var
//  r, lC, lS: integer;
//  C: string;
//  S: string;
//begin
//  if x64 >= 0 then
//    Result := intoStr(x64)
//  else begin
//    C := '0' + intoStr(high(x64));
//    S := intoStr(high(x64) + x64);
//    lC := length(C);
//    lS := length(S);
//    r := 2;
//    repeat
//      r := r + ord(C[lC]) - ord('0');
//      if lS > 0 then
//        r := r + ord(S[lS]) - ord('0');
//      C[lC] := Char((r mod 10) + ord('0'));
//      r := r div 10;
//      dec(lC); dec(lS);
//    until lC < 1;
//    Result := C;
//  end;
//end;

{$R+ percumah gak ngaruh musti di-set di project options - compiler}

function factor(const I: TValidMaxOrderRange; const ValidOnly: Boolean = TRUE): Int64;
begin
  //if I>high(TMaxOrderRange) then
  //  Result:= List_factorials[high(TMaxOrderRange)]
  //more restrict later, over 26 really are bogus numbers
  if (I > high(TValidMaxOrderRange) + 1) and (ValidOnly = TRUE) then
    Result := List_factorials[high(TValidMaxOrderRange) + 1]
  else
    Result := List_factorials[I];
end;
{$R-}

function factors(const I: TValidMaxOrderRange): string;
var
  X: Int64;
begin
  X := factor(I, FALSE);
  if I <= VALID_MAX_N then begin
    Result := uintoStr(X);
  end
  else
    Result := List_Factorials_s[I];
end;

function factorx(const I: TValidMaxOrderRange; const ZeroTrail: Boolean = FALSE): string;
var
  X: Int64;
  Z: integer;
begin
  X := factor(I, FALSE);
  if ZeroTrail then
    Z := 16
  else
    Z := 0;
  if I <= VALID_MAX_N then
    Result := intoHex(X, Z)
  else
    Result := List_Factorials_x[I];
end;

function GetMaxCoefficient(const Value: Int64; const ValidOnly: Boolean = TRUE): integer;
var
  i: integer;
begin
  if Value < 0 then
    Result := VALID_MAX_N
  else
    for i := low(List_Factorials) to high(List_factorials) do begin
      Result := i - 1;
      if (List_Factorials[i] > Value) or (i > VALID_MAX_N) then
        break;
    end;
  if Result < 1 then
    Result := 1;
end;

procedure QSort(var S: string; L, R: integer; const Ascending: Boolean = TRUE);
var
  I, J: integer;
  P, Ch: Char;
begin
  repeat
    I := L; J := R;
    P := S[(L + R) shr 1];
    repeat
      if Ascending then begin
        while S[i] < P do inc(i);
        while S[j] > P do dec(j);
      end
      else begin
        while S[i] > P do inc(i);
        while S[j] < P do dec(j);
      end;
      if I <= J then begin
        //Exchange(I, J);
        Ch := S[i]; S[i] := S[j]; S[j] := Ch;
        Inc(I); Dec(J);
      end
    until I > J;
    if L < J then QSort(S, L, J, Ascending);
    L := I;
  until I >= R;
end;

procedure QSortA(var S: string; L, R: integer); //; const Ascending: Boolean = TRUE);
var
  I, J: integer;
  P, Ch: Char;
begin
  repeat
    I := L; J := R;
    P := S[(L + R) shr 1];
    repeat
      // if Ascending then begin
      while S[i] < P do inc(i);
      while S[j] > P do dec(j);
      // end
      // else begin
      //   while S[i] > P do inc(i);
      //   while S[j] < P do dec(j);
      // end;
      if I <= J then begin
        //Exchange(I, J);
        Ch := S[i]; S[i] := S[j]; S[j] := Ch;
        Inc(I); Dec(J);
      end
    until I > J;
    if L < J then QSortA(S, L, J); //, Ascending);
    L := I;
  until I >= R;
end;

procedure QSortD(var S: string; L, R: integer); //; const Ascending: Boolean = TRUE);
var
  I, J: integer;
  P, Ch: Char;
begin
  repeat
    I := L; J := R;
    P := S[(L + R) shr 1];
    repeat
      // if Ascending then begin
      //   while S[i] < P do inc(i);
      //   while S[j] > P do dec(j);
      // end
      // else begin
      while S[i] > P do inc(i);
      while S[j] < P do dec(j);
      // end;
      if I <= J then begin
        //Exchange(I, J);
        Ch := S[i]; S[i] := S[j]; S[j] := Ch;
        Inc(I); Dec(J);
      end
    until I > J;
    if L < J then QSortD(S, L, J); //, Ascending);
    L := I;
  until I >= R;
end;

function QuickSort(const S: string; const Ascending: Boolean = TRUE): string;
begin
  Result := S;
  QSort(Result, 1, length(Result), Ascending);
end;

function isValidOrder(const S: string): Boolean;
// to make sure there's no same/repeated char
var
  i: integer;
begin
  Result := TRUE;
  for i := 1 to length(S) do begin
    if pos(S[i], S) <> i then begin
      Result := FALSE;
      break;
    end;
  end;
end;

procedure ValidateAnOrder(var S: string; l: integer; const Expand: Boolean = TRUE);
var
  i: integer;
  Sx: string;
begin
  if l > VALID_MAX_N + 1 then
    l := VALID_MAX_N + 1;
  if (length(S) <> l) or not isValidOrder(S) then begin
    if Expand then
      Sx := S + FullOrder;
    S := '';
    i := 0;
    while (length(S) < l) and (i < length(sx)) do begin
      inc(i);
      if pos(sx[i], S) < 1 then
        S := S + sx[i];
    end;
  end;
end;

function PackOrder(const S: string): string;
begin
  Result := S;
  ValidateAnOrder(Result, length(Result), FALSE);
end;

function SortOrder(const S: string; const Ascending: Boolean = TRUE): string;
begin
  Result := PackOrder(S);
  QuickSort(Result, Ascending);
end;

function isValidOrderChoice(const AnOrder, BaseOrder: string): boolean;
var
  i: integer;
begin
  Result := length(AnOrder) = length(BaseOrder);
  if Result = TRUE then
    for i := 1 to length(BaseOrder) do
      if pos(AnOrder[i], BaseOrder) < 1 then begin
        Result := FALSE;
        break;
      end
end;

procedure ValidateOrderChoice(var AnOrder: string; var BaseOrder: string;
  EVOption: TAnOrderValidateOption = evExtendBaseOrder);

procedure ExtendAnOrder; var i: integer; begin
    for i := 1 to length(BaseOrder) do
      if pos(BaseOrder[i], AnOrder) < 1 then
        AnOrder := AnOrder + BaseOrder[i];
  end;

procedure ShrinkAnOrder; var i: integer; begin
    for i := length(AnOrder) downto 1 do
      if pos(AnOrder[i], BaseOrder) < 1 then
        delete(AnOrder, i, 1);
  end;

procedure ExtendBaseOrder; var i: integer; begin
    for i := 1 to length(AnOrder) do
      if pos(AnOrder[i], BaseOrder) < 1 then
        BaseOrder := BaseOrder + AnOrder[i];
  end;

procedure ShrinkBaseOrder; var i: integer; begin
    for i := length(BaseOrder) downto 1 do
      if pos(BaseOrder[i], AnOrder) < 1 then
        delete(BaseOrder, i, 1);
  end;

begin
  AnOrder := PackOrder(AnOrder);
  BaseOrder := PackOrder(BaseOrder);
  if not isValidOrderChoice(AnOrder, BaseOrder) then begin
    case EVOption of
      evShrinkAnOrder: begin
          ShrinkAnOrder;
          if length(BaseOrder) > length(AnOrder) then ShrinkBaseOrder;
        end;
      evExtendAnOrder: begin
          ExtendAnOrder;
          if length(AnOrder) > length(BaseOrder) then ExtendBaseOrder;
        end;
      evShrinkBaseOrder: begin
          ShrinkBaseOrder;
          if length(AnOrder) > length(BaseOrder) then ShrinkAnOrder;
        end;
      evExtendBaseOrder: begin
          ExtendBaseOrder;
          if length(BaseOrder) > length(AnOrder) then ExtendAnOrder;
        end;
    end;
  end;
end;

function ValidOrder(const Index: Int64; const BaseOrder: string): string;
var
  l, n: integer;
begin
  n := GetMaxCoefficient(Index); //dont forget, it's zero -based
  Result := BaseOrder;
  l := length(Result);
  if l < (n + 1) then l := (n + 1);
  ValidateAnOrder(Result, l);
end;

function GetCombination(const Index: Int64; BaseOrder: string = HEXADECIMAL_CHAR_STR): string;
//note that Index is zero based
var
  i, l, n: integer;
  X, r, t: Int64;

begin
  Result := '';
  r := Index; //dont forget, it's zero -based
  n := GetMaxCoefficient(r);
  l := length(BaseOrder);
  if l < (n + 1) then
    l := (n + 1);
  ValidateAnOrder(BaseOrder, l);
  for i := length(BaseOrder) - 1 downto 1 do begin
    //calculate divisor (of next-under-level factorial) and it's remainder
    X := factor(i);
    if r >= 0 then
      n := r div X
    else begin
      //special-case to overcome negative value
      t := high(r) mod X + (high(r) + r) mod X + 2 mod X; //2's complement
      n := high(r) div X + (high(r) + r) div X + t div X;
      r := t;
    end;
    Result := Result + BaseOrder[n + 1];
    delete(BaseOrder, n + 1, 1);
    r := r mod X;
  end;
  if BaseOrder <> '' then
    Result := Result + BaseOrder;
end;

function GetCombination16(const Index: Int64; BaseOrder: string = HEXADECIMAL_CHAR_STR): string;
var
  I, r: Int64;
begin
  if Index < 0 then begin
    r := high(Index) mod factor(16) + abs(Index) mod factor(16) + 2;
    I := r mod factor(16);
  end
  else
    I := Index mod factor(16);
  Result := GetCombination(I, BaseOrder);
end;

function GetCombination10(const Index: integer; BaseOrder: string = DECIMAL_CHAR_STR): string;
var
  I, r: integer;
begin
  if Index < 0 then begin
    r := high(Index) mod factor(10) + abs(Index) mod factor(10) + 2;
    I := r mod factor(10);
  end
  else
    I := Index mod factor(10);
  Result := GetCombination(I, Baseorder);
end;

function GetIndexNo_old(AnOrder: string; BaseOrder: string = HEXADECIMAL_CHAR_STR): Int64;
var
  n, k, L: integer;
  S: string;
  Ch: Char;

  function putElemen(const Ch: Char; const n: integer): integer;
  var
    i, j: integer;// t: integer;
    Cmi: char;
  begin
    Result := 1;
    if S = '' then S := Ch // just append if S is empty
    else begin
      //n := pos(Ch, BaseOrder);   // get pos of Ch in BaseOrder
      for i := 1 to Length(S) do begin
      // if pos(S[i], BaseOrder) > n then begin
      //   insert(Ch, S, pos(S[i], S));
      //   break;
      // end;
        Cmi := S[i]; // get current S[i]'s char
        j := pos(Cmi, BaseOrder); // where is Cm position in BaseOrder?
        if j > n then begin // is that position greater than pos Ch in BaseOrder
          //t := pos(Cmi, S); // yes. get Cm position in S
          //insert(Ch, S, t); // insert Ch at that position in S
          // stupid! t is identical with i
          insert(Ch, S, i); // insert Ch at that position in S
          break; // then out
        end;
      //skip, if pos(Cm) in BaseOrder <= pos(Ch) in BaseOrder
      end;
      if i > length(S) then
        S := S + Ch;
      //Result := pos(Ch, S);
      //stupid!  result is always i
      Result := i;
    end;
  end;
var
  //p, q: integer;
  q, SLen: integer;
  //Cr: Char;
begin
  S := ''; Result := 0;
  ValidateOrderChoice(AnOrder, BaseOrder);
  //L := length(AnOrder);
  //for n := L downto 1 do begin
  //  Ch := AnOrder[n];
  //  k := putElemen(Ch, n);
  //  dec(k);
  //  if k > 0 then // 0 mul any integer will always equal 0
  //                // also prevent factor(0); since k > 0
  //    Result := Result + factor(L - n) * Int64(k);
  //end;

  L := Length(AnOrder); if L < 1 then exit;
  Ch := AnOrder[L]; S := Ch;
  Result := pos(Ch, BaseOrder) - 1;

  for n := L - 1 downto 1 do begin
    Ch := AnOrder[n];
    //for k := 1 to Length(S) do
    //  if pos(S[k], BaseOrder) > n then begin
    //    insert(Ch, S, k);
    //    break;
    //  end;
    //if k > length(S) then S := S + Ch;
    k := 0; SLen := length(S);
    repeat
      inc(k);
      q := pos(S[k], BaseOrder);
    until (k > SLen) or (q > n);
    insert(Ch, S, k);
    if k > 1 then begin
      Result := Result + factor(L - n) * Int64(k - 1);
    end;
  end;
end;

function GetIndexNo_what(AnOrder: string; BaseOrder: string = HEXADECIMAL_CHAR_STR): Int64;
var
  S: string;
  Ch: Char;
  n, k, q, L, SLen: integer;
  X: int64;
begin
  S := ''; Result := 0;
  ValidateOrderChoice(AnOrder, BaseOrder);
  L := Length(AnOrder);
  if L > 0 then begin
    Ch := AnOrder[L]; S := Ch;
    for n := L - 1 downto 1 do begin
      Ch := AnOrder[n];
      k := 0; SLen := length(S);
      repeat
        inc(k);
        q := pos(S[k], BaseOrder);
      until (k > SLen) or (q > n);
      insert(Ch, S, k);
      //dec(k); // here k will be > 0
      //Result := Result + factor(L - n) * Int64(k);
      X := factor(L - n);
      repeat dec(k); inc(Result, X)
      until k = 0;
    end;
  end;
end;

function GetIndexNo(AnOrder: string; BaseOrder: string = HEXADECIMAL_CHAR_STR): Int64;
var
  i, n, L: integer;
  S: string;
  Ch: Char;

  function putElemen(const Ch: Char): integer;
  var
    i, n: integer;
  begin
    if S = '' then S := Ch
    else begin
      n := pos(Ch, BaseOrder);
      for i := 1 to Length(S) do begin
        if pos(S[i], BaseOrder) > n then begin
          insert(Ch, S, pos(S[i], S));
          break;
        end
      end;
      if i > length(S) then
        S := S + Ch;
    end;
    Result := pos(Ch, S);
  end;

begin
  S := ''; Result := 0;
  ValidateOrderChoice(AnOrder, BaseOrder);
  L := length(AnOrder);
  for i := L downto 1 do begin
    Ch := AnOrder[i];
    n := putElemen(Ch);
    dec(n);
    if n > 0 then //also prevent factor(0);
      Result := Result + factor(L - i) * Int64(n);
  end;
end;

function GetIndexNo_test(AnOrder: string; BaseOrder: string = HEXADECIMAL_CHAR_STR): Int64;
var
  i, n, L: integer;
  S: string;
  Ch: Char;

  function putElemen(const Ch: Char; const m: integer): integer;
  var
    i, n: integer;
  begin
    if S = '' then S := Ch
    else begin
      n := pos(Ch, BaseOrder);
      for i := 1 to Length(S) do begin
        if pos(S[i], BaseOrder) > n then begin
          insert(Ch, S, pos(S[i], S));
          break;
        end
      end;
      if i > length(S) then
        S := S + Ch;
    end;
    Result := pos(Ch, S);
  end;

begin
  S := ''; Result := 0;
  ValidateOrderChoice(AnOrder, BaseOrder);
  L := length(AnOrder);
  for i := L downto 1 do begin
    Ch := AnOrder[i];
    n := putElemen(Ch, i);
    dec(n);
    if n > 0 then //also prevent factor(0);
      Result := Result + factor(L - i) * Int64(n);
  end;
end;

procedure build_nth_factorials;
const
  anchor1 = VALID_MAX_N + 1;
  anchor2 = 24; anchor3 = 25; anchor4 = 26;
var
  i: integer;
begin
  for i := 1 to MAX_NTH do
    if i = 1 then
      List_factorials[1] := 1
    else if i = anchor1 then
      List_factorials[i] := (List_factorials[i - 1]shr$10 * i) //unsigned div $10000
    else if i = anchor2 then
      List_factorials[i] := (List_factorials[i - 1] * i)shr$4 //unsigned div $10
    else if i = anchor3 then
      List_factorials[i] := (List_factorials[i - 1] div 100 * i)
    else
      //if i=anchor4 then
      //  List_factorials[i]:= (List_factorials[i-1] * i) div 10
      //else
      List_factorials[i] := List_factorials[i - 1] * i;

end;

{ from bc
  1       1                               1
  2       2                               2
  3       6                               6
  4       18                              24
  5       78                              120
  6       2D0                             720
  7       13B0                            5040
  8       9D80                            40320
  9       58980                           362880
  10      375F00                          3628800
  11      2611500                         39916800
  12      1C8CFC00                        479001600
  13      17328CC00                       6227020800
  14      144C3B2800                      87178291200
  15      13077775800                     1307674368000
  16      130777758000                    20922789888000
  17      1437EEECD8000                   355687428096000
  18      16BEECCA730000                  6402373705728000
  19      1B02B9306890000                 121645100408832000
  20      21C3677C82B40000                2432902008176640000
  21      2C5077D36B8C40000               51090942171709440000
  22      3CEEA4C2B3E0D80000              1124000727777607680000
  23      57970CD7E2933680000             25852016738884976640000
  24      83629343D3DCD1C00000            620448401733239439360000
  25      CD4A0619FB0907BC00000           15511210043330985984000000
  26      14D9849EA37EEAC91800000         403291461126605635584000000
  27      232F0FCBB3E62C3358800000        10888869450418352160768000000
  28      3D925BA47AD2CD59DAE000000       304888344611713860501504000000
  29      6F99461A1E9E1432DCB6000000      8841761993739701954543616000000
  30      D13F6370F96865DF5DD54000000     265252859812191058636308480000000
  31      1956AD0AAE33A4560C5CD2C000000   8222838654177922817725562880000000
  32      32AD5A155C6748AC18B9A580000000  263130836933693530167218012160000000
}

initialization
  //randomize;
  build_nth_factorials;

end.


unit Rupiahs;

{
  Copyright (c) 2002, Adrian Hafizh, adrianhafizh@yahoo.com
  Private property of PT Softindo,  http://delphi.softindo.net

  Unit konversi rupiah dari angka (atau string digit)
    menjadi kalimat, termasuk pecahan sen jika ada

  kapasitas: trigintilion (96 digit),
    extensible dengan menambah definisi array tmoneybucket
  string digit bisa dalam format float, mis. 1e3, 1234e-2 dsb.
    (dalam format ini max presisi adalah 18 digit atau nilai max = 1e18 - 1)
  menggunakan localsetting untuk pemisah desimal
  opsi formatting khusus untuk nilai negatif dan nilai 0

  catatan:
    nilai dibulatkan sampai sen penuh
    input berupa blank string tidak akan diproses karena
      bukan merupakan nilai yang valid

  contoh:
    input: "-12345e-3"
    result: "( dua belas rupiah, tiga puluh lima sen )"
    input: "-100000000000000000000000000000000123, minus"
    result: "minus seratus desiliun seratus dua puluh tiga rupiah"
}

interface

// negative, prefix string untuk nilai negatif. jika berupa empty string
//   maka nilai negatif akan diapit oleh kurung buka/tutup
// zero, string untuk nilai 0, mis. "-" atau "NIHIL"
// (untuk mengubah format, koreksi bagian terakhir fungsi rps)
function Rp(const value: currency; const negative: string = '';
  const zero: string = '0'): string; overload;
function Rp(const value: string; const negative: string = '';
  const zero: string = '0'): string; overload;

implementation

uses sysutils;
const
  space = ' '; _se = 'se';
  nol = '0'; sembilan = '9';
  numeric = [nol..sembilan];
  {$J+}
  monetary: set of Char = numeric;
  monetary_ext: set of Char = numeric;
  {$J-}

function triplex(const n: word): string;
const
  satu = 'satu';
  belas = 'belas';
  puluh = 'puluh' + space;
  ratus = 'ratus' + space;
  cblok: array[0..9] of string = ('', _se, 'dua ', 'tiga ', 'empat ', 'lima ',
    'enam ', 'tujuh ', 'delapan ', 'sembilan ');
var
  x, y, z: byte;
  sy, sz: string;
begin
  x := n div 100;
  y := n mod 100 div 10;
  z := n mod 10;
  if z > 0 then
    sz := cblok[z]
  else
    sz := '';
  if y > 0 then
    sy := cblok[y] + puluh
  else
    sy := '';
  if y = 1 then begin
    if z > 0 then begin
      sy := sz; sz := belas;
    end;
  end
  else if z = 1 then
    sz := satu;
  Result := trim(sy + sz);
  if x > 0 then Result := trim(cblok[x] + ratus + Result);
end;

function rps(const value: string; const negative: string = '';
  const zero: string = '0'): string; overload;
type
  tmoneybucket = (cgsatuan, mbribu, mbjuta, mbmilyar, mbtriliun, mbquadrillion,
    mbquintillion, mbhexillion, mbheptillion, mboctillion, mbnonillion, mbdecillion,
    mbundecillion, mbduodecillion, mbtredecillion, mbquatuordecillion, mbquindecillion,
    mbsexdecillion, mbseptendecillion, mboktodecillion, mbnovemdecillion, mbvigintillion,
    mbunvigintillion, mbdovigintillion, mbtrevigintillion, mbquattrovigintillion,
    mbquinvigintillion, mbsexvigintillion, mbseptenvigintillion, mboktovigintillion,
    mbnovemvigintillion, mbtrigintillion, mbtoomany);
const
  blok = 3;
  _sen = ' sen';
  _rupiah = ' rupiah';
  triplez = '000';
  zerone = '001';
  moneybuck: array[tmoneybucket] of
  string = ('', 'ribu', 'juta', 'miliar', 'triliun', 'kuadriliun', 'kuintiliun',
    'heksiliun', 'heptiliun', 'oktiliun', 'noniliun', 'desiliun', 'undesiliun',
    'duodesiliun', 'tredesiliun', 'kuatuordesiliun', 'kuindesiliun', 'seksdesiliun',
    'septendesiliun', 'oktodesiliun', 'novemdesiliun', 'vigintiliun', 'unvigintiliun',
    'dovigintiliun', 'trevigintiliun', 'kuatrovigintiliun', 'kuinvigintiliun',
    'seksvigintiliun', 'septenvigintiliun', 'oktovigintiliun', 'novemvigintiliun',
    'trigintiliun', 'BuanyakBuangetDah');
var
  i, j, k, n: word;
  S, l, r: ShortString;
  neg: boolean;
begin
  r := '';
  Result := '';
  if value = '' then
    exit
  else
    S := value;
  neg := S[1] = '-';
  if neg then delete(S, 1, 1);
  if pos(decimalseparator, S) > 0 then begin
    l := copy(S, 1, pos(decimalseparator, S) - 1);
    r := copy(S, pos(decimalseparator, S) + 1, length(S));
    if length(r) = 1 then
      r := r + nol
    else if length(r) > 2 then
      r := copy(r, 1, 2);
  end
  else
    l := S;
  while length(l) mod blok > 0 do l := nol + l;
  Result := '';
  j := length(l) div blok;
  for i := j downto 1 do begin
    S := (copy(l, (j - i) * blok + 1, blok));
    n := strtointdef(S, 0);
    if n = 0 then continue;
    k := i - 1;
    if (n = 1) and (k = 1) then
      S := _se
    else
      S := triplex(n);
    if S <> '' then begin
      if k > byte(mbtoomany) then k := byte(mbtoomany);
      if i < j then Result := Result + space;
      if S <> _se then S := S + space;
      Result := trim(Result + S + moneybuck[tmoneybucket(k)]);
    end;
  end;
  if Result <> '' then Result := Result + _rupiah;
  n := strtointdef(r, 0);
  if (n > 0) then begin
    if Result <> '' then Result := Result + ', ';
    Result := Result + triplex(n) + _sen;
  end;
  if Result = '' then result := zero; // untuk menyatakan nilai nol
  // untuk menyatakan nilai negatif,
  // misal: ditambah [red]nilai[/red] bisa dubah disini
  if neg then begin
    if negative = '' then
      Result := '( ' + trim(Result) + ' )'
    else
      Result := negative + space + Result
  end
end;

function rp(const value: string; const negative: string = '';
  const zero: string = '0'): string; overload;
const
  ext = 'E';
var
  i, n: integer;
  f: extended;
  l, r: string;
  flagset: boolean;
begin
  Result := '';
  if value = '' then exit;
  for i := 1 to length(value) do
    if value[i] in monetary_ext then
      Result := Result + value[i];
  if pos(ext, uppercase(value)) > 0 then begin
    f := strtofloat(value);
    Result := formatFloat('#.##', f);
    //Result := currtostr(strtocurr(value));
    if pos(ext, uppercase(Result)) > 0 then
      raise exception.create('bilangan terlalu besar');
  end;
  n := pos(decimalseparator, Result);
  if n = length(Result) then begin
    delete(Result, length(Result), 1);
    n := pos(decimalseparator, Result);
  end;
  if n > 0 then begin
    l := copy(Result, 1, n - 1);
    r := copy(Result, n, length(Result));
    f := strtocurr(r);
    r := format('%F', [f]);
    if r = '1.00' then begin
      flagset := TRUE;
      for i := length(l) downto 0 do begin
        if flagset = FALSE then break;
        if i = 0 then
          l := '1' + l
        else begin
          flagset := l[i] = sembilan;
          if flagset = TRUE then
            l[i] := nol
          else
            l[i] := Char(ord(l[i]) + 1);
        end;
      end;
    end;
    r := copy(r, length(r) - 2, 3);
    Result := l + r;
  end;
  Result := rps(Result);
end;

function rp(const value: currency; const negative: string = '';
  const zero: string = '0'): string; overload;
const
  ext = 'E';
var
  S: string;
begin
  S := format('%F', [value]);
  Result := rps(S);
end;

initialization
  monetary := [decimalseparator] + ['+', '-'] + numeric;
  monetary_ext := monetary + ['e', 'E'];
end.


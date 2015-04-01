unit EXACGlobal;
interface
uses SoftReleases;

type
  TInvalidYear = type SoftReleases.TDevBaseYear;
  TYear = succ(low(TInvalidYear))..high(TInvalidYear);
  //error? TDevMonth = low(SoftReleases.TDevMonth)..high(SoftReleases.TDevMonth);
  TMonth = type SoftReleases.TDevMonth;
  TRelease = type SoftReleases.TProductReleaseID;

//const
//  indomonths: array[TMonth] of string = ('Januari', 'Februari', 'Maret', 'April', 'Mei',
//    'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'Nopember', 'Desember');
//
//  indomonthshort: array[TMonth] of string = ('Jan', 'Feb', 'Mar', 'Apr', 'Mei',
//    'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nop', 'Des');

type
  TEXACRelease = TProductReleaseID;
  TEXACNewYear = succ(low(TDevYear))..high(TDevYear);
  TEXACUpdateEvent1 = (eusMarch, eusJune, eusSeptember, eusDecember);

const
  //TEXACUpdateEvent types family MUST be sorted by the same order with TMonth
  EXACUpdateCountPerYear = ord(high(TEXACUpdateEvent1)) + 1;
  EXACUpdateMonthsPeriod = MonthsPerYear div EXACUpdateCountPerYear; // how long in months
  EXACUpdateEventSet = [tmMarch, tmJune, tmSeptember, tmDecember];
  EXACUpdateEvents: array[TEXACUpdateEvent1] of TMonth =
  (tmMarch, tmJune, tmSeptember, tmDecember);

type
  TReleaseStrFormat = SoftReleases.TReleaseStrFormat;

function GetEXACReleaseIndex(const Release: TRelease; //const StartRelease: TRelease = 0;
  const UpdateMonthsPeriod: integer = EXACUpdateMonthsPeriod): integer; overload;
// 0-based, used for example indexing in a tstrings
// used only for regular & consistent update period (per 3months),

function GetEXACReleaseIndex(const year: TYear; UpdateEvent: TEXACUpdateEvent1): integer; overload;
// 0-based, used for example indexing in a tstrings
// used for irregular update period, currently unused yet anyway

function GetEXACReleaseOfIndex(const Index: byte): TRelease; // const StartRelease: TRelease = 0): TRelease;
//  const UpdatePerYear: integer = EXACUpdateCountPerYear): integer;

function getRelease(const year: TYear; const month: TMonth): TRelease;
function getYear(const Release: TRelease): TYear;
function getMonth(const Release: TRelease): TMonth;

function StrRelease(const Release: TProductReleaseID;
  const StrFormat: TReleaseStrFormat = rdfVerbose;
  const Separator: string = ''): string; overload; forward;

function StrRelease(const year: TDevYear; const month: TDevMonth;
  const StrFormat: TReleaseStrFormat = rdfVerbose;
  const Separator: string = ''): string; overload; forward;

implementation
uses SysUtils; //, XCInternal;

function GetEXACReleaseIndex(const Release: TRelease; //const StartRelease: TRelease = 0;
  const UpdateMonthsPeriod: integer = EXACUpdateMonthsPeriod): integer; overload;
begin
  Result := Release div UpdateMonthsPeriod;
end;

function GetEXACReleaseIndex(const year: TYear; UpdateEvent: TEXACUpdateEvent1): integer; overload;
// 0-based, used for example indexing in a tstrings
// used for irregular update period, currently unused yet anyway
var
  Release: TRelease;
  y, x: integer;
  m: TMonth;
  found: boolean;
  e: TEXACUpdateEvent1;
begin
  if EXACUpdateCountPerYear < 1 then
    Result := 0
  else begin
    Release := GetRelease(year, EXACUpdateEvents[UpdateEvent]);
    if EXACUpdateCountPerYear = 1 then Result := Release
    else begin
      // count how many years from the base
      // we use 0-based ie. 0=jan, 1=feb and so on.., originally 0=sep
      y := (ord(Release) + ReleaseBaseStart - 1) div 12;
      //inc(y);
      dec(y);
      // eliminate overvalued. hidden problem, might be negative
      // (if UpdEvent selected below RelBaseMonth in the RelBaseYear)
      // (or should be no problem , its eliminated by valid Release?)

      // we found the index based on year by mult. with event count
      x := y * EXACUpdateCountPerYear; //ord(high(TEXACUpdateEvent1)) + 1;

      found := false;
      for e := low(e) to high(e) do
        if EXACUpdateEvents[e] >= tmonth(ReleaseBaseMonth) then begin
          // got the displacement from ReleaseBaseStart, here e means
          // count of update events before ReleaseBase (September),
          // used to adjust the index value computed from the years
          //

          // above (ie. x),  note that ord(e) is already 0-based

          // dec(x, ord(e));

          // actually it should be: inc(x, UpdCount - ord(e))
          // to simplify this, we've already inc(y) above
          // which also means: inc(x, UpdCount)
          // that left us only to dec(x) by ord(e)

          // changed, since if not found we have to dec(x) again
          // by UpdCount. inc(y) line above also removed
          // not found means none UpdEvent take place after ReleaseBaseMonth
          found := TRUE;
          break;
        end;
      if found then inc(x, EXACUpdateCountPerYear - ord(e));

      // now search for given UpdateEvent
      m := EXACUpdateEvents[UpdateEvent];
      for e := low(e) to high(e) do
        if EXACUpdateEvents[e] = m then begin
          // here we have to dec(x) from overvalued by simply
          // multplying y with UpdCount.

          //changed used inc(x)instead, we add dec(y)above
          inc(x, ord(e) + 1);

          break;
        end;
      if x < 0 then Result := 0
      else
        Result := x;
    end;
  end;
end;

function GetEXACReleaseOfIndex(const Index: byte): TRelease; //;; const StartRelease: TRelease = 0): TRelease;
begin
  Result := 0;
end;

function getRelease(const year: TYear; const month: TMonth): TRelease;
begin
  Result := EncodeRelease(year, month)
end;

function getYear(const Release: TRelease): TYear;
begin
  Result := DecodeReleaseYear(Release);
end;

function getMonth(const Release: TRelease): TMonth;
begin
  Result := DecodeReleaseMonth(Release);
end;

function StrRelease(const Release: TProductReleaseID;
  const StrFormat: TReleaseStrFormat; const Separator: string): string; overload;
begin
  Result := SoftReleases.StrRelease(Release, StrFormat, Separator);
end;

function StrRelease(const year: TDevYear; const month: TDevMonth;
  const StrFormat: TReleaseStrFormat; const Separator: string): string; overload;
begin
  Result := SoftReleases.StrRelease(year, month, StrFormat, Separator);
end;

function StrRelease(const year: TYear; const UpdEvent: TEXACUpdateEvent1;
  const StrFormat: TReleaseStrFormat = rdfVerbose;
  const Separator: string = ''): string; overload;
begin
  Result := '';
end;

function StrRelToVal(const Release: string): integer;
begin
  Result := 0;
end;

end.


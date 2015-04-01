unit EXACReleases;
interface

uses SoftReleases;

type
  //TInvalidYear = type SoftReleases.TDevBaseYear;
  TYear = type SoftReleases.TDevYear;
  //error? TDevMonth = low(SoftReleases.TDevMonth)..high(SoftReleases.TDevMonth);
  //TMonth = tmJanuary..tmDecember;
  TMonth = type SoftReleases.TValidMonth;
  TRelease = type SoftReleases.TProductReleaseID;

//const
//  indomonths: array[TMonth] of string = ('Januari', 'Februari', 'Maret', 'April', 'Mei',
//    'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'Nopember', 'Desember');
//
//  indomonthshort: array[TMonth] of string = ('Jan', 'Feb', 'Mar', 'Apr', 'Mei',
//    'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nop', 'Des');

type
  TEXACRelease = SoftReleases.TProductReleaseID;
  //TEXACUpdateEvent1 = (eusMarch, eusJune, eusSeptember, eusDecember);

const
  //TEXACUpdateEvent types family MUST be sorted by the same order with TMonth
  //EXACUpdateCountPerYear = ord(high(TEXACUpdateEvent1)) + 1;
  //EXACUpdateMonthsPeriod = MonthsPerYear div EXACUpdateCountPerYear; // how long in months
  //EXACUpdateEventSet = [tmMarch, tmJune, tmSeptember, tmDecember];
  //EXACUpdateEvents: array[TEXACUpdateEvent1] of TMonth =
  //(tmMarch, tmJune, tmSeptember, tmDecember);
  EXACUpdateEvents = [tmMarch, tmJune, tmSeptember, tmDecember];

type
  TReleaseStrFormat = type SoftReleases.TReleaseStrFormat;

function GetIndexOfEXACRelease(const Release: TRelease): integer; //const StartRelease: TRelease = 0;
  //const UpdateMonthsPeriod: integer = EXACUpdateMonthsPeriod): integer; overload;
// 0-based, used for example indexing in a tstrings
// used only for regular & consistent update period (per 3months),

//function GetIndexOfEXACRelease(const year: TYear; UpdateEvent: TEXACUpdateEvent1): integer; overload;
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

function StrRelease(const year: TDevYear; const month: TMonth;
  const StrFormat: TReleaseStrFormat = rdfVerbose;
  const Separator: string = ''): string; overload; forward;

function firstEXACRelease: TRelease;

function getEXACUpdateCountPerYear: integer;
function getEXACUpdateMonthPeriod: integer;

implementation
uses SysUtils; //, XCInternal;

const
  ErrEmptyUpdEvents = ^j'EXACUpdateEvents is empty!!!';

function getEXACUpdateCountPerYear: integer;
const
  fCount: integer = -1;
begin
  if fCount < 1 then
    if EXACUpdateEvents = [] then
      raise exception.Create(ErrEmptyUpdEvents + ^j'UpdateCount not available.'^j)
    else
      fCount := CountMonthMemberOf(EXACUpdateEvents);
  Result := fCount
end;

function getEXACUpdateMonthPeriod: integer;
const
  fPeriod: integer = -1;
begin
  if fPeriod < 1 then
    if EXACUpdateEvents = [] then
      raise exception.Create(ErrEmptyUpdEvents + ^j + 'UpdatePeriiod not available.'^j)
    else
      fPeriod := MonthsPerYear div getEXACUpdateCountPerYear;
  Result := fPeriod;
end;

function GetIndexOfEXACRelease(const Release: TRelease): integer; //const StartRelease: TRelease = 0;
  //const UpdateMonthsPeriod: integer = EXACUpdateMonthsPeriod): integer; overload;
begin

  //Result := Release div UpdateMonthsPeriod;
  Result := Release div getEXACUpdateMonthPeriod;
end;

function LastUpdateEventOccurred_BeforeReleaseBase: boolean; overload;
var
  m: tmonth;
begin
  Result := TRUE;
  if ExacUpdateEvents <> [] then
    for m := high(m) downto tmonth(ReleaseBaseMonth) do
      if m in ExacUpdateEvents then begin
        Result := FALSE;
        break;
      end;
  //if tmonth(ReleaseBaseMonth)
  //Result := EXACUpdateEvents[high(TEXACUpdateEvent1)] < tmonth(ReleaseBaseMonth)
end;

function LastUpdateEventOccurred_BeforeReleaseBase(var month: TMonth): boolean; overload;
begin
  //Result := EXACUpdateEvents[high(TEXACUpdateEvent1)] < tmonth(ReleaseBaseMonth);
  //result := high(EXACUpdateEvents) = tmSeptember;
  //if Result = TRUE then month := EXACUpdateEvents[low(TEXACUpdateEvent1)];
  Result := LastUpdateEventOccurred_BeforeReleaseBase;
  if Result = TRUE then month := getLowestMonthMemberOf(EXACUpdateEvents);
end;

//function firstEXACUpdateEvent: TEXACUpdateEvent1; overload;
//begin
//  if LastUpdateEventOccurred_BeforeReleaseBase then Result := low(Result)
//  else
//    for Result := low(Result) to high(Result) do
//      //if EXACUpdateEvents[Result] >= tmonth(ReleaseBaseMonth) then break;
//end;

//function firstEXACUpdateEvent(var month: TMonth): TEXACUpdateEvent1; overload;
//begin
//  if LastUpdateEventOccurred_BeforeReleaseBase(month) then Result := low(Result)
//  else
//    for Result := low(Result) to high(Result) do begin
//      month := EXACUpdateEvents[Result];
//      if month >= tmonth(ReleaseBaseMonth) then break
//    end;
//end;

function firstEXACUpdateMonth: TMonth; // maybe overlapped to next year!
var
  found: boolean;
begin
  if ExacUpdateEvents = [] then Result := tmonth(ReleaseBaseMonth)
  else begin
    found := FALSE;
    for Result := tmonth(ReleaseBaseMonth) to high(Result) do
      if Result in ExacUpdateEvents then begin
        found := TRUE;
        break;
      end;
    if not found then Result := getLowestMonthMemberOf(ExacUpdateEvents);
  end;
  //if Result=TRUE then
  //if tmonth(ReleaseBaseMonth)
  //Result := EXACUpdateEvents[high(TEXACUpdateEvent1)] < tmonth(ReleaseBaseMonth)
end;
//begin
//  //Result := EXACUpdateEvents[firstEXACUpdateEvent];
//  if LastUpdateEventOccurred_BeforeReleaseBase then
//    month := getLowestMonthMemberOf(EXACUpdateEvents)
//  else
//end;

function firstEXACUpdateYear: TYear; overload
begin
  Result := low(TYear);
  if LastUpdateEventOccurred_BeforeReleaseBase then inc(Result);
end;

function firstEXACUpdateYear(var month: TMonth): TYear; overload
begin
  Result := low(TYear);
  if not LastUpdateEventOccurred_BeforeReleaseBase then Month := firstEXACUpdateMonth
  else begin
    inc(Result);
    //month := EXACUpdateEvents[low(TEXACUpdateEvent1)];
    month := getLowestMonthMemberOf(EXACUpdateEvents);
  end;
end;

function firstEXACRelease: TRelease;
begin
  Result := getRelease(firstEXACUpdateYear, firstEXACUpdateMonth);
end;

//function getEXACUpdateEvent(const Release: TRelease): TEXACUpdateEvent1;
//var
//  m: TMonth;
//begin
//  m := getMonth(Release);
//  if EXACUpdateEvents[low(TEXACUpdateEvent1)] > m then
//    Result := high(TEXACUpdateEvent1)
//  else
//    for Result := high(Result) downto low(Result) do
//      if EXACUpdateEvents[Result] <= m then break;
//end;

//function GetIndexOfEXACRelease(const year: TYear; UpdateEvent: TEXACUpdateEvent1): integer; overload;
//// 0-based, used for example indexing in a tstrings
//// used for irregular update period, currently unused yet anyway
//var
//  Release: TRelease;
//  y, x: integer;
//  m: TMonth;
//  found: boolean;
//  e: TEXACUpdateEvent1;
//begin
//  Release := GetRelease(year, EXACUpdateEvents[UpdateEvent]);
//  if EXACUpdateCountPerYear = 1 then Result := Release
//  else begin
//    // count how many years from the base
//    // we use 0-based ie. 0=jan, 1=feb and so on.., originally 0=sep
//    y := (ord(Release) + ReleaseBaseStart - 1) div 12;
//    //inc(y);
//    dec(y);
//    // eliminate overvalued. hidden problem, might be negative
//    // (if UpdEvent selected below RelBaseMonth in the RelBaseYear)
//    // (or should be no problem , its eliminated by valid Release?)
//
//    // we found the index based on year by mult. with event count
//    x := y * EXACUpdateCountPerYear; //ord(high(TEXACUpdateEvent1)) + 1;
//
//    found := false;
//    for e := low(e) to high(e) do
//      if EXACUpdateEvents[e] >= tmonth(ReleaseBaseMonth) then begin
//        // got the displacement from ReleaseBaseStart, here e means
//        // count of update events before ReleaseBase (September),
//        // used to adjust the index value computed from the years
//        //
//
//        // above (ie. x),  note that ord(e) is already 0-based
//
//        // dec(x, ord(e));
//
//        // actually it should be: inc(x, UpdCount - ord(e))
//        // to simplify this, we've already inc(y) above
//        // which also means: inc(x, UpdCount)
//        // that left us only to dec(x) by ord(e)
//
//        // changed, since if not found we have to dec(x) again
//        // by UpdCount. inc(y) line above also removed
//        // not found means none UpdEvent take place after ReleaseBaseMonth
//        found := TRUE;
//        break;
//      end;
//    if found then inc(x, EXACUpdateCountPerYear - ord(e));
//
//    // now search for given UpdateEvent
//    m := EXACUpdateEvents[UpdateEvent];
//    for e := low(e) to high(e) do
//      if EXACUpdateEvents[e] = m then begin
//        // here we have to dec(x) from overvalued by simply
//        // multplying y with UpdCount.
//
//        //changed used inc(x)instead, we add dec(y)above
//        inc(x, ord(e) + 1);
//
//        break;
//      end;
//    if x < 0 then Result := 0
//    else
//      Result := x;
//  end;
//end;

function GetEXACReleaseOfIndex(const Index: byte): TRelease; //;; const StartRelease: TRelease = 0): TRelease;
var
  m: TMonth;
  procedure incm; begin
    if m < high(m) then inc(m) else m := low(m);
  end;
var
  i: integer;
begin
  if index > high(TRelease) div getEXACUpdateMonthPeriod then
    Result := 0
  else begin
    Result := firstEXACRelease;
    if Index > 0 then begin
      i := 0; incm;
      repeat
        inc(Result);
        if m in EXACUpdateEvents then inc(i);
        incm;
      until i >= Index;
    end;
  end;
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

function StrRelease(const year: TDevYear; const month: TMonth;
  const StrFormat: TReleaseStrFormat; const Separator: string): string; overload;
begin
  Result := SoftReleases.StrRelease(year, month, StrFormat, Separator);
end;

function StrRelToVal(const Release: string): integer;
begin
  Result := 0;
end;

end.


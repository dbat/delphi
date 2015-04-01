unit WinGlobs;
interface
//uses windows;
// from SysUtils
{ Currency and date/time formatting options

  The initial values of these variables are fetched from the system registry
  using the GetLocaleInfo function in the Win32 API. The description of each
  variable specifies the LOCALE_XXXX constant used to fetch the initial
  value.

  CurrencyString - Defines the currency symbol used in floating-point to
  decimal conversions. The initial value is fetched from LOCALE_SCURRENCY.

  CurrencyFormat - Defines the currency symbol placement and separation
  used in floating-point to decimal conversions. Possible values are:

    0 = '$1'
    1 = '1$'
    2 = '$ 1'
    3 = '1 $'

  The initial value is fetched from LOCALE_ICURRENCY.

  NegCurrFormat - Defines the currency format for used in floating-point to
  decimal conversions of negative numbers. Possible values are:

    0 = '($1)'      4 = '(1$)'      8 = '-1 $'      12 = '$ -1'
    1 = '-$1'       5 = '-1$'       9 = '-$ 1'      13 = '1- $'
    2 = '$-1'       6 = '1-$'      10 = '1 $-'      14 = '($ 1)'
    3 = '$1-'       7 = '1$-'      11 = '$ 1-'      15 = '(1 $)'

  The initial value is fetched from LOCALE_INEGCURR.

  ThousandSeparator - The character used to separate thousands in numbers
  with more than three digits to the left of the decimal separator. The
  initial value is fetched from LOCALE_STHOUSAND.

  DecimalSeparator - The character used to separate the integer part from
  the fractional part of a number. The initial value is fetched from
  LOCALE_SDECIMAL.

  CurrencyDecimals - The number of digits to the right of the decimal point
  in a currency amount. The initial value is fetched from LOCALE_ICURRDIGITS.

  DateSeparator - The character used to separate the year, month, and day
  parts of a date value. The initial value is fetched from LOCATE_SDATE.

  ShortDateFormat - The format string used to convert a date value to a
  short string suitable for editing. For a complete description of date and
  time format strings, refer to the documentation for the FormatDate
  function. The short date format should only use the date separator
  character and the  m, mm, d, dd, yy, and yyyy format specifiers. The
  initial value is fetched from LOCALE_SSHORTDATE.

  LongDateFormat - The format string used to convert a date value to a long
  string suitable for display but not for editing. For a complete description
  of date and time format strings, refer to the documentation for the
  FormatDate function. The initial value is fetched from LOCALE_SLONGDATE.

  TimeSeparator - The character used to separate the hour, minute, and
  second parts of a time value. The initial value is fetched from
  LOCALE_STIME.

  TimeAMString - The suffix string used for time values between 00:00 and
  11:59 in 12-hour clock format. The initial value is fetched from
  LOCALE_S1159.

  TimePMString - The suffix string used for time values between 12:00 and
  23:59 in 12-hour clock format. The initial value is fetched from
  LOCALE_S2359.

  ShortTimeFormat - The format string used to convert a time value to a
  short string with only hours and minutes. The default value is computed
  from LOCALE_ITIME and LOCALE_ITLZERO.

  LongTimeFormat - The format string used to convert a time value to a long
  string with hours, minutes, and seconds. The default value is computed
  from LOCALE_ITIME and LOCALE_ITLZERO.

  ShortMonthNames - Array of strings containing short month names. The mmm
  format specifier in a format string passed to FormatDate causes a short
  month name to be substituted. The default values are fecthed from the
  LOCALE_SABBREVMONTHNAME system locale entries.

  LongMonthNames - Array of strings containing long month names. The mmmm
  format specifier in a format string passed to FormatDate causes a long
  month name to be substituted. The default values are fecthed from the
  LOCALE_SMONTHNAME system locale entries.

  ShortDayNames - Array of strings containing short day names. The ddd
  format specifier in a format string passed to FormatDate causes a short
  day name to be substituted. The default values are fecthed from the
  LOCALE_SABBREVDAYNAME system locale entries.

  LongDayNames - Array of strings containing long day names. The dddd
  format specifier in a format string passed to FormatDate causes a long
  day name to be substituted. The default values are fecthed from the
  LOCALE_SDAYNAME system locale entries.

  ListSeparator - The character used to separate items in a list.  The
  initial value is fetched from LOCALE_SLIST.

  TwoDigitYearCenturyWindow - Determines what century is added to two
  digit years when converting string dates to numeric dates.  This value
  is subtracted from the current year before extracting the century.
  This can be used to extend the lifetime of existing applications that
  are inextricably tied to 2 digit year data entry.  The best solution
  to Year 2000 (Y2k) issues is not to accept 2 digit years at all - require
  4 digit years in data entry to eliminate century ambiguities.

  Examples:

  Current TwoDigitCenturyWindow  Century  StrToDate() of:
  Year    Value                  Pivot    '01/01/03' '01/01/68' '01/01/50'
  -------------------------------------------------------------------------
  1998    0                      1900     1903       1968       1950
  2002    0                      2000     2003       2068       2050
  1998    50 (default)           1948     2003       1968       1950
  2002    50 (default)           1952     2003       1968       2050
  2020    50 (default)           1970     2003       2068       2050
 }

type
  DWORD = longword; {$EXTERNALSYM DWORD}
  LCID = DWORD; {$EXTERNALSYM LCID}
  LANGID = Word; {$EXTERNALSYM LANGID}

  TSysLocale = packed record
    DefaultLCID: LCID;
    PriLangID: LANGID;
    SubLangID: LANGID;
    FarEast: Boolean;
    MiddleEast: Boolean;
  end;

  TSysCharSet = set of Char;

type
  TWinGlobalSettings = record
  //Version Information
    Win32Platform: integer;
    Win32MajorVersion: integer;
    Win32MinorVersion: integer;
    Win32BuildNumber: integer;
    Win32CSDVersion: string;

    CurrencyString: string;
    CurrencyDecimals: Byte;
    CurrencyFormat: Byte;
    NegCurrFormat: Byte;
    ThousandSeparator: Char;
    DecimalSeparator: Char;

    ShortDateFormat: string;
    LongDateFormat: string;
    DateSeparator: Char;

    TimeAMString: string;
    TimePMString: string;
    ShortTimeFormat: string;
    LongTimeFormat: string;
    TimeSeparator: Char;

    ShortMonthNames: array[1..12] of string;
    LongMonthNames: array[1..12] of string;
    ShortDayNames: array[1..7] of string;
    LongDayNames: array[1..7] of string;

    SysLocale: TSysLocale;
    LeadBytes: set of Char; // = [];

    EraNames: array[1..7] of string;
    EraYearOffsets: array[1..7] of Integer;
    TwoDigitYearCenturyWindow: word; // = 50;
    ListSeparator: Char;
  end;

var
  WinGlobal: TWinGlobalSettings;

function WinGlobalSet(NewSettings: TWinGlobalSettings): boolean;
function WinGlobalReset: boolean;
procedure WinGlobalSetIndoFormat;

implementation
uses SysUtils;
var
  WinGlobal_Saved: TWinGlobalSettings;
  GlobalFormatHasBeenSet: boolean = FALSE;

const WinGlobal_ID: TWinGlobalSettings = (
    CurrencyString: 'Rp';
    CurrencyDecimals: 2;
    CurrencyFormat: 2;
    // 0 = $1      1 = 1$      2 = $ 1       3 = 1 $
    NegCurrFormat: 14;
    // 0 = ($1)    4 = (1$)    8 = -1 $     12 = $ -1
    // 1 = -$1     5 = -1$     9 = -$ 1     13 = 1- $
    // 2 = $-1     6 = 1-$    10 = 1 $-     14 = ($ 1)
    // 3 = $1-     7 = 1$-    11 = $ 1-     15 = (1 $)
    ThousandSeparator: '.';
    DecimalSeparator: ',';

    ShortDateFormat: 'dd-mm-yyyy';
    LongDateFormat: 'dddd, dd mmmm yyyy';
    DateSeparator: '-';

    ShortTimeFormat: 'hh:mm:ss';
    LongTimeFormat: 'hh:mm:ss:zzz';
    TimeSeparator: ':';
    //ListSeparator := ListSeparator;
    );

//procedure LoadSettingsFromSystemTo(Settings: TWinGlobalSettings); forward;
//procedure ApplySettingToSystemFrom(Settings: TWinGlobalSettings); forward;
//procedure CopySettings(Source, Destination: TWinGlobalSettings); forward;
procedure LoadSettings(Settings: TWinGlobalSettings); forward;
procedure ApplySettingsOf(Settings: TWinGlobalSettings); forward;
procedure SaveCurrentSettings; forward;
procedure CopySettingsFrom(Source, ToDestination: TWinGlobalSettings); forward;

function WinGlobalReset: boolean;
begin
  Result := FALSE;
  if GlobalFormatHasBeenSet then begin
    ApplySettingsOf(WinGlobal_Saved);
    GlobalFormatHasBeenSet := FALSE;
    Result := TRUE;
  end;
end;

function WinGlobalSet(NewSettings: TWinGlobalSettings): boolean;
begin
  Result := FALSE;
  if not GlobalFormatHasBeenSet then begin
    SaveCurrentSettings;
    ApplySettingsOf(NewSettings);
    GlobalFormatHasBeenSet := TRUE;
    Result := TRUE;
  end;
end;

const
  LANG_INDONESIAN = $21; {$EXTERNALSYM LANG_INDONESIAN}

procedure WinGlobalSetIndoFormat;
var
  IndoSettings: TWinGlobalSettings;
begin
  CopySettingsFrom(WinGlobal, IndoSettings);
  with IndoSettings do begin
    CurrencyString := 'Rp ';
    CurrencyDecimals := 2;
    CurrencyFormat := 2;
    // 0 = $1      1 = 1$      2 = $ 1       3 = 1 $
    NegCurrFormat := 14;
    // 0 = ($1)    4 = (1$)    8 = -1 $     12 = $ -1
    // 1 = -$1     5 = -1$     9 = -$ 1     13 = 1- $
    // 2 = $-1     6 = 1-$    10 = 1 $-     14 = ($ 1)
    // 3 = $1-     7 = 1$-    11 = $ 1-     15 = (1 $)
    ThousandSeparator := '.';
    DecimalSeparator := ',';

    ShortDateFormat := 'dd-MM-yyyy';
    LongDateFormat := 'dddd, dd mmmm yyyy';
    DateSeparator := '-';

    ShortTimeFormat := 'hh:mm:ss';
    LongTimeFormat := 'hh:mm:ss:zzz';
    TimeSeparator := ':';
    SysLocale.PriLangID := LANG_INDONESIAN;
  end;

  WinGlobalSet(IndoSettings);
end;

procedure WinGlobalForceSetting(ForcedSettings: TWinGlobalSettings);
begin
  //ApplySettingToSystemFrom(ForcedSettings);
end;

// ============================================================
procedure CopySettingsFrom(Source, ToDestination: TWinGlobalSettings);
var
  i: integer;
begin
  ToDestination.Win32Platform := Source.Win32Platform;
  ToDestination.Win32MajorVersion := Source.Win32MajorVersion;
  ToDestination.Win32MinorVersion := Source.Win32MinorVersion;
  ToDestination.Win32BuildNumber := Source.Win32BuildNumber;
  ToDestination.Win32CSDVersion := Source.Win32CSDVersion;

  ToDestination.CurrencyString := Source.CurrencyString;
  ToDestination.CurrencyFormat := Source.CurrencyFormat;
  ToDestination.NegCurrFormat := Source.NegCurrFormat;
  ToDestination.ThousandSeparator := Source.ThousandSeparator;
  ToDestination.DecimalSeparator := Source.DecimalSeparator;
  ToDestination.CurrencyDecimals := Source.CurrencyDecimals;
  ToDestination.DateSeparator := Source.DateSeparator;
  ToDestination.ShortDateFormat := Source.ShortDateFormat;
  ToDestination.LongDateFormat := Source.LongDateFormat;
  ToDestination.TimeSeparator := Source.TimeSeparator;
  ToDestination.TimeAMString := Source.TimeAMString;
  ToDestination.TimePMString := Source.TimePMString;
  ToDestination.ShortTimeFormat := Source.ShortTimeFormat;
  ToDestination.LongTimeFormat := Source.LongTimeFormat;

  for i := Low(LongDayNames) to high(LongDayNames) do
    ToDestination.LongDayNames[i] := Source.LongDayNames[i];
  for i := low(ShortDayNames) to high(ShortDayNames) do
    ToDestination.ShortDayNames[i] := Source.ShortDayNames[i];
  for i := Low(LongMonthNames) to high(LongMonthNames) do
    ToDestination.LongMonthNames[i] := Source.LongMonthNames[i];
  for i := Low(ShortMonthNames) to high(ShortMonthNames) do
    ToDestination.ShortMonthNames[i] := Source.ShortMonthNames[i];

  ToDestination.SysLocale.DefaultLCID := Source.SysLocale.DefaultLCID;
  ToDestination.SysLocale.FarEast := Source.SysLocale.FarEast;
  ToDestination.SysLocale.MiddleEast := Source.SysLocale.MiddleEast;
  ToDestination.SysLocale.PriLangID := Source.SysLocale.PriLangID;
  ToDestination.SysLocale.SubLangID := Source.SysLocale.SubLangID;
  ToDestination.LeadBytes := Source.LeadBytes;

  for i := Low(EraNames) to high(EraNames) do
    ToDestination.EraNames[i] := Source.EraNames[i];
  for i := low(EraYearOffsets) to high(EraYearOffsets) do
    ToDestination.EraYearOffsets[i] := Source.EraYearOffsets[i];

  ToDestination.TwoDigitYearCenturyWindow := Source.TwoDigitYearCenturyWindow;
  ToDestination.ListSeparator := Source.ListSeparator;
end;

procedure SaveCurrentSettings;
begin
  CopySettingsFrom(WinGlobal, WinGlobal_Saved);
end;

//  ============================================================
//  procedure LoadSettingsFromSystemTo(Settings: TWinGlobalSettings);
//  // DO NOT do this, ALWAYS use WinGlobal for sync
//  var i: integer;
//  begin
//    Settings.Win32Platform := SysUtils.Win32Platform;
//    Settings.Win32MajorVersion := SysUtils.Win32MajorVersion;
//    Settings.Win32MinorVersion := SysUtils.Win32MinorVersion;
//    Settings.Win32BuildNumber := SysUtils.Win32BuildNumber;
//    Settings.Win32CSDVersion := SysUtils.Win32CSDVersion;
//
//    Settings.CurrencyString := SysUtils.CurrencyString;
//    Settings.CurrencyFormat := SysUtils.CurrencyFormat;
//    Settings.NegCurrFormat := SysUtils.NegCurrFormat;
//    Settings.ThousandSeparator := SysUtils.ThousandSeparator;
//    Settings.DecimalSeparator := SysUtils.DecimalSeparator;
//    Settings.CurrencyDecimals := SysUtils.CurrencyDecimals;
//    Settings.DateSeparator := SysUtils.DateSeparator;
//    Settings.ShortDateFormat := SysUtils.ShortDateFormat;
//    Settings.LongDateFormat := SysUtils.LongDateFormat;
//    Settings.TimeSeparator := SysUtils.TimeSeparator;
//    Settings.TimeAMString := SysUtils.TimeAMString;
//    Settings.TimePMString := SysUtils.TimePMString;
//    Settings.ShortTimeFormat := SysUtils.ShortTimeFormat;
//    Settings.LongTimeFormat := SysUtils.LongTimeFormat;
//
//    for i := low(LongDayNames) to high(LongDayNames) do
//      Settings.LongDayNames[i] := SysUtils.LongDayNames[i]; // array[1..7] of string;
//    for i := low(ShortDayNames) to high(ShortDayNames) do
//      Settings.ShortDayNames[i] := SysUtils.ShortDayNames[i]; // array[1..7] of string;
//    for i := Low(LongMonthNames) to high(LongMonthNames) do
//      Settings.LongMonthNames[i] := SysUtils.LongMonthNames[i]; // array[1..12] of string;
//    for i := Low(ShortMonthNames) to high(ShortMonthNames) do
//      Settings.ShortMonthNames[i] := SysUtils.ShortMonthNames[i]; // array[1..12] of string;
//
//    Settings.SysLocale.DefaultLCID := SysUtils.SysLocale.DefaultLCID;
//    Settings.SysLocale.FarEast := SysUtils.SysLocale.FarEast;
//    Settings.SysLocale.MiddleEast := SysUtils.SysLocale.MiddleEast;
//    Settings.SysLocale.PriLangID := SysUtils.SysLocale.PriLangID;
//    Settings.SysLocale.SubLangID := SysUtils.SysLocale.SubLangID;
//    Settings.LeadBytes := SysUtils.LeadBytes;
//
//    for i := Low(EraNames) to high(EraNames) do
//      Settings.EraNames[i] := SysUtils.EraNames[i]; // array[1..7] of string;
//    for i := low(EraYearOffsets) to high(EraYearOffsets) do
//      Settings.EraYearOffsets[i] := SysUtils.EraYearOffsets[i]; // array[1..7] of Integer;
//    Settings.TwoDigitYearCenturyWindow := SysUtils.TwoDigitYearCenturyWindow;
//    Settings.ListSeparator := SysUtils.ListSeparator;
//  end;
//
//  procedure ApplySettingToSystemFrom(Settings: TWinGlobalSettings);
//  // DO NOT do this, ALWAYS use WinGlobal for sync
//  var i: integer;
//  begin
//    SysUtils.Win32Platform := Settings.Win32Platform;
//    SysUtils.Win32MajorVersion := Settings.Win32MajorVersion;
//    SysUtils.Win32MinorVersion := Settings.Win32MinorVersion;
//    SysUtils.Win32BuildNumber := Settings.Win32BuildNumber;
//    SysUtils.Win32CSDVersion := Settings.Win32CSDVersion;
//
//    SysUtils.CurrencyString := Settings.CurrencyString;
//    SysUtils.CurrencyFormat := Settings.CurrencyFormat;
//    SysUtils.NegCurrFormat := Settings.NegCurrFormat;
//    SysUtils.ThousandSeparator := Settings.ThousandSeparator;
//    SysUtils.DecimalSeparator := Settings.DecimalSeparator;
//    SysUtils.CurrencyDecimals := Settings.CurrencyDecimals;
//    SysUtils.DateSeparator := Settings.DateSeparator;
//    SysUtils.ShortDateFormat := Settings.ShortDateFormat;
//    SysUtils.LongDateFormat := Settings.LongDateFormat;
//    SysUtils.TimeSeparator := Settings.TimeSeparator;
//    SysUtils.TimeAMString := Settings.TimeAMString;
//    SysUtils.TimePMString := Settings.TimePMString;
//    SysUtils.ShortTimeFormat := Settings.ShortTimeFormat;
//    SysUtils.LongTimeFormat := Settings.LongTimeFormat;
//
//    for i := low(LongDayNames) to high(LongDayNames) do
//      SysUtils.LongDayNames[i] := Settings.LongDayNames[i];
//    for i := low(ShortDayNames) to high(ShortDayNames) do
//      SysUtils.ShortDayNames[i] := Settings.ShortDayNames[i];
//    for i := Low(LongMonthNames) to high(LongMonthNames) do
//      SysUtils.LongMonthNames[i] := Settings.LongMonthNames[i];
//    for i := Low(ShortMonthNames) to high(ShortMonthNames) do
//      SysUtils.ShortMonthNames[i] := Settings.ShortMonthNames[i];
//
//    SysUtils.SysLocale.DefaultLCID := Settings.SysLocale.DefaultLCID;
//    SysUtils.SysLocale.FarEast := Settings.SysLocale.FarEast;
//    SysUtils.SysLocale.MiddleEast := Settings.SysLocale.MiddleEast;
//    SysUtils.SysLocale.PriLangID := Settings.SysLocale.PriLangID;
//    SysUtils.SysLocale.SubLangID := Settings.SysLocale.SubLangID;
//    SysUtils.LeadBytes := Settings.LeadBytes;
//
//    for i := Low(EraNames) to high(EraNames) do
//      SysUtils.EraNames[i] := Settings.EraNames[i];
//    for i := low(EraYearOffsets) to high(EraYearOffsets) do
//      SysUtils.EraYearOffsets[i] := Settings.EraYearOffsets[i];
//    SysUtils.TwoDigitYearCenturyWindow := Settings.TwoDigitYearCenturyWindow;
//    SysUtils.ListSeparator := Settings.ListSeparator;
//  end;
//   ============================================================

// ============================================================
procedure LoadSettingsFromSystem;
// ALWAYS use WinGlobal for sync
var i: integer;
begin
  WinGlobal.Win32Platform := SysUtils.Win32Platform;
  WinGlobal.Win32MajorVersion := SysUtils.Win32MajorVersion;
  WinGlobal.Win32MinorVersion := SysUtils.Win32MinorVersion;
  WinGlobal.Win32BuildNumber := SysUtils.Win32BuildNumber;
  WinGlobal.Win32CSDVersion := SysUtils.Win32CSDVersion;

  WinGlobal.CurrencyString := SysUtils.CurrencyString;
  WinGlobal.CurrencyFormat := SysUtils.CurrencyFormat;
  WinGlobal.NegCurrFormat := SysUtils.NegCurrFormat;
  WinGlobal.ThousandSeparator := SysUtils.ThousandSeparator;
  WinGlobal.DecimalSeparator := SysUtils.DecimalSeparator;
  WinGlobal.CurrencyDecimals := SysUtils.CurrencyDecimals;
  WinGlobal.DateSeparator := SysUtils.DateSeparator;
  WinGlobal.ShortDateFormat := SysUtils.ShortDateFormat;
  WinGlobal.LongDateFormat := SysUtils.LongDateFormat;
  WinGlobal.TimeSeparator := SysUtils.TimeSeparator;
  WinGlobal.TimeAMString := SysUtils.TimeAMString;
  WinGlobal.TimePMString := SysUtils.TimePMString;
  WinGlobal.ShortTimeFormat := SysUtils.ShortTimeFormat;
  WinGlobal.LongTimeFormat := SysUtils.LongTimeFormat;

  for i := low(LongDayNames) to high(LongDayNames) do
    WinGlobal.LongDayNames[i] := SysUtils.LongDayNames[i]; // array[1..7] of string;
  for i := low(ShortDayNames) to high(ShortDayNames) do
    WinGlobal.ShortDayNames[i] := SysUtils.ShortDayNames[i]; // array[1..7] of string;
  for i := Low(LongMonthNames) to high(LongMonthNames) do
    WinGlobal.LongMonthNames[i] := SysUtils.LongMonthNames[i]; // array[1..12] of string;
  for i := Low(ShortMonthNames) to high(ShortMonthNames) do
    WinGlobal.ShortMonthNames[i] := SysUtils.ShortMonthNames[i]; // array[1..12] of string;

  WinGlobal.SysLocale.DefaultLCID := SysUtils.SysLocale.DefaultLCID;
  WinGlobal.SysLocale.FarEast := SysUtils.SysLocale.FarEast;
  WinGlobal.SysLocale.MiddleEast := SysUtils.SysLocale.MiddleEast;
  WinGlobal.SysLocale.PriLangID := SysUtils.SysLocale.PriLangID;
  WinGlobal.SysLocale.SubLangID := SysUtils.SysLocale.SubLangID;
  WinGlobal.LeadBytes := SysUtils.LeadBytes;

  for i := Low(EraNames) to high(EraNames) do
    WinGlobal.EraNames[i] := SysUtils.EraNames[i]; // array[1..7] of string;
  for i := low(EraYearOffsets) to high(EraYearOffsets) do
    WinGlobal.EraYearOffsets[i] := SysUtils.EraYearOffsets[i]; // array[1..7] of Integer;
  WinGlobal.TwoDigitYearCenturyWindow := SysUtils.TwoDigitYearCenturyWindow;
  WinGlobal.ListSeparator := SysUtils.ListSeparator;
end;

procedure ApplySettingToSystem;
// ALWAYS use WinGlobal for sync
var i: integer;
begin
  //SysUtils.Win32Platform := WinGlobal.Win32Platform;
  //SysUtils.Win32MajorVersion := WinGlobal.Win32MajorVersion;
  //SysUtils.Win32MinorVersion := WinGlobal.Win32MinorVersion;
  //SysUtils.Win32BuildNumber := WinGlobal.Win32BuildNumber;
  //SysUtils.Win32CSDVersion := WinGlobal.Win32CSDVersion;

  if SysUtils.SysLocale.DefaultLCID <> WinGlobal.SysLocale.DefaultLCID then
    SysUtils.SysLocale.DefaultLCID := WinGlobal.SysLocale.DefaultLCID;
  if SysUtils.SysLocale.FarEast <> WinGlobal.SysLocale.FarEast then
    SysUtils.SysLocale.FarEast := WinGlobal.SysLocale.FarEast;
  if SysUtils.SysLocale.MiddleEast <> WinGlobal.SysLocale.MiddleEast then
    SysUtils.SysLocale.MiddleEast := WinGlobal.SysLocale.MiddleEast;
  if SysUtils.SysLocale.PriLangID <> WinGlobal.SysLocale.PriLangID then
    SysUtils.SysLocale.PriLangID := WinGlobal.SysLocale.PriLangID;
  if SysUtils.SysLocale.SubLangID <> WinGlobal.SysLocale.SubLangID then
    SysUtils.SysLocale.SubLangID := WinGlobal.SysLocale.SubLangID;
  if SysUtils.LeadBytes <> WinGlobal.LeadBytes then
    SysUtils.LeadBytes := WinGlobal.LeadBytes;

  if SysUtils.CurrencyString <> WinGlobal.CurrencyString then
    SysUtils.CurrencyString := WinGlobal.CurrencyString;
  if SysUtils.CurrencyFormat <> WinGlobal.CurrencyFormat then
    SysUtils.CurrencyFormat := WinGlobal.CurrencyFormat;
  if SysUtils.NegCurrFormat <> WinGlobal.NegCurrFormat then
    SysUtils.NegCurrFormat := WinGlobal.NegCurrFormat;
  if SysUtils.ThousandSeparator <> WinGlobal.ThousandSeparator then
    SysUtils.ThousandSeparator := WinGlobal.ThousandSeparator;
  if SysUtils.CurrencyDecimals <> WinGlobal.CurrencyDecimals then
    SysUtils.CurrencyDecimals := WinGlobal.CurrencyDecimals;
  if SysUtils.DecimalSeparator <> WinGlobal.DecimalSeparator then
    SysUtils.DecimalSeparator := WinGlobal.DecimalSeparator;

  if SysUtils.ShortDateFormat <> WinGlobal.ShortDateFormat then
    SysUtils.ShortDateFormat := WinGlobal.ShortDateFormat;
  if SysUtils.LongDateFormat <> WinGlobal.LongDateFormat then
    SysUtils.LongDateFormat := WinGlobal.LongDateFormat;
  if SysUtils.DateSeparator <> WinGlobal.DateSeparator then
    SysUtils.DateSeparator := WinGlobal.DateSeparator;

  if SysUtils.TimeAMString <> WinGlobal.TimeAMString then
    SysUtils.TimeAMString := WinGlobal.TimeAMString;
  if SysUtils.TimePMString <> WinGlobal.TimePMString then
    SysUtils.TimePMString := WinGlobal.TimePMString;
  if SysUtils.ShortTimeFormat <> WinGlobal.ShortTimeFormat then
    SysUtils.ShortTimeFormat := WinGlobal.ShortTimeFormat;
  if SysUtils.LongTimeFormat <> WinGlobal.LongTimeFormat then
    SysUtils.LongTimeFormat := WinGlobal.LongTimeFormat;
  if SysUtils.TimeSeparator <> WinGlobal.TimeSeparator then
    SysUtils.TimeSeparator := WinGlobal.TimeSeparator;

  for i := low(LongDayNames) to high(LongDayNames) do
    if SysUtils.LongDayNames[i] <> WinGlobal.LongDayNames[i] then
      SysUtils.LongDayNames[i] := WinGlobal.LongDayNames[i];
  for i := low(ShortDayNames) to high(ShortDayNames) do
    if SysUtils.ShortDayNames[i] <> WinGlobal.ShortDayNames[i] then
      SysUtils.ShortDayNames[i] := WinGlobal.ShortDayNames[i];
  for i := Low(LongMonthNames) to high(LongMonthNames) do
    if SysUtils.LongMonthNames[i] <> WinGlobal.LongMonthNames[i] then
      SysUtils.LongMonthNames[i] := WinGlobal.LongMonthNames[i];
  for i := Low(ShortMonthNames) to high(ShortMonthNames) do
    if SysUtils.ShortMonthNames[i] <> WinGlobal.ShortMonthNames[i] then
      SysUtils.ShortMonthNames[i] := WinGlobal.ShortMonthNames[i];

  for i := Low(EraNames) to high(EraNames) do
    if SysUtils.EraNames[i] <> WinGlobal.EraNames[i] then
      SysUtils.EraNames[i] := WinGlobal.EraNames[i];
  for i := low(EraYearOffsets) to high(EraYearOffsets) do
    if SysUtils.EraYearOffsets[i] <> WinGlobal.EraYearOffsets[i] then
      SysUtils.EraYearOffsets[i] := WinGlobal.EraYearOffsets[i];

  if SysUtils.TwoDigitYearCenturyWindow <> WinGlobal.TwoDigitYearCenturyWindow then
    SysUtils.TwoDigitYearCenturyWindow := WinGlobal.TwoDigitYearCenturyWindow;
  if SysUtils.ListSeparator <> WinGlobal.ListSeparator then
    SysUtils.ListSeparator := WinGlobal.ListSeparator;
end;
// ============================================================

procedure LoadSettings(Settings: TWinGlobalSettings);
begin
  LoadSettingsFromSystem;
  CopySettingsFrom(Settings, WinGlobal);
end;

procedure ApplySettingsOf(Settings: TWinGlobalSettings);
begin
  CopySettingsFrom(Settings, WinGlobal);
  ApplySettingToSystem;
end;

procedure InitWinGlobalSettings;
begin
  LoadSettingsFromSystem;
end;

initialization
  InitWinGlobalSettings

end.


unit SoftReleases;

interface

const
  ReleaseBaseYear03 = 03;
  ReleaseBaseYear2000 = 2000;
  ReleaseBaseYear2003 = ReleaseBaseYear2000 + ReleaseBaseYear03;
  ReleaseBaseMonth = 09; // Sept 2003;
  ReleaseBaseStart = ReleaseBaseMonth;
  ReleaseCountYear = 20;
  // this system can only afford about 2 decades of release!
  // since internally saved as byte (8bits) with max.value = 255
  // months/year=12, years handled = 255/12 = 21 years.

type
  TByte = type byte;
  TInteger = type integer;
  TIDByte = type TByte;
  TIDInteger = type TInteger;

type
  //TDevBaseYear = iby2000..iby2005;
  //TDevYear = iby2003..iby2050;
  TDevBaseYear = ReleaseBaseYear2003..ReleaseBaseYear2003 + ReleaseCountYear;
  TDevYear = low(TDevBaseYear)..high(TDevBaseYear);
  TInc1DevYear = succ(low(TDevYear))..high(TDevYear);

type
  tInvalidBaseMonth = (tmInvalid, tmJanuary, tmFebruary, tmMarch, tmApril, tmMay,
    tmJune, tmJuly, tmAugust, tmSeptember, tmOctober, tmNovember, tmDecember);
  TDevMonth = tmJanuary..tmDecember;
  TValidMonth = succ(Low(TInvalidBaseMonth))..high(TInvalidBaseMonth);
  TMonths = set of TValidMonth;

type
  TSoftindoProduct = (softUnknown, SoftEXAC, SoftPPh21, SoftPPN, SoftGL, SoftDBEdit,
    SoftAbsRW, SoftCDCheck, SoftCPUID, SoftChkFlags, SoftDocLink, SoftChPos, SoftCxPos); // 8bit = 255
  TProductMajorVersion = (pvUnknown, pvDemo, pvStandard, pvProfessional, pvEnterprise, pvPrivate); //5bit = 31
  TProductMinorVersion = (svUnknown, svPatch); // 3bit = 7

  //TSoftindoProductID = type TIDByte; // softindoProduct
  //TProductItemID = TSoftindoProductID; //alias of softindoProduct

  TProductID = type TIDInteger; // product id, version & release
  TProductVersionID = type TIDByte;
  TProductReleaseID = type TIDByte;

  TProductIDEnumComponent = (enRelease, enVersion, enProduct);
  // low-order-first, better be 8bits mask for easy maintainenance

  TProductUpdateEvents = array[TSoftindoProduct] of TMonths;

const
  UpdateEventsNone = [];
  UpdateEventsAll = [tmJanuary..tmDecember];
  UpdateEventsEXAC = [tmMarch, tmJune, tmSeptember, tmDecember];
  UpdateEventsPPh21 = [tmJanuary, tmMarch, tmApril, tmMay, tmAugust, tmSeptember, tmOctober];
  UpdateEventsPPN = [tmJanuary, tmFebruary, tmApril, tmJuly, tmAugust, tmNovember];
  UpdateEventsGL = [tmFebruary, tmMarch, tmJuly, tmSeptember, tmDecember];

const MonthsPerYear = ord(high(TValidMonth)) - ord(low(TValidMonth)) + 1;

  //DevMonthCount = ord(high(TValidMonth)) - ord(low(TValidMonth)) + 1;
  //DevYearCount = ord(high(TDevYear)) - ord(low(TDevYear)) + 1;
  //ReleaseCount = DevMonthCount * DevYearCount;

  //MajorVersionCount = ord(high(TProductMajorVersion)) + 1;
  //MinorVersionCount = ord(high(TProductMinorVersion)) + 1;
  //VersionCount = MajorVersionCount * MinorVersionCount;

  ReleaseCount = high(byte);
  VersionCount = high(byte);
  ProductCount = ord(high(TSoftindoProduct)) + 1;

  ProductIDComponentsCount: array[TProductIDEnumComponent] of integer =
  (ReleaseCount, VersionCount, ProductCount);

function EncodeProductID(const SIProduct: TSoftindoProduct;
  const VersionID: TProductVersionID; ReleaseID: TProductReleaseID): TProductID;
function DecodeProductIDComponent(const ProductID: TProductID;
  const IDComponentEnum: TProductIDEnumComponent): TIDByte;
function DecodeSoftProduct(const ProductID: TProductID): TSoftindoProduct;
function DecodeProductVersionID(const ProductID: TProductID): TProductVersionID;
function DecodeProductMajorVersion(const ProductID: TProductID): TProductMajorVersion;
function DecodeProductMinorVersion(const ProductID: TProductID): TProductMinorVersion;
function DecodeProductReleaseID(const ProductID: TProductID): TProductReleaseID;
function DecodeProductReleaseYear(const ProductID: TProductID): TDevYear;
function DecodeProductReleaseMonth(const ProductID: TProductID): TValidMonth;

function EncodeRelease(const year: TDevYear; const month: TValidMonth): TProductReleaseID;
function DecodeReleaseYear(const Release: TProductReleaseID): TDevYear;
function DecodeReleaseMonth(const Release: TProductReleaseID): TValidMonth;

function EncodeVersion(const Major: TProductMajorVersion;
  const Minor: TProductMinorVersion): TProductVersionID;
function DecodeRootVersion(const Version: TProductVersionID): TProductMajorVersion;
function DecodeSubVersion(const Version: TProductVersionID): TProductMinorVersion;

function CountMonthMemberOf(const Months: TMonths): integer;
function getLowestMonthMemberOf(const Months: TMonths): TValidMonth;
function getHighestMonthMemberOf(const Months: TMonths): TValidMonth;

type
  TReleaseStrFormat = (rdfNone, rdfInt, rdfHex, rdfPack, rdfBrief, rdfVerbose);

function StrRelease(const Release: TProductReleaseID;
  const StrFormat: TReleaseStrFormat = rdfVerbose;
  const Separator: string = ' '): string; overload; forward;

function StrRelease(const year: TDevYear; const month: TValidMonth;
  const StrFormat: TReleaseStrFormat = rdfVerbose;
  const Separator: string = ' '): string; overload; forward;

procedure donothing;

// type //aliases
//   TProduct = TSoftindoProduct;
//   TVersion = TProductVersionID;
//   TRootVer = TProductMajorVersion;
//   TSubVer = TProductMinorVersion;
//   TRelease = TProductReleaseID;
//   TYear = TDevYear;
//   TMonth = TValidMonth;

implementation

//uses cxpos, SysUtils; // for formatstr function
uses EXACHexs;

procedure donothing;
begin
end;

const
  BitsPerByte = 8;
  //CustomBits = BitsPerByte;
  IDComponentBitsWide = BitsPerByte;
  IDComponentBitMask = 1 shl IDComponentBitsWide - 1;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Version Sub-encoding/decoding routines
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  MinorMaskBits = 3;
  MajorMaskbits = IDComponentBitsWide - MinorMaskBits;
  MinorMask = 1 shl MinorMaskBits - 1; // 00000111
  MajorMask = 1 shl MajorMaskBits - 1; // 00011111

function EncodeVersion(const Major: TProductMajorVersion;
  const Minor: TProductMinorVersion): TProductVersionID;
var
  m, n: integer;
begin
  // low order is n (minor), the m (major) then must be shifted-left
  // by the value of n (minor) maskbits
  n := ord(minor) and MinorMask;
  m := (ord(major) and MajorMask) shl 3;
  Result := TProductVersionID((m or n) and IDCOmponentBitMask);
end;

function DecodeRootVersion(const Version: TProductVersionID): TProductMajorVersion;
begin
  Result := TProductMajorVersion((ord(Version) shr MinorMaskBits) and MajorMask);
end;

function DecodeSubVersion(const Version: TProductVersionID): TProductMinorVersion;
begin
  Result := TProductMinorVersion(ord(Version) and MinorMask);
end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Release Sub-encoding/decoding routines
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function EncodeRelease(const year: TDevYear; const month: TValidMonth): TProductReleaseID;
var i: integer;
begin
  i := ord(year);
  dec(i, ReleaseBaseYear2003);
  i := i * MonthsPerYear + ord(month) - ReleaseBaseStart; //ord(tmSeptember);
  Result := TProductReleaseID(i and IDComponentBitMask);
end;

function DecodeReleaseYear(const Release: TProductReleaseID): TDevYear;
var
  i: integer;
begin
  i := Release + ReleaseBaseStart; //ord(tmSeptember);
  if i mod (MonthsPerYear) = 0 then dec(i);
  i := i div MonthsPerYear;
  inc(i, ReleaseBaseYear2003);
  Result := TDevYear(i);
end;

function DecodeReleaseMonth(const Release: TProductReleaseID): TValidMonth;
var
  i: integer;
begin
  i := Release + ReleaseBaseStart; //ord(tmSeptember);
  i := i mod (MonthsPerYear);
  if i = 0 then i := MonthsPerYear;
  Result := TValidMonth(i);
end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// String Release Display routines
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
const
  indomonths: array[TValidMonth] of string = ('Januari', 'Februari', 'Maret', 'April', 'Mei',
    'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'Nopember', 'Desember');

  indomonthshort: array[TValidMonth] of string = ('Jan', 'Feb', 'Mar', 'Apr', 'Mei',
    'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nop', 'Des');

//const
//  xcrfNone = ''; //blank
//  xcrfInt = '%.04d'; // 0027
//  xcrfHex = '%.04X'; // 001B
//  xcrfPack = '%.02d%.02d';
//  xcrfBrief = '%s-%02d';
//  xcrfVerbose = '%s %.04d';
//  ReleaseFormat: array[TReleaseStrFormat] of string =
//  (xcrFNone, xcrfInt, xcrfHex, xcrfPack, xcrfBrief, xcrfVerbose);

function StrRelease(const year: TDevYear; const month: TValidMonth;
  const StrFormat: TReleaseStrFormat; const Separator: string): string; overload;
const
  dash = '-';
  space = ' ';
  BriefSeparator = dash;
  VerboseSeparator = space;
var
  yr: integer;
  yrs: string;
begin
  yr := ord(year);
  if StrFormat <> rdfVerbose then begin
    dec(yr, ReleaseBaseYear2000);
    yrs := EXACHexs.intoStr(yr, 2);
  end
  else
    yrs := EXACHexs.intoStr(yr, 4);
  case StrFormat of
    rdfPack: Result := yrs + EXACHexs.intoStr(ord(month), 2);
    rdfBrief: Result := indomonthshort[month] + BriefSeparator + yrs;
    rdfVerbose: Result := indomonths[month] + VerboseSeparator + yrs;
    else
      Result := StrRelease(EncodeRelease(year, month), StrFormat, Separator);
  end;
end;

function StrRelease(const Release: TProductReleaseID;
  const StrFormat: TReleaseStrFormat; const Separator: string): string; overload;
const
  zero = '0';
  dec = 'D';
  hex = 'H';
  hex0 = hex + zero;
begin
  case StrFormat of
    rdfInt: Result := dec + EXACHexs.IntoStr(ord(Release), 3);
    //rdfHex: Result := hex0 + EXACHexs.IntoHex_Old(ord(Release), 1);
    rdfHex: Result := hex + EXACHexs.IntoHex(ord(Release), 3);
    rdfPack, rdfBrief, rdfVerbose:
      Result := StrRelease(DecodeReleaseYear(Release), DecodeReleaseMonth(Release), StrFormat, Separator);
    else
      Result := '';
  end;
end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Main Encoding/Decoding routines
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
const
  //ByteBits = 8; CustomBits = ByteBits;
  EncodeShift = IDComponentBitsWide; //ByteBits;
  EncodeMask = 1 shl EncodeShift - 1;

function EncodeProductID(const SIProduct: TSoftindoProduct;
  const VersionID: TProductVersionID; ReleaseID: TProductReleaseID): TProductID;
  // here we permit EncodeShift <> ByteBits
const
  pk = EncodeMask shl (ord(enProduct) * EncodeShift);
  vk = EncodeMask shl (ord(enVersion) * EncodeShift);
  rk = EncodeMask shl (ord(enRelease) * EncodeShift);
var
  p, v, r: integer;
begin
  //p := (ord(Product) shl (ord(enProduct) * EncodeShift)) and pk; //inconvenient
  p := pk and (ord(SIProduct) shl (ord(enProduct) * EncodeShift)); // same result
  v := vk and (ord(VersionID) shl (ord(enVersion) * EncodeShift));
  r := rk and (ord(ReleaseID) shl (ord(enRelease) * EncodeShift));
  Result := p or v or r;
end;

function DecodeProductIDComponent(const ProductID: TProductID;
  const IDComponentEnum: TProductIDEnumComponent): TIDByte;
begin
  Result := (ProductID shr (EncodeShift * ord(IDComponentEnum))) and EncodeMask;
  //check whether it is out of range
  if Result >= ProductIDComponentsCount[IDComponentEnum] then
    Result := pred(ProductIDComponentsCount[IDComponentEnum])
end;

function DecodeSoftProduct(const ProductID: TProductID): TSoftindoProduct;
var ID: TIDByte;
begin
  ID := DecodeProductIDComponent(ProductID, enProduct);
  Result := TSoftindoProduct(ID);
end;

function DecodeProductVersionID(const ProductID: TProductID): TProductVersionID;
var ID: TIDByte;
begin
  ID := DecodeProductIDComponent(ProductID, enVersion);
  Result := TProductVersionID(ID);
end;

function DecodeProductMajorVersion(const ProductID: TProductID): TProductMajorVersion;
var
  Version: TProductVersionID;
begin
  Version := DecodeProductVersionID(ProductID); // calls version Main-decoding
  Result := DecodeRootVersion(Version); // calls version Sub-decoding
end;

function DecodeProductMinorVersion(const ProductID: TProductID): TProductMinorVersion;
var
  VersionID: TProductVersionID;
begin
  VersionID := DecodeProductVersionID(ProductID); // calls version Main-decoding
  Result := DecodeSubVersion(VersionID); // calls version Sub-decoding
end;

function DecodeProductReleaseID(const ProductID: TProductID): TProductReleaseID;
var ID: TIDByte;
begin
  ID := DecodeProductIDComponent(ProductID, enRelease);
  Result := TProductReleaseID(ID);
end;

function DecodeProductReleaseYear(const ProductID: TProductID): TDevYear;
var
  ReleaseID: TProductReleaseID;
begin
  ReleaseID := DecodeProductReleaseID(ProductID); // calls release Main-decoding
  Result := DecodeReleaseYear(ReleaseID); // calls release Sub-decoding
end;

function DecodeProductReleaseMonth(const ProductID: TProductID): TValidMonth;
var
  ReleaseID: TProductReleaseID;
begin
  ReleaseID := DecodeProductReleaseID(ProductID); // calls release Main-decoding
  Result := DecodeReleaseMonth(ReleaseID); // calls release Sub-decoding
end;

function CountMonthMemberOf(const Months: TMonths): integer;
var m: TValidMonth;
begin
  Result := 0;
  if Months <> [] then
    for m := low(m) to high(m) do
      if m in Months then inc(Result);
end;

function getLowestMonthMemberOf(const Months: TMonths): TValidMonth;
begin
  if Months = [] then Result := high(Result) else
    for Result := low(Result) to high(result) do
      if Result in Months then break;
end;

function getHighestMonthMemberOf(const Months: TMonths): TValidMonth;
begin
  if Months = [] then Result := low(Result) else
    for Result := high(Result) downto low(result) do
      if Result in Months then break;
end;

end.


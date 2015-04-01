unit docltool;
{.$WEAKPACKAGEUNIT ON}
interface
uses Classes;
const
  TAB = ^i;
  YES = TRUE;

const
  Unknown_Header = '';
  MapFile_Header = '[ID Conversion Table]';
  RevFile_Header = '[ID Revision Table]';
  TabFile_Header = '[Excel-Tab Summary]';
  TabFile_Header2 = '[Excel-Tab Revisions]';
  TabFile_Header3 = '[Excel-Tab Obsolescenses]';

  MapFile_KRelease = 'Release'; //K = Key

  MapFile_CTitle = 'New-ID'^i'Old-ID'^i^i'Old-ID'^i'New-ID'; // C = Column/Content

  MapFile_CTitle2 = 'NewID'^i'BaseID'^i^i'BaseID'^i'NewID'; // C = Column/Content

  MapFile_CTitle3 = 'New-ID'^i'BaseID'^i^i'BaseID'^i'New-ID'; // C = Column/Content
  MapFile_CTitle4 = 'New-ID'^i'Base-ID'^i^i'Base-ID'^i'New-ID'; // C = Column/Content

  MapFile_CTitle5 = 'New_ID'^i'BaseID'^i^i'BaseID'^i'New_ID'; // C = Column/Content
  MapFile_CTitle6 = 'New_ID'^i'Base_ID'^i^i'Base_ID'^i'New_ID'; // C = Column/Content

  RevFile_CTitle = 'ID'^i'REV1'^i'REV2'^i'REV3'^i'REV4'^i'REV5'^i'OBS1'^i'OBS2'^i'OBS3'^i'OBS4'^i'OBS5';
  TabFile_CTitle = RevFile_CTitle;
  TabFile_CTitle2 = 'ID'^i'REV1'^i'REV2'^i'REV3'^i'REV4'^i'REV5'; //^i'REV6'^i'REV7'^i'REV8'^i'REV9'^i'REV10';
  TabFile_CTitle3 = 'ID'^i'OBS1'^i'OBS2'^i'OBS3'^i'OBS4'^i'OBS5'; //^i'OBS6'^i'OBS7'^i'OBS8'^i'OBS9'^i'OBS10';
  TabFile_CTitle4 = 'ID'^i'REVS1'^i'REVS2'^i'REVS3'^i'REVS4'^i'REVS5'; //^i'REV6'^i'REV7'^i'REV8'^i'REV9'^i'REV10';

type
  TDocLinkFileType = (dlftUnknown, dlftMap, dlftTab, dlftRev);
  TDocLinkMapConversion = (dlmcNewToBase, dlmcBaseToNew, dlmcCross);

  TDocLinkTabRange = 1..high(byte) div 4; //max = 64
  TDocLinkTabRangeSet = set of TDocLinkTabRange;

procedure CombineIDList(const CombinedList, SLTabOnly1, SLTabOnly2: TStrings;
  const maxID: integer; const delimiter: char = TAB);

function ProceedDocLinkFile(const tabfile, mapfile: string;
  const ZipXList: boolean = FALSE; const GotExpRList: TObject = nil): string; overload;
//function ProceedDocLinkFile(const tabfile, mapfile, dbfile: string; gotExtList: TObject = nil): integer; overload;
function ProceedDocLinkFile(const tabfile, mapfile1, mapfile2: string;
  const Operation: TDocLinkMapConversion; const GotExpRList: TObject;
  const BuildRevsObses, ZipXList, StoreMap: boolean): string; overload;
//function GetDocLinkFileType(const filename: string): TDocLinkFileType;
//function FileAsType(const filename: string; const FType: TDocLinkFileType): string;
//function Filexist(const filename: string; const FType: TDocLinkFileType): boolean;
//function GetCIDTitle(const docType: TDocLinkFileType): string;
//function intoStr(const I: integer; const digits: Integer = 0): string;
//function intOf(const S: string; const DefaultValue: integer = 0): integer;
//function Str2Int(const S: string; const DefaultValue: integer = 0): integer;

function IsValidDocLinkContentList(filename: string; DocType: TDocLinkFileType;
  const HeaderMustBeValid, TitleMustBeValid: boolean): boolean;

function ExtractRevListBySection(const got1Reves, got2Obses, got3Reved, got4Obsed: TObject): boolean; overload;

//function ConvertDocLinkTabByMapList(const tabfile: string; const Operation: TDocLinkMapConversion;
//  const Map1Strings: TObject; const Map2Strings: TObject = nil;
//  {const inplaceModification: boolean = FALSE;}const BuildRevedByAndObsedBy: boolean = TRUE;
//  {const BuildCombinedRevObs: boolean = TRUE;}const StoreMap: boolean = FALSE): string; overload;

function ConvertDocLinkTabByMapList(const tabfile: string; const Operation: TDocLinkMapConversion;
  //const CRevObs, GotRevedObsedList, GotRevesList, GotObsesList, GotRevedList, GotObsedList: TStringList;
  const GotExpRList: TObject; const Map1Strings: TObject; const Map2Strings: TObject = nil;
  {const inplaceModification: boolean = FALSE;}const BuildRevsedAndObsed: boolean = TRUE;
  {const BuildCombinedRevObs: boolean = TRUE;}const ZipXList: boolean = FALSE; const StoreMap: boolean = FALSE): string; overload;

function ConvertDocLinkTabByMapFile(const Operation: TDocLinkMapConversion;
  {const ZipXList: boolean;}const GotExpRList: TObject; const tabfile, mapfile1: string;
  const mapfile2: string; BuildRevedByAndObsedBy, ZipXList, StoreMap: boolean): string; overload;

//function GetDocLinkBakFilename(const Filename: string; const NewExtension: string = '.';
//  const CounterDigits: integer = 3; const AutoPrependExtensionWithDot: Boolean = YES): string;

//function RevisionIDTabFilename(const packzed: boolean): string;

//function unixed(const CRLFText: string): string;
//function UNIXed2(const CRLFText: string): string;
//function MACed(const CRLFText: string): string;
//function PosCRLF(const S: string; const StartPos: integer = 1): integer;

procedure BuildRevedObsed(const SLTabOnly, GotRevObsedList, GotRevByList, GotObsByList: TStringList;
  const RevsRange, ObsesRange: TDocLinkTabRangeSet; const Delimiter: Char); overload;

function BuildComprehensiveRevisions(const tabfile: string; GotRevesObses, GotRevedObsed: TStringList;
  GotReves, GotObses, GotReved, GotObsed: TStringList): integer; overload; //all stringlist are result containers

function SaveXList(const List: TStrings; filename: string; const zipped: boolean): string;

implementation

uses fDfuncs, {CxPos,} ChPos, ClipBrd, dzx, fileCprX, EXACdbConsts, ACConsts; //, ACommon, OrdNums;

type
  TCHeadTit = (tcHeader, tcTitle);

  THeadTit = packed record
    Valid: boolean;
    Header, Title: string;
  end;

const
  DOT = '.';
  NULLCHAR = #0;
  DOCNUMBERAPPROX = $1969;
  //MAXDOCID = $1000;
  NewIDX = 1; // column of New-ID
  BaseIDByNewIDX = 2; // column of Old-ID (Base-ID) Sorted by New-ID
  NotUsedColumnIDX = 3; // not-used
  BaseIDX = 4; // column of Old-ID (Base-ID)
  NewIDByBaseIDX = 5; // column of New-ID Sorted by Old-ID (Base-ID)

const
  NUMERIC = ['0'..'9'];
  HEXHIGH = ['A'..'F'];
  HEXNUM = NUMERIC + HEXhigh;
  ALPHABET = ['A'..'Z', 'a'..'z'];
  ALPHANUMERIC = ALPHABET + NUMERIC;

const
  _ID_ = 'ID'^i;
  _REV_ = 'REV'; _OBS_ = 'OBS';

const
  ext_Any = '';
  ext_map = '.map';
  ext_tab = '.tab';
  ext_rev = '.rev';
  ext_bin = '.bin';
  ext_zx = ext_bin;
  error_ = 'error!';

type
  TInts = ACConsts.TInts;
  TStrs = ACConsts.TStrs;

const
  DEFAULT_DocLinkKeyWords: string =
  'batal'^j'dibatalkan'^j'membatalkan'^j'pembatalan'^j +
    'cabut'^j'dicabut'^j'mencabut'^j'pencabutan'^j +
    'ubah'^j'berubah'^j'diubah'^j'mengubah'^j'pengubah'^j'pengubahan'^j'perubahan'^j +
    'rubah'^j'dirubah'^j'merubah'^j'perubah'^ +
    'obah'^j'berobah'^j'diobah'^j'mengobah'^j'pengobah'^j'pengobahan'^j +
    'robah'^j'dirobah'^j'merobah'^j'perobah'^j'perobahan'^j +
    'ganti'^j'berganti'^j'diganti'^j'digantikan'^j'mengganti'^j'menggantikan'^j +
    'pengganti'^j'penggantian'^j'pergantian'^j +
    'hapus'^j'dihapus'^j'menghapus'^j'menghapuskan'^j'penghapus'^j'penghapusan'^j +
    'berlaku'^j'diberlakukan'^j'pemberlakuan'^j +
    'sempurna'^j'disempurnakan'^j'menyempurnakan'^j'penyempurnaan'^j +
    'revisi'^j'direvisi'^j'merevisi'^j;

  // ========================  SysUtils =========================

  //function Strscan(const Str: PChar; Chr: Char): PChar; assembler;
  //asm
  //        PUSH    EDI
  //        PUSH    EAX
  //        MOV     EDI,Str
  //        MOV     ECX,0FFFFFFFFH
  //        XOR     AL,AL
  //        REPNE   SCASB
  //        NOT     ECX
  //        POP     EDI
  //        MOV     AL,Chr
  //        REPNE   SCASB
  //        MOV     EAX,0
  //        JNE     @@1
  //        MOV     EAX,EDI
  //        DEC     EAX
  //@@1:    POP     EDI
  //end;
  //
  //function LastDelimiter(const Delimiters, S: string): Integer;
  //var
  //  P: PChar;
  //begin
  //  Result := Length(S);
  //  P := PChar(Delimiters);
  //  while Result > 0 do
  //  begin
  //    if (S[Result] <> #0) and (Strscan(P, S[Result]) <> nil) then
  //      if (ByteType(S, Result) = mbTrailByte) then
  //        Dec(Result)
  //      else
  //        Exit;
  //    Dec(Result);
  //  end;
  //end;
  //
  //function ChangeFileExt(const FileName, Extension: string): string;
  //var
  //  I: Integer;
  //begin
  //  I := LastDelimiter('.\:', Filename);
  //  if (I = 0) or (FileName[I] <> '.') then I := MaxInt;
  //  Result := Copy(FileName, 1, I - 1) + Extension;
  //end;

  // function LastDelimiter(const Delimiters, S: string): integer;
  //  //apart from SysUtils'es LastDelimiter, this might not work with mbcs
  // var
  //   i, j: integer;
  // begin
  //   Result := 0;
  //   for i := length(S) downto 1 do
  //     for j := 1 to length(Delimiters) do
  //       if S[i] = Delimiters[j] then begin
  //         Result := i;
  //         exit; //break; // do not use break (under inner loop)
  //       end;
  // end;
  //
  // function ChangeFileExt(const Filename, Extension: string): string;
  // var
  //   i: integer;
  // begin
  //   i := LastDelimiter('.\:', Filename);
  //   if (i = 0) or (Filename[i] <> '.') then i := MaxInt;
  //   Result := Copy(Filename, 1, i - 1) + Extension;
  // end;

  // function GetCIDTitle(const docType: TDocLinkFileType): string;
  //   function getet(const S: string; const pos: integer): string;
  //   var n: integer;
  //   begin
  //     n := ChPos.CharNth(2, TAB, S);
  //     if n < 1 then Result := '' else Result := Copy(S, 1, n - 1);
  //   end;
  //
  // const
  //   CIDMap = MapFile_CTitle;
  //   CIDRev = RevFile_CTitle;
  //   CIDTab = TabFile_CTitle;
  // begin
  //   case docType of
  //     dlftMap: Result := getet(CIDMap, 2);
  //     dlftTab: Result := getet(CIDTab, 4);
  //     dlftRev: Result := getet(CIDRev, 4);
  //     else Result := '';
  //   end;
  // end;

function min(const a, b: integer): integer; asm
  cmp a, b; jle @end
  mov a, b; @end:
end;

function max(const a, b: integer): integer; asm
  cmp a, b; jge @end
  mov a, b; @end:
end;

function PlainPSort(a, b: pointer): integer; asm sub eax, edx; end;
//function plainSort(a, b: pointer): integer; asm sub a, b; end;

procedure SortUpInts(Ints: TInts); //sort ascending
  procedure QSort(Ints: TInts; L, R: Integer);
  var
    i, j: Integer;
    A, B: integer;
  begin
    repeat
      i := L; j := R;
      A := Ints[(L + R) shr 1];
      repeat
        while Ints[i] < A do
          inc(i);
        while Ints[j] > A do
          dec(j);
        if i <= j then begin
          B := Ints[i];
          Ints[i] := Ints[j];
          Ints[j] := B;
          inc(i); dec(j);
        end;
      until i > j;
      if L < j then
        QSort(Ints, L, j);
      L := i;
    until i >= R;
  end;

begin
  QSort(Ints, 0, high(Ints));
end;

procedure SortDownInts(Ints: TInts); //sort ascending
  procedure QSort(Ints: TInts; L, R: Integer);
  var
    i, j: Integer;
    A, B: integer;
  begin
    repeat
      i := L; j := R;
      A := Ints[(L + R) shr 1];
      repeat
        while Ints[i] > A do
          inc(i);
        while Ints[j] < A do
          dec(j);
        if i <= j then begin
          B := Ints[i];
          Ints[i] := Ints[j];
          Ints[j] := B;
          inc(i); dec(j);
        end;
      until i > j;
      if L < j then
        QSort(Ints, L, j);
      L := i;
    until i >= R;
  end;

begin
  QSort(Ints, 0, high(Ints));
end;

procedure PQuickSort(SortList: PPointerList; L, R: Integer);
var
  i, j: integer;
  P, Q: pointer;
begin
  repeat
    i := L;
    j := R;
    P := SortList^[(L + R) shr 1];
    repeat
      while integer(SortList^[i]) < integer(P) do
        inc(i);
      while integer(SortList^[j]) > integer(P) do
        dec(j);
      if i <= j then begin
        Q := SortList^[i];
        SortList^[i] := SortList^[j];
        SortList^[j] := Q;
        inc(i); dec(j);
      end;
    until i > j;
    if L < j then
      PQuickSort(SortList, L, j);
    L := i;
  until i >= R;
end;

function intOf(const S: string; const DefaultValue: integer = 0): integer;
var
  e: integer;
begin
  val(S, Result, e);
  if e <> 0 then
    Result := DefaultValue;
end;

function Str2Int(const S: string; const DefaultValue: integer = 0): integer;
var
  e: integer;
begin
  Val(S, Result, e);
  if e <> 0 then
    Result := DefaultValue;
end;

function intoStr(const I: integer; const digits: Integer = 0): string;
const
  zero = '0'; dash = '-';
var
  n: integer;
begin
  if I = 0 then
    Result := StringOfChar(zero, max(1, digits))
  else begin
    Str(I: 0, Result);
    n := length(Result);
    if digits > n then begin
      if i > 0 then
        Result := StringOfchar(zero, digits - n) + Result
      else
        Result := dash + StringOfChar(zero, digits - n) + copy(Result, 2, n);
    end;
  end;
end;

function trimStr(const S: string): string;
var
  i, Len: integer;
begin
  i := 1;
  Len := Length(S);
  while (i <= Len) and (S[i] <= ' ') do
    inc(i);
  if i > Len then
    Result := ''
  else begin
    while S[Len] <= ' ' do
      dec(Len);
    Result := Copy(S, i, Len - i + 1);
  end;
end;

function trimmed(const S: string; const Delimiter: char): string;
var
  i, Len: integer;
begin
  i := 1;
  Len := Length(S);
  while (i <= Len) and (S[i] = Delimiter) do
    inc(i);
  if i > Len then
    Result := ''
  else begin
    while S[Len] = Delimiter do
      dec(Len);
    Result := Copy(S, i, Len - i + 1);
  end;
end;

function _trimStr(const S: string): string;
var
  i, L: integer;
begin
  i := 1;
  L := Length(S);
  while (i <= L) and (S[i] <= ' ') do
    inc(i);
  if i > L then
    Result := ''
  else begin
    while S[L] <= ' ' do
      dec(L);
    Result := Copy(S, i, L - i + 1);
  end;
end;

function trimStr_(const S: string): string;
var
  i: integer;
begin
  i := Length(S);
  while (i > 0) and (S[i] <= ' ') do
    dec(i);
  Result := Copy(S, 1, i);
end;

function GetDelimiter(const Str: string): char;
var
  i: integer;
  S: string;
begin
  Result := #0;
  S := trimStr(Str);
  if S <> '' then
    for i := 1 to length(S) do
      if not (S[i] in ALPHANUMERIC) then begin
        Result := S[i];
        Break;
      end;
end;

procedure trimStrs(var Strs: TStrs);
var
  i, j: integer;
  ss: TStrs;
begin
  if length(Strs) > 1 then begin
    SetLength(ss, length(Strs));
    j := 0;
    for i := 0 to high(Strs) do
      if Strs[i] <> '' then begin
        ss[j] := Strs[i];
        inc(j);
      end;
    if j < length(Strs) then begin
      SetLength(Strs, j);
      for i := 0 to j - 1 do
        Strs[i] := ss[i];
    end;
    SetLength(ss, 0);
  end;
end;

type
  tSortOrder = (soNone, soAscending, soDescending);

function WCSortLS(const LSn: TStringList; const Delimiter: Char; const Include1stWord: boolean; SortOrder: TSortOrder): integer;
// LSn is a TStringList must contain only list of numbers
// (LSn items is a string of delimited numbers) such as:
// '100,02,34,567,08', '04<TAB>55<TAB>003<TAB>' etc.
// (note that in this doclink system, delimiter is a TAB)
// this function Sort all items individually & return maxword count
// (the highest count of word (as number) contained in the list items)
// useful to allocate the array wide which can handles all numbers
// not that the StringList itself is NOT Sorted.
var
  i, j, n: integer;
  S, sn: string;
  Ints: TInts;
  shift: integer;
begin
  Result := 0;
  shift := ord(not Include1stWord);
  with LSn do
    for i := 0 to Count - 1 do begin
      S := Strings[i];
      n := WordCount(S, Delimiter);
      if Result < n then
        Result := n;
      if n > Shift then begin
        SetLength(Ints, n - Shift);
        for j := 0 to n - 1 - Shift do
          Ints[j] := intOf(WordAtIndex(j + 1 + Shift, S, Delimiter), 0);
        case SortOrder of
          soAscending: SortUpInts(Ints);
          soDescending: SortDownInts(Ints);
        else
          ;
        end;

        sn := '';
        for j := 0 to n - 1 - Shift do begin
          if j > 0 then
            sn := sn + Delimiter;
          sn := sn + intoStr(Ints[j], 5);
        end;
        S := WordAtIndex(Shift, S, Delimiter);
        if (sn <> '') then
          if (S <> '') then
            S := S + Delimiter + sn
          else
            S := sn;
        Strings[i] := S;
      end;
    end
end;

function GetPossibleHeaders(const DocType: TDocLinkFileType): TStrs; // including invalid one
const
  InvalidTabFileHeader = EXACdbConsts.HEADER_ReleaseIndexMap; // invalid base table but accepted as header
const
  DocLinkHeader: array[TDocLinkFileType] of string =
  (Unknown_Header, MapFile_Header, TabFile_Header, RevFile_Header);

  TabFile_Headers: array[1..5] of string =
  (RevFile_Header, TabFile_Header, InvalidTabFileHeader, TabFile_Header2, TabFile_Header3);

const
  TabhL = Low(TabFile_Headers);
  TabhH = high(TabFile_Headers);
  TabhN = TabhH - TabhL + 1;
var
  i: integer;
begin
  SetLength(Result, 1);
  case DocType of //(dtUnknown, dtMap, dlftTab, dtRev);
    dlftMap: Result[0] := trimStr(DocLinkHeader[DocType]);
    dlftTab: begin
        SetLength(Result, TabhN);
        for i := 0 to TabhN - 1 do
          Result[i] := TabFile_Headers[i + TabhL];
      end;
  else
    SetLength(Result, 0);
  end;
  trimStrs(Result);
end;

function GetPossibleTitles(const DocType: TDocLinkFileType): TStrs;
const
  Delimiter = TAB;
  TabFile_CTitles: array[1..4] of string =
  (TabFile_CTitle, TabFile_CTitle2, TabFile_CTitle3, TabFile_CTitle4);

  MapFile_CTitles: array[1..6] of string =
  (MapFile_CTitle, MapFile_CTitle2, MapFile_CTitle3, MapFile_CTitle4,
    MapFile_CTitle5, MapFile_CTitle6);
const
  MaptL = Low(MapFile_CTitles);
  MaptH = high(MapFile_CTitles);
  MaptN = MaptH - MaptL + 1;

  TabtL = Low(TabFile_CTitles);
  TabtH = high(TabFile_CTitles);
  TabtN = TabtH - TabtL + 1;
var
  S: string;
  i, n: integer;
begin
  case DocType of
    dlftMap: begin
        SetLength(Result, MaptN);
        for i := 0 to MaptH do begin
          S := MapFile_CTitles[i + MaptL];
          n := ChPos.CharAtIndex(2, Delimiter, S);
          if n > 0 then
            Result[i] := Copy(S, 1, n - 1);
        end;
      end;
    dlftTab: begin
        SetLength(Result, TabtN);
        for i := 0 to TabtN - 1 do begin
          S := TabFile_CTitles[i + TabtL];
          n := ChPos.CharAtIndex(2, Delimiter, S);
          if n > 0 then
            Result[i] := Copy(S, 1, n - 1);
        end;
      end;
  else
    SetLength(Result, 0);
  end;
  trimStrs(Result);
end;

procedure GetPossibletHeadersAndTitles(var headers, titles: TStrs; const DLFType: TDocLinkFileType);
begin
  headers := GetPossibleHeaders(DLFType);
  titles := GetPossibleTitles(DLFType);
end;

function GetDelimitedIDvalue(const S: string; const Delimiter: Char;
  const ColIndex: integer = NewIDX): integer; overload;
begin
  Result := intOf(ChPos.WordAtIndex(ColIndex, S, Delimiter));
end;

function GetDelimitedIDvalue(const S: string;
  const ColIndex: integer = NewIDX): integer; overload;
begin
  Result := GetDelimitedIDvalue(S, GetDelimiter(S), ColIndex);
end;

function MaxNewID(const S: string): integer; overload;
begin
  Result := GetDelimitedIDvalue(S, GetDelimiter(S), NewIDX); //col-1
end;

function MaxNewID(const IDMapList: TStrings): integer; overload;
begin
  with IDMapList do
    if Count < DOCNUMBERAPPROX then
      Result := -1
    else
      Result := MaxNewID(Strings[Count - 1]);
end;

function MaxBaseID(const S: string): integer; overload;
begin
  Result := GetDelimitedIDvalue(S, GetDelimiter(S), BaseIDX); //col-4
end;

function MaxBaseID(const IDMapList: TStrings): integer; overload;
begin
  with IDMapList do
    if Count < DOCNUMBERAPPROX then
      Result := -1
    else
      Result := MaxBaseID(Strings[Count - 1]);
end;

//function GetLastIDValue(const IDList: TStringList; const Delimiter: Char;
//  const ReSort: boolean = FALSE): integer; overload;
//var
//  sn: string;
//begin
//  if ReSort then IDList.Sort;
//  with IDList do if Count > 0 then
//      Result := getDelimitedIDvalue(Strings[Count - 1], Delimiter)
//    else Result := -1;
//end;

//  function GetLastIDValue(const IDList: TStringList; const ColIndex: integer = NewIDX): integer; overload;
//  begin
//    //if ReSort then IDList.Sort;
//    with IDList do if Count < 1 then Result := -1
//      else Result := getDelimitedIDvalue(Strings[Count - 1], ColIndex)
//  end;

//  procedure GetListIDValues(out Result: TInts; const SL: TStringList;
//    const ColIndex: integer = NewIDX; IDMax: integer = -1);
//  var
//    n: integer;
//    Ch: char;
//  begin
//    if IDMax > 0 then n := IDMax else n := GetLastIDValue(SL, ColIndex);
//    SetLength(Result, n + 1);
//    if length(Result) > 0 then begin
//      Result[high(Result)] := n;
//      Ch := GetDelimiter(SL[0]);
//      for n := 0 to high(Result) - 1 do
//        Result[n] := -1;
//      with SL do
//        for n := 0 to Count - 1 - 1 do
//          Result[n] := GetDelimitedIDvalue(Strings[n], Ch, ColIndex);
//    end;
//  end;

procedure GetMapByBaseID(out IDsMap: TInts; const SLMap: TStrings);
// results: IDsMap[BaseID] = NewID
var
  x: integer;
  new, base: integer;
  Ch: char;
begin
  x := MaxBaseID(SLMap); //GetLastIDValue(SL, ColIndex);
  if x < DOCNUMBERAPPROX then
    SetLength(IDsMap, 0)
  else begin
    inc(x);
    SetLength(IDsMap, x);
    for x := 0 to high(IDsMap) do
      IDsMap[x] := -1;
    Ch := GetDelimiter(SLMap[0]);
    with SLMap do
      for x := 0 to Count - 1 do {if trim(Strings[x]) <> '' then} begin
        base := GetDelimitedIDvalue(Strings[x], Ch, BaseIDX); // Col-4
        new := GetDelimitedIDvalue(Strings[x], Ch, NewIDByBaseIDX); // Col-5
        IDsMap[base] := new;
      end;
  end;
end;

procedure GetMapByNewID(out IDsMap: TInts; const SLMap: TStrings);
// results: IDsMap[NewID] = BaseID
var
  x: integer;
  new, base: integer;
  Ch: char;
begin
  x := MaxNewID(SLMap); //GetLastIDValue(SL, ColIndex);
  if x < DOCNUMBERAPPROX then
    SetLength(IDsMap, 0)
  else begin
    inc(x);
    SetLength(IDsMap, x);
    for x := 0 to high(IDsMap) do
      IDsMap[x] := -1;
    Ch := GetDelimiter(SLMap[0]);
    with SLMap do
      for x := 0 to Count - 1 do {if trim(Strings[x]) <> '' then} begin
        new := GetDelimitedIDvalue(Strings[x], Ch, NewIDX); //Col-1
        base := GetDelimitedIDvalue(Strings[x], Ch, BaseIDByNewIDX); //Col-2
        IDsMap[new] := base;
      end;
  end;

end;

function WordIndexOf(const SubStr, S: string; const Delimiter: char;
  const LengthToBeCompared: integer = MaxInt; const ignoreCase: boolean = TRUE): integer;
var
  i: integer;
  CS, CSubStr: string;
  M: integer;
begin
  Result := -1;
  if (S <> '') and (SubStr <> '') and (LengthToBeCompared > 0) then begin
    M := min(Length(SubStr), LengthToBeCompared);
    if (length(S) >= M) then begin
      CS := S;
      CSubStr := copy(SubStr, 1, M);
      if IgnoreCase then begin
        CS := UpperStr(CS);
        CSubStr := UpperStr(CSubStr);
      end;
      for i := 1 to WordCount(CS, Delimiter) do
        if copy(WordAtIndex(i, CS, Delimiter), 1, M) = CSubStr then begin
          Result := i;
          break;
        end;
    end;
  end;
end;

function GetClipBoardList(const Ints: TInts; Delimiter: Char = TAB;
  ClearClipBoard: boolean = TRUE): integer;
var
  i: integer;
  S: string;
begin
  S := '';
  Result := high(Ints);
  if Result > 0 then begin
    for i := 0 to Result do begin
      S := S + intoStr(i, 5);
      S := S + Delimiter;
      S := S + intoStr(Ints[i], 5);
      S := S + ^j;
    end;
    with ClipBoard do
      if ClearClipBoard then
        AsText := S
      else
        AsText := AsText + ^j + S
  end;
end;

function LookStrs(const SL: TStrings; const Strs: TStrs; const MAXLOOKUP: integer = 0): integer;
  function upt(const S: string): string; begin
    Result := UpperStr(trimStr(S));
  end;
var
  n, k: integer;
  S, ss: string;
begin
  Result := -1;
  if SL.Count > 1 then
    for n := 0 to min(SL.Count - 1, MAXLOOKUP) do
      if Result < 0 then begin
        S := SL[n];
        for k := 0 to high(Strs) do
          if Strs[k] <> '' then begin
            ss := upt(Strs[k]);
            if ss = Copy(upt(S), 1, length(ss)) then begin
              Result := n;
              Break;
            end;
          end;
      end;
end;

function getRevObsRanges(const Title: string; var RevsRange, ObsesRange: TDocLinkTabRangeSet): Char;
const
  CIDLen2BCmp = length(_ID_);
var
  k: integer;
  sk: string;
begin
  Result := GetDelimiter(Title);
  RevsRange := []; ObsesRange := [];
  for k := 1 to WordCount(Title, Result) do begin
    sk := UpperStr(Copy(WordAtIndex(k, Title, Result), 1, CIDLen2BCmp));
    if sk = _REV_ then
      Include(RevsRange, k)
    else if sk = _OBS_ then
      Include(ObsesRange, k);
  end;
end;

function isPerfectRangeSequence(const Range: TDocLinkTabRangeSet): boolean; overload;
var
  rMin, rMax, rCtr: TDocLinkTabRange;
  testrange: TDocLinkTabRangeSet;
begin
  if Range = [] then
    Result := TRUE
  else begin
    rMin := Low(rMin); while not rMin in Range do
      inc(rMin);
    rMax := rMin; while rMax in Range do
      inc(rMax);
    testrange := []; for rCtr := rMin to rMax do
      include(testRange, rCtr);
    Result := testRange = Range;
  end;
end;

function isPerfectRangeSequence(const Title: string): boolean; overload;
var
  RevsRange, ObsesRange: TDocLinkTabRangeSet;
begin
  getRevObsRanges(Title, RevsRange, ObsesRange);
  Result := isPerfectRangeSequence(RevsRange) and isPerfectRangeSequence(ObsesRange)
end;

procedure _SplitObsRev(const SLTabTitled: TStrings; const GotRevs, GotObses: TStrings);
const
  CIDLen2BCmp = length(_ID_);
  DEBUG = FALSE;
var
  i, xr, xo, k: integer;
  S, sid, sn: string;
  RevsRange, ObsesRange: TDocLinkTabRangeSet;
  Delimiter: char;
begin
  GotRevs.Clear; GotObses.Clear;
  with SLTabTitled do
    while trimStr(Strings[Count - 1]) = '' do
      delete(Count - 1);
  if (SLTabTitled.Count > 2) and (Copy(SLTabTitled[0], 1, 3) = _ID_) then begin
    Delimiter := getRevObsRanges(SLTabTitled[0], RevsRange, ObsesRange);
    begin
      for i := 1 to SLtabTitled.Count - 1 do begin
        S := SLTabTitled[i];
        xr := -1; xo := -1;
        sid := WordAtIndex(1, S, Delimiter);
        for k := 2 to WordCount(S, Delimiter) do begin
          sn := WordAtIndex(k, S, Delimiter);
          if (sn <> '') and (intOf(sn) > 0) then begin
            if k in RevsRange then begin
              if xr < 0 then
                xr := GotRevs.add(sid);
              GotRevs[xr] := GotRevs[xr] + Delimiter + sn;
            end
            else if k in ObsesRange then begin
              if xo < 0 then
                xo := GotObses.add(sid);
              GotObses[xo] := GotObses[xo] + Delimiter + sn;
            end
            else
              ;
          end;
        end;
      end;
    end;
  end;
end;

function internalExtractRevisionList(const RevisionFilename: string;
  const Reves, Obses, Reved, Obsed: TStrings; const packzed: boolean): boolean; overload;
const
  _I_ = 'I';
  _0_ = '0';
  fmOpenRead = 0;
  fmShareDenyNone = 0;
var
  p, sz: integer;
  S: string;
  fs: TfileStream;
  SLRevObses, SLRevObsed: TStringList;
begin
  S := '';
  Result := FALSE;
  if packzed then
    S := fileCprX.UnpackedStringOfFile(RevisionFileName, DefaultZipPassword)
  else begin
    fs := TFileStream.Create(RevisionFileName, fmOpenRead or fmShareDenyNone);
    try
      sz := fs.size;
      SetLength(S, sz);
      fs.position := 0;
      fs.read(S[1], sz);
    finally
      fs.Free;
    end;
  end;
  if Copy(S, 1, 3) = _ID_ then begin
    p := ChPos.CharPos(^j, S);
    if p > 0 then
      p := ChPos.CharPos(_I_, S, p);
    if (p > 0) and (Copy(S, p, 3) = _ID_) then begin
      SLRevObses := TStringList.Create; SLRevObsed := TStringList.Create;
      try
        SLRevObses.Text := Copy(S, 1, p - 1);
        SLRevObsed.Text := Copy(S, p, length(S));

        _SplitObsRev(SLRevObses, Reves, Obses);
        _SplitObsRev(SLRevObsed, Reved, Obsed);
      finally
        SLRevObses.Free; SLRevObsed.Free;
      end;
    end;
  end;
end;

const
  _DefaultRevisionFilename_ = '_DocLink' + ext_tab;

  // function RevisionIDTabFilename(const packzed: boolean): string;
  // begin
  //   Result := _RevisionFilename;
  //   if packzed then Result := ChangeFileExt(Result, ext_zx); // SysUtils
  // end;

function ExtractRevListBySection(const got1Reves, got2Obses, got3Reved, got4Obsed: TObject): boolean; overload;
var
  fnRevision, basename: string;
  packexist: boolean;
  Reves, Obses, Reved, Obsed: TStrings;
begin
  Result := FALSE;
  if (got1Reves is TStrings) and (got2Obses is TStrings) and (got3Reved is TStrings) and (got4Obsed is TStrings) then begin
    Reves := TStrings(got1Reves); Obses := TStrings(got2Obses);
    Reved := TStrings(got3Reved); Obsed := TStrings(got4Obsed);
    Reves.Clear; Obses.Clear; Reved.Clear; Obsed.Clear;
    basename := ChangeFileExt(_DefaultRevisionFilename_, '');
    fnRevision := basename + ext_zx;
    packexist := FileExists(fnRevision);
    if not packexist then
      fnRevision := basename + ext_tab;
    if FileExists(fnRevision) then begin
      Result := internalExtractRevisionList(fnRevision, Reves, Obses, Reved, Obsed, packexist);
    end;
  end
end;

function ExtractRevisionList(const RevObses, RevObsed: TStringList;
  const Obses, Reves, Obsed, Reved: TStrings; const packzed: boolean): boolean; overload;
begin
  Result := FALSE;
end;

function IsValidDocLinkContentList(filename: string; DocType: TDocLinkFileType;
  const HeaderMustBeValid, TitleMustBeValid: boolean): boolean;
const
  MAXLOOKUPLINES = $10;
var
  headers, titles: TStrs;
  SL: TStringList;
begin
  if not (HeaderMustBeValid or TitleMustBeValid) then
    Result := TRUE
  else begin
    Result := FALSE;
    SL := TStringList.Create;
    try
      SL.LoadFromFile(filename);
      GetPossibletHeadersAndTitles(headers, titles, DocType);
      if HeaderMustBeValid then
        Result := LookStrs(SL, headers, 0) = 0;
      if (Result = TRUE) and TitleMustBeValid then
        Result := LookStrs(SL, titles, MAXLOOKUPLINES) > 0;
    finally
      SL.Free;
    end;
  end;
end;

function ValidateCList(SL: TStringList; const ValidHeaders, ValidTitles: TStrs;
  const ReSort, HeaderMustBeValid, TitleMustBeValid: boolean): TheadTit;
// checks for header & title, then REMOVE all non contents,
// results the Last ID Value, NOT the List.Count
// NO. changed again, result is the List.Count
// Changed again, now results THeadTit, along with Validity, also header and fieldTitles

const
  TITLEMAXLOOKUP = $10;
var
  i: integer;
  S: string;
  Ch: Char;
begin
  Result.Valid := FALSE;
  Result.Header := '';
  Result.Title := '';

  with SL do
    for i := Count - 1 downto 0 do
      if trimStr(Strings[i]) = '' then
        delete(i);
  if (SL.Count > 0) and (not HeaderMustBeValid or (LookStrs(SL, ValidHeaders, 0) = 0)) then begin
    i := -1;
    with Result do
      if HeaderMustBeValid then
        header := SL[0]
      else
        ;
    with Result do
      if not TitleMustBeValid then
        Valid := TRUE
      else begin
        i := LookStrs(SL, ValidTitles, TITLEMAXLOOKUP);
        Valid := i >= 0;
        if Valid then
          title := SL[i];
      end;
    if Result.Valid then begin
      with SL do begin
        for i := i downto 0 do
          delete(i);
        for i := Count - 1 downto 0 do begin
          S := trimStr(Strings[i]);
          if (S = '') or not (S[1] in NUMERIC) then
            delete(i);
        end;
        if Count > 0 then begin
          Ch := GetDelimiter(Strings[0]);
          for i := 0 to Count - 1 do
            Strings[i] := trimmed(Strings[i], Ch);
          if ReSort then
            SL.Sort;
        end;
      end;
      Result.Valid := SL.Count > 0;
    end;
  end;
end;

// procedure BuildRevObsIncludeEmptyOnes(const SLTabOnly, RevListContainer, ObsListContainer: TStringList;
//   const RevsRange, ObsesRange: TDocLinkTabRangeSet; const Delimiter: Char);
// const
//   NUMERIC = ['0'..'9'];
//   ARBUFSIZE = high(smallint);
// var
//   i, j, k, n: integer;
//   S, sn, sid: string;
//   sidno: Integer;
//   //IDsRev, IDsObs: TStringList;
//   HighRev, HighObs: integer;
// begin
//   RevListContainer.Clear; ObsListContainer.Clear;
//   RevListContainer.Capacity := high(word);
//   ObsListContainer.Capacity := high(word);
//   with SLTabOnly do begin
//     for i := Count - 1 downto 0 do begin
//       S := Strings[i];
//       S := trimStr(S);
//       if (S = '') or not (S[1] in NUMERIC) then delete(i);
//     end;
//     //IDsRev := TStringList.Create;
//     //IDsObs := TStringList.Create;
//     //try
//     HighRev := RevListContainer.Count - 1;
//     HighObs := ObsListContainer.Count - 1;
//     for i := Count - 1 downto 0 do begin
//       S := Strings[i];
//       n := WordCount(S, Delimiter);
//       if n > 1 then begin
//         sid := WordAtIndex(1, S, Delimiter);
//         sidno := StrToIntDef(sid, 0);
//         for j := 2 to n do begin
//           sn := WordAtIndex(j, S, Delimiter);
//           if StrToIntDef(sn, 0) > 0 then begin
//             if (j in RevsRange) then begin
//               if HighRev < sidno then begin
//                 for k := HighRev + 1 to sidno do
//                   RevListContainer.add({''}intoStr(k, 5));
//                 HighRev := sidno;
//               end;
//               RevListContainer[sidno] := RevListContainer[sidno] + Delimiter + sn;
//             end
//             else if (j in ObsesRange) then begin
//               if HighObs < sidno then begin
//                 for k := HighObs + 1 to sidno do
//                   ObsListContainer.add({''}intoStr(k, 5));
//                 HighObs := sidno;
//               end;
//               ObsListContainer[sidno] := ObsListContainer[sidno] + Delimiter + sn;
//             end;
//           end;
//         end;
//       end;
//     end;
//     //finally
//       //IDsRev.Free; IDSObs.Free;
//     //end;
//     RevListContainer.Sort;
//     ObsListContainer.Sort;
//   end;
// end;
//
// procedure BuildRevObsExcludeTheEmptyOnes(const SLTabOnly, RevListContainer, ObsListContainer: TStringList;
//   const RevsRange, ObsesRange: TDocLinkTabRangeSet; const Delimiter: Char);
//   //excluded the empty ones
// const
//   NUMERIC = ['0'..'9'];
//   ARBUFSIZE = high(smallint);
// var
//   i, j, n: integer;
//   S, sn, sid: string;
//   sidno: Integer;
//   IDsRev, IDsObs: TStringList;
// begin
//   RevListContainer.Clear; ObsListContainer.Clear;
//   with SLTabOnly do begin
//     for i := Count - 1 downto 0 do begin
//       S := Strings[i];
//       S := trimStr(S);
//       if (S = '') or not (S[1] in NUMERIC) then delete(i);
//     end;
//     IDsRev := TStringList.Create;
//     IDsObs := TStringList.Create;
//     try
//       for i := Count - 1 downto 0 do begin
//         S := Strings[i];
//         n := WordCount(S, Delimiter);
//         if n > 1 then begin
//           sid := WordAtIndex(1, S, Delimiter);
//           for j := 2 to n do begin
//             sn := WordAtIndex(j, S, Delimiter);
//             if StrToIntDef(sn, 0) > 0 then begin
//               if (j in RevsRange) then begin
//                 //sidno := RevListContainer.IndexOf(sid);
//                 sidno := IDsRev.IndexOf(sid);
//                 if sidno < 0 then begin
//                   sidno := IDsRev.add(sid);
//                   if sidno <> RevListContainer.add(sid) then begin
//                     raise exception.Create('Rev ID index different!');
//                   //sidno := RevListContainer.add(sid);
//                   end;
//                 end;
//                 RevListContainer[sidno] := RevListContainer[sidno] + Delimiter + sn;
//               end
//               else if (j in ObsesRange) then begin
//                 //sidno := ObsListContainer.IndexOf(sid);
//                 sidno := IDsObs.IndexOf(sid);
//                 if sidno < 0 then begin
//                   sidno := IDsObs.add(sid);
//                   if sidno <> ObsListContainer.add(sid) then begin
//                     raise exception.Create('Obs ID index different!');
//                   //sidno := ObsListContainer.add(sid);
//                   end;
//                 end;
//                 ObsListContainer[sidno] := ObsListContainer[sidno] + Delimiter + sn;
//               end;
//             end;
//           end;
//         end;
//       end;
//     finally
//       IDsRev.Free; IDSObs.Free;
//     end;
//     RevListContainer.Sort;
//     ObsListContainer.Sort;
//   end;
// end;

//procedure GetRevedObsed(const SLTabOnly, GotRevObsedList, GotRevByList, GotObsByList: TStringList;
//  const RevsRange, ObsesRange: TDocLinkTabRangeSet; const Delimiter: Char); overload;
//begin
//end;

//function CombineRevObs(const gotRevObs, Reves, Obses: TStringList): integer;
//var
//  List: TInts;
//begin
//  SetLength(List, 0);
//  gotRevObs.Clear;
//  Result := length(List);
//end;

procedure CombineIDList(const CombinedList, SLTabOnly1, SLTabOnly2: TStrings; const maxID: integer; const delimiter: char = TAB);
// SLTabOnly1 and SLTabOnly2 COULD BE header/titled but WILL BE validated
// and trimmed  (no title/header  no blank item);
  function GetIDListfromSLTab(const SLTab: TStrings; const outIDList: TStringList; const MaxID: integer): integer;
    // SLTabOnly1 COULD BE header/titled but WILL BE validated
    // and trimmed  (no title/header  no blank item);
    // outIDList WILL BE cleared beforewise
    // Result max. WordCount of all items
  var
    i, id, n: integer;
    S, ids: string;
  begin
    Result := 0;
    for i := SLTab.Count - 1 downto 0 do begin
      S := trimStr(SLTab[i]);
      if SLTab[i] <> S then
        SLTab[i] := S;
      if (S = '') or not (S[1] in NUMERIC) then
        SLTab.delete(i)
      else begin
        ids := ChPos.WordAtIndex(1, S, delimiter);
        id := intof(S);
        if (id < 1) or (id > MaxID) then
          SLTab.delete(i)
        else begin
          n := ChPos.WordCount(S, delimiter);
          if n < 2 then
            SLTab.delete(i)
          else if Result < n then
            Result := n;
        end;
      end;
    end;
    outIDList.Clear;
    for i := 0 to SLTab.Count - 1 do begin
      ids := ChPos.WordAtIndex(1, SLTab[i], delimiter);
      outIDList.add(ids);
    end;
  end;

var
  nList1, nList2: TStringList;
  i, ix, k: integer;
  SS, S, ids: string;

const
  MAXIDSLEN = 4096;

begin
  nList1 := TStringList.Create;
  nList2 := TStringList.Create;
  try
    GetIDListfromSLTab(SLTabOnly1, nList1, MaxID);
    GetIDListfromSLTab(SLTabOnly2, nList2, MaxID);
    CombinedList.Clear;
    for i := 0 to nList2.Count - 1 do begin
      ids := nList1[i];
      ix := nList2.IndexOf(ids);
      SS := '';
      if ix >= 0 then begin
        S := SLTabOnly2[ix];
        k := ChPos.CharPos(delimiter, S);
        SS := Copy(S, k, MAXIDSLEN); //including tab/delimiter-prefix
      end;
      CombinedList.add(SLTabOnly1[i] + SS); //including tab/delimiter-prefix
    end;
  finally
    nList1.Free; nList2.Free;
  end;
end;

procedure BuildRevedObsed(const SLTabOnly, GotRevObsedList, GotRevByList, GotObsByList: TStringList;
  const RevsRange, ObsesRange: TDocLinkTabRangeSet; const Delimiter: Char); overload;
//excluded the empty ones

const
  NUMERIC = ['0'..'9'];
  ARBUFSIZE = high(smallint);
  id_ = 'ID';
  rev_ = 'REV';
  obs_ = 'OBS';
var
  i, j, n: integer;
  S, sn, sm, sid: string;
  sidno: Integer;
  IDsRev, IDsObs: TStringList;
  maxRevWords: integer;
  maxObsWords: integer;
  title: string;
begin
  IDsRev := TStringList.Create;
  IDsObs := TStringList.Create;
  //RevList := TStringList.Create;
  //ObsList := TStringList.Create;
  GotRevByList.Clear; GotObsByList.Clear;
  try
    with SLTabOnly do begin
      for i := Count - 1 downto 0 do begin
        S := Strings[i];
        S := trimStr(S);
        if (S = '') or not (S[1] in NUMERIC) then
          delete(i);
      end;

      for i := Count - 1 downto 0 do begin
        S := Strings[i];
        n := WordCount(S, Delimiter);
        if n > 1 then begin
          sid := WordAtIndex(1, S, Delimiter);
          for j := 2 to n do begin
            sn := WordAtIndex(j, S, Delimiter);
            if IntOf(sn) > 0 then begin
              if (j in RevsRange) then begin
                sidno := IDsRev.IndexOf(sn);
                if sidno < 0 then begin
                  sidno := IDsRev.add(sn);
                  if sidno <> GotRevByList.add('' {sid}) then begin
                    //raise exception.Create('Rev ID index different!');
                  end
                end;
                if GotRevByList[sidno] = '' then
                  GotRevByList[sidno] := sid
                else
                  GotRevByList[sidno] := GotRevByList[sidno] + Delimiter + sid;
              end
              else if (j in ObsesRange) then begin
                sidno := IDsObs.IndexOf(sn);
                if sidno < 0 then begin
                  sidno := IDsObs.add(sn);
                  if sidno <> GotObsByList.add('' {sid}) then begin
                    //raise exception.Create('Obs ID index different!');
                  end
                end;
                if GotObsByList[sidno] = '' then
                  GotObsByList[sidno] := sid
                else
                  GotObsByList[sidno] := GotObsByList[sidno] + Delimiter + sid;
              end;
            end;
          end;
        end;
      end;
    end;

    MaxRevWords := WCSortLS(GotRevByList, Delimiter, YES, soAscending);
    MaxObsWords := WCSortLS(GotObsByList, Delimiter, YES, soAscending);

    GotRevObsedList.Clear;
    GotRevObsedList.Capacity := (IDsRev.Count + IDsObs.Count);
    with GotRevByList do
      for i := 0 to Count - 1 do
        GotRevObsedList.add(IDsRev[i]);
    with GotRevObsedList do
      for i := 0 to IDsObs.Count - 1 do
        if IndexOf(IDsObs[i]) < 0 then
          add(IDsObs[i]);
    GotRevObsedList.Sort;

    with GotRevObsedList do
      for i := 0 to Count - 1 do begin
        sid := Strings[i];
        j := IDSRev.IndexOf(sid);
        if j < 0 then
          sn := Delimiter
        else
          sn := GotRevByList[j];
        j := IDSObs.IndexOf(sid);
        if j < 0 then
          sm := ''
        else begin
          sm := GotObsByList[j];
          n := WordCount(sn, Delimiter); // 1. do not change
          sn := sn + Delimiter; // 2. the line order
          if n < MaxRevWords then
            sn := sn + stringofChar(Delimiter, MaxRevWords - n);
        end;

        if (trimmed(sn, Delimiter) = '') and (trimmed(sm, Delimiter) = '') then begin
          //raise exception.Create(error_ + ^j + 'both Rev & Obs are empty');
        end;

        Strings[i] := (sid + Delimiter + sn + sm);
      end;

    with GotRevByList do
      for i := 0 to Count - 1 do
        Strings[i] := IDsRev[i] + Delimiter + Strings[i];
    with GotObsByList do
      for i := 0 to Count - 1 do
        Strings[i] := IDsObs[i] + Delimiter + Strings[i];

    GotRevByList.Sort; GotObsByList.Sort; // DO NOT Sort if still intact (using IDsRev/Obs as index)

    title := ID_;
    for i := 1 to maxRevWords do
      title := title + Delimiter + rev_ + intoStr(i);
    for i := 1 to maxObsWords do
      title := title + Delimiter + obs_ + intoStr(i);

    GotRevObsedList.Insert(0, title);

  finally
    IDsRev.Free; IDSObs.Free;
  end;
end;

function BuildComprehensiveRevisions(const tabfile: string; GotRevesObses, GotRevedObsed: TStringList;
  GotReves, GotObses, GotReved, GotObsed: TStringList): integer; overload;
//all stringlist are result containers
var
  ht: THeadTit;
  headers, titles: TStrs;
  Delimiter: char;
  RevRange, ObsRange: TDocLinkTabRangeSet;
begin
  Result := -1;
  if FileExists(tabfile) then begin
    GotRevesObses.LoadFromFile(tabfile);
    GetPossibletHeadersAndTitles(headers, titles, dlftTab);
    ht := ValidateCList(GotRevesObses, headers, titles, FALSE, FALSE, YES);
    if ht.Valid then begin
      Result := GotRevesObses.Count;
      Delimiter := GetDelimiter(ht.Title);
      getRevObsRanges(ht.Title, RevRange, ObsRange);
      BuildRevedObsed(GotRevesObses, GotRevedObsed, GotReved, GotObsed, RevRange, ObsRange, Delimiter);
      GotRevesObses.Insert(0, ht.Title);
      _SplitObsRev(GotRevesObses, GotReves, GotObses);
    end;
  end;
end;

// const
//   kernel32 = 'kernel32.dll';
//
// function GetFileAttributes(lpFileName: PAnsiChar): integer; stdcall;
//   external kernel32 name 'GetFileAttributesA'; {$EXTERNALSYM GetFileAttributes}
//
// function DirectoryExists(const Filename: string): Boolean;
// const
//   FILE_ATTRIBUTE_DIRECTORY = $00000010;
// var
//   Code: Integer;
// begin
//   Code := GetFileAttributes(PChar(Filename));
//   Result := (Code <> -1) and (FILE_ATTRIBUTE_DIRECTORY and Code <> 0);
// end;

{
function _cWordPos(const Ch: WideChar; const S: ANSIString;
  const StartPos: integer = 1): integer;
asm
  @@Start:
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi
    lea esi, S + StartPos -1
    sub StartPos, S-4; jge @@notfound
  @_Loop:
    cmp ax, [esi]; lea esi, esi +2; je @@found
    add StartPos, 2; jle @_Loop
  @@notfound: mov esi, S
  @@found: sub esi, S; mov eax, esi
  @@end: pop esi
  @@Stop:
end;

function PosCRLF(const S: string; const StartPos: integer = 1): integer;
const
  _CR = ^m; // $0D
  _LF = ^j; // $0A
  _CRLF = ord(_CR) shr 8 or ord(_LF); // $0D0A
begin
  with txSearch.Create(_CR + _LF) do begin
    Result := pos(S, StartPos);
    Free;
  end;
end;

function MACed(const CRLFText: string): string;
// strip LF from CRLF, CRLF to CR only (MAC style)
type
  par = ^tar;
  tar = array[0..0] of Char;
var
  i, j, k, L: integer;
  Buf: Par;
begin
  Result := CRLFText;
  L := Length(CRLFText);
  getMem(Buf, L);
  try
    j := 1; k := 0;
    i := PosCRLF(CRLFText);
    if i > 1 then begin
      repeat
        L := i - j - 1; // ecxluding the last-char
        move(CRLFText[j], Buf^[k], L);
        inc(k, L);
        j := i;
        i := PosCRLF(CRLFText, j + 1);
      until i < 1;
    end;
    if j > 1 then begin
      SetLength(Result, j);
      move(Buf^[0], Result[1], j);
    end;
  finally
    freemem(Buf);
  end;
end;

function UNIXed2(const CRLFText: string): string;
// strip CR from CRLF, CRLF to LF only (unix style)
const
  LF = ^j;
type
  par = ^tar;
  tar = array[0..0] of Char;
var
  i, j, k, L: integer;
  Buf: Par;
begin
  Result := CRLFText;
  L := Length(CRLFText);
  getMem(Buf, L);
  try
    i := PosCRLF(CRLFText);
    if i > 0 then begin
      j := 1; k := 0;
      while i > 0 do begin
        L := i - j;
        move(CRLFText[j], Buf^[k], L);
        inc(k, L); Buf^[k] := ^j; inc(k);
        j := i + 2;
        i := PosCRLF(CRLFText, j);
      end;
      L := length(CRLFText) - j;
      move(CRLFText[j], Buf^[k], L);

      inc(j, L);
      SetLength(Result, j);
      move(Buf^[0], Result[1], j);
    end;
  finally
    freemem(Buf);
  end;
end;
}

function unixed(const CRLFText: string): string;
// strip CR from CRLF, CRLF to LF only (unix style)
type
  par = ^tar;
  tar = array[0..0] of Char;
var
  i, j, k, L: integer;
  Buf: Par;
  S: string;
begin
  Result := '';
  L := Length(CRLFText);
  getMem(Buf, L);
  try
    j := 0; k := 0;
    for i := 1 to ChPos.WordCount(CRLFText, ^m) do begin
      inc(k);
      S := ChPos.WordAtIndex(1, CRLFText, ^m, k);
      L := length(S);
      move(S[1], Buf^[j], L);
      inc(j, L); inc(k, L);
    end;
    if j > 0 then begin
      SetLength(Result, j);
      move(Buf^[0], Result[1], j);
    end;
  finally
    freemem(Buf);
  end;
end;

function SaveXList(const List: TStrings; filename: string; const zipped: boolean): string;
// save and remove CR (Save as UNIX file);
type
  Par = ^Tar;
  Tar = array[0..0] of Char;
var
  i, j, k, L: integer;
  Buf: Par;
  S, Sx: string; bakname, zipname: string;
begin
  Result := '';
  //bakname := Acommon.MakeBackupFilename(filename);
  //List.SaveToFile(filename);
  S := List.Text;
  L := Length(S);
  getMem(Buf, L);
  //j := 0;
  //for i := List.Count - 1 do begin
  //  L := length(List[i]);
  //  move(List[i]
  //
  //end;
  try
    j := 0; k := 0;
    for i := 1 to ChPos.WordCount(S, ^m) do begin
      inc(k);
      Sx := ChPos.WordAtIndex(1, S, ^m, k);
      L := length(Sx);
      move(Sx[1], Buf^[j], L);
      inc(j, L);
      inc(k, L);
    end;
    if j > 0 then begin
      SetLength(S, j);
      move(Buf^[0], S[1], j);
      fDfuncs.WriteStringTo(filename, S, FALSE);
      if not (zipped and fileexists(filename)) then
        zipname := ''
      else begin
        zipname := ChangeFileExt(filename, ext_zip);
        fileCprX.CompressFile(filename, zipname, DefaultZipPassword);
      end;
      if filename <> bakname then
        filename := filename + ^j + bakname;

      Result := filename + ^j + zipname;
    end;
  finally
    FreeMem(Buf);
  end;
end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  - This is THE function
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function ConvertDocLinkTabByMapList(const tabfile: string; const Operation: TDocLinkMapConversion;
  //const CRevObs, GotRevedObsedList, GotRevesList, GotObsesList, GotRevedList, GotObsedList: TStringList;
  const GotExpRList: TObject; const Map1Strings: TObject; const Map2Strings: TObject = nil;
  {const inplaceModification: boolean = FALSE;}const BuildRevsedAndObsed: boolean = TRUE;
  {const BuildCombinedRevObs: boolean = TRUE;}const ZipXList: boolean = FALSE;
  const StoreMap: boolean = FALSE): string; overload;

  function chop(const S: string; tailCutLength: integer = 1): string; begin
    Result := Copy(S, 1, length(S) - tailCutLength);
  end;

  function NewIDOf(const BaseID: integer; const IDsMap: TInts): integer;
  var
    i: integer;
  begin
    Result := -1;
    for i := 0 to high(IDsMap) do
      if IDsMap[i] = BaseID then begin
        Result := i;
        break;
      end;
  end;

var
  tabfilebak: string;

  function StoreIDsMap(const IDsMap: TInts; const isNewToBaseID: boolean): string;
  const
    StorageName: array[boolean] of string = ('_MapBase', '_MapNew');
  var
    i: integer;
    SL: TStringList;
  begin
    Result := error_;
    i := length(IDsMap);
    if i > 1 then begin
      SL := TStringList.Create;
      SL.Clear;
      SL.Capacity := i;
      try
        for i := 0 to i - 1 do
          if IDSMap[i] > 0 then
            SL.add(intoStr(i, 5) + TAB + intoStr(IDsMap[i], 5));
        Result := StorageName[isNewToBaseID] + extractfileext(tabfilebak);
        SL.SaveToFile(Result);

      finally
        SL.Free;
      end;
    end;
  end;

  // from Acommon unit. keep these update!
  // from fDfuncs
  //  function GetBakFilename(const Filename: string; const NewExtension: string = '.';
  //    const CounterDigits: integer = 3; const AutoPrependExtensionWithDot: Boolean = YES): string;
  //  const
  //    DOT = '.';
  //  var
  //    i: Cardinal;
  //    Dir, fn, e, ext: string;
  //  begin
  //    if (NewExtension = '') then ext := ExtractFileExt(Filename)
  //    else begin
  //      ext := NewExtension;
  //      if (ext[1] <> DOT) and AutoPrependExtensionWithDot then ext := DOT + ext;
  //    end;
  //    i := 0;
  //    if CounterDigits < 1 then e := ext else e := ext + intoStr(i, CounterDigits);
  //    Dir := ExtractFilePath(filename);
  //    fn := ExtractFilename(filename);
  //    if FileExists(Dir + fn) then fn := ChangeFileExt(fn, e);
  //    while FileExists(Dir + fn) do begin
  //      fn := ChangeFileExt(fn, ext + IntoStr(i, CounterDigits)); //format('%.1u', [i]));
  //      if i >= high(Cardinal) then ;
  //      //pending: raise exception.Create('too many tries');
  //      inc(i);
  //    end;
  //    Result := fn;
  //  end;
  //
  //
  //  function CreateDirTree(DirTree: string): Boolean;
  //  const
  //    MINLEN = 2;
  //  begin
  //    Result := YES;
  //    if Length(DirTree) = 0 then exit;
  //    //raise Exception.CreateRes(@SCannotCreateDir);
  //    //raise Exception.Create(Err_fCreate);
  //    DirTree := ExcludeTrailingBackslash(DirTree);
  //    if (Length(DirTree) > MINLEN) and not DirectoryExists(DirTree) and (ExtractFilePath(DirTree) <> DirTree) then
  //    // avoid 'xyz:\' problem.
  //      Result := CreateDirTree(ExtractFilePath(DirTree)) and CreateDir(DirTree);
  //  end;
  //
  //  function MakeBackupFilename(const Filename: string; const BackupExtension: string = '';
  //    const BackupSubDir: string = '' {'backup'}): string;
  //  var Dir, DirSub, fname, bakname, _ext: string;
  //  begin
  //    if not FileExists(Filename) then Result := Filename
  //    else begin
  //      fname := ExtractFilename(Filename);
  //      if BackupExtension <> '' then _ext := BackupExtension
  //      else _ext := ExtractFileExt(GetBakFilename(Filename));
  //    //ext := ExtractFileExt(Filename);
  //      Dir := ExtractFileDir(Filename);
  //      if (Dir <> '') and (BackupSubDir <> '') then
  //        DirSub := IncludeTrailingBackslash(Dir) + BackupSubDir
  //      else DirSub := Dir + BackupSubDir;
  //      if (DirSub <> '') then DirSub := IncludeTrailingBackslash(DirSub);
  //      bakname := DirSub + ChangeFileExt(fname, '') + _ext;
  //      if (DirSub <> '') and not DirectoryExists(DirSub) then CreateDirTree(DirSub);
  //      if FileExists(bakname) then DeleteFile(PChar(bakname));
  //      if not FileExists(bakname) then RenameFile(PChar(Filename), bakname);
  //      Result := bakname;
  //    end;
  //  end;

var
  SLMap1, SLMap2, SLTab: TStringList;

  procedure getDocListfromMap2(const DocList: TStrings);
    //var i: integer;
  begin

  end;

const
  isnotatstrings = 'is not a TStrings';

const
  _REV = 'REV';
  _OBS = 'OBS';
  _RevesFilename = '_Revises' + ext_tab;
  _ObsesFilename = '_Obsoletes' + ext_tab;
  _RevNObsesFilename = '_RevNObses' + ext_tab;
  _RevedFilename = '_Revised' + ext_tab;
  _ObsedFilename = '_Obsoleted' + ext_tab;
  _RevNObsedFilename = '_RevNObsed' + ext_tab;
  _RevisionsFilename = _DefaultRevisionFilename_;
  //_XRevObsFilename = '_XRevObs' + ext_tab;
  _XRevObsFilename = EXACDBConsts.XRevObsFileName;
  _Tabfile_in = 'Original Mapped ID saved in: ';
  _RevesFile_in = 'List Revises in: ';
  _ObsesFile_in = 'List Obsoletes in: ';
  _RevedFile_in = 'List RevisedBy in: ';
  _ObsedFile_in = 'List ObsoletedBy in: ';
  _RevesNObsesFile_in = 'Revises-Obsoletes List in: ';
  _RevedNObsedFile_in = 'RevisedBy-ObsoletedBy List in: ';
  _Revisions_in = 'Combined Revision-Obsolescences List in: ';
  _XRevObsFile_in = 'Expanded Revisions List in: ';
  _BackupFile_in = 'Any old files backed up in: OLDNAMES';
  _MapBaseID_in = 'Map to BaseID in file: ';
  _MapNewID_in = 'Map to NewID in file: ';
  _Sep = EXACDBConsts.XRevObsSectionSeparator;

  unknown_cvtabhead = '[Unknown Tabfile header]';
  unknown_cvtabtitle = '[Unknown Tabfile title]';

var
  maxnew: integer;
  Delimiter: char;
  i, n, k: integer;
  id_tab, id_mapped, id_cross: integer;
  S, Sx: string;
  ss, sn, _ext: string;
  RevesRange, ObsesRange: TDocLinkTabRangeSet;
  IDs1NewToBase, IDs2BaseToNew: TInts;
  headers, titles: TStrs;
  ht: THeadTit;
  GotXRevObs: TStringList;
  GotRevedObsedList, GotRevesList, GotObsesList, GotRevByList, GotObsByList: TStringList;

begin
  Result := error_;
  //if not (Map1Strings is TStrings) then begin
  //  //raise exception.Create(Result + ^j + 'map1 ' + isnotatstrings);
  //end;
  //if (Operation = dlmcCross) and not (Map2Strings is TStrings) then begin
  //  //raise exception.Create(Result + ^j + 'map2 ' + isnotatstrings);
  //end;
  SLTab := TStringList.Create;
  SLMap1 := TStringList.Create; SLMap2 := TStringList.Create;
  GotXRevObs := TStringList.Create;
  GotRevesList := TStringList.Create; GotObsesList := TStringList.Create;
  GotRevByList := TStringList.Create; GotObsByList := TStringList.Create;
  try
    with TStrings(Map1Strings) do begin
      SLMap1.Capacity := Count + $10;
      SLMap1.Text := Text;
    end;
    SLMap1.Text := TStrings(Map1Strings).Text;
    if assigned(Map2Strings) then
      with (TStrings(Map2Strings)) do begin
        SLMap2.Capacity := Count + $10;
        SLMap2.Text := Text;
      end
    else begin
      SLMap2.Free;
      SLMap2 := nil;
    end;

    GetPossibletHeadersAndTitles(headers, titles, dlftMap);
    if ValidateCList(SLMap1, headers, titles, FALSE, YES, YES).Valid and
      ((Operation <> dlmcCross) or ValidateCList(SLMap2, headers, titles, FALSE, YES, YES).Valid) then begin
      Result := '';

      tabfilebak := GetBakFilename(tabfile);
      _ext := lowerStr(ExtractFileExt(tabfilebak));

      GetMapByNewID(IDs1NewToBase, SLMap1);
      if (Operation = dlmcCross) then
        GetMapByBaseID(IDs2BaseToNew, SLMap2)
      else
        SetLength(IDs2BaseToNew, 0);
      if StoreMap then begin
        Result := Result + _MapNewID_in + StoreIDsMap(IDs1NewToBase, YES);
        Result := Result + ^j + _MapBaseID_in + StoreIDsMap(IDs2BaseToNew, FALSE) + ^j;
      end;

      SLTab.LoadFromFile(tabfile);
      SLTab.SaveToFile(tabfilebak);
      Result := Result + ^j + _Tabfile_in + tabfilebak + ^j;

      GetPossibletHeadersAndTitles(headers, titles, dlftTab);

      ht := ValidateCList(SLTab, headers, titles, FALSE, FALSE, YES);
      if ht.Valid then begin
        if ht.header = '' then
          ht.Header := unknown_cvtabhead;
        Delimiter := GetDelimiter(ht.Title);
        maxnew := length(IDs1NewToBase);

        for i := 0 to SLTab.Count - 1 do begin
          S := SLTab[i];
          k := WordCount(S, Delimiter);
          Ss := '';
          for n := 1 to k do begin
            sn := WordAtIndex(n, S, Delimiter);
            id_tab := intOf(sn);
            if id_tab > 0 then begin
              case Operation of
                dlmcNewToBase:
                  if id_tab < maxnew then
                    id_mapped := IDs1NewToBase[id_tab]
                  else
                    id_mapped := -1;
                dlmcBaseToNew: id_mapped := NewIDOf(id_tab, IDs1NewToBase);
                dlmcCross:
                  if id_tab >= maxnew then
                    id_mapped := -1
                  else begin
                    id_cross := IDs1NewToBase[id_tab];
                    id_mapped := IDs2BaseToNew[id_cross];
                  end;
              else
                id_mapped := id_tab;
              end;
              Ss := Ss + intoStr(id_mapped, 5);
            end;
            Ss := Ss + Delimiter;
          end;
          SLTab[i] := chop(Ss);
        end;

        SLTab.Insert(0, ht.Title);
        MakeBackupFilename(_RevNObsesFilename, _ext);

        SLTab.SaveToFile(_RevNObsesFilename);
        //Result := Result + ^j + _RevesNObsesFile_in + _RevNObsesFilename + ^j;

        SetLength(IDs1NewToBase, 0);
        SetLength(IDs2BaseToNew, 0);

        _SplitObsRev(SLTab, GotRevesList, GotObsesList);

        MakeBackupFilename(_RevesFilename, _ext);
        MakeBackupFilename(_ObsesFilename, _ext);

        GotRevesList.SaveToFile(_RevesFilename);
        Result := Result + ^j + _RevesFile_in + _RevesFilename;

        GotObsesList.SaveToFile(_ObsesFilename);
        Result := Result + ^j + _ObsesFile_in + _ObsesFilename;

        if BuildRevsedAndObsed then begin
          GotRevedObsedList := TStringList.Create;
          getRevObsRanges(ht.Title, RevesRange, ObsesRange);

          BuildRevedObsed(SLTab, GotRevedObsedList, GotRevByList, GotObsByList, RevesRange, ObsesRange, Delimiter);

          MakeBackupFilename(_RevedFilename, _ext);
          MakeBackupFilename(_ObsedFilename, _ext);
          MakeBackupFilename(_RevNObsedFilename, _ext);
          MakeBackupFilename(_RevisionsFilename, _ext);
          MakeBackupFilename(_XRevObsFilename, _ext);

          GotRevByList.SaveToFile(_RevedFilename);
          Result := Result + ^j + _RevedFile_in + _RevedFilename;

          GotObsByList.SaveToFile(_ObsedFilename);
          Result := Result + ^j + _ObsedFile_in + _ObsedFilename;

          GotRevedObsedList.SaveToFile(_RevNObsedFilename);
          //Result := Result + ^j^j  + _RevedNObsedFile_in + _RevNObsedFilename;

          Result := Result + ^j;
          Result := Result + ^j + _RevesNObsesFile_in + _RevNObsesFilename;
          Result := Result + ^j + _RevedNObsedFile_in + _RevNObsedFilename;
          Result := Result + ^j;

          SLTab.Insert(0, ht.Title);
          SLTab.AddStrings(GotRevedObsedList);
          SLTab.SaveToFile(_RevisionsFilename);
          Result := Result + ^j + _Revisions_in + _RevisionsFilename;

          GotXRevObs.Text :=
            {#1}_Sep + GotRevByList.Text +
          {#2}_Sep + GotObsByList.Text +
          {#3}_Sep + GotRevesList.Text +
          {#4}_Sep + GotObsesList.Text;

          with GotXRevObs do
            for i := Count - 1 downto 0 do
              if (trimStr(Strings[i]) = '') or ((ChPos.Charpos('-', Strings[i]) > 0) and (Strings[i][1] <> _Sep)) then
                delete(i);

          Result := Result + ^j + _XRevObsFile_in;

          if (GotExpRList = nil) or not (GotExpRList is TStrings) then
            Result := Result + SaveXList(GotXRevObs, _XRevObsFilename, ZipXList)
              //else if TStrings(GotExpRList).Count < 1 then begin
          //  Result := Result + SaveXList(GotXRevObs, _XRevObsFilename, ZipXList)
          //end //GotXRevObs.SaveToFile(_XRevObsFilename)
          else begin
            if (TStrings(GotExpRList).Count < 1) and (SLMap2 <> nil) then
              getDocListfromMap2(TStrings(GotExpRList));
            //with (GotExpRList as Tstrings) do begin
            //  // Clear // DONT!
            //  // GotExpRList is NOT cleared, just added with Expanded RevObs TStrings
            //  AddStrings(GotXRevObs);
            //  SaveToFile(_XRevObsFilename);
            //end;
            TStrings(GotExpRList).AddStrings(GotXRevObs);
            Result := Result + SaveXList(GotExpRList as TStrings, _XRevObsFilename, ZipXList)
          end;

          //Result := Result + ^j + _XRevObsFile_in + _XRevObsFilename;
          if ZipXList then begin
            //MakeBackupFilename(
            //dzx.CompressFile(
          end;

          if _ext <> lowerStr(ext_tab) then
            Result := Result + ^j^j  + _BackupFile_in + _ext;
        end;
      end;
    end;
  finally
    GotRevedObsedList.Free;
    GotRevByList.Free; GotObsByList.Free;
    GotRevesList.Free; GotObsesList.Free;
    GotXRevObs.Free;
    SLMap1.Free; SLMap2.Free;
    SLTab.Free;
  end;
{$WARNINGS OFF}
end;
{$WARNINGS ON}

//function ConvertDocLinkTabByMapList(const tabfile: string; const Operation: TDocLinkMapConversion;
//  const Map1Strings: TObject; const Map2Strings: TObject = nil;
//  {const inplaceModification: boolean = FALSE;}const BuildRevedByAndObsedBy: boolean = TRUE;
//  {const BuildCombinedRevObs: boolean = TRUE;}const StoreMap: boolean = FALSE): string; overload;
//var
//  GotExtractedRevObsList: TStringList;
//begin
//  GotExtractedRevObsList := TStringList.Create;
//  try
//    Result := ConvertDocLinkTabByMapList(tabfile, Operation,
//      GotExtractedRevObsList, Map1Strings, Map2Strings, BuildRevedByAndObsedBy);
//  finally
//    GotExtractedRevObsList.Free;
//  end;
//end;

function ConvertDocLinkTabByMapFile(const Operation: TDocLinkMapConversion;
  {const ZipXList: boolean;}const GotExpRList: TObject; const tabfile, mapfile1: string;
  const mapfile2: string; BuildRevedByAndObsedBy, ZipXList, StoreMap: boolean): string; overload;
const
  invalid = 'Invalid ';
var
  SLMap1, SLMap2: TStringList;
begin
  SLMap1 := nil; SLMap2 := nil;
  if not IsValidDocLinkContentList(mapfile1, dlftMap, YES, YES) then begin
    //raise exception.Create(invalid + mapfile1)
  end
  else
    SLMap1 := TStringList.Create;
  //try
  if (Operation <> dlmcCross) then // SLMap2 := nil
  else if not IsValidDocLinkContentList(mapfile2, dlftMap, YES, YES) then begin
    //raise exception.Create(invalid + mapfile2)
  end
  else
    SLMap2 := TStringList.Create;
  SLMap1.LoadFromFile(mapfile1);
  if assigned(SLMap2) then
    SLMap2.LoadFromFile(mapfile2);
  Result := ConvertDocLinkTabByMapList(tabfile, Operation, GotExpRList, SLMap1, SLMap2, BuildRevedByAndObsedBy);
  //finally
  SLMap1.Free; SLMap2.Free;
  //end;
end;

function ProceedDocLinkFile(const tabfile, mapfile1, mapfile2: string;
  const Operation: TDocLinkMapConversion; const GotExpRList: TObject;
  const BuildRevsObses, ZipXList, StoreMap: boolean): string; overload;
begin
  if not fileexists(mapfile1) or not fileexists(tabfile) then
    Result := error_
  else if (Operation = dlmcCross) and ((mapfile2 = '') or not fileexists(mapfile2)) then
    Result := error_
  else
    Result := ConvertDocLinkTabByMapFile(Operation, TStrings(GotExpRList), tabfile, mapfile1, mapfile2, BuildRevsObses, ZipXList, StoreMap);
end;

function ProceedDocLinkFile(const tabfile, mapfile: string;
  const ZipXList: boolean = FALSE; const GotExpRList: TObject = nil): string; overload;
begin
  if not fileexists(mapfile) or not fileexists(tabfile) then
    Result := error_
  else
    Result := ProceedDocLinkFile(tabfile, mapfile, '', dlmcNewToBase, GotExpRList, ZipXList, YES, FALSE);
end;

//function ProceedDocLinkFile(const tabfile, mapfile, dbfile: string; GotExtList: TObject = nil): integer; overload;
//begin
//  result := low(result);
//end;

end.


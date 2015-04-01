unit EXACdbConsts;
interface
uses ACConsts; // ChPos

function DefaultZipPassword: string;

type
  TEXACBASEField = (
    //please-please MUST be sync'ed with physical underlying dataset!
    xbfID, xbfJenis, xbfNomor, xbfTanggal, xbfPerihal, xbfNomorDokumen,
    xbfSeri, xbfLampiran, xbfRef1, xbfRef2, xbfRef3,
    xbfRevises, xbfObsoletes, xbfRevisedBy, xbfObsoletedBy,
    xbfWordSet, xbfRelDemo, xbfRelStd, xbfRelPro, xbfRelEnt, xbfRelBC, xbfFlags,
    xbfBaseID, {xbfPerihalDokumen} xbfTitle, xbfBody //xbfCrossRef
    );

  TTAXESField = (
    //please-please MUST be sync'ed with physical underlying dataset!
    txfID, txfJenis, txfNomor, txfTanggal, txfPerihal, txfNomorDokumen,
    txfSeri, txfLampiran, txfRef1, txfRef2, txfRef3, txfBaseID,
    txfRevises, txfObsoletes, txfRevisedBy, txfObsoletedBy //txfCrossRef
    );

  TWordListField = (wlfID, wlfCount, wlfWord, wlfList, wlfListB);

const
  YES = ACConsts.YES;
  TAB = ACConsts.CHAR_TAB;
  SPACE = ACConsts.CHAR_SPACE;
  COLON = ACConsts.CHAR_COLON;
  COMMA = ACConsts.CHAR_COMMA;
  COMMASPACE = ACConsts.CHAR_COMMA + SPACE;

  fld_ID = 'ID';
  fld_Nomor = 'Nomor';
  fld_NomorDokumen = 'NomorDokumen';
  fld_Jenis = 'Jenis';
  fld_Tanggal = 'Tanggal';
  fld_Perihal = 'Perihal';
  fld_PerihalIndex = 'PerihalIndex';
  fld_Lampiran = 'Lampiran';
  fld_Seri = 'Seri';
  fld_Ref1 = 'Ref1';
  fld_Ref2 = 'Ref2';
  fld_Ref3 = 'Ref3';
  //fld_Ref4 = 'Ref4';
  //fld_Ref5 = 'Ref5';
  //fld_Flag = 'Flag';
  fld_Flags = 'Flags';

  fld_Revisions = 'Revisions';
  fld_Obsolescences = 'Obsolescences';
  fld_Revises = 'Revises';
  fld_RevObs_0 = fld_Revises;
  fld_Obsoletes = 'Obsoletes'; // item 0 is invalid
  fld_RevisedBy = 'RevisedBy'; // item 0 is invalid
  desc_RevisedBy = 'Revised by'; // item 0 is invalid
  fld_ObsoletedBy = 'ObsoletedBy'; // item 0 is invalid
  desc_ObsoletedBy = 'Obsoleted by'; // item 0 is invalid
  fld_WordSet = 'WordSet';
  //fld_ReleaseSet = 'ReleaseSet';
  fld_RelDemo = 'Demo';
  fld_RelStd = 'Std';
  fld_RelPro = 'Pro';
  fld_RelEnt = 'Ent';
  fld_RelBC = 'BC';
  fld_CrossRef = 'CrossRef';

  fld_BaseID = 'BaseID';

  //obsolete: DEFAULT_BytesField_Capacity = 32;
  DEFAULT_fld_RevObs_Capacity = 32;
  DEFAULT_RevObsItemSize = sizeof(WORD);
  fld_RevObs_Size = DEFAULT_fld_RevObs_Capacity * DEFAULT_RevObsItemSize;

  fld_IDS = 'IDS';
  fld_XRef = 'XRef';
  fld_ID_Rev = 'Rev'; //fld_Revises;//'ID_Rev';
  fld_ID_Exp = 'Obs'; //fld_Obsoletes;//'ID_Exp';
  fld_ID_RevBy = 'RevBy'; //fld_RevisedBy;//'ID_Revd';
  fld_ID_ExpBy = 'ObsBy'; //fld_ObsoletedBy;//'ID_Expd';

  fld_taxes_PerihalDokumen = 'PerihalDokumen';
  //fld_Header = 'Header';
  fld_Title = 'Title';
  fld_Body = 'Body';

  fld_Count = 'Count';
  fld_Word = 'Word';
  fld_List = 'List';
  fld_ListB = 'ListB';

  //support tables
  fld_Desc = 'Desc'; //common description
  fld_Mnemonic = 'Mnemonic'; //regClass mnemonic
  fld_Country = 'Country'; //ISO-3166
  fld_A2 = 'A2'; //ISO-3166
  fld_A3 = 'A3'; //ISO-3166

  fld_Perihal_Width_TAXES = 80;
  fld_Perihal_Width_BASE = 240;

const
  ext_tab = '.tab';
  ext_zip = '.ref';
  ext_map = '.map';
  _XMAP_ = 'IndexMap';
  _SectionSeparatorChar_ = #01;
  _LineSeparatorChar_ = ^j;
  //_SectionSeparatorStr_: string[3] = '~~~';
  _IndexMapFilename_ = _XMAP_ + '0000' + ext_map;
  IndexMapFilename = _IndexMapFileName_;
  NomorDokFilename = 'NomorDok' + ext_tab;
  DocAndMapFilename = 'DocMap' + ext_tab;
  _DOCLINKS_ = 'DocLinks';
  XRevObsFileName = _DOCLINKS_ + ext_tab;
  XRevObsZipFileName = _DOCLINKS_ + ext_zip;
  XRevObsSectionSeparator = _SectionSeparatorChar_;
  HEADER_IndexMap = '[ID Conversion Table]';
  HEADER_BaseIndexMap = HEADER_IndexMap;
  HEADER_ReleaseIndexMap = '[Invalid Index Map]'; // invalid base table but accepted as header

  EXACReleaseMDBTAX = 'taxes.mdb';
  //EXACReleasedbCTAX = 'taxes.db';
  EXACReleasedbTAXES = 'taxes.db';
  EXACReleasedbTAXDEMO = 'taxdemo.db';
  EXACReleasedbEXACDATA = 'exacdata.db';
  EXACReleasedbEXACDEMO = 'exacdemo.db';

  EXACReleaseMDBPassword = '-';
  //PARADOXPassword1: string = 'cupcdvum';
  {}PARADOXPassword1: string = 'dvqdewvn';
  //PARADOXPassword2: string = 'jIGGAe';
  {}PARADOXPassword2: string = 'kJHHBf';

  EXACReleaseTAXES = 'taxes';
  EXACReleaseCatalog = 'Catalog';
  EXACReleaseRegClass = 'RegClass';
  EXACReleaseISO3166 = 'ISO-3166';

  EXACReleaseTAXES_db: string = 'taxes.db';
  EXACReleaseCatalog_db: string = 'Catalog.db';
  EXACReleaseRegClass_db: string = 'RegClass.db';
  EXACReleaseISO3166_db: string = 'ISO-3166.db';

  //nomordoknamez = 'DocNewID.bin';

  ZX_SignatureAA: string[2] = #$B8#$38;
  BZ_SignatureAA: string[4] = #$80#$E6#$55#$43;
  BZ_SignatureAA_NotNull: string[8] = #$80#$E6#$55#$43#$AE#$F8#$E4#$BB;

type
  tExacBaseRelease = (ebrDemo, ebrStandard, ebrProfessional, ebrEnterprise, ebrBeaCukai);
  tExacBaseReleases = set of tExacBaseRelease;

const
  EXACReleaseCharDesc: array[tExacBaseRelease] of char = ('D', 'S', 'P', 'E', 'B');
  EXACReleaseShortDesc: array[tExacBaseRelease] of string = (fld_RelDemo, fld_RelStd, fld_RelPro, fld_RelEnt, fld_RelBC);
  EXACReleaseLongDesc: array[tExacBaseRelease] of string = ('Demo', 'Standard', 'Professional', 'Enterprise', 'BeaCukai');

  EXACBaseFieldsName: array[TEXACBASEField] of string = (
    fld_ID, fld_Jenis, fld_Nomor, fld_Tanggal, fld_Perihal, fld_NomorDokumen,
    fld_Seri, fld_Lampiran, fld_Ref1, fld_Ref2, fld_Ref3,
    fld_Revises, fld_Obsoletes, fld_RevisedBy, fld_ObsoletedBy, fld_WordSet,
    {fld_ReleaseSet,}fld_RelDemo, fld_RelStd, fld_RelPro, fld_RelEnt, fld_RelBC,
    fld_Flags, fld_BaseID, {fld_PerihalDokumen,} fld_Title, fld_Body
    );

  TAXESFieldsName: array[TTAXESField] of string = (
    fld_ID, fld_Jenis, fld_Nomor, fld_Tanggal, fld_Perihal, fld_NomorDokumen,
    fld_Seri, fld_Lampiran, fld_Ref1, fld_Ref2, fld_Ref3, fld_BaseID,
    fld_Revises, fld_Obsoletes, fld_RevisedBy, fld_ObsoletedBy
    );

  WordlistFieldNames: array[TWordListField] of string =
  (fld_ID, flD_Count, fld_Word, fld_List, fld_ListB);

type
  TQBLObElement = type word;
  TQBWordList = packed array[0..65535 div sizeof(TQBLObElement) - 1] of TQBLObElement;
  PQBWordList = ^TQBWordList;
  PQWordListB = PQBWordList;

function EXACReleasePassword(const Release: tEXACBaseRelease): string;

implementation

function EXACReleasePassword(const Release: tEXACBaseRelease): string;
begin
  Result := EXACdbConsts.DefaultZipPassword + EXACReleaseShortDesc[Release];
  //if length(Result) < 1 then Result := EXACReleaseLongDesc[Release];
  //Result[1] := EXACReleaseCharDesc[Release];
end;

function DefaultZipPassword: string;
var
  C: cardinal;
const
  Password: string[sizeOf(C)] = '';

begin
  if Password <> '' then
    Result := Password
  else begin
    C := __AAMAGIC0__;
    SetLength(Password, sizeOf(C));
    move(C, Password[1], sizeOf(C));
    Result := Password;
  end;
  //Result := '';
end;

procedure madeuppassword;
var
  i: integer;
begin
  for i := 1 to length(PARADOXPassword1) do
    PARADOXPassword1[i] := char(ord(PARADOXPassword1[i]) - 1);
  for i := 1 to length(PARADOXPassword2) do
    PARADOXPassword2[i] := char(ord(PARADOXPassword2[i]) - 1);
end;

procedure buildFieldsName;
begin
  EXACBaseFieldsName[xbfID] := fld_ID;
  EXACBaseFieldsName[xbfJenis] := fld_Jenis;
  EXACBaseFieldsName[xbfNomor] := fld_Nomor;
  EXACBaseFieldsName[xbfTanggal] := fld_Tanggal;
  EXACBaseFieldsName[xbfPerihal] := fld_Perihal;
  EXACBaseFieldsName[xbfNomorDokumen] := fld_NomorDokumen;
  EXACBaseFieldsName[xbfSeri] := fld_Seri;
  EXACBaseFieldsName[xbfLampiran] := fld_Lampiran;
  EXACBaseFieldsName[xbfRef1] := fld_Ref1;
  EXACBaseFieldsName[xbfRef2] := fld_Ref2;
  EXACBaseFieldsName[xbfRef3] := fld_Ref3;
  EXACBaseFieldsName[xbfRevises] := fld_Revises;
  EXACBaseFieldsName[xbfObsoletes] := fld_Obsoletes;
  EXACBaseFieldsName[xbfRevisedBy] := fld_RevisedBy;
  EXACBaseFieldsName[xbfObsoletedBy] := fld_ObsoletedBy;
  EXACBaseFieldsName[xbfWordSet] := fld_WordSet;
  EXACBaseFieldsName[xbfRelDemo] := fld_RelDemo;
  EXACBaseFieldsName[xbfRelStd] := fld_RelStd;
  EXACBaseFieldsName[xbfRelPro] := fld_RelPro;
  EXACBaseFieldsName[xbfRelEnt] := fld_RelEnt;
  EXACBaseFieldsName[xbfRelBC] := fld_RelBC;
  EXACBaseFieldsName[xbfFlags] := fld_Flags;
  EXACBaseFieldsName[xbfBaseID] := fld_BaseID;
  EXACBaseFieldsName[xbfTitle] := fld_Title;
  EXACBaseFieldsName[xbfBody] := fld_Body;

  TAXESFieldsName[txfID] := fld_ID;
  TAXESFieldsName[txfJenis] := fld_Jenis;
  TAXESFieldsName[txfNomor] := fld_Nomor;
  TAXESFieldsName[txfTanggal] := fld_Tanggal;
  TAXESFieldsName[txfPerihal] := fld_Perihal;
  TAXESFieldsName[txfNomorDokumen] := fld_NomorDokumen;
  TAXESFieldsName[txfSeri] := fld_Seri;
  TAXESFieldsName[txfLampiran] := fld_Lampiran;
  TAXESFieldsName[txfRef1] := fld_Ref1;
  TAXESFieldsName[txfRef2] := fld_Ref2;
  TAXESFieldsName[txfRef3] := fld_Ref3;
  TAXESFieldsName[txfBaseID] := fld_BaseID;
  TAXESFieldsName[txfRevises] := fld_Revises;
  TAXESFieldsName[txfObsoletes] := fld_Obsoletes;
  TAXESFieldsName[txfRevisedBy] := fld_RevisedBy;
  TAXESFieldsName[txfObsoletedBy] := fld_ObsoletedBy;
end;

initialization
  madeuppassword;
  buildFieldsName;

finalization

end.


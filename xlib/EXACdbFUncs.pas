unit EXACdbfuncs;
{.$WEAKPACKAGEUNIT ON}
{$J-} //no-writeableconst
{$R-} //no-rangechecking
{$Q-} //no-overflowchecking
{.$D-}//no-debug
interface
uses EXACdbConsts, Classes, dbTables, ACConsts;

// IDMap Result[x] = EXACRelease.ID
function getIDMap(const dbBase: ttable; const EXACRelease: tExacBaseRelease): TInts; overload;
function getIDMap(const EXACBase: string; const EXACRelease: tExacBaseRelease): TInts; overload;
function IDMaptoString(const IDMap: TInts; const Rel: TEXACBaseRelease): string;

function getIndexMapList(const db: ttable; const List: TStrings;
  const MapHeader: boolean = TRUE): boolean; overload; //const Delimiter: Char = #9); overload;
function getNomorDokList(const db: TTable; const List: TStrings;
  const IDList: boolean = TRUE): boolean; overload; //const Delimiter: Char = #9); overload;
function getDokAndMapList(const db: TTable; const List: TStrings;
  const MapHeader: boolean = TRUE; const IDList: boolean = TRUE): boolean; overload; //const Delimiter: Char = #9); overload;

function getIndexMapList(const TableName: string; const List: TStrings;
  const MapHeader: boolean = TRUE): boolean; overload; //const Delimiter: Char = #9); overload;
function getNomorDokList(const TableName: string; const List: TStrings;
  const IDList: boolean = TRUE): boolean; overload; //const Delimiter: Char = #9); overload;
function getDokAndMapList(const TableName: string; const List: TStrings;
  const MapHeader: boolean = TRUE; const IDList: boolean = TRUE): boolean; overload; //const Delimiter: Char = #9); overload;

function saveNomorDokList(const db: TTable; const IDList: boolean = TRUE;
  const zipped: boolean = FALSE): string; overload; //const Delimiter: Char); overload;
function saveIndexMapList(const db: TTable; const MapHeader: boolean = TRUE;
  const zipped: boolean = FALSE): string; overload; //const Delimiter: Char); overload;
function saveDokAndMapList(const db: TTable; const MapHeader: boolean = TRUE;
  const IDList: boolean = TRUE; const zipped: boolean = FALSE): string; overload; //const Delimiter: Char); overload;

function saveNomorDokList(const TableName: string; const IDList: boolean = TRUE;
  const zipped: boolean = FALSE): string; overload; //const Delimiter: Char); overload;
function saveIndexMapList(const TableName: string; const MapHeader: boolean = TRUE;
  const zipped: boolean = FALSE): string; overload; //const Delimiter: Char); overload;
function saveDokAndMapList(const TableName: string; const MapHeader: boolean = TRUE;
  const IDList: boolean = TRUE; const zipped: boolean = FALSE): string; overload; //const Delimiter: Char); overload;

function isValidEXACBaseTable(const dbtax: TTable): boolean; overload;
function isValidEXACBaseTable(const filename: string): boolean; overload;

function IndexMapFileName(const CurrentDated: boolean = TRUE): string;

function getRelTableDir(const Dir: string; const EXACRelease: TEXACBaseRelease): string;
function getRelTablePath(const Dir: string; const EXACRelease: TEXACBaseRelease): string;
function getdbPath(const db: ttable): string;

procedure DelSecondaryIndexFiles(const dbname: string; const ValOnly: boolean = FALSE);

const
  Delimiter: Char = #9;
const
  SectionSeparator = EXACdbConsts._SectionSeparatorChar_;

implementation
uses db, SysUtils, fDfuncs, Ordinals, ChPos, dzx, fileCprX; //CPrX; //, exceptn;

function isValidEXACBaseTable(const dbtax: TTable): boolean;
var
  f: TEXACBASEField;
begin
  with dbtax do begin
    if not Active then Open;
    Result := TRUE;
    for f := Low(f) to high(f) do
      if findfield(EXACBaseFieldsName[f]) = nil then begin
        Result := FALSE;
        break;
      end;
  end;
end;

function isValidEXACBaseTable(const filename: string): boolean;
var
  table: TTable;
begin
  table := TTable.Create(nil);
  try
    table.TableName := ExpandFileName(filename);
    table.ReadOnly := TRUE;
    Result := isValidEXACBaseTable(table);
  finally
    table.Free;
  end;
end;

function getRelTableDir(const Dir: string; const EXACRelease: TEXACBaseRelease): string;
begin
  Result := Backslashed(Dir) + lowerstr(EXACReleaseShortDesc[EXACRelease]) + '\tables';
end;

function getRelTablePath(const Dir: string; const EXACRelease: TEXACBaseRelease): string;
begin
  Result := Backslashed(Dir) + lowerstr(EXACReleaseShortDesc[EXACRelease]) + '\tables\';
end;

const
  kernel32 = 'kernel32.dll'; user32 = 'user32.dll';
type
  DWORD = longword;

  // function MessageBoxEx(hWnd: integer; Text, Caption: PChar; uType: longword; LanguageID: Word): integer; stdcall;
  //   external user32 name 'MessageBoxExA'; {$EXTERNALSYM MessageBoxEx}
  //
  // function FormatMessage(Flags: DWORD; Source: pointer;
  //   MessageId: DWORD; LanguageId: DWORD; Buffer: PChar;
  //   Size: DWORD; Arguments: Pointer): DWORD; stdcall;
  //   external kernel32 name 'FormatMessageA'; {$EXTERNALSYM FormatMessage}
  //
  // function LocalFree(hMem: integer): integer; stdcall;
  //   external kernel32 name 'LocalFree'; {$EXTERNALSYM LocalFree}
  //
  // const EXCEPTION_NONCONTINUABLE = 1; {$EXTERNALSYM EXCEPTION_NONCONTINUABLE}
  // procedure RaiseException(Code: Cardinal = $DEADF0E; Flags: Cardinal = EXCEPTION_NONCONTINUABLE;
  //   ArgCount: Cardinal = 0; Arguments: pointer = nil); stdcall;
  //   external kernel32 name 'RaiseException'; {$EXTERNALSYM RaiseException}
  //
  // procedure ExitProcess(ExitCode: integer); stdcall; external kernel32 name 'ExitProcess'; {$EXTERNALSYM ExitProcess}
  //
  // function ErrStr(const ErrNo: Cardinal; const ShowErrNo: Boolean = YES;
  //   const AlwaysShowMessage: Boolean = YES): string;
  // const
  //   nomessage = 'Error message is not available';
  // const
  //   FORMAT_MESSAGE_ALLOCATE_BUFFER = $100; //{$EXTERNALSYM FORMAT_MESSAGE_ALLOCATE_BUFFER}
  //   FORMAT_MESSAGE_FROM_STRING = $400; //{$EXTERNALSYM FORMAT_MESSAGE_FROM_STRING}
  //   FORMAT_MESSAGE_FROM_HMODULE = $800; //{$EXTERNALSYM FORMAT_MESSAGE_FROM_HMODULE}
  //   FORMAT_MESSAGE_FROM_SYSTEM = $1000; //{$EXTERNALSYM FORMAT_MESSAGE_FROM_SYSTEM}
  //   FORMAT_MESSAGE_ARGUMENT_ARRAY = $2000; //{$EXTERNALSYM FORMAT_MESSAGE_ARGUMENT_ARRAY}
  // var
  //   buf: pChar;
  // begin
  //   SetLength(Result, FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM {or FORMAT_MESSAGE_FROM_HMODULE} or
  //     FORMAT_MESSAGE_ALLOCATE_BUFFER, nil, ErrNo, 0, @buf, high(Word), nil));
  //   if AlwaysShowMessage and (Result = '') then
  //     Result := nomessage
  //   else
  //     move(buf^, Result[1], length(Result));
  //   if ShowErrNo then
  //     Result := 'Error no. ' + IntoHex(ErrNo, 2) + ' (' + IntoStr(ErrNo) + ')' + ^j^j  + Result;
  //   LocalFree(Cardinal(buf));
  //   //Result := trimStr(Result);
  // end;
  //
  // type
  //   TMsgKind = (mtWarning, mtError, mtInformation, mtConfirmation);
  //
  // function _ShowMsg(const MsgKind: TMsgKind; title, text: string; hOwner: cardinal): word;
  // const
  //   { MessageBox() Flags }
  //   MB_OK = $00000000; // {$EXTERNALSYM MB_OK}
  //   MB_YESNO = $00000004; // {$EXTERNALSYM MB_YESNO}
  //
  //   MB_ICONHAND = $00000010; // {$EXTERNALSYM MB_ICONHAND}
  //   MB_ICONQUESTION = $00000020; // {$EXTERNALSYM MB_ICONQUESTION}
  //   MB_ICONEXCLAMATION = $00000030; // {$EXTERNALSYM MB_ICONEXCLAMATION}
  //   MB_ICONASTERISK = $00000040; // {$EXTERNALSYM MB_ICONASTERISK}
  //   MB_USERICON = $00000080; // {$EXTERNALSYM MB_USERICON}
  //   MB_ICONWARNING = MB_ICONEXCLAMATION; // {$EXTERNALSYM MB_ICONWARNING}
  //   MB_ICONERROR = MB_ICONHAND; // {$EXTERNALSYM MB_ICONERROR}
  //   MB_ICONINFORMATION = MB_ICONASTERISK; // {$EXTERNALSYM MB_ICONINFORMATION}
  //   MB_ICONSTOP = MB_ICONHAND; // {$EXTERNALSYM MB_ICONSTOP}
  //
  //   MB_DEFBUTTON1 = $00000000; // {$EXTERNALSYM MB_DEFBUTTON1}
  //   MB_DEFBUTTON2 = $00000100; // {$EXTERNALSYM MB_DEFBUTTON2}
  //   MB_APPLMODAL = $00000000; // {$EXTERNALSYM MB_APPLMODAL}
  //   MB_SYSTEMMODAL = $00001000; // {$EXTERNALSYM MB_SYSTEMMODAL}
  //   MB_TASKMODAL = $00002000; // {$EXTERNALSYM MB_TASKMODAL}
  //   MB_SETFOREGROUND = $00010000; // {$EXTERNALSYM MB_SETFOREGROUND}
  //   MB_TOPMOST = $00040000; // {$EXTERNALSYM MB_TOPMOST}
  //
  //   Default_mbSet = mb_systemmodal + mb_SetForeGround + mb_TopMost;
  //
  // const
  //   titles: array[TMsgKind] of string[12] = ('Error!', 'Information', 'Confirmation', 'Caution!');
  //   Default_mb = mb_systemmodal + mb_SetForeGround + mb_TopMost;
  //   mbSets: array[TMsgKind] of cardinal = (mb_IconExclamation or mb_DefButton2, mb_IconStop, 0, mb_IconQuestion);
  //   dash = '-';
  // var
  //   mbSet: cardinal;
  // begin
  //   mbSet := Default_mbSet or mbSets[MsgKind];
  //   if MsgKind in [mtWarning, mtConfirmation] then mbSet := mbSet or mb_YesNo;
  //   //if hOwner = 0 then hOwner := CommonHandle;
  //   if title = dash then title := titles[MsgKind];
  //   Result := MessageBoxEx(hOwner, pchar(text), pchar(title), mbSet, 0);
  // end;
  //
  // function ShowMsgError(const text: string; title: string = ''; hOwner: Cardinal = 0): word;
  // begin
  //   Result := _ShowMsg(mtError, title, Text, hOwner);
  // end;
  //
  // function ShowMsgOK(const text: string; title: string = ''; hOwner: Cardinal = 0): word;
  // begin
  //   Result := _ShowMsg(mtInformation, title, Text, hOwner);
  // end;
  //
  // function ConfirmYN(const text: string; title: string = ''; hOwner: Cardinal = 0): word;
  // begin
  //   Result := _ShowMsg(mtConfirmation, title, Text, hOwner);
  // end;
  //
  // function ConfirmCritical(const text: string; title: string = ''; hOwner: Cardinal = 0): word;
  // begin
  //   Result := _ShowMsg(mtWarning, title, Text, hOwner);
  // end;
  //
  // procedure Abort;
  //   function ReturnAddr: Pointer;
  //   asm
  //    // mov eax,[esp + 4] !!! codegen dependant
  //    mov eax, ebp - 4
  //   end;
  //
  // begin //exceptn
  //   raise error.Create('WOW');
  // end;
  //
  // procedure _ErrFileNotFound(const ErrorNumber: integer; const msg: string);
  // const
  //   ERROR_INCORRECT_FUNCTION = 1;
  //   ERROR_FILE_NOT_FOUND = 2;
  //   ERROR_PATH_NOT_FOUND = 3;
  //   ERROR_CANNOT_OPEN_FILE = 4;
  // //var e: error; halt
  // begin
  //   _ShowMsg(mtError, '-', errStr(ERROR_FILE_NOT_FOUND), 0);
  //   SysUtils.Abort;
  //   //e := error.Create('TEEEST');
  //   //asm
  //   //  mov eax, e
  //   //  push eax
  //   //  call System.@RaiseExcept
  //   //end;
  //   //ExitProcess(ERROR_FILE_NOT_FOUND);
  //   //halt(ERROR_FILE_NOT_FOUND);
  //   //RaiseException(ERROR_FILE_NOT_FOUND, 1, 1, PChar(msg));
  // end;

  //var bouw: string;

function CheckFileExists(const filename: string): boolean;
const
  ext_db = '.DB';
begin
  //bouw := extractfileext(filename);
  //if bouw = 'oblag' then exit;
  //bouw := changefileext(filename, ext_DB);
  //if bouw = 'oblag' then exit;
  if filename = '' then
    raise exception.Create('error! filename not specified')
  else if (extractfileext(filename) = '') and fileexists(changefileext(filename, ext_DB)) then
    Result := TRUE
  else if upperCase(fDfuncs.ExtractFileExt(filename)) <> ext_db then
    raise exception.Create('error! file is not a paradox table')
  else if not FileExists(filename) then
    raise exception.Create('file not found!')
  else
    Result := TRUE;
end;

function getIndexMapList(const TableName: string; const List: TStrings;
  const MapHeader: boolean = TRUE): boolean; overload; //const Delimiter: Char); overload;
//const  DEBUG: boolean = FALSE;
const
  NewID = 'NewID';
  BaseID = 'BaseID';
  SortedBy = 'SortedBy:';
  BaseIndexMap = HEADER_IndexMap;
  NonBaseIndexMap = '[Invalid Index Map]';
type
  tints = array of integer;
var
  i, n, idx: integer;
  S: string;
{$IFDEF _DEBUG_}
  idd: integer;
{$ENDIF _DEBUG_}
  //fActive: boolean;
  ints: tints;
  que: TQuery;
  ContinuousID: boolean;
begin
  Result := CheckFileExists(TableName);
  if Result = FALSE then
    exit;
  //fActive := db.Active;
  //with db do if not fActive then Open;
  que := TQuery.Create(nil);
  try
    que.Close;
    que.SQL.Clear;
    que.SQL.add('select ' + fld_ID + ', ' + fld_Tanggal);
    que.SQL.add('from "' + TableName + '"');
    que.SQL.add('order by ' + fld_Tanggal);
    que.SQL.add(', ' + fld_ID); //DO NOT fORGET TO ALWAYS SORT ALSO BY ID!!!
    que.Prepare;

    que.Open;
    idx := que.FieldByName(fld_ID).FieldNo - 1; //fieldno is 1-based
{$IFDEF _DEBUG_}
    idd := que.FieldByName(fld_Tanggal).FieldNo - 1; //fieldno is 1-based
{$ENDIF _DEBUG_}
    List.Clear;

    i := 0;
    SetLength(ints, que.RecordCount);
    que.first;
    with que do
      while not EOF do begin
        n := Fields[idx].AsInteger;
        ints[i] := n;
        inc(i);
        S := intoStr(n, 5) + Delimiter + intoStr(i, 5);
{$IFDEF _DEBUG_}
        {if DEBUG then }S := S + Delimiter + Fields[idd].AsString;
{$ENDIF _DEBUG_}
        List.add(S);
        next;
      end;
    que.Close;

    TStringList(List).Sort;
    ContinuousID := TRUE;
    for i := 0 to high(ints) do begin
      n := ints[i];
      if ContinuousID and (n <> i + 1) then
        ContinuousID := FALSE;
      S := intoStr(i + 1, 5) + Delimiter + intoStr(n, 5);
      List[i] := S + Delimiter + Delimiter + List[i];
    end;

    //    i := 0;
    //    que.first;
    //    with que do
    //      while not EOF do begin
    //        S := intoStr(i + 1, 5) + Delimiter + intoStr(Fields[idx].AsInteger, 5);
    //        List[i] := S + Delimiter + Delimiter + List[i];
    //        next;
    //        inc(i);
    //      end;
    //
    //    que.Close;

    if MapHeader then begin // never executed! debugging purpose only.
      List.Insert(0, NewID + Delimiter + BaseID + Delimiter + Delimiter + BaseID + Delimiter + NewID);
      List.Insert(0, SortedBy + NewID + Delimiter + Delimiter + SortedBy + BaseID);
      List.insert(0, '');
      if ContinuousID then
        List.Insert(0, NonBaseIndexMap);
      List.insert(0, BaseIndexMap);
    end;

    Result := not ContinuousID;
  finally
    que.Free;
  end;
  //with db do if not fActive then Close;
end;

function getNomorDokList(const TableName: string; const List: TStrings;
  const IDList: boolean = TRUE): boolean; overload; //const Delimiter: Char = #9); overload;
const
  //DO NOT fORGET TO ALWAYS SORT ALSO BY ID!!!
  SQLCmd_Select_NOD_DATE = 'select ' + fld_NomorDokumen + ', ' + fld_Tanggal;
  SQLCmd_Select_NOD_DATE_ID = 'select ' + fld_NomorDokumen + ', ' + fld_Tanggal + ', ' + fld_ID;
  //actually we do not need date & id value, they merely for sorting purpose
  SQLCmd_SortBy_DATE_ID = 'order by ' + fld_Tanggal + ', ' + fld_ID;
var
  i, nodx, idx, n: integer;
  que: TQuery;
  S: string;
  ContinuousID: boolean;
begin
  Result := CheckFileExists(TableName);
  if Result = FALSE then
    exit;
  que := TQuery.Create(nil);
  try
    que.SQL.add(SQLCmd_Select_NOD_DATE_ID);
    que.SQL.add('from "' + TableName + '"');
    que.SQL.add(SQLCmd_SortBy_DATE_ID);
    List.Clear;
    i := 0;
    ContinuousID := TRUE;
    que.Prepare;
    que.Open;
    nodx := que.FieldByName(fld_NomorDokumen).FieldNo - 1; //fieldno is 1-based
    idx := que.FieldByName(fld_ID).FieldNo - 1; //fieldno is 1-based
    que.first;
    with que do
      while not EOF do begin
        inc(i);
        n := fields[idx].AsInteger;
        if ContinuousID and (n <> i) then
          ContinuousID := FALSE;
        if not IDList then
          S := ''
            //else S := intoStr(i, 5) + Delimiter; // counter
        else
          S := intoStr(n, 5) + Delimiter; // using original id instead
        S := S + fields[nodx].AsString;
        List.add(S);
        next;
      end;
    Result := not ContinuousID;
  finally
    que.Free;
  end;
end;

function getDokAndMapList(const TableName: string; const List: TStrings;
  const MapHeader: boolean = TRUE; const IDList: boolean = TRUE): boolean; overload; //const Delimiter: Char = #9); overload;
var
  LS: TStringList;
begin
  LS := TStringList.Create;
  try
    Result := getNomorDokList(TableName, List);
    Result := Result and getIndexMapList(TableName, LS, MapHeader);
    List.add(SectionSeparator);
    List.AddStrings(LS);
  finally
    LS.Free;
  end;
end;

function gettablename(const db: TTable): string;
var
  fActive: boolean;
begin
  if not CheckFileExists(db.TableName) then
    exit;
  fActive := db.Active;
  with db do
    if not fActive then
      Open;
  Result := db.TableName;
  with db do
    if not fActive then
      Close;
end;

function getNomorDokList(const db: TTable; const List: TStrings;
  const IDList: boolean = TRUE): boolean; overload; //const Delimiter: Char = #9); overload;
begin
  Result := getNomorDokList(gettablename(db), List);
end;

function getIndexMapList(const db: ttable; const List: TStrings;
  const MapHeader: boolean = TRUE): boolean; overload; //const Delimiter: Char); overload;
begin
  Result := getIndexMapList(gettablename(db), List, MapHeader);
end;

function getDokAndMapList(const db: TTable; const List: TStrings;
  const MapHeader: boolean = TRUE; const IDList: boolean = TRUE): boolean; overload; //const Delimiter: Char); overload;
begin
  Result := getDokAndMapList(gettablename(db), List, MapHeader);
end;

//const kernel32 = 'kernel32.dll';

type
  TSystemTime = record
    wYear: Word;
    wMonth: Word;
    wDayOfWeek: Word;
    wDay: Word;
    wHour: Word;
    wMinute: Word;
    wSecond: Word;
    wMilliseconds: Word;
  end;

procedure GetSystemTime(var SystemTime: TSystemTime); stdcall;
  external kernel32 name 'GetSystemTime'; {$EXTERNALSYM GetSystemTime}

function IndexMapFileName(const CurrentDated: boolean = TRUE): string;
var
  yr, mo: string;
  tm: TSystemTime;
begin

  if not CurrentDated then
    Result := _IndexMapFilename_
  else begin
    GetSystemTime(tm);
    yr := intoStr(tm.wYear mod 100, 2);
    mo := intoStr(tm.wMonth, 2);
    Result := _XMAP_ + yr + mo + ext_map;
  end;
end;

function SaveList(const List: TStrings; filename: string; const zipped: boolean): string;
var
  bakname, zipname: string;
begin
  //bakname := Acommon.MakeBackupFilename(filename);
  List.SaveToFile(filename);
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

function saveNomorDokList(const TableName: string; const IDList: boolean = TRUE;
  const zipped: boolean = FALSE): string; overload; //const Delimiter: Char); overload;
var
  List: TStringList;
begin
  if not CheckFileExists(TableName) then
    exit;
  List := TStringList.Create;
  try
    getNomorDokList(TableName, List, IDList);
    Result := saveList(List, exacdbConsts.NomorDokFilename, zipped);
  finally
    List.Free;
  end;
end;

function saveIndexMapList(const TableName: string; const MapHeader: boolean = TRUE;
  const zipped: boolean = FALSE): string; overload; //const Delimiter: Char); overload;
var
  List: TStringList;
begin
  if not CheckFileExists(TableName) then
    exit;
  List := TStringList.Create;
  try
    getIndexMapList(TableName, List, MapHeader);
    Result := saveList(List, exacdbConsts.IndexMapFilename, zipped);
  finally
    List.Free;
  end;
end;

function saveDokAndMapList(const TableName: string; const MapHeader: boolean = TRUE;
  const IDList: boolean = TRUE; const zipped: boolean = FALSE): string; overload; //const Delimiter: Char); overload;
var
  ListDocMap: TStringList;
begin
  ListDocMap := TStringList.Create;
  try
    getDokAndMapList(TableName, ListDocMap, MapHeader);
    Result := saveList(ListDocMap, exacdbConsts.DocAndMapFilename, zipped);
  finally
    ListDocMap.Free;
  end;
end;

function saveNomorDokList(const db: TTable; const IDList: boolean = TRUE;
  const zipped: boolean = FALSE): string; overload; //const Delimiter: Char); overload;
begin
  Result := saveNomorDokList(gettablename(db), IDList, zipped);
end;

function saveIndexMapList(const db: TTable; const MapHeader: boolean = TRUE;
  const zipped: boolean = FALSE): string; overload; //const Delimiter: Char); overload;
begin
  Result := saveIndexMapList(gettablename(db), MapHeader, zipped);
end;

function saveDokAndMapList(const db: TTable; const MapHeader: boolean = TRUE;
  const IDList: boolean = TRUE; const zipped: boolean = FALSE): string; overload; //const Delimiter: Char); overload;
begin
  Result := saveDokAndMapList(gettablename(db), MapHeader, IDList, zipped);
end;

function getIDMap(const dbBase: ttable; const EXACRelease: tExacBaseRelease): TInts; overload;
var
  fulldbname: string;
begin
  fulldbname := changefileext(dbbase.tablename, '.db');
  fulldbname := expandfilename(fulldbname);
  Result := getIDMap(fulldbname, EXACRelease);
end;

function getIDMap(const EXACBase: string; const EXACRelease: tExacBaseRelease): TInts; overload;
const
  Q0: string = 'select MAX(' + fld_ID + ') from ';
  Q1: string = 'select ' + fld_ID + ', ' + fld_Tanggal + ' from ';
  Q2: string = 'order by ' + fld_Tanggal + ', ' + fld_ID; //DO NOT fORGET TO ALWAYS SORT ALSO BY ID!!!
  QUOTE = '"';
var
  ckfield: string;
  MaxID, Ctr, BaseID: integer;
  quoteddbbasename: string;

begin
  if EXACRelease = ebrDemo then
    ckfield := EXACDBCOnsts.EXACReleaseShortDesc[ebrEnterprise]
  else
    ckfield := EXACDBCOnsts.EXACReleaseShortDesc[EXACRelease];
  with TQuery.Create(nil) do begin
    //DatabaseName := dbBase.DatabaseName;
    quoteddbbasename := QUOTE + EXACBase + QUOTE;

    SQL.Text := Q0 + quoteddbbasename;
    open; first; MaxID := fields[0].AsInteger;
    Close; unprepare;

    setlength(Result, MaxID + 1);
    fillchar(Result[0], length(Result) * sizeof(Result[0]), 0);

    SQL.Text := Q1 + quoteddbbasename;
    SQL.add('where ' + ckfield + ' = TRUE');
    SQL.add(Q2);

    Open;
    Ctr := 1;
    while not EOF do begin
      BaseID := fields[0].AsInteger;
      Result[BaseID] := Ctr;
      next;
      inc(Ctr);
    end;
    Close; Free;
  end;
end;

function IDMaptoString(const IDMap: TInts; const Rel: TEXACBaseRelease): string;
var
  i: integer;
  L: TstringList;
begin
  Result := '';
  L := TStringList.Create;
  try
    L.add(exacdbconsts.EXACReleaseLongDesc[Rel]);
    for i := 0 to high(IDMap) do
      L.add(intoStr(i, 5) + TAB + intoStr(IDMap[i], 5));
    L.add('');
    Result := L.Text;
  finally
    L.Free;
  end;
end;

function getdbPath(const db: ttable): string;
begin
  with db do
    if active and assigned(Database) then
      Result := backSlashed(Database.Directory)
    else if DataBaseName <> '' then
      Result := backSlashed(DatabaseName)
    else
      Result := ExtractFilePath(tablename)
end;

procedure DelSecondaryIndexFiles(const dbname: string; const ValOnly: boolean = FALSE);
var
  full: string;
  fname: string;
  fnoext: string;
  path: string;
begin
  full := ExpandFileName(dbname);
  fname := ExtractFileName(dbname);
  fnoext := changefileext(fname, '');
  path := ExtractFilePath(dbname);
  DeleteFiles(path + fnoext + '*.val');
  if not ValOnly then begin
    DeleteFiles(path + fnoext + '.x*');
    DeleteFiles(path + fnoext + '.y*');
  end;
end;

{procedure showVal(const Field: TField);
var
  S: string;
  ints: TInts;
  i: integer;
  Chs:
begin
  if assigned(Field) then begin
    case Field.DataType of
      ftBytes:
        if Field.FieldName = fld_WordSet then
          frm.CheckWordSetValuesCurrentRecord1.Click
        else begin
          S := '';
          ints := RevObstoInts(Field);
          for i := low(ints) to high(ints) do
            S := S + inttoStr(ints[i]) + ^j;
          showmessage(S);
          if length(ints) > 0 then setlength(ints, 0);
        end;
      ftBLOb: begin
          if Field.FieldName = fld_ListB then begin
            S := '';
            ints := WordsBLObtoInts(Field);
            for i := 0 to high(ints) do
              S := S + intoStr(ints[i]) + ' ';
            S := 'Found ' + intoStr(length(ints)) + ' items:'^j + S;
          end
          else begin
            S := LoadFieldValue(Field);
            S := hexs(@S[1], length(S), ' ');
          end;
          showmessage(S);
        end
    else showmessage(Field.AsString);
    end;
  end;
end;
}

end.


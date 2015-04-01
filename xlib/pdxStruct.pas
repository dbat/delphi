//{$A+,B-,C-,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q+,R+,S+,T-,U-,V+,W-,X+,Y-,Z1}
//{$MINSTACKSIZE $00004000}
//{$MAXSTACKSIZE $00100000}
//{$IMAGEBASE $00400000}
//{$APPTYPE GUI}
// This unit contains all the procedures needed to alter Paradox version level,
//      block size, and strict integrity constraints.

unit pdxStruct;
{$WEAKPACKAGEUNIT ON}

interface

uses
  DBTables;

// Alter table's version level
// Input Example: AlterVersion(Table1, 7);
//procedure AlterVersion(Table: TTable; Version: Byte); overload;
procedure AlterVersion(Table: TTable; Version: Byte; Password: string = ''); overload;

// Alter table's block size
// Input Example: AlterBlockSize(Table1, 4096);
procedure AlterBlockSize(Table: TTable; BlockSize: Integer; Password: string = ''); overload;

// Alter table's strict integrity constraint
// Input Example: AlterStrictIntegrity(Table1, TRUE);
procedure AlterStrictIntegrity(Table: TTable; Strict: Boolean; Password: string = ''); overload;

procedure OpenExclusive(var tabel: ttable; var LastActiveStatus: boolean);

function SetdbPassword(var table: TTable; password: string): Boolean;

procedure PackTable(table: ttable);

implementation

uses
  DB, BDE, fam3Consts, Sysutils, Classes;

const
  // Constants used by EDatabaseError exceptions that are raised during
  //   abnormal termination
  notOpenError = 'Table must be open to complete restructure operation';
  notExclusiveError = 'Table must be opened exclusively to complete restructure operation';
  mustBeParadoxTable = 'Table is not a Paradox table type';

// Calls DbiDoRestructure with the Option to change and the OptData which is
//   the new value of the option.
// Since a database handle is needed and the table cannot be opened when
//   restructuring is done, a new database handle is created and set to the
//   directory where the table resides.

function CharToOem(lpszSrc: PChar; lpszDst: PChar): Longbool; stdcall;
  external 'user32.dll' name 'CharToOemA'; {$EXTERNALSYM CharToOem}

function StrToOem(const AnsiStr: string): string;
begin
  SetLength(result, Length(AnsiStr));
  if Length(result) > 0 then CharToOem(PChar(AnsiStr), PChar(result))
end;

function getdbiHandle(const Table: TTable): hDBIDb;
var
  Props: CurProps;
begin
  // If the table is not opened, raise an error.
  // Need the table open to get the table directory.
  if Table.Active <> True then
    raise EDatabaseError.Create(notOpenError);

  // If the table is not opened exclusively, raise an error.
  // DbiDoRestructure will need exclusive access to the table.
  if Table.Exclusive <> True then
    raise EDatabaseError.Create(notExclusiveError);

  // Get the table properties.
  Check(DbiGetCursorProps(Table.Handle, Props));

  // If the table is not a Paradox type, raise an error.
  // These options only work with Paradox tables.
  if StrComp(Props.szTableType, szPARADOX) <> 0 then
    raise EDatabaseError.Create(mustBeParadoxTable);

  // Get the database handle.
  Check(DbiGetObjFromObj(hDBIObj(Table.Handle), objDATABASE, hDBIObj(Result)));

end;

//------------------------------------
//Example 2: Pack a Paradox or dBASE table.
//This example will pack a Paradox or dBASE table therfore removing already deleted rows in a table. This function will also regenerate all out-of-date indexes (maintained indexes) This example uses the following input:
//PackTable(Table1) // Pack a Paradox or dBASE table
// The table must be opened execlusively before calling this function...
procedure _PackTable(Table: TTable);
var
  Props: CURProps;
  hDb: hDBIDb;
  TableDesc: CRTblDesc;
begin
  // Make sure the table is open exclusively so we can get the db handle...
  if Table.Active = False then
    raise EDatabaseError.Create('Table must be opened to pack');
  if Table.Exclusive = False then
    raise EDatabaseError.Create('Table must be opened exclusively to pack');

  // Get the table properties to determine table type...
  Check(DbiGetCursorProps(Table.Handle, Props));

  // If the table is a Paradox table, you must call DbiDoRestructure...
  if Props.szTableType = szPARADOX then begin
    // Blank out the structure...
    FillChar(TableDesc, sizeof(TableDesc), 0);
    //  Get the database handle from the table's cursor handle...
    Check(DbiGetObjFromObj(hDBIObj(Table.Handle), objDATABASE, hDBIObj(hDb)));
    // Put the table name in the table descriptor...
    StrPCopy(TableDesc.szTblName, Table.TableName);
    // Put the table type in the table descriptor...
    StrPCopy(TableDesc.szTblType, Props.szTableType);
    // Set the Pack option in the table descriptor to TRUE...
    TableDesc.bPack := True;
    // Close the table so the restructure can complete...
    Table.Close;
    // Call DbiDoRestructure...
    Check(DbiDoRestructure(hDb, 1, @TableDesc, nil, nil, nil, FALSE));
  end
  else
    // If the table is a dBASE table, simply call DbiPackTable...
    if Props.szTableType = szDBASE then
    Check(DbiPackTable(Table.DBHandle, Table.Handle, nil, szDBASE, TRUE))
  else
      // Pack only works on PAradox or dBASE; nothing else...
    raise EDatabaseError.Create('Table must be either of Paradox or dBASE ' +
      'type to pack');

  Table.Open;
end;

procedure packtable(Table: ttable);
begin
  table.close;
  table.Exclusive := TRUE;
  table.open;
  _PackTable(Table);
  table.close;
  table.Exclusive := FALSE;
end;

procedure RestructureTable(Table: TTable; const Option, OptData: string; const password: string = ''; const pack: boolean = TRUE);
var
  hDb: hDBIDb;
  TblDesc: CRTblDesc;
  pFDesc: FldDesc;

begin
  hDB := getdbiHandle(table);
  Table.Close;

  // Setup the Table descriptor for DbiDoRestructure
  FillChar(TblDesc, SizeOf(TblDesc), #0);
  with TblDesc do begin
    StrPCopy(szTblName, StrToOem(Table.Tablename));
    //StrCopy(TblDesc.szTblType, szParadox);
    TblDesc.szTblType := szParadox;
    bPack := pack;
    if password <> '' then begin
      bProtected := TRUE;
      StrPCopy(szPassword, StrToOem(password));
    end;
  end;

  // The optional parameters are passed in through the FLDDesc structure.
  // It is possible to change many Options at one time by using a pointer
  // to a FLDDesc (pFLDDesc) and allocating memory for the structure.
  pFDesc.iOffset := 0;
  pFDesc.iLen := Length(OptData) + 1;
  StrPCopy(pFDesc.szName, Option);

  // The changed values of the optional parameters are in a contiguous memory
  // space.  Sonce only one parameter is being used, the OptData variable
  // can be used as a contiguous memory space.
  TblDesc.iOptParams := 1; // Only one optional parameter
  TblDesc.pFldOptParams := @pFDesc;
  TblDesc.pOptData := @OptData[1];
  try
    // Restructure the table with the new parameter.
    Check(DbiDoRestructure(hDb, 1, @TblDesc, nil, nil, nil, False));
  finally
    //Table.Open;
  end;
end;

procedure AlterVersion(Table: TTable; Version: Byte; password: string = ''); overload;
// Setup RestructureTable parameters for changing the table version
begin
  RestructureTable(Table, 'LEVEL', inttoStr(Version), password);
end;

procedure AlterBlockSize(Table: TTable; BlockSize: Integer; Password: string = ''); overload;
// Setup RestructureTable parameters for changing the table block size
begin
  RestructureTable(Table, 'BLOCK SIZE', inttoStr(BlockSize), Password);
end;

procedure AlterStrictIntegrity(Table: TTable; Strict: Boolean; Password: string = ''); overload;
// Setup RestructureTable parameters for changing the table strict integrity
const S: array[boolean] of string[5] = ('FALSE', 'TRUE');
begin
  RestructureTable(Table, 'STRICTINTEGRTY', S[Strict], Password);
end;

function SetdbPassword(var table: TTable; password: string): Boolean;
var
  TblDesc: CRTblDesc;
  hDb: hDBIDb;
begin
  hdb := getdbiHandle(Table);
  Table.Close;

  //GetMem(pTblDesc, sizeof(CRTblDesc));
  FillChar(TblDesc, sizeof(CRTblDesc), 0);
  with TblDesc do begin
    StrPCopy(szTblName, StrToOem(table.tablename));
    szTblType := szParadox;
    bPack := TRUE;
    if password <> '' then begin
      StrPCopy(szPassword, StrToOem(password));
      bProtected := TRUE
    end;
  end;

  Result := DbiDoRestructure(hDb, 1, @TblDesc, nil, nil, nil, FALSE) = DBIERR_NONE;
end;

// From Fam3Tables
// --------------------------------
// uses dbTables, konstan, Classes;
//
// function BDE_AutoIncConvert(db: TTable; const FieldConversion: TFieldConversion): boolean;
// //procedure BDERIntRemove(detail:TFamTable);
// procedure BDE_RIntRemove(const DAT: TFamTable);
// procedure BDE_RIntRemoveAll;
// procedure BDE_RIntSetup(const DAT: TFamTable);
// procedure BDE_RIntSetupAll;
// procedure BDE_ShowRintDesc(Table: TTable; Lines: TStrings);
// procedure BDE_ValueCheck(Tbl: TTable; FieldNo: integer; MinVal, MaxVal,
//   DefVal: pointer; Required: Boolean);
//
// procedure Codec_AddRIntField(Master, Detail: TTable; const RIntName: string; const idxNo: integer);
// procedure Codec_TestAddRI(Master, Detail: TTable; const RIName: string; const idxNo: integer); // ModOp, DelOp: RINTQual);
// //procedure BDERIntSetdb(const detail:TFamTable);
// //procedure BDEAddSlaveRI (slave:ttable; RIName:String);
//
var
  FamTables: array[TFamTable] of TTable;

function BDE_AutoIncConvert(db: TTable; const FieldConversion: TFieldConversion): boolean;
type TRestructStatus = (rsFieldNotFound, rsNothingToDo, rsDoIt);
var
  i: integer;
  hDB: hDBIdb;
  pTableDesc: pCRTblDesc;
  pFldOp: pCROpType; {array of pCROpType}
  pFieldDesc: pFldDesc; {array of pFldDesc}
  CurPrp: CurProps;
  eRestrStatus: TRestructStatus;
  LastActive: boolean;
begin
  with db do begin
    Result := False;
    eRestrStatus := rsFieldNotFound;
    pTableDesc := nil; pFieldDesc := nil; pFldOp := nil;
    LastActive := Active;
    try
      {make sure we have exclusive access and save the dbhandle:}
      if Active and (not Exclusive) then Close;
      if (not Exclusive) then Exclusive := True;
      if (not Active) then Open;
      hDB := DBHandle;

      {preparing data for DBIDoRestructure:}
      Check(DBIGetCursorProps(Handle, CurPrp));
      GetMem(pFieldDesc, CurPrp.iFields * sizeOf(FldDesc));
      Check(DBIGetFieldDescs(Handle, pFieldDesc));

      GetMem(pFldOp, CurPrp.iFields * sizeOf(CROpType));
      FillChar(pFldOp^, CurPrp.iFields * sizeOf(CROpType), 0);

      {step through the fielddesc to find our field:}
      //eRestrStatus:= rsNothingToDo;
      for i := 1 to CurPrp.iFields do begin
        {for input we have to supply serials instead
        of the Pdox ID's returned with DbiGetFieldDescs:}
        pFieldDesc^.iFldNum := i;
          // memo1.lines.Add(pfieldDesc^.szName+'  '+inttostr(pfieldDesc^.iFldType)+
          //' '+inttostr(pfieldDesc^.iSubType));
        if (pFieldDesc^.iFldType = fldINT32) then
          case FieldConversion of
            fxAuto2Int:
              if (pFieldDesc^.iSubType = fldstAUTOINC) then begin
                pFieldDesc^.iSubType := 0;
                pFldOp^ := crModify;
                eRestrStatus := rsDoIt;
              end;
            fxInt2Auto:
              if (pFieldDesc^.iSubType = fldstAUTOINC) then
                eRestrStatus := rsNothingToDo
              else if (pFieldDesc^.iSubType = 0) and (eRestrStatus = rsFieldNotFound) then begin
                pFieldDesc^.iSubType := fldstAUTOINC;
                pFldOp^ := crModify;
                eRestrStatus := rsDoIt;
              end;
          else {case};
          end;
        inc(pFieldDesc);
        inc(pFldOp);
      end; {for}

      {readjust array pointer:}
      dec(pFieldDesc, CurPrp.iFields);
      dec(pFldOp, CurPrp.iFields);

      if eRestrStatus = rsDoIt then begin
        GetMem(pTableDesc, sizeOf(CRTblDesc));
        FillChar(pTableDesc^, SizeOf(CRTblDesc), 0);
        StrPCopy(pTableDesc^.szTblName, StrToOem(TableName));
        {StrPCopy(pTableDesc^.szTblType,szPARADOX); {}
        pTableDesc^.szTblType := CurPrp.szTableType;
        pTableDesc^.iFldCount := CurPrp.iFields;
        pTableDesc^.pecrFldOp := pFldOp;
        pTableDesc^.pfldDesc := pFieldDesc;
        Close;
        Check(DbiDoRestructure(hDB, 1, pTableDesc, nil, nil, nil, False));
      end;

    finally
      if pTableDesc <> nil then FreeMem(pTableDesc, sizeOf(CRTblDesc));
      if pFldOp <> nil then FreeMem(pFldOp, CurPrp.iFields * sizeOf(CROpType));
      if pFieldDesc <> nil then FreeMem(pFieldDesc, CurPrp.iFields * sizeOf(FldDesc));
      Close; Exclusive := FALSE; Active := LastActive;
    end; {try with table1}
  end;
  if Result = False then Result := True;
end;

//==================NEW====================

type
  MAXFIELDS = 0..$32;
  TLField = array[MAXFIELDS] of FldDesc;
  TLIndex = array[MAXFIELDS] of IdxDesc;
  TLRInt = array[MAXFIELDS] of RIntDesc;
  TLOption = array[MAXFIELDS] of CROpType;

var mLastAct: boolean = FALSE; sLastAct: Boolean = FALSE;

type TGetFree = (mGet, mFree);

procedure memex(var p: pointer; const size: integer; const gm: TGetFree = mGet); begin
  case gm of
    mGet: begin
        GetMem(p, size);
        FillChar(p^, size, #0);
      end;
    mFree: begin
        FreeMem(p);
        p := nil;
      end;
  else ;
  end;
end;

procedure OpenExclusive(var tabel: ttable; var LastActiveStatus: boolean);
begin
  with tabel do begin
    LastActiveStatus := Active;
    if Active and (not Exclusive) then Close;
    if (not Exclusive) then Exclusive := True;
    if (not Active) then Open;
  end;
end;

procedure BDERIntRemove(detail: TFamTable);
var
  i: integer;
  slave: TTable;
  dbd: CrTblDesc;
  hdb: hDBIdb;
  scp: CurProps;
  LRInt: ^TLRInt;
  LRIntOp: ^TLOption;
  sLastAct: Boolean;
  dt: TFamTable;
begin
  for dt := low(TFamTable) to high(TFamTable) do FamTables[dt].Close;
  LRInt := nil; LRIntOp := nil;
  slave := FamTables[detail];
  try
    OpenExclusive(slave, sLastAct);
    check(dbiGetCursorProps(slave.handle, scp));
    if scp.iRefIntChecks > 0 then begin
      memex(pointer(LRIntOp), scp.iRefIntChecks * sizeof(crOpType), mGet);
      memex(pointer(LRInt), scp.iRefIntChecks * sizeof(RIntDesc), mGet);
      for i := 1 to scp.iRefIntChecks do begin
        check(DbiGetRintDesc(slave.handle, i, @LRInt[i - 1]));
        if LRInt^[i - 1].eType = rintDEPENDENT then
          LRIntOp^[i - 1] := crDROP
        else
          //LRIntOp^[i-1]:=crMODIFY;
      end;
      check(dbiGetObjFromObj(hdbiObj(slave.handle), objDATABASE, hdbiObj(hdb)));
      slave.Close;

      FillChar(dbd, SizeOf(dbd), #0);
      StrPCopy(dbd.szTblName, StrToOem(slave.Tablename));
      //StrCopy(dbd.szTblType, scp.szTableType);
      dbd.szTblType := scp.szTableType;
      dbd.iRintCount := scp.iRefIntchecks;
      dbd.printDesc := pointer(LRInt);
      dbd.pecrRintOp := pointer(LRIntOp);
      dbd.bPack := TRUE;

      check(dbiDoRestructure(hdb, 1, @dbd, nil, nil, nil, FALSE));
    end;
  finally
    slave.close; slave.exclusive := FALSE; slave.Active := sLastAct;
    if assigned(LRInt) then memex(pointer(LRInt), 0, mFree);

    if assigned(LRIntOp) then memex(pointer(LRIntOp), 0, mFree);
  end;
end;

procedure BDERIntSet(const detail: TFamTable);
var i, r: integer; fn: string; master, slave: TTable;
  dbd: CrTblDesc; hdb: hDBIdb; scp: CurProps;
  LRInt: ^TLRInt; LRIntOp: ^TLOption; LField: ^TLField;
  //LIndex:^TLIndex; mdx:IdxDesc;
  dt: TFamTable; //dir:DBINAME;
begin
  for dt := low(TFamTable) to high(TFamTable) do begin
    FamTables[dt].Close;
    FamTables[dt].Exclusive := TRUE;
  end;
  BDERIntRemove(detail);
  hdb := nil; LRInt := nil; LRIntOp := nil; LField := nil; //LIndex:=nil; //
  master := nil; slave := FamTables[detail];
  try
    OpenExclusive(slave, sLastAct);
    check(dbiGetCursorProps(slave.handle, scp));

    memex(pointer(LField), scp.iFields * sizeof(FldDesc));
    check(DbiGetFieldDescs(slave.handle, pointer(LField)));

    r := scp.iRefIntChecks + nRInts[detail];
    memex(pointer(LRIntOp), r * sizeof(crOpType), mGet);
    memex(pointer(LRInt), r * sizeof(RIntDesc), mGet);

    for i := 0 to scp.iRefIntChecks - 1 do
      check(DbiGetRintDesc(slave.handle, i + 1, @LRInt[i]));

    r := scp.iRefIntChecks;
    for i := 0 to scp.iFields - 1 do begin
      fn := (LField^[i].szName);
      if isRIntField(fn) then begin
        if (pos(fn, RInts_Origin_Person) > 0) then begin
          if detail = dtPerson then begin
            master := nil;
            //master:=FamTables[dtPerson];
          end
          else begin
            master := FamTables[dtPerson];
          end;
        end
        else if (pos(fn, RInts_Origin_Alamat) > 0) then
          master := FamTables[dtAlamat]
        else if (pos(fn, RInts_Origin_Telepon) > 0) then
          master := FamTables[dtTelepon]
        else master := nil;
        //if master=Famtables[detail] then master:=nil;
        if master <> nil then begin
          LRIntOp^[r] := crADD;
          with LRInt^[r] do begin
            iRintNum := r;
            iFldCount := 1;
            eType := rintDEPENDENT;
            strpCopy(szRintName, StrToOem(fn));
            strpCopy(szTblName, StrToOem(master.TableName));
            aiThisTabFld[0] := LField^[i].iFldnum;
            aiOthTabFld[0] := 1;
            inc(r);
            if master = FamTables[detail] then begin
              eModOp := rintRESTRICT;
              break;
            end
            else
              eModOp := rintCASCADE;
          end;
        end;
      end;
    end;
    FillChar(dbd, SizeOf(dbd), #0);
    StrPCopy(dbd.szTblName, StrToOem(slave.Tablename));
    //StrCopy(dbd.szTblType, scp.szTableType);
    dbd.szTblType := scp.szTableType;
    dbd.iRintCount := r;
    dbd.printDesc := @LRInt[0]; //pointer(LRInt);
    dbd.pecrRintOp := @LRIntOp[0]; //pointer(LRIntOp);

    dbd.bPack := TRUE;
    if hdb = nil then
      check(dbiGetObjFromObj(hdbiObj(slave.handle), objDATABASE, hdbiObj(hdb)));
    slave.Close; if master <> nil then master.Close;
    check(dbiDoRestructure(hdb, 1, @dbd, nil, nil, nil, FALSE));
  finally
    for dt := low(TFamTable) to high(TFamTable) do begin
      FamTables[dt].Close;
      FamTables[dt].Exclusive := FALSE;
    end;
//    master.open; slave.open;
//    slave.close; if assigned(master) then master.close;
//    slave.exclusive:=FALSE; if assigned(master) then master.exclusive:=FALSE;
//    slave.Active:=sLastAct; //if assigned(master) then master.Active:=mLastAct;
    if assigned(LRInt) then memex(pointer(LRInt), 0, mFree);
    if assigned(LField) then memex(pointer(LField), 0, mFree);
//    if assigned(LIndex) then  memex(pointer(LIndex), 0, mFree);
    if assigned(LRIntOp) then memex(pointer(LRIntOp), 0, mFree);
  end;
end;

procedure CreateRIdp;
begin
end;

procedure CreateRIda;
begin
end;

procedure CreateRIdt;
begin
end;

procedure CreateRIdn;
begin
end;

procedure CreateRIdi;
begin
end;

procedure BDE_RIntRemove(const DAT: TFamTable);
begin
  case DAT of
    dtPerson: BDERIntRemove(DAT);
    dtAlamat: BDERIntRemove(DAT);
    dtTelepon: BDERIntRemove(DAT);
    dtNikah: BDERIntRemove(DAT);
  end;
end;

procedure BDE_RIntRemoveAll;
var dt: TFamTable;
begin
  for dt := low(TFamTable) to high(TFamTable) do
    BDE_RIntRemove(dt);
end;

procedure BDE_RIntSetup(const DAT: TFamTable); begin
  case DAT of
    dtPerson: BDERIntSet(DAT);
    dtAlamat: BDERIntSet(DAT);
    dtTelepon: BDERIntSet(DAT);
    dtNikah: BDERIntSet(DAT);
  end;
end;

procedure BDE_RIntSetupAll;
var dt: TFamTable;
begin
  for dt := low(TFamTable) to high(TFamTable) do
    BDE_RIntSetup(dt);
end;

procedure BDE_ShowRintDesc(Table: TTable; Lines: TStrings);
var
  hCur: hDBICur;
  RIDesc: RINTDesc;
  rslt: DBIResult;
  B: Byte;
  Temp: string;
begin
  // Get a cursor to the RI information...
  Check(DbiOpenRIntList(Table.DBHandle, PChar(Table.TableName), nil, hCur));
  try
    Lines.Clear;
    Check(DbiSetToBegin(hCur));
    rslt := DBIERR_NONE;
    // While there are no errors, get RI information...
    while (rslt = DBIERR_NONE) do begin

      // Get the next RI record...
      rslt := DbiGetNextRecord(hCur, dbiNOLOCK, @RIDesc, nil);
      if (rslt <> DBIERR_EOF) then begin
        // Make sure nothing out of the ordinary happened...
        Check(rslt);
        // Display information...
        Lines.Add('RI Number: ' + IntToStr(RIDesc.iRintNum));
        Lines.Add('RI Name: ' + RIDesc.szRintName);
        case RIDesc.eType of
          rintMASTER: Lines.Add('RI Type: MASTER');

          rintDEPENDENT: Lines.Add('RI Type: DEPENDENT');
        else
          Lines.Add('RI Type: UNKNOWN');
        end;
        Lines.Add('RI Other Table Name: ' + RIDesc.szTblName);
        case RIDesc.eModOp of
          rintRESTRICT: Lines.Add('RI Modify Qualifier: RESTRICT');
          rintCASCADE: Lines.Add('RI Modify Qualifier: CASCADE');
        else
          Lines.Add('RI Modify Qualifier: UNKNOWN');
        end;

        case RIDesc.eDelOp of
          rintRESTRICT: Lines.Add('RI Delete Qualifier: RESTRICT');
          rintCASCADE: Lines.Add('RI Delete Qualifier: CASCADE');
        else
          Lines.Add('RI Delete Qualifier: UNKNOWN');
        end;
        Lines.Add('RI Fields in Linking Key: ' + IntToStr(RIDesc.iFldCount));
        Temp := '';
        for B := 0 to (RIDesc.iFldCount - 1) do
          Temp := Temp + IntToStr(RIDesc.aiThisTabFld[B]) + ', ';

        SetLength(Temp, Length(Temp) - 2);
        Lines.Add('RI Key Field Numbers in Table: ' + Temp);
        Temp := '';
        for B := 0 to RIDesc.iFldCount - 1 do
          Temp := Temp + IntToStr(RIDesc.aiOthTabFld[B]) + ', ';
        SetLength(Temp, Length(Temp) - 2);
        Lines.Add('RI Key Field Numbers in Other Table: ' + Temp);
        Lines.Add('');
      end;
    end;
  finally
    // All information was retrieved, close the in-memory table...

    Check(DbiCloseCursor(hCur));
  end;

end;

procedure Codec_AddRIntField(Master, Detail: TTable; const RIntName: ANSIString; const idxNo: integer);
var
  i: integer; doAddRInt: Boolean;
  LField: ^TLField;
  MasterProps, DetailProps: CURProps;
  hDb: hDBIDb;
  TableDesc: CRTblDesc;
  Op: CROpType;
  RInt: RINTDesc;
  MIndex, DIndex: IDXDesc;
  mLastAct, sLastAct: Boolean;
begin
  OpenExclusive(master, mLastAct);
  OpenExclusive(detail, sLastAct);
  // Make sure the tables are opened with an index and get their descriptors...

  FillChar(DIndex, sizeof(DIndex), 0);
  FillChar(MIndex, sizeof(MIndex), 0);
  Check(DbiGetIndexDesc(Detail.Handle, 0, DIndex));
  Check(DbiGetIndexDesc(Master.Handle, 0, MIndex));

  // Get the table properties to determine table type...
  Check(DbiGetCursorProps(Master.Handle, MasterProps));
  Check(DbiGetCursorProps(Detail.Handle, DetailProps));

  // If the table is not a Paradox table, raise an error...
  // Blank out the structures...
  FillChar(TableDesc, sizeof(TableDesc), 0);
  FillChar(RInt, sizeof(RInt), 0);
  //  Get the database handle from the table's cursor handle...
  Check(DbiGetObjFromObj(hDBIObj(Master.Handle), objDATABASE, hDBIObj(hDb)));
  // Put the table name in the table descriptor...
  StrPCopy(TableDesc.szTblName, StrToOem(Detail.TableName));
  // Put the table type in the table descriptor...
  TableDesc.szTblType := MasterProps.szTableType;
  // Set the operation type...
  LField := nil; Op := crNOOP;
  memex(pointer(LField), DetailProps.iFields * sizeof(FldDesc));
  try
    DbiGetFieldDescs(detail.handle, pointer(LField));
    doAddRInt := FALSE;
    for i := 0 to DetailProps.iFields - 1 do begin
      if StrComp(LField^[i].szName, pChar(RIntName)) = 0 then begin
        doAddRInt := TRUE;
        Op := crADD;
        TableDesc.pecrRintOp := @Op;
        // Set the amount of new RI descriptors...
        TableDesc.iRintCount := 1;
        // Connect the table descriptor to the RI descriptor...
        StrPCopy(RInt.szRintName, StrToOem(RIntName));
        // Do the restructure on the dependent (detail) table...
        RInt.eType := rintDEPENDENT;
        // Add the master table name...
        StrPCopy(RInt.szTblName, StrToOem(Master.TableName));
        // Modify operations will be restricted (this can be changed to rintCASCADE)...
        if master = detail then
          RInt.eModOp := rintRESTRICT
        else
          RInt.eModOp := rintRESTRICT;
//          RInt.eModOp := rintCASCADE;
        // Delete operations will be restricted (NOTE: rintCASCADE will not work)...
        RInt.eDelOp := rintRESTRICT;
        // Only one field in link...
        RInt.iFldCount := 1;
        // If the tables are Paradox, then put the associated field numbers
        // in the descriptor...
        RInt.aiThisTabFld[0] := idxNo; //DIndex.aiKeyFld;
        RInt.aiOthTabFld := MIndex.aiKeyFld;
        //RInt.aiThisTabFld[0]:= LField^[i].iFldNum;
        TableDesc.printDesc := @RInt;
        // Setup the RI descriptor...
        // Put in the name of the RI...
        break;
      end;
    end;
    Master.Close; Detail.Close;
    if doAddRInt then begin
      Check(DbiDoRestructure(hDb, 1, @TableDesc, nil, nil, nil, FALSE));
    end;
  finally
    if LField <> nil then memex(pointer(LField), 0, mFree);
    //Master.Open; Detail.Open;
  end;
end;

procedure Codec_TestAddRI(Master, Detail: TTable; const RIName: ANSIString; const idxNo: integer); // ModOp, DelOp: RINTQual);
var
  MasterProps, DetailProps: CURProps;
  hDb: hDBIDb;
  TableDesc: CRTblDesc;
  Op: CROpType;
  RInt: RINTDesc;
  MIndex, DIndex: IDXDesc;
  MNo, DNo: Word;

begin
  // Make sure the tables are opened with an index and get their descriptors...
  FillChar(DIndex, sizeof(DIndex), 0);
  FillChar(MIndex, sizeof(MIndex), 0);
  Check(DbiGetIndexDesc(Detail.Handle, 0, DIndex));
  Check(DbiGetIndexDesc(Master.Handle, 0, MIndex));

  // Get the table properties to determine table type...
  Check(DbiGetCursorProps(Master.Handle, MasterProps));
  Check(DbiGetCursorProps(Detail.Handle, DetailProps));

  // If the table is not a Paradox table, raise an error...

  // Blank out the structures...
  FillChar(TableDesc, sizeof(TableDesc), 0);
  FillChar(RInt, sizeof(RInt), 0);
  //  Get the database handle from the table's cursor handle...
  Check(DbiGetObjFromObj(hDBIObj(Master.Handle), objDATABASE, hDBIObj(hDb)));
  // Put the table name in the table descriptor...
  StrPCopy(TableDesc.szTblName, StrToOem(Detail.TableName));
  // Put the table type in the table descriptor...
  TableDesc.szTblType := MasterProps.szTableType;
  // Set the operation type...
  Op := crADD;
  TableDesc.pecrRintOp := @Op;
  // Set the amount of new RI descriptors...
  TableDesc.iRintCount := 1;
  // Connect the table descriptor to the RI descriptor...
  TableDesc.printDesc := @RInt;
  // Setup the RI descriptor...
  // Put in the name of the RI...
  StrPCopy(RInt.szRintName, StrToOem(RIName));
  // Do the restructure on the dependent (detail) table...
  RInt.eType := rintDEPENDENT;
  // Add the master table name...
  StrPCopy(RInt.szTblName, StrToOem(Master.TableName));
  // Modify operations will be restricted (this can be changed to rintCASCADE)...
  //RInt.eModOp := ModOp;
  // Delete operations will be restricted (NOTE: rintCASCADE will not work)...
  //RInt.eDelOp := DelOp;
  // Only one field in link...
  RInt.iFldCount := 1;
  // If the tables are Paradox, then put the associated field numbers
  // in the descriptor...
  if (MasterProps.szTableType = szPARADOX) then begin
    //
    // Put the detail field index in the array...
    ///RInt.aiThisTabFld := DIndex.aiKeyFld;
    RInt.aiThisTabFld[0] := idxNo;
    // Put the master field index in the array...
    ///RInt.aiOthTabFld := MIndex.aiKeyFld;
    RInt.aiOthTabFld[0] := 1;
  end;

  // If the tables are dBASE, then put the sequence number in the descriptor...
  if MasterProps.szTableType = szDBASE then begin
    Check(DbiGetIndexSeqNo(Master.Handle, MIndex.szName, MIndex.szTagName, 0, MNo));
    Check(DbiGetIndexSeqNo(Detail.Handle, DIndex.szName, DIndex.szTagName, 0, DNo));
    // Put the detail field index in the array...
    RInt.aiThisTabFld[0] := DNo;
    // Put the master field index in the array...
    RInt.aiOthTabFld[0] := MNo;
  end;

  try
    Master.Close; Detail.Close;
    Check(DbiDoRestructure(hDb, 1, @TableDesc, nil, nil, nil, FALSE));
  finally
    //Master.Open;  Detail.Open;
  end;
end;

procedure BDE_ValueCheck(Tbl: TTable; FieldNo: integer; MinVal, MaxVal,
  DefVal: pointer; Required: Boolean);
var
  hDb: hDbiDb;
  TblDesc: CRTblDesc;
  VChk: pVChkDesc;
  Dir: string;
  NumVChks: Word;
  OpType: CROpType;

begin
  NumVChks := 0;
  SetLength(Dir, dbiMaxNameLen + 1);
  Check(DbiGetDirectory(Tbl.DBHandle, False, PChar(Dir)));
  SetLength(Dir, StrLen(PChar(Dir)));
  VChk := AllocMem(sizeof(VChkDesc));
  try
    FillChar(TblDesc, sizeof(CRTblDesc), #0);

    VChk.iFldNum := FieldNo; //Field.Index + 1;
    Tbl.DisableControls;
    Tbl.Close;
    Check(DbiOpenDatabase(nil, nil, dbiReadWrite, dbiOpenExcl,
      nil, 0, nil, nil, hDb));
    Check(DbiSetDirectory(hDb, PChar(Dir)));
    with VChk^ do begin
      bRequired := Required;
      if MinVal <> nil then begin
        Inc(NumVChks);
        bHasMinVal := True;
        move(MinVal^, aMinVal, sizeof(MinVal^));
      end
      else
        bHasMinVal := False;
      if MaxVal <> nil then begin
        Inc(NumVChks);
        bHasMaxVal := True;
        move(MaxVal^, aMaxVal, sizeof(MaxVal^));
      end
      else
        bHasMaxVal := False;
      if DefVal <> nil then begin
        Inc(NumVChks);
        bHasDefVal := True;
        move(DefVal^, aDefVal, sizeof(DefVal^));
      end
      else
        bHasDefVal := False;

    end;
    TblDesc.iValChkCount := NumVChks;
    TblDesc.pVChkDesc := VChk;
    OpType := crADD;
    TblDesc.pecrValChkOp := @OpType;

    StrPCopy(TblDesc.szTblName, StrToOem(Tbl.TableName));
    //StrCopy(TblDesc.szTblType, szParadox);
    TblDesc.szTblType := szParadox;
    Check(DbiDoRestructure(hDb, 1, @TblDesc, nil, nil, nil, False));
  finally
    Check(DbiCloseDatabase(hDb));
    FreeMem(VChk, sizeof(VChkDesc));
    Tbl.EnableControls;
    //Tbl.Open;
  end;
end;

initialization

end.


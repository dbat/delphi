unit cRevisions;
{$IFDEF EXAC_DEMO}
{$DEFINE EXAC_ENT}
{$ENDIF}

{$IFDEF EXAC_ENT}
{$DEFINE EXAC_PRO}
{$ENDIF}

{$IFDEF EXAC_STD}
{$DEFINE EXACS}
{$ENDIF}

{$IFDEF EXAC_PRO}
{$DEFINE EXACS}
{$ENDIF}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, db,
  StdCtrls, ExtCtrls, OvalBtn, Menus, Ordinals, EllipseBevel, ACConsts;

type

  TExpRevObsSection = (roDocID, roRevisedBy, roObsoletedBy, roRevises, roObsoletes);
  TXRevObsSection = roRevisedBy..roObsoletes;

  //TInts = array of integer;
  //TArInts = array of TInts; //array of array of integer; ~ugly
  //TStrs = array of string;

  TMenuItems = array of TMenuItem;

  //TXRevObsInts = array[TXRevObsSection] of TArInts;

  TfrRevs = class(TForm)
    OvalButton1: TOvalButton;
    OvalButton2: TOvalButton;
    OvalButton3: TOvalButton;
    OvalButton4: TOvalButton;
    OvalButton5: TOvalButton;
    popd: TPopupMenu;
    PopupMenu1: TPopupMenu;
    test11: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Label5Click(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure test11Click(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure OvalButton1Click(Sender: TObject);
    procedure OvalButton2Click(Sender: TObject);
    procedure OvalButton3Click(Sender: TObject);
    procedure OvalButton4Click(Sender: TObject);
    procedure OvalButton5Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure popdPopup(Sender: TObject);
    procedure FormHide(Sender: TObject);
  public
    fDocList: TStrs; //array of string; ~ugly
    fRevBy, fObsBy, fRev, fObs: TArInts; //array of array of integer; ~ugly
    noteAddBookmark: TNotifyEvent;
    JumpShiftEnabled: boolean;
    FollowDocLinkChain: boolean;
    function getPrettyDocNumber(const Index: integer): string; // index is 1-based!

  private
    //fAutoReferesh: boolean;
    OlddbAfterScrolled: TDataSetNotifyEvent;
    fLinkedToDB: boolean;
    fDefaultPos: tPoint;
    //procedure LinkToDB;
    //procedure InitPopUpMenus;
    procedure init;
    procedure OnFormHitTest(var m: TWMNCHitTest); message WM_NCHITTEST;
    procedure Revision_dbAfterScrolled(db: TDataSet);
    procedure RoundeCorner;
    procedure InitOvalButtons;
    //procedure RestoredbScroll;
    procedure setFollowdbScroll(followScroll: Boolean);
    function getDefaultPos: tPoint;
  public
    //property DefaultPos: tPoint read getDeafultPos write setDefaultPos;
    property DefaultPos: tPoint read getDefaultPos;
    property LinkedToDB: boolean read fLinkedToDB write setFollowdbScroll;
{$IFDEF EXACS}private{$ENDIF}
    procedure LoadRevObs;

  private
    function BuildPopUpDocList(const RevTag, ID: integer; const Recursive: boolean = FALSE; ResetState: boolean = FALSE): integer;
    procedure MPopDocListJumpClicked(Sender: TObject);
    procedure MPopDocListShiftJumpClicked(Sender: TObject);
  private
    fCurrentdbPos: integer;
    function InsideOval(const ptX, ptY: integer): boolean;
    procedure XOvaleOnClicked(Sender: TObject);
    function BuildMenuItems(const Owner: TComponent; const section: TXRevObsSection;
      const Index: integer; const Recursive: boolean): TMenuItems;
    procedure getmaxRevObs;
    procedure getmaxRevObsBits;
  public
    GUIEnabled_EnterpriseOnly: boolean; // ENTERPRISE ONLY!
  public
    RecursiveRevObs: boolean;
    function getRevObsDocCount(const section: TXRevObsSection; ID: integer): integer; overload;
    //function getRevObsDocNth(const section: TXRevObsSection; const ID: integer; const Index: integer = 0): string; overload;
    //function getRevObsDoc1st(const section: TXRevObsSection; const ID: integer): string; overload;
    function getRevObsDocAll(const section: TXRevObsSection; const ID: integer; prefix: string = ''; const Delimiter: Char = ^j): string; overload;
    function getRevObsIDs(const section: TXRevObsSection; const ID: integer): TInts; overload;
    function getDocNo(Index: integer): string;
    property DocListItem[Index: integer]: string read getDocNo;
  public
    firstShownPos: TPoint;
    ResetBuildPopUpState: boolean;
    //procedure WMSysCommand_minimize(var msg: TWMSysCommand); message WM_SysCommand;
    procedure HideFromTaskBar;
    procedure ResetPrevState; //switch from recursive-nonrecursive

  private
  end;

var
  frRevs: TfrRevs;
  XRInts: array[TXRevObsSection] of TArInts;

const
  XRCaption: array[TXRevObsSection] of string = (
    'Revised by:', 'Obsoleted by:', 'Revises:', 'Obsoletes:');

const
  DEFAULT_POS_TOP = 68;
  DEFAULT_POS_LEFT = 181;

implementation

{$R *.DFM}
uses
///=============================================
///change with vskin:
///{$IFDEF EXAC_ENT}XPMenu, {$ENDIF EXAC_ENT}
  kbpress, datas, EXACDBConsts, fileCprX, {dzx, } ChPos, ClipBrd, ACommon;

var
  XROvales: array[TXRevObsSection] of TOvalButton;
{$IFDEF EXAC_ENT}
///=============================================
///change with vskin:
///  XPMenu1: TXPMenu;
{$ENDIF EXAC_ENT}
  //XRPopUps: array[TXRevObsSection] of TPopUpMenu;
//function CreateEllipticRgn(
//  nLeftRect: integer;  // x-coordinate of the upper-left corner
//  nTopRect: integer;   // y-coordinate of the upper-left corner
//  nRightRect: integer; // x-coordinate of the lower-right
//  nBottomRect: Integer // y-coordinate of the lower-right corner
//  ): HRGN;

// The SetWindowRgn function sets the window region of a window.
//function SetWindowRgn(
//  hWnd: HWND;      // handle to window whose window region is to be set
//  hRgn: HRGN;      // handle to region
//  bRedraw: Boolean // window redraw flag
//  ): integer;

function TfrRevs.InsideOval(const ptX, ptY: integer): boolean;
const
  pointed: boolean = FALSE;
const
  But5Wi: integer = 16;
const
  But5He: integer = 16;
var
  w, h: integer;
  rx, ry, my: integer;
  fO1, fO2, fO3, fO4, fO5: TPoint;
  procedure pointit; begin
    with OvalButton1, fO1 do begin
      w := width; h := height;
      x := Left; y := top;
      rx := w div 2; ry := h div 2;
      my := y + ry;
    end;
    with OvalButton2, fO2 do begin
      x := Left; y := top;
    end;
    with OvalButton3, fO3 do begin
      x := Left; y := top;
    end;
    with OvalButton4, fO4 do begin
      x := Left; y := top;
    end;
    with OvalButton5, fO5 do begin
      x := Left; y := top;
      But5Wi := width; But5He := Height;
    end;
  end;

const
  ono: cardinal = 0;
  function inOvalX(const fO: tPoint): boolean;
  var
    BtnEllipse: HRgn;
  begin
    BtnEllipse := CreateEllipticRgn(fO.x, fO.y, fO.x + w, fO.y + h);
    Result := PtInRegion(BtnEllipse, ptX, ptY);
    DeleteObject(BtnEllipse);
  end;

  function inOval5(const fO5: tPoint): boolean;
  var
    BtnEllipse: HRgn;
  begin
    BtnEllipse := CreateEllipticRgn(fO5.x, fO5.y, fO5.x + But5Wi, fO5.y + But5He);
    Result := PtInRegion(BtnEllipse, ptX, ptY);
    DeleteObject(BtnEllipse);
  end;

begin
  if not pointed then
    pointit;

  if (ptX <= fO1.x) or (ptY >= fO1.y + h) or (ptY <= fO4.y) {or(ptX >= fO.x + w)} or (ptX >= fO5.x + But5Wi)
    or ((ptX >= fO2.x + w) and (ptX <= fO3.x)) then
    Result := FALSE
  else begin
    Result := inOvalX(fO1) or inOvalX(fO2) or inOvalX(fO3) or inOvalX(fO4) or inOval5(fO5)
  end;
end;

//
//function TfrRevs.OutsideOval(const ptX, ptY: integer): boolean;
//begin
//  Result := FALSE
//end;
//

procedure TfrRevs.OnFormHitTest(var m: TWMNCHitTest);
var
  pt: TPoint;
  C: TControl;
begin
  inherited;
  //with m do if Result = HTCAPTION then Result := HTNOWHERE;
  with m do
    if Result = HTCLIENT then begin
      //if (pt.X <> m.XPos) or (pt.Y <> m.YPos) then begin
      pt.X := m.XPos;
      pt.Y := m.YPos;
      pt := ScreenToClient(pt);
      if not InsideOval(pt.X, pt.Y) then
        Result := HTCAPTION
      else begin
        C := COntrolAtPos(pt, TRUE);
        if (C <> nil) and not C.Enabled then
          Result := HTCAPTION;
      end;
    end;
end;

procedure TfrRevs.FormPaint(Sender: TObject);
begin
  with TForm(Self) do begin
    Canvas.Pen.Color := $2E0E0E0;
    //Canvas.Brush.Color := clRed;
    //Canvas.Brush.Style := bsDiagCross;
    Canvas.RoundRect(1, 1, ClientWidth - 2, ClientHeight - 2, height - 3, width - 3);
    //Canvas.TextOut(3,3, 'embro');
  end;
  inherited;
end;

procedure TfrRevs.RoundeCorner;
var
  rgn: HRGN;
begin
  Borderstyle := bsNone;
  rgn := CreateRoundRectRgn(0, 0, // XY-coordinate of the region's upper-left corner
    ClientWidth, ClientHeight, // XY-coordinate of the region's lower-right corner
    Height, Width); // height/width of ellipse for rounded corners
  SetWindowRgn(Handle, rgn, True);
end;

procedure TfrRevs.MPopDocListJumpClicked(Sender: TObject);
var
  id: integer;
begin
  with TMenuItem(Sender) do begin
    if assigned(noteAddBookmark) then
      noteAddBookmark(Self);
    id := tag;
    //dm.dbtax.RecNo := Tag
    if not dm.dbtax.Locate('ID', id, []) then
      //if not dm.dbtax.Locate(dm.dbtaxBaseID.fieldname, Tag, []) then
      ShowMessage('Warning, document not found. You might have to'^j+
      'click Trace Back or Reset Search beforewise');
  end;
end;

procedure TfrRevs.MPopDocListShiftJumpClicked(Sender: TObject);
begin
  if FollowDocLinkChain
    or (JumpShiftEnabled and KBShift_Pressed) then
    with TMenuItem(Sender) do begin
      if not dm.dbtax.Locate('ID', Tag, []) then begin
        //if not dm.dbtax.Locate(dm.dbtaxBaseID.fieldname, Tag, []) then
            //ShowMessage('Warning! Document not found');
      //if assigned(AddBookmark) then
      //  AddBookmark(Self);
      //dm.dbtax.RecNo := Tag
      end;
    end;
end;

function tfrRevs.getRevObsDocCount(const section: TXRevObsSection; ID: integer): integer;
// result is Length, NOT high value!
begin
  if (ID < length(XRints[section])) and (XRints[section, ID] <> nil) then
    Result := length(XRints[section, ID])
  else
    Result := 0;
end;

function tfrRevs.getPrettyDocNumber(const Index: integer): string; // index is 1-based!
var
  group: string;
begin
  if Index > high(fDocList) then
    Result := ''
  else begin
    Result := fDOcList[index];
    if ((Result = '') or (Result[1] in ['0'..'9', ' ', '-'])) and assigned(dm.LookJenis) then begin
      group := dm.LookJenis.Values[intoStr(Index)];
      group := dm.LookMnemonics.Values[group];
      if group <> '' then
        Result := group + ' ' + Result;
    end;
  end;
end;

//  function tfrRevs.getRevObsDocNth(const section: TXRevObsSection; const ID:
//    integer; const Index: integer = 0): string; //index is 0-based
//  var
//    n, idx: integer;
//    doc, group: string;
//  begin
//    Result := '';
//    n := getRevObsDocCount(section, ID);
//    if Index < n then begin
//      idx := XRints[section, ID, n];
//      doc := fDOcList[idx];
//      if ((doc = '') or (doc[1] in ['0'..'9', ' ', '-'])) and assigned(dm.LookJenis) then begin
//        group := dm.LookJenis.Values[intoStr(Index)];
//        group := dm.LookMnemonics.Values[group];
//        if group <> '' then
//          doc := group + ' ' + doc;
//      end;
//    end;
//  end;
//
//  function tfrRevs.getRevObsDoc1st(const section: TXRevObsSection; const ID: integer): string;
//  begin
//    Result := getRevObsDocNth(section, ID);
//  end;

function tfrRevs.getRevObsDocAll(const section: TXRevObsSection;
  const ID: integer; prefix: string = ''; const Delimiter: Char = ^j): string;
var
  n, idx: integer;
  doc: string; //group: string;
begin
  Result := '';
  n := getRevObsDocCount(section, ID);
  if n > 0 then
    for n := 0 to n - 1 do begin
      idx := XRints[section, ID, n];
      //doc := fDOcList[idx];
      //if ((doc = '') or (doc[1] in ['0'..'9', ' ', '-'])) and assigned(dm.LookJenis) then begin
      //  group := dm.LookJenis.Values[intoStr(idx)];
      //  group := dm.LookMnemonics.Values[group];
      //  if group <> '' then
      //    doc := group + ' ' + doc;
      //end;
      doc := getPrettyDocNumber(idx);
      Result := Result + prefix + doc + Delimiter;
    end;
end;

function tfrRevs.getRevObsIDs(const section: TXRevObsSection; const ID: integer): TInts;
var
  n: integer;
begin
  SetLength(Result, 0);
  if (ID < length(XRints[section])) then
    SetLength(Result, length(XRints[section, ID]));
  for n := 0 to high(Result) do
    Result[n] := XRints[section, ID, n];
end;

function TfrRevs.BuildMenuItems(const Owner: TComponent; const section: TXRevObsSection;
  const Index: integer; const Recursive: boolean): TMenuItems;
var
  n, i: integer;
  m: TMenuItem;
  doc, group: string;
  submenus: TMenuItems;
begin
  SetLength(Result, 0);
  SetLength(submenus, 0);
  n := length(XRints[section]); // the Index must be in-range
  if (Index < n) and (XRints[section, Index] <> nil) then begin
    n := length(XRints[section, Index]); // Ints member of ArInts section
    SetLength(Result, n);
    for n := 0 to n - 1 do begin
      i := XRints[section, Index, n];
      m := TMenuItem.Create(Owner);
      m.Tag := i;
      doc := fDOcList[i];
      if ((doc = '') or (doc[1] in ['0'..'9', ' ', '-'])) and assigned(dm.LookJenis) then begin
        group := dm.LookJenis.Values[intoStr(i)];
        group := dm.LookMnemonics.Values[group];
        if group <> '' then
          doc := group + ' ' + doc;
      end;
      m.Caption := doc;
      Result[n] := m;
      m.OnClick := MPopDocListJumpClicked;
      if Recursive then begin
        submenus := BuildMenuItems(m, section, i, TRUE);
        if submenus <> nil then begin
          m.OnClick := MPopDocListShiftJumpClicked;
          m.add(submenus);
        end;
      end
    end;
  end;
end;

function TfrRevs.BuildPopUpDocList(const RevTag, ID: integer; const Recursive: boolean = FALSE; ResetState: boolean = FALSE): integer;
const
  _INITIAL_RESULT = -1;
  _INITIAL_PREV_R = Low(TXRevObsSection);
  _INITIAL_PREV_IDX = -190969;

  function popheads(const r: TXRevObsSection): TMenuItems;
  var
    m: TMenuItem;
  begin
    SetLength(Result, 2);
    m := TMenuItem.Create(Self);
    m.Caption := XRCaption[r];
    Result[0] := m;
    m := TMenuItem.Create(Self);
    m.Caption := '-';
    Result[1] := m;
  end;

var
  r: TXRevObsSection;
  submenus: TMenuItems;
const
  prev_Result: integer = _INITIAL_RESULT;
  prev_r: TXRevObsSection = _INITIAL_PREV_R;
  prev_Index: integer = _INITIAL_PREV_IDX;
begin
  SetLength(submenus, 0);
  if (RevTag < ord(Low(r))) or (RevTag > ord(high(r))) then
    Result := 0
  else begin
    r := TXRevObsSection(RevTag);
    if ResetState then begin
      prev_Result := _INITIAL_RESULT;
      prev_r := _INITIAL_PREV_R;
      prev_Index := _INITIAL_PREV_IDX;
    end;
    if (prev_r = r) and (prev_Index = fCUrrentdbPos) then
      Result := prev_Result
    else begin
      prev_r := r; prev_Index := fCUrrentdbPos;
{$IFDEF EXAC_ENT}
///=============================================
///change with vskin:
///      XPMenu1.Active := FALSE; //MUST be set to FALSE beforewise then TRUE after creation
{$ENDIF EXAC_ENT}
      submenus := BuildMenuItems(popd, r, ID, Recursive);
      Result := length(submenus); prev_Result := Result;
      if Result > 0 then begin
        popd.items.Clear;
        popd.items.add(popheads(r));
        popd.items.add(submenus);
      end;
{$IFDEF EXAC_ENT}
///=============================================
///change with vskin:
///      XPMenu1.Active := TRUE; //MUST be set to FALSE beforewise then TRUE after creation
{$ENDIF EXAC_ENT}
    end;
  end;
end;

procedure TfrRevs.ResetPrevState; //switch from recursive-nonrecursive
begin
  //BuildPopUpDocList
end;

procedure TfrRevs.XOvaleOnClicked(Sender: TObject);
//const RECURSIVE_REVOBS = TRUE;
var
  pt: TPoint;
begin
  GetCursorPos(pt);
  if BuildPopUpDocList(TControl(Sender).Tag, fCurrentdbPos, RecursiveRevObs, ResetBuildPopUpState) > 0 then begin
    ResetBuildPopUpState := FALSE;
    popd.Popup(pt.X, pt.Y);
  end;
end;

procedure TfrRevs.InitOvalButtons;
  procedure InitO(const O: TOvalButton);
  const
    r: TXRevObsSection = Low(TXRevObsSection);
  begin
    O.Tag := ord(r);
    O.Enabled := FALSE;
    O.OnClick := XOvaleOnClicked;
    XROvales[r] := O;
    if r < high(r) then
      inc(r)
    else
      r := Low(r);
  end;

begin
  with OvalButton1 do begin
    Self.height := height + top * 2;
    Self.width := Left * 3 div 2 + OvalButton5.width + OvalButton5.Left;
  end;
  InitO(OvalButton1);
  InitO(OvalButton2);
  InitO(OvalButton3);
  InitO(OvalButton4);
end;

//procedure TfrRevs.InitPopUpMenus;
//begin
//  // non-need // see buildpopdoc instead
//end;

procedure TfrRevs.init;
begin
  KeyPreview := TRUE;
  BorderStyle := bsSizeToolWin;
  FormStyle := fsStayOnTop;
  InitOvalButtons;
  RoundeCorner;
  fLinkedToDB := FALSE;
end;

procedure TfrRevs.Revision_dbAfterScrolled(db: TDataSet);
var
  id: Integer;
  r: TXRevObsSection;
begin
  //if fieldBaseID = nil then begin
  //  fieldBaseID := db.FindField(fld_BaseID);
  //  if fieldBaseID = nil then
  //    fieldBaseID := db.Fields[0];
  //end;
  if assigned(OlddbAfterScrolled) then
    OlddbAfterScrolled(db);
  if Showing and db.Active then begin
    //id := fieldBaseID.AsInteger;
    id := db.fields[0].AsInteger;
    fCurrentdbPos := id;
    //slow...?
    for r := Low(r) to high(r) do
      XROvales[r].Enabled := (id > 0) and (id < length(XRInts[r])) and
        (XRInts[r, id] <> nil)

  end;
end;

function StringOfFile(const fileName: string): string;
var
  fs: TFileStream;
begin
  fs := TFileStream.Create(filename, fmOpenRead or fmShareDenyNone);
  try
    SetLength(Result, fs.size);
    fs.position := 0;
    fs.read(Result[1], fs.size);
  finally
    fs.Free;
  end;
end;

function TextToStrs(const CRLFText: string; const Delimiter: Char = TAB): TStrs;
// NO CHECKING AT ALL! (intended for release)
// input MUST BE VALID!
// format: ID TAB STRING
//         ID: 00000 will be used as index
const
{$IFDEF PASS_ALL}
  MINDOCLIST_COUNT = 1;
{$ELSE}
  MINDOCLIST_COUNT = 1000;
{$ENDIF}
  INTBLOCKLEN = 5;
  STRBLOCKSTART = INTBLOCKLEN + SizeOf(Char) + 1;
  STRBLOCKLEN = $40;

var
  i, n: integer;
  Line, sn, ss: string;
  List: TStringList;
  Valid: boolean;
begin
  List := TStringList.Create;
  try
    List.Text := trim(CRLFText);
    List.Sort;
    sn := WordAtIndex(1, List[List.Count - 1], Delimiter);
    Valid := (length(sn) = 5) and (sn[1] in ['0'..'9']) and (List.Count > MINDOCLIST_COUNT);
    if Valid then begin

      n := IntOf(sn);

      SetLength(Result, n + 1);
      with List do
        for i := 0 to Count - 1 do begin
          Line := Strings[i];
          //sn := WordAtIndex(1, Line, Delimiter);
          //ss := WordAtIndex(2, Line, Delimiter);
          sn := Copy(Line, 1, INTBLOCKLEN); // 00000
          ss := Copy(Line, STRBLOCKSTART, STRBLOCKLEN); // max doc-num-length = 64
          n := intOf(sn);
          Result[n] := ss;
        end;
    end;
  finally
    List.Free;
  end;
end;

//function TextToArInts(const CRLFText: string; const Delimiter: Char = TAB): TArInts;
//D7FIX: Delimiter IS member property of TStringList!
function TextToArInts(const CRLFText: string; const SubDelimiter: Char = TAB): TArInts;
const
{$IFDEF PASS_ALL}
  MINREVLIST_COUNT = 1;
{$ELSE}
  MINREVLIST_COUNT = 32;
{$ENDIF}
  INTBLOCKLEN = 5;
  STRBLOCKSTART = INTBLOCKLEN + SizeOf(Char) + 1;
  STRBLOCKLEN = $40;
var
  Ctr, Max, wc, k, n, x: integer;
  Line, sn, sk: string;
  List: TStringList;
  Valid: boolean;

begin
  List := TStringList.Create;
  try
    List.Text := trim(CRLFText);
    List.Sort;
    sn := WordAtIndex(1, List[List.Count - 1], SubDelimiter);
    Valid := (length(sn) = 5) and (sn[1] in ['0'..'9']) and (List.Count > MINREVLIST_COUNT);
    if Valid then begin
      Max := IntOf(sn);
      SetLength(Result, Max + 1);
      with List do
        for Ctr := 0 to Count - 1 do begin
          Line := Strings[Ctr];
          //sn := WordAtIndex(1, Line, SubDelimiter);
          //ss := WordAtIndex(2, Line, SubDelimiter);
          sn := Copy(Line, 1, INTBLOCKLEN); // 00000
          n := intOf(sn);
          //wc := ChPos.wordCount(Line, SubDelimiter, STRBLOCKSTART);
          //D7FIX: Delimiter IS member property of TStringList!
          wc := ChPos.wordCount(Line, SubDelimiter, STRBLOCKSTART);
          if wc > 0 then begin
            SetLength(Result[n], wc);
            for k := 1 to wc do begin
              sk := WordAtIndex(k, Line, SubDelimiter, STRBLOCKSTART);
              x := intOf(sk);
              Result[n, k - 1] := x;
            end;
          end;
        end;
    end;
  finally
    List.Free;
  end;
end;
{$I COMPILERS.INC}

function ArIntsToText(const ArInts: TArInts; const Delimiter: Char = TAB): string;
begin

end;

procedure TfrRevs.LoadRevObs;
const
  XRevobs: string = EXACDBConsts.XRevObsFileName;
  XRevobZ: string = EXACDBConsts.XRevObsZipFileName;
  Sep = EXACDBConsts.XRevObsSectionSeparator;
  Loaded: boolean = FALSE;
const
  Dx =
{$IFDEF DELPHI_6_UP} 'D7'
{$ELSE} 'D5'
{$ENDIF}
  ;
var
  Path, S, SDoc, SRevBy, SObsBy, SRev, SObs: string;
  L: TStringList;
begin
{$IFDEF EXACS}
  Path := IncludeTrailingBackslash(dm.pPATHTABLES);
{$ELSE}
  Path := ExtractFilePath(Application.ExeName);
{$ENDIF EXACS}
  if fileexists(Path + XRevobZ) then
    S := fileCprX.UnpackedStringOfFile(Path + XRevobZ, exacdbConsts.DefaultZipPassword)
  else if fileexists(Path + XRevobs) then
    S := StringOfFile(Path + XRevobZ)
  else
    raise exception.Create('Error! Missing DocLinks file');

  L := TStringList.Create;

  SDoc := ChPos.WordAtIndex(1, S, Sep);
  SRevBy := ChPos.WordAtIndex(2, S, Sep);
  SObsBy := ChPos.WordAtIndex(3, S, Sep);
  SRev := ChPos.WordAtIndex(4, S, Sep);
  SObs := ChPos.WordAtIndex(5, S, Sep);
{$IFDEF PASS_ALL}
  L.Text := SDoc; L.SaveToFile(Dx + 'rv_Doc.txt');
  L.Text := SRev; L.SaveToFile(Dx + 'rv_Rev.txt');
  L.Text := SRevBy; L.SaveToFile(Dx + 'rv_RevBy.txt');
  L.Text := SObsBy; L.SaveToFile(Dx + 'rv_ObsBy.txt');
  L.Text := SObs; L.SaveToFile(Dx + 'rv_Obs.txt');
{$ENDIF PASS_ALL}
  L.Free;

  fDocList := TextToStrs(SDoc);
  fRevBy := TextToArInts(SRevBy);
  fObsBy := TextToArInts(SObsBy);
  fRev := TextToArInts(SRev);
  fObs := TextToArInts(SObs);

  //TExpRevObsSection = (roDocList, roRevisedBy, roObsoletedBy, roRevises, roObsoletes);
  XRInts[roRevisedBy] := fRevBy;
  XRInts[roObsoletedBy] := fObsBy;
  XRInts[roRevises] := fRev;
  XRInts[roObsoletes] := fObs;
end;

procedure TfrRevs.setFollowdbScroll(followScroll: Boolean);
begin
  if not GUIEnabled_EnterpriseOnly then exit;
  if (fLinkedToDB <> followScroll) and dm.dbtax.Active then begin
    if followScroll then begin
      OlddbAfterScrolled := dm.dbtax.AfterScroll;
      dm.dbtax.AfterScroll := Revision_dbAfterScrolled;
      Revision_dbAfterScrolled(dm.dbtax);
    end
    else begin
      dm.dbtax.AfterScroll := OlddbAfterScrolled;
      OlddbAfterScrolled := nil;
    end;
    fLinkedToDB := followScroll;
  end;
end;

procedure TfrRevs.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  LinkedToDB := FALSE;
end;

procedure TfrRevs.FormHide(Sender: TObject);
begin
  LinkedToDB := FALSE;
end;

function TfrRevs.getDefaultPos: tPoint;
const
  DEFAULT_POS_TOP = 68;
  ORIGINAL_WIDTH = 300;
  ORIGINAL_HEIGHT = 100;
var
  WBOUND, HBOUND: integer;

begin
  with fDefaultPos do begin
    WBOUND := screen.width - ORIGINAL_WIDTH;
    HBOUND := screen.height - ORIGINAL_HEIGHT;
    if (X <= 0) or (X > WBOUND) then begin
      X := WBOUND - 24;
      //if screen.width > 1024 then inc(X, 16);
    end;
    if (Y <= 0) or (Y > HBOUND) then Y := DEFAULT_POS_TOP;
  end;
  Result := fDefaultPos;
end;

procedure TfrRevs.FormCreate(Sender: TObject);
begin
  GetDefaultPos;
  Left := fDefaultPos.X;
  top := fDefaultPos.Y;
  init;
{$IFDEF EXACS}
  LoadRevObs;
{$IFDEF EXAC_ENT}
///=============================================
///change with vskin:
///  XPMenu1 := TXPMenu.Create(Self);
{$ENDIF EXAC_ENT}
{$ENDIF}
end;

procedure TfrRevs.FormShow(Sender: TObject);
const
  firstShown: boolean = TRUE;
begin
  if firstShown then begin
    with firstShownPos do begin
      //top := 105;
      //Left := 145;
      if X > 0 then
        left := X;
      if Y > 0 then
        Top := Y;
      firstShown := FALSE;
    end
  end;
  LinkedToDB := TRUE; // also test whether GUIEnable
  if not LinkedToDB then begin
    width := 0; height := 0;
    Enabled := FALSE;
    OnClose := nil;
  end;
  //HideFromTaskBar;
end;

procedure TfrRevs.Label5Click(Sender: TObject);
begin
  //with XPMenu1 do if not Active then Active := TRUE else Active := false
end;

procedure TfrRevs.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = ^[then begin
    Key := #0;
    close
  end;
end;

procedure TfrRevs.test11Click(Sender: TObject);
begin
  close
end;

procedure TfrRevs.OvalButton1Click(Sender: TObject);
begin
  //
end;

procedure TfrRevs.OvalButton2Click(Sender: TObject);
begin
  //
end;

procedure TfrRevs.OvalButton3Click(Sender: TObject);
begin
  //
end;

procedure TfrRevs.OvalButton4Click(Sender: TObject);
begin
  //
end;

//function KBCTRL_Pressed: Boolean;
//var
//  State: TKeyboardState;
//begin
//  GetKeyboardState(State);
//  Result := ((State[VK_CONTROL] and 128) <> 0);
//end;
//
//function KBALT_Pressed: Boolean;
//var
//  State: TKeyboardState;
//begin
//  GetKeyboardState(State);
//  Result := ((State[VK_MENU] and 128) <> 0);
//end;
//
//function KBSHIFT_Pressed: Boolean;
//var
//  State: TKeyboardState;
//begin
//  GetKeyboardState(State);
//  Result := ((State[VK_SHIFT] and 128) <> 0);
//end;

procedure TfrRevs.getmaxRevObsBits;
begin
end;

procedure TfrRevs.getmaxRevObs;
const
  most_ = 'Most '; _docs = ' documents:'; no_ = 'No.';
  rev_ = 'revis'; ob_ = 'obsole'; obs_ = ob_ + 't'; obsed_ = ob_ + 't';
  _ed = 'ed'; _ing = 'ing';
  xreved = most_ + rev_ + _ed;
  xobsed = most_ + obsed_ + _ed;
  xreves = most_ + rev_ + _ing;
  xobses = most_ + obs_ + _ing;
  xmost: array[TXRevObsSection] of string = (xreved, xobsed, xreves, xobses);

type
  trxStat = packed record nmax, idmax, nmid, idmid, nmin, idmin: integer; end;

  procedure SortDown(var tx: trxStat);
    procedure exchange(var A, id_A, B, id_B: integer);
    var
      X, id_X: integer;
    begin
      X := A; id_X := id_A;
      A := B; id_A := id_B;
      B := X; id_B := id_X;
    end;
  begin
    with tx do begin
      if nmax < nmin then
        exchange(nmax, idmax, nmin, idmin);
      if nmax < nmid then
        exchange(nmax, idmax, nmid, idmid);
      if nmid < nmin then
        exchange(nmid, idmid, nmin, idmin);
    end;
  end;

var
  rxa: packed array[TXRevObsSection] of trxStat;
  //re: packed array[TExpRevObsSection] of integer;

  function puts(const n, i: integer): string;
  begin
    Result := '';
    if n > 0 then begin
      Result := Result + '- ';
      Result := Result + 'No.' + intoStr(i);
      Result := Result + ' (' + intoStr(n) + 'x)' + ^i;
      Result := Result + fDocList[i];
      Result := Result + ^j;
    end;
  end;

  //procedure initrx; var r: TXRevObsSection; begin for r := Low(r) to high(r) do with rx[r] do begin nmax := -1; nmid := -1; nmin := -1; idmax := -1; idmid := -1; idmin := -1; end; end;
type
  TrxIDStatus = packed record
    ID, nReved, nObsed, nReves, nObses: integer;
  end;
  TrxBitStorage = packed array[boolean, boolean, boolean, boolean] of TrxIDStatus;

const
  _a = roRevisedBy;
  _b = roObsoletedBy;
  _c = roRevises;
  _d = roObsoletes;

const
  rxsHeader = 'Mutations:'^j^j'No.'^i + 'Rev''d'^i'Obs''d'^i'Reves'^i'Obses'^i'Document';
  rxCount = (ord(high(TXRevObsSection)) - ord(Low(TXRevObsSection))) + 1;

var
  rxs: TrxBitStorage;

  procedure CmpXChgIDBits(const Index, reved, obsed, reves, obses: integer);
  begin
    with rxs[(reved > 0), (obsed > 0), (reves > 0), (obses > 0)] do begin
      if (nReved <= reved) and (nObsed <= obsed) and (nReves <= reves) and (nObses <= obses) then begin
        ID := Index; nReved := reved; nObsed := obsed; nReves := reves; nObses := obses;
      end;
    end;
  end;

  function IDBitStrOf(const reved, obsed, reves, obses: longbool): string;
  const
    zero = '0'; dash = '-';
  var
    i: integer;
  begin
    Result := '';
    with rxs[reved, obsed, reves, obses] do
      if ID > 1 then begin
        Result := intoStr(ID);
        Result := Result + ^i + intoStr(nReved) + ^i + intoStr(nObsed);
        Result := Result + ^i + intoStr(nReves) + ^i + intoStr(nObses);
        Result := Result + ^i + DocListItem[ID] + ^i;
      end;
    for i := 1 to length(Result) - 1 - 1 do
      if (Result[i] = ^i) and (Result[i + 1] = zero) and (Result[i + 2] = ^i) then
        Result[i + 1] := dash;
  end;

var
  i, m, n: integer;
  S: string;
  r: TXRevObsSection;
  a, b, c, d: integer;
begin
  //initrx;
  //fillchar(rx, sizeOf(rx), -1);
  getmaxRevObsBits;
  fillchar(rxa, sizeOf(rxa), -1);
  for r := Low(r) to high(r) do begin
    m := high(XRInts[r]);
    for i := 0 to m do begin
      with rxa[r] do begin
        n := high(XRInts[r, i]);
        if nmin < n then begin
          nmin := n;
          idmin := i;
          sortDown(rxa[r]);
        end;
      end;
    end;
  end;

  S := '';
  for r := Low(r) to high(r) do begin
    S := S + xmost[r] + _docs + ^j^j;
      //S := S + stringofChar('-', 40) + ^j;
    with rxa[r] do begin
      S := S + puts(nmax, idmax);
      S := S + puts(nmid, idmid);
      S := S + puts(nmin, idmin);
    end;
    S := S + ^J;
  end;

  fillchar(rxs, sizeOf(rxs), 0);
  for i := 0 to high(fDocList) do begin
    if (i < length(XRInts[_a])) then
      a := length(XRInts[_a, i])
    else
      a := 0;
    if (i < length(XRInts[_b])) then
      b := length(XRInts[_b, i])
    else
      b := 0;
    if (i < length(XRInts[_c])) then
      c := length(XRInts[_c, i])
    else
      c := 0;
    if (i < length(XRInts[_d])) then
      d := length(XRInts[_d, i])
    else
      d := 0;
    if (a > 0) or (b > 0) or (c > 0) or (d > 0) then
      CmpXChgIDBits(i, a, b, c, d);
  end;

  S := S + rxsHeader + ^j;
  for i := 0 to (1 shl rxCount) - 1 do
    S := S + IDBitStrOf(boolean(i and (1 shl 0)), boolean(i and (1 shl 1)), boolean(i and (1 shl 2)), boolean(i and (1 shl 3))) + ^j;
  Clipboard.AsText := S;
  if KBSHIFT_Pressed then
    ShowMessage(S);

end;

function TfrRevs.getDocNo(Index: integer): string;
var
  doc, group: string;
begin
  doc := '';
  if (Index >= 0) and (Index < length(fDocList)) then begin
    doc := fDocList[Index];
    if ((doc = '') or (doc[1] in ['0'..'9', ' ', '-'])) and assigned(dm.LookJenis) then begin
      group := dm.LookJenis.Values[intoStr(Index)];
      group := dm.LookMnemonics.Values[group];
      if group <> '' then
        doc := group + ' ' + doc;
    end;
  end;
  Result := doc;
end;

procedure TfrRevs.OvalButton5Click(Sender: TObject);
const
  NeverAgain: boolean = FALSE;
begin
// OK. changed. make it always accessible
//  if (KBALT_Pressed) and not (KBCTRL_Pressed) and not NeverAgain then
//    getmaxRevObs;
//  if not (KBCTRL_Pressed) then
//{$IFNDEF PASS_ALL}
//    NeverAgain := TRUE;
//{$ENDIF PASS_ALL}
//  if not ((KBALT_Pressed) and not KBSHIFT_Pressed) then
//    Close;
getmaxRevObs;

  // how are those interpreted?
  // --------------------------
  // press both (and should be only) ALT-SHIFT to shows info-message,
  // beware, pressing CTRL key will nullified 'the fun'
  //   if only ALT had pressed the message will not be shown
  //   (the Result will always copied to the Clipboard whether
  //   the info-message would shown or not)

  // press ALT and avoid SHIFT (do not press it), to prevent closing
  // pressing the other keys (including CTRL) has no influence to closing

  // press CTRL to retain the usability of 'the fun'
  // at the first chance you miss to press CTRL upon exit,
  // 'this fun' will never again be respecting you :)

  //
  // confused? don't be. its amazingly simple on summary
  // - press ONLY ALT-SHIFT when Clicking the little red button
  // - press ONLY CTRL-ALT when Clicking the OK Button, to continue working
  // - press ONLY CTRL to when Clicking the OK Button, to close
  //

end;

procedure TfrRevs.FormDestroy(Sender: TObject);
begin
{$IFDEF EXAC_ENT}
///=============================================
///change with vskin:
///  XPMenu1.Free;
{$ENDIF EXAC_ENT}
end;

procedure TfrRevs.popdPopup(Sender: TObject);
begin
  with (Sender as TPopupMenu) do
    (Popupcomponent as TControl).Perform(CM_MOUSELEAVE, 0, 0);
end;

procedure TfrRevs.HideFromTaskBar;
var
  hwndOwner: HWnd;
begin
  hwndOwner := GetWindow(Handle, GW_OWNER);
  ShowWindow(hwndOwner, SW_HIDE);
  // For Windows 2000, additionally call the ShowWindowAsync function:
  ShowWindowAsync(hwndOwner, SW_HIDE);
  ShowWindowAsync(Self.Handle, SW_HIDE);
end;

procedure TfrRevs_WMSysCommand_minimize(var msg: TWMSysCommand);
begin
  if msg.CmdType and $FFF0 = SC_MINIMIZE then
    //hide
  else
    //inherited;
end;

end.


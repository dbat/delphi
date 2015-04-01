unit dBrowse2;
{$I QUIET.INC}
{
  Copyright (c) 2004, aa, Inge DR. & Adrian Hafizh.
  Property of PT SOFTINDO Jakarta.
  All rights reserved.

  mailto:aa|AT|softindo|DOT|net,  http://delphi.softindo.net

  Computer, Folder & Printer Browser

  excerpted, polished, furnished & completed, based on rx's (who else?)
  compiled in D5, maybe works in D4 too.

  Version: 1.0.0
  Dated: 2004.04.03
}

{$D-}
interface
uses Classes;

function BrowseComputer(var ComputerName: string; const Title: string = 'Select Computer';
  HelpContext: Cardinal = 0): Boolean;
function BrowseDirectory(var InitialDir: string; const Title: string = 'Select Directory';
  const SelectForFolders: Boolean = TRUE; SelectForFiles: Boolean = FALSE; HelpContext: Cardinal = 0): Boolean;
//SelectForItems: TBrowseItemSelections = [biSelectFolders];
function BrowsePrinter(var PrinterName: string; const Title: string = 'Select Printer';
  HelpContext: Cardinal = 0): Boolean;

function AdvSelectDirectory(var Directory: string; const Root: WideString = '';
  const EditBox: Boolean = False; const Caption: string = 'Select Directory';
  ShowFiles: Boolean = False; AllowCreateDirs: Boolean = True): Boolean;
//function AdvSelectDirectory(const Caption: string; const Root: WideString;
//  var Directory: string; EditBox: Boolean = False; ShowFiles: Boolean = False;
//  AllowCreateDirs: Boolean = True): Boolean;

function getFileList(const fileList: TStrings; const Folder, filemask: string; const Recursive: boolean): integer;

implementation

uses Forms, Windows, messages, SysUtils, FileScan, ShlObj, ActiveX; //, ShlObj;
//those craps below removed. there's only 1 external procedure from both of them were utilized :((
//, ComObj;//, ActiveX;

type
  TBrowseKind = (brFolders, brComputers, brPrinters);
  TBrowseDialogPosition = (dgDefault, dgScreenCenter);

const
  {$EXTERNALSYM BIF_RETURNONLYFSDIRS}
  BIF_RETURNONLYFSDIRS = $0001; { For finding a folder to start document searching }
  {$EXTERNALSYM BIF_DONTGOBELOWDOMAIN}
  BIF_DONTGOBELOWDOMAIN = $0002; { For starting the Find Computer }
  {$EXTERNALSYM BIF_STATUSTEXT}
  BIF_STATUSTEXT = $0004;
  {$EXTERNALSYM BIF_RETURNFSANCESTORS}
  BIF_RETURNFSANCESTORS = $0008;
  {$EXTERNALSYM BIF_EDITBOX}
  BIF_EDITBOX = $0010;
  {$EXTERNALSYM BIF_VALIDATE}
  BIF_VALIDATE = $0020; { insist on valid result (or CANCEL) }

  {$EXTERNALSYM BIF_BROWSEFORCOMPUTER}
  BIF_BROWSEFORCOMPUTER = $1000; { Browsing for Computers. }
  {$EXTERNALSYM BIF_BROWSEFORPRINTER}
  BIF_BROWSEFORPRINTER = $2000; { Browsing for Printers }
  {$EXTERNALSYM BIF_BROWSEINCLUDEFILES}
  BIF_BROWSEINCLUDEFILES = $4000; { Browsing for Everything }

const
  { message from browser }
  {$EXTERNALSYM BFFM_INITIALIZED}
  BFFM_INITIALIZED = 1;
  {$EXTERNALSYM BFFM_SELCHANGED}
  BFFM_SELCHANGED = 2;

  { messages to browser }
  {$EXTERNALSYM BFFM_SETSTATUSTEXT}
  BFFM_SETSTATUSTEXT = (WM_USER + 100);
  {$EXTERNALSYM BFFM_ENABLEOK}
  BFFM_ENABLEOK = (WM_USER + 101);
  {$EXTERNALSYM BFFM_SETSELECTION}
  BFFM_SETSELECTION = (WM_USER + 102);

  {$EXTERNALSYM CSIDL_DRIVES}
  CSIDL_DRIVES = $0011;
  {$EXTERNALSYM CSIDL_NETWORK}
  CSIDL_NETWORK = $0012;
  {$EXTERNALSYM CSIDL_PRINTERS}
  CSIDL_PRINTERS = $0004;

type
  {$EXTERNALSYM BFFCALLBACK}
  BFFCALLBACK = function(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): integer stdcall;
  TFNBFFCallBack = type BFFCALLBACK;

  { TItemIDList -- List if item IDs (combined with 0-terminator) }
  PItemIDList = ^TItemIDList;
  TItemIDList = record
    cb: WORD; { Size of the ID (including cb itself) }
    abID: array[0..0] of Byte; { The item ID (variable length) }
  end;

  TBrowseInfo = record
    hwndOwner: HWND;
    pidlRoot: PItemIDList;
    pszDisplayName: PAnsiChar; { Return display name of item selected. }
    lpszTitle: PAnsiChar; { text to go in the banner over the tree. }
    ulFlags: UINT; { Flags that control the return stuff }
    lpfn: TFNBFFCallBack;
    lParam: LPARAM; { extra info that's passed back in callbacks }
    iImage: integer; { output var: where to return the Image index. }
  end;

const
  Shell32 = 'shell32.dll';
  ole32 = 'ole32.dll';

function SHBrowseForFolder(var lpbi: TBrowseInfo): PItemIDList; stdcall; far;
  external Shell32 name 'SHBrowseForFolder';

function SHGetPathFromIDList(pidl: PItemIDList; pszPath: LPSTR): BOOL; stdcall; far;
  external Shell32 name 'SHGetPathFromIDList';

function SHGetSpecialFolderLocation(hwndOwner: HWND; nFolder: integer;
  var ppidl: PItemIDList): HResult; stdcall; far;
  external Shell32 name 'SHGetSpecialFolderLocation';

type
  TBrowseItemSelection = (biSelectFolders, biSelectFiles);
  TBrowseItemSelections = set of TBrowseItemSelection;

type
  TBrowseFolderDlg = class(TComponent)
  private
    FDefWndProc: Pointer;
    FHelpContext: THelpContext;
    FHandle: HWnd;
    FObjectInstance: Pointer;
    FDesktopRoot: Boolean;
    FBrowseKind: TBrowseKind;
    FPosition: TBrowseDialogPosition;
    FText: string;
    FDisplayName: string;
    FSelectedName: string;
    FInfoText: string;
    fItemSelections: TBrowseItemSelections;
    //fSelectFolders, fSelectFiles: Boolean;
    FImageIndex: integer;
    FOnInitialized: TNotifyEvent;
    FOnSelChanged: TNotifyEvent;
    procedure SetSelPath(const Path: string);
    procedure SetOkEnable(Value: Boolean);
    procedure DoInitialized;
    procedure DoSelChanged(Param: PItemIDList);
    procedure WMNCDestroy(var Message: TWMNCDestroy); message WM_NCDESTROY;
    procedure WMCommand(var Message: TMessage); message WM_COMMAND;
  protected
    procedure DefaultHandler(var Message); override;
    procedure WndProc(var Message: TMessage); virtual;
    function TaskModalDialog(var Info: TBrowseInfo): PItemIDList;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Execute: Boolean;
    property Handle: HWnd read FHandle;
    property DisplayName: string read FDisplayName;
    property SelectedName: string read FSelectedName write FSelectedName;
    property ImageIndex: integer read FImageIndex;
  published
    property BrowseKind: TBrowseKind
      read FBrowseKind write FBrowseKind default brFolders;
    property DesktopRoot: Boolean
      read FDesktopRoot write FDesktopRoot default TRUE;
    property DialogText: string
      read FText write FText;
    property InfoText: string
      read FInfoText write FInfoText;
    property ItemSelections: TBrowseItemSelections
      read fItemSelections write fItemSelections;
    //property SelectForFolder: Boolean read fSelectFolders write fSelectFolders;
    //property SelectForFiles: Boolean  read fSelectFiles write fSelectFiles;
    property HelpContext: THelpContext
      read FHelpContext write FHelpContext default 0;
    property Position: TBrowseDialogPosition
      read FPosition write FPosition default dgScreenCenter;
    property OnInitialized: TNotifyEvent
      read FOnInitialized write FOnInitialized;
    property OnSelChanged: TNotifyEvent
      read FOnSelChanged write FOnSelChanged;
  end;

constructor TBrowseFolderDlg.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fObjectInstance := MakeObjectInstance(WndProc);
  fDesktopRoot := TRUE;
  fBrowseKind := brFolders;
  fPosition := dgScreenCenter;
  fItemSelections := [];
  //fSelectFolders:= TRUE;
  //fSelectFiles:= FALSE;
  SetLength(FDisplayName, MAX_PATH);
end;

destructor TBrowseFolderDlg.Destroy;
begin
  if FObjectInstance <> nil then
    FreeObjectInstance(FObjectInstance);
  inherited Destroy;
end;

const
  HelpButtonId = $FFFF;

resourcestring
  SHelpButton = 'HELP';

function DirectoryExists(const Name: string): Boolean; forward;

procedure TBrowseFolderDlg.DoInitialized;
const
  SBtn = 'BUTTON';
var
  BtnHandle, HelpBtn, BtnFont: THandle;
  BtnSize: TRect;
  DirPart: string;
begin
  if (FBrowseKind in [brComputers, brPrinters]) then
    SetSelPath(FInfoText)
  else begin
    // set selection to supplied text as filename (if IncludeFile option selected)
    // if the specified file is not exist, select it's directory instead
    // or else set selection to supplied text as folder (if IncludeFolder option selected)
    // if that folder is not exist (maybe it's a filename that had entered),
    //   then try to get the correct value (it's upper folder)
    // if only none of above tries were succeed then we'll gave up :)
    if ((biSelectFiles in fItemSelections) and FileExists(FInfoText))
      or
      ((biSelectFolders in fItemSelections) and DirectoryExists(FInfoText)) then
      SetSelPath(FInfoText)
    else begin
      DirPart := ExtractFileDir(FInfoText);
      if DirectoryExists(DirPart) then
        SetSelPath(DirPart)
    end;
  end;
  if FHelpContext <> 0 then begin
    BtnHandle := FindWindowEx(FHandle, 0, SBtn, nil);
    if (BtnHandle <> 0) then begin
      GetWindowRect(BtnHandle, BtnSize);
      ScreenToClient(FHandle, BtnSize.TopLeft);
      ScreenToClient(FHandle, BtnSize.BottomRight);
      BtnFont := SendMessage(FHandle, WM_GETFONT, 0, 0);
      //HelpBtn := CreateWindow(SBtn, PChar(ResStr(SHelpButton)),
      HelpBtn := CreateWindow(SBtn, PChar(SHelpButton),
        WS_CHILD or WS_CLIPSIBLINGS or WS_VISIBLE or BS_PUSHBUTTON or WS_TABSTOP, 12,
        BtnSize.Top, BtnSize.Right - BtnSize.Left, BtnSize.Bottom - BtnSize.Top,
        FHandle, HelpButtonId, HInstance, nil);
      if BtnFont <> 0 then
        SendMessage(HelpBtn, WM_SETFONT, BtnFont, MakeLParam(1, 0));
      UpdateWindow(FHandle);
    end;
  end;
  if Assigned(FOnInitialized) then
    FOnInitialized(Self);
end;

procedure TBrowseFolderDlg.DoSelChanged(Param: PItemIDList);
var
  Temp: array[0..MAX_PATH] of Char;
  fOK: Boolean;
begin
  if (FBrowseKind in [brComputers, brPrinters]) then begin
    FSelectedName := DisplayName;
    if FBrowseKind = brPrinters then
      SetOkEnable(TRUE);
  end
  else begin
    if SHGetPathFromIDList(Param, Temp) then begin
      FSelectedName := StrPas(Temp);
      fOK := FALSE;
      if biSelectFolders in fItemSelections then
        fOK := (DirectoryExists(FSelectedName));
      if not fOK and (biSelectFiles in fItemSelections) then
        fOK := (FileExists(FSelectedName));
      SetOkEnable(fOK);
    end
    else begin
      FSelectedName := '';
      SetOkEnable(FALSE);
    end;
  end;
  if Assigned(FOnSelChanged) then
    FOnSelChanged(Self);
end;

procedure TBrowseFolderDlg.SetSelPath(const Path: string);
begin
  if FHandle <> 0 then
    SendMessage(FHandle, BFFM_SETSELECTION, 1, LongInt(PChar(Path)));
end;

procedure TBrowseFolderDlg.SetOkEnable(Value: Boolean);
begin
  if FHandle <> 0 then
    SendMessage(FHandle, BFFM_ENABLEOK, 0, Ord(Value));
end;

procedure TBrowseFolderDlg.DefaultHandler(var Message);
begin
  if FHandle <> 0 then
    with TMessage(Message) do
      Result := CallWindowProc(FDefWndProc, FHandle, Msg, WParam, LParam)
  else
    inherited DefaultHandler(Message);
end;

procedure TBrowseFolderDlg.WndProc(var Message: TMessage);
begin
  Dispatch(Message);
end;

procedure TBrowseFolderDlg.WMCommand(var Message: TMessage);
begin
  if (Message.wParam = HelpButtonId) and (LongRec(Message.lParam).Hi = BN_CLICKED) and
    (FHelpContext <> 0) then
    Application.HelpContext(FHelpContext)
  else
    inherited;
end;

procedure TBrowseFolderDlg.WMNCDestroy(var Message: TWMNCDestroy);
begin
  inherited;
  FHandle := 0;
end;

function ExplorerHook(Wnd: HWnd; Msg: UINT; LParam: LPARAM; Data: LPARAM): integer; stdcall; forward;

//to avoid using ActiveX units for using JUST this ONLY SINGLE procedure ALONE. no shit!
{$EXTERNALSYM CoTaskMemFree}

procedure CoTaskMemFree(pv: Pointer); stdcall; external ole32 name 'CoTaskMemFree';

//to avoid using ComObj units for using JUST this ONLY SINGLE procedure ALONE. no shit!

procedure OleCheck(Result: HResult);
begin
  if not Succeeded(Result) then //OleError(Result);
    raise exception.Create('OLE Error');
end;

function TBrowseFolderDlg.Execute: Boolean;
var
  BrowseInfo: TBrowseInfo;
  ItemIDList: PItemIDList;
  Temp: array[0..MAX_PATH] of Char;
begin
  if FDesktopRoot and (FBrowseKind = brFolders) then
    BrowseInfo.pidlRoot := nil
  else
    case FBrowseKind of
      brComputers: // root - Network
        OleCheck(SHGetSpecialFolderLocation(0, CSIDL_NETWORK, BrowseInfo.pidlRoot));
      brFolders: // root - MyComputer
        OleCheck(SHGetSpecialFolderLocation(0, CSIDL_DRIVES, BrowseInfo.pidlRoot));
      brPrinters:
        OleCheck(SHGetSpecialFolderLocation(0, CSIDL_PRINTERS, BrowseInfo.pidlRoot));
    end;
  try
    SetLength(FDisplayName, MAX_PATH);
    with BrowseInfo do begin
      pszDisplayName := PChar(DisplayName);
      if DialogText <> '' then
        lpszTitle := PChar(DialogText)
      else
        lpszTitle := nil;
      case FBrowseKind of
        brComputers: ulFlags := BIF_BROWSEFORCOMPUTER;
        brFolders: begin
            ulFlags := BIF_RETURNONLYFSDIRS or BIF_RETURNFSANCESTORS;
            if biSelectFiles in fItemSelections then
              ulFlags := ulFlags or BIF_BROWSEINCLUDEFILES;
          end;
        brPrinters: ulFlags := BIF_BROWSEFORPRINTER;
      end;
      lpfn := ExplorerHook;
      lParam := LongInt(Self);
      hWndOwner := Application.Handle;
      iImage := 0;
    end;
    ItemIDList := TaskModalDialog(BrowseInfo);
    Result := ItemIDList <> nil;
    if Result then try
      case FBrowseKind of
        brFolders {, brPrinters}: begin
            Win32Check(SHGetPathFromIDList(ItemIDList, Temp));
            FInfoText := {RemoveBackSlash} ExcludeTrailingBackSlash(StrPas(Temp));
          end;
      else
        FInfoText := DisplayName;
      end;
      FSelectedName := FInfoText;
      FImageIndex := BrowseInfo.iImage;
    finally
      CoTaskMemFree(ItemIDList);
    end;
  finally
    if BrowseInfo.pidlRoot <> nil then
      CoTaskMemFree(BrowseInfo.pidlRoot);
  end;
end;

function DirectoryExists(const Name: string): Boolean;
var
  Code: integer;
begin
  Code := GetFileAttributes(PChar(Name));
  Result := (Code <> -1) and (faDirectory and Code <> 0);
end;

function TBrowseFolderDlg.TaskModalDialog(var Info: TBrowseInfo): PItemIDList;
var
  ActiveWindow: HWnd;
  WindowList: Pointer;
begin
  ActiveWindow := GetActiveWindow;
  WindowList := DisableTaskWindows(0);
  try
    try
      Result := SHBrowseForFolder(Info);
    finally
      FHandle := 0;
      FDefWndProc := nil;
    end;
  finally
    EnableTaskWindows(WindowList);
    SetActiveWindow(ActiveWindow);
  end;
end;

procedure FitRectToScreen(var Rect: TRect);
var
  X, Y, Delta: integer;
begin
  X := GetSystemMetrics(SM_CXSCREEN);
  Y := GetSystemMetrics(SM_CYSCREEN);
  with Rect do begin
    if Right > X then begin
      Delta := Right - Left;
      Right := X;
      Left := Right - Delta;
    end;
    if Left < 0 then begin
      Delta := Right - Left;
      Left := 0;
      Right := Left + Delta;
    end;
    if Bottom > Y then begin
      Delta := Bottom - Top;
      Bottom := Y;
      Top := Bottom - Delta;
    end;
    if Top < 0 then begin
      Delta := Bottom - Top;
      Top := 0;
      Bottom := Top + Delta;
    end;
  end;
end;

procedure CenterWindow(Wnd: HWnd);
var
  R: TRect;
begin
  GetWindowRect(Wnd, R);
  R := Rect((GetSystemMetrics(SM_CXSCREEN) - R.Right + R.Left) div 2,
    (GetSystemMetrics(SM_CYSCREEN) - R.Bottom + R.Top) div 2,
    R.Right - R.Left, R.Bottom - R.Top);
  FitRectToScreen(R);
  SetWindowPos(Wnd, 0, R.Left, R.Top, 0, 0, SWP_NOACTIVATE or
    SWP_NOSIZE or SWP_NOZORDER);
end;

function ExplorerHook(Wnd: HWnd; Msg: UINT; LParam: LPARAM; Data: LPARAM): integer; stdcall;
begin
  Result := 0;
  if Msg = BFFM_INITIALIZED then begin
    if TBrowseFolderDlg(Data).Position = dgScreenCenter then
      CenterWindow(Wnd);
    TBrowseFolderDlg(Data).FHandle := Wnd;
    TBrowseFolderDlg(Data).FDefWndProc := Pointer(SetWindowLong(Wnd, GWL_WNDPROC,
      LongInt(TBrowseFolderDlg(Data).FObjectInstance)));
    TBrowseFolderDlg(Data).DoInitialized;
  end
  else if Msg = BFFM_SELCHANGED then begin
    TBrowseFolderDlg(Data).FHandle := Wnd;
    TBrowseFolderDlg(Data).DoSelChanged(PItemIDList(LParam));
  end;
end;

function RequestInfo(var Info: string; const Title: string; const BrowseKind: TBrowseKind;
  RequestedItems: TBrowseItemSelections; const iHelpContext: Cardinal): Boolean;
begin
  with TBrowseFolderDlg.Create(Application) do try
    DialogText := Title;
    InfoText := Info;
    fItemSelections := RequestedItems;
    HelpContext := iHelpContext;
    Result := Execute;
    if Result = TRUE then
      Info := InfoText;
  finally
    Free;
  end;
end;

function BrowseDirectory(var InitialDir: string; const Title: string = 'Select Directory';
  const SelectForFolders: Boolean = TRUE; SelectForFiles: Boolean = FALSE; HelpContext: Cardinal = 0): Boolean;
//SelectForItems: TBrowseItemSelections = [biSelectFolders];
var
  ReqItems: TBrowseItemSelections;
begin
  ReqItems := [];
  if SelectForFolders then
    include(ReqItems, biSelectFolders);
  if SelectForFiles then
    include(ReqItems, biSelectFiles);
  Result := RequestInfo(InitialDir, Title, brFolders, ReqItems, HelpContext);
end;

function BrowseComputer(var ComputerName: string; const Title: string = 'Select Computer';
  HelpContext: Cardinal = 0): Boolean;
begin
  Result := RequestInfo(ComputerName, Title, brComputers, [], HelpContext);
end;

function BrowsePrinter(var PrinterName: string; const Title: string = 'Select Printer';
  HelpContext: Cardinal = 0): Boolean;
begin
  Result := RequestInfo(PrinterName, Title, brPrinters, [], HelpContext);
end;

function AdvSelectDirectory(var Directory: string; const Root: WideString = '';
  const EditBox: Boolean = False; const Caption: string = 'Select Directory';
  ShowFiles: Boolean = False; AllowCreateDirs: Boolean = True): Boolean;
// callback function that is called when the dialog has been initialized
// or a new directory has been selected

  function SelectDirCB(Wnd: HWND; uMsg: UINT; lParam, lpData: lParam): Integer; stdcall;
    //var PathName: array[0..MAX_PATH] of Char;
  begin
    case uMsg of
      BFFM_INITIALIZED: SendMessage(Wnd, BFFM_SETSELECTION, Ord(True), Integer(lpData));
      // include the following comment into your code if you want to react on the
      // event that is called when a new directory has been selected
      {BFFM_SELCHANGED:
      begin
        SHGetPathFromIDList(PItemIDList(lParam), @PathName);
        // the directory "PathName" has been selected
      end;}
    end;
    Result := 0;
  end;
var
  WindowList: Pointer;
  BrowseInfo: TBrowseInfo;
  Buffer: PChar;
  RootItemIDList, ItemIDList: PItemIDList;
  ShellMalloc: IMalloc;
  IDesktopFolder: IShellFolder;
  Eaten, Flags: Longword;
const
  // necessary for some of the additional expansions
  // notwendig für einige der zusätzlichen Erweiterungen
  BIF_USENEWUI = $0040;
  BIF_NOCREATEDIRS = $0200;
begin
  Result := False;
  if not DirectoryExists(Directory) then
    Directory := '';
  FillChar(BrowseInfo, SizeOf(BrowseInfo), 0);
  if (ShGetMalloc(ShellMalloc) = S_OK) and (ShellMalloc <> nil) then begin
    Buffer := ShellMalloc.Alloc(MAX_PATH);
    try
      RootItemIDList := nil;
      if Root <> '' then begin
        SHGetDesktopFolder(IDesktopFolder);

        IDesktopFolder.ParseDisplayName(
          Application.Handle,
          nil,
          POleStr(Root),
          Eaten,
          SHlObj.PITemIDList(RootItemIDList),
          Flags
          );
      end;
      OleInitialize(nil);
      with BrowseInfo do begin
        hwndOwner := Application.Handle;
        pidlRoot := RootItemIDList;
        pszDisplayName := Buffer;
        lpszTitle := PChar(Caption);
        // defines how the dialog will appear:
        // legt fest, wie der Dialog erscheint:
        ulFlags := BIF_RETURNONLYFSDIRS or BIF_USENEWUI or
          BIF_EDITBOX * Ord(EditBox) or BIF_BROWSEINCLUDEFILES * Ord(ShowFiles) or
          BIF_NOCREATEDIRS * Ord(not AllowCreateDirs);
        lpfn := @SelectDirCB;
        if Directory <> '' then
          lParam := Integer(PChar(Directory));
      end;
      WindowList := DisableTaskWindows(0);
      try
        ItemIDList := ShBrowseForFolder(BrowseInfo);
      finally
        EnableTaskWindows(WindowList);
      end;
      Result := ItemIDList <> nil;
      if Result then begin
        ShGetPathFromIDList(ItemIDList, Buffer);
        ShellMalloc.Free(ItemIDList);
        Directory := Buffer;
      end;
    finally
      ShellMalloc.Free(Buffer);
    end;
  end;
end;

function getFileList(const fileList: TStrings; const Folder, filemask: string; const Recursive: boolean): integer;
var
  dirCount, fileCount: integer;
begin
  FileScan.ScanFiles(dirCount, fileCount, filemask, '', Folder, Recursive, fileList);
  Result := fileCount;
end;

function SimplifyPath(const path: string): string;
const MAXPATH = 260;
var
  PFileName: pChar;
  Buffer: array[0..MAX_PATH] of char;
begin
  PFileName := pChar(path);
  fillchar(Buffer, MAXPATH, 0);
  // GetFullPathName() do not check if the path or the file do not exists.
  // It works with UNC (\\machinename\share).
  GetFullPathName(PFileName, MAX_PATH, Buffer, PFileName);
  Result := string(PChar(@Buffer[0]));
end;

end.


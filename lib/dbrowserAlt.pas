unit dbrowserAlt;

interface

function SelectDirectoryEx(hOwn: integer; var Path: string;
  Caption, RootDir: string; uFlag: cardinal = $25): Boolean;
function BrowseforFile(Handle: integer; Title: string; Filename: string): string;

implementation
//...show the select directory dialog and sepeify the initial directory?
uses ShlObj, fDirfunc; //, ActiveX;

type
  IUnknown = interface
    ['{00000000-0000-0000-C000-000000000046}']
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  end;

  IMalloc = interface(IUnknown)
    ['{00000002-0000-0000-C000-000000000046}']
    function Alloc(cb: Longint): Pointer; stdcall;
    function Realloc(pv: Pointer; cb: Longint): Pointer; stdcall;
    procedure Free(pv: Pointer); stdcall;
    function GetSize(pv: Pointer): Longint; stdcall;
    function DidAlloc(pv: Pointer): Integer; stdcall;
    procedure HeapMinimize; stdcall;
  end;

function SendMessage(hWnd: integer; Msg, wParam, lParam: cardinal): integer; stdcall;
  external 'user32.dll' name 'SendMessageA';

function SHGetMalloc(var ppMalloc: IMalloc): HResult; stdcall;
  external 'shell32.dll' name 'SHGetMalloc';

function SelectDirectoryEx(hOwn: integer; var Path: string;
  Caption, RootDir: string; uFlag: cardinal = $25): Boolean;

const
  BIF_NEWDIALOGSTYLE = $0040;
var
  BrowseInfo: TBrowseInfo;
  Buffer: PChar;
  RootItemIDList, ItemIDList: PItemIDList;
  ShellMalloc: IMalloc;
  IDesktopFolder: IShellFolder;
  Dummy: LongWord;

const
  MAX_PATH = 255;
  S_OK = 0;

  function BrowseCallbackProc(hwnd: integer; uMsg, lParam, lpData: Cardinal): integer; stdcall;
  var
    PathName: array[0..MAX_PATH] of Char;
  begin
    case uMsg of
      BFFM_INITIALIZED:
        SendMessage(Hwnd, BFFM_SETSELECTION, Ord(True), integer(lpData));
      BFFM_SELCHANGED: begin
          SHGetPathFromIDList(PItemIDList(lParam), @PathName);
          SendMessage(hwnd, BFFM_SETSTATUSTEXT, 0, Longint(PChar(@PathName)));
        end;
    end;
    Result := 0;
  end;
type
  POleStr = PWideChar;
begin
  Result := False;
  FillChar(BrowseInfo, SizeOf(BrowseInfo), 0);
  if (ShGetMalloc(ShellMalloc) = S_OK) and (ShellMalloc <> nil) then begin
    Buffer := ShellMalloc.Alloc(MAX_PATH);
    try
      RootItemIDList := nil;
      if RootDir <> '' then begin
        SHGetDesktopFolder(IDesktopFolder);
        IDesktopFolder.ParseDisplayName(hOwn, nil, POleStr(WideString(RootDir)),
          Dummy, RootItemIDList, Dummy);
      end;
      with BrowseInfo do begin
        hwndOwner := hOwn;
        pidlRoot := RootItemIDList;
        pszDisplayName := Buffer;
        lpszTitle := PChar(Caption);
        ulFlags := uFlag;
        lpfn := @BrowseCallbackProc;
        lParam := integer(PChar(Path));
      end;
      ItemIDList := ShBrowseForFolder(BrowseInfo);
      Result := ItemIDList <> nil;
      if Result then begin
        ShGetPathFromIDList(ItemIDList, Buffer);
        ShellMalloc.Free(ItemIDList);
        Path := string(PChar(Buffer));
      end;
    finally
      ShellMalloc.Free(Buffer);
    end;
  end;
end;

function BrowseCallBack(Hwnd: integer; uMsg, lpParam, lpData: cardinal): integer; stdcall;
var
  Buffer: array[0..255] of char;
  Buffer2: array[0..255] of char;
  TmpStr: string;
begin
  // Initialize buffers
  FillChar(Buffer, SizeOf(Buffer), #0);
  FillChar(Buffer2, SizeOf(Buffer2), #0);

  // Statusline text
  TmpStr := 'Locate folder containing ' + string(PChar(lpData));

  // Copy statustext to pchar
  //StrPCopy(Buffer2, TmpStr);
  move(tmpStr[1], Buffer2, length(tmpStr));

  // Send message to BrowseForDlg that
  // the status text has changed
  SendMessage(hwnd, BFFM_SETSTATUSTEXT, 0, integer(@Buffer2));

  // If directory in BrowswForDlg has changed ?
  if uMsg = BFFM_SELCHANGED then begin
    // Get the new folder name
    SHGetPathFromIDList(PItemIDList(lpParam), Buffer);
    // And check for existens of our file.
{$IFDEF RX_D3} //RxLib - extentions
    if FileExists(NormalDir(StrPas(Buffer)) + StrPas(PChar(lpData)))
      and (StrLen(Buffer) > 0) then
{$ELSE}
    if Length(string(Buffer)) <> 0 then
      if Buffer[Length(string(Buffer)) - 1] = '\' then
        Buffer[Length(string(Buffer)) - 1] := #0;
    if FileExists(string(Buffer) + '\' + string(PChar(lpData))) and
      (length(string(Buffer)) > 0) then
{$ENDIF}
      // found : Send message to enable OK-button
      SendMessage(hwnd, BFFM_ENABLEOK, 1, 1)
    else
      // Send message to disable OK-Button
      SendMessage(Hwnd, BFFM_ENABLEOK, 0, 0);
  end;
  result := 0
end;

{type HGLOBAL = integer;
const kernel32 = 'kernel32.dll';
function GlobalHandle(Mem: Pointer): integer; stdcall;
  external kernel32 name 'GlobalHandle';
function GlobalUnlock(hMem: HGLOBAL): longbool; stdcall;
  external kernel32 name ' GlobalUnlock';
function GlobalFree(hMem: HGLOBAL): integer; stdcall;
  external kernel32 name 'GlobalFree';

function GlobalFreePtr(P: Pointer): integer; assembler asm
  push eax
  call GlobalHandle
  push eax; push eax
  call GlobalUnlock
  call GlobalFree
end;
}

function BrowseforFile(Handle: integer; Title: string; Filename: string): string;
var
  BrowseInfo: TBrowseInfo;
  RetBuffer, FName, ResultBuffer: array[0..255] of char;
  PIDL: PItemIDList;
begin
  //StrPCopy(Fname, FileName);
  move(FileName, fname, length(Filename));

  //Initialize buffers
  FillChar(BrowseInfo, SizeOf(TBrowseInfo), #0);
  Fillchar(RetBuffer, SizeOf(RetBuffer), #0);
  FillChar(ResultBuffer, SizeOf(ResultBuffer), #0);

  BrowseInfo.hwndOwner := Handle;
  BrowseInfo.pszDisplayName := @Retbuffer;
  BrowseInfo.lpszTitle := @Title[1];

  // we want a status-text
  BrowseInfo.ulFlags := BIF_StatusText;

  // Our call-back function cheching for fileexist
  BrowseInfo.lpfn := @BrowseCallBack;
  BrowseInfo.lParam := integer(@FName);

  // Show BrowseForDlg
  PIDL := SHBrowseForFolder(BrowseInfo);

  // Return fullpath to file
  if SHGetPathFromIDList(PIDL, ResultBuffer) then
    result := string(ResultBuffer)
  else
    Result := '';

  //GlobalFreePtr(PIDL); //Clean up
end;

// Example:
//
//procedure TForm1.Button1Click(Sender: TObject);
//const
//  FileName = 'File.xyz';
//var
//  Answer: integer;
//begin
//  if MessageBox(0, 'To locate the file yourself, click ok',
//     PChar(Format('File %s not found.',[FileName])),MB_OKCANCEL) = 1 then
//       BrowseforFile(Handle, 'locate ' + FileName, FileName);
//end;

end.


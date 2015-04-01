unit Shower;
{$DEFINE SYSUTILS}

interface
{$IFDEF SYSUTILS}uses SysUtils; //{$WEAKPACKAGEUNIT ON}
{$ENDIF SYSUTILS}

type
{$IFDEF SYSUTILS}Error = class(Exception);
{$ELSE}Error = class(TObject)
  private
    _errmsg: string;
  public
    constructor Create(const errMsg: string); overload;
    constructor Create(const errMsg: string; const errno: integer); overload;
  end;
{$ENDIF NO SYSUTILS}

procedure _Err(const ErrorNumber: integer);
//====================================================================
// error number to string conversion
function ErrStr(const ErrNo: Cardinal; const ShowErrNo: Boolean = TRUE;
  const AlwaysShowMessage: Boolean = TRUE): string;
// if (AlwaysShowMessage is set to TRUE), then if the message
// to be shown is not available (it did happen sometimes),
// then Result is a string "the message is not available".
// if set to FALSE then Result is simply an empty string.
function LastErrStr(const ShowErrNo: boolean = TRUE): string;
// ErrStr is essential routines to translate error number to string
// LastErr is basically just a macro which calls & translate GetLastError to string

// various showmessage replacement
function ShowmsgOK(const text: string; title: string = ''): word; // hOwner: Cardinal = 0): word;
function ShowmsgError(const text: string; title: string = ''): word; overload; // hOwner: Cardinal = 0): word;
function ConfirmYN(const text: string; title: string = ''): word; // hOwner: Cardinal = 0): word;
function ConfirmCritical(const text: string; title: string = ''; const Default_YES: boolean = FALSE): word; overload; // hOwner: Cardinal = 0): word;
function ConfirmCritical(const text: string; const Default_YES: boolean): word; overload;
function ConfirmYNCancel(const text: string; title: string = '';
  const Default_YES: boolean = FALSE): word; overload; // hOwner: Cardinal = 0): word;
function ConfirmYNCancel(const text: string; const Default_YES: boolean): word; overload; // hOwner: Cardinal = 0): word;
// confirmation - check Result against idYES or idNO

// error result showmessage
function ShowLastErr(title: string = ''; const ShowErrNo: boolean = TRUE;
  const AlwaysShowMessage: Boolean = TRUE): word; overload; // hOwner: Cardinal = 0): word;
function ShowmsgError(const ErrNo: integer; title: string = '';
  const ShowErrNo: boolean = TRUE; const AlwaysShowMessage: Boolean = TRUE): word; overload; // hOwner: Cardinal = 0): word;

//====================================================================

implementation
uses ACConsts, Ordinals;

{$IFNDEF SYSUTILS}

constructor Error.Create(const errMsg: string); begin
  _errmsg := ^j + errMsg + ^j;
  ShowmsgError(_errmsg);
end;

constructor Error.Create(const errMsg: string; const errno: integer); begin
  _errmsg := ^j'Error ' + intoHex(errno) + 'H' + ' (' + intoStr(errno) + ')' + ^j + errmsg + ^j;
  ShowmsgError(_errmsg);
end;

procedure ErrorHandler(ErrorCode: Byte; ErrorAddr: Pointer); export;
begin
  ShowmsgError(Error(ErrorAddr)._errmsg);
  halt(1);
end;
{$ENDIF NO SYSUTILS}

const
  kernel32 = 'kernel32.dll';
  user32 = 'user32.dll';

procedure RaiseException(Code: Longword = $DEADF0E; Flags: Longword = 1;
  ArgCount: Longword = 0; Arguments: pointer = nil); stdcall;
  external kernel32 name 'RaiseException'; {$EXTERNALSYM RaiseException}

procedure _Err(const ErrorNumber: integer); //; const msg: string);
const
  EXCEPTION_NONCONTINUABLE = 1; //{$EXTERNALSYM EXCEPTION_NONCONTINUABLE}
begin
  RaiseException(ErrorNumber, EXCEPTION_NONCONTINUABLE, 0, nil); //PChar('Cannot Continue'));
end;

type
  DWORD = Longword; //{$EXTERNALSYM DWORD}
  UINT = LongWord; //{$EXTERNALSYM UINT}
  HWND = type LongWord; //{$EXTERNALSYM HWND}
  THandle = LongWord;
  PHandle = ^THandle;
  HLOCAL = THandle; //{$EXTERNALSYM HLOCAL}

function FormatMessage(dwFlags: DWORD; lpSource: Pointer;
  dwMessageId: DWORD; dwLanguageId: DWORD; lpBuffer: PChar;
  nSize: DWORD; Arguments: Pointer): DWORD; stdcall;
  external kernel32 name 'FormatMessageA'; //{$EXTERNALSYM FormatMessage}

function LocalFree(hMem: HLOCAL): HLOCAL; stdcall;
  external kernel32 name 'LocalFree'; //{$EXTERNALSYM LocalFree}

function trimStr(const S: string): string;
var
  i, Len: integer;
begin
  i := 1;
  Len := Length(S);
  while (i <= Len) and (S[i] <= ' ') do inc(i);
  if i > Len then Result := ''
  else begin
    while S[Len] <= ' ' do dec(Len);
    Result := Copy(S, i, Len - i + 1);
  end;
end;

function ErrStr(const ErrNo: Cardinal; const ShowErrNo: Boolean = YES;
  const AlwaysShowMessage: Boolean = YES): string;
const
  nomessage = 'Error message is not available';
const
  FORMAT_MESSAGE_ALLOCATE_BUFFER = $100; //{$EXTERNALSYM FORMAT_MESSAGE_ALLOCATE_BUFFER}
  FORMAT_MESSAGE_FROM_STRING = $400; //{$EXTERNALSYM FORMAT_MESSAGE_FROM_STRING}
  FORMAT_MESSAGE_FROM_HMODULE = $800; //{$EXTERNALSYM FORMAT_MESSAGE_FROM_HMODULE}
  FORMAT_MESSAGE_FROM_SYSTEM = $1000; //{$EXTERNALSYM FORMAT_MESSAGE_FROM_SYSTEM}
  FORMAT_MESSAGE_ARGUMENT_ARRAY = $2000; //{$EXTERNALSYM FORMAT_MESSAGE_ARGUMENT_ARRAY}
var
  buf: pChar;
begin //acommon
  SetLength(Result, FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM {or FORMAT_MESSAGE_FROM_HMODULE} or
    FORMAT_MESSAGE_ALLOCATE_BUFFER, nil, ErrNo, 0, @buf, high(Word), nil));
  if AlwaysShowMessage and (Result = '') then
    Result := nomessage
  else
    move(buf^, Result[1], length(Result));
  if ShowErrNo then
    Result := 'Error no. ' + intoHex(ErrNo, 2) + ' (' + IntoStr(ErrNo) + ')' + CR2 + Result;
  LocalFree(Cardinal(buf));
  Result := trimStr(Result);
end;

function GetLastError: DWORD; stdcall; external kernel32 name 'GetLastError'; {$EXTERNALSYM GetLastError}

function LastErrStr(const ShowErrNo: boolean = YES {LastErr is always show something}): string;
begin
  Result := ErrStr(GetLastError, ShowErrNo);
end;

//function ShowmsgYN(const title, text: string; const owner: integer = 0;
//  const DefaultYes: Boolean = YES): word; forward;

function MessageBoxEx(hWnd: HWND; lpText, lpCaption: PChar; uType: UINT; wLanguageId: Word): integer; stdcall;
  external user32 name 'MessageBoxExA'; {$EXTERNALSYM MessageBoxEx}

type
  TmsgKind = (mtWarning, mtError, mtInformation, mtConfirmation, mtConfirmYNCancel);

function _Showmsg(const msgKind: TmsgKind; title, text: string; const DefBtnYES: boolean): word; // hOwner: cardinal): word;
const
  { MessageBox() Flags }
  MB_OK = $00000000; // {$EXTERNALSYM MB_OK}
  MB_OKCANCEL = $00000001; //{$EXTERNALSYM MB_OKCANCEL}
  MB_ABORTRETRYIGNORE = $00000002; //{$EXTERNALSYM MB_ABORTRETRYIGNORE}
  MB_YESNOCANCEL = $00000003; //{$EXTERNALSYM MB_YESNOCANCEL}
  MB_YESNO = $00000004; // {$EXTERNALSYM MB_YESNO} windows
  MB_RETRYCANCEL = $00000005; //{$EXTERNALSYM MB_RETRYCANCEL}

  MB_ICONHAND = $00000010; // {$EXTERNALSYM MB_ICONHAND}
  MB_ICONQUESTION = $00000020; // {$EXTERNALSYM MB_ICONQUESTION}
  MB_ICONEXCLAMATION = $00000030; // {$EXTERNALSYM MB_ICONEXCLAMATION}
  MB_ICONASTERISK = $00000040; // {$EXTERNALSYM MB_ICONASTERISK}
  MB_USERICON = $00000080; // {$EXTERNALSYM MB_USERICON}
  MB_ICONWARNING = MB_ICONEXCLAMATION; // {$EXTERNALSYM MB_ICONWARNING}
  MB_ICONERROR = MB_ICONHAND; // {$EXTERNALSYM MB_ICONERROR}
  MB_ICONINFORMATION = MB_ICONASTERISK; // {$EXTERNALSYM MB_ICONINFORMATION}
  MB_ICONSTOP = MB_ICONHAND; // {$EXTERNALSYM MB_ICONSTOP}

  MB_DEFBUTTON1 = $00000000; // {$EXTERNALSYM MB_DEFBUTTON1}
  MB_DEFBUTTON2 = $00000100; // {$EXTERNALSYM MB_DEFBUTTON2}
  MB_APPLMODAL = $00000000; // {$EXTERNALSYM MB_APPLMODAL}
  MB_SYSTEMMODAL = $00001000; // {$EXTERNALSYM MB_SYSTEMMODAL}
  MB_TASKMODAL = $00002000; // {$EXTERNALSYM MB_TASKMODAL}
  MB_SETFOREGROUND = $00010000; // {$EXTERNALSYM MB_SETFOREGROUND}
  MB_TOPMOST = $00040000; // {$EXTERNALSYM MB_TOPMOST}

  Default_mbSet = mb_systemmodal + mb_SetForeGround + mb_TopMost;

const
  titles: array[TmsgKind] of string = ('Warning', 'Error!', 'Information', 'Confirmation', 'Confirmation');
  Default_mb = mb_systemmodal + mb_SetForeGround + mb_TopMost;
  mbSets: array[TmsgKind] of cardinal = (mb_IconExclamation or mb_DefButton2, mb_IconStop, mb_IconInformation, mb_IconQuestion, mb_IconQuestion);
  dash = CHAR_DASH;
var
  mbSet: cardinal;
begin
  mbSet := Default_mbSet or mbSets[msgKind];
  if msgKind in [mtWarning, mtConfirmation, mtConfirmYNCancel] then begin
    if msgKind = mtConfirmYNCancel then
      mbSet := mbSet or mb_YesNoCancel
    else
      mbSet := mbSet or mb_YesNo;
    if not DefBtnYES then mbSet := mbSet or MB_DEFBUTTON2;
  end;
  //if hOwner = 0 then
  //hOwner := CommonHandle;
  if title = dash then
    title := titles[msgKind];
  Result := MessageBoxEx(0 {hOwner}, pchar(text), pchar(title), mbSet, 0);
end;

function ShowLastErr(title: string = ''; const ShowErrNo: boolean = TRUE;
  const AlwaysShowMessage: Boolean = TRUE): word; overload; // hOwner: Cardinal = 0): word;
begin
  Result := _Showmsg(mtError, title, ErrStr(GetLastError, ShowErrNo, AlwaysShowMessage), FALSE); //, hOwner);
end;

function ShowmsgError(const ErrNo: integer; title: string = '';
  const ShowErrNo: boolean = TRUE; const AlwaysShowMessage: Boolean = TRUE): word; overload; // hOwner: Cardinal = 0): word;
begin
  Result := _Showmsg(mtError, title, ErrStr(ErrNo, ShowErrNo, AlwaysShowMessage), FALSE); //, hOwner);
end;

function ShowmsgError(const text: string; title: string = ''): word; overload; // hOwner: Cardinal = 0): word;
begin
  Result := _Showmsg(mtError, title, Text, FALSE); //, hOwner);
end;

function ShowmsgOK(const text: string; title: string = ''): word; // hOwner: Cardinal = 0): word;
begin
  Result := _Showmsg(mtInformation, title, Text, FALSE); //, hOwner);
end;

function ConfirmYN(const text: string; title: string = ''): word; // hOwner: Cardinal = 0): word;
begin
  Result := _Showmsg(mtConfirmation, title, Text, FALSE); //, hOwner);
end;

function ConfirmCritical(const text: string; title: string = '';
  const Default_YES: boolean = FALSE): word; // hOwner: Cardinal = 0): word;
begin
  Result := _Showmsg(mtWarning, title, Text, Default_YES); //, hOwner);
end;

function ConfirmCritical(const text: string; const Default_YES: boolean): word; overload;
begin
  Result := _Showmsg(mtWarning, 'Warning', Text, Default_YES); //, hOwner);
end;

function ConfirmYNCancel(const text: string; title: string = '';
  const Default_YES: boolean = FALSE): word; // hOwner: Cardinal = 0): word;
begin
  Result := _Showmsg(mtConfirmYNCancel, title, Text, Default_YES); //, hOwner);
end;

function ConfirmYNCancel(const text: string; const Default_YES: boolean): word; // hOwner: Cardinal = 0): word;
begin
  Result := _Showmsg(mtConfirmYNCancel, 'Confirmation', Text, Default_YES); //, hOwner);
end;

function MessageBox(hWnd: HWND; lpText, lpCaption: PChar; uType: UINT): Integer; stdcall;
  external user32 name 'MessageBoxA'; {$EXTERNALSYM MessageBox}

//function ConfirmCritical(const text: string; const Default_YES: boolean): word; overload;
//const
//  MB_DEFBUTTON1 = $00000000; MB_DEFBUTTON2 = $00000100;
//  MB_ICONEXCLAMATION = $00000030; MB_YESNO = $00000004;
//  MBYN = MB_ICONEXCLAMATION or MB_YESNO;
//var
//  MB: WORD;
//begin
//  if Default_YES then MB := MBYN or MB_DEFBUTTON1
//  else MB := MBYN or MB_DEFBUTTON2;
//  Result := MessageBox(0, pChar(text), 'Confirmation', MB);
//end;

{$IFNDEF SYSUTILS}

procedure InitError;
var
  Err: Error;
begin
  System.ExceptionClass := Error;
  System.ErrorProc := @ErrorHandler;
  System.ExceptClsProc := @Err;
  System.ExceptObjProc := @Err;
end;

initialization InitError
{$ENDIF NO SYSUTILS}

end.


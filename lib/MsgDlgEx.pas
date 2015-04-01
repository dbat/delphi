unit MsgDlgEx;

interface

uses Dialogs, Forms;

{
TMsgDlgType
  mtWarning       A message box containing a yellow exclamation point symbol.
  mtError         A message box containing a red stop sign.
  mtInformation   A message box containing a blue "i".
  mtConfirmation  A message box containing a green question mark.
  mtCustom        A message box containing no bitmap.

TMsgDlgBtn = (
  mbYes, mbNo, mbOK, mbCancel,
  mbAbort, mbRetry, mbIgnore,
  mbAll, mbNoToAll, mbYesToAll, mbHelp
  );

TMsgDlgButtons = set of TMsgDlgBtn;

  In addition, there are three constants for commonly used buttons set:

  mbYesNoCancel = [mbYes, mbNo, mbCancel]
  mbOKCancel = [mbOK, mbCancel]
  mbAbortRetryIgnore = [mbAbort, mbRetry, mbIgnore]

TModalResult = (
  mrNone, mrOK, mrCancel,
  mrAbort, mrRetry, mrIgnore,
  mrYes, mrNo,
  mrAll, mrNoToAll, mrYesToAll
  );

}

function AskBox(const Caption: string; const Message: string; MsgDlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; DefaultButton: TModalResult; HelpContext: longint): TModalResult;

function AskNoMoreBox(const Caption: string; const Message: string;
  MsgDlgType: TMsgDlgType; Buttons: TMsgDlgButtons; DefaultButton: TModalResult;
  HelpContext: longint; var askNoMore: Boolean): TModalResult;

implementation

uses Windows, Classes, Controls, stdctrls, sysutils;

const { Copied from Dialogs }
  ModalResults: array[TMsgDlgBtn] of integer = (mrYes, mrNo, mrOk,
    mrCancel, mrAbort, mrRetry, mrIgnore, mrAll, mrNoToAll, mrYesToAll, 0);

var { Filled during unit initialization }
  ButtonCaptions: array[TMsgDlgBtn] of string;

  { Convert a modal result to a TMsgDlgBtn code. }
function ModalResultToBtn(res: TModalResult): TMsgDlgBtn;
begin
  for Result := Low(Result) to High(Result) do //begin
    if ModalResults[Result] = res then Exit;
  //end; { For }
  Result := mbHelp; // to remove warning only
  Assert(False, 'ModalResultToBtn: unknown modalresult ' + IntToStr(res));
end; { ModalResultToBtn }

const
  SideMargin = 16;
  DoubleSideMargin = SideMargin * 2;

{ When the button captions on the message form are translated
  the button size and as a consequence the button positions need
  to be adjusted. }
procedure AdjustButtons(AForm: TForm);
var
  buttons: TList;
  btnWidth: integer;
  btnGap: integer;

  procedure CollectButtons;
  var
    i: integer;
  begin
    for i := 0 to AForm.Controlcount - 1 do
      if AForm.Controls[i] is TButton then
        buttons.Add(AForm.Controls[i]);
  end; { CollectButtons }

  procedure MeasureButtons;
  var
    i: integer;
    textrect: TRect;
    w: integer;
  begin
    btnWidth := TButton(buttons[0]).Width;
    AForm.Canvas.Font := AForm.Font;
    for i := 0 to buttons.Count - 1 do begin
      TextRect := Rect(0, 0, 0, 0);
      Windows.DrawText(AForm.canvas.handle,
        PChar(TButton(buttons[i]).Caption), -1, TextRect,
        DT_CALCRECT or DT_LEFT or DT_SINGLELINE);
      with TextRect do w := Right - Left - DoubleSideMargin; //16; //32???
      if w > btnWidth then btnWidth := w;
    end; { For }
    if buttons.Count > 1 then
      btnGap := TButton(buttons[1]).Left - TButton(buttons[0]).Left - TButton(buttons[0]).Width
    else
      btnGap := 0;
  end; { MeasureButtons }

  procedure SizeButtons;
  var
    i: integer;
  begin
    for i := 0 to buttons.Count - 1 do
      TButton(buttons[i]).Width := btnWidth;
  end; { SizeButtons }

type
  TJustify = (juLeftwise, juCenter, juRightwise);

  procedure ArrangeButtons(const Justify: TJustify = TJustify(2));
  var
    i: integer;
    total, left: integer;
  begin
    total := (buttons.Count - 1) * btnGap;
    for i := 0 to buttons.Count - 1 do
      Inc(total, TButton(buttons[i]).Width);
    left := (AForm.ClientWidth - total) div 2; // center
    if left < 0 then begin
      AForm.ClientWidth := AForm.Width + 2 * Abs(left);
      left := abs(left);
    end; { If }
    if (Justify <> juCenter) and (Left > SideMargin) then begin
      if Justify = juLeftWise then
        Left := SideMargin
      else
        Left := AForm.ClientWidth - total - SideMargin;
    end;
    for i := 0 to buttons.Count - 1 do begin
      TButton(buttons[i]).Left := left;
      Inc(left, btnWidth + btnGap);
    end;

  end; { ArrangeButtons }
begin
  buttons := TList.Create;
  try
    CollectButtons;
    if buttons.Count = 0 then Exit;
    MeasureButtons;
    SizeButtons;
    ArrangeButtons();
  finally
    buttons.Free;
  end; { finally }
end; { AdjustButtons }

procedure InitMsgForm(AForm: TForm; const ACaption: string;
  helpContex: longint; DefaultButton: integer);
var
  i: integer;
  btn: TButton;
begin
  with AForm do begin
    if Length(ACaption) > 0 then
      Caption := ACaption;
    HelpContext := HelpContex;
    for i := 0 to ComponentCount - 1 do begin
      if Components[i] is TButton then begin
        btn := TButton(Components[i]);
        btn.Default := btn.ModalResult = DefaultButton;
        if btn.Default then ActiveControl := Btn;
{.$DEFINE STANDARDCAPTIONS}
{$IFNDEF STANDARDCAPTIONS}
        btn.Caption := ButtonCaptions[ModalResultToBtn(btn.Modalresult)];
{$ENDIF}
      end;
    end; { For }
{$IFNDEF STANDARDCAPTIONS}
    AdjustButtons(AForm);
{$ENDIF}
  end;
end; { InitMsgForm }

{-- DefMessageDlg -----------------------------------------------------}
{: Creates a MessageDlg with translated button captions and a configurable
   default button and caption.
@Param ACaption   Caption to use for the dialog. If empty the default is used.
@Param Msg        message to display
@Param MsgDlgType type of dialog, see MessageDlg online help
@Param Buttons    buttons to display, see MessageDlg online help
@Param DefButton  ModalResult of the button that should be the default.
@Param HelpCtx    help context (optional)
@Returns the ModalResult of the dialog
}

function AskBox(const Caption: string; const Message: string;
  MsgDlgType: TMsgDlgType; Buttons: TMsgDlgButtons; DefaultButton: TModalResult;
  HelpContext: longint): TModalResult;
var
  Form: TForm;
begin { DefMessageDlg }
  Form := CreateMessageDialog(Message, MsgDlgType, Buttons);
  try
    InitMsgForm(Form, Caption, helpContext, DefaultButton);
    Result := Form.ShowModal;
  finally
    Form.Free;
  end;
end; { DefMessageDlg }

resourcestring
  AskNoMoreCaption = 'Don''t ask me again';

{-- MessageDlgWithNoMorebox -------------------------------------------}
{: Creates a MessageDlg with translated button captions and a configurable
   default button and caption.
@Param ACaption   Caption to use for the dialog. If empty the default is used.
@Param Msg        message to display
@Param DlgType    type of dialog, see MessageDlg online help
@Param Buttons    buttons to display, see MessageDlg online help
@Param DefButton  ModalResult of the button that should be the  default.
@Param HelpCtx    help context (optional)
@Param askNoMore  if this is passed in as True the function will directly
                  return the DefButton result. Otherwise a checkbox is
                  shown beneath the buttons which the user can check to
                  not have this dialog show up in the future. Its checked
                  state is returned in the parameter.
@Returns the ModalResult of the dialog
}

function AskNoMoreBox(const Caption: string; const Message: string;
  MsgDlgType: TMsgDlgType; Buttons: TMsgDlgButtons; DefaultButton: TModalResult;
  HelpContext: longint; var askNoMore: Boolean): TModalResult;
var
  Form: TForm;
  Chk: TCheckbox;
begin { MessageDlgWithNoMorebox }
  if askNoMore then
    Result := DefaultButton
  else begin
    Form := CreateMessageDialog(Message, MsgDlgType, Buttons);
    try
      InitMsgForm(Form, Caption, helpContext, DefaultButton);
      chk := TCheckbox.Create(Form);
      chk.Parent := Form;
      chk.SetBounds(SideMargin, Form.ClientHeight - 8, Form.Clientwidth - SideMargin * 2, chk.Height);
      chk.Checked := False;
      chk.Caption := AskNoMoreCaption;
      Form.Height := Form.Height + chk.Height + 8;
      Result := Form.ShowModal;
      askNoMore := chk.Checked;
    finally
      Form.Free;
    end;
  end;
end; { MessageDlgWithNoMorebox }

resourcestring
  cmbYes = '&Yes';
  cmbNo = '&No';
  cmbOK = 'OK';
  cmbCancel = 'Cancel';
  cmbHelp = '&Help';
  cmbAbort = '&Abort';
  cmbRetry = '&Retry';
  cmbIgnore = '&Ignore';
  cmbAll = '&All';
  cmbNoToAll = 'N&o to All';
  cmbYesToAll = 'Yes to &All';

procedure InitButtonCaptions;
begin
  ButtonCaptions[mbYes] := cmbYes;
  ButtonCaptions[mbNo] := cmbNo;
  ButtonCaptions[mbOK] := cmbOK;
  ButtonCaptions[mbCancel] := cmbCancel;
  ButtonCaptions[mbAbort] := cmbAbort;
  ButtonCaptions[mbRetry] := cmbRetry;
  ButtonCaptions[mbIgnore] := cmbIgnore;
  ButtonCaptions[mbAll] := cmbAll;
  ButtonCaptions[mbNoToAll] := cmbNoToAll;
  ButtonCaptions[mbYesToAll] := cmbYesToAll;
  ButtonCaptions[mbHelp] := cmbHelp;
end; { InitButtonCaptions }

initialization
  InitButtonCaptions;
end.


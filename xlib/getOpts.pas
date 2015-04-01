unit GetOpts;
{.$WEAKPACKAGEUNIT ON}
{$J-} //no-writeableconst
{$R-} //no-rangechecking
{$Q-} //no-overflowchecking
{.$D-} //no-debug
{
  unit Command Line utility
  purpose: get switch index and its respective values from commandline
  version: 1.0.0.1
  date: 2004-10-24
}
{
//  Copyright (c) 2004, aa, Adrian H., Ray AF. & Inge DR.
  Property of PT SOFTINDO Jakarta.
  All rights reserved.

  mailto:aa|AT|softindo|DOT|net, zero_inge|AT|yahoo|DOT|com
  http://delphi.softindo.net
}

interface
uses SysUtils;

const
  DEFAULT_SWITCH_CHAR = '/';
  DEFAULT_SWITCH_CHARSET = [DEFAULT_SWITCH_CHAR];
  BLANK_DELIMITER = #0;
  BLANK_SWITCH = '';

// Gets the switch index in CommandLine e.g. ParamStr(Index),
// Returns -1 if switch is not exist
function SwitchIndex(const Switch: Char; const SwitchChar: Char = DEFAULT_SWITCH_CHAR;
  const IgnoreCase: Boolean = TRUE): integer; overload;

// Collecting the next arguments following one particular switch
// Example:
//  -f "C:\DIR1" -f D:\DIR1\*.* -f D:\DIR2\FILES1.TXT
//  for switch = f, with default delimiter semicolon (;), will return:
//  "C:\DIR1;D:\DIR1\*.*;D:\DIR2\FILES1.TXT"

// NOTE:If delimiter is set to #0, then only the last value-
// will be returned (for this example = D:\DIR2\FILES1.TXT)
function GetSwitchValues(const Switch: Char; const Delimiter: Char = ';';
  const SwitchChar: Char = DEFAULT_SWITCH_CHAR; const IgnoreCase: Boolean = TRUE): string; overload;

// get list of values of arguments which not prepended by any switches
// SkipAfterSwitches : switches which might NOT preceding the values
//   that is (usually) the switch wich must have argument,
//   since any value after that (following), it must be its argument
function GetUnSwitchedValues(const SkipAfterSwitches: string; const Delimiter: Char = ';';
  const SwitchChar: Char = DEFAULT_SWITCH_CHAR; const IgnoreCase: boolean = TRUE): string; overload;

// Enhanced version, switchars = set, switch = string
function SwitchIndex(const Switch: string; const SwitchChars: TSysCharSet = DEFAULT_SWITCH_CHARSET;
  const IgnoreCase: Boolean = TRUE): integer; overload;
function GetSwitchValues(const Switch: string; const Delimiter: Char = ';';
  const SwitchChars: TSysCharSet = DEFAULT_SWITCH_CHARSET; const IgnoreCase: Boolean = TRUE): string; overload;
function GetUnSwitchedValues(const SkipAfterSwitches: array of string; const Delimiter: Char = ';';
  const SwitchChars: TSysCharSet = DEFAULT_SWITCH_CHARSET; const IgnoreCase: boolean = TRUE): string; overload;

implementation

function SwitchIndex(const Switch: string; const SwitchChars: TSysCharSet = DEFAULT_SWITCH_CHARSET;
  const IgnoreCase: Boolean = TRUE): integer; overload;
var
  S: string;
begin
  for Result := 1 to ParamCount do begin
    S := ParamStr(Result);
    if (SwitchChars = []) or ((length(S[1]) > 0) and (S[1] in SwitchChars)) then
      if IgnoreCase then begin
        if (AnsiCompareText(Copy(S, 2, Maxint), Switch) = 0) then
          Exit;
      end
      else begin
        if (AnsiCompareStr(Copy(S, 2, Maxint), Switch) = 0) then
          Exit;
      end;
  end;
  Result := -1;
end;

function SwitchIndex(const Switch: Char; const SwitchChar: Char = DEFAULT_SWITCH_CHAR;
  const IgnoreCase: Boolean = TRUE): integer; overload;
const
  WORDLEN = 2;
var
  S: string;
begin
  for Result := 1 to ParamCount do begin
    S := ParamStr(Result);
    if length(S) = WORDLEN then begin
      if S[1] = SwitchChar then begin
        if IgnoreCase then begin
          if upCase(S[WORDLEN]) = upCase(Switch) then
            Exit;
        end
        else begin
          if S[WORDLEN] = Switch then
            Exit;
        end;
      end;
    end;
  end;
  Result := -1;
end;

//======================================================================================

function GetUnSwitchedValues(const SkipAfterSwitches: string {TSysCharSet}; const Delimiter: Char = ';';
  const SwitchChar: Char = DEFAULT_SWITCH_CHAR; const IgnoreCase: boolean = TRUE): string; overload;
// SkipAfterSwitches : switches which might NOT preceding the values (ie. switches that need an argument/value after them)
// for instance, if switches /D (for input dir) and /F (for input file) or /O (for output dir/file)
// which are expecting for some arguments, then SkipAfterSwitches must be 'DFO' (order is not important);
// whereas flag switches /?, /H (for help) and /I (for ignorecase) need not be included

  function onSwitch(const S: string): boolean;
  begin
    Result := (length(S) = 2) and (S[1] = SwitchChar);
    if Result = TRUE then
      Result := pos(S[2], SkipAfterSwitches) > 0;
    if not Result and IgnoreCase then
      Result := pos(upCase(S[2]), SkipAfterSwitches) > 0;
  end;

const
  StripAmbiguousSwitch: boolean = TRUE;
var
  i: integer;
  S: string;
  CurState, PrevState: boolean;
begin
  Result := ''; PrevState := FALSE;
  for i := 1 to ParamCount do begin
    S := ParamStr(i); CurState := onSwitch(S);
    if i = 1 then begin
      if not (PrevState or CurState) then
        if not StripAmbiguousSwitch or ((length(S) > 0) and not (S[1] = SwitchChar)) then
          Result := S
    end
    else begin
      if not (PrevState or CurState) then
        if (Delimiter = #0) then begin
          if not StripAmbiguousSwitch or ((length(S) > 0) and not (S[1] = SwitchChar)) then
            Result := S
        end
        else if not StripAmbiguousSwitch or ((length(S) > 0) and not (S[1] = SwitchChar)) then begin
          if Result <> '' then Result := Result + Delimiter;
          Result := Result + S;
        end;
    end;
    PrevState := CurState;
  end;
end;

function GetUnSwitchedValues(const SkipAfterSwitches: array of string; const Delimiter: Char = ';';
  const SwitchChars: TSysCharSet = DEFAULT_SWITCH_CHARSET; const IgnoreCase: boolean = TRUE): string; overload;
// SkipAfterSwitches : switches which might NOT preceding the values

  function onSwitch(const S: string): boolean;
  var
    i: integer;
    Sn, Si: string;
  begin
    Result := (length(SkipAfterSwitches) > 0) and (length(S) > 1) and (S[1] in SwitchChars);
    if Result = TRUE then begin
      Sn := copy(S, 2, MaxInt);
      Result := FALSE;
      for i := low(SkipAfterSwitches) to high(SkipAfterSwitches) do begin
        Si := SkipAfterSwitches[i];
        Si := copy(Si, 2, MaxInt);
        if not IgnoreCase then
          Result := Sn = Si
        else
          Result := AnsiCompareText(Sn, Si) = 0;
        if Result = TRUE then break;
      end;
    end;
  end;

const
  StripAmbiguousSwitch: boolean = TRUE;
var
  i: integer;
  S: string;
  CurState, PrevState: boolean;
begin
  Result := ''; PrevState := FALSE;
  for i := 1 to ParamCount do begin
    S := ParamStr(i); CurState := onSwitch(S);
    if i = 1 then begin
      if not (PrevState or CurState) then
        if not StripAmbiguousSwitch or ((length(S) > 0) and not (S[1] in SwitchChars)) then
          Result := S;
    end
    else begin
      if not (PrevState or CurState) then begin
        if (Delimiter = #0) then begin
          if not StripAmbiguousSwitch or ((length(S) > 0) and not (S[1] in SwitchChars)) then
            Result := S
        end
        else if not StripAmbiguousSwitch or ((length(S) > 0) and not (S[1] in SwitchChars)) then begin
          if Result <> '' then Result := Result + Delimiter;
          Result := Result + S;
        end;
      end;
    end;
    PrevState := CurState;
  end;
end;

function GetUnboundArgsValues(const SwitchChars: TSysCharSet = DEFAULT_SWITCH_CHARSET; const Delimiter: Char = ';'): string;
var
  i: integer;
  S, Sp: string;
begin
  Result := '';
  for i := 1 to ParamCount do begin
    S := ParamStr(i);
    if (length(S) > 0) and not (S[1] in SwitchChars) then begin
      if i = 1 then
        Sp := S
      else
        Sp := ParamStr(i - 1);
      if (length(Sp) > 0) and not (Sp[1] in SwitchChars) then begin
        if (Delimiter = #0) then
          Result := S
        else begin
          if Result <> '' then Result := Result + Delimiter;
          Result := Result + S;
        end;
      end;
    end;
  end;
end;

function GetSwitchValues(const Switch: Char; const Delimiter: Char = ';';
  const SwitchChar: Char = DEFAULT_SWITCH_CHAR; const IgnoreCase: Boolean = TRUE): string; overload;
const
  WORDLEN = 2;
var
  i: integer;

  procedure getnextargs(var Value: string);
  var
    S: string;
  begin
    S := ParamStr(i + 1);
    if (length(S) > 0) and (S[1] <> SwitchChar) then begin
      if ('' = Value) or (Delimiter = #0) then
        Value := S
      else
        Value := Value + Delimiter + S;
    end;
  end;

var
  S: string;
begin
  Result := '';
  for i := 1 to ParamCount - 1 do begin
    S := ParamStr(i);
    if length(S) = WORDLEN then begin
      if (S[1] = SwitchChar) then begin
        if IgnoreCase then begin
          if upCase(S[WORDLEN]) = upCase(Switch) then
            getnextargs(Result)
        end
        else begin
          if S[WORDLEN] = Switch then
            getnextargs(Result)
        end;
      end;
    end;
  end;
  //end;
end;

function GetSwitchValues(const Switch: string; const Delimiter: Char = ';';
  const SwitchChars: TSysCharSet = DEFAULT_SWITCH_CHARSET; const IgnoreCase: Boolean = TRUE): string; overload;
var
  i: integer;

  procedure getnextargs(var Value: string);
  var
    S: string;
  begin
    S := ParamStr(i + 1);
    if (length(S) > 0) and not (S[1] in SwitchChars) then begin
      if ('' = Value) or (Delimiter = #0) then
        Value := S
      else
        Value := Value + Delimiter + S;
    end;
  end;

var
  S: string;
begin
  Result := '';
  for i := 1 to ParamCount do begin
    S := ParamStr(i);
    if (SwitchChars = []) or ((length(S[1]) > 0) and (S[1] in SwitchChars)) then
      if IgnoreCase then begin
        if (AnsiCompareText(Copy(S, 2, Maxint), Switch) = 0) then
          getnextargs(Result)
      end
      else begin
        if (AnsiCompareStr(Copy(S, 2, Maxint), Switch) = 0) then
          getnextargs(Result)
      end;
  end;
end;

end.


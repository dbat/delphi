unit kbpress;

interface
function KBPressed_CTRL: Boolean;
function KBPressed_ALT: Boolean;
function KBPressed_SHIFT: Boolean;

implementation
uses Windows;

function KBPressed_CTRL: Boolean;
var
  State: TKeyboardState;
begin
  GetKeyboardState(State);
  Result := ((State[VK_CONTROL] and 128) <> 0);
end;

function KBPressed_ALT: Boolean;
var
  State: TKeyboardState;
begin
  GetKeyboardState(State);
  Result := ((State[VK_MENU] and 128) <> 0);
end;

function KBPressed_SHIFT: Boolean;
var
  State: TKeyboardState;
begin
  GetKeyboardState(State);
  Result := ((State[VK_SHIFT] and 128) <> 0);
end;

end.




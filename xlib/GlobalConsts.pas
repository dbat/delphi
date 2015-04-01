unit GlobalConsts;
{$WEAKPACKAGEUNIT ON}
{$WRITEABLECONST OFF}

interface

function isAdmin: boolean;
function isWinNT: boolean;
function isWin9X: boolean;
function WinVersion: int64; // high: majorVersion; low: minorVersion
function WinVersionMajor: integer;
function WinVersionMinor: integer;
function WinBuildNumber: integer;
function WinPlatformID: integer;
function WinCSDVersion: string;

implementation
uses windows;

const
{$IFOPT J-}{$DEFINE J_OFF}{$J+}{$ENDIF}
  OSVerInfo: TOSVersionInfo = (dwOSVersionInfoSize: dword(-1));
{$IFDEF J_OFF}{$J-}{$ENDIF}

procedure __initWinVer;
begin
  with OSVerInfo do
    if dwOSVersionInfoSize <> dword(-1) then exit
    else dwOSVersionInfoSize := sizeof(OSVerInfo);
  GetVersionEx(OSVerInfo);
end;

function isWinNT: boolean;
asm
  call __initWinVer;
  mov edx,OSVerInfo.dwPlatformID; xor eax,eax;
  cmp edx,VER_PLATFORM_WIN32_NT; sete al
end;

function isWin9X: boolean;
asm
  call isWinNT; xor eax,1
end;

function WinVersion: int64;
asm
  call __initWinVer;
  mov eax,OSVerInfo.dwMajorVersion
  mov edx,OSVerInfo.dwMinorVersion
end;

function WinVersionMajor: integer;
asm
  jmp WinVersion;
end;

function WinVersionMinor: integer;
asm
  call WinVersion; xchg eax,edx
end;

function WinBuildNumber: integer;
asm
  call __initWinVer;
  mov eax,OSVerInfo.dwBuildNumber
end;

function WinPlatformID: integer;
asm
  call __initWinVer;
  mov eax,OSVerInfo.dwPlatformID
end;

function WinCSDVersion: string;
begin
  __initWinVer;
  Result := string(PChar(@OSVerInfo.szCSDVersion));
end;

function isAdmin: Boolean;
const
  //ERROR_NO_TOKEN = 1008;
  SECURITY_BUILTIN_DOMAIN_RID = $00000020;
  DOMAIN_ALIAS_RID_ADMINS = $00000220;
  SECURITY_NT_AUTHORITY: TSIDIdentifierAuthority = (Value: (0, 0, 0, 0, 0, 5));
const
  INVALID = INVALID_HANDLE_VALUE xor $19091969 or 1;
{$IFOPT J-}{$DEFINE J_OFF}{$J+}{$ENDIF}
  fIsAdmin: cardinal = INVALID;
{$IFDEF J_OFF}{$J-}{$ENDIF}
var
  i: integer;
  bSuccess: longbool;
  hAccessToken: THandle;
  ptgGroups: PTokenGroups;
  dwInfoBufferSize: DWORD;
  psidAdministrators: PSID;
begin
  Result := boolean(fIsAdmin);
  if fIsAdmin <> INVALID then exit;

  fIsAdmin := 0;
  //Result := FALSE;
  bSuccess := OpenThreadToken(GetCurrentThread, TOKEN_QUERY, TRUE, hAccessToken);
  if not bSuccess then begin
    if GetLastError = ERROR_NO_TOKEN then
      bSuccess := OpenProcessToken(GetCurrentProcess, TOKEN_QUERY, hAccessToken);
  end;
  if bSuccess then begin
    getMem(ptgGroups, 1024);
    bSuccess := GetTokenInformation(hAccessToken, TokenGroups,
      ptgGroups, 1024, dwInfoBufferSize);
    CloseHandle(hAccessToken);
    if bSuccess then begin
      AllocateAndInitializeSid(SECURITY_NT_AUTHORITY, 2,
        SECURITY_BUILTIN_DOMAIN_RID, DOMAIN_ALIAS_RID_ADMINS,
        0, 0, 0, 0, 0, 0, psidAdministrators);
{$IFOPT R+}{$DEFINE R_ON}{$R-}{$ENDIF}
      for i := 0 to ptgGroups.GroupCount - 1 do
        if EqualSid(psidAdministrators, ptgGroups.Groups[i].Sid) then begin
          //Result := TRUE;
          fIsAdmin := 1;
          Break;
        end;
{$IFDEF R_ON}{$R+}{$ENDIF}
      FreeSID(psidAdministrators);
    end;
    freeMem(ptgGroups);
  end;
  Result := boolean(fIsAdmin);
end;

end.


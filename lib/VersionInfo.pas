unit VersionInfo;
{$WEAKPACKAGEUNIT}
{
  Copyright (c) 2004, aa, Inge DR. & Adrian Hafizh.
  Property of PT SOFTINDO Jakarta.
  All rights reserved.

  mailto:aa|AT|softindo|DOT|net,  http://delphi.softindo.net

  version: 1.0.0.3
}
{.$D-}
interface

function VersionInfoText(const Filename: string; const DigitOnly: Boolean = FALSE): string; overload

implementation
const
  version = 'version.dll';

function GetFileVersionInfoSize(lptstrFilename: PChar; var zero: integer): integer; stdcall;
  external version name 'GetFileVersionInfoSizeA';
function GetFileVersionInfo(Filename: PChar; handle, vSize: integer; Data: Pointer): longbool; stdcall;
  external version name 'GetFileVersionInfoA';
function VerQueryValue(Block: Pointer; SubBlock: PChar; var Buffer: Pointer; var vSize: integer): longbool; stdcall;
  external version name 'VerQueryValueA';

function GetVersionNumber(const ExeName: string; var Version, Build: cardinal): Boolean;
type
  DWORD = longword;
  PVSFixedFileInfo = ^TVSFixedFileInfo;
  TVSFixedFileInfo = packed record
    Signature: DWORD; //         { e.g. $feef04bd }
    StrucVersion: DWORD; //      { e.g. $00000042 = "0.42" }
    FileVersionMS: DWORD; //     { e.g. $00030075 = "3.75" }
    FileVersionLS: DWORD; //     { e.g. $00000031 = "0.31" }
    ProductVersionMS: DWORD; //  { e.g. $00030010 = "3.10" }
    ProductVersionLS: DWORD; //  { e.g. $00000031 = "0.31" }
    FileFlagsMask: DWORD; //     { = $3F for version "0.42" }
    FileFlags: DWORD; //         { e.g. VFF_DEBUG | VFF_PRERELEASE }
    FileOS: DWORD; //            { e.g. VOS_DOS_WINDOWS16 }
    FileType: DWORD; //          { e.g. VFT_DRIVER }
    FileSubtype: DWORD; //       { e.g. VFT2_DRV_KEYBOARD }
    FileDateMS: DWORD; //        { e.g. 0 }
    FileDateLS: DWORD; //        { e.g. 0 }
  end;
var
  VerInfoSize: integer;
  VerInfo: Pointer;
  VerValueSize: integer;
  VerValue: PVSFixedFileInfo;
  zero: integer;
begin
  VerInfoSize := GetFileVersionInfoSize(PChar(ExeName), zero);
  Result := VerInfoSize > 0;
  if Result = TRUE then begin
    GetMem(VerInfo, VerInfoSize);
    try
      GetFileVersionInfo(PChar(ExeName), 0, VerInfoSize, VerInfo);
      VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
      with VerValue^ do begin
        Version := FileVersionMS;
        Build := FileVersionLS;
      end;
    finally
      FreeMem(VerInfo, VerInfoSize);
    end
  end
end;

function VersionInfoText(const Filename: string; const DigitOnly: Boolean = FALSE): string;
const DOT = '.';
type
  tint = packed record
    lo, hi: word;
  end;
var
  Version, Build: Cardinal;
  v1, v2, v3, B: string;
begin
  if GetVersionNumber(Filename, Version, Build) = TRUE then begin
    Str(tint(Version).hi, v1);
    Str(tint(Version).lo, v2);
    Str(tint(Build).hi, v3);
    Str(tint(Build).lo, B);
    Result := v1 + DOT + v2 + DOT + v3;
    if DigitOnly then
      Result := Result + DOT + B
    else
      Result := 'Version ' + Result + ' (build ' + B + ')'
  end
  else
    if DigitOnly then
      Result := '0.0.0.0'
    else
      Result := 'Unknown';
end;

end.


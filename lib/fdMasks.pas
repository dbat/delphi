unit fdMasks;
interface
uses Classes, chPos;

function matchesMasks(const name, MaskStr: string;
  const delimiter: Char = ';'): boolean; overload;

function matchesMasks(const name, MaskStr: string;
  const delimiters: TChposCharSet): boolean; overload;

function matchesMasks(const name: string;
  const MaskStr: tStrings): boolean; overload;

function matchesMasks(const name: string; const mask:
  string; MaskStr: tStrings): boolean; overload;

function FilemaskExists(const Filemask: string; const asFile, asDir: boolean): Boolean; overload;
function FilemaskExists(const Dirname: string; const Filemasks: TStringList; const asFile, asDir: boolean): Boolean; overload;
//filemasks is semicolon-separated masks
function FilemaskExists(const Dirname, Filemasks: string; const asFile, asDir: boolean): Boolean; overload;

implementation

uses Windows, Masks, fdFuncs;

function matchesMasks(const name, MaskStr: string;
  const delimiter: Char): boolean; overload;
var
  i: integer;
  S: string;
begin
  Result := FALSE;
  if (name = '') or (MaskStr = '') then exit;
  i := 1;
  while i > 0 do begin
    S := Chpos.fetchWord(MaskStr, i, delimiter);
    S := Chpos.trimS(S);
    if (S = '') or (i < 0) then continue;
    Result := matchesMask(name, S);
    if Result = TRUE then break;
  end;
end;

function matchesMasks(const name, MaskStr: string;
  const delimiters: TChposCharSet): boolean; overload;
var
  i: integer;
  S: string;
begin
  Result := FALSE;
  if (name = '') or (MaskStr = '') then exit;
  i := 1;
  while i > 0 do begin
    S := Chpos.fetchWord(MaskStr, i, delimiters);
    S := Chpos.trimS(S);
    if (S = '') or (i < 0) then continue;
    Result := matchesMask(name, S);
    if Result = TRUE then break;
  end;
end;

function matchesMasks(const name: string;
  const MaskStr: tStrings): boolean; overload;
var
  i: integer;
begin
  Result := FALSE;
  if name <> '' then begin
    for i := 0 to MaskStr.Count - 1 do
      if matchesMask(name, MaskStr[i]) then begin
        Result := TRUE;
        break
      end
  end;
end;

function matchesMasks(const name: string; const mask:
  string; MaskStr: tStrings): boolean; overload;
begin
  Result := FALSE;
  if name <> '' then begin
    if mask <> '' then Result := matchesMask(name, mask);
    if not Result and assigned(MaskStr) then Result := matchesMasks(name, MaskStr);
  end;
end;

function FilemaskExists(const Filemask: string; const asFile, asDir: boolean): Boolean; overload;
var
  fh: THandle;
  Data: TWin32FindData;
  Root, name: string;
begin
  Result := FALSE;
  if (asDir or asFile) then begin
    Root := ExtractfileDir(Filemask);
    name := Extractfilename(Filemask);
    fh := Windows.FindFirstFile(PChar(Root + '\*.*'), Data);
    if fh <> INVALID_Handle_VALUE then begin
      Result := (name = '') and asDir;
      if not Result then repeat
          if Data.dwFileAttributes and faDirectory <> 0 then begin
            if not asDir then continue
          end
          else
            if not asFile then continue;
          if matchesmasks(string(Data.cFileName), Filemask) then begin
            Result := TRUE;
            break;
          end;
        until not windows.findnextfile(fh, Data);
      Windows.FindClose(fh);
    end;
  end;
end;

function FilemaskExists(const Dirname, filemasks: string; const asFile, asDir: boolean): Boolean; overload;
var
  fh: THandle;
  Data: TWin32FindData;
begin
  Result := FALSE;
  if (asDir or asFile) then begin
    fh := Windows.FindFirstFile(PChar(CatDir(Dirname, '*.*')), Data);
    if fh <> INVALID_Handle_VALUE then begin
      repeat
        if Data.dwFileAttributes and faDirectory <> 0 then begin
          if not asDir then continue
        end
        else
          if not asFile then continue;
        if matchesmasks(string(Data.cFileName), Filemasks) then begin
          Result := TRUE;
          break;
        end;
      until not windows.findnextfile(fh, Data);
      Windows.FindClose(fh);
    end;
  end;
end;

function FilemaskExists(const Dirname: string; const Filemasks: TStringList; const asFile, asDir: boolean): Boolean; overload;
var
  fh: THandle;
  Data: TWin32FindData;
begin
  Result := FALSE;
  if (asDir or asFile) then begin
    fh := Windows.FindFirstFile(PChar(CatDir(Dirname, '*.*')), Data);
    if fh <> INVALID_Handle_VALUE then begin
      repeat
        if Data.dwFileAttributes and faDirectory <> 0 then begin
          if not asDir then continue
        end
        else
          if not asFile then continue;
        if matchesmasks(string(Data.cFileName), Filemasks) then begin
          Result := TRUE;
          break;
        end;
      until not windows.findnextfile(fh, Data);
      Windows.FindClose(fh);
    end;
  end;
end;

end.


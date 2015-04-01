unit FileScan;
{$I QUIET.INC}
{.$WEAKPACKAGEUNIT ON}
{$J-} //no-writeableconst
{$R-} //no-rangechecking
{$Q-} //no-overflowchecking
{.$D-}//no-debug
{
  unit file processor
  high capability file scanner, scanning specified files in directories
  with full featured filter and (if wished) do some command on them
  version: 1.0.0.1
  date: 2004-10-24
  rev1: 2004-11-06
  rev2: 2005-01-03

  prototype:
     ScanForFiles(
       DirCount, FileCount: Match counter (mandatory)
       SearchMasks: List of wildcards of filenames to search for
         beware that default is empty which will be interpreted as ALL files
         it is the caller responsibility to handle if its not intended as so
       ExcludedSearchMasks: List of wildcards of filenames to be excluded in scanning
         note that default scan result WILL includes this (currently) running file,
         you MUST explicitly exclude the current file if required (as for delete, modify, etc);
       Directories: List of Directories to be searched for
       Recursive: whether or not search to be recursive
       FilesFoundList: if it isn't NIL, will be populated with matching files
       Command: CallBack procedure to be processed for each of file found
       CommandArgument: Should the command need an argument, usually a structure
       MinSize, MaxSize: Filesize range search
       MinDate, MaxDate: Time-limit of file
       Attribute, AttrMustHave: Attribute mask filter
       CheckReservedName: Whether valid filenames would be checked first // slows down slightly
       MaskDelimiter: delimiter for list of directories, files & excluded-files
  );

  note:
  DirCount and FileCount MUST be supplied, the other arguments are optional
  matchesmasks works different (slightly) with filename findfirst/findnext function
  particularly when it's regarding with filename without extension
  e.g. filename NNNNN does NOT match mask "*n." (with dot), use mask "*n" instead
  the MatchesMaskDotFix used here simply remove single trailing dot from the mask
  the side-effect is, mask "*n." as "*n" will also match filename ABCDEF.XXN

  except the first-two, None of above arguments are mandatory.
  FilesProcessor tested as default to writeln(filename),
  beware that this writeln procedure might raise an exception on Windows GUI ($APPTYPE GUI)
  you HAVE TO supply the proper procedure/function for this FilesProcessor argument (or NIL),
  common uses such as collects the filenames to stringlist (already done with filelist anyway)
  note that filelist content (if any) will keep preserved,
  (manually clear the filelist before calling this procedure if it had to)
}
{
  Copyright (c) 2004, aa, Adrian H., Ray AF. & Inge DR.
  Property of PT SOFTINDO Jakarta.
  All rights reserved.

  mailto:aa|AT|softindo|DOT|net, zero_inge|AT|yahoo|DOT|com
  http://delphi.softindo.net
}

interface
uses SysUtils, Classes;

type
  TDelimitedList = string;
  TDelimitedMaskedList = TDelimitedList;
  TFilesProcessor = function(const FileName: string; const Parameter: pointer): integer;
  TScanFileStatistic = packed record
    CtrDir, CtrFileMatch, CtrFileNoMatch: integer;
  end;

  PFileSearchOptions = ^TFileSearchOptions;
  TFileSearchOptions = packed record
    OptRecursive, OptChkResv: Boolean;
    OptSizeMin, OptSizeMax: Cardinal;
    OptTimeStart, OptTimeEnd: Cardinal;
    OptAttribute, OptAttrMustHave: Cardinal;
  end;

  TFileScanMasks = record
    SearchMasks, ExcludedSearchMask: TDelimitedMaskedList;
    Directories: TDelimitedList;
    MaskDelimiter: char;
  end;

  TFileScanArguments = {packed} record
    SearchMasks, ExcludedSearchMask: TDelimitedMaskedList;
    Directories: TDelimitedList;
    SearchOptions: TFileSearchOptions;
    //MinSize, MaxSize: Cardinal;
    //MinDate, MaxDate: cardinal;
    //Attribute, AttrMustHave: cardinal;
    //Recursive, CheckReservedName: boolean;
    MaskDelimiter: char;
  end;

const
  // modify here to change default behaviour
  DEFAULT_SEARCHOP_RECURSIVE = FALSE;
  DEFAULT_SEARCHOP_SIZE_MIN = 0;
  DEFAULT_SEARCHOP_SIZE_MAX = high(Cardinal);
  DEFAULT_SEARCHOP_TIME_START = 0;
  DEFAULT_SEARCHOP_TIME_END = high(Cardinal);
  DEFAULT_SEARCHOP_ATTRIB = faAnyFile and not (faVolumeID);
  DEFAULT_SEARCHOP_ATTRMUST = 0;
  DEFAULT_SEARCHOP_CHECK_RESV_NAME = FALSE;
  DEFAULT_LIST_DELIMITER = ';';

function ScanFiles(
  out DirCount, FileCount: integer;
  const SearchMasks: TDelimitedMaskedList = '';
  const ExcludedSearchMasks: TDelimitedMaskedList = '';
  //const ExcludeCurrentProgram: Boolean = TRUE;
  const Directories: TDelimitedList = '';
  const Recursive: Boolean = DEFAULT_SEARCHOP_RECURSIVE;
  const FileList: TStrings = nil;
  const DirList: TStrings = nil;
  const FileCommand: TFilesProcessor = nil;
  const FileCmdArgument: pointer = nil;
  const DirCommand: TFilesProcessor = nil;
  const DirCmdArgument: pointer = nil;
  const MinSize: Cardinal = DEFAULT_SEARCHOP_SIZE_MIN;
  const MaxSize: Cardinal = DEFAULT_SEARCHOP_SIZE_MAX;
  const MinDate: Cardinal = DEFAULT_SEARCHOP_TIME_START;
  const MaxDate: cardinal = DEFAULT_SEARCHOP_TIME_END;
  const Attribute: integer = DEFAULT_SEARCHOP_ATTRIB;
  const AttrMustHave: integer = DEFAULT_SEARCHOP_ATTRMUST;
  const CheckReservedName: Boolean = DEFAULT_SEARCHOP_CHECK_RESV_NAME;
  const MaskDelimiter: Char = DEFAULT_LIST_DELIMITER
  ): integer; overload;

//function ScanFiles(out DirCount, FileCount: integer; ScanArguments: TFileScanArguments): integer; overload;
implementation

uses Masks;

const
  FILE_ATTRIBUTE_NORMAL = $80;
  FILE_ATTRIBUTE_TEMPORARY = $100;
  FILE_ATTRIBUTE_COMPRESSED = $800;

var
  SearchOp: TFileSearchOptions;
  //  SearchOp:TFileSearchOptions
  //  pulled-out, so it will not exhaust recursive function call stack

  //  const Recursive: Boolean = DEFAULT_SEARCHOP_RECURSIVE;
  //  const MinSize: Cardinal = DEFAULT_SEARCHOP_SIZE_MIN;
  //  const MaxSize: Cardinal = DEFAULT_SEARCHOP_SIZE_MAX;
  //  const MinDate: Cardinal = DEFAULT_SEARCHOP_TIME_START;
  //  const MaxDate: cardinal = DEFAULT_SEARCHOP_TIME_END;
  //  const Attr: integer = DEFAULT_SEARCHOP_ATTRIB;
  //  const CheckReservedName: Boolean = DEFAULT_SEARCHOP_CHECKRESVNAME

const
  DefaultSearchOption: TFileSearchOptions = (
    OptRecursive: DEFAULT_SEARCHOP_RECURSIVE;
    OptChkResv: DEFAULT_SEARCHOP_CHECK_RESV_NAME;
    OptSizeMin: DEFAULT_SEARCHOP_SIZE_MIN;
    OptSizeMax: DEFAULT_SEARCHOP_SIZE_MAX;
    OptTimeStart: DEFAULT_SEARCHOP_TIME_START;
    OptTimeEnd: DEFAULT_SEARCHOP_TIME_END;
    OptAttribute: DEFAULT_SEARCHOP_ATTRIB;
    OptAttrMustHave: DEFAULT_SEARCHOP_ATTRMUST;
    );

function CharPos(const Ch: Char; const S: string; const StartPos: integer = 1): integer;
// beware! this function is for ANSI character only
// deprecated in next release. use unit cxpos instead!
{
  Copyright (c) 2004, aa, Inge DR. & Adrian Hafizh.
  Property of PT SOFTINDO Jakarta.
  All rights reserved.

  mailto:aa|AT|softindo|DOT|net,
  http://delphi.softindo.net
}
asm
  or ecx, ecx
  jle @zero        // StartPos < 1
  test edx, edx
  jz @zero         // S = '' (blank)
  cmp ecx, edx-4   // properly written: dword ptr [edx-4]
  jle @goon        // StartPos <= length

  @zero:           // Result = 0
  xor eax, eax
  jmp @@end

  @goon:
  push edi
  mov edi, edx     // edi = S
  dec ecx
  add edi, ecx     // now edi = S[StartPos]
  sub ecx, edx-4   // offset to the end of S (negative)
  neg ecx          // bingo!

  repne scasb      // all we want to do actually

  sub edi, edx
  mov eax, edi
  pop edi
  @@end:
end;

function CharPosNoCase(const Ch: Char; const S: string; const StartPos: integer = 1): integer;
{
  Copyright (c) 2004, aa, Inge DR. & Adrian Hafizh.
  Property of PT SOFTINDO Jakarta.
  All rights reserved.

  mailto:aa|AT|softindo|DOT|net,
  http://delphi.softindo.net
}
// beware! this function is for ANSI character only
// deprecated in next release. use unit cxpos instead!
asm
  @@Start:
  or ecx, ecx
  jle @zero        // StartPos < 1
  test edx, edx
  jz @zero         // S = '' (blank)
  cmp ecx, edx-4   // properly written: dword ptr [edx-4]
  jle @goon        // StartPos <= length

  @zero:           // Result = 0
  xor eax, eax; jmp @@end

  @goon:
  push edi
  mov edi, edx     // edi = S
  dec ecx          // 1-based, offset by 1
  add edi, ecx     // now edi = S[StartPos]
  sub ecx, edx-4   // offset to the end of S (negative)
  neg ecx          // cx contains repeat count

  mov ah, al       // put char in AH
  or ah, 20h       // lowercase the char
  cmp ah, 'a'      // if AH (locase char) < 'a'
  jb @Sensi        // or > 'z'
  cmp ah, 'z'      // then...
  ja @Sensi        // use faster sensitive method instead

  cmp ah, al       // resulting AH must be between 'a'..'z'
  jne @Insensi     // if AH <> AL, then AL=upcase AH=locase
  and ah, not 20H  // else make AH to be upcase char

  @Insensi:
  scasb
  je @done
  cmp ah, byte ptr [edi-1]   // check again with AH
  je @done
  Loop @Insensi
  jmp @notfound

  @Sensi:
  clc              // might be carry
  repne scasb      // all we want to do actually
  jcxz @notfound
  jmp @done

  @notfound:       // slick, dx forced equal with di,
  mov edx, edi     // in order to resulting ax:00!

  @done:
  sub edi, edx
  mov eax, edi

  pop edi
  @@end:
end;

function ReservedName(const filename: TFileName): Boolean;
const
  DOT = '.';

  function BaseName0(const filename: TFileName): string;
  begin
    Result := ExtractFileName(filename);
    if CharPos(DOT, Result) > 1 then
      Result := Copy(Result, 1, CharPos(DOT, Result) - 1)
  end;

const
  STAR = '*';
  RSV_NAME1 = STAR + 'AUX' + STAR + 'CON' + STAR + 'PRN' + STAR;
  RSV_NAME2 = STAR + 'LPT' + STAR + 'COM' + STAR;

var
  S: string;

begin
  if SearchOp.OptChkResv then begin
    S := UpperCase(BaseName0(filename));
    case length(S) of
      length('AUX'): Result := Pos(STAR + S + STAR, RSV_NAME1) > 0;
      length('LPT1'): Result := (S[length('LPT1')] in ['0'..'7']) and
        (pos(STAR + copy(S, 1, length('LPT')) + STAR, RSV_NAME2) > 0);
    else
      Result := FALSE;
    end;
  end
  else
    Result := FALSE;
end;

function DotDir(const filename: TFileName): Boolean; //
const
  DOT = '.';
  DOTDOT = DOT + DOT;
begin
  Result := (DOT = filename) or (DOTDOT = filename);
end;

function MatchesMaskDotFix(name, mask: string): boolean;
const
  DOT = '.';
  // specialized matchesmask to (partly) overcome filename without extension slips
begin
  if '' = mask then
    Result := FALSE
  else begin
    if mask[length(mask)] = DOT then
      mask := copy(mask, 1, length(mask) - 1);
    Result := MatchesMask(name, mask);
  end;
end;

function FileMatchMasks(const filename: TFileName;
  const ListMasks, ListMasksExc: Tstrings): Boolean;
var
  i, j: integer;
begin
  Result := FALSE;
  for i := 0 to ListMasks.Count - 1 do begin
    if MatchesMaskDotFix(filename, ListMasks[i]) then begin
      Result := TRUE;
      for j := 0 to ListMasksExc.Count - 1 do begin
        if MatchesMaskDotFix(filename, ListMasksExc[j]) then begin
          Result := FALSE;
          break;
        end;
      end;
      break;
    end;
  end;
end;

const
  ANYFILE: string = '*.*';

function proceed_subdirs(out CtrDirs, CtrFiles: integer; const FileLister: TStrings = nil; DirLister: Tstrings = nil;
  const FileCommand: TFilesProcessor = nil; const FileCommandArg: pointer = nil; const DirCommand: TFilesProcessor = nil;
  const DirCommandArg: pointer = nil; const ListMasks: TStrings = nil; const ListMasksExc: Tstrings = nil;
  const ListDirs: TStrings = nil): integer;
var
  CtrMatch: integer;

  procedure DirScan(const Pathname: TFileName);
  const
    FOUND = 0;

  var
    shrek: TSearchRec;
    DirSlash: string;

    function filemet: boolean;
    begin
      Result := FALSE;

      if not DotDir(shrek.name) then begin
        if not ReservedName(shrek.name) then begin
          if (word(shrek.Attr) and faDirectory > 0) then begin
            if SearchOp.OptRecursive then
              DirScan(DirSlash + shrek.name);
          end
          else begin
            inc(CtrFiles);
            Result :=
              (Cardinal(shrek.Size) >= SearchOp.OptSizeMin)
              and (Cardinal(shrek.size) <= SearchOp.OptSizeMax)
              and (cardinal(shrek.Time) >= SearchOp.OptTimeStart)
              and (cardinal(shrek.Time) <= SearchOp.OptTimeEnd);

            if Result and (SearchOp.OptAttribute <> DEFAULT_SEARCHOP_ATTRIB) then begin
              //i'm lost...:(( please replace this messy with more efficient one
              {
              if (faReadOnly and SearchOp.Attrib = 0) then
                Result := Result and not (faReadOnly and shrek.Attr > 0);
              if (faHidden and SearchOp.Attrib = 0) then
                Result := Result and not (faHidden and shrek.Attr > 0);
              if (faSysFile and SearchOp.Attrib = 0) then
                Result := Result and not (faSysFile and shrek.Attr > 0);
              if (faArchive and SearchOp.Attrib = 0) then
                Result := Result and not (faArchive and shrek.Attr > 0);
              }

              Result := Result and (
                //(shrek.attr and faAnyFile = 0) or // -> shrek.Attr = FILE_ATTRIBUTE_NORMAL = $80
                (cardinal(shrek.attr) and faAnyFile = cardinal(SearchOp.OptAttribute) and faAnyFile) or
                (shrek.attr and SearchOp.OptAttribute > 0) // get only one that specified in SearchOp.Attrib
                ); // maybe this?
            end;
            Result := Result and (shrek.Attr and SearchOp.OptAttrMustHave = SearchOp.OptAttrMustHave);
            Result := Result and FileMatchMasks(shrek.Name, ListMasks, ListMasksExc);
            if Result = TRUE then
              inc(CtrMatch)
          end;
        end;
      end;
    end;

  var
    fullpathfilename: string;
  begin
    inc(CtrDirs);
    if (PathName <> '') then
      DirSlash := IncludeTrailingBackslash(PathName)
    else
      DirSlash := PathName;

    if assigned(DirLister) then DirLister.Add(PathName);
    if assigned(DirCommand) then DirCommand(PathName, DirCommandArg);

    if FindFirst(DirSlash + ANYFILE, DEFAULT_SEARCHOP_ATTRIB,
      //SearchOp.Attrib, //DEFAULT_SEARCHOP_ATTRIB, //(faAnyFile and not faVolumeID),
      shrek) = FOUND then begin
      if filemet then begin
        fullpathfilename := DirSlash + shrek.Name;
        if assigned(FileLister) then FileLister.Add(fullpathfilename);
        if assigned(FileCommand) then FileCommand(ExpandFileName(fullpathfilename), FileCommandArg);
      end;
      while FindNext(shrek) = FOUND do
        if filemet then begin
          fullpathfilename := DirSlash + shrek.Name;
          if assigned(FileLister) then FileLister.Add(fullpathfilename);
          if assigned(FileCommand) then FileCommand(ExpandFileName(fullpathfilename), FileCommandArg);
        end;
      FindClose(shrek);
    end;
  end;

var
  i: integer;

begin
  CtrDirs := 0; CtrFiles := 0; CtrMatch := 0;
  for i := 0 to ListDirs.Count - 1 do
    DirScan(ListDirs[i]);
  Result := CtrMatch;
end;

function WordList(out List: Tstrings; const Words: string = '';
  const Delimiter: Char = DEFAULT_LIST_DELIMITER;
  const DirKindCheck: Boolean = FALSE): integer;

  function min(a, b: integer): integer;
  asm
    cmp a, b; jle @end
    mov a, b
    @end:
  end;

var
  i, j, k, L, n: integer;
  tobecontinued: boolean;
  LS: TStringList;
  S: string;
begin
  List.Clear;
  Result := 0;
  if (Words <> '') then begin
    i := CharPos(Delimiter, words);
    if i = 0 then begin
      Result := 1;
      List.Add(words)
    end
    else begin
      i := 1;
      L := length(words);
      LS := TStringList.Create;
      LS.Sorted := TRUE;
      try
        while i <= L do begin
          while (i <= L) and (words[i] = Delimiter) do
            inc(i); //words[i] in Delimiters do inc(i)
          if (i <= L) then inc(Result);
          S := '';
          while (i <= L) and (words[i] <> Delimiter) do begin // not words[i] in Delimiters do begin
            S := S + words[i];
            inc(i);
          end;
          S := uppercase(S);
          if (S <> '') and (List.IndexOf(S) < 0) then begin
            if DirKindCheck then begin
              if LS.Count = 0 then
                LS.Add(S)
              else begin
                tobecontinued := FALSE;
                for j := 0 to LS.Count - 1 do begin
                  k := min(length(S), length(LS[j]));
                  if copy(S, 1, k) = copy(LS[j], 1, k) then begin
                    if length(LS[j]) > k then begin
                      n := List.IndexOf(LS[j]); // n MUST be >= 0 !!!
                      List[n] := S;
                      // DO NOT do this on sorted stringlist
                      // LS[j] := S;
                      LS.Delete(j);
                      LS.Add(S);
                    end;
                    tobecontinued := TRUE;
                    break;
                  end;
                end;

                if tobecontinued then continue;
                LS.Add(S);
              end; // of DirKindCheck
            end;
            List.Add(S);
            inc(Result);
          end;
        end;
      finally
        LS.Free;
      end;
    end
  end;
end;

procedure BuildList(out List: Tstrings; const Text: string = ''; const Delimiter: Char =
  DEFAULT_LIST_DELIMITER; const DefaultEntry: string = ''; const DirKind: Boolean = FALSE);
begin
  List.Clear;
  if WordList(List, Text, Delimiter, DirKind) < 1 then
    List.Add(DefaultEntry);
end;

procedure writeln_file(const filename: string; AnArgument: pointer);
begin
  writeln(filename);
  // do nothing with AnArgument
end;

//function ScanFiles(out DirCount, FileCount: integer; ScanArguments: TFileScanArguments): integer; overload;
//begin
//  result := 0;
//end;

function ScanFiles(
  out DirCount, FileCount: integer;
  const SearchMasks: TDelimitedMaskedList = '';
  const ExcludedSearchMasks: TDelimitedMaskedList = '';
  //const ExcludeCurrentProgram: Boolean = TRUE;
  const Directories: TDelimitedList = '';
  const Recursive: Boolean = DEFAULT_SEARCHOP_RECURSIVE;
  //const FilesFoundList: TStrings = nil;
  //const Command: TFilesProcessor = nil;
  //const CommandArgument: pointer = nil;
  const FileList: TStrings = nil;
  const DirList: TStrings = nil;
  const FileCommand: TFilesProcessor = nil;
  const FileCmdArgument: pointer = nil;
  const DirCommand: TFilesProcessor = nil;
  const DirCmdArgument: pointer = nil;
  const MinSize: Cardinal = DEFAULT_SEARCHOP_SIZE_MIN;
  const MaxSize: Cardinal = DEFAULT_SEARCHOP_SIZE_MAX;
  const MinDate: Cardinal = DEFAULT_SEARCHOP_TIME_START;
  const MaxDate: cardinal = DEFAULT_SEARCHOP_TIME_END;
  const Attribute: integer = DEFAULT_SEARCHOP_ATTRIB;
  const AttrMustHave: integer = DEFAULT_SEARCHOP_ATTRMUST;
  const CheckReservedName: Boolean = DEFAULT_SEARCHOP_CHECK_RESV_NAME;
  const MaskDelimiter: Char = DEFAULT_LIST_DELIMITER
  ): integer;

var
  ListFileMasks, ListExcludedFileMasks, ListDirectories: TStrings;
  FilesProcessor: TFilesProcessor;
  //  DirCount, FileCount: integer;
begin
  ListFileMasks := TStringList.Create;
  ListExcludedFileMasks := TStringList.Create;
  ListDirectories := TStringList.Create;
  try
    BuildList(ListDirectories, Directories, MaskDelimiter, '', TRUE);
    BuildList(ListFileMasks, SearchMasks, MaskDelimiter, '*');
    BuildList(ListExcludedFileMasks, ExcludedSearchMasks, MaskDelimiter, '');

    with SearchOp do begin
      OptRecursive := Recursive;
      OptSizeMin := MinSize;
      OptSizeMax := MaxSize;
      OptTimeStart := MinDate;
      OptTimeEnd := MaxDate;
      OptAttribute := Attribute;
      OptAttrMustHave := AttrMustHave;
      OptChkResv := CheckReservedName;
    end;

    // test for command, put a comment on them on final production
    FilesProcessor := nil;
    if assigned(FileCommand) then
      FilesProcessor := FileCommand
{$IFDEF DEBUG}
    else
      FilesProcessor := @writeln_file
{$ENDIF}
      ;
    //if assigned(filelist) then filelist.Clear;
    Result := proceed_subdirs(DirCount, FileCount, FileList, DirList, FilesProcessor,
      FileCmdArgument, DirCommand, DirCmdArgument, ListFileMasks, ListExcludedFileMasks,
      ListDirectories // MinSize, MaxSize, MinDate, MaxDate, Attribute, CheckReservedName
      );
  finally
    ListFileMasks.Free;
    ListExcludedFileMasks.Free;
    ListDirectories.Free;
  end;
end;

procedure SetDefaultSearch;
begin
  move(DefaultSearchOption, SearchOp, SizeOf(TFileSearchOptions));
end;

initialization
  SetDefaultSearch;

end.


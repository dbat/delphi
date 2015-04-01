////////////////////////////////////////////////////////////////////////////////
//
//                            BIOS Helper for Delphi
//
//               BIOS related utilities for Win32(i386) and Linux
//
////////////////////////////////////////////////////////////////////////////////
//
//  The Original Code is:
//   BiosHelp.pas, released 2001-09-02.
//
//  The Initial Developer of the Original Code is Nico Bendlin.
//
//  Portions created by Nico Bendlin are
//   Copyright (C) 2001-2003 Nico Bendlin. All Rights Reserved.
//
//  Contributor(s):
//   Nico Bendlin <nicode@gmx.net>
//
//  The contents of this file are subject to the Mozilla Public License Version
//  1.1 (the "License"); you may not use this file except in compliance with the
//  License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
//  Software distributed under the License is distributed on an "AS IS" basis,
//  WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
//  the specific language governing rights and limitations under the License.
//
//  Alternatively, the contents of this file may be used under the terms of
//  either the GNU General Public License Version 2 or later (the "GPL"), or
//  the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
//  in which case the provisions of the GPL or the LGPL are applicable instead
//  of those above. If you wish to allow use of your version of this file only
//  under the terms of either the GPL or the LGPL, and not to allow others to
//  use your version of this file under the terms of the MPL, indicate your
//  decision by deleting the provisions above and replace them with the notice
//  and other provisions required by the GPL or the LGPL. If you do not delete
//  the provisions above, a recipient may use your version of this file under
//  the terms of any one of the MPL, the GPL or the LGPL.
//
////////////////////////////////////////////////////////////////////////////////
//
//  Revision:
//
//    2003-02-15  2.00 [NicoDE]
//                     - generic dump method completely rewritten
//                     - default range is now E000:0000-F000:FFFF
//    2003-03-13  2.10 [NicoDE]
//                     - introduced basic Linux support (/dev/mem)
//    2003-04-10  2.20 [NicoDE]
//                     - changes for Borland CBuilder compability
//
////////////////////////////////////////////////////////////////////////////////
unit BIOSHelp;
{$MINENUMSIZE 4}
{$WEAKPACKAGEUNIT}
{$IFDEF CONDITIONALEXPRESSIONS}
{$IF Defined(CompilerVersion)}
{$IF CompilerVersion >= 14.5}
{$WARN UNSAFE_TYPE OFF}
{$WARN UNSAFE_CODE OFF}
{$IFEND}
{$IFEND}
{$ENDIF}
interface
{$NOINCLUDE System}
{$NOINCLUDE SysInit}
const
  ROMBIOSDumpBase = Cardinal($000C0000);
  ROMBIOSDumpBasePtr = Pointer(ROMBIOSDumpBase);
  ROMBIOSDumpEnd = Cardinal($000FFFFF);
  ROMBIOSDumpEndPtr = Pointer(ROMBIOSDumpEnd);
  ROMBIOSDumpSize = Cardinal(ROMBIOSDumpEnd - ROMBIOSDumpBase + 1);

type
  PROMBIOSDump = ^TROMBIOSDump;
  TROMBIOSDump = record
    ByteArray: array[0..ROMBIOSDumpSize - 1] of Byte;
  end;
  
type
  TRomDumpMethod = (
    rdmAutomatic, // Autodetect OS type and use proper method
    rdmGeneric, // Dump with external 16bit program (Win32)
    rdmMemory, // Dump from process' address space (Win9x)
    rdmPhysical, // Dump from physical memory object (WinNT)
    rdmDevMem // Dump from memory device /dev/mem (Linux)
    );
    
function DumpROMBIOS(out Dump: TROMBIOSDump; Method: TRomDumpMethod = rdmAutomatic; Timeout: Longword = 5000): Boolean;
function DumpROMBIOSEx(ROMBase: Pointer; RomSize: Cardinal; out Dump; Method: TRomDumpMethod = rdmAutomatic; Timeout: Longword = 5000): Boolean;
procedure ReadROMDumpBuffer(const Dump: TROMBIOSDump; Addr: Pointer; out Buffer; Size: Cardinal);
procedure ReadROMDumpBufferEx(const Dump; Base, Addr: Pointer; out Buffer; Size: Cardinal);
function GetROMDumpAddr(const Dump: TROMBIOSDump; Addr: Pointer): Pointer;
function GetROMDumpAddrEx(const Dump; Base, Addr: Pointer): Pointer;

implementation
uses
{$IFDEF WIN32}
  Windows;
{$ELSE}
{$IFDEF LINUX}
  Libc;
{$ELSE}
{$MESSAGE ERROR 'BIOSHelp: Unsupported Target Platform'}
{$ENDIF}
{$ENDIF}
{$IFDEF LINUX}
const
  ERROR_SUCCESS = 0;
  ERROR_INVALID_PARAMETER = EINVAL;
  ERROR_CALL_NOT_IMPLEMENTED = ENOSYS;
function SetLastError(Error: Longword): Longword;
var
  errno: PInteger;
begin
  errno := __errno_location();
  Result := Longword(errno^);
  Longword(errno^) := Error;
end;
{$ENDIF}
////////////////////////////////////////////////////////////////////////////////
//
//  DumpROMBIOS16 (rdmGeneric)
//
//    Creates an 16-bit EXE program in TEMP and runs it redirected to an file.
//
//    WARNING: One day 16-bit code will not run on future Windows.
//    WARNING: You are dumping the BIOS inside the MS-DOS 'emulator'.
//
{$IFDEF WIN32}
function _ROMDumpCode(ROMBase: Pointer; ROMSize: Cardinal; out Code: Pointer; out Size: Cardinal): Boolean;
const
  BlockSize = $1000;
type { ; ROMDump (dumps memory to STDOUT)     }
  PROMDumpCode = ^TROMDumpCode; { ; Copyright (C) 2003 Nico Bendlin      }
  TROMDumpCode = packed record { ; (BlockSize MUST be multiple of 10h)  }
    head: TImageDosHeader; {                                        }
    note: array[0..$4F] of AnsiChar; { @@note: db      'ROMDump', ...         }
    init: packed record { @@init:                                }
      x00050: array[0..2] of Byte; {         mov     ax, 4400h              }
      x00053: array[0..2] of Byte; {         mov     bx, 0001h              }
      x00056: array[0..1] of Byte; {         int     21h                    }
      x00058: array[0..1] of Byte; {         jc      @@code                 }
      x0005A: array[0..3] of Byte; {         and     dx, 0082h              }
      x0005E: array[0..3] of Byte; {         cmp     dx, 0082h              }
      x00062: array[0..1] of Byte; {         jne     @@code                 }
      x00064: Byte; {         push    cs                     }
      x00065: Byte; {         push    ds                     }
      x00066: array[0..2] of Byte; {         mov     dx, offset @@note      }
      x00069: array[0..1] of Byte; {         mov     ah, 09h                }
      x0006B: array[0..1] of Byte; {         int     21h                    }
      x0006D: array[0..2] of Byte; {         mov     ax, 4C01h              }
      x00070: array[0..1] of Byte; {         int     21h                    }
    end; {                                        }
    code: packed record { @@code:                                }
      x00072: Byte; BlockCount: Word; {         mov     cx, <BlockCount>       }
      x00075: Byte; DatSegment: Word; {         mov     dx, <DatSegment>       }
      x00078: array[0..1] of Byte; {         jcxz    @@last                 }
    end; {                                        }
    loop: packed record { @@loop:                                }
      x0007A: Byte; {         push    cx                     }
      x0007B: Byte; {         push    dx                     }
      x0007C: array[0..1] of Byte; {         mov     ds, dx                 }
      x0007E: Byte; DatOffset: Word; {         mov     dx, <DatOffset>        }
      x00081: array[0..2] of Byte; {         mov     cx, <BlockSize>        }
      x00084: array[0..2] of Byte; {         mov     bx, 0001h              }
      x00087: array[0..2] of Byte; {         mov     ax, 4000h              }
      x0008A: array[0..1] of Byte; {         int     21h                    }
      x0008C: Byte; {         pop     dx                     }
      x0008D: Byte; {         pop     cx                     }
      x0008E: array[0..1] of Byte; {         jc      @@exit                 }
      x00090: array[0..3] of Byte; {         add     dx, <BlockSize / 10h>  }
      x00094: array[0..1] of Byte; {         loop    @@loop                 }
    end; {                                        }
    last: packed record { @@last:                                }
      x00096: array[0..1] of Byte; {         mov     ds, dx                 }
      x00098: Byte; DatOffset: Word; {         mov     dx, <DatOffset>        }
      x0009B: Byte; LenghtMod: Word; {         mov     cx, <LenghtMod>        }
      x0009E: array[0..2] of Byte; {         mov     bx, 0001h              }
      x000A1: array[0..2] of Byte; {         mov     ax, 4000h              }
      x000A4: array[0..1] of Byte; {         jcxz    @@exit                 }
      x000A6: array[0..1] of Byte; {         int     21h                    }
      x000A8: array[0..1] of Byte; {         jc      @@exit                 }
      x000AA: array[0..1] of Byte; {         mov     al, 00h                }
    end; {                                        }
    exit: packed record { @@exit:                                }
      x000AC: array[0..1] of Byte; {         mov     ah, 4Ch                }
      x000AE: array[0..1] of Byte; {         int     21h                    }
    end; {                                        }
  end; {                                        }
const
  ROMDumpCodeSize = SizeOf(TROMDumpCode) - SizeOf(TImageDosHeader);
  ROMDumpCode: TROMDumpCode = (
    head: (
    e_magic: IMAGE_DOS_SIGNATURE;
    e_cblp: Word(ROMDumpCodeSize) and $1FF;
    e_cp: Word((ROMDumpCodeSize - 1) shr 9) + 1;
    e_crlc: $0000;
    e_cparhdr: SizeOf(TImageDosHeader) shr 4;
    e_minalloc: $0000;
    e_maxalloc: $FFFF;
    e_ss: $0000;
    e_sp: $1000;
    e_csum: $0000;
    e_ip: SizeOf(ROMDumpCode.note);
    e_cs: $0000;
    e_lfarlc: SizeOf(TImageDosHeader);
    e_ovno: $0000;
    e_res: ($0000, $0000, $0000, $0000);
    e_oemid: $0000;
    e_oeminfo: $0000;
    e_res2: (
    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000);
    _lfanew: $00000000
    );
    note: #13#10'BIOS-Dump 1.0.0.0'#13#10 +
    'Copyright (C) 2004-2007 PT Softindo, JAKARTA.'#13#10#13#10 +
    ''#13#10#13#10'$';
    init: (
    x00050: ($B8, $00, $44);
    x00053: ($BB, $01, $00);
    x00056: ($CD, $21);
    x00058: ($72, $18);
    x0005A: ($81, $E2, $82, $00);
    x0005E: ($81, $FA, $82, $00);
    x00062: ($75, $0E);
    x00064: $0E;
    x00065: $1F;
    x00066: ($BA, $00, $00);
    x00069: ($B4, $09);
    x0006B: ($CD, $21);
    x0006D: ($B8, $01, $4C);
    x00070: ($CD, $21);
    );
    code: (
    x00072: $B9; BlockCount: $0020;
    x00075: $BA; DatSegment: $E000;
    x00078: ($E3, $1C)
    );
    loop: (
    x0007A: $51;
    x0007B: $52;
    x0007C: ($8E, $DA);
    x0007E: $BA; DatOffset: $0000;
    x00081: ($B9, Lo(BlockSize), Hi(BlockSize));
    x00084: ($BB, $01, $00);
    x00087: ($B8, $00, $40);
    x0008A: ($CD, $21);
    x0008C: $5A;
    x0008D: $59;
    x0008E: ($72, $1C);
    x00090: ($81, $C2, Lo(BlockSize shr 4), Hi(BlockSize shr 4));
    x00094: ($E2, $E4)
    );
    last: (
    x00096: ($8E, $DA);
    x00098: $BA; DatOffset: $0000;
    x0009B: $B9; LenghtMod: $0000;
    x0009E: ($BB, $01, $00);
    x000A1: ($B8, $00, $40);
    x000A4: ($E3, $06);
    x000A6: ($CD, $21);
    x000A8: ($72, $02);
    x000AA: ($B0, $00)
    );
    exit: (
    x000AC: ($B4, $4C);
    x000AE: ($CD, $21)
    )
    );
begin
  Result := False;
  if (ROMSize > 0) and (ROMSize <= $100000) and
    (Cardinal(ROMBase) < $00100000) and
    (Cardinal(ROMBase) + ROMSize <= $00100000) then begin
    Size := SizeOf(TROMDumpCode);
    Code := Pointer(LocalAlloc(LPTR, Size));
    if Code <> nil then try
      PROMDumpCode(Code)^ := ROMDumpCode;
      with PROMDumpCode(Code)^ do begin
        code.BlockCount := Word(ROMSize div BlockSize);
        code.DatSegment := Word(Cardinal(ROMBase) shr 4);
        loop.DatOffset := Word(Cardinal(ROMBase)) and $000F;
        last.DatOffset := loop.DatOffset;
        last.LenghtMod := Word(ROMSize mod BlockSize);
      end;
      Result := True;
    except
      LocalFree(HLOCAL(Code));
      Code := nil;
      Size := 0;
    end;
  end;
end;

function _SaveROMDumpCodeToFile(ROMBase: Pointer; ROMSize: Cardinal; const Filename: string): Boolean;
var
  Code: Pointer;
  Size: Cardinal;
  Hand: THandle;
  Num: DWORD;
begin
  Result := False;
  if _ROMDumpCode(ROMBase, ROMSize, Code, Size) then try
    Hand := CreateFile(PChar(Filename), GENERIC_WRITE, FILE_SHARE_READ, nil,
      CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
    if Hand <> INVALID_HANDLE_VALUE then try
      Result := WriteFile(Hand, Code^, Size, Num, nil) and (Num = Size);
      if not Result then
        DeleteFile(PChar(Filename));
    finally
      CloseHandle(Hand);
    end;
  finally
    LocalFree(HLOCAL(Code));
  end;
end;
function _ExecuteROMDumpCode(const Code, Dump: string; Timeout: DWORD): Boolean;
var
  ComSpec: string;
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
  ErrorMode: Cardinal;
begin
  Result := False;
  SetLength(ComSpec, MAX_PATH + 1);
  SetLength(ComSpec,
    GetEnvironmentVariable('ComSpec', PChar(@ComSpec[1]), MAX_PATH));
  if Length(ComSpec) <= 0 then
    Exit;
  FillChar(StartInfo, SizeOf(TStartupInfo), 0);
  StartInfo.cb := SizeOf(TStartupInfo);
  StartInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartInfo.wShowWindow := SW_HIDE;
  ErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS or SEM_NOGPFAULTERRORBOX or
    SEM_NOALIGNMENTFAULTEXCEPT or SEM_NOOPENFILEERRORBOX);
  try
    if CreateProcess(nil, PChar(ComSpec + ' /C ' + Code + ' > ' + Dump),
      nil, nil, False, HIGH_PRIORITY_CLASS, nil, nil, StartInfo, ProcInfo) then try
      Result :=
        (WaitForSingleObject(ProcInfo.hProcess, Timeout) <> WAIT_TIMEOUT);
      if not Result then
        TerminateProcess(ProcInfo.hProcess, STATUS_TIMEOUT);
    finally
      CloseHandle(ProcInfo.hThread);
      CloseHandle(ProcInfo.hProcess);
    end;
  finally
    SetErrorMode(ErrorMode);
  end;
end;
{$ENDIF} // WIN32
function DumpROMBIOS16(ROMBase: Pointer; ROMSize: Cardinal; var Dump; Timeout: Longword): Boolean;
{$IFDEF WIN32}
var
  Tmp: array[0..MAX_PATH] of Char;
  Dmp: array[0..MAX_PATH] of Char;
  Exe: array[0..MAX_PATH] of Char;
  Hnd: THandle;
  Num: DWORD;
{$ENDIF}
begin
  Result := False;
{$IFDEF WIN32}
  if GetTempPath(MAX_PATH, Tmp) > 0 then
    GetShortPathName(Tmp, Tmp, MAX_PATH)
  else
    lstrcpy(Tmp, '.');
  if GetTempFileName(Tmp, '~rdmp', 0, Dmp) > 0 then try
    lstrcpy(Exe, Dmp);
    lstrcat(Exe, '.exe'); // Win9x requires .EXE extention
    if _SaveROMDumpCodeToFile(ROMBase, ROMSize, Exe) then try
      if _ExecuteROMDumpCode(Exe, Dmp, Timeout) then begin
        Hnd := CreateFile(Dmp, GENERIC_READ, FILE_SHARE_READ or
          FILE_SHARE_WRITE, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
        if Hnd <> INVALID_HANDLE_VALUE then try
          Result := ReadFile(Hnd, Dump, ROMSize, Num, nil) and (Num = ROMSize);
        finally
          CloseHandle(Hnd);
        end;
      end;
    finally
      DeleteFile(Exe);
    end;
  finally
    DeleteFile(Dmp);
  end;
{$ELSE}
  SetLastError(ERROR_CALL_NOT_IMPLEMENTED);
{$ENDIF}
end;
////////////////////////////////////////////////////////////////////////////////
//
//  DumpROMBIOS9x (rdmMemory)
//
//    Win9x maps the BIOS into every process - therefore it's directly accessed.
//
function DumpROMBIOS9x(ROMBase: Pointer; ROMSize: Cardinal; var Dump): Boolean;
begin
  Result := False;
  try
    Move(ROMBase^, Dump, ROMSize);
    Result := True;
  except
    // ignore exeptions
  end
end;
////////////////////////////////////////////////////////////////////////////////
//
//  DumpROMBIOSNT (rdmPhysical)
//
//    On WinNT the BIOS is accessable through section '\Device\PhysicalMemory'.
//    This object can only be opened by members of local 'Adminstrators' group.
//    ZwOpenSection and RtlNtStatusToDosError are documented in newer MSDN/DDK.
//
{$IFDEF WIN32}
type
  NTSTATUS = Integer;
  PUnicodeString = ^TUnicodeString;
  TUnicodeString = packed record
    Length: Word;
    MaximumLength: Word;
    Buffer: PWideChar;
  end;
  PObjectAttributes = ^TObjectAttributes;
  TObjectAttributes = record
    Length: ULONG;
    RootDirectory: THandle;
    ObjectName: PUnicodeString;
    Attributes: ULONG;
    SecurityDescriptor: PSecurityDescriptor;
    SecurityQualityOfService: PSecurityQualityOfService;
  end;
  TFNZwOpenSection = function(out Section: THandle; Access: ACCESS_MASK;
    Attributes: PObjectAttributes): NTSTATUS; stdcall;
  TFNRtlNtStatusToDosError = function(Status: NTSTATUS): DWORD; stdcall;
const
  PhysMemDevName = '\Device\PhysicalMemory';
  PhysMemName: TUnicodeString = (
    Length: Length(PhysMemDevName) * SizeOf(WideChar);
    MaximumLength: Length(PhysMemDevName) * SizeOf(WideChar) + SizeOf(WideChar);
    Buffer: PhysMemDevName;
    );
  PhysMemMask: ACCESS_MASK = SECTION_MAP_READ;
  PhysMemAttr: TObjectAttributes = (
    Length: SizeOf(TObjectAttributes);
    RootDirectory: 0;
    ObjectName: @PhysMemName;
    Attributes: $00000040; // OBJ_CASE_INSENSITIVE
    SecurityDescriptor: nil;
    SecurityQualityOfService: nil;
    );
var
  ZwOpenSection: TFNZwOpenSection;
  RtlNtStatusToDosError: TFNRtlNtStatusToDosError;
{$ENDIF} // WIN32
function DumpROMBIOSNT(ROMBase: Pointer; ROMSize: Cardinal; var Dump): Boolean;
{$IFDEF WIN32}
var
  HMod: HMODULE;
  Stat: NTSTATUS;
  Sect: THandle;
  View: Pointer;
{$ENDIF}
begin
  Result := False;
{$IFDEF WIN32}
  HMod := GetModuleHandle('ntdll.dll');
  if HMod = 0 then
    SetLastError(ERROR_CALL_NOT_IMPLEMENTED)
  else begin
    if not Assigned(ZwOpenSection) then
      ZwOpenSection := GetProcAddress(HMod, 'ZwOpenSection');
    if not Assigned(RtlNtStatusToDosError) then
      RtlNtStatusToDosError := GetProcAddress(HMod, 'RtlNtStatusToDosError');
    if not Assigned(ZwOpenSection) or not Assigned(RtlNtStatusToDosError) then
      SetLastError(ERROR_CALL_NOT_IMPLEMENTED)
    else begin
      Stat := ZwOpenSection(Sect, PhysMemMask, @PhysMemAttr);
      if Stat >= 0 then try
        View := MapViewOfFile(Sect, PhysMemMask, 0, Cardinal(ROMBase), ROMSize);
        if View <> nil then try
          Move(View^, Dump, ROMSize);
          Result := True;
        finally
          UnmapViewOfFile(View);
        end;
      finally
        CloseHandle(Sect);
      end
      else
        SetLastError(RtlNtStatusToDosError(Stat));
    end;
  end;
{$ELSE}
  SetLastError(ERROR_CALL_NOT_IMPLEMENTED);
{$ENDIF}
end;
////////////////////////////////////////////////////////////////////////////////
//
//  DumpROMBIOSMM (rdmDevMem)
//
//    The device /dev/mem is available on most Linux boxes. However, the device
//    would (and should) be only accessable by the superuser (root) and members
//    of the kmem group. So you have to use tools like fakeroot, setuid, or su.
//
function DumpROMBIOSMM(ROMBase: Pointer; ROMSize: Cardinal; var Dump): Boolean;
{$IFDEF LINUX}
var
  Mem: Integer;
  Map: Pointer;
{$ENDIF}
begin
  Result := False;
{$IFDEF LINUX}
  Mem := open('/dev/mem', O_RDONLY, 0);
  if Mem > 0 then try
    Map := mmap(nil, ROMSize, PROT_READ, MAP_SHARED, Mem, Integer(ROMBase));
    if Map <> MAP_FAILED then try
      Move(Map^, Dump, ROMSize);
      Result := True;
    finally
      munmap(Map, ROMSize);
    end;
  finally
    __close(Mem);
  end;
{$ELSE}
  SetLastError(ERROR_CALL_NOT_IMPLEMENTED);
{$ENDIF}
end;
////////////////////////////////////////////////////////////////////////////////
//
//  DumpROMBIOS(Ex)
//
//    Public functions to call OS-dependent implementations.
//
function DumpROMBIOS(out Dump: TROMBIOSDump; Method: TROMDumpMethod = rdmAutomatic; Timeout: Longword = 5000): Boolean;
begin
  Result := DumpROMBIOSEx(ROMBIOSDumpBasePtr, ROMBIOSDumpSize, Dump, Method, Timeout);
end;

function DumpROMBIOSEx(ROMBase: Pointer; ROMSize: Cardinal; out Dump; Method: TROMDumpMethod = rdmAutomatic; Timeout: Longword = 5000): Boolean;
begin
  Result := False;
  SetLastError(ERROR_SUCCESS);
  case Method of
    rdmAutomatic:
{$IFDEF WIN32}
      if (GetVersion() and $80000000) <> 0 then
        Result := DumpROMBIOS9x(ROMBase, ROMSize, Dump)
      else begin
        Result := DumpROMBIOSNT(ROMBase, ROMSize, Dump);
        if not Result then
          Result := DumpROMBIOS16(ROMBase, ROMSize, Dump, Timeout);
      end;
{$ELSE}
{$IFDEF LINUX}
      Result := DumpROMBIOSMM(ROMBase, ROMSize, Dump);
{$ENDIF}
{$ENDIF}
    rdmGeneric: Result := DumpROMBIOS16(ROMBase, ROMSize, Dump, Timeout);
    rdmMemory: Result := DumpROMBIOS9x(ROMBase, ROMSize, Dump);
    rdmPhysical: Result := DumpROMBIOSNT(ROMBase, ROMSize, Dump);
    rdmDevMem: Result := DumpROMBIOSMM(ROMBase, ROMSize, Dump);
  else
    SetLastError(ERROR_INVALID_PARAMETER);
  end;
end;
////////////////////////////////////////////////////////////////////////////////
//
//  ReadROMDumpBuffer(Ex) / GetROMDumpAddr(Ex)
//
//    Utilities to simplify the access to dumps.
//
procedure ReadROMDumpBuffer(const Dump: TROMBIOSDump; Addr: Pointer; out Buffer; Size: Cardinal);
begin
  Move(Pointer(Cardinal(@Dump) + Cardinal(Addr) - ROMBIOSDumpBase)^, Buffer, Size);
end;

procedure ReadROMDumpBufferEx(const Dump; Base, Addr: Pointer; out Buffer; Size: Cardinal);
begin
  Move(Pointer(Cardinal(@Dump) + Cardinal(Addr) - Cardinal(Base))^, Buffer, Size);
end;

function GetROMDumpAddr(const Dump: TROMBIOSDump; Addr: Pointer): Pointer;
begin
  Result := Pointer(Cardinal(@Dump) + Cardinal(Addr) - ROMBIOSDumpBase);
end;

function GetROMDumpAddrEx(const Dump; Base, Addr: Pointer): Pointer;
begin
  Result := Pointer(Cardinal(@Dump) + Cardinal(Addr) - Cardinal(Base));
end;

end.



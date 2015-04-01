unit BigIntX;
{$A+,Z4} // DO NOT CHANGE!!!
{ ***************************************************** }
{ Static Big Integer Library version: 1.0.0.0           }
{                                                       }
{ Copyright (C) 2005,2006, aa                           }
{ Property of PT SOFTINDO, Jakarta                      }
{                                                       }
{ License: Public Domain                                }
{ ***************************************************** }

{
CHANGES:

Version: 1.0.0.0, LastUpdated: 2006.0.0
  moved from ordinals.unit
  changed (part) licensing from Mozilla 1 and GNU GPL 1/2
  caution: big-division routines (>128) has not been thoroughly
           tested yet, expect some bugs within.
}

interface

type
{ currently of power of 2; max. practical limit: 2Gbits        }
{ please notice if you would make your own BigInt types,       }
{ it should be of 8-bytes fold and adjust IntegerSize table    }
{ (some routines may still accept dword (4 bytes) size though) }

{ common uses }
  PInt128 = ^int128;
  int128 = packed record
    case integer of
      -1: (_Lo, _Hi: int64);
      -9: (GUID: TGUID);
      00: (b: packed array[0..15] of byte);
      01: (w: packed array[0..07] of word);
      02: (I: packed array[0..03] of integer);
  end;

  PInt256 = ^int256;
  int256 = packed record
    case integer of
      -1: (_Lo, _Hi: Int128);
      -9: (GUID1, GUID2: TGUID);
      00: (b: packed array[0..31] of byte);
      01: (w: packed array[0..15] of word);
      02: (I: packed array[0..07] of integer);
      03: (Q: packed array[0..03] of int64);
  end;

  PInt512 = ^int512;
  int512 = packed record
    case integer of
      -1: (_Lo, _Hi: Int256);
      -9: (U: packed array[0..03] of TGUID);
      02: (I: packed array[0..15] of integer);
      03: (Q: packed array[0..07] of int64);
      04: (A: packed array[0..03] of Int128);
      //6: (B0, B1: Int256);
  end;

{ these structures are for intermediate users only }
  PInt1024 = ^int1024;
  int1024 = packed record
    case integer of
      -1: (_Lo, _Hi: Int512);
      -9: (U: packed array[0..07] of TGUID);
      02: (I: packed array[0..31] of integer);
      03: (Q: packed array[0..15] of int64);
      04: (A: packed array[0..07] of Int128);
      05: (B: packed array[0..03] of Int256);
      //7: (C0, C1: Int512);
  end;

  PInt2K = ^int2K;
  int2K = packed record
    case integer of
      -1: (_Lo, _Hi: Int1024);
      -9: (U: packed array[0..15] of TGUID);
      02: (I: packed array[0..63] of integer);
      03: (Q: packed array[0..31] of int64);
      04: (A: packed array[0..15] of Int128);
      05: (B: packed array[0..07] of Int256);
      06: (C: packed array[0..03] of Int512);
      //8: (D0, D1: Int1024);
  end;

  PInt4K = ^int4K;
  int4K = packed record
    case integer of
      -1: (_Lo, _Hi: Int2K);
      -9: (U: packed array[0..031] of TGUID);
      02: (I: packed array[0..127] of integer);
      03: (Q: packed array[0..063] of int64);
      04: (A: packed array[0..031] of Int128);
      05: (B: packed array[0..015] of Int256);
      06: (C: packed array[0..007] of Int512);
      07: (D: packed array[0..003] of Int1024);
      //9: (E0, E1: Int2048);
  end;

{ advanced user. the structure is more than sufficient enough }
{ for most demanding applications                             }
  PInt8K = ^int8K;
  int8K = packed record
    case integer of
      -1: (_Lo, _Hi: Int4K);
      -9: (U: packed array[0..063] of TGUID);
      02: (I: packed array[0..255] of integer);
      03: (Q: packed array[0..127] of int64);
      04: (A: packed array[0..063] of Int128);
      05: (B: packed array[0..031] of Int256);
      06: (C: packed array[0..015] of Int512);
      07: (D: packed array[0..007] of Int1024);
      08: (E: packed array[0..003] of Int2K);
      //10: (F0, F1: Int4096);
  end;

{ the structures after this is not for common usage }
  PInt16K = ^int16K;
  int16K = packed record
    case integer of
      -1: (_Lo, _Hi: Int8K);
      -9: (U: packed array[0..127] of TGUID);
      02: (I: packed array[0..511] of integer);
      03: (Q: packed array[0..255] of int64);
      04: (A: packed array[0..127] of Int128);
      05: (B: packed array[0..063] of Int256);
      06: (C: packed array[0..031] of Int512);
      07: (E: packed array[0..015] of Int1024);
      08: (F: packed array[0..007] of Int2K);
      09: (G: packed array[0..003] of Int4K);
      //10: (F0, F1: Int4096);
  end;

{ military confidential or very high profile commercial developers }
{ (with very specific task)                                        }
  PInt32K = ^int32K;
  int32K = packed record
    case integer of
      -1: (_Lo, _Hi: Int16K);
      -9: (U: packed array[0..0255] of TGUID);
      02: (I: packed array[0..1023] of integer);
      03: (Q: packed array[0..0511] of int64);
      04: (A: packed array[0..0255] of Int128);
      05: (B: packed array[0..0127] of Int256);
      06: (C: packed array[0..0063] of Int512);
      07: (D: packed array[0..0031] of Int1024);
      08: (F: packed array[0..0015] of Int2K);
      09: (G: packed array[0..0007] of Int4K);
      10: (H: packed array[0..0003] of Int8K);
      //10: (F0, F1: Int4096);
  end;

  PInt64K = ^int64K;
  int64K = packed record
    case integer of
      -1: (_Lo, _Hi: Int32K);
      -9: (U: packed array[0..0511] of TGUID);
      02: (I: packed array[0..2047] of integer);
      03: (Q: packed array[0..1023] of int64);
      04: (A: packed array[0..0511] of Int128);
      05: (B: packed array[0..0255] of Int256);
      06: (C: packed array[0..0127] of Int512);
      07: (D: packed array[0..0063] of Int1024);
      08: (E: packed array[0..0031] of Int2K);
      09: (F: packed array[0..0015] of Int4K);
      10: (G: packed array[0..0007] of Int8K);
      11: (H: packed array[0..0003] of Int16K);
      //10: (F0, F1: Int4096);
  end;

{ used only by determined heavy weight tester/benchmarker }
  PInt128K = ^int128K;
  int128K = packed record
    case integer of
      -1: (_Lo, _Hi: Int64K);
      -9: (U: packed array[0..1023] of TGUID);
      02: (I: packed array[0..4095] of integer);
      03: (Q: packed array[0..2047] of int64);
      04: (A: packed array[0..1023] of Int128);
      05: (B: packed array[0..0511] of Int256);
      06: (C: packed array[0..0255] of Int512);
      07: (D: packed array[0..0127] of Int1024);
      08: (E: packed array[0..0063] of Int2K);
      09: (F: packed array[0..0031] of Int4K);
      10: (G: packed array[0..0015] of Int8K);
      11: (H: packed array[0..0007] of Int16K);
      12: (II: packed array[0..003] of Int32K);
      //10: (F0, F1: Int4096);
  end;

  PInt256K = ^int256K;
  int256K = packed record
    case integer of
      -1: (_Lo, _Hi: Int128K);
      -9: (U: packed array[0..2047] of TGUID);
      02: (I: packed array[0..8191] of integer);
      03: (Q: packed array[0..4095] of int64);
      04: (A: packed array[0..2047] of Int128);
      05: (B: packed array[0..1023] of Int256);
      06: (C: packed array[0..0511] of Int512);
      07: (D: packed array[0..0255] of Int1024);
      08: (E: packed array[0..0127] of Int2K);
      09: (F: packed array[0..0063] of Int4K);
      10: (G: packed array[0..0031] of Int8K);
      11: (H: packed array[0..0015] of Int16K);
      12: (II: packed array[0..007] of Int32K);
      13: (QQ: packed array[0..003] of Int64K);
      //10: (F0, F1: Int4096);
  end;

  PInt512K = ^int512K;
  int512K = packed record
    case integer of
      -1: (_Lo, _Hi: Int256K);
      -9: (U: packed array[0..04095] of TGUID);
      02: (I: packed array[0..16383] of integer);
      03: (Q: packed array[0..08191] of int64);
      04: (A: packed array[0..04095] of Int128);
      05: (B: packed array[0..02047] of Int256);
      06: (C: packed array[0..01023] of Int512);
      07: (D: packed array[0..00511] of Int1024);
      08: (E: packed array[0..00255] of Int2K);
      09: (F: packed array[0..00127] of Int4K);
      10: (G: packed array[0..00063] of Int8K);
      11: (H: packed array[0..00031] of Int16K);
      12: (II: packed array[0..0015] of Int32K);
      13: (QQ: packed array[0..0007] of Int64K);
      14: (AA: packed array[0..0003] of Int128K);
      //10: (F0, F1: Int4096);
  end;

{ really serious, over confident; supposed to be brainiac post-grad scientist }
  PInt1024K = ^int1024K;
  int1024K = packed record
    case integer of
      -1: (_Lo, _Hi: Int512K);
      -9: (U: packed array[0..08191] of TGUID);
      02: (I: packed array[0..32767] of integer);
      03: (Q: packed array[0..16383] of int64);
      04: (A: packed array[0..08191] of Int128);
      05: (B: packed array[0..04095] of Int256);
      06: (C: packed array[0..02047] of Int512);
      07: (D: packed array[0..01023] of Int1024);
      08: (E: packed array[0..00511] of Int2K);
      09: (F: packed array[0..00255] of Int4K);
      10: (G: packed array[0..00127] of Int8K);
      11: (H: packed array[0..00063] of Int16K);
      12: (II: packed array[0..0031] of Int32K);
      13: (QQ: packed array[0..0015] of Int64K);
      14: (AA: packed array[0..0007] of Int128K);
      15: (BB: packed array[0..0003] of Int256K);
      //10: (F0, F1: Int4096);
  end;

  PInt2M = ^int2M;
  int2M = packed record
    case integer of
      -1: (_Lo, _Hi: Int1024K);
      -9: (U: packed array[0..16383] of TGUID);
      02: (I: packed array[0..65535] of integer);
      03: (Q: packed array[0..32767] of int64);
      04: (A: packed array[0..16383] of Int128);
      05: (B: packed array[0..08191] of Int256);
      06: (C: packed array[0..04095] of Int512);
      07: (D: packed array[0..02047] of Int1024);
      08: (E: packed array[0..01023] of Int2K);
      09: (F: packed array[0..00511] of Int4K);
      10: (G: packed array[0..00255] of Int8K);
      11: (H: packed array[0..00127] of Int16K);
      12: (II: packed array[0..0063] of Int32K);
      13: (QQ: packed array[0..0031] of Int64K);
      14: (AA: packed array[0..0015] of Int128K);
      15: (BB: packed array[0..0007] of Int256K);
      16: (CC: packed array[0..0003] of Int512K);
      //10: (F0, F1: Int4096);
  end;

  PInt4M = ^int4M;
  int4M = packed record
    case integer of
      -1: (_Lo, _Hi: Int2M);
      17: (DD: packed array[0..0003] of Int1024K);
  end;

{ wizard only with lots of patients;                            }
{ most users will never reach here since default stack is 1MB,  }
{ simple variable of int8M alone needs 1MB stack, hence it will }
{ bring out the stack overflow                                  }

  PInt8M = ^int8M;
  int8M = packed record
    case integer of
      -1: (_Lo, _Hi: Int4M);
      18: (EE: packed array[0..0003] of Int2M);
  end;

{ yoda, wizard gurus, with lots, lots of patients }
  PInt16M = ^int16M;
  int16M = packed record
    case integer of
      -1: (_Lo, _Hi: Int8M);
      19: (FF: packed array[0..0003] of Int4M);
  end;

{ maniac superhuman. stubborn and wealth (armored with powerful }
{ parallel computers - with [very] plenty of RAM)               }
  PInt32M = ^int32M;
  int32M = packed record
    case integer of
      -1: (_Lo, _Hi: Int16M);
      20: (GG: packed array[0..0003] of Int8M);
  end;

  PInt64M = ^int64M;
  int64M = packed record
    case integer of
      -1: (_Lo, _Hi: Int32M);
      21: (HH: packed array[0..0003] of Int16M);
  end;

{ either insane or idiot will (try to) use this. }
{ it doesn't even allowed by max stack           }
  PInt128M = ^int128M;
  int128M = packed record
    case integer of
      -1: (_Lo, _Hi: Int64M);
      22: (III: packed array[0..0003] of Int32M);
  end;

{ not human (nor have any living biological braincells) }
  PInt256M = ^int256M;
  int256M = packed record
    case integer of
      -1: (_Lo, _Hi: Int128M);
      23: (QQQ: packed array[0..0003] of Int64M);
  end;

{ next computer generation }
  PInt512M = ^int512M;
  int512M = packed record
    case integer of
      -1: (_Lo, _Hi: Int256M);
      24: (AAA: packed array[0..0003] of Int128M);
  end;

{ next computer revolution }
  PInt1024M = ^int1024M;
  int1024M = packed record
    case integer of
      -1: (_Lo, _Hi: Int512M);
      25: (BBB: packed array[0..0003] of Int256M);
  end;

{ next information technology era }
  PInt2G = ^int2G;
  int2G = packed record
    case integer of
      -1: (_Lo, _Hi: Int1024M);
      26: (CCC: packed array[0..0003] of Int512M);
  end;

{ next 3rd information technology era (after armageddon) }
  PInt4G = ^int4G;
  int4G = packed record
    case integer of
      -1: (_Lo, _Hi: Int2G);
      27: (DDD: packed array[0..0003] of Int1024M);
  end;

{ not applicable }
  PInt8G = ^int8G;
  int8G = packed record
    case integer of
      -1: (_Lo, _Hi: Int4G);
      28: (EEE: packed array[0..0003] of Int2G);
  end;

{ for reference only. any 32 bit OS won't even have any sufficient memory }
{ last to operate. even if it did, in my pc (P4-3GHz/HT), with current    }
{ intXtoStr routine implementation, it will take one and a half millenium }
{ to convert full bitmasked value (-1) into string (of length with more   }
{ than 5 billion digits).                                                 }
  PInt16G_1 = ^int16G_1;
  int16G_1 = packed record
    case integer of
      -1: (_Lo: int8G;
        case integer of
          -9: (U_: packed array[0..067108863 - 1] of TGUID);
          00: (y_: packed array[0..$40000000 - 2] of byte);
          01: (w_: packed array[0..$20000000 - 2] of word);
          02: (I_: packed array[0..$10000000 - 2] of integer);
          03: (Q_: packed array[0..$08000000 - 2] of int64);
          04: (A_: packed array[0..$04000000 - 2] of Int128);
          05: (B_: packed array[0..$02000000 - 2] of Int256);
          06: (C_: packed array[0..$01000000 - 2] of Int512);
          07: (D_: packed array[0..$00800000 - 2] of Int1024);
          08: (E_: packed array[0..$00400000 - 2] of Int2K);
          09: (F_: packed array[0..$00200000 - 2] of Int4K);
          10: (G_: packed array[0..$00100000 - 2] of Int8K);
          11: (H_: packed array[0..$00080000 - 2] of Int16K);
          12: (II_: packed array[0..$0040000 - 2] of Int32K);
          13: (QQ_: packed array[0..$0020000 - 2] of Int64K);
          14: (AA_: packed array[0..$0010000 - 2] of Int128K);
          15: (BB_: packed array[0..$0008000 - 2] of Int256K);
          16: (CC_: packed array[0..$0004000 - 2] of Int512K);
          17: (DD_: packed array[0..$0002000 - 2] of Int1024K);
          18: (EE_: packed array[0..$0001000 - 2] of Int2M);
          19: (FF_: packed array[0..$0000800 - 2] of Int4M);
          20: (GG_: packed array[0..$0000400 - 2] of Int8M);
          21: (HH_: packed array[0..$0000200 - 2] of Int16M);
          22: (III_: packed array[0..$000100 - 2] of Int32M);
          23: (QQQ_: packed array[0..$000080 - 2] of Int64M);
          24: (AAA_: packed array[0..$000040 - 2] of Int128M);
          25: (BBB_: packed array[0..$000020 - 2] of Int256M);
          26: (CCC_: packed array[0..$000010 - 2] of Int512M);
          27: (DDD_: packed array[0..$000008 - 2] of Int1024M);
          28: (EEE_: packed array[0..$000004 - 2] of Int2G);
          29: (FFF_: packed array[0..$000002 - 2] of Int4G);
          );
      -9: (U: packed array[0..134217727 - 1] of TGUID);
      00: (y: packed array[0..$80000000 - 2] of byte);
      01: (w: packed array[0..$40000000 - 2] of word);
      02: (I: packed array[0..$20000000 - 2] of integer);
      03: (Q: packed array[0..$10000000 - 2] of int64);
      04: (A: packed array[0..$08000000 - 2] of Int128);
      05: (B: packed array[0..$04000000 - 2] of Int256);
      06: (C: packed array[0..$02000000 - 2] of Int512);
      07: (D: packed array[0..$01000000 - 2] of Int1024);
      08: (E: packed array[0..$00800000 - 2] of Int2K);
      09: (F: packed array[0..$00400000 - 2] of Int4K);
      10: (G: packed array[0..$00200000 - 2] of Int8K);
      11: (H: packed array[0..$00100000 - 2] of Int16K);
      12: (II: packed array[0..$0080000 - 2] of Int32K);
      13: (QQ: packed array[0..$0040000 - 2] of Int64K);
      14: (AA: packed array[0..$0020000 - 2] of Int128K);
      15: (BB: packed array[0..$0010000 - 2] of Int256K);
      16: (CC: packed array[0..$0008000 - 2] of Int512K);
      17: (DD: packed array[0..$0004000 - 2] of Int1024K);
      18: (EE: packed array[0..$0002000 - 2] of Int2M);
      19: (FF: packed array[0..$0001000 - 2] of Int4M);
      20: (GG: packed array[0..$0000800 - 2] of Int8M);
      21: (HH: packed array[0..$0000400 - 2] of Int16M);
      22: (III: packed array[0..$000200 - 2] of Int32M);
      23: (QQQ: packed array[0..$000100 - 2] of Int64M);
      24: (AAA: packed array[0..$000080 - 2] of Int128M);
      25: (BBB: packed array[0..$000040 - 2] of Int256M);
      26: (CCC: packed array[0..$000020 - 2] of Int512M);
      27: (DDD: packed array[0..$000010 - 2] of Int1024M);
      28: (EEE: packed array[0..$000008 - 2] of Int2G);
      29: (FFF: packed array[0..$000004 - 2] of Int4G);
  end;

// thats all, see you later in 1024-bit OS :)

  tIntegerBits = (bitShortInt, bitSmallInt, bitInteger, bit64, bit128,
    bit256, bit512, bit1024, bit2K, bit4K, bit8K, bit16K,
    bit32K, bit64K, bit128K, bit256K, bit512K, bit1024K,
    bit2M, bit4M, bit8M, bit16M, bit32M, bit64M, bit128M,
    bit256M, bit512M, bit1024M, bit2G, bit4G, bit8G, bit16G);

  tBigInteger = succ(succ(succ(low(tIntegerBits))))..high(tIntegerBits);

procedure intXAdd(var BigIntA; const BigIntB; const IntType: tBigInteger);
procedure intXSub(var BigIntA; const BigIntB; const IntType: tBigInteger);

// Add with dword / qword
procedure incX(var BigInt; const I: integer; const IntType: tBigInteger);
procedure intXAddQ(var BigInt; const I: int64; const IntType: tBigInteger);

// Substract with dword / qword
procedure decX(var BigInt; const I: integer; const IntType: tBigInteger);
procedure intXSubQ(var BigInt; const I: int64; const IntType: tBigInteger);
function intXCmp(const BigIntA, BigIntB; const IntType: tBigInteger): integer;

{ get Smallest fit Integer size of given integer, with propsed type:IntType      }
{ (excludes zero extend on MSB [most significant bits])                          }
{ Beware that result is IN BYTES and may be 0 (an outbound range of BigInt type) }
function IntSmallestFit(const I; const ProposedIntType: tIntegerBits): tIntegerBits;

{ get specified BigInt type size in bytes }
function intXSize(const IntType: tBigInteger): integer;

{ intXSet/intXFill/intXFill8: fill BigInt with given value as pattern }
{ intXsetMMX is fast and should be used whenever possible             }
procedure intXSet(var BigInt; const IntType: tBigInteger; const Value: byte);
procedure intXSetMMX(var BigInt; const IntType: tBigInteger; const Value: byte);
procedure intXFill(var BigInt; const IntType: tBigInteger; const Value: integer);
procedure intXFill8(var BigInt; const IntType: tBigInteger; const Value: int64);

{ fast Division/Multiplication by power of 2 }
procedure intXshl(var BigInt; const IntType: tBigInteger; const ShiftCount: integer);
procedure intXshr(var BigInt; const IntType: tBigInteger; const ShiftCount: integer);

{ shiftLeft/right }
procedure ShiftDLeft(var Buffer; const DWORDCount, ShiftCount: integer);
procedure ShiftDRight(var Buffer; const DWORDCount, ShiftCount: integer);

{ multiplication; Result MUST be twice of IntType's wide;      }
{ Result may NOT be overlapped with multiplier or multiplicant }
procedure intXmul(const A, B; const IntType: tBigInteger; out BigIntResult); overload;

{ slow, generic bitshift Division; arguments must NOT be overlapped }
{ Dividend and remainder may NOT be overlapped                      }
procedure intXDivMod(var Dividend; const Divisor; out Remainder; const IntType: tBigInteger);

{ faster Multiplication; restricted by size of multiplicant/multiplicant }
{ Result: excess/high value carried (truncated by BigInt size)           }
function intXMulD(var BigInt; const Multiplier: longword; const IntType: tBigInteger): longword;
function intXMulQ(var BigInt; const Multiplier: int64; const IntType: tBigInteger): int64;
function int128MulD(var BigInt: int128; const Multiplier: longword): longword;
function int256MulD(var BigInt: int256; const Multiplier: longword): longword;

{ specific size of bitshift division; faster than generic bitshift division }
{ note: Result is Remainder                                                 }
function intXDivD(var BigInt; const Multiplier: Longword; const IntType: tBigInteger): integer; overload;
function intXDivQ(var Dividend; const Divisor: int64; const IntType: tBigInteger): int64;
function int128DivD(var Dividend: int128; const Divisor: longword): Longword;
function int128DivQ(var Dividend: int128; const Divisor: int64): int64;
function int128DivMod(var Dividend: int128; const Divisor: int128): int128;

{ conversion routines }
function intXtoStr(const BigInt; const IntType: tBigInteger): string;
function StrToIntX(const S: string; var BigInt; const IntType: tBigInteger): integer;
function HexToIntX(const S: string; var BigInt; const IntType: tBigInteger): integer;
procedure __fastMove(const Source; var Dest; Count: Integer);

// ========================================================================
// test area... do not use
// ========================================================================

procedure __intXClear8(var BigInt; const Count8: integer); overload;

{ ShiftLeft only }
{ for shiftcount mod 7 = 0 (full byte shift) SrcSize and DestSize can be of any size   }
{ for shiftcount mod 7 > 0 (NOT full byte shift) SrcSize and DestSize MUST be of dword }
{ (4 bytes) fold;  it will be treated as 4 bytes fold regardless of given size         }
procedure __shldd(var Source, Dest; const bitShiftCount, SrcSize, DestSize: integer);

procedure __dwDivMod_unfinished(var Dividend; const Divisor; out Remainder; DwordCount: integer);
//procedure __intXDivModD(var Dividend; const Divisor; out Remainder; intType: tBigInteger);

//original test, do not use; use int128DivMod instead
procedure int128DivMod_test1(var Dividend; const Divisor: int128; var Remainder: int128);

function WaitForSingleObject(hHandle: THandle; dwMilliseconds: longword): longword; stdcall; {$EXTERNALSYM WaitForSingleObject}
function WaitForMultipleObjects(nCount: integer; pHandles: pointer; bWaitAll: boolean; dwMilliseconds: longword): longword; stdcall; {$EXTERNALSYM WaitForMultipleObjects}
function CreateThread(SecurityAttributes: Pointer; StackSize: LongWord; ThreadFunc: TThreadFunc; Parameter: Pointer; CreationFlags: LongWord; var ThreadId: LongWord): Integer; stdcall; {$EXTERNALSYM CreateThread}
function CloseHandle(hanlde: thandle): boolean; stdcall; {$EXTERNALSYM CloseHandle}

implementation
uses ordinals, b2n;

const
{ max = 2147483647 bytes / 1073741824 bits }
  IntegerSize: packed array[tIntegerBits] of integer = (
    sizeof(ShortInt), sizeof(smallInt), sizeof(integer), sizeof(int64), sizeof(int128),
    sizeof(int256), sizeof(int512), sizeof(int1024), sizeof(int2K), sizeof(int4K),
    sizeof(int8K), sizeof(int16K), sizeof(int32K), sizeof(int64K), sizeof(int128K),
    sizeof(int256K), sizeof(int512K), sizeof(int1024K), sizeof(int2M), sizeof(int4M),
    sizeof(int8M), sizeof(int16M), sizeof(int32K), sizeof(int64K), sizeof(int128K),
    sizeof(int256K), sizeof(int512K), sizeof(int1024K), sizeof(int2K), sizeof(int4K),
    sizeof(int8G), sizeof(int16G_1)
    );

const // real constants
  MaxIntType = high(tBigInteger);
  __zero = 0.0;
  __one = 1.0;
  __ten = 10.0;
  __7ff = 0.0 + high(int64);
  __80e = __one + __7ff;
  __100e = 2.0 * __80e;
  { __08e  and __100e to be compared/added to negative (float) value   }
  { to make it equal with its' positive (unsigned integer) counterpart }
  __100r = 1.0 / __100e; // to be multiplied with excess multiplication

const // typed constants
  fixSign: array[boolean] of single = (__100e, __zero);
  fpZero: single = __zero;
  fpOne: single = __one;
  fp1oe: single = __ten;
  fp10r: single = 1.0 / __ten;
  fp80e: single = __80e;
  fp100e: single = __100e;
  fp100r: single = __100r;

function int128add1(const A, B: int128): int128;
asm
  push ebx
  mov ebx,[A]; add ebx,[B]; mov [Result],ebx
  mov ebx,[A+04]; adc ebx,[B+04]; mov [Result+04],ebx
  mov ebx,[A+08]; adc ebx,[B+08]; mov [Result+08],ebx
  mov ebx,[A+12]; adc ebx,[B+12]; mov [Result+12],ebx
  pop ebx
end;

function int128sub1(const A, B: int128): int128;
asm
  push ebx
  mov ebx,[A]; sub ebx,[B]; mov [Result],ebx
  mov ebx,[A+04]; sbb ebx,[B+04]; mov [Result+04],ebx
  mov ebx,[A+08]; sbb ebx,[B+08]; mov [Result+08],ebx
  mov ebx,[A+12]; sbb ebx,[B+12]; mov [Result+12],ebx
  pop ebx
end;

function int128add2(const A, B: int128): int128;
asm
  push esi; push edi
  mov esi,A; mov edi,B
  mov eax,[esi]; mov edx,[edi]; add eax,edx; mov [Result],eax
  mov eax,[esi+04]; mov edx,[edi+04]; adc eax,edx; mov [Result+04],eax
  mov eax,[esi+08]; mov edx,[edi+08]; adc eax,edx; mov [Result+08],eax
  mov eax,[esi+12]; mov edx,[edi+12]; adc eax,edx; mov [Result+12],eax
  pop edi; pop esi
end;

function int128sub2(const A, B: int128): int128;
asm
  push esi; push ebx
  mov esi,A; mov ebx,B
  mov eax,[esi]; mov edx,[ebx]; sub eax,edx; mov [Result],eax
  mov eax,[esi+04]; mov edx,[ebx+04]; sbb eax,edx; mov [Result+04],eax
  mov eax,[esi+08]; mov edx,[ebx+08]; sbb eax,edx; mov [Result+08],eax
  mov eax,[esi+12]; mov edx,[ebx+12]; sbb eax,edx; mov [Result+12],eax
  pop ebx; pop esi
end;

function int128mul_pencil(const A, B: int128): int256;
asm
  push esi; push edi; push ebx
  mov esi,A; mov ebx,B; mov edi, Result
  xor eax,eax; mov ecx,256/8/4
  push edi; rep stosd; pop edi

@@Loop0:
  mov eax,[esi+00]; mul[ebx+00]; mov[edi+00],eax; mov[edi+04],edx; //adc edi+08,0; adc edi+12,0; adc edi+16,0;
  mov eax,[esi+04]; mul[ebx+00]; add[edi+04],eax; adc[edi+08],edx; //adc edi+12,0; adc edi+16,0;
  mov eax,[esi+08]; mul[ebx+00]; add[edi+08],eax; adc[edi+12],edx; //adc edi+16,0;
  mov eax,[esi+12]; mul[ebx+00]; add[edi+12],eax; adc[edi+16],edx;

@@Loop1:
  mov eax,[esi+00]; mul[ebx+04]; add[edi+04],eax; adc[edi+08],edx; adc[edi+12],0; adc[edi+16],0; adc[edi+20],0;
  mov eax,[esi+04]; mul[ebx+04]; add[edi+08],eax; adc[edi+12],edx; adc[edi+16],0; adc[edi+20],0;
  mov eax,[esi+08]; mul[ebx+04]; add[edi+12],eax; adc[edi+16],edx; adc[edi+20],0;
  mov eax,[esi+12]; mul[ebx+04]; add[edi+16],eax; adc[edi+20],edx;

@@Loop2:
  mov eax,[esi+00]; mul[ebx+08]; add[edi+08],eax; adc[edi+12],edx; adc[edi+16],0; adc[edi+20],0; adc[edi+24],0;
  mov eax,[esi+04]; mul[ebx+08]; add[edi+12],eax; adc[edi+16],edx; adc[edi+20],0; adc[edi+24],0;
  mov eax,[esi+08]; mul[ebx+08]; add[edi+16],eax; adc[edi+20],edx; adc[edi+24],0;
  mov eax,[esi+12]; mul[ebx+08]; add[edi+20],eax; adc[edi+24],edx

@@Loop3:
  mov eax,[esi+00]; mul[ebx+12]; add[edi+12],eax; adc[edi+16],edx; adc[edi+20],0; adc[edi+24],0; adc[edi+28],0;
  mov eax,[esi+04]; mul[ebx+12]; add[edi+16],eax; adc[edi+20],edx; adc[edi+24],0; adc[edi+28],0;
  mov eax,[esi+08]; mul[ebx+12]; add[edi+20],eax; adc[edi+24],edx; adc[edi+28],0;
  mov eax,[esi+12]; mul[ebx+12]; add[edi+24],eax; adc[edi+28],edx

  pop ebx; pop edi; pop esi
end;

function int128div_pencil(const Dividend: int128; const Divisor: Longword; const Quotient: int128): Longword;
asm
  test Divisor,Divisor; jnz @@begin
  jmp @@stop
@@begin:
  push esi; push edi; push ebx
  mov esi,Dividend; mov ebx,Divisor; mov edi, Quotient
  xor edx,edx
  mov eax,[esi+12]; div ebx; mov [edi+12],eax
  mov eax,[esi+08]; div ebx; mov [edi+08],eax
  mov eax,[esi+04]; div ebx; mov [edi+04],eax
  mov eax,[esi   ]; div ebx; mov [edi   ],eax
  mov eax,edx
@@end: pop ebx; pop edi; pop esi
@@stop:
end;

function __int128div2_pencil(const Dividend: int128; const Divisor: Longword; const Quotient: int128): Longword;
asm
  test Divisor,Divisor; jnz @@begin
  jmp @@stop
  @@begin:
  push esi; push edi; push ebx
  mov esi,Dividend; mov ebx,Divisor; mov edi, Quotient
  xor edx,edx
  mov eax,[esi+12]; div ebx; mov [edi+12],eax
  mov eax,[esi+08]; div ebx; mov [edi+08],eax
  mov eax,[esi+04]; div ebx; mov [edi+04],eax
  mov eax,[esi   ]; div ebx; mov [edi   ],eax
  mov eax,edx
  pop ebx; pop edi; pop esi
  @@stop:
end;

function intXMulD1(var Dividend; const Divisor: longword; const IntType: tBigInteger): longword;
asm // allow dword (4-bytes) fold Dividend
@@Start:
  //!!!movzx ecx,intType;
  mov ecx,intType*4+IntegerSize
  sar ecx,2; jg @@begin
@@err: call System.Error; jmp @@stop
@@begin: push esi; push edi; push ebx;
  mov esi,eax; mov ebx,divisor; xor edi,edi
@@Loop:
  mov eax,[esi]; lea esi,esi+4; mul ebx;
  add eax,edi; adc edx,0;
  mov [esi-4],eax; mov edi,edx
  dec ecx; jnz @@Loop
@@done: mov eax,edx
@@end: pop ebx; pop edi; pop esi;
@@Stop:
end;

function int128MulD(var BigInt: int128; const Multiplier: longword): longword;
asm
@@Start: push esi; push ebx;
  mov esi,BigInt; mov ecx,Multiplier
@@begin: xor edx,edx
  mov eax,esi+00; mul ecx; {                    }; mov esi+00,eax; mov ebx,edx;
  mov eax,esi+04; mul ecx; add eax,ebx; adc edx,0; mov esi+04,eax; mov ebx,edx;
  mov eax,esi+08; mul ecx; add eax,ebx; adc edx,0; mov esi+08,eax; mov ebx,edx;
  mov eax,esi+12; mul ecx; add eax,ebx; adc edx,0; mov esi+12,eax; //mov ecx,edx;
@@done: mov eax,edx
@@Stop: pop ebx; pop esi;
end;

function int128DivD(var Dividend: int128; const Divisor: longword): Longword;
asm
@@Start: push esi; push ebx;
  mov esi,eax; mov ebx,divisor
@@begin: xor edx,edx
  mov eax,[esi+12]; div ebx; mov [esi+12],eax
  mov eax,[esi+08]; div ebx; mov [esi+08],eax
  mov eax,[esi+04]; div ebx; mov [esi+04],eax
  mov eax,[esi   ]; div ebx; mov [esi   ],eax
@@done: mov eax,edx
@@Stop: pop ebx; pop esi;
end;

function int256MulD(var BigInt: int256; const Multiplier: longword): longword;
asm
@@Start: push esi; push ebx;
  mov esi,BigInt; mov ecx,Multiplier
@@begin: xor edx,edx
  mov eax,esi+00; mul ecx;                         mov esi+00,eax; mov ebx,edx;
  mov eax,esi+04; mul ecx; add eax,ebx; adc edx,0; mov esi+04,eax; mov ebx,edx;
  mov eax,esi+08; mul ecx; add eax,ebx; adc edx,0; mov esi+08,eax; mov ebx,edx;
  mov eax,esi+12; mul ecx; add eax,ebx; adc edx,0; mov esi+12,eax; mov ebx,edx;
  mov eax,esi+16; mul ecx; add eax,ebx; adc edx,0; mov esi+16,eax; mov ebx,edx;
  mov eax,esi+20; mul ecx; add eax,ebx; adc edx,0; mov esi+20,eax; mov ebx,edx;
  mov eax,esi+24; mul ecx; add eax,ebx; adc edx,0; mov esi+24,eax; mov ebx,edx;
  mov eax,esi+28; mul ecx; add eax,ebx; adc edx,0; mov esi+28,eax; mov ebx,edx;
@@done: mov eax,edx
@@Stop: pop ebx; pop esi;
end;

function intXdivDr(const Dividend; const Divisor: Longword;
  out Quotient; const IntType: tBigInteger): integer; overload;
const MaxIntType = high(tBigInteger);
asm
@@1: cmp IntType,MaxintType; jbe @@2
@@e: call System.Error; jmp @@Stop
@@2: sub IntType,2; jle @@e
@@begin: push esi; push edi; push ebx
  mov esi,Dividend; mov edi, Quotient;
  mov ebx,Divisor;
  //!!!movzx ecx,intType;

  xor eax,eax; lea edx,eax+1;
  shl edx,cl; mov ecx,edx
  xor edx,edx
  cmp ebx,1 jne @@L1
  rep movsd; jmp @@end
  //push -1; pop edx;
  //ecx MUST be>0
@@L1: //dec ecx; jl @@done ;// result 0 if empty
  mov [edi+ecx*4-4],eax;//zero
  mov eax,[esi+ecx*4-4];
  dec ecx; jl @@done ;// result 0 if empty
@@L2: test eax,eax; jz @@L1;

//@@L1: dec ecx; jl @@end
//  mov [edi+ecx*4],eax;//zero
//  mov eax,[esi+ecx*4];
//  test eax,eax; jz @@L1;

//  xor edx,edx
@@edx_0: //(edx=remainder) = 0
  mov eax,[esi+ecx*4];
  cmp eax,ebx; jbe @@be
  @@ab: div ebx
        mov [edi+ecx*4],eax;
        dec ecx; jl @@done
        jmp @@tstdx
  @@be: jne @b
  {@e:} lea eax,edx+1
        mov[edi+ecx*4],eax
        dec ecx; jge @@edx_0;
        jmp @@done
    @b: mov edx,eax; xor eax,eax
        mov[edi+ecx*4],eax
        dec ecx; jge @@edx_1;
        jmp @@done

@@tstdx:
  test edx,edx; jz @@edx_0

@@edx_1: //(edx=remainder) > 0
  mov eax,[esi+ecx*4]; div ebx
  mov [edi+ecx*4],eax;
  dec ecx; jge @@tstdx

@@done: mov eax,edx
@@end: pop ebx; pop edi; pop esi
@@stop:
end;

{ Division by integer; min. size is dword (4bytes);                     }
{ if all zero, will return -1 as remainder which never be a valid value }
{ for remainder, because remainder must be LESS than Divisor;           }
{ -1 or $ffffffff is max. Divisor;  max. remainder will be: $fffffffe   }
function intXDivD(var BigInt; const Multiplier: Longword; const IntType: tBigInteger): integer; overload;
asm
@@begin: push esi; push edi; push ebx
  mov esi,BigInt;  mov edi,IntType;
  mov ebx,Multiplier;
  xor edx,edx; cmp ebx,1;
  jz @@done;
  jb @@err_done;
  //!!!movzx ecx,intType;
  mov ecx,intType*4+IntegerSize; shr ecx,2;
  jz @@err_done
  //cmp ecx,2; jbe @@smallDiv
  push ecx; push 0; push ebx
  call ordinals.bitScantest;
  pop ecx; test eax,eax; jnl @@shlDiv
  mov edi,esi; push -1; pop edx

  // ecx MUST be>0
@@L1: //dec ecx; jl @@done
  mov eax,[esi+ecx*4-4];
  dec ecx; jl @@done; // result = -1 if empty
@@L2: test eax,eax; jz @@L1

xor edx,edx
@@edx_0: //(edx=remainder) = 0
  mov eax,[esi+ecx*4];
  cmp eax,ebx; jbe @@be
  @@ab: div ebx
        mov [edi+ecx*4],eax;
        dec ecx; jl @@done
        jmp @@tstdx
  @@be: jne @b
  {@e:} lea eax,edx+1
        mov[edi+ecx*4],eax
        dec ecx; jge @@edx_0;
        jmp @@done
    @b: mov edx,eax; xor eax,eax
        mov[edi+ecx*4],eax
        dec ecx; jge @@edx_1;
        jmp @@done

@@tstdx:
  test edx,edx; jz @@edx_0

@@edx_1: //(edx=remainder) > 0
  mov eax,[esi+ecx*4]; div ebx
  mov [edi+ecx*4],eax;
  dec ecx; jge @@tstdx
  jmp @@done

@@ShlDiv:
  push 1; mov ecx,eax;
  pop eax; shl eax,cl; dec eax
  mov edx,edi*4+IntegerSize
  mov edx,esi+edx-4;
  and eax,edx; push eax
  mov eax,esi; mov edx,edi
  call intXshr
  pop edx; jmp @@done

@@SmallDiv:
  mov eax,[esi]; div ebx

@@err_done:
@@e: mov eax, reRangeError; call System.Error;
@@done: mov eax,edx
@@end: pop ebx; pop edi; pop esi
@@stop:
end;

function Int64Div(var X, Y: Int64): Int64; //fastCode
asm
 fnstcw esp-16; mov cx,esp-16;
 or cx,1111b shl 8; mov esp-8,cx
 fldcw word ptr esp-8
 fild qword ptr X.0; fild qword ptr Y.0
 fdivp; mov ecx,esp
 and ecx,not 7; fistp qword ptr ecx-8
 //wait //no-need
 fldcw word ptr esp-16 //restore controlword
 mov eax,ecx-8; mov edx,ecx-4
end;

function uInt64Div(const Dividend, Divisor: Int64): Int64;
asm
  mov edx,dword ptr Divisor+4
  mov eax,dword ptr Divisor
  push edx; push eax
  sub eax,dword ptr Dividend
  sbb edx,dword ptr Dividend+4
  jb @@scan;
  lea esp,esp+8
  sete al; movzx eax,al;
  xor edx,edx; jmp @@stop
@@Scan: call ordinals.bitScantest
  test eax,eax; jl @@divQ;
  mov edx,dword ptr Divisor+4
  mov eax,dword ptr Divisor
  jz @@Stop
  shrd eax,edx,cl; shr edx,cl
  cmp cl,32; jb @@Stop
  mov eax,edx; xor edx,edx; jmp @@Stop
@@divQ:
  push 0
  fnstcw word ptr [esp] ; // save FPU control word
  pop ax;
  mov word ptr [esp],ax ; // get and resave
  or ax, 111100000000b  ; // set rounding = integer, precision = 64bit
  push ax               ;
  fldcw word ptr [esp]  ; // get new control word
  add esp,-8
  mov eax,dword ptr Divisor+4
  mov edx,dword ptr Dividend+4
  sar eax,31; sar edx,31
  fild   qword ptr [Divisor]
  fadd dword ptr fixSign+eax*4+4
  fild   qword ptr [Dividend]
  fadd dword ptr fixSign+edx*4+4
  fdivrp
  fistp qword ptr [esp]
  pop eax; pop edx
  fldcw [esp+2]; pop ecx; // restore control word
@@Stop:
end;

function uInt64DivMod(var Dividend: int64; const Divisor: Int64): Int64;
asm
  mov edx,dword ptr Divisor+4
  mov eax,dword ptr Divisor
  push edx; push eax
  sub eax,dword ptr Dividend
  sbb edx,dword ptr Dividend+4
  jb @@scan;
  lea esp,esp+8
  sete al; movzx eax,al;
  xor edx,edx; jmp @@stop
@@Scan: call ordinals.bitScantest
  test eax,eax; jl @@divQ;
  mov edx,dword ptr Divisor+4
  mov eax,dword ptr Divisor
  jz @@Stop
  shrd eax,edx,cl; shr edx,cl
  cmp cl,32; jb @@Stop
  mov eax,edx; xor edx,edx; jmp @@Stop
@@divQ:
  push 0
  fnstcw word ptr [esp] ; // save FPU control word
  pop ax;
  mov word ptr [esp],ax ; // get and resave
  or ah, 1111b          ; // set rounding = integer, precision = 64bit
  push ax               ;
  fldcw word ptr [esp]  ; // get new control word
  add esp,-8
  mov eax,dword ptr Divisor+4
  mov edx,dword ptr Dividend+4
  sar eax,31; sar edx,31
  fild   qword ptr [Divisor]
  fadd dword ptr fixSign+eax*4+4
  fild   qword ptr [Dividend]
  fadd dword ptr fixSign+edx*4+4
  fdivrp
  fistp qword ptr [esp]
  pop eax; pop edx
  fldcw [esp+2]; pop ecx; // restore control word
@@Stop:
end;

function intXMulQ(var BigInt; const Multiplier: int64; const IntType: tBigInteger): int64;
var
  I: int64;
asm // 8-bytes fold BigInteger size
@@Start:
  //!!!movzx edx,intType;
  mov ecx,intType*4+IntegerSize
  sar ecx,3; jg @@begin
@@err: call System.Error; jmp @@stop
@@begin: push esi; push edi; push ebx; //push ebp;
  mov esi,eax; mov edi,ecx;//lea ebx,Multiplier; xor edi,edi
  mov edx,Multiplier.r64.hi; mov eax,Multiplier.r64.lo;
  call ordinals.bitScantest
  test eax,eax; jl @@multQ

@@shlmul: mov edx,0; jz @@done
  mov ecx,eax;
  mov eax,[esi+edi*8];
  mov edx,[esi+edi*8-4];
  shld eax,edx,cl; xor edx,edx
  cmp cl,31; jna @@doShl
  push eax
  mov eax,[esi+edi*8-4];
  mov edx,[esi+edi*8-8];
  shld eax,edx,cl;
  pop edx

@@doShl:
  push edx; push eax
  mov eax,esi; mov edx,edi; movzx ecx,cl
  call intXshr
  pop edx; pop eax;jmp @@done

@@multQ:

 @@cw_store:
   push 0;
   fnstcw word ptr [esp] ; // save FPU control word
   pop bx;
   mov word ptr [esp],bx ; // get and resave
   or bh, 1111b          ; // set rounding = integer, precision = 64bit
   push bx               ;
   fldcw word ptr [esp]  ; // get new control word

  fild qword ptr Multiplier  // [m]

//@@mcheck:
//  fld st           //[m] => [m,m]
//  fmul fp100r      //[m,m] => [mr,m]
//  fstp tbyte ptr [Result]     //[mr,m] => [m]
//  fld tbyte ptr Result      //[m] => [mr,m]
//  fmul fp100e      //[m,m] => [mr,m]
//  fmul st,st(1)    //[mm,m]
//

  fld dword ptr fpZero; // [m] => [Z,m]
  mov dword ptr I,0; mov dword ptr I+4,0

@@Loop:
@@f0: ;//[Z,m]
    mov eax,[esi]; mov edx,[esi+4]
    or eax,edx; jz @@f0_next
    sar edx,31
    fild qword ptr [esi];      // [m] => [I,Z,m]
    fadd dword ptr [fixSign+edx*4+4]  ;// markup negative signed,  [I+,Z,m]
    fmul st,st(2)              // [I,Z,m] => [I*m,Z,m] or [X,Z,m]
    fstp st(1)                    // trash zero //[X,Z,m] => [X,m]

  @@f0_chk: ;// [X,m] or [Y,m]
    fCom dword ptr fp100e      // carry?
    fnstsw ax; sahf
    jnb @@f0_carry

    fCom dword ptr fp80e;      // more than integer can handle?
    fnstsw ax;                 // our boring routines
    and ah,1; movzx eax,ah;    // carry means positive;
    fsub dword ptr[fixSign+eax*4]; // [X,m] => [X+,m]
    fistp qword ptr [esi];      // [X+,m] => [m]
    fld dword ptr fpZero        // [m] => [Z,m]
  @@f0_next:
    lea esi,esi+8
    dec edi; jnz @@f0;
    jmp @@done_mulQ

  @@f0_carry:
    fld st                     // [Y,m] => [Y,Y,m]
    fmul dword ptr fp100r      // [Y,Y,m] => [Yr,Y,m]

    fCom dword ptr fp80e;      // more than integer can handle?
    fnstsw ax;                 // our boring routines
    and ah,1; movzx eax,ah;    // carry means positive;
    fsub dword ptr[fixSign+eax*4]; // [Yr,Y,m] => [Yr+,Y,m]

    fistp I;                   // [Yr,Y,m] => [Y,m]
    mov edx,dword ptr[I+4]; sar edx,31
    fild I
    fadd dword ptr [fixSign+edx*4+4]  ;// markup negative signed,  [f,Y,m]
    fxch                    // [f,Y,m] => [Y,f,m]
    fld st(1)               // [Y,f,m] => [f,Y,f,m]
    fmul dword ptr fp100e    //   [f,Y,f,m] => [G,Y,f,m]
    fsubp st(1),st;// st0 = st0-st1?   //[G,Y,f,m] => [Y-G,f,m] as [k,f,m]
    //idiot intel reference. fsubp => st0 = st1 - st0

    fCom dword ptr fp80e;      // more than integer can handle?
    fnstsw ax;                 // our boring routines
    and ah,1; movzx eax,ah;    // carry means positive;
    fsub dword ptr[fixSign+eax*4]; // [k,f,m] => [k+,f,m]
    fistp qword ptr [esi];     // [k,f,m] => [f,m]
  @@f0_carry_next:
    lea esi,esi+8
    dec edi; jnz @@f1
    Jmp @@done_mulQ


@@f1: // [f,m]
    mov eax,[esi]; mov edx,[esi+4]
    or eax,edx; jz @@f1_next
    sar edx,31
    fild qword ptr [esi];      // [f,m] => [I,f,m]
    fadd dword ptr [fixSign+edx*4+4]  ;// markup negative signed,  [I+,m]

    fmul st,st(2)              // [I,f,m] => [I*m,f,m] or [X,f,m]
    //fadd st,st(1)              // [X,f,m] => [X+f,m] or [Y,m]
    //jmp @@f1_chk

  @@f1_chk: ;// [X,m] or [Y,m]
    fCom dword ptr fp100e      // carry?
    fnstsw ax; sahf
    jnb @@f1_carry

    fadd                       // [X,f,m] => [X+f,m] or [Y,m]
    fCom dword ptr fp100e      // carry1?
    fnstsw ax; sahf
    jnb @@f1_carry1

    fCom dword ptr fp80e;      // more than integer can handle?
    fnstsw ax;                 // our boring routines
    and ah,1; movzx eax,ah;    // carry means positive;
    fsub dword ptr[fixSign+eax*4]; // [X,m] => [X+,m]
    fistp qword ptr [esi];      // [X+,m] => [m]
    fld dword ptr fpZero        // [m] => [Z,m]
  //@@f1_next_n:
    lea esi,esi+8
    dec edi; jnz @@f0;
    jmp @@done_mulQ

  @@f1_carry1:
    fSub dword ptr fp100e      // [X,f,m] => [X-1,f,m] or [Y,m]
    fCom dword ptr fp80e;      // more than integer can handle?
    fnstsw ax;                 // our boring routines
    and ah,1; movzx eax,ah;    // carry means positive;
    fsub dword ptr[fixSign+eax*4]; // [X,m] => [X+,m]
    fistp qword ptr [esi];      // [X+,m] => [m]
    fld dword ptr fpOne        // [m] => [1,m]
  //@@f1_next_1:
    lea esi,esi+8
    dec edi; jnz @@f0;
    jmp @@done_mulQ

  @@f1_carry:
    fld st                     // [Y,f,m] => [Y,Y,f,m]
    fmul dword ptr fp100r      // [Y,Y,f,m] => [Yr,Y,f,m]

    fCom dword ptr fp80e;      // more than integer can handle?
    fnstsw ax;                 // our boring routines
    and ah,1; movzx eax,ah;    // carry means positive;
    fsub dword ptr[fixSign+eax*4]; // [Yr,Y,f,m] => [Yr+,Y,f,m]

    fistp I;                   // [Yr,Y,f,m] => [Y,f,m]
    mov edx,dword ptr[I+4]; sar edx,31
    fild I
    fadd dword ptr [fixSign+edx*4+4]  ;// markup negative signed,  [f1,Y,f,m]
    fxch                    // [f1,Y,f,m] => [Y,f1,f,m]
    fld st(1)               // [Y,f1,f,m] => [f1,Y,f1,f,m]
    fmul dword ptr fp100e    //   [f1,Y,f1,f,m] => [G,Y,f1,f,m]
    fsub;// st0 = st0-st1?   //[G,Y,f1,f,m] => [k,f1,f,m]
    //idiot intel reference. fsubp => st0 = st1 - st0
    //fxch st(2); // [k,f1,f,m] => [f,f1,k,m]
    faddp st(2),st; //[k,f1,f,m] => [f1,k+f,m]
    fxch; // [f1,k+f,m] => [k+f,f1,m]
    fCom dword ptr fp100e
    fnstsw; sahf
    jnb @@f1_100

    fCom dword ptr fp80e;      // more than integer can handle?
    fnstsw ax;                 // our boring routines
    and ah,1; movzx eax,ah;    // carry means positive;
    fsub dword ptr[fixSign+eax*4]; //[k+f-100,f1,m] => [k+f-100,f1,m]
    fistp qword ptr [esi];      // [k+f-100,f1,m] => [f1,m]
  //@@f1_next_1:
    lea esi,esi+8
    dec edi; jnz @@f1;
    jmp @@done_mulQ


  @@f1_100:
    fsub dword ptr fp100e      // [k+f,f1,m] => [k+f-100,f1,m]
    fCom dword ptr fp80e;      // more than integer can handle?
    fnstsw ax;                 // our boring routines
    and ah,1; movzx eax,ah;    // carry means positive;
    fsub dword ptr[fixSign+eax*4]; //[k+f-100,f1,m] => [k+f-100,f1,m]
    fistp qword ptr [esi];      // [k+f-100,f1,m] => [f1,m]
    fadd dword ptr fpOne        //  [f1,m] => [f1+1,m] as [f1,m]
  //@@f1_next_1:
    lea esi,esi+8
    dec edi; jnz @@f0;
    jmp @@done_mulQ

  @@f1_next:
    fCom dword ptr fp80e;      // more than integer can handle?
    fnstsw ax;                 // our boring routines
    and ah,1; movzx eax,ah;    // carry means positive;
    fsub dword ptr[fixSign+eax*4]; // [f,m] => [m]
    fistp qword ptr [esi]
    fld fpZero;                // [m] => [Z,m]
    lea esi,esi+8
    dec edi; jnz @@f0;
    jmp @@done_mulQ

@@done_mulQ: fistp I;
@@cw_restore:
   fldcw [esp+2];
   pop ebx               ; // restore control word
   mov eax,I.r64.lo; mov edx,I.r64.hi
@@done:
@@end: pop ebx; pop edi; pop esi;
@@Stop:
end;

function intXdivQ(var Dividend; const Divisor: int64; const IntType: tBigInteger): int64;
var
  I: int64;
asm
  mov ecx,Divisor.r64.Hi; test ecx,ecx; jnz @@begin
@@useDivD:
  mov ecx,edx; mov edx,Divisor.r64.Lo;
  call intXDivD; jmp @@Stop;
@@begin: push esi; push edi; push ebx
  mov esi,Dividend;
  //xxxmovzx edi,IntType; //xxxlea ebx,Divisor;
  mov edi,intType
  mov ebx,Divisor.r64.Lo;
  push ecx; push ebx; call ordinals.bitScantest;
  test eax,eax; jge @@shrDiv
  mov ecx,edi*4+IntegerSize; shr ecx,3; jz @@err_done
  lea ebx,Divisor
  shl ecx,1; xor edx,edx; //edx must be=0; ecx MUST be>0
@@L1: //dec ecx; jl @@done
  mov eax,[esi+ecx*4-4];
  dec ecx; jl @@done; // result = -1 if empty
@@L2: test eax,eax; jz @@L1

@@floatDiv:
  //lea esi,esi+ecx*4;
  mov edi,ecx; shr edi,1
  lea esi,esi+edi*8;

 @@cw_store:
   push 0;
   fnstcw word ptr [esp] ; // save FPU control word
   pop bx;
   mov word ptr [esp],bx ; // get and resave
   or bh, 1111b          ; // set rounding = integer, precision = 64bit
   push bx               ;
   fldcw word ptr [esp]  ; // get new control word

  mov ecx,Divisor.r64.hi; sar ecx,31
  fild qword ptr [Divisor];
  fadd dword ptr [fixSign+ecx*4+4]  ;// markup negative signed

  fld dword ptr [fixSign+4] ;//zero as remainder

  // stack legend:
  // D = dividend; S = divisor; Z = zero
  // Q = quotient (D div S); R = remainder (D mod S);
  // M = remainder's markup (R * 2^64);
  // Mq = R's quotient (M div S); Mr = M's remainder (M mod S)
  // D+ or Q+ means adjusted (signed integer conversion, either +/- 2^64)
;//------------------------------------------
@@fr0:; // without remainder starting point
 // STACK START = [Z,S]
;//------------------------------------------
  mov eax,esi.r64.Lo; mov edx,esi.r64.hi;
  mov ecx,eax; or ecx,edx;
  jz @@fr0_next;  // zero Dividend

@@fr0_begin:
  mov ecx,edx; sar ecx,31; // save sign first!
  sub eax,Divisor.r64.Lo; sbb edx,Divisor.r64.hi;
  jnz @@fr0_above_or_below; // flag still will be checked for above
                                     //jz @@fr0_equal;
@@fr0_equal:
  mov [esi+4],edx
  inc edx; mov [esi],edx

@@fr0_next:                          // used by zero & Dividend=Divisor
  lea esi,esi-8; dec edi;
  jge @@fr0
  jmp @@done_floatDivQ

@@fr0_above_or_below:
  fild qword ptr [esi];              // Dividend; [D,Z,S]
  fadd dword ptr [fixSign+ecx*4+4]  ;// markup negative signed
  ja @@fr0_above
  //sahf => (high) SZ-A-P-C (low)

@@fr0_below:; // below; quotient = 0, remainder <> 0 (exists); [D,Z,S]
  fstp st(1)                         // pop-out zero (last remainder); [D,Z,S] => [D,S]
  xor edx,edx
  mov [esi],edx; mov [esi+4],edx;    // save 0 for quotient
  lea esi,esi-8; dec edi;
  jge @@fr1;                         // remainder must be > 0
  jmp @@done_floatDivQ;

@@fr0_above:;                        // above, quotient>1, remainder=?; [D,Z,S]
  fstp st(1)                         // pop-out zero (last remainder); [D,Z,S] => [D,S]

@@fr_generic:
  fld st(1);                         // copy Divisor; [D,S] => [S,D,S]
  fld st(1)                          // copy Dividend; [X,D,X] => [D,S,D,S]
  fdivrp                             // st1 = st0 div st1, pop st0; [D,S,D,S] => [Q,D,S]
  //-overflow will not ever happen here
  fcom dword ptr fp80e;          // more than integer can handle?
  xor eax,eax; fnstsw ax;            // our boring routines
  and ah,1; movzx eax,ah             // carry means positive;
  fsub dword ptr[fixSign+eax*4]
  fistp qword ptr[esi]               //  [Q,D,S] => [D,S]

  jmp @@fr_test

@@fr_test: // remainder test, must be in form [D,S]
  // fprem must be in form: st(0) = Dividend, st(1) = Divisor
  @@getrem:
  fprem;     // get new fprem of remainder; [D,S] => [R,S]
  fnstsw ax; sahf; // our boring routines // (high) SZ-A-P-C (low)
    jp @@getrem;   // keep trying until done
  lea esi,esi-8; dec edi
    jl @@done_floatDivQ
  ftst
  fnstsw ax; sahf; // our boring routines // (high) SZ-A-P-C (low)
    jz @@fr0;
  jmp @@fr1;

;//--------------------------------------
@@fr1: // with remainder starting point
 // STACK START = [R,S]
;//--------------------------------------

  fmul dword ptr fixSign;   // mul reminder by 2^64; [R,S] => [M,S]
  fld st                    // get a copy; [M,S] => [M,M,S]
  fdiv st,st(2);            // get rem-quotient; [M,M,S] => [mq,M,S]
  fxch st(2)                // divisor up; [mq,M,S] => [S,M,mq]
  fxch                      // dividend div last remainder up; [S,M,mq] => [M,S,mq]

  // fprem must be in form: st0 = Dividend, st1 = Divisor
  @@fr1_prem: fprem;        // get new fprem of remainder; [M,S,mq] => [mr,S,mq]
    fnstsw; sahf;           // our boring routines // (high) SZ-A-P-C (low)
    jp @@fr1_prem;          // keep trying until die
  ftst
  fnstsw; sahf;       // our boring routines // (high) SZ-A-P-C (low)
  fxch;                     // [mr,S,mq] => [S,mr,mq]
  fxch st(2)                // [S,mr,mq] => [mq,mr,S]
  jz @@fr10_nomore_rem      // for status: [mq,mr,S] => [mq,Z,S]
  jnz @@fr11_still_remain   // for status: [mq,mr,S] => [mq,mr,S]

@@fr10_nomore_rem:          // [mq,Z,S]
@@fr10_start:               // [mq,Z,S]
  mov eax,esi.r64.Lo; mov edx,esi.r64.hi;
  mov ecx,eax; or ecx,edx;
  jz @@fr10_zero;           // zero Dividend

@@fr10_begin:
  mov ecx,edx; sar ecx,31;  // save sign first!
  sub eax,Divisor.r64.Lo; sbb edx,Divisor.r64.hi;
  jnz @@fr10_above_or_below;// donot disturb flag and ecx
  //jz @@fr0_equal;

@@fr10_below_or_equal:      // [mq,Z,S]
@@fr10_equal:               // [mq,Z,S]
  //-overflow will not ever happen here
  fcom dword ptr fp80e;          // more than integer can handle?
  xor eax,eax; fnstsw ax;            // our boring routines
  and ah,1; movzx eax,ah             // carry means positive;
  fsub dword ptr[fixSign+eax*4]
  fistp qword ptr[esi];              // [mq,Z,S] => [Z,S]
  add [esi],1; adc [esi+4],0
  lea esi,esi-8; dec edi;
  jge @@fr0; jmp @@done_floatDivQ

@@fr10_zero:                         // [mq,Z,S]
  //-overflow will not ever happen here
  fcom dword ptr fp80e;          // more than integer can handle?
  xor eax,eax; fnstsw ax;            // our boring routines
  and ah,1; movzx eax,ah             // carry means positive;
  fsub dword ptr[fixSign+eax*4]
  fistp qword ptr[esi];              // [mq,Z,S] => [Z,S]
  lea esi,esi-8; dec edi;
  jge @@fr0; jmp @@done_floatDivQ

@@fr10_above_or_below:;              // Dividend is not zero nor equal with divisor; [mq,Z,S]
  fstp st(1);                        //trash zero we dont need it; [mq,Z,S] => [mq,S]
  fild qword ptr [esi];              // Dividend; [mq,S] => [D,mq,S]
  fadd dword ptr [fixSign+ecx*4+4];  // markup if negative; [+D,mq,S]
  //faddp; wrong!!! never add mq to D; mq must be op against Q. NOT to D.
  fxch;                              //[D,mq,S] => [mq,D,S]
  ja @@fr10_above;                   // [mq,D,S]
@@fr10_below:;                       // below; quotient = 0+mq, remainder <> 0 (exists); [D,S,mq]
  fistp qword ptr [esi];                       //  [mq,D,S] => [D,S] as [R,S]
  lea esi,esi-8; dec edi;
  jge @@fr1; jmp @@done_floatDivQ;

@@fr10_above:;                       // above, quotient>1, remainder:? [mq,D,S]
  fld st(1)                          // copy Dividend; [mq,D,S] =>  [D,mq,D,S]
  fdiv st,st(3)                      // st0 = st0 div st3; [D,mq,D,S] => [Q,mq,D,S]
  faddp                              // [Q,mq,D,S] => [Q+mq,D,S]
  fCom dword ptr fp80e;              // more than integer can handle?
  fnstsw ax;                         // our boring routines
  and ah,1; movzx eax,ah             // carry means positive;
  fsub dword ptr[fixSign+eax*4]
  fistp qword ptr[esi];              // [Q+mq,D,S] => [D,S] to be tested for remainder
  jmp @@fr_test

@@fr11_still_remain:                // [mq,mr,S]
@@fr11_start:                       // [mq,mr,S]
  mov eax,esi.r64.Lo; mov edx,esi.r64.hi;
  mov ecx,eax; or ecx,edx;
  jz @@fr11_zero;                   // zero Dividend

@@fr11_begin:                       // [mq,mr,S]
  mov ecx,edx; sar ecx,31;          // save sign first!
  sub eax,Divisor.r64.Lo; sbb edx,Divisor.r64.hi;
  jnz @@fr11_above_or_below;        // donot disturb flag and ecx
  //jz @@fr11_equal;

@@fr11_below_or_equal:              // [mq,mr,S]
@@fr11_equal:                       // [mq,mr,S]
  //-overflow will not ever happen here
  fcom dword ptr fp80e;          // more than integer can handle?
  fnstsw ax;            // our boring routines
  and ah,1; movzx eax,ah             // carry means positive;
  fsub dword ptr[fixSign+eax*4]
  fistp qword ptr[esi];             // [mq,mr,S] => [mr,S] as [R,S]
  add [esi],1; adc [esi+4],0
  lea esi,esi-8; dec edi;
  jge @@fr1; jmp @@done_floatDivQ

@@fr11_zero: // used by zero & Dividend=Divisor // [mq,mr,S]
  //-overflow will not ever happen here
  fcom dword ptr fp80e;          // more than integer can handle?
  fnstsw ax;            // our boring routines
  and ah,1; movzx eax,ah             // carry means positive;
  fsub dword ptr[fixSign+eax*4]
  fistp qword ptr[esi];             // [mq,mr,S] => [mr,S] as [R,S]
  lea esi,esi-8; dec edi;
  jge @@fr1; jmp @@done_floatDivQ

@@fr11_above_or_below:               // [mq,mr,S]
  fild qword ptr [esi];              // Dividend; [mq,mr,S] => [D,mq,mr,S]
  fadd dword ptr [fixSign+ecx*4+4]  ;// markup negative signed,  [+D,mq,mr,S]
  //fxch;                              //  [+D,mq,mr,S] =>  [mq,+D,mr,S]
  ja @@fr11_above
  //sahf => (high) SZ-A-P-C (low)

@@fr11_below:; // Dividend < Divisor; [+D,mq,mr,S] ; dividend as remainder
  faddp st(2),st // add st0 to st2 and pop st0; [+D,mq,mr,S] => [mq,D+mr,S]
  fcom dword ptr fp80e;          // more than integer can handle?
  fnstsw ax;            // our boring routines
  and ah,1; movzx eax,ah             // carry means positive;
  fsub dword ptr[fixSign+eax*4]
  fistp qword ptr [esi];                       //  [mq,D+mr,S] => [D+mr,S] as [R,S]
  lea esi,esi-8; dec edi;
  jge @@fr1; jmp @@done_floatDivQ;

  jge @@fr1;                         // remainder must be > 0
  jmp @@done_floatDivQ;

@@fr11_above:; // above, quotient>1, remainder:? STACK = [+D,mq,mr,S]
  fld st(3);                         // copy Divisor; [+D,mq,mr,S] => [S,+D,mq,mr,S]
  fld st(1)                          // copy Dividend; [S,+D,mq,mr,S] => [+D,S,+D,mq,mr,S]
  @@fr11_prem: fprem;  //  [+D,S,+D,mq,mr,S] => [R,S,+D,mq,mr,S]
    fnstsw; sahf;           // our boring routines // (high) SZ-A-P-C (low)
  jp @@fr11_prem;          // keep trying until droll
  faddp st(4),st // add st0 to st4 and pop st0; [R,S,+D,mq,mr,S] => [S,+D,mq,R+mr,S]

  fdiv; //  [S,+D,mq,R+mr,S] => [Q,mq,R+mr,S]
  // can not do this must be truncated as integer
  //fadd; //  [Q,mq,R+mr,S] => [Q+mq,R+mr,S]

  fCom dword ptr fp80e;              // more than integer can handle?
  fnstsw ax;            // our boring routines
  and ah,1; movzx eax,ah             // carry means positive;
  fsub dword ptr[fixSign+eax*4]        //[Q+,mq,R+mr,S]
  //fistp qword ptr[esi];              // [Q+mq,R+mr,S] => [R+mr,S]
  fistp qword ptr I                    // [Q+,mq,R+mr,S] => [mq,R+mr,S]
  mov ebx,dword ptr I
  mov ecx,dword ptr I+4

  fCom dword ptr fp80e;              // more than integer can handle?
  fnstsw ax;            // our boring routines
  and ah,1; movzx eax,ah             // carry means positive;
  fsub dword ptr[fixSign+eax*4]      // [mq,R+mr,S] => [mq+,R+mr,S]
  //fistp qword ptr[esi];              // [Q+mq,R+mr,S] => [R+mr,S]
  fistp qword ptr I                 //[mq+,R+mr,S] =>  [R+mr,S]
  add ebx,dword ptr I
  adc ecx,dword ptr I+4

  fCom; // compare st0 with st1
  fnstsw ax; sahf  // our boring routines // (high) SZ-A-P-C (low)
  jb @@fr111_below
  je @@fr111_equal

  @@fr111_above:
  fsub st,st(1);                   // [R+mr,S] => [R,S]
  //add [esi],1; adc [esi+4],0
  add ebx,1; adc ecx,0
  mov [esi],ebx; mov [esi+4],ecx
  lea esi,esi-8; dec edi;
  jge @@fr1; jmp @@done_floatDivQ;

  @@fr111_equal:
  fstp st; fld dword ptr [fixSign+4] ;//zero as remainder
  //add [esi],1; adc [esi+4],0
  add ebx,1; adc ecx,0
  mov [esi],ebx; mov [esi+4],ecx
  lea esi,esi-8; dec edi;
  jge @@fr0; jmp @@done_floatDivQ;

  @@fr111_below:
  mov [esi],ebx; mov [esi+4],ecx
  lea esi,esi-8; dec edi;
  jge @@fr1; jmp @@done_floatDivQ;

@@done_floatDivQ:
  xor eax,eax; xor edx,edx;
  ftst; fnstsw ax; sahf; jz @@done_getrem
                                           //fmul dword ptr fixUp100
  fistp qword ptr I
  mov eax,dword ptr I
  mov edx,dword ptr I+4
  fstp st

@@done_getrem:
@@cw_recall:
   fldcw [esp+2];
   pop ebx               ; // restore control word
jmp @@done


@@ShrDiv: mov edx,0; jz @@done
  push 1; mov ecx,eax; pop eax
  mov ch,cl; shl eax,cl;
  dec eax; cmp ch,31;
  jna @@shrr_done
  mov edx,eax; or eax,-1

@@shrr_done:
  //mov ebx,edi*4+IntegerSize-8
  //and eax,esi+ebx-8
  //and edx,esi+ebx-4

  and eax,[esi]; and edx,[esi+4]
  push eax; push edx
  mov eax,esi; mov edx,edi; movzx ecx,cl
  call intXshr
  pop edx; pop eax;jmp @@done

//@@SmallDivisor: jnb @@err_done
//  test ebx+4,-1;
//  mov eax,[esi]; div ebx

@@err_done:
@@e: mov eax, reRangeError; call System.Error;
@@done: //mov eax,edx
@@end: pop ebx; pop edi; pop esi
@@stop:
end;

function int128divQ(var Dividend: int128; const Divisor: int64): int64;
asm
  push esi; mov esi,eax
  mov eax,esi+8; or eax,esi+12;
  jz @@64
  mov edx,dword ptr Divisor+4
  mov eax,dword ptr Divisor
  push edx; push eax
@@Scan: call ordinals.bitScantest
  xor edx,edx; test eax,eax; jle @@divQ;

  cmp eax,32; jae @@32more
  push esi+0; mov eax,esi+4; mov edx,esi+8;
  shrd esi+0,eax,cl; shrd eax,edx,cl
  mov esi+4,eax; mov eax,esi+12
  shrd edx,eax,cl; shr eax,cl
  mov esi+8,eax; mov esi+12,edx;
  pop edx; push 1; pop eax;
  shl eax,cl; dec eax; and eax,edx
  xor edx,edx; jmp @@Stop

  @@32more: push ebx; mov ecx,eax
  push 0; push esi+0;
  mov eax,esi+4; mov edx,esi+8;
  mov ebx,esi+12; mov esi+12,0;
  //notworth missed branch prediction failure
  //@@32: mov esi+0,eax; mov esi+4,edx; mov esi+8,ebx;
  //jz @@mdone;
  shrd eax,edx,cl; mov esi+0,eax;
  shrd edx,ebx,cl; mov esi+4,edx;
  shr ebx,cl; mov esi+8,ebx;
  push 1; pop eax; shl eax,cl;
  dec eax; and [esp+4],eax; jmp @@mdone
  @@mdone: pop eax; pop edx; pop ebx; jmp @@Stop;

@@64: push esi+0; push esi+4
      push dword ptr Divisor+0; push dword ptr Divisor+4
      call ordinals.uint64Div; jmp @@Stop

@@divQ: jz @@Stop;
  mov eax,dword ptr Divisor+4;
  mov edx,dword ptr esi+12;
  sar eax,31; sar edx,31;

  push 0
  fnstcw word ptr [esp] ; // save FPU control word
  pop cx;
  mov word ptr [esp],cx ; // get and resave
  or ch, 1111b          ; // set rounding = integer, precision = 64bit
  push cx               ;
  fldcw word ptr [esp]  ; // get new control word
  mov ecx,dword ptr esi+4

  fild qword ptr [Divisor]     // [S]
  fadd dword ptr fixSign+eax*4+4
  mov eax,dword ptr [esi]

  fild qword ptr [esi+8]    // [S] => [D2,S]
  fadd dword ptr fixSign+edx*4+4
  mov edx,ecx; sar ecx,31
  or edx,eax; // LSB8 = 0 ?
  jnz @@fullDivQ; xor ecx,ecx // ecx will be next used as zero fill
  mov eax,dword ptr [esi+08]; mov dword ptr [esi+08],ecx
  mov edx,dword ptr [esi+12]; mov dword ptr [esi+12],ecx
  sub eax,Divisor.r64.lo; sbb edx,Divisor.r64.hi
  jz  @@Divno;    //[D2,S]; D2 = S ?
  jb @@Divb2;     //[D2,S]; D2 < S ?
  @@Diva2: // D2 > S
    fld st                     //[D2,S] => [D2,D2,S]
    fDiv st,st(2)              //[D2,D2,S] => [Q2,D2,S]
    fistp [esp+8]              //[Q2,D2,S] => [D2,S]
    fprem;                     //[D2,S] => [R2,S]
    ftst; fnstsw ax; sahf;     // R2 = 0 ?
    mov eax,ecx;
    jz @@divnodone
  @@Divb2:// D2 < S; [D2,S] as [R,S]
    fmul fp100e                //[R2,S] => [Rx2,S]
    fld st                     //[Rx2,S] => [Rx2,Rx2,S]
    fDiv st,st(2)              //[Rx2,Rx2,S] => [Qx2,Rx2,S]
    fxch st(2)                 //[Qx2,Rx2,S] => [S,Rx2,Qx2] as [S,Rx2,Q]
    fxch                       //[S,Rx2,Q] => [Rx2,S,Q]
    @@getr1: fprem; fnstsw ax; sahf;
    jp @@getr1                 // [Rx2,S,Q] => [R,S,Q]
    push eax; push eax; jmp @@fvv_below

  @@Divno: inc [esi+8];
  @@divnodone: fstp st; fstp st; jmp @@cwr

@@fullDivQ:
  fild   qword ptr [esi]  // [D2,S] => [D1,D2,S]
  fadd dword ptr fixSign+ecx*4+4 // [D1,D2,S] =>  [D1+,D2,S]

  fxch                           // [D1,D2,S] => [D2,D1,S]
  fld st;                        // [D2,D1,S] => [D2,D2,D1,S]
  fdiv st,st(3)                  // [D2,D2,D1,S] => [Q2,D2,D1,S]
  fistp qword ptr [esi+8];       // [Q2,D2,D1,S] => [D2,D1,S]
  fld st(2);                     // [D2,D1,S] => [S,D2,D1,S]
  fxch;                          // [S,D2,D1,S] => [D2,S,D1,S]
  fprem                          // [D2,S,D1,S] => [R2,S,D1,S]
  ftst; fnstsw ax; sahf
  jnz @@fD_D2rem1

    fstp st;                     // [R2=Z,S,D1,S] = [S,D1,S] as [S,D,S]
    fld st(1)                    // [S,D,S] = [D,S,D,S]
    fdivrp                       // [D,S,D,S] => [Q,D,S]
    fxch st(2)                   // [Q,D,S] => [S,D,Q]
    fxch                         // [S,D,Q] => [D,S,Q]
    fprem                        // [D,S,Q] => [R,S,Q]
    push eax; push eax
    jmp @@fvv_below

  @@fD_D2rem1:
  fmul fp100e                    // [R2,S,D1,S] => [Rx2,S,D1,S]
  fxch                           // [Rx2,S,D1,S] => [S,Rx2,D1,S]
  fld st(1)                      // [S,Rx2,D1,S] => [Rx2,S,Rx2,D1,S]
  @@getrem: fprem;               // [Rx2,S,Rx2,D1,S] => [R2,S,Rx2,D1,S]
  fnstsw; sahf;
  jp @@getrem

  fxch st(2)                     // [R2,S,Rx2,D1,S] => [Rx2,S,R2,D1,S]
  fDivrp st(1),st                // [Rx2,S,R2,D1,S] => [Qx2,R2,D1,S]
  fxch st(3)                     // [Qx2,R2,D1,S] => [S,R2,D1,Qx2]
  fld st(2)                      // [S,R2,D1,Qx2] => [D1,S,R2,D1,Qx2]
  fprem                          // [D1,S,R2,D1,Qx2] => [R1,S,R2,D1,Qx2]

  fxch st(3)                     // [R1,S,R2,D1,Qx2] => [D1,S,R2,R1,Qx2]

  fdiv st,st(1)                  // [D1,S,R2,R1,Qx2] => [Q1,S,R2,R1,Qx2]
  faddp st(4),st                 // [Q1,S,R2,R1,Qx2] => [S,R2,R1,Q]

  fxch st(2)                     // [S,R2,R1,Q] => [R2,R1,S,Q]
  fadd                           // [R2,R1,S,Q] => [R,S,Q]

  fCom; fnstsw; sahf             // R ~ S
  push eax; push eax;
  jb @@fvv_below

  @@fvv_above:
  @@fvv_equal:
    fsub st,st(1)                // [R,S,Q]
    fld1                         // [R,S,Q] => [1,R,S,Q]
    faddp st(3),st               // [1,R,S,Q] => [R,S,Q+1] as [R,S,Q]

  @@fvv_below:                   // [R,S,Q]
   fcom fp80e                    // R negative?
   fnstsw ax; sahf;
   and ah,1; movzx eax,ah
   fSub dword ptr fixSign+eax*4
   fistp qword ptr [esp]         //[R,S,Q] => [S,Q]

   fstp st                       //[S,Q] => [Q]

   fcom fp80e                    //Q negative?
   fnstsw ax; sahf;
   and ah,1; movzx eax,ah
   fSub dword ptr fixSign+eax*4
   fistp qword ptr [esi]
@@donedivQ: pop eax; pop edx
@@cwr:fldcw [esp+2]; pop ecx; // restore control word
@@Stop: pop esi;
end;

procedure int128DivMod_test1(var Dividend; const Divisor: int128; var Remainder: int128);
//function int128DivMod(var Dividend: int128; const Divisor: int128): int128;
// this is dogslow; Dividend and Divisor may overlap (not too useful anyway)
const
  _Offset = 16;
  _Dividend = 4 * 7 + _offset;
  _Divisor = 5 * 6 + _offset;
  _Remainder = 4 * 6 + _offset;
asm
@@begin: pushad; //ax[7],cx[6],dx[5],bx[4],tmp[3],bp[2],si[1],di[0]
@@notzero:
  sub esp,_offset
  fild qword ptr Divisor+8; fild qword ptr Divisor+0
  fistp qword ptr esp+0; fistp qword ptr esp+8
  fldz; fst qword ptr Remainder+0; fstp qword ptr Remainder+8;

  mov ebp,128
  mov esi,esp._Dividend; mov edi,esp._Remainder;

@@Loop:
  mov eax,esi+0; shl eax,1;
  mov edx,esi+4; rcl edx,1;
  mov ecx,esi+8; rcl ecx,1;
  mov ebx,esi+12; rcl ebx,1

  mov esi+0,eax; mov esi+04,edx;
  mov esi+8,ecx; mov esi+12,ebx;

  mov eax,edi+0; rcl eax,1;
  mov edx,edi+4; rcl edx,1;
  mov ecx,edi+8; rcl ecx,1;
  mov ebx,edi+12; rcl ebx,1

  cmp ebx,esp+12; ja @@above; jb @@below
  cmp ecx,esp+08; ja @@above; jb @@below
  cmp edx,esp+04; ja @@above; jb @@below
  cmp eax,esp+00;             jb @@below

@@above:
   sub eax,[esp]; sbb edx,esp+4; sbb ecx,esp+8; sbb ebx,esp+12;
   inc esi+0

@@below:
   mov edi+0,eax; mov edi+4,edx; mov edi+8,ecx; mov edi+12,ebx
   dec ebp; jg @@Loop
   add esp,_Offset
@@end: popad
@@stop:
end;

function int128DivMod(var Dividend: int128; const Divisor: int128): int128;
//function int128DivMod2(var Dividend: int128; const Divisor: int128): int128;
// this is dogslow; Dividend and Divisor may overlap (not too useful anyway)
const
  _Offset = 16;
  _Dividend = 4 * 7 + _offset;
  _Result = 4 * 6 + _offset;
asm
@@begin: pushad; //ax[7],cx[6],dx[5],bx[4],tmp[3],bp[2],si[1],di[0]
@@notzero:
  sub esp,_offset
  fild qword ptr Divisor+8; fild qword ptr Divisor+0
  fistp qword ptr esp+0; fistp qword ptr esp+8
  //fldz; fst qword ptr Result+0; fstp qword ptr Result+8;
  fldz; fst qword ptr ecx+0; fstp qword ptr ecx+8;
  or ebx,-1;
@@check1:
  test esp+12,ebx; jnz @@check2
  test esp+8,ebx; jnz @@check2
@@QDiv:
  test esp+4,ebx; jz @@DivD
  //mov edx,esp;
  call int128DivQ;
  add esp,8;
  mov ecx,[esp+4*6]; mov [ecx],eax; mov ecx+4,edx; jmp @@end
@@DivD:
  mov edx,[esp]; call int128DivD; add esp,16;
  mov ecx,[esp+4*6]; mov [ecx],eax; jmp @@end
@@check2:

@@prep:
  mov ebp,128
  mov esi,esp._Dividend; mov edi,esp._Result;

@@Loop:
  //mov eax,esi+0; mov edx,esi+4;
  //mov ecx,esi+8; mov ebx,esi+12;

  mov eax,esi+0; shl eax,1;
  mov edx,esi+4; rcl edx,1;
  mov ecx,esi+8; rcl ecx,1;
  mov ebx,esi+12; rcl ebx,1

  mov esi+0,eax; mov esi+04,edx;
  mov esi+8,ecx; mov esi+12,ebx;

  mov eax,edi+0; rcl eax,1;
  mov edx,edi+4; rcl edx,1;
  mov ecx,edi+8; rcl ecx,1;
  mov ebx,edi+12; rcl ebx,1

  cmp ebx,esp+12; ja @@above; jb @@below
  cmp ecx,esp+08; ja @@above; jb @@below
  cmp edx,esp+04; ja @@above; jb @@below
  cmp eax,esp+00;             jb @@below

@@above:
   sub eax,[esp]; sbb edx,esp+4; sbb ecx,esp+8; sbb ebx,esp+12;
   inc esi+0

@@below:
   mov edi+0,eax; mov edi+4,edx; mov edi+8,ecx; mov edi+12,ebx
   dec ebp; jg @@Loop
   add esp,_Offset
@@end: popad
@@stop:
end;

procedure intXDivMod(var Dividend; const Divisor; out Remainder; const IntType: tBigInteger);
// NEVER overlapping any of Dividend, Divisor and Remainder! NO checking
//   it is up to you if you want to ruin your program intentionally.
// also, all three of them should be in the same size,
//   (this bitshift routine is deadly slow. triple slower for int128 type than
//   the slow int128DivMod, 5 times slower if it is of int256, and so on...
//   you've been warned!)
const
  _minplus_offset = 8;
  _Counter = 4 * 3;
asm
@@begin: pushad; //ax[7],cx[6],dx[5],bx[4],tmp[3],bp[2],si[1],di[0]
  //!!!movzx ebx,IntType;
  mov ebx,intType
  mov ebx,dword ptr IntegerSize+ebx*4;
  cmp ebx,8; jge @@mulai//get qword, we do not need less than 8-bytes wide
  popad; call System.error; jmp @@stop
@@mulai:
  mov esp._counter, ebx
  @ckzLoop: mov esi,Divisor+ebx-8; mov edi,Divisor+ebx-4; or ebp,esi; or ebp,edi;
    sub ebx,8; jg @ckzLoop
  test ebp,ebp; jnz @@notzero
    popad; div ebp; jmp @@stop
@@notzero:
  mov esi,Dividend; mov eax,esp._counter;
  mov edi,Remainder; mov ecx,eax; mov ebx,Divisor
  lea esi,esi+eax; // esi = ALWAYS TAIL
  shr ecx,3; shl eax,3; mov esp._counter,eax;
  mov ebp,ecx; push ecx; neg ebp; push ebp;

  fldz;
    @@fLoopz: fst qword ptr edi+ecx*8-8; dec ecx; jg @@fLoopz;
  fstp st

  pop ebp; pop ecx; push ecx; push ebp;

@@LoopX:
  //mov eax,esp._counter+_minplus_offset;
  xor eax,eax; lea edi,edi+ecx*8; // edi = TAIL
@@lsh1: //ebp NEGATIVE; esi = TAIL
  mov eax,esi+ebp*8+0; rcl eax,1;
  mov edx,esi+ebp*8+4; rcl edx,1;
  mov esi+ebp*8,eax; mov esi+ebp*8+4,edx; inc ebp; jl @@lsh1

  pop ebp; pop ecx; push ecx; push ebp;

@@lsh2: //ebp = negative; edi = TAIL
  mov eax,edi+ebp*8+0; rcl eax,1;
  mov edx,edi+ebp*8+4; rcl edx,1;
  mov edi+ebp*8,eax; mov edi+ebp*8+4,edx; inc ebp; jl @@lsh2

  pop ebp; lea edi,edi+ebp*8 // edi = HEAD

  pop ecx; push ecx; push ebp;

@@lsh3: //ecx POSITIVE; edi = HEAD; ebx = HEAD
  // compare msb downto lsb
  mov edx,edi+ecx*8-4; mov eax,ebx+ecx*8-4;
  cmp edx,eax; ja @@above; jb @@below
  mov edx,edi+ecx*8-8; mov eax,ebx+ecx*8-8;
  cmp edx,eax; ja @@above; jb @@below
  dec ecx; jg @@lsh3

@@above:
  pop ebp; pop ecx; push ecx; push ebp;
  push edi; lea edi,edi+ecx*8; // edi = TAIL;
  push ebx; lea ebx,ebx+ecx*8; // ebx = TAIL
  inc esi+ebp*8; xor eax,eax

@@a_Loop: //ebp = negative; edi = TAIL; ebx = TAIL;
  //substract from lsb to msb
  mov eax,edi+ebp*8; mov edx,edi+ebp*8+4;
  sbb eax,ebx+ebp*8; sbb edx,ebx+ebp*8+4
  mov edi+ebp*8,eax; mov edi+ebp*8+4,edx
  inc ebp; jl @@a_Loop

  pop ebx; pop edi;

@@below:
  pop ebp; pop ecx; push ecx; push ebp;
  dec esp._counter+_minplus_offset;
  jg @@LoopX; add esp,8
@@end: popad
@@Stop:
end;

function intXMulD(var BigInt; const Multiplier: longword; const IntType: tBigInteger): longword;
asm // 8-bytes fold BigInteger size
@@Start: //!!!movzx ecx,intType;
  mov ecx,intType*4+IntegerSize
  sar ecx,3; jg @@begin
@@err: call System.Error; jmp @@stop
@@begin: push esi; push edi; push ebx; //push ebp;
  mov esi,eax; mov ebx,Multiplier; xor edi,edi
@@Loop:
  mov eax,[esi]; mul ebx;
  add eax,edi; adc edx,0;
  mov [esi],eax; mov edi,edx
  mov eax,[esi+4];lea esi,esi+8; mul ebx;
  add eax,edi; adc edx,0;
  mov [esi-4],eax; mov edi,edx
  dec ecx; jnz @@Loop
@@done: mov eax,edx
@@end: pop ebx; pop edi; pop esi;
@@Stop:
end;

procedure intXmul(const A, B; const IntType: tBigInteger; out BigIntResult); // NO CHECKING!!!
//cmovz eax,eax //0F,44,C3h //db 0Fh; dw 0C044h // dw 440Fh; db 0C0h
//cmovz eax,ecx //0F,44,C1h //db 0Fh; dw 0C144h // dw 440Fh; db 0C1h
//cmovz eax,edx //0F,44,C2h //db 0Fh; dw 0C244h // dw 440Fh; db 0C2h
//cmovz eax,ebx //0F,44,C3h //db 0Fh; dw 0C344h // dw 440Fh; db 0C3h

//cmovz edx,eax //0F,44,D0h //db 0Fh; dw 0D044h // dw 440Fh; db 0D0h
//cmovz edx,ecx //0F,44,D2h //db 0Fh; dw 0D144h // dw 440Fh; db 0D1h
//cmovz edx,edx //0F,44,D3h //db 0Fh; dw 0D244h // dw 440Fh; db 0D2h
//cmovz edx,ebx //0F,44,D3h //db 0Fh; dw 0D344h // dw 440Fh; db 0D3h
asm
//@@1:cmp IntType, ibInt1024; jbe @@2
@@2: //!!!movzx ecx,intType;
cmp IntType,bitInteger; jg @@begin
@@err: call System.Error; jmp @@stop
{$IFDEF BIGMATH_DEBUG}
   cmp IntType, itSmallInt; jz @@itWord; jb @@itByte
 @@ibInt:
   test eax,eax; dw 440fh; db 0d0h ;//cmovz edx,eax
   test edx,edx; dw 440fh; db 0c2h ;//cmovz eax,edx
   jz @@store_4; mul edx
 @@store_4: mov [ecx],eax; mov [ecx+4],edx
   jmp @@stop
 @@itWord:
   test eax,eax; dw 440fh; db 0d0h ;//cmovz edx,eax
   test edx,edx; dw 440fh; db 0c2h ;//cmovz eax,edx
   jz @@store_2; mul dx
 @@store_2: mov [ecx],ax; mov [ecx+2],dx
   jmp @@stop
 @@itByte:
   test eax,eax; dw 440fh; db 0d0h ;//cmovz edx,eax
   test edx,edx; dw 440fh; db 0c2h ;//cmovz eax,edx
   jz @@store_1; mul dl
 @@store_1: mov [ecx],al; mov [ecx+1],dl
   jmp @@Stop
{$ENDIF BIGMATH_DEBUG}
@@begin: push esi; push edi; push ebx
  mov esi,A; mov eax,ecx*4+IntegerSize;
  mov edi,BigIntResult; shr eax,2
  mov ebx,B; mov ecx,eax; mov ebp,eax
  fldz; @@fz: fst qword ptr edi+eax*8-8; dec eax; jg @@fz; fstp st

  @@L1: dec ecx; jl @@done
        mov eax,[esi+ecx*4]; test eax,eax; jz @@L1
  @@L2: dec ebp; jl @@done
        mov eax,[ebx+ebp*4]; test eax,eax; jz @@L2;

  neg ecx
  @@LoopA: push ecx
    //push ebx; push esi; push edi;
    @@LoopB:
      mov eax,[esi];
      mov edx,[ebx];
      test eax,eax; jz @@ckin
      test edx,edx; jz @@ckin
        mul edx;
        add[edi],eax;
        adc[edi+4],edx; jnb @@ckin
        push 2; pop eax
        @b:adc edi+eax*4,0; inc eax; jb @b
      @@ckin:
       lea esi,esi+4;
       lea edi,edi+4;
       inc ecx; jle @@LoopB
    pop ecx
    //pop edi; pop esi; pop ebx;
    //add edi,4; add esi,4; add ebx,4
    lea ebx,ebx+4;
    lea edi,edi+ecx*4
    lea esi,esi+ecx*4-4
    dec ebp; jge @@LoopA

@@done:
@@end: pop ebx; pop edi; pop esi
@@Stop:
end;

procedure __int128mulD(var A; const I: integer);
//var temp: array[0..3] of integer;
asm
  cmp edx,1; ja @@begin; jz @@ret1;
    mov eax+0,edx; mov eax+04,edx;
    mov eax+8,edx; mov eax+12,edx;
    @@ret1: ret;
@@begin:
  push esi; push edi;
  mov esi,eax+8; mov edi,eax+12;
  push ebx; push ebp;
  mov ebp,eax; push edx;
  bsf ecx,edx;
  mov edx,eax+4; mov eax,[eax]
  xor ebx,ebx; cmp ecx,1;
  seta bl; sbb ebx,0; // -1, 0, or +1
  jmp ebx*4+@@shltable+4; nop; nop;
  @@shltable: dd @@shl1, @@shld, @@save;
    @@shl1:
      shl eax,1; mov ebx,[esp];
      rcl edx,1;
      rcl esi,1; rcl edi,1;
      shr ebx,1; mov[esp],ebx; jmp @@save;
    @@shld: mov ebx,[esp];
      shld edi,esi,cl; shld esi,edx,cl;
      shld edx,eax,cl; shl eax,cl;
      shr ebx,cl; mov[esp],ebx;
    @@save: pop ecx;
      mov [ebp+0],eax; mov [ebp+04],edx
      mov [ebp+8],esi; mov [ebp+12],edi
    @@cked: cmp ecx,35; sbb ebx,ebx;
    and ebx,ecx; inc ebx; shr ebx,1; jmp ebx*4+@@multable
    @@multable: dd @@x00,@@x01,@@x03,@@x05,@@x07,@@x09,@@x11,@@x13,@@x15,@@x17
                dd @@x19,@@x21,@@x23,@@x25,@@x27,@@x29,@@x31,@@x33,@@x35,@@x37
    //OK---------------------------------------------------------------------
    @@x37: add eax,eax; adc edx,edx; adc esi,esi; adc edi,edi;
           add eax,ebp+0; adc edx,ebp+04;
           adc esi,ebp+8; adc edi,ebp+12;
           add eax,eax; adc edx,edx; adc esi,esi; adc edi,edi; jmp @@x07

    @@x35:
    @@x21: {debug: OK} mov eax,eax;
           add eax,eax; adc edx,edx; adc esi,esi; adc edi,edi;
           //add eax,eax; adc edx,edx; adc esi,esi; adc edi,edi;
           //add eax,ebp+0; adc edx,ebp+04;
           //adc esi,ebp+8; adc edi,ebp+12; jmp @@x05;
           //neg ebx; jmp ebx*4+@@jmpMult+4*11+4*3; //jmp ebx*4+@@jmpMult-4*8

    @@x19: {debug: OK} mov eax,eax;
           //add eax,eax; adc edx,edx; push eax; push edx;
           //adc esi,esi; adc edi,edi; push esi; push edi;
           //add eax,ebp+00; adc edx,ebp+04;
           //mov ebp+00,eax; mov ebp+04,edx;
           //adc esi,ebp+08; adc edi,ebp+12;
           //mov ebp+08,esi; mov ebp+12,edi;
           //mov eax,esp+12; mov edx,esp+8; mov esi,esp+4; mov edi,[esp];
           //add esp,16; jmp @@x09;
           neg ebx;
           add eax,eax; adc edx,edx; adc esi,esi; adc edi,edi;
           add eax,ebp+0; adc edx,ebp+04; adc esi,ebp+8; adc edi,ebp+12; //jmp @@x07;
           jmp ebx*4+@@multable+4*10+4*4; //jmp ebx*4+@@jmpMult-4*6

    //OK---------------------------------------------------------------------
    @@x31: {debug: OK} mov eax,eax; // 32n - r
           //push eax; push edi;
           //xor edi,edi; push 0; neg eax; sbb edi,edx;
           //mov ebp+0,eax; mov ebp+04,edi;
           //mov eax,[esp]; mov edi,[esp]; sbb eax,esi; sbb edi,edi;
           //mov ebp+8,eax; mov ebp+12,edi;
           //mov edi,[esp+4]; mov eax,[esp+8]; add esp,12; jmp @@x33

    @@x23: {debug: OK} mov eax,eax; // 24n - r
           //push eax; push edi;
           //xor edi,edi; push 0; neg eax; sbb edi,edx;
           //mov ebp+0,eax; mov ebp+04,edi;
           //mov eax,[esp]; mov edi,[esp]; sbb eax,esi; sbb edi,edi;
           //mov ebp+8,eax; mov ebp+12,edi;
           //mov edi,[esp+4]; mov eax,[esp+8]; add esp,12; //jmp @@x25
           //jmp ebx*4+@@jmpMult+4

    @@x15: {debug: OK} mov eax,eax; // 16n - r
           //add eax,eax; adc edx,edx; adc esi,esi; adc edi,edi;
           //add eax,ebp+0; adc edx,ebp+04;
           //mov ebp+0,eax; mov ebp+04,edx;
           //adc esi,ebp+8; adc edi,ebp+12;
           //mov ebp+8,esi; mov ebp+12,edi; jmp @@x05;
           push eax; push edi;
           xor edi,edi; push 0; neg eax; sbb edi,edx;
           mov ebp+0,eax; mov ebp+04,edi;
           mov eax,[esp]; mov edi,[esp]; sbb eax,esi; sbb edi,edi;
           mov ebp+8,eax; mov ebp+12,edi;
           mov edi,[esp+4]; mov eax,[esp+8]; add esp,12; //jmp @@x17
           jmp ebx*4+@@multable+4

    @@x29: {debug: OK} mov eax,eax; //jmp @@lmul
           add eax,eax; adc edx,edx; push eax; push edx;
           adc esi,esi; adc edi,edi; push esi; push edi;
           add eax,eax; adc edx,edx; adc esi,esi; adc edi,edi;
           add eax,ebp+00; adc edx,ebp+04;
           mov ebp+00,eax; mov ebp+04,edx;
           adc esi,ebp+08; adc edi,ebp+12;
           mov ebp+08,esi; mov ebp+12,edi;
           add eax,eax; adc edx,edx; adc esi,esi; adc edi,edi;
           jmp @@_7a

    @@x11: {debug: OK} mov eax,eax; //10n +r
           push eax; push edx; add eax,eax; adc edx,edx;
           push esi; push edi; adc esi,esi; adc edi,edi;
           add eax,eax; adc edx,edx; adc esi,esi; adc edi,edi;
           jmp @@_7a;
    //@@x10: add eax,eax; adc edx,edx; adc esi,esi; adc edi,edi;
    //       mov ebp+0,eax; mov ebp+04,edx; mov ebp+8,esi; mov ebp+12,edi; jmp @@x05;
    //OK---------------------------------------------------------------------
    //@@x49: add eax,eax; adc edx,edx; adc esi,esi; adc edi,edi; jmp @@x25
    @@x25: {24n +r}  add eax,eax; adc edx,edx; adc esi,esi; adc edi,edi; jmp @@x13
    @@x13: {12n +r}  add eax,eax; adc edx,edx; adc esi,esi; adc edi,edi; jmp @@x07
    @@x07: {6n +r}   push eax; push edx; add eax,eax; adc edx,edx;
                     push esi; push edi; adc esi,esi; adc edi,edi;
    @@_7a: {2n+2s+r} add eax,esp+12; adc edx,esp+8; adc esi,esp+4; adc edi,[esp];
                     add esp,16; jmp @@x03;
    //OK??---------------------------------------------------------------------
    @@x27: {debug: OK} mov eax,eax; //3n,3r -> 24n + 3r
           add eax,eax; adc edx,edx; adc esi,esi; adc edi,edi;
           add eax,ebp+0; adc edx,ebp+04;
           mov ebp+0,eax; mov ebp+04,edx;
           adc esi,ebp+8; adc edi,ebp+12;
           mov ebp+8,esi; mov ebp+12,edi;
           jmp @@x09
    //OK---------------------------------------------------------------------
    @@x33: {32n +r} add eax,eax; adc edx,edx; adc esi,esi; adc edi,edi; jmp @@x17;
    @@x17: {16n +r} add eax,eax; adc edx,edx; adc esi,esi; adc edi,edi; jmp @@x09;
    @@x09: {8n +r}  add eax,eax; adc edx,edx; adc esi,esi; adc edi,edi; jmp @@x05;
    @@x05: {4n +r}  add eax,eax; adc edx,edx; adc esi,esi; adc edi,edi; jmp @@x03;
    //@@x12: add eax,eax; adc edx,edx; adc esi,esi; adc edi,edi; jmp @@x06;
    //@@x06: add eax,eax; adc edx,edx; adc esi,esi; adc edi,edi;
    //       mov ebp+0,eax; mov ebp+04,edx;
    //       mov ebp+8,esi; mov ebp+12,edi; jmp @@x03;
    @@x03: {2n} add eax,eax; adc edx,edx; adc esi,esi; adc edi,edi; {2n +r}
    @@_3a: {+r} add eax,ebp+0; adc edx,ebp+04; {+r}
                adc esi,ebp+8; adc edi,ebp+12;
    //@@x08: add eax,eax; adc edx,edx; adc esi,esi; adc edi,edi; jmp @@x04;
    //@@x04: pop ebx; add eax,eax; adc edx,edx; adc esi,esi; adc edi,edi; jmp @@x02;
    //@@x02: pop ebx; add eax,eax; adc edx,edx; adc esi,esi; adc edi,edi; jmp @@addstore;
    //@@x01: pop ebx; jmp @@addstore;
    @@x00: jmp @@lmul
    @@lmul: mov ebx,edx;
      mul ecx;
      push eax; mov eax,ebx; mov ebx,edx
      mul ecx; add eax,ebx;
      adc edx,0; mov eax,esi; mov ebx,edx;
      mul ecx; add eax,ebx;
      adc edx,0; mov eax,edi; mov ebx,edx;
      mul ecx; add eax,ebx;
      adc edx,0; mov edi,eax;
      pop eax;
    @@x01: jmp @@addstore
  @@addstore: mov ebx,esp; add esp,16;
    mov ebp+0,eax; mov ebp+4,edx; mov ebp+8,esi; mov ebp+12,edi;
    mov ebp,[ebx]; mov esi,ebx+8; mov edi,[ebx+12]; mov ebx,[ebx+4]
end;

procedure intXAdd(var BigIntA; const BigIntB; const IntType: tBigInteger);
asm //movzx ecx,intType; // NO CHECKING!!!
mov ecx,intType*4+IntegerSize; shr ecx,2; jnz @@begin
//@@err: mov eax,reRangeError; call System.Error; ret
@@begin: push ebx; xor ebx,ebx;
  @@Loop:
    mov ebx,[edx]; lea edx,edx+4;
    adc [eax],ebx; lea eax,eax+4;
    dec ecx; jnl @@Loop;
@@end: pop ebx;
end;

procedure intXSub(var BigIntA; const BigIntB; const IntType: tBigInteger);
asm //movzx ecx,intType;
mov ecx,intType*4+IntegerSize; shr ecx,2; jnz @@begin
//@@err: mov eax,reRangeError; call System.Error; ret
@@begin: push ebx; xor ebx,ebx;
  @@Loop:
    mov ebx,[eax]; sbb ebx,[edx];
    mov [eax],ebx; lea eax,eax+4;
    lea edx,edx+4; dec ecx; jnz @@Loop;
@@end: pop ebx;
end;

procedure incX(var BigInt; const I: integer; const IntType: tBigInteger);
asm //movzx ecx,intType;
mov ecx,intType*4+IntegerSize; shr ecx,2; jnz @@begin
//@@err: mov eax,reRangeError; call System.Error; ret
@@begin: add [eax],I; mov edx,[eax+4]; jnb @@end
  dec ecx; jnz @@Loop; ret
  //sbb ecx,0; jc @@Loop; ret
@@Loop: adc edx,0; mov[eax+4],edx; mov edx,[eax+8];
  lea eax,eax+4; dec ecx; jnz @@Loop
@@end:
end;

procedure intXSubD_0(var BigInt; const I: integer; const IntType: tBigInteger);
asm //movzx ecx,intType;
mov ecx,intType*4+IntegerSize; shr ecx,2; jnz @@begin
//@@err: mov eax,reRangeError; call System.Error; ret
@@begin: sub [eax],I; mov edx,[eax+4]; jnb @@end
  dec ecx; jnz @@Loop; ret
@@Loop: sbb edx,0; mov[eax+4],edx; mov edx,[eax+8];
  lea eax,eax+4; dec ecx; jnz @@Loop
@@end:
end;

procedure decX(var BigInt; const I: integer; const IntType: tBigInteger);
asm //movzx ecx,intType;
mov ecx,intType*4+IntegerSize; shr ecx,2; jnz @@begin
//@@err: mov eax,reRangeError; call System.Error; ret
@@begin: neg I; jz @@end
  add I,[eax]; mov [eax],I; jnb @@end
  mov edx,[eax+4]; dec ecx; jz @@end
@@Loop: sbb edx,0; mov[eax+4],edx;
  mov edx,[eax+8]; lea eax,eax+4; jnb @@end;
  dec ecx; jnz @@Loop
@@end:
end;

procedure intXAddQ(var BigInt; const I: int64; const IntType: tBigInteger);
asm //movzx ecx,intType;
mov ecx,intType*4+IntegerSize; shr ecx,3; jnz @@begin
//@@err: mov eax,reRangeError; call System.Error; ret
@@begin: push ebx;
  mov ebx,I.r64.lo; mov edx,I.r64.hi
  sub [eax],ebx; sbb [eax+4],edx; jnb @@end
  //sbb ecx,0; jnc @@end
  dec ecx; jz @@end
@@Loop:
  mov ebx,[eax+8]; mov edx,[eax+12]
  adc ebx,0; adc edx,0;
  mov [eax+8],ebx; mov [eax+12],edx
  lea eax,eax+8; dec ecx; jnz @@Loop
@@end: pop ebx;
end;

procedure intXSubQ(var BigInt; const I: int64; const IntType: tBigInteger);
asm //movzx ecx,intType;
mov ecx,intType*4+IntegerSize; shr ecx,3; jnz @@begin
//@@err: mov eax,reRangeError; call System.Error; ret
@@begin: push ebx;
  mov ebx,I.r64.lo; mov edx,I.r64.hi
  sub [eax],ebx; sbb [eax+4],edx;
  sbb ecx,0; jnb @@end
@@Loop:
  mov ebx,[eax+8]; mov edx,[eax+12]
  sbb ebx,0; sbb edx,0;
  mov [eax+8],ebx; mov [eax+12],edx
  lea eax,eax+8; sbb ecx,0; jb @@Loop
@@end: pop ebx;
end;

function intXCmp_old(const A, B; const IntType: tBigInteger): integer;
asm //movzx ecx,intType;
  mov ecx,intType*4+IntegerSize; shr ecx,2; jnz @@begin
@@err: mov eax,reRangeError; call System.Error; ret
@@begin: push ebx;
  @@Loop: mov ebx,[eax+ecx*4-4];
    sub ebx,[edx+ecx*4-4]; jnz @@end;
    dec ecx; jnz @@Loop
@@end: pop ebx;
end;

function intXCmp(const BigIntA, BigIntB; const IntType: tBigInteger): integer;
asm
  mov ecx,intType*4+IntegerSize; sub edx,eax;
  add eax,ecx; sub eax,4; shr ecx,2; jnz @@begin
@@err: mov eax,reRangeError; call System.Error; ret
@@begin: push esi; push edi;
  @@Loop: mov esi,[eax]; mov edi,[eax+edx];
    sub eax,4; sub esi,edi; jnz @@end;
    dec ecx; jnz @@Loop
@@end: mov eax,esi; pop edi; pop esi;
end;

function IntXSize(const IntType: tBigInteger): integer; asm mov eax,eax*4+IntegerSize end;
function IntSmallestFit(const I; const ProposedIntType: tIntegerBits): tIntegerBits;
// check for smallest fit BigInteger type (excludes zero extend)
const
  maxIntBits = high(tIntegerBits);
  maxBigIntType = high(tBigInteger);
  _ALLZERO_ = -1;
asm
  //movzx edx,proposedIntType;
  push esi; mov esi,eax; xor eax,eax;
  mov edx,proposedIntType*4+IntegerSize; shr edx,2; jz @@end
  @@L: test eax,eax; jnz @@done; mov eax,[esi+edx*4-4]; dec edx; jnz @@L
  // how should i treat 0 size? leave it, or assign it an invalid mark?
  // or give it a smallest yet VALID BigInt type?
  // (i arbitrarily pick the last choice)
  // mov eax,3; // give the smallest valid bigInt
  // push _ALLZERO_; pop eax; // assign invalid
  // (i change my mind, leave it instead, so it may be used outside bigint);
  xor eax,eax; jmp @@end;
  @@done: lea esi,IntegerSize+4;
  xor eax,eax; xor ecx,ecx; lea edx,edx*4+4;
  @@n: cmp ecx,edx; jnb @@end;
  mov ecx,esi+eax*4; inc eax;
  cmp eax,maxIntBits jb @@n
  @@end: pop esi
end;

// pretty much faster than i had expected
function intXtoStr(const BigInt; const IntType: tBigInteger): string;
// TIME TABLE; how much time required to convert a full bitmask of particular BigInt type
//             (tested under PIII 2.4GHz)
//----------------------------------------------------------------------------------------
// type      p = power2,            L = length of S needed to store decimal [(2^p)-1]
//----------------------------------------------------------------------------------------
// bit       p = 2^0 = 1            Length (2^1-1)   = 1 <- Length('1')
// N.A.      p = 2^1 = 2            Length (2^2-1)   = 1 <- Length('3')
// nibble    p = 2^2 = 4            Length (2^4-1)   = 2 <- Length('15')
// byte      p = 2^3 = 8            Length (2^8-1)   = 3 <- Length('255')
// word      p = 2^4 = 16           Length (2^16-1)  = 5 <- Length('65535')
// integer   p = 2^5 = 32           Length (2^32-1)  = 10 <- Length('4294967295')
// int64     p = 2^6 = 64           Length (2^64-1)  = 20 <- Length('18446744073709551615')
// int128    p = 2^7 = 128          Length (2^128-1) = 39 <- Length('340282366920938463463374607431768211455')
// int256    p = 2^8 = 256          Length (2^256-1) = 78 <- Length('115792089237316195423570985008687907853269984665640564039457584007913129639935')
// int512    p = 2^9 = 512          Length (2^512-1) = 155
// int1024   p = 2^10 = 1024        Length (2^1024-1) = 309
// int2K     p = 2^11 = 2048        Length (2^2048-1) = 617
// int4K     p = 2^12 = 4096        Length (2^4096-1) = 1234 ~ intXtoStr: 0.003 second
// int8K     p = 2^13 = 8192        Length (2^8192-1) = 2467 ~ intXtoStr: 0.010 second
// int16K    p = 2^14 = 16384       Length (2^16384-1) = 4933 ~ intXtoStr: 0.039 second
// int32K    p = 2^15 = 32768       Length (2^32768-1) = 9865 ~ intXtoStr: 0.16 second
// int64K    p = 2^16 = 65536       Length (2^65536-1) = 19729 ~ intXtoStr: 0.65 second
// int128K   p = 2^17 = 131072      Length (2^131072-1) = 39457 ~ intXtoStr: 2.5 seconds
// int256K   p = 2^18 = 262144      Length (2^262144-1) = 78914 ~ intXtoStr: 10.3 seconds
// int512K   p = 2^19 = 524288      Length (2^524288-1) = 157827 ~ intXtoStr: 41.5 seconds
// int1024K  p = 2^20 = 1048576     Length (2^1048576-1) = 315653 ~ intXtoStr: 165.8 seconds = 2.75 minutes
// ---after here, approximation only...--------------------------------------------------------------------------------
// int2M     p = 2^21 = 2097152     Length (2^2097152-1) = 631306 ~ (estimated) intXtoStr: 170 x4 = 680 = 11+ minutes
// int4M     p = 2^22 = 4194304     Length (2^4194304-1) = 1262612 ~ (estimated) intXtoStr: 680 x4 = 2720 = 45+ minutes
// int8M     p = 2^23 = 8388608     Length (2^8388608-1) = 2525223 ~ (estimated) intXtoStr: 2720 x4 = 10880 = 3+ hours
// int16M    p = 2^24 = 16777216    Length (2^16777216-1) = 5050446 ~ (estimated) intXtoStr: 10880 x4 = 43520 = 12+ hours
// int32M    p = 2^25 = 33554432    Length (2^33554432-1) = ? (estimated) 10100892 ~ intXtoStr: 174080 = 48+ hours = 2+ days
// int64M    p = 2^26 = 67108864    Length (2^67108864-1) = ? (estimated) 20201784 ~ intXtoStr: 696320 = 193.4+ hours = 8+ days
// int128M   p = 2^27 = 134217728   Length (2^134217728-1) = ? (estimated) 40403568 ~ intXtoStr: 2785280 = 773.6+ hours = 32.4+ days
// int256M   p = 2^28 = 268435456   Length (2^268435456-1) = ? (estimated) 80807136 ~ intXtoStr: 11141120 = 3094 hours = 129 days = 4.5 month
// int512M   p = 2^29 = 536870912   Length (2^536870912-1) = ? (estimated) 161614272 ~ intXtoStr: 44564480 = 12379 hours = 516 days = 17+ months
// int1024M  p = 2^30 = 1073741824  Length (2^1073741824-1) = ? (estimated) 323228544 ~ intXtoStr: 178257920 = 49516 hours = 2063 days = 68.8 months = 5.5 years
// int2G     p = 2^31 = 2147483648  Length (2^2147483648-1) = ? (estimated) 646457088 ~ intXtoStr: 713031680 = 198064 hours = 8253 days = 275 months = 22.9 years
// int4G     p = 2^32 = 4294967296  Length (2^4294967296-1) = ? (estimated) 1292914176 ~ intXtoStr: 2852126720 = 792257 hours = 33011 days = 1100 months = 92 years
// ---limit-----------------------------------------------------------------------------------------------------------------------------------------------------------------
// int8G     p = 2^33 = 8589934592  Length (2^8589934592-1) = ? (estimated) 2585828352 ~ intXtoStr: 11408506880 = 3169030 hours = 132043 days = 4401 months = 367 years
// int16G    p = 2^34 = 17179869184 Length (2^17179869184-1) = ? (estimated) 5171656704 ~ intXtoStr: 45634027520 = 12676119 hours = 528172 days = 17606 months = 1467 years
// int32G    p = 2^35 = 34359738368 Length (2^34359738368-1) = ? (estimated) 10343313408 ~ 5.8 millenium
// int64G    p = 2^36 = 68719476736 Length (2^68719476736-1) = ? (estimated) 20686626816 ~ 23.5 millenium
// -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
const
  _10MB = 1024 * 1024 * 10;
  intXLength: array[tIntegerBits] of longword =
  (2, 5, 10, 20, 39, 78, 155, 309, 617, 1234, 2467, 4933, 9865, 19729,
    39457, 78914, 157827, 315653, 631306, 1262612, 2525223, 5050446,
    _10MB, _10MB * 2, _10MB * 4, _10MB * 8, _10MB * 16, _10MB * 32,
    _10MB * 64, _10MB * 128, Longword(_10MB) * 256, Longword(_10MB) * 409);
  decimals: array[0..9] of char = '0123456789';
var
  r: integer;
  k: longword;
  pin: ^PInt8G;
  Str: pChar;
  //X: int64;
  realType: tBigInteger;
begin
  //if not muchBlank then realType := IntType else
  realType := intSmallestFit(BigInt, IntType);
  if realType <= low(tBigInteger) then
    Result := ordinals.uintoStr(PInt64(@BigInt)^)
  else begin
    getmem(pin, IntegerSize[RealType]);
    //fastXmove8(BigInt, pin^, RealType);
    __fastMove(BigInt, pin^, IntegerSize[RealType]);
    r := intXdivD(pin^, 10, RealType);
    if r < 0 then
      Result := '0'
    else begin
      k := intXLength[RealType];
      getmem(Str, k + 1);
      Str[k] := #0;
      while r >= 0 do begin
        dec(k); if integer(k) < 0 then break;
        Str[k] := char(ord(r) + ord('0'));
        r := intXdivD(pin^, 10, RealType);
      end;
      Result := PChar(Str + k); // force as pchar
      freemem(Str);
    end;
    freemem(pin);
  end;
end;

function StrToIntX(const S: string; var BigInt; const IntType: tBigInteger): integer;
const
  _offset = 4;
  _ctr = 4 * 3 + _offset;
  _bigint = 4 * 5 + _offset;
  _size = 4 * 6 + _offset;
  _result = 4 * 7;
asm //ret//1.0000.0000h / 0Ah = 1999.9999h =  429.496.729
  //!!!movzx ecx,intType;
  mov ecx,intType*4+IntegerSize;
  sar ecx,3; jge @@Start;
  call System.Error; ret
@@Start: push ecx; fldz;
  @@fLoopz: fst qword ptr BigInt+ecx*8-8; dec ecx; jg @@fLoopz; fstp st
  pop ecx; test S,S; jz @@Stop
@@begin: pushad; //ax[7],cx[6],dx[5],bx[4],tmp[3],bp[2],si[1],di[0]
  mov esi,S; xor eax,eax;
  mov ebp,BigInt;
  xor ebx,ebx; xor edx,edx; push 10
  @@L1:
    mov bl,[esi]; inc esi;
    test bl,bl; jz @@big1
    lea eax,eax*4+eax;
    sub bl,'0'; shl eax,1;
    cmp bl,9; ja @@err
    add eax,ebx
    cmp eax,1999999Ah; jb @@L1
  @@L2:
    mov bl,[esi]; inc esi;
    test bl,bl; jz @@big1
    sub bl,'0'; cmp bl,9; ja @@err
    mov ecx,eax; mov edi,edx;
    shld edx,eax,2; shl eax,2
    add eax,ecx; adc edx,edi;
    shl eax,1; rcl edx,1;
    add eax,ebx; adc edx,0; //ja @@L2//jb @@err
    cmp edx,19999999h; jb @@L2; ja @@big1;
    cmp eax,9999999Ah; jb @@L2;
  @@big1: //xor edi,edi
    mov ebp+0,eax; mov ebp+4,edx;
    test byte ptr esi,-1; jz @@done
    mov esp._ctr,1;
  @@quad16: //inc _dbg
    mov ecx,esp._ctr
    mov bl,[esi]; inc esi;
    test bl,bl; jz @@done
    sub bl,'0';
    cmp bl,9; ja @@err
    xor edi,edi
  @@muld10:
    mov eax,[ebp]; mul [esp];
    add eax,edi; adc edx,0;
    mov [ebp],eax; mov edi,edx
    mov eax,[ebp+4];lea ebp,ebp+8; mul [esp];
    add eax,edi; adc edx,0;
    mov [ebp-4],eax; mov edi,edx
    dec ecx; jge @@muld10
    mov ebp,esp._bigint;
    mov ecx,esp._ctr; mov edx,esp._ctr;
    cmp edi,1; sbb ecx,-1; //inc ecx if edi > 0
    cmp ecx,esp._size; je @@err; {else}
    mov ebp+edx*8+8,edi

    mov esp._ctr,ecx; test bl,bl; jz @@quad16
    @@ladd: mov edi,ebp;
      mov eax,ebp+0; adc eax,ebx;
      mov edx,ebp+4; adc edx,0; lea ebp,ebp+8;
      mov edi+0,eax; mov edi+4,edx;
      jb @@ladd
    mov ebp,esp._bigint; jmp @@quad16
@@err: add esp,4; popad; mov eax,reRangeError; call System.error; jmp @@Stop
@@done: add esp,4; mov esp._result,edi; popad
@@Stop: //cmp eax,_dbg
end;

function HexToIntX(const S: string; var BigInt; const IntType: tBigInteger): integer;
// convert hexadecimal string to BigInt, this may also be applied to int64;
// albeit its length and idiosyncracies, this gains 5x faster than inttostr64
{.$DEFINE DEBUG_HEX2INT}
const
  HEXTABLE: pointer = nil;
  //errStatus: boolean = FALSE;
asm
{$IFDEF DEBUG_HEX2INT}
  //inc _dbg; mov errStatus, reRangeError;
{$ENDIF DEBUG_HEX2INT}
  //!!!movzx ecx,intType
  mov ecx,intType*4+IntegerSize; test S,S; jz @@zero
  mov [BigInt], $33333333
  push esi; mov esi,eax; mov eax,eax-4;
  push edi; mov edi,edx; xor edx,edx
  test eax,eax; jz @@done_zero;

  cmp byte ptr [esi],'$'; jnz @@scan0
  inc esi; dec eax; jz @@err_done2

  //using simpler scan instead
  @@scan0: //xor edx,edx
  @@sc0: cmp byte ptr[esi+edx],'0'; lea edx,edx+1; jz @@sc0
  lea esi,esi+edx-1; sub eax,edx; inc eax; jg @@begin;

  @@done_zero: mov edx,edi; pop edi; pop esi;
  @@zero: shr ecx,3; jz @@errX; fldz;
  @@flz0: fst qword ptr edx+ecx*8-8; dec ecx; jnz @@flz0; fstp st; jmp @@Stop;

@@begin:
  push ebx; mov ebx,HEXTABLE
  push eax; shr eax,1; adc eax,0;

  sub ecx,eax; jl @@err_done
  sub eax,1; adc eax,0;
  shr eax,2; lea edi,edi+eax*4

  shr ecx,2; jz @@mkmap;
  and eax,1; shl eax,2; add eax,edi;
  inc ecx; shr ecx,1;

  fldz; @@flz: fst qword ptr eax+ecx*8-8; dec ecx; jnz @@flz;
  fstp st;

  @@mkmap: test ebx,ebx; jnz @@getch
    xor eax,eax; inc ah
    //call System.GetMemory
    //mov ebx,[eax]; mov HEXTABLE,ebx
    call System.@GetMem
    mov ebx,eax; mov HEXTABLE,eax
    push 256/8; pop ecx;
    fld1; fchs;
    @@fln: fld st; fistp qword ptr ebx+ecx*8-8; dec ecx; jnz @@fln; fstp st;
    //mov byte ptr ebx,0  ;// NULL need also be set as a valid value
    mov word ptr ebx+'8',0908h;
    mov word ptr ebx+'E',0F0Eh; mov word ptr ebx+'e',0F0Eh;
    mov ebx+'0',03020100h; mov ebx+'4',07060504h;
    mov ebx+'A',0D0C0B0Ah; mov ebx+'a',0D0C0B0Ah;

  @@getch: mov ecx,[esp];
  //{$IFDEF DEBUG_HEX2INT} xor eax,eax; jmp @@fetch {$ENDIF}
  push esi; xor eax,eax; xor edx,edx
  shr ecx,2; jz @@testX3
  @@testX4:
    mov al,[esi]; shl edx,8; mov dl,eax+ebx
    mov al,[esi+1]; shl edx,8; mov dl,eax+ebx
    mov al,[esi+2]; shl edx,8; mov dl,eax+ebx
    mov al,[esi+3]; lea esi,esi+4; shl edx,8; mov dl,eax+ebx
    test edx,not 0f0f0f0fh; jnz @@err_test;
    dec ecx; jnz @@testX4

  @@testX3:
    mov al,[esi]; lea esi,esi+1; test al,al; jz @@done_test
    mov dl,eax+ebx; test dl,not 0fh; jnz @@err_test; jmp @@testX3

  @@done_test: pop esi

  @@fetch: pop ecx; and ecx,7; jz @@fold8

  @@fold7: xor edx,edx;
  @@L7: mov al,[esi]; lea esi,esi+1;
    shl edx,4; or dl,[ebx+eax];
    dec ecx jnz @@L7
    mov [edi],edx; lea edi,edi-4;

  @@fold8: xor edx,edx;
  movzx eax,byte ptr[esi]; test eax,eax; jz @@done_OK
  @@L8:
    shl edx,4; or dl,[ebx+eax]; mov al,[esi+1];
    shl edx,4; or dl,[ebx+eax]; mov al,[esi+2];
    shl edx,4; or dl,[ebx+eax]; mov al,[esi+3];
    shl edx,4; or dl,[ebx+eax]; mov al,[esi+4];
    shl edx,4; or dl,[ebx+eax]; mov al,[esi+5];
    shl edx,4; or dl,[ebx+eax]; mov al,[esi+6];
    shl edx,4; or dl,[ebx+eax]; mov al,[esi+7]; lea esi,esi+8;
    shl edx,4; or dl,[ebx+eax]; mov [edi], edx; lea edi,edi-4;
    mov al,[esi]; test al,al; jnz @@L8

  @@done_OK: pop ebx; pop edi; pop esi; jmp @@Stop

  @@err_test: pop esi;
  @@err_done: pop ebx;
  @@err_done2: pop ebx; pop edi; pop esi;
  @@errX: jmp @@Stop; mov eax,reIntOverflow; call System.Error; jmp @@Stop
  @@Stop:
end;

procedure intXSet(var BigInt; const IntType: tBigInteger; const Value: byte);
asm // this ONLY for 8 bytes fold! use fastcode's fillchar instead for bytes fill
  //!!!movzx edx,intType
  mov edx,intType*4+IntegerSize; shr edx,3; jz @@err
  @@begin: mov ch,cl;
  mov [eax  ],cx; mov [eax+2],cx; // these are
  mov [eax+4],cx; mov [eax+6],cx; // significant
  dec edx; jz @@Stop
  fld qword ptr [eax]; mov ecx,[eax];
  //fst qword ptr eax+edx*8;
  //mov [eax+edx*8],ecx; mov [eax+edx*8+4],ecx
  mov [eax+edx*8+0],cx; mov [eax+edx*8+2],cx; // these are
  mov [eax+edx*8+4],cx; mov [eax+edx*8+6],cx; // significant
  and eax,not 7; push esi
  @@L7a: fst qword ptr [eax+edx*8]; dec edx; jnz @@L7a
  pop esi; fstp st; ret;
  @@err: mov eax,reRangeError; call System.Error
  @@Stop:
end;

procedure intXSetMMX(var BigInt; const IntType: tBigInteger; const Value: byte);
asm // this ONLY for 8 bytes fold! use fastcode's fillchar instead for bytes fill
  //!!!movzx edx,intType
  mov edx,intType*4+IntegerSize; shr edx,3; jz @@err
  mov ch,cl;
  mov [eax  ],cx; mov [eax+2],cx; // these are
  mov [eax+4],cx; mov [eax+6],cx; // significant
  dec edx; jz @@Stop
  //fld qword ptr [eax]; //mov ecx,[eax];
  //fst qword ptr eax+edx*8;
  //mov [eax+edx*8],ecx; mov [eax+edx*8+4],ecx
  movq mm0,[eax];
  mov [eax+edx*8+0],cx; mov [eax+edx*8+2],cx; // these are
  mov [eax+edx*8+4],cx; mov [eax+edx*8+6],cx; // significant
  and eax,not 7;
  //@@L7: fst qword ptr [eax+edx*8] dec edx; jnz @@L7
  //@@done: fstp st; ret;
  @@L8: movq mm0,[eax+edx*8] dec edx; jnz @@L8
  @@doneMMX:emms; ret
  @@err: mov eax,reRangeError; call System.Error
  @@Stop:
end;

procedure intXFill(var BigInt; const IntType: tBigInteger; const Value: integer);
// fills 4 bytes pattern
asm
  //!!!movzx edx,intType
  mov edx,intType*4+IntegerSize; shr edx,3; jz @@err
  mov [eax],ecx; mov [eax+4],ecx;
  dec edx; jz @@Stop
  fild qword ptr [eax];
  fld st; fistp qword ptr eax+edx*8;
  and eax,not 7
  @@L7a: fld st; fistp qword ptr eax+edx*8; dec edx; jnz @@L7a
  fstp st; ret;
  @@err: mov eax,reRangeError; call System.Error
  @@Stop:
end;

procedure intXFill8(var BigInt; const IntType: tBigInteger; const Value: int64);
// fills 8 bytes pattern
asm
  //!!!movzx edx,intType
  mov edx,intType*4+IntegerSize; shr edx,3; jnz @@begin
  @@err: mov eax,reRangeError; call System.Error
  @@begin: fild qword ptr [Value]; fld st; fistp qword ptr [BigInt]
  dec edx; jz @@done
  fst qword ptr [eax+edx*8]
  and eax,not 7
  @@L7: fld st; fistp qword ptr eax+edx*8; dec edx; jnz @@L7
  @@done: fstp st; //ret;
  @@Stop:
end;

procedure __fastMove(const Source; var Dest; Count: Integer); assembler asm
//based on fastCode (John O'Harrow) fast! Move
  cmp eax,edx; je @@exit;
  cmp ecx,20h; ja @@move;   //caution! also of (Count < 0)
  sub ecx,08h; jg @@QQ;     //1Q+1 to 3Q
  jmp ecx*4+20h+@@dbJmp;    //upto 1Q
@@QQ: fild qword[eax]; fild qword[eax+ecx];  //load firstQ/lastQ
  cmp ecx,08h; jle @@2Q; fild qword[eax+8];  //load 2nd*Q
  cmp ecx,10h; jle @@3Q;
  fild qword[eax+10h]; fistp qword[edx+10h]; //load/save 3rd*Q
@@3Q: fistp qword[edx+08h];                  //save 2nd*Q
@@2Q: fistp qword[edx+ecx]; fistp qword[edx];//save lastQ/firstQ
@@exit: ret; mov eax,eax
@@dbJmp: dd @@exit, @@1, @@2, @@3, @@4, @@5, @@6, @@7, @@8
@@fmove: push edx; fild qword[eax];          //firstQ
  lea eax,[eax+ecx-8]; lea ecx,[ecx+edx-8];
  push ecx; neg ecx; fild qword[eax];        //lastQ
  lea ecx,[ecx+edx+8]; pop edx;              //Q-aligned
  @@LoopQ1: fild qword[eax+ecx]; fistp qword[edx+ecx];
    add ecx,8; jl @@LoopQ1;
  fistp qword[edx];                          //lastQ
  pop edx; fistp qword[edx]; ret;            //firstQ
@@move: jg @@gmove; ret                      //(Count < 0)
@@gmove: cmp eax,edx; ja @@fmove;
  sub edx,ecx; cmp eax,edx;
  lea edx,[edx+ecx]; jna @@fmove;
  sub ecx,8; push ecx;                       //backward
  fild qword[eax+ecx]; fild qword[eax];      //LAST-Q/firstQ
  add ecx,edx; and ecx,not 7; sub ecx,edx;   //Q-aligned
  @@LoopQBack: fild qword[eax+ecx]; fistp qword[edx+ecx];
    sub ecx,8; jg @@LoopQBack;
  pop ecx; fistp qword[edx]; fistp qword[edx+ecx]; //FIRST-Q/lastQ
@@done: ret
@@1: mov  cl,[eax]; mov [edx], cl; ret;
@@2: mov  cx,[eax]; mov [edx], cx; ret;
@@4: mov ecx,[eax]; mov [edx],ecx; ret;
@@3: mov  cx,[eax]; mov  al,[eax+2]; mov [edx], cx; mov [edx+2], al; ret;
@@5: mov ecx,[eax]; mov  al,[eax+4]; mov [edx],ecx; mov [edx+4], al; ret;
@@6: mov ecx,[eax]; mov  ax,[eax+4]; mov [edx],ecx; mov [edx+4], ax; ret;
@@7: mov ecx,[eax]; mov eax,[eax+3]; mov [edx],ecx; mov [edx+3],eax; ret;
@@8: fild [eax].qword; fistp [edx].qword;
//@@exit:
end;

procedure __fastFillChar(var Dest; const Count: Integer; const Value: char); overload asm
//fastCode (John O'Harrow) fast! Move
  cmp edx,32; mov ch,cl; jl @@Small
  mov [eax  ],cx; mov [eax+2],cx
  mov [eax+4],cx; mov [eax+6],cx
  sub edx,10h; fld qword ptr [eax]
  fst qword ptr [eax+edx]; fst qword ptr [eax+edx+8]
  mov ecx,eax; and ecx,7; sub ecx,8
  sub eax,ecx; add edx,ecx;
  add eax,edx; neg edx
@@Loop:
  fst qword ptr [eax+edx]; fst qword ptr [eax+edx+8]
  add edx,10h; jl @@Loop
  fstp st; ret; lea ecx,ecx+0
@@Small: test edx,edx; jle @@Done
  mov [eax+edx-1],cl
  and edx,not 1; neg edx
  lea edx,[@@SmallFill + 60 + edx * 2]
  jmp edx; mov eax,eax
@@SmallFill:
  mov [eax+28],cx; mov [eax+26],cx
  mov [eax+24],cx; mov [eax+22],cx
  mov [eax+20],cx; mov [eax+18],cx
  mov [eax+16],cx; mov [eax+14],cx
  mov [eax+12],cx; mov [eax+10],cx
  mov [eax+ 8],cx; mov [eax+ 6],cx
  mov [eax+ 4],cx; mov [eax+ 2],cx
  mov [eax   ],cx; ret;//alignment
@@Done:
end;

procedure __move(const esi; var edi; ecx: Integer); assembler asm
// internal use! based on fastCode (John O'Harrow) fast! Move
// source: esi, destination: edi
// destroys: ecx, preserved: eax,edx,esi,edi
  cmp esi,edi; jz @@exit;
  cmp ecx,20h; ja @@move;   //caution! also of (Count < 0)
  sub ecx,08h; jg @@QQ;     //1Q+1 upto 3Q
  jmp ecx*4+20h+@@dbJmp;    //upto 1Q
@@QQ: fild qword[esi]; fild qword[esi+ecx];  //firstQ/lastQ
  cmp ecx,08; jle @@2Q; fild qword[esi+8];   //2nd*Q?
  cmp ecx,10h; jle @@3Q;
  fild qword[esi+10h]; fistp qword[edi+10h]; //3rd*Q
@@3Q: fistp qword[edi+08h];                  //2nd*Q
@@2Q: fistp qword[edi+ecx];                  //lastQ
@@1Q: fistp qword[edi]; ret                  //1st*Q
@@move: jng @@exit; //skip neg
  mov edx,edi; cmp esi,edi; ja @@fmove;
  sub edx,ecx; cmp esi,edx;
  lea edx,edx+ecx; jna @@fmove;
  fild qword[esi+ecx-8]; fild qword[esi];   //LAST-Q/firstQ
  sub ecx,8; push ecx;                      //backward
  add ecx,edx; and ecx,not 7; sub ecx,edx;  //Q-aligned
  @@LoopQBack: fild qword[esi+ecx]; fistp qword[edx+ecx];
     sub ecx,8; jg @@LoopQBack; pop ecx;
  fistp qword[edi]; fistp qword[edi+ecx]; ret;  //FIRST-Q/lastQ
@@fmove:
  push eax; lea eax,esi+ecx-8;
  lea ecx,ecx+edx-8; push ecx;
  neg ecx; add ecx,edx;
  pop edx; add ecx,8; //Q-aligned
  fild qword[esi]; fild qword[eax];         //firstQ/lastQ
  @@LoopQ1: fild qword[eax+ecx]; fistp qword[edx+ecx];
    add ecx,8; jl @@LoopQ1; pop eax;
  fistp qword[edx]; fistp qword[edi]; ret //lastQ/firstQ
@@dbJmp: dd @@exit, @@1, @@2, @@3, @@4, @@5, @@6, @@7, @@8
@@1: mov  cl,[esi]; mov [edi], cl; ret
@@2: mov  cx,[esi]; mov [edi], cx; ret
@@4: mov ecx,[esi]; mov [edi],ecx; ret
@@3: push edx; mov  dx,[esi]; mov  cl,[esi+2]; mov [edi], dx; pop edx; mov [edi+2], cl; ret
@@5: push edx; mov edx,[esi]; mov  cl,[esi+4]; mov [edi],edx; pop edx; mov [edi+4], cl; ret
@@6: push edx; mov edx,[esi]; mov  cx,[esi+4]; mov [edi],edx; pop edx; mov [edi+4], cx; ret
@@7: push edx; mov edx,[esi]; mov ecx,[esi+3]; mov [edi],edx; pop edx; mov [edi+3],ecx; ret
@@8: fild [esi].qword; fistp [edi].qword; //ret
@@exit:
end;

procedure intXshl(var BigInt; const IntType: tBigInteger; const ShiftCount: integer);
{$DEFINE DO_NOT_CHANGE}
asm
  test ecx,ecx; jg @@begin
  neg ecx; jg intXshr.0dh; ret
@@begin: push esi; push edi;
  mov esi,eax; mov edi,ecx//lea edi,ecx+7;
  //!!!movzx edx,intType
  mov eax,intType*4+IntegerSize;
  shr edi,3; cmp edi,eax; jnb @@zero
@@beginSHL: test ecx,7; jz @@move;
{$DEFINE DO_NOT_CHANGE}
  //jnz @@shldd;
@@doShiftLeft: push ebp
  lea edi,ecx+7; shr edi,3
  sub eax,edi; add edi,3
  shr eax,2; and edi,-4 //not3
  mov ebp,eax; and ecx,31;
  cmp edi,5; sbb ebp,-1
  lea esi,esi+eax*4;
  @@shldl:
    mov eax,[esi-4]; mov edx,[esi]
    shld edx,eax,cl;
    mov [esi+edi-4],edx;
    lea esi,esi-4
    dec ebp
    jnz @@shldl
  @@lastfix:
  shl esi+edi-4, cl
  sub edi,4; jz @@done_shld
  push 1 pop eax; shl eax,cl; dec eax; not eax
  and esi+edi+4, eax
  lea eax,esi+4; mov edx,edi; xor ecx,ecx
  call __fastfillChar
@@done_shld: pop ebp; jmp @@done;
@@zero: mov eax,esi; xor ecx,ecx; call intXSet; jmp @@end
{$DEFINE DO_NOT_CHANGE}
@@move:
  lea edx,esi+edi; mov ecx,eax;
  mov eax,esi; sub ecx,edi; call __fastMove;
  //mov eax,esi; mov edx,edi; xor ecx,ecx; call f1fillChar
  xor ecx,ecx; mov edx,edi; mov eax,esi; call __fastfillChar
  jmp @@done;
@@done:
@@end: pop edi; pop esi; jmp @@Stop;//popad; jmp @@Stop
{$DEFINE DO_NOT_CHANGE}
@@Stop:
end;

procedure intXshr(var BigInt; const IntType: tBigInteger; const ShiftCount: integer);
{$DEFINE DO_NOT_CHANGE}
asm
  test ecx,ecx; jg @@begin
  neg ecx; jg intXshl.0dh; ret
@@begin: push esi; push edi;
  mov esi,eax; mov edi,ecx//lea edi,ecx+7;
  //!!!movzx edx,intType
  mov eax,intType*4+IntegerSize;
  shr edi,3; cmp edi,eax; jnb @@zero
@@beginSHR: test ecx,7; jz @@move;
{$DEFINE DO_NOT_CHANGE}
  //jnz @@shrdd;
@@doShiftRight: push ebp
  lea edi,ecx+7; shr edi,3
  sub eax,edi; add edi,3
  shr eax,2; and edi,-4 //not3
  mov ebp,eax; and ecx,31;
  cmp edi,5; sbb ebp,-1
  //lea esi,esi+eax*4;
  mov eax,[esi+edi-4]
  @@shrdL:
    mov edx,[esi+edi];
    shrd eax,edx,cl;
    mov [esi],eax;
    lea esi,esi+4; mov eax,edx;
    dec ebp
    jnz @@shrdL
  @@lastfix:
  shr [esi],cl
  sub edi,4; jz @@done_shrd
  push -1 pop eax; shr eax,cl//; dec eax; //not eax
  and esi-4, eax
  mov eax,esi; mov edx,edi; xor ecx,ecx
  call __fastfillChar
@@done_shrd: pop ebp; jmp @@done;
@@zero: mov eax,esi; xor ecx,ecx; call intXSet; jmp @@end
{$DEFINE DO_NOT_CHANGE}
@@move:
  push eax
  lea edx,esi+edi; mov ecx,eax;
  mov eax,esi; sub ecx,edi; //call f1Move;
  xchg eax,edx; call __fastMove;
  //mov eax,esi; mov edx,edi; xor ecx,ecx; call f1fillChar
  xor ecx,ecx; mov edx,edi; //mov eax,esi; call f1fillChar
  pop eax; add eax,esi; sub eax,edi; call __fastfillChar
jmp @@done;
@@done:
@@end: pop edi; pop esi; jmp @@Stop;//popad; jmp @@Stop
{$DEFINE DO_NOT_CHANGE}
@@Stop:
end;

procedure ShiftDLeft(var Buffer; const DWORDCount, ShiftCount: integer);
asm
  test ecx,ecx; jg @@begin
  neg ecx; jg intXshr.0dh; ret
@@begin: push esi; push edi;
  mov esi,eax; mov edi,ecx//lea edi,ecx+7;
  //!!!movzx edx,intType
  //mov eax,intType*4+IntegerSize;
  lea eax,edx*4
  shr edi,3; cmp edi,eax; jnb @@zero
@@beginSHL: test ecx,7; jz @@move;
  //jnz @@shldd;
@@ShiftLeft: push ebp
  lea edi,ecx+7; shr edi,3
  sub eax,edi; add edi,3
  shr eax,2; and edi,-4 //not3
  mov ebp,eax; and ecx,31;
  cmp edi,5; sbb ebp,-1
  lea esi,esi+eax*4;
  @@shldl:
    mov eax,[esi-4]; mov edx,[esi]
    shld edx,eax,cl;
    mov [esi+edi-4],edx;
    lea esi,esi-4; dec ebp
    jnz @@shldl
  @@lastfix:
  shl esi+edi-4, cl
  sub edi,4; jz @@done_shld
  push 1 pop eax; shl eax,cl; dec eax; not eax
  and esi+edi+4, eax
  lea eax,esi+4; mov edx,edi; xor ecx,ecx
  call __fastfillChar
@@done_shld: pop ebp; jmp @@done;
@@zero: shl edx,2; mov eax,esi; xor ecx,ecx; call __fastFillChar; jmp @@end
@@move:
  lea edx,esi+edi; mov ecx,eax;
  mov eax,esi; sub ecx,edi; call __fastMove;
  //mov eax,esi; mov edx,edi; xor ecx,ecx; call f1fillChar
  xor ecx,ecx; mov edx,edi; mov eax,esi; call __fastfillChar
  jmp @@done;
@@done:
@@end: pop edi; pop esi; jmp @@Stop;//popad; jmp @@Stop
@@Stop:
end;

procedure ShiftDRight(var Buffer; const DWORDCount, ShiftCount: integer);
asm
  test ecx,ecx; jg @@begin
  neg ecx; jg intXshl.0dh; ret
@@begin: push esi; push edi;
  mov esi,eax; mov edi,ecx//lea edi,ecx+7;
  //!!!movzx edx,intType
  //mov eax,intType*4+IntegerSize;
  lea eax,edx*4
  shr edi,3; cmp edi,eax; jnb @@zero
@@beginSHR: test ecx,7; jz @@move;
  //jnz @@shrdd;
@@ShiftRight: push ebp
  lea edi,ecx+7; shr edi,3
  sub eax,edi; add edi,3
  shr eax,2; and edi,-4 //not3
  mov ebp,eax; and ecx,31;
  cmp edi,5; sbb ebp,-1
  //lea esi,esi+eax*4;
  mov eax,[esi+edi-4]
  @@shrdL:
    mov edx,[esi+edi];
    shrd eax,edx,cl;
    mov [esi],eax;
    lea esi,esi+4;
    mov eax,edx; dec ebp
    jnz @@shrdL
  @@lastfix:
  shr [esi],cl
  sub edi,4; jz @@done_shrd
  push -1 pop eax; shr eax,cl//; dec eax; //not eax
  and esi-4, eax
  mov eax,esi; mov edx,edi; xor ecx,ecx
  call __fastfillChar
@@done_shrd: pop ebp; jmp @@done;
@@zero: shl edx,2; mov eax,esi; xor ecx,ecx; call __fastFillChar; jmp @@end
@@move:
  push eax
  lea edx,esi+edi; mov ecx,eax;
  mov eax,esi; sub ecx,edi; //call f1Move;
  xchg eax,edx; call __fastMove;
  //mov eax,esi; mov edx,edi; xor ecx,ecx; call f1fillChar
  xor ecx,ecx; mov edx,edi; //mov eax,esi; call f1fillChar
  pop eax; add eax,esi; sub eax,edi; call __fastfillChar
jmp @@done;
@@done:
@@end: pop edi; pop esi; jmp @@Stop;//popad; jmp @@Stop
@@Stop:
end;

//=======================================================================

procedure ShiftLeft(var Buffer; const BufSize, ShiftCount: integer);
asm
  test ecx,ecx; jg @@begin
  neg ecx; jg intXshr.0dh; ret
@@begin: push esi; push edi;
  mov esi,Buffer; mov edi,ShiftCount//lea edi,ecx+7;
  //!!!movzx edx,intType
  mov eax,BufSize//intType*4+IntegerSize;
  shr edi,3; cmp edi,eax; jnb @@zero
@@beginSHL: test ecx,7; jz @@move;
  //jnz @@shldd;
@@ShiftLeft: push ebp;
  lea edi,ecx+7; shr edi,3
  sub eax,edi; add edi,3
  shr eax,2; and edi,-4 //not3
  mov ebp,eax; and ecx,31;
  cmp edi,5; sbb ebp,-1
  lea esi,esi+eax*4;
  @@shldl:
    mov eax,[esi-4]; mov edx,[esi]
    shld edx,eax,cl; mov [esi+edi-4],edx;
    lea esi,esi-4; dec ebp
    jnz @@shldl
  @@lastfix:
  shl esi+edi-4, cl
  sub edi,4; jz @@done_shld
  push 1 pop eax; shl eax,cl;
  dec eax; not eax
  and esi+edi+4, eax
  lea eax,esi+4; mov edx,edi; xor ecx,ecx
  call __fastfillChar
@@done_shld: pop ebp; jmp @@done;
@@zero: mov eax,esi; xor ecx,ecx; call __fastFillChar; jmp @@end
@@move:
  lea edx,esi+edi; mov ecx,eax;
  mov eax,esi; sub ecx,edi; call __fastMove;
  //mov eax,esi; mov edx,edi; xor ecx,ecx; call f1fillChar
  xor ecx,ecx; mov edx,edi; mov eax,esi; call __fastfillChar
  jmp @@done;
@@done:
@@end: pop edi; pop esi; jmp @@Stop;//popad; jmp @@Stop
@@Stop:
end;

procedure ShiftRight(var Buffer; const BufSize, ShiftCount: integer);
asm
  test ecx,ecx; jg @@begin
  neg ecx; jg intXshl.0dh; ret
@@begin: push esi; push edi;
  mov esi,eax; mov edi,ecx//lea edi,ecx+7;
  //!!!movzx edx,intType
  mov eax,edx//intType*4+IntegerSize;
  shr edi,3; cmp edi,eax; jnb @@zero
@@beginSHR: test ecx,7; jz @@move;
  //jnz @@shrdd;
@@ShiftRight: push ebp
  lea edi,ecx+7; shr edi,3
  sub eax,edi; add edi,3
  shr eax,2; and edi,-4 //not3
  mov ebp,eax; and ecx,31;
  cmp edi,5; sbb ebp,-1
  //lea esi,esi+eax*4;
  mov eax,[esi+edi-4]
  @@shrdL:
    mov edx,[esi+edi]; shrd eax,edx,cl;
    mov [esi],eax; lea esi,esi+4;
    mov eax,edx; dec ebp
    jnz @@shrdL
  @@lastfix:
  shr [esi],cl
  sub edi,4; jz @@done_shrd
  push -1 pop eax; shr eax,cl//; dec eax; //not eax
  and esi-4, eax
  mov eax,esi; mov edx,edi; xor ecx,ecx
  call __fastfillChar
@@done_shrd: pop ebp; jmp @@done;
@@zero: mov eax,esi; xor ecx,ecx; call __fastfillChar; jmp @@end
@@move:
  push eax
  lea edx,esi+edi; mov ecx,eax;
  mov eax,esi; sub ecx,edi; //call f1Move;
  xchg eax,edx; call __fastMove;
  //mov eax,esi; mov edx,edi; xor ecx,ecx; call f1fillChar
  xor ecx,ecx; mov edx,edi; //mov eax,esi; call f1fillChar
  pop eax; add eax,esi; sub eax,edi; call __fastfillChar
jmp @@done;
@@done:
@@end: pop edi; pop esi; jmp @@Stop;//popad; jmp @@Stop
@@Stop:
end;

procedure __intXClear8(var BigInt; const Count8: integer); overload;
asm
  fldz; shr edx,1;
  jnb @@nb; fst qword ptr [eax]
  @@nb: jz @@Stop
  lea eax,eax+edx*8; fst qword ptr eax+edx*8-8;
  lea eax,eax+edx*8-8; dec edx; jz @@Stop
  and eax, not 7; fst qword ptr [eax];
  @@loop16: fst qword ptr [eax-16]; fst qword ptr [eax-8];
  sub eax,16; dec edx; jnz @@loop16;
  @@Stop: fstp st
end;

procedure __shldd(var Source, Dest; const bitShiftCount, SrcSize, DestSize: integer);
// for shiftcount mod 7 = 0 (full byte shift) SrcSize and DestSize can be of any size
// for shiftcount mod 7 > 0 (NOT full byte shift) SrcSize and DestSize should be of
// dword (4 bytes) fold; it WILL ALWAYS be folded-up to 4 bytes of given size.
asm
  @@begin: push esi; push edi; push ebx;
  mov esi,eax; mov edi,edx

  push ecx
  @@move: shr ecx,3; jz @@doneShift8
    mov ebx,ecx; mov edx,DestSize;
    sub edx,ecx; jge @@moveit
    //mov eax,edx; // negative offset
    add edx,SrcSize; jle @@allClear;
    mov ecx,DestSize;
    mov eax,edx; // bytes to move
    sub edx,ecx; jle @@esiClear

  @@moveSplit:
    //push eax; push edx; // increment of  esi
    push edx

    mov eax,esi; mov ecx,DestSize;
    add eax,edx; mov edx,edi; call __fastMove

    pop ecx; mov edx,SrcSize;
    sub edx,ecx; push edx;
    mov eax,esi; add edx,esi; call __fastMove

    mov eax,esi; pop edx;
    ;;; add esi,edx; sub SrcSize,edx
    xor ecx,ecx; call __fastfillChar

    jmp @@doneShift8

  @@moveit:
    mov ecx,edx; mov edx,edi; add edx,ebx;
    mov eax,edi; call __fastMove

    mov eax,esi; mov edx,SrcSize;
    cmp edx,ebx; jl @@move2
    mov ecx,ebx; add eax,edx;
    mov edx,edi; sub eax,ecx;
    //edi,DestSize unchanged
    call __fastMove;

    mov eax,esi; mov edx,esi
    mov ecx,SrcSize; add edx,ebx;
    sub ecx,ebx; call __fastMove;

    mov eax,esi; mov edx,ebx;
    ;;; add esi,ebx; sub SrcSize,ebx ///
    xor ecx,ecx; call __fastfillChar

    jmp @@doneShift8

    @@move2:
      mov ecx,SrcSize; lea edx,edi+ebx;
      sub edx,ecx; call __fastMove;

      mov ecx,SrcSize; mov edx,ebx;
      sub edx,ecx; mov eax,edi;
      ;;; add edi,edx; sub DestSize,edx ///
      xor ecx,ecx; call __fastfillChar

      mov eax,esi; mov edx,SrcSize;
      xor ecx,ecx; ;;; mov SrcSize,ecx; ///
      call __fastfillChar

      jmp @@doneShift8

  @@esiClear:
    neg edx; mov ecx,eax;
    push edx; add edx,edi
    mov eax,esi; call __fastMove

    pop edx; mov eax,edi;
    xor ecx,ecx; call __fastfillChar

    mov eax,esi; mov edx,SrcSize;
    xor ecx,ecx; ;;; mov SrcSize,ecx; ///
    call __fastfillChar
    jmp @@doneShift8

  @@allClear:
    mov eax,esi; mov edx,SrcSize
    xor ecx,ecx; ;;; mov SrcSize,ecx; ///
    call __fastfillChar
    mov eax,edi; mov edx,DestSize;
    xor ecx,ecx; ;;; mov DestSize,ecx; ///
    call __fastfillChar
    jmp @@doneShift8

  @@doneShift8: pop ecx
  and ecx,7; jz @@done
  xor edx,edx
  @@ShlSrc: mov eax,SrcSize; test eax,eax; jz @@ShlDst
  add esi,eax; dec eax; shr eax,2; neg eax
  @@lsh1: mov ebx,[esi+eax*4-4]
    push ebx; shld ebx,edx,cl
    mov [esi+eax*4-4],ebx;
    pop edx; inc eax; jle @@lsh1

  @@ShlDst: mov eax,DestSize; test eax,eax; jz @@ShlDone
  add edi,eax; dec eax; shr eax,2; neg eax
  @@lsh2: mov ebx,[edi+eax*4-4]
    push ebx; shld ebx,edx,cl
    mov [edi+eax*4-4],ebx;
    pop edx; inc eax; jle @@lsh2

  @@shlDone:
  //@@alldone:
  @@done: pop ebx; pop edi; pop esi;
end;

procedure __dwDivMod_unfinished(var Dividend; const Divisor; out Remainder; DwordCount: integer);
//
const
  _temp = 4 * 3; _divisor = 4 * 5;
  _dividend = 4 * 7; _remainder = 4 * 6;
// stack-contents; $20h
  _offs = 9 * 8;
  _Counter = 0 * 8 + 0; _incr = 0 * 8 + 4; // ShiftCount, increment;
  _tailS = 1 * 8 + 0; _tailR = 1 * 8 + 4; // divisor/remainder tail (actual shift)
  _nx32S = 2 * 8 + 0; _nx32D = 2 * 8 + 4; // complement-32 excess bits divisor/dividend
  _bitS = 3 * 8 + 0; bitD = 3 * 8 + 4; // size in bits (bytes * 8)
  _nLenS = 4 * 8 + 0; _nLenD = 4 * 8 + 4; // negative divisor/dividend wide (in bytes; multiple of 4 as distance)
  _LenS = 5 * 8 + 0; _LenD = 5 * 8 + 4; // divisor/dividend wide (in bytes; multiple of 4 as distance)
  _ex32S = 6 * 8 + 0; _ex32D = 6 * 8 + 4; // excess32-bit divisor/dividend
  _nCountS = 7 * 8 + 0; _nCountD = 7 * 8 + 4; // negative counter in dword size (bytes div 4)
  _CountS = 8 * 8 + 0; _CountD = 8 * 8 + 4; // actual divisor/dividend wide in dword size (bytes div 4)
asm
  test DwordCount,-1; jng @@Stop;// jmp @@Stop
  pushad //save all for ease; A7 C6 D5 B4 t3 B2 S1 D0
  mov edi,DwordCount; mov esi,Dividend;
  mov ebx,Divisor; mov eax,Remainder;
  lea edx,edi*4;
  lea esi,esi+edi*4-4; lea ebx,ebx+edi*4-4
  xor ecx,ecx; call __fastfillChar

  //mov ecx,[edi*4+IntegerSize]; mov esp._temp,edi;
  //mov ecx,edi
  //mov edx,edi; mov edi,eax;
  //lea esi,esi+ecx-4; lea ebx,ebx+ecx-4
  //shr ecx,2; mov DwordCount,ecx;
  //xor ecx,ecx; call intXSet

  mov eax,esi; and eax,not 3;
  mov edx,ebx; and edx,not 3;
  push -1; pop edi

    @@ckDivisor: mov ecx,DwordCount
    test [ebx],edi; jnz @@bsr1//jnz @@ckDividend

    and ebx,3; dec ecx; jz @@zero_divisor
    @@lc01: test [edx],edi; lea edx,edx-4;
    jnz @@done_lc01; dec ecx; jnz @@lc01
    //test edx,edx; jnz @@bsr1; // debug
    @@zero_divisor: div ecx
    @@done_lc01: lea ebx,ebx+edx+4; jmp @@bsr1
    @@bsr1: bsr edx,[ebx]
    jmp @@ckDividend

    @@ckDividend: mov ebp,DwordCount;
    test [esi],edi; jnz @@bsr2//jnz @@ckDivDiv

    and esi,3; dec ebp; jz @@done_all
    @@lc02: test [eax],edi; lea eax,eax-4;
    jnz @@done_lc02; dec ebp; jnz @@lc02;
    //  test eax,eax; jnz @@bsr2; // debug
    @@zero_dividend: jmp @@done_all
    @@done_lc02: lea esi,esi+eax+4; jmp @@bsr2
    @@bsr2: bsr eax,[esi]
    jmp @@ckDivDiv

  @@ckDivDiv: //dividend bits = ebp:eax; divisor bits = ecx:edx
    cmp ebp,ecx; ja @@begin; jb @@dd_testz
    cmp eax,edx; ja @@begin
  @@dd_testz: //lea ebp,ecx+ebp
    sete dl; movzx esi,dl; xor ecx,ecx
  @@ddprep_for_less: // esi=0 = less
    sub ecx,ebp; neg ecx; // allow reentrance by ecx with some value
    mov eax,esp+_dividend; mov edx,esp+_remainder;
    shl ecx,2; call __fastMove
    xor ebx,ebx; test esi,esi; jz @@dd_done // bits_less
  @@bits_equal:
    mov eax,esp+_divisor; mov edi,esp+_remainder;
    sub edi,eax; mov ecx,ebp; xor esi,esi; // clc; set default as less
  @@ddl_sub:
    mov edx,[eax]; sbb [eax+edi],edx; lea eax,eax+4;
    jb @@ddprep_for_less; dec ecx; jnz @@ddl_sub;
    inc ebx; jmp @@dd_done;// set 1 if not less
  @@dd_done:
    mov eax,esp+_dividend; mov [eax],ebx;
    add eax,4; lea edx,ebp*4-4;
    call __fastfillChar; jmp @@done_all

  @@begin: //dividend bits = ebp:eax > divisor bits = ecx:edx
    mov ebx,esp+_divisor; mov edi,esp+_remainder; mov esi,esp+_dividend;
    push ebp; push ecx; push ebp; push ecx; // actual counter (size in dword)
    neg [esp]; neg [esp+4]; // negative counter
    push eax; push edx; // excess-32 bit
    shl ebp,2; shl ecx,2; //
    push ebp; push ecx; push ebp; push ecx; // distance (counter * 4 bytes)
    neg [esp]; neg [esp+4]; // negative distance
    add esi,ebp; add edi,ebp; add ebx,ebp
    // here esi: dividend tail; ebx: divisor tail; edi: remainder tail

    shr ebp,3; shr ecx,3;     // crop 1 byte
    shl ebp,3+3; shl ecx,3+3; // restore; mult 8 bits
    add ebp,eax; add ecx,edx  //
    push ebp; push ecx;       // size in bits
    shl ebp,1; sub ebp,ecx    // double; sub with divisor bits

    neg eax; neg edx; and eax,31; and edx,31;
    push eax; push edx;  // complement-32 excess bit shift
    mov ecx,eax; push 1; pop eax; shl eax,cl; //increment
    push edi; push ebx; // remainder/divisor tail
    push eax; push ebp; //increment & bit-Shift Count

  @@shiftL_divisor: mov ecx,[esp._ex32S];
    test ecx,ecx; jz @@shls1_done;
    mov ebp,[esp._nCountS]; // ebx here: divisor tail
    xor eax,eax;
  @@lsh_divisor: mov edx,[ebx+ebp*4]
    push edx; shld edx,eax,cl
    mov [ebx+ebp*4],edx;
    pop eax; inc ebp; jnz @@lsh_divisor
  @@shls1_done:

  @@shiftL_dividend: mov ecx,[esp._ex32D];
    test ecx,ecx; jz @@shld1_done;
    mov ebp,[esp._nCountD]; // esi here: dividend tail
    xor eax,eax;
  @@lsh_dividend: mov edx,[esi+ebp*4]
    push edx; shld edx,eax,cl
    mov [esi+ebp*4],edx;
    pop eax; inc ebp; jnz @@lsh_dividend
  @@shld1_done:

    //mov eax,esi; mov edx,edi;
    mov eax,esp._offs._Dividend; mov edx,esp._offs._Remainder;
    mov ecx,esp._LenD; call __fastMove

    jmp @@Compare0;

  // _offs = 9 * 8;
  // _Counter = 0 * 8 + 0; _incr = 0 * 8 + 4; // ShiftCount, increment;
  // _tailS = 1 * 8 + 0; _tailR = 1 * 8 + 4; // divisor/remainder tail (actual shift)
  // _nx32S = 2 * 8 + 0; _nx32D = 2 * 8 + 4; // complement-32 excess bits divisor/dividend
  // _bitS = 3 * 8 + 0; bitD = 3 * 8 + 4; // size in bits (bytes * 8)
  // _nLenS = 4 * 8 + 0; _nLenD = 4 * 8 + 4; // negative divisor/dividend wide (in bytes; multiple of 4 as distance)
  // _LenS = 5 * 8 + 0; _LenD = 5 * 8 + 4; // divisor/dividend wide (in bytes; multiple of 4 as distance)
  // _ex32S = 6 * 8 + 0; _ex32D = 6 * 8 + 4; // excess32-bit divisor/dividend
  // _nCountS = 7 * 8 + 0; _nCountD = 7 * 8 + 4; // negative counter in dword size (bytes div 4)
  // _CountS = 8 * 8 + 0; _CountD = 8 * 8 + 4; // actual divisor/dividend wide in dword size (bytes div 4)

    @@Compare0:
      mov ebx,esp._offs._Divisor;
      mov ebp,esp._offs._Remainder; sub ebp,ebx;
      mov ecx,esp._nCountD;

    @@LCmp0: mov eax,[ebx]; mov edx,[ebx+ebp]; add ebx,4
      cmp eax,edx; jb @@SubCycle0; ja @@nextCycle0
      dec ecx; jnz @@LCmp0

    @@nextCycle0: // shiftleft by 1 (remainder < divisor)

      test esp._Counter,-1; jng @@bitshl_done
      mov ecx,esp._nCountD; xor eax,eax
      @@rcl0_1: rcl [esi+ecx*4],1; inc ecx; jnz @@rcl0_1

      mov ecx,esp._nCountS; mov edi,esp._tailR
      @@rcl0_2: rcl [edi+ecx*4],1; inc ecx; jnz @@rcl0_2

    // shifted-left by 1 (remainder shoukd be >  divisor)
    @@subCycle0: xor eax,eax
        mov ebx,esp._tailS; mov edi,esp._tailR
        mov ecx,esp._nCountD; //push ecx;

    @@Substract:
      mov ebx,esp._offs._Divisor; xor eax,eax

    @@LSub0:
      mov eax,[ebx+ecx*4];
      sbb [edi+ecx*4],eax
      inc ecx; jnz @@LSub0;

      mov eax,esp._incr; mov ecx,esp._nCountD; //pop ecx;
      or [esi+ecx*4],eax

      sub esp._Counter,1; jna @@bitshl_done

    @@ck4z:
      mov ecx,esp._nCountS; mov edx,esp._nCountD
      lea eax,edi-4; // remainder tail

      @@ck4z_R: test [eax],-1; lea eax,eax-4; jnz @@ck4z_done
      inc ecx; jnz @@ck4z_R

      lea eax,esi-4; // dividend tail
      @@ck4z_D: test [eax],-1; lea eax,eax-4; jnz @@ck4z_done
      inc edx; jnz @@ck4z_D

    @@ck4z_done: add edx,ecx;
      mov ecx,esp._CountS; add edx,esp._CountD
      add ecx,edx; shr ecx,2;

    @@getz_count: bsr edx,[edi]; add ecx,edx
      mov edx,esp._Counter;
      // ecx := minOf(ecx, edx);
      sub edx,ecx; sbb eax,eax; // if edx < ecx; eax=bitmask (edx=negative)
      and eax,edx; add ecx,eax; // if edx >= ecx; eax=zero, (edx=positive)

      mov eax,esp._offs._Dividend; mov edx,esp._offs._Remainder
      mov ebp,esp._LenD; push ebp; push ebp;
      mov ebp,ecx; call __shldd

      mov eax,esi; mov ecx,_LenS
      sub eax,ecx; mov edx,esp._incr;
      or [eax],edx; //add eax,ecx

      sub esp._Counter,ebp; jna @@bitshl_done; jmp @@Compare0

    // @@scan4n0R:
    //   //wrong: lea eax,esi-4;//ecx must NOT zero
    //   //alreday_done: mov ecx,esp._nCountS
    //   //mov eax,esp._tailR; sub eax,4
    //   //lea eax,edi-4
    //
    //   @@lscan0: add ecx,1; jna @@bitshl_done
    //   mov edx,[eax]; lea eax,eax-4; test edx,edx; jz @@lscan0;
    //
    // @@scan4n01:
    //   @@lscan1: add ecx,1; jna @@bitshl_done
    //   mov edx,[eax]; lea eax,eax-4; test edx,edx; jz @@lscan1;
    //
    //   @@getshl_count:
    //   dec ecx; add ecx,esp._CountD; bsr edx,edx;
    //   shl ecx,2; add ecx,edx;
    //   mov edx,esp._Counter;
    //   // ecx := minOf(ecx, edx);
    //   sub edx,ecx; sbb eax,eax; // if edx < ecx; eax=bitmask (edx=negative)
    //   and eax,edx; add ecx,eax; // if edx >= ecx; eax=zero, (edx=positive)
    //
    //   mov eax,esp._offs._Dividend; mov edx,esp._offs._Remainder
    //   mov ebp,esp._LenD; push ebp; push ebp;
    //   mov ebp,ecx; call __shldd
    //
    //   mov eax,esi; mov ecx,_LenS
    //   sub eax,ecx; mov edx,esp._incr;
    //   or [eax],edx; //add eax,ecx
    //
    //   sub esp._Counter,ebp; jna @@bitshl_done; jmp @@Compare0

    @@bitshl_done:


    @@shiftR_divisor: mov ecx,[esp._ex32S];
      test ecx,ecx; jz @@shr_S_done;
      mov eax,esp._tailS; sub eax,4
      mov ebp,[esp._CountS]; xor ebx,ebx;
    @@shr_divisor: mov edx,[eax];
      push edx; shld edx,ebx,cl
      mov [eax],edx; sub eax,4
      pop ebx; dec ebp; jnz @@shr_divisor
    @@shr_S_done:

    @@shiftR_dividend: mov ecx,[esp._ex32D];
      test ecx,ecx; jz @@shr_D_done;
      mov eax,esp._offs._Dividend;
      mov ebp,[esp._CountD];
      lea eax,eax+ebp*4-4; xor ebx,ebx;
    @@shr_dividend: mov edx,[eax]
      push edx; shld edx,ebx,cl
      mov [eax],edx; sub eax,4
      pop ebx; dec ebp; jnz @@shr_dividend
    @@shr_D_done:

    @@shiftR_remainder: mov ecx,[esp._ex32D];
      test ecx,ecx; jz @@shr_R_done;
      mov eax,esp._tailR; sub eax,4
      mov ebp,[esp._CountS]; xor ebx,ebx;
    @@shr_remainder: mov edx,[eax]
      push edx; shld edx,ebx,cl
      mov [eax],edx; sub eax,4
      pop ebx; dec ebp; jnz @@shr_remainder
    @@shr_R_done:
    add esp,_offs

  @@done_all: popad
  @@Stop:
end;

const
  kernel32 = 'kernel32.dll';

function WaitForSingleObject; external kernel32 name 'WaitForSingleObject';
function WaitForMultipleObjects; external kernel32 name 'WaitForMultipleObjects';
function CloseHandle; external kernel32 name 'CloseHandle';
function CreateThread; external kernel32 name 'CreateThread';

end.


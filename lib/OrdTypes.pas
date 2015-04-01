unit OrdTypes;

interface

//(* to be used in Ordinals propertyEditor *)

type
  TByte = Byte;
  TShortInt = ShortInt;
  TSmallInt = SmallInt;
  TWord = Word;
  TInteger = Integer;
  TLongword = Longword;
  TCardinal = Cardinal;
  TPointer = Pointer;
  TInt64 = Int64;
  TString = string;

  TByteR = type TByte;
  TShortIntR = type TShortInt;
  TSmallIntR = type TSmallInt;
  TWordR = type TWord;
  TIntegerR = type TInteger;
  TLongwordR = type TLongword;
  TCardinalR = type TCardinal;
  TPointerR = type TPointer;
  TInt64R = type TInt64;
  TStringR = type TString;

  TBaseAddressR = type TCardinal;
  TSegmentBaseR = type TCardinal;

  TBin8 = type TByte; // Bits
  TBin16 = type Tword;
  TBin32 = type TInteger;
  TBin64 = type TInt64;

  TOct8 = type TByte; // Octal  real
  TOct16 = type Tword;
  TOct32 = type TInteger;
  TOct64 = type TInt64;

  THex8 = type TByte; // Hexadecimal
  THex16 = type Tword;
  THex32 = type TInteger;
  THex64 = type TInt64;

  TBCD8 = type TByte; // Binary Coded Decimal, 1 Byte = type  2 digits of [0..9]
  TBCD16 = type TWord; //
  TBCD32 = type TCardinal;
  TBCD64 = type TInt64;

  TVersion = type TCardinal; // file version long format: major.minor.release.build
  TVerShort = type Tword; // packed file version (major/minor occupies 1 Byte each)
  TVerSwap = type Tword; // Big-Endian packed file version
  TVer8 = type TByte; // very packed file version such as BCD, but with hex value

  { ReadOnly Version }

  TBin8R = type TBin8;
  TBin16R = type TBin16;
  TBin32R = type TBin32;
  TBin64R = type TBin64;

  TOct8R = type TOct8;
  TOct16R = type TOct16;
  TOct32R = type TOct32;
  TOct64R = type TOct64;

  THex8R = type THex8;
  THex16R = type THex16;
  THex32R = type THex32;
  THex64R = type THex64;

  TBCD8R = type TBCD8;
  TBCD16R = type TBCD16;
  TBCD32R = type TBCD32;
  TBCD64R = type TBCD64;

  TVersionR = type TVersion;
  TVerShortR = type TVerShort;
  TVerSwapR = type TVerSwap;
  TVer8R = type TVer8;

implementation

end.


//-------------------------------------------------------
// Copyright 2002-2005, aa (Adrian H.) & Ray AF.
// PT SOFTINDO, Jakarta,
// All rights reserved
// zero_inge/at/yahoo/dot/com
//-------------------------------------------------------

// interpretation:
// CompilerX means applied to and ONLY to a specified Compiler: Compiler, Version: X
// CompilerX_up means applied to specified Compiler: Compiler, Version: X and upward Versions

{(*}//(*/// our various formatting skip

{$undef Compiler01} {$undef Compiler01_up}
{$undef Compiler02} {$undef Compiler02_up}
{$undef Compiler03} {$undef Compiler03_up}
{$undef Compiler04} {$undef Compiler04_up}
{$undef Compiler05} {$undef Compiler05_up}
{$undef Compiler06} {$undef Compiler06_up}
{$undef Compiler07} {$undef Compiler07_up}
{$undef Compiler08} {$undef Compiler08_up}
{$undef Compiler09} {$undef Compiler09_up}
{$undef Compiler10} {$undef Compiler10_up}
{$undef Compiler11} {$undef Compiler11_up}
{$undef Compiler12} {$undef Compiler12_up}
{$undef Compiler13} {$undef Compiler13_up}
{$undef Compiler14} {$undef Compiler14_up}
{$undef Compiler15} {$undef Compiler15_up}
{$undef Compiler16} {$undef Compiler16_up}
{$undef Compiler17} {$undef Compiler17_up}
// {$undef Compiler18} {$undef Compiler18_up}
// {$undef Compiler19} {$undef Compiler19_up}
// {$undef Compiler20} {$undef Compiler20_up}
// {$undef Compiler21} {$undef Compiler21_up}
// {$undef Compiler22} {$undef Compiler22_up}
// {$undef Compiler23} {$undef Compiler23_up}
// {$undef Compiler24} {$undef Compiler24_up}
// {$undef Compiler25} {$undef Compiler25_up}
// {$undef Compiler26} {$undef Compiler26_up}
// {$undef Compiler27} {$undef Compiler27_up}
// {$undef Compiler28} {$undef Compiler28_up}
// {$undef Compiler29} {$undef Compiler29_up}
// {$undef Compiler30} {$undef Compiler30_up}

{$undef RTL080} {$undef RTL080_up}
{$undef RTL090} {$undef RTL090_up}
{$undef RTL093} {$undef RTL093_up}
{$undef RTL100} {$undef RTL100_up}
{$undef RTL110} {$undef RTL110_up}
{$undef RTL120} {$undef RTL120_up}
{$undef RTL125} {$undef RTL125_up}
{$undef RTL130} {$undef RTL130_up}
{$undef RTL140} {$undef RTL140_up}
{$undef RTL150} {$undef RTL150_up}
{$undef RTL160} {$undef RTL160_up}
{$undef RTL170} {$undef RTL170_up}
{$undef RTL180} {$undef RTL180_up}
{$undef RTL190} {$undef RTL190_up}
{$undef RTL200} {$undef RTL200_up}
{$undef RTL210} {$undef RTL210_up}
{$undef RTL220} {$undef RTL220_up}
{$undef RTL230} {$undef RTL230_up}
{$undef RTL240} {$undef RTL240_up}
//{$undef RTL250} {$undef RTL250_up}
//{$undef RTL260} {$undef RTL260_up}
//{$undef RTL270} {$undef RTL270_up}
//{$undef RTL280} {$undef RTL280_up}
//{$undef RTL290} {$undef RTL290_up}
//{$undef RTL300} {$undef RTL300_up}
//{$undef RTL310} {$undef RTL310_up}
//{$undef RTL320} {$undef RTL320_up}
//{$undef RTL330} {$undef RTL330_up}
//{$undef RTL340} {$undef RTL340_up}
//{$undef RTL350} {$undef RTL350_up}

 {$ifdef Ver80} {$define RTL080} {$define RTL080_up} {$define Compiler01} {$define Compiler01_up} {$else} // D1
 {$ifdef Ver90} {$define RTL090} {$define RTL090_up} {$define Compiler02} {$define Compiler02_up} {$else} // D2
 {$ifdef Ver93} {$define RTL093} {$define RTL093_up} {$define Compiler02} {$define Compiler02_up} {$else} // BCB1
{$ifdef Ver100} {$define RTL100} {$define RTL100_up} {$define Compiler03} {$define Compiler03_up} {$else} // D3
{$ifdef Ver110} {$define RTL110} {$define RTL110_up} {$define Compiler03} {$define Compiler03_up} {$else} // BCB3
{$ifdef Ver120} {$define RTL120} {$define RTL120_up} {$define Compiler04} {$define Compiler04_up} {$else} // D4
{$ifdef Ver125} {$define RTL125} {$define RTL125_up} {$define Compiler04} {$define Compiler04_up} {$else} // BCB4
{$ifdef Ver130} {$define RTL130} {$define RTL130_up} {$define Compiler05} {$define Compiler05_up} {$else} // D5 / BCB 5
{$ifdef Ver140} {$define RTL140} {$define RTL140_up} {$define Compiler06} {$define Compiler06_up} {$else} // D6 / BCB 6 / K1 / K2 / K3
{$ifdef Ver150} {$define RTL150} {$define RTL150_up} {$define Compiler07} {$define Compiler07_up} {$else} // D7 / BCB 7 / K3
{$ifdef Ver160} {$define RTL160} {$define RTL160_up} {$define Compiler08} {$define Compiler08_up} {$else} // D8 / BCB 8 / .N1
{$ifdef Ver170} {$define RTL170} {$define RTL170_up} {$define Compiler09} {$define Compiler09_up} {$else} // D9 / BCB 9 / .N2
{$ifdef Ver180} {$define RTL180} {$define RTL180_up} {$define Compiler10} {$define Compiler10_up} {$else} // D10 / BCB 10 / .N3
{$ifdef Ver190} {$define RTL190} {$define RTL190_up} {$define Compiler11} {$define Compiler11_up} {$else}
{$ifdef Ver200} {$define RTL200} {$define RTL200_up} {$define Compiler12} {$define Compiler12_up} {$else}
{$ifdef Ver210} {$define RTL210} {$define RTL210_up} {$define Compiler13} {$define Compiler13_up} {$else}
{$ifdef Ver220} {$define RTL220} {$define RTL220_up} {$define Compiler14} {$define Compiler14_up} {$else}
{$ifdef Ver230} {$define RTL230} {$define RTL230_up} {$define Compiler15} {$define Compiler15_up} {$else}
{$ifdef Ver240} {$define RTL240} {$define RTL240_up} {$define Compiler16} {$define Compiler16_up} {$else}
{$ifdef Ver250} {$define RTL250} {$define RTL250_up} {$define Compiler17} {$define Compiler17_up} {$else}
// {$ifdef Ver260} {$define RTL260} {$define RTL260_up} {$define Compiler18} {$define Compiler18_up} {$else}
// {$ifdef Ver270} {$define RTL270} {$define RTL270_up} {$define Compiler19} {$define Compiler19_up} {$else}
// {$ifdef Ver280} {$define RTL280} {$define RTL280_up} {$define Compiler20} {$define Compiler20_up} {$else}
// {$ifdef Ver290} {$define RTL290} {$define RTL290_up} {$define Compiler21} {$define Compiler21_up} {$else}
// {$ifdef Ver300} {$define RTL300} {$define RTL300_up} {$define Compiler22} {$define Compiler22_up} {$else}
// {$ifdef Ver310} {$define RTL310} {$define RTL310_up} {$define Compiler23} {$define Compiler23_up} {$else}
// {$ifdef Ver320} {$define RTL320} {$define RTL320_up} {$define Compiler24} {$define Compiler24_up} {$else}
// {$ifdef Ver330} {$define RTL330} {$define RTL330_up} {$define Compiler25} {$define Compiler25_up} {$else}
// {$ifdef Ver340} {$define RTL340} {$define RTL340_up} {$define Compiler26} {$define Compiler26_up} {$else}
// {$ifdef Ver350} {$define RTL350} {$define RTL350_up} {$define Compiler27} {$define Compiler27_up} {$else}

and so on... ~ERROR IS EXPECTED HERE~ for cheap parser :)

// {$endif} {$endif} {$endif} {$endif} {$endif} {$endif} {$endif} {$endif} {$endif} {$endif}
{$endif} {$endif} {$endif} {$endif} {$endif} {$endif} {$endif} {$endif} {$endif} {$endif}
{$endif} {$endif} {$endif} {$endif} {$endif} {$endif} {$endif} {$endif} {$endif} {$endif}

// incremental Compiler
// {$ifdef Compiler27_up} {$define Compiler26_up} {$endif}
// {$ifdef Compiler26_up} {$define Compiler25_up} {$endif}
// {$ifdef Compiler25_up} {$define Compiler24_up} {$endif}
// {$ifdef Compiler24_up} {$define Compiler23_up} {$endif}
// {$ifdef Compiler23_up} {$define Compiler22_up} {$endif}
// {$ifdef Compiler22_up} {$define Compiler21_up} {$endif}
// {$ifdef Compiler21_up} {$define Compiler20_up} {$endif}
// {$ifdef Compiler20_up} {$define Compiler19_up} {$endif}
// {$ifdef Compiler19_up} {$define Compiler18_up} {$endif}
// {$ifdef Compiler18_up} {$define Compiler17_up} {$endif}
{$ifdef Compiler17_up} {$define Compiler16_up} {$endif}
{$ifdef Compiler16_up} {$define Compiler15_up} {$endif}
{$ifdef Compiler15_up} {$define Compiler14_up} {$endif}
{$ifdef Compiler14_up} {$define Compiler13_up} {$endif}
{$ifdef Compiler13_up} {$define Compiler12_up} {$endif}
{$ifdef Compiler12_up} {$define Compiler11_up} {$endif}
{$ifdef Compiler11_up} {$define Compiler10_up} {$endif}
{$ifdef Compiler10_up} {$define Compiler09_up} {$endif}
{$ifdef Compiler09_up} {$define Compiler08_up} {$endif}
{$ifdef Compiler08_up} {$define Compiler07_up} {$endif}
{$ifdef Compiler07_up} {$define Compiler06_up} {$endif}
{$ifdef Compiler06_up} {$define Compiler05_up} {$endif}
{$ifdef Compiler05_up} {$define Compiler04_up} {$endif}
{$ifdef Compiler04_up} {$define Compiler03_up} {$endif}
{$ifdef Compiler03_up} {$define Compiler02_up} {$endif}
{$ifdef Compiler02_up} {$define Compiler01_up} {$endif}

// incremental RTL
//{$ifdef RTL350_up} {$define RTL340_up} {$endif}
//{$ifdef RTL340_up} {$define RTL330_up} {$endif}
//{$ifdef RTL330_up} {$define RTL320_up} {$endif}
//{$ifdef RTL320_up} {$define RTL310_up} {$endif}
//{$ifdef RTL310_up} {$define RTL300_up} {$endif}
//{$ifdef RTL300_up} {$define RTL290_up} {$endif}
//{$ifdef RTL290_up} {$define RTL280_up} {$endif}
//{$ifdef RTL280_up} {$define RTL270_up} {$endif}
//{$ifdef RTL270_up} {$define RTL260_up} {$endif}
//{$ifdef RTL260_up} {$define RTL250_up} {$endif}
//{$ifdef RTL250_up} {$define RTL240_up} {$endif}
{$ifdef RTL240_up} {$define RTL230_up}  {$endif}
{$ifdef RTL230_up} {$define RTL220_up}  {$endif}
{$ifdef RTL220_up} {$define RTL210_up}  {$endif}
{$ifdef RTL210_up} {$define RTL200_up}  {$endif}
{$ifdef RTL200_up} {$define RTL190_up}  {$endif}
{$ifdef RTL190_up} {$define RTL180_up}  {$endif}
{$ifdef RTL180_up} {$define RTL170_up}  {$endif}
{$ifdef RTL170_up} {$define RTL160_up}  {$endif}
{$ifdef RTL160_up} {$define RTL150_up}  {$endif}
{$ifdef RTL150_up} {$define RTL140_up}  {$endif}
{$ifdef RTL140_up} {$define RTL130_up}  {$endif}
{$ifdef RTL130_up} {$define RTL125_up}  {$endif}
{$ifdef RTL125_up} {$define RTL120_up}  {$endif}
{$ifdef RTL120_up} {$define RTL110_up}  {$endif}
{$ifdef RTL110_up} {$define RTL100_up}  {$endif}
{$ifdef RTL100_up} {$define RTL093_up}  {$endif}
{$ifdef RTL093_up} {$define RTL090_up}  {$endif}
{$ifdef RTL090_up} {$define RTL080_up}  {$endif}

//break.test

{$undef BCB}
{$undef BDS}
{$undef DELPHI}
{$undef KYLIX}

{$ifndef Win32}
  {$ifndef LINUX} _ERROR_UNKNOWN_COMPILER_
  {$endif}
  {$define KYLIX}
  {$define QT_CLX}
{$else}
  {$ifdef Ver93}
    {$define BCB}
  {$else}
    {$ifdef Ver110}
      {$define BCB}
    {$else}
      {$ifdef Ver125}
        {$define BCB}
      {$else} // BCB defined in (start from) Ver130 ~~ Delphi 5
        {$ifndef BCB}
          {$define DELPHI}
          {$ifdef CLR}
            {$define BDS} // CLR defined for Delphi_NET
          {$endif}
        {$endif}
      {$endif}
    {$endif}
  {$endif}
{$endif}

{$ifdef DELPHI}
  {$ifdef Compiler01} {$define Delphi01} {$define Delphi01_up} {$endif}
  {$ifdef Compiler02} {$define Delphi02} {$define Delphi02_up} {$endif}
  {$ifdef Compiler03} {$define Delphi03} {$define Delphi03_up} {$endif}
  {$ifdef Compiler04} {$define Delphi04} {$define Delphi04_up} {$endif}
  {$ifdef Compiler05} {$define Delphi05} {$define Delphi05_up} {$endif}
  {$ifdef Compiler06} {$define Delphi06} {$define Delphi06_up} {$endif}
  {$ifdef Compiler07} {$define Delphi07} {$define Delphi07_up} {$endif}
  {$ifdef Compiler08} {$define Delphi08} {$define Delphi08_up} {$endif}
  {$ifdef Compiler09} {$define Delphi09} {$define Delphi09_up} {$endif}
  {$ifdef Compiler10} {$define Delphi10} {$define Delphi10_up} {$endif}
  {$ifdef Compiler11} {$define Delphi11} {$define Delphi11_up} {$endif}
  {$ifdef Compiler12} {$define Delphi12} {$define Delphi12_up} {$endif}
  {$ifdef Compiler13} {$define Delphi13} {$define Delphi13_up} {$endif}
  {$ifdef Compiler14} {$define Delphi14} {$define Delphi14_up} {$endif}
  {$ifdef Compiler15} {$define Delphi15} {$define Delphi15_up} {$endif}
  {$ifdef Compiler16} {$define Delphi16} {$define Delphi16_up} {$endif}
  {$ifdef Compiler17} {$define Delphi17} {$define Delphi17_up} {$endif}

  {$ifdef Delphi17_up} {$define Delphi16_up} {$endif}
  {$ifdef Delphi16_up} {$define Delphi15_up} {$endif}
  {$ifdef Delphi15_up} {$define Delphi14_up} {$endif}
  {$ifdef Delphi14_up} {$define Delphi13_up} {$endif}
  {$ifdef Delphi13_up} {$define Delphi12_up} {$endif}
  {$ifdef Delphi12_up} {$define Delphi11_up} {$endif}
  {$ifdef Delphi11_up} {$define Delphi10_up} {$endif}
  {$ifdef Delphi10_up} {$define Delphi09_up} {$endif}
  {$ifdef Delphi09_up} {$define Delphi08_up} {$endif}
  {$ifdef Delphi08_up} {$define Delphi07_up} {$endif}
  {$ifdef Delphi07_up} {$define Delphi06_up} {$endif}
  {$ifdef Delphi06_up} {$define Delphi05_up} {$endif}
  {$ifdef Delphi05_up} {$define Delphi04_up} {$endif}
  {$ifdef Delphi04_up} {$define Delphi03_up} {$endif}
  {$ifdef Delphi03_up} {$define Delphi02_up} {$endif}
  {$ifdef Delphi02_up} {$define Delphi01_up} {$endif}
  {$ifdef Delphi01_up} {$define Delphi00_up} {$endif}
{$endif DELPHI}

//break.test

{$ifdef BDS}
  {$ifndef Compiler08_up} _ERROR_DELPHI_NET_START_FROM_DELPHI_8_ {$endif}

  {$ifdef Compiler08} {$define BDS01} {$define BDS01_up} {$endif}
  {$ifdef Compiler09} {$define BDS02} {$define BDS02_up} {$endif}
  {$ifdef Compiler10} {$define BDS03} {$define BDS03_up} {$endif}
  {$ifdef Compiler11} {$define BDS04} {$define BDS04_up} {$endif}
  {$ifdef Compiler12} {$define BDS05} {$define BDS05_up} {$endif}
  {$ifdef Compiler13} {$define BDS06} {$define BDS06_up} {$endif}
  {$ifdef Compiler14} {$define BDS07} {$define BDS07_up} {$endif}
  {$ifdef Compiler15} {$define BDS08} {$define BDS08_up} {$endif}
  {$ifdef Compiler16} {$define BDS09} {$define BDS09_up} {$endif}
  {$ifdef Compiler17} {$define BDS10} {$define BDS10_up} {$endif}

  {$ifdef BDS10_up} {$define BDS09_up} {$endif}
  {$ifdef BDS09_up} {$define BDS08_up} {$endif}
  {$ifdef BDS08_up} {$define BDS07_up} {$endif}
  {$ifdef BDS07_up} {$define BDS06_up} {$endif}
  {$ifdef BDS06_up} {$define BDS05_up} {$endif}
  {$ifdef BDS05_up} {$define BDS04_up} {$endif}
  {$ifdef BDS04_up} {$define BDS03_up} {$endif}
  {$ifdef BDS03_up} {$define BDS02_up} {$endif}
  {$ifdef BDS02_up} {$define BDS01_up} {$endif}
{$endif BDS}

//break.test

{$ifdef KYLIX}
  {$ifndef Compiler06_up} _ERROR_KYLIX_START_FROM_DELPHI_6_ {$endif}

  {$ifdef Compiler06}
    // note:
    //   NEVER using $if - $ifend pair, unless they're really necessary
    //   the IDE WILL ALWAYS parse them even if they will never be reached anyway
    //
    // example:
    //   {$undef BOTCH} // clear
    //   {$ifdef BOTCH}
    //     $if some junks,  -> OK
    //     I see no BOTCH here,  --> OK
    //     ... another junks,  -> OK
    //     {$nonexistent_directive is doesn't matter too},  -> OK
    //     {$if any BOTCH here?}  -> ERROR! // MUST be closed with {$ifend}
    //   {$endif}
    //
    {.$ifdef conditionalexpressions} // always did
    {$if Declared(RTLVersion) and (RTLVersion = 14.2)} {$define Kylix01}
    {$elseif Declared(RTLVersion) and (RTLVersion = 14.2) } {$define Kylix02}
    {$elseif Declared(RTLVersion) and (RTLVersion = 14.5)} {$define Kylix03}
    {$else} _ERROR_UNKNOWN_KYLIX_VERSION_
    {$ifend}
  {$endif}

  {$ifdef Compiler07} {$define Kylix03} {$define Kylix03_up} {$endif}
  {$ifdef Compiler08} {$define Kylix04} {$define Kylix04_up} {$endif}
  {$ifdef Compiler09} {$define Kylix05} {$define Kylix05_up} {$endif}
  {$ifdef Compiler10} {$define Kylix06} {$define Kylix06_up} {$endif}
  {$ifdef Compiler11} {$define Kylix07} {$define Kylix07_up} {$endif}
  {$ifdef Compiler12} {$define Kylix08} {$define Kylix08_up} {$endif}
  {$ifdef Compiler13} {$define Kylix09} {$define Kylix09_up} {$endif}
  {$ifdef Compiler14} {$define Kylix10} {$define Kylix10_up} {$endif}
  {$ifdef Compiler15} {$define Kylix11} {$define Kylix11_up} {$endif}
  {$ifdef Compiler16} {$define Kylix12} {$define Kylix12_up} {$endif}
  {$ifdef Compiler17} {$define Kylix13} {$define Kylix13_up} {$endif}

  {$ifdef Kylix13_up} {$define Kylix12_up} {$endif}
  {$ifdef Kylix12_up} {$define Kylix11_up} {$endif}
  {$ifdef Kylix11_up} {$define Kylix10_up} {$endif}
  {$ifdef Kylix10_up} {$define Kylix09_up} {$endif}
  {$ifdef Kylix09_up} {$define Kylix08_up} {$endif}
  {$ifdef Kylix08_up} {$define Kylix07_up} {$endif}
  {$ifdef Kylix07_up} {$define Kylix06_up} {$endif}
  {$ifdef Kylix06_up} {$define Kylix05_up} {$endif}
  {$ifdef Kylix05_up} {$define Kylix04_up} {$endif}
  {$ifdef Kylix04_up} {$define Kylix03_up} {$endif}
  {$ifdef Kylix03_up} {$define Kylix02_up} {$endif}
  {$ifdef Kylix02_up} {$define Kylix01_up} {$endif}
{$endif KYLIX}

//break.test

{$ifdef BCB}
  {$ifndef Compiler02_up} _ERROR_UNKNOWN_BCB_VerSION_ {$endif}

  {$ifdef Compiler02} {$define BCB02} {$define BCB02_up} {$endif}
  {$ifdef Compiler03} {$define BCB03} {$define BCB03_up} {$endif}
  {$ifdef Compiler04} {$define BCB04} {$define BCB04_up} {$endif}
  {$ifdef Compiler05} {$define BCB05} {$define BCB05_up} {$endif}
  {$ifdef Compiler06} {$define BCB06} {$define BCB06_up} {$endif}
  {$ifdef Compiler07} {$define BCB07} {$define BCB07_up} {$endif}
  {$ifdef Compiler08} {$define BCB08} {$define BCB08_up} {$endif}
  {$ifdef Compiler09} {$define BCB09} {$define BCB09_up} {$endif}
  {$ifdef Compiler10} {$define BCB10} {$define BCB10_up} {$endif}
  {$ifdef Compiler11} {$define BCB11} {$define BCB11_up} {$endif}
  {$ifdef Compiler12} {$define BCB12} {$define BCB12_up} {$endif}
  {$ifdef Compiler13} {$define BCB13} {$define BCB13_up} {$endif}
  {$ifdef Compiler14} {$define BCB14} {$define BCB14_up} {$endif}
  {$ifdef Compiler15} {$define BCB15} {$define BCB15_up} {$endif}
  {$ifdef Compiler16} {$define BCB16} {$define BCB16_up} {$endif}
  {$ifdef Compiler17} {$define BCB17} {$define BCB17_up} {$endif}

  {$ifdef BCB17_up} {$define BCB16_up} {$endif}
  {$ifdef BCB16_up} {$define BCB15_up} {$endif}
  {$ifdef BCB15_up} {$define BCB14_up} {$endif}
  {$ifdef BCB14_up} {$define BCB13_up} {$endif}
  {$ifdef BCB13_up} {$define BCB12_up} {$endif}
  {$ifdef BCB12_up} {$define BCB11_up} {$endif}
  {$ifdef BCB11_up} {$define BCB10_up} {$endif}
  {$ifdef BCB10_up} {$define BCB09_up} {$endif}
  {$ifdef BCB09_up} {$define BCB08_up} {$endif}
  {$ifdef BCB08_up} {$define BCB07_up} {$endif}
  {$ifdef BCB07_up} {$define BCB06_up} {$endif}
  {$ifdef BCB06_up} {$define BCB05_up} {$endif}
  {$ifdef BCB05_up} {$define BCB04_up} {$endif}
  {$ifdef BCB04_up} {$define BCB03_up} {$endif}
  {$ifdef BCB03_up} {$define BCB02_up} {$endif}
  {$ifdef BCB02_up} {$define BCB01_up} {$endif}
{$endif BCB}

{$ifdef BCB_3_up}
  {$OBJEXPORTALL ON}
{$endif}

//
// compatibilities
//

{$define DEF_COMPAT_COMPILER_ON}
{$ifdef DEF_COMPAT_COMPILER_ON}
  {$ifdef Compiler01_up} {$define Compiler_01_up} {$define Compiler_01up}  {$define Compiler1_up} {$define Compiler_1_up} {$define Compiler_1up} {$endif}
  {$ifdef Compiler02_up} {$define Compiler_02_up} {$define Compiler_02up}  {$define Compiler2_up} {$define Compiler_2_up} {$define Compiler_2up} {$endif}
  {$ifdef Compiler03_up} {$define Compiler_03_up} {$define Compiler_03up}  {$define Compiler3_up} {$define Compiler_3_up} {$define Compiler_3up} {$endif}
  {$ifdef Compiler04_up} {$define Compiler_04_up} {$define Compiler_04up}  {$define Compiler4_up} {$define Compiler_4_up} {$define Compiler_4up} {$endif}
  {$ifdef Compiler05_up} {$define Compiler_05_up} {$define Compiler_05up}  {$define Compiler5_up} {$define Compiler_5_up} {$define Compiler_5up} {$endif}
  {$ifdef Compiler06_up} {$define Compiler_06_up} {$define Compiler_06up}  {$define Compiler6_up} {$define Compiler_6_up} {$define Compiler_6up} {$endif}
  {$ifdef Compiler07_up} {$define Compiler_07_up} {$define Compiler_07up}  {$define Compiler7_up} {$define Compiler_7_up} {$define Compiler_7up} {$endif}
  {$ifdef Compiler08_up} {$define Compiler_08_up} {$define Compiler_08up}  {$define Compiler8_up} {$define Compiler_8_up} {$define Compiler_8up} {$endif}
  {$ifdef Compiler09_up} {$define Compiler_09_up} {$define Compiler_09up}  {$define Compiler9_up} {$define Compiler_9_up} {$define Compiler_9up} {$endif}
  {$ifdef Compiler10_up} {$define Compiler_10_up} {$define Compiler_10up} {$endif}
  {$ifdef Compiler11_up} {$define Compiler_11_up} {$define Compiler_11up} {$endif}
  {$ifdef Compiler12_up} {$define Compiler_12_up} {$define Compiler_12up} {$endif}
  {$ifdef Compiler13_up} {$define Compiler_13_up} {$define Compiler_13up} {$endif}
  {$ifdef Compiler14_up} {$define Compiler_14_up} {$define Compiler_14up} {$endif}
  {$ifdef Compiler15_up} {$define Compiler_15_up} {$define Compiler_15up} {$endif}
  {$ifdef Compiler16_up} {$define Compiler_16_up} {$define Compiler_16up} {$endif}
  {$ifdef Compiler17_up} {$define Compiler_17_up} {$define Compiler_17up} {$endif}
{$endif}

{$define DEF_COMPAT_DELPHI_ON}
{$ifdef DEF_COMPAT_DELPHI_ON}
  {$ifdef Delphi01} {$define Delphi_01} {$define Delphi1} {$define Delphi_1} {$endif}
  {$ifdef Delphi02} {$define Delphi_02} {$define Delphi2} {$define Delphi_2} {$endif}
  {$ifdef Delphi03} {$define Delphi_03} {$define Delphi3} {$define Delphi_3} {$endif}
  {$ifdef Delphi04} {$define Delphi_04} {$define Delphi4} {$define Delphi_4} {$endif}
  {$ifdef Delphi05} {$define Delphi_05} {$define Delphi5} {$define Delphi_5} {$endif}
  {$ifdef Delphi06} {$define Delphi_06} {$define Delphi6} {$define Delphi_6} {$endif}
  {$ifdef Delphi07} {$define Delphi_07} {$define Delphi7} {$define Delphi_7} {$endif}
  {$ifdef Delphi08} {$define Delphi_08} {$define Delphi8} {$define Delphi_8} {$endif}
  {$ifdef Delphi09} {$define Delphi_09} {$define Delphi9} {$define Delphi_9} {$endif}
  {$ifdef Delphi10} {$define Delphi_10} {$endif}
  {$ifdef Delphi11} {$define Delphi_11} {$endif}
  {$ifdef Delphi12} {$define Delphi_12} {$endif}
  {$ifdef Delphi13} {$define Delphi_13} {$endif}
  {$ifdef Delphi14} {$define Delphi_14} {$endif}
  {$ifdef Delphi15} {$define Delphi_15} {$endif}
  {$ifdef Delphi16} {$define Delphi_16} {$endif}
  {$ifdef Delphi17} {$define Delphi_17} {$endif}

  {$ifdef Delphi01_up} {$define Delphi_01_up} {$define Delphi_01up} {$define Delphi1_up} {$define Delphi_1_up} {$define Delphi_1up} {$endif}
  {$ifdef Delphi02_up} {$define Delphi_02_up} {$define Delphi_02up} {$define Delphi2_up} {$define Delphi_2_up} {$define Delphi_2up} {$endif}
  {$ifdef Delphi03_up} {$define Delphi_03_up} {$define Delphi_03up} {$define Delphi3_up} {$define Delphi_3_up} {$define Delphi_3up} {$endif}
  {$ifdef Delphi04_up} {$define Delphi_04_up} {$define Delphi_04up} {$define Delphi4_up} {$define Delphi_4_up} {$define Delphi_4up} {$endif}
  {$ifdef Delphi05_up} {$define Delphi_05_up} {$define Delphi_05up} {$define Delphi5_up} {$define Delphi_5_up} {$define Delphi_5up} {$endif}
  {$ifdef Delphi06_up} {$define Delphi_06_up} {$define Delphi_06up} {$define Delphi6_up} {$define Delphi_6_up} {$define Delphi_6up} {$endif}
  {$ifdef Delphi07_up} {$define Delphi_07_up} {$define Delphi_07up} {$define Delphi7_up} {$define Delphi_7_up} {$define Delphi_7up} {$endif}
  {$ifdef Delphi08_up} {$define Delphi_08_up} {$define Delphi_08up} {$define Delphi8_up} {$define Delphi_8_up} {$define Delphi_8up} {$endif}
  {$ifdef Delphi09_up} {$define Delphi_09_up} {$define Delphi_09up} {$define Delphi9_up} {$define Delphi_9_up} {$define Delphi_9up} {$endif}
  {$ifdef Delphi10_up} {$define Delphi_10_up} {$define Delphi_10up} {$endif}
  {$ifdef Delphi11_up} {$define Delphi_11_up} {$define Delphi_11up} {$endif}
  {$ifdef Delphi12_up} {$define Delphi_12_up} {$define Delphi_12up} {$endif}
  {$ifdef Delphi13_up} {$define Delphi_13_up} {$define Delphi_13up} {$endif}
  {$ifdef Delphi14_up} {$define Delphi_14_up} {$define Delphi_14up} {$endif}
  {$ifdef Delphi15_up} {$define Delphi_15_up} {$define Delphi_15up} {$endif}
  {$ifdef Delphi16_up} {$define Delphi_16_up} {$define Delphi_16up} {$endif}
  {$ifdef Delphi17_up} {$define Delphi_17_up} {$define Delphi_17up} {$endif}

  {...define DEF_COMPAT_DELPHI.NET_ON}
  {$ifdef DEF_COMPAT_DELPHI_NET_ON}
    // DELPHI.NET (with DOT) is no more valid as identifier
    {$ifdef BDS01} {$define Delphi_NET_01} {$define Delphi_NET1} {$define Delphi_NET_1} {$endif}
    {$ifdef BDS02} {$define Delphi_NET_02} {$define Delphi_NET2} {$define Delphi_NET_2} {$endif}
    {$ifdef BDS03} {$define Delphi_NET_03} {$define Delphi_NET3} {$define Delphi_NET_3} {$endif}
    {$ifdef BDS04} {$define Delphi_NET_04} {$define Delphi_NET4} {$define Delphi_NET_4} {$endif}
    {$ifdef BDS05} {$define Delphi_NET_05} {$define Delphi_NET5} {$define Delphi_NET_5} {$endif}
    {$ifdef BDS06} {$define Delphi_NET_06} {$define Delphi_NET6} {$define Delphi_NET_6} {$endif}
    {$ifdef BDS07} {$define Delphi_NET_07} {$define Delphi_NET7} {$define Delphi_NET_7} {$endif}
    {$ifdef BDS08} {$define Delphi_NET_08} {$define Delphi_NET8} {$define Delphi_NET_8} {$endif}
    {$ifdef BDS09} {$define Delphi_NET_09} {$define Delphi_NET9} {$define Delphi_NET_9} {$endif}
    {$ifdef BDS10} {$define Delphi_NET_10} {$endif}

    {$ifdef BDS01_up} {$define Delphi_NET_01_up} {$define Delphi_NET_01up} {$define Delphi_NET1_up} {$define Delphi_NET_1_up} {$define Delphi_NET_1up} {$endif}
    {$ifdef BDS02_up} {$define Delphi_NET_02_up} {$define Delphi_NET_02up} {$define Delphi_NET2_up} {$define Delphi_NET_2_up} {$define Delphi_NET_2up} {$endif}
    {$ifdef BDS03_up} {$define Delphi_NET_03_up} {$define Delphi_NET_03up} {$define Delphi_NET3_up} {$define Delphi_NET_3_up} {$define Delphi_NET_3up} {$endif}
    {$ifdef BDS04_up} {$define Delphi_NET_04_up} {$define Delphi_NET_04up} {$define Delphi_NET4_up} {$define Delphi_NET_4_up} {$define Delphi_NET_4up} {$endif}
    {$ifdef BDS05_up} {$define Delphi_NET_05_up} {$define Delphi_NET_05up} {$define Delphi_NET5_up} {$define Delphi_NET_5_up} {$define Delphi_NET_5up} {$endif}
    {$ifdef BDS06_up} {$define Delphi_NET_06_up} {$define Delphi_NET_06up} {$define Delphi_NET6_up} {$define Delphi_NET_6_up} {$define Delphi_NET_6up} {$endif}
    {$ifdef BDS07_up} {$define Delphi_NET_07_up} {$define Delphi_NET_07up} {$define Delphi_NET7_up} {$define Delphi_NET_7_up} {$define Delphi_NET_7up} {$endif}
    {$ifdef BDS08_up} {$define Delphi_NET_08_up} {$define Delphi_NET_08up} {$define Delphi_NET8_up} {$define Delphi_NET_8_up} {$define Delphi_NET_8up} {$endif}
    {$ifdef BDS09_up} {$define Delphi_NET_09_up} {$define Delphi_NET_09up} {$define Delphi_NET9_up} {$define Delphi_NET_9_up} {$define Delphi_NET_9up} {$endif}
    {$ifdef BDS10_up} {$define Delphi_NET_10_up} {$define Delphi_NET_10up} {$endif}
  {$endif}

  {$define DEF_COMPAT_DELPHI_RX}
  {$ifdef DEF_COMPAT_DELPHI_RX}
    {$ifdef Delphi03} {$define RX_D3} {$endif}
    {$ifdef Delphi04} {$define RX_D4} {$endif}
    {$ifdef Delphi05} {$define RX_D5} {$endif}
    {$ifdef RX_D5} {$define RX_D4} {$endif}
    {$ifdef RX_D4} {$define RX_D3} {$endif}
  {$endif DEF_COMPAT_DELPHI_RX}
{$endif DEF_COMPAT_DELPHI_ON}

{$define DEF_COMPAT_BCB_ON}
{$ifdef DEF_COMPAT_BCB_ON}
  {$ifdef BCB01} {$define BCB_01} {$define BCB1} {$define BCB_1} {$endif}
  {$ifdef BCB02} {$define BCB_02} {$define BCB2} {$define BCB_2} {$endif}
  {$ifdef BCB03} {$define BCB_03} {$define BCB3} {$define BCB_3} {$endif}
  {$ifdef BCB04} {$define BCB_04} {$define BCB4} {$define BCB_4} {$endif}
  {$ifdef BCB05} {$define BCB_05} {$define BCB5} {$define BCB_5} {$endif}
  {$ifdef BCB06} {$define BCB_06} {$define BCB6} {$define BCB_6} {$endif}
  {$ifdef BCB07} {$define BCB_07} {$define BCB7} {$define BCB_7} {$endif}
  {$ifdef BCB08} {$define BCB_08} {$define BCB8} {$define BCB_8} {$endif}
  {$ifdef BCB09} {$define BCB_09} {$define BCB9} {$define BCB_9} {$endif}
  {$ifdef BCB10} {$define BCB_10} {$endif}
  {$ifdef BCB11} {$define BCB_11} {$endif}
  {$ifdef BCB12} {$define BCB_12} {$endif}
  {$ifdef BCB13} {$define BCB_13} {$endif}
  {$ifdef BCB14} {$define BCB_14} {$endif}
  {$ifdef BCB15} {$define BCB_15} {$endif}
  {$ifdef BCB16} {$define BCB_16} {$endif}
  {$ifdef BCB17} {$define BCB_17} {$endif}

  {$ifdef BCB01_up} {$define BCB_01_up} {$define BCB_01up} {$define BCB1_up} {$define BCB_1_up} {$define BCB_1up} {$endif}
  {$ifdef BCB02_up} {$define BCB_02_up} {$define BCB_02up} {$define BCB2_up} {$define BCB_2_up} {$define BCB_2up} {$endif}
  {$ifdef BCB03_up} {$define BCB_03_up} {$define BCB_03up} {$define BCB3_up} {$define BCB_3_up} {$define BCB_3up} {$endif}
  {$ifdef BCB04_up} {$define BCB_04_up} {$define BCB_04up} {$define BCB4_up} {$define BCB_4_up} {$define BCB_4up} {$endif}
  {$ifdef BCB05_up} {$define BCB_05_up} {$define BCB_05up} {$define BCB5_up} {$define BCB_5_up} {$define BCB_5up} {$endif}
  {$ifdef BCB06_up} {$define BCB_06_up} {$define BCB_06up} {$define BCB6_up} {$define BCB_6_up} {$define BCB_6up} {$endif}
  {$ifdef BCB07_up} {$define BCB_07_up} {$define BCB_07up} {$define BCB7_up} {$define BCB_7_up} {$define BCB_7up} {$endif}
  {$ifdef BCB08_up} {$define BCB_08_up} {$define BCB_08up} {$define BCB8_up} {$define BCB_8_up} {$define BCB_8up} {$endif}
  {$ifdef BCB09_up} {$define BCB_09_up} {$define BCB_09up} {$define BCB9_up} {$define BCB_9_up} {$define BCB_9up} {$endif}
  {$ifdef BCB10_up} {$define BCB_10_up} {$define BCB_10up} {$endif}
  {$ifdef BCB11_up} {$define BCB_11_up} {$define BCB_11up} {$endif}
  {$ifdef BCB12_up} {$define BCB_12_up} {$define BCB_12up} {$endif}
  {$ifdef BCB13_up} {$define BCB_13_up} {$define BCB_13up} {$endif}
  {$ifdef BCB14_up} {$define BCB_14_up} {$define BCB_14up} {$endif}
  {$ifdef BCB15_up} {$define BCB_15_up} {$define BCB_15up} {$endif}
  {$ifdef BCB16_up} {$define BCB_16_up} {$define BCB_16up} {$endif}
  {$ifdef BCB17_up} {$define BCB_17_up} {$define BCB_17up} {$endif}

  {.$define DEF_COMPAT_CPPB_ON}
  {$ifdef DEF_COMPAT_CPPB_ON}
    {$ifdef BCB01_up} {$define CPPB_01_up} {$define CPPB_01up} {$define CPPB1_up} {$define CPPB_1_up}  {$define CPPB_1up} {$endif}
    {$ifdef BCB02_up} {$define CPPB_02_up} {$define CPPB_02up} {$define CPPB2_up} {$define CPPB_2_up}  {$define CPPB_2up} {$endif}
    {$ifdef BCB03_up} {$define CPPB_03_up} {$define CPPB_03up} {$define CPPB3_up} {$define CPPB_3_up}  {$define CPPB_3up} {$endif}
    {$ifdef BCB04_up} {$define CPPB_04_up} {$define CPPB_04up} {$define CPPB4_up} {$define CPPB_4_up}  {$define CPPB_4up} {$endif}
    {$ifdef BCB05_up} {$define CPPB_05_up} {$define CPPB_05up} {$define CPPB5_up} {$define CPPB_5_up}  {$define CPPB_5up} {$endif}
    {$ifdef BCB06_up} {$define CPPB_06_up} {$define CPPB_06up} {$define CPPB6_up} {$define CPPB_6_up}  {$define CPPB_6up} {$endif}
    {$ifdef BCB07_up} {$define CPPB_07_up} {$define CPPB_07up} {$define CPPB7_up} {$define CPPB_7_up}  {$define CPPB_7up} {$endif}
    {$ifdef BCB08_up} {$define CPPB_08_up} {$define CPPB_08up} {$define CPPB8_up} {$define CPPB_8_up}  {$define CPPB_8up} {$endif}
    {$ifdef BCB09_up} {$define CPPB_09_up} {$define CPPB_09up} {$define CPPB9_up} {$define CPPB_9_up}  {$define CPPB_9up} {$endif}
    {$ifdef BCB10_up} {$define CPPB_10_up} {$define CPPB_10up} {$endif}
    {$ifdef BCB11_up} {$define CPPB_11_up} {$define CPPB_11up} {$endif}
    {$ifdef BCB12_up} {$define CPPB_12_up} {$define CPPB_12up} {$endif}
    {$ifdef BCB13_up} {$define CPPB_13_up} {$define CPPB_13up} {$endif}
    {$ifdef BCB14_up} {$define CPPB_14_up} {$define CPPB_14up} {$endif}
    {$ifdef BCB15_up} {$define CPPB_15_up} {$define CPPB_15up} {$endif}
    {$ifdef BCB16_up} {$define CPPB_16_up} {$define CPPB_16up} {$endif}
    {$ifdef BCB17_up} {$define CPPB_17_up} {$define CPPB_17up} {$endif}
  {$endif DEF_COMPAT_CPPB_ON}
{$endif DEF_COMPAT_BCB_ON}

{.$define DEF_COMPAT_DFS}
{$ifdef DEF_COMPAT_DFS}
  {$ifdef Compiler01} {$define DFS_Compiler_1} {$endif}
  {$ifdef Compiler02} {$define DFS_Compiler_2} {$endif}
  {$ifdef Compiler03} {$define DFS_Compiler_3} {$endif}
  {$ifdef Compiler04} {$define DFS_Compiler_4} {$endif}
  {$ifdef Compiler05} {$define DFS_Compiler_5} {$endif}
  {$ifdef Compiler06} {$define DFS_Compiler_6} {$endif}
  {$ifdef Compiler07} {$define DFS_Compiler_7} {$endif}
  {$ifdef Compiler08} {$define DFS_Compiler_8} {$endif}
  {$ifdef Compiler09} {$define DFS_Compiler_9} {$endif}
  {$ifdef Compiler10} {$define DFS_Compiler_10} {$endif}
  {$ifdef Compiler11} {$define DFS_Compiler_11} {$endif}
  {$ifdef Compiler12} {$define DFS_Compiler_12} {$endif}
  {$ifdef Compiler13} {$define DFS_Compiler_13} {$endif}
  {$ifdef Compiler14} {$define DFS_Compiler_14} {$endif}
  {$ifdef Compiler15} {$define DFS_Compiler_15} {$endif}
  {$ifdef Compiler16} {$define DFS_Compiler_16} {$endif}
  {$ifdef Compiler17} {$define DFS_Compiler_17} {$endif}

  {$ifdef Compiler01_up} {$define DFS_Compiler_1_up} {$endif}
  {$ifdef Compiler02_up} {$define DFS_Compiler_2_up} {$endif}
  {$ifdef Compiler03_up} {$define DFS_Compiler_3_up} {$endif}
  {$ifdef Compiler04_up} {$define DFS_Compiler_4_up} {$endif}
  {$ifdef Compiler05_up} {$define DFS_Compiler_5_up} {$endif}
  {$ifdef Compiler06_up} {$define DFS_Compiler_6_up} {$endif}
  {$ifdef Compiler07_up} {$define DFS_Compiler_7_up} {$endif}
  {$ifdef Compiler08_up} {$define DFS_Compiler_8_up} {$endif}
  {$ifdef Compiler09_up} {$define DFS_Compiler_9_up} {$endif}
  {$ifdef Compiler10_up} {$define DFS_Compiler_10_up} {$endif}
  {$ifdef Compiler11_up} {$define DFS_Compiler_11_up} {$endif}
  {$ifdef Compiler12_up} {$define DFS_Compiler_12_up} {$endif}
  {$ifdef Compiler13_up} {$define DFS_Compiler_13_up} {$endif}
  {$ifdef Compiler14_up} {$define DFS_Compiler_14_up} {$endif}
  {$ifdef Compiler15_up} {$define DFS_Compiler_15_up} {$endif}
  {$ifdef Compiler16_up} {$define DFS_Compiler_16_up} {$endif}
  {$ifdef Compiler17_up} {$define DFS_Compiler_17_up} {$endif}

  {$ifdef Delphi01} {$define DFS_Delphi_1} {$endif}
  {$ifdef Delphi02} {$define DFS_Delphi_2} {$endif}
  {$ifdef Delphi03} {$define DFS_Delphi_3} {$endif}
  {$ifdef Delphi04} {$define DFS_Delphi_4} {$endif}
  {$ifdef Delphi05} {$define DFS_Delphi_5} {$endif}
  {$ifdef Delphi06} {$define DFS_Delphi_6} {$endif}
  {$ifdef Delphi07} {$define DFS_Delphi_7} {$endif}
  {$ifdef Delphi08} {$define DFS_Delphi_8} {$endif}
  {$ifdef Delphi09} {$define DFS_Delphi_9} {$endif}
  {$ifdef Delphi10} {$define DFS_Delphi_10} {$endif}
  {$ifdef Delphi11} {$define DFS_Delphi_11} {$endif}
  {$ifdef Delphi12} {$define DFS_Delphi_12} {$endif}
  {$ifdef Delphi13} {$define DFS_Delphi_13} {$endif}
  {$ifdef Delphi14} {$define DFS_Delphi_14} {$endif}
  {$ifdef Delphi15} {$define DFS_Delphi_15} {$endif}
  {$ifdef Delphi16} {$define DFS_Delphi_16} {$endif}
  {$ifdef Delphi17} {$define DFS_Delphi_17} {$endif}

  {$ifdef Delphi01_up} {$define DFS_Delphi_1_up} {$endif}
  {$ifdef Delphi02_up} {$define DFS_Delphi_2_up} {$endif}
  {$ifdef Delphi03_up} {$define DFS_Delphi_3_up} {$endif}
  {$ifdef Delphi04_up} {$define DFS_Delphi_4_up} {$endif}
  {$ifdef Delphi05_up} {$define DFS_Delphi_5_up} {$endif}
  {$ifdef Delphi06_up} {$define DFS_Delphi_6_up} {$endif}
  {$ifdef Delphi07_up} {$define DFS_Delphi_7_up} {$endif}
  {$ifdef Delphi08_up} {$define DFS_Delphi_8_up} {$endif}
  {$ifdef Delphi09_up} {$define DFS_Delphi_9_up} {$endif}
  {$ifdef Delphi10_up} {$define DFS_Delphi_10_up} {$endif}
  {$ifdef Delphi11_up} {$define DFS_Delphi_11_up} {$endif}
  {$ifdef Delphi12_up} {$define DFS_Delphi_12_up} {$endif}
  {$ifdef Delphi13_up} {$define DFS_Delphi_13_up} {$endif}
  {$ifdef Delphi14_up} {$define DFS_Delphi_14_up} {$endif}
  {$ifdef Delphi15_up} {$define DFS_Delphi_15_up} {$endif}
  {$ifdef Delphi16_up} {$define DFS_Delphi_16_up} {$endif}
  {$ifdef Delphi17_up} {$define DFS_Delphi_17_up} {$endif}

  {$ifdef BCB01} {$define DFS_CPPB_1} {$endif}
  {$ifdef BCB02} {$define DFS_CPPB_2} {$endif}
  {$ifdef BCB03} {$define DFS_CPPB_3} {$endif}
  {$ifdef BCB04} {$define DFS_CPPB_4} {$endif}
  {$ifdef BCB05} {$define DFS_CPPB_5} {$endif}
  {$ifdef BCB06} {$define DFS_CPPB_6} {$endif}
  {$ifdef BCB07} {$define DFS_CPPB_7} {$endif}
  {$ifdef BCB08} {$define DFS_CPPB_8} {$endif}
  {$ifdef BCB09} {$define DFS_CPPB_9} {$endif}
  {$ifdef BCB10} {$define DFS_CPPB_10} {$endif}
  {$ifdef BCB11} {$define DFS_CPPB_11} {$endif}
  {$ifdef BCB12} {$define DFS_CPPB_12} {$endif}
  {$ifdef BCB13} {$define DFS_CPPB_13} {$endif}
  {$ifdef BCB14} {$define DFS_CPPB_14} {$endif}
  {$ifdef BCB15} {$define DFS_CPPB_15} {$endif}
  {$ifdef BCB16} {$define DFS_CPPB_16} {$endif}
  {$ifdef BCB17} {$define DFS_CPPB_17} {$endif}

  {$ifdef BCB01_up} {$define DFS_CPPB_1_up} {$endif}
  {$ifdef BCB02_up} {$define DFS_CPPB_2_up} {$endif}
  {$ifdef BCB03_up} {$define DFS_CPPB_3_up} {$endif}
  {$ifdef BCB04_up} {$define DFS_CPPB_4_up} {$endif}
  {$ifdef BCB05_up} {$define DFS_CPPB_5_up} {$endif}
  {$ifdef BCB06_up} {$define DFS_CPPB_6_up} {$endif}
  {$ifdef BCB07_up} {$define DFS_CPPB_7_up} {$endif}
  {$ifdef BCB08_up} {$define DFS_CPPB_8_up} {$endif}
  {$ifdef BCB09_up} {$define DFS_CPPB_9_up} {$endif}
  {$ifdef BCB10_up} {$define DFS_CPPB_10_up} {$endif}
  {$ifdef BCB11_up} {$define DFS_CPPB_11_up} {$endif}
  {$ifdef BCB12_up} {$define DFS_CPPB_12_up} {$endif}
  {$ifdef BCB13_up} {$define DFS_CPPB_13_up} {$endif}
  {$ifdef BCB14_up} {$define DFS_CPPB_14_up} {$endif}
  {$ifdef BCB15_up} {$define DFS_CPPB_15_up} {$endif}
  {$ifdef BCB16_up} {$define DFS_CPPB_16_up} {$endif}
  {$ifdef BCB17_up} {$define DFS_CPPB_17_up} {$endif}

{$endif DEF_COMPAT_DFS}



// don't worry about those bulk of constants
// it's easy to get them from gnu's bc; try this shell script:
// #!/bin/sh
// /bin/bc<<"#EOF"
// for (i=1; i<=19; i++) {
//   obase=A;
//   print "\n"
//   for (j=1; j<10; j++) {
//     n=10^i*j
//     r=65536*65536
//     a=n/r; b=n%r
//     obase=A; print "n"; print i; "_"; print j; "="
//     obase=16; print "0"; print n; print "h; "
//     obase=A; print "n"; print i; "_"; print j; "hi="
//      obase=16; print "0"; print a; print "h; "
//     obase=A; print "n"; print i; "_"; print j; "lo="
//     obase=16; print "0"; print b; print "h;\n"
//   }
// }
// quit
// #EOF

const
  E01_1 = $0A; E01_1hi = $00; E01_1lo = $0A;
  E01_2 = $014; E01_2hi = $00; E01_2lo = $014;
  E01_3 = $01E0; E01_3hi = $00; E01_3lo = $01E0;
  E01_4 = $028; E01_4hi = $00; E01_4lo = $028;
  E01_5 = $032; E01_5hi = $00; E01_5lo = $032;
  E01_6 = $03C; E01_6hi = $00; E01_6lo = $03C;
  E01_7 = $046; E01_7hi = $00; E01_7lo = $046;
  E01_8 = $050; E01_8hi = $00; E01_8lo = $050;
  E01_9 = $05A; E01_9hi = $00; E01_9lo = $05A;
  E02_1 = $064; E02_1hi = $00; E02_1lo = $064;
  E02_2 = $0C8; E02_2hi = $00; E02_2lo = $0C8;
  E02_3 = $012C; E02_3hi = $00; E02_3lo = $012C;
  E02_4 = $0190; E02_4hi = $00; E02_4lo = $0190;
  E02_5 = $01F4; E02_5hi = $00; E02_5lo = $01F4;
  E02_6 = $0258; E02_6hi = $00; E02_6lo = $0258;
  E02_7 = $02BC; E02_7hi = $00; E02_7lo = $02BC;
  E02_8 = $0320; E02_8hi = $00; E02_8lo = $0320;
  E02_9 = $0384; E02_9hi = $00; E02_9lo = $0384;
  E03_1 = $03E08; E03_1hi = $00; E03_1lo = $03E08;
  E03_2 = $07D0; E03_2hi = $00; E03_2lo = $07D0;
  E03_3 = $0BB8; E03_3hi = $00; E03_3lo = $0BB8;
  E03_4 = $0FA0; E03_4hi = $00; E03_4lo = $0FA0;
  E03_5 = $01388; E03_5hi = $00; E03_5lo = $01388;
  E03_6 = $01770; E03_6hi = $00; E03_6lo = $01770;
  E03_7 = $01B58; E03_7hi = $00; E03_7lo = $01B58;
  E03_8 = $01F40; E03_8hi = $00; E03_8lo = $01F40;
  E03_9 = $02328; E03_9hi = $00; E03_9lo = $02328;
  E04_1 = $02710; E04_1hi = $00; E04_1lo = $02710;
  E04_2 = $04E020; E04_2hi = $00; E04_2lo = $04E020;
  E04_3 = $07530; E04_3hi = $00; E04_3lo = $07530;
  E04_4 = $09C40; E04_4hi = $00; E04_4lo = $09C40;
  E04_5 = $0C350; E04_5hi = $00; E04_5lo = $0C350;
  E04_6 = $0E0A60; E04_6hi = $00; E04_6lo = $0E0A60;
  E04_7 = $011170; E04_7hi = $00; E04_7lo = $011170;
  E04_8 = $013880; E04_8hi = $00; E04_8lo = $013880;
  E04_9 = $015F90; E04_9hi = $00; E04_9lo = $015F90;
  E05_1 = $0186A0; E05_1hi = $00; E05_1lo = $0186A0;
  E05_2 = $030D40; E05_2hi = $00; E05_2lo = $030D40;
  E05_3 = $0493E00; E05_3hi = $00; E05_3lo = $0493E00;
  E05_4 = $061A80; E05_4hi = $00; E05_4lo = $061A80;
  E05_5 = $07A120; E05_5hi = $00; E05_5lo = $07A120;
  E05_6 = $0927C0; E05_6hi = $00; E05_6lo = $0927C0;
  E05_7 = $0AAE060; E05_7hi = $00; E05_7lo = $0AAE060;
  E05_8 = $0C3500; E05_8hi = $00; E05_8lo = $0C3500;
  E05_9 = $0DBBA0; E05_9hi = $00; E05_9lo = $0DBBA0;
  E06_1 = $0F4240; E06_1hi = $00; E06_1lo = $0F4240;
  E06_2 = $01E08480; E06_2hi = $00; E06_2lo = $01E08480;
  E06_3 = $02DC6C0; E06_3hi = $00; E06_3lo = $02DC6C0;
  E06_4 = $03D0900; E06_4hi = $00; E06_4lo = $03D0900;
  E06_5 = $04C4B40; E06_5hi = $00; E06_5lo = $04C4B40;
  E06_6 = $05B8D80; E06_6hi = $00; E06_6lo = $05B8D80;
  E06_7 = $06ACFC0; E06_7hi = $00; E06_7lo = $06ACFC0;
  E06_8 = $07A1200; E06_8hi = $00; E06_8lo = $07A1200;
  E06_9 = $0895440; E06_9hi = $00; E06_9lo = $0895440;
  E07_1 = $0989680; E07_1hi = $00; E07_1lo = $0989680;
  E07_2 = $01312D00; E07_2hi = $00; E07_2lo = $01312D00;
  E07_3 = $01C9C380; E07_3hi = $00; E07_3lo = $01C9C380;
  E07_4 = $02625A00; E07_4hi = $00; E07_4lo = $02625A00;
  E07_5 = $02FAF080; E07_5hi = $00; E07_5lo = $02FAF080;
  E07_6 = $03938700; E07_6hi = $00; E07_6lo = $03938700;
  E07_7 = $042C1D80; E07_7hi = $00; E07_7lo = $042C1D80;
  E07_8 = $04C4B400; E07_8hi = $00; E07_8lo = $04C4B400;
  E07_9 = $055D4A80; E07_9hi = $00; E07_9lo = $055D4A80;
  E08_1 = $05F5E0100; E08_1hi = $00; E08_1lo = $05F5E0100;
  E08_2 = $0BE0BC200; E08_2hi = $00; E08_2lo = $0BE0BC200;
  E08_3 = $011E01A300; E08_3hi = $00; E08_3lo = $011E01A300;
  E08_4 = $017D78400; E08_4hi = $00; E08_4lo = $017D78400;
  E08_5 = $01DCD6500; E08_5hi = $00; E08_5lo = $01DCD6500;
  E08_6 = $023C34600; E08_6hi = $00; E08_6lo = $023C34600;
  E08_7 = $029B92700; E08_7hi = $00; E08_7lo = $029B92700;
  E08_8 = $02FAF0800; E08_8hi = $00; E08_8lo = $02FAF0800;
  E08_9 = $035A4E0900; E08_9hi = $00; E08_9lo = $035A4E0900;
  E09_1 = $03B9ACA00; E09_1hi = $00; E09_1lo = $03B9ACA00;
  E09_2 = $077359400; E09_2hi = $00; E09_2lo = $077359400;
  E09_3 = $0B2D05E000; E09_3hi = $00; E09_3lo = $0B2D05E000;
  E09_4 = $0E0E06B2800; E09_4hi = $00; E09_4lo = $0E0E06B2800;
  E09_5 = $012A05F200; E09_5hi = $01; E09_5lo = $02A05F200;
  E09_6 = $0165A0BC00; E09_6hi = $01; E09_6lo = $065A0BC00;
  E09_7 = $01A13B8600; E09_7hi = $01; E09_7lo = $0A13B8600;
  E09_8 = $01DCD65000; E09_8hi = $01; E09_8lo = $0DCD65000;
  E09_9 = $0218711A00; E09_9hi = $02; E09_9lo = $018711A00;
  E10_1 = $02540BE400; E10_1hi = $02; E10_1lo = $0540BE400;
  E10_2 = $04A817C800; E10_2hi = $04; E10_2lo = $0A817C800;
  E10_3 = $06FC23AC00; E10_3hi = $06; E10_3lo = $0FC23AC00;
  E10_4 = $09502F9000; E10_4hi = $09; E10_4lo = $0502F9000;
  E10_5 = $0BA43B7400; E10_5hi = $0B; E10_5lo = $0A43B7400;
  E10_6 = $0DF8475800; E10_6hi = $0D; E10_6lo = $0F8475800;
  E10_7 = $0104C533C00; E10_7hi = $010; E10_7lo = $04C533C00;
  E10_8 = $012A05F2000; E10_8hi = $012; E10_8lo = $0A05F2000;
  E10_9 = $014F46B0400; E10_9hi = $014; E10_9lo = $0F46B0400;
  E11_1 = $0174876E800; E11_1hi = $017; E11_1lo = $04876E800;
  E11_2 = $02E90EDD000; E11_2hi = $02E; E11_2lo = $090EDD000;
  E11_3 = $045D964B800; E11_3hi = $045; E11_3lo = $0D964B800;
  E11_4 = $05D21DBA000; E11_4hi = $05D; E11_4lo = $021DBA000;
  E11_5 = $0746A528800; E11_5hi = $074; E11_5lo = $06A528800;
  E11_6 = $08BB2C97000; E11_6hi = $08B; E11_6lo = $0B2C97000;
  E11_7 = $0A2FB405800; E11_7hi = $0A2; E11_7lo = $0FB405800;
  E11_8 = $0BA43B74000; E11_8hi = $0BA; E11_8lo = $043B74000;
  E11_9 = $0D18C2E2800; E11_9hi = $0D1; E11_9lo = $08C2E2800;
  E12_1 = $0E8D4A51000; E12_1hi = $0E8; E12_1lo = $0D4A51000;
  E12_2 = $01D1A94A2000; E12_2hi = $01D1; E12_2lo = $0A94A2000;
  E12_3 = $02BA7DEF3000; E12_3hi = $02BA; E12_3lo = $07DEF3000;
  E12_4 = $03A352944000; E12_4hi = $03A3; E12_4lo = $052944000;
  E12_5 = $048C27395000; E12_5hi = $048C; E12_5lo = $027395000;
  E12_6 = $0574FBDE6000; E12_6hi = $0574; E12_6lo = $0FBDE6000;
  E12_7 = $065DD0837000; E12_7hi = $065D; E12_7lo = $0D0837000;
  E12_8 = $0746A5288000; E12_8hi = $0746; E12_8lo = $0A5288000;
  E12_9 = $082F79CD9000; E12_9hi = $082F; E12_9lo = $079CD9000;
  E13_1 = $09184E72A000; E13_1hi = $0918; E13_1lo = $04E72A000;
  E13_2 = $012309CE54000; E13_2hi = $01230; E13_2lo = $09CE54000;
  E13_3 = $01B48EB57E000; E13_3hi = $01B48; E13_3lo = $0EB57E000;
  E13_4 = $0246139CA8000; E13_4hi = $02461; E13_4lo = $039CA8000;
  E13_5 = $02D79883D2000; E13_5hi = $02D79; E13_5lo = $0883D2000;
  E13_6 = $03691D6AFC000; E13_6hi = $03691; E13_6lo = $0D6AFC000;
  E13_7 = $03FAA25226000; E13_7hi = $03FAA; E13_7lo = $025226000;
  E13_8 = $048C273950000; E13_8hi = $048C2; E13_8lo = $073950000;
  E13_9 = $051DAC207A000; E13_9hi = $051DA; E13_9lo = $0C207A000;

  E14_1 = $05AF3107A4000; E14_1hi = $05AF3; E14_1lo = $0107A4000;
  E14_2 = $0B5E620F48000; E14_2hi = $0B5E6; E14_2lo = $020F48000;
  E14_3 = $0110D9316EC000; E14_3hi = $0110D9; E14_3lo = $0316EC000;
  E14_4 = $016BCC41E90000; E14_4hi = $016BCC; E14_4lo = $041E90000;
  E14_5 = $01C6BF52634000; E14_5hi = $01C6BF; E14_5lo = $052634000;
  E14_6 = $0221B262DD8000; E14_6hi = $0221B2; E14_6lo = $062DD8000;
  E14_7 = $027CA57357C000; E14_7hi = $027CA5; E14_7lo = $07357C000;
  E14_8 = $02D79883D20000; E14_8hi = $02D798; E14_8lo = $083D20000;
  E14_9 = $03328B944C4000; E14_9hi = $03328B; E14_9lo = $0944C4000;
  
  E15_1 = $038D7EA4C68000; E15_1hi = $038D7E; E15_1lo = $0A4C68000;
  E15_2 = $071AFD498D0000; E15_2hi = $071AFD; E15_2lo = $0498D0000;
  E15_3 = $0AA87BEE538000; E15_3hi = $0AA87B; E15_3lo = $0EE538000;
  E15_4 = $0E35FA931A0000; E15_4hi = $0E35FA; E15_4lo = $0931A0000;
  E15_5 = $011C37937E08000; E15_5hi = $011C379; E15_5lo = $037E08000;
  E15_6 = $01550F7DCA70000; E15_6hi = $01550F7; E15_6lo = $0DCA70000;
  E15_7 = $018DE76816D8000; E15_7hi = $018DE76; E15_7lo = $0816D8000;
  E15_8 = $01C6BF526340000; E15_8hi = $01C6BF5; E15_8lo = $026340000;
  E15_9 = $01FF973CAFA8000; E15_9hi = $01FF973; E15_9lo = $0CAFA8000;
  E16_1 = $02386F26FC10000; E16_1hi = $02386F2; E16_1lo = $06FC10000;
  E16_2 = $0470DE4DF820000; E16_2hi = $0470DE4; E16_2lo = $0DF820000;
  E16_3 = $06A94D74F430000; E16_3hi = $06A94D7; E16_3lo = $04F430000;
  E16_4 = $08E1BC9BF040000; E16_4hi = $08E1BC9; E16_4lo = $0BF040000;
  E16_5 = $0B1A2BC2EC50000; E16_5hi = $0B1A2BC; E16_5lo = $02EC50000;
  E16_6 = $0D529AE9E860000; E16_6hi = $0D529AE; E16_6lo = $09E860000;
  E16_7 = $0F8B0A10E470000; E16_7hi = $0F8B0A1; E16_7lo = $0E470000;
  E16_8 = $011C37937E080000; E16_8hi = $011C3793; E16_8lo = $07E080000;
  E16_9 = $013FBE85EDC90000; E16_9hi = $013FBE85; E16_9lo = $0EDC90000;
  E17_1 = $016345785D8A0000; E17_1hi = $01634578; E17_1lo = $05D8A0000;
  E17_2 = $02C68AF0BB140000; E17_2hi = $02C68AF0; E17_2lo = $0BB140000;
  E17_3 = $0429D069189E0000; E17_3hi = $0429D069; E17_3lo = $0189E0000;
  E17_4 = $058D15E176280000; E17_4hi = $058D15E1; E17_4lo = $076280000;
  E17_5 = $06F05B59D3B20000; E17_5hi = $06F05B59; E17_5lo = $0D3B20000;
  E17_6 = $0853A0D2313C0000; E17_6hi = $0853A0D2; E17_6lo = $0313C0000;
  E17_7 = $09B6E64A8EC60000; E17_7hi = $09B6E64A; E17_7lo = $08EC60000;
  E17_8 = $0B1A2BC2EC500000; E17_8hi = $0B1A2BC2; E17_8lo = $0EC500000;
  E17_9 = $0C7D713B49DA0000; E17_9hi = $0C7D713B; E17_9lo = $049DA0000;
  E18_1 = $0DE0B6B3A7640000; E18_1hi = $0DE0B6B3; E18_1lo = $0A7640000;
  E18_2 = $01BC16D674EC80000; E18_2hi = $01BC16D67; E18_2lo = $04EC80000;
  E18_3 = $029A2241AF62C0000; E18_3hi = $029A2241A; E18_3lo = $0F62C0000;
  E18_4 = $03782DACE9D900000; E18_4hi = $03782DACE; E18_4lo = $09D900000;
  E18_5 = $04563918244F40000; E18_5hi = $045639182; E18_5lo = $044F40000;
  E18_6 = $053444835EC580000; E18_6hi = $053444835; E18_6lo = $0EC580000;
  E18_7 = $06124FEE993BC0000; E18_7hi = $06124FEE9; E18_7lo = $093BC0000;
  E18_8 = $06F05B59D3B200000; E18_8hi = $06F05B59D; E18_8lo = $03B200000;
  E18_9 = $07CE66C50E2840000; E18_9hi = $07CE66C50; E18_9lo = $0E2840000;
  E19_1 = $08AC7230489E80000; E19_1hi = $08AC72304; E19_1lo = $089E80000;
  //E19_2 = $01158E460913D00000; E19_2hi = $01158E4609; E19_2lo = $013D00000;
  //E19_3 = $01A055690D9DB80000; E19_3hi = $01A055690D; E19_3lo = $09DB80000;
  //E19_4 = $022B1C8C1227A00000; E19_4hi = $022B1C8C12; E19_4lo = $027A00000;
  //E19_5 = $02B5E3AF16B1880000; E19_5hi = $02B5E3AF16; E19_5lo = $0B1880000;
  //E19_6 = $0340AAD21B3B700000; E19_6hi = $0340AAD21B; E19_6lo = $03B700000;
  //E19_7 = $03CB71F51FC5580000; E19_7hi = $03CB71F51F; E19_7lo = $0C5580000;
  //E19_8 = $04563918244F400000; E19_8hi = $0456391824; E19_8lo = $04F400000;
  //E19_9 = $04E1003B28D9280000; E19_9hi = $04E1003B28; E19_9lo = $0D9280000;

unit mamat;

interface

function geta003(const I: Int64): integer;
function getl00(const I: Int64): integer;
function getl01(const I: Int64): integer;
function getl02(const I: Int64): integer;
function getl02a(const I: Int64): integer;

implementation
const
  //int64 //_1e19 =  -8446744073709551616
  _1e19 = $8AC7230489E80000; _1e19h = $8AC72304; _1e19L = $89E80000;
  _1e18 = $0DE0B6B3A7640000; _1e18h = $0DE0B6B3; _1e18L = $A7640000;
  _1e17 = $016345785D8A0000; _1e17h = $01634578; _1e17L = $5D8A0000;
  _1e16 = $002386F26FC10000; _1e16h = $002386F2; _1e16L = $6FC10000;
  _1e15 = $00038D7EA4C68000; _1e15h = $00038D7E; _1e15L = $A4C68000;
  _1e14 = $00005AF3107A4000; _1e14h = $00005AF3; _1e14L = $107A4000;
  _1e13 = $000009184E72A000; _1e13h = $00000918; _1e13L = $4E72A000;
  _1e12 = $000000E8D4A51000; _1e12h = $000000E8; _1e12L = $D4A51000;
  _1e11 = $000000174876E800; _1e11h = $00000017; _1e11L = $4876E800;
  _1e10 = $00000002540BE400; _1e10h = $00000002; _1e10L = $540BE400;

  //integer
  _1e09 = $3B9ACA00; _1e08 = $05F5E100; _1e07 = $00989680;
  _1e06 = $000F4240; _1e05 = $000186A0;

  //word/byte
  _1e04 = $2710; _1e03 = $03E8; _1e02 = $64; _1e01 = $A; _1e00 = 0;

//$6BC75E2D 63100000
//8AC7230489E80000
function getl01(const I: Int64): integer;
var
  Len: integer;
begin
  if I < _1e19 then Len := 19
  else begin
    if I > _1e09 then begin
      if I > _1e14 then begin
        if I > _1e16 then begin
          if I > _1e18 then Len := 19
          else if I > _1e17 then Len := 18
          else Len := 17
        end
        else begin
          if I > _1e15 then Len := 16
          else len := 15
        end
      end
      else begin
        if I > _1e11 then begin
          if I > _1e13 then Len := 14
          else begin
            if I > _1e12 then Len := 13
            else Len := 14
          end
        end
        else begin
          if I > _1e10 then Len := 11
          else Len := 10
        end
      end
    end
    else begin
      if I < 0 then Len := 20
      else if I < _1e01 then Len := 1
      else begin
        if I < _1e05 then begin
          if I < _1e03 then begin
            if I < _1e02 then Len := 02
            else Len := 03
          end
          else begin
            if I < _1e04 then Len := 04
            else Len := 05
          end
        end
        else begin
          if I < _1e07 then begin
            if I < _1e06 then Len := 06
            else Len := 07
          end
          else begin
            if I > _1e08 then Len := 08
            else Len := 09;
          end
        end
      end;
    end;
  end;
  Result := Len;
end;

function getl01a(const I: Int64): integer;
var
  Len: integer;
begin
  if I < _1e19 then Len := 19
  else begin
    if I > _1e09 then begin
      if I > _1e14 then begin
        if I > _1e16 then begin
          if I > _1e18 then Len := 19
          else if I > _1e17 then Len := 18
          else Len := 17
        end
        else begin
          if I > _1e15 then Len := 16
          else len := 15
        end
      end
      else begin
        if I > _1e11 then begin
          if I > _1e13 then Len := 14
          else begin
            if I > _1e12 then Len := 13
            else Len := 14
          end
        end
        else begin
          if I > _1e10 then Len := 11
          else Len := 10
        end
      end
    end
    else begin
      if I < 0 then Len := 20
      else if I < _1e01 then Len := 1
      else begin
        if I < _1e05 then begin
          if I < _1e03 then begin
            if I < _1e02 then Len := 02
            else Len := 03
          end
          else begin
            if I < _1e04 then Len := 04
            else Len := 05
          end
        end
        else begin
          if I < _1e07 then begin
            if I < _1e06 then Len := 06
            else Len := 07
          end
          else begin
            if I > _1e08 then Len := 08
            else Len := 09;
          end
        end
      end;
    end;
  end;
  Result := Len;
end;

function geta000(const I: Int64): integer;
const
  //int64 //_1e19 =  -8446744073709551616
  _1e19 = $8AC7230489E80000; _1e19h = $8AC72304; _1e19L = $89E80000;
  _1e18 = $0DE0B6B3A7640000; _1e18h = $0DE0B6B3; _1e18L = $A7640000;
  _1e17 = $016345785D8A0000; _1e17h = $01634578; _1e17L = $5D8A0000;
  _1e16 = $002386F26FC10000; _1e16h = $002386F2; _1e16L = $6FC10000;
  _1e15 = $00038D7EA4C68000; _1e15h = $00038D7E; _1e15L = $A4C68000;
  _1e14 = $00005AF3107A4000; _1e14h = $00005AF3; _1e14L = $107A4000;
  _1e13 = $000009184E72A000; _1e13h = $00000918; _1e13L = $4E72A000;
  _1e12 = $000000E8D4A51000; _1e12h = $000000E8; _1e12L = $D4A51000;
  _1e11 = $000000174876E800; _1e11h = $00000017; _1e11L = $4876E800;
  _1e10 = $00000002540BE400; _1e10h = $00000002; _1e10L = $540BE400;

  //integer
  _1e09 = $3B9ACA00; _1e08 = $05F5E100; _1e07 = $00989680;
  _1e06 = $000F4240; _1e05 = $000186A0;

  //word/byte
  _1e04 = $2710; _1e03 = $03E8; _1e02 = $64; _1e01 = $A; _1e00 = 0;
asm
  mov eax, dword[I]; mov edx, dword[I+4]
  test edx, edx; jz @int32

  @t20: cmp edx, _1e19h; jb @t19; cmp eax, _1e19L; jae @n20
  @t19: cmp edx, _1e18h; jb @t18; cmp eax, _1e18L; jae @n19
  @t18: cmp edx, _1e17h; jb @t17; cmp eax, _1e17L; jae @n18
  @t17: cmp edx, _1e16h; jb @t16; cmp eax, _1e16L; jae @n17
  @t16: cmp edx, _1e15h; jb @t15; cmp eax, _1e15L; jae @n16
  @t15: cmp edx, _1e14h; jb @t14; cmp eax, _1e14L; jae @n15
  @t14: cmp edx, _1e13h; jb @t13; cmp eax, _1e13L; jae @n14
  @t13: cmp edx, _1e12h; jb @t12; cmp eax, _1e12L; jae @n13
  @t12: cmp edx, _1e11h; jb @t11; cmp eax, _1e11L; jae @n12
  @t11: cmp edx, _1e10h; jb @t1X; cmp eax, _1e10L; jae @n11
  @t1X: jmp @n10 //edx would not be zero, already tested above
  @int32: test eax, eax; jz @zero
  @t10:{cmp edx, _1e09h; jb @t09;}cmp eax, _1e09; jae @n10
  @t09:{cmp edx, _1e08h; jb @t08;}cmp eax, _1e08; jae @n09
  @t08:{cmp edx, _1e07h; jb @t07;}cmp eax, _1e07; jae @n08
  @t07:{cmp edx, _1e06h; jb @t06;}cmp eax, _1e06; jae @n07
  @t06:{cmp edx, _1e05h; jb @t05;}cmp eax, _1e05; jae @n06
  @t05:{cmp edx, _1e04h; jb @t04;}cmp eax, _1e04; jae @n05
  @t04:{cmp edx, _1e03h; jb @t03;}cmp eax, _1e03; jae @n04
  @t03:{cmp edx, _1e02h; jb @t02;}cmp eax, _1e02; jae @n03
  @t02:{cmp edx, _1e01h; jb @t01;}cmp eax, _1e01; jae @n02
  //@t01:{cmp edx, _1e00h; jb @t00;}cmp eax, _1e00; jae @n01
  //@t00:{cmp edx, _1e00h; jb @t00;}cmp eax, _1e00; jae @n00

  @n20:
  @n19:
  @n18:
  @n17:
  @n16:
  @n15:
  @n14:
  @n13:
  @n12:
  @n11:
  @n10:
  @n09:
  @n08:
  @n07:
  @n06:
  @n05:
  @n04:
  @n03:
  @n02:
  @n01:
  @n00:

  @zero: inc ecx

end;

function geta001(const I: Int64): integer;
const
  //int64 //_1e19 =  -8446744073709551616
  _1e19 = $8AC7230489E80000; _1e19h = $8AC72304; _1e19L = $89E80000;
  _1e18 = $0DE0B6B3A7640000; _1e18h = $0DE0B6B3; _1e18L = $A7640000;
  _1e17 = $016345785D8A0000; _1e17h = $01634578; _1e17L = $5D8A0000;
  _1e16 = $002386F26FC10000; _1e16h = $002386F2; _1e16L = $6FC10000;
  _1e15 = $00038D7EA4C68000; _1e15h = $00038D7E; _1e15L = $A4C68000;
  _1e14 = $00005AF3107A4000; _1e14h = $00005AF3; _1e14L = $107A4000;
  _1e13 = $000009184E72A000; _1e13h = $00000918; _1e13L = $4E72A000;
  _1e12 = $000000E8D4A51000; _1e12h = $000000E8; _1e12L = $D4A51000;
  _1e11 = $000000174876E800; _1e11h = $00000017; _1e11L = $4876E800;
  _1e10 = $00000002540BE400; _1e10h = $00000002; _1e10L = $540BE400;

  //integer
  _1e09 = $3B9ACA00; _1e08 = $05F5E100; _1e07 = $00989680;
  _1e06 = $000F4240; _1e05 = $000186A0;

  //word/byte
  _1e04 = $2710; _1e03 = $03E8; _1e02 = $64; _1e01 = $A; _1e00 = 0;
asm
  mov eax, dword[I]; mov edx, dword[I+4]
  test edx, edx; jz @int32

  @t20: cmp edx, _1e19h; jb @t19; cmp eax, _1e19L; jae @n20
  @t19: cmp edx, _1e18h; jb @t18; cmp eax, _1e18L; jae @n19
  @t18: cmp edx, _1e17h; jb @t17; cmp eax, _1e17L; jae @n18
  @t17: cmp edx, _1e16h; jb @t16; cmp eax, _1e16L; jae @n17
  @t16: cmp edx, _1e15h; jb @t15; cmp eax, _1e15L; jae @n16
  @t15: cmp edx, _1e14h; jb @t14; cmp eax, _1e14L; jae @n15
  @t14: cmp edx, _1e13h; jb @t13; cmp eax, _1e13L; jae @n14
  @t13: cmp edx, _1e12h; jb @t12; cmp eax, _1e12L; jae @n13
  @t12: cmp edx, _1e11h; jb @t11; cmp eax, _1e11L; jae @n12
  @t11: cmp edx, _1e10h; jb @t1X; cmp eax, _1e10L; jae @n11
  @t1X: jmp @n10 //edx would not be zero, already tested above
  @int32: test eax, eax; jz @zero
  @t10:{cmp edx, _1e09h; jb @t09;}cmp eax, _1e09; jae @n10
  @t09:{cmp edx, _1e08h; jb @t08;}cmp eax, _1e08; jae @n09
  @t08:{cmp edx, _1e07h; jb @t07;}cmp eax, _1e07; jae @n08
  @t07:{cmp edx, _1e06h; jb @t06;}cmp eax, _1e06; jae @n07
  @t06:{cmp edx, _1e05h; jb @t05;}cmp eax, _1e05; jae @n06
  @t05:{cmp edx, _1e04h; jb @t04;}cmp eax, _1e04; jae @n05
  @t04:{cmp edx, _1e03h; jb @t03;}cmp eax, _1e03; jae @n04
  @t03:{cmp edx, _1e02h; jb @t02;}cmp eax, _1e02; jae @n03
  @t02:{cmp edx, _1e01h; jb @t01;}cmp eax, _1e01; jae @n02
  //@t01:{cmp edx, _1e00h; jb @t00;}cmp eax, _1e00; jae @n01
  //@t00:{cmp edx, _1e00h; jb @t00;}cmp eax, _1e00; jae @n00

  @n20:
  @n19:
  @n18:
  @n17:
  @n16:
  @n15:
  @n14:
  @n13:
  @n12:
  @n11:
  @n10:
  @n09:
  @n08:
  @n07:
  @n06:
  @n05:
  @n04:
  @n03:
  @n02:
  @n01:
  @n00:

  @zero: inc ecx

end;

function geta002(const I: Int64): integer;
const
  //int64 //_1e19 =  -8446744073709551616
  _1e19 = $8AC7230489E80000; _1e19h = $8AC72304; _1e19L = $89E80000;
  _1e18 = $0DE0B6B3A7640000; _1e18h = $0DE0B6B3; _1e18L = $A7640000;
  _1e17 = $016345785D8A0000; _1e17h = $01634578; _1e17L = $5D8A0000;
  _1e16 = $002386F26FC10000; _1e16h = $002386F2; _1e16L = $6FC10000;
  _1e15 = $00038D7EA4C68000; _1e15h = $00038D7E; _1e15L = $A4C68000;
  _1e14 = $00005AF3107A4000; _1e14h = $00005AF3; _1e14L = $107A4000;
  _1e13 = $000009184E72A000; _1e13h = $00000918; _1e13L = $4E72A000;
  _1e12 = $000000E8D4A51000; _1e12h = $000000E8; _1e12L = $D4A51000;
  _1e11 = $000000174876E800; _1e11h = $00000017; _1e11L = $4876E800;
  _1e10 = $00000002540BE400; _1e10h = $00000002; _1e10L = $540BE400;

  //integer
  _1e09 = $3B9ACA00; _1e08 = $05F5E100; _1e07 = $00989680;
  _1e06 = $000F4240; _1e05 = $000186A0;

  //word/byte
  _1e04 = $2710; _1e03 = $03E8; _1e02 = $64; _1e01 = $A; _1e00 = 0;
asm
  mov eax, dword[I]; mov edx, dword[I+4]
  xor ecx, ecx; test edx, edx; jz @int32

  mov cl, 21
  @t20: dec ecx; cmp edx, _1e19h; jb @t19; cmp eax, _1e19L; jae @done
  @t19: dec ecx; cmp edx, _1e18h; jb @t18; cmp eax, _1e18L; jae @done
  @t18: dec ecx; cmp edx, _1e17h; jb @t17; cmp eax, _1e17L; jae @done
  @t17: dec ecx; cmp edx, _1e16h; jb @t16; cmp eax, _1e16L; jae @done
  @t16: dec ecx; cmp edx, _1e15h; jb @t15; cmp eax, _1e15L; jae @done
  @t15: dec ecx; cmp edx, _1e14h; jb @t14; cmp eax, _1e14L; jae @done
  @t14: dec ecx; cmp edx, _1e13h; jb @t13; cmp eax, _1e13L; jae @done
  @t13: dec ecx; cmp edx, _1e12h; jb @t12; cmp eax, _1e12L; jae @done
  @t12: dec ecx; cmp edx, _1e11h; jb @t11; cmp eax, _1e11L; jae @done
  @t11: dec ecx; cmp edx, _1e10h; jb @t10; cmp eax, _1e10L; jae @done
  @t10: dec ecx; jmp @done // edx would not be zero

  @int32:
  @t01: inc ecx; cmp eax, _1e01; jb @done
  @t02: inc ecx; cmp eax, _1e02; jb @done
  @t03: inc ecx; cmp eax, _1e03; jb @done
  @t04: inc ecx; cmp eax, _1e04; jb @done
  @t05: inc ecx; cmp eax, _1e05; jb @done
  @t06: inc ecx; cmp eax, _1e06; jb @done
  @t07: inc ecx; cmp eax, _1e07; jb @done
  @t08: inc ecx; cmp eax, _1e08; jb @done
  @t09: inc ecx; jmp @done //cmp eax, _1e09; jb @done

  @zero: inc ecx
  @done:

end;

function geta003(const I: Int64): integer;
var
  S: string;
asm push esi; push edi; push ebx;
  mov eax, dword[I]; mov edx, dword[I+4]
  xor ecx, ecx; test edx, edx; jz @int32;

  mov cl, 21
  @t20: dec ecx; cmp edx, _1e19h; jb @t19; ja @n20; cmp eax, _1e19L; jae @n20
  @t19: dec ecx; cmp edx, _1e18h; jb @t18; ja @n19; cmp eax, _1e18L; jae @n19
  @t18: dec ecx; cmp edx, _1e17h; jb @t17; ja @n18; cmp eax, _1e17L; jae @n18
  @t17: dec ecx; cmp edx, _1e16h; jb @t16; ja @n17; cmp eax, _1e16L; jae @n17
  @t16: dec ecx; cmp edx, _1e15h; jb @t15; ja @n16; cmp eax, _1e15L; jae @n16
  @t15: dec ecx; cmp edx, _1e14h; jb @t14; ja @n15; cmp eax, _1e14L; jae @n15
  @t14: dec ecx; cmp edx, _1e13h; jb @t13; ja @n14; cmp eax, _1e13L; jae @n14
  @t13: dec ecx; cmp edx, _1e12h; jb @t12; ja @n13; cmp eax, _1e12L; jae @n13
  @t12: dec ecx; cmp edx, _1e11h; jb @t11; ja @n12; cmp eax, _1e11L; jae @n12
  @t11: dec ecx; cmp edx, _1e10h; jb @t10; ja @n11; cmp eax, _1e10L; jae @n11
  @t10: dec ecx; jmp @n10 // edx would not be zero

  @int32:
  @t01: inc ecx; cmp eax, _1e01; jb @n01
  @t02: inc ecx; cmp eax, _1e02; jb @n02
  @t03: inc ecx; cmp eax, _1e03; jb @n03
  @t04: inc ecx; cmp eax, _1e04; jb @n04
  @t05: inc ecx; cmp eax, _1e05; jb @n05
  @t06: inc ecx; cmp eax, _1e06; jb @n06
  @t07: inc ecx; cmp eax, _1e07; jb @n07
  @t08: inc ecx; cmp eax, _1e08; jb @n08
  @t09: inc ecx; jmp @n09 //cmp eax, _1e09; jb @done

  @zero: inc ecx
  @done:

  @n20:
  @n19:
  @n18:
  @n17:
  @n16:
  @n15:
  @n14:
  @n13:
  @n12:
  @n11:
  @n10:
  @n09:
  @n08:
  @n07:
  @n06:
  @n05:
  @n04:

  @n03:
   sub eax, 100; adc bl, 0; add eax, 100; //mov edi

  @n02:
  @n01:
  @n00:




  mov eax, ecx
  @@Stop: pop ebx; pop edi; pop esi;
end;

function getl02(const I: Int64): integer;
var
  Len: integer;
begin
  if I < _1e19 then Len := 19
  else begin
    if I > _1e09 then
      if I > _1e14 then
        if I > _1e16 then
          if I > _1e18 then
            Len := 19
          else if I > _1e17 then
            Len := 18
          else Len := 17
        else
          if I > _1e15 then
          Len := 16
        else len := 15
      else
        if I > _1e11 then
        if I > _1e13 then
          Len := 14
        else
          if I > _1e12 then
          Len := 13
        else
          Len := 14
      else
        if I > _1e10 then
        Len := 11
      else
        Len := 10
    else
      if I < 0 then
      Len := 20
    else if cardinal(I) < _1e01 then
      Len := 1
    else
      if cardinal(I) < _1e05 then
      if cardinal(I) < _1e03 then
        if cardinal(I) < _1e02 then
          Len := 02
        else Len := 03
      else
        if cardinal(I) < _1e04 then
        Len := 04
      else Len := 05
    else
      if cardinal(I) < _1e07 then
      if cardinal(I) < _1e06 then
        Len := 06
      else Len := 07
    else
      if cardinal(I) > _1e08 then
      Len := 08
    else Len := 09;
  end;
  Result := Len;
end;

function getl02a(const I: Int64): integer;
var
  Len: integer;
begin
  // look at that code; pretty isn't?
  // sexier than britney spears!
  if I < _1e19 then Len := 19
  else
    if I > _1e09 then
    if I > _1e14 then
      if I > _1e16 then
        if I > _1e18 then
          Len := 19
        else if I > _1e17 then
          Len := 18
        else Len := 17
      else
        if I > _1e15 then
        Len := 16
      else len := 15
    else
      if I > _1e11 then
      if I > _1e13 then
        Len := 14
      else
        if I > _1e12 then
        Len := 13
      else
        Len := 14
    else
      if I > _1e10 then
      Len := 11
    else
      Len := 10
  else begin
    if I < 0 then Len := 20
    else
      if I < _1e01 then
      Len := 1
    else
      if I < _1e05 then
      if I < _1e03 then
        if I < _1e02 then
          Len := 02
        else
          Len := 03
      else
        if I < _1e04 then
        Len := 04
      else
        Len := 05
    else
      if I < _1e07 then
      if I < _1e06 then
        Len := 06
      else
        Len := 07
    else
      if I > _1e08 then
      Len := 08
    else
      Len := 09;
  end;
  Result := Len;
end;

function getl00(const I: Int64): integer;
var
  Len: integer;
begin
  if I < _1e19 then Len := 19
  else if I < 0 then Len := 20
  else if I > _1e18 then Len := 19
  else if I > _1e17 then Len := 18
  else if I > _1e16 then Len := 17
  else if I > _1e15 then Len := 16
  else if I > _1e14 then Len := 15
  else if I > _1e13 then Len := 14
  else if I > _1e12 then Len := 13
  else if I > _1e11 then Len := 12
  else if cardinal(I) > _1e10 then Len := 11
  else if cardinal(I) > _1e09 then Len := 10
  else if cardinal(I) > _1e08 then Len := 09
  else if cardinal(I) > _1e07 then Len := 08
  else if cardinal(I) > _1e06 then Len := 07
  else if cardinal(I) > _1e05 then Len := 06
  else if cardinal(I) > _1e04 then Len := 05
  else if cardinal(I) > _1e03 then Len := 04
  else if cardinal(I) > _1e02 then Len := 03
  else if cardinal(I) > _1e01 then Len := 02
  else Len := 01;
  Result := Len;
end;

function ulStr(const I: Int64; const Digits: byte = 0): string;
const
  //int64
  _1e19 = $8AC7230489E80000; // -8446744073709551616
  _1e18 = $0DE0B6B3A7640000; _1e17 = $016345785D8A0000;
  _1e16 = $002386F26FC10000; _1e15 = $00038D7EA4C68000;
  _1e14 = $00005AF3107A4000; _1e13 = $000009184E72A000;
  _1e12 = $000000E8D4A51000; _1e11 = $000000174876E800;
  _1e10 = $00000002540BE400;

  //integer
  _1e09 = $3B9ACA00; _1e08 = $05F5E100; _1e07 = $00989680;
  _1e06 = $000F4240; _1e05 = $000186A0;

  //word/byte
  _1e04 = $2710; _1e03 = $03E8; _1e02 = $64; _1e01 = $A;

var
  r, lC, lS: integer;
  C: string;
  S: string[20];
  k, t, Len: integer;
  U: Int64;

begin
  k := 0; t := 0; U := I;
  if I < _1e19 then Len := 19
  else if I < 0 then Len := 20
  else if I > _1e18 then Len := 19
  else if I > _1e17 then Len := 18
  else if I > _1e16 then Len := 17
  else if I > _1e15 then Len := 16
  else if I > _1e14 then Len := 15
  else if I > _1e13 then Len := 14
  else if I > _1e12 then Len := 13
  else if I > _1e11 then Len := 12
  else if I > _1e10 then Len := 11
  else if I > _1e09 then Len := 10
  else if I > _1e08 then Len := 09
  else if I > _1e07 then Len := 08
  else if I > _1e06 then Len := 07
  else if I > _1e05 then Len := 06
  else if I > _1e04 then Len := 05
  else if I > _1e03 then Len := 04
  else if I > _1e02 then Len := 03
  else if I > _1e01 then Len := 02
  else if I > 00000 then Len := 01;

  if I <= _1e19 then begin
    dec(U, _1e19);
    inc(k); S[k] := '1';
  end;
  if I > _1e18 then begin
    inc(k); dec(U, _1e18);
    if U < _1e17 then S[k] := '0'
    else if U < 2 * _1e17 then S[k] := '1'
    else if U < 3 * _1e17 then S[k] := '2'
    else if U < 4 * _1e17 then S[k] := '3'
    else if U < 5 * _1e17 then S[k] := '4'
    else if U < 6 * _1e17 then S[k] := '5'
    else if U < 7 * _1e17 then S[k] := '6'
    else if U < 8 * _1e17 then S[k] := '7'
    else if U < 9 * _1e17 then S[k] := '8'
    else S[k] := '9'
  end;

end;

{$I int64hilo.inc}

function uintos(const I: Int64): string;
asm push esi; push edi; push ebx;
  mov eax, dword[I]; mov edx, dword[I+4]
  xor ecx, ecx; test edx, edx; jz @int32;



  @t14: cmp edx, E14_1hi; ja @t17; jb @t12
  @t14_5: cmp eax, E14_5Lo; ja @t14_8; jb @t14_3; mov cl, 5; jmp @done
  @t14_9: mov cl, 9; jmp @done
  @t14_8: cmp eax, E14_8Lo; ja @t14_9; jb @t14_7; mov cl, 8; jmp @done
  @t14_7: cmp eax, E14_7Lo; ja @t14_9; jb @t14_6; mov cl, 8; jmp @done
  @t14_6:
  //@n14_5:
  @t14_4:
  @t14_3:
  @t14_2:
  @t14_1:
  @t17:
  @t12:


  @int32:


  {
  mov cl, 21
  @t20: dec ecx; cmp edx, _1e19h; jb @t19; ja @n20; cmp eax, _1e19L; jae @n20
  @t19: dec ecx; cmp edx, _1e18h; jb @t18; ja @n19; cmp eax, _1e18L; jae @n19
  @t18: dec ecx; cmp edx, _1e17h; jb @t17; ja @n18; cmp eax, _1e17L; jae @n18
  @t17: dec ecx; cmp edx, _1e16h; jb @t16; ja @n17; cmp eax, _1e16L; jae @n17
  @t16: dec ecx; cmp edx, _1e15h; jb @t15; ja @n16; cmp eax, _1e15L; jae @n16
  @t15: dec ecx; cmp edx, _1e14h; jb @t14; ja @n15; cmp eax, _1e14L; jae @n15
  @t14: dec ecx; cmp edx, _1e13h; jb @t13; ja @n14; cmp eax, _1e13L; jae @n14
  @t13: dec ecx; cmp edx, _1e12h; jb @t12; ja @n13; cmp eax, _1e12L; jae @n13
  @t12: dec ecx; cmp edx, _1e11h; jb @t11; ja @n12; cmp eax, _1e11L; jae @n12
  @t11: dec ecx; cmp edx, _1e10h; jb @t10; ja @n11; cmp eax, _1e10L; jae @n11
  @t10: dec ecx; jmp @n10 // edx would not be zero

  @int32:
  @t01: inc ecx; cmp eax, _1e01; jb @n01
  @t02: inc ecx; cmp eax, _1e02; jb @n02
  @t03: inc ecx; cmp eax, _1e03; jb @n03
  @t04: inc ecx; cmp eax, _1e04; jb @n04
  @t05: inc ecx; cmp eax, _1e05; jb @n05
  @t06: inc ecx; cmp eax, _1e06; jb @n06
  @t07: inc ecx; cmp eax, _1e07; jb @n07
  @t08: inc ecx; cmp eax, _1e08; jb @n08
  @t09: inc ecx; jmp @n09 //cmp eax, _1e09; jb @done

  @zero: inc ecx
  @done:

  @n20:
  @n19:
  @n18:
  @n17:
  @n16:
  @n15:
  @n14:
  @n13:
  @n12:
  @n11:
  @n10:
  @n09:
  @n08:
  @n07:
  @n06:
  @n05:
  @n04:

  @n03:
   sub eax, 100; adc bl, 0; add eax, 100; //mov edi

  @n02:
  @n01:
  @n00:



  }
  @done:
  mov eax, ecx
  @@Stop: pop ebx; pop edi; pop esi;
end;

end.


PAGE 255,240

%BIN 0
.386
;---------------------------------------------
; this is the *real* FAST md4/md5 hash
; assembler: turbo assembler tasm/tasm32
; version: 1.0.0.2
;
; important! using register calling convention
;
; copyright 2005, aa, Adrian Hafizh & Inge DR.
; Property of PT SOFTINDO Jakarta.
; All rights reserved.
;
; mail,to:@[zero_inge]AT@-y.a,h.o.o.@DOTcom,
; mail,to:@[aa]AT@-s.o.f.t,i.n.d.o.@DOTnet
; http://delphi.softindo.net
;---------------------------------------------
; USAGE
; 1. call __mdxinit
;      argument is pointer to 16 bytes MD4/MD5 digest, passed via EAX
; 2. call __mdx5fetch/__mdx4fetch for every integral chunks of 64 bytes
;    do not call it if the length of the chunk is less than 64 bytes
;      arguments are:
;        pointer to 16 bytes MD4/MD5 digest, passed via EAX
;        pointer to 64 bytes data chunk, passed via EDX
;    call after here also any tracking/gauge/progress function you wish
;    do not worry, all registers are preserved here
; 3. call __mdx5finalize/__mdx4finalize for the last chunk whose length
;    less than 64 bytes (including 0 length chunk, if total size is perfectly
;    64 bytes fold or the total length itself was 0)
;      arguments are:
;        pointer to 16 bytes MD4/MD5 digest, passed via EAX
;        pointer to 0-63 bytes data chunk tail (last), passed via EDX
;        Original/Total Data Size/Length in bytes (up to 72057594037927935 bytes)
;          passed via stack as a pair of DWORDs, intel's BigEndian scheme, which
;          is simply an int64 type in Delphi
; 4. done. result in 16 bytes MD4/MD5 digest
;
;--------------------------------------------------------
; 2006.1.1 fixed bug: bad passing parameters by dirty trick in md[4/5/x]finalize,
;                     now using clean and obvious way

;; MAGIC NUMBERS1

A00 = 067452301h
B00 = 0efcdab89h
C00 = 098badcfeh
D00 = 010325476h

;; MAGIC NUMBERS2
;; 4294967296 times abs(sin(i)), where i is in radians
;; grouped according to associated macro's block

;; MD5:  A = B + ((A + FUNC(b, c, d) + X + t) <<< s)
;; MD4:  A = A + FUNC(b, c, d) + X + t) <<< s

ENTRANCE macro @@A, @@B, @@X, @@t ;; modified: @@A, saved: @@B, @@A + @@X + @@t
  ifnb <@@t>
    add   @@A, @@t
  endif
  add   @@A, @@X
  mov   tmp, @@A
  push  @@B
endm

DEPART macro @@A, @@B, @@s ;; modified: @@A, restored: @@B
  mov   @@B, tmp
  add   @@A, @@B
  rol   @@A, @@s
  pop   @@B
  add   @@A, @@B
endm

F5 macro  @@A, @@B, @@C, @@D, @@X, @@s, @@t ;; Result in: @@A, Modified: @@B
; A = B + ((A + FUNC(b, c, d) + X + t) <<< s)
  ENTRANCE @@A, @@B, <@@X>, @@t
    ; FUNC1(b, c, d) = (b and c) or ((not b) and d)
    mov   @@A, @@B
    and   @@A, @@C
    not   @@B
    and   @@B, @@D
    or    @@A, @@B
  DEPART  @@A, @@B, @@s
endm

G5 macro  @@A, @@B, @@C, @@D, @@X, @@s, @@t
; A = B + ((A + FUNC(b, c, d) + X + t) <<< s)
  ENTRANCE @@A, @@B, <@@X>, @@t
    ; FUNC2(b, c, d) = (b and d) or (c and (not d))
    and   @@B, @@D
    mov   @@A, @@B
    mov   @@B, @@D
    not   @@B
    and   @@B, @@C
    or    @@A, @@B
  DEPART  @@A, @@B, @@s
endm

H5 macro  @@A, @@B, @@C, @@D, @@X, @@s, @@t
; A = B + ((A + FUNC(b, c, d) + X + t) <<< s)
  ;;ENTRANCE @@A, @@B, <@@X>, @@t
  ;;  ; FUNC3(b, c, d) = b xor c xor d
  ;;  mov   @@A, @@B
  ;;  xor   @@A, @@C
  ;;  xor   @@A, @@D
  ;;DEPART  @@A, @@B, @@s

  HX @@A, @@B, @@C, @@D, @@X, @@s, @@t
  add @@A, @@B
endm

I5 macro  @@A, @@B, @@C, @@D, @@X, @@s, @@t
; A = B + ((A + FUNC(b, c, d) + X + t) <<< s)
  ENTRANCE @@A, @@B, <@@X>, @@t
    ; FUNC4(b, c, d) = c xor (b or (not d))
    mov   @@A, @@D
    not   @@A
    or    @@A, @@B
    xor   @@A, @@C
  DEPART  @@A, @@B, @@s
endm


;MD4
ENTRANCE4 macro @@A, @@B, @@X, @@t ;; modified: @@A, saved: @@B, @@A + @@X + @@t
  ifnb <@@t>
    ENTRANCE @@A, @@B, <@@X>, @@t
  else
    ENTRANCE @@A, @@B, <@@X>
  endif
  mov   @@A, @@B
endm

DEPART4 macro @@A, @@B, @@s ;; modified: @@A, restored: @@B
  mov   @@B, tmp
  add   @@A, @@B
  rol   @@A, @@s
  pop   @@B
  ;add   @@A, @@B
endm

F4 macro  @@A, @@B, @@C, @@D, @@X, @@s ;; Result in: @@A, Modified: @@B
; A = (A + func(B, C, D) + X[i]) <<< s
  ENTRANCE4 @@A, @@B, <@@X>
    ; FUNC1(b, c, d) = (b and c) or ((not b) and d)
    and   @@A, @@C
    not   @@B
    and   @@B, @@D
    or    @@A, @@B
  DEPART4 @@A, @@B, @@s
endm

G4 macro  @@A, @@B, @@C, @@D, @@X, @@s, @@t
; A = (A + func(B, C, D) + X[i] + 5A827999h) <<< s
  ENTRANCE4 @@A, @@B, <@@X>, @@t
    ; FUNC2(b, c, d) = (b and c) or (b and d) or (c and d))
    and   @@B, @@C
    and   @@A, @@D
    or    @@A, @@B
    ;
    mov   @@B, @@C
    and   @@B, @@D
    or    @@A, @@B
  DEPART4 @@A, @@B, @@s
endm

H4 macro  @@A, @@B, @@C, @@D, @@X, @@s, @@t
; A = (A + func(B, C, D) + X[i] + 6ED9EBA1) <<< s
  ;;ENTRANCE4 @@A, @@B, <@@X>, @@t
  ;;  ; FUNC3(b, c, d) = b xor c xor d
  ;;  xor   @@A, @@C
  ;;  xor   @@A, @@D
  ;;DEPART4 @@A, @@B, @@s

  HX @@A, @@B, @@C, @@D, @@X, @@s, @@t
endm

HX macro  @@A, @@B, @@C, @@D, @@X, @@s, @@t
  push @@B
  xor @@B, @@C
  xor @@B, @@D
  add @@B, @@t
  add @@B, @@A
  mov @@A, @@X
  add @@A, @@B
  rol @@A, @@s
  pop @@B
endm

.model FLAT
.code

PUBLIC __mdxInit
  TDigest struc
    dtA dd ?
    dtB dd ?
    dtC dd ?
    dtD dd ?
  TDigest ends

__mdxInit proc near ;; (var PDigest:eax)
  ; Param1:PDigest:DWORD
  ; arg PDigest:dword = ArgSize // not used, using register instead
%BIN 24
  XDigest equ <[eax].TDigest>
    mov XDigest.dtA, A00
    mov XDigest.dtB, B00
    mov XDigest.dtC, C00
    mov XDigest.dtD, D00
    ret; //ArgSize
%BIN 0
__mdxInit endp

A equ eax
B equ ebx
C equ ecx
D equ edx
E equ dword ptr [edi]

align 4
PUBLIC __MDX5fetch ; ALL registers are preserved
__MDX5fetch proc near ;; (var PDigest:eax; const PBuffer64:edx)
  ; ==================================================================
  ; Param1:PDigest:DWORD, Param2:PBuffer64:DWORD
  ; arg PDigest: dword, PBuffer64:dword = ArgSize // not used, using register instead
  ; DO NOT call under pascal calling convention! use explicit register directive if had to
  ; (the caller must not push anything into the stack, pass the args via registers instead)
  ; ==================================================================
%BIN 24
  local tmp:dword, Algo:dword = LocalSize
  push ebp              ; since we're using local storage
  mov ebp, esp          ; stack-pointer must be adjusted here
  add esp, -LocalSize   ;

  pushad

  mov esi, eax
  mov edi, edx

  mov A, [esi.TDigest.dtA]
  mov B, [esi.TDigest.dtB]
  mov C, [esi.TDigest.dtC]
  mov D, [esi.TDigest.dtD]

  S0 = 07h
  S1 = 0Ch
  S2 = 11h
  S3 = 16h

  F5 A, B, C, D, <E[4*00]>, S0, 0d76aa478h ; Step 1
  F5 D, A, B, C, <E[4*01]>, S1, 0e8c7b756h ; Step 2
  F5 C, D, A, B, <E[4*02]>, S2, 0242070dbh ; Step 3
  F5 B, C, D, A, <E[4*03]>, S3, 0c1bdceeeh ; Step 4
  F5 A, B, C, D, <E[4*04]>, S0, 0f57c0fafh ; Step 5
  F5 D, A, B, C, <E[4*05]>, S1, 04787c62ah ; Step 6
  F5 C, D, A, B, <E[4*06]>, S2, 0a8304613h ; Step 7
  F5 B, C, D, A, <E[4*07]>, S3, 0fd469501h ; Step 8
  F5 A, B, C, D, <E[4*08]>, S0, 0698098d8h ; Step 9
  F5 D, A, B, C, <E[4*09]>, S1, 08b44f7afh ; Step 10
  F5 C, D, A, B, <E[4*10]>, S2, 0ffff5bb1h ; Step 11
  F5 B, C, D, A, <E[4*11]>, S3, 0895cd7beh ; Step 12
  F5 A, B, C, D, <E[4*12]>, S0, 06b901122h ; Step 13
  F5 D, A, B, C, <E[4*13]>, S1, 0fd987193h ; Step 14
  F5 C, D, A, B, <E[4*14]>, S2, 0a679438eh ; Step 15
  F5 B, C, D, A, <E[4*15]>, S3, 049b40821h ; Step 16

  S0 = 05h
  S1 = 09h
  S2 = 0Eh
  S3 = 14h
  G5 A, B, C, D, <E[4*01]>, S0, 0f61e2562h ; Step 17
  G5 D, A, B, C, <E[4*06]>, S1, 0c040b340h ; Step 18
  G5 C, D, A, B, <E[4*11]>, S2, 0265e5a51h ; Step 19
  G5 B, C, D, A, <E[4*00]>, S3, 0e9b6c7aah ; Step 20
  G5 A, B, C, D, <E[4*05]>, S0, 0d62f105dh ; Step 21
  G5 D, A, B, C, <E[4*10]>, S1, 002441453h ; Step 22
  G5 C, D, A, B, <E[4*15]>, S2, 0d8a1e681h ; Step 23
  G5 B, C, D, A, <E[4*04]>, S3, 0e7d3fbc8h ; Step 24
  G5 A, B, C, D, <E[4*09]>, S0, 021e1cde6h ; Step 25
  G5 D, A, B, C, <E[4*14]>, S1, 0c33707d6h ; Step 26
  G5 C, D, A, B, <E[4*03]>, S2, 0f4d50d87h ; Step 27
  G5 B, C, D, A, <E[4*08]>, S3, 0455a14edh ; Step 28
  G5 A, B, C, D, <E[4*13]>, S0, 0a9e3e905h ; Step 29
  G5 D, A, B, C, <E[4*02]>, S1, 0fcefa3f8h ; Step 30
  G5 C, D, A, B, <E[4*07]>, S2, 0676f02d9h ; Step 31
  G5 B, C, D, A, <E[4*12]>, S3, 08d2a4c8ah ; Step 32

  S0 = 04h
  S1 = 0Bh
  S2 = 10h
  S3 = 17h
  H5 A, B, C, D, <E[4*05]>, S0, 0fffa3942h ; Step 33
  H5 D, A, B, C, <E[4*08]>, S1, 08771f681h ; Step 34
  H5 C, D, A, B, <E[4*11]>, S2, 06d9d6122h ; Step 35
  H5 B, C, D, A, <E[4*14]>, S3, 0fde5380ch ; Step 36
  H5 A, B, C, D, <E[4*01]>, S0, 0a4beea44h ; Step 37
  H5 D, A, B, C, <E[4*04]>, S1, 04bdecfa9h ; Step 38
  H5 C, D, A, B, <E[4*07]>, S2, 0f6bb4b60h ; Step 39
  H5 B, C, D, A, <E[4*10]>, S3, 0bebfbc70h ; Step 30
  H5 A, B, C, D, <E[4*13]>, S0, 0289b7ec6h ; Step 41
  H5 D, A, B, C, <E[4*00]>, S1, 0eaa127fah ; Step 42
  H5 C, D, A, B, <E[4*03]>, S2, 0d4ef3085h ; Step 43
  H5 B, C, D, A, <E[4*06]>, S3, 004881d05h ; Step 44
  H5 A, B, C, D, <E[4*09]>, S0, 0d9d4d039h ; Step 45
  H5 D, A, B, C, <E[4*12]>, S1, 0e6db99e5h ; Step 46
  H5 C, D, A, B, <E[4*15]>, S2, 01fa27cf8h ; Step 47
  H5 B, C, D, A, <E[4*02]>, S3, 0c4ac5665h ; Step 48

  S0 = 06h
  S1 = 0Ah
  S2 = 0Fh
  S3 = 15h
  I5 A, B, C, D, <E[4*00]>, S0, 0f4292244h ; Step 49
  I5 D, A, B, C, <E[4*07]>, S1, 0432aff97h ; Step 50
  I5 C, D, A, B, <E[4*14]>, S2, 0ab9423a7h ; Step 51
  I5 B, C, D, A, <E[4*05]>, S3, 0fc93a039h ; Step 52
  I5 A, B, C, D, <E[4*12]>, S0, 0655b59c3h ; Step 53
  I5 D, A, B, C, <E[4*03]>, S1, 08f0ccc92h ; Step 54
  I5 C, D, A, B, <E[4*10]>, S2, 0ffeff47dh ; Step 55
  I5 B, C, D, A, <E[4*01]>, S3, 085845dd1h ; Step 56
  I5 A, B, C, D, <E[4*08]>, S0, 06fa87e4fh ; Step 57
  I5 D, A, B, C, <E[4*15]>, S1, 0fe2ce6e0h ; Step 58
  I5 C, D, A, B, <E[4*06]>, S2, 0a3014314h ; Step 59
  I5 B, C, D, A, <E[4*13]>, S3, 04e0811a1h ; Step 50
  I5 A, B, C, D, <E[4*04]>, S0, 0f7537e82h ; Step 61
  I5 D, A, B, C, <E[4*11]>, S1, 0bd3af235h ; Step 62
  I5 C, D, A, B, <E[4*02]>, S2, 02ad7d2bbh ; Step 63
  I5 B, C, D, A, <E[4*09]>, S3, 0eb86d391h ; Step 64

;@@DoneTransform:
  add [esi.TDigest.dtA], A
  add [esi.TDigest.dtB], B
  add [esi.TDigest.dtC], C
  add [esi.TDigest.dtD], D

  popad

  mov esp, ebp
  pop ebp
  ret; //ArgSize
%BIN 0
__MDX5fetch endp

align 4
PUBLIC __MDX4fetch ; ALL registers are preserved
__MDX4fetch proc near ;; (var PDigest:eax; const PBuffer64:edx)
  ; ==================================================================
  ; Param1:PDigest:DWORD, Param2:PBuffer64:DWORD
  ; arg PDigest: dword, PBuffer64:dword = ArgSize // not used, using register instead
  ; DO NOT call under pascal calling convention! use explicit register directive if had to
  ; (the caller must not push anything into the stack, pass the args via registers instead)
  ; ==================================================================
%BIN 24
  local tmp:dword, Algo:dword = LocalSize
  push ebp              ; since we're using local storage
  mov ebp, esp          ; stack-pointer must be adjusted
  add esp, -LocalSize   ;

  pushad

  mov esi, eax
  mov edi, edx

  mov A, [esi.TDigest.dtA]
  mov B, [esi.TDigest.dtB]
  mov C, [esi.TDigest.dtC]
  mov D, [esi.TDigest.dtD]

  S0 = 03h
  S1 = 07h
  S2 = 0Bh
  S3 = 13h

  F4x = 0
  rept 4
    F4 A, B, C, D, <E[4*(F4x+0)]>, S0
    F4 D, A, B, C, <E[4*(F4x+1)]>, S1
    F4 C, D, A, B, <E[4*(F4x+2)]>, S2
    F4 B, C, D, A, <E[4*(F4x+3)]>, S3
    F4x = (F4x + 4)
  endm

  S0 = 03h
  S1 = 05h
  S2 = 09h
  S3 = 0Dh
  G4t = 5A827999h
  G4 A, B, C, D, <E[4*00]>, S0, G4t
  G4 D, A, B, C, <E[4*04]>, S1, G4t
  G4 C, D, A, B, <E[4*08]>, S2, G4t
  G4 B, C, D, A, <E[4*12]>, S3, G4t
  G4 A, B, C, D, <E[4*01]>, S0, G4t
  G4 D, A, B, C, <E[4*05]>, S1, G4t
  G4 C, D, A, B, <E[4*09]>, S2, G4t
  G4 B, C, D, A, <E[4*13]>, S3, G4t
  G4 A, B, C, D, <E[4*02]>, S0, G4t
  G4 D, A, B, C, <E[4*06]>, S1, G4t
  G4 C, D, A, B, <E[4*10]>, S2, G4t
  G4 B, C, D, A, <E[4*14]>, S3, G4t
  G4 A, B, C, D, <E[4*03]>, S0, G4t
  G4 D, A, B, C, <E[4*07]>, S1, G4t
  G4 C, D, A, B, <E[4*11]>, S2, G4t
  G4 B, C, D, A, <E[4*15]>, S3, G4t

  S0 = 03h
  S1 = 09h
  S2 = 0Bh
  S3 = 0Fh
  H4t = 6ED9EBA1h
  H4 A, B, C, D, <E[4*00]>, S0, H4t
  H4 D, A, B, C, <E[4*08]>, S1, H4t
  H4 C, D, A, B, <E[4*04]>, S2, H4t
  H4 B, C, D, A, <E[4*12]>, S3, H4t
  H4 A, B, C, D, <E[4*02]>, S0, H4t
  H4 D, A, B, C, <E[4*10]>, S1, H4t
  H4 C, D, A, B, <E[4*06]>, S2, H4t
  H4 B, C, D, A, <E[4*14]>, S3, H4t
  H4 A, B, C, D, <E[4*01]>, S0, H4t
  H4 D, A, B, C, <E[4*09]>, S1, H4t
  H4 C, D, A, B, <E[4*05]>, S2, H4t
  H4 B, C, D, A, <E[4*13]>, S3, H4t
  H4 A, B, C, D, <E[4*03]>, S0, H4t
  H4 D, A, B, C, <E[4*11]>, S1, H4t
  H4 C, D, A, B, <E[4*07]>, S2, H4t
  H4 B, C, D, A, <E[4*15]>, S3, H4t

;@@DoneTransform:
  add [esi.TDigest.dtA], A
  add [esi.TDigest.dtB], B
  add [esi.TDigest.dtC], C
  add [esi.TDigest.dtD], D

  popad

  mov esp, ebp
  pop ebp
  ret; //ArgSize
%BIN 0
__MDX4fetch endp

align 4
PUBLIC __mdx5Finalize
;__mdx5Finalize proc near ;; (var PDigest, PBuffer64: pointer; Length: int64)
  ; ==================================================================
  ; Param1:eax:DWORD, Param2:edx:DWORD, Param3:[esp-4]:[esp-8] (High:Low)
  ; only ActualLength pushed into stack; note: [esp] contains return eip!
  ; (push ONLY Length into the stack, pass the first 2 arguments via register)
  ; DO NOT call under pascal calling convention!
  ; use explicit 'register' compiler directive if it had to
  ; ==================================================================
%BIN 24
  ;arg LengthLo:DWORD, LengthHi:DWORD = ArgSize
  ;push LengthHi
  ;push LengthLo
  ;push 5  ;; means MD5
  ;call __mdxFinalize
  ;ret ArgSize
%BIN 0
;__mdx5Finalize endp

PUBLIC __mdx4Finalize
;__mdx4Finalize proc near ;; (var PDigest, PBuffer64: pointer; Length: int64)
  ; ==================================================================
  ; comments equ ABOVE
  ; ==================================================================
%BIN 24
  ;arg LengthLo:DWORD, LengthHi:DWORD = ArgSize
  ;push LengthHi
  ;push LengthLo
  ;push 4  ;; means MD4
  ;call __mdxFinalize
  ;ret ArgSize
;__mdx4Finalize endp
%BIN 0

PUBLIC __mdxFinalize
  TRUE = 1
  FALSE = 0
  MDxCSize = size TMDxChunk
  MDxCMask = MDxCSize - 1
%BIN 24
  TMDxChunk struc
    DataPadding    db 56 dup (?)
    DataLength_Lo  dd ?
    DataLength_Hi  dd ?
  TMDxChunk ends
%BIN 0

__mdxFinalize proc near ; (var PDigest, PBuffer64: pointer; Algo: integer; Length: int64)
  ; ActualLengthHi, ActualLengthLo and Algorithm respectively, had been
  ; pushed into stack in that order, the stack contents then:
  ;                                - ebp
  ;   [ESP] = EIP (return address) - ebp +4
  ;   [ESP+04] = LLo               - ebp +c
  ;   [ESP+08] = LHi               - ebp +10
  ; (bottom = 00000000)
%BIN 24
  ;arg Algo:dword, LengthHi:DWORD, LengthLo:DWORD = ArgSize
  arg LengthLo:DWORD, LengthHi:DWORD = ArgSize
  local Extend:byte, Algo:byte, Buf:TMDxChunk:2 = LocalSize
  jmp short @@mdxFinalizeStart

__mdx4Finalize label near
  mov cl,4
  jmp short @@mdxFinalizeStart

__mdx5Finalize label near
  mov cl,5
  ;jmp short @@mdxFinalizeStart

@@mdxFinalizeStart:
  push ebp             ; since we're using local storage
  mov ebp, esp         ; stack-pointer must be adjusted here
  sub esp, LocalSize   ; add esp, -LocalSize

  cmp cl,4             ; anything not equal 4 means MD5
  setne Algo
  add Algo,4

  push esi
  push edi
  mov esi, eax
  mov edi, edx

  mov eax, LengthLo
  mov edx, LengthHi
  mov ecx, eax
  shld eax, edx, 3

  mov dword ptr Buf.DataLength_Hi, edx            ; Buf[00+56+4]
  mov dword ptr Buf[+MDxCSize].DataLength_Hi, edx ; Buf[64+56+4]

  mov dword ptr Buf.DataLength_Lo, eax            ; Buf[00+56]
  mov dword ptr Buf[+MDxCSize].DataLength_Lo, eax ; Buf[64+56]

  mov eax, ecx
  and eax, MDxCMask ;; 64 bytes/512bits block, size of TBuffer64
  push eax
  mov byte ptr Buf[eax], 80h
  dec eax
  jl short @@movedone

@@L_MoveData:
  mov dl, edi[eax]
  mov byte ptr Buf[eax], dl
  dec eax
  jge short @@L_MoveData

@@movedone:
  pop eax
  xor edx, edx
  mov Extend, dl
  push edi
  lea edi, Buf.DataLength_Lo
  sub eax, 56 ;; congruent 448 bits check
  jl short @@goon

@@extend:
  mov Extend, TRUE

  lea edi, edi[+MDxCSize]
  sub eax, MDxCSize

@@goon:
  inc eax
  jz short @@done

@@fillblank:
  inc eax
  mov edi[eax-1], dl
  jl short @@fillblank

@@done:
  pop edi

  mov eax, esi
  lea edx, Buf
  cmp Algo, 4
  je short @@md4

  call __MDX5fetch
  test Extend, 1
  jz short @@end
  add edx, 64
  call __MDX5fetch
  jmp short @@end

@@md4:
  call __MDX4fetch

  test Extend, 1
  jz short @@end
  add edx, 64
  call __MDX4fetch
  jmp short @@end

@@end:
  pop edi
  pop esi

  mov esp, ebp
  pop ebp
  ret ArgSize
%BIN 0
__mdxFinalize endp

END

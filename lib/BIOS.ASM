CRLF equ <0dh,0ah>
.286
segment code
assume cs:code, ds:code
org 100h
@@Start: jmp short @Begin
CPR	db CRLF, 'ROM-BIOS dumper',CRLF
	db 'Copyright (c) 2004, Adrian Hafizh.',CRLF
	db 'aa@softindo.net',CRLF,CRLF
	db 'Usage:	BIOS > filename$'
@Begin:
  mov ax,4400h
  mov bx,00001
  int 21h
  jb  @init
  and dl,82h
  cmp dl,82h
  jne @init
 
  push cs
  push ds
  mov dx,102h
  mov ah,9 
  int 21h
  mov ax,4C01h
  int 21h
 
@init:
  xor ax,ax
  xor bx,bx
  xor dx,dx
  mov cx,100h
  inc bx

@Loop:
  pusha
  mov ds,ax
  mov cx,1000h
  mov ax,4000h
  int 21h
  popa
  jb  @exit
  add ax,100h
  loop @Loop
  xor ax,ax    
 
 @exit:
  mov         ah,4Ch
  int         21h
@End:
code ends
end @@Start

bits 16
org 0

_start:
	cli
	jmp 0x7C0:stage1

stage1:
	mov ax, cs
	mov ds, ax
	xor ax, ax
	mov ss, ax
	mov sp, 0x7C00
	sti
	push dx

	mov bx, loadmsg
	call pstr

	pop dx
	mov ah, 0x42
	mov si, dap
	int 0x13
	jc .err

	mov bx, stage2msg
	call pstr
	jmp 0x1000:0

.err: 
	mov bx, errmsg
	call pstr

	jmp $

; str in bx
pstr:
	mov al, [bx]
	cmp al, 0
	je pstr_end
	inc bx
	mov ah, 0x0E
	push bx
	int 0x10
	pop bx
	jmp pstr
pstr_end:
	ret

loadmsg:
	db "Stage 1 booted", 13, 10, 0
errmsg:
	db "Error loading stage 2", 13, 10, 0
stage2msg:
	db "Loading stage 2...", 13, 10, 0

dap:
	db 0x10
	db 0
	dw 127 ; sectors to read
	dw 0x0 ; destination offset
	dw 0x1000 ; destination segment
	dq 1 ; starting lba

times 446 - ($ - $$) db 0
db 0x80, 0x00, 0x01, 0x00, 0x83, 0xFE, 0xFF, 0xFF
dd 1
dd 2048
times 48 db 0
dw 0xAA55

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

	mov ah, 0x42
	mov si, dap
	int 0x13
	jc .err
	jmp 0x1000:0

	int 0x10

.err: 
	mov ah, 0x0E
	mov al, 'E'
	int 0x10
	mov ah, 0x0E
	mov al, 'R'
	int 0x10
	mov ah, 0x0E
	mov al, 'R'
	int 0x10
.hlt: jmp .hlt

dap:
	db 0x10
	db 0
	dw 1
	dw 0x0
	dw 0x1000
	dq 1

times 446 - ($ - $$) db 0
db 0x80, 0x00, 0x01, 0x00, 0x83, 0xFE, 0xFF, 0xFF
dd 1
dd 2097152
times 48 db 0
dw 0xAA55

section .stage2 vstart=0

stage2:
	mov ax, 0x1000
	mov ds, ax

	mov bx, msg
	call pstr
.hlt: jmp .hlt

; bx = string
pstr:
	mov al, [bx]
	inc bx
	cmp al, 0
	jz .pstr_end
	push bx
	mov ah, 0x0E
	int 0x10
	pop bx
	jmp pstr
.pstr_end:
	ret

msg: db "Stage 2 booted successfully.", 13, 10, "Hello world", 13, 10, 0

times 512 - ($ - $$) db 0

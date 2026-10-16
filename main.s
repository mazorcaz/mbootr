bits 16
org 0

_start:
	cli
	jmp 0x7C0:cp

cp:
	mov ax, 0x60
	mov ds, ax
	xor bx, bx
	cploop:
	mov ax, [cs:bx]
	mov [ds:bx], ax
	add bx, 2
	cmp bx, 512
	jl cploop
	jmp 0x60:main

drive: dw 0

main:
	mov ax, cs
	mov ds, ax
	xor ax, ax
	mov ss, ax
	mov sp, 0x7C00
	mov [drive], dl
	sti

	mov bx, loadmsg
	call pstr

	xor bx, bx
rpart:
	mov al, [part + bx]
	cmp al, 0x80
	jne rpart_end
	mov ax, bx
	shr ax, 4
	add ax, '1'
	mov [foundmsg_i], al
	push bx
	mov bx, foundmsg
	call pstr
	pop bx
	mov ax, [part + bx + 8]
	mov [dap + 8], ax
	mov ax, [part + bx + 10]
	mov [dap + 10], ax
	mov dl, [drive]
	mov ah, 0x42
	mov si, dap
	int 0x13
	jc rpart_err
	mov bx, bootmsg
	call pstr
	jmp 0x7C0:0
	rpart_err:
	mov bx, readfailmsg
	call pstr
	jmp $
	rpart_end:
	add bx, 16
	cmp bx, 64
	jl rpart

	mov bx, nobootmsg
	call pstr
	jmp $

dap:
	db 0x10
	db 0
	dw 1 ; sectors to read
	dw 0x0 ; destination offset
	dw 0x7C0 ; destination segment
	dq 1 ; starting lba


loadmsg: db "mbootr 1.1", 13, 10, 0
foundmsg: db "Found bootable partition: #", 
foundmsg_i: db 0, 13, 10, 0
bootmsg: db "Booting to partition...", 13, 10, 0
nobootmsg: db "No bootable partitions", 13, 10, 0
readfailmsg: db "Failed to load partition", 13, 10, 0

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

times 446 - ($ - $$) db 0

part:
db 0x80, 0x00, 0x01, 0x00, 0x83, 0xFE, 0xFF, 0xFF
dd 1
dd 1
times 48 db 0
dw 0xAA55

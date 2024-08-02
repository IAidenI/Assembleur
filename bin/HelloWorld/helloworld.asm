section .data
	message		db 	"Hello world!", 0xA
	messageLen 	equ 	$-message

section .text
	global _start

_start:
	mov 	edx, 	messageLen
	mov 	ecx, 	message
	mov 	ebx, 	1
	mov 	eax, 	4
	int 	0x80

	mov 	eax, 	1
	xor 	ebx, 	ebx
	int 	0x80

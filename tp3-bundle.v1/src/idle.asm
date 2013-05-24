; ==============================================================================
; TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
; ==============================================================================

ORG 0x3A0000

BITS 32

%include "imprimir.mac"

idle:
	next:
	inc DWORD [numero]
	mov ebx, [numero]
	cmp ebx, 0x4
	jl .ok
		mov DWORD [numero], 0x0
		mov ebx, 0
	.ok:
		add ebx, message1
		mov edx, message
		imprimir_texto_mp edx, 5, 0x0f, 24, 0
		imprimir_texto_mp ebx, 1, 0x0f, 24, 5
	jmp	next

message: db 'Idle:'
numero: dd 0x00000000
message1: db '|'
message2: db '/'
message3: db '-'
message4: db '\'

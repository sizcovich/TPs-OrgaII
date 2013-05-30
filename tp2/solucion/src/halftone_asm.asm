; void halftone_asm (
; 	unsigned char *src,
; 	unsigned char *dst,
; 	int m,
; 	int n,
; 	int src_row_size,
; 	int dst_row_size
; );

; Parámetros:
; 	rdi = src
; 	rsi = dst
; 	rdx = h
; 	rcx = w
; 	r8 = src_row_size
; 	r9 = dst_row_size

extern halftone_c

global halftone_asm

section .text

halftone_asm:
	push RBP
	mov RBP, RSP
	push R12
	push R13
	
;	mov r12, rdx ;me guardo el alto
;	mov r13, rcx ;me guardo el ancho
	;veo si tiene ancho y largo pares
;	mov rax, r12
;.paridad:
;	cmp rax, 0
	jl .resto
;	div rdi, 2

.resto:
	sub r12, 1
	
;*******************************

	call halftone_c

;*******************************	
	pop R13
	pop R12
	pop RBP
	ret

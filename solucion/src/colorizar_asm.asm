BITS 64
; void colorizar_asm (
; 	unsigned char *src,
; 	unsigned char *dst,
; 	int h,
; 	int w,
; 	int src_row_size,
; 	int dst_row_size,
;   float alpha
; );

; Parámetros:
; 	rdi = src
; 	rsi = dst
; 	rdx = h
; 	rcx = w
; 	r8 = src_row_size
; 	r9 = dst_row_size
;   xmm0 = alpha


global colorizar_asm


section .text

colorizar_asm:
	;; TODO: Implementar

	;Setup
	push RBP
	mov RSP, RBP
	push R15

	xor R15, R15 ;Preparo R15 para usarlo de indice

	;Copio la primera fila



	ret


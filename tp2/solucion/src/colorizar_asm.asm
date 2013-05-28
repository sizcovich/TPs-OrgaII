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
extern colorizar_c

global colorizar_asm


section .text

colorizar_asm:
	;; TODO: Implementar

	;Setup
	;.setup:
	;push RBP
	;mov RSP, RBP
	;push R15

	;imul ECX, ECX, 3	;Ahora el ancho esta en bytes y no en pixels
	;El row_size ya viene en bytes
	;imul R8d, R8d, 3	;Ahora el row_size esta en bytes, no en pixels
	;imul R9d, R9d, 3	;Ahora el row_size esta en bytes, no en pixels

	;xor R15, R15 ;Preparo R15 para usarlo de indice

	;pshufd XMM0, XMM0, 0	;Copia en las cuatro

	;Copio la primera fila
	;.firstRow:
		;movdqu XMM1, [RDI+R15]	;Levanto los bytes
		;movdqu [RSI+R15], XMM1	;Como solo los quiero copiar los pongo
		;add R15, 16
		;cmp R15, RCX	;Me fijo si llegue al ancho de la imagen
		;jl .firstRow
		
		;add RDI, R8	;Avanzo una fila el puntero de la imagen fuente
		;add RSI, R9	;Avanzo una fila el puntero de la imagen destino

	movdqu xmm0, [rdi]
	movdqu [rsi], xmm0
	;pop RBP
	ret


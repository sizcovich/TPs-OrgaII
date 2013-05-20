BITS 64
; void waves_c (
;	unsigned char *src,
;	unsigned char *dst,
;	int m,
;	int n,
;	int row_size,
;	float x_scale,
;	float y_scale,
;	float g_scale
; );

; Parámetros:
; 	rdi = src
; 	rsi = dst
; 	rdx = m
; 	rcx = n
; 	r8 = row_size
; 	xmm0 = x_scale
; 	xmm1 = y_scale
; 	xmm2 = g_scale

extern waves_c

global waves_asm

section .rodata:
;Me defino los Pi empaquetados 
ppi: dd 3.14159265359, 3.14159265359, 3.14159265359, 3.14159265359

;Indices
col_index: dd 0.0, 1.0, 2.0, 3.0	;Las columnas
;REFERENCIA DE FORMATO => row_index: dd 0, 0, 0, 0	;Las filas

;Incrementos
col_inc: dd 4.0, 4.0, 4.0, 4.0
row_inc: dd 1.0, 1.0, 1.0, 1.0

;Valor para dividir en el sin_taylor
div_taylor: dd 8.0, 8.0, 8.0, 8.0

section .text

waves_asm:
	.setup:
		;Replico los _scale en sus registros correspondientes
		shufps xmm0, xmm0, 0
		shufps xmm1, xmm1, 0
		
		pxor xmm10, xmm10	;Para desempaquetar
		
		;Cargo los Pi para realizar las cuentas de sin_taylor
		movups xmm15, [ppi]
		
		;xmm13 va a tener mi indice de columnas
		;xmm14 va a tener mi indice de filas
		movups xmm13, [col_index]
		pxor xmm14, xmm14	;Lo quiero en 0
		
		.sin_taylor_j:
		movups xmm12, xmm14
		divps xmm11, [div_taylor]	;Divido el indice de columna por 8.0
		

	.procesarFila:
		movdqu xmm4, [rdi]	;16 pixels de la fila que estoy procesando
		movdqu xmm5, xmm4
		punpckhbw xmm5, xmm10	;Desempaqueto la parte alta
		punpcklbw xmm4, xmm10	;Desempaqueto la parte baja
		;Obtengo el original en formato word en xmm5:xmm4
		movdqu xmm3, xmm4
		movdqu xmm6, xmm5
		punpckhwd xmm6, xmm10
		punpcklwd xmm5, xmm10
		punpckhwd xmm4, xmm10
		punpcklwd xmm3, xmm10
		;Obtengo el original en formato doubleword xmm6:xmm5:xmm4:xmm3

		.sin_taylor_i:
			movups xmm11, xmm13
			divps xmm11, [div_taylor]	;Divido los indices por 8.0
			
		
	ret

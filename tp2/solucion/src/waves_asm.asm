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

section .data:
;Me defino los Pi empaquetados 
ppi: dd 3.14159265359, 3.14159265359, 3.14159265359, 3.14159265359

doses: dd 2.0, 2.0, 2.0, 2.0

;Indices
col_index: dd 0.0, 1.0, 2.0, 3.0	;Las columnas
;REFERENCIA DE FORMATO => row_index: dd 0, 0, 0, 0	;Las filas

;Incrementos
col_inc: dd 4.0, 4.0, 4.0, 4.0
row_inc: dd 1.0, 1.0, 1.0, 1.0

;Valor para dividir en el sin_taylor
div_taylor: dd 8.0, 8.0, 8.0, 8.0
div_pol7: dd 5040.0, 5040.0, 5040.0, 5040.0
div_pol5: dd 120.0, 120.0, 120.0, 120.0
div_pol3: dd 6.0, 6.0, 6.0, 6.0

section .text

waves_asm:
	.setup:
		;Replico los _scale en sus registros correspondientes
		shufps xmm0, xmm0, 0
		shufps xmm1, xmm1, 0
		shufps xmm2, xmm2, 0
		
		pxor xmm10, xmm10	;Para desempaquetar
		
		;Cargo los Pi para realizar las cuentas de sin_taylor
		movups xmm15, [ppi]
		
		;xmm13 va a tener mi indice de columnas
		;xmm14 va a tener mi indice de filas
		movups xmm13, [col_index]
		pxor xmm14, xmm14	;Lo quiero en 0
		
		.sin_taylor_j:
			;movups xmm3, [div_taylor]
			;movups xmm4, [div_pol7]
			;movups xmm5, [div_pol5]
			;movups xmm6, [div_pol3]
			movups xmm7, [doses]

			movups xmm12, xmm14
			divps xmm12, [div_taylor]	;xmm3	;Divido el indice de columna por 8.0
			
			;k <- floor(x/(2*pi))
			movups xmm11, xmm12
			divps xmm11, xmm7
			divps xmm11, xmm15
			roundps xmm11, xmm11, 11B

			;x <- x - k*2*pi
			mulps xmm11, xmm7
			mulps xmm11, xmm15
			subps xmm12, xmm11
			
			subps xmm12, xmm15	;x <- x - pi

			;x <- x - (x^3/6) + (x^5/120) - (x^7/5040)
			movups xmm10, xmm12	;x^7
			mulps xmm10, xmm10	;x*x
			mulps xmm10, xmm12	;x*x*x
			mulps xmm10, xmm10	;x*x*x*x*x*x
			mulps xmm10, xmm12	;x^7
			divps xmm10, [div_pol7]	;xmm4

			movups xmm11, xmm12	;x^5
			mulps xmm11, xmm11	;x*x
			mulps xmm11, xmm11	;x*x*x*x
			mulps xmm11, xmm12	;x^5
			divps xmm11, [div_pol5]	;xmm5
			subps xmm11, xmm10	;(x^5/120) - (x^7/5040)
		
			movups xmm10, xmm12	;x^3
			mulps xmm10, xmm10	;x*x
			mulps xmm10, xmm12	;x^3
			divps xmm10, [div_pol3]	;xmm6
			subps xmm12, xmm10	;x - (x^3/6)

			addps xmm12, xmm11 ;x - (x^3/6) + (x^5/120) - (x^7/5040)

	.procesarFila:
		;movups xmm3, [div_taylor]
		;movups xmm4, [div_pol7]
		;movups xmm5, [div_pol5]
		;movups xmm6, [div_pol3]
		movups xmm7, [doses]

		call sin_taylor_i
		movdqu xmm11, xmm3	;pixels[0:3]
		addps xmm13, [col_inc]

		call sin_taylor_i
		movdqu xmm10, xmm3	;pixels[4:7]
		addps xmm13, [col_inc]

		call sin_taylor_i
		movdqu xmm9, xmm3	;pixels[8:11]
		addps xmm13, [col_inc]

		call sin_taylor_i
		movdqu xmm8, xmm3	;pixels[12:15]
		addps xmm13, [col_inc]

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
		
	ret


sin_taylor_i:
	movups xmm3, xmm13
	divps xmm3, [div_taylor]	;Divido los indices por 8.0
	
	;k <- floor(x/(2*pi))
	movups xmm4, xmm3
	divps xmm4, xmm7
	divps xmm4, xmm15
	roundps xmm4, xmm4, 11B

	;x <- x - k*2*pi
	mulps xmm4, xmm7
	mulps xmm4, xmm15
	subps xmm3, xmm4
	
	subps xmm3, xmm15	;x <- x - pi

	;x <- x - (x^3/6) + (x^5/120) - (x^7/5040)
	movups xmm5, xmm3	;x^7
	mulps xmm5, xmm5	;x*x
	mulps xmm5, xmm3	;x*x*x
	mulps xmm5, xmm5	;x*x*x*x*x*x
	mulps xmm5, xmm3	;x^7
	divps xmm5, [div_pol7]	;xmm4

	movups xmm4, xmm3	;x^5
	mulps xmm4, xmm4	;x*x
	mulps xmm4, xmm4	;x*x*x*x
	mulps xmm4, xmm3	;x^5
	divps xmm4, [div_pol5]	;xmm5
	subps xmm4, xmm5	;(x^5/120) - (x^7/5040)

	movups xmm5, xmm3	;x^3
	mulps xmm5, xmm5	;x*x
	mulps xmm5, xmm3	;x^3
	divps xmm5, [div_pol3]	;xmm6
	subps xmm3, xmm5	;x - (x^3/6)

	addps xmm3, xmm4 ;x - (x^3/6) + (x^5/120) - (x^7/5040)

	ret


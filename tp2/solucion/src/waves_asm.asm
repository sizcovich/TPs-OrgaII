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

doses: dd 2.0	;Esto lo voy a poner en registro normal para acceso rapido

;Indices
col_index: dd 0.0, 1.0, 2.0, 3.0	;Las columnas
;REFERENCIA DE FORMATO => row_index: dd 0, 0, 0, 0	;Las filas

;Incrementos
col_inc: dd 4.0, 4.0, 4.0, 4.0
row_inc: dd 1.0, 1.0, 1.0, 1.0

;Valores para operar en el sin_taylor
div_taylor: dd 8.0
div_pol7: dd 5040.0
div_pol5: dd 120.0
div_pol3: dd 6.0

section .text

waves_asm:
	.setup:
		push rbp
		mov rbp, rsp
		push r15
		push r14
		push r13
		push r12
		push rbx

		;Calculo la cantidad total de bytes y preparo un contador para recorrer
		;todos los elementos
		imul rdx, r8	;Cuantos bytes tiene la imagen con row_size
		;Como no quiero perder el row_size lo guardo donde las filas
		xor rcx, rcx	;Como las columnas reales no me importan lo hago contador
		xor rax, rax	;Lo hago el contador de columna

		;Preservo los scales para usarlos cuando son necesarios
		movq r9, xmm0
		movq r10, xmm1
		movq r11, xmm2

		;Cargo los valores que voy a estar usando mucho en registros de
		;proposito general para acceso rapido
		mov r15, [doses]
		mov r14, [div_taylor]
		mov r13, [div_pol7]
		mov r12, [div_pol5]
		mov rbx, [div_pol3]
		
		;Cargo los Pi para realizar las cuentas de sin_taylor
		movups xmm15, [ppi]
		
		;xmm13 va a tener mi indice de columnas
		;xmm14 va a tener mi indice de filas
		movups xmm13, [col_index]
		pxor xmm14, xmm14	;Lo quiero en 0
		
		.sin_taylor_j:
			movups xmm12, xmm14	;En xmm12 voy a guardar el resultado de
										;sin_taylor para la fila completa
			movd xmm7, r14d	;8.0
			shufps xmm7, xmm7, 0
			divps xmm12, xmm7	;xmm3	;Divido el indice de fila por 8.0
			
			;k <- floor(x/(2*pi))
			movd xmm7, r15d	;2.0
			shufps xmm7, xmm7, 0
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
			movd xmm7, r13d	;5040.0
			shufps xmm7, xmm7, 0
			movups xmm10, xmm12	;x^7
			mulps xmm10, xmm10	;x*x
			mulps xmm10, xmm12	;x*x*x
			mulps xmm10, xmm10	;x*x*x*x*x*x
			mulps xmm10, xmm12	;x^7
			divps xmm10, xmm7

			movd xmm7, r12d	;120.0
			shufps xmm7, xmm7, 0
			movups xmm11, xmm12	;x^5
			mulps xmm11, xmm11	;x*x
			mulps xmm11, xmm11	;x*x*x*x
			mulps xmm11, xmm12	;x^5
			divps xmm11, xmm7
			subps xmm11, xmm10	;(x^5/120) - (x^7/5040)
		
			movd xmm7, ebx	;6.0
			shufps xmm7, xmm7, 0
			movups xmm10, xmm12	;x^3
			mulps xmm10, xmm10	;x*x
			mulps xmm10, xmm12	;x^3
			divps xmm10, xmm7
			subps xmm12, xmm10	;x - (x^3/6)

			addps xmm12, xmm11 ;x - (x^3/6) + (x^5/120) - (x^7/5040)
			
			movq xmm7, r10
			shufps xmm7, xmm7, 0
			mulps xmm12, xmm7	;Multiplico por el y_scale

	.procesarFila:
		movups xmm8, [col_inc]
		call sin_taylor_i
		movdqu xmm0, xmm11	;pixels[0:3]
		addps xmm13, xmm8
		;calculo prof para los pixels[0:3]
		addps xmm0, xmm12
		movd xmm7, r15d	;2.0
		shufps xmm7, xmm7, 0
		divps xmm0, xmm7

		call sin_taylor_i
		movdqu xmm1, xmm11	;pixels[4:7]
		addps xmm13, xmm8
		;calculo prof para los pixels[4:7]
		addps xmm1, xmm12
		movd xmm7, r15d	;2.0
		shufps xmm7, xmm7, 0
		divps xmm1, xmm7

		call sin_taylor_i
		movdqu xmm2, xmm11	;pixels[8:11]
		addps xmm13, xmm8
		;calculo prof para los pixels[8:11]
		addps xmm2, xmm12
		movd xmm7, r15d	;2.0
		shufps xmm7, xmm7, 0
		divps xmm2, xmm7

		call sin_taylor_i
		movdqu xmm3, xmm11	;pixels[12:15]
		addps xmm13, xmm8
		;calculo prof para los pixels[12:15]
		addps xmm3, xmm12
		movd xmm7, r15d	;2.0
		shufps xmm7, xmm7, 0
		divps xmm3, xmm7

		;Cargo en xmm10 el g_scale
		movq xmm10, r11
		shufps xmm10, xmm10, 0
		;Multiplico prof por g_scale
		mulps xmm3, xmm10
		mulps xmm2, xmm10
		mulps xmm1, xmm10
		mulps xmm0, xmm10
		
		pxor xmm10, xmm10	;Para desempaquetar
		movdqu xmm5, [rdi+rcx]	;16 pixels de la fila que estoy procesando
		movdqu xmm6, xmm4
		punpckhbw xmm6, xmm10	;Desempaqueto la parte alta
		punpcklbw xmm5, xmm10	;Desempaqueto la parte baja
		;Obtengo el original en formato word en xmm5:xmm4
		movdqu xmm4, xmm5
		movdqu xmm7, xmm6
		punpckhwd xmm7, xmm10
		punpcklwd xmm6, xmm10
		punpckhwd xmm5, xmm10
		punpcklwd xmm4, xmm10
		;Obtengo el original en formato doubleword xmm7:xmm6:xmm5:xmm4

		;Convierto los dword a float
		cvtdq2ps xmm7, xmm7
		cvtdq2ps xmm6, xmm6
		cvtdq2ps xmm5, xmm5
		cvtdq2ps xmm4, xmm4
		;Multiplico prof por el pixel
		addps xmm7, xmm3
		addps xmm6, xmm2
		addps xmm5, xmm1
		addps xmm4, xmm0

		cvttps2dq xmm7, xmm7
		cvttps2dq xmm6, xmm6
		cvttps2dq xmm5, xmm5
		cvttps2dq xmm4, xmm4

		packssdw xmm6, xmm7
		packssdw xmm4, xmm5

		packuswb xmm4, xmm6	;Volvi a empaquetar a bytes

		movdqu [rsi+rcx], xmm4	;Escribo en destino
		lea rcx, [rcx+16]	;Avanzo los 16 bytes
		lea rax, [rax+16]

		cmp rcx, rdx	;Me fijo si llegue al final de la imagen
		jge .return
		cmp rax, r8	;Me fijo si estoy al final de la linea
		jl .procesarFila
		;Si termine la fila voy a resetear los contadores y avanzar una fila
		xor rax, rax
		;movdqu 
		;addps ;TODO this counting shit yo
		
	.return:
	pop rbx
	pop r12
	pop r13
	pop r14
	pop r15
	pop rbp
	ret


sin_taylor_i:
	movups xmm11, xmm13	;En xmm11 voy a guardar el resultado de
								;sin_taylor para 4 columnas
	movd xmm7, r14d	;8.0
	shufps xmm7, xmm7, 0
	divps xmm11, xmm7	;xmm3	;Divido el indice de columna por 8.0
	
	;k <- floor(x/(2*pi))
	movd xmm7, r15d	;2.0
	shufps xmm7, xmm7, 0
	movups xmm10, xmm11
	divps xmm10, xmm7
	divps xmm10, xmm15
	roundps xmm10, xmm10, 11B

	;x <- x - k*2*pi
	mulps xmm10, xmm7
	mulps xmm10, xmm15
	subps xmm11, xmm10
	
	subps xmm11, xmm15	;x <- x - pi

	;x <- x - (x^3/6) + (x^5/120) - (x^7/5040)
	movd xmm7, r13d	;5040.0
	shufps xmm7, xmm7, 0
	movups xmm9, xmm11	;x^7
	mulps xmm9, xmm9	;x*x
	mulps xmm9, xmm11	;x*x*x
	mulps xmm9, xmm9	;x*x*x*x*x*x
	mulps xmm9, xmm11	;x^7
	divps xmm9, xmm7

	movd xmm7, r12d	;120.0
	shufps xmm7, xmm7, 0
	movups xmm10, xmm11	;x^5
	mulps xmm10, xmm10	;x*x
	mulps xmm10, xmm10	;x*x*x*x
	mulps xmm10, xmm11	;x^5
	divps xmm10, xmm7
	subps xmm10, xmm9	;(x^5/120) - (x^7/5040)

	movd xmm7, ebx	;6.0
	shufps xmm7, xmm7, 0
	movups xmm9, xmm11	;x^3
	mulps xmm9, xmm9	;x*x
	mulps xmm9, xmm11	;x^3
	divps xmm9, xmm7
	subps xmm11, xmm9	;x - (x^3/6)

	addps xmm11, xmm10 ;x - (x^3/6) + (x^5/120) - (x^7/5040)
	
	movq xmm7, r9
	shufps xmm7, xmm7, 0
	mulps xmm11, xmm7	;Multiplico por el x_scale

	ret


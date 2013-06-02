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
	;; TODO: PASAR A WORD, BYTE NO COMPARA UNSIGNED

	;Setup
	.setup:
	push rbp
	mov rbp, rsp
	push r15
	push r14
	push r13
	push r12

	imul ecx, 3	;Ahora el ancho esta en bytes y no en pixels
	;El row_size ya viene en bytes
	;imul r8d, 3	;Ahora el row_size esta en bytes, no en pixels
	;imul r9d, 3	;Ahora el row_size esta en bytes, no en pixels

	mov r15, 1
	movd xmm15, r15d
	pshufd xmm15, xmm15
	cvtdq2ps xmm15, xmm15	;Cargo 1.0, 1.0, 1.0, 1.0 para el phi

	mov r15, 0xFF
	movd xmm13, r15d
	pxor xmm14, xmm14
	pshufb xmm13, xmm14	;Cargo todos 0xFF

	mov r12, 0x0A0704	;Cargar en 0, 1 y 2 los 3 valores del canal que sea
	movd xmm14, r12	;Me cargo la mascara que voy a usar al comparar canales

	xor r15, r15	;Preparo R15 para usarlo de indice
	xor r14, r14	;Indice columna media
	xor r13, r13	;Indice columna baja
	mov r14d, r8d
	mov r13d, r8d
	add r13, r13

	shufps xmm0, xmm0, 0	;Copia en las cuatro
	subps xmm15, xmm0	;1-alpha
	addps xmm0, xmm0	;alpha*2

	;Copio la primera fila
	.firstRow:
		movdqu xmm1, [rdi+r15]	;Levanto los bytes
		movdqu [rsi+r15], xmm1	;Como solo los quiero copiar los pongo
		add r15, 16
		cmp r15, rcx	;Me fijo si llegue al ancho de la imagen
		jl .firstRow
		
	add rdi, r8	;Avanzo una fila el puntero de la imagen fuente
	add rsi, r9	;Avanzo una fila el puntero de la imagen destino
	xor r15, r15

	.procesarFila:
		;Levanto un tramo de 3x5 pixels
		;(0 1 2)(3 4 5)(6 7 8)(9 10 11)(12 13 14)(15
		;(0 1 2)(3 4 5)(6 7 8)(9 10 11)(12 13 14)(15
		;(0 1 2)(3 4 5)(6 7 8)(9 10 11)(12 13 14)(15
		;El ultimo byte es descarte
		movdqu xmm1, [rdi+r15]
		movdqu xmm2, [rdi+r14]
		movdqu xmm3, [rdi+r13]

		;Comparo fila con fila para sacar el máximo de cada canal en la columna
		pmaxub xmm1, xmm2
		pmaxub xmm1, xmm3	;Acumule los maximos en xmm1

		;Desplazo los registros de modo que me quedan las columnas alineadas para
		;calcular los maximos de cada grupo de pixels
		;       (0 1 2)(3  4  5)( 6  7  8)( 9 10 11)(12
		;(0 1 2)(3 4 5)(6  7  8)( 9 10 11)(12 13 14)(15
		;(3 4 5)(6 7 8)(9 10 11)(12 13 14)(15 xx xx)(xx
		movdqu xmm3, xmm1	;La lina de arriba
		movdqu xmm4, xmm1	;La linea de abajo
		psrldq xmm3, 3
		pslldq xmm4, 3

		;Calculo los maximos y obtengo 3 pixels solo de maximos valores
		;(x x x)(3 4 5)(6  7  8)( 9 10 11)(xx xx xx)(xx
		pmaxub xmm1, xmm3
		pmaxub xmm1, xmm4

		;Me fijo cual de los tres canales es el maximo
		;Duplico los pixels maximos y comparo los 3 canales de cada uno
		movdqu xmm3, xmm1	;Canal azul
		movdqu xmm4, xmm1	;Canal rojo

		pshufb xmm4, xmm14	;Junto los rojos en los bytes 0, 1 y 2
		add r12, 0x010101
		movq xmm14, r12		;0...0 | 11 | 08 | 05
		pshufb xmm1, xmm14	;Junto los verdes en los bytes 0, 1 y 2
		add r12, 0x010101
		movq xmm14, r12		;0...0 | 12 | 09 | 06
		pshufb xmm3, xmm14	;Junto los azules en los bytes 0, 1 y 2

		sub r12, 0x0200000100000000
		movq xmm14, r12		;0...0 | 02 | ## | ## | 01 | ## | ## | 00 | ##
		pslldq xmm14, 1		;Para reposicionar los rojos

		movdqu xmm5, xmm3
		pcmpgtb xmm5, xmm1	;Si el azul es mas grande que el verde
		pcmpgtb xmm3, xmm4	;Si el azul es mas grande que el rojo
		pcmpgtb xmm1, xmm4	;Si el verde es mas grande que el rojo

		movdqu xmm4, xmm5		;Voy a usar el 5 con el pandn para tener g >= b
		movdqu xmm6, xmm3		;Lo voy a invertir para tener r >= b
		movdqu xmm7, xmm1		;Lo voy a usar para tener r >= g

		pxor xmm7, xmm13		;Le hago un not
		
		pand xmm4, xmm3	;phi azul
		pandn xmm5, xmm1	;phi verde
		pandn xmm3, xmm7	;phi rojo

		pshufb xmm3, xmm14	;Reacomodo las mascaras del rojo
		pslldq xmm14, 1

		pshufb xmm4, xmm14	;Reacomodo las mascaras del verde
		pslldq xmm14, 1

		pshufb xmm5, xmm14	;Reacomodo las mascaras del azul

		;Junto las 3 mascaras para obtener una que me filtre que canal es el
		;maximo del pixel
		por xmm3, xmm4
		por xmm3, xmm5

		;Desarmo la mascara en 4

		sub r12, 0x020202
		movq xmm14, r12		;0...0 | 10 | 07 | 04

	
	;**************
	;sub rsp, 8
	;call colorizar_c
	;add rsp, 8
	;**************

	pop r12
	pop r13
	pop r14
	pop r15
	pop rbp
	ret


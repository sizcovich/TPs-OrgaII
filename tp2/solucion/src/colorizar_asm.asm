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

section .rodata
mascaraCambios: dq 0xFFFFFFFF00000000, 0x000000FFFFFFFFFF
mascaraCanales: dq 0x0000FF0000000000, 0x00000000FF0000FF

section .text

colorizar_asm:
	.setup:
	push rbp
	mov rbp, rsp
	push r15
	push r14
	push r13
	push r12

	imul ecx, 3	;Ahora el ancho esta en bytes y no en pixels
	;El row_size ya viene en bytes
	sub rdx, 2	;Me voy a detener en altura menos 2

	mov r15, 1
	movd xmm15, r15d
	pshufd xmm15, xmm15, 0
	cvtdq2ps xmm15, xmm15	;Cargo 1.0, 1.0, 1.0, 1.0 para el phi

	movdqu xmm13, [mascaraCambios]
	movdqu xmm12, [mascaraCanales]

	xor r15, r15	;Preparo R15 para usarlo de indice
	xor r14, r14	;Indice columna media
	xor r13, r13	;Indice columna baja

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
		
	.comienzoFila:
		mov r15, 0
		mov r14d, r8d
		mov r13d, r8d
		add r13, r13

		movdqu xmm2, [rdi+r14]
		movdqu [rsi+r14], xmm2
;		add r14, 3
;		add r13, 3

	.procesarFila:
		;Levanto un tramo de 3x5 pixels
		;(0 1 2)(3 4 5)(6 7 8)(9 10 11)(12 13 14)(15
		;(0 1 2)(3 4 5)(6 7 8)(9 10 11)(12 13 14)(15
		;(0 1 2)(3 4 5)(6 7 8)(9 10 11)(12 13 14)(15
		;El ultimo byte es descarte
		movdqu xmm1, [rdi+r15-3]
		movdqu xmm2, [rdi+r14-3]	;Me voy a quedar con la fila del medio
		movdqu xmm3, [rdi+r13-3]

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
		;xmm1 tiene el canal verde
		
		;Descarto el primer byte para que me quede alineado cuando desempaqueto
		pslldq xmm1, 1
		pslldq xmm3, 1
		pslldq xmm4, 1

		movdqu xmm5, xmm3	;Copio el canal para desempaquetar
		movdqu xmm6, xmm1	;Copio el canal para desempaquetar
		movdqu xmm7, xmm4	;Copio el canal para desempaquetar
		
		pxor xmm10, xmm10
		punpckhbw xmm3, xmm10
		punpckhbw xmm1, xmm10
		punpckhbw xmm4, xmm10
		punpcklbw xmm5, xmm10
		punpcklbw xmm6, xmm10
		punpcklbw xmm7, xmm10

		mov r12, 0x00000000FF0000FF	;Mascara hw
		movq xmm14, r12
		punpcklbw xmm14, xmm14	;Me cargo la mascara de words para la parte alta

		pand xmm4, xmm14	;Me quedo solo con el canal rojo

		pslldq xmm14, 2	;Cambio al canal verde
		pand xmm1, xmm14	;Me quedo solo con el canal verde

		pslldq xmm14, 2	;Cambio al canal azul
		pand xmm3, xmm14	;Me quedo con el canal azul

		;Hago las comparaciones para el maximo de los canales en la parte alta
		psrldq xmm1, 2
		psrldq xmm3, 4
		;Ahora los tres canales estan alineados

		movdqu xmm14, xmm3	;Copio el azul
		pcmpgtw xmm3, xmm1	;B > G
		pcmpgtw xmm14, xmm4	;B > R
		pcmpgtw xmm1, xmm4	;G > R
		movdqu xmm4, xmm14	;B > R
		
		mov r12, 0x0000FF0000000000	;Mascara lw
		movq xmm14, r12
		punpcklbw xmm14, xmm14	;Me cargo la mascara de words para la parte baja

		pand xmm7, xmm14	;Me quedo con el canal rojo

		pslldq xmm14, 2	;Cambio al canal verde
		pand xmm6, xmm14	;Me quedo con el canal verde

		pslldq xmm14, 2	;Cambio al canal azul
		pand xmm5, xmm14	;Me quedo con el canal azul

		;Hago las comparaciones para el maximo de los canales en la parte baja
		psrldq xmm6, 2
		psrldq xmm5, 4
		;Ahora los tres canales estan alineados

		movdqu xmm14, xmm5	;Copio el azul
		pcmpgtw xmm5, xmm6	;B > G
		pcmpgtw xmm14, xmm7	;B > R
		pcmpgtw xmm6, xmm7	;G > R
		movdqu xmm7, xmm14	;B > R

		packsswb xmm6, xmm1	;G > R Completo
		packsswb xmm5, xmm3	;B > G Completo
		packsswb xmm7, xmm4	;B > R Completo

		movdqu xmm4, xmm7	;B > R Completo
		mov r12, 0xFFFFFFFF
		movd xmm14, r12d
		pshufd xmm14, xmm14, 0	;Me preparo una mascara para invertir
		pxor xmm4, xmm14

		;Evaluo los casos de phi
		pand xmm7, xmm5	;Si es caso phiB
		pandn xmm5, xmm6	;Si es caso phiG
		pandn xmm6, xmm4	;Si es caso phiR
		pand xmm7, xmm12
		pand xmm6, xmm12
		pand xmm5, xmm12

		;Acomodo para que queden las mascaras de phi como
		;0 0 0 B G R B G R B G R 0 0 0 0
		psrldq xmm6, 1
		;psrldq xmm5, 1	;Este esta donde debe
		pslldq xmm7, 1
		por xmm5, xmm6
		por xmm5, xmm7	;Junto todas las mascaras en xmm3 y me quedan los maximos

		movdqu xmm3, xmm5	;Copio el filtro de phi para desempaquetar
		punpckhbw xmm3, xmm3	;Desempaqueto sign_extended
		punpcklbw xmm5, xmm5	;Desempaqueto sign_extended
		; xmm3 : xmm5

		movdqu xmm4, xmm3 ;Copio el filtro de phi para desempaquetar
		movdqu xmm6, xmm5 ;Copio el filtro de phi para desempaquetar
		punpckhbw xmm3, xmm3	;Desempaqueto sign_extended
		punpcklbw xmm4, xmm4	;Desempaqueto sign_extended
		punpckhbw xmm5, xmm5	;Desempaqueto sign_extended
		punpcklbw xmm6, xmm6	;Desempaqueto sign_extended
		; xmm3 : xmm4 : xmm5 : xmm6

		;Obtengo donde los alpha suman
		pand xmm3, xmm0	;Filtro los phi
		pand xmm4, xmm0	;Filtro los phi
		pand xmm5, xmm0	;Filtro los phi
		pand xmm6, xmm0	;Filtro los phi
		;Sumo los alphas
		addps xmm3, xmm15
		addps xmm4, xmm15
		addps xmm5, xmm15
		addps xmm6, xmm15

		;Desempaqueto los datos originales
		pxor xmm14, xmm14
		movdqu xmm7, xmm2	;Copio los datos originales
		movdqu xmm9, xmm2	;Copio los datos originales
		punpckhbw xmm7, xmm14	;Desempaqueto sign_extended
		punpcklbw xmm9, xmm14	;Desempaqueto sign_extended
		; xmm7 : xmm9

		movdqu xmm8, xmm7 ;Copio los datos originales
		movdqu xmm10, xmm8 ;Copio los datos originales
		punpckhbw xmm7, xmm14	;Desempaqueto
		punpcklbw xmm8, xmm14	;Desempaqueto
		punpckhbw xmm9, xmm14	;Desempaqueto
		punpcklbw xmm10, xmm14	;Desempaqueto
		; xmm7 : xmm8 : xmm9 : xmm10

		cvtdq2ps xmm7, xmm7
		cvtdq2ps xmm8, xmm8
		cvtdq2ps xmm9, xmm9
		cvtdq2ps xmm10, xmm10

		;Multiplico los phi por el canal que corresponde
		mulps xmm3, xmm7
		mulps xmm4, xmm8
		mulps xmm5, xmm9
		mulps xmm6, xmm10

		;Trunco a int
		cvttps2dq xmm3, xmm3
		cvttps2dq xmm4, xmm4
		cvttps2dq xmm5, xmm5
		cvttps2dq xmm6, xmm6
		
		;Empaqueto los datos otra vez para escribir
		packssdw xmm4, xmm3
		packssdw xmm6, xmm5
		packuswb xmm6, xmm4

		movdqu xmm14, xmm13
		pand xmm6, xmm13	;Me quedo con los 3 pixels del medio
		pandn xmm14, xmm2	;Me quedo con los bytes de las puntas
		por xmm6, xmm14

		psrldq xmm6, 3	;Acomodo para escribir
		movdqu [rsi+r14], xmm6

		add r15, 9
		add r14, 9
		add r13, 9
		cmp r15, rcx
		jl .procesarFila

	.nextRow:
		add rdi, r8
		add rsi, r9

		dec rdx
		cmp rdx, 0
		jg .comienzoFila

;***		pshufb xmm4, xmm14	;Junto los rojos en los bytes 0, 1 y 2
;***		add r12, 0x010101
;***		movq xmm14, r12		;0...0 | 11 | 08 | 05
;***		pshufb xmm1, xmm14	;Junto los verdes en los bytes 0, 1 y 2
;***		add r12, 0x010101
;***		movq xmm14, r12		;0...0 | 12 | 09 | 06
;***		pshufb xmm3, xmm14	;Junto los azules en los bytes 0, 1 y 2
;***
;***;		mov r12, 0x0200000100000000
;***;		movq xmm14, r12		;0...0 | 02 | ## | ## | 01 | ## | ## | 00 | ##
;***;		pslldq xmm14, 1		;Para reposicionar los rojos
;***
;***		movdqu xmm5, xmm3
;***		pcmpgtb xmm5, xmm1	;Si el azul es mas grande que el verde
;***		pcmpgtb xmm3, xmm4	;Si el azul es mas grande que el rojo
;***		pcmpgtb xmm1, xmm4	;Si el verde es mas grande que el rojo
;***
;***		movdqu xmm4, xmm5		;Voy a usar el 5 con el pandn para tener g >= b
;***		movdqu xmm6, xmm3		;Lo voy a invertir para tener r >= b
;***		movdqu xmm7, xmm1		;Lo voy a usar para tener r >= g
;***
;***		pxor xmm7, xmm13		;Le hago un not
;***		
;***		pand xmm4, xmm3	;phi azul
;***		pandn xmm5, xmm1	;phi verde
;***		pandn xmm3, xmm7	;phi rojo
;***
;***		pshufb xmm3, xmm14	;Reacomodo las mascaras del rojo
;***		pslldq xmm14, 1
;***
;***		pshufb xmm4, xmm14	;Reacomodo las mascaras del verde
;***		pslldq xmm14, 1
;***
;***		pshufb xmm5, xmm14	;Reacomodo las mascaras del azul
;***
;***		;Junto las 3 mascaras para obtener una que me filtre que canal es el
;***		;maximo del pixel
;***		por xmm3, xmm4
;***		por xmm3, xmm5
;***
;***		;Desarmo la mascara en 4
;***
;***		sub r12, 0x020202
;***		movq xmm14, r12		;0...0 | 10 | 07 | 04

	
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


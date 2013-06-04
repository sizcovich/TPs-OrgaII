; void umbralizar_c (
; 	unsigned char *src,
; 	unsigned char *dst,
; 	int m,
; 	int n,
; 	int row_size,
; 	unsigned char min,
; 	unsigned char max,
; 	unsigned char q
; );

; Parámetros:
; 	rdi = src
; 	rsi = dst
; 	rdx = m = h
; 	rcx = n = w
; 	r8 = row_size
; 	r9 = min
; 	rbp + 16 = max
; 	rbp + 24 = q

extern umbralizar_c

global umbralizar_asm

section .rodata:
;Para invertir las mascaras
notMask: dw 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF
;Para acomodar el filtro por maximo
maxfilter: dw 0xFF00, 0xFF00, 0xFF00, 0xFF00, 0xFF00, 0xFF00, 0xFF00, 0xFF00

section .text

umbralizar_asm:
	push rbp
	mov rbp, rsp
	push r15
	sub rsp, 8
	;-----voy a calcular el tamanio
	;mov rcx, r8
	;imul rcx, rdx ;me guardo el tamanio
	sub rcx, 16
	xor r10, r10
	mov r10b, [rbp+24]
	movq xmm7, r10
	pshufd xmm7, xmm7, 0 ;Q en XMM7
	cvtdq2ps xmm7, xmm7	;me guardo Q en float
	movq xmm0, r9
	pxor xmm2, xmm2
	pshufb xmm0, xmm2 ;me guardo el minimo en xmm0
	pxor xmm1, xmm1
	movdqu xmm1, [rbp+16]
	pshufb xmm1, xmm2 ;me guardo el maximo en xmm1
	pxor xmm15, xmm15
	punpcklbw xmm0, xmm15
	punpcklbw xmm1, xmm15
	xor r15, r15	;Preparo un indice de columna

.ciclo:
	movdqu xmm2, [rdi+r15]
	movdqu xmm6, xmm2
	punpckhbw xmm6, xmm15 ;en xmm6 tengo la parte alta
	punpcklbw xmm2, xmm15 ;en xmm2 tengo la parte baja

	;-----empiezo a comparar
	movdqu xmm3, xmm0 ;me guardo el minimo
	movdqu xmm13, xmm0 ;me guardo el minimo
	pcmpgtw xmm3, xmm2 ;min > pixel, voy a ver cuando es 0 [Parte baja]
	pcmpgtw xmm13, xmm6 ;min > pixel, voy a ver cuando es 0 [Parte alta]
	;-----quiero ver cuando el pixel es menor al minimo
	movdqu xmm4, xmm1 
	movdqu xmm14, xmm1
	pcmpgtw xmm4, xmm2 ;max > pixel [Parte baja]
	pcmpgtw xmm14, xmm6 ;max > pixel [Parte alta]

	;Para que las mascaras me queden bien armadas necesito tambien necesito
	;comparar por igual al maximo
	movdqu xmm10, xmm1
	pcmpeqw xmm10, xmm2
	por xmm4, xmm10

	movdqu xmm10, xmm1
	pcmpeqw xmm10, xmm6
	por xmm14, xmm10
	;-----me guardo la mascara de maximo

	;-----Invierto las mascaras
	movdqu xmm10, [notMask]
	pxor xmm3, xmm10	;FF si min < pixel
	pxor xmm4, xmm10	;FF si max < pixel
	pxor xmm13, xmm10
	pxor xmm14, xmm10
	movdqu xmm10, [maxfilter]
	psubusw xmm4, xmm10	;FF si max < pixel
	psubusw xmm14, xmm10

	movdqu xmm10, xmm6
	movdqu xmm11, xmm2
	punpckhwd xmm10, xmm15	;1 cuarto
	punpcklwd xmm11, xmm15	;4 cuarto
	punpcklwd xmm6, xmm15	;2 cuarto
	punpckhwd xmm2, xmm15	;3 cuarto
	;-----convertimos los int a float
	cvtdq2ps xmm10, xmm10
	cvtdq2ps xmm6, xmm6
	cvtdq2ps xmm2, xmm2
	cvtdq2ps xmm11, xmm11
	;-----Divido por Q
	divps xmm11, xmm7
	divps xmm2, xmm7
	divps xmm6, xmm7
	divps xmm10, xmm7
	;-----multiplico por Q
	roundps xmm10, xmm10, 11B
	roundps xmm6,xmm6, 11B
	roundps xmm2,xmm2, 11B
	roundps xmm11,xmm11, 11B
	;-----multiplico por Q
	mulps xmm6, xmm7
	mulps xmm2, xmm7
	mulps xmm11, xmm7
	mulps xmm10, xmm7
	;----vuelvo a pasar a doubleword
	cvtps2dq xmm6, xmm6
	cvtps2dq xmm10, xmm10
	cvtps2dq xmm11, xmm11
	cvtps2dq xmm2, xmm2
	
	;----empaqueto
	packusdw xmm6, xmm10
	packusdw xmm11, xmm2

	;----filtrado por mascara
	pand xmm6, xmm13 ;filtre por el minimo	[Parte alta]
	pand xmm11, xmm3 ;filtre por el minimo	[Parte baja]
	por xmm6, xmm14 ;filtre por el maximo	[Parte alta]
	por xmm11, xmm4 ;filtre por el maximo	[Parte baja]

	packuswb xmm11, xmm6

	movdqu [rsi+r15], xmm11 ;lo guardo en destino
	add r15, 16
	cmp r15, rcx
	jge .reprocess
	jmp .ciclo

	.reprocess:
		mov r15, rcx
;		mov rax, rcx
;		add rax, 16
;		sub rax, r15
;		sub r15, rax

	.lastCol:
		movdqu xmm2, [rdi+r15]
		movdqu xmm6, xmm2
		punpckhbw xmm6, xmm15 ;en xmm6 tengo la parte alta
		punpcklbw xmm2, xmm15 ;en xmm2 tengo la parte baja

		;-----empiezo a comparar
		movdqu xmm3, xmm0 ;me guardo el minimo
		movdqu xmm13, xmm0 ;me guardo el minimo
		pcmpgtw xmm3, xmm2 ;min > pixel, voy a ver cuando es 0 [Parte baja]
		pcmpgtw xmm13, xmm6 ;min > pixel, voy a ver cuando es 0 [Parte alta]
		;-----quiero ver cuando el pixel es menor al minimo
		movdqu xmm4, xmm1 
		movdqu xmm14, xmm1
		pcmpgtw xmm4, xmm2 ;max > pixel [Parte baja]
		pcmpgtw xmm14, xmm6 ;max > pixel [Parte alta]

		;Para que las mascaras me queden bien armadas necesito tambien necesito
		;comparar por igual al maximo
		movdqu xmm10, xmm1
		pcmpeqw xmm10, xmm2
		por xmm4, xmm10

		movdqu xmm10, xmm1
		pcmpeqw xmm10, xmm6
		por xmm14, xmm10
		;-----me guardo la mascara de maximo

		;-----Invierto las mascaras
		movdqu xmm10, [notMask]
		pxor xmm3, xmm10	;FF si min < pixel
		pxor xmm4, xmm10	;FF si max < pixel
		pxor xmm13, xmm10
		pxor xmm14, xmm10
		movdqu xmm10, [maxfilter]
		psubusw xmm4, xmm10	;FF si max < pixel
		psubusw xmm14, xmm10

		movdqu xmm10, xmm6
		movdqu xmm11, xmm2
		punpckhwd xmm10, xmm15	;1 cuarto
		punpcklwd xmm11, xmm15	;4 cuarto
		punpcklwd xmm6, xmm15	;2 cuarto
		punpckhwd xmm2, xmm15	;3 cuarto
		;-----convertimos los int a float
		cvtdq2ps xmm10, xmm10
		cvtdq2ps xmm6, xmm6
		cvtdq2ps xmm2, xmm2
		cvtdq2ps xmm11, xmm11
		;-----Divido por Q
		divps xmm11, xmm7
		divps xmm2, xmm7
		divps xmm6, xmm7
		divps xmm10, xmm7
		;-----multiplico por Q
		roundps xmm10, xmm10, 11B
		roundps xmm6,xmm6, 11B
		roundps xmm2,xmm2, 11B
		roundps xmm11,xmm11, 11B
		;-----multiplico por Q
		mulps xmm6, xmm7
		mulps xmm2, xmm7
		mulps xmm11, xmm7
		mulps xmm10, xmm7
		;----vuelvo a pasar a doubleword
		cvtps2dq xmm6, xmm6
		cvtps2dq xmm10, xmm10
		cvtps2dq xmm11, xmm11
		cvtps2dq xmm2, xmm2
		
		;----empaqueto
		packusdw xmm6, xmm10
		packusdw xmm11, xmm2

		;----filtrado por mascara
		pand xmm6, xmm13 ;filtre por el minimo	[Parte alta]
		pand xmm11, xmm3 ;filtre por el minimo	[Parte baja]
		por xmm6, xmm14 ;filtre por el maximo	[Parte alta]
		por xmm11, xmm4 ;filtre por el maximo	[Parte baja]

		packuswb xmm11, xmm6

		movdqu [rsi+r15], xmm11 ;lo guardo en destino

		dec rdx
		add rdi, r8
		add rsi, r8
		xor r15, r15
		cmp rdx, 0
		jg .ciclo
		jmp .fin

.fin:
	add rsp, 8
	pop r15
	pop rbp
	ret



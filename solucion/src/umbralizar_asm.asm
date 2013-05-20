BITS 64
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

section .text

umbralizar_asm:
	push rbp
	mov rbp, rsp
	;-----voy a calcular el tamaño
    mov rcx, r8
	imul rcx, rdx ;me guardo el tamaño
	;xor rdx, rdx
	;mov rcx, 16
	;idiv rcx
	;mov rcx, rax
	;-----me guardo los parametros
	;me guardo los parámetros de entrada necesarios
	movdqu xmm5, [rbp+24]
	pshufd xmm5, xmm5, 0 ;Q en XMM5
	movdqu xmm7, xmm5 ;me guardo Q en float
	cvtdq2ps xmm7, xmm7
	movq xmm0, r9
	pxor xmm2, xmm2
	pshufb xmm0, xmm2 ;me guardo el minimo en xmm0
	pxor xmm1, xmm1
	movdqu xmm1, [rbp+16]
	pshufb xmm1, xmm2 ;me guardo el maximo en xmm1****** lo guarda como -128
.ciclo:
	movdqu xmm2, [rdi]
	;-----empiezo a comparar
	movdqu xmm3, xmm0 ;me guardo el minimo
	pcmpgtw xmm3, xmm2 ;min > pixel, voy a ver cuando es 0
	;-----quiero ver cuando el pixel es menor al minimo
	movdqu xmm4, xmm1 
	pcmpgtw xmm4, xmm2 ;max > pixel
	;-----me guardo la mascara de maximo
	pxor xmm15, xmm15
    movdqu xmm6, xmm2 ;************** despues de est xmm6 vale 0 y xmm2 vale otras cosas
	punpckhbw xmm6, xmm15 ;en xmm6 tengo la parte alta
	punpcklbw xmm2, xmm15 ;en xmm2 tengo la parte baja
	movdqu xmm10, xmm6
	movdqu xmm11, xmm2
	punpckhwd xmm10, xmm15 ;desempaqueto
	punpcklwd xmm11, xmm15
	punpcklwd xmm6, xmm15
	punpckhwd xmm2, xmm15
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
	packusdw xmm10, xmm6
	packusdw xmm2, xmm11
	packuswb xmm10, xmm2
	;----filtrado por mascara
	pand xmm10, xmm3 ;filtre por el minimo
	por xmm10, xmm4 ;filtre por el maximo
	movdqu [rsi], xmm10 ;lo guardo en destino
	sub rcx, 16
	add rdi, 16
	add rsi, 16
	;loop .ciclo
	;dec rcx
	cmp rcx, 0
	jne .ciclo
.fin:
	pop rbp
	ret



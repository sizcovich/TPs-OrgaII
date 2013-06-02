; void rotar_asm (
; 	unsigned char *src,
; 	unsigned char *dst,
; 	int m,
; 	int n,
; 	int src_row_size,
; 	int dst_row_size
; );

; ParÃ¡metros:
; 	rdi = src
; 	rsi = dst
; 	rdx = h
; 	rcx = w
; 	r8 = src_row_size
; 	r9 = dst_row_size

extern rotar_c

global rotar_asm

section .rodata
	tiraDeDos: dd 2.0, 2.0, 2.0, 2.0
	escalera: db 0x0000, 0x0001, 0x0002, 0x0003, 0x0004, 0x0005, 0x0006, 0x0007, 0x0008, 0x0009, 0x000A, 0x000B, 0x000C, 0x000D, 0x000E, 0x000F
 
section .text

rotar_asm:
	push RBP
	mov RBP, RSP
	push R15
	push R14
	push R13
	push R12
	push RBX
	sub rsp, 8
	
	;Idst = Isrc(u,v) entre 0<=u<Isrc_width y 0<=v<Isrc_height
	;u  = cx + sqrt(2)/2 (x-cx) - sqrt(2)/2 (y-cy)
	;v = cy + sqrt(2)/2 (x-cx) + sqrt(2)/2 (y-cy)
	;cx = [Isrc_width/2]
	;cy = [Isrc_height/2]
	mov r12, rdx ;tengo a h
	mov r14, rcx ;tengo a w
	shr rdx, 1 ;Cy en rdx
	shr rcx, 1 ;Cx en rcx
	mov r11, rcx
	;armo x e y
	mov r15, 0 ;contador x
	mov r10, 0	;contador y
	
	;mov r10, r8
	;sub r10, r14 ;en r10 tengo lo que tengo que es basura
	movdqu xmm3, [escalera]
	movups xmm15, [tiraDeDos]
	
	;me genero una copia para calcularle la raiz
	movdqu xmm0, xmm15	;1 cuarto
	
	;calculo la raiz cuadrada
	sqrtps xmm0, xmm0
	
	;divido por 2
	divps xmm0, xmm15
	

.inicioCiclo:
	movdqu xmm11, xmm3
	movdqu xmm12, xmm3
	
	pxor xmm7, xmm7
	
	punpcklbw xmm12, xmm7	;1 mitad
	punpckhbw xmm11, xmm7	;2 mitad
	
	movdqu xmm10, xmm12
	movdqu xmm13, xmm11

	;desempaqueto la escalera
	punpcklwd xmm10, xmm7	;1 cuarto
	punpckhwd xmm11, xmm7	;4 cuarto
	punpckhwd xmm12, xmm7	;2 cuarto
	punpcklwd xmm13, xmm7	;3 cuarto
	;xmm3 = xmm10 : xmm12 : xmm13 : xmm11
	
	movq xmm7, r15 ;tenemos a x
	pshufd xmm7, xmm7, 0
	
	;le sumamos el offset
	paddd xmm10, xmm7	;1 cuarto
	paddd xmm11, xmm7	;4 cuarto
	paddd xmm12, xmm7	;2 cuarto
	paddd xmm13, xmm7	;3 cuarto

	mov rax, 4
.cuarto:
	;Voy a cargar el indice de fila
	movq xmm1, r10 ;contador y
	pshufd xmm1, xmm1, 0
	cvtdq2ps xmm1, xmm1

	cvtdq2ps xmm10, xmm10	;Convierto a float a los indices
	
	movq xmm5, r11 ;tengo Cx
	movq xmm2, rdx ;tengo Cy
	pshufd xmm2, xmm2, 0
	pshufd xmm5, xmm5, 0
	
	;convierto los cx y cy a float
	cvtdq2ps xmm2, xmm2
	cvtdq2ps xmm5, xmm5
	
	subps xmm10, xmm2
	subps xmm1, xmm5
	
	mulps xmm10, xmm0 ;multiplico (x-Cx)sqrt(2)/2
	mulps xmm1, xmm0 ;multiplico (y-Cy)sqrt(2)/2
	
	movdqu xmm4, xmm10	;(x-Cx)sqrt(2)/2
	movdqu xmm6, xmm1	;(y-Cy)sqrt(2)/2
	;sumo Cx y Cy
	addps xmm4, xmm5	;(x-Cx)sqrt(2)/2 + Cx
	addps xmm6, xmm2	;(y-Cy)sqrt(2)/2 + Cy
	
	subps xmm4, xmm1 ;u esta en xmm4
	addps xmm6, xmm10 ;v esta en xmm6
	
	;u<-XMM4 v<-XMM6
	pxor xmm7, xmm7
	movups xmm14, xmm4
	movups xmm5, xmm6
	movups xmm8, xmm4 ;tengo a u
	movups xmm2, xmm6 ;tengo a v
	cmpps xmm4, xmm7, 5 ;0≤u 
	cmpps xmm6, xmm7, 5 ;0≤v 
	movq xmm7, r12 ;tengo a h
	movq xmm9, r14;tengo a w
	pshufd xmm7, xmm7, 0
	pshufd xmm9, xmm9, 0
	cvtdq2ps xmm7, xmm7
	cvtdq2ps xmm9, xmm9
	cmpps xmm14, xmm9, 1 ;u < w ?
	cmpps xmm5, xmm7, 1 ;v < h?
	
	cvtps2dq xmm8, xmm8	;u
	cvtps2dq xmm2, xmm2	;v
	
	pand xmm4, xmm14
	pand xmm5, xmm6
	pand xmm4, xmm5	;Obtengo cuando se cumplen las dos condiciones

	push rax
	sub rsp, 8
.continuo0:
	xor r13, r13
	pextrd r13d, xmm4, 0
	cmp r13, 0
	je .daCero0
	
	xor rbx, rbx
	xor rax, rax
	pextrd ebx, xmm2, 0	;Obtengo la coordenada vertical
	imul rbx, r8	;Calculo el offset vertical de la coordenada
	pextrd eax, xmm8, 0	;Obtengo la coordenada horizontal
	add rbx, rax	;Calculo el offset final de la coordenada
	mov cl, [rdi+rbx]	;Obtengo el pixel que quiero mover
	
	mov rbx, r10	;Copio el indice y
	imul rbx, r9	;Calculo el offset vertical del destino
	add rbx, r15	;Calculo el oofset final del destino
	mov [rsi+rbx], cl	;Copio el pixel
	
	inc r15
	
	jmp .continuo1
.daCero0:
	;En caso de que sea falsa la condicion
	inc r15

.continuo1:
	xor r13, r13
	pextrd r13d, xmm4, 1
	cmp r13, 0
	je .daCero1
	
	xor rbx, rbx
	xor rax, rax
	pextrd ebx, xmm2, 1	;Obtengo la coordenada vertical
	imul rbx, r8	;Calculo el offset vertical de la coordenada
	pextrd eax, xmm8, 1	;Obtengo la coordenada horizontal
	add rbx, rax	;Calculo el offset final de la coordenada
	mov cl, [rdi+rbx]	;Obtengo el pixel que quiero mover
	
	mov rbx, r10	;Copio el indice y
	imul rbx, r9	;Calculo el offset vertical del destino
	add rbx, r15	;Calculo el oofset final del destino
	mov [rsi+rbx], cl	;Copio el pixel
	
	inc r15
	
	jmp .continuo2
.daCero1:
	;En caso de que sea falsa la condicion
	inc r15
	
.continuo2:
	xor r13, r13
	pextrd r13d, xmm4, 2
	cmp r13, 0
	je .daCero2
	
	xor rbx, rbx
	xor rax, rax
	pextrd ebx, xmm2, 2	;Obtengo la coordenada vertical
	imul rbx, r8	;Calculo el offset vertical de la coordenada
	pextrd eax, xmm8, 2	;Obtengo la coordenada horizontal
	add rbx, rax	;Calculo el offset final de la coordenada
	mov cl, [rdi+rbx]	;Obtengo el pixel que quiero mover
	
	mov rbx, r10	;Copio el indice y
	imul rbx, r9	;Calculo el offset vertical del destino
	add rbx, r15	;Calculo el oofset final del destino
	mov [rsi+rbx], cl	;Copio el pixel
	
	inc r15
	
	jmp .continuo3
.daCero2:
	;En caso de que sea falsa la condicion
	inc r15

.continuo3:
	xor r13, r13
	pextrd r13d, xmm4, 3
	cmp r13, 0
	je .daCero3
	
	xor rbx, rbx
	xor rax, rax
	pextrd ebx, xmm2, 3	;Obtengo la coordenada vertical
	imul rbx, r8	;Calculo el offset vertical de la coordenada
	pextrd eax, xmm8, 3	;Obtengo la coordenada horizontal
	add rbx, rax	;Calculo el offset final de la coordenada
	mov cl, [rdi+rbx]	;Obtengo el pixel que quiero mover
	
	mov rbx, r10	;Copio el indice y
	imul rbx, r9	;Calculo el offset vertical del destino
	add rbx, r15	;Calculo el oofset final del destino
	mov [rsi+rbx], cl	;Copio el pixel
	
	inc r15
	
	jmp .continuo4
.daCero3:
	;En caso de que sea falsa la condicion
	inc r15

.continuo4:
	add rsp, 8
	pop rax
	dec rax
	movdqu xmm10, xmm12
	movdqu xmm12, xmm13
	movdqu xmm13, xmm11
	cmp rax, 0
	jg .cuarto
	cmp r15, r14	;Me fijo si estoy al tamaño de la fila
	jge .sigFila
	
.veoSiLlegoAlFin:	
	;add r15, 16 ;le sumo 16
	;Me quiero fijar si estoy en la franja de los ultimos 16
	sub r14, 16
	cmp r15, r14
	jge .ultimoTramo
	add r14, 16
	jmp .inicioCiclo
	
.sigFila:
	cmp r10, r12
	je .fin
	mov r15, 0
	add r10, 1
	jmp .inicioCiclo

.ultimoTramo:
	mov rbx, rax
	sub rbx, r14	;Tengo el offset que volver para atras
	sub rax, rbx	;Tengo el indice corregido
	add r14, 16
	jmp .inicioCiclo
		
.fin:
	add RSP,8
	pop RBX
	pop R12
	pop R13
	pop R14
	pop R15
	pop RBP
	ret

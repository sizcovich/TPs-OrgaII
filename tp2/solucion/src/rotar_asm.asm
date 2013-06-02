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
	;armo x e y
	mov r15, 0 ;contador x
	movq xmm1, r15;contador y
	mov r10, r8
	sub r10, rcx ;en r10 tengo lo que tengo que es basura
	movdqu xmm3, [escalera]
	movups xmm15, [tiraDeDos]
	
	;desempaqueto la escalera
	punpckhwd xmm10, xmm3	;1 cuarto
	punpcklwd xmm11, xmm3	;4 cuarto
	punpcklwd xmm12, xmm3	;2 cuarto
	punpckhwd xmm13, xmm3	;3 cuarto
	
	;me genero una copia para calcularle la raiz
	movdqu xmm0, xmm15	;1 cuarto
	
	;calculo la raiz cuadrada
	sqrtps xmm0, xmm0
	
	;divido por 2
	divps xmm0, xmm15
	

.inicioCiclo:

	movq xmm5, rcx ;tengo Cx
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
	
	movdqu xmm4, xmm10
	movdqu xmm6, xmm1
	;sumo Cx y Cy
	addps xmm4, xmm5
	addps xmm6, xmm2
	
	subps xmm4, xmm10 ;u esta en xmm4
	addps xmm6, xmm1 ;v esta en xmm6
	
	;u<-XMM4 v<-XMM6
	
	jl .noEntra
	cmp r13, r14
	jge .noEntra
	;aca veo v
	cmp r15, 0
	jl .noEntra
	cmp rdi, r12
	jge .noEntra
	
;no salto entonces hay que operar
.esMenor:

	
.noEntra:
	mov qword rsi, 0

	
.veoSiLlegoAlFin:	
	add r15, 16 ;le sumo 16
	cmp r15, r12
	jne .inicioCiclo
	mov r15, 0
	cmp r13, rcx
	je .fin
	add r13, 1
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

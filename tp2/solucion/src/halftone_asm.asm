; void halftone_asm (
; 	unsigned char *src,
; 	unsigned char *dst,
; 	int m,
; 	int n,
; 	int src_row_size,
; 	int dst_row_size
; );

; Parámetros:
; 	rdi = src
; 	rsi = dst
; 	rdx = h
; 	rcx = w
; 	r8 = src_row_size
; 	r9 = dst_row_size

global halftone_asm

section .rodata

dosCientosCinco: DW 205, 205, 205, 205, 205, 205, 205, 205
cuatroCientosDiez: DW 410, 410, 410, 410, 410, 410, 410, 410
seisCientosQuince: DW 615, 615, 615, 615, 615, 615, 615, 615
ochoCientosVeinte: DW 820, 820, 820, 820, 820, 820, 820, 820
inversor: DQ 0xffffffffffffffff,0xffffffffffffffff
filaAbajo: DQ 0x00ff00ff00ff00ff,0x00ff00ff00ff00ff
filaArriba: DQ 0xff00ff00ff00ff00,0xff00ff00ff00ff00

section .text

halftone_asm:
	push RBP
	mov RBP, RSP
	push R12
	push R13
	push r14
	push r15
	push rbx
	sub rsp, 8

	mov r15, rdi
	;voy a ver si el ancho y largo es par
	mov r14, rdx ;me guardo el alto
	mov r13, rcx ;me guardo el ancho
	;veo si tiene ancho y largo pares
	xor rdx, rdx
	mov rbx, 2
	mov rax, r14
	div ebx
	cmp rdx, 0
	je .verAncho
	dec r14
.verAncho:
	xor rdx, rdx
	mov rax, r13
	div ebx
	cmp rdx, 0
	je .inicio
	dec r13
.inicio:
	mov r10, r8
	mov r11, r9
	sub r10, rcx
	sub r11, rcx
    xor rbx, rbx
	
	sub r13, 16 ;resto para ver cuando llego al final
	movdqu xmm15, [dosCientosCinco]
	movdqu xmm14, [cuatroCientosDiez]
	movdqu xmm13, [seisCientosQuince]
	movdqu xmm12, [ochoCientosVeinte]
	movdqu xmm11, [inversor]
	movdqu xmm10, [filaAbajo]
	movdqu xmm9, [filaArriba]
	add r15, r8
.ciclo:
	movdqu xmm0, [rdi] ;me voy a desplazar con rbx
	movdqu xmm2, [rdi+r8] ;sumo rdi+r8

	pxor xmm8, xmm8
	movq xmm1, xmm0 ;fila arriba
	movq xmm3, xmm2 ;fila de abajo
	
	punpckhbw xmm0, xmm8 ;fila 1
	punpcklbw xmm1, xmm8 ;fila 1
	punpckhbw xmm2, xmm8 ;fila 2
	punpcklbw xmm3, xmm8 ;fila 2

	;sumamos para obtener los valores de los cuadraditos
	paddw xmm0, xmm2
	paddw xmm1, xmm3
	phaddw xmm1, xmm0

	;En caso de que sea >= 205 solo cambio el valor de arriba
	;En caso de que sea >= 410 cambio el de abajo con respecto al anterior
	;En caso de que sea >= 615 cambio el de abajo con respecto al anterior
	;En caso de que sea >= 820 cambio todo
	
	;t >=205
	movdqu xmm0, xmm15
	pcmpgtw xmm0, xmm1
	pxor xmm0, xmm11
	pand xmm0, xmm10	;Fila de arriba
	
	movdqu xmm2, xmm14
	pcmpgtw xmm2, xmm1
	pxor xmm2, xmm11
	pand xmm2, xmm9	;Fila de abajo filtrada
	
	movdqu xmm3, xmm13
	pcmpgtw xmm3, xmm1
	pxor xmm3, xmm11 ;invierto
	pand xmm3, xmm10
	
	movdqu xmm4, xmm12
	pcmpgtw xmm4, xmm1
	pxor xmm4, xmm11
	pand xmm4, xmm9
	
	;combino los datos de la fila de arriba
	por xmm0, xmm4
	por xmm2, xmm3
	
	movdqu [rsi],xmm0
	movdqu [rsi+r9],xmm2
	
	add rbx, 16 ;le sumo 16 a mi contador
	add rsi, 16
	add rdi, 16
	cmp rbx, r13
	jl .ciclo
	je .siguienteFila
.ultimaColumna:

	sub rbx, r13
	sub rdi, rbx
	sub rsi, rbx
	movdqu xmm0, [rdi] ;me voy a desplazar con rbx
	movdqu xmm2, [rdi+r8] ;sumo rdi+r8

	pxor xmm8, xmm8
	movq xmm1, xmm0 ;fila arriba
	movq xmm3, xmm2 ;fila de abajo
	
	punpckhbw xmm0, xmm8 ;fila 1
	punpcklbw xmm1, xmm8 ;fila 1
	punpckhbw xmm2, xmm8 ;fila 2
	punpcklbw xmm3, xmm8 ;fila 2

	;sumamos para obtener los valores de los cuadraditos
	paddw xmm0, xmm2
	paddw xmm1, xmm3
	phaddw xmm1, xmm0

	;En caso de que sea >= 205 solo cambio el valor de arriba
	;En caso de que sea >= 410 cambio el de abajo con respecto al anterior
	;En caso de que sea >= 615 cambio el de abajo con respecto al anterior
	;En caso de que sea >= 820 cambio todo
	
	;t >=205
	movdqu xmm0, xmm15
	pcmpgtw xmm0, xmm1
	pxor xmm0, xmm11
	pand xmm0, xmm10	;Fila de arriba
	
	movdqu xmm2, xmm14
	pcmpgtw xmm2, xmm1
	pxor xmm2, xmm11
	pand xmm2, xmm9	;Fila de abajo filtrada
	
	movdqu xmm3, xmm13
	pcmpgtw xmm3, xmm1
	pxor xmm3, xmm11 ;invierto
	pand xmm3, xmm10
	
	movdqu xmm4, xmm12
	pcmpgtw xmm4, xmm1
	pxor xmm4, xmm11
	pand xmm4, xmm9
	
	;combino los datos de la fila de arriba
	por xmm0, xmm4
	por xmm2, xmm3
	
	movdqu [rsi],xmm0
	movdqu [rsi+r9],xmm2
	
.siguienteFila:
	sub r14, 2 ;veo si tengo mas filas
	cmp r14, 0
	jle .fin
	add rdi, 16
	add rsi, 16
	add rdi, r10
	add rsi, r11
	add rdi, r8
	add rsi, r9
	xor rbx, rbx
	jmp .ciclo
	

.fin:
	add rsp, 8
	pop rbx
	pop r15
	pop r14
	pop R13
	pop R12
	pop RBP
	ret

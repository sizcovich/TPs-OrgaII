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

extern halftone_c

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
	mov r12, rdx ;me guardo el alto
	mov r13, rcx ;me guardo el ancho
	;veo si tiene ancho y largo pares
	xor rdx, rdx
	mov rbx, 2
	mov rax, r12
	div ebx
	cmp rdx, 0
	je .verAncho
	dec r12
.verAncho:
	xor rdx, rdx
	mov rax, r13
	div ebx
	cmp rdx, 0
	je .inicio
	dec r13
.inicio:
    xor rbx, rbx

	sub r13, 16
	movdqu xmm15, [dosCientosCinco]
	movdqu xmm14, [cuatroCientosDiez]
	movdqu xmm13, [seisCientosQuince]
	movdqu xmm12, [ochoCientosVeinte]
	movdqu xmm11, [inversor]
	movdqu xmm10, [filaAbajo]
	movdqu xmm9, [filaArriba]
.ciclo:
	add r15, r8
	movdqu xmm0, [rdi+rbx]
	movdqu xmm2, [r15+rbx]

	pxor xmm8, xmm8
	movdqu xmm1, xmm0
	movdqu xmm3, xmm2
	punpckhbw xmm0, xmm8
	punpcklbw xmm3, xmm8
	punpckhbw xmm2, xmm8
	punpcklbw xmm1, xmm8

	;sumamos para obtener los valores de los cuadraditos
	phaddw xmm0, xmm1
	phaddw xmm2, xmm3
	paddw xmm0, xmm2

	movdqu xmm1, xmm0
	movdqu xmm2, xmm0
	movdqu xmm3, xmm0
	movdqu xmm4, xmm0
	movdqu xmm5, xmm0
	movdqu xmm6, xmm0
	movdqu xmm7, xmm0

	pcmpgtw xmm0, xmm15	;obtenemos los valores mayores a 205
	pcmpeqw xmm1, xmm15	;Obtenemos los valores iguales a 205
	por xmm0, xmm1

	pcmpgtw xmm2, xmm14	;obtenemos los valores mayores a 410
	pcmpeqw xmm3, xmm14	;Obtenemos los valores iguales a 410
	por xmm2, xmm3

	pcmpgtw xmm4, xmm13	;obtenemos los valores mayores a 615
	pcmpeqw xmm5, xmm13	;Obtenemos los valores iguales a 615
	por xmm4, xmm5

	pcmpgtw xmm6, xmm12	;obtenemos los valores mayores a 820
	pcmpeqw xmm7, xmm12	;Obtenemos los valores iguales a 820
	por xmm6, xmm7

	;En caso de que sea >= 205 solo cambio el valor de arriba
	;En caso de que sea >= 410 cambio el de abajo con respecto al anterior
	;En caso de que sea >= 615 cambio el de abajo con respecto al anterior
	;En caso de que sea >= 820 cambio todo
	pand xmm0, xmm9	;Fila de arriba filtrada
	pand xmm2, xmm10	;Fila de abajo filtrada
	pand xmm4, xmm10	;Fila de abajo filtrada
	pand xmm6, xmm9	;Fila de arriba filtrada

	;combino los datos de la fila de arriba
	por xmm0, xmm6
	;combino los datos de la fila de arriba
	por xmm2, xmm4

	mov r12, rbx
	add r12, r9
	movdqu [rsi+rbx], xmm0
	movdqu [rsi+r12], xmm2
	add rbx, 16

	cmp rbx, r13
	jl .ciclo

.ultimaColumna:
	mov r12, rbx
	sub r12, r13
	sub rbx, r12	;Le resto la diferencia para caer en los ultimos 16
	
	add r15, r8
	movdqu xmm0, [rdi+rbx]
	movdqu xmm2, [r15+rbx]

	pxor xmm8, xmm8
	movdqu xmm1, xmm0
	movdqu xmm3, xmm2
	punpckhbw xmm0, xmm8
	punpcklbw xmm3, xmm8
	punpckhbw xmm2, xmm8
	punpcklbw xmm1, xmm8

	;sumamos para obtener los valores de los cuadraditos
	phaddw xmm0, xmm1
	phaddw xmm2, xmm3
	paddw xmm0, xmm2

	movdqu xmm1, xmm0
	movdqu xmm2, xmm0
	movdqu xmm3, xmm0
	movdqu xmm4, xmm0
	movdqu xmm5, xmm0
	movdqu xmm6, xmm0
	movdqu xmm7, xmm0

	pcmpgtw xmm0, xmm15	;obtenemos los valores mayores a 205
	pcmpeqw xmm1, xmm15	;Obtenemos los valores iguales a 205
	por xmm0, xmm1

	pcmpgtw xmm2, xmm14	;obtenemos los valores mayores a 410
	pcmpeqw xmm3, xmm14	;Obtenemos los valores iguales a 410
	por xmm2, xmm3

	pcmpgtw xmm4, xmm13	;obtenemos los valores mayores a 615
	pcmpeqw xmm5, xmm13	;Obtenemos los valores iguales a 615
	por xmm4, xmm5

	pcmpgtw xmm6, xmm12	;obtenemos los valores mayores a 820
	pcmpeqw xmm7, xmm12	;Obtenemos los valores iguales a 820
	por xmm6, xmm7

	;En caso de que sea >= 205 solo cambio el valor de arriba
	;En caso de que sea >= 410 cambio el de abajo con respecto al anterior
	;En caso de que sea >= 615 cambio el de abajo con respecto al anterior
	;En caso de que sea >= 820 cambio todo
	pand xmm0, xmm9	;Fila de arriba filtrada
	pand xmm2, xmm10	;Fila de abajo filtrada
	pand xmm4, xmm10	;Fila de abajo filtrada
	pand xmm6, xmm9	;Fila de arriba filtrada

	;combino los datos de la fila de arriba
	por xmm0, xmm6
	;combino los datos de la fila de arriba
	por xmm2, xmm4

	mov r12, rbx
	add r12, r9
	movdqu [rsi+rbx], xmm0
	movdqu [rsi+r12], xmm2
	
.siguienteFila:
	sub r12, 2 ;veo si tengo mas filas
	cmp r12, 0
	je .fin
;	add rbx, r8
;	add rbx, r8
	
.fin:
	add rsp, 8
	pop rbx
	pop r15
	pop r14
	pop R13
	pop R12
	pop RBP
	ret

; void recortar_asm (
; 	unsigned char *src,
; 	unsigned char *dst,
; 	int h,
; 	int w,
; 	int src_row_size,
; 	int dst_row_size,
; 	int tam
; );

; Parametros:
; 	rdi = src
; 	rsi = dst
; 	rdx = h
; 	rcx = w
; 	r8 = src_row_size
; 	r9 = dst_row_size
; 	rbp + 16 = tam

extern recortar_c

global recortar_asm

section .text

recortar_asm:

	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	push rbx
	sub rsp, 8
   
   mov r12, rdx	;H
   mov r13, rcx	;W

;Cuadrante B
;--------------
; 	rdi = src
; 	rsi = dst
; 	r8 = src_row_size
; 	r9 = dst_row_size
; 	rbp + 16 = tam
;   rdx es la fila
;   rcx es la columna


.cuadradoB:
   xor rdx, rdx    ;primer fila
	xor r10, r10
	mov r10d, r13d	;Copio el ancho
	sub r10d, [rbp+16]	;Le resto el tam para obtener el offset
  
	xor r14, r14	;Acumulador
	xor r11, r11    ;Offset vertical
	mov rax, r9
	imul dword [rbp+16]
	mov r11d, eax	;Calculo el offset vertical de destino
	mov rbx, r11

.cicloB:
	xor r15, r15    ;Acumulador
	mov rcx, r10	;Me paro al inicio del cuadrado
	add rcx, rdx	;Me muevo al principio del cuadrado en la linea rdx
.loopLineaB:
	movdqu xmm0, [rdi+rcx]	;Tomo el pedazo de memoria
	movdqu [rsi+rbx], xmm0	;Guardo los valores en destino
	add rcx, 16
	add rbx, 16
	add r15, 16
  
	cmp r15d, [rbp + 16]	;Me fijo que el desplazamiento horizontal todavia este dentro de la linea
	jl .loopLineaB

	add rdx, r8
	add r11, r9
	mov rbx, r11
	inc r14
	cmp r14d, [rbp+16]	;Me fijo que el acumulador sea menor que el total de filas
	jne .cicloB

;-------------------------------------------------
.cuadradoD:
    xor rdx, rdx
    xor rax, rax    ;primer fila
    mov eax, r12d
    sub eax, [rbp+16]
    imul r8
    mov edx, eax    ;offset vertical
   
	xor r10, r10
	mov r10d, r13d	;Copio el ancho
	sub r10d, [rbp+16]	;Le resto el tam para obtener el offset horizontal
  
	xor r14, r14	;Acumulador
	xor r11, r11    ;Offset vertical dst(osea 0)
	mov rbx, r11

.cicloD:
	xor r15, r15    ;Acumulador
	mov rcx, r10	;Me paro al inicio del cuadrado
	add rcx, rdx	;Me muevo al principio del cuadrado en la linea rdx
.loopLineaD:
	movdqu xmm0, [rdi+rcx]	;Tomo el pedazo de memoria

	movdqu [rsi+rbx], xmm0	;Guardo los valores en destino
	add rcx, 16
	add rbx, 16
	add r15, 16
  
	cmp r15d, [rbp + 16]	;Me fijo que el desplazamiento horizontal todavia este dentro de la linea
	jl .loopLineaD

	add rdx, r8
	add r11, r9
	mov rbx, r11
	inc r14
	cmp r14d, [rbp+16]	;Me fijo que el acumulador sea menor que el total de filas
	jne .cicloD
  
;-------------------------------------------------
;.cuadradoA:
;    xor rdx, rdx    ;primer fila
;	xor r10, r10    ;Offset vertical src
;  
;	xor r14, r14	;Acumulador
;	xor r11, r11    ;Offset vertical dst
;	mov eax, [rbp+16]
;	imul dword r9
;	mov r11d, eax	;Calculo el offset vertical de destino
;	add r11d, [rbp+16]
;	mov rbx, r11
;
;.cicloA:
;	xor r15, r15    ;Acumulador
;	mov rcx, r10	;Me paro al inicio del cuadrado
;	add rcx, rdx	;Me muevo al principio del cuadrado en la linea rdx
;.loopLineaA:
;	movdqu xmm0, [rdi+rcx]	;Tomo el pedazo de memoria
;
;	movdqu [rsi+rbx], xmm0	;Guardo los valores en destino
;	add rcx, 16
;	add rbx, 16
;	add r15, 16
;  
;	cmp r15d, [rbp + 16]	;Me fijo que el desplazamiento horizontal todavia este dentro de la linea
;	jl .loopLineaA
;
;	add rdx, r8
;	add r11, r9
;	mov rbx, r11
;	inc r14
;	cmp r14d, [rbp+16]	;Me fijo que el acumulador sea menor que el total de filas
;	jne .cicloA

;-------------------------------------------------
.cuadradoC:
    xor rdx, rdx
    xor rax, rax    ;primer fila
    mov eax, r12d
    sub eax, [rbp+16]
    imul r8
    mov edx, eax    ;offset vertical
   
	xor r10, r10
	mov r10d, r13d	;Copio el ancho
	sub r10d, [rbp+16]	;Le resto el tam para obtener el offset horizontal
  
	xor r14, r14	;Acumulador
	xor r11, r11    ;Offset vertical dst(osea 0)
	mov rbx, r11

.cicloC:
	xor r15, r15    ;Acumulador
	mov rcx, r10	;Me paro al inicio del cuadrado
	add rcx, rdx	;Me muevo al principio del cuadrado en la linea rdx
.loopLineaC:
	movdqu xmm0, [rdi+rcx]	;Tomo el pedazo de memoria

	movdqu [rsi+rbx], xmm0	;Guardo los valores en destino
	add rcx, 16
	add rbx, 16
	add r15, 16
  
	cmp r15d, [rbp + 16]	;Me fijo que el desplazamiento horizontal todavia este dentro de la linea
	jl .loopLineaC

	add rdx, r8
	add r11, r9
	mov rbx, r11
	inc r14
	cmp r14d, [rbp+16]	;Me fijo que el acumulador sea menor que el total de filas
	jne .cicloC

	add rsp, 8
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
; **************************************
;push rbp
;	mov rbp, rsp
;
;	sub rsp, 8
;
;	push qword [rbp + 16]
;	call recortar_c
;	add rsp, 8
;
;	add rsp, 8
;
;	pop rbp
;**************************************	
	ret

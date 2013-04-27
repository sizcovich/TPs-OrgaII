; void recortar_asm (
; 	unsigned char *src,
; 	unsigned char *dst,
; 	int h,
; 	int w,
; 	int src_row_size,
; 	int dst_row_size,
; 	int tam
; );

; Parámetros:
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

    mov r12, rdx	;H
    mov r13, rcx	;W

;Cuadrante B
;--------------
;rdx es la fila
;rcx es la columna

    xor rdx, rdx    ;primer fila

	xor r10, r10
	mov r10d, r13d	;Copio el ancho
	sub r10d, [rbp+16]	;Le resto el tam para obtener el offset

.cuadradoB:
	xor r14, r14	;Acumulador
	xor r11, r11
	mov rax, r9
	imul [rbp+16]
	mov r11d, eax	;Calculo el offset vertical de destino

.ciclo:
	mov rcx, r10	;Me paro al inicio del cuadrado
.loopLinea:
	add rcx, rdx	;Me muevo al principio del cuadrado en la linea rdx
	movdqu xmm0, [rdi+rcx]	;Tomo el pedazo de memoria

	movdqu [rsi+r11], xmm0	;Guardo los valores en destino
	add rcx, 16
	cmp rcx, r8	;Me fijo que el desplazamiento horizontal todavia este dentro de la linea
	jge .loopLinea

	add rdx, r8
	inc r14
	cmp r14, [rbp+16]	;Me fijo que el acumulador sea menor que el total de filas
	jne .ciclo

;	push qword [rbp + 16]
;	call recortar_c
;	add rsp, 8

    pop r13
    pop r12
    pop rbp

	ret

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

    mov r12, rdx
    mov r13, rcx

;Cuadrante B
;--------------
;rdx es la fila
;rcx es la columna

    xor rdx, rdx    ;primer fila

	xor r10, r10
	mov r10d, r13d	;Copio el ancho
	sub r10d, [rbp+16]	;Le resto el tam para obtener el offset

.cuadradoB:
	mov rcx, r10	;Me paro al inicio del cuadrado
	

;	push qword [rbp + 16]
;	call recortar_c
;	add rsp, 8

    pop r13
    pop r12
    pop rbp

	ret


; void rotar_asm (
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

extern rotar_c

global rotar_asm

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
	mov rax, rdx
	div 2
	mov r13, rax ;Cy
	mov rax, rcx
	div 2
	mov r15, rax ;Cx
	;en r8 y en r9 voy a guardar u y v
	
	
	;aca veo u
	cmp rsi, 0
	jl .noEntra
	cmp rsi, r14
	jge .noEntra
	;aca veo v
	cmp rdi, 0
	jl .noEntra
	cmp rdi, r14
	jge .noEntra
;no salto entonces hay que operar
.esMenor:
	mov r8, r15
	mov r10, 2
	sqrtps r10, r10
	mov rax, r10
	div 2
	mov r10, rax
	mov r11, x
	sub r11, r15
	mov rax, r15
	mul r10
	
.noEntra:
	mov rsi, 0

		
	;empiezo a comparar
	;aca recorro la matriz
.ciclo:
	xor r15, r15    ;Acumulador
	add r15, 16
	mov rcx, r10	;Me paro al inicio del cuadrado
	add rcx, rdx	;Me muevo al principio del cuadrado en la linea rdx
.loopLinea:
	movdqu xmm0, [rdi+rcx]	;Tomo el pedazo de memoria
	movdqu [rsi+rbx], xmm0	;Guardo los valores en destino
	add rcx, 16
	add rbx, 16
	add r15, 16
  
	cmp r15d, eax	;Me fijo que el desplazamiento horizontal todavia este dentro de la linea
	jl .loopLinea
	sub r15d, eax	;Me quedo con la diferencia por la que me pase
	sub ecx, r15d	;Retrocedo el exceso
	sub ebx, r15d
	movdqu xmm0, [rdi+rcx]	;Tomo el pedazo de memoria
	movdqu [rsi+rbx], xmm0	;Guardo los valores en destino

	add rdx, r8
	add r11, r9
	mov rbx, r11
	inc r14
	cmp r14d, eax	;Me fijo que el acumulador sea menor que el total de filas
	jl .ciclo
	
	
;*******************
;	sub rsp, 8

;	call rotar_c

;	add rsp, 8
;*******************	
	add RSP,8
	pop RBX
	pop R12
	pop R13
	pop R14
	pop R15
	pop RBP
	ret

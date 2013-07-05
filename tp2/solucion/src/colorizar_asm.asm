; void colorizar_asm (
; 	unsigned char *src,
; 	unsigned char *dst,
; 	int m,
; 	int n,
; 	int src_row_size,
; 	int dst_row_size,
;   float alpha
; );

; Parámetros:
; 	rdi = src
; 	rsi = dst
; 	rdx = m //altura
; 	rcx = n //fila
; 	r8 = src_row_size
; 	r9 = dst_row_size
;   xmm0 = alpha

%define cant_de_datos 9

global colorizar_asm

section .rodata:
align 16
;Para invertir las mascaras
negador: dw 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF
;1415	1213	1011	89	67	45	23	01
datos_que_me_interesan: dw 0x0000, 0x00FF, 0xFF00, 0x0000, 0x00FF, 0x0000, 0x0000, 0x0000
;Lo uso para acomodar r3, g3, b3
datos_que_me_interesan2: dw 0x00FF, 0x00FF, 0x0000, 0x00FF, 0x0000, 0x0000, 0x0000, 0x0000
;lo uso para quitar el segundo float en q
datos_que_me_interesan3: dw 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0x0000, 0x0000

rearmo_fila_r: dw 0xFFFF, 0xFFFF, 0x00FF, 0xFFFF, 0xFF01, 0x02FF, 0xFFFF, 0xFFFF
;10     32       54      76      98    1110    1312    1514
rearmo_fila_g: dw 0xFFFF, 0xFFFF, 0xFF00, 0x01FF, 0xFFFF, 0xFF02, 0xFFFF, 0xFFFF
;10     32       54      76      98    1110    1312    1514
rearmo_fila_b: dw 0xFFFF, 0x00FF, 0xFFFF, 0xFF01, 0x02FF, 0xFFFF, 0xFFFF, 0xFFFF

limpio_el_medio_y_comienzo: dw 0xFFFF, 0x00FF, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000

limpio_el_medio_y_fin: dw 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0xFFFF, 0xFFFF

acomodo_r: dw 0xFF06, 0xFFFF, 0xFF09, 0xFFFF, 0xFFFF, 0xFFFF, 0xFF0C, 0xFFFF
			   ;1415	1213	1011	  89	  67	  45	 23	     01
acomodo_g: dw 0xFF05, 0xFFFF, 0xFF08, 0xFFFF, 0xFFFF, 0xFFFF, 0xFF0B, 0xFFFF

acomodo_b: dw 0xFF04, 0xFFFF, 0xFF07, 0xFFFF, 0xFFFF, 0xFFFF, 0xFF0A, 0xFFFF
;10     32       54      76      98    1110    1312    1514
acomodo_r_g_b: dw 0xFF02, 0xFFFF, 0xFF05, 0xFFFF, 0xFF08, 0xFFFF, 0xFFFF, 0xFFFF

mascara_caso_borde: dw 0xFFFF, 0xFFFF, 0x0000, 0x0000, 0x0000, 0x0000, 0xFF00, 0xFFFF

section .text

colorizar_asm:
 	push rbp
	mov rbp, rsp
	push rbx
	push r15
	push r14
	push r13
	push r12
	add rsp, 8
		
	;r12d es puntero a la fuente y r13d puntero al destino y 
	;los coloco en la segunda fila
	mov r12, rdi
	mov r13, rsi
	add r12, r8
	add r13, r9
		
	;me guardo un -9 para hacer una comparacion
	xor r10, r10
	sub r10, 9
	
	;r14 me dice en que lugar de la fila estoy
	imul rcx, 3
	mov r14, rcx ;rcx = w
	sub r14, 16
	
	;como miro de a 3 filas resta la ultima y la primera
	sub rdx, 2
	
	;todos 0's para desempaquetar
	pxor xmm8, xmm8
	
	;me guardo la mascara del negador para no hacer tantos accesos a memoria
	movdqu xmm15, [negador]
	
	;me guardo la mascara para seleccionar los datos que me interesan 
	movdqu xmm12, [datos_que_me_interesan]
	movdqu xmm13, [datos_que_me_interesan2]
	
	;coloco a q en todo el xmm0
	shufps xmm0, xmm0, 0
	movdqu xmm11, xmm0
	
	;en xmm11 tengo 1 + alpha
	mov ebx, 1
	movq xmm1, rbx
	shufps xmm1, xmm1, 0
	cvtdq2ps xmm1, xmm1
	addps xmm1, xmm0
	movdqu xmm11, xmm1
	;en xmm0 tengo 1 - alpha
	mov ebx, 1
	movq xmm1, rbx
	shufps xmm1, xmm1, 0
	cvtdq2ps xmm1, xmm1
	subps xmm1, xmm0
	movdqu xmm0, xmm1
	
	;limpio el 1º float
	movdqu xmm2, [datos_que_me_interesan3]
	pand xmm0, xmm2
	pand xmm11, xmm2
	
	;rdi es unflag que cuando esta en 1 estoy procesando el fin de la linea 
	;cuando me pase
	xor rdi, rdi
	
.bloque:
	;muevo 16 bytes
	xor r15, r15
	sub r15, r8
	
.cargo_datos:
	movdqu xmm1, [r12 + r15] ;xmm1 b6|r5|g5|b5|r4|g4|b4|r3|g3|b3|r2|g2|b2|r1|g1|b1
	movdqu xmm2, [r12]
	movdqu xmm3, [r12 + r8]
	cmp rdi, 0
	je .proceso_datos

.cargo_datos_si_me_pase: ;con este shift lo ue logro es acomodar los datos
	psrldq xmm1, 1
	psrldq xmm2, 1
	psrldq xmm3, 1
	
.proceso_datos:

	;calculo el maximo entre los que estan en la misma columna
	pmaxub xmm2, xmm1 
	pmaxub xmm2, xmm3 ;xmm2 b6|r5|g5|b5|r4|g4|b4|r3|g3|b3|r2|g2|b2|r1|g1|b1
		
	;calculo el maximo entre los que estan en la misma fila
	movdqu xmm1, xmm2
	movdqu xmm3, xmm2
				   ;xmm2 b6|r5|g5|b5|r4|g4|b4|r3|g3|b3|r2|g2|b2|r1|g1|b1
	psrldq xmm1, 3 ;xmm1  0| 0| 0|b6|r5|g5|b5|r4|g4|b4|r3|g3|b3|r2|g2|b2
	psrldq xmm3, 6 ;xmm3  0| 0| 0| 0| 0| 0|b6|r5|g5|b5|r4|g4|b4|r3|g3|b3
	
	pmaxub xmm2, xmm1
	pmaxub xmm2, xmm3 ;xmm2 X|X|X|X|X|X|X|r4|g4|b4|r3|g3|b3|r2|g2|b2
	
	;separo los datos segun si son R G o B 
	movdqu xmm1, xmm2
	movdqu xmm3, xmm2 ;xmm1 X|X|X|X|X| X| X|r4|g4|b4|r3|g3|b3|r2|g2|b2
	pslldq xmm2, 1    ;xmm2 X|X|X|X|X| X|r4|g4|b4|r3|g3|b3|r2|g2|b2| 0
	pslldq xmm3, 2 	  ;xmm3 X|X|X|X|X|r4|g4|b4|r3|g3|b3|r2|g2|b2| 0| 0
	;me interesan estos datos               ^^       ^^       ^^
	
	;limpio los valores que no me interesan
	pand xmm1, xmm12 ;xmm1 0|0|0|0|0|0|0|r4|0|0|r3|0|0|r2|0|0
	pand xmm2, xmm12 ;xmm2 0|0|0|0|0|0|0|g4|0|0|g3|0|0|g2|0|0
	pand xmm3, xmm12 ;xmm3 0|0|0|0|0|0|0|b4|0|0|b3|0|0|b2|0|0
	
	;los acomodo para q puedan ser usados como floats
	movdqu xmm7, [acomodo_r_g_b]
	pshufb xmm1, xmm7
	;xmm1 0|0|0|0|0|0|0|r4|0|0|0|r3|0|0|0|r2
	pshufb xmm2, xmm7
	;xmm2 0|0|0|0|0|0|0|g4|0|0|0|g3|0|0|0|g2
	pshufb xmm3, xmm7
	;xmm3 0|0|0|0|0|0|0|b4|0|0|0|b3|0|0|0|b2
	
	;creo las mascaras para φR, φG, φB
	movdqu xmm4, xmm1
	movdqu xmm5, xmm2
	movdqu xmm6, xmm3
	;φR (i, j) 
	;si maxR (i, j) ≥ maxG (i, j) y maxR (i, j) ≥ maxB (i, j)
	pcmpgtd xmm4, xmm5 ;maxR (i, j) > maxG (i, j) para los 3
	movdqu xmm7, xmm1
	pcmpeqd xmm7, xmm5 ;maxR (i, j) = maxG (i, j) para los 3
	por xmm4, xmm7    ;si maxR (i, j) ≥ maxG (i, j)
	movdqu xmm9, xmm4  ;me lo guardo para usarlo en φG (i, j) 
	
	movdqu xmm7, xmm1
	
	pcmpgtd xmm7, xmm6 ;maxR (i, j) > maxB (i, j)para los 3
	movdqu xmm10, xmm1
	pcmpeqd xmm10, xmm6 ;maxR (i, j) = maxB (i, j) para los 3
	por xmm7, xmm10   ;si maxR (i, j) ≥ maxB (i, j)
	movdqu xmm14, xmm7  ;me lo guardo para usarlo en φB (i, j)
	
	pand xmm4, xmm7    ;si maxR (i, j) ≥ maxG (i, j) y 
					   ;maxR (i, j) ≥ maxB (i, j)
					   
	;φG (i, j) 
	;si maxR (i, j) < maxG (i, j) y maxG (i, j) ≥ maxB (i, j)
	pxor xmm9, xmm15 ;si maxR (i, j) < maxG (i, j) para los 3
	
	pcmpgtd xmm5, xmm6 ;maxG (i, j) > maxB (i, j) para los 3
	movdqu xmm7, xmm2
	pcmpeqd xmm7, xmm6 ;maxG (i, j) = maxB (i, j) para los 3
	por xmm5, xmm7    ;maxG (i, j) ≥ maxB (i, j)
	movdqu xmm6, xmm5  ;me lo guardo para usarlo en φB (i, j)
	
	pand xmm5, xmm9    ;si maxR (i, j) < maxG (i, j) y 
					   ;maxG (i, j) ≥ maxB (i, j)
					   
	;φB (i, j)
	;si maxR (i, j) < maxB (i, j) y maxG (i, j) < maxB (i, j)
	pxor xmm14, xmm15 ;si maxR (i, j) < maxB (i, j) para los 3
	pxor xmm6, xmm15 ;si maxG (i, j) < maxB (i, j)para los 3
	
	pand xmm6, xmm14    ;si maxR (i, j) < maxB (i, j) y 
					    ;maxG (i, j) < maxB (i, j)
					    
	;Agrego el 1+alpha o el 1-alpha
	movdqu xmm1, xmm4
	movdqu xmm2, xmm5
	movdqu xmm3, xmm6
	
	pxor xmm1, xmm15
	pxor xmm2, xmm15
	pxor xmm3, xmm15
	
	pand xmm4, xmm11;1+alpha
	pand xmm5, xmm11;1+alpha
	pand xmm6, xmm11;1+alpha
	
	pand xmm1, xmm0;1-alpha
	pand xmm2, xmm0;1-alpha
	pand xmm3, xmm0;1-alpha
	
	por xmm1, xmm4 ;xmm1 = φR 0|1+-alpha 4|1+-alpha 3|1+-alpha 2
	por xmm2, xmm5 ;xmm2 = φG 0|1+-alpha 4|1+-alpha 3|1+-alpha 2
	por xmm3, xmm6 ;xmm3 = φB 0|1+-alpha 4|1+-alpha 3|1+-alpha 2
			
	;ya tengo los 1 +- alpha, ahora busco los datos para multiplicarlos
	movdqu xmm4, [r12]
	movdqu xmm5, xmm4
	movdqu xmm6, xmm4
	movdqu xmm9, xmm4
	;xmm4 b6|r5|g5|b5|r4|g4|b4|r3|g3|b3|r2|g2|b2|r1|g1|b1
	
	cmp rdi, 0
	je .sigo_procesando

.cargo_la_fila_si_me_pase: ;con este shift lo ue logro es acomodar los datos
	psrldq xmm4, 1
	psrldq xmm5, 1
	psrldq xmm6, 1
	
.sigo_procesando:
	psrldq xmm4, 3 ;xmm4  0| 0| 0|b6|r5|g5|b5|r4|g4|b4|r3|g3|b3|r2|g2|b2
	psrldq xmm5, 2 ;xmm5  0| 0|b6|r5|g5|b5|r4|g4|b4|r3|g3|b3|r2|g2|b2|r1
	psrldq xmm6, 1 ;xmm6  0|b6|r5|g5|b5|r4|g4|b4|r3|g3|b3|r2|g2|b2|r1|g1
	;me interesan estos datos                 ^^       ^^       ^^
	
	;limpio los valores que no me interesan
	pand xmm4, xmm12 ;xmm4 0|0|0|0|0|0|0|r4|0|0|r3|0|0|r2|0|0
	pand xmm5, xmm12 ;xmm5 0|0|0|0|0|0|0|g4|0|0|g3|0|0|g2|0|0
	pand xmm6, xmm12 ;xmm6 0|0|0|0|0|0|0|b4|0|0|b3|0|0|b2|0|0
	
	;los acomodo para q puedan ser usados como floats
	movdqu xmm7, [acomodo_r_g_b]
	pshufb xmm4, xmm7
	;xmm4 0|0|0|0|0|0|0|r4|0|0|0|r3|0|0|0|r2
	pshufb xmm5, xmm7
	;xmm5 0|0|0|0|0|0|0|g4|0|0|0|g3|0|0|0|g2
	pshufb xmm6, xmm7
	;xmm6 0|0|0|0|0|0|0|b4|0|0|0|b3|0|0|0|b2
 	
	;los paso a float
	cvtdq2ps xmm4, xmm4
	cvtdq2ps xmm5, xmm5
	cvtdq2ps xmm6, xmm6
	
	;multiplico los 1 +- alpha por los datos
	mulps xmm1, xmm4
	mulps xmm2, xmm5
	mulps xmm3, xmm6
	
	;los paso a int
	cvtps2dq xmm1, xmm1
	cvtps2dq xmm2, xmm2
	cvtps2dq xmm3, xmm3
	
	;empaqueto saturando
	packusdw xmm1, xmm8 ;xmm1 0 0|0 0|0 0|0 0|0 0|0 r4|0 r3|0 r2                       
	packuswb xmm1, xmm8 ;xmm1 0|0|0|0|0|0|0|0|0|0|0|0|0|r4|r3|r2
	packusdw xmm2, xmm8 ;xmm2 0 0|0 0|0 0|0 0|0 0|0 g4|0 g3|0 g2         
	packuswb xmm2, xmm8 ;xmm2 0|0|0|0|0|0|0|0|0|0|0|0|0|g4|g3|g2
	packusdw xmm3, xmm8 ;xmm3 0 0|0 0|0 0|0 0|0 0|0 b4|0 b3|0 b2                    
	packuswb xmm3, xmm8 ;xmm3 0|0|0|0|0|0|0|0|0|0|0|0|0|b4|b3|b2
	
	;rearmo la fila
	;xmm1 0|0|0|0|0|0|0|0|0|0|0|0|0|r4|r3|r2
	movdqu xmm7, [rearmo_fila_r]
	pshufb xmm1, xmm7
	;xmm1 0|0|0|0|r4|0|0|r3|0|0|r2|0|0|0|0|0
	
	;xmm2 0|0|0|0|0|0|0|0|0|0|0|0|0|g4|g3|g2
	movdqu xmm7, [rearmo_fila_g]
	pshufb xmm2, xmm7
	;xmm2 0|0|0|0|0|g4|0|0|g3|0|0|g2|0|0|0|0
	
	;xmm3 0|0|0|0|0|0|0|0|0|0|0|0|0|b4|b3|b2
	movdqu xmm7, [rearmo_fila_b]
	pshufb xmm3, xmm7
	;xmm3 0|0|0|0|0|0|b4|0|0|b3|0|0|b2|0|0|0
	
	por xmm1, xmm2
	por xmm1, xmm3
	;xmm1 0|0|0|0|r4|g4|b4|r3|g3|b3|r2|g2|b2|0|0|0

	cmp rdi, 0
	je .guardo_los_datos

.guardo_los_datos_si_me_pase: ;con este shift lo ue logro es acomodar los datos
	pslldq xmm1, 1
	
	;me cargo los datos que estaban en la imagen de salida para solo cargar 
	;lo que modifique
	movdqu xmm7, [r13]
	
	;aplico un filtro para q solo cambien los valores que modifique
	movdqu xmm9, [mascara_caso_borde]
	pand xmm7, xmm9 ;me quedo con los datos que estan en la salida salvo
	;los que modifique
	
	pxor xmm9, xmm15
	pand xmm1, xmm9 ;me quedo con los datos que modifique
	
	por xmm1, xmm7
	
	jmp .escribo_en_memoria
	
.guardo_los_datos:

	movdqu xmm7, [limpio_el_medio_y_fin]
	pand xmm9, xmm7

	por xmm1, xmm9
	;xmm1 b6|r5|g5|b5|r4|g4|b4|r3|g3|b3|r2|g2|b2|0|0|0
	
	;coloco el pixel que ya habia procesado
	movdqu xmm9, [r13]
	movdqu xmm7, [limpio_el_medio_y_comienzo]
	pand xmm9, xmm7
	
	por xmm1, xmm9
	;xmm1 b6|r5|g5|b5|r4|g4|b4|r3|g3|b3|r2|g2|b2|r1|g1|b1
	
.escribo_en_memoria:
	movdqu [r13], xmm1
	
	;ya procese el xmm ahora veo como tengo que seguir
	;muevo los punteros y decremento la posicion del arreglo en donde estoy
	add r12, cant_de_datos
	add r13, cant_de_datos
	sub r14, cant_de_datos
	;si r14 es negativo significa que me pase y q me faltan procesar datos
	;pero la cantidad de los mismos es menor a 16
	js .me_pase
	
	cmp r14, 0
	je .me_pase
	
	jmp .bloque
		
.me_pase:
	;como me faltan procesar datos, le sumo a los punteros el r14 que me indica cualtos
	;dats tengo que retroceder para que entren en un bloque de 16. Seteo r14 en 16 para 
	;que haga un ciclo mas y despues entre a paso_a_la_fila_de_abajo ya que la cuenta va a dar 0
	cmp r14, r10
	je .paso_a_la_fila_de_abajo
		
	add r12, r14
	add r13, r14
	xor r14, r14
	add rdi, 1
	jmp .bloque
	
.paso_a_la_fila_de_abajo:
	xor rdi, rdi
	;decremento en 1 la cantidad de filas y me fijo si tengo mas filas que procesar
	sub edx, 1
	cmp edx, 0
	je .fin
	;muevo los punteros al comienzo y le sumo el row_size
	add r12, 7
	add r13, 7
	sub r12, rcx
	sub r13, rcx
	add r12, r8
	add r13, r9
	;Recargo r14
	mov r14, rcx
	sub r14, 16
	jmp .bloque

.fin:
	sub rsp, 8
	pop r12
	pop r13
	pop r14
	pop r15
	pop rbx
	pop rbp
	ret


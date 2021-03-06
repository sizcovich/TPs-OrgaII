; ** por compatibilidad se omiten tildes **
; ==============================================================================
; TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
; ==============================================================================
; definicion de rutinas de atencion de interrupciones

%include "imprimir.mac"

BITS 32

TAREA_QUANTUM: dd 2

global _isr32
global _isr33
global _isr128
global _isr144

extern pausa
;; PIC
extern fin_intr_pic1

;;
;; SCHEDULER
extern sched_proximo_indice
extern sched_remover_tarea
extern get_actual
extern obtener
extern reloj_tarea
extern avanzar_tarea

;;
;;JUEGO
extern juego_finalizo
extern game_terminar
extern game_iniciar
extern game_migrar
extern game_duplicar
extern juego_iniciado
;;
;; Definición de MACROS
;;

%macro error 2
error%1: db "Interrupcion ",%2
error%1_len equ $ - error%1
%endmacro

%macro ISR 1
global _isr%1

_isr%1:
	str eax
	shr eax, 3
	sub eax, 10
	push eax
	call sched_remover_tarea
	add esp, 4
	call get_actual
	cmp eax, 0
	jne .tarea2
	imprimir_texto_mp	error%1, error%1_len, 0x0F, 19, 4
	jmp .fin
	
	.tarea2:
	cmp eax, 1
	jne .tarea3
	imprimir_texto_mp	error%1, error%1_len, 0x0F, 20, 4
	jmp .fin
	
	.tarea3:
	cmp eax, 2
	jne .tarea4
	imprimir_texto_mp	error%1, error%1_len, 0x0F, 21, 4
	jmp .fin
	
	.tarea4:
	cmp eax, 3
	jne .arbitro
	imprimir_texto_mp	error%1, error%1_len, 0x0F, 22, 4
	jmp .fin
	
	.arbitro:
	imprimir_texto_mp	error%1, error%1_len, 0x0F, 23, 4
	jmp .fin
	
	.fin:
	mov dword[TAREA_QUANTUM], 0
	iret
%endmacro

%macro ISR_CODED 1
global _isr%1

_isr%1:
	add esp, 4
	str eax
	shr eax, 3
	sub eax, 10
	push eax
	call sched_remover_tarea
	add esp, 4
	call get_actual
	cmp eax, 0
	jne .tarea2
	imprimir_texto_mp	error%1, error%1_len, 0x0F, 19, 4
	jmp .fin
	
	.tarea2:
	cmp eax, 1
	jne .tarea3
	imprimir_texto_mp	error%1, error%1_len, 0x0F, 20, 4
	jmp .fin
	
	.tarea3:
	cmp eax, 2
	jne .tarea4
	imprimir_texto_mp	error%1, error%1_len, 0x0F, 21, 4
	jmp .fin
	
	.tarea4:
	cmp eax, 3
	jne .arbitro
	imprimir_texto_mp	error%1, error%1_len, 0x0F, 22, 4
	jmp .fin
	
	.arbitro:
	imprimir_texto_mp	error%1, error%1_len, 0x0F, 23, 4
	jmp .fin
	
	.fin:
	mov dword[TAREA_QUANTUM], 0
	iret
%endmacro

;;
;; Datos
;;
offset: dd 0
selector: dw 0
; Scheduler
reloj_numero:		 	dd 0x00000000
reloj:  				db '|/-\'

;;mensaje excepción genérico
mensaje: db 'Excepcion numero ', 0
numero: db 48, 0

;; Rutina de atención de las EXCEPCIONES
;;
error 0, "0: Divide error"
error 1, "1: Reserved"
error 2, "2: NMI Interrupt"
error 3, "3: Breakpoint"
error 4, "4: Overflow"
error 5, "5: Bound Range Exceeded"
error 6, "6: Invalid Opcode"
error 7, "7: Device Not Available"
error 8, "8: Double Fault"
error 9, "9: Coprocessor Segment Overrun"
error 10, "10: Invalid TSS"
error 11, "11: Segment Not Present"
error 12, "12: Stack Segment Fault"
error 13, "13: General Protection"
error 14, "14: Page Fault"
error 15, "15"
error 16, "16: x87 FPU Floating Point Error"
error 17, "17: Alignment Check"
error 18, "18: Machine Check"
error 19, "19: SIMD Floating Point Exception"
ISR 0
ISR 1
ISR 2
ISR 3
ISR 4
ISR 5
ISR 6
ISR 7
ISR 8
ISR 9
ISR_CODED 10
ISR_CODED 11
ISR_CODED 12
ISR_CODED 13
ISR 15
ISR 16
ISR 17
ISR 18
ISR 19


;;
;; Rutina de atencion del PF
;;
global _isr14

_isr14:
	;#PF
	add esp, 4 ;descarto el error code
	call get_actual
	push eax
	mov eax, cr2 ;tengo la direccion lineal en cr2
	push eax
	call obtener
	add esp, 8
	cmp eax, 0 ; significa que mapeo bien
	je .fin
	;CASO EN EL QUE FALLA
.falla:
	str eax
	shr eax, 3 
	sub eax, 10 ;calculo indice a remover
	push eax
	call sched_remover_tarea
	add esp, 4
	call get_actual
	cmp eax, 0
	jne .tarea2
	imprimir_texto_mp	error14, error14_len, 0x0F, 19, 4
	jmp .borrar
	
	.tarea2:
	cmp eax, 0
	jne .tarea3
	imprimir_texto_mp	error14, error14_len, 0x0F, 20, 4
	jmp .borrar
	
	.tarea3:
	cmp eax, 0
	jne .tarea4
	imprimir_texto_mp	error14, error14_len, 0x0F, 21, 4
	jmp .borrar
	
	.tarea4:
	cmp eax, 0
	jne .arbitro
	imprimir_texto_mp	error14, error14_len, 0x0F, 22, 4
	jmp .borrar
	
	.arbitro:
	imprimir_texto_mp	error14, error14_len, 0x0F, 23, 4
	jmp .borrar
	
	.borrar:
	mov dword[TAREA_QUANTUM], 0
	
.fin:
	iret

;;
;; Rutina de atención del RELOJ
;; 32
_isr32:
	cli
	pushad
	call fin_intr_pic1
	
	call juego_finalizo
	cmp eax, 1
	je .finalizo
	
	cmp byte [pausa], 1
	je .pausado

	call proximo_reloj
	call reloj_tarea
	
	cmp dword[TAREA_QUANTUM], 0
	je .siguienteTarea
	
	dec dword[TAREA_QUANTUM]
	jmp .fin
	
	.finalizo:
		str eax
		cmp ax, 0x48
		je .fin

		mov word[selector], 0x48
		jmp far [offset]
		jmp .fin
	
	.siguienteTarea:
		add dword[TAREA_QUANTUM], 2
		call juego_iniciado
		cmp eax, 0
		je .arbitro

		call sched_proximo_indice
		mov [selector], ax
		jmp far [offset]
		jmp .fin

	.pausado:
		str eax
		cmp ax, 0x48
		je .fin
		
		mov word [selector], 0x48
		jmp far [offset]
		jmp .fin

	.arbitro:
		mov word[selector], 0x70
		jmp far [offset]

	.fin:
	popad
	sti
	iret
;;
;; Rutina de atención del TECLADO
;; 33
_isr33:
	cli
	pushad
	call fin_intr_pic1
	in al, 0x60
	cmp al, 0x99 ;ver si se pulso p
	je .P
	
	cmp al, 0x93 ;ver si se pulso r
	je .R
	jmp .fin
	
	.R:
	mov byte[pausa], 0
	jmp .fin
	
	.P:
	mov byte[pausa], 1
	jmp .fin
	
	.fin:
	popad
	sti
	iret


;;
;; Rutinas de atención de las SYSCALLS
;;
_isr128:	;Interrupcion 0x80
	cli
	pushad
		
	cmp eax, 111	;duplicar
	je .duplicar
	cmp eax, 222	;migrar
	je .migrar
	mov eax, 0
	jmp .fin
	
	.duplicar:
	push ecx
	push ebx
	call get_actual
	inc eax
	push eax
	call game_duplicar
	add esp, 12
	jmp .llamoArbitro
	;cmp eax, 0 ;pregunto si salio bien
	;je .fin
	;jmp .llamoArbitro
	
	.migrar:
	push esi
	push edx
	push ecx
	push ebx
	call get_actual
	inc eax
	push eax
	call game_migrar
	add esp, 20
	;cmp eax, 0
	;je .fin

.llamoArbitro:
	call reloj_tarea
	mov dword[TAREA_QUANTUM], 2
	mov word[selector], 0x70
	jmp far [offset]
	
	
.fin:
	call fin_intr_pic1
	popad
	sti
	iret

	
_isr144: ;Int 0x90
	cli
	pushad
	
	cmp eax, 200	;iniciar
	je .iniciar
	cmp eax, 300	;terminar
	je .terminar
	mov eax, 0
	jmp .fin
	
	.iniciar:
	call game_iniciar
	jmp .fin
	
	.terminar:
	call game_terminar
	jmp .fin
	
	.fin:
	call fin_intr_pic1
	popad
	sti
	iret

proximo_reloj:
	pushad
	inc DWORD [reloj_numero]
	mov ebx, [reloj_numero]
	cmp ebx, 0x4
	jl .ok
		mov DWORD [reloj_numero], 0x0
		mov ebx, 0
	.ok:
		add ebx, reloj
		imprimir_texto_mp ebx, 1, 0x0f, 24, 79

	popad
	ret

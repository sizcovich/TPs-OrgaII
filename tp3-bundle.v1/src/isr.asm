; ** por compatibilidad se omiten tildes **
; ==============================================================================
; TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
; ==============================================================================
; definicion de rutinas de atencion de interrupciones

%include "imprimir.mac"

BITS 32

%define TAREA_QUANTUM		2

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
extern get_actual

;;
;;JUEGO
extern juego_finalizo
extern game_terminar
extern game_iniciar
extern game_migrar
extern game_duplicar
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
	mov eax, %1
	push ebx
	mov bx, es
	
	mov ecx, 4000
	mov ax, 0x38
	mov es, ax
	mov ax, 0x0F00
	.escribeTodo:
		mov [es:ecx], ax
		dec ecx
	loop .escribeTodo
	mov [es:ecx], ax
	mov es, bx
	pop ebx
	imprimir_texto_mp	error%1, error%1_len, 0xF, 0, 0
	jmp $
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
ISR 10
ISR 11
ISR 12
ISR 13
ISR 14
ISR 15
ISR 16
ISR 17
ISR 18
ISR 19


;;
;; Rutina de atención del RELOJ
;; 32
_isr32:
	cli
	pushad
	pushfd
	call juego_finalizo
	cmp eax, 1
	je .finalizo
	
	call fin_intr_pic1
	call proximo_reloj
	
	cmp byte[TAREA_QUANTUM], 0
	je .siguienteTarea
	
	dec byte[TAREA_QUANTUM]
	jmp .fin
	
	.finalizo:
	mov word[selector], 0x48
	jmp far [offset]
	jmp .fin
	
	.siguienteTarea:
	add byte[TAREA_QUANTUM], 2
	call sched_proximo_indice
	mov [selector], ax
	jmp far [offset]

	.fin:
	popfd
	popad
	sti
	iret
;;
;; Rutina de atención del TECLADO
;; 33
_isr33:
	cli
	pushad
	pushfd
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
	popfd
	popad
	sti
	iret


;;
;; Rutinas de atención de las SYSCALLS
;;
_isr128:	;Interrupcion 0x80
	cli
	pushad
	pushfd
	call fin_intr_pic1
	
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
	push eax
	call game_duplicar
	sub esp, 12
	jmp .fin
	
	.migrar:
	push esi
	push edx
	push ecx
	push ebx
	call get_actual
	push eax
	call game_migrar
	sub esp, 20
	jmp .fin
	
	.fin:
	popfd
	popad
	sti
	iret
	
_isr144: ;Int 0x90
	cli
	pushad
	pushfd
	call fin_intr_pic1
	
	cmp eax, 300	;iniciar
	je .iniciar
	cmp eax, 200	;terminar
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
	popfd
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

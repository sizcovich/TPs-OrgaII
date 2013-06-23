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
;_isr%1:
;
;	mov al, 10 
;	add byte [numero], %1
;	imprimir_texto_mp mensaje, 17, 0x0F, 1, 1
;	cmp al, %1
;	jge .ponerDos 
;	imprimir_texto_mp numero, 1, 0x0F, 1, 18 
;	jmp .seguir
;.ponerDos:
;	imprimir_texto_mp numero, 2, 0x0F, 1, 18
;.seguir:
;	sub byte [numero], %1
;	jmp $

%endmacro

;;
;; Datos
;;
; Scheduler
reloj_numero:		 	dd 0x00000000
reloj:  				db '|/-\'

;;mensaje excepción genérico
mensaje: db 'Excepcion numero ', 0
numero: db 48, 0

;; Rutina de atención de las EXCEPCIONES
;;
error 0, "0"
error 1, "1"
error 2, "2"
error 3, "3"
error 4, "4"
error 5, "5"
error 6, "6"
error 7, "7"
error 8, "8"
error 9, "9"
error 10, "10"
error 11, "11"
error 12, "12"
error 13, "13"
error 14, "14"
error 15, "15"
error 16, "16"
error 17, "17"
error 18, "18"
error 19, "19"
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
	call fin_intr_pic1
	call proximo_reloj	
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
	push ebx
	push ecx
	pop ecx
	pop ebx
	
	.migrar:
	push ebx
	push ecx
	push edx
	push esi
	pop esi
	pop edx
	pop ecx
	pop ebx
	
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
	
	.terminar:
	
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

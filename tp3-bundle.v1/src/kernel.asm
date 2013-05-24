; ** por compatibilidad se omiten tildes **
; ==============================================================================
; TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
; ==============================================================================

%include "imprimir.mac"

global start


;; GDT
extern GDT_DESC

;; IDT
extern IDT_DESC
extern idt_inicializar

;; PIC
extern resetear_pic
extern habilitar_pic


;; Saltear seccion de datos
jmp start

;;
;; Seccion de datos.
;;
iniciando_mr_msg db		'Iniciando kernel (Modo Real)...'
iniciando_mr_len equ	$ - iniciando_mr_msg

iniciando_mp_msg db		'Iniciando kernel (Modo Protegido)...'
iniciando_mp_len equ	$ - iniciando_mp_msg

;;
;; Seccion de código.
;;

;; Punto de entrada del kernel.
BITS 16
start:
	; Deshabilitar interrupciones
	cli

	; Imprimir mensaje de bienvenida
	imprimir_texto_mr iniciando_mr_msg, iniciando_mr_len, 0x07, 0, 0

	xchg bx, bx


	; habilitar A20

	; dehsabilitar las interrupciones

	; cargar la GDT

	; setear el bit PE del registro CR0

	; pasar a modo protegido

	; acomodar los segmentos

	; seteo la pila

	; pintar pantalla, todos los colores, que bonito!

	; inicializar el manejador de memoria

	; inicializar el directorio de paginas

	; inicializar memoria de tareas

	; habilitar paginacion

	; inicializar tarea idle

	; inicializar todas las tsss

	; inicializar entradas de la gdt de tss

	; inicializar el scheduler

	; inicializar la IDT

	; configurar controlador de interrupciones

	; cargo la primer tarea null

	; aca salto a la primer tarea

	; Ciclar infinitamente (por si algo sale mal)
	jmp $

%include "a20.asm"

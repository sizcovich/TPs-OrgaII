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

;; MMU
extern mmu_inicializar

;; Saltear seccion de datos
jmp start

;;
;; Seccion de datos.
;;
iniciando_mr_msg db		'Iniciando kernel (Modo Real)...'
iniciando_mr_len equ	$ - iniciando_mr_msg

iniciando_mp_msg db		'Iniciando kernel (Modo Protegido)...'
iniciando_mp_len equ	$ - iniciando_mp_msg

nombre_grupo_msg db 'Grupo: Napolitana con jamon y morrones'
nombre_grupo_len equ	$ -nombre_grupo_msg

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

	;xchg bx, bx

	; habilitar A20
	call deshabilitar_A20
	call checkear_A20 ;muestra por pantalla que esta deshabilitada
	call habilitar_A20
	
	xchg bx, bx
	
	; cargar la GDT
	lgdt [GDT_DESC]

	; setear el bit PE del registro CR0
	mov eax, cr0
	or eax, 1
	mov cr0, eax
	; pasar a modo protegido
	jmp 0x8:modoprotegido
BITS 32

modoprotegido:
	; seteo la pila
	mov ax, 0x10
	mov ss, ax;GDT_IDX_DATA0_DESC|TI|RPL 0|0
	mov ds, ax       ; data segment
	mov es, ax
	mov gs, ax

	mov ebp, 0x20000
	mov esp, 0x20000

	; pintar pantalla, todos los colores, que bonito!
limpiarPantalla:
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

	; inicializar el manejador de memoria

	; inicializar el directorio de paginas
	call mmu_inicializar
	xchg bx, bx

	; inicializar memoria de tareas

	; habilitar paginacion
		mov eax, 0x00021000		;cargo la direccion del directorio en cr3
		mov cr3, eax
		mov eax, cr0				
		or  eax, 0x80000000		;habilito paginacion
		mov cr0, eax
		xchg bx, bx
		imprimir_texto_mp nombre_grupo_msg, nombre_grupo_len, 0x07, 0, 0
		
		;copiar las tareas
		mov eax, 0x00011000 ;De donde copiar las tareas
		mov ebx, 0x00101000 ;A donde copiar las tareas
		mov ecx, 5120 ;Copio 5*1024 dw
.copiarTarea:
		mov esi, [eax]
		mov [ebx], esi
		add eax, 4
		add ebx, 4
		loop .copiarTarea
	; inicializar tarea idle

	; inicializar todas las tsss

	; inicializar entradas de la gdt de tss

	; inicializar el scheduler

	; inicializar la IDT
	call idt_inicializar

	lidt [IDT_DESC]
	
	mov eax, 0x00030000
	mov cr3, eax
	imprimir_texto_mp nombre_grupo_msg, nombre_grupo_len, 0x57, 0, 0
	mov eax, 0x00021000
	mov cr3, eax
	
	xchg bx, bx

;para probar la interrupcion
	;xor edx, edx
	;xor eax, eax
	;xor ecx, ecx
	;div ecx

	; configurar controlador de interrupciones

	; cargo la primer tarea null

	; aca salto a la primer tarea

	; Ciclar infinitamente (por si algo sale mal)
	jmp $

%include "a20.asm"

/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

	Definiciones globales del sistema.
*/

#ifndef __DEFINES_H__
#define __DEFINES_H__

/*
NOTA:
	* TASK_1 = Tarea Jugador 1
	* TASK_2 = Tarea Jugador 2
	* TASK_3 = Tarea Jugador 3
	* TASK_4 = Tarea Jugador 4
	* TASK_5 = Tarea Arbitro
*/

/* VALORES PARA IMPRIMIR */
//#define NULL_CHAR	0x00
//#define WRITECHAR	0x00
//#define COLORES	0x00
//#define FILA		0x00
//#define COLUMNA	0x00

/* TAREAS */
#define CANT_TAREAS   			5

/* INDICES EN LA GDT */
#define GDT_IDX_NULL_DESC		0
#define GDT_IDX_CODE0_DESC		1
#define GDT_IDX_DATA0_DESC		2
#define GDT_IDX_CODE2_DESC		3
#define GDT_IDX_DATA2_DESC		4
#define GDT_IDX_CODE3_DESC		5
#define GDT_IDX_DATA3_DESC		6
#define GDT_IDX_AREA_DESC		7
#define GDT_TSS_INICIAL			8
#define GDT_TSS_IDLE			9
#define GDT_TSS_TAREA1			10
#define GDT_TSS_TAREA2			11
#define GDT_TSS_TAREA3			12
#define GDT_TSS_TAREA4			13
#define GDT_TSS_ARBITRO			14

/* DIRECCIONES VIRTUALES DE CÓDIGO, PILA y DATOS */
#define TASK_CODE    			0x003A0000 /* direccion virtual codigo */
#define TASK_STACK   			0x003B0000 /* direccion virtual stack  */

#define TABLERO_ADDR 			0x003C0000 /* direccion virtual del tablero */
#define VIDEO_ADDR 			0x000B8000 /* direccion virtual de la memoria de video */

/* MISC */
#define TAMANO_PAGINA 			0x00001000


/* DIRECCIONES DE MEMORIA */
#define BOOTSECTOR    			0x00001000 /* direccion fisica de comienzo del bootsector (copiado) */
#define KERNEL        			0x00001200 /* direccion fisica de comienzo del kernel */
#define VIDEO         			0x000B8000 /* direccion fisica del buffer de video */
#define TABLERO_ADDR_PA			0x00100000 /* dirección física del tablero */

/* DIRECCIONES FISICAS DE CODIGOS Y PILAS DE LAS TAREAS */
#define TASK_1_CODE_PA			0x00101000	/* Direccion fisica del codigo la tarea 1 */
#define TASK_2_CODE_PA			0x00102000	/* Direccion fisica del codigo la tarea 2 */
#define TASK_3_CODE_PA			0x00103000	/* Direccion fisica del codigo la tarea 3 */
#define TASK_4_CODE_PA			0x00104000	/* Direccion fisica del codigo la tarea 4 */
#define TASK_5_CODE_PA			0x00105000	/* Direccion fisica del codigo la tarea 5 */

#define TASK_1_STACK_PA 		0x00115000	/* Direccion fisica de la pila la tarea 1 */
#define TASK_2_STACK_PA 		0x00116000	/* Direccion fisica de la pila la tarea 2 */
#define TASK_3_STACK_PA 		0x00117000	/* Direccion fisica de la pila la tarea 3 */
#define TASK_4_STACK_PA 		0x00118000	/* Direccion fisica de la pila la tarea 4 */
#define TASK_5_STACK_PA 		0x00119000	/* Direccion fisica de la pila la tarea 5 */

/* DIRECCIONES FISICAS DE CODIGOS */
/*
	En estas direcciones estan los códigos de todas las tareas. De aqui se
	copiaran al destino indicado por TASK_<i>_CODE_ADDR.
*/
#define TASK_IDLE_CODE_SRC_ADDR 0x00010000 /* direccion fisica del codigo de la tarea idle */
#define TASK_1_CODE_SRC_ADDR    0x00011000 /* direccion fisica del codigo de la tarea tarea 1 */
#define TASK_2_CODE_SRC_ADDR    0x00012000 /* direccion fisica del codigo de la tarea tarea 2 */
#define TASK_3_CODE_SRC_ADDR    0x00013000 /* direccion fisica del codigo de la tarea tarea 3 */
#define TASK_4_CODE_SRC_ADDR    0x00014000 /* direccion fisica del codigo de la tarea tarea 4 */
#define TASK_5_CODE_SRC_ADDR 	0x00015000 /* direccion fisica del codigo de la tarea tarea 5 */

/* DIRECCIONES FISICAS DE PILAS */
#define KERNEL_STACK   			0x00020000 /* direccion fisica para el stack del kernel */

#define TASK_1_STACK_RING_0 	0x0003A000 /* direccion fisica para la pila de nivel 0 de la tarea 1 */
#define TASK_2_STACK_RING_0 	0x0003B000 /* direccion fisica para la pila de nivel 0 de la tarea 2 */
#define TASK_3_STACK_RING_0 	0x0003C000 /* direccion fisica para la pila de nivel 0 de la tarea 3 */
#define TASK_4_STACK_RING_0 	0x0003D000 /* direccion fisica para la pila de nivel 0 de la tarea 4 */
#define TASK_5_STACK_RING_0 	0x0003E000 /* direccion fisica para la pila de nivel 0 de la tarea 5 */
#define TASK_IDLE_STACK_RING_0	0x0003F000 /* direccion fisica para la pila de la tarea idle */

/* DIRECCIONES FISICAS DE DIRECTORIOS Y TABLAS DE PAGINAS */
#define KERNEL_PAGE_DIR			0x00021000 /* direccion fisica para el directorio de paginas del kernel */
#define KERNEL_PAGE_TABLE		0x00022000 /* direccion fisica para la tabla de paginas del kernel */

#define TASK_1_PAGE_DIR 		0x00030000 /* direccion fisica para el directorio de paginas de la tarea 1 */
#define TASK_2_PAGE_DIR 		0x00031000 /* direccion fisica para el directorio de paginas de la tarea 2 */
#define TASK_3_PAGE_DIR 		0x00032000 /* direccion fisica para el directorio de paginas de la tarea 3 */
#define TASK_4_PAGE_DIR 		0x00033000 /* direccion fisica para el directorio de paginas de la tarea 4 */
#define TASK_5_PAGE_DIR 		0x00034000 /* direccion fisica para el directorio de paginas de la tarea 5 */

#define TASK_1_PAGE_TABLE		0x00035000 /* direccion fisica para la tabla de paginas de la tarea 1 */
#define TASK_2_PAGE_TABLE		0x00036000 /* direccion fisica para la tabla de paginas de la tarea 2 */
#define TASK_3_PAGE_TABLE		0x00037000 /* direccion fisica para la tabla de paginas de la tarea 3 */
#define TASK_4_PAGE_TABLE		0x00038000 /* direccion fisica para la tabla de paginas de la tarea 4 */
#define TASK_5_PAGE_TABLE		0x00039000 /* direccion fisica para la tabla de paginas de la tarea 5 */


/* BOOL */
#define TRUE					0x00000001
#define FALSE					0x00000000

#endif	/* !__DEFINES_H__ */

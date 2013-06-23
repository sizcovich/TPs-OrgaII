/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
  definicion de estructuras para administrar tareas
*/

#include "defines.h"
#include "gdt.h"
#include "tss.h"
#include "i386.h"

tss tarea_inicial;
tss tarea_idle;
tss tarea_dibujar;

tss tsss[CANT_TAREAS];

void tss_inicializar() {
	//Tarea idle
	tarea_idle.cr3 = KERNEL_PAGE_DIR;
	tarea_idle.eip = TASK_CODE;
	tarea_idle.esp = TASK_IDLE_STACK_RING_0;
	tarea_idle.ebp = TASK_IDLE_STACK_RING_0;
	tarea_idle.iomap = 0xFFFF;
	tarea_idle.eflags = 0x202;
	tarea_idle.cs = 0x8;
	tarea_idle.ds = 0x10;
	tarea_idle.es = 0x10;
	tarea_idle.fs = 0x10;
	tarea_idle.gs = 0x10;
	tarea_idle.ss = 0x10;
	tarea_idle.ss0 = 0x10;
	
	//Tarea 1
	tsss[1].cr3 = TASK_1_PAGE_DIR;
	tsss[1].eip = TASK_CODE;
	tsss[1].esp = TASK_STACK;
	tsss[1].ebp = TASK_STACK;
	tsss[1].iomap = 0xFFFF;
	tsss[1].eflags = 0x202;
	tsss[1].cs = 0x2B;
	tsss[1].ds = 0x33;
	tsss[1].es = 0x33;
	tsss[1].fs = 0x33;
	tsss[1].gs = 0x33;
	tsss[1].ss = 0x33;
	tsss[1].ss0 = 0x10;
	tsss[1].esp0 = TASK_1_STACK_RING_0;
	
	//Tarea 2
	tsss[2].cr3 = TASK_2_PAGE_DIR;
	tsss[2].eip = TASK_CODE;
	tsss[2].esp = TASK_STACK;
	tsss[2].ebp = TASK_STACK;
	tsss[2].iomap = 0xFFFF;
	tsss[2].eflags = 0x202;
	tsss[2].cs = 0x2B;
	tsss[2].ds = 0x33;
	tsss[2].es = 0x33;
	tsss[2].fs = 0x33;
	tsss[2].gs = 0x33;
	tsss[2].ss = 0x33;
	tsss[2].ss0 = 0x10;
	tsss[2].esp0 = TASK_2_STACK_RING_0;
	
	//Tarea 3
	tsss[3].cr3 = TASK_3_PAGE_DIR;
	tsss[3].eip = TASK_CODE;
	tsss[3].esp = TASK_STACK;
	tsss[3].ebp = TASK_STACK;
	tsss[3].iomap = 0xFFFF;
	tsss[3].eflags = 0x202;
	tsss[3].cs = 0x2B;
	tsss[3].ds = 0x33;
	tsss[3].es = 0x33;
	tsss[3].fs = 0x33;
	tsss[3].gs = 0x33;
	tsss[3].ss = 0x33;
	tsss[3].ss0 = 0x10;
	tsss[3].esp0 = TASK_3_STACK_RING_0;
	
	//Tarea 4
	tsss[4].cr3 = TASK_4_PAGE_DIR;
	tsss[4].eip = TASK_CODE;
	tsss[4].esp = TASK_STACK;
	tsss[4].ebp = TASK_STACK;
	tsss[4].iomap = 0xFFFF;
	tsss[4].eflags = 0x202;
	tsss[4].cs = 0x2B;
	tsss[4].ds = 0x33;
	tsss[4].es = 0x33;
	tsss[4].fs = 0x33;
	tsss[4].gs = 0x33;
	tsss[4].ss = 0x33;
	tsss[4].ss0 = 0x10;
	tsss[4].esp0 = TASK_4_STACK_RING_0;
	
	//Arbitro
	tsss[5].cr3 = TASK_5_PAGE_DIR;
	tsss[5].eip = TASK_CODE;
	tsss[5].esp = TASK_STACK;
	tsss[5].ebp = TASK_STACK;
	tsss[5].iomap = 0xFFFF;
	tsss[5].eflags = 0x202;
	tsss[5].cs = 0x1A;
	tsss[5].ds = 0x22;
	tsss[5].es = 0x22;
	tsss[5].fs = 0x22;
	tsss[5].gs = 0x22;
	tsss[5].ss = 0x22;
	tsss[5].ss0 = 0x10;
	tsss[5].esp0 = TASK_5_STACK_RING_0;
}

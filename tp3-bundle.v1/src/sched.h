/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
  definicion de funciones del scheduler
*/

#ifndef __SCHED_H__
#define __SCHED_H__

#include "tss.h"
#include "gdt.h"
#include "mmu.h"
#include "i386.h"


extern unsigned short tareas[CANT_TAREAS];

void sched_inicializar();
unsigned short sched_proximo_indice();
void sched_remover_tarea(unsigned int process_id);
char get_actual();

#endif	/* !__SCHED_H__ */

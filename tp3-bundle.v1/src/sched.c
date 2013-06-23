/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
  definicion de funciones del scheduler
*/
#include "defines.h"
#include "screen.h"
#include "sched.h"

unsigned short tareas[CANT_TAREAS];
char indice_actual;

void sched_inicializar() {
	tareas[0] = 0x50;
	tareas[1] = 0x58;
	tareas[2] = 0x60;
	tareas[3] = 0x68;
	tareas[4] = 0x70;
	indice_actual = 0;
}

unsigned short sched_proximo_indice() {
	unsigned int indice = indice_actual;
	while (tareas[(indice+1) % 5] == 0) {
		indice = (indice + 1) % 5;
	}
	return tareas[indice];
}

void sched_remover_tarea(unsigned int process_id) {
	tareas[process_id] = 0x0;
}

char get_actual() {
	return indice_actual;
}

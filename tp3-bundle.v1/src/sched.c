/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
  definicion de funciones del scheduler
*/
#include "defines.h"
#include "screen.h"
#include "sched.h"
#include "i386.h"

unsigned short tareas[CANT_TAREAS];
char indice_actual;

void sched_inicializar() {
	tareas[0] = 0x50;
	tareas[1] = 0x58;
	tareas[2] = 0x60;
	tareas[3] = 0x68;
	tareas[4] = 0x70;
	indice_actual = 4;
}

unsigned short sched_proximo_indice() {
	if(rtr() != (GDT_TSS_ARBITRO<<3)){
		return (GDT_TSS_ARBITRO<<3);
	}
	else{
		unsigned int indice = (indice_actual + 1) % 4;
		unsigned int j = 0;
		while (tareas[indice] == 0x0 && j < 4) {
			indice = ((indice + 1) % 4);
			++j;
		}
		if (j >= 4) {
			indice_actual = 4;
			return 5;
		}
		indice_actual = indice;
		return tareas[indice];
	}
}

void sched_remover_tarea(unsigned int process_id) {
	tareas[process_id] = 0x0;
}

char get_actual() {
	return indice_actual;
}

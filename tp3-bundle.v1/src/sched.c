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

unsigned char reloj[4] = {'|', '/', '-', '\\'};
unsigned int relojes[5] = {0,0,0,0,0};

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
		return 0x70;
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
			return 0x70;
		}
		indice_actual = indice;
		return tareas[indice];
	}
}

void sched_remover_tarea(unsigned int process_id) {
	tareas[process_id] = 0x0;
}

char get_actual() {
	unsigned short segSel = rtr();
	char res;
	switch (segSel) {
		case 0x50:
			res = 0;
			break;
		case 0x58:
			res = 1;
			break;
		case 0x60:
			res = 2;
			break;
		case 0x68:
			res = 3;
			break;
		case 0x70:
			res = 4;
			break;
		default:
			res = 5;
			break;
	}
	return res;
}

void reloj_tarea() {
	unsigned short *video = (unsigned short *)VIDEO_ADDR;
	
	int actual = get_actual();
	
	switch (actual) {
		case 0:
			video[19*80] = reloj[relojes[actual]] + 0x0F00;
			++relojes[actual];
			break;
		case 1:
			video[20*80] = reloj[relojes[actual]] + 0x0F00;
			++relojes[actual];
			break;
		case 2:
			video[21*80] = reloj[relojes[actual]] + 0x0F00;
			++relojes[actual];
			break;
		case 3:
			video[22*80] = reloj[relojes[actual]] + 0x0F00;
			++relojes[actual];
			break;
		case 4:
			video[23*80] = reloj[relojes[actual]] + 0x0F00;
			++relojes[actual];
			break;
	}
	if (relojes[actual] == 4) {
		relojes[actual] = 0;
	}
}

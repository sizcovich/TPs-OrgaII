/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
*/

#include "defines.h"
#include "game.h"
#include "syscall.h"
#include "screen.h"
#include "i386.h"

char init = 0;
int puntJugadores[4] = {0,0,0,0};

void print(const char* str, unsigned int fil, unsigned int col, unsigned short attr);

void imprimir_tablero(unsigned char * tablero);
void imprimir_puntaje(int * puntajes);
void imprimir_ganador(int * puntajes);
int  juego_terminado(unsigned char * tablero);
void actualizar_pantalla(unsigned char * tablero, int * puntajes);
void calcular_puntajes(unsigned char * tablero, int * puntajes);

void screen_pintar_pantalla();
void imprimir(unsigned char *, unsigned int, unsigned char, unsigned short, unsigned short);
void imprimir_char(unsigned char, unsigned char, unsigned short, unsigned short);
void imprimir_fondo(unsigned char, unsigned short, unsigned short);

void int2str(int, int, int);
int length(int);

void task() {
	/* Task 5 : Tarea arbitro */
	syscall_iniciar();

	screen_pintar_pantalla();
	calcular_puntajes((unsigned char *)TABLERO_ADDR, puntJugadores);
	imprimir_tablero((unsigned char *)TABLERO_ADDR);
	imprimir_puntaje(puntJugadores);

	while(1) {
		if (juego_terminado((unsigned char *)TABLERO_ADDR) != TRUE) {
			actualizar_pantalla((unsigned char *)TABLERO_ADDR, puntJugadores);
		} else {
			syscall_terminar();
			actualizar_pantalla((unsigned char *)TABLERO_ADDR, puntJugadores);
			imprimir_ganador(puntJugadores);
			while(1) { }
		}
	}
}

void calcular_puntajes(unsigned char * tablero, int * puntajes) {
	int i, j;
	int celda = 0;
	puntJugadores[0] = 0;
	puntJugadores[1] = 0;
	puntJugadores[2] = 0;
	puntJugadores[3] = 0;

	for (i = 0; i < 16; ++i) {
		for (j = 0; j < 40; ++j) {
			celda = tablero[j + i*40];
			switch (celda) {
				case JUG_1:
					++puntJugadores[0];
					break;
				case JUG_2:
					++puntJugadores[1];
					break;
				case JUG_3:
					++puntJugadores[2];
					break;
				case JUG_4:
					++puntJugadores[3];
					break;
			}
		}
	}
}

void actualizar_pantalla(unsigned char * tablero, int * puntajes) {
	calcular_puntajes(tablero, puntajes);	
	imprimir_tablero(tablero);
	imprimir_puntaje(puntajes);
}

int juego_terminado(unsigned char * tablero) {
	int i, j;
	int termino = TRUE;
	for (i = 0; i < 16; ++i) {
		for (j = 0; j < 40; ++j) {
			if (tablero[j + i*40] == 0xff) {
				termino = FALSE;
				break;
			}
		}
	}
	return termino;
}

void imprimir_ganador(int * puntajes) {
	unsigned char outStr[8] = "Ganador!";
	
	int ganador = 0;
	if (puntajes[ganador] <= puntajes[0]) {
		ganador = 0;
	}
	if (puntajes[ganador] <= puntajes[1]) {
		ganador = 1;
	}
	if (puntajes[ganador] <= puntajes[2]) {
		ganador = 2;
	}
	if (puntajes[ganador] <= puntajes[3]) {
		ganador = 3;
	}
	imprimir(outStr, 8, (C_BLINK + C_BG_RED + C_FG_WHITE - ganador*0x10), (4 + ganador), 57);
}

void imprimir_puntaje(int * puntajes) {
	unsigned char msgPuntaje[7] = "Puntaje";
	imprimir(msgPuntaje, 7, C_BG_BROWN + C_FG_WHITE, 2, 46);
	
	int i, size;
	for (i = 0; i < 4; ++i) {
		size = length(puntJugadores[i]);
		int2str(puntJugadores[i], size, i);
	}
}

void imprimir_tablero(unsigned char * tablero) {
	int i, j;
	int celda = 0;
	unsigned short color = 0;
	for (i = 0; i < 16; ++i) {
		for (j = 0; j < 40; ++j) {
			celda = tablero[j + i*40];
			switch (celda) {
				case 1:
					color = C_BG_RED + C_FG_WHITE;
					break;
				case 2:
					color = C_BG_CYAN + C_FG_WHITE;
					break;
				case 3:
					color = C_BG_GREEN + C_FG_WHITE;
					break;
				case 4:
					color = C_BG_BLUE + C_FG_WHITE;
					break;
				default:
					color = C_BG_BLACK + C_FG_WHITE;
					break;
			}
			imprimir_fondo(color, i+2, j+2);
		}
	}
}

void print(const char* str, unsigned int fil, unsigned int col, unsigned short attr) {
	// Sugerencia: Implementar esta funcion que imprime en pantalla el string
	// *str* en la posicion (fil, col) con los atributos attr y usarla para
	// implementar todas las demas funciones que imprimen en pantalla.
}

/////////////////

void screen_pintar_pantalla() {
	//fondo gris
	char i, j;
	for (i = 1; i < VIDEO_FILS - 6; ++i) {
		for (j = 0; j < VIDEO_COLS; ++j) {
			imprimir_fondo(C_BG_LIGHT_GREY + C_FG_WHITE, i, j);
		}
	}
	for (i = VIDEO_FILS - 6; i < VIDEO_FILS - 1; ++i) {
		for (j = 2; j < VIDEO_COLS; ++j) {
			imprimir_fondo(C_BG_BROWN + C_FG_WHITE, i, j);
		}
	}
	imprimir_char('1', C_BG_RED + C_FG_LIGHT_GREY, 19, 1);
	imprimir_char('2', C_BG_CYAN + C_FG_LIGHT_GREY, 20, 1);
	imprimir_char('3', C_BG_GREEN + C_FG_LIGHT_GREY, 21, 1);
	imprimir_char('4', C_BG_BLUE + C_FG_LIGHT_GREY, 22, 1);
	imprimir_char('A', C_BG_MAGENTA + C_FG_LIGHT_GREY, 23, 1);
}

void imprimir(unsigned char *msg, unsigned int len, unsigned char colores, unsigned short fila,
		unsigned short columna) {
	unsigned short *video = (unsigned short *)VIDEO_ADDR;
	unsigned int pos = (fila*VIDEO_COLS) + columna;
	unsigned int i;

	for (i = 0; i < len; ++i) {
		video[pos+i] = (unsigned short)((colores << 8) + msg[i]);
	}
}

void imprimir_char(unsigned char msg, unsigned char colores, unsigned short fila, unsigned short columna) {
	unsigned char msg2[1];
	msg2[0] = msg;
	imprimir(msg2, 1, colores, fila, columna);
}

void imprimir_fondo(unsigned char colores, unsigned short fila, unsigned short columna) {
	imprimir_char(0x0, colores, fila, columna);
}

int length(int num) {
	int count = 0;
	while (num > 0) {
		++count;
		num /= 10;
	}
	return count;
}

void int2str(int inInt, int size, int jugador) {
	unsigned char outStr[size];
	int i, val;
	char elChar;
	if (size == 0) {
		imprimir_char('0', (C_BG_RED + C_FG_WHITE - jugador*0x10), (4 + jugador), 47);
	} else {
		for (i = size-1; i >= 0; --i) {
			val = inInt % 10;
			switch (val) {
				case 0:
				elChar = '0';
				break;
				
				case 1:
				elChar = '1';
				break;
				
				case 2:
				elChar = '2';
				break;
				
				case 3:
				elChar = '3';
				break;
				
				case 4:
				elChar = '4';
				break;
				
				case 5:
				elChar = '5';
				break;
				
				case 6:
				elChar = '6';
				break;
				
				case 7:
				elChar = '7';
				break;
				
				case 8:
				elChar = '8';
				break;
				
				case 9:
				elChar = '9';
				break;
			}
			outStr[i] = elChar;
			inInt /= 10;
		}
		imprimir(outStr, size, (C_BG_RED + C_FG_WHITE - jugador*0x10), (4 + jugador), 47);
	}
}

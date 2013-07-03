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

void print(const char* str, unsigned int fil, unsigned int col, unsigned short attr);

void imprimir_tablero(unsigned char * tablero);
void imprimir_puntaje();//int * puntajes
void imprimir_ganador(int * puntajes);
int  juego_terminado(unsigned char * tablero);
void actualizar_pantalla(unsigned char * tablero, int * puntajes);
void calcular_puntajes(unsigned char * tablero, int * puntajes);

void screen_pintar_pantalla();
void imprimir(unsigned char *, unsigned int, unsigned char, unsigned short, unsigned short);
void imprimir_char(unsigned char, unsigned char, unsigned short, unsigned short);
void imprimir_fondo(unsigned char, unsigned short, unsigned short);

void task() {
	/* Task 5 : Tarea arbitro */
	breakpoint();
	screen_pintar_pantalla();
	imprimir_tablero((unsigned char *)TABLERO_ADDR);
	imprimir_puntaje();

	while(1) { }
}

void calcular_puntajes(unsigned char * tablero, int * puntajes) {
	
}

void actualizar_pantalla(unsigned char * tablero, int * puntajes) {	
}

int juego_terminado(unsigned char * tablero) {
	return FALSE;
}

void imprimir_ganador(int * puntajes) {
}

void imprimir_puntaje() { //int * puntajes
	unsigned char msgPuntaje[7] = "Puntaje";
	imprimir(msgPuntaje, 7, C_BG_BROWN + C_FG_WHITE, 2, 46);
}

void imprimir_tablero(unsigned char * tablero) {
	int i, j;
	for (i = 0; i < 16; ++i) {
		for (j = 0; j < 40; ++j) {
			imprimir_fondo(C_FG_BLACK + C_FG_WHITE, i+2, j+2);
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

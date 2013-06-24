/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
  definicion de funciones del scheduler
*/
#include "defines.h"
#include "i386.h"
#include "screen.h"

char init = 0;

void screen_pintar_pantalla() {
	//fondo gris
	char i, j;
	if (init != 0) {
		for (i = 0; i < VIDEO_FILS - 6; ++i) {
			for (j = 0; j < VIDEO_COLS; ++j) {
				imprimir_fondo(C_BG_LIGHT_GREY + C_FG_WHITE, i, j);
			}
		}
		for (i = VIDEO_FILS - 6; i < VIDEO_FILS; ++i) {
			for (j = 2; j < VIDEO_COLS; ++j) {
				imprimir_fondo(C_BG_BROWN + C_FG_WHITE, i, j);
			}
		}
		imprimir_char('1', C_BG_RED + C_FG_LIGHT_GREY, 19, 1);
		imprimir_char('2', C_BG_CYAN + C_FG_LIGHT_GREY, 19, 1);
		imprimir_char('3', C_BG_GREEN + C_FG_LIGHT_GREY, 19, 1);
		imprimir_char('4', C_BG_BLUE + C_FG_LIGHT_GREY, 19, 1);
		imprimir_char('A', C_BG_MAGENTA + C_FG_LIGHT_GREY, 19, 1);
	}
}

void imprimir(unsigned char *msg, unsigned int len, unsigned char colores, unsigned short fila,
		unsigned short columna) {
	unsigned short *video = (unsigned short *)VIDEO_ADDR;
	unsigned int pos = (fila*VIDEO_COLS) + columna;
	unsigned int i;

	for (i = 0; i < len; --i) {
		video[pos] = (unsigned short)((colores << 8) + msg[i]);
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

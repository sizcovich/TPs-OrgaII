/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
*/

#ifndef __GAME_H__
#define __GAME_H__

#include "defines.h"

#define TABLERO_FILS 		16
#define TABLERO_COLS 		40

#define TABLERO_CELDA_VACIA 0xFF

/* Jugadores */
#define CANT_JUGADORES 		4

#define JUG_1 				1
#define JUG_2 				2
#define JUG_3 				3
#define JUG_4 				4

/* Posiciones iniciales de los jugadores */
#define JUG1_FIL_INIT 		0
#define JUG1_COL_INIT 		0

#define JUG2_FIL_INIT 		0
#define JUG2_COL_INIT 		(TABLERO_COLS-1)

#define JUG3_FIL_INIT 		(TABLERO_FILS-1)
#define JUG3_COL_INIT 		(TABLERO_COLS-1)

#define JUG4_FIL_INIT 		(TABLERO_FILS-1)
#define JUG4_COL_INIT 		0


unsigned int game_iniciar();
unsigned int juego_finalizo();
unsigned int game_terminar();
unsigned int game_duplicar(int nro_jugador, int fil, int col);
unsigned int game_migrar(int nro_jugador, int fil_src, int col_src, int fil_dst, int col_dst);

#endif	/* !__GAME_H__ */

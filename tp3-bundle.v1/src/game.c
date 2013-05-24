/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
*/

#include "game.h"

unsigned char (*tablero)[TABLERO_COLS] = (unsigned char (*)[TABLERO_COLS]) (TABLERO_ADDR);

unsigned int game_finalizado;

int abs(int n);

unsigned int game_salto_en_rango(int nro_jugador, int fil_src, int col_src, int fil_dst, int col_dst);
unsigned int game_es_adyacente(int nro_jugador, int fil, int col);
unsigned int game_posicion_en_rango(int fil, int col);
unsigned int game_celda_vacia(int fil, int col);
void         game_infectar_adyacentes(int nro_jugador, int fil, int col);

unsigned int game_iniciar() {
	int f;
	int c;

	// Inicialización de celdas
	for(f = 0; f < TABLERO_FILS; f++) {
		for(c = 0; c < TABLERO_COLS; c++) {
			tablero[f][c] = TABLERO_CELDA_VACIA;
		}
	}

	// Inicialización de jugadores
	tablero[JUG1_FIL_INIT][JUG1_COL_INIT] = JUG_1;
	tablero[JUG2_FIL_INIT][JUG2_COL_INIT] = JUG_2;
	tablero[JUG3_FIL_INIT][JUG3_COL_INIT] = JUG_3;
	tablero[JUG4_FIL_INIT][JUG4_COL_INIT] = JUG_4;

	// Inicializar estado del juego
	game_finalizado = FALSE;

	return TRUE;
}

unsigned int game_terminar() {
	game_finalizado = TRUE;

	return TRUE;
}

unsigned int game_duplicar(int nro_jugador, int fil, int col) {
	if (!game_posicion_en_rango(fil, col) ||
		!game_celda_vacia(fil, col) ||
		!game_es_adyacente(nro_jugador, fil, col)) {
		return FALSE;
	} else {
		tablero[fil][col] = nro_jugador;

		game_infectar_adyacentes(nro_jugador, fil, col);

		return TRUE;
	}
}

unsigned int game_migrar(int nro_jugador, int fil_src, int col_src, int fil_dst, int col_dst) {
	if (!game_salto_en_rango(nro_jugador, fil_src, col_src, fil_dst, col_dst) ||
		 game_es_adyacente(nro_jugador, fil_dst, col_dst)) {
		return FALSE;
	} else {
		tablero[fil_src][col_src] = TABLERO_CELDA_VACIA;
		tablero[fil_dst][col_dst] = nro_jugador;

		game_infectar_adyacentes(nro_jugador, fil_dst, col_dst);

		return TRUE;
	}
}

unsigned int game_posicion_en_rango(int fil, int col) {
	if (0 <= fil && fil < TABLERO_FILS &&
		0 <= col && col < TABLERO_COLS) {
		return TRUE;
	} else {
		return FALSE;
	}
}

unsigned int game_celda_vacia(int fil, int col) {
	if (tablero[fil][col] == TABLERO_CELDA_VACIA) {
		return TRUE;
	} else {
		return FALSE;
	}
}

unsigned int game_es_adyacente(int nro_jugador, int fil, int col) {
	unsigned int es_adyacente = FALSE;

	// Fila superior
	es_adyacente |= game_posicion_en_rango(fil - 1, col - 1) ?
		tablero[fil - 1][col - 1] == nro_jugador : FALSE;

	es_adyacente |= game_posicion_en_rango(fil - 1, col + 0) ?
		tablero[fil - 1][col + 0] == nro_jugador : FALSE;

	es_adyacente |= game_posicion_en_rango(fil - 1, col + 1) ?
		tablero[fil - 1][col + 1] == nro_jugador : FALSE;

	// Fila central
	es_adyacente |= game_posicion_en_rango(fil + 0, col - 1) ?
		tablero[fil + 0][col - 1] == nro_jugador : FALSE;

	es_adyacente |= game_posicion_en_rango(fil + 0, col + 1) ?
		tablero[fil + 0][col + 1] == nro_jugador : FALSE;

	// Fila inferior
	es_adyacente |= game_posicion_en_rango(fil + 1, col - 1) ?
		tablero[fil + 1][col - 1] == nro_jugador : FALSE;

	es_adyacente |= game_posicion_en_rango(fil + 1, col + 0) ?
		tablero[fil + 1][col + 0] == nro_jugador : FALSE;

	es_adyacente |= game_posicion_en_rango(fil + 1, col + 1) ?
		tablero[fil + 1][col + 1] == nro_jugador : FALSE;

	return es_adyacente == FALSE ? FALSE : TRUE;	// Para asegurarse que TRUE == 0x1
}

unsigned int game_salto_en_rango(int nro_jugador, int fil_src, int col_src, int fil_dst, int col_dst) {
	// el salto no puede ser mayor a tres celdas
	if ((abs(fil_src - fil_dst) + abs(col_src - col_dst)) <= 3) {
		return TRUE;
	} else {
		return FALSE;
	}
}

void game_infectar_adyacentes(int nro_jugador, int fil, int col) {
	// Fila superior
	if (game_posicion_en_rango(fil - 1, col - 1) &&
		tablero[fil - 1][col - 1] != TABLERO_CELDA_VACIA) {
		tablero[fil - 1][col - 1] = nro_jugador;
	}

	if (game_posicion_en_rango(fil - 1, col + 0) &&
		tablero[fil - 1][col + 0] != TABLERO_CELDA_VACIA) {
		tablero[fil - 1][col + 0] = nro_jugador;
	}

	if (game_posicion_en_rango(fil - 1, col + 1) &&
		tablero[fil - 1][col + 1] != TABLERO_CELDA_VACIA) {
		tablero[fil - 1][col + 1] = nro_jugador;
	}

	// Fila central
	if (game_posicion_en_rango(fil + 0, col - 1) &&
		tablero[fil + 0][col - 1] != TABLERO_CELDA_VACIA) {
		tablero[fil + 0][col - 1] = nro_jugador;
	}

	if (game_posicion_en_rango(fil + 0, col + 1) &&
		tablero[fil + 0][col + 1] != TABLERO_CELDA_VACIA) {
		tablero[fil + 0][col + 1] = nro_jugador;
	}

	// Fila inferior
	if (game_posicion_en_rango(fil + 1, col - 1) &&
		tablero[fil + 1][col - 1] != TABLERO_CELDA_VACIA) {
		tablero[fil + 1][col - 1] = nro_jugador;
	}

	if (game_posicion_en_rango(fil + 1, col + 0) &&
		tablero[fil + 1][col + 0] != TABLERO_CELDA_VACIA) {
		tablero[fil + 1][col + 0] = nro_jugador;
	}

	if (game_posicion_en_rango(fil + 1, col + 1) &&
		tablero[fil + 1][col + 1] != TABLERO_CELDA_VACIA) {
		tablero[fil + 1][col + 1] = nro_jugador;
	}
}

int abs(int n) {
	if (n >= 0) {
		return n;
	} else {
		return -n;
	}
}

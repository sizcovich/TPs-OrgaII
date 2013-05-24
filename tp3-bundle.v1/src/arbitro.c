/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
*/

#include "defines.h"
#include "game.h"
#include "syscall.h"


void print(const char* str, unsigned int fil, unsigned int col, unsigned short attr);

void imprimir_tablero(unsigned char * tablero);
void imprimir_puntaje(int * puntajes);
void imprimir_ganador(int * puntajes);
int  juego_terminado(unsigned char * tablero);
void actualizar_pantalla(unsigned char * tablero, int * puntajes);
void calcular_puntajes(unsigned char * tablero, int * puntajes);

void task() {
	/* Task 5 : Tarea arbitro */

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

void imprimir_puntaje(int * puntajes) {
}

void imprimir_tablero(unsigned char * tablero) {
}


void print(const char* str, unsigned int fil, unsigned int col, unsigned short attr) {
	// Sugerencia: Implementar esta funcion que imprime en pantalla el string
	// *str* en la posicion (fil, col) con los atributos attr y usarla para
	// implementar todas las demas funciones que imprimen en pantalla.
}

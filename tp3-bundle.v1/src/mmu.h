/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
  definicion de funciones del manejador de memoria
*/

#ifndef __MMU_H__
#define __MMU_H__

//Lleva el control de cuantas paginas pidio cada tarea



// inicializa el mmu
void mmu_inicializar_dir_kernel();
void mmu_inicializar_tarea_jugador();
void mmu_inicializar_tarea_arbitro();
void mmu_mapear_pagina(unsigned int virtual, unsigned int cr3, unsigned int fisica, unsigned int attrs);
void mmu_inicializar();
void inicializar_tarea1();
void inicializar_tarea2();
void inicializar_tarea3();
void inicializar_tarea4();
int obtener(unsigned int virtual, unsigned int tarea);


#endif	/* !__MMU_H__ */

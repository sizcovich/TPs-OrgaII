/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
  definicion de funciones del manejador de memoria
*/
#include "defines.h"
#include "mmu.h"
#include "i386.h"


void mmu_inicializar() {
	mmu_inicializar_dir_kernel();
	mmu_inicializar_tarea_jugador();
	mmu_inicializar_tarea_arbitro();
	tlbflush();
}

void mmu_inicializar_dir_kernel() {
	int i;
	int *page_dir = (int *)KERNEL_PAGE_DIR;
	int *page_tab = (int *)KERNEL_PAGE_TABLE; 
	for(i = 0; i<1024; ++i){
		*((unsigned int*) &(page_dir[i])) = 0x00000000;
		*((unsigned int*) &(page_tab[i])) = 0x00000000;
	}
	*((unsigned int*) &(page_dir[0])) = 0x00022003;
	
	unsigned int val = 0x0;
	for(i = 0; i < 356 ; ++i) {
		val = i*0x1000 + 0x3;
		*((unsigned int*) &(page_tab[i])) = val;
	}
	mmu_mapear_pagina(0x3A0000, KERNEL_PAGE_DIR, TASK_IDLE_CODE_SRC_ADDR, 0x003);
}

void inicializar_tarea1(){
	int i;
	unsigned char* fuente = (unsigned char*) (TASK_1_CODE_SRC_ADDR);
	unsigned char* destino = (unsigned char*) (TASK_1_CODE_PA);
	for(i = 0; i<4096; ++i){
		destino[i] = fuente[i];
	}
	int *page_dir = (int *)TASK_1_PAGE_DIR;
	int *page_tab = (int *)TASK_1_PAGE_TABLE; 
	for(i = 0; i<1024; ++i){
		*((unsigned int*) &(page_dir[i])) = 0x00000000;
		*((unsigned int*) &(page_tab[i])) = 0x00000000;
	}
	*((unsigned int*) &(page_dir[0])) = 0x00035007;
	
	unsigned int val = 0x0;
	for(i = 0; i < 356 ; ++i) {
		val = i*0x1000 + 0x3;
		*((unsigned int*) &(page_tab[i])) = val;
	}
	mmu_mapear_pagina(0x3A0000, TASK_1_PAGE_DIR, TASK_1_CODE_PA, 0x005);
	mmu_mapear_pagina(0x3B0000, TASK_1_PAGE_DIR, TASK_1_STACK_PA, 0x007);
	mmu_mapear_pagina(0x3C0000, TASK_1_PAGE_DIR, TABLERO_ADDR_PA, 0x005);
}

void inicializar_tarea2(){
	int i;
	unsigned char* fuente = (unsigned char*) (TASK_2_CODE_SRC_ADDR);
	unsigned char* destino = (unsigned char*) (TASK_2_CODE_PA);
	for(i = 0; i<4096; ++i){
		destino[i] = fuente[i];
	}
	int *page_dir = (int *)TASK_2_PAGE_DIR;
	int *page_tab = (int *)TASK_2_PAGE_TABLE; 
	for(i = 0; i<1024; ++i){
		*((unsigned int*) &(page_dir[i])) = 0x00000000;
		*((unsigned int*) &(page_tab[i])) = 0x00000000;
	}
	
	*((unsigned int*) &(page_dir[0])) = 0x00000000;
	*((unsigned int*) &(page_tab[0])) = 0x00000000;
		
	*((unsigned int*) &(page_dir[0])) = 0x00036007;
	
	unsigned int val = 0x0;
	for(i = 0; i < 356 ; ++i) {
		val = i*0x1000 + 0x3;
		*((unsigned int*) &(page_tab[i])) = val;
	}
	
	mmu_mapear_pagina(0x3A0000, TASK_2_PAGE_DIR, TASK_2_CODE_PA, 0x005);
	mmu_mapear_pagina(0x3B0000, TASK_2_PAGE_DIR, TASK_2_STACK_PA, 0x007);
	mmu_mapear_pagina(0x3C0000, TASK_2_PAGE_DIR, TABLERO_ADDR_PA, 0x005);
}

void inicializar_tarea3(){
	int i;
	unsigned char* fuente = (unsigned char*) (TASK_3_CODE_SRC_ADDR);
	unsigned char* destino = (unsigned char*) (TASK_3_CODE_PA);
	for(i = 0; i<4096; ++i){
		destino[i] = fuente[i];
	}
	int *page_dir = (int *)TASK_3_PAGE_DIR;
	int *page_tab = (int *)TASK_3_PAGE_TABLE; 
	for(i = 0; i<1024; ++i){
		*((unsigned int*) &(page_dir[i])) = 0x00000000;
		*((unsigned int*) &(page_tab[i])) = 0x00000000;
	}
	*((unsigned int*) &(page_dir[0])) = 0x00037007;
	
	unsigned int val = 0x0;
	for(i = 0; i < 356 ; ++i) {
		val = i*0x1000 + 0x3;
		*((unsigned int*) &(page_tab[i])) = val;
	}
	
	mmu_mapear_pagina(0x3A0000, TASK_3_PAGE_DIR, TASK_3_CODE_PA, 0x005);
	mmu_mapear_pagina(0x3B0000, TASK_3_PAGE_DIR, TASK_3_STACK_PA, 0x007);
	mmu_mapear_pagina(0x3C0000, TASK_3_PAGE_DIR, TABLERO_ADDR_PA, 0x005);
}

void inicializar_tarea4(){
	int i;
	unsigned char* fuente = (unsigned char*) (TASK_4_CODE_SRC_ADDR);
	unsigned char* destino = (unsigned char*) (TASK_4_CODE_PA);
	for(i = 0; i<4096; ++i){
		destino[i] = fuente[i];
	}
	int *page_dir = (int *)TASK_4_PAGE_DIR;
	int *page_tab = (int *)TASK_4_PAGE_TABLE; 
	for(i = 0; i<1024; ++i){
		*((unsigned int*) &(page_dir[i])) = 0x00000000;
		*((unsigned int*) &(page_tab[i])) = 0x00000000;
	}
	*((unsigned int*) &(page_dir[0])) = 0x00038007;
	
	unsigned int val = 0x0;
	for(i = 0; i < 356 ; ++i) {
		val = i*0x1000 + 0x3;
		*((unsigned int*) &(page_tab[i])) = val;
	}
	
	mmu_mapear_pagina(0x3A0000, TASK_4_PAGE_DIR, TASK_4_CODE_PA, 0x005);
	mmu_mapear_pagina(0x3B0000, TASK_4_PAGE_DIR, TASK_4_STACK_PA, 0x007);
	mmu_mapear_pagina(0x3C0000, TASK_4_PAGE_DIR, TABLERO_ADDR_PA, 0x005);
}

void mmu_mapear_pagina(unsigned int virtual, unsigned int cr3, unsigned int fisica, unsigned int attrs){
	int *page_dir = (int *)cr3; //cargo page directory
	
	int PDE = virtual >> 22; //busco PDE, quiero los 10 primeros bits de la direccion lineal
	int *page_tab = (int *)(*((unsigned int*) &(page_dir[PDE])) & 0xFFFFF000); //obtengo la direccion del page table
	
	int PTE = (0x003FF000 & virtual) >> 12; //pongo en 0 virtual para obtener el indice dentro del page table
	*((unsigned int*) &(page_tab[PTE])) = (0xFFFFF000 & fisica) | (0xFFF & attrs); //escribo en esa direccion la entrada de la direccion correspondiente
}

void mmu_inicializar_tarea_jugador() {
	inicializar_tarea1();
	inicializar_tarea2();
	inicializar_tarea3();
	inicializar_tarea4();
}

void mmu_inicializar_tarea_arbitro() {
	int i;
	unsigned char* fuente = (unsigned char*) (TASK_5_CODE_SRC_ADDR);
	unsigned char* destino = (unsigned char*) (TASK_5_CODE_PA);
	for(i = 0; i<4096; ++i){
		destino[i] = fuente[i];
	}
	int *page_dir = (int *)TASK_5_PAGE_DIR;
	int *page_tab = (int *)TASK_5_PAGE_TABLE; 
	for(i = 0; i<1024; ++i){
		*((unsigned int*) &(page_dir[i])) = 0x00000000;
		*((unsigned int*) &(page_tab[i])) = 0x00000000;
	}
	*((unsigned int*) &(page_dir[0])) = 0x00039003;
	
	unsigned int val = 0x0;
	for(i = 0; i < 356 ; ++i) {
		val = i*0x1000 + 0x3;
		*((unsigned int*) &(page_tab[i])) = val;
	}
	
	mmu_mapear_pagina(0x3A0000, TASK_5_PAGE_DIR, TASK_5_CODE_PA, 0x001);
	mmu_mapear_pagina(0x3B0000, TASK_5_PAGE_DIR, TASK_5_STACK_PA, 0x003);
	mmu_mapear_pagina(VIDEO_ADDR, TASK_5_PAGE_DIR, VIDEO_ADDR, 0x003);  //esto no estaba
	mmu_mapear_pagina(0x3C0000, TASK_5_PAGE_DIR, TABLERO_ADDR_PA, 0x001); //esto tenia un 3 y le puse un 1
}

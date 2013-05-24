/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
  definicion de estructuras para administrar tareas
*/

#include "defines.h"
#include "gdt.h"
#include "tss.h"
#include "i386.h"

tss tarea_inicial;
tss tarea_idle;
tss tarea_dibujar;

tss tsss[CANT_TAREAS];


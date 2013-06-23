/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
  definicion de la tabla de descriptores globales
*/
#include "defines.h"
#include "gdt.h"
#include "tss.h"

gdt_entry gdt[GDT_COUNT] = {
	/* Descriptor nulo*/
	/* Offset = 0x00 */
	[GDT_IDX_NULL_DESC] = (gdt_entry) {
		(unsigned short)	0x0000,			/* limit[0:15]  */
		(unsigned short)	0x0000,			/* base[0:15]   */
		(unsigned char)		0x00,			/* base[23:16]  */
		(unsigned char)		0x00,			/* type         */
		(unsigned char)		0x00,			/* s            */
		(unsigned char)		0x00,			/* dpl          */
		(unsigned char)		0x00,			/* p            */
		(unsigned char)		0x00,			/* limit[16:19] */
		(unsigned char)		0x00,			/* avl          */
		(unsigned char)		0x00,			/* l            */
		(unsigned char)		0x00,			/* db           */
		(unsigned char)		0x00,			/* g            */
		(unsigned char)		0x00,			/* base[31:24]  */
	},
	[GDT_IDX_CODE0_DESC] = (gdt_entry) {
		(unsigned short)	0xFFFF,			/* limit[0:15]  */
		(unsigned short)	0x0000,			/* base[0:15]   */
		(unsigned char)		0x00,			/* base[23:16]  */
		(unsigned char)		0x0A,			/* type         */
		(unsigned char)		0x01,			/* s            */
		(unsigned char)		0x00,			/* dpl          */
		(unsigned char)		0x01,			/* p            */
		(unsigned char)		0x07,			/* limit[16:19] */
		(unsigned char)		0x00,			/* avl          */
		(unsigned char)		0x00,			/* l            */
		(unsigned char)		0x01,			/* db           */
		(unsigned char)		0x01,			/* g            */
		(unsigned char)		0x00,			/* base[31:24]  */
	},
	[GDT_IDX_DATA0_DESC] = (gdt_entry) {
		(unsigned short)	0xFFFF,			/* limit[0:15]  */
		(unsigned short)	0x0000,			/* base[0:15]   */
		(unsigned char)		0x00,			/* base[23:16]  */
		(unsigned char)		0x02,			/* type         */
		(unsigned char)		0x01,			/* s            */
		(unsigned char)		0x00,			/* dpl          */
		(unsigned char)		0x01,			/* p            */
		(unsigned char)		0x07,			/* limit[16:19] */
		(unsigned char)		0x00,			/* avl          */
		(unsigned char)		0x00,			/* l            */
		(unsigned char)		0x01,			/* db           */
		(unsigned char)		0x01,			/* g            */
		(unsigned char)		0x00,			/* base[31:24]  */
	},
	[GDT_IDX_CODE2_DESC] = (gdt_entry) {
		(unsigned short)	0xFFFF,			/* limit[0:15]  */
		(unsigned short)	0x0000,			/* base[0:15]   */
		(unsigned char)		0x00,			/* base[23:16]  */
		(unsigned char)		0x0A,			/* type         */
		(unsigned char)		0x01,			/* s            */
		(unsigned char)		0x02,			/* dpl          */
		(unsigned char)		0x01,			/* p            */
		(unsigned char)		0x07,			/* limit[16:19] */
		(unsigned char)		0x00,			/* avl          */
		(unsigned char)		0x00,			/* l            */
		(unsigned char)		0x01,			/* db           */
		(unsigned char)		0x01,			/* g            */
		(unsigned char)		0x00,			/* base[31:24]  */
	},
	[GDT_IDX_DATA2_DESC] = (gdt_entry) {
		(unsigned short)	0xFFFF,			/* limit[0:15]  */
		(unsigned short)	0x0000,			/* base[0:15]   */
		(unsigned char)		0x00,			/* base[23:16]  */
		(unsigned char)		0x02,			/* type         */
		(unsigned char)		0x01,			/* s            */
		(unsigned char)		0x02,			/* dpl          */
		(unsigned char)		0x01,			/* p            */
		(unsigned char)		0x07,			/* limit[16:19] */
		(unsigned char)		0x00,			/* avl          */
		(unsigned char)		0x00,			/* l            */
		(unsigned char)		0x01,			/* db           */
		(unsigned char)		0x01,			/* g            */
		(unsigned char)		0x00,			/* base[31:24]  */
	},
	[GDT_IDX_CODE3_DESC] = (gdt_entry) {
		(unsigned short)	0xFFFF,			/* limit[0:15]  */
		(unsigned short)	0x0000,			/* base[0:15]   */
		(unsigned char)		0x00,			/* base[23:16]  */
		(unsigned char)		0x0A,			/* type         */
		(unsigned char)		0x01,			/* s            */
		(unsigned char)		0x03,			/* dpl          */
		(unsigned char)		0x01,			/* p            */
		(unsigned char)		0x07,			/* limit[16:19] */
		(unsigned char)		0x00,			/* avl          */
		(unsigned char)		0x00,			/* l            */
		(unsigned char)		0x01,			/* db           */
		(unsigned char)		0x01,			/* g            */
		(unsigned char)		0x00,			/* base[31:24]  */
	},
	[GDT_IDX_DATA3_DESC] = (gdt_entry) {
		(unsigned short)	0xFFFF,			/* limit[0:15]  */
		(unsigned short)	0x0000,			/* base[0:15]   */
		(unsigned char)		0x00,			/* base[23:16]  */
		(unsigned char)		0x02,			/* type         */
		(unsigned char)		0x01,			/* s            */
		(unsigned char)		0x03,			/* dpl          */
		(unsigned char)		0x01,			/* p            */
		(unsigned char)		0x07,			/* limit[16:19] */
		(unsigned char)		0x00,			/* avl          */
		(unsigned char)		0x00,			/* l            */
		(unsigned char)		0x01,			/* db           */
		(unsigned char)		0x01,			/* g            */
		(unsigned char)		0x00,			/* base[31:24]  */
	},
	[GDT_IDX_AREA_DESC] = (gdt_entry) {
		(unsigned short)	0x7FFF,			/* limit[0:15]  */
		(unsigned short)	0x8000,			/* base[0:15]   */
		(unsigned char)		0x0B,			/* base[23:16]  */
		(unsigned char)		0x02,			/* type         */
		(unsigned char)		0x01,			/* s            */
		(unsigned char)		0x00,			/* dpl          */
		(unsigned char)		0x01,			/* p            */
		(unsigned char)		0x00,			/* limit[16:19] */
		(unsigned char)		0x00,			/* avl          */
		(unsigned char)		0x00,			/* l            */
		(unsigned char)		0x01,			/* db           */
		(unsigned char)		0x00,			/* g            */
		(unsigned char)		0x00,			/* base[31:24]  */
	},
};

void inicializar_gdt_tss() {
	gdt[GDT_TSS_INICIAL] = (gdt_entry) {
		(unsigned short)		0x67,			/* limit[0:15]  */
		(unsigned short)		(unsigned int)&tarea_inicial,			/* base[0:15]   */
		(unsigned char)		(unsigned int)&tarea_inicial >> 16,			/* base[23:16]  */
		(unsigned char)		0x09,			/* type         */
		(unsigned char)		0x00,			/* s            */
		(unsigned char)		0x00,			/* dpl          */
		(unsigned char)		0x01,			/* p            */
		(unsigned char)		0x00,			/* limit[16:19] */
		(unsigned char)		0x00,			/* avl          */
		(unsigned char)		0x00,			/* l            */
		(unsigned char)		0x00,			/* db           */
		(unsigned char)		0x00,			/* g            */
		(unsigned char)		(unsigned int)&tarea_inicial >> 24,			/* base[31:24]  */
	};
	
	gdt[GDT_TSS_IDLE] = (gdt_entry) {
		(unsigned short)		0x67,			/* limit[0:15]  */
		(unsigned short)		(unsigned int)&tarea_idle,			/* base[0:15]   */
		(unsigned char)		(unsigned int)&tarea_idle >> 16,			/* base[23:16]  */
		(unsigned char)		0x09,			/* type         */
		(unsigned char)		0x00,			/* s            */
		(unsigned char)		0x00,			/* dpl          */
		(unsigned char)		0x01,			/* p            */
		(unsigned char)		0x00,			/* limit[16:19] */
		(unsigned char)		0x00,			/* avl          */
		(unsigned char)		0x00,			/* l            */
		(unsigned char)		0x00,			/* db           */
		(unsigned char)		0x00,			/* g            */
		(unsigned char)		(unsigned int)&tarea_idle >> 24,			/* base[31:24]  */
	};
	
	gdt[GDT_TSS_TAREA1] = (gdt_entry) {
		(unsigned short)		0x67,			/* limit[0:15]  */
		(unsigned short)		(unsigned int)&tsss[1],			/* base[0:15]   */
		(unsigned char)		(unsigned int)&tsss[1] >> 16,			/* base[23:16]  */
		(unsigned char)		0x09,			/* type         */
		(unsigned char)		0x00,			/* s            */
		(unsigned char)		0x00,			/* dpl          */
		(unsigned char)		0x01,			/* p            */
		(unsigned char)		0x00,			/* limit[16:19] */
		(unsigned char)		0x00,			/* avl          */
		(unsigned char)		0x00,			/* l            */
		(unsigned char)		0x00,			/* db           */
		(unsigned char)		0x00,			/* g            */
		(unsigned char)		(unsigned int)&tsss[1] >> 24,			/* base[31:24]  */
	};
	
	gdt[GDT_TSS_TAREA2] = (gdt_entry) {
		(unsigned short)		0x67,			/* limit[0:15]  */
		(unsigned short)		(unsigned int)&tsss[2],			/* base[0:15]   */
		(unsigned char)		(unsigned int)&tsss[2] >> 16,			/* base[23:16]  */
		(unsigned char)		0x09,			/* type         */
		(unsigned char)		0x00,			/* s            */
		(unsigned char)		0x00,			/* dpl          */
		(unsigned char)		0x01,			/* p            */
		(unsigned char)		0x00,			/* limit[16:19] */
		(unsigned char)		0x00,			/* avl          */
		(unsigned char)		0x00,			/* l            */
		(unsigned char)		0x00,			/* db           */
		(unsigned char)		0x00,			/* g            */
		(unsigned char)		(unsigned int)&tsss[2] >> 24,			/* base[31:24]  */
	};
	
	gdt[GDT_TSS_TAREA3] = (gdt_entry) {
		(unsigned short)		0x67,			/* limit[0:15]  */
		(unsigned short)		(unsigned int)&tsss[3],			/* base[0:15]   */
		(unsigned char)		(unsigned int)&tsss[3] >> 16,			/* base[23:16]  */
		(unsigned char)		0x09,			/* type         */
		(unsigned char)		0x00,			/* s            */
		(unsigned char)		0x00,			/* dpl          */
		(unsigned char)		0x01,			/* p            */
		(unsigned char)		0x00,			/* limit[16:19] */
		(unsigned char)		0x00,			/* avl          */
		(unsigned char)		0x00,			/* l            */
		(unsigned char)		0x00,			/* db           */
		(unsigned char)		0x00,			/* g            */
		(unsigned char)		(unsigned int)&tsss[3] >> 24,			/* base[31:24]  */
	};
	
	gdt[GDT_TSS_TAREA4] = (gdt_entry) {
		(unsigned short)		0x67,			/* limit[0:15]  */
		(unsigned short)		(unsigned int)&tsss[4],			/* base[0:15]   */
		(unsigned char)		(unsigned int)&tsss[4] >> 16,			/* base[23:16]  */
		(unsigned char)		0x09,			/* type         */
		(unsigned char)		0x00,			/* s            */
		(unsigned char)		0x00,			/* dpl          */
		(unsigned char)		0x01,			/* p            */
		(unsigned char)		0x00,			/* limit[16:19] */
		(unsigned char)		0x00,			/* avl          */
		(unsigned char)		0x00,			/* l            */
		(unsigned char)		0x00,			/* db           */
		(unsigned char)		0x00,			/* g            */
		(unsigned char)		(unsigned int)&tsss[4] >> 24,			/* base[31:24]  */
	};
	
	gdt[GDT_TSS_ARBITRO] = (gdt_entry) {
		(unsigned short)		0x67,			/* limit[0:15]  */
		(unsigned short)		(unsigned int)&tsss[5],			/* base[0:15]   */
		(unsigned char)		(unsigned int)&tsss[5] >> 16,			/* base[23:16]  */
		(unsigned char)		0x09,			/* type         */
		(unsigned char)		0x00,			/* s            */
		(unsigned char)		0x00,			/* dpl          */
		(unsigned char)		0x01,			/* p            */
		(unsigned char)		0x00,			/* limit[16:19] */
		(unsigned char)		0x00,			/* avl          */
		(unsigned char)		0x00,			/* l            */
		(unsigned char)		0x00,			/* db           */
		(unsigned char)		0x00,			/* g            */
		(unsigned char)		(unsigned int)&tsss[5] >> 24,			/* base[31:24]  */
	};
}

gdt_descriptor GDT_DESC = {
	sizeof(gdt) - 1,
	(unsigned int) &gdt
};

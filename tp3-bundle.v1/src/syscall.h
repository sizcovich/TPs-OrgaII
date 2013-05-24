/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
  definicion de la tabla de descriptores globales
*/

#ifndef __SYSCALL_H__
#define __SYSCALL_H__

#define LS_INLINE static __inline __attribute__((always_inline))

#define SYS_DUPLICAR	111
#define SYS_MIGRAR		222
#define SYS_INICIAR		200
#define SYS_TERMINAR	300

/*
 * Syscalls anillo #3
 */
LS_INLINE unsigned int syscall_duplicar(int fil, int col) {
	int ret;

	__asm __volatile(
		"mov %0, %%eax \n"
		"mov %1, %%ebx \n"
		"mov %2, %%ecx \n"
		"int $0x80     \n"
		: /* no output*/
		: "r" (SYS_DUPLICAR), "m" (fil), "m" (col)
		: "eax", "ebx", "ecx"
	);

	__asm __volatile("mov %%eax, %0" : "=r" (ret));

	return ret;
}

LS_INLINE unsigned int syscall_migrar(int fil_src, int col_src, int fil_dst, int col_dst) {
	int ret;

	__asm __volatile(
		"mov %0, %%eax \n"
		"mov %1, %%ebx \n"
		"mov %2, %%ecx \n"
		"mov %3, %%edx \n"
		"mov %4, %%esi \n"
		"int $0x80     \n"
		: /* no output*/
		: "r" (SYS_MIGRAR),
		  "m" (fil_src), "m" (col_src),
		  "m" (fil_dst), "m" (col_dst)
	  	: "eax", "ebx", "ecx", "edx", "esi"
	);

	__asm __volatile("mov %%eax, %0" : "=r" (ret));

	return ret;
}

/*
 * Syscalls anillo #2
 */
LS_INLINE unsigned int syscall_iniciar(void) {
	int ret;

	__asm __volatile(
		"mov %0, %%eax \n"
		"int $0x90     \n"
		: /* no output */
		: "r" (SYS_INICIAR)
	);

	__asm __volatile("mov %%eax, %0" : "=r" (ret));

	return ret;
}

LS_INLINE unsigned int syscall_terminar(void) {
	int ret;

	__asm __volatile(
		"mov %0, %%eax \n"
		"int $0x90     \n"
		: /* no output */
		: "r" (SYS_TERMINAR)
	);

	__asm __volatile("mov %%eax, %0" : "=r" (ret));

	return ret;
}

#endif	/* !__SYSCALL_H__ */

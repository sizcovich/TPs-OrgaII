#!/usr/bin/env python2
# encoding: UTF-8

# Uso: ./rendimiento <iteraciones> <parametros del filtro>
# No es necesario especificar la implementación.
# Ejemplo: ./rendimiento 100 colorizar lena.bmp 0.5

import os
import sys
import commands

st_c,   out_c   = commands.getstatusoutput("./tp2 -i c   -t " + " ".join(sys.argv[1:]))
st_asm, out_asm = commands.getstatusoutput("./tp2 -i asm -t " + " ".join(sys.argv[1:]))

print "Implementación C"
print "----------------"
print
print out_c
print 
print "Implementación ASM"
print "------------------"
print
print out_asm

if(st_asm == -1 or st_c == -1): sys.exit(-1)

# Obtengo cantidad de ciclos
ciclos_c   = float(out_c  .split("\n")[5].split(": ")[1])
ciclos_asm = float(out_asm.split("\n")[5].split(": ")[1])

# Obtengo tiempo inicial y final
t0_c   = int(out_c  .split("\n")[1].split(": ")[1])
tf_c   = int(out_c  .split("\n")[2].split(": ")[1])
t0_asm = int(out_asm.split("\n")[1].split(": ")[1])
tf_asm = int(out_asm.split("\n")[2].split(": ")[1])

# Calculo tiempos
tiempo_c   = tf_c - t0_c
tiempo_asm = tf_asm - t0_asm

print
print "Resultados"
print "----------"
print

print "Ciclos C:                 " + str(ciclos_c)
print "Ciclos ASM:               " + str(ciclos_asm)
print "Ciclos ASM respecto de C: " + str(ciclos_asm * 100.0 / ciclos_c) + "%"
print "Tiempo C:                 " + str(tiempo_c)
print "Tiempo ASM:               " + str(tiempo_asm)
print "Tiempo ASM respecto de C: " + str(tiempo_asm * 100.0 / tiempo_c) + "%"
print

CC = gcc
ASM = nasm
DBG = gdb
CFLAGS = -ggdb -Wall -std=c99 -pedantic -m64
ASMFLAGS = -felf64 -g -F dwarf
OPENCV_LIB = `pkg-config --cflags --libs opencv`

BUNDLEDIR = ../../tp2-bundle

BIN = tp2
BIN_DIR = ../bin

OBJS = tp2.o utils.o \
	recortar_c.o recortar_asm.o \
	colorizar_c.o colorizar_asm.o \
	halftone_c.o halftone_asm.o \
	rotar_c.o rotar_asm.o \
	umbralizar_c.o umbralizar_asm.o \
	waves_c.o waves_asm.o

.PHONY: all clean

$(BIN): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $@ $(OPENCV_LIB)
	cp $(BIN) $(BIN_DIR)/$(BIN)

tp2.o: tp2.c
	$(CC) $(CFLAGS) -c -o $@ $< $(OPENCV_LIB)

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $< -lm

%.o: %.asm
	$(ASM) $(ASMFLAGS) -o $@ $<

all: $(BIN)

clean:
	rm -f $(OBJS)
	rm -f ./$(BIN)
	rm -f $(BIN_DIR)/$(BIN)

bundle:
	rm -rf $(BUNDLEDIR)
	mkdir -p $(BUNDLEDIR)
	cp ../../enunciado/tp2-enunciado.pdf versiones.txt $(BUNDLEDIR)
	../../../deleter.py .. $(BUNDLEDIR)/solucion/zz
	mkdir -p $(BUNDLEDIR)/solucion/bin
	rmdir $(BUNDLEDIR)/solucion/zz
	tar -czf $(BUNDLEDIR)/../tp2.tar.gz $(BUNDLEDIR)



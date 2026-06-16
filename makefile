CC=gcc
CFLAGS= -Wall
LFLAGS= -z noexecstack
all: lissajous

lissajous: main.o lissajousAVX512.o
	$(CC) $(CFLAGS) $(LFLAGS) main.o lissajousAVX512.o -o lissajous -lSDL2

main.o: main.c
	$(CC) $(CFLAGS) -c main.c

lissajousAVX512.o: lissajousAVX512.s
	nasm -f elf64 -w+all lissajousAVX512.s

clean:
	rm -rf *.o

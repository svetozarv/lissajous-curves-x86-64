CC=gcc
CFLAGS= -Wall -lSDL2

all: lissajous

lissajous: main.o lissajous.o
	$(CC) $(CFLAGS) main.o lissajous.o -o lissajous

main.o: main.c
	$(CC) $(CFLAGS) -c main.c

lissajous.o: lissajous.s
	nasm -f elf64 lissajous.s

clean:
	rm -rf *.o

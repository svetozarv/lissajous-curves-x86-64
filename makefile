CC=gcc
CFLAGS=-m32 -Wall

all: lissajous

lissajous: main.o lissajous.o
	$(CC) $(CFLAGS) main.o lissajous.o -o lissajous

main.o: main.c
	$(CC) $(CFLAGS) -c main.c -o main.o

lissajous.o: lissajous.s
	nasm -f elf lissajous.s -o lissajous.o

clean:
	rm -rf *.o

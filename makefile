CC=gcc
CFLAGS= -Wall

all: lissajous

lissajous: main.o lissajous.o
	$(CC) $(CFLAGS) -z noexecstack main.o lissajous.o -o lissajous -lSDL2

main.o: main.c
	$(CC) $(CFLAGS) -c main.c

lissajous.o: lissajous.s
	nasm -f elf64 lissajous.s

clean:
	rm -rf *.o

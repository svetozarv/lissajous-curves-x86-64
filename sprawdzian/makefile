CC=gcc
CFLAGS=-m32 -Wall

all: main.o f.o
	$(CC) $(CFLAGS) main.o f.o -o f

main.o: main.c
	$(CC) $(CFLAGS) -c main.c -o main.o

f.o: compress.s
	nasm -f elf compress.s -o f.o

clean:
	rm -rf *.o
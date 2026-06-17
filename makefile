CC=gcc
CFLAGS= -Wall
LFLAGS= -z noexecstack
all: lissajous

lissajous: main.o lissajous.o lissajousAVX.o
	$(CC) $(CFLAGS) $(LFLAGS) main.o lissajous.o lissajousAVX.o lissajousAVX512.o -o lissajous -lSDL2

main.o: main.c
	$(CC) $(CFLAGS) -c main.c

# lissajous.o: lissajous.s
# 	nasm -f elf64 -w+all lissajous.s

lissajousAVX.o: lissajousAVX.s
	nasm -f elf64 -w+all lissajousAVX.s

# lissajousAVX512.o: lissajousAVX512.s
# 	nasm -f elf64 -w+all lissajousAVX512.s

clean:
	rm -rf *.o

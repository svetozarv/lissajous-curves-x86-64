CC=gcc
CFLAGS=-m32 -Wall

# =====================================================
all: reversepairs remrep

reversepairs: main.o reversepairs.o
	$(CC) $(CFLAGS) main.o reversepairs.o -o reversepairs

remrep: main.o remrep.o
	$(CC) $(CFLAGS) main.o remrep.o -o remrep
# =====================================================

main.o: main.c
	$(CC) $(CFLAGS) -c main.c -o main.o

# =====================================================
leavelastndig.o: asm/leavelastndig.s
	nasm -f elf asm/leavelastndig.s -o leavelastndig.o

leaverng.o: asm/leaverng.s
	nasm -f elf asm/leaverng.s -o leaverng.o

remnth.o: asm/remnth.s
	nasm -f elf asm/remnth.s -o remnth.o

removerng.o: asm/removerng.s
	nasm -f elf asm/removerng.s -o removerng.o

remrep.o: asm/remrep.s
	nasm -f elf asm/remrep.s -o remrep.o

reversepairs.o: asm/reversepairs.s
	nasm -f elf asm/reversepairs.s -o reversepairs.o
# =====================================================

clean:
	rm -rf *.o
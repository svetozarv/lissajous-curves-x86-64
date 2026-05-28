CC=gcc
CFLAGS=-m32 -Wall

all: leavelastndig leaverng remnth removerng remrep reversepairs

# ================= Link .o =================
leavelastndig: leavelastndig_main.o leavelastndig.o
	$(CC) $(CFLAGS) leavelastndig_main.o leavelastndig.o -o leavelastndig

leaverng: leaverng_main.o leaverng.o
	$(CC) $(CFLAGS) leaverng_main.o leaverng.o -o leaverng

remnth: remnth_main.o remnth.o
	$(CC) $(CFLAGS) remnth_main.o remnth.o -o remnth

removerng: removerng_main.o removerng.o
	$(CC) $(CFLAGS) removerng_main.o removerng.o -o removerng

remrep: remrep_main.o remrep.o
	$(CC) $(CFLAGS) remrep_main.o remrep.o -o remrep

reversepairs: reversepairs_main.o reversepairs.o
	$(CC) $(CFLAGS) reversepairs_main.o reversepairs.o -o reversepairs

# ================= Compile .c =================

leavelastndig_main.o: asm/leavelastndig/main.c
	$(CC) $(CFLAGS) -c asm/leavelastndig/main.c -o leavelastndig_main.o

leaverng_main.o: asm/leaverng/main.c
	$(CC) $(CFLAGS) -c asm/leaverng/main.c -o leaverng_main.o

remnth_main.o: asm/remnth/main.c
	$(CC) $(CFLAGS) -c asm/remnth/main.c -o remnth_main.o

removerng_main.o: asm/removerng/main.c
	$(CC) $(CFLAGS) -c asm/removerng/main.c -o removerng_main.o

remrep_main.o: asm/remrep/main.c
	$(CC) $(CFLAGS) -c asm/remrep/main.c -o remrep_main.o

reversepairs_main.o: asm/reversepairs/main.c
	$(CC) $(CFLAGS) -c asm/reversepairs/main.c -o reversepairs_main.o

# ================= Compile .asm =================
leavelastndig.o: asm/leavelastndig/leavelastndig.s
	nasm -f elf asm/leavelastndig/leavelastndig.s -o leavelastndig.o

leaverng.o: asm/leaverng/leaverng.s
	nasm -f elf asm/leaverng/leaverng.s -o leaverng.o

remnth.o: asm/remnth/remnth.s
	nasm -f elf asm/remnth/remnth.s -o remnth.o

removerng.o: asm/removerng/removerng.s
	nasm -f elf asm/removerng/removerng.s -o removerng.o

remrep.o: asm/remrep/remrep.s
	nasm -f elf asm/remrep/remrep.s -o remrep.o

reversepairs.o: asm/reversepairs/reversepairs.s
	nasm -f elf asm/reversepairs/reversepairs.s -o reversepairs.o
# =================================================

clean:
	rm -rf *.o

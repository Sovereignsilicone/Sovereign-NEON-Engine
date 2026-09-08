CC = clang
CFLAGS = --target=aarch64-none-elf -ffreestanding -nostdlib -O3 -Wall -Iinclude
LDFLAGS = -T linker.ld -nostdlib

all: kernel.bin

startup.o: startup.s
	$(CC) $(CFLAGS) -c startup.s -o startup.o

kernel.o: kernel.c
	$(CC) $(CFLAGS) -c kernel.c -o kernel.o

low_level.o: kernel/low_level.c
	$(CC) $(CFLAGS) -c kernel/low_level.c -o low_level.o

sovereign_neon_kernel.o: sovereign_neon_kernel.c
	$(CC) $(CFLAGS) -c sovereign_neon_kernel.c -o sovereign_neon_kernel.o

timer.o: drivers/timer.c
	$(CC) $(CFLAGS) -c drivers/timer.c -o timer.o

kernel.elf: startup.o kernel.o low_level.o sovereign_neon_kernel.o timer.o
	$(CC) $(LDFLAGS) startup.o kernel.o low_level.o sovereign_neon_kernel.o timer.o -o kernel.elf

kernel.bin: kernel.elf
	llvm-objcopy -O binary kernel.elf kernel.bin

clean:
	rm -f *.o *.elf *.bin

ASM = nasm
CC = gcc
LD = ld
OBJCOPY = objcopy
QEMU = qemu-system-i386

CFLAGS = -m32 -ffreestanding -c
LDFLAGS = -m elf_i386 -T kernel/linker.ld

all: os.bin

boot.bin: boot.asm
	$(ASM) -f bin $< -o $@

stage2.bin: stage2.asm
	$(ASM) -f bin $< -o $@

kernel/kernel_entry.o: kernel/kernel_entry.asm
	$(ASM) -f elf32 $< -o $@

kernel/kernel.o: kernel/kernel.c
	$(CC) $(CFLAGS) $< -o $@

kernel/kernel.elf: kernel/kernel_entry.o kernel/kernel.o
	$(LD) $(LDFLAGS) $^ -o $@

kernel/kernel.bin: kernel/kernel.elf
	$(OBJCOPY) -O binary $< $@

os.bin: boot.bin stage2.bin kernel/kernel.bin
	cat $^ > $@

run: os.bin
	$(QEMU) -drive format=raw,file=os.bin -display curses

clean:
	rm -f boot.bin stage2.bin os.bin
	rm -f kernel/*.o kernel/*.elf kernel/*.bin

.PHONY: all run clean
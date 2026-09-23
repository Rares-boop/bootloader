# Bootloader

A bare metal x86 bootloader written from scratch in NASM assembly and C. No OS, no libraries, no runtime — just raw code that runs directly on the CPU at boot.

When a PC powers on, the BIOS loads the first 512 bytes from disk into memory at address `0x7C00`, checks for the `0xAA55` boot signature, and jumps there. Everything after that is up to you. This project builds a bootloader incrementally, from a simple "hello world" on a black screen to loading a C kernel in 32-bit protected mode.

## What it does

**Stage 1** (`boot.asm`) — the 512-byte boot sector. Sets up segment registers and stack in 16-bit real mode, prints a welcome message using BIOS interrupt `INT 10h`, reads the second sector from disk via `INT 13h`, and jumps to stage 2.

**Stage 2** (`stage2.asm`) — loaded by stage 1 at address `0x7E00`. Prints a status message, reads the kernel from disk into memory at `0x1000`, builds a Global Descriptor Table (GDT) with null, code, and data segment descriptors, disables interrupts, sets the PE bit in `CR0`, performs a far jump into 32-bit protected mode, writes directly to VGA text buffer at `0xB8000` to confirm the switch, and jumps to the kernel.

**Kernel** (`kernel/`) — a freestanding C kernel loaded by stage 2. `kernel_entry.asm` provides the entry point and calls `main()` in `kernel.c`, which writes directly to video memory at `0xB8000` without any OS, libc, or runtime.

## Build & Run

```bash
nasm -f bin boot.asm -o boot.bin
nasm -f bin stage2.asm -o stage2.bin
nasm -f elf32 kernel/kernel_entry.asm -o kernel/kernel_entry.o
gcc -m32 -ffreestanding -c kernel/kernel.c -o kernel/kernel.o
ld -m elf_i386 -T kernel/linker.ld kernel/kernel_entry.o kernel/kernel.o -o kernel/kernel.elf
objcopy -O binary kernel/kernel.elf kernel/kernel.bin
cat boot.bin stage2.bin kernel/kernel.bin > os.bin
qemu-system-i386 -drive format=raw,file=os.bin
```

Requires NASM, GCC (32-bit), binutils, and QEMU (`sudo apt install nasm gcc-multilib binutils qemu-system-x86`).
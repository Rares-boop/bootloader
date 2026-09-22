# Bootloader

A bare metal x86 bootloader written from scratch in NASM assembly. No OS, no libraries, no runtime — just raw code that runs directly on the CPU at boot.

When a PC powers on, the BIOS loads the first 512 bytes from disk into memory at address `0x7C00`, checks for the `0xAA55` boot signature, and jumps there. Everything after that is up to you. This project builds a bootloader incrementally, from a simple "hello world" on a black screen to loading a kernel in 32-bit protected mode.

## What it does

**Stage 1** (`boot.asm`) — the 512-byte boot sector. Sets up segment registers and stack in 16-bit real mode, prints a welcome message using BIOS interrupt `INT 10h`, reads the second sector from disk via `INT 13h`, and jumps to stage 2.

**Stage 2** (`stage2.asm`) — loaded by stage 1 at address `0x7E00`. Prints a status message, builds a Global Descriptor Table (GDT) with null, code, and data segment descriptors, disables interrupts, sets the PE bit in `CR0`, performs a far jump into 32-bit protected mode, and writes directly to VGA text buffer at `0xB8000` to confirm the switch.

## Build & Run

```bash
nasm -f bin boot.asm -o boot.bin
nasm -f bin stage2.asm -o stage2.bin
cat boot.bin stage2.bin > os.bin
qemu-system-i386 -drive format=raw,file=os.bin
```

Requires NASM and QEMU (`sudo apt install nasm qemu-system-x86`).
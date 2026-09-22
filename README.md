# Bootloader

A bare metal x86 bootloader written from scratch in NASM assembly. No OS, no libraries, no runtime — just raw code that runs directly on the CPU at boot.

When a PC powers on, the BIOS loads the first 512 bytes from disk into memory at address `0x7C00`, checks for the `0xAA55` boot signature, and jumps there. Everything after that is up to you. This project builds a bootloader incrementally, from a simple "hello world" on a black screen to loading a kernel in 32-bit protected mode.

## Build & Run

```bash
nasm -f bin boot.asm -o boot.bin
qemu-system-i386 -floppy boot.bin
```

Requires NASM and QEMU (`sudo apt install nasm qemu-system-x86`).
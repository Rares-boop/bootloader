
; GDT - Global Descriptor Table describes the segments
; entry - full description of a memory segment
; Byte 0-1:  Limit (bits 0-15)         — segment size (lower 16 bits)
; Byte 2-4:  Base (bits 0-23)          — segment start address (lower 24 bits)
; Byte 5:    Access byte               — permissions: present, privilege level (ring), type, read/write/execute
; Byte 6:    Flags (4 bits)            — granularity (byte or 4KB pages), 16-bit or 32-bit mode
;            + Limit bits 16-19        — segment size (upper 4 bits)
; Byte 7:    Base (bits 24-31)         — segment start address (upper 8 bits)

ORG 0x7E00
BITS 16

mov si, message

_print:
    mov al, [si]
    inc si
    cmp al, 0
    jz _load_kernel
    mov ah, 0x0E
    int 10h
    jmp _print

_load_kernel:
    mov ah, 0x02      ; citire sectoare
    mov al, 5         ; 5 sectoare (destul pentru kernel mic)
    mov ch, 0         ; cilindru 0
    mov cl, 3         ; sector 3 (1=boot, 2=stage2, 3+=kernel)
    mov dh, 0         ; head 0
    mov dl, 0x80      ; hard disk
    mov bx, 0x1000    ; adresa unde pui kernel-ul (ES:BX = 0x0000:0x1000)
    int 13h

_switch:
    cli ; stop the CPU from responding to interrupts (in order to swich from 16-bit to 32-bit)
    lgdt [_gdt_descriptor] ; load the GDT into GDTR
    ; CR0 Control Register 0 special CPU register which can activate/deactivate CPU functionalities
    ; bit 0 from CR0 register is PE (Protection Enable) and when it is set the CPU enters protected mode
    ; since CR0 is not a regular register we cannot or cr0, 1
    ; mov eax, cr0 special directive
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    ; simple jmp changes only th IP (instruction pointer)
    ; far jump changes the CS (code segment)
    jmp 0x08:_protected_mode ; this is a far jump it changes CS at 0x08 and jumps to the new label

BITS 32
_protected_mode:
    mov ax, 0x10 ; data segment offset in GDT
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, 0x90000 ; new stack and a safe address in 32-bit

_print_protected:
    ; row 10 × 80 columns × 2 bytes per char = 1600 = 0x640
    mov byte [0xB8000 + 0x640], 'P' ; the character
    mov byte [0xB8001 + 0x640], 0x0F ; the colour white on black
    mov byte [0xB8002 + 0x640], 'M'
    mov byte [0xB8003 + 0x640], 0x0F
    jmp 0x1000

message db 'Stage 2 loading', 0x0D, 0x0A, 0

_gdt_start:

_gdt_null:
    dd 0x00000000
    dd 0x00000000

_gdt_code:
    dw 0xFFFF      ; Limit bits 0-15
    dw 0x0000      ; Base bits 0-15
    db 0x00        ; Base bits 16-23
    db 10011010b   ; Access byte: present=1, ring 0=00, type=1, executable=1, readable=1, accessed=0
    db 11001111b   ; Flags: granularity=1 (4KB pages), 32-bit=1 + Limit bits 16-19 = 1111
    db 0x00        ; Base bits 24-31

_gdt_data:
    dw 0xFFFF      ; Limit bits 0-15
    dw 0x0000      ; Base bits 0-15
    db 0x00        ; Base bits 16-23
    db 10010010b   ; Access byte: present=1, ring 0=00, type=1, writable=1, readable=1, accessed=0
    db 11001111b   ; Flags: same as code segment
    db 0x00        ; Base bits 24-31

_gdt_end:

_gdt_descriptor:
    dw  _gdt_end - _gdt_start -  1 ; GDT size
    dd  _gdt_start ; GDT address

times 512 - ($ - $$) db 0 ; padding so the stage 2 sector is exactly 512 bytes




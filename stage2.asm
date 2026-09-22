
ORG 0x7E00
BITS 16

mov si, message

_print:
    mov al, [si]
    inc si
    cmp al, 0
    jz _done
    mov ah, 0x0E
    int 10h
    jmp _print

_done:
    jmp $

message db 'Stage 2 loaded complete', 0



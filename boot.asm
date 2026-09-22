; this is a initial bootloader file
; Offset 0x000 - 0x1FD  →  codul tău (510 bytes disponibili)
; Offset 0x1FE - 0x1FF  →  signatura 0xAA55 (obligatorie)
; boot file order code -> halt -> data -> padding -> signature


ORG 0x7C00 ; directive which tells the assembler that the code will be loaded at this address (BIOS has boot sector here)
BITS 16 ; real mode 

; set the segment registers (CPU does not allow arithmetic or logic operations on those)
; physical address = segment * 16 + offset
; CS - Code Segment where the code executes
; DS - Data Segment used when accessing data from memory (mov al, [message] -> CPU calculates DS * 16 + message)
; ES - Extra Segment for string operations
; SS - Stack Segment where the stack is (push and pop use SS:SP as address)

xor ax, ax
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7C00 ; set the stack

; print the message
mov si, message ; load the message

_print:
    mov al, [si] ; take the byte from si address
    inc si ; increment si with 1 so the pointer move to the next byte
    cmp al, 0 ; compare with 0 to see if we reached the end of the string
    jz _done ; exit the loop
    mov ah, 0x0E ; teletype funtion for printing on scree the character
    int 10h ; interrupt for video funtions
    jmp _print

_done:
    jmp $ ; halt for infinite loop

; define the data
message db 'Hello from bare metal!', 0

; padding + signature
; $$ - start address of the file
; $ - current address
; $ - $$ - number of bytes written (code + strings + everything)
; 510 - ($ - $$) - number of bytes till 510 position
; times N db 0 - repeats db 0 N times (files the boot sector with 0 if we have space remaining)
; dw 0xAA55 - boot signature

times 510 - ($ - $$) db 0
dw 0xAA55



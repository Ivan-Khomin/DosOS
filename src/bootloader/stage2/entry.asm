bits 16

section .entry

extern __bss_section
extern __end

extern start
global entry

entry:
    cli
    mov [bootDrive], dl

    ; setup segment registers
    mov ax, ds
    mov ss, ax

    ; setup stack
    mov sp, 0
    mov bp, sp
    sti

    ; clear bss
    mov ecx, __end
    mov edi, __bss_section
    sub ecx, edi
    mov al, 0
    cld
    rep stosb

    ; put boot drive in dl, send it as argument to start function
    xor dx, dx
    mov dl, [bootDrive]
    push dx
    call start

    cli
    hlt

bootDrive:  db 0
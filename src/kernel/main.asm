org 0x0
bits 16

start:
    mov si, msg
    call Print

    cli
    hlt
    
Print:
    push si
    push ax
    push bx

.loop:
    lodsb
    or al, al
    jz .ret

    mov ah, 0Eh
    mov bh, 0
    int 10h
    jmp .loop

.ret:
    pop si
    pop ax
    pop bx

    ret

msg: db 'Hello world from kernel!', 0Ah, 0Dh, 0
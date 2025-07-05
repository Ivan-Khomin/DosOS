;
; Prototype: void __attribute__((cdecl)) x86_outb(uint16_t port, uint8_t value)
;
global x86_outb
x86_outb:
    mov dx, [esp + 4]
    mov al, [esp + 8]
    out dx, al
    ret

;
; Prototype: uint8_t __attribute__((cdecl)) x86_inb(uint16_t port)
;
global x86_inb
x86_inb:
    mov dx, [esp + 4]
    xor eax, eax
    in al, dx
    ret
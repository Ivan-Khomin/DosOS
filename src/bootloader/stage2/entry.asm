bits 16

section .entry

extern __bss_section
extern __end

extern start
global entry

entry:
    cli
    mov [bootDrive], dl

    mov ax, ds
    mov ss, ax
    mov sp, 0xFFF0
    mov bp, sp

    ; switch to protected mode
    call EnableA20
    call LoadGDT

    ; set protection enable flag in cr0
    mov eax, cr0
    or al, 1
    mov cr0, eax

    ; far jump into protected mode
    jmp dword 08h:.pmode

.pmode:
    [bits 32]
    ; setup registers
    mov ax, 0x10
    mov ds, ax
    mov ss, ax

    ; clear bss
    mov edi, __bss_section
    mov ecx, __end
    sub ecx, edi
    mov al, 0
    cld
    rep stosb

    ; put boot drive in dl, send it as argument to start function
    xor edx, edx
    mov dl, [bootDrive]
    push edx
    call start

    cli
    hlt

LoadGDT:
    [bits 16]
    lgdt [GDTDesc]
    
    ret

EnableA20:
    [bits 16]
    ; disable keyboard
    call A20WaitInput
    mov al, KbdControllerDisableKeyboard
    out KbdControllerCommandPort, al

    ; read control output port
    call A20WaitInput
    mov al, KbdControllerReadCtrlOutputPort
    out KbdControllerCommandPort, al

    call A20WaitInput
    in al, KbdControllerDataPort
    push eax

    ; write control output port
    call A20WaitInput
    mov al, KbdControllerWriteCtrlOutputPort
    out KbdControllerCommandPort, al

    call A20WaitInput
    pop eax
    or al, 2                                    ; bit 2 = A20 bit
    out KbdControllerDataPort, al

    ; enable keyboard
    call A20WaitInput
    mov al, KbdControllerEnableKeyboard
    out KbdControllerCommandPort, al

    call A20WaitInput

    ret

A20WaitInput:
    [bits 16]
    ; wait until status bit 2 (input buffer) is 0
    ; by reading from command port, we read status byte
    in al, KbdControllerCommandPort
    test al, 2
    jnz A20WaitInput

    ret

A20WaitOutput:
    [bits 16]
    ; wait until status bit 1 (output buffer) is 1 so it can be read
    in al, KbdControllerCommandPort
    test al, 1
    jz A20WaitOutput

    ret

KbdControllerDataPort               equ 0x60
KbdControllerCommandPort            equ 0x64
KbdControllerEnableKeyboard         equ 0xAE
KbdControllerDisableKeyboard        equ 0xAD
KbdControllerReadCtrlOutputPort     equ 0xD0
KbdControllerWriteCtrlOutputPort    equ 0xD1

GDTD:       ; NULL descriptor
            dq 0

            ; 32 bit code segment
            dw 0FFFFh                           ; limit (bits 0-15)
            dw 0                                ; base (bits 0-15)
            db 0                                ; base (bits 16-23)
            db 10011010b                        ; access (present, ring 0, code segment, executable, direction 0, readable)
            db 11001111b                        ; granularity (4k pages, 32-bit pmode) + limit (bits 16-19)
            db 0                                ; base high

            ; 32 bit data segment
            dw 0FFFFh                           ; limit (bits 0-15)
            dw 0                                ; base (bits 0-15)
            db 0                                ; base (bits 16-23)
            db 10010010b                        ; access (present, ring 0, data segment, executable, direction 0, writable)
            db 11001111b                        ; granularity (4k pages, 32-bit pmode) + limit (bits 16-19)
            db 0                                ; base high

            ; 16 bit code segment
            dw 0FFFFh                           ; limit (bits 0-15)
            dw 0                                ; base (bits 0-15)
            db 0                                ; base (bits 16-23)
            db 10011010b                        ; access (present, ring 0, code segment, executable, direction 0, readable)
            db 00001111b                        ; granularity (1b pages, 16-bit pmode) + limit (bits 16-19)
            db 0                                ; base high

            ; 16 bit data segment
            dw 0FFFFh                           ; limit (bits 0-15)
            dw 0                                ; base (bits 0-15)
            db 0                                ; base (bits 16-23)
            db 10010010b                        ; access (present, ring 0, data segment, executable, direction 0, writable)
            db 00001111b                        ; granularity (1b pages, 16-bit pmode) + limit (bits 16-19)
            db 0                                ; base high

GDTDesc:    dw GDTDesc - GDTD - 1               ; limit = size of GDT - 1
            dd GDTD                             ; address of GDT

bootDrive:  db 0
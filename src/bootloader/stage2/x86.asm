bits 16

;
; Prototype: void ASMCALL x86_Video_WriteCharTTY(char c, uint8_t page)
; Write character in teletype mode
;
global x86_Video_WriteCharTTY
x86_Video_WriteCharTTY:
    ; make new call frame
    push bp
    mov bp, sp

    ; save bx
    push bx

    mov ah, 0Eh
    mov al, [bp + 4]
    mov bh, [bp + 6]
    int 10h

    ; restore bx
    pop bx

    ; restore old call frame
    mov sp, bp
    pop bp

    ret

;
; bool ASMCALL x86_Disk_GetDriveParameters(uint8_t drive,
;                                          uint8_t* driveType,
;                                          uint16_t* cylinders,
;                                          uint16_t* heads,
;                                          uint16_t* sectors)
; Get drive parameters
;
global x86_Disk_GetDriveParameters
x86_Disk_GetDriveParameters:
    ; make new call frame
    push bp
    mov bp, sp

    ; save registers
    push es
    push di
    push si
    push bx

    ; put drive in dl and invoke int13h
    mov dl, [bp + 4]
    mov ah, 08h
    mov di, 0
    mov es, di                              ; 0:0
    stc
    int 13h

    ; return params
    mov ax, 1
    sbb ax, 0

    ; drive type from bl
    mov si, [bp + 6]
    mov [si], bl

    ; cylinders
    mov bl, ch                              ; cylinders - lower 8 bits
    mov bh, cl                              ; cylinder - upper 2 bits
    shr bh, 6
    mov si, [bp + 8]
    mov [si], bx

    ; heads
    xor bx, bx
    mov bl, dh
    mov si, [bp + 10]
    mov [si], bx

    ; sectors
    xor ch, ch
    and cl, 3Fh                             ; sectors - lower 5 bits in cl
    mov si, [bp + 12]
    mov [si], cx

    ; restore registers
    pop bx
    pop si
    pop di
    pop es

    ; restore old call frame
    mov sp, bp
    pop bp

    ret

;
; bool ASMCALL x86_Disk_Read(uint8_t drive,
;                            uint16_t cylinder,
;                            uint16_t head,
;                            uint16_t sector,
;                            uint8_t count,
;                            void far* data)
; Read data from disk
;
global x86_Disk_Read
x86_Disk_Read:
    ; make new call frame
    push bp
    mov bp, sp

    ; save registers
    push es
    push bx

    ; setup vars
    mov dl, [bp + 4]                        ; drive in dl

    mov ch, [bp + 6]                        ; cylinder (lower 8 bits)
    mov cl, [bp + 7]                        ; cylinder (upper 2 bits)
    shl cl, 6

    mov dh, [bp + 8]                        ; head

    mov al, [bp + 10]                       ; sectors (0-5 bits)
    and al, 3Fh
    or cl, al

    mov al, [bp + 12]                       ; sectors count

    mov bx, [bp + 16]                       ; es:bx - far pointer
    mov es, bx                              ; segment
    mov bx, [bp + 14]                       ; offset
    
    ; call int13h
    mov ah, 02h
    stc
    int 13h
    
    ; return params
    mov ax, 1
    sbb ax, 0

    ; restore registers
    pop bx
    pop es

    ; restore old call frame
    mov sp, bp
    pop bp

    ret

;
; Prototype: bool ASMCALL x86_Disk_Reset(uint8_t drive)
; Reset disk controller from drive
;
global x86_Disk_Reset
x86_Disk_Reset:
    ; make new call frame
    push bp
    mov bp, sp

    ; put drive in dl and call int13h
    mov dl, [bp + 4]
    mov ah, 0
    stc
    int 13h

    ; return params
    mov ax, 1
    sbb ax, 0

    ; restore old call frame
    mov sp, bp
    pop bp

    ret
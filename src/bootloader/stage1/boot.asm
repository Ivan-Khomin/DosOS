org 0x7C00
bits 16

;
; FAT header
;
jmp short start
nop

Oem:                    db 'DOS_OS25'
BytesPerSector:         dw 512
SectorsPerCluster:      db 1
ReservedSectors:        dw 1
FatCount:               db 2
RootDirEntries:         dw 0E0h
TotalSectors:           dw 2880
MediaDescriptorType:    db 0F0h
SectorsPerFat:          dw 9
SectorsPerTrack:        dw 18
Heads:                  dw 2
HiddenSectors:          dd 0
LargeSectorCount:       dd 0

DriveNumber:            db 0
                        db 0
Signature:              db 29h
VolumeId:               db 12h, 34h, 56h, 78h
VolumeLabel:            db 'NO NAME    '
SystemId:               db 'FAT12   '

start:
    ; setup registers
    xor ax, ax
    mov ds, ax
    mov es, ax
    
    ; setup stack
    mov ss, ax
    mov sp, 0x7C00

    push es
    push word .loadingStage2
    retf

.loadingStage2:
    mov si, msg
    call Print

    ; compute LBA of root directory
    mov ax, [SectorsPerFat]
    mov bl, [FatCount]
    xor bh, bh
    mul bx
    add ax, [ReservedSectors]
    push ax

    ; compute size of root directory
    mov ax, [RootDirEntries]
    shl ax, 5
    xor dx, dx
    div word [BytesPerSector]
    jz .readRootDirectory

    inc ax

.readRootDirectory:
    mov cl, al
    mov [dataSectionLba], ax
    pop ax
    add [dataSectionLba], ax
    mov dl, [DriveNumber]
    mov bx, buffer
    call ReadSectors
    jc ReadFailedError

    xor bx, bx
    mov di, buffer

.searchStage2:
    mov si, fileStage2Bin
    mov cx, 11                                      ; 11 chars to compare
    push di
    repe cmpsb
    pop di
    je .foundStage2

    add di, 32
    inc bx
    cmp bx, [RootDirEntries]
    jl .searchStage2

    jmp Stage2NotFoundError

.foundStage2:
    mov ax, [di + 26]                               ; first cluster low
    mov [stage2Cluster], ax

    ; load FAR from disk into memory
    mov ax, [ReservedSectors]
    mov cl, [SectorsPerFat]
    mov dl, [DriveNumber]
    mov bx, buffer
    call ReadSectors
    jc ReadFailedError

    mov bx, STAGE2_SEGMENT
    mov es, bx
    mov bx, STAGE2_OFFSET

.loadStage2:
    mov ax, [stage2Cluster]
    sub ax, 2
    mul byte [SectorsPerCluster]
    mov cx, [dataSectionLba]
    add ax, cx

    mov cl, [SectorsPerCluster]
    mov dl, [DriveNumber]
    call ReadSectors
    jc ReadFailedError

    add bx, [BytesPerSector]

    mov ax, [stage2Cluster]
    mov cx, 3
    mul cx
    mov cx, 2
    div cx

    mov si, buffer
    add si, ax
    mov ax, [ds:si]

    test dx, dx
    jz .evenCluster

.oddCluster:
    shr ax, 4
    jmp .nextCluster

.evenCluster:
    and ax, 0x0FFF

.nextCluster:   
    cmp ax, 0x0FF8
    jae .executeStage2

    mov [stage2Cluster], ax
    jmp .loadStage2

.executeStage2:
    ; executing stage2
    mov dl, [DriveNumber]                           ; store drive number in dl

    ; setup registers
    mov ax, STAGE2_SEGMENT
    mov ds, ax
    mov es, ax

    ; jump to our stage2
    jmp STAGE2_SEGMENT:STAGE2_OFFSET

    jmp WaitToReboot

    cli
    hlt

;
; Print text on screen
; Parameters:
;   ds:si - string
;
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

;
; Working with disk
;

;
; Converts LBA address to CHS
; Parametes:
;   ax - LBA
; Returns:
;   cx [0-5 bits] - sector
;   cx [6-15 bits] - cylinder
;   dh - head
;
LBA2CHS:
    push ax
    push dx

    xor dx, dx
    div word [SectorsPerTrack]

    inc dx
    mov cx, dx

    xor dx, dx
    div word [Heads]

    mov dh, dl
    mov ch, al
    shl ah, 6
    or cl, ah

    pop ax
    mov dl, al
    pop ax
    
    ret

;
; Reads sectors from a disk
; Parameters:
;   - ax: LBA address
;   - cl: number of sectors to read (up to 128)
;   - dl: drive number
;   - es:bx: memory address where to store read data
;
ReadSectors:
    push ax
    push bx
    push cx
    push dx
    push di

    push cx
    call LBA2CHS
    pop ax
    
    mov ah, 02h
    mov di, 3

.retry:
    pusha
    stc
    int 13h
    jnc .done

    popa
    mov ah, 0
    int 13h

    dec di
    test di, di
    jnz .retry

.done:
    popa
    pop di
    pop dx
    pop cx
    pop bx
    pop ax

    ret

;
; Errors
;

ReadFailedError:
    mov si, msgReadFailed
    call Print
    jmp WaitToReboot

Stage2NotFoundError:
    mov si, msgStage2NotFound
    call Print
    jmp WaitToReboot

WaitToReboot:
    mov ah, 0
    int 16h
    jmp 0FFFFh:0h

msg:                    db 'Loading...', 0Dh, 0Ah, 0
msgReadFailed:          db 'Read from disk failed!', 0Dh, 0Ah, 0
msgStage2NotFound:      db 'stage2.bin not found!', 0Dh, 0Ah, 0
fileStage2Bin:          db 'STAGE2  BIN'

dataSectionLba:         dw 0
stage2Cluster:          dw 0

STAGE2_SEGMENT:         equ 0x0000
STAGE2_OFFSET:          equ 0x0500

times 510 - ($ - $$) db 0
dw 0AA55h

buffer:
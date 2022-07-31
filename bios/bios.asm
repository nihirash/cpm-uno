BOOT:	JP	bios.boot		
WBOOT:	JP	bios.wboot
CONST:	JP	keyboard.read_status
CONIN:	JP	keyboard.read
CONOUT:	JP	display.write
LIST:	JP	bios.nothing
PUNCH:	JP	bios.nothing
READER:	JP	bios.nothing
HOME:	JP	disk.home
SELDSK:	JP	disk.seldsk
SETTRK:	JP	disk.settrk
SETSEC:	JP	disk.setsec
SETDMA:	JP	disk.set_dma
READ:	JP	disk.read
WRITE:	JP	disk.write
PRSTAT:	JP	bios.nothing
SECTRN:	JP	disk.sectran

    macro localStack
    di
    ld (bios.int_handler.sp_save), sp
    ld sp, #fffe
    push af, bc, de, hl,ix,iy
    exx
    push af, bc, de, hl,ix,iy
    endm

    macro usualStack
    pop iy,ix,hl, de, bc, af
    exx
    pop iy,ix,hl, de, bc, af
    ld sp, (bios.int_handler.sp_save)
    endm

    module bios
int_handler:
    localStack
    call    keyboard.update
    usualStack
    ei
    reti
.sp_save dw 0

nothing:
    ld a, #ff
    ret
boot:
    di
    im 1
    ld sp, #fffe
    ld a, 3 : ld bc, #7ffd : out (c), a

    call drive.init
    call display.init

    ld a, %00000101 : ld bc, #1ffd : out (c),a
    
    ld hl, CBASE
    ld de, ccp_backup
    ld bc, FBASE-CBASE
    ldir
    ld a, %00000001 : ld bc, #1ffd : out (c),a

    ld hl, welcome
    call bios_print


    call disk.init
wboot:
    di
    ld a,%00000101 : ld bc, #1ffd : out (c),a
    ld sp, cpm-1
    ld hl, ccp_backup
    ld de, CBASE
    ld bc, FBASE-CBASE
    ldir
    ld a,%00000001 : ld bc, #1ffd : out (c),a
     
    call gocpm
    jp COMMAND

gocpm:
; Setup jump table
    ld a, #0c3
    ld (0),a
    ld hl, WBOOT
    ld (1), hl
    
    ld (5), a
    ld hl, FBASE 
    ld (6), hl

    ld bc, #80
    call   SETDMA

    call install_int

    im 1
    ei

    ld c, 0
    call SELDSK
    call HOME
    ret

install_int:
    ld (.set_a),a
    ld (.set_hl), hl
    ld a, #0c3
    ld (#38),a
    ld hl, int_handler
    ld (#39), hl
    ld a,0
.set_a = $ -1
    ld hl, 0
.set_hl = $ - 2
    ret

bios_print:
    ld a, (hl)
    and a 
    ret z
    inc hl
    push hl : call display.putC : pop hl
    jr bios_print

welcome db "Stop the war in Ukraine!", 13, 10, 13, 10
        db "ZXUno CP/M 2.2",13,10
        db "+3 MMU and Timex screen BIOS v.0.1",13, 10
        db "2022 (c) Nihirash",13,10,13,10
        db "BDOS and CCP v 2.2",13,10
        db "1979 (c) Digital research",13,10,13,10
        db 0

    endmodule

    include "disk.asm"
    include "display.asm"
    include "keyboard.asm"
    include "divmmc.asm"
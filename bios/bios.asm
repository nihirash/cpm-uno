BOOT:	JP	bios.boot		
WBOOT:	JP	bios.wboot
CONST:	JP	console.status
CONIN:	JP	console.in
CONOUT:	JP	console.out
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
    ld sp, #ffff
    push af, bc, de, hl,ix,iy
    exx
    push af, bc, de, hl,ix,iy
    exx
    endm

    macro usualStack
    exx
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
    ld sp, #ffff
    ld a, 3 : ld bc, #7ffd : out (c), a

    call drive.init
    call display.init
    call uart.init

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
    ld bc, #ff
    ld hl, 0
    ld de, 1
    xor a: ld (hl), a
    ldir
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
    
    ld a, 1 : ld (IOBYTE),a
    
    call install_int

    ld c, 0
    call SELDSK
    call HOME
    im 1
    ei

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

welcome db 26, "Stop the war in Ukraine!", 13, 10, 13, 10
        db "ZXUno CP/M port",13,10
        db "+3 MMU and Timex screen BIOS v.0.1",13, 10
        db "2022 (c) Nihirash",13,10,13,10
        db "BDOS and CCP v 2.2 with patches",13,10
        db "1979 (c) Digital research",13,10
        db "2022 (c) Nihirash",13,10,13,10
        db 0

    endmodule

    include "disk.asm"
    include "display.asm"
    include "console.asm"
    include "keyboard.asm"
    include "divmmc.asm"
    include "uart.asm"
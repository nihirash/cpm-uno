    module drive
mmc_en = #e7
mmc_data = #eb
slot1 = #fe

CMD_12    EQU 0x4C    ;STOP_TRANSMISSION
CMD_17    EQU 0x51    ;READ_SINGLE_BLOCK
CMD_18    EQU 0x52    ;READ_MULTIPLE_BLOCK
CMD_24    EQU 0x58    ;WRITE_BLOCK
CMD_25    EQU 0x59    ;WRITE_MULTIPLE_BLOCK
CMD_55    EQU 0x77    ;APP_CMD
CMD_58    EQU 0x7A    ;READ_OCR
CMD_59    EQU 0x7B    ;CRC_ON_OFF
ACMD_41   EQU 0x69   ;SD_SEND_OP_COND

    macro mmc_cs_en
        push af
        ld a, slot1 : out (mmc_en), a
        pop af
    endm

    macro mmc_cs_dis
        push af
        ld a, #ff : out (mmc_en), a
        pop af
    endm

init:
    mmc_cs_dis
    ld bc, mmc_data
    ld de, #20FF        ; Just flush all data from SD buffer
.init_loop
    out (c), e
    dec d
    jr nz, .init_loop
.zaw001
    ld hl, CMD00 : call outcom : call in_oout
    dec a
    jr  nz, .zaw001 ; If response not eq 1 - retry
    ld hl, CMD08 : call outcom : call in_oout
    dup 4
    in h, (c) : nop ; We don't care about result 
    edup
    ld hl, 0
    bit 2, a
    jr  nz, .zaw006
    ld h, #40   ; Looks like it's SDHC
.zaw006
    ld a, CMD_55 : call out_com : call in_oout
    in (c) : in (c)
    ld a, ACMD_41 : out (c), a : nop
    out (c), h : nop
    out (c), l : nop
    out (c), l : nop
    out (c), l : nop
    ld a, #ff : out (c), a : call in_oout
    and a
    jr nz, .zaw006
.zaw004 ; Disable CRC
    ld a, CMD_59 : call out_com 
    call in_oout : and a
    jr nz, .zaw004
.zaw005 ; Force 512b block
    ld hl, CMD16 : call outcom 
    call in_oout : and a
    jr nz, .zaw005

    ld a, CMD_58 : ld bc, mmc_data
    call out_com : call in_oout
    in a, (c) : nop
    in h, (c) : nop
    in h, (c) : nop
    in h, (c) : nop
    and #40
    ld (blsize), a
    mmc_cs_dis
    ret

secm200:
    push hl
    push af
    ld h, b 
    ld l, c
    ld bc, mmc_data
    mmc_cs_en
    ld a, 00
blsize = $ - 1
    or a
    jr nz, .secn200
    ex de, hl
    add hl, hl
    ex de, hl
    adc hl, hl
    ld h, l
    ld l, d
    ld d, e
    ld e, 0
.secn200
    pop af
    in (c) : in (c)
    out (c), a : nop
    out (c), h : nop
    out (c), l : nop
    out (c), d : nop
    out (c), e : nop
    ld a, #ff : out (c), a
    pop hl
    ret

;; BCDE - LBA addr
;; HL - dma buff
read:
    ld a, CMD_17 : call secm200
.rd1
    call in_oout
    cp #fe
    jr nz, .rd1
    ld bc, mmc_data
    inir : nop
    inir : nop
    in a, (c) : nop
    in a, (c) : nop
    mmc_cs_dis
    ret

write:
    di
    ld a, CMD_25 : call secm200
.wait1
    call in_oout 
    inc a
    jr nz, .wait1
    ld a, #fc : ld bc, mmc_data : out (c), a : nop
    ld b, #80 : otir : nop
    ld b, #80 : otir : nop
    ld b, #80 : otir : nop
    ld b, #80 : otir : nop

    ld a, #ff : out (c),a : nop
    ld a, #ff : out (c),a : nop
.wait2
    call in_oout
    inc a
    jr nz, .wait2
    ld c, mmc_data : ld a, #fd
    out (c),a
.wait3    
    call in_oout
    inc a
    jr nz, .wait3

    mmc_cs_dis
    ret
    
outcom:
    mmc_cs_en
    ld bc, #600+mmc_data ; 6 is loop counter
    otir
    ret


out_com:
    push af
    mmc_cs_en
    pop af
    ld bc, mmc_data
    in (c)
    in (c)
    out (c), a
    xor a
    out (c), a : nop
    out (c), a : nop
    out (c), a : nop
    out (c), a : nop
    dec a : out (c), a
    ret

in_oout:
    di
    push de
    ld   de, #20ff
    ld    b, mmc_data
.in_wait
    in a, (c)
    cp e
    jr nz, .in_exit
.in_next
    dec d
    jr nz, .in_wait
.in_exit
    pop de
    ret


CMD00    db  0x40,0x00,0x00,0x00,0x00,0x95 ;GO_IDLE_STATE
CMD08    db  0x48,0x00,0x00,0x01,0xAA,0x87 ;SEND_IF_COND
CMD16    db 0x50,0x00,0x00,0x02,0x00,0xFF ;SET_BLOCKEN

buffer  ds 512
    endmodule
    DEVICE ZXSPECTRUM128
    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION

    
    DEFINE SPECCY_SCR
    DEFINE DIVMMC
;   DEFINE TIMEX_SCR
;   DEFINE ZXUNO
;   DEFINE ZC

    org 0x8000
stack_top:
main:
    di
    ld bc, #7ffd : ld a, 6 : out (c),a
    ld hl, page6
    ld de, #c000
    ld bc,page6_len
    ldir
     

    ld bc, #7ffd : ld a, 3 : out (c),a
    ld hl, cpm
    ld de, cpm_start
    ld bc, cpm_size
    ldir

    jp  cpm_start
page6:
    DISP #8000
    include "bios/offload.asm"
    ENT
page6_len = $ - page6

cpm:
    DISP $d5b0
    DISPLAY "CP/M starts here: ", $
cpm_start:
    jp BOOT
    include "cpm.asm"
cpm_size = $ - cpm_start
    ENT

    save3dos "cpm.sys", main, $-main
    savesna "test.sna", main
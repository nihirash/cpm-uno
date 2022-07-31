    module disk
set_dma:
    ld hl, bc
    ld (dma_addr), hl
    ret

seldsk:
    ld hl, 0
    ld a, c
    cp 2
    jr nc, .exit
    ld (cur_drive), a
    ld hl, dpbase    
.exit
    ret

settrk:
    ld hl, bc
    ld (disk_trk), hl
    ret

setsec:
    ld hl, bc
    ld (disk_sec), bc
    ret

home:
    ld hl, 0
    ld (disk_sec), hl
    ld (disk_trk), hl
    xor a
    ret

checksect:
    call calc_offset
    ld hl, (cur_sect)
    ld a, h : cp b : jr nz, .do_read
    ld a, l : cp c : jr nz, .do_read
    ld hl, (cur_sect + 2)
    ld a, h : cp d : jr nz, .do_read
    ld a, l : cp e : jr nz, .do_read
    ret 
.do_read
    ld (cur_sect), bc
    ld (cur_sect + 2), de
    ld hl, sec_buffer
    call drive.read
    ret

read:
    call checksect

    ld a, (disk_sec)
    and 3
    ld hl, sec_buffer
    ld de, 128
    jr z, .copy
.offset    
    add hl, de
    dec a
    jr nz, .offset
.copy
    ld de, (dma_addr)
    ld bc, 128
    ldir
    xor a
    ret

write:
    call checksect
    
    ld a, (disk_sec)
    and 3
    ld hl, sec_buffer
    ld de, 128
    jr z, .copy
.offset    
    add hl, de
    dec a
    jr nz, .offset
.copy
    ex de, hl
    ld hl, (dma_addr)
    ld bc, 128
    ldir

    ld bc, (cur_sect)
    ld de, (cur_sect + 2)
    ld hl, sec_buffer
    call drive.write
    xor a
    ret

sectran:
    ld hl, bc
    ret

calc_offset:
    ld a, (cur_drive)
    ld ix, drives_offsets
    and a : jr z, .calc
    ld bc, 3
.offset
    add ix, bc
    dec a
    jr nz, .offset
.calc
    ld hl,(disk_trk)
    ld de,(disk_sec)
   
    srl d
    rr e
    srl d
    rr e

   
    ld b, 0
    ld c, (ix + 2)
    add hl,bc
    srl l
    jr nc, .sec1
    ld d, 1
.sec1
    ld a, h
    and 1
    jr z, .sec2
    ld a, l
    or #80
    ld l, a
.sec2
    ld h, 0
    ld b, (ix + 1)
    ld c, (ix + 0)
    add hl, bc
    call chs_to_sector

    ld bc, hl
    ret

dma_addr dw 0
disk_sec dw 0 
disk_trk dw 0
cur_drive db 0

IDEDOS_PE_START_CYL_LO    equ 0x11
IDEDOS_PE_START_CYL_HI    equ 0x12
IDEDOS_PE_START_HEAD      equ 0x13
IDEDOS_PE_END_CYL_LO      equ 0x14
IDEDOS_PE_END_CYL_HI      equ 0x15
IDEDOS_PE_END_HEAD        equ 0x16

init:
    di
    call load_part_table : jp nz, .error1

    ld a,0 : ld (cur_drive),a : ld iy, partition_1 : call find_partition
    ld a,1 : ld (cur_drive),a : ld iy, partition_2 : call find_partition
    ret

.error1
    ld hl, .error1msg
    call bios.bios_print
    ret
.error1msg db 13, 10, "[ERROR] Didn't found partition table", 13, 10, 0

find_partition:
    ld bc, 0  : ld de, (part_table_offset) : ld hl, sec_buffer
    call drive.read

    ld ix, sec_buffer
    ld b, 8 ; Partitions per sector
.loop
    ld a, (ix + #10) ; Partition type
    and a : jp z, .unused 
    ld a, (ix + 0) : cp (iy + 0) : jp nz, .wrong    ; C
    ld a, (ix + 1) : cp (iy + 1) : jp nz, .wrong    ; P
    ld a, (ix + 2) : cp (iy + 2) : jp nz, .wrong    ; M
    ld a, (ix + 3) : cp (iy + 3) : jp nz, .wrong    ; .
    ld a, (ix + 4) : cp (iy + 4) : jp nz, .wrong    ; A
    ld a, (ix + 5) : cp (iy + 5) : jr nz, .wrong    ; <space>
    ld a, (ix + 6) : cp (iy + 6) : jr nz, .wrong    
    ld a, (ix + 7) : cp (iy + 7) : jr nz, .wrong    
    ld a, (ix + 8) : cp (iy + 8) : jr nz, .wrong    
    ld a, (ix + 9) : cp (iy + 9) : jr nz, .wrong    
    ld a, (ix +10) : cp (iy +10) : jr nz, .wrong    
    ld a, (ix +11) : cp (iy +11) : jr nz, .wrong    
    ld a, (ix +12) : cp (iy +12) : jr nz, .wrong    
    ld a, (ix +13) : cp (iy +13) : jr nz, .wrong    
    ld a, (ix +14) : cp (iy +14) : jr nz, .wrong    
    ld a, (ix +15) : cp (iy +15) : jr nz, .wrong    
    ;; Found partition
    ld l, (ix + IDEDOS_PE_START_CYL_LO)
    ld h, (ix + IDEDOS_PE_START_CYL_HI)
    ld a, (cur_drive) : ld iy, drives_offsets
    and a : jr z, .write_offset 

    ld bc, 3
.offset_loop
    add iy, bc
    dec a
    jr nz, .offset_loop
.write_offset
    ld (iy + 0), l
    ld (iy + 1), h
    ld a, (ix + IDEDOS_PE_START_HEAD)
    ld (iy + 2), a
    xor a
    ret
.wrong
    ld de, #40
    add ix, de
    dec b
    jp nz, .loop
    ld hl, (part_table_offset) : inc hl : ld (part_table_offset), hl
    jr find_part_table
.unused
    or 1
    ret

load_part_table:
    ld bc, 0
    ld de, 0
    ld hl, sec_buffer
    call drive.read
    call find_part_table
    ret z
    ld bc, 0
    ld de, 128
    ld (part_table_offset), de
    ld hl, sec_buffer
    call drive.read
    call find_part_table
    ret 
    

find_part_table:
    ld ix, sec_buffer
    ld a, (ix + #00) : cp 'P' : ret nz
    ld a, (ix + #01) : cp 'L' : ret nz
    ld a, (ix + #02) : cp 'U' : ret nz
    ld a, (ix + #10) : cp #01 : ret nz ; Partition table
    ret


chs_to_sector:
; HL - cylinder
; D  - head
; E  - sector
; returns:
; HL:DE - 32-bit sector number (MSB .. LSB)
; corrupts:
; flags, A, BC
    ld a, d
    and 1 ; assuming two heads
    jr z, _chs_to_sector_carry_on
    ld a, e
    or 0x80 ; with the assumption that sector number is always below 128
    ld e, a
_chs_to_sector_carry_on:
    push hl
    pop bc
    ld h, 0
    ld l, b
    ld d, c
    ret

part_table_offset dw 0

cur_sect   ds 4
sec_buffer ds 512

volumes_found db 0
drives_offsets  dw 8
partition_1 db 'CPM.A           '
partition_2 db 'CPM.B           '
dpbase:	
    defw	0000h, 0000h
	defw	0000h, 0000h
	defw	dirbf, dpblk
	defw	chk00, all00
;
dpblk:	;disk parameter block for all disks.
	defw	#0200		;sectors per track
	defm	#05		;block shift factor
	defm	#1f		;block mask
	defm	#01		;null mask
	defw	#07ff	;disk size-1
	defw	#01ff	;directory max
	defm	240		;alloc 0
	defm	0		;alloc 1
	defw	32768	;check size
	defw	#0	    ;track offset


dirbf   ds  128
chk00 ds #ff
all00 ds 240


    endmodule
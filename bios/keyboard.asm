    module keyboard
read_status:
    ei
    ld a,(status)
    and a
    ret z
    ld a, #ff
    ret
read:
    call bios.install_int
    ei 
.wait
    halt
    ld a, (status)
    and a
    jr z, .wait
    ld c, a
    xor a
    ld (counter), a
    ld (status), a
    ld a,c
    ret

update:
    ld a,(status)
    and a
    ret nz

    ld hl, counter
    inc (hl)
    ld a, (hl)
    cp	7
    ret c
    ld a, %101 : ld bc, #1ffd : out (c),a
     
    call Read_Keyboard
    push af
    ld a, %001 : ld bc, #1ffd : out (c),a
    pop af
    cp CAPS : jr nz, .ok
    ld a, (cl_status) : xor #ff : ld (cl_status),a
    xor a 
.ok
    ld (status), a
    ret

; key scan routine (no wait)
Read_Keyboard: ; out: a - char code, z = false - key scanned, z = true - no key

    ld bc, 0xFEFE
    ld hl, Scan_Line0

Scan_Loop:
    in a, (c)
    cpl
    and 0x1F ; mask right 5 bits
    ld (hl), a
    inc hl
    rlc b
    jr c, Scan_Loop
    
    ld a, (cl_status)
    ld hl, Keyboard_Map
    or a : jr z, .capsoff
    ld hl, Keyboard_Map_CL
.capsoff
    ld de, 5 * 8 ; map size
    ld a, (Scan_Line0)
    bit 0, a ; check CS bit is zero
    call nz, Pressed_CS
    ld a, (Scan_Line7)
    bit 1, a ; check SS bit is zero
    call nz, Pressed_SS
    
    ld de, Scan_Line0
    ld b, 8
Lines_Rotate:	
    ld a, (de)
    ld c, 5
Bits_Rotate:	
    rrc a
    jr c, Bit_Found
    inc hl ; keyboard map offset - select char
    dec c
    jr nz, Bits_Rotate
    inc de ; scan line offset
    djnz Lines_Rotate
    xor a
    ret
    
Bit_Found:
    ld a, (hl)
    or a
    ret 
    
Pressed_CS:
    add hl, de
    res 0, a
    ld (Scan_Line0), a
    ret
Pressed_SS:
    add hl, de
    add hl, de
    res 1, a
    ld (Scan_Line7), a
    ret
    
Scan_Line0 db 0
Scan_Line1 db 0
Scan_Line2 db 0
Scan_Line3 db 0
Scan_Line4 db 0
Scan_Line5 db 0
Scan_Line6 db 0
Scan_Line7 db 0

cl_status db #ff

ESC EQU #1b
CNTRLC  EQU 3   ;control-c
CNTRLE  EQU 05H   ;control-e
BS  EQU 08H   ;backspace
TAB EQU 09H   ;tab
LF  EQU 0AH   ;line feed
FF  EQU 0CH   ;form feed
CR  EQU 0DH   ;carriage return
CNTRLP  EQU 10H   ;control-p
CNTRLR  EQU 12H   ;control-r
CNTRLS  EQU 13H   ;control-s
CNTRLU  EQU 15H   ;control-u
CNTRLX  EQU 18H   ;control-x
CNTRLZ  EQU 1AH   ;control-z (end-of-file mark)
DEL EQU 7FH   ;rubout
CAPS EQU #FF				

status	db 0
counter db 0

    endmodule
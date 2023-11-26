    module display

init:
    ld a, 3 : ld bc, #7ffd : out (c),a
    ld a, %00000101 : ld bc, #1ffd : out (c),a

    ld a, 016O
    ld hl, #5800
    ld de, #5801
    ld bc, 767
    ld (hl), a
    ldir

    call cls    
    call cursor
    ld a, %00000001 : ld bc, #1ffd : out (c),a
    ret

cls:
    ld a, 1 : out (#fe), a
    xor a
    ld hl,#4000
    ld de,#4001
    ld bc,#17ff
    ld (hl),a
    ldir
home:
    or a
    sbc hl, hl
    ld (coords), hl
    ret

write:
    di
    localStack
    ld a, c
    push af
    ld a, %00000101 : ld bc, #1ffd : out (c),a
    pop af
; A - char
    call tty_putC
    ld a, %00000001 : ld bc, #1ffd : out (c),a
    usualStack
    ei
    ret

putC:
    push af
    ld a, %00000101 : ld bc, #1ffd : out (c),a
    pop af
    call tty_putC
    ld a, %00000001 : ld bc, #1ffd : out (c),a
    ret

tty_putC:
    push af
    call cursor
    ld a, (is_esc) : and a : jr nz, handleEsc
    pop af
    call _tty_putC
    jp cursor

handleEsc:
    pop bc
    ld a, (is_esc)
    cp 2 : jr nc, .load
    ld a, '=' : cp b : jr z, .prepare_load
.not_valid
    xor a : ld (is_esc), a
    jp cursor
.load
    ld a, (is_esc)
    ld hl, coords
    cp 3 : jr z, .load_coord
    inc hl
.load_coord
    ld a, b
    sub 32
    ld (hl), a
    ld a, (is_esc) : cp 3 : jr z, .not_valid
.prepare_load
    ld hl, is_esc
    inc (hl)
    jp cursor

handleBS:
    ld hl, (coords)
    ld a, l
    and a
    jr z, .prev_line
    dec a
    ld l, a
.exit
    ld (coords), hl
    ret
.prev_line
    ld a, h
    and a
    jr z, .exit
    dec h
    ld l, 63
    jr .exit    

cursor_up:
    ld a, (coords + 1)
    and a
    ret z
    dec a
    ld (coords + 1),a
    ret

cursor_down:
    ld hl, (coords)
    inc h
    ld (coords), hl
    jp scrollCheck

_esc:
    ld a, 1 : ld (is_esc),a
    ret

clearline:
    ld de, (coords)
.loop    
    ld a, 80
    cp e : ret z
    push de
    call posit
    xor a
    
    dup 8
    ld (de), a : inc d
    edup

    pop de
    inc e 
    jr .loop


_tty_putC: 
    cp 1 : jp z, home
    cp 8 : jp z, handleBS
    cp 12 : jp z, cls
    cp 13 : jp z, .cr
    cp 10 : jp z, .lf
    cp 20 : jp z, cursor_up
    cp 21 : jp z, cursor_down
    cp 22 : jp z, handleBS
    cp 23 : jp z, .cursor_right
    cp 24 : jp z, clearline
    cp 26 : jp z, cls
    cp 27 : jr z, _esc
    call drawC

.cursor_right    
    ld hl, coords
    inc (hl)
    ld a, (hl) : cp 64 : jr nc, .crlf
    ret
.crlf:
    ld hl, coords : xor a : ld (hl), a
    jr .lf
.cr:
    ld hl, coords
    xor a : ld (hl), a
    ret
.lf
    ld hl, coords+1
    inc (hl)
scrollCheck:
    ld a, (coords+1)
    cp 24 : ret c
    ld a, 23
    ld (coords+1), a
scroll:
    ld hl, table_addr_scr
    ld b, 184
.do
    push bc
    ld e, (hl) : inc hl
    ld d, (hl) : inc hl
    push hl
    ld bc, 14
    add hl, bc
    ld c, (hl) : inc hl
    ld b, (hl)
    
    ld h, b
    ld l, c

    ld bc, 32
    ldir

    pop hl
    pop bc
    djnz .do
    
    ld b, 8
.bottom
    push	bc
    ld	e,(hl)
    inc	hl
    ld	a,(hl)
    ld  d, a
    inc	hl

    push hl
    ld	h,d
    ld	l,e
    inc	de
    ld	(hl),0
    ld	bc,31
    ldir

    pop	hl
    pop	bc
    djnz .bottom
    ret

cursor:
    or a
    ld de, (coords)
    rr e
    jp c, .right

    call posit

    ld hl, #0700
    add hl, de
    ex de, hl
    ld a, (de)
    xor %11110000
    ld (de), a
    ret
.right
    call posit
    ld hl, #0700
    add hl, de
    ex de, hl

    ld a, (de)
    xor %00001111
    ld (de), a
    ret

posit:
    ld a, d
    and 7
    rrca : rrca : rrca
    or e
    ld e, a
    ld a, d
    and 24
    or #40
    ld d, a
    ret

; a - character
drawC:
    ld l, a
    ld h, 0
    add hl, hl ; *2
    add hl, hl ; *4
    add hl, hl ; *8
    ld bc, font
    add hl, bc
    ld de, (coords)
    rr e
    jp c, .right
    call posit
    ld b, 8
.left
    ld a, (hl)
    and %11110000
    ld c, a
    ld a, (de)
    and %00001111
    or c
    ld (de), a
    inc d
    inc hl
    djnz .left
    ret
.right
    call posit
    ld b, 8
.draw_right
    ld a, (hl)
    and %00001111
    ld c, a
    ld a, (de)
    and %11110000
    or c
    ld (de), a
    inc d
    inc hl
    djnz .draw_right
    ret


coords  dw 0 
is_esc  db 0
    endmodule
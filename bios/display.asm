    module display

init:
    di
    ld a, %00110110 : out (#ff), a
    ld a, 3 : ld bc, #7ffd : out (c),a
clrscr:
    di
    ld a, %00000101 : ld bc, #1ffd : out (c),a
    
    ld hl,#4000
    ld de,#4001
    ld bc,6143
    xor a
    ld (hl),a
    ldir
    ld hl,#4000
    ld de,#6000
    ld bc, 6144
    ldir
    ld (coords), bc 
    call draw_cursor
    ld a, %00000001 : ld bc, #1ffd : out (c),a
    ret


find_screen:
    ld a, e
    srl a
    ld e,a
    ld b, #60
    jr c, .proc
    ld b, #40
.proc
    LD A,D
    AND 7
    RRCA
    RRCA
    RRCA
    OR E
    LD E,A
    LD A,D
    AND 24
    OR b
    LD D,A
    ret


handleBS:
    ld hl, (coords)
    ld a, l
    and a
    jr z, .prev_line
    dec a
    ld l, a
.exit
    ld (coords), hl
    jp draw_cursor
.prev_line
    ld a, h
    and a
    jr z, .exit
    dec h
    ld l, #80
    jr .exit

write:
    di
    localStack
    ld a,c
; A - char
    call tty_putC
    usualStack
    ei
    ret
putC:
tty_putC:
    di
    push af
    call draw_cursor
    ld a, (.is_esc) : and a : jr nz,.handle_esc
    pop af

    cp 1 : jp z, home
    cp 8 : jp z, handleBS
    cp 12 : jp z, cls
    cp 13 : jp z, carridge_return

    cp 10 : jp z, cursor_down
    cp 20 : jp z, cursor_up
    cp 21 : jp z, cursor_down
    cp 22 : jp z, handleBS
    cp 23 : jp z, cursor_right
    cp 24 : jp z, clearline
    cp 26 : jp z, cls
    cp 27 : jr z, .esc
    call _putC
    jp draw_cursor
.esc
    ld a, 1 : ld (.is_esc),a
    jp draw_cursor
.handle_esc
    pop bc
    ld a,(.is_esc)
    cp 2 : jr nc, .load
    ld a,'=' : cp b : jr z, .prepare_load
.not_esc
    xor a : ld (.is_esc), a
    jp draw_cursor

.load
    ld a, (.is_esc)
    ld hl, coords
    cp 3 : jr z, .loadX
    inc hl
.loadX
    ld a,b
    sub 32
    ld (hl), a
    
    ld a, (.is_esc) : cp 3 : jr z, .not_esc
.prepare_load
    ld hl, .is_esc
    inc (hl)
    jp draw_cursor

.is_esc dw 0

clearline:
    ld de, (coords)
.loop    
    di
    ld a, %00000101 : ld bc, #1ffd : out (c),a
    
    
    ld a, 80
    cp e : jp z, draw_cursor
    push de
    call find_screen : xor a 
    dup 8
    ld (de),a
    inc d
    edup
    pop de
    
    inc e
    jr .loop
    

cursor_up:
    ld a, (coords + 1)
    and a
    ret z
    dec a
    ld (coords + 1),a
    jp draw_cursor

home:
    ld hl, 0
    ld (coords), hl
    jp draw_cursor

cls:
    di
    ld a, %00000101 : ld bc, #1ffd : out (c),a
    
    ld hl,#4000
    ld de,#4001
    ld bc,6143
    xor a
    ld (hl),a
    ldir
    ld hl,#4000
    ld de,#6000
    ld bc, 6144
    ldir
    ld (coords), bc 
    ld a, %00000001 : ld bc, #1ffd : out (c),a
    jp draw_cursor

carridge_return:
    ld hl, coords
    xor a
    ld (hl),a
    jp draw_cursor
    

cursor_down:
    di
    ld a, %00000101 : ld bc, #1ffd : out (c),a
    ld hl, (coords)
    inc h
    ld (coords), hl
    call scrollCheck
    jp draw_cursor
_putC:
    push af
    call find_screen

    di
    ld a, %00000101 : ld bc, #1ffd : out (c),a
    pop af
    call drawC
    ld a, %00000001 : ld bc, #1ffd : out (c),a
cursor_right:	
    ld hl, (coords)
    inc l
    ld a, l
    cp 80
    jr nc, .cr
.ok
    ld (coords), hl
    ret
.cr
    ld hl, (coords)
    inc h
    ld l, 0, (coords), hl
scrollCheck:
    ld a, h
    cp 24
    jp c, .exit
    ld h, 23
    ld (coords), hl
    call scroll
.exit
    ld a, %00000001 : ld bc, #1ffd : out (c),a
    ret

draw_cursor:
    di
    push af, bc
    ld a, %00000101 : ld bc, #1ffd : out (c),a
    ld hl, (coords)
    ld b, l
    call drawC.calc
    ld de, hl
    ld (drawC.rot_tmp), a
    call find_screen
    ex hl, de

    ld ix, hl
    ld a, h 
    bit 5, a 
    jr z, .ok
    inc l
.ok
    xor #20 : ld h, a
    ld iy, hl
    ld a, (drawC.rot_tmp)
    call drawC.rotate_mask
    ld a, h : xor #ff : ld h,a
    ld a, l : xor #ff : ld l,a
    
    ld b, 8
.loop
    ld a,(ix) : xor h : ld (ix),a
    ld a,(iy) : xor l : ld (iy),a
    inc ixh
    inc iyh
    djnz .loop 

    ld a, %00000001 : ld bc, #1ffd : out (c),a
    pop bc, af
    ret


drawC:
    ld (.char_tmp), a
    ld hl, (coords)
    ld b, l
    call .calc
    ld d, h
    ld e, l
    ld (.rot_tmp), a
    call display.find_screen
    push de
    call .get_char

    pop hl
.print0
    ld ix, hl
    ld a, h 
    bit 5, a 
    jr z, .ok
    inc l
.ok
    xor #20 : ld h, a
    ld iy, hl
    ld a, (.rot_tmp)
    call .rotate_mask
    ld a, (.rot_tmp)
    jp basic_draw
.calc
      ld l,0
      ld a, b : and a : ret z
      ld ix, 0
      ld de,6
1     add ix, de
      djnz 1b
      ld de, -8
2     ld a, ixh
      and a 
      jr nz, 3f
      ld a, ixl
      cp 8
      ret c
3     
      add ix, de
      inc l
      jr 2b
      ret

.rotate_mask
    ld hl, #03ff
    and a : ret z
.rot_loop
    ex af, af
    ld a,l
    rrca
    rr h
    rr l
    ex af, af
    dec a
    jr nz, .rot_loop
    ret
.get_char:
    ld a, (.char_tmp)
    ld l, a
    ld h, 0
    add hl, hl
    add hl, hl
    add hl, hl
    ld bc, font
    add hl, bc
    ex hl, de
    ret
.char_tmp db 0
.rot_tmp  db 0
; A - rotation counter
; DE - font PTR
; HL - mask
; IX - left half on screen 
; IY - right half on screen
basic_draw:
    ld (.rot_cnt),a

    ld a, l
    ld (.mask1), a
    ld a, h
    ld (.mask2), a
    ld b, 8
.printIt
    ld a, (de)
    ld h, a
    ld l, 0
    ld a, 0
.rot_cnt = $ - 1
    and a : jr z, .skiprot
.rot
    ex af, af
    ld a,l
    rrca
    rr h
    rr l
    ex af, af
    dec a
    jr nz, .rot
.skiprot
    ld a, (iy)
    and #0f
.mask1 = $ - 1
    or l
    ld (iy), a
    ld a, (ix)
    and #fc
.mask2 = $ -1
    or h
    ld (ix), a
    inc ixh
    inc iyh
    inc de
    djnz .printIt
    ret

scroll
    di
    ld a, %00000101 : ld bc, #1ffd : out (c),a
    ld	hl,table_addr_scr
    ld	b,184
.pass1		
    push	bc

    ld	e,(hl)
    inc	hl
    ld	d,(hl)
    inc	hl

    push	hl

    ld	bc,14
    add	hl,bc
    ld	c,(hl)
    inc	hl
    ld	b,(hl)

    ld	h,b
    ld	l,c

    ld	bc,32
    ldir

    pop	hl
    pop	bc
    djnz	.pass1

    ld	b,8
.pass2	
    push	bc

    ld	e,(hl)
    inc	hl
    ld	d,(hl)
    inc	hl

    push	hl

    ld	h,d
    ld	l,e
    inc	de
    ld	(hl),0
    ld	bc,31
    ldir

    pop	hl
    pop	bc
    djnz	.pass2
    ld	hl,table_addr_scr
    ld	b,184
.pass3		
    push	bc

    ld	e,(hl)
    inc	hl
    ld	a,(hl)
    or  #20
    ld  d, a
    inc	hl

    push	hl

    ld	bc,14
    add	hl,bc
    ld	c,(hl)
    inc	hl
    ld	a,(hl)
    or #20
    ld b, a

    ld	h,b
    ld	l,c

    ld	bc,32
    ldir

    pop	hl
    pop	bc
    djnz	.pass3

    ld	b,8
.pass4
    push	bc

    ld	e,(hl)
    inc	hl
    ld	a,(hl)
    or  #20
    ld  d, a
    inc	hl

    push	hl

    ld	h,d
    ld	l,e
    inc	de
    ld	(hl),0
    ld	bc,31
    ldir

    pop	hl
    pop	bc
    djnz	.pass4
    ld a, %00000001 : ld bc, #1ffd : out (c),a
    ei
    ret


coords  dw 0 



    endmodule
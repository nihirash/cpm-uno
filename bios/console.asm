    module console

status:
    ld a, (IOBYTE)
    and 3
    jp nz, keyboard.read_status
    jp  uart.status
in:
    ld a, (IOBYTE)
    and 3
    jp nz, keyboard.read
    jp  uart.read

out:
    ld a, (IOBYTE)
    and 3
    jp nz, display.write
    jp uart.write
    endmodule
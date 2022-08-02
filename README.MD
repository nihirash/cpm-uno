# CP/M 2.2 Port for ZXUno

This repository contains vanilla CP/M 2.2 ported to ZXUno.

It uses +3DOS volumes on divMMC as CP/M's partitions and Timex Hi-Res video mode
for 80 characters text output

**This software still in development and can be unstable!**

## Development

I'm using Zesarux emualtor, sjasmplus assembler and VSCode with DeZog plugin. 

Project contains already preconfigured enviroment for development.

In Zesarux I've enabled speccy +2A with MMC emulation via divMMC but without divMMC paging.

You can also use +3e roms to check how it works with basic volumes.

MMC card should have +3DOS volumes. Most important things are - SD card should have couple of volumes:
 * `CPM.A`(case sensitive - important create them in uppercase, 8 megs size - cause CP/M 2.2 limitations)
 * `CPM.B`(similar)

## Current state

CP/M boots in emulator(still not tested in real HW), uses 80 symbols per line video mode and works with +3e volumes. I've checked mbasic, zork and some other small utils.

### Terminal

Currently, implemented **very dumb terminal**.

Implemented control codes:
 * 0x01 - Home cursor
 * 0x0A - new line(works like cursor down)
 * 0x0C - clear screen
 * 0x0D - CR(just returns cursor to first character position in line)
 * 0x14 - cursor up
 * 0x15 - cursor down
 * 0x16 - cursor left(similar to backspace)
 * 0x17 - cursor right
 * `ESC`+`=`+<X>+<Y> - set absolute position on screen 

## Porting possibility

If you'll drop off timex screen driver and replace it with usual speccy screen driver - it should work out of the box with Speccy +2A/+3 with divMMC as +3e drive. 

Porting to other hardware will require a bit more work.

## Used third party components

I've used some 3rd party components:
 * I've used ZXMMC driver as reference for loading +3DOS partition table
 * I've used Andrew Owen's 6x8 font 
 * I've used DR's CCP and BDOS
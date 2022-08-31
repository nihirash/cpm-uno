    module display
font: 
    incbin "font.bin"
table_addr_scr		
    defw	#4000,#4100,#4200,#4300,#4400,#4500,#4600,#4700
    defw	#4020,#4120,#4220,#4320,#4420,#4520,#4620,#4720
    defw	#4040,#4140,#4240,#4340,#4440,#4540,#4640,#4740
    defw	#4060,#4160,#4260,#4360,#4460,#4560,#4660,#4760
    defw	#4080,#4180,#4280,#4380,#4480,#4580,#4680,#4780
    defw	#40a0,#41a0,#42a0,#43a0,#44a0,#45a0,#46a0,#47a0
    defw	#40c0,#41c0,#42c0,#43c0,#44c0,#45c0,#46c0,#47c0
    defw	#40e0,#41e0,#42e0,#43e0,#44e0,#45e0,#46e0,#47e0

    defw	#4800,#4900,#4a00,#4b00,#4c00,#4d00,#4e00,#4f00
    defw	#4820,#4920,#4a20,#4b20,#4c20,#4d20,#4e20,#4f20
    defw	#4840,#4940,#4a40,#4b40,#4c40,#4d40,#4e40,#4f40
    defw	#4860,#4960,#4a60,#4b60,#4c60,#4d60,#4e60,#4f60
    defw	#4880,#4980,#4a80,#4b80,#4c80,#4d80,#4e80,#4f80
    defw	#48a0,#49a0,#4aa0,#4ba0,#4ca0,#4da0,#4ea0,#4fa0
    defw	#48c0,#49c0,#4ac0,#4bc0,#4cc0,#4dc0,#4ec0,#4fc0
    defw	#48e0,#49e0,#4ae0,#4be0,#4ce0,#4de0,#4ee0,#4fe0

    defw	#5000,#5100,#5200,#5300,#5400,#5500,#5600,#5700
    defw	#5020,#5120,#5220,#5320,#5420,#5520,#5620,#5720
    defw	#5040,#5140,#5240,#5340,#5440,#5540,#5640,#5740
    defw	#5060,#5160,#5260,#5360,#5460,#5560,#5660,#5760
    defw	#5080,#5180,#5280,#5380,#5480,#5580,#5680,#5780
    defw	#50a0,#51a0,#52a0,#53a0,#54a0,#55a0,#56a0,#57a0
    defw	#50c0,#51c0,#52c0,#53c0,#54c0,#55c0,#56c0,#57c0
    defw	#50e0,#51e0,#52e0,#53e0,#54e0,#55e0,#56e0,#57e0
    endmodule

    module keyboard
                        
Keyboard_Map:           DB 0x00,"z","x","c","v"
                        DB "a","s","d","f","g"
                        DB "q","w","e","r","t"
                        DB "1","2","3","4","5"
                        DB "0","9","8","7","6"
                        DB "p","o","i","u","y"
                        DB CR,"l","k","j","h"
                        DB " ",0x00,"m","n","b"

                                                
Keyboard_Map_CS:        DB 0x00,"Z","X","C","V"
                        DB "A","S","D","F","G"
                        DB "Q","W","E","R","T"
                        DB BS,CAPS,0x00,0x00,0x08
                        DB DEL,TAB,0x0c,0x0b,0x0a
                        DB "P","O","I","U","Y"
                        DB CR,"L","K","J","H"
                        DB ESC,0x00,"M","N","B"

Keyboard_Map_SS:        DB 0x00,":","$","?","/"
                        DB '~','|','\','{','}'
                        DB 0x00,'{','}',"<",">"
                        DB "!","@","#","$","%"
                        DB "_",")","(","'","&"
                        DB "\"",";",0x00,']','['
                        DB CR,"=","+","-","^"
                        DB " ",0x00,".",",","*"

Keyboard_Map_CSSS:      
                        DB 0x00,CNTRLZ,CNTRLX,CNTRLC,0x16
                        DB 0x01,CNTRLS,0x04,0x06,0x07
                        DB 0x11,0x17,CNTRLE,CNTRLR,0x14
                        DB DEL,0x00,0x00,0x00,0x00
                        DB BS,0x00,TAB,0x00,0x00
                        DB CNTRLP,0x0f,0x09,CNTRLU,0x19
                        DB CR,0x0c,0x0b,0x0a,0x08
                        DB " ",0x00,0x0d,0x0e,0x02
Keyboard_Map_CL:        DB 0x00,"Z","X","C","V"
                        DB "A","S","D","F","G"
                        DB "Q","W","E","R","T"
                        DB "1","2","3","4","5"
                        DB "0","9","8","7","6"
                        DB "P","O","I","U","Y"
                        DB CR,"L","K","J","H"
                        DB " ",0x00,"M","N","B"

Keyboard_Map_CL_CS:     DB 0x00,"Z","X","C","V"
                        DB "A","S","D","F","G"
                        DB "Q","W","E","R","T"
                        DB BS,CAPS,0x00,0x00,0x08
                        DB DEL,TAB,0x0c,0x0b,0x0a
                        DB "P","O","I","U","Y"
                        DB CR,"L","K","J","H"
                        DB ESC,0x00,"M","N","B"

Keyboard_Map_CL_SS:        DB 0x00,":","$","?","/"
                        DB '~','|','\','{','}'
                        DB 0x00,'{','}',"<",">"
                        DB "!","@","#","$","%"
                        DB "_",")","(","'","&"
                        DB "\"",";",0x00,']','['
                        DB CR,"=","+","-","^"
                        DB " ",0x00,".",",","*"

Keyboard_Map_CL_CSSS:   
                        DB 0x00,CNTRLZ,CNTRLX,CNTRLC,0x16
                        DB 0x01,CNTRLS,0x04,0x06,0x07
                        DB 0x11,0x17,CNTRLE,CNTRLR,0x14
                        DB DEL,0x00,0x00,0x00,0x00
                        DB BS,0x00,TAB,0x00,0x00
                        DB CNTRLP,0x0f,0x09,CNTRLU,0x19
                        DB CR,0x0c,0x0b,0x0a,0x08
                        DB " ",0x00,0x0d,0x0e,0x02    
    endmodule
ccp_backup:
    ds  FBASE-CBASE
    display "CCP_BACKUP_size: ",$-ccp_backup

    display $c000-$

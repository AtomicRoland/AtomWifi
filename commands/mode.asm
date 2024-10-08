\ WiFi *MODE command for Acorn Atom
\ (c) Roland Leurs, July 2022

\ MODE command, used to set the Wifi mode to STATION, ACCESSPOINT or BOTH.
\ Version 1.00

\ Syntax:       *MODE <1 | 2 | 3>

include "atomcommand.asm"

.atmheader          equs "MODE",0,0,0,0,0,0,0,0,0,0,0,0
                    equw __CODE__
                    equw commandStart
                    equw commandEnd - __CODE__

include "driver.asm"
include "serial.asm"
include "routines.asm"
include "errors.asm"

.commandStart

.mode_cmd 			        \ start command from here
 jsr skipspace1             \ forward Y pointer to first non-space character
 jsr read_cli_param         \ read ssid from command line
 cpx #&00                   \ test if ssid given, x will be > 0
 bne mode_init_heap         \ continue as the ssid is on the command line
 jsr printtext              \ no ssid, print a message
 equs "Usage: *MODE <1..3>",&0D,&0A
 equs "MODE 1 -> STATION",&0D,&0A
 equs "MODE 2 -> ACCESS POINT",&0D,&0A
 equs "MODE 3 -> BOTH",&0D,&0A,&EA
 jmp call_claimed           \ end of command

.mode_init_heap
 ldx #0                     \ reset heap pointer
 jsr copy_to_heap           \ copy the parameter to the heap

 lda heap                   \ check for query (param = ?)
 cmp #'?'
 bne set_mode
 lda #0                     \ user asks for mode
 sta heap                   \ clear parameters
.set_mode
 ldx #>heap                 \ load address of parameter block
 ldy #<heap                   
 lda #&07                   \ load driver command
 jsr wifidriver
 jsr reset_buffer
 lda pageram
 beq no_device
.version_l3
 jsr read_buffer
 jsr oswrch
 lda datalen+1     \ compare data pointer with data length
 cmp pagereg
 bne version_l3
 cpx datalen
 bne version_l3

.version_end
 jmp call_claimed

.no_device
 ldx #(error_no_response-error_table)
 jmp error

.commandEnd

SAVE "MODE", atmheader, commandEnd
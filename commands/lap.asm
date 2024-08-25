\ WiFi *LAP command for Acorn Atom
\ (c) Roland Leurs, July 2022

\ Get list of access points
\ Version 1.00

\ Syntax:       *LAP

include "atomcommand.asm"

.atmheader          equs "LAP",0,0,0,0,0,0,0,0,0,0,0,0,0
                    equw __CODE__
                    equw commandStart
                    equw commandEnd - __CODE__

include "driver.asm"
include "serial.asm"
include "routines.asm"
include "errors.asm"

.commandStart

.version_cmd
.lap_cmd
 lda #3                     \ Load driver call number

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

SAVE "LAP", atmheader, commandEnd
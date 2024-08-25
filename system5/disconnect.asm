\ WiFi *DISCONNECT command for Acorn System 5
\ (c) Roland Leurs, August 2024

\ Close connection to server
\ Version 1.00

\ Syntax:       *DISCON

include "atomcommand.asm"

.atmheader          equs "DISCON",0,0,0,0,0,0,0,0,0,0
                    equw __CODE__
                    equw commandStart
                    equw commandEnd - __CODE__

include "driver.asm"
include "serial.asm"
include "routines.asm"
include "errors.asm"

.commandStart

.version_cmd
  lda #14            \ load driver command

.generic_cmd
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

SAVE "DISCON", atmheader, commandEnd
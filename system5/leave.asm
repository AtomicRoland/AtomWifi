\ WiFi *LEAVE command for Acorn System 5
\ (c) Roland Leurs, August 2024

\ Disconnect from WiFi network
\ Version 1.00

\ Syntax:       *LEAVE

include "atomcommand.asm"

.atmheader          equs "LEAVE",0,0,0,0,0,0,0,0,0,0,0
                    equw __CODE__
                    equw commandStart
                    equw commandEnd - __CODE__

include "driver.asm"
include "serial.asm"
include "routines.asm"
include "errors.asm"

.commandStart

.leave_cmd
  lda #&05                    \ Load driver call number
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

SAVE "LEAVE", atmheader, commandEnd
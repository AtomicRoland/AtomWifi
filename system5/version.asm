\ WiFi *VERSION command for Acorn System 5
\ (c) Roland Leurs, August 2024

\ Get ESP8266 firmware version
\ Version 1.00

\ Syntax:       *VERSION

include "atomcommand.asm"

.atmheader          equs "VERSION",0,0,0,0,0,0,0,0,0
                    equw __CODE__
                    equw commandStart
                    equw commandEnd - __CODE__

include "driver.asm"
include "serial.asm"
include "routines.asm"
include "errors.asm"

.commandStart

.version_cmd
  \ print ROM version
  jsr print_version_string
  \ Get ESP firemware version
  lda #2            \ load driver command

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

.print_version_string
  ldx #0
.version_l1
  lda versionstring,x
  bmi version_l2
  jsr oswrch
  inx
  bne version_l1

.version_l2
  jmp osnewl

.versionstring EQUS "SYSTEM5 WIFI V1.00", &A0

.commandEnd

SAVE "VERSION", atmheader, commandEnd
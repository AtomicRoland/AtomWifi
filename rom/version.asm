\ Sideway ROM for Electron Wifi board
\ (c) Roland Leurs, May 2020

\ Get ESP8266 firmware version
\ Version 1.00

\ Syntax:       *VERSION

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

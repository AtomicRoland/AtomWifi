\ WiFi *WIFI command for Acorn System 5
\ (c) Roland Leurs, August 2024

\ WIFI command to control the ESP controller
\ Version 1.00

\ Syntax: *WIFI [ON | OFF | SR | HR]


include "atomcommand.asm"

.atmheader          equs "WIFI",0,0,0,0,0,0,0,0,0,0,0,0
                    equw __CODE__
                    equw commandStart
                    equw commandEnd - __CODE__

include "driver.asm"
include "serial.asm"
include "routines.asm"
include "errors.asm"

.commandStart

.wifi_cmd       ldy #0                      \ initialize pointer
                jsr skipspace1              \ forward Y pointer to first non-space character
                cmp #&0D                    \ test if no paramaters given
                beq wifi_badcmd             \ if &0D then there are no parameters
                cmp #'O'                    \ It's on or off
                beq wifi_on_off
                cmp #'S'                    \ Soft reset
                beq wifi_sr                 
                cmp #'H'                    \ Hard reset
                beq wifi_hr
.wifi_badcmd    jmp wifi_help               \ unrecognised or no parameter, print help text

.wifi_hr        ldx #1                      \ load driver command for hard reset (toggle RTS line)
                bne wifi_reset              \ branch always

.wifi_sr        ldx #0                      \ load driver command for soft reset (send AT+RST)
.wifi_reset     iny                         \ increment pointer to command line
                lda line,y                  \ load next character
                cmp #'R'                    \ check if second letter is an R                
                bne wifi_badcmd             \ No it's not, go print help info
                txa                         \ transfer driver command to A
                jsr wifidriver              \ perform the action
                jmp call_claimed            \ end of command

.wifi_on_off    jsr skipspace               \ read the next character (skips space but that won't matter)
                cmp #'N'                    \ it's an N, so wifi on
                beq wifi_on
                cmp #'F'                    \ if's an F, so wifi off
                bne wifi_badcmd             \ No F, so unrecognized command

.wifi_off       jsr printtext
                equs "SWITCHING WIFI OFF",&0D,&EA
                ldx #0                      \ switch wifi off (pass call to wifi driver)
.wifi_off_l1    lda #24
                jsr wifidriver              
                jmp call_claimed

.wifi_on        jsr printtext               \ for now this will do
                equs "SWITCHING WIFI ON",&0D,&EA
                lda #1                      \ switch wifi on
                bne wifi_off_l1             \ branch always

.wifi_help      jsr printtext
                equs " ON   ENABLE WIFI",&0D
                equs " OFF  DISABLE WIFI",&0D
                equs " SR   DO SOFT RESET",&0D
                equs " HR   DO HARD RESET",&0D,&EA
                jmp call_claimed


.commandEnd

SAVE "WIFI", atmheader, commandEnd

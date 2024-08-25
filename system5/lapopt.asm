\ WiFi *LAPOPT command for Acorn System 5
\ (c) Roland Leurs, August 2024

\ Set LAP options
\ Version 1.00

\ Syntax:       *LAPOPT n

include "atomcommand.asm"

.atmheader          equs "LAPOPT",0,0,0,0,0,0,0,0,0,0
                    equw __CODE__
                    equw commandStart
                    equw commandEnd - __CODE__

include "driver.asm"
include "serial.asm"
include "routines.asm"
include "errors.asm"

.commandStart

.lapopt_cmd
 ldy #0                     \ initialize Y register
 jsr skipspace1             \ forward Y pointer to first non-space character
 jsr read_cli_param         \ read parameter (option value) from command line
 cpx #&00                   \ test if parameter given, x will be > 0
 bne lapopt_param           \ jump if there is a parameter 
 lda #'1'                   \ write default value to heap
 sta heap
 lda #'2'
 sta heap+1
 lda #'7'
 sta heap+2
 lda #&0D
 sta heap+3
 bne do_lapopt              \ branch always
.lapopt_param
 ldx #0                     \ reset heap pointer
 jsr copy_to_heap           \ copy parameter to head (parameter block)
.do_lapopt
 ldx #>heap                 \ load pointer to parameter block
 ldy #<heap
 lda #25                    \ Load driver call number
 jsr wifidriver
 jsr reset_buffer
 lda pageram
 beq no_device
.version_l3
 jsr read_buffer
 jsr oswrch
 lda datalen+1              \ compare data pointer with data length
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
SAVE "LAPOPT", atmheader, commandEnd
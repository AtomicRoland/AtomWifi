\ WiFi *JOIN command for Acorn Atom
\ (c) Roland Leurs, July 2022

\ Get basic network interface configuration
\ Version 1.00

\ Syntax:     *JOIN <ssid> [passwd]

include "atomcommand.asm"

.atmheader          equs "JOIN",0,0,0,0,0,0,0,0,0,0,0,0
                    equw __CODE__
                    equw commandStart
                    equw commandEnd - __CODE__

include "driver.asm"
include "serial.asm"
include "routines.asm"
include "errors.asm"

.commandStart

.join_cmd 			        \ start command from here
 ldy #0                     \ initialize Y pointer
 jsr skipspace1             \ forward Y pointer to first non-space character
 jsr read_cli_param         \ read ssid from command line
 cpx #&00                   \ test if ssid given, x will be > 0
 bne join_init_heap         \ continue as the ssid is on the command line
 jsr printtext              \ no ssid, print a message
 equs "USAGE: JOIN <SSID> [PASSWORD]",&0D,&0A,&EA
 jmp call_claimed           \ end of command

.join_init_heap
 ldx #0                     \ reset heap pointer
 jsr copy_to_heap           \ copy the parameter to the heap

 lda heap                   \ check if user issues a query
 cmp #'?'                   \ is the parameter a ?
 beq query_network          \ yes, then don't check/ask for password but issue the call
 stx save_x                 \ save pointer in heap memory
 jsr skipspace1             \ move pointer to first non-space character
 jsr read_cli_param         \ read the next parameter, i.e. password
 cpx #0                     \ is password given
 bne copy_password          \ yes, copy it to the heap
 jsr printtext              \ no password given, prompt for it
 equs "ENTER PASSWORD: ",&EA
.enter_password
 jsr osrdch                 \ read character from keyboard
 cmp #&7F                   \ is it delete?    
 beq delete                 \ yes, then jump
 sta strbuf,x                 \ no, then store it as parameter
 pha                        \ save accu for printing an asterisk
 lda #'*'                   \ load asterisk
 jsr oswrch                 \ print it
 pla                        \ restore accu
 inx                        \ increment pointer
 bmi copy_password          \ jmp if 128th character given (that is a very strong password ;-)
 cmp #&0D                   \ is it the end of the password   
 bne enter_password         \ no, then jump for the next character
 jsr osnewl                 \ print a new line
.copy_password
 ldx save_x                 \ restore pointer in heap memory
 jsr copy_to_heap           \ copy the password to the heap
 jmp join_network
 
.delete
 cpx #0                     \ test for start of input
 beq enter_password         \ if start then there is nothing to delete
 jsr oswrch                 \ perform the delete action
 dex                        \ decrement the pointer
 bpl enter_password         \ jmp for new character
 
.query_network
 lda #0                     \ user asks for connected network
 sta heap                   \ clear parameters
.join_network
 ldx #>heap                 \ load address of parameter block
 ldy #<heap                   
 lda #&04                   \ load driver command
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

SAVE "JOIN", atmheader, commandEnd
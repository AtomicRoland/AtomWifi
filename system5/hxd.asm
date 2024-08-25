\ HeXDump command for Acorn System5
\ (c) Roland Leurs, May 2024

; HXD - dumps the contents of memory
; This commant accepts one optional parameter which is the start address of the
; dump. 

; Syntax:   *HXD [address]

include "atomcommand.asm"

.atmheader          equs "HXD",0,0,0,0,0,0,0,0,0,0,0,0,0
                    equw __CODE__
                    equw commandStart
                    equw commandEnd - __CODE__

include "driver.asm"
include "serial.asm"
include "routines.asm"
include "errors.asm"

.commandStart

.hdump_cmd
 lda #LINECOUNT         ; reset line count
 sta hdump_line_cnt

 ldy #0                 ; reset command line pointer
 jsr skipspace1         ; forward Y pointer to first non-space character
 jsr read_cli_param     ; read parameter (start address) from command line
 cpx #&00               ; test if parameter given, x will be > 0
 bne hdump_param        ; jump if there is a parameter 
 lda #0                 ; set paged ram to page 0
 sta load_addr          ; save the index to page ram
 sta load_addr+1
 beq hdump_start        ; jump always

.hdump_param            
 ldx #load_addr         ; load zp address where the parameter value will be stored
 jsr string2hex         ; convert the string to a 16 bit address

.hdump_start
 lda load_addr          ; load the offset in paged ram
 and #&F8               ; align to 0 or 8 offset
 sta load_addr          ; store load address
 tay                    ; transfer to index register

.hdump_l1
 lda load_addr+1        ; load the page number
 jsr printhex           ; print it
 tya                    ; transfer the ram-pointer to Accu
 pha                    ; save the value
 jsr printhex           ; print pointer value
 lda #':'               ; print a colon
 jsr oswrch
 lda #' '               ; print two spaces
 jsr oswrch
 jsr oswrch
 ldx #8                 ; load counter
.hdump_l2               
 lda (load_addr),y      ; load data byte
 jsr printhex           ; print it
 lda #' '               ; print a space
 jsr oswrch
 iny                    ; increment pointer
 dex                    ; decrement counter
 bne hdump_l2           ; if not complete line (8 bytes) then do next byte
 pla                    ; get pointer value back
 tay                    ; write to ram-pointer
 ldx #8                 ; re-load counter
.hdump_l3
 lda (load_addr),y      ; load data byte
 bmi hdump_dot          ; if negative, print a dot
 cmp #&20               ; check for non printable value below 20
 bmi hdump_dot          ; print a dot
 cmp #&7F               ; check for backspace
 beq hdump_dot          ; print a dot
 jsr oswrch             ; it's a printable character, print it
.hdump_l4
 iny                    ; increment pointer
 dex                    ; decrement counter
 bne hdump_l3           ; if not complete line (8 bytes) then do next byte
 jsr osnewl             ; print new line
 dec hdump_line_cnt     ; decrement line counter
 bne hdump_l5           ; jump if not number of lines is reached
 jsr osrdch             ; wait for key press
 lda #LINECOUNT         ; reset line count
 sta hdump_line_cnt
.hdump_l5
 jsr check_esc          ; test if escape is pressed
 bcs hdump_end          ; if escape is pressed then end routine
 cpy #0                 ; check if full page is displayed
 bne hdump_l1           ; not full page, continue
 inc load_addr+1        ; increment the page
 bne hdump_l1           ; jump if not last page

.hdump_end
 jmp call_claimed       ; claim the call and end routine

.hdump_dot
 lda #'.'               ; print a dot
 jsr oswrch
 jmp hdump_l4           ; continue

.hdump_line_cnt         equb 0      ; page mode line counter

.commandEnd

SAVE "HXD", atmheader, commandEnd
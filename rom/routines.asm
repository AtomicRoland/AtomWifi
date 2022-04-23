\ routines.asm

\ This routine prints a text string until the &0D character is encountered. It returns
\ after the calling jsr instruction. This routine will usually be called to print text
\ strings from the ESP8266 response.
\.print_string
.print_string       jsr read_buffer          \ read character
                    beq print_string_end     \ on end of buffer also end routine
                    jsr oswrch               \ print it
                    cmp #&0D                 \ test end of string
                    bne print_string         \ continue for next character
.print_string_end   jsr osnewl               \ perform new line and end routine

\ This routine converts the hexadecimal string in the string buffer to
\ a 16 bit integer address. The destination in the zeropage is pointed by the
\ X register. On exit X and Y will be preserved. A indicates whether there 
\ was an address (A <> 0) or not (A == 0)
.string2hex         tya                     \ save Y register on stack
                    pha
                    lda #0                  \ reset accu and zeropage
                    sta &00,x
                    sta &01,x
                    sta &02,x
                    tay                     \ reset pointer
.string2hex_l1      lda strbuf,y            \ load character
                    cmp #&0D                \ check for end of string
                    beq string2hex_end      \ it's the end, so jump
                    jsr digit2hex           \ convert to hex value
                    bcs string2hex_end      \ a false digit was encountered, end routine
                    asl a                   \ shift four times left
                    asl a
                    asl a
                    asl a
                    sty &02,x               \ save index
                    ldy #4                  \ load bit shift counter
.string2hex_l2      asl a                   \ shift left
                    rol &00,x               \ shift into zeropage
                    rol &01,x               \ shift also high byte
                    dey                     \ decrease counter
                    bne string2hex_l2       \ do next bit
                    ldy &02,x               \ restore the index
                    iny                     \ increment index
                    bne string2hex_l1       \ process next digit
.string2hex_end     pla                     \ restore Y
                    tay
                    lda &02,x               \ load saved index, if 0 then there was no parameter
                    rts

\ Converts an ascii character to hexadecimal value. If the character is not a valid hex digit 
\ then the routine will exit with A undefined and carry set. If no error is encountered then A
\ holds the hex value and the carry is cleared.
.digit2hex          cmp #'0'                \ test for character smaller than '0'
                    bcc digit2hex_inv       \ jump if invalid character
                    cmp #':'                \ test if character larger than '9'
                    bcc digit2hex_conv      \ jmp if valid character
                    sbc #7                  \ substract 7 to skip characters &3A-&3F
                    bcc digit2hex_inv       \ jmp if invalid character 
                    cmp #'@'                \ test for larger than '@'
                    bcs digit2hex_inv       \ jump if invalid character
.digit2hex_conv     and #&0F                \ clear high nibble so the hex value is in the accu
                    rts
.digit2hex_inv      sec                     \ set carry
                    rts

\ This short routine restores the registers X and Y and sets the accumulator to &00 to claim a call.
.call_claimed
                    rts

 \ find routine: search for a needle in a haystack.
 \ The haystack is the paged ram. 
 \ zeropage: X-reg    = pointer to memory block in current selected ram page
 \           needle   = pointer to string
 \           size     = number of bytes to search
 \ on exit:  carry = 1: string found, X points directly after needle in paged ram buffer
 \           carry = 0: string not found
 \           registers A and X are undefined

.fnd
 ldy #0                         \ reset index
.fnd1
 jsr read_buffer                \ read the data at position X
 beq fnd_not_found              \ if the end of data is reached then the string is not found
 cmp (needle),y                 \ compare with needle
 bne fnd                        \ if not equal reset search pointer
 iny
 cpy size
 bne fnd1
 sec
 rts
.fnd_not_found
 clc
 rts
 
\ Check if the string, pointed by X, in the buffer is "OK". 
\ On exit: Z = 1 -> yes, it is "OK"
\          Z = 0 -> no, it is not "OK"
\          A = not modified
\          X = not modified
.test_ok
 pha
 lda pageram,x
 cmp #'O'
 bne test1
 lda pageram+1,x  \\ this goes wrong if x=255 !
 cmp #'K'
.test1
 pla
 rts
  
\ Check if the string, pointed by X, in the buffer is "ERROR" (actually it is a bit lazy, only 
\ checks for the string "ERR" 
\ On exit: Z = 1 -> yes, it is "ERR"
\          Z = 0 -> no, it is not "ERR"
\          A = undefined
\          X = undefined (however, still points to the next position for reading the buffer)
.test_error
 pha
 jsr read_buffer
 cmp #'E'
 bne test1
 jsr read_buffer
 cmp #'R'
 bne test1
 jsr read_buffer
 cmp #'R'
 pla
 rts

\ Search for the next occurence of the newline character (&0A). 
\ On exit:  A is undefined (&0A if found, otherwise unknown) 
\           X points to the next character 
\           Z = 1 if end of buffer is reached
\           Z = 0 if newline is found
.search0a
 jsr read_buffer        \ read character from buffer
 beq search0a_l1        \ jump if end of buffer is reached
 cmp #&0A               \ compare with &0A
 bne search0a           \ it's not, keep searching
 cmp #&0D               \ it is &0A, compare to another value to clear the Z-flag
.search0a_l1     
 rts                    \ return

\ Read a parameter from the command line. The parameter will be stored in 'strbuf'. On exit X indicates
\ whether there was a parameter ( x <> 0 ) or not ( x == 0 )
.read_cli_param             \ Read a parameter from the command line
 ldx #0                     \ Reset pointer for storing the parameter
.read_param_loop
 lda line,y                 \ Read the next character from the command line
 cmp #&0D                   \ Is it end of line?
 beq read_param_end         \ Yes, jump to the end of the routine
 cmp #'"'                   \ is it a double quote?
 beq read_param_quoted      \ Yes, jump for slightly modified routine
 cmp #&20                   \ Is it a space (end of parameter)
 beq read_param_end         \ Yes, jump to the end of the routine
 sta strbuf,x               \ Store in temporary space
 iny                        \ Increment pointer on command line
 inx                        \ Increment storage pointer
 cpx #&FF                   \ Test for end of storage
 bne read_param_loop        \ Go for the next character
.read_param_end
 lda #&0D                   \ Terminate the parameter string
 sta strbuf,x
 rts                        \ End of routine

.read_param_quoted
  iny                        \ increment pointer
  lda line,y                 \ read next character
  cmp #&0D                   \ check for end of line
  beq read_param_error       \ jump for error (missing closing quote)
  sta strbuf,x               \ store character in string buffer
  inx                        \ increment storage pointer
  cmp #'"'                   \ check for quote
  bne read_param_quoted      \ if not then jump for next character
  dex                        \ decrement storage pointer
  iny                        \ increment input pointer
  lda line,y                 \ read next character
  cmp #'"'                   \ check for double quote
  bne read_param_end         \ if not double then it was the closing quote, jump to end
  inx                        \ increment input pointer
  bcs read_param_quoted      \ jump for next character

.read_param_error
 ldx #(error_bad_param - error_table)       \ load "parameter error"
 jmp error                  \ throw an error

\ Copy the parameter at 'strbuf' to the parameter block (called heap, because in the original Atom version
\ it was really on the heap). X should be set to zero at the first call.
.copy_to_heap
 sty save_y                 \ save Y register
 ldy #0                     \ reset pointer
.cth1
 lda strbuf,y               \ read parameter
 iny
 sta heap,x                 \ write to heap
 inx                        \ increment heap pointer
 cmp #&0D                   \ test for end of string
 bne cth1                   \ not the end, continue for next character
 ldy save_y                 \ restore Y register
 rts                        \ end subroutine
 
\ Test presense of paged ram
\ This test is destructive for both the ram content and the A register.
\ Returns with Z=0 for ram error.
.test_paged_ram
  lda #&AA                   \ load byte
  sta pageram                \ write to memory
  cmp pageram                \ compare memory with value
 .ram_error
  rts                        \ return from subroutine


.save_registers                     \ save registers
 sta save_a
 stx save_x
 sty save_y
 rts

.restore_registers                  \ restore registers
 lda save_a
 ldx save_x
 ldy save_y
 rts

\ Calculates  DIVEND / DIVSOR = RESULT	
.div16
 divisor = zp+6                     \ just to make the code more human readable
 dividend = zp                    \ what a coincidence .... this is the address of baudrate
 remainder = zp+2                   \ not necessary, but it's calculated
 result = dividend                  \ more readability

 lda #0	                            \ reset remainder
 sta remainder
 sta remainder+1
 ldx #16	                        \ the number of bits

.div16loop	
 asl dividend	                    \ dividend lb & hb*2, msb to carry
 rol dividend+1	
 rol remainder	                    \ remainder lb & hb * 2 + msb from carry
 rol remainder+1
 lda remainder
 sec                                \ set carry for substraction
 sbc divisor	                    \ substract divisor to see if it fits in
 tay	                            \ lb result -> Y, for we may need it later
 lda remainder+1
 sbc divisor+1
 bcc div16skip	                    \ if carry=0 then divisor didn't fit in yet

 sta remainder+1	                \ else save substraction result as new remainder,
 sty remainder	
 inc result	                        \ and INCrement result cause divisor fit in 1 times

.div16skip
 dex
 bne div16loop	
 rts                                \ do you understand it? I don't ;-)


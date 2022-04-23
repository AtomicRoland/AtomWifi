\ Sideway ROM for Acorn Atom Wifi board
\ (c) Roland Leurs, May 2020

\ Main service ROM
\ Version 1.00


include "acornatom.asm"

.atmheader          equs "atomwifi.rom",0,0,0,0
                    equw &9000                  \ during development we'll load at &1800
                    equw &9000
                    equw romend-romstart

\ Rom header
.romstart

\ Command table
.commands           lda #<command                \ set comvec to our rom
                    sta comvec
                    lda #>command
                    sta comvec+1
                    jmp print_version_string

\ This routine searches the service roms command table for the command on the command line. The
\ command may be abbreviated with a dot. If the command is not in the table then this routine
\ will exit with the registers restored.
\ This routine comes from the ATOM GDOS 1.5 sources. Credits go to Gerrit Hillebrand. 

.command            ldx #&FF                    \ load index register, one byte before command table
                    cld                         \ clear decimal flag
.command_x4         ldy #0                      \ reset Y pointer to beginning of command line
                    jsr skipspace+1             \ forward Y pointer to first non-space character
                    dey                         \ set pointer to beginning of command
.command_x2         iny                         \ increment pointer
                    inx                         \ increment index
\ The search routine compares all the commands in the table with the command on the command line.
.command_x5         lda commandtable,x          \ load character from command table
                    bmi command_x1              \ jump if negative (i.e. end of command, high byte of start address)
                    cmp line,y                  \ compare with character on command line
                    beq command_x2              \ jump if equal
\ There was a character read that is not in the current command. Either it is abbreviated or it's
\ another command. In both cases, increment the X index to the end of the command in the table. X points
\ to the (possible) start address of the command.
                    dex                         \ decrement index
.command_x3         inx                         \ increment index
                    lda commandtable,x          \ read character
                    bpl command_x3              \ jump if not end of command
                    inx                         \ increment index
                    lda line,y                  \ read character from command line
                    cmp #'.'                    \ is it a dot (abbreviated command)?
                    bne command_x4              \ jump if not a dot
                    iny                         \ increment pointer (Y points now directy after the command)
                    dex                         \ decrement index
                    bcs command_x5              \ continue with the next command in the table. 
.command_x1         sta zp+1                    \ set in workspace
                    lda commandtable+1,x        \ load low byte of command start
                    sta zp                      \ set in workspace
                    jsr set_bank_0              \ select bank 0
                    jmp (zp)                    \ go and execute the command
.command_x6         jmp comerr


.commandtable       equs "WGET"
                    equb >wget_cmd, <wget_cmd
                    equs "WIFI"
                    equb >wifi_cmd, <wifi_cmd 
                    equs "VERSION"
                    equb >version_cmd, <version_cmd
                    equs "LAPOPT"
                    equb >lapopt_cmd, <lapopt_cmd
                    equs "LAP"
                    equb >lap_cmd, <lap_cmd
                    equs "IFCFG"
                    equb >ifcfg_cmd, <ifcfg_cmd
                    equs "DATE"
                    equb >date_cmd, <date_cmd
                    equs "TIME"
                    equb >time_cmd, <time_cmd
                    equs "JOIN"
                    equb >join_cmd, <join_cmd
                    equs "LEAVE"
                    equb >leave_cmd, <leave_cmd
                    equs "PING"
                    equb >ping_cmd, <ping_cmd
                    equs "MODE"
                    equb >mode_cmd, <mode_cmd
                    equs "DISCONNECT"
                    equb >wget_close, <wget_close
                    equb >command_x6, <command_x6

include "routines.asm"
include "errors.asm"
include "serial.asm"
include "driver.asm"
include "version.asm"
include "time.asm"
include "lap.asm"
include "ifcfg.asm"
include "wificmd.asm"
include "join.asm"
include "mode.asm"
include "wget.asm"
include "ping.asm"


skipto &EFF0
.versionstring EQUS "ATOM WIFI V1.00", &E0
.romend             

SAVE "atomwifi.rom", romstart, romend
SAVE "ATOMWIFI.ATM", atmheader, romend
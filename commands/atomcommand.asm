\ Acorn Atom WiFi commands
\ Settings, definitions and constants

\ (C)Roland Leurs 2021
\ Version 1.00 August 2021

__FPGATOM__ = 0
__CODE__    = &0700

if __FPGATOM__

			uart    = &BFC0         \ Base address for the 16C2552 UART B-port
            pagereg = &BFF8
            bankreg = &BFF9
            pageram = &B100
            workspace = &0500       \ Base address of workspace
			strbuf    = &0600       \ Some volatile memory area for string buffer
			switch    = &BFFF       \ Sideways ram control register
			shadow    = &BFFF       \ On FPGAtoms this register is readable

else

            uart    = &BB30         \ Base address for the 16C2552 UART B-port
            pagereg = &BBFF
            pageram = &BC00
            workspace = &0500       \ Base address of workspace
			strbuf    = &0600       \ Some volatile memory area for string buffer
			switch    = &BFFF       \ Sideways ram control register
			shadow    = &04FF       \ Set according to Branquar compilation

endif
            timer     = workspace   \ Count down timer, 3 bytes
			time_out  = timer+4     \ Time-out setting, 1 byte
            heap      = timer+8     \ Some volatile memory area for tempory storage

            osrdch    = &FFE3
            oswrch    = &FFF4
            osnewl    = &FFED
            oswait    = &FE66
            keyscan   = &FE71
            comerr    = &F926      \ COM? error address
            printhex  = &F802      \ Print hex value of accu
            printtext = &F7D1      \ Print string until negative byte encountered
            skipspace = &F875      \ OS routine to read non-space character
            skipspace1= &F876

            line = &100            \ address for command line pointer
            zp = &80               \ workspace

			save_a = zp+2          \ only used in driver, outside driver is may be used for "local" work
			save_y = zp+3          \ only used in driver, outside driver is may be used for "local" work
			save_x = zp+4          \ only used in driver, outside driver is may be used for "local" work
            pr24pad = zp+5
			paramblok = save_y

			data_counter = zp+6
            blocksize = zp+6
            load_addr = zp+9

            baudrate = zp+6         \ must be the same as blocksize because of MUL10 routine
            parity   = zp+9
            databits = zp+10
            stopbits = zp+11

			buffer_ptr = zp+9       \ buffer_ptr and data_pointer must be adjescent!
			data_pointer = zp+11    \ a.k.a. data length
            size = zp+11            \ indeed, same as data_pointer
            needle = zp+12          \ may overlap with data_pointer, 2 bytes
            datalen = zp+13         \ data length counter, 2 bytes


ORG __CODE__-22   ; it contains an ATM header


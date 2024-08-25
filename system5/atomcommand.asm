\ Acorn System 5 WiFi commands
\ Settings, definitions and constants

\ (C)Roland Leurs 2021 - 2024
\ Atom Version 1.00 August 2021
\ System Version 1.00 August 2024

__ATOMSYS5__ = 0
__CODE__    = &7200
LINECOUNT   = 20

if __ATOMSYS5__
            \ Atom2k14 hardware simulating System5
			uart    = &0830         \ Base address for the 16C2552 UART B-port
            pagereg = &08FF
            pageram = &0900
            line = &100             \ address for command line pointer
            workspace = &0500       \ Base address of workspace
			strbuf    = &0600       \ Some volatile memory area for string buffer
			switch    = &0BFF       \ Sideways ram control register, not used in System hardware
			shadow    = &0BFF       \ On FPGAtoms this register is readable
else
            line    = &140          \ address for command line pointer
			uart    = &0B30         \ Base address for the 16C2552 UART B-port
            pagereg = &0BFF
            pageram = &0D00
            workspace = &7000       \ Base address of workspace
			strbuf    = &7100       \ Some volatile memory area for string buffer
			switch    = &0BFF       \ Sideways ram control register, not used in System hardware
			shadow    = &0BFF       \ Set according to Branquar compilation
endif
            timer     = workspace   \ Count down timer, 3 bytes
			time_out  = timer+4     \ Time-out setting, 1 byte
            heap      = timer+8     \ Some volatile memory area for tempory storage

            osrdch    = &FFE3
            oswrch    = &FFF4
            osasci    = &FFE9
            osnewl    = &FFED

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


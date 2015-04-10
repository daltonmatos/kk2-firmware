
SetupHardwareForSatellite:

	;       76543210	;set port directions
	ldi t,0b00110010	;output5, output6
	out ddra,t

	;       76543210
	ldi t,0b00001110
//	ldi t,0b00001111	// DEBUGGING
	out ddrb,t

	;       76543210
	ldi t,0b11111100	;scl, sda, output 1-8
	out ddrc,t

	;       76543210
	ldi t,0b11110010
	out ddrd,t

	;       76543210
	ldi t,0b11111111	;turn off digital inputs on port A
	store didr0,t

	;       76543210
	ldi t,0b11110001	;turn on pull ups on button inputs and aux pin
	out portb,t

	;       76543210
	ldi t,0b00000011	;turn on pull ups SPI pin
	out portc,t

	;       76543210
	ldi t,0b00001101	;turn on pull ups on thr, ele and ail
	out portd ,t


	//*****************************************************************
	// Spektrum receiver binding - Code from David Thompson and Steveis
	//*****************************************************************

	// Wait 70 msec (GetButtons has 10 msec debounce)

	ldx 60
	call WaitXms

	// Bind as master if button 2&3 are pressed

	call GetButtons
	cpi t, 0x06		;button 2&3 pressed for Satellite binding
	brne skipbinding

	ldi xl, 3		;3 bind pulses to force DSM2 1024 single frame

	lds t, RxMode
	cpi t, RxModeSatDSMX
	brne srb1

	ldi xl, 7		;7 bind pulses to force DSMX 2048 single frame

srb1:	// Make port d,0 (throttle) output for binding
	;       76543210
	ldi t,0b11110011
	out ddrd, t

	call bind_master

	// set port D direction back (throttle input)
	;       76543210
	ldi t,0b11110010
	out ddrd, t

	rvsetflagtrue Mode	;set flag to skip ESC calibration

skipbinding:

	;       76543210
	ldi t,0b00000000	;set timer 1 to run at 2.5MHz
	store tccr1a, t

	;       76543210
	ldi t,0b00000010	
	store tccr1b, t

	;       76543210
	ldi t,0b00000000	
	store tccr1c, t



	;--- Init_TWI ---

	lds t, TWSR
	andi t, 0b11111100	;initialize twi prescaler set to 4^0 = 1
	sts TWSR, t

	ldi t, 17 
	sts TWBR, t		;TWBR = ((20000000L / 400000L) - 16) / 2 = 17 for 400kHz clk rate



	;--- Setup LCD --- 

	sbi lcd_cs1		;LCD signals
	sbi lcd_scl
	cbi lcd_res

	LedOn			;I'm alive
	BuzzerOn
	ldx 500
	call WaitXms
	LedOff
	BuzzerOff

	sbi lcd_res

	ldx 100
	call WaitXms

	

	;---

	ret



	;--- Spektrum 8N1 (8 data bits / No parity / 1 stop bit / 115.2Kbps) ---
	
SatUsartInit:

	; Set baud rate
	clr t
	sts ucsr0a, t		; Clear the 2x flag
	sts ubrr0h, t		; Baud High Byte = 0
	ldi t, 0x0A
	sts ubrr0l, t		; Baud Low Byte = 10

	; Enable receiver and Enable Receive Data Complete Interupt, 8 data
	;       76543210
	ldi t,0b10010000
	sts ucsr0b,t

	; Set frame format: Async, No Parity, 1 stop bit, 8 data
	;       76543210
	ldi t,0b00000110
	sts ucsr0c,t

	ret


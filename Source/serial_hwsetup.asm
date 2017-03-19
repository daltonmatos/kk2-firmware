
SetupHardwareForSerialLink:

	;       76543210	;set port directions
	ldi t,0b00110010	// output5, output6
	out ddra, t

	;       76543210
	ldi t,0b00001111	;LED, LVA, buzzer and DG2 digital outputs
	out ddrb, t
	
	;       76543210
	ldi t,0b11111100	// scl, sda, output 1-8
	out ddrc, t

	;       76543210
	ldi t,0b11111110	;LCD control signals (A0, RES, CS1, SCL and SI), serial port TX and LMA output
	out ddrd, t

	;       76543210
	ldi t,0b11111111	;turn off digital inputs on port A
	store didr0, t

	;       76543210
	ldi t,0b11110000	;turn on pull ups on button inputs
	out portb, t

	;       76543210
	ldi t,0b00000011	;turn on pull ups SPI pin
	out portc, t

	;       76543210
	ldi t,0b00001101	;turn on pull ups on thr, ele and ail
	out portd, t


	;--- Set timer 1 to run at 2.5MHz ---

	;       76543210
	ldi t,0b00000000
	store tccr1a, t

	;       76543210
	ldi t,0b00000010
	store tccr1b, t

	;       76543210
	ldi t,0b00000000
	store tccr1c, t


	;--- TWI/I2C setup ---

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
	ret



	;--- Serial 8N1 (8 data bits / No parity / 1 stop bit / 250kbps) ---
	
SerialLinkInit:

	;set baud rate
	ldi t, 0b00000010
	sts ucsr0a, t		;set the 2x flag
	sts ucsr1a, t		;set the 2x flag

	clr t
	sts ubrr0h, t		;Baud high byte = 0
	sts ubrr1h, t		;Baud high byte = 0

	ldi t, 0x09
	sts ubrr0l, t		;Baud low byte = 9
	sts ubrr1l, t		;Baud low byte = 9

	;       76543210
	ldi t,0b10010000	;enable receiver and Enable Receive Data Complete Interrupt
	sts ucsr0b, t

	;       76543210
	ldi t,0b00001000	;enable transmitter
	sts ucsr1b, t

	;       76543210
	ldi t,0b00000110	;set frame format: Async, No Parity, 1 stop bit, 8 data bits
	sts ucsr0c, t
	sts ucsr1c, t

	ret



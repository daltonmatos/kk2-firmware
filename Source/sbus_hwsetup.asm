
SetupHardwareForSBus:

	;       76543210	;set port directions
//	ldi t,0b00000000
	ldi t,0b00110010	// output5, output6
	out ddra,t

	;       76543210
	ldi t,0b00001111
	out ddrb,t

	;       76543210
//	ldi t,0b11111111
	ldi t,0b11111100	// scl, sda, output 1-8
	out ddrc,t

	;       76543210
	ldi t,0b11110010
	out ddrd,t

	;       76543210
	ldi t,0b11111111	;turn off digital inputs on port A
	store didr0,t

	;       76543210
	ldi t,0b11110101	;turn on pull ups on button inputs and aux, rud
	out portb,t

	;       76543210
	ldi t,0b00000011	;turn on pull ups SPI pin
	out portc,t

	;       76543210
	ldi t,0b00001101	;turn on pull ups on thr, ele and ail
	out portd ,t

	;       76543210
	ldi t,0b00000000	;set timer 1 to run at 2.5MHz
	store tccr1a, t

	;       76543210
	ldi t,0b00000010	
	store tccr1b, t

	;       76543210
	ldi t,0b00000000	
	store tccr1c, t


	;--- Setup USART0 for S.Bus communication ---

usart1:	load t, ucsr0a		;make sure USART RX buffer is empty
	andi t, 0x80
	breq usart2

	load t, udr0
	rjmp usart1

usart2:	ldi t, 0x02		;set the 2x flag (U2X0)
	store ucsr0a, t

	clr t			;set baud rate registers for 100k baud. Baud = 20000000 / ( 8 * (UBRRn + 1))	Where U2X0 = 1
	store ubrr0h, t

	ldi t, 0x18		;UBRRn = (fOSC / (8 * BAUD)) - 1 = (20000000 / 800000) - 1 = 24
	store ubrr0l, t

	ldi t, 0x10		;enable receiver (RXEN0)
	store ucsr0b, t

	;       76543210
	ldi t,0b00101110	;use asynchronous mode and 8E2 communication
	store ucsr0c, t

	load t, ucsr0b		;enable USART RX Complete Interrupt (RXCIE0)
	ori t, 0x80
	store ucsr0b, t



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


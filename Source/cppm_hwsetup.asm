
SetupHardwareForCppm:

	;       76543210	;set port directions
	ldi t,0b00110010	// output5, output6
	out ddra,t

	;       76543210
	ldi t,0b00001110
//	ldi t,0b00001111	// DEBUGGING
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
	ldi t,0b11110001	;turn on pull ups on button inputs and aux pin
	out portb,t

	;       76543210
	ldi t,0b00000011	;turn on pull-ups TWI pins
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

	;       76543210
	ldi t,0b00001000	;CPPM input on throttle pin
	store pcicr, t

	;       76543210
	ldi t,0b00000001
	store pcmsk3, t



	;--- Init TWI ---

	lds t, TWSR
	andi t, 0b11111100	;initialize TWI prescaler set to 4^0 = 1
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


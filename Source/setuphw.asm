
SetupHardware:

	;       76543210	;set port directions
	ldi t,0b00000000
	out ddra,t

	;       76543210
	ldi t,0b00001010
//	ldi t,0b00001011	// DEBUGGING
	out ddrb,t

	;       76543210
	ldi t,0b11111111
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
	ldi t,0b00010101	;setup external interrupts.
	store eicra, t

	;       76543210
	ldi t,0b00000011	;aileron and elevator
	store eimsk, t

	;       76543210
	ldi t,0b00001010
	store pcicr, t

	;       76543210
	ldi t,0b00000001	;throttle
	store pcmsk3, t

	;       76543210
	ldi t,0b00000101	;rudder and aux
	store pcmsk1, t



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


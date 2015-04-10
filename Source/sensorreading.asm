AdcRead:
	ldi t, 1
	rcall AdcReadChannel
	b16store GyroRoll

	ldi t, 2
	rcall AdcReadChannel
	b16store GyroYaw

	ldi t, 3
	rcall AdcReadChannel
	b16store BatteryVoltage

	ldi t, 4
	rcall AdcReadChannel
	b16store GyroPitch

	ldi t, 5
	rcall AdcReadChannel
	b16store AccX

	ldi t, 6
	rcall AdcReadChannel
	b16store AccY

	ldi t, 7
	rcall AdcReadChannel
	b16store AccZ

	ret



AdcReadChannel:
	store admux, t		;channel to be read

	;        76543210
	ldi t, 0b11000111
	store adcsra, t		;start ADC

	ldx 2500		;timeout limit (X * 8 cycles)
	
	clr yh

adc2:	sbiw x, 1		;wait until finished or timeout
	brcs adc1
	lds t, adcsra
	sbrc t, adsc
	rjmp adc2
	
	cli
	load xl, adcl		;X = ADC
	load xh, adch
	sei
	ret

adc1:	;log timeout error here


	ret




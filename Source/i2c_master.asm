

	;--- Write a single byte ---

I2C_writeData:

	;--- Start ---

	rcall I2C_waitForStart
	brcs iicerr


	;--- Slave address ---

	ldi t, SlaveAddress + 0			;slave address (+ write bit)
	store TWDR, t

	ldi t, (1<<TWINT)|(1<<TWEN)		;re-enable and send request to slave
	store TWCR, t

	call I2C_wait				;wait for response

	load t, TWSR				;check status
	andi t, 0b11111000
	cpi t, 0x18
	brne iicerr


	;--- Register ---

	lds t, TWI_address			;register address
	store TWDR, t

	ldi t, (1<<TWINT)|(1<<TWEN)		;re-enable and send request to slave
	store TWCR, t

	call I2C_wait				;wait for response

	load t, TWSR				;check status
	andi t, 0b11111000
	cpi t, 0x28
	brne iicerr


	;--- Data ---

	lds t, TWI_data				;data byte to be sent
	store TWDR, t

	ldi t, (1<<TWINT)|(1<<TWEN)		;re-enable and send data
	store TWCR, t

	call I2C_wait				;wait for response

	load t, TWSR				;check status
	andi t, 0b11111000
	cpi t, 0x28
	brne iicerr


	;--- Stop ---

	ldi t, (1<<TWINT)|(1<<TWEN)|(1<<TWSTO)	;re-enable and transmit STOP
	store TWCR, t
	ret



	;--- Error handler ---

iicerr:

	clr yl					;tag data as invalid
	ret



	;--- Read data into SRAM buffer ---

I2C_readData:

	clr yl					;tag data as invalid


	;--- Start ---

	rcall I2C_waitForStart
	brcs iicerr


	;--- Slave address ---

	ldi t, SlaveAddress + 0			;slave address (+ write bit)
	store TWDR, t

	ldi t, (1<<TWINT)|(1<<TWEN)		;re-enable and send request to slave
	store TWCR, t

	call I2C_wait				;wait for response

	load t, TWSR				;check status
	andi t, 0b11111000
	cpi t, 0x18
	brne iicerr


	;--- Register ---

	lds t, TWI_address			;register address
	store TWDR, t

	ldi t, (1<<TWINT)|(1<<TWEN)		;re-enable and send request to slave
	store TWCR, t

	call I2C_wait				;wait for response

	load t, TWSR				;check status
	andi t, 0b11111000
	cpi t, 0x28
	brne iicerr


	;--- Restart ---

	rcall I2C_waitForStart
	brcs iicerr


	;--- Slave address ---

	ldi t, SlaveAddress + 1			;slave address (+ read bit)
	store TWDR, t

	ldi t, (1<<TWINT)|(1<<TWEN)		;re-enable and send request to slave
	store TWCR, t

	call I2C_wait				;wait for response

	load t, TWSR				;check status
	andi t, 0b11111000
	cpi t, 0x40
	brne iicerr


	;--- Read data ---

iicrd5:	dec yh					;register YH holds the number of bytes to read
	breq iicrd6

	ldi t, (1<<TWINT)|(1<<TWEN)|(1<<TWEA)	;re-enable and read (more data remaining)
	rjmp iicrd7

iicrd6:	ldi t, (1<<TWINT)|(1<<TWEN)		;re-enable and read final data byte

iicrd7:	store TWCR, t

	call I2C_wait				;wait for response

	load t, TWSR				;check status
	andi t, 0b11110000			;mask accepts 0x50 and 0x58
	cpi t, 0x50
	brne iicerr

	load t, TWDR				;store data in SRAM buffer
	st x+, t

	tst yh					;contimue reading?
	brne iicrd5


	;--- Stop ---

	ldi t, (1<<TWINT)|(1<<TWEN)|(1<<TWSTO)	;re-enable and transmit STOP
	store TWCR, t

	ser yl					;tag data as valid
	ret



	;--- Wait for I2C start/restart condition ---

I2C_waitForStart:

	ldi t, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)	;enable and transmit START
	store TWCR, t

	call I2C_wait				;wait for START to be transmitted

	load t, TWSR				;check Status
	andi t, 0b11111000
	cpi t, 0x08				;start?
	breq iicwfs

	cpi t, 0x10				;restart?
	breq iicwfs

	sec					;error
	ret

iicwfs:	clc					;success
	ret



	;--- Wait for I2C response ---

I2C_wait:

	load t, TWCR
	sbrs t, TWINT

	rjmp I2C_wait

	ret



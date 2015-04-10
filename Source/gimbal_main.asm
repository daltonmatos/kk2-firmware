
	;--- Main routine for gimbal controller mode ---

GimbalMain:


	;--- Misc. ---

	clr t				;reset flags
	sts flagSlOn, t
	sts flagSlStickMixing, t
	sts flagAlarmOn, t

	sei				;enable global interrupts

	rvsetflagtrue Mode		;will prevent buttons held down during start-up from opening the menu or changing user profile


	;--- Reset LCD contrast when button #1 is held down ---

	call GetButtons
	cpi t, 0x08
	brne gm2

	call SetDefaultLcdContrast


	;--- Flight loop init ---

gm2:	call FlightInit

	;       76543210		;clear pending OCR1A and B interrupt
	ldi t,0b00000110
	store tifr1, t


	;--- Flight loop ---

gm1:	call PwmStart			;runtime between PwmStart and B interrupt (in PwmEnd) must not exeed 1.5ms
	call GetRxChannels
	call Imu
	call Mixer
	call GimbalStab
	call Beeper
	call Lva
	call PwmEnd

	b16clr NoActivityTimer		;prevent the "no activity" alarm from going off

	rvbrflagfalse flagLcdUpdate, gm3;update LCD once if flagLcdUpdate is true

	rvsetflagfalse flagLcdUpdate
	call UpdateFlightDisplay

gm3:	rvbrflagfalse flagArmed, gm7	;skip buttonreading if armed
	rjmp gm1

gm7:	load t, pinb			;read buttons
	com t
	swap t
	andi t, 0x0F			;any button pushed?
	brne gm4

	rvsetflagfalse Mode		;no, reset Mode and ButtonDelay, and then go to start of the loop

gm8:	lrv ButtonDelay, 0
	rjmp gm1	

gm4:	rvinc ButtonDelay		;yes, ButtonDelay++
	rvcpi ButtonDelay, 50		;ButtonDelay == 50?
	breq gm6			;yes, re-check button
	rjmp gm1			;no, go to start of the loop	

gm6:	rvbrflagtrue Mode, gm8		;abort if the button hasn't been released since start-up

;	         76543210		;disable OCR1A and B interrupt
	ldi t, 0b00000000
	store timsk1, t

	call GetButtons			;re-check the button and abort if it was released too soon
	andi t, 0x07
	breq gm8

	cpi t, 0x01
	breq gm9


	;--- User profile ---

	call ChangeUserProfile
	rjmp gm2


gm9:	;--- Menu ---

	call Beep
	BuzzerOff			;will prevent constant beeping in menu when 'Button Beep' is disabled
	call StartLedSeq		;the LED flashing sequence will indicate current user profile selection
	call StartPwmQuiet
	call GimbalMainMenu
	call StopPwmQuiet
	call StopLedSeq
	rjmp gm2


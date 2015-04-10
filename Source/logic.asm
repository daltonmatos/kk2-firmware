
Logic:

	;--- Live update ---

	rvbrflagtrue flagArmed, liv1		;skip this section if armed	

	b16dec LiveUpdateTimer			;set flagLcdUpdate every second
	b16clr Temp
	b16cmp LiveUpdateTimer, Temp
	brge lol10

	rvsetflagtrue flagLcdUpdate
	b16ldi LiveUpdateTimer, 400
	rjmp lol10

liv1:

	;--- Flashing LED if status bits are set while armed ---

	lds t, StatusBits
	tst t
	breq lol10

	lds t, FlashingLEDCounter
	tst t
	breq lol1
	brmi lol6
	rjmp lol3

lol1:	ldi t, 40
	LedOn

	lds zl, FlashingLEDCount		;update counter every time the LED is turned on
	dec zl
	sts FlashingLEDCount, zl
	tst zl
	brne lol5

	lds zl, StatusBits			;clear the LVA Warning bit to end flashing
	cbr zl, LvaWarning
	sts StatusBits, zl
	rjmp lol5

lol3:	dec t
	breq lol4

	rjmp lol5

lol4:	ldi t, -60
	LedOff
	rjmp lol5

lol6:	inc t
	breq lol1

lol5:	sts FlashingLEDCounter, t

lol10:

	;--- Activate functions based on AUX switch position ---

	lds t, AuxSwitchPosition		;skip this section if the AUX switch position is unchanged
	lds xl, AuxSwitchPositionOld
	cp t, xl
	brne asp1

	rjmp asp20

asp1:	sts AuxSwitchPositionOld, t

	tst xl					;produce a short beep when the AUX switch changes position
	brmi asp6

	ser xl
	sts flagDebugBuzzerOn, xl

asp6:	ldx AuxPos1Function			;calculate the address of the variable holding the function ID
	add xl, t
	brcc asp2

	inc xh

asp2:	clr t					;reset flags
	sts flagSlOn, t
	sts flagSlStickMixing, t
	sts flagAlarmOn, t

	ld t, x					;check the function ID
	tst t					;acro?
	breq asp20

	cpi t, 3				;alarm?
	brne asp4

	rvsetflagtrue flagAlarmOn		;yes, set flag and re-initialize the delay counter
	ser t
	sts AuxBeepDelay, t
	rjmp asp3				;activate SL Stick Mixing mode

asp4:	cpi t, 2				;normal SL?
	brne asp3

	rvsetflagtrue flagSlOn			;yes
	b16mov SelflevelPgain, SelflevelPgainOrg
	rjmp asp20

asp3:	ser xl					;SL Stick Mixing is active
	sts flagSlStickMixing, xl

asp20:


	;--- LED flashing in sync with the LVA beeps ---

	rvbrflagtrue flagLvaBuzzerOn, led2



	;--- Turn on LED if armed ---

	rvbrflagtrue flagArmed, led1

led2:	LedOff
	ret

led1:	lds t, StatusBits			;allow the LED to flash when status bits are set
	tst t
	brne led3

	LedOn

led3:	ret



Logic:

	;--- Live update ---

	rvbrflagtrue flagArmed, liv1		;skip this section when armed

	b16dec LiveUpdateTimer			;set flagLcdUpdate every second
	brlt liv2

	rjmp lol10

liv2:	rvsetflagtrue flagLcdUpdate
	b16ldi LiveUpdateTimer, 400
	rjmp lol10

liv1:

	;--- Flight timer update ---

	rvbrflagtrue flagThrottleZero, tim1	;skip this section if throttle is zero

	b16dec FlightTimer
	brne tim1

	b16ldi FlightTimer, 398			;tuned for better accuracy

	lds xl, Timer1sec			;flight timer (running while motors are spinning)
	inc xl
	cpi xl, 60
	brne tim2

	lds xh, Timer1min
	inc xh
	sts Timer1min, xh
	clr xl

tim2:	sts Timer1sec, xl

tim1:

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

	ldx AuxPos1SS				;calculate the address of the variable holding the stick scaling offset
	add xl, t
	brcc asp6

	inc xh

asp6:	ld zl, x				;get the stick scaling offset ID
	andi zl, 0x03
	sts AuxStickScaling, zl

	ldx AuxPos1Function			;calculate the address of the variable holding the function ID
	add xl, t
	brcc asp2

	inc xh

asp2:	clr t					;reset flags
	sts flagSlOn, t
	sts flagSlStickMixing, t
	sts flagAlarmOn, t
	sts flagMotorSpin, t

	ld t, x					;get the function ID
	mov xl, t
	andi t, 0x03

	andi xl, 0x04				;is the Motor Spin feature active?
	breq asp7

	ser xl					;yes
	sts flagMotorSpin, xl

asp7:	lds xl, AuxFunctionOld			;produce a short beep when the AUX function (flight mode + alarm + stick scaling) changes
	swap zl
	or zl, t
	sts AuxFunctionOld, zl
	cp zl, xl
	breq asp5

	ser xl
	sts flagDebugBuzzerOn, xl

asp5:	tst t					;acro?
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


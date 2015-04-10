


	;--- Read S.Bus flags ---

GetSBusFlags:

	;S.Bus flags (4 bit) are stored in SBusFlags:
	;S.Bus data received:	----4567

	lds xl, SBusFlags
	lds xh, RxFrameValid
	tst xh				;is S.Bus data frame valid?
	brne sbf5

	setstatusbit NoSBusInput	;no, exit and refuse arming
	ret

sbf5:	lds t, StatusBits		;yes, clear the "No S.Bus data" error
	cbr t, NoSBusInput
	sts StatusBits, t

	mov t, xl			;read digital channel 17
	andi t, 0x01
	sts Channel17, t

	dec t				;activate alarm when channel 17 is on
	com t
	sts flagAlarmOverride, t

	lsr xl				;read digital channel 18
	mov t, xl
	andi t, 0x01
	sts Channel18, t

	lsr xl				;ignore the 'Frame Lost' flag

	lsr xl				;set the 'Failsafe' flag if one or more failsafe situations occurred
	andi xl, 0x01
	breq sbf1

	sts Failsafe, xl
	setstatusbit SBusFailsafe
	rvsetflagtrue flagAlarmOverride	;activate the Lost Model alarm
	rvbrflagfalse flagArmed, sbf1

	ldi xl, ErrorFailsafe
	call LogError

sbf1:	ret



	;--- Run features assigned to channel 18 (DG2) ---

SBusFeatures:

	lds t, Channel18		;get DG2 switch position
	tst t
	brne ref1

	sbi DigitalOutPin		;off. Reset digital output (aux)
	rjmp ref3

ref1:	lds yl, DG2Functions		;on. Handle active functions
	lsr yl
	brcc ref2

	rvsetflagfalse flagThrottleZero	;keep motors spinning and prevent accidental disarming in mid-air

ref2:	lsr yl
	brcc ref3

	cbi DigitalOutPin		;set digital output (aux)

ref3:	ret


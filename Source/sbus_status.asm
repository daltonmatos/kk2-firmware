


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

	clr xl
	clr xh
	clr yh

	lds t, Channel18		;get DG2 switch position
	tst t
	brne ref1

	cbi DigitalOut4Pin		;off. Use normal stick scaling values and set digital outputs (rudder & aux)
	sbi DigitalOut5Pin
	rjmp ref20

ref1:	lds yl, DG2Functions		;on. Handle active functions
	lsr yl
	brcc ref2

	rvsetflagfalse flagThrottleZero	;keep motors spinning and prevent accidental disarming in mid-air

ref2:	lsr yl
	brcc ref3

	sbi DigitalOut4Pin		;set digital outputs (rudder & aux)
	cbi DigitalOut5Pin

ref3:	lsr yl
	brcc ref4

	adiw x, 20			;increase aileron and elevator stick scaling

ref4:	lsr yl
	brcc ref20

	adiw x, 30			;increase aileron and elevator stick scaling

ref20:	b16store Temp			;increase aileron and elevator stick scaling by 0 (off), 20, 30 or 50
	call TempDiv16
	b16add StickScaleRoll, StickScaleRollOrg, Temp
	b16add StickScalePitch, StickScalePitchOrg, Temp
	ret


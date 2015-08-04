
	;--- Low voltage alarm ---

Lva:

	b16cmp BatteryVoltage, BatteryVoltageLogged			;log the lowest battery voltage
	brge lva4

	b16mov BatteryVoltageLogged, BatteryVoltage

lva4:	b16sub Error, BatteryVoltage, BatteryVoltageLowpass		;lowpass filter
	b16fdiv Error, 8
	b16add BatteryVoltageLowpass, BatteryVoltageLowpass, Error

	b16sub Error, BattAlarmVoltage, BatteryVoltageLowpass		;calculate error
	brpl lva3
	rjmp lva1

lva3:	b16fdiv Error, 2

	b16ldi Temp, 16							;limit error
	b16cmp Error, Temp
	brlt lva2

	b16mov Error, Temp

lva2:	b16add LvaDdsAcc, LvaDdsAcc, Error				;DDS
	b16load LvaDdsAcc
	tst xl
	brmi lva1

	lds t, LvaDdsOn							;limit the buzzer "on" time
	tst t
	breq LvaOutputOff

	dec t
	sts LvaDdsOn, t

	rvsetflagtrue flagLvaBuzzerOn

	lds t, RxMode							;set digital output when not in standard RX mode
	cpi t, RxModeStandard
	breq lva6

	sbi LvaOutputPin

lva6:	ret

lva1:	ldi t, 100
	sts LvaDdsOn, t


LvaOutputOff:

	rvsetflagfalse flagLvaBuzzerOn

	lds t, RxMode							;clear digital output when not in standard RX mode
	cpi t, RxModeStandard
	breq loo1

	cbi LvaOutputPin

loo1:	ret



	;--- Check the LVA setting ---

CheckLvaSetting:

	b16ldi Temper, 1.22			;LVA value set too low?
	b16mul Temp, BattAlarmVoltage, Temper
	b16cmp Temp, BatteryVoltage
	brge cls1

	setstatusbit LvaWarning			;yes, the LED will flash rapidly for a few seconds after arming

cls1:	ret


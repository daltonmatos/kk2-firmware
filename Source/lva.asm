

	;--- Low voltage alarm ---

Lva:

	b16loadx BatteryVoltage						;log the lowest battery voltage
	b16loadz BatteryVoltageLogged
	cp xl, zl
	cpc xh, zh
	brge lva4

	b16storex BatteryVoltageLogged
	lds yh, Timer1min
	lds yl, Timer1sec
	sts BattLogTimeMin, yh
	sts BattLogTimeSec, yl

lva4:	lds kh, BattAlarmVoltage + 0					;skip LVA calculations when alarm is deactivated
	lds kl, BattAlarmVoltage + 1
	clr ka
	cp kl, ka
	cpc kh, ka
	breq lva5

//	b16sub Error, BatteryVoltage, BatteryVoltageLowpass		;lowpass filter
	lds zh, BatteryVoltageLowpass + 0
	lds zl, BatteryVoltageLowpass + 1
	lds yl, BatteryVoltageLowpass + 2
	clr yh
	sub yh, yl
	sbc xl, zl
	sbc xh, zh
//	b16fdiv Error, 8
	mov yh, xl
	mov xl, xh
	mov t, xh
	clr xh
	lsl t
	sbci xh, 0
//	b16add BatteryVoltageLowpass, BatteryVoltageLowpass, Error
	add yh, yl
	adc xl, zl
	adc xh, zh
	b16store BatteryVoltageLowpass

	lds t, LvaHysteresis						;add hysteresis value
	add kl, t
	adc kh, ka

//	b16sub Error, BattAlarmVoltage, BatteryVoltageLowpass		;calculate error
	sub ka, yh
	sbc kl, xl
	sbc kh, xh
	brpl lva3

	clr t								;reset hysteresis value
	sts LvaHysteresis, t

lva5:	rjmp lva1

lva3:	sub kl, t							;subtract hysteresis value again to avoid affecting the LVA beeps
	clr t
	sbc kh, t
	brpl lva7

	clr kh
	clr kl

lva7:	ldi t, 10							;set hysteresis value
	sts LvaHysteresis, t

//	b16fdiv Error, 2
	asr kh
	ror kl
	ror ka
	asr kh
	ror kl
	ror ka

//	b16ldi Temp, 16							;limit error
	clr xh
	ldi xl, 16
	clr yh
//	b16cmp Error, Temp
	cp ka, yh
	cpc kl, xl
	cpc kh, xh
	brlt lva2

//	b16mov Error, Temp
	movw k, x
	mov ka, yh

lva2://	b16add LvaDdsAcc, LvaDdsAcc, Error				;DDS
	lds xl, LvaDdsAcc + 1
	lds yh, LvaDdsAcc + 2
	add yh, ka
	adc xl, kl
	sts LvaDdsAcc + 1, xl
	sts LvaDdsAcc + 2, yh
//	lds xl, LvaDdsAcc + 1
//	tst xl
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

	rvbrflagfalse flagArmed, cls1		;skip the LVA check when disarming

	b16ldi Temper, 1.22			;LVA value set too low?
	b16mul Temp, BattAlarmVoltage, Temper
	b16cmp Temp, BatteryVoltage
	brge cls1

	setstatusbit LvaWarning			;yes, the LED will flash rapidly for a few seconds after arming

cls1:	ret


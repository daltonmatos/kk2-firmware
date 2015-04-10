
	;--- Turn off buzzer when BeeperDelay runs out ----

Beeper:

	b16clr Temp					;is BeeperDelay == 0 ?
	b16cmp BeeperDelay, Temp
	breq bee1

	b16dec BeeperDelay				;No, subtract one and exit
	rjmp bee2


bee1:	rvsetflagfalse flagGeneralBuzzerOn		;yes, turn off buzzer and exit


bee2:	;--- Turn off buzzer previously activated by an AUX switch position change ---

	rvbrflagfalse flagDebugBuzzerOn, bee11

	lds t, AuxCounter
	dec t
	sts AuxCounter, t
	tst t
	brne bee11

	rvsetflagfalse flagDebugBuzzerOn
	ldi xl, AuxCounterInit
	sts AuxCounter, xl


bee11:	;--- Make a short beep regulary when armed and throttle at idle ---

	rvflagand flagA, flagArmed, flagThrottleZero
	rvbrflagfalse FlagA, bee4

	rvbrflagtrue flagAlarmOverride, bee4			;skip this section if failsafe was trigged

	b16dec ArmedBeepDds
	brge bee4

	b16ldi ArmedBeepDds, 400*2

	rvsetflagtrue flagGeneralBuzzerOn
	b16ldi BeeperDelay, 20


bee4:	;--- No activity alarm ---

	rvflageor flagA, flagArmed, flagArmedOldState		;flagA == true if flagArmed changes state

	rvbrflagfalse flagA, bee5				;activity?

	b16clr NoActivityTimer					;Yes, reset timer

bee5:	b16ldi Temp, 0.004					;add 3.90625ms to timer
	b16add NoActivityTimer, NoActivityTimer, Temp

	b16ldi Temp, 32000					;avoid wrap-around
	b16cmp NoActivityTimer, Temp
	brlt bee8

	b16mov NoActivityTimer, Temp

bee8:	rvbrflagtrue flagAlarmOverride, bee10
	rvbrflagfalse flagAlarmOn, bee9				;is alarm activated by AUX switch?

bee10:	lds t, AuxBeepDelay					;short delay
	tst t
	breq bee7

	dec t
	sts AuxBeepDelay, t
	b16clr NoActivityDds

bee9:	b16ldi Temp, 937.5 * 3					;30 minutes without activity? (arming or disarming)
	b16cmp NoActivityTimer, Temp
	brlt bee6

bee7:	b16dec NoActivityDds					;yes, beep once every 5s
	brge bee6

	b16ldi NoActivityDds, 400*5
	rvsetflagtrue flagGeneralBuzzerOn
	b16ldi BeeperDelay, 400


bee6:	;--- Turn buzzer on/off depending on flags ---

	rvflagor flagA, flagGeneralBuzzerOn, flagLvaBuzzerOn
	rvflagor flagA, flagA, flagDebugBuzzerOn
	rvbrflagtrue flagA, bee3

	BuzzerOff
	ret

bee3:	BuzzerOn
	ret




	;--- A short (button) beep ---

Beep:

	push t				;check beep setting
	pushz
	ldz eeButtonBeep
	call ReadEeprom
	popz
	brflagtrue t, beep1

	pop t				;button beep is turned off
	ret

beep1:	push yl				;beep

	BuzzerOn
	ldi yl, 50
	call wms
	BuzzerOff

	pop yl
	pop t
	ret

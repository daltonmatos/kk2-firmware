



	;--- Arming/Disarming ---

Arming:

	rvflagand flagA, flagThrottleZero, flagAutoDisarm	;auto disarm logic
	rvflagand flagA, flagA, flagArmed
	rvbrflagtrue flagA, arm10	

	b16clr AutoDisarmDelay					;if throttle is non-zero or auto disarm is off, clear counter
	rjmp arm12

arm10:	b16inc AutoDisarmDelay					;if throttle is zero and autodisarm is on, inc counter
	b16ldi Temp, 400 * 20
	b16cmp AutoDisarmDelay, Temp				;counter = 20 sec?
	brne arm12

	b16clr AutoDisarmDelay					;Yes, disarm
	rvsetflagfalse flagArmed
	rvsetflagtrue flagLcdUpdate

	rvsetflagtrue flagAlarmOverride				;turn on the Lost Model Alarm
	ldi t, 1						;make sure the 'NoActivityDds' counter will be reset
	sts AuxBeepDelay, t
	ret

arm12:	rvbrflagfalse flagThrottleZero, arm1

	b16ldi Temp, -500			;rudder in Arming position?
	b16cmp RxYaw, Temp
	brlt arm2

	b16ldi Temp, 500			;rudder in Safe position?
	b16cmp RxYaw, Temp
	brge arm2

arm1:	lrv ArmingDelay, 0			;no, clear delay counter and exit
	ret

arm2:	rvinc ArmingDelay			;yes, ArmingDelay++
	lds t, ArmingDelay
	cpi t, 255				;delay reached?
	breq arm9

	rjmp arm3				;no, leave

arm9:	b16load RxYaw
	tst xh					;yes, set or clear flagArmed depending on the rudder direction
	brpl arm6

	lds t, StatusBits			;skip arming if status is not OK.
	cbr t, LvaWarning			;ignore Low Voltage Alarm warning
	breq arm5

	ret

arm5:	rvsetflagtrue flagArmed			;arm
	b16ldi BeeperDelay, 300
	call GyroCal				;calibrate gyros
	call Initialize3dVector			;set 3d vector to point straigth up

	ldi t, 10				;initialize counter for warning about no LVA value set
	sts FlashingLEDCount, t
	rjmp Arm11

arm6:	rvsetflagfalse flagArmed		;disarm
	b16ldi BeeperDelay, 150

arm11:	rvsetflagfalse flagAlarmOverride	;arming/disarming will stop the Lost Model Alarm if overridden

	ldz eeArmingBeeps			;check beep setting
	call GetEePVariable8
	brflagfalse xl, arm4

	rvsetflagtrue flagGeneralBuzzerOn

arm4:	rvsetflagtrue flagLcdUpdate
	b16ldi ArmedBeepDds, 400*2
	b16clr AutoDisarmDelay

arm3:	ret



	;--- Specialized setup and main routine for CPPM receivers ---

CppmMain:

	call SetupHardwareForCppm


	;--- Initialize LCD ---

	ldz eeLcdContrast
	call ReadEeprom
	sts LcdContrast, t

	call LcdUpdate
	call LcdClear
	call LcdUpdate


	;--- Variables init ---

	call EeInit

	lrv MainMenuCursorYposSave, 0
	lrv MainMenuListYposSave, 0

	lrv LoadMenuCursorYposSave, 0
	lrv LoadMenuListYposSave, 0

	b16ldi BatteryVoltageLogged, 1023

	clr t
	sts TuningMode, t

	sts flagPwmGen, t

	sts FlashingLEDCounter, t

	ldi xl, AuxCounterInit
	sts AuxCounter, xl
	sts AuxSwitchPosition, t
	ldi xl, 1
	sts Aux4SwitchPosition, xl

	sts CppmChannel1L, t
	sts CppmChannel1H, t
	sts CppmChannel2L, t
	sts CppmChannel2H, t
	sts CppmChannel3L, t
	sts CppmChannel3H, t
	sts CppmChannel4L, t
	sts CppmChannel4H, t
	sts CppmChannel5L, t
	sts CppmChannel5H, t
	sts CppmChannel6L, t
	sts CppmChannel6H, t
	sts CppmChannel7L, t
	sts CppmChannel7H, t
	sts CppmChannel8L, t
	sts CppmChannel8H, t

	sts RxFrameValid, t
	lrv CppmDetectionCounter, CppmDetectionCount

	ldz CppmChannel1L
	sts CppmPulseArrayAddressL, zl
	sts CppmPulseArrayAddressH, zh

	ldi xl, 3			;RxBufferState must be set to 3 (i.e. "New data") to make the Tuning and AUX Settings screens work properly
	sts RxBufferState, xl

	ldi t, NoCppmInput
	sts StatusBits, t

	call setup_mpu6050

	call GyroCal



	;--- ESC calibration ----

	sei				;global interrupts must be enabled here for PWM output in EscThrottleCalibration

	ldz eeEscCalibration		;check ESC calibration setting
	call ReadEeprom
	tst t
	breq cm5			;jump if ESC calibration is disabled

	call DisableEscCalibration

	load t, pinb			;read buttons. Will not use 'GetButtons' here because of delay
	com t
	swap t
	andi t, 0x0f			;any button pressed?
	breq cm2

	call FlightInit			;some variables must be initialized prior to ESC calibration
	call EscThrottleCalibration
	rjmp cm2



	;--- Reset LCD contrast if button #1 is held down ---

cm5:	call GetButtons
	cpi t, 0x08
	brne cm2

	call SetDefaultLcdContrast



	;--- Flight loop init ---

cm2:	call FlightInit

	;       76543210		;clear pending OCR1A and B interrupt
	ldi t,0b00000110
	store tifr1, t



	;--- Flight loop ---

cm1:	call PwmStart			;runtime between PwmStart and B interrupt (in PwmEnd) must not exeed 1.5ms
	call GetCppmChannels
	call CheckCppmRx
	call Arming
	call Logic
	call Tuning
	call Imu
	call HeightDampening
	call Mixer
	call GimbalStab
	call Beeper
	call Lva
	call PwmEnd

	rvflageor flagA, flagArmed, flagArmedOldState	;flagA == true if flagArmed changes state
	rvbrflagfalse flagA, cm11

	call CheckLvaSetting

	lds t, flagArmed
	sts flagArmedOldState, t

cm11:	rvbrflagfalse flagLcdUpdate, cm3;update LCD once if flagLcdUpdate is true

	rvsetflagfalse flagLcdUpdate
	call UpdateFlightDisplay

cm3:	rvbrflagfalse flagArmed, cm7	;skip buttonreading if armed
	rjmp cm1

cm7:	load t, pinb			;read buttons
	com t
	swap t
	andi t, 0x07			;PROFILE or MENU?
	brne cm4
	
cm8:	lrv ButtonDelay, 0		;no, reset ButtonDelay, and go to start of the loop
	rjmp cm1	

cm4:	rvinc ButtonDelay		;yes, ButtonDelay++
	rvcpi ButtonDelay, 50		;ButtonDelay == 50?
	breq cm6			;yes, re-check button
	rjmp cm1			;no, go to start of the loop	

cm6:;	         76543210		;disable OCR1A and B interrupt
	ldi t, 0b00000000
	store timsk1, t

	call GetButtons			;re-check the button and abort if it was released too soon
	andi t, 0x07
	breq cm8

	cpi t, 0x01
	breq cm9


	;--- User profile ---

	call ChangeUserProfile
	rjmp cm2


cm9:	;--- Menu ---

	call Beep
	BuzzerOff			;will prevent constant beeping in menu when 'Button Beep' is disabled
	call StartLedSeq		;the LED flashing sequence will indicate current user profile selection
	call StartPwmQuiet
	call CppmMainMenu
	call StopPwmQuiet
	call StopLedSeq
	rjmp cm2


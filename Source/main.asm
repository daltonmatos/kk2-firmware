
	;--- Specialized setup and main routine for standard receivers ---

Main:

	call SetupHardware


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

	b16ldi CheckRxDelay, 400 * 10

	clr t
	sts TuningMode, t
	sts QTuningIndex, t

	sts flagPwmGen, t

	sts FlashingLEDCounter, t

	ldi xl, AuxCounterInit
	sts AuxCounter, xl
	sts AuxSwitchPosition, t
	ldi xl, 1
	sts Aux4SwitchPosition, xl

	sts flagAlarmOverride, t

	sts RollL, t
	sts RollH, t
	sts PitchL, t
	sts PitchH, t
	sts ThrottleL, t
	sts ThrottleH, t
	sts YawL, t
	sts YawH, t
	sts AuxL, t
	sts AuxH, t

	sts RudderRxPinState, t
	sts AuxRxPinState, t

	ldi xl, 3			;RxBufferState must be set to 3 (i.e. "New data") to make the AUX Settings screen work properly
	sts RxBufferState, xl

	sts StatusBits, t

	call setup_mpu6050

	call GyroCal



	;--- ESC calibration ----

	sei				;global interrupts must be enabled here for PWM output in EscThrottleCalibration

	ldz eeEscCalibration		;check ESC calibration setting
	call ReadEeprom
	tst t
	breq ma5			;jump if ESC calibration is disabled

	call DisableEscCalibration

	load t, pinb			;read buttons. Will not use 'GetButtons' here because of delay
	com t
	swap t
	andi t, 0x0f			;any button pressed?
	breq ma2

	call FlightInit			;some variables must be initialized prior to ESC calibration
	call EscThrottleCalibration
	rjmp ma2



	;--- Reset LCD contrast if button #1 is held down ---

ma5:	call GetButtons
	cpi t, 0x08
	brne ma2

	call SetDefaultLcdContrast



	;--- Flight loop init ---

ma2:	call FlightInit

	;       76543210		;clear pending OCR1A and B interrupt
	ldi t,0b00000110
	store tifr1, t



	;--- Flight loop ---

ma1:	call PwmStart			;runtime between PwmStart and B interrupt (in PwmEnd) must not exeed 1.5ms
	call GetStdRxChannels
	call CheckRx
	call Arming
	call Logic
	call Imu
	call HeightDampening
	call Mixer
	call CameraStab
	call Beeper
	call Lva
	call PwmEnd

	rvflageor flagA, flagArmed, flagArmedOldState	;flagA == true if flagArmed changes state
	rvbrflagfalse flagA, ma11

	call CheckLvaSetting

	lds t, flagArmed
	sts flagArmedOldState, t

ma11:	rvbrflagfalse flagLcdUpdate, ma3;update LCD once if flagLcdUpdate is true

	rvsetflagfalse flagLcdUpdate
	call UpdateFlightDisplay

ma3:	rvbrflagfalse flagArmed, ma7	;skip buttonreading if armed
	rjmp ma1

ma7:	load t, pinb			;read buttons
	com t
	swap t
	andi t, 0x07			;PROFILE or MENU?
	brne ma4

ma8:	lrv ButtonDelay, 0		;no, reset ButtonDelay, and go to start of the loop
	rjmp ma1	

ma4:	rvinc ButtonDelay		;yes, ButtonDelay++
	rvcpi ButtonDelay, 50		;ButtonDelay == 50?
	breq ma6			;yes, re-check button
	rjmp ma1			;no, go to start of the loop	

ma6:;	         76543210		;disable OCR1A and B interrupt
	ldi t, 0b00000000
	store timsk1, t

	call GetButtons			;re-check the button and abort if it was released too soon
	andi t, 0x07
	breq ma8

	cpi t, 0x01
	breq ma9


	;--- User profile ---

	call ChangeUserProfile
	rjmp ma2


ma9:	;--- Menu ---

	call Beep
	BuzzerOff			;will prevent constant beeping in menu when 'Button Beep' is disabled
	call StartLedSeq		;the LED flashing sequence will indicate current user profile selection
	call StartPwmQuiet
	call MainMenu
	call StopPwmQuiet
	call StopLedSeq
	rjmp ma2


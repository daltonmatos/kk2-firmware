
	;--- Specialized setup and main routine for Spektrum Satellite units ---

SatelliteMain:

	rvsetflagfalse Mode		;the Satelite bind process may set this flag to 'true' (i.e. to skip ESC calibration)
	call SetupHardwareForSatellite


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

	sts RxFrameValid, t

	sts RxBufferIndex, t
	sts RxBufferIndexOld, t
	sts RxBufferState, t
	sts RxBuffer2, t
	ldz RxBuffer0
	sts RxBufferAddressL, zl
	sts RxBufferAddressH, zh
	ser t
	sts RxBufferState, t

	ldi t, NoSatelliteInput
	sts StatusBits, t

	call setup_mpu6050

	call GyroCal

	call SatUsartInit


	;--- ESC calibration ----

	sei				;global interrupts must be enabled here for PWM output in EscThrottleCalibration

	ldz eeEscCalibration		;check ESC calibration setting
	call ReadEeprom
	tst t
	breq am5			;jump if ESC calibration is disabled

	call DisableEscCalibration

	rvbrflagtrue Mode, am2		;skip ESC calibration if arriving here after Satellite binding

	load t, pinb			;read buttons. Will not use 'GetButtons' here because of delay
	com t
	swap t
	andi t, 0x0f			;any button pressed?
	breq am2

	call FlightInit			;some variables must be initialized prior to ESC calibration
	call EscThrottleCalibration
	rjmp am2



	;--- Reset LCD contrast if button #1 is held down ---

am5:	call GetButtons
	cpi t, 0x08
	brne am2

	call SetDefaultLcdContrast



	;--- Flight loop init ---

am2:	call FlightInit

	;       76543210		;clear pending OCR1A and B interrupt
	ldi t,0b00000110
	store tifr1, t



	;--- Flight loop ---

am1:	call PwmStart			;runtime between PwmStart and B interrupt (in PwmEnd) must not exeed 1.5ms
	call GetSatChannels
	call CheckSatRx
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
	rvbrflagfalse flagA, am11

	call CheckLvaSetting

	lds t, flagArmed
	sts flagArmedOldState, t

am11:	rvbrflagfalse flagLcdUpdate, am3;update LCD once if flagLcdUpdate is true

	rvsetflagfalse flagLcdUpdate
	call UpdateFlightDisplay

am3:	rvbrflagfalse flagArmed, am7	;skip buttonreading if armed
	rjmp am1

am7:	load t, pinb			;read buttons
	com t
	swap t
	andi t, 0x07			;PROFILE or MENU?
	brne am4
	
am8:	lrv ButtonDelay, 0		;no, reset ButtonDelay, and go to start of the loop
	rjmp am1	

am4:	rvinc ButtonDelay		;yes, ButtonDelay++
	rvcpi ButtonDelay, 50		;ButtonDelay == 50?
	breq am6			;yes, re-check button
	rjmp am1			;no, go to start of the loop	

am6:;	         76543210		;disable OCR1A and B interrupt
	ldi t, 0b00000000
	store timsk1, t

	call GetButtons			;re-check the button and abort if it was released too soon
	andi t, 0x07
	breq am8

	cpi t, 0x01
	breq am9


	;--- User profile ---

	call ChangeUserProfile
	rjmp am2


am9:	;--- Menu ---

	call Beep
	BuzzerOff			;will prevent constant beeping in menu when 'Button Beep' is disabled
	call StartLedSeq		;the LED flashing sequence will indicate current user profile selection
	call StartPwmQuiet
	call SatMainMenu
	call StopPwmQuiet
	call StopLedSeq
	rjmp am2



	;--- Specialized setup and main routine for Spektrum Satellite units ---

SatelliteMain:

	rvsetflagfalse Mode		;the Satelite bind process may set this flag to 'true' (i.e. to skip ESC calibration)
	call SetupHardwareForSatellite


	;--- Initialize LCD ---

	;call LoadLcdContrast; Not needed, called in main.c
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

	b16ldi FlightTimer, 398		;tuned for better accuracy (1 second)

	clr t
	sts Timer1sec, t
	sts Timer1min, t

	sts TuningMode, t

	sts flagPwmGen, t

	sts flagErrorLogSetup, t

	sts FlashingLEDCounter, t

	ldi xl, AuxCounterInit
	sts AuxCounter, xl
	ldi xl, 2
	sts AuxSwitchPosition, xl
	ldi xl, 1
	sts Aux4SwitchPosition, xl
	sts AuxFunctionOld, xl

	sts flagAileronCentered, t	;set to false
	sts flagElevatorCentered, t

	ldi xl, 16
	sts RxFrameLength, xl

	sts RxFrameValid, t
	sts TimeoutCounter, t

	sts RxBufferIndex, t
	sts RxBufferIndexOld, t
	sts RxBufferState, t
	ldz RxBuffer0
	sts RxBufferAddressL, zl
	sts RxBufferAddressH, zh

	sts Channel1L, t
	sts Channel1H, t
	sts Channel2L, t
	sts Channel2H, t
	sts Channel3L, t
	sts Channel3H, t
	sts Channel4L, t
	sts Channel4H, t
	sts Channel5L, t
	sts Channel5H, t
	sts Channel6L, t
	sts Channel6H, t
	sts Channel7L, t
	sts Channel7H, t

	ldi t, NoSatelliteInput
	sts StatusBits, t

	call setup_mpu6050

	call GyroCal

	call SatUsartInit


	;--- Gimbal controller mode ---

	;call GetGimbalControllerMode ; Not needed, called in main.c
	rvbrflagfalse flagGimbalMode, am10

	jmp GimbalMain


am10:	;--- ESC calibration ----

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
	andi t, 0x0F			;any button pressed?
	breq am2

	call EscThrottleCalibration	;yes, do calibration
	rjmp am2


	;--- Misc. ---

am5:	rvsetflagtrue Mode		;will prevent buttons held down during start-up from opening the menu or changing user profile


	;--- Reset LCD contrast when button #1 is held down ---

	call GetButtons
	cpi t, 0x08
	brne am15

	call SetDefaultLcdContrast


	;--- Display the Error Log setup screen when button #4 is held down ---

am15:	cpi t, 0x01
	brne am2

	rvsetflagtrue flagErrorLogSetup


	;--- Flight loop init ---

am2:	call FlightInit

	lds t, StatusBits		;clear the SatProtocolError flag
	cbr t, SatProtocolError
	sts StatusBits, t

	;       76543210		;clear pending OCR1A and B interrupt
	ldi t,0b00000110
	store tifr1, t


	;--- Flight loop ---

am1:	call PwmStart			;runtime between PwmStart and B interrupt (in PwmEnd) must not exeed 1.5ms
	call GetSatChannels
	call CheckSatRx
	call Arming
	call Logic
	call AddAuxStickScaling
#ifdef IN_FLIGHT_TUNING
	call RemoteTuning
#endif
	call Imu
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
	andi t, 0x0F			;any button pushed?
	brne am4

	rvsetflagfalse Mode		;no, reset Mode and ButtonDelay, and then go to start of the loop

am8:	lrv ButtonDelay, 0
	rjmp am1	

am4:	rvinc ButtonDelay		;yes, ButtonDelay++
	rvcpi ButtonDelay, 50		;ButtonDelay == 50?
	breq am6			;yes, re-check button
	rjmp am1			;no, go to start of the loop	

am6:	rvbrflagtrue Mode, am8		;abort if the button hasn't been released since start-up

;	         76543210		;disable OCR1A and B interrupt
	ldi t, 0b00000000
	store timsk1, t

	call GetButtons			;re-check the button and abort if it was released too soon
	andi t, 0x0F
	breq am8

	cpi t, 0x01
	breq am9

	cpi t, 0x08
	breq am13


	;--- User profile ---

	call ChangeUserProfile
	rjmp am2


am9:	;--- Error log ---

	call Beep
	call ClearLoggedError		;clear logged error when the ERROR LOG screen is displayed
	brcc am12

am14:	rvsetflagtrue Mode		;will wait for the button to be released
	rjmp am2

am13:	call Beep
	call ToggleErrorLogState	;toggle error logging state when the setup screen is displayed
	rjmp am14


am12:	;--- Menu ---

	BuzzerOff			;will prevent constant beeping in menu when 'Button Beep' is disabled
	cbi LvaOutputPin		;will avoid constant high level on external LVA output pin
	call StartLedSeq		;the LED flashing sequence will indicate current user profile selection
	call StartPwmQuiet
	call SatMainMenu
	call StopPwmQuiet
	call StopLedSeq
	rjmp am2


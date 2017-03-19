
	;--- Specialized setup and main routine for CPPM receivers ---

CppmMain:

	ldx 100
	call WaitXms

	call SetupHardwareForCppm


	;--- Initialize LCD ---

	call LoadLcdContrast
	call LcdUpdate
	call LcdClear
	call LcdUpdate


	;--- Variables init ---

	call EeInit

	lrv MainMenuCursorYposSave, 0
	lrv MainMenuListYposSave, 0

	lrv LoadMenuCursorYposSave, 0
	lrv LoadMenuListYposSave, 0

	b16ldi BatteryVoltageOffsetOrg, 2000

	b16ldi FlightTimer, 398		;tuned for better accuracy (1 second)

	clr t
	sts Timer1sec, t
	sts Timer1min, t

	sts TuningMode, t
	sts flagPortExpTuning, t

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
	sts Channel8L, t
	sts Channel8H, t

	sts flagRxFrameValid, t
	sts flagRxBufferFull, t
	sts TimeoutCounter, t
	sts CppmChannelCount, t
	sts ChannelCount, t

	b16set RxRoll
	b16set RxPitch
	b16set RxThrottle
;	b16set RxYaw			;rudder value will be cleared later (see flightinit,asm)
	b16set RxAux
	b16set RxAux2
	b16set RxAux3
	b16set RxAux4

	ldz Channel1L
	sts CppmPulseArrayAddressL, zl
	sts CppmPulseArrayAddressH, zh

	rvsetflagtrue flagNewRxFrame 	;flag for "New RX Frame" must be set to make some screens (e.g. AUX Settings) work properly

	ldi t, NoCppmInput
	sts StatusBits, t

	call setup_mpu6050

	call GyroCal


	;--- Gimbal controller mode ---

	call GetGimbalControllerMode
	rvbrflagfalse flagGimbalMode, cm10

	jmp GimbalMain


cm10:	;--- ESC calibration ----

	sei				;global interrupts must be enabled here for PWM output in EscThrottleCalibration

	ldz eeEscCalibration		;check ESC calibration setting
	call ReadEeprom
	tst t
	breq cm5			;jump if ESC calibration is disabled

	call DisableEscCalibration

	load t, pinb			;read buttons. Will not use 'GetButtons' here because of delay
	com t
	swap t
	andi t, 0x0F			;any button pressed?
	breq cm2

	call EscThrottleCalibration	;yes, do calibration
	rjmp cm2


	;--- Misc. ---

cm5:	rvsetflagtrue Mode		;will prevent buttons held down during start-up from opening the menu or changing user profile


	;--- Reset LCD contrast when button #1 is held down ---

	call GetButtons
	cpi t, 0x08
	brne cm15

	call SetDefaultLcdContrast


	;--- Display the Error Log setup screen when button #4 is held down ---

cm15:	cpi t, 0x01
	brne cm2

	rvsetflagtrue flagErrorLogSetup


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
	call AddAuxStickScaling
	call RemoteTuning
	call Imu
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

cm3:	rvbrflagtrue flagArmed, cm1	;skip buttonreading when armed

	load t, pinb			;read buttons
	com t
	swap t
	andi t, 0x0F			;any button pushed?
	brne cm4

	rvsetflagfalse Mode		;no, reset Mode and ButtonDelay, and then go to start of the loop

cm8:	lrv ButtonDelay, 0
	rjmp cm1	

cm4:	rvinc ButtonDelay		;yes, ButtonDelay++
	rvcpi ButtonDelay, 50		;ButtonDelay == 50?
	breq cm6

	rjmp cm1			;no, go to start of the loop	

cm6:	rvbrflagtrue Mode, cm8		;abort if the button hasn't been released since start-up

;	         76543210		;disable OCR1A and B interrupt
	ldi t, 0b00000000
	store timsk1, t

	call GetButtons			;re-check the button and abort if it was released too soon
	andi t, 0x0F
	breq cm8

	cpi t, 0x01
	breq cm9

	cpi t, 0x08
	breq cm13


	;--- User profile ---

	mov yl, t			;register YL is used for button input in ChangeUserProfile
	call Beep
	rvbrflagfalse flagHomeScreen, cm7

	call ChangeUserProfile
	rjmp cm14


cm9:	;--- Error log ---

	call Beep
	call ClearLoggedError		;clear logged error when the ERROR LOG screen is displayed
	brcc cm12

cm14:	rvsetflagtrue Mode		;will wait for the button to be released
	rjmp cm2

cm13:	call Beep
	call ToggleErrorLogState	;toggle error logging state when the setup screen is displayed
	brcs cm7


	;--- Battery log ---

	lds t, flagBatteryLog		;display/exit the battery log screen
	com t
	sts flagBatteryLog, t

cm7:	rvsetflagtrue Mode		;will wait for the button to be released
	rjmp cm1


cm12:	;--- Menu ---

	rvbrflagfalse flagHomeScreen, cm7

	BuzzerOff			;will prevent constant beeping in menu when 'Button Beep' is disabled
	cbi LvaOutputPin		;will avoid constant high level on external LVA output pin
	call StartLedSeq		;the LED flashing sequence will indicate current user profile selection
	call StartPwmQuiet
	call CppmMainMenu
	call StopPwmQuiet
	call StopLedSeq
	rjmp cm14


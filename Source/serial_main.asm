
	;--- Specialized setup and main routine for serial link ---

SerialMain:

	ldx 100
	call WaitXms

	call SetupHardwareForSerialLink
	call SerialLinkInit


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

	lrv RxModePortExp, RxModeStandard

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

	ldi xl, 0x12			;set AUX and AUX4 switches to center position initially
	sts RxSwitches, xl
	ldi xl, 2
	sts AuxSwitchPosition, xl
	ldi xl, 1
	sts Aux4SwitchPosition, xl
	sts AuxFunctionOld, xl

	sts flagAileronCentered, t	;set to false
	sts flagElevatorCentered, t

	sts flagRxFrameValid, t
	sts flagNewRxFrame, t
	sts TimeoutCounter, t

	sts flagRxBufferFull, t
	sts RxBuffer0, t
	ldz RxBuffer0
	sts RxBufferAddressL, zl
	sts RxBufferAddressH, zh
	ldz RxBufferEnd
	sts RxBufferEndL, zl
	sts RxBufferEndH, zh

	ldi t, SyncCount
	sts SerialSyncCounter, t

	ldi t, NoSerialData
	sts StatusBits, t

	call setup_mpu6050

	call GyroCal


	;--- Gimbal controller mode ---

	call GetGimbalControllerMode
	rvbrflagfalse flagGimbalMode, sl10

	jmp GimbalMain


sl10:	;--- ESC calibration ----

	sei				;global interrupts must be enabled here for PWM output in EscThrottleCalibration

	ldz eeEscCalibration		;check ESC calibration setting
	call ReadEeprom
	tst t
	breq sl5			;jump if ESC calibration is disabled

	call DisableEscCalibration

	load t, pinb			;read buttons. Will not use 'GetButtons' here because of delay
	com t
	swap t
	andi t, 0x0F			;any button pressed?
	breq sl2

	call EscThrottleCalibration	;yes, do calibration
	rjmp sl2


	;--- Misc. ---

sl5:	rvsetflagtrue Mode		;will prevent buttons held down during start-up from opening the menu or changing the LVA setting


	;--- Reset LCD contrast when button #1 is held down ---

	call GetButtons
	cpi t, 0x08
	brne sl2

	call SetDefaultLcdContrast


	;--- Flight loop init ---

sl2:	call FlightInit

	;       76543210		;clear pending OCR1A and B interrupt
	ldi t,0b00000110
	store tifr1, t


	;--- Flight loop ---

sl1:	call PwmStart			;runtime between PwmStart and B interrupt (in PwmEnd) must not exeed 1.5ms
	call GetSerialLinkChannels
	call CheckSerialLink
	call SerialSBusFlags
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
	rvbrflagfalse flagA, sl11

	call CheckLvaSetting

	lds t, flagArmed
	sts flagArmedOldState, t

sl11:	rvbrflagfalse flagLcdUpdate, sl3;update LCD once if flagLcdUpdate is true

	rvsetflagfalse flagLcdUpdate
	call UpdateFlightDisplay

sl3:	rvbrflagtrue flagArmed, sl1	;skip buttonreading when armed

	load t, pinb			;read buttons
	com t
	swap t
	andi t, 0x0F			;any button pushed?
	brne sl4

	rvsetflagfalse Mode		;no, reset Mode and ButtonDelay, and then go to start of the loop

sl8:	lrv ButtonDelay, 0
	rjmp sl1	

sl4:	rvinc ButtonDelay		;yes, ButtonDelay++
	rvcpi ButtonDelay, 50		;ButtonDelay == 50?
	breq sl6

	rjmp sl1			;no, go to start of the loop	

sl6:	rvbrflagtrue Mode, sl8		;abort if the button hasn't been released since start-up

;	         76543210		;disable OCR1A and B interrupt
	ldi t, 0b00000000
	store timsk1, t

	call GetButtons			;re-check the button and abort if it was released too soon
	andi t, 0x0F
	breq sl8

	cpi t, 0x01
	breq sl9

	cpi t, 0x08
	breq sl13


	;--- User profile ---

	mov yl, t			;register YL is used for button input in ChangeUserProfile
	call Beep
	rvbrflagfalse flagHomeScreen, sl7

	call ChangeUserProfile
	rjmp sl14


sl9:	;--- Error log ---

	call Beep
	call ClearLoggedError		;clear logged error when the ERROR LOG screen is displayed
	brcc sl12

sl14:	rvsetflagtrue Mode		;will wait for the button to be released
	rjmp sl2

sl13:	call Beep
	call ToggleErrorLogState	;toggle error logging state when the setup screen is displayed
	brcs sl7


	;--- Battery log ---

	lds t, flagBatteryLog		;display/exit the battery log screen
	com t
	sts flagBatteryLog, t

sl7:	rvsetflagtrue Mode		;will wait for the button to be released
	rjmp sl1


sl12:	;--- Menu ---

	rvbrflagfalse flagHomeScreen, sl7

	BuzzerOff			;will prevent constant beeping in menu when 'Button Beep' is disabled
	cbi LvaOutputPin		;will avoid constant high level on external LVA output pin
	call StartLedSeq		;the LED flashing sequence will indicate current user profile selection
	call StartPwmQuiet
	call SerialMainMenu
	call StopPwmQuiet
	call StopLedSeq
	rjmp sl14


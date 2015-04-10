
	;--- Specialized setup and main routine for Futaba S.Bus receivers ---

SBusMain:

	call SetupHardwareForSBus


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
	sts Channel17, t
	sts Channel18, t
	call ClearSBusErrors

	clr t
	sts RxBufferIndex, t
	sts RxBufferIndexOld, t
	sts RxBufferState, t
	sts RxBuffer0, t
	ldz RxBuffer0
	sts RxBufferAddressL, zl
	sts RxBufferAddressH, zh

	ldi t, NoSBusInput
	sts StatusBits, t

	call setup_mpu6050

	call GyroCal



	;--- ESC calibration ----

	sei				;global interrupts must be enabled here for PWM output in EscThrottleCalibration

	ldz eeEscCalibration		;check ESC calibration setting
	call ReadEeprom
	tst t
	breq bm5			;jump if ESC calibration is disabled

	call DisableEscCalibration

	load t, pinb			;read buttons. Will not use 'GetButtons' here because of delay
	com t
	swap t
	andi t, 0x0f			;any button pressed?
	breq bm2

	call FlightInit			;some variables must be initialized prior to ESC calibration
	call EscThrottleCalibration
	rjmp bm2



	;--- Reset LCD contrast if button #1 is held down ---

bm5:	call GetButtons
	cpi t, 0x08
	brne bm2

	call SetDefaultLcdContrast



	;--- Flight loop init ---

bm2:	call FlightInit

	lds t, StatusBits		;clear the failsafe flag
	cbr t, SBusFailsafe
	sts StatusBits, t

	;       76543210		;clear pending OCR1A and B interrupt
	ldi t,0b00000110
	store tifr1, t



	;--- Flight loop ---

bm1:	call PwmStart			;runtime between PwmStart and B interrupt (in PwmEnd) must not exeed 1.5ms
	call GetSBusChannels
	call GetSBusFlags
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
	rvbrflagfalse flagA, bm11

	call CheckLvaSetting

	lds t, flagArmed
	sts flagArmedOldState, t

bm11:	rvbrflagfalse flagLcdUpdate, bm3;update LCD once if flagLcdUpdate is true

	rvsetflagfalse flagLcdUpdate
	call UpdateFlightDisplay

bm3:	rvbrflagfalse flagArmed, bm7	;skip buttonreading if armed
	rjmp bm1

bm7:	load t, pinb			;read buttons
	com t
	swap t
	andi t, 0x07			;PROFILE or MENU?
	brne bm4
	
bm8:	lrv ButtonDelay, 0		;no, reset ButtonDelay, and go to start of the loop
	rjmp bm1	

bm4:	rvinc ButtonDelay		;yes, ButtonDelay++
	rvcpi ButtonDelay, 50		;ButtonDelay == 50?
	breq bm6			;yes, re-check button
	rjmp bm1			;no, go to start of the loop	

bm6:;	         76543210		;disable OCR1A and B interrupt
	ldi t, 0b00000000
	store timsk1, t

	call GetButtons			;re-check the button and abort if it was released too soon
	andi t, 0x07
	breq bm8

	cpi t, 0x01
	breq bm9


	;--- User profile ---

	call ChangeUserProfile
	rjmp bm2


bm9:	;--- Menu ---

	call Beep
	BuzzerOff			;will prevent constant beeping in menu when 'Button Beep' is disabled
	call StartLedSeq		;the LED flashing sequence will indicate current user profile selection
	call StartPwmQuiet
	call SBusMainMenu
	call StopPwmQuiet
	call StopLedSeq
	rjmp bm2


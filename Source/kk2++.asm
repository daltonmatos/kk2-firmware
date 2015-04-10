
;Original code by Rolf R Bakke 2011, 2012, 2013

;best viewed with a TAB-setting of 8 and monospace font.



.include "m324Pdef.inc"
.include "macros.inc"
.include "miscmacros.inc"
.include "variables.asm"
.include "hardware.asm"
.include "168mathlib_macros.inc"
.include "824mathlib_macros.inc"
.include "constants.asm"

.org 0x0000

	jmp reset		; Reset
	jmp IsrPitch		; External Interrupt Request 0
	jmp IsrRoll		; External Interrupt Request 1
	jmp unused		; External Interrupt Request 2
	jmp unused		; Pin Change Interrupt Request 0
	jmp IsrYawAux		; Pin Change Interrupt Request 1
	jmp unused		; Pin Change Interrupt Request 2
	jmp IsrThrottle		; Pin Change Interrupt Request 3
	jmp unused		; Watchdog Time-out Interrupt
	jmp unused		; Timer/Counter2 Compare Match A
	jmp unused		; Timer/Counter2 Compare Match B
	jmp IsrPwmQuiet		; Timer/Counter2 Overflow
	jmp unused		; Timer/Counter1 Capture Event
	jmp IsrPwmStart		; Timer/Counter1 Compare Match A
	jmp IsrPwmEnd		; Timer/Counter1 Compare Match B
	jmp unused		; Timer/Counter1 Overflow
	jmp unused		; Timer/Counter0 Compare Match A
	jmp unused		; Timer/Counter0 Compare Match B
	jmp IsrLed		; Timer/Counter0 Overflow
	jmp unused		; SPI Serial Transfer Complete
	jmp unused		; USART0, Rx Complete
	jmp unused		; USART0 Data register Empty
	jmp unused		; USART0, Tx Complete
	jmp unused		; Analog Comparator
	jmp unused		; ADC Conversion Complete
	jmp unused		; EEPROM Ready
	jmp unused		; 2-wire Serial Interface
	jmp unused		; Store Program Memory Read
	jmp unused		; USART1 RX complete
	jmp unused		; USART1 Data Register Empty
	jmp unused		; USART1 TX complete

unused:	reti


	;--- Hardware init ---

reset:

	ldi t,low(ramend)	;initalize stack pointer
	out spl,t
	ldi t,high(ramend)
	out sph,t

	ldx 100
	call WaitXms

	call SetupHardware


	;--- Initialize LCD ---

	call LoadLcdContrast
	call LcdUpdate
	call LcdClear
	call LcdUpdate


	;--- Variables init ---

	ldz eeUserProfile		;user profile
	call ReadEeprom
	andi t, 0x03
	sts UserProfile, t

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

	sts QTuningIndex, t

	sts flagPwmGen, t

	sts FlashingLEDCounter, t

	ldi xl, AuxCounterInit
	sts AuxCounter, xl
	ldi xl, 2
	sts AuxSwitchPosition, xl
	ldi xl, 1
	sts Aux4SwitchPosition, xl
	sts AuxFunctionOld, xl

	sts flagAlarmOverride, t

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

	sts RudderRxPinState, t
	sts AuxRxPinState, t

	ldi xl, StdRxTimeoutLimit	;start with all RX channels timed out
	sts RollDcnt, xl
	sts PitchDcnt, xl
	sts ThrottleDcnt, xl
	sts YawDcnt, xl
	sts AuxDcnt, xl
	sts Aux2Dcnt, xl
	sts Aux3Dcnt, xl
	sts Aux4Dcnt, xl

	ldi xl, NoAileronInput | NoElevatorInput | NoThrottleInput | NoRudderInput
	sts StatusBits, xl

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
	andi t, 0x0F			;any button pressed?
	breq ma2

	call EscThrottleCalibration	;yes, do calibration
	rjmp ma2


	;--- Misc. ---

ma5:	rvsetflagtrue Mode		;will prevent buttons held down during start-up from opening the menu or changing user profile


	;--- Reset LCD contrast when button #1 is held down ---

	call GetButtons
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
	call GetRxChannels
	call Arming
	call Logic
	call Imu
	call HeightDampening
	call Mixer
	call GimbalStab
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

	rvsetflagfalse Mode		;no, reset Mode and ButtonDelay, and then go to start of the loop

ma8:	lrv ButtonDelay, 0
	rjmp ma1	

ma4:	rvinc ButtonDelay		;yes, ButtonDelay++
	rvcpi ButtonDelay, 50		;ButtonDelay == 50?
	breq ma6			;yes, re-check button
	rjmp ma1			;no, go to start of the loop	

ma6:	rvbrflagtrue Mode, ma8		;abort if the button hasn't been released since start-up

;	         76543210		;disable OCR1A and B interrupt
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


.include "quicktuning.asm"
.include "gimbal.asm"
.include "userprofile.asm"
.include "trigonometry.asm"
.include "channelmapping.asm"
.include "setuphw.asm"
.include "version.asm"
.include "beeper.asm"
.include "menu.asm"
.include "lva.asm"
.include "logic.asm"
.include "contrast.asm"
.include "auxsettings.asm"
.include "heightdamp.asm"
.include "loader.asm"
.include "selflevel.asm"
.include "layout.asm"
.include "throttlecal.asm"
.include "eeinit.asm"
.include "sensorcal.asm"
.include "settingsc.asm"
.include "settingsb.asm"
.include "settingsa.asm"
.include "flightdisplay.asm"
.include "arm.asm"
.include "flightinit.asm"
.include "pieditor.asm"
.include "numedit.asm"
.include "mixedit.asm"
.include "mixer2.asm"
.include "imu.asm"
.include "pwmgen.asm"
.include "rxtest.asm"
.include "readrx.asm"
.include "mainmenu.asm"
.include "sensortest.asm"
.include "sensorreading.asm"
.include "ST7565.asm"
.include "miscsubs.asm"
.include "168mathlib_subs.asm"
.include "824mathlib_subs.asm"
font6x8:
.include "font6x8.asm"
font8x12:
;.include "font8x12.asm"
font12x16:
.include "font12x16.asm"
symbols16x16:
.include "symbols16x16.asm"
font4x6:
.include "font4x6.asm"




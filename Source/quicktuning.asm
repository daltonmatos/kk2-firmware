
	;--- Quick tuning ---

QuickTuning:

	call FlightInit				;initialize variables that might have been modified without returning to the SAFE screen
	call StopLedSeq				;the KK2 LED cannot be used to indicate selected user profile here
	call StopPwmQuiet			;stop PWM timer (if running). PWM output will instead be generated by the flight loop below

	clr t					;reset flight mode
	sts flagSlStickMixing, t
	sts flagAlarmOn, t

qt10:	lds t, QTuningIndex			;set SL or acro mode according to the selected parameter
	cpi t, 6
	brlt qt16

	ser t					;SL
	rjmp qt17

qt16:	clr t					;acro

qt17:	sts flagSlOn, t

	;header
	call LcdClear12x16
	rvbrflagfalse flagArmed, qt11

	lrv X1, 34				;armed
	lrv Y1, 22
	ldz armed*2
	call PrintString
	rjmp qt12

qt11:	lrv X1, 28				;tuning (safe)
	ldz tuning*2
	call PrintHeader

	;parameter
	lrv X1, 0				;aileron and elevator linked?
	lds t, QTuningIndex
	cpi t, 4
	brge qt14

	lds xl, flagRollPitchLink
	tst xl
	breq qt14

	andi t, 0x01				;yes, print "Ail+Ele"
	sts QTuningIndex, t
	ldz ailele*2
	call PrintString
	rjmp qt15

qt14:	ldz tune1*2				;first part of the parameter label (e.g. "Aileron")
	call PrintFromStringArray

qt15:	ldi t, ' '				;second part of the parameter label (e.g. "P gain")
	call PrintChar
	lds t, QTuningIndex
	ldz tune2*2
	call PrintFromStringArray
	call PrintColonAndSpace

	lds yl, QTuningIndex			;fetch parameter value from EEPROM
	rcall LoadEeTuningAddress
	call GetEePVariable16
 	call Print16Signed

	;status
	lrv X1, 0
	lrv Y1, 30
	ldz ready*2				;default string is "Ready for take-off!"
	call LoadStatusString
	call PrintString

	lds t, StatusBits			;make the status text flash if status isn't OK or throttle level is above idle
	cbr t, LvaWarning			;ignore the LVA warning bit
	lds xl, flagThrottleZero
	com xl					;the throttle zero flag must be inverted
	or t, xl
	breq qt13

	lds t, StatusCounter			;flashing status text banner
	inc t
	sts StatusCounter, t
	andi t, 0x01
	breq qt13

	ldz qt7*2				;highlight the status text
	call PrintSelector

qt13:	;flight mode
	lrv X1, 0
	lrv Y1, 39
	ldz flmode*2
	call PrintString
	call PrintFlightMode

	;footer
	call PrintStdFooter

qt12:	call LcdUpdate

qt50:	;flight loop
	call PwmStart				;runtime between PwmStart and B interrupt (in PwmEnd) must not exeed 1.5ms
	call GetRxChannels
	call Arming
	rcall QtLogic
	call Imu
	call Mixer
	call GimbalStab
	call Beeper
	call Lva
	call PwmEnd

	rvflageor flagA, flagArmed, flagArmedOldState	;flagA == true if flagArmed changes state
	rvbrflagfalse flagA, qt52

	call CheckLvaSetting

	lds t, flagArmed
	sts flagArmedOldState, t

qt52:	rvbrflagfalse flagLcdUpdate, qt53	;update LCD once if flagLcdUpdate is true

	rvsetflagfalse flagLcdUpdate
	rjmp qt10

qt53:	rvbrflagfalse flagArmed, qt54		;skip buttonreading if armed
	rjmp qt50

qt54:	load t, pinb				;read buttons
	com t
	swap t
	andi t, 0x0F				;button pressed?
	brne qt55
	
	lrv ButtonDelay, 0			;no, reset ButtonDelay, and go to start of the loop
	rjmp qt50	

qt55:	rvinc ButtonDelay			;yes, ButtonDelay++
	rvcpi ButtonDelay, 50			;ButtonDelay == 50?
	breq qt56				;yes, re-check button

qt51:	rjmp qt50				;no, go to start of the loop	

qt56:	call GetButtons
	cpi t, 0x08				;BACK?
	brne qt57

;	         76543210			;disable OCR1A and B interrupt
	ldi t, 0b00000000
	store timsk1, t

	call StartLedSeq
	call StartPwmQuiet
	ret

qt57:	cpi t, 0x04				;PREV?
	brne qt58

	lds xl, QTuningIndex
	dec xl
	brpl qt62

	ldi xl, 10
	rjmp qt62

qt58:	cpi t, 0x02				;NEXT?
	brne qt59

	lds xl, QTuningIndex
	inc xl
	cpi xl, 11
	brlt qt61

	clr xl
	rjmp qt62

qt61:	rvbrflagfalse flagRollPitchLink, qt62

	cpi xl, 2
	brne qt62

	ldi xl, 4

qt62:	sts QTuningIndex, xl
	rjmp qt10

qt59:	cpi t, 0x01				;CHANGE?
	brne qt51

;	         76543210			;yes, disable OCR1A and B interrupt
	ldi t, 0b00000000
	store timsk1, t

	call StartLedSeq
	call StartPwmQuiet

	lds yl, QTuningIndex
	rcall LoadEeTuningAddress
	pushz
	call GetEePVariable16
	ldzarray tune4*2, 4, yl
	lpm yl, Z+
	lpm yh, Z+
	lpm r0, Z+
	lpm r1, Z+
	mov zl, r0
	mov zh, r1
	call NumberEdit
	mov xl, r0
	mov xh, r1
	popz
	call StoreEePVariable16

	call FlightInit				;initialize variables

	call StopLedSeq
	call StopPwmQuiet
	rjmp qt10



tuning:	.db 72, 73, 67, 64, 67, 63, 0, 0	;the text "TUNING" in the mangled 12x16 font

ready:	.db "Ready for take-off!", 0

qt7:	.db 0, 29, 127, 38

roll:	.db "Roll", 0, 0
pitch:	.db "Pitch", 0

tune1:	.dw ail*2, ail*2, ele*2, ele*2, rudd*2, rudd*2, selflvl*2, sltrim*2, sltrim*2, gimbal*2, gimbal*2
tune2:	.dw pgain*2, igain*2, pgain*2, igain*2, pgain*2, igain*2, pgain*2, roll*2, pitch*2, roll*2, pitch*2
tune3:	.dw 0x0044, 0x0048, 0x004C, 0x0050, 0x0054, 0x0058, eeSelflevelPgain, eeAccTrimRoll, eeAccTrimPitch, eeCamRollGain, eeCamPitchGain

tune4:	.dw 0, 900				;aileron P-gain
	.dw 0, 900				;aileron I-gain
	.dw 0, 900				;elevator P-gain
	.dw 0, 900				;elevator I-gain
	.dw 0, 900				;rudder P-gain
	.dw 0, 900				;rudder I-gain
	.dw 0, 900				;SL P-gain
	.dw -900, 900				;ACC trim roll
	.dw -900, 900				;ACC trim pitch
	.dw -9000, 9000				;gimbal roll gain
	.dw -9000, 9000				;gimbal pitch gain



	;--- Load EEPROM variable's address ---

LoadEeTuningAddress:

	ldzarray tune3, 1, yl
	lsl zl
	rol zh
	lpm xl, z+
	lpm xh, z
	movw z, x
	ret




	;--- Logic functions to be used during Quick Tuning ---
QtLogic:

	rvbrflagtrue flagArmed, qtl1		;skip Live Update if armed	

	b16dec LiveUpdateTimer			;set flagLcdUpdate every second
	brlt qtl2

	rjmp qts10

qtl2:	rvsetflagtrue flagLcdUpdate
	b16ldi LiveUpdateTimer, 400
	rjmp qts10

qtl1:
	;--- Flashing LED if status bits are set while armed ---

	lds t, StatusBits
	tst t
	breq qts10

	lds t, FlashingLEDCounter
	tst t
	breq qts1
	brmi qts6
	rjmp qts3

qts1:	ldi t, 40
	LedOn

	lds zl, FlashingLEDCount		;update counter every time the LED is turned on
	dec zl
	sts FlashingLEDCount, zl
	brne qts5

	lds zl, StatusBits			;clear the LVA Warning bit to end flashing
	cbr zl, LvaWarning
	sts StatusBits, zl
	rjmp qts5

qts3:	dec t
	breq qts4

	rjmp qts5

qts4:	ldi t, -60
	LedOff
	rjmp qts5

qts6:	inc t
	breq qts1

qts5:	sts FlashingLEDCounter, t

qts10:

	;--- LED flashing in sync with the LVA beeps ---

	rvbrflagtrue flagLvaBuzzerOn, qtf2


	;--- Turn on LED if armed ---

	rvbrflagtrue flagArmed, qtf1

qtf2:	LedOff
	ret

qtf1:	lds t, StatusBits			;allow the LED to flash when status bits are set
	tst t
	brne qtf3

	LedOn

qtf3:	ret


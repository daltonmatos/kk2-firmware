
	;--- Quick tuning ---

QuickTuning:

	b16clr Tuned7

	call FlightInit				;initialize variables that might have been modified without returning to the SAFE screen
	call LoadTuningRate			;load tuning rate from EEPROM
	call StopLedSeq				;the KK2 LED cannot be used to indicate selected user profile here
	call StopPwmQuiet			;stop PWM timer (if running). PWM output will instead be generated by the flight loop below

	ser t					;make sure the camera gimbal is centered while tuning
	sts TuningMode, t

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
 	call PrintNumberLF

	;status
	lrv X1, 0
	ldz null*2				;default string is blank
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

qt13:	;remote tuning (offset)
	lrv X1, 0
	lrv Y1, 35
	ldz remtun*2
	call PrintString
	b16load Tuned7				;Tuned7 = RxAux2 * TuningRateValue / 10
	call PrintNumberLF

	;flight mode
	lrv X1, 0
	ldz flimode*2
	call PrintFlightMode

	;footer
	lrv X1, 0
	lrv Y1, 57
	ldz qtunefn*2
	call PrintString

qt12:	call LcdUpdate

qt50:	;flight loop
	call PwmStart				;runtime between PwmStart and B interrupt (in PwmEnd) must not exeed 1.5ms
	call GetRxChannels
	call Arming
	call QtLogic
	call RemoteQuickTuning
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

;	         76543210			;yes, disable OCR1A and B interrupt
	ldi t, 0b00000000
	store timsk1, t

	sts TuningMode, t			;allow camera gimbal to be controlled remotely again

	call StartLedSeq
	call StartPwmQuiet
	ret

qt57:	cpi t, 0x04				;RATE?
	brne qt58

;	         76543210			;yes, disable OCR1A and B interrupt
	ldi t, 0b00000000
	store timsk1, t

	call StartLedSeq
	call StartPwmQuiet

	call SetInputRate

	call StopLedSeq
	call StopPwmQuiet
	rjmp qt10

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

	b16load Tuned6				;Tuned6 = current EE value + remote offset
	lds yl, QTuningIndex
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
	pushx
	lds yl, QTuningIndex
	rcall LoadEeTuningAddress
	popx
	call StoreEePVariable16

	call FlightInit				;initialize variables

	call StopLedSeq
	call StopPwmQuiet
	rjmp qt10



tuning:	.db "TUNING", 0, 0
remtun:	.db "Remote Input: ", 0, 0
flimode:.db "Flight Mode : ", 0, 0

qt7:	.db 0, 25, 127, 34

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



	;--- Remote quick tuning ---

RemoteQuickTuning:

	b16ldi Temp, 0.1			;scale Aux2 input down to [-100, 100]
	b16mul RxAux2, RxAux2, Temp

	b16mul RxAux2, RxAux2, TuningRateValue	;scale Aux2 according to selected tuning rate
	b16mov Tuned7, RxAux2

	lds t, QTuningIndex
	tst t
	brne rqt1

	b16mov Temp, PGainRollOrg		;aileron P-gain
	rcall AddQtRxOffset
	b16mov PGainRoll, Temp
	rvbrflagtrue flagRollPitchLink, rqt55	;aileron and elevator settings linked?

	ret

rqt1:	cpi t, 1
	brne rqt2

	b16mov Temp, IGainRollOrg		;aileron I-gain
	rcall AddQtRxOffset
	call TempDiv16				;Temp = Temp / 16
	b16mov IGainRoll, Temp
	rvbrflagtrue flagRollPitchLink, rqt56	;aileron and elevator settings linked?

	ret

rqt2:	cpi t, 2
	brne rqt3

	b16mov Temp, PGainPitchOrg		;elevator P-gain
	rcall AddQtRxOffset

rqt55:	b16mov PGainPitch, Temp
	ret

rqt3:	cpi t, 3
	brne rqt4

	b16mov Temp, IGainPitchOrg		;elevator I-gain
	rcall AddQtRxOffset
	call TempDiv16				;Temp = Temp / 16

rqt56:	b16mov IGainPitch, Temp
	ret

rqt4:	cpi t, 4
	brne rqt5

	b16mov Temp, PGainYawOrg		;rudder P-gain
	rcall AddQtRxOffset
	b16mov PGainYaw, Temp
	ret

rqt5:	cpi t, 5
	brne rqt6

	b16mov Temp, IGainYawOrg		;rudder I-gain
	rcall AddQtRxOffset
	call TempDiv16				;Temp = Temp / 16
	b16mov IGainYaw, Temp
	ret

rqt6:	cpi t, 6
	brne rqt7

	b16mov Temp, SelflevelPgainOrg		;SL P-gain
	rcall AddQtRxOffset
	b16mov SelflevelPgain, Temp
	ret

rqt7:	cpi t, 7
	brne rqt8

	b16add Tuned6, AccTrimRollOrg, RxAux2	;ACC trim roll (can be negative)
	b16mov AccTrimRoll, Tuned6
	b16fdiv AccTrimRoll, 2
	ret

rqt8:	cpi t, 8
	brne rqt9

	b16add Tuned6, AccTrimPitchOrg, RxAux2	;ACC trim pitch (can be negative)
	b16mov AccTrimPitch, Tuned6
	b16fdiv AccTrimPitch, 2
	ret

rqt9:	cpi t, 9
	brne rqt10

	b16add Tuned6, CamRollGainOrg, RxAux2	;gimbal roll gain (can be negative)
	b16mov CamRollGain, Tuned6
	b16fdiv CamRollGain, 4
	ret

rqt10:	b16add Tuned6, CamPitchGainOrg, RxAux2	;gimbal pitch gain (can be negative)
	b16mov CamPitchGain, Tuned6
	b16fdiv CamPitchGain, 4
	ret



	;--- Add RX offset for quick tuning ---

AddQtRxOffset:

	b16add Tuned6, Temp, RxAux2
	brge qro2

	b16clr Tuned6				;cannot use negative values

qro2:	b16mov Temp, Tuned6
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


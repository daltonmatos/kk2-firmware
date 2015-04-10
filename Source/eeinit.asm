
.def	Counter = r17

EeInit:

	ldz 0				;check EE signature
	call GetEeVariable8
	cpi xl, 0x19
	brne eei1

	call GetEeVariable8
	cpi xl, 0x03
	brne eei1

	call GetEeVariable8
	cpi xl, 0x73
	brne eei1

	call GetEeVariable8
	cpi xl, 0xC2
	brne eei1

	ldz eeUserAccepted		;show the disclaimer unless it has already been accepted
	call ReadEeprom
	brflagtrue t, eei2

	rcall ShowDisclaimer

eei2:	ret

eei1:					;initalize

	ldz eeMixerTable		;Mixertable
	ldx 0
	ldi Counter, 64
eei3:	call StoreEeVariable8
	dec Counter
	brne eei3

	ldx eeParameterTable		;ParameterTable
	ldy eei4*2
	ldi Counter, 24
eei5:	movw z, y
	lpm t, z
	movw z, x
	call WriteEeprom
	adiw x, 1
	adiw y, 1
	dec Counter
	brne eei5

	ldx eeStickScaleRoll		;Stick Scaling
	ldy eei7*2
	ldi Counter, 10
eei8:	movw z, y
	lpm t, z
	movw z, x
	call WriteEeprom
	adiw x, 1
	adiw y, 1
	dec Counter
	brne eei8


	ldx 60
	ldz eeSelflevelPgain
	call StoreEeVariable16
	ldx 20
	call StoreEeVariable16		;eeSelflevelPlimit
	ldx 0
	call StoreEeVariable16		;eeAccTrimRoll
	call StoreEeVariable16		;eeAccTrimPitch
	ldx 10
	call StoreEeVariable16		;eeSlMixRate


	call StoreEeVariable16		;eeEscLowLimit (set to 10)
	ldx 0
	call StoreEeVariable16		;eeHeightDampeningGain
	ldx 30
	call StoreEeVariable16		;eeHeightDampeningLimit
	ldx 0
	call StoreEeVariable16		;eeBattAlarmVoltage
	ldx 50
	call StoreEeVariable16		;eeServoFilter


	ser xl
	call StoreEeVariable8		;eeLinkRollPitch (set to YES)
	call StoreEeVariable8		;eeAutoDisarm
	call StoreEeVariable8		;eeButtonBeep
	call StoreEeVariable8		;eeArmingBeeps
	ldx 0
	call StoreEeVariable8		;eeQuietESCs (set to NO)


	call StoreEeVariable16		;eeCamRollGain (set to zero)
	call StoreEeVariable16		;eeCamPitchGain
	call StoreEeVariable8		;eeCamServoMixing (set to NONE)
	call StoreEeVariable16		;eeCamRollLockPos
	call StoreEeVariable16		;eeCamPitchLockPos


	setflagfalse xl
	call StoreEeVariable8		;eeSensorsCalibrated
	call StoreEeVariable8		;eeMotorLayoutOk
	call StoreEeVariable8		;eeUserAccepted


	call DisableEscCalibration

	rcall SetDefaultLcdContrast

	ldi xl, 2			;tuning rate (set to MEDIUM)
	ldz eeTuningRate
	call StoreEeVariable8

	ldz 0				;EE signature
	ldi xl, 0x19
	call StoreEeVariable8
	ldi xl, 0x03
	call StoreEeVariable8
	ldi xl, 0x73
	call StoreEeVariable8
	ldi xl, 0xC2
	call StoreEeVariable8

	ldi Counter, 5
eei6:	call Beep
	ldi yl, 0
	call wms
	dec Counter
	brne eei6



	;--- Disclaimer ---

ShowDisclaimer:

	call LcdClear12x16

	lrv X1, 16			;reminder
	ldz eew1*2
	call PrintString

	lrv FontSelector, f6x8

	lrv X1, 0			;print disclaimer text
	lrv Y1, 17
	clr t

eew12:	push t
	ldz eew10*2
	call PrintFromStringArray
	lrv X1, 0
	rvadd Y1, 9
	pop t
	inc t
	cpi t, 4
	brne eew12

	;footer
	call PrintOkFooter

	call LcdUpdate

eew11:	call GetButtonsBlocking
	cpi t, 0x01			;OK?
	brne eew11

	ser t				;set flag to indicate that the user has accepted the disclaimer
	ldz eeUserAccepted
	call WriteEeprom

	call ReleaseButtons		;make sure buttons are released
	ret




eei4:	.dw 50, 100, 25, 20		;default PI gains and limits for aileron, elevator and rudder
	.dw 50, 100, 25, 20
	.dw 50, 20, 50, 10


eei7:	.dw 30, 30, 50, 90, 100		;default stick scaling values


eew1:	.db 69, 61, 66, 64, 67, 60, 61, 69, 0, 0;the text "REMINDER" in the mangled 12x16 font

eew2:	.db "YOU USE THIS FIRMWARE", 0
eew3:	.db "AT YOUR OWN RISK!", 0
eew4:	.db "Read the instructions", 0
eew5:	.db "carefully.", 0, 0

eew10:	.dw eew2*2, eew3*2, eew4*2, eew5*2


.undef Counter


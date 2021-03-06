
.def	Counter = r17



	;--- Initialize EEPROM if the signature is bad ---

EeInit:

	ldz 0				;check EEPROM signature for user profile #1
	rcall CheckEeSignature
	sts Init, xl
	tst xl
	breq eei1

	clr t				;initialize user profile #1
	sts UserProfile, t
	rcall InitUserProfile

	clr t				;not accepted yet
	ldz eeUserAccepted
	call WriteEeprom

	call DisableEscCalibration	;initialize variables that are used in profile #1 only
	call ResetBatteryVoltageOffset
	call ResetErrorLogging

	call setup_mpu6050
	rcall ShowDisclaimer
	call InitialSetup		;display initial setup menu
	rjmp eei3

eei1:	ldz eeUserAccepted		;show the disclaimer if not yet accepted
	call ReadEeprom
	brflagtrue t, eei2

	rcall ShowDisclaimer

eei2:	lds zh, UserProfile		;check EEPROM signature for the current user profile (skipped for profile #1)
	tst zh
	breq eei3

	clr zl
	rcall CheckEeSignature
	tst xl
	breq eei3

	rcall InitUserProfile		;initialize current user profile

eei3:	ldz eeButtonsReversed		;normal or reversed buttons
	call ReadEeprom
	sts BtnReversed, t
	ret



	;--- Check EEPROM signature (register ZH decides which user profile to check) ---

CheckEeSignature:

	call GetEeVariable8
	cpi xl, 0x21
	brne ces1

	call GetEeVariable8
	cpi xl, 0x05
	brne ces1

	call GetEeVariable8
	cpi xl, 0xAA
	brne ces1

	call GetEeVariable8
	cpi xl, 0x04
	brne ces1

	clr xl				;signature is OK
	ret

ces1:	ser xl				;bad signature
	ret



	;--- Initialize the current user profile ---

InitUserProfile:

	ldz EeMixerTable		;mixer table
	ldx 0
	ldi Counter, 64
iup3:	call StoreEePVariable8
	dec Counter
	brne iup3

	ldz EeSensorCalData		;sensor calibration data
	ldi Counter, 18
iup4:	call StoreEePVariable8
	dec Counter
	brne iup4

	ldx EeParameterTable		;parameter table
	ldy eei4*2
	ldi Counter, 24
iup5:	movw z, y
	lpm t, z
	movw z, x
	call WriteEepromP
	adiw x, 1
	adiw y, 1
	dec Counter
	brne iup5

	ldx eeStickScaleRoll		;stick scaling
	ldy eei7*2
	ldi Counter, 10
iup8:	movw z, y
	lpm t, z
	movw z, x
	call WriteEepromP
	adiw x, 1
	adiw y, 1
	dec Counter
	brne iup8


	ldx 60
	ldz eeSelflevelPgain
	call StoreEePVariable16		;eeSelflevelPgain
	ldx 20
	call StoreEePVariable16		;eeSelflevelPlimit
	ldx 0
	call StoreEePVariable16		;eeAccTrimRoll
	call StoreEePVariable16		;eeAccTrimPitch
	ldx 10
	call StoreEePVariable16		;eeSlMixRate


	call StoreEePVariable16		;eeEscLowLimit (set to 10)
	ldx 0
	call StoreEePVariable16		;eeStickDeadZone
	call StoreEePVariable16		;eeBattAlarmVoltage
	ldx 50
	call StoreEePVariable16		;eeServoFilter
	ldx 0
	call StoreEePVariable16		;UNUSED ****************************


	ldi xl, 1 
	call StoreEePVariable8		;eeChannelRoll
	ldi xl, 2
	call StoreEePVariable8		;eeChannelPitch
	ldi xl, 3
	call StoreEePVariable8		;eeChannelThrottle
	ldi xl, 4
	call StoreEePVariable8		;eeChannelYaw
	ldi xl, 5
	call StoreEePVariable8		;eeChannelAux
	ldi xl, 6
	call StoreEePVariable8		;eeChannelAux2
	ldi xl, 7
	call StoreEePVariable8		;eeChannelAux3
	ldi xl, 8
	call StoreEePVariable8		;eeChannelAux4


	ldi xl, 2
	call StoreEePVariable8		;eeSatChannelRoll
	ldi xl, 3
	call StoreEePVariable8		;eeSatChannelPitch
	ldi xl, 1 
	call StoreEePVariable8		;eeSatChannelThrottle
	ldi xl, 4
	call StoreEePVariable8		;eeSatChannelYaw
	ldi xl, 5
	call StoreEePVariable8		;eeSatChannelAux
	ldi xl, 6
	call StoreEePVariable8		;eeSatChannelAux2
	ldi xl, 7
	call StoreEePVariable8		;eeSatChannelAux3
	ldi xl, 8
	call StoreEePVariable8		;eeSatChannelAux4


	ser xl
	call StoreEePVariable8		;eeLinkRollPitch (set to YES)
	call StoreEePVariable8		;eeAutoDisarm (set to YES)
	call StoreEePVariable8		;eeButtonBeep (set to YES)
	call StoreEePVariable8		;eeArmingBeeps (set to YES)
	call StoreEePVariable8		;eeUnused2


	ldx 0
	call StoreEePVariable16		;eeCamRollGain
	call StoreEePVariable16		;eeCamRollOffset
	call StoreEePVariable16		;eeCamPitchGain
	call StoreEePVariable16		;eeCamPitchOffset
	call StoreEePVariable8		;eeCamServoMixing (set to NONE)
	call StoreEePVariable16		;eeCamRollLockPos
	call StoreEePVariable16		;eeCamPitchLockPos


	setflagfalse xl
	call StoreEePVariable8		;eeSensorsCalibrated
	call StoreEePVariable8		;eeMotorLayoutOk


	clr xl
	call StoreEePVariable8		;eeAuxPos1SS
	call StoreEePVariable8		;eeAuxPos2SS
	call StoreEePVariable8		;eeAuxPos3SS
	call StoreEePVariable8		;eeAuxPos4SS
	call StoreEePVariable8		;eeAuxPos5SS
	call StoreEePVariable8		;eeAuxPos1Function (set to Acro)
	ldi xl, 3
	call StoreEePVariable8		;eeAuxPos2Function (set to Alarm)
	ldi xl, 1
	call StoreEePVariable8		;eeAuxPos3Function (set to SL Mix)
	ldi xl, 3
	call StoreEePVariable8		;eeAuxPos4Function (set to Alarm)
	ldi xl, 2
	call StoreEePVariable8		;eeAuxPos5Function (set to Normal SL)


	clr xl
	call StoreEePVariable8		;eeMpuFilter (set to 256 Hz)
	ldi xl, 0x08
	call StoreEePVariable8		;eeMpuGyroCfg (set to 500 deg/s)
	call StoreEePVariable8		;eeMpuAccCfg (set to 4 g)


	clr xl
	call StoreEePVariable8		;eeTuningRate (set to INVALID here, but it will still be read as 2, MEDIUM)
	call StoreEePVariable8		;eeDG2Functions


	ldz 0				;EEPROM signature
	ldi xl, 0x21
	call StoreEePVariable8
	ldi xl, 0x05
	call StoreEePVariable8
	ldi xl, 0xAA
	call StoreEePVariable8
	ldi xl, 0x04
	call StoreEePVariable8


	;--- User profile #1 ---

	lds t, UserProfile		;skip this section for user profile 2 - 4
	tst t
	brne iup7

	ldz eeUserProfile		;set user profile #1 to be used as default
	call WriteEeprom

	clr t				;set board orientation back to normal (0 degrees)
	ldz eeBoardOrientation
	call WriteEeprom

	call SetDefaultLcdContrast
	call ResetGimbalControllerMode
	call ResetRxMode

	lds t, Init			;display initial setup menu and enforce restart when called from the User Profile menu
	tst t
	brne iup9

	rcall ShowDisclaimer
	call InitialSetup
	rjmp EnforceRestart

iup9:	clr t
	sts Init, t


iup7:	;--- Done ---

	ldi Counter, 5

iup6:	call Beep
	ldi yl, 0
	call wms
	dec Counter
	brne iup6

	ret



	;--- Disclaimer ---		Will also detect reversed buttons

ShowDisclaimer:

	call LcdClear12x16

	lrv X1, 16			;reminder
	ldz eew1*2
	call PrintHeader

	ldi t, 4			;print disclaimer text
	ldz eew10*2
	call PrintStringArray

	;footer
	call PrintOkFooter

	call LcdUpdate

	clr t				;reset button mode (normal button order)
	sts BtnReversed, t

eew11:	call GetButtonsBlocking
	cpi t, 0x01			;OK?
	brne eew12

	clr t				;normal button order
	rjmp eew14

eew12:	cpi t, 0x08			;OK (reversed buttons)?
	brne eew11

	ser t				;reversed

eew14:	sts BtnReversed, t
	ldz eeButtonsReversed
	call WriteEeprom

eew13:	ser t				;set flag to indicate that the user has accepted the disclaimer
	ldz eeUserAccepted
	call WriteEeprom

	call ReleaseButtons		;make sure buttons are released
	ret




eei4:	.dw 50, 100, 25, 20		;default PI gains and limits for aileron, elevator and rudder
	.dw 50, 100, 25, 20
	.dw 50, 20, 50, 10


eei7:	.dw 30, 30, 50, 90, 100		;default stick scaling values


eew1:	.db "REMINDER", 0, 0
eew2:	.db "YOU USE THIS FIRMWARE", 0
eew3:	.db "AT YOUR OWN RISK!", 0
eew4:	.db "Read all included", 0
eew5:	.db "documents carefully.", 0, 0

eew10:	.dw eew2*2, eew3*2, eew4*2, eew5*2


.undef Counter

	;--- Enforce restart ---

srm4:	.db "Restart is required!", 0, 0
EnforceRestart:

	call LcdClear6x8		;restart is required
	lrv Y1, 28
	ldz srm4*2
	call PrintString
	call LcdUpdate

enf1:	rjmp enf1			;infinite loop

	;--- Reset gimbal controller mode ---

ResetGimbalControllerMode:

	clr t
	ldz eeGimbalMode
	call WriteEeprom		;save in profile #1 only
	ret

	;--- Reset RX mode ---

ResetRxMode:

	ldi t, RxModeStandard		;set RX mode to 'Standard Receiver'
	sts RxMode, t
	ldz eeRxMode
	call WriteEeprom
	ret


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
	call ResetErrorLogging

	call setup_mpu6050
	rcall ShowDisclaimer
	rcall InitialSetup		;display initial setup menu
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
	cpi xl, 0x08
	brne ces2

	clr xl				;signature is OK
	ret

ces1:	ser xl				;bad signature
	ret

ces2:	cpi xl, 0x07			;upgrade from revision 7?
	brne ces1

	lds ka, UserProfile		;yes, temporarily set the user profile value (in case eeUserProfile is non-zero)
	sts UserProfile, zh

	clr xl				;initialize new EEPROM variables
	ldz eeWS2812Pattern
	call StoreEePVariable8		;eeWS2812Pattern
	call StoreEePVariable8		;eeWS2812Brightness

	ldi xl, 0x08			;update the 4th. signature byte
	ldz 3
	call StoreEePVariable8

	tst zh				;user profile #1?
	brne ces3

	call LcdClear12x16		;yes, show a dialogue with header "UPDATED" and the usual disclaimer text

	lrv X1, 22
	ldz eeu1*2
	call PrintHeader

	ldi t, 4
	ldz eew10*2
	call PrintStringArray

	call PrintOkFooter
	call LcdUpdate

	call GetButtonsBlocking		;any button can be pressed to continue to the "Restart is required" screen
	rjmp EnforceRestart

ces3:	sts UserProfile, ka		;user profile #2, 3 or 4. Restore the user profile value

	clr xl				;OK
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


	ldx 2				;battery voltage offset for KK2.1.5 = 2
	ldz eeBatteryVoltageOffset
	call StoreEePVariable16


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
	call StoreEePVariable16		;eeMotorSpinLevel
	call StoreEePVariable16		;eeUnused


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
	clr xl
	call StoreEePVariable8		;eeBigHomeScreen (set to NO)


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
	call StoreEePVariable8		;eeAuxPos1SS
	call StoreEePVariable8		;eeAuxPos2SS
	call StoreEePVariable8		;eeAuxPos3SS
	call StoreEePVariable8		;eeAuxPos4SS
	call StoreEePVariable8		;eeAuxPos5SS


	clr xl
	call StoreEePVariable8		;eeMpuFilter (set to 256 Hz)
	ldi xl, 0x08
	call StoreEePVariable8		;eeMpuGyroCfg (set to 500 deg/s)
	call StoreEePVariable8		;eeMpuAccCfg (set to 4 g)


	clr xl
	call StoreEePVariable8		;eeTuningRate (set to INVALID here, but it will still be read as 2, MEDIUM)
	call StoreEePVariable8		;eeDG2Functions


	ldi xl, 128
	call StoreEePVariable8		;eeTpa1P (set to 1.0)
	call StoreEePVariable8		;eeTpa1I (set to 1.0)
	call StoreEePVariable8		;eeTpa2P (set to 1.0)
	call StoreEePVariable8		;eeTpa2I (set to 1.0)
	call StoreEePVariable8		;eeTpa3P (set to 1.0)
	call StoreEePVariable8		;eeTpa3I (set to 1.0)
	call StoreEePVariable8		;eeTpa4P (set to 1.0)
	call StoreEePVariable8		;eeTpa4I (set to 1.0)
	call StoreEePVariable8		;eeTpa5P (set to 1.0)
	call StoreEePVariable8		;eeTpa5I (set to 1.0)


	call StoreEePVariable8		;eeTSSA1 (set to 1.0)
	call StoreEePVariable8		;eeTSSA2 (set to 1.0)
	call StoreEePVariable8		;eeTSSA3 (set to 1.0)
	call StoreEePVariable8		;eeTSSA4 (set to 1.0)
	call StoreEePVariable8		;eeTSSA5 (set to 1.0)


	ldi xl, 50
	call StoreEePVariable8		;eeServoFilter
	clr xl
	call StoreEePVariable8		;eeServoFilterDelay
	ldi xl, -100
	call StoreEePVariable8		;eeServoLimitM7L
	ldi xl, 100
	call StoreEePVariable8		;eeServoLimitM7H
	ldi xl, -100
	call StoreEePVariable8		;eeServoLimitM8L
	ldi xl, 100
	call StoreEePVariable8		;eeServoLimitM8H
	ldi xl, 5
	call StoreEePVariable8		;eeLowOutputRate (set to 80Hz)


	clr xl
	call StoreEePVariable8		;eeWS2812Pin (set to none/disabled for user profile #1)
	call StoreEePVariable8		;eeWS2812Pattern
	call StoreEePVariable8		;eeWS2812Brightness


	ldz 0				;EEPROM signature
	ldi xl, 0x21
	call StoreEePVariable8
	ldi xl, 0x05
	call StoreEePVariable8
	ldi xl, 0xAA
	call StoreEePVariable8
	ldi xl, 0x08
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
	rcall InitialSetup
	rjmp EnforceRestart

iup9:	clr t
	sts Init, t


	;--- Done ---

iup7:	ldi Counter, 5

iup6:	call Beep
	ldi yl, 0
	call wms
	dec Counter
	brne iup6

	ret



	;--- Disclaimer ---		Will also detect reversed buttons

ShowDisclaimer:

	call LcdClear12x16

	;header
	lrv X1, 16
	ldz remindr*2
	call PrintHeader

	;text
	ldi t, 4
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


eeu1:	.db "UPDATED", 0

eew2:	.db "YOU USE THIS FIRMWARE", 0
eew3:	.db "AT YOUR OWN RISK!", 0
eew4:	.db "Read all included", 0
eew5:	.db "documents carefully.", 0, 0

eew10:	.dw eew2*2, eew3*2, eew4*2, eew5*2


isp1:	.db "SETUP", 0
isp2:	.db "Load Motor Layout", 0
isp3:	.db "ACC Calibration", 0
isp4:	.db "Trim Battery Voltage", 0, 0
isp5:	.db "Select RX Mode", 0, 0



isp7:	.db 0, 16, 127, 25
	.db 0, 25, 127, 34
	.db 0, 34, 127, 43
	.db 0, 43, 127, 52

isp10:	.dw isp2*2, isp3*2, isp4*2, isp5*2



	;--- Initial setup menu ---

InitialSetup:

	clr Counter
	sts LoadMenuListYposSave, Counter
	sts LoadMenuCursorYposSave, Counter

isp11:	call LcdClear12x16

	;header
	lrv X1, 34
	ldz isp1*2
	call PrintHeader

	;disclaimer text
	ldi t, 4
	ldz isp10*2
	call PrintStringArray

	;footer
	call PrintMenuFooter

	;selector
	ldzarray isp7*2, 4, Counter
	call PrintSelector

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08			;BACK?
	brne isp15

	ret

isp15:	cpi t, 0x04			;PREV?
	brne isp20

	dec Counter

isp16:	andi Counter, 0x03
	rjmp isp11

isp20:	cpi t, 0x02			;NEXT?
	brne isp25

	inc Counter
	rjmp isp16

isp25:	cpi t, 0x01			;SELECT?
	brne isp11

	call ReleaseButtons
	push Counter
	cpi Counter, 0
	brne isp26

	call LoadMixer			;load motor layout
	rjmp isp40

isp26:	cpi Counter, 1
	brne isp27

	call CalibrateSensors		;ACC calibration
	rjmp isp40

isp27:	cpi Counter, 2
	brne isp28
	
	call AdjustBatteryVoltage	;adjust battery voltage
	rjmp isp40

isp28:	call SelectRxMode		;select RX mode

isp40:	pop Counter
	rjmp isp11


.undef Counter



	;--- Enforce restart ---

EnforceRestart:

	call LcdClear6x8		;restart is required
	lrv Y1, 28
	ldz srm4*2
	call PrintString
	call LcdUpdate

enf1:	rjmp enf1			;infinite loop


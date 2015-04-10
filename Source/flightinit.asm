
FlightInit:

	rcall LoadMixerTable			;copy Mixertable from EE to RAM

	ldz EeParameterTable			;copy and scale PI gain and limits from EE to 16.8 variables
	rcall fli2
	b16mov PgainRoll, Temp
	b16mov PgainRollOrg, Temp

	rcall fli2
	rcall fli5
	b16mov PlimitRoll, Temp

	rcall fli2
	b16mov IgainRollOrg, Temp
	rcall TempDiv16
	b16mov IgainRoll, Temp

	rcall fli2
	rcall fli5
	b16mov IlimitRoll, Temp

	rcall fli2
	b16mov PgainPitch, Temp
	b16mov PgainPitchOrg, Temp

	rcall fli2
	rcall fli5
	b16mov PlimitPitch, Temp

	rcall fli2
	b16mov IgainPitchOrg, Temp
	rcall TempDiv16
	b16mov IgainPitch, Temp

	rcall fli2
	rcall fli5
	b16mov IlimitPitch, Temp

	rcall fli2
	b16mov PgainYaw, Temp
	b16mov PgainYawOrg, Temp

	rcall fli2
	rcall fli5
	b16mov PlimitYaw, Temp

	rcall fli2
	b16mov IgainYawOrg, Temp
	rcall TempDiv16
	b16mov IgainYaw, Temp

	rcall fli2
	rcall fli5
	b16mov IlimitYaw, Temp


	rcall UpdateOutputTypeAndRate


	b16ldi Temp, 2500			;preload the servo filters
	lrv Index, 0
fli8:	b16store_array FilteredOut1, Temp
	rvinc Index
	rvcpi Index, 8
	brne fli8


	ldz eeSelflevelPgain
	rcall fli2
	b16mov SelflevelPgain, Temp
	b16mov SelfLevelPgainOrg, Temp

	rcall fli2				;eeSelflevelPlimit
	b16ldi Temper, 10
	b16mul SelflevelPlimit, Temp, Temper

	rcall fli2				;eeAccTrimRoll
	b16mov AccTrimRollOrg, Temp
	b16fdiv Temp, 3
	b16mov AccTrimRoll, Temp

	rcall fli2				;eeAccTrimPitch
	b16mov AccTrimPitchOrg, Temp
	b16fdiv Temp, 3
	b16mov AccTrimPitch, Temp

	rcall fli2				;eeSlMixRate
	rcall TempDiv100
	b16mov SelflevelPgainRate, Temp


	ldz eeEscLowLimit
	rcall fli2
	b16ldi Temper, 50.0
	b16mul EscLowLimit, Temp, Temper

	rcall fli2				;eeHeightDampeningGain
	b16mov HeightDampeningGain, Temp

	rcall fli2				;eeHeightDampeningLimit
	rcall fli5
	b16mov HeightDampeningLimit, Temp

	rcall fli2				;eeBattAlarmVoltage
	b16ldi Temper, 3.7236
	b16mul BattAlarmVoltage, Temp, Temper

	rcall fli2				;eeServoFilter
	b16ldi Temper, 100
	b16sub ServoFilter, Temper, Temp
	b16fdiv ServoFilter, 7


	ldz eeStickScaleRoll
	rcall fli2
	rcall TempDiv16
	b16mov StickScaleRoll, Temp

	rcall fli2				;eeStickScalePitch
	rcall TempDiv16
	b16mov StickScalePitch, Temp

	rcall fli2				;eeStickScaleYaw
	rcall TempDiv16
	b16mov StickScaleYaw, Temp

	rcall fli2				;eeStickScaleThrottle
	rcall TempDiv16
	b16mov StickScaleThrottle, Temp

	rcall fli2				;eeStickScaleSlMixing
	rcall TempDiv100
	b16mov MixFactor, Temp


	ldz eeCamRollGain
	rcall fli2
	b16mov CamRollGainOrg, Temp
	rcall TempDiv16
	b16mov CamRollGain, Temp

	rcall fli2				;eeCamPitchGain
	b16mov CamPitchGainOrg, Temp
	rcall TempDiv16
	b16mov CamPitchGain, Temp

	call GetEeVariable8			;eeCamServoMixing
	sts CamServoMixing, xl

	rcall fli2				;eeCamRollHomePos
	b16mov CamRollHomePos, Temp

	rcall fli2				;eeCamPitchHomePos
	b16mov CamPitchHomePos, Temp


	ldz EeSensorCalData			;load ACC calibration data
	call GetEeVariable168
	b16store AccXZero
	call GetEeVariable168
	b16store AccYZero
	call GetEeVariable168
	b16store AccZZero


	rcall ReadLinkRollPitchFlag
	call CheckTuningMode

	ldz eeAutoDisarm
	call ReadEeprom
	sts flagAutoDisarm, t


	ser t					;make sure the AUX switch function will be updated
	sts AuxSwitchPositionOld, t

	lrv OutputRateDividerCounter, 1
	lrv OutputRateDivider, 5		;slow rate divider. f = 400 / OutputRateDivider

	rvsetflagtrue flagLcdUpdate

	clr t
	sts flagMutePwm, t

	sts flagArmed, t
	sts flagArmedOldState, t

	sts flagSlOn, t

	sts flagAlarmOn, t
	sts flagAlarmOverride, t

	sts flagGeneralBuzzerOn, t
	sts flagLvaBuzzerOn, t
	sts flagDebugBuzzerOn, t

	sts flagGyrosCalibrated, t

	b16set AutoDisarmDelay

	b16set BeeperDelay

	b16set ArmedBeepDds

	b16set NoActivityTimer
	b16set NoActivityDds

	b16set LiveUpdateTimer

	b16set CamRoll
	b16set CamPitch

	b16set EulerAngleRoll
	b16set EulerAnglePitch

	rcall Initialize3dVector		;set 3d vector to point straigth up

	b16ldi BatteryVoltageLowpass, 1023

	lds t, StatusBits			;clear the lower status bits
	andi t, 0xF0
	sts StatusBits, t

	ldz eeMotorLayoutOk			;motor layout loaded?
	call ReadEeprom
	brflagtrue t, fli4

	setstatusbit NoMotorLayout		;no, will display an error and refuse arming

fli4:	ldz eeSensorsCalibrated			;sensors calibrated?
	call ReadEeprom
	brflagtrue t, fli11

	setstatusbit AccNotCalibrated		;no, will display an error and refuse arming
	ret					;skip the sanity check

fli11:	rcall SanityCheck
	ret



	;--- Set 3d vector to point straigth up ---

Initialize3dVector:

	b824clr VectorX
	b824clr VectorY
	b824ldi VectorZ, 1
	ret



	;--- Divide Temp by 16 ---

TempDiv16:

	b16fdiv Temp, 4
	ret



	;--- Divide Temp by 100 ---

TempDiv100:

	b16ldi Temper, 0.3203125		;0.3125 * 0.03203125 = 0.010009765 which is much closer to 0.01 than 0.0078125 (= b16ldi Temp, 0.01)
	b16mul Temp, Temp, Temper
	b16ldi Temper, 0.03125
	b16mul Temp, Temp, Temper
	ret



	;---

fli2:	call GetEeVariable16			;Temp = (Z+)
	clr yh
	b16store Temp
	ret

fli5:	b16ldi Temper, 128.0			;most limit values (0-100%) are scaled with 128.0 to fit to the 12800.0 full throttle value
	b16mul Temp, Temp, Temper
	ret

fli9:	b16ldi Temper, 50.0
	b16mul Temp, Temp, Temper
	ret



	;---

SanityCheck:

	call LcdClear6x8

	lrv X1, 0
	lrv Y1, 15

;	CheckLimit SelflevelPgain, 0, 501, san1
;	CheckLimit SelflevelPlimit, 0, 3411, san1			;30%

	CheckLimit EscLowLimit, 0, 1001, san1				;20%

	CheckLimit HeightDampeningGain, 0, 501 ,san1
	CheckLimit HeightDampeningLimit, 0, 3841 ,san1			;30%

	CheckLimit GyroRollZero, GyroLowLimit, GyroHighLimit, san2
	CheckLimit GyroPitchZero, GyroLowLimit, GyroHighLimit, san2
	CheckLimit GyroYawZero, GyroLowLimit, GyroHighLimit, san2

	CheckLimit AccXZero, AccLowLimit, AccHighLimit, san2
	CheckLimit AccYZero, AccLowLimit, AccHighLimit, san2
	CheckLimit AccZZero, AccLowLimit, AccHighLimit, san2

	call AdcRead
	call AdcRead

	CheckLimit GyroRoll, 100, 900, san3
	CheckLimit GyroPitch, 100, 900, san3
	CheckLimit GyroYaw, 100, 900, san3

	CheckLimit AccX, 100, 900, san3
	CheckLimit AccY, 100, 900, san3
	CheckLimit AccZ, 100, 900, san3

	ret 				;No errors, return


san1:	clr t				;print error message "One or more settings are out of limits."
	ldi yh, 9
	rcall PrintSanityMessage
	rjmp san4

san2:	ldi t, 2			;print error message "Sensor calibration data out of limits."
	ldi yh, 9
	rcall PrintSanityMessage
	rjmp san4

san3:	ldi t, 4			;print error message "Sensor raw data are out of limits."
	ldi yh, 9
	rcall PrintSanityMessage

san4:	setstatusbit SanityCheckFailed	;Error

	lrv X1, 40			;print "WARNING!" header and "Check your settings!!"
	lrv Y1, 1
	ldi t, 6
	ldi yh, 39
	rcall PrintSanityMessage

	call PrintContinueFooter

	call LcdUpdate

	BuzzerOn
	ldi yh, 39
san5:	ldi yl, 0
	call wms
	dec yh
	brne san5
	BuzzerOff

san6:	call GetButtonsBlocking
	cpi t, 0x01			;CONTINUE?
	brne san6

	call ReleaseButtons		;make sure all buttons are released
	ret



	;---

limit:

	cp  xl, yl			;less?
	cpc xh, yh
	brlt lim1
	cp  xl, zl			;greater?
	cpc xh, zh
	brge lim1
	clc				;OK
	ret

lim1:	sec				;not OK
	ret



	;--- Copy Mixertable from EEPROM to RAM ---

LoadMixerTable:

	ldi yl, 64
	ldx RamMixerTable
	ldz EeMixerTable

mt1:	call ReadEeprom
	st x+, t
	adiw z, 1
	dec yl
	brne mt1

	ret



	;--- Prepare the OutputRateBitmask and OutputTypeBitmask variables ---

UpdateOutputTypeAndRate:

	ldi yl, 8
	ldz RamMixerTable

otr1:	ldd t, z + MixvalueFlags

	clc
	sbrc t, bMixerFlagRate
	sec
	ror xl

	clc
	sbrc t, bMixerFlagType
	sec
	ror xh

	adiw z, 8
	dec yl
	brne otr1

	sts OutputRateBitmask, xl
	sts OutputTypeBitmask, xh
	ret



	;--- Read the LinkRollPitch flag from EEPROM ---

ReadLinkRollPitchFlag:

	ldz eeLinkRollPitch
	call ReadEeprom
	sts flagRollPitchLink, t
	ret



	;--- Print "Sanity" message (two lines) ---

PrintSanityMessage:

	ldi yl, 2			;loop counter

psm1:	push yl
	push t				;register T is the input parameter that decides which messages to print (valid range: 0 - 6)
	push yh				;register YH is the input parameter that decides the line offset increment
	ldz mad10*2
	call PrintFromStringArray
	lrv X1, 0
	lds t, Y1
	pop yh
	add t, yh
	sts Y1, t
	pop t
	inc t
	pop yl
	dec yl
	brne psm1

	ret



mad1:	.db "One or more settings", 0, 0
mad2:	.db "are out of limits.", 0, 0

mad3:	.db "Check your settings!!", 0

mad5:	.db "Sensor calibration", 0, 0
mad6:	.db "data out of limits.", 0

mad7:	.db "Sensor raw data", 0

mad8:	.db "WARNING!", 0, 0

mad10:	.dw mad1*2, mad2*2, mad5*2, mad6*2, mad7*2, mad2*2, mad8*2, mad3*2


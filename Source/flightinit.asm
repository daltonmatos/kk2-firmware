
FlightInit:

	rcall LoadMixerTable			;copy Mixertable from EE to RAM
	rcall LoadParameterTable		;copy and scale PI gain and limits from EE to 16.8 variables
	rcall UpdateOutputTypeAndRate


	b16ldi Temp, 2500			;preload the servo filters
	lrv Index, 0

fli8:	b16store_array FilteredOut1, Temp
	rvinc Index
	rvcpi Index, 8
	brne fli8


	no_offset_ldz eeBoardOrientation			;eeBoardOrientation
	call ReadEeprom
	sts BoardOrientation, t


	rcall LoadSelfLevelSettings


	rcall LoadEscLowLimit			;eeEscLowLimit
	rcall LoadStickDeadZone			;eeStickDeadZone

	rcall fli2				;eeBattAlarmVoltage
	b16fmul Temp, 2
	b16mov BattAlarmVoltage, Temp

	rcall fli2				;eeServoFilter
	b16ldi Temper, 100
	b16sub ServoFilter, Temper, Temp
	b16fdiv ServoFilter, 7


	no_offset_ldz eeStickScaleRoll
	rcall fli2
	rcall TempDiv16
	b16mov2 StickScaleRoll, StickScaleRollOrg, Temp

	rcall fli2				;eeStickScalePitch
	rcall TempDiv16
	b16mov2 StickScalePitch, StickScalePitchOrg, Temp

	rcall fli2				;eeStickScaleYaw
	rcall TempDiv16
	b16mov StickScaleYaw, Temp

	rcall fli2				;eeStickScaleThrottle
	rcall TempDiv16
	b16mov StickScaleThrottle, Temp

	rcall fli2				;eeStickScaleSlMixing
	rcall TempDiv100
	b16mov MixFactor, Temp


	ldy MappedChannel1
	rcall GetEeChannelMapping
	rcall LoadMappedChannel			;eeChannelRoll		or eeSatChannelRoll
	rcall LoadMappedChannel			;eeChannelPitch		or eeSatChannelPitch
	rcall LoadMappedChannel			;eeChannelThrottle	or eeSatChannelThrottle
	rcall LoadMappedChannel			;eeChannelYaw		or eeSatChannelYaw
	rcall LoadMappedChannel			;eeChannelAux		or eeSatChannelAux
	rcall LoadMappedChannel			;eeChannelAux2		or eeSatChannelAux2
	rcall LoadMappedChannel			;eeChannelAux3		or eeSatChannelAux3
	rcall LoadMappedChannel			;eeChannelAux4		or eeSatChannelAux4
	call CheckChannelMapping
	brcc fli3

	call ChannelMappingError		;invalid channel mapping must be resolved before we can continue
	call ChannelMapping


fli3:	rcall LoadGimbalSettings


	no_offset_ldz EeSensorCalData			;load ACC calibration data
	call GetEePVariable168
	b16store AccXZero
	call GetEePVariable168
	b16store AccYZero
	call GetEePVariable168
	b16store AccZZero


	rcall ReadLinkRollPitchFlag
	call CheckTuningMode
	call LoadAuxSwitchSetup
	call LoadBatteryVoltageOffset
	call LoadDG2Settings

	no_offset_ldz eeAutoDisarm
	call ReadEepromP
	sts flagAutoDisarm, t


	ser t					;make sure the AUX switch function will be updated
	sts AuxSwitchPositionOld, t

	sts flagLcdUpdate, t

	lrv OutputRateDividerCounter, 1
	lrv OutputRateDivider, 5		;slow rate divider. f = 400 / OutputRateDivider

	lrv RxTimeoutLimit, TimeoutLimit

	clr t
	sts flagMutePwm, t

	sts flagArmed, t
	sts flagArmedOldState, t

	sts ButtonDelay, t

	sts flagAlarmOverride, t
	sts flagGeneralBuzzerOn, t
	sts flagLvaBuzzerOn, t
	sts flagDebugBuzzerOn, t

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


	;--- ACC ---

	ldi yh, 8				;ACC SW Filter
	clr xl
	clr xh
	b16store AccSWFilter

	lds t, MpuAccCfg
	cpi t, MpuAcc2g
	brne fli22

	b16ldi AccZTest, 128			;2g
	b16ldi TiltAngMult, 0.33
	rjmp fli30

fli22:	cpi t, MpuAcc4g
	brne fli24

	b16ldi AccZTest, 64			;4g
	b16ldi TiltAngMult, 0.66
	rjmp fli30

fli24:	cpi t, MpuAcc8g
	brne fli26

	b16ldi AccZTest, 32			;8g
	b16ldi TiltAngMult, 1.32
	rjmp fli30

fli26:	b16ldi AccZTest, 16			;16g
	b16ldi TiltAngMult, 2.64


fli30:	;--- Gyro ---

	b832ldi MagicNumberMult, 1.830082440462336 ;1.830082440462336*(6250/4096)=2.7924841926 (all settings use this magic number as the GyroRate is scaled instead in imu.asm)


	;--- Status ---

	lds t, StatusBits			;clear the lower status bits
	andi t, 0xF0
	sts StatusBits, t

	no_offset_ldz eeMotorLayoutOk			;motor layout loaded?
	call ReadEeprom				;check user profile #1 only
	brflagtrue t, fli4

	setstatusbit NoMotorLayout		;no, will display an error and refuse arming

fli4:	no_offset_ldz eeSensorsCalibrated			;sensors calibrated?
	call ReadEepromP
	brflagtrue t, fli11

	setstatusbit AccNotCalibrated		;no, will display an error and refuse arming
	ret					;skip the sanity check

fli11:	rcall SanityCheck
	ret



	;--- Set 3d vector to point straigth up ---

Initialize3dVector:

	b832clr VectorX
	b832clr VectorY
	b832ldi VectorZ, 1
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

fli2:	call GetEePVariable16			;Temp = (Z+)
	clr yh
	b16store Temp
	ret

fli5:	b16ldi Temper, 128.0			;most limit values (0-100%) are scaled with 128.0 to fit to the 12800.0 full throttle value
	b16mul Temp, Temp, Temper
	ret



mad1:	.db "Data out of limits:", 0
mad5:	.db "Sensor calibration", 0, 0
mad7:	.db "Sensor raw data", 0



	;--- Sanity check ---

SanityCheck:

	call LcdClear6x8

	lrv X1, 0
	lrv Y1, 26

	call AdcRead

	CheckLimit GyroRoll, -400, 400, san3
	CheckLimit GyroPitch, -400, 400, san3
	CheckLimit GyroYaw, -400, 400, san3

	CheckLimit AccX, -400, 400, san3
	CheckLimit AccY, -400, 400, san3
	CheckLimit AccZ, -400, 400, san3

	CheckLimit GyroRollZero, GyroLowLimit, GyroHighLimit, san2
	CheckLimit GyroPitchZero, GyroLowLimit, GyroHighLimit, san2
	CheckLimit GyroYawZero, GyroLowLimit, GyroHighLimit, san2

	CheckLimit AccXZero, AccLowLimit, AccHighLimit, san2
	CheckLimit AccYZero, AccLowLimit, AccHighLimit, san2
	CheckLimit AccZZero, AccLowLimit, AccZHighLimit, san2

;	CheckLimit SelflevelPgain, 0, 501, san1
;	CheckLimit SelflevelPlimit, 0, 3411, san1			;30%

	CheckLimit EscLowLimit, 0, 1001, san1				;20%

	ret 				;no errors, return

san1:	ldz stt1*2			;print "Minimum Throttle"
	call PrintString
	rjmp san4

san2:	ldz mad5*2			;print "Sensor calibration"
	call PrintString
	rjmp san4

san3:	ldz mad7*2			;print "Sensor raw data"
	call PrintString

san4:	setstatusbit SanityCheckFailed

	;footer
	call PrintContinueFooter

	;header
	lrv Y1, 0
	lrv FontSelector, f12x16
	call PrintWarningHeader

	lrv X1, 0			;print "Data out of limits:"
	ldz mad1*2
	call PrintString

	call LcdUpdate

	call WaitForOkButton		;CONTINUE?
	ret



	;--- Check limits ---

Limit:

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
	no_offset_ldz EeMixerTable

mt1:	call ReadEeprom
	st x+, t
	adiw z, 1
	dec yl
	brne mt1

	ret



	;--- Copy and scale PI gain and limits from EE to 16.8 variables ---

LoadParameterTable:

	no_offset_ldz EeParameterTable
	rcall fli2
	b16mov2 PgainRoll, PgainRollOrg, Temp

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

	rvbrflagfalse flagRollPitchLink, lpt1

	no_offset_ldz EeParameterTable

lpt1:	rcall fli2
	b16mov2 PgainPitch, PgainPitchOrg, Temp

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

	no_offset_ldz 0x0054
	rcall fli2
	b16mov2 PgainYaw, PgainYawOrg, Temp

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
	ret



	;--- Load SL parameters from EEPROM ---

LoadSelfLevelSettings:

	no_offset_ldz eeSelflevelPgain
	rcall fli2
	b16mov2 SelflevelPgain, SelfLevelPgainOrg, Temp

	rcall fli2				;eeSelflevelPlimit
	b16ldi Temper, 10
	b16mul SelflevelPlimit, Temp, Temper

	rcall fli2				;eeAccTrimRoll
	b16mov AccTrimRollOrg, Temp
	b16fdiv Temp, 2
	b16mov AccTrimRoll, Temp

	rcall fli2				;eeAccTrimPitch
	b16mov AccTrimPitchOrg, Temp
	b16fdiv Temp, 2
	b16mov AccTrimPitch, Temp

	rcall fli2				;eeSlMixRate
	rcall TempDiv100
	b16mov SelflevelPgainRate, Temp
	ret



	;--- Load gimbal settings from EEPROM ---

LoadGimbalSettings:

	no_offset_ldz eeCamRollGain
	rcall fli2
	b16mov CamRollGainOrg, Temp
	rcall TempDiv16
	b16mov CamRollGain, Temp

	rcall fli2				;eeCamRollOffset
	b16mov CamRollOffset, Temp

	rcall fli2				;eeCamPitchGain
	b16mov CamPitchGainOrg, Temp
	rcall TempDiv16
	b16mov CamPitchGain, Temp

	rcall fli2				;eeCamPitchOffset
	b16mov CamPitchOffset, Temp

	call GetEePVariable8			;eeCamServoMixing
	sts CamServoMixing, xl

	rcall fli2				;eeCamRollHomePos
	b16mov CamRollHomePos, Temp

	rcall fli2				;eeCamPitchHomePos
	b16mov CamPitchHomePos, Temp
	ret



	;--- Load ESC low limit setting from EEPROM ---

LoadEscLowLimit:

	no_offset_ldz eeEscLowLimit
	rcall fli2
	b16ldi Temper, 50.0
	b16mul EscLowLimit, Temp, Temper
	ret



	;--- Load stick dead zone setting from EEPROM ---

LoadStickDeadZone:

	no_offset_ldz eeStickDeadZone
	rcall fli2
	b16mov StickDeadZone, Temp
	ret



	;--- Prepare the OutputRateBitmask and OutputTypeBitmask variables ---

UpdateOutputTypeAndRate:

	ldi yl, 8
	no_offset_ldz RamMixerTable

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

	no_offset_ldz eeLinkRollPitch
	call ReadEepromP
	sts flagRollPitchLink, t
	ret



	;--- Read the S.Bus DG2 settings from EEPROM ---

LoadDG2Settings:

	no_offset_ldz eeDG2Functions
	call ReadEepromP
	sts DG2Functions, t
	ret



	;--- Get EEPROM address of the first mapped channel ---

GetEeChannelMapping:

	lds t, RxMode
	cpi t, RxModeSatDSM2
	brlt ecm1

	no_offset_ldz eeSatChannelRoll		;channel mapping for Satellite mode
	rjmp ecm2

ecm1:	no_offset_ldz eeChannelRoll		;normal channel mapping

ecm2:	ret



	;--- Read mapped channel value from EEPROM ---

LoadMappedChannel:

	call GetEePVariable8
	dec xl
	st y+, xl
	ret



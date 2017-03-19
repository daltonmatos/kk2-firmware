
FlightInit:

	rcall LoadMixerTable			;copy Mixertable from EEPROM to RAM
	rcall LoadParameterTable		;copy and scale PI gain and limits from EEPROM to 16.8 variables
	rcall UpdateOutputTypeAndRate


	ldx 2500				;preload the servo filters
	ldy FilteredOut1
	ldz ServoFilterDelayCounter1
	clr ka
	ldi t, 8

fli8:	st y+, xh
	st y+, xl
	st y+, ka
	st z+, ka
	dec t
	brne fli8


	;board orientation
	ldz eeBoardOrientation
	call ReadEeprom
	sts BoardOrientation, t


	;self-level
	rcall LoadSelfLevelSettings


	;misc. settings
	rcall LoadEscLowLimit			;eeEscLowLimit
	rcall LoadStickDeadZone			;eeStickDeadZone

	call GetEePVariable16			;eeBattAlarmVoltage
	lsl xl
	rol xh
	lsl xl
	rol xh
	clr yh
	b16store BattAlarmVoltage

	rcall fli2				;eeMotorSpinLevel
	rcall fli5
	b16mov MotorSpinLevel, Temp


	;stick scaling
	ldz eeStickScaleRoll
	rcall fli2
	rcall TempDiv16
	b16mov2 StickScaleRoll, StickScaleRollOrg, Temp

	rcall fli2				;eeStickScalePitch
	rcall TempDiv16
	b16mov2 StickScalePitch, StickScalePitchOrg, Temp

	rcall fli2				;eeStickScaleYaw
	rcall TempDiv16
	b16mov2 StickScaleYaw, StickScaleYawOrg, Temp

	rcall fli2				;eeStickScaleThrottle
	rcall TempDiv16
	b16mov StickScaleThrottle, Temp


	;channel mapping
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


	;gimbal settings
fli3:	rcall LoadGimbalSettings


	;servo settings
	ldz eeServoFilter
	call GetEePVariable8			;ServoFilter = (100 - eeServoFilter) / 128
	ldi yh, 100
	sub yh, xl
	lsl yh
	clr xl
	clr xh
	b16store ServoFilter

	call GetEePVariable8			;eeServoFilterDelay
	sts ServoFilterDelay, xl

	lds t, OutputTypeBitmask
	andi t, 0xC0
	breq fli6

	ldx 3					;ESC mode on M7 and/or M8
	b16storex PwmLimitM7L
	b16storex PwmLimitM8L
	ldx 2500
	b16storex PwmLimitM7H
	b16storex PwmLimitM8H
	ldz eeLowOutputRate
	rjmp fli7

fli6:	ldz eeServoLimitM7L			;servo mode on M7 and M8
	rcall GetServoLimit
	b16storex PwmLimitM7L
	rcall GetServoLimit
	b16storex PwmLimitM7H
	rcall GetServoLimit
	b16storex PwmLimitM8L
	rcall GetServoLimit
	b16storex PwmLimitM8H

fli7:	call GetEePVariable8			;eeLowOutputRate
	dec xl
	andi xl, 0x07
	inc xl
	sts OutputRateDivider, xl		;slow rate divider. f = 400 / OutputRateDivider
	lrv OutputRateDividerCounter, 1


	;sensor calibration data
	ldz EeSensorCalData			;load ACC calibration data
	call GetEePVariable168
	b16store AccXZero
	call GetEePVariable168
	b16store AccYZero
	call GetEePVariable168
	b16store AccZZero


	;mode settings
	rcall ReadLinkRollPitchFlag

	ldz eeAutoDisarm
	call ReadEepromP
	sts flagAutoDisarm, t


	;remaining settings
	call CheckTuningMode
	call LoadAuxSwitchSetup
	call LoadBatteryVoltageOffset
	call LoadDG2Settings
	call LoadTPASettings
	call LoadTSSASettings


	;reset variables
	ser t					;make sure the AUX switch function will be updated
	sts AuxSwitchPositionOld, t

	sts flagLcdUpdate, t

	lrv RxTimeoutLimit, TimeoutLimit


	clr t
	sts flagMutePwm, t

	sts flagMotorSpin, t

	sts flagArmed, t
	sts flagArmedOldState, t

	sts ButtonDelay, t

	sts flagAlarmOverride, t
	sts flagGeneralBuzzerOn, t
	sts flagLvaBuzzerOn, t
	sts flagDebugBuzzerOn, t

	b16set AutoDisarmDelay

	b16set BeeperDelay

	b16set LvaDdsAcc
	sts LvaDdsOn, t
	sts LvaHysteresis, t

	b16set ArmedBeepDds

	b16set NoActivityTimer
	b16set NoActivityDds

	b16set LiveUpdateTimer

	b16set CamRoll
	b16set CamPitch

	b16set RxYaw

	b16set EulerAngleRoll
	b16set EulerAnglePitch

	sts flagBatteryLog, t
	b16ldi BatteryVoltageLowpass, 1023

	ldi t, 20				;will skip a few iterations to help RX input syncronization
	sts RxSyncCounter, t

	rcall Initialize3dVector		;set 3d vector to point straigth up


	;ACC
	lds t, MpuAccCfg
	cpi t, MpuAcc2g
	brne fli22

	b16ldi TiltAngMult, 0.33		;2g
	rjmp fli30

fli22:	cpi t, MpuAcc4g
	brne fli24

	b16ldi TiltAngMult, 0.66		;4g
	rjmp fli30

fli24:	cpi t, MpuAcc8g
	brne fli26

	b16ldi TiltAngMult, 1.32		;8g
	rjmp fli30

fli26:	b16ldi TiltAngMult, 2.64		;16g


	;gyro
fli30:	b832ldi MagicNumberMult, 1.830082440462336 ;1.830082440462336*(6250/4096)=2.7924841926 (all settings use this magic number as the GyroRate is scaled instead in imu.asm)


	;RGB LED
	rcall LoadWS2812Settings		;LED pattern and brightness

	call WS2812LoadData
	brcs fli33

	call WS2812SendData			;update the RGB LED strip


	;status
fli33:	lds t, StatusBits			;clear the lower status bits
	andi t, 0xF0
	sts StatusBits, t

	ldz eeMotorLayoutOk			;motor layout loaded?
	call ReadEeprom				;check user profile #1 only
	brflagtrue t, fli4

	setstatusbit NoMotorLayout		;no, will display an error and refuse arming

fli4:	ldz eeSensorsCalibrated			;sensors calibrated?
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

	b16ldi Temper, 0.3203125		;0.3203125 * 0.03125 = 0.010009765 which is much closer to 0.01 than 0.0078125 (= b16ldi Temp, 0.01)
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



	;--- Get servo limit ---		// OBSERVE: For M7 and M8 only!

GetServoLimit:

	call GetEePVariable8			;get EEPROM value (range should be [-100, 100]) and multiply by 25
	ldi t, 25
	muls xl, t
	movw x, r1:r0

	ldy 2500				;shift range from [-2500, 2500] to [0, 5000]
	add xl, yl
	adc xh, yh

	asr xh					;divide by 2
	ror xl

	cp xl, yl				;value >= 2500?
	cpc xh, yh
	brlt gsl1

	movw x, y				;yes, set to 2500
	ret

gsl1:	ldy 3					;value < 3?
	cp xl, yl
	cpc xh, yh
	brge gsl2

	movw x, y				;yes, set to 3 (cannot use smaller values because then the timer won't trigger)

gsl2:	ret



mad1:	.db "Data out of limits:", 0
mad5:	.db "Sensor calibration", 0, 0
mad7:	.db "Sensor raw data", 0



	;--- Sanity check ---

SanityCheck:

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

	call CheckTPAValues
	brts san4

	call CheckTSSAValues
	brts san5

	ret 					;no errors, return

san1:	ldz stt1*2				;error "Minimum Throttle"
	rjmp san10

san2:	ldz mad5*2				;error "Sensor calibration"
	rjmp san10

san3:	ldz mad7*2				;error "Sensor raw data"
	rjmp san10

san4:	ldz xps2*2				;error "TPA Settings"
	rjmp san10

san5:	ldz xps3*2				;error "TSSA Settings"

san10:	pushz
	setstatusbit SanityCheckFailed

	;header
	call PrintWarningHeader

	lrv X1, 0				;print "Data out of limits:"
	ldz mad1*2
	call PrintString

	;error message
	lrv X1, 0
	call LineFeed
	popz
	call PrintString

	;footer
	call PrintContinueFooter
	call LcdUpdate

	call WaitForOkButton			;CONTINUE?
	ret



	;--- Check limits ---

Limit:

	cp  xl, yl				;less?
	cpc xh, yh
	brlt lim1

	cp  xl, zl				;greater?
	cpc xh, zh
	brge lim1

	clc					;OK
	ret

lim1:	sec					;not OK
	ret



	;--- Copy Mixertable from EEPROM to RAM ---

LoadMixerTable:

	ldi yl, 64
	ldi yh, 8
	clr kh
	ldx RamMixerTable
	ldz EeMixerTable

lmt1:	call ReadEeprom
	st x+, t
	adiw z, 1

	or kh, t				;generate bitmask for active outputs
	dec yh
	brne lmt2

	ldi t, 0xFC				;will ignore the output type and rate flags (and other mixer values of 1, 2 or 3)
	add t, kh
	ror kl
	clr kh
	ldi yh, 8

lmt2:	dec yl
	brne lmt1

	sts OutputStateBitmask, kl
	ret



	;--- Copy and scale PI gain and limits from EE to 16.8 variables ---

LoadParameterTable:

	ldz EeParameterTable
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

	ldz EeParameterTable

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

	ldz 0x0054
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

	ldz eeSelflevelPgain
	rcall fli2
	b16mov2 SelflevelPgain, SelfLevelPgainOrg, Temp

	rcall fli2				;eeSelflevelPlimit
	b16ldi Temper, 10
	b16mul SelflevelPlimit, Temp, Temper

	rcall fli2				;eeAccTrimRoll
	b16mov2 AccTrimRoll, AccTrimRollOrg, Temp
	b16fdiv AccTrimRoll, 2

	rcall fli2				;eeAccTrimPitch
	b16mov2 AccTrimPitch, AccTrimPitchOrg, Temp
	b16fdiv AccTrimPitch, 2

	rcall fli2				;eeSlMixRate
	rcall TempDiv100
	b16mov SelflevelPgainRate, Temp
	ret



	;--- Load gimbal settings from EEPROM ---

LoadGimbalSettings:

	ldz eeCamRollGain
	rcall fli2
	movw k, x
	b16mov CamRollGainOrg, Temp
	rcall TempDiv16
	b16mov CamRollGain, Temp

	clr ka					;will activate output M7 when roll gain is non-zero
	ldy 0xFFFF
	add yl, kl
	adc yh, kh
	ror ka

	rcall fli2				;eeCamRollOffset
	b16mov CamRollOffset, Temp

	rcall fli2				;eeCamPitchGain
	movw k, x
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

	ldy 0xFFFF				;will activate output M8 when pitch gain is non-zero
	add yl, kl
	adc yh, kh
	ror ka

	lds t, OutputStateBitmask
	or t, ka
	sts OutputStateBitmask, t
	ret



	;--- Load ESC low limit setting from EEPROM ---

LoadEscLowLimit:

	ldz eeEscLowLimit
	rcall fli2
	b16ldi Temper, 50.0
	b16mul EscLowLimit, Temp, Temper
	ret



	;--- Load stick dead zone setting from EEPROM ---

LoadStickDeadZone:

	ldz eeStickDeadZone
	rcall fli2
	b16mov StickDeadZone, Temp
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
	call ReadEepromP
	sts flagRollPitchLink, t
	ret



	;--- Get EEPROM address of the first mapped channel ---

GetEeChannelMapping:

	lds t, RxMode
	cpi t, RxModeSatDSM2
	brlt ecm1

	ldz eeSatChannelRoll			;channel mapping for Satellite mode
	rjmp ecm2

ecm1:	ldz eeChannelRoll			;normal channel mapping

ecm2:	ret



	;--- Read mapped channel value from EEPROM ---

LoadMappedChannel:

	call GetEePVariable8
	dec xl
	st y+, xl
	ret



	;--- Read WS2812 settings from EEPROM ---

LoadWS2812Settings:

	ldz eeWS2812Pattern			;eeWS2812Pattern
	call ReadEepromP
	andi t, 0x03
	sts WS2812Pattern, t

	adiw z, 1				;eeWS2812Brightness
	call ReadEepromP
	sts WS2812Brightness, t
	ret



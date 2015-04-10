;--- RAM ---

.equ	LcdBuffer	=0x0100 ;to 0x04ff  Screen buffer, 1024 bytes

.equ	RamMixerTable	=0x0500 ;to 0x053f  SRAM copy of mixer table

.set	RamVariables	=0x0540 ;to 0x07ff  SRAM variables

				;0x0800-0x08ff Stack





;--- EEPROM ---

			;0x0000  to 0x0003  Signature 

.equ	EeMixerTable	=0x0004 ;to 0x0043  Mixer Table, 8bit, 64 bytes

.equ	EeParameterTable=0x0044 ;to 0x005c  Axis gain and limit parameters, 16bit, 24 bytes

.equ	EeSensorCalData	=0x005d ;to 0x006f  Sensor calibration data, 16.8bit, 18 bytes

.set	EeRegisters	=0x0070 ;to

        

;---  16.8 bit signed registers ---

FixedPointVariableEnumerate168 Temp
FixedPointVariableEnumerate168 RxChannel
FixedPointVariableEnumerate168 RxRoll
FixedPointVariableEnumerate168 RxPitch
FixedPointVariableEnumerate168 RxThrottle
FixedPointVariableEnumerate168 RxYaw
FixedPointVariableEnumerate168 RxAux
FixedPointVariableEnumerate168 RxAux2
FixedPointVariableEnumerate168 RxAux3
FixedPointVariableEnumerate168 RxAux4

FixedPointVariableEnumerate168 GyroRoll
FixedPointVariableEnumerate168 GyroPitch
FixedPointVariableEnumerate168 GyroYaw
FixedPointVariableEnumerate168 GyroRollZero
FixedPointVariableEnumerate168 GyroPitchZero
FixedPointVariableEnumerate168 GyroYawZero
FixedPointVariableEnumerate168 GyroRollVC
FixedPointVariableEnumerate168 GyroPitchVC

FixedPointVariableEnumerate168 AccX
FixedPointVariableEnumerate168 AccY
FixedPointVariableEnumerate168 AccZ
FixedPointVariableEnumerate168 AccXZero
FixedPointVariableEnumerate168 AccYZero
FixedPointVariableEnumerate168 AccZZero

FixedPointVariableEnumerate168 BatteryVoltage
FixedPointVariableEnumerate168 BatteryVoltageLowpass
FixedPointVariableEnumerate168 BatteryVoltageLogged

FixedPointVariableEnumerate168 CommandRoll		;output from IMU
FixedPointVariableEnumerate168 CommandPitch
FixedPointVariableEnumerate168 CommandYaw

FixedPointVariableEnumerate168 IntegralRoll		;PI control
FixedPointVariableEnumerate168 IntegralPitch
FixedPointVariableEnumerate168 IntegralYaw
FixedPointVariableEnumerate168 Error
FixedPointVariableEnumerate168 PgainRoll
FixedPointVariableEnumerate168 PgainPitch
FixedPointVariableEnumerate168 PgainYaw
FixedPointVariableEnumerate168 PlimitRoll
FixedPointVariableEnumerate168 PlimitPitch
FixedPointVariableEnumerate168 PlimitYaw
FixedPointVariableEnumerate168 IgainRoll
FixedPointVariableEnumerate168 IgainPitch
FixedPointVariableEnumerate168 IgainYaw
FixedPointVariableEnumerate168 IlimitRoll
FixedPointVariableEnumerate168 IlimitPitch
FixedPointVariableEnumerate168 IlimitYaw

FixedPointVariableEnumerate168 PgainRollOrg		;variables used for remote tuning
FixedPointVariableEnumerate168 PgainPitchOrg
FixedPointVariableEnumerate168 PgainYawOrg
FixedPointVariableEnumerate168 IgainRollOrg
FixedPointVariableEnumerate168 IgainPitchOrg
FixedPointVariableEnumerate168 IgainYawOrg

FixedPointVariableEnumerate168 Tuned6			;variables used for remote tuning
FixedPointVariableEnumerate168 Tuned7

FixedPointVariableEnumerate168 EscLowLimit

FixedPointVariableEnumerate168 StickScaleRoll
FixedPointVariableEnumerate168 StickScalePitch
FixedPointVariableEnumerate168 StickScaleYaw
FixedPointVariableEnumerate168 StickScaleThrottle
FixedPointVariableEnumerate168 MixFactor

FixedPointVariableEnumerate168 MixValue
FixedPointVariableEnumerate168 MixValueFactor

FixedPointVariableEnumerate168 Out1
FixedPointVariableEnumerate168 Out2
FixedPointVariableEnumerate168 Out3
FixedPointVariableEnumerate168 Out4
FixedPointVariableEnumerate168 Out5
FixedPointVariableEnumerate168 Out6
FixedPointVariableEnumerate168 Out7
FixedPointVariableEnumerate168 Out8

FixedPointVariableEnumerate168 FilteredOut1
FixedPointVariableEnumerate168 FilteredOut2
FixedPointVariableEnumerate168 FilteredOut3
FixedPointVariableEnumerate168 FilteredOut4
FixedPointVariableEnumerate168 FilteredOut5
FixedPointVariableEnumerate168 FilteredOut6
FixedPointVariableEnumerate168 FilteredOut7
FixedPointVariableEnumerate168 FilteredOut8

FixedPointVariableEnumerate168 Offset1
FixedPointVariableEnumerate168 Offset2
FixedPointVariableEnumerate168 Offset3
FixedPointVariableEnumerate168 Offset4
FixedPointVariableEnumerate168 Offset5
FixedPointVariableEnumerate168 Offset6
FixedPointVariableEnumerate168 Offset7
FixedPointVariableEnumerate168 Offset8

FixedPointVariableEnumerate168 Temper

FixedPointVariableEnumerate168 SelflevelPgain
FixedPointVariableEnumerate168 SelflevelPgainOrg	;used for remote tuning
FixedPointVariableEnumerate168 SelflevelPgainRate
FixedPointVariableEnumerate168 SelflevelPlimit

FixedPointVariableEnumerate168 HeightDampeningGain
FixedPointVariableEnumerate168 HeightDampeningLimit

FixedPointVariableEnumerate168 BattAlarmVoltage

FixedPointVariableEnumerate168 AccAngleRoll
FixedPointVariableEnumerate168 AccAnglePitch

FixedPointVariableEnumerate168 LimitV
FixedPointVariableEnumerate168 Value

FixedPointVariableEnumerate168 LvaDdsAcc

FixedPointVariableEnumerate168 PwmOutput

FixedPointVariableEnumerate168 ServoFilter

FixedPointVariableEnumerate168 ArmedBeepDds

FixedPointVariableEnumerate168 BeeperDelay

FixedPointVariableEnumerate168 AccTrimRoll
FixedPointVariableEnumerate168 AccTrimPitch

FixedPointVariableEnumerate168 AccTrimRollOrg		;variables used for remote tuning
FixedPointVariableEnumerate168 AccTrimPitchOrg

FixedPointVariableEnumerate168 AutoDisarmDelay

FixedPointVariableEnumerate168 NoActivityTimer
FixedPointVariableEnumerate168 NoActivityDds

FixedPointVariableEnumerate168 LiveUpdateTimer

FixedPointVariableEnumerate168 EulerAngleRoll
FixedPointVariableEnumerate168 EulerAnglePitch

FixedPointVariableEnumerate168 Angle

FixedPointVariableEnumerate168 AccXfilter
FixedPointVariableEnumerate168 AccYfilter
FixedPointVariableEnumerate168 AccZfilter

FixedPointVariableEnumerate168 CamRollGain
FixedPointVariableEnumerate168 CamRollOffset
FixedPointVariableEnumerate168 CamPitchGain
FixedPointVariableEnumerate168 CamPitchOffset
FixedPointVariableEnumerate168 CamRoll
FixedPointVariableEnumerate168 CamPitch
FixedPointVariableEnumerate168 CamRollHomePos
FixedPointVariableEnumerate168 CamPitchHomePos

FixedPointVariableEnumerate168 CamRollGainOrg		;variables used for remote tuning
FixedPointVariableEnumerate168 CamPitchGainOrg

FixedPointVariableEnumerate168 TuningRateValue		;common input rate used for remote tuning

FixedPointVariableEnumerate824 Theta
FixedPointVariableEnumerate824 Sine
FixedPointVariableEnumerate824 Cosine

FixedPointVariableEnumerate824 VectorX
FixedPointVariableEnumerate824 VectorY
FixedPointVariableEnumerate824 VectorZ
FixedPointVariableEnumerate824 LengthVector

FixedPointVariableEnumerate824 VectorA
FixedPointVariableEnumerate824 VectorB

FixedPointVariableEnumerate824 TempA
FixedPointVariableEnumerate824 TempB
FixedPointVariableEnumerate824 TempC
FixedPointVariableEnumerate824 TempD

FixedPointVariableEnumerate824 VectorNewA
FixedPointVariableEnumerate824 VectorNewB



;--- RAM variables (8bit)----

RamVariableEnumerate8 Xpos			;pixel pos
RamVariableEnumerate8 Ypos

RamVariableEnumerate8 X1			;line start and end
RamVariableEnumerate8 Y1
RamVariableEnumerate8 X2
RamVariableEnumerate8 Y2

RamVariableEnumerate8 PixelType			;0 = EOR   1 = OR   2 = AND

RamVariableEnumerate8 FontSelector

RamVariableEnumerate8 MainMenuCursorYposSave
RamVariableEnumerate8 MainMenuListYposSave

RamVariableEnumerate8 LoadMenuCursorYposSave
RamVariableEnumerate8 LoadMenuListYposSave

RamVariableEnumerate8 SBusByte0			;the following byte values work as an array and the order must not be modified!
RamVariableEnumerate8 SBusByte1
RamVariableEnumerate8 SBusByte2
RamVariableEnumerate8 SBusByte3
RamVariableEnumerate8 SBusByte4
RamVariableEnumerate8 SBusByte5
RamVariableEnumerate8 SBusByte6
RamVariableEnumerate8 SBusByte7
RamVariableEnumerate8 SBusByte8
RamVariableEnumerate8 SBusByte9
RamVariableEnumerate8 SBusByte10

RamVariableEnumerate8 SBusFlags

RamVariableEnumerate8 Channel17
RamVariableEnumerate8 Channel18
RamVariableEnumerate8 FrameLossMax
RamVariableEnumerate8 Failsafe
RamVariableEnumerate8 flagSBusFrameValid
RamVariableEnumerate8 TimeoutCounter
RamVariableEnumerate8 FrameCounter
RamVariableEnumerate8 FrameLossCounter

RamVariableEnumerate8 OutputRateBitmask		;for each output channel: 0=slow rate  1=fast rate
RamVariableEnumerate8 OutputTypeBitmask		;for each output channel: 0=servo 1=ESC
RamVariableEnumerate8 OutputRateDivider
RamVariableEnumerate8 OutputRateDividerCounter

RamVariableEnumerate8 flagRollPitchLink

RamVariableEnumerate8 flagPwmEnd
RamVariableEnumerate8 flagPwmGen
RamVariableEnumerate8 flagPwmState
RamVariableEnumerate8 PwmOutputMask

RamVariableEnumerate8 flagArmed
RamVariableEnumerate8 flagArmedOldState
RamVariableEnumerate8 flagThrottleZero
RamVariableEnumerate8 ArmingDelay

RamVariableEnumerate8 FlashingLEDCounter
RamVariableEnumerate8 FlashingLEDCount

RamVariableEnumerate8 flagLcdUpdate

RamVariableEnumerate8 flagSlOn
RamVariableEnumerate8 flagSlStickMixing

RamVariableEnumerate8 flagAlarmOn		;alarm activated from the AUX switch
RamVariableEnumerate8 flagAlarmOverride

RamVariableEnumerate8 AuxBeepDelay
RamVariableEnumerate8 AuxCounter
RamVariableEnumerate8 AuxSwitchPosition
RamVariableEnumerate8 AuxSwitchPositionOld
RamVariableEnumerate8 Aux4SwitchPosition

RamVariableEnumerate8 flagSensorsOk

RamVariableEnumerate8 flagA
RamVariableEnumerate8 flagB

RamVariableEnumerate8 Index
RamVariableEnumerate8 Mode

RamVariableEnumerate8 OutputTypeBitmaskCopy

RamVariableEnumerate8 flagInactive

RamVariableEnumerate8 LvaDdsOn
RamVariableEnumerate8 flagLvaBuzzerOn

RamVariableEnumerate8 flagGeneralBuzzerOn

RamVariableEnumerate8 StatusBits
RamVariableEnumerate8 StatusCounter

RamVariableEnumerate8 flagAutoDisarm

RamVariableEnumerate8 flagMutePwm

RamVariableEnumerate8 flagDebugBuzzerOn

RamVariableEnumerate8 flagGyrosCalibrated

RamVariableEnumerate8 CamServoMixing

RamVariableEnumerate8 LcdContrast

RamVariableEnumerate8 TuningMode		;0=Off, 1=Aileron, 2=Elevator, 3=Rudder, 4=SL gain, 5=ACC trim, 6=Gimbal
RamVariableEnumerate8 TuningRate		;0=invalid, 1=Low, 2=Medium, 3=High

RamVariableEnumerate8 RxBuffer0
RamVariableEnumerate8 RxBuffer1
RamVariableEnumerate8 RxBuffer2
RamVariableEnumerate8 RxBuffer3
RamVariableEnumerate8 RxBuffer4
RamVariableEnumerate8 RxBuffer5
RamVariableEnumerate8 RxBuffer6
RamVariableEnumerate8 RxBuffer7
RamVariableEnumerate8 RxBuffer8
RamVariableEnumerate8 RxBuffer9
RamVariableEnumerate8 RxBuffer10
RamVariableEnumerate8 RxBuffer11
RamVariableEnumerate8 RxBuffer12
RamVariableEnumerate8 RxBuffer13
RamVariableEnumerate8 RxBuffer14
RamVariableEnumerate8 RxBuffer15
RamVariableEnumerate8 RxBuffer16
RamVariableEnumerate8 RxBuffer17
RamVariableEnumerate8 RxBuffer18
RamVariableEnumerate8 RxBuffer19
RamVariableEnumerate8 RxBuffer20
RamVariableEnumerate8 RxBuffer21
RamVariableEnumerate8 RxBuffer22
RamVariableEnumerate8 RxBuffer23
RamVariableEnumerate8 RxBuffer24

RamVariableEnumerate8 RxBufferAddressL
RamVariableEnumerate8 RxBufferAddressH

RamVariableEnumerate8 RxBufferIndex
RamVariableEnumerate8 RxBufferIndexOld
RamVariableEnumerate8 RxBufferState

RamVariableEnumerate8 FlagByte1			;bit flags for motor layout arrays (one byte for each output, M1 - M8) to set negative values
RamVariableEnumerate8 FlagByte2			;(throttle aileron elevator rudder X X X Y) where Y sets rudder to -1 and X is unused
RamVariableEnumerate8 FlagByte3
RamVariableEnumerate8 FlagByte4
RamVariableEnumerate8 FlagByte5
RamVariableEnumerate8 FlagByte6
RamVariableEnumerate8 FlagByte7
RamVariableEnumerate8 FlagByte8




;--- EEPROM registers ----			;Do not change the order of the EEPROM variables! They are read and written sequentially.

EEVariableEnumerate8 eeLcdContrast

EEVariableEnumerate16 eeStickScaleRoll
EEVariableEnumerate16 eeStickScalePitch
EEVariableEnumerate16 eeStickScaleYaw
EEVariableEnumerate16 eeStickScaleThrottle
EEVariableEnumerate16 eeStickScaleSlMixing

EEVariableEnumerate16 eeSelflevelPgain
EEVariableEnumerate16 eeSelflevelPlimit
EEVariableEnumerate16 eeAccTrimRoll
EEVariableEnumerate16 eeAccTrimPitch
EEVariableEnumerate16 eeSlMixRate

EEVariableEnumerate16 eeEscLowLimit
EEVariableEnumerate16 eeHeightDampeningGain
EEVariableEnumerate16 eeHeightDampeningLimit
EEVariableEnumerate16 eeBattAlarmVoltage
EEVariableEnumerate16 eeServoFilter

EEVariableEnumerate8 eeLinkRollPitch		;true=on  false=off
EEVariableEnumerate8 eeAutoDisarm		;true=on  false=off
EEVariableEnumerate8 eeButtonBeep		;true=on  false=off
EEVariableEnumerate8 eeArmingBeeps		;true=on  false=off
EEVariableEnumerate8 eeQuietESCs		;true=on  false=off

EEVariableEnumerate16 eeCamRollGain
EEVariableEnumerate16 eeCamPitchGain
EEVariableEnumerate8 eeCamServoMixing		;true=vtail/differential mixing false=vanilla servo output
EEVariableEnumerate16 eeCamRollHomePos
EEVariableEnumerate16 eeCamPitchHomePos

EEVariableEnumerate8 eeSensorsCalibrated
EEVariableEnumerate8 eeMotorLayoutOk
EEVariableEnumerate8 eeUserAccepted

EEVariableEnumerate8 eeEscCalibration

EEVariableEnumerate8 eeTuningRate



;--- Registers (global) ----

					;r0-r1 used by the HW multiplier

					;r2-r13 part of the local variables pool

.def	treg			=r14	;temp reg for ISR

.def	SregSaver		=r15	;Storage of the SREG, used in ISR

.def	t			=r16	;Main temporary register

					;R17-R24 is the local variables pool

.def	tt			=r25	;Temp reg for ISR


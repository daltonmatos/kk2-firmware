

;fonts
.equ	f4x6			= 0	;fonts and symbols
.equ 	f6x8			= 1
.equ	f8x12			= 2
.equ	f12x16			= 3
.equ	s16x16			= 4

;RX modes
.equ	RxModeStandard		= 0
.equ	RxModeCppm		= 1
.equ	RxModeSBus		= 2
.equ	RxModeSatDSM2		= 3
.equ	RxModeSatDSMX		= 4
.equ	RxModeSerialLink	= 5

;mixer
.equ	MixValueThrottle	= 0
.equ	MixValueRoll		= 1
.equ	MixValuePitch		= 2
.equ	MixValueYaw		= 3
.equ	MixValueOffset		= 4
.equ	MixValueFlags		= 5

.equ	bMixerFlagType		= 0	;1 = ESC  0 = servo
.equ	fEsc			= 1
.equ	fServo			= 0

.equ	bMixerFlagRate		= 1	;1 = high 0 = low
.equ	fHigh			= 1
.equ	fLow			= 0

;sensors
.equ	GyroLowLimit 		= -120	;limits for sensor testing
.equ	GyroHighLimit	 	= 120

.equ	AccLowLimit 		= -120
.equ	AccHighLimit	 	= 120
.equ	AccZHighLimit	 	= 338

.equ	MpuAcc16g		= 0x18
.equ	MpuAcc8g		= 0x10
.equ	MpuAcc4g		= 0x08
.equ	MpuAcc2g		= 0x00

.equ	MpuGyro2000		= 0x18
.equ	MpuGyro1000		= 0x10
.equ	MpuGyro500		= 0x08
.equ	MpuGyro250		= 0x00

.equ	SlaveAddress		= 0xD0	;MPU I2C address

;status
.equ	AccNotCalibrated	= 0x01
.equ	SanityCheckFailed	= 0x02
.equ	RxSignalLost		= 0x03	;this bit pattern has top priority
.equ	NoMotorLayout		= 0x04
.equ	LvaWarning		= 0x08	;this bit will not prevent arming

.equ	NoAileronInput		= 0x10	;status bit values for standard receiver mode
.equ	NoElevatorInput		= 0x20
.equ	NoThrottleInput		= 0x40
.equ	NoRudderInput		= 0x80

.equ	NoCppmInput		= 0x10	;status bit values for CPPM receiver mode

.equ	NoSBusInput		= 0x10	;status bit values for S.Bus receiver mode
.equ	SBusFailsafe		= 0x20

.equ	NoSatelliteInput	= 0x10	;status bit values for Satellite mode
.equ	SatProtocolError	= 0x20

.equ	NoSerialData		= 0x10	;status bit values for Serial Link mode
.equ	ProtocolError		= 0x20
.equ	RxInputProblem		= 0x40

.equ	NoRxInput		= 0xF0	;RX status flags (for Serial Link mode)
;.equ	NoAileronInput		= 0x10	;see standard receiver mode
;.equ	NoElevatorInput		= 0x20	;see standard receiver mode
;.equ	NoThrottleInput		= 0x40	;see standard receiver mode
;.equ	NoRudderInput		= 0x80	;see standard receiver mode
.equ	CriticalRxError		= 0x08	;S.Bus failsafe or Satellite protocol error

.equ	TimeoutLimit		= 250

.equ	SyncCount		= 2	;2 = 5ms sync interval (when the flight loop is 2.5ms). Minimum value is 2

.equ	AuxCounterInit		= 175

;error log
.equ	NoError			= 0	;message codes for the error log
.equ	ErrorSignalLost		= 1
.equ	ErrorFailsafe		= 2
.equ	ErrorSatProtocolFail	= 3
.equ	ErrorCppmSyncLost	= 4
.equ	ErrorLoopTimeExceeded	= 5
.equ	MaxError		= 6	;must be set to the highest error code +1

;serial link buffer
.equ	RxStartByte		= 0xF0
.equ	RxEndByte		= 0x00
.equ	RxSlaveEndByte		= 0xFF


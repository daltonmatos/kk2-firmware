
.equ	f4x6			= 0	;fonts and symbols
.equ 	f6x8			= 1
.equ	f8x12			= 2
.equ	f12x16			= 3
.equ	s16x16			= 4

.equ	M1			= 0x40	;portc,6
.equ	M2			= 0x10	;portc,4
.equ	M3			= 0x04	;portc,2
.equ	M4			= 0x08	;portc,3
.equ	M5			= 0x02	;portc,1
.equ	M6			= 0x01	;portc,0
.equ	M7			= 0x20	;portc,5
.equ	M8			= 0x80	;portc,7

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

.equ	GyroLowLimit 		= 400	;limits for sensor testing
.equ	GyroHighLimit	 	= 730

.equ	AccLowLimit 		= 450
.equ	AccHighLimit	 	= 850

.equ	AuxCounterInit		= 175

.equ	NoMotorLayout		= 0x01	;status bit values
.equ	AccNotCalibrated	= 0x02
.equ	SanityCheckFailed	= 0x04
.equ	RxSignalLost		= 0x08
.equ	ChannelMappingError	= 0x10
.equ	SatProtocolError	= 0x20
.equ	NoSatelliteInput	= 0x40
.equ	LvaWarning		= 0x80	;this bit will not prevent arming
.equ	CheckThrottleLevel	= 0x80

.equ 	SatRxTimeoutLimit	= 250	;timeout value for Satellite data


	//************************************************************
	//* Serial link data format (8-N-1/250kbps)
	//*
	//*   Byte1:	Start byte (0xF0)
	//*   Byte2:	Flags
	//*   Byte3:	Channel data (MSB)
	//*   Byte4:	Channel data (LSB)
	//*   ...
	//*   Byte21:	Channel data (MSB)
	//*   Byte22:	Channel data (LSB)
	//*   Byte23:	Sonar data (MSB)
	//*   Byte24:	Sonar data (LSB)
	//*   Byte25:	Barometer data (MSB)
	//*   Byte26:	Barometer data (LSB)
	//*   Byte27:	Switches (AUX+AUX4+RX Mode)
	//*   Byte28:	End byte (0x00)
	//*
	//* Flags:	[F7 F6 F5 F4 F3 F2 F1 F0]
	//*
	//*   F0: S.Bus digital channel 17 (DG1).
	//*   F1: S.Bus digital channel 18 (DG2)
	//*   F2: S.Bus frame loss.
	//*   F3: S.Bus failsafe.
	//*   F4: No aileron input.
	//*   F5: No elevator input.
	//*   F6: No throttle input.
	//*   F7: No rudder input.
	//*
	//*   F4+F5+F6+F7: No RX input.
	//*
	//* Channel data (16 bit):
	//*
	//*   MSB:	[D15 D14 D13 D12 D11 D10 D9 D8]
	//*   LSB:	[D7 D6 D5 D4 D3 D2 D1 D0]
	//*
	//* Channel order:
	//*
	//*   1: Throttle, 2: Aileron, 3: Elevator, 4: Rudder, 5: Aux2, 6: Aux3, 7: Aux5,
	//*   8: Aux6, 9: Aux7, 10: Aux8.
	//*
	//* Channel 1 - 10:
	//*
	//*   The data values can range from -1000 to 1000 (11 bit) at full deflection
	//*   with center position at zero. Throttle value range is 0 to 1880.
	//*
	//* Sonar:
	//*
	//*   The sonar value can range from 0 to 4500 (13 bit).
	//*
	//* Barometer:
	//*
	//*   The barometer value can range from 0 to 65535 (16 bit).
	//*
	//* Switches:	[C1 C0 B1 B0 D A2 A1 A0]
	//*
	//*   A0 - A2:	AUX switch position (Up to 8 positions)
	//*   B0 - B1:	AUX4 switch position (Up to 4 positions)
	//*   C0 - C1:	RX mode (00 = Standard RX, 01 = CPPM, 10 = S.Bus, 11 = DSM2)
	//*   D:	Remote tuning (0 = Off, 1 = Altitude hold)
	//*
	//************************************************************



	;--- Put serial RX data into the buffer --- This ISR is also used for S.Bus and Satellite input!!!

IsrSerialRx:

	in SregSaver, sreg

	push zh
	push zl

	;Read and store data
	lds treg, udr0				;read from USART buffer

	lds zl, RxBufferAddressL		;save the received data byte in the buffer
	lds zh, RxBufferAddressH
	st z+, treg

	;Check buffer pointer
	lds treg, RxBufferEndL
	lds tt, RxBufferEndH
	cp zl, treg
	cpc zh, tt
	brne isr20

	ser tt					;buffer is full. Set flag and reset buffer pointer
	sts flagRxBufferFull, tt
	ldz RxBuffer0

isr20:	;Save the buffer pointer
	sts RxBufferAddressL, zl
	sts RxBufferAddressH, zh

	;Exit
	pop zl
	pop zh
	out sreg, SregSaver
	reti



	;--- Read all input channel values ---

GetSerialLinkChannels:

	clr xl					;signal (pull USART pin low) for the external port expander to start transmitting data
	store udr1, xl

	rvsetflagfalse flagNewRxFrame

	;check buffer
	cli
	lds xh, flagRxBufferFull
	sts flagRxBufferFull, xl
	lds kl, RxBufferAddressL
	lds kh, RxBufferAddressH
	sei

	tst xh					;buffer full?
	brne ser22

	rvbrflagfalse flagRxFrameValid, ser21	;no. Will use old input values, but only if valid

	rjmp ser31				;use old input values

ser22:	ldz RxBuffer0				;buffer is full. Is the communication synchronized?
	cp kl, zl
	cpc kh, zh
	brne ser20

	ld t, z					;check start byte
	cpi t, RxStartByte
	brne ser20

	lds t, RxBuffer27			;check end byte
	cpi t, RxEndByte
	breq ser7

ser20:	clr t					;communication must be out of sync so we'll try to recover...

	cli
	sts RxBuffer0, t
	ldz RxBuffer0
	sts RxBufferAddressL, zl
	sts RxBufferAddressH, zh
	sei

ser21:	rjmp ClearSerialChannels

ser7:	;data frame appears to be valid
	rvsetflagtrue flagRxFrameValid

	;fetch channel values
	ldx RxBuffer2				;register X points to the buffer data
	ldi r17, 12				;using register R17 as Byte Index. Number of 16bit values to copy
	ldz Channel1L				;register Z points to the Channel array

ser3:	ld yh, x+				;get MSB from the data array
	ld yl, x+				;get LSB from the data array

	st z+, yl				;store D7 to D0
	st z+, yh				;store D15 to D8

	dec r17					;continue the loop until all 16bit values have been copied
	brne ser3

	;switches
	ld t, x+
	sts RxSwitches, t

	;signal for "New data frame"
	rvsetflagtrue flagNewRxFrame

	clr t					;reset timeout counter
	sts TimeoutCounter, t

	;RX mode (port expander)
ser31:	lds t, RxSwitches
	swap t
	lsr t
	lsr t
	andi t, 0x03
	sts RxModePortExp, t

	;flags
	lds t, RxBuffer1			;check flight critical flags
	sts RxFlags, t
	andi t, 0xF8				;this bit mask will also detect failsafe (S.Bus) and Sat protocol errors
	breq ser33

	setstatusbit RxInputProblem		;aileron, elevator, throttle or rudder inputs are absent
	rjmp csc2				;clear all input channels before leaving, but keep the "RX frame valid" flag set

ser33:	lds t, StatusBits			;clear the "RX input problem" status flag
	cbr t, RxInputProblem
	sts StatusBits, t


	;--- Throttle ---

	ldz Channel1L
	clr yh
	ld xl, z+
	ld xh, z+
	b16store RxThrottle
	rvsetflagfalse flagThrottleZero

	cp  xl, yh				;X == 0 ?
	cpc xh, yh
	brne ser30

	rvsetflagtrue flagThrottleZero		;yes, set flag


ser30:	;--- Aileron ---

	ld xl, z+
	ld xh, z+
	b16store RxRoll


	;--- Elevator ---

	ld xl, z+
	ld xh, z+
	b16store RxPitch


	;--- Rudder ---

	ld xl, z+
	ld xh, z+
	b16store RxYaw


	;--- AUX2 ---

	ld xl, z+
	ld xh, z+
	b16store RxAux2


	;--- AUX3 ---

	ld xl, z+
	ld xh, z+
	b16store RxAux3


/*	;--- AUX5 ---

	ld xl, z+
	ld xh, z+
	b16store RxAux5


	;--- AUX6 ---

	ld xl, z+
	ld xh, z+
	b16store RxAux6


	;--- AUX7 ---

	ld xl, z+
	ld xh, z+
	b16store RxAux7


	;--- AUX8 ---

	ld xl, z+
	ld xh, z+
	b16store RxAux8


	;--- Sonar ---

	ld xh, z+
	ld xl, z+

	st y+, xl				;store sonar value
	st y+, xh
	st y+, t


	;--- Barometer ---

	ld xh, z+
	ld xl, z+

	st y+, xl				;store barometer value
	st y+, xh
	st y+, t
*/

	;--- Switches ---

	lds xl, RxSwitches			;AUX switch position
	andi xl, 0x07
	sts AuxSwitchPosition, xl

	lds xl, RxSwitches			;AUX4 switch position
	swap xl
	andi xl, 0x03
	sts Aux4SwitchPosition, xl

	lds xl, RxSwitches			;remote tuning
	ser t
	sbrs xl, 3
	clr t
	sts flagPortExpTuning, t


	;--- Check aileron and elevator input ---

	b16load RxRoll				;aileron centered?
	call IsChannelCentered
	sts flagAileronCentered, yl

	b16load RxPitch				;elevator centered?
	call IsChannelCentered
	sts flagElevatorCentered, yl


	;--- Check RX ---

	lds t, TimeoutCounter			;timeout?
	inc t
	cpi t, TimeoutLimit
	brsh ClearSerialChannels

	sts TimeoutCounter, t			;not yet


	;--- Request new data ---

req1:	lds xl, SerialSyncCounter		;will send signal to the external port expander when the counter reaches zero
	dec xl
	brne req2

	ser t					;set start and stop bytes to incorrect values (to 'clear' the data buffer)
	sts RxBuffer0, t
	sts RxBuffer27, t

	call TransmitStatus			;also acts as a signal for the external port expander to get ready

	ldi xl, SyncCount

req2:	sts SerialSyncCounter, xl
	ret



	;---- Clear all input values ---

ClearSerialChannels:

	rvsetflagfalse flagRxFrameValid		;set flag to false and all RX input values to zero

csc2:	rvbrflagfalse flagArmed, csc6

	setstatusbit RxSignalLost		;set status bit for "Signal Lost" and activate the Lost Model alarm only when armed
	rvsetflagtrue flagAlarmOverride

csc6:	ldz RxThrottle
	clr t
	ldi xl, 36				;loop counter. 12 variables * 3 bytes per veriable = 36 bytes

csc7:	st z+, t
	dec xl
	brne csc7

	rvsetflagtrue flagThrottleZero

	lds t, AuxSwitchPosition		;select AUX function #3 if not set already
	cpi t, 2
	breq csc1

	ldi t, 2
	sts AuxSwitchPosition, t
	ser t					;make sure the AUX switch function will be updated
	sts AuxSwitchPositionOld, t

csc1:	rjmp req1				;request new data



	;--- Check serial link ---

CheckSerialLink:

	lds t, flagRxFrameValid			;set/clear RX error
	com t
	andi t, NoSerialData
	lds xl, StatusBits
	cbr xl, NoSerialData
	or t, xl
	sts StatusBits, t
	ret



	;--- Check S.Bus flags and run features ---

SerialSBusFlags:

	lds t, RxModePortExp
	cpi t, RxModeSBus
	brne ssf1

	rvbrflagfalse flagRxFrameValid, ssf1

	lds t, RxFlags				;failsafe
	andi t, CriticalRxError
	breq ssf2

	setstatusbit RxSignalLost		;set status bit for "Signal Lost" and activate the Lost Model alarm
	rvsetflagtrue flagAlarmOverride

ssf2:	lds yl, RxFlags				;DG1
	mov t, yl
	andi t, 0x01

	dec t					;activate the (lost model) alarm when DG1 is on
	com t
	sts flagAlarmOverride, t

	lsr yl					;DG2
	andi t, 0x01
	breq ssf1

	cbi DigitalOutPin			;DG2 switch is on
	ret

ssf1:	sbi DigitalOutPin			;DG2 switch is off
	ret





	//************************************************************
	//* Spektrum Satellite format (8-N-1/115Kbps) MSB sent first
	//* DX7/DX6i: One data-frame at 115200 baud every 22ms.
	//*           Every frame is 16 byte long and consists of a 'frame loss' counter value
	//*           plus 7 channels.
	//*
	//*    byte1:  frame loss counter
	//*    byte2:  [0 0 0 R 0 0 N1 N0]
	//*    byte3:  channel data (MSB)
	//*    byte4:  channel data (LSB)
	//*    ...
	//*    byte15: channel data (MSB)
	//*    byte16: channel data (LSB)
	//* 
	//* Channel data (16 bit):
	//*
	//*   MSB:     [F 0 C3 C2 C1 C0 D9 D8]
	//*   LSB:     [D7 D6 D5 D4 D3 D2 D1 D0]
	//* 
	//* R: 0 for 10 bit resolution 1 for 11 bit resolution channel data
	//* N1 to N0 is the number of frames required to receive all channel data. 
	//* F: 1 = indicates beginning of 2nd frame for CH8-9 (DS9 only). Otherwise zero.
	//* C3 to C0 is the channel ID. 0 to 9 (4 bit, as assigned in the transmitter).
	//* D9 to D0 is the channel data (10 bit).
	//*
	//* Channel IDs:
	//*
	//*   0: Throttle, 1: Aileron, 2: Elevator, 3: Rudder, 4: Gear, 5: Aux1, 6: Aux2.
	//*
	//* The data values can range from 0 to 1023/2047 to define a servo pulse width 
	//* from approximately 0.75ms to 2.25ms (1.50ms difference). 1.465us per digit.
	//* A value of 171/342 is 1.0 ms
	//* A value of 512/1024 is 1.5 ms
	//* A value of 853/1706 is 2.0 ms
	//* 0 = 750us, 1023/2047 = 2250us
	//*
	//************************************************************
	

	// This code supports DSM2 (10 bit, single frame) and DSMX (11 bit, single frame).
	// CH0 = Throttle, CH1 = Aileron, CH2 = Elevator, CH3 = Rudder, CH4 = Gear, etc....


	;--- Read all input channel values ---

GetSatChannels:

	rvsetflagfalse flagNewRxFrame

	;Satellite protocol
	clr r20					;used for protocol detection

	lds t, RxMode				;set registers and variables based on selected RX mode
	cpi t, RxModeSatDSMX
	breq sat8

	ldi r18, 0x1C				;DSM2
	ldi r19, 0x03				;mask for 10 bit data (DSM2)
	b16ldi RxOffset, 512
	b16ldi Temp, 2.93			;will convert range [-341, 341] to [-1000, 1000] (throttle = [0, 1880])
	b16ldi Temp2, 205			;throttle value adjustment
	rjmp sat9

sat8:	ldi r18, 0x38				;DSMX
	ldi r19, 0x07				;mask for 11 bit data (DSMX)
	b16ldi RxOffset, 1024
	b16ldi Temp, 1.466			;will convert range [-682, 682] to [-1000, 1000] (throttle = [0, 1880])
	b16ldi Temp2, 410			;throttle value adjustment

sat9:	sts SatDataMask, r19			;data mask (MSB)

	;check buffer
	clr xl

	cli
	lds xh, flagRxBufferFull
	sts flagRxBufferFull, xl
	lds kl, RxBufferAddressL
	lds kh, RxBufferAddressH
	sei

	tst xh					;buffer full?
	brne sat10

	rvbrflagfalse flagRxFrameValid, sat11	;no. Will use old input values, but only if valid

	rjmp sat31				;use old input values

sat10:	ldz RxBuffer0				;buffer is full. Is the communication synchronized?
	cp kl, zl
	cpc kh, zh
	breq sat14

	cli					;no, try to recover...
	sts RxBufferAddressL, zl
	sts RxBufferAddressH, zh
	sei

	rjmp sat31				;use old input values

sat11:	rjmp sat24				;clear all input channels before leaving

sat14:	;Satellite frame appears to be synchronized/valid
	rvsetflagtrue flagRxFrameValid

	;fetch channel values
	ldx RxBuffer2				;skip the first 2 bytes
	ldi r17, 2				;using register R17 as Byte Index

sat3:	ldz Channel1L				;set Channel Array to 1st location
	ld yh, x+				;get MSB from the satelite array
	ld yl, x+				;get LSB from the satelite array

	cpi yh, 0xFF				;ignore non-existent channel
	breq sat6

	or r20, yh				;protocol detection

	mov t, yh				;the channel ID is used to store the channel value at the correct index in the Channel array
	lsr t

	cpi r18, 0x38				;11 data bits?
	brne sat4

	lsr t					;yes, shift the channel ID one more time

sat4:	andi t, 0x0E				;mask Channel ID (multiplied by two and limited to 7 channels)
	inc t					;add one so we end up at ChannelXH
	
	add zl, t				;adjust the Channel array pointer to match the satelite channel ID
	brcc sat2

	inc zh

sat2:	and yh, r19				;data mask for MSB
	st z, yh				;store and decrement pointer to reach ChannelXL
	sbiw z, 1
	st z, yl				;store D0 to D7

sat6:	inc r17					;continue the loop until all 7 channel values have been copied
	inc r17
	cpi r17, 16
	brlt sat3

	;protocol detection
	mov t, r19				;register R19 holds the MSB data mask for the selected mode
	com t
	and r20, t
	cp r20, r18
	breq sat1

	setstatusbit SatProtocolError		;protocol error detected, clear all input channels before leaving
	rvbrflagfalse flagArmed, sat5

	ldi xl, ErrorSatProtocolFail
	call LogError

sat5:	rjmp sat24

sat1:	;set signal for "New frame"
	rvsetflagtrue flagNewRxFrame

	clr t					;reset timeout counter
	sts TimeoutCounter, t


sat31:	;--- Virtual channels ---

	clr t
	sts Channel8L, t
	sts Channel8H, t


	;--- Roll ---

	lds r0, MappedChannel1
	rcall GetSatChannelValue
	rcall AdjustSatValue
	call DeadZone
	b16store RxRoll
	call IsChannelCentered
	sts flagAileronCentered, yl

	
	;--- Pitch ---

	lds r0, MappedChannel2
	rcall GetSatChannelValue
	rcall AdjustSatValue
	call DeadZone
	b16store RxPitch
	call IsChannelCentered
	sts flagElevatorCentered, yl


	;--- Throttle ---

	lds r0, MappedChannel3
	rcall GetSatChannelValue

	rvsetflagfalse flagThrottleZero

	b16loadz Temp2				;throttle value adjustment
	sub xl, zl
	sbc xh, zh
	rcall AdjustSatValue2

	ldz 0					;X < 0 ?
	cp  xl, zl
	cpc xh, zh
	brge sat30

	ldx 0					;yes, set to zero
	rvsetflagtrue flagThrottleZero

sat30:	b16store RxThrottle


	;--- Yaw ---

	lds r0, MappedChannel4
	rcall GetSatChannelValue
	rcall AdjustSatValue
	call DeadZone
	b16store RxYaw

	
	;--- AUX ---

	lds r0, MappedChannel5
	rcall GetSatChannelValue
	rcall AdjustSatValue
	b16store RxAux

	clr yl					;position #1
	ldz -600
	cp  xl, zl
	cpc xh, zh
	brlt sat35

	inc yl					;position #2
	ldz -200
	cp  xl, zl
	cpc xh, zh
	brlt sat35

	inc yl					;position #3
	ldz 200
	cp  xl, zl
	cpc xh, zh
	brlt sat35

	inc yl					;position #4
	ldz 600
	cp  xl, zl
	cpc xh, zh
	brlt sat35

	inc yl					;position #5

sat35:	sts AuxSwitchPosition, yl


	;--- AUX2 ---

	lds r0, MappedChannel6
	rcall GetSatChannelValue
	rcall AdjustSatValue
	b16store RxAux2


	;--- AUX3 ---

	lds r0, MappedChannel7
	rcall GetSatChannelValue
	rcall AdjustSatValue
	b16store RxAux3


	;--- AUX4 ---

	lds r0, MappedChannel8
	rcall GetSatChannelValue
	rcall AdjustSatValue
	b16store RxAux4

	clr yl					;position #1
	ldz -400
	cp  xl, zl
	cpc xh, zh
	brlt sat38

	inc yl					;position #2
	ldz 400
	cp  xl, zl
	cpc xh, zh
	brlt sat38

	inc yl					;position #3

sat38:	sts Aux4SwitchPosition, yl


	;--- Check RX ---

	rvbrflagfalse flagRxFrameValid, sat24
	rjmp sat22

sat23:	sts TimeoutCounter, t
	ret

sat22:	lds t, TimeoutCounter			;timeout?
	inc t
	cpi t, TimeoutLimit
	brlo sat23

	rvbrflagfalse flagArmed, sat24		;yes

	setstatusbit RxSignalLost		;set status bit for "Signal Lost" and activate the Lost Model alarm only when armed
	rvsetflagtrue flagAlarmOverride

sat24:	jmp ClearInputChannels			;will tag the received frame as invalid and clear all input channels



	;--- Get channel value ---

GetSatChannelValue:

	ldzarray Channel1L, 2, r0		;register R0 (input parameter) holds the mapped channel ID
	ld xl, z+
	ld xh, z
	clr yh

	lds t, SatDataMask			;limit value to 1023 or 2047
	and xh, t
	ret



	;--- Adjust satellite value ---

AdjustSatValue:					;subtract Spektrum Satelite channel value offset and adjust the input range

	cp xl, yh				;unused channel (value == zero)?
	cpc xh, yh
	brne asv1

	ret					;yes, return zero

asv1:	b16loadz RxOffset
	sub xl, zl
	sbc xh, zh

AdjustSatValue2:

	b16store Temper
	b16mul Temper, Temper, Temp
	b16load Temper
	ret



	;--- Set or clear RX error ---

CheckSatRx:

	lds t, flagRxFrameValid
	com t
	andi t, NoSatelliteInput
	lds xl, StatusBits
	cbr xl, NoSatelliteInput
	or t, xl
	sts StatusBits, t
	ret



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
	

	// This code supports only DSM2 1024 (10 bit and all channels in a single frame, 16 bytes)
	// CH0 = Throttle, CH1 = Aileron, CH2 = Elevator, CH3 = Rudder, CH4 = Gear, etc....

IsrSatellite:

	in SregSaver, sreg

	push zh
	push zl

	;Read and store data
	lds treg, udr0			;read from USART buffer

	lds zl, RxBufferAddressL	;save the received data byte in the buffer
	lds zh, RxBufferAddressH
	st z+, treg

	;Update buffer index
	lds tt, RxBufferIndex
	inc tt
	cpi tt, 16
	brlt isa20

	ldz RxBuffer0
	clr tt

isa20:	sts RxBufferIndex, tt

	;Save the buffer pointer
	sts RxBufferAddressL, zl
	sts RxBufferAddressH, zh

	;Exit
	pop zl
	pop zh
	out sreg, SregSaver
	reti



	;--- Read all input channel values ---

GetRxChannels:

	clr r20				;used for protocol detection

	lds xl, RxBufferIndex		;data received since last iteration?
	lds xh, RxBufferIndexOld
	cp xl, xh
	breq sat12

	sts RxBufferIndexOld, xl	;yes. Will use old input values, but only if valid
	ldi t, 1
	sts RxBufferState, t
	rvbrflagfalse SatFrameValid, sat11

	rjmp sat31			;use old input values

sat11:	rjmp ClearInputChannels		;clear all input channels before leaving

sat12:	lds t, RxBufferState		;no additional data received. Frame sync?
	cpi t, 2
	breq sat13

	tst t				;no, update status (if non-zero). 0 = No data received since start-up or re-sync
	breq sat11

	cpi t, 100			;prevent wrap-around
	brge sat15

	inc t

sat15:	sts RxBufferState, t
	rvbrflagfalse SatFrameValid, sat11

	rjmp sat31			;use old input values

sat13:	lds xl, RxBufferIndex		;is the communication synchronized?
	tst xl
	breq sat14

	clr t				;no, try to recover...
	sts RxBufferState, t
	sts RxBufferIndexOld, t
	cli
	sts RxBufferIndex, t
	ldz RxBuffer0
	sts RxBufferAddressL, zl
	sts RxBufferAddressH, zh
	sei
	rjmp ClearInputChannels		;clear all input channels before leaving

sat14:	ser t				;the data frame appears to be valid
	sts SatFrameValid, t

	ldx RxBuffer2			;skip first 2 bytes
	ldi r17, 2			;using register R17 as Byte Index

sat3:	ldz Channel1L			;set Channel Array to 1st location
	ld yh, x+			;get MSB from the satelite array
	ld yl, x+			;get LSB from the satelite array

	or r20, yh			;protocol detection

	mov t, yh			;the channel ID is used to store the channel value at the correct index in the Channel array
	lsr t
	andi t, 0x0E			;mask Channel ID (multiplied by two and limited to 7 channels)
	inc t				;add one so we end up at ChannelXH
	
	add zl, t			;adjust the Channel array pointer to match the satelite channel ID
	brcc sat2

	inc zh

sat2:	andi yh, 0x03			;mask for D9 & D8
	st z, yh			;store and decrement pointer to reach ChannelXL
	sbiw z, 1
	st z, yl			;store D0 to D7

	inc r17				;continue the loop until all 7 channel values have been copied
	inc r17
	cpi r17, 16
	brlt sat3

	;Protocol detection
	andi r20, 0xFC
	cpi r20, 0x1C
	breq sat1

	setstatusbit SatProtocolError	;protocol error detected, clear all input channels before leaving
	rjmp ClearInputChannels

sat1:	;Set signal for "New frame"
	ldi t, 3
	sts RxBufferState, t

	clr t				;reset timeout counter
	sts TimeoutCounter, t


sat31:	;--- Virtual channels ---

	clr t
	sts Channel8L, t
	sts Channel8H, t


	;--- Roll ---

	lds r0, MappedChannel1		;get aileron channel value
	rcall GetChannelValue
	rcall AdjustSatValue
	b16store RxRoll

	
	;--- Pitch ---

	lds r0, MappedChannel2		;get elevator channel value
	rcall GetChannelValue
	rcall AdjustSatValue
	b16store RxPitch


	;--- Throttle ---

	lds r0, MappedChannel3		;get throttle channel value
	rcall GetChannelValue

	rvsetflagfalse flagThrottleZero

	ldz 205				;X = X - 205
	sub xl, zl
	sbc xh, zh
	rcall AdjustSatValue2

	ldz 0				;X < 0 ?
	cp  xl, zl
	cpc xh, zh
	brge sat30

	ldx 0				;yes, set to zero
	rvsetflagtrue flagThrottleZero

sat30:	b16store RxThrottle


	;--- Yaw ---

	lds r0, MappedChannel4		;get rudder channel value
	rcall GetChannelValue
	rcall AdjustSatValue
	b16store RxYaw

	
	;--- AUX ---

	lds r0, MappedChannel5		;get aux channel value
	rcall GetChannelValue
	rcall AdjustSatValue
	b16store RxAux

	clr yl				;AUX switch position #1
	ldz -600
	cp  xl, zl
	cpc xh, zh
	brlt sat35

	inc yl				;AUX switch position #2
	ldz -200
	cp  xl, zl
	cpc xh, zh
	brlt sat35

	inc yl				;AUX switch position #3
	ldz 200
	cp  xl, zl
	cpc xh, zh
	brlt sat35

	inc yl				;AUX switch position #4
	ldz 600
	cp  xl, zl
	cpc xh, zh
	brlt sat35

	inc yl				;AUX switch position #5

sat35:	sts AuxSwitchPosition, yl


	;--- AUX2 ---

	lds r0, MappedChannel6		;get aux2 channel value
	rcall GetChannelValue
	rcall AdjustSatValue
	b16store RxAux2


	;--- AUX3 ---

	lds r0, MappedChannel7		;get aux3 channel value
	rcall GetChannelValue
	rcall AdjustSatValue
	b16store RxAux3


	;--- AUX4 ---

	lds r0, MappedChannel8		;get aux4 channel value
	rcall GetChannelValue
	rcall AdjustSatValue
	b16store RxAux4

	clr yl				;AUX4 switch position #1
	ldz -400
	cp  xl, zl
	cpc xh, zh
	brlt sat38

	inc yl				;AUX4 switch position #2
	ldz 400
	cp  xl, zl
	cpc xh, zh
	brlt sat38

	inc yl				;AUX4 switch position #3

sat38:	sts Aux4SwitchPosition, yl


	;--- Check RX ---

	lds t, TimeoutCounter		;timeout?
	inc t
	cpi t, SatRxTimeoutLimit
	brsh ClearInputChannels

	sts TimeoutCounter, t		;not yet
	ret



	;---- Clear all input values ---

ClearInputChannels:

	rvbrflagfalse flagArmed, cic2

	lds t, StatusBits		;avoid setting the RxSignalLost bit when the SatProtocolError has already been set. See status message priority
	andi t, SatProtocolError
	brne cic3

	setstatusbit RxSignalLost	;set status bit for "Signal Lost" and activate the Lost Model alarm only when armed

cic3:	rvsetflagtrue flagAlarmOverride

cic2:	rvsetflagfalse SatFrameValid	;set flag to false and all RX input values to zero
	b16clr RxRoll
	b16set RxPitch
	b16set RxThrottle
	b16set RxYaw
	b16set RxAux
	b16set RxAux2
	b16set RxAux3
	b16set RxAux4
	rvsetflagtrue flagThrottleZero

	lds t, AuxSwitchPosition	;select AUX function #3. PS! Repeatedly setting this value will cause Alarm problems (AuxBeepDelay)
	cpi t, 2
	breq cic1

	ldi t, 2
	sts AuxSwitchPosition, t
	ser t				;make sure the AUX switch function will be updated
	sts AuxSwitchPositionOld, t

cic1:	ret



	;--- Get channel value ---

GetChannelValue:

	mov xl, r0			;check channel mapping
	andi xl, 0xF8
	breq gcv1

	clr xh				;invalid channel mapping. Return zero
	clr xl
	clr yh
	ret

gcv1:	ldzarray Channel1L, 2, r0	;register R0 (input parameter) holds the mapped channel ID
	ld xl, z+
	ld xh, z
	clr yh
	andi xh, 0x03			;limit value to 1023
	ret



	;--- Adjust satellite value ---

AdjustSatValue:				;subtract Spektrum Satelite channel value offset (512) and adjust the input range

	cp xl, yh			;unused channel (value == zero)?
	cpc xh, yh
	brne asv1

	ret				;yes, return zero

asv1:	ldz 512				;X = X - 512
	sub xl, zl
	sbc xh, zh

AdjustSatValue2:

	b16store Temper
	b16ldi Temp, 2.93		;convert range [-341, 341] to [-1000, 1000] (throttle = [0, 1880])
	b16mul Temper, Temper, Temp
	b16load Temper
	ret



	;--- Scale AUX input values (divide by 10) ---

ScaleAuxInputValues:

	b16ldi Temp, 0.1
	b16mul RxAux2, RxAux2, Temp
	b16mul RxAux3, RxAux3, Temp
	ret



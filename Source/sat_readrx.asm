
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

	;Read, check and store data
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
	sts RxBufferState, tt

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

GetSatChannels:

	lds t, RxBufferState		;waiting for the very first data frame?
	tst t
	brpl sat10

	rjmp sat24			;yes, clear all input channels before leaving

sat10:	lds xl, RxBufferIndex		;data received since last iteration?
	lds xh, RxBufferIndexOld
	cp xl, xh
	breq sat12

	sts RxBufferIndexOld, xl	;yes. Will use old input values, but only if valid
	ldi t, 1
	sts RxBufferState, t
	rvbrflagfalse RxFrameValid, sat11

	rjmp sat31			;use old input values

sat11:	rjmp sat24			;clear all input channels before leaving

sat12:	cpi t, 2			;frame sync?
	breq sat13

	inc t				;no, use old input values, but only if valid
	sts RxBufferState, t
	rvbrflagfalse RxFrameValid, sat11

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
	rjmp sat24			;clear all input channels before leaving

sat14:	lds t, RxBuffer2		;check for protocol error (e.g. DSMX)
	andi t, 0x80
	breq sat1

	setstatusbit SatProtocolError
	rjmp sat31			;use old input values

sat1:	ser t				;the data frame appears to be valid
	sts RxFrameValid, t

	ldx RxBuffer2			;skip first 2 bytes
	ldi r17, 2			;using register R17 as Byte Index

sat3:	ldz SatChannel1L		;set SatChannel Array to 1st location
	ld yh, x+			;get MSB from the satelite array
	ld yl, x+			;get LSB from the satelite array

	mov t, yh			;the channel ID is used to store the channel value at the correct index in the Sat Channel array
	lsr t
	andi t, 0x0E			;mask Channel ID (multiplied by two and limited to 7 channels)
	inc t				;add one so we end up at SatChannelXH
	
	add zl, t			;adjust the Sat Channel array pointer to match the satelite channel ID
	brcc sat2

	inc zh

sat2:	andi yh, 0x03			;mask for D9 & D8
	st z, yh			;store and decrement pointer to reach SatChannelXL
	sbiw z, 1
	st z, yl			;store D0 to D7

	inc r17				;continue the loop until all 7 channel values have been copied
	inc r17
	cpi r17, 16
	brlt sat3

	;Set signal for "New frame"
	ldi t, 3
	sts RxBufferState, t



sat31:	;--- Roll ---

	ldi t, 1			;aileron has satelite channel ID 1
	rcall GetSatChannelValue
	rcall AdjustSatValue
	clr yh				;store RX value
	b16store RxRoll

	
	;--- Pitch

	ldi t, 2			;elevator has satelite channel ID 2
	rcall GetSatChannelValue
	rcall AdjustSatValue
	clr yh				;store RX value
	b16store RxPitch


	;--- Throttle ---

	ldi t, 0			;throttle has satelite channel ID 0
	rcall GetSatChannelValue

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

sat30:	clr yh				;store RX value
	b16store RxThrottle


	;--- Yaw ---

	ldi t, 3			;rudder has satelite channel ID 3
	rcall GetSatChannelValue
	rcall AdjustSatValue
	clr yh				;store in RX variable
	b16store RxYaw

	
	;--- AUX ---

	ldi t, 4			;aux has satelite channel ID 4
	rcall GetSatChannelValue
	rcall AdjustSatValue

	clr yl				;detect AUX switch position
	ldz -600
	cp  xl, zl
	cpc xh, zh
	brlt sat35			;AUX switch is in position #1

	inc yl
	ldz -200
	cp  xl, zl
	cpc xh, zh
	brlt sat35			;AUX switch is in position #2

	inc yl
	ldz 200
	cp  xl, zl
	cpc xh, zh
	brlt sat35			;AUX switch is in position #3

	inc yl
	ldz 600
	cp  xl, zl
	cpc xh, zh
	brlt sat35			;AUX switch is in position #4

	inc yl				;AUX switch is in position #5

sat35:	sts AuxSwitchPosition, yl
	clr yh				;store RX value
	b16store RxAux


	;--- AUX2 ---

	ldi t, 5			;aux2 has satelite channel ID 5
	rcall GetSatChannelValue
	rcall AdjustSatValue

	clr yh				;store RX value
	b16store RxAux2


	;--- AUX3 ---

	ldi t, 6			;aux3 has satelite channel ID 6
	rcall GetSatChannelValue
	rcall AdjustSatValue
	
	clr yh				;store RX value
	b16store RxAux3


	;--- Check RX ---

	rvbrflagfalse RxFrameValid, sat24
	rjmp sat22

sat23:	ret

sat22:	lds t, RxBufferState
	cpi t, SatRxTimeoutLimit
	brlo sat23

	ldi t, SatRxTimeoutLimit
	sts RxBufferState, t

	clr t				;select AUX switch function #1
	sts AuxSwitchPosition, t
	ser t				;make sure the AUX switch function will be updated
	sts AuxSwitchPositionOld, t

sat24:	rvsetflagfalse RxFrameValid	;yes, set flag to false and values to zero
	b16clr RxRoll
	b16set RxPitch
	b16set RxThrottle
	b16set RxYaw
	b16set RxAux
	b16set RxAux2
	b16set RxAux3
	rvsetflagtrue flagThrottleZero
	ret



	;----

GetSatChannelValue:

	mov r0, t
	ldzarray SatChannel1L, 2, r0
	ld xl, z+
	ld xh, z
	andi xh, 0x03			;limit value to 1023
	ret



	;--- Adjust satelite value ---

AdjustSatValue:				;subtract Spektrum Satelite channel value offset (512) and adjust the input range

	ldz 512				;X = X - 512
	sub xl, zl
	sbc xh, zh

AdjustSatValue2:

	b16store Temper
	b16ldi Temp, 2.93		;convert range [-341, 341] to [-1000, 1000] (throttle = [0, 1880])
	b16mul Temper, Temper, Temp
	b16load Temper
	ret



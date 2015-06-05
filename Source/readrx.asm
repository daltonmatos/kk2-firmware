
	//************************************************************
	//* Futaba S.Bus format (8-E-2/100Kbps)
	//*	S.Bus decoding algorithm borrowed in part from Arduino
	//*
	//* The protocol is 25 Bytes long and is sent every 14ms (analog mode) or 7ms (highspeed mode).
	//* One Byte = 1 startbit + 8 data bit + 1 parity bit + 2 stopbit (8E2), baudrate = 100,000 bit/s
	//*
	//* The highest bit is sent first. The logic is inverted.
	//*
	//* [startbyte] [data1] [data2] .... [data22] [flags][endbyte]
	//* 
	//* 0 startbyte = 11110000b (0xF0)
	//* 1-22 data = [ch1, 11bit][ch2, 11bit] .... [ch16, 11bit] (Values = 0 to 2047)
	//* 	channel 1 uses 8 bits from data1 and 3 bits from data2
	//* 	channel 2 uses last 5 bits from data2 and 6 bits from data3
	//* 	etc.
	//* 
	//* 23 flags = 
	//*	bit7 = ch17 = digital channel (0x80)
	//* 	bit6 = ch18 = digital channel (0x40)
	//* 	bit5 = Frame lost, equivalent red LED on receiver (0x20)
	//* 	bit4 = failsafe activated (0x10)
	//* 	bit3 = n/a
	//* 	bit2 = n/a
	//* 	bit1 = n/a
	//* 	bit0 = n/a
	//* 24 endbyte = 00000000b
	//*
	//************************************************************

IsrSBus:

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
	cpi tt, 25
	brlt sb20

	ldz RxBuffer0
	clr tt

sb20:	sts RxBufferIndex, tt

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

	lds xl, RxBufferIndex		;data received since last iteration?
	lds xh, RxBufferIndexOld
	cp xl, xh
	breq gsc1

	sts RxBufferIndexOld, xl	;yes. Will use old input values, but only if valid
	ldi t, 1
	sts RxBufferState, t
	rvbrflagfalse flagSBusFrameValid, gsc2

	rjmp gsc31			;use old input values

gsc2:	rjmp ClearInputChannels		;invalid

gsc1:	lds t, RxBufferState		;no additional data received. Frame sync?
	cpi t, 2
	breq gsc3

	inc t				;no, update status
	cpi t, 100
	brlo gsc15

	dec t				;prevent wrap-around

gsc15:	sts RxBufferState, t
	rvbrflagfalse flagSBusFrameValid, gsc2

	rjmp gsc31			;use old input values

gsc3:	lds xl, RxBufferIndex		;is the buffer full?
	tst xl
	breq gsc4

	clr t				;no, communication must be out of sync so we'll try to recover...
	sts RxBufferState, t
	sts RxBufferIndexOld, t
	cli
	sts RxBufferIndex, t
	sts RxBuffer0, t
	ldz RxBuffer0
	sts RxBufferAddressL, zl
	sts RxBufferAddressH, zh
	sei
	rjmp ClearInputChannels

gsc4:	ldz RxBuffer0			;yes, check start byte
	ld t, z
	cpi t, 0x0F			;OBSERVE! Bit order is reversed when read from the USART buffer
	breq gsc6

gsc5:	rjmp ClearInputChannels		;invalid value found

gsc6:	ldz RxBuffer24			;check end byte
	ld t, z
	tst t				;FASST
	breq gsc7

	ld t, z				;FASSTest (thanks to fnurgel)
	andi t, 0xCF
	cpi t, 0x04
	brne gsc5

gsc7:	;S.Bus frame appears to be valid
	ser t
	sts flagSBusFrameValid, t

	;S.Bus flags
	sbiw z, 1
	ld t, z
	sts SBusFlags, t

	;Data bytes
	ldz RxBuffer1
	ldx SBusByte0
	ldi yl, 10

gsc8:	ld t, z+
	st x+, t
	dec yl
	brpl gsc8

	;Set signal for "New frame"
	ldi t, 3
	sts RxBufferState, t

	clr t				;reset timeout counter
	sts TimeoutCounter, t


gsc31:	;--- Channel 1 ---

	;S.Bus channel 1 is 11 bit long and is stored in SBusByte0 and SBusByte1:
	;S.Bus data received:	76543210 -----A98
	;Variable name:		   xl	    xh

	lds xl, SBusByte0
	lds xh, SBusByte1

	andi xh, 0x07
	rcall AdjustSBusValue

	sts Channel1L, xl
	sts Channel1H, xh

	
	;--- Channel 2 ---

	;S.Bus channel 2 is 11 bit long and is stored in SBusByte1 and SBusByte2:
	;S.Bus data received:	43210--- --A98765
	;Variable name:		   xl	    xh

	lds xl, SBusByte1
	lds xh, SBusByte2

	ror xh
	ror xl
	ror xh
	ror xl
	ror xh
	ror xl
	andi xh, 0x07
	rcall AdjustSBusValue

	sts Channel2L, xl
	sts Channel2H, xh


	;--- Channel 3 ---

	;S.Bus channel 3 is 11 bit long and is stored in SBusByte2, SBusByte3 and SBusByte4:
	;S.Bus data received:	10------ 98765432 -------A
	;Variable name:		   yh	    xl	     xh

	lds yh, SBusByte2
	lds xl, SBusByte3
	lds xh, SBusByte4

	rol yh
	rol xl
	rol xh
	rol yh
	rol xl
	rol xh
	andi xh, 0x07

	sts Channel3L, xl
	sts Channel3H, xh


	;--- Channel 4 ---

	;S.Bus channel 4 is 11 bit long and is stored in SBusByte4 and SBusByte5:
	;S.Bus data received:	6543210- ----A987
	;Variable name:    	   xl       xh

	lds xl, SBusByte4
	lds xh, SBusByte5

	ror xh
	ror xl
	andi xh, 0x07
	rcall AdjustSBusValue

	sts Channel4L, xl
	sts Channel4H, xh


	;--- Channel 5 ---

	;S.Bus channel 5 is 11 bit long and is stored in SBusByte5 and SBusByte6:
	;S.Bus data received:	3210---- -A987654
	;Variable name:    	   xl       xh

	lds xl, SBusByte5
	lds xh, SBusByte6

	ror xh
	ror xl
	ror xh
	ror xl
	ror xh
	ror xl
	ror xh
	ror xl
	andi xh, 0x07
	rcall AdjustSBusValue

	sts Channel5L, xl
	sts Channel5H, xh


	;--- Channel 6 ---

	;S.Bus channel 6 is 11 bit long and is stored in SBusByte6, SBusByte7 and SBusByte8:
	;S.Bus data received:	0------- 87654321 ------A9
	;Variable name:    	   yh       xl       xh

	lds yh, SBusByte6
	lds xl, SBusByte7
	lds xh, SBusByte8

	rol yh
	rol xl
	rol xh
	andi xh, 0x07
	rcall AdjustSBusValue

	sts Channel6L, xl
	sts Channel6H, xh


	;--- Channel 7 ---

	;S.Bus channel 7 is 11 bit long and is stored in SBusByte8 and SBusByte9:
	;S.Bus data received:	543210-- ---A9876
	;Variable name:    	   xl       xh

	lds xl, SBusByte8
	lds xh, SBusByte9

	ror xh
	ror xl
	ror xh
	ror xl
	andi xh, 0x07
	rcall AdjustSBusValue

	sts Channel7L, xl
	sts Channel7H, xh


	;--- Channel 8 ---

	;S.Bus channel 8 is 11 bit long and is stored in SBusByte9 and SBusByte10:
	;S.Bus data received:	210----- A9876543
	;Variable name:    	   xl       xh

	lds xl, SBusByte9
	lds xh, SbusByte10

	ldi t, 5
gsc58:	lsr xh
	ror xl
	dec t
	brne gsc58

	rcall AdjustSBusValue

	sts Channel8L, xl
	sts Channel8H, xh


	;--- Roll ---

	lds r0, MappedChannel1		;get aileron channel value
	rcall GetChannelValue
	b16store RxRoll
	rcall IsChannelCentered
	sts flagAileronCentered, yl


	;--- Pitch ---

	lds r0, MappedChannel2		;get elevator channel value
	rcall GetChannelValue
	b16store RxPitch
	rcall IsChannelCentered
	sts flagElevatorCentered, yl


	;--- Throttle ---

	lds r0, MappedChannel3		;get throttle channel value
	rcall GetChannelValue

	rvsetflagfalse flagThrottleZero

	ldz 400				;X = X - 400
	sub xl, zl
	sbc xh, zh
	rcall Add50Percent		;X = X * 1.5

	ldz 0				;X < 0 ?
	cp  xl, zl
	cpc xh, zh
	brge gsc30

	ldx 0				;yes, set to zero
	rvsetflagtrue flagThrottleZero

gsc30:	b16store RxThrottle


	;--- Yaw ---

	lds r0, MappedChannel4		;get rudder channel value
	rcall GetChannelValue
	b16store RxYaw


	;--- AUX ---

	lds r0, MappedChannel5		;get aux channel value
	rcall GetChannelValue
	b16store RxAux

	clr yl				;AUX switch position #1
	ldz -625
	cp  xl, zl
	cpc xh, zh
	brlt gsc35

	inc yl				;AUX switch position #2
	ldz 625
	cp  xl, zl
	cpc xh, zh
	brlt gsc35

	inc yl				;AUX switch position #3

gsc35:	sts AuxSwitchPosition, yl


	;--- AUX2 ---

	lds r0, MappedChannel6		;get aux2 channel value
	rcall GetChannelValue
	b16store RxAux2


	;--- AUX3 ---

	lds r0, MappedChannel7		;get aux3 channel value
	rcall GetChannelValue
	b16store RxAux3


	;--- AUX4 ---

	lds r0, MappedChannel8		;get aux4 channel value
	rcall GetChannelValue
	b16store RxAux4

	clr yl				;AUX4 switch position #1
	ldz -400
	cp  xl, zl
	cpc xh, zh
	brlt gsc38

	inc yl				;AUX4 switch position #2
	ldz 400
	cp  xl, zl
	cpc xh, zh
	brlt gsc38

	inc yl				;AUX4 switch position #3

gsc38:	sts Aux4SwitchPosition, yl


	;--- Check RX ---

	lds t, TimeoutCounter		;timeout?
	inc t
	cpi t, SBusTimeoutLimit
	brsh ClearInputChannels

	sts TimeoutCounter, t		;not yet
	ret



	;---- Clear all input values ---

ClearInputChannels:

	rvbrflagfalse flagArmed, cic2

	lds t, StatusBits		;avoid setting the RxSignalLost bit when SBusFailsafe has already been set. See status message priority
	andi t, SBusFailsafe
	brne cic3

	setstatusbit RxSignalLost	;set status bit for "Signal Lost" and activate the Lost Model alarm only when armed

cic3:	rvsetflagtrue flagAlarmOverride

cic2:	rvsetflagfalse flagSbusFrameValid	;set flag to false and all RX input values to zero
	b16clr RxRoll
	b16set RxPitch
	b16set RxThrottle
	b16set RxYaw
	b16set RxAux
	b16set RxAux2
	b16set RxAux3
	b16set RxAux4
	rvsetflagtrue flagThrottleZero

	lds t, AuxSwitchPosition	;select AUX function #3 if not set already
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
	ret



	;---- Adapt S.Bus value to KK value ---

AdjustSBusValue:	;Subtract Futaba S.Bus offset (1024) and multiply by 1.5

	ldz 1024	;X = X - 1024
	sub xl, zl
	sbc xh, zh

Add50Percent:

	mov zl, xl	;Z = X / 2
	mov zh, xh
	asr zh
	ror zl

	add xl, zl	;X = X + Z
	adc xh, zh
	ret



	;--- Check if input channel is centered ---

IsChannelCentered:

	ldz 25
	cp xl, zl
	cpc xh, zh
	brge icc1

	ldz -25
	cp xl, zl
	cpc xh, zh
	brlt icc1

	ser yl		;centered
	ret

icc1:	clr yl		;not centered
	ret



	;--- Scale AUX input values (divide by 10) ---

ScaleAuxInputValues:

	b16ldi Temp, 0.1
	b16mul RxAux2, RxAux2, Temp
	b16mul RxAux3, RxAux3, Temp
	ret




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


	;--- Read all input channel values ---

GetSBusChannels:

	rvsetflagfalse flagNewRxFrame

	;check buffer
	clr xl

	cli
	lds xh, flagRxBufferFull
	sts flagRxBufferFull, xl
	lds kl, RxBufferAddressL
	lds kh, RxBufferAddressH
	sei

	tst xh					;buffer full?
	brne gsc1

	rvbrflagfalse flagRxFrameValid, gsc2	;no. Will use old input values, but only if valid

	rjmp gsc31				;use old input values

gsc1:	ldz RxBuffer0				;buffer is full. Is the communication synchronized?
	cp kl, zl
	cpc kh, zh
	brne gsc3

	ld t, z					;check start byte
	cpi t, 0x0F
	brne gsc3

	ldz RxBuffer24				;check end byte
	ld t, z
	tst t					;FASST
	breq gsc7

	ld t, z					;FASSTest (thanks to fnurgel)
	andi t, 0xCF
	cpi t, 0x04
	breq gsc7

gsc3:	clr t					;communication must be out of sync so we'll try to recover...

	cli
	sts RxBuffer0, t
	ldz RxBuffer0
	sts RxBufferAddressL, zl
	sts RxBufferAddressH, zh
	sei

	rjmp gsc31				;use old input values

gsc2:	rjmp ClearInputChannels

gsc7:	;S.Bus frame appears to be valid
	rvsetflagtrue flagRxFrameValid

	;S.Bus flags
	sbiw z, 1
	ld t, z
	sts SBusFlags, t

	;signal for "New frame"
	rvsetflagtrue flagNewRxFrame

	clr t					;reset timeout counter
	sts TimeoutCounter, t


	;--- Channel 1 ---

	;S.Bus channel 1 is 11 bit long and is stored in RxBuffer1 and RxBuffer2:
	;S.Bus data received:	76543210 -----A98
	;Variable name:		   xl	    xh

	lds xl, RxBuffer1
	lds xh, RxBuffer2

	andi xh, 0x07

	sts Channel1L, xl
	sts Channel1H, xh

	
	;--- Channel 2 ---

	;S.Bus channel 2 is 11 bit long and is stored in RxBuffer2 and RxBuffer3:
	;S.Bus data received:	43210--- --A98765
	;Variable name:		   xl	    xh

	lds xl, RxBuffer2
	lds xh, RxBuffer3

	ror xh
	ror xl
	ror xh
	ror xl
	ror xh
	ror xl
	andi xh, 0x07

	sts Channel2L, xl
	sts Channel2H, xh


	;--- Channel 3 ---

	;S.Bus channel 3 is 11 bit long and is stored in RxBuffer3, RxBuffer4 and RxBuffer5:
	;S.Bus data received:	10------ 98765432 -------A
	;Variable name:		   yh	    xl	     xh

	lds yh, RxBuffer3
	lds xl, RxBuffer4
	lds xh, RxBuffer5

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

	;S.Bus channel 4 is 11 bit long and is stored in RxBuffer5 and RxBuffer6:
	;S.Bus data received:	6543210- ----A987
	;Variable name:    	   xl       xh

	lds xl, RxBuffer5
	lds xh, RxBuffer6

	ror xh
	ror xl
	andi xh, 0x07

	sts Channel4L, xl
	sts Channel4H, xh


	;--- Channel 5 ---

	;S.Bus channel 5 is 11 bit long and is stored in RxBuffer6 and RxBuffer7:
	;S.Bus data received:	3210---- -A987654
	;Variable name:    	   xl       xh

	lds xl, RxBuffer6
	lds xh, RxBuffer7

	ror xh
	ror xl
	ror xh
	ror xl
	ror xh
	ror xl
	ror xh
	ror xl
	andi xh, 0x07

	sts Channel5L, xl
	sts Channel5H, xh


	;--- Channel 6 ---

	;S.Bus channel 6 is 11 bit long and is stored in RxBuffer7, RxBuffer8 and RxBuffer9:
	;S.Bus data received:	0------- 87654321 ------A9
	;Variable name:    	   yh       xl       xh

	lds yh, RxBuffer7
	lds xl, RxBuffer8
	lds xh, RxBuffer9

	rol yh
	rol xl
	rol xh
	andi xh, 0x07

	sts Channel6L, xl
	sts Channel6H, xh


	;--- Channel 7 ---

	;S.Bus channel 7 is 11 bit long and is stored in RxBuffer9 and RxBuffer10:
	;S.Bus data received:	543210-- ---A9876
	;Variable name:    	   xl       xh

	lds xl, RxBuffer9
	lds xh, RxBuffer10

	ror xh
	ror xl
	ror xh
	ror xl
	andi xh, 0x07

	sts Channel7L, xl
	sts Channel7H, xh


	;--- Channel 8 ---

	;S.Bus channel 8 is 11 bit long and is stored in RxBuffer10 and RxBuffer11:
	;S.Bus data received:	210----- A9876543
	;Variable name:    	   xl       xh

	lds xl, RxBuffer10
	lds xh, RxBuffer11

	lsr xh
	ror xl
	swap xl
	swap xh
	mov t, xh
	andi t, 0xF0
	andi xl, 0x0F
	or xl, t
	andi xh, 0x07

;	ldi t, 5
;gsc58:	lsr xh
;	ror xl
;	dec t
;	brne gsc58

	sts Channel8L, xl
	sts Channel8H, xh


	;--- Roll ---

gsc31:	lds r0, MappedChannel1
	rcall GetChannelValue
	rcall AdjustSBusValue
	call DeadZone
	b16store RxRoll
	call IsChannelCentered
	sts flagAileronCentered, yl


	;--- Pitch ---

	lds r0, MappedChannel2
	rcall GetChannelValue
	rcall AdjustSBusValue
	call DeadZone
	b16store RxPitch
	call IsChannelCentered
	sts flagElevatorCentered, yl


	;--- Throttle ---

	lds r0, MappedChannel3
	rcall GetChannelValue

	rvsetflagfalse flagThrottleZero

	ldz 400					;X = X - 400
	sub xl, zl
	sbc xh, zh
	rcall Add50Percent			;X = X * 1.5

	ldz 0					;X < 0 ?
	cp  xl, zl
	cpc xh, zh
	brge gsc30

	ldx 0					;yes, set to zero
	rvsetflagtrue flagThrottleZero

gsc30:	b16store RxThrottle


	;--- Yaw ---

	lds r0, MappedChannel4
	rcall GetChannelValue
	rcall AdjustSBusValue
	call DeadZone
	b16store RxYaw


	;--- AUX ---

	lds r0, MappedChannel5
	rcall GetChannelValue
	rcall AdjustSBusValue
	b16store RxAux

	clr yl					;position #1
	ldz -600
	cp  xl, zl
	cpc xh, zh
	brlt gsc35

	inc yl					;position #2
	ldz -200
	cp  xl, zl
	cpc xh, zh
	brlt gsc35

	inc yl					;position #3
	ldz 200
	cp  xl, zl
	cpc xh, zh
	brlt gsc35

	inc yl					;position #4
	ldz 600
	cp  xl, zl
	cpc xh, zh
	brlt gsc35

	inc yl					;position #5

gsc35:	sts AuxSwitchPosition, yl


	;--- AUX2 ---

	lds r0, MappedChannel6
	rcall GetChannelValue
	rcall AdjustSBusValue
	b16store RxAux2


	;--- AUX3 ---

	lds r0, MappedChannel7
	rcall GetChannelValue
	rcall AdjustSBusValue
	b16store RxAux3


	;--- AUX4 ---

	lds r0, MappedChannel8
	rcall GetChannelValue
	rcall AdjustSBusValue
	b16store RxAux4

	clr yl					;position #1
	ldz -400
	cp  xl, zl
	cpc xh, zh
	brlt gsc38

	inc yl					;position #2
	ldz 400
	cp  xl, zl
	cpc xh, zh
	brlt gsc38

	inc yl					;position #3

gsc38:	sts Aux4SwitchPosition, yl


	;--- Check RX ---

	rvbrflagfalse flagRxFrameValid, ClearInputChannels
	rjmp gsc22

gsc23:	sts TimeoutCounter, t
	ret

gsc22:	lds t, TimeoutCounter			;timeout?
	inc t
	cpi t, TimeoutLimit
	brlo gsc23

	rvbrflagfalse flagArmed, ClearInputChannels	;yes

	setstatusbit RxSignalLost		;set status bit for "Signal Lost" and activate the Lost Model alarm only when armed
	rvsetflagtrue flagAlarmOverride



	;---- Clear all input values ---

ClearInputChannels:

	rvsetflagfalse flagRxFrameValid		;set flag to false and all RX input values to zero
	b16clr RxRoll
	b16set RxPitch
	b16set RxThrottle
	b16set RxYaw
	b16set RxAux
	b16set RxAux2
	b16set RxAux3
	b16set RxAux4
	rvsetflagtrue flagThrottleZero

	lds t, AuxSwitchPosition		;select AUX function #3 if not set already
	cpi t, 2
	breq cic1

	ldi t, 2
	sts AuxSwitchPosition, t
	ser t					;make sure the AUX switch function will be updated
	sts AuxSwitchPositionOld, t

cic1:	rvbrflagfalse flagArmed, cic2		;log error when armed

	ldi xl, ErrorSignalLost
	call LogError

cic2:	ret



	;--- Get channel value ---

GetChannelValue:

	ldzarray Channel1L, 2, r0		;register R0 (input parameter) holds the mapped channel ID
	ld xl, z+
	ld xh, z
	clr yh
	ret



	;---- Adapt S.Bus value to KK value ---

AdjustSBusValue:				;subtract Futaba S.Bus offset (1024) and multiply by 1.5

	ldz 1024				;X = X - 1024
	sub xl, zl
	sbc xh, zh

Add50Percent:

	mov zl, xl				;Z = X / 2
	mov zh, xh
	asr zh
	ror zl

	add xl, zl				;X = X + Z
	adc xh, zh
	ret


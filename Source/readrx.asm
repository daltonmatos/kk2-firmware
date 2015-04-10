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

gsc2:	rcall ClearInputChannels	;invalid
	ret

gsc1:	lds t, RxBufferState		;no additional data received. Frame sync?
	cpi t, 2
	breq gsc3

	inc t				;no, use old input values, but only if valid
	sts RxBufferState, t
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
	ldz RxBuffer0
	sts RxBufferAddressL, zl
	sts RxBufferAddressH, zh
	sei
	rjmp gsc2

gsc4:	ldz RxBuffer0			;yes, check start byte
	ld t, z
	cpi t, 0x0F			;OBSERVE! Bit order is reversed when read from the USART buffer
	breq gsc6

gsc5:	clr t				;invalid value found
	sts flagSBusFrameValid, t
	rjmp gsc2

gsc6:	ldz RxBuffer24			;check end byte
	ld t, z
	tst t				;FASST
	breq gsc7

	ld t, z				;FASSTest
	andi t, 0xCF
	cpi t, 0x04
	brne gsc5

gsc7:	;S.Bus frame is valid
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



gsc31:	;--- Roll ---

	;S.Bus channel 1 is 11 bit long and is stored in SBusByte0 and SBusByte1:
	;S.Bus data received:	76543210 -----A98
	;Variable name:		   xl	    xh

	lds xl, SBusByte0
	lds xh, SBusByte1

	andi xh, 0x07
	rcall AdjustSBusValue

	clr yh				;store in register
	b16store RxRoll


	
	;--- Pitch ---

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

	clr yh				;store in register
	b16store RxPitch



	;--- Throttle ---

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

gsc30:	clr yh				;store in register
	b16store RxThrottle



	;--- Yaw ---

	;S.Bus channel 4 is 11 bit long and is stored in SBusByte4 and SBusByte5:
	;S.Bus data received:	6543210- ----A987
	;Variable name:    	   xl       xh

	lds xl, SBusByte4
	lds xh, SBusByte5

	ror xh
	ror xl
	andi xh, 0x07
	rcall AdjustSBusValue

	clr yh				;store in register
	b16store RxYaw



	;--- AUX ---

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

	clr yl				;detect AUX switch position
	ldz -625
	cp  xl, zl
	cpc xh, zh
	brlt gsc35			;AUX switch is in position #1

	inc yl
	ldz 625
	cp  xl, zl
	cpc xh, zh
	brlt gsc35			;AUX switch is in position #2

	inc yl				;AUX switch is in position #3

gsc35:	sts AuxSwitchPosition, yl

	clr yh				;store in register
	b16store RxAux



	;--- AUX2 ---

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

	clr yh				;store in register
	b16store RxAux2



	;--- AUX3 ---

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

	clr yh				;store in register
	b16store RxAux3



	;--- AUX4 ---

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

	clr yl				;detect AUX4 switch position
	ldz -400
	cp  xl, zl
	cpc xh, zh
	brlt gsc38			;AUX4 switch is in position #1

	inc yl
	ldz 400
	cp  xl, zl
	cpc xh, zh
	brlt gsc38			;AUX4 switch is in position #2

	inc yl				;AUX4 switch is in position #3

gsc38:	sts Aux4SwitchPosition, yl

	clr yh				;store in register
	b16store RxAux4



	;---

	ret



	;---- Clear all input values ---

ClearInputChannels:

	b16clr RxRoll
	b16set RxPitch
	b16set RxThrottle
	b16set RxYaw
	b16set RxAux
	b16set RxAux2
	b16set RxAux3
	b16set RxAux4
	rvsetflagtrue flagThrottleZero

	lds t, AuxSwitchPosition	;select AUX function #1. PS! Setting this value multiple times will cause Alarm problems (AuxBeepDelay)
	tst t
	breq cic1

	clr t
	sts AuxSwitchPosition, t
	ser t				;make sure the AUX switch function will be updated
	sts AuxSwitchPositionOld, t

cic1:	ret



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



	;--- Scale AUX input values (divide by 10) ---

ScaleAuxInputValues:

	b16ldi Temp, 0.1
	b16mul RxAux2, RxAux2, Temp
	b16mul RxAux3, RxAux3, Temp
	ret




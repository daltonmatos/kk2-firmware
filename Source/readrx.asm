


	;--- CPPM ISR ---

IsrCppm:

	in SregSaver, sreg

	sbic pind,3			;rising or falling?
	rjmp cppm7

	out sreg, SregSaver		;falling, exit
	reti

cppm7:	push xl				;rising, calculate pulse length:
	push xh
	push zl
	push zh

	lds xl, tcnt1l			;X = TCNT1 - CppmPulseStart, CppmPulseStart = TCNT1
	lds xh, tcnt1h
	lds zl, CppmPulseStartL
	lds zh, CppmPulseStartH
	sts CppmPulseStartL, xl
	sts CppmPulseStartH, xh
	sub xl, zl
	sbc xh, zh
	brpl cppm8

	ldz 0				;X = ABS(X)
	sub zl, xl
	sbc zh, xh
	movw x, z

cppm8:	ldz 6250			;pulse longer than 2.5ms?
	cp  xl, zl
	cpc xh, zh
	brlo cppm9

	ldz Channel1L			;yes, reset cppm sequence

	lds tt, CppmChannelCount	;CPPM pulse train is considered valid when minimum 4 channels have been detected
	clr treg
	sts CppmChannelCount, treg
	cpi tt, 4
	brge cppm6

	rjmp cppm10			;invalid CPPM frame

cppm6:	ser tt				;set flag to indicate that a valid CPPM pulse train has been received
	sts flagCppmValid, tt

	sts CppmTimeoutCounter, treg	;reset timeout counter
	rjmp cppm10

cppm9:	lds tt, CppmChannelCount	;count channels
	inc tt
	sts CppmChannelCount, tt

cppm11:	lds zl, CppmPulseArrayAddressL	;store channel in channel array.
	lds zh, CppmPulseArrayAddressH

	st z+, xl
	st z+, xh

	ldx Channel9L			;end of array reached?
	cp  zl, xl
	cpc zh, xh
	brlo cppm10
	breq cppm10

	ldz Channel9L			;yes, limit

cppm10:	sts CppmPulseArrayAddressL, zl	;store array pointer
	sts CppmPulseArrayAddressH, zh

	pop zh
	pop zl
	pop xh
	pop xl

	out sreg, SregSaver		;exit	
	reti



	;--- Read all input channel values ---

GetRxChannels:

	;--- Roll ---

	lds r0, MappedChannel1		;get roll channel value
	rcall GetSafeChannelValue
	rcall Sanitize

	clr yh				;store in register
	b16store RxRoll

	
	;--- Pitch ---

	lds r0, MappedChannel2		;get pitch channel value
	rcall GetSafeChannelValue
	rcall Sanitize

	clr yh				;store in register
	b16store RxPitch


	;--- Throttle ---

	lds r0, MappedChannel3		;get throttle channel value
	rcall GetSafeChannelValue

	rvsetflagfalse flagThrottleZero

	rcall Xabs			;X = ABS(X)

	ldz 2875			;X = X - 2875 (1.15ms)
	sub xl, zl
	sbc xh, zh

	ldz 0				;X < 0 ?
	cp  xl, zl
	cpc xh, zh
	brge gcc8

	rjmp gcc30			;yes, set to zero

gcc8:	ldz 3125			;X > 3125? (1.25ms)
	cp  xl, zl
	cpc xh, zh
	brlt gcc2

gcc30:	ldx 0				;yes, set to zero
	rvsetflagtrue flagThrottleZero

gcc2:	clr yh				;store in register
	b16store RxThrottle


	;--- Yaw ---

	lds r0, MappedChannel4		;get yaw channel value
	rcall GetSafeChannelValue
	rcall Sanitize
	clr yh				;store in register
	b16store RxYaw

	
	;--- AUX ---

	lds r0, MappedChannel5		;get aux channel value
	rcall GetSafeChannelValue
	rcall Sanitize

	clr yl				;AUX switch position #1
	ldz -600
	cp  xl, zl
	cpc xh, zh
	brlt gcc35

	inc yl				;AUX switch position #2
	ldz -200
	cp  xl, zl
	cpc xh, zh
	brlt gcc35

	inc yl				;AUX switch position #3
	ldz 200
	cp  xl, zl
	cpc xh, zh
	brlt gcc35

	inc yl				;AUX switch position #4
	ldz 600
	cp  xl, zl
	cpc xh, zh
	brlt gcc35

	inc yl				;AUX switch position #5

gcc35:	sts AuxSwitchPosition, yl

	clr yh				;store in register
	b16store RxAux


	;--- AUX2 ---

	lds r0, MappedChannel6		;get aux2 channel value
	rcall GetSafeChannelValue
	rcall Sanitize

	clr yh				;store in register
	b16store RxAux2


	;--- AUX3 ---

	lds r0, MappedChannel7		;get aux3 channel value
	rcall GetSafeChannelValue
	rcall Sanitize

	clr yh				;store in register
	b16store RxAux3


	;--- AUX4 ---

	lds r0, MappedChannel8		;get aux4 channel value
	rcall GetSafeChannelValue
	rcall Sanitize

	clr yl				;AUX4 switch position #1
	ldz -400
	cp  xl, zl
	cpc xh, zh
	brlt gcc38

	inc yl				;AUX4 switch position #2
	ldz 400
	cp  xl, zl
	cpc xh, zh
	brlt gcc38

	inc yl				;AUX4 switch position #3

gcc38:	sts Aux4SwitchPosition, yl

	clr yh				;store in register
	b16store RxAux4


	;--- Check RX ---

	rvbrflagfalse flagCppmValid, ClearInputChannels
	rjmp gcc22

gcc23:	sts CppmTimeoutCounter, t
	ret

gcc22:	lds t, CppmTimeoutCounter	;timeout?
	inc t
	lds xl, RxTimeoutLimit
	cp t, xl
	brlo gcc23

	rvbrflagfalse flagArmed, ClearInputChannels	;yes

	setstatusbit RxSignalLost	;set status bit for "Signal Lost" and activate the Lost Model alarm only when armed
	rvsetflagtrue flagAlarmOverride



	;---- Clear all input values ---

ClearInputChannels:

	rvsetflagfalse flagCppmValid	;set flag to false and all RX input values to zero
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




	;--- Get channel value (blocking interrupts) ---

GetSafeChannelValue:

	mov xl, r0			;check channel mapping
	andi xl, 0xF8
	breq gcv1

	clr xh				;invalid channel mapping. Return zero
	clr xl
	clr yh
	ret

gcv1:	ldzarray Channel1L, 2, r0	;register R0 (input parameter) holds the mapped channel ID
	cli
	ld xl, z+
	ld xh, z
	sei

	ret



	;--- Sanitize RX input ---

Sanitize:

	rcall Xabs	;X = ABS(X)

	ldz 3750	;X = X - 3750 (1.5ms)
	sub xl, zl
	sbc xh, zh

	ldz -1750	;X < -1750?  (0.7ms)
	cp  xl, zl
	cpc xh, zh
	brlt gt1m2

	ldz 1750	;X > 1750?
	cp  xl, zl
	cpc xh, zh
	brge gt1m2

	ret		;No, exit

gt1m2:	ldx 0		;Yes, set to zero
	ret





Xabs:

	tst xh		;X = ABS(X)
	brpl xa1

	com xl
	com xh
	
	ldi t, 1
	add xl, t
	clr t
	adc xh, t

xa1:	ret



	;--- Scale AUX inputs (divide by 10) ---

ScaleAuxInputValues:

	b16ldi Temp, 0.1
	b16mul RxAux2, RxAux2, Temp
	b16mul RxAux3, RxAux3, Temp
	ret




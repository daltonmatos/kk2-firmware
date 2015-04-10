


	;--- CPPM ISR ---

IsrCppm:

;	in SregSaver, sreg		;see isr.asm

	push xl
	push xh
	push zl
	push zh

	lds xl, tcnt1l			;calculate pulse length: X = TCNT1 - CppmPulseStart, CppmPulseStart = TCNT1
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
	brlo cppm11

	ldz CppmChannel1L		;yes, reset cppm sequence

	lds tt, CppmDetectionCounter	;detect CPPM pulse train after start-up or after a timeout
	dec tt
	brmi cppm6

	sts CppmDetectionCounter, tt
	rjmp cppm10

cppm6:	ser tt				;set flag to indicate that a valid CPPM pulse train has been received
	sts RxFrameValid, tt
	rjmp cppm10

cppm11:	lds zl, CppmPulseArrayAddressL	;store channel in channel array.
	lds zh, CppmPulseArrayAddressH

	st z+, xl
	st z+, xh

	ldx CppmChannel9L		;end of array reached?
	cp  zl, xl
	cpc zh, xh
	brlo cppm10
	breq cppm10

	ldz CppmChannel9L		;yes, limit

cppm10:	sts CppmPulseArrayAddressL, zl	;store array pointer
	sts CppmPulseArrayAddressH, zh

	clr tt				;reset timeout counter
	sts CppmTimeoutCounter, tt

	pop zh
	pop zl
	pop xh
	pop xl

	out sreg, SregSaver		;exit	
	reti



	;--- Read all input channel values ---

GetCppmChannels:

	;--- Roll ---

	ldz eeCppmRoll
	rcall GetCppmChannel
	call Sanitize
	clr yh				;store in register
	b16store RxRoll

	
	;--- Pitch ---

	ldz eeCppmPitch
	rcall GetCppmChannel
	call Sanitize
	clr yh				;store in register
	b16store RxPitch


	;--- Throttle ---

	ldz eeCppmThrottle
	rcall GetCppmChannel

	rvsetflagfalse flagThrottleZero

	call Xabs			;X = ABS(X)

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

	ldz eeCppmYaw
	rcall GetCppmChannel
	call Sanitize
	clr yh				;store in register
	b16store RxYaw

	
	;--- AUX ---

	ldz eeCppmAux
	rcall GetCppmChannel
	call Sanitize

	clr yl				;detect AUX switch position
	ldz -600
	cp  xl, zl
	cpc xh, zh
	brlt gcc35			;AUX switch is in position #1

	inc yl
	ldz -200
	cp  xl, zl
	cpc xh, zh
	brlt gcc35			;AUX switch is in position #2

	inc yl
	ldz 200
	cp  xl, zl
	cpc xh, zh
	brlt gcc35			;AUX switch is in position #3

	inc yl
	ldz 600
	cp  xl, zl
	cpc xh, zh
	brlt gcc35			;AUX switch is in position #4

	inc yl				;AUX switch is in position #5

gcc35:	sts AuxSwitchPosition, yl

	clr yh				;store in register
	b16store RxAux


	;--- AUX2 ---

	ldz CppmChannel6L
	cli
	ld xl, z+
	ld xh, z
	sei
	call Sanitize

	clr yh				;store in register
	b16store RxAux2


	;--- AUX3 ---

	ldz CppmChannel7L
	cli
	ld xl, z+
	ld xh, z
	sei
	call Sanitize

	clr yh				;store in register
	b16store RxAux3


	;--- AUX4 ---

	ldz CppmChannel8L
	cli
	ld xl, z+
	ld xh, z
	sei
	call Sanitize

	clr yl				;detect AUX4 switch position
	ldz -400
	cp  xl, zl
	cpc xh, zh
	brlt gcc38			;AUX4 switch is in position #1

	inc yl
	ldz 400
	cp  xl, zl
	cpc xh, zh
	brlt gcc38			;AUX4 switch is in position #2

	inc yl				;AUX4 switch is in position #3

gcc38:	sts Aux4SwitchPosition, yl

	clr yh				;store in register
	b16store RxAux4


	;--- Check RX ---

	rvbrflagfalse RxFrameValid, gcc24
	rjmp gcc22

gcc23:	ret

gcc22:	rvinc CppmTimeoutCounter	;CPPM timeout?
	rvcp CppmTimeoutCounter, CppmTimeoutLimit
	brlo gcc23

	lrv CppmDetectionCounter, CppmDetectionCount

	clr t				;select AUX switch function #1
	sts AuxSwitchPosition, t
	ser t				;make sure the AUX switch function will be updated
	sts AuxSwitchPositionOld, t

gcc24:	rvsetflagfalse RxFrameValid	;set flag to false and values to zero
	b16clr RxRoll
	b16set RxPitch
	b16set RxThrottle
	b16set RxYaw
	b16set RxAux
	b16set RxAux2
	b16set RxAux3
	b16set RxAux4
	rvsetflagtrue flagThrottleZero
	ret



	;---

GetCppmChannel:

	call ReadEepromP
	dec t
	mov r0, t
	ldzarray CppmChannel1L, 2, r0
	cli
	ld xl, z+
	ld xh, z
	sei

	ret



	;--- Scale AUX inputs (divide by 10) ---

ScaleAuxInputValues:

	b16ldi Temp, 0.1
	b16mul RxAux2, RxAux2, Temp
	b16mul RxAux3, RxAux3, Temp
	ret








IsrRollCppm:

	in SregSaver, sreg
	lds tt, RxMode
	cpi tt, RxModeCppm
	breq isr2

	rjmp IsrRoll

isr2:	jmp IsrCppm



IsrRoll:

	sbis pind,3			;rising or falling?
	rjmp rx1

	lds tt, tcnt1l			;rising, store the start value
	sts RollStartL, tt
	lds tt, tcnt1h
	sts RollStartH, tt
	
	clr tt
	sts RollDcnt, tt

	out sreg, SregSaver		;exit	
	reti

rx1:	lds tt, tcnt1l			;falling, calculate the pulse length
	lds treg, RollStartL
	sub tt, treg
	sts RollL, tt

	lds tt, tcnt1h
	lds treg, RollStartH
	sbc tt, treg
	sts RollH, tt

	out sreg, SregSaver		;exit	
	reti



IsrPitch:

	in SregSaver, sreg

	sbis pind,2			;rising or falling?
	rjmp rx2

	lds tt, tcnt1l			;rising, store the start value
	sts PitchStartL, tt
	lds tt, tcnt1h
	sts PitchStartH, tt

	clr tt
	sts PitchDcnt, tt
	
	out sreg, SregSaver		;exit	
	reti

rx2:	lds tt, tcnt1l			;falling, calculate the pulse length
	lds treg, PitchStartL
	sub tt, treg
	sts PitchL, tt

	lds tt, tcnt1h
	lds treg, PitchStartH
	sbc tt, treg
	sts PitchH, tt

	out sreg, SregSaver		;exit	
	reti



IsrThrottle:

	in SregSaver, sreg

	sbis pind,0			;rising or falling?
	rjmp rx3

	lds tt, tcnt1l			;rising, store the start value
	sts ThrottleStartL, tt
	lds tt, tcnt1h
	sts ThrottleStartH, tt
	
	clr tt
	sts ThrottleDcnt, tt

	out sreg, SregSaver		;exit	
	reti

rx3:	lds tt, tcnt1l			;falling, calculate the pulse length
	lds treg, ThrottleStartL
	sub tt, treg
	sts ThrottleL, tt

	lds tt, tcnt1h
	lds treg, ThrottleStartH
	sbc tt, treg
	sts ThrottleH, tt

	out sreg, SregSaver		;exit	
	reti



	;--- Common interrupt routine section for yaw and aux input ---

IsrYawAux:

	in SregSaver, sreg

	push xl				;save the current time stamp
	push xh
	lds xl, tcnt1l
	lds xh, tcnt1h

	rcall IsrYaw
	rcall IsrAux

	pop xh				;exit
	pop xl
	out sreg, SregSaver
	reti



	;--- Rudder ISR ---

IsrYaw:

	in tt, pinb			;check for pin state change
	andi tt, 0x04
	lds treg, RudderRxPinState
	sts RudderRxPinState, tt
	cp tt, treg
	brne iyaw1

	ret

iyaw1:	sbis pinb, 2			;rising or falling?
	rjmp iyaw2

	sts YawStartL, xl		;rising, store the start value
	sts YawStartH, xh

	clr tt				;clear timeout counter
	sts YawDcnt, tt

	lds tt, StatusBits		;clear status flag
	cbr tt, NoRudderInput
	sts StatusBits, tt
	ret

iyaw2:	mov tt, xl			;falling, calculate the pulse length
	lds treg, YawStartL
	sub tt, treg
	sts YawL, tt

	mov tt, xh
	lds treg, YawStartH
	sbc tt, treg
	sts YawH, tt
	ret



	;--- Aux ISR ---

IsrAux:

	in tt, pinb			;check for pin state change
	andi tt, 0x01
	lds treg, AuxRxPinState
	sts AuxRxPinState, tt
	cp tt, treg
	brne iaux1

	ret

iaux1:	sbis pinb, 0			;rising or falling?
	rjmp iaux2

	sts AuxStartL, xl		;rising, store the start value
	sts AuxStartH, xh

	clr tt				;clear timeout counter
	sts AuxDcnt, tt
	ret

iaux2:	mov tt, xl			;falling, calculate the pulse length
	lds treg, AuxStartL
	sub tt, treg
	sts AuxL, tt

	mov tt, xh
	lds treg, AuxStartH
	sbc tt, treg
	sts AuxH, tt
	ret



	;--- Jump to the correct RX routine based on selected RX mode ---

GetRxChannels:				;OBSERVE: This routine should only be called from GUI code!

	lds t, RxMode
	cpi t, RxModeStandard
	brne grx1

	rjmp GetStdRxChannels

grx1:	cpi t, RxModeCppm
	brne grx2

	jmp GetCppmChannels

grx2:	cpi t, RxModeSBus
	brne grx3

	jmp GetSBusChannels

grx3:	jmp GetSatChannels



	;--- Retrieve channel values for standard RX ---


GetStdRxChannels:

	;--- Roll ---

	cli				;get roll channel value
	lds xl, RollL
	lds xh, RollH
	sei

	rcall Sanitize			;sanitize
	clr yh				;store in register
	b16store RxRoll

	
	;--- Pitch

	cli				;get Pitch channel value
	lds xl, PitchL
	lds xh, PitchH
	sei

	rcall Sanitize			;sanitize
	clr yh				;store in register
	b16store RxPitch


	;--- Throttle ---

	cli				;get Throttle channel value
	lds xl, ThrottleL
	lds xh, ThrottleH
	sei

	rvsetflagfalse flagThrottleZero

	rcall Xabs			;X = ABS(X)

	ldz 2875			;X = X - 2875 (1.15ms)
	sub xl, zl
	sbc xh, zh

	ldz 0				;X < 0 ?
	cp  xl, zl
	cpc xh, zh
	brge gt8m8

	rjmp rx30			;yes, set to zero

gt8m8:	ldz 3125			;X > 3125? (1.25ms)
	cp  xl, zl
	cpc xh, zh
	brlt gt7m2

rx30:	ldx 0				;Yes, set to zero
	rvsetflagtrue flagThrottleZero

gt7m2:	clr yh				;store in register
	b16store RxThrottle


	;--- Yaw ---

	cli				;get Yaw channel value
	lds xl, YawL
	lds xh, YawH
	sei

	rcall Sanitize			;sanitize

	clr yh				;store in register
	b16store RxYaw

	
	;--- AUX ---

	cli				;get Aux channel value
	lds xl, AuxL
	lds xh, AuxH
	sei

	rcall Sanitize			;sanitize

	clr yl				;detect AUX switch position
	ldz -600
	cp  xl, zl
	cpc xh, zh
	brlt rx35			;AUX switch is in position #1

	inc yl
	ldz -200
	cp  xl, zl
	cpc xh, zh
	brlt rx35			;AUX switch is in position #2

	inc yl
	ldz 200
	cp  xl, zl
	cpc xh, zh
	brlt rx35			;AUX switch is in position #3

	inc yl
	ldz 600
	cp  xl, zl
	cpc xh, zh
	brlt rx35			;AUX switch is in position #4

	inc yl				;AUX switch is in position #5

rx35:	rvbrflagfalse flagAuxValid, rx24;won't update aux switch position while the input is invalid

	sts AuxSwitchPosition, yl
	clr yh				;store in register
	b16store RxAux



rx24:	;--- Check RX ---

	ser t
	sts flagRollValid, t
	sts flagPitchValid, t
	sts flagThrottleValid, t
	sts flagYawValid, t
	sts flagAuxValid, t

	rvinc RollDcnt				;aileron signal timed out?
	rvcp RollDcnt, RxTimeoutLimit
	brlo rx25

	rvdec RollDcnt				;yes, cut throttle
	rvsetflagfalse flagRollValid
	b16clr RxThrottle
	rvsetflagtrue flagThrottleZero

rx25:	rvinc PitchDcnt				;elevator signal timed out?
	rvcp PitchDcnt, RxTimeoutLimit
	brlo rx26

	rvdec PitchDcnt				;yes, cut throttle
	rvsetflagfalse flagPitchValid
	b16clr RxThrottle
	rvsetflagtrue flagThrottleZero

rx26:	rvinc ThrottleDcnt			;throttle signal timed out?
	rvcp ThrottleDcnt, RxTimeoutLimit
	brlo rx27

	rvdec ThrottleDcnt			;yes, cut throttle
	rvsetflagfalse flagThrottleValid
	b16clr RxThrottle
	rvsetflagtrue flagThrottleZero

rx27:	rvinc YawDcnt				;rudder signal timed out?
	rvcp YawDcnt, RxTimeoutLimit
	brlo rx28

	rvdec YawDcnt				;yes, set flag to false and set value to 0
	rvsetflagfalse flagYawValid
	b16clr RxYaw

rx28:	rvinc AuxDcnt				;aux signal timed out?
	rvcp AuxDcnt, RxTimeoutLimit
	brlo rx29

	rvdec AuxDcnt				;yes, set flag to false and set value to 0
	rvsetflagfalse flagAuxValid

	lds t, AuxSwitchPosition		;select AUX function #1. PS! Setting this value multiple times will cause Alarm problems (AuxBeepDelay)
	tst t
	breq rx29

	clr t
	sts AuxSwitchPosition, t
	ser t					;make sure the AUX switch function will be updated
	sts AuxSwitchPositionOld, t

rx29:	ret



	;---

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
	
	ldi t,1
	add xl,t
	clr t
	adc xh,t

xa1:	ret





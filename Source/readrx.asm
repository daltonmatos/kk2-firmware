

IsrRoll:

	in SregSaver, sreg

	sbis pind,3			;rising or falling?
	rjmp rx1

	lds tt, tcnt1l			;rising, store the start value
	sts RollStartL, tt
	lds tt, tcnt1h
	sts RollStartH, tt
	
	clr tt				;clear timeout counter
	sts RollDcnt, tt

	out sreg, SregSaver		;exit	
	reti

rx1:	lds tt, tcnt1l			;falling, calculate the pulse length
	lds treg, RollStartL
	sub tt, treg
	sts Channel1L, tt

	lds tt, tcnt1h
	lds treg, RollStartH
	sbc tt, treg
	sts Channel1H, tt

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

	clr tt				;clear timeout counter
	sts PitchDcnt, tt
	
	out sreg, SregSaver		;exit	
	reti

rx2:	lds tt, tcnt1l			;falling, calculate the pulse length
	lds treg, PitchStartL
	sub tt, treg
	sts Channel2L, tt

	lds tt, tcnt1h
	lds treg, PitchStartH
	sbc tt, treg
	sts Channel2H, tt

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
	
	clr tt				;clear timeout counter
	sts ThrottleDcnt, tt

	out sreg, SregSaver		;exit	
	reti

rx3:	lds tt, tcnt1l			;falling, calculate the pulse length
	lds treg, ThrottleStartL
	sub tt, treg
	sts Channel3L, tt

	lds tt, tcnt1h
	lds treg, ThrottleStartH
	sbc tt, treg
	sts Channel3H, tt

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
	ret

iyaw2:	mov tt, xl			;falling, calculate the pulse length
	lds treg, YawStartL
	sub tt, treg
	sts Channel4L, tt

	mov tt, xh
	lds treg, YawStartH
	sbc tt, treg
	sts Channel4H, tt
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
	sts Channel5L, tt

	mov tt, xh
	lds treg, AuxStartH
	sbc tt, treg
	sts Channel5H, tt
	ret



	;--- Get RX channels ---

GetRxChannels:

	;--- Roll ---

	lds r0, MappedChannel1		;get aileron channel value
	rcall GetSafeChannelValue
	rcall Sanitize
	rcall DeadZone

	clr yh
	b16store RxRoll
	rcall IsChannelCentered
	sts flagAileronCentered, yl


	;--- Pitch ---

	lds r0, MappedChannel2		;get elevator channel value
	rcall GetSafeChannelValue
	rcall Sanitize
	rcall DeadZone

	clr yh
	b16store RxPitch
	rcall IsChannelCentered
	sts flagElevatorCentered, yl


	;--- Throttle ---

	lds r0, MappedChannel3		;get throttle channel value
	rcall GetSafeChannelValue

	rvsetflagfalse flagThrottleZero

	rcall Xabs			;X = ABS(X)

	ldz 2875			;X = X - 2875 (1.15ms)
	sub xl, zl
	sbc xh, zh

	ldz 0				;X < 0 ?
	cp xl, zl
	cpc xh, zh
	brge rx32

	rjmp rx30			;yes, set to zero

rx32:	ldz 3125			;X > 3125? (1.25ms)
	cp xl, zl
	cpc xh, zh
	brlt rx33

rx30:	ldx 0				;yes, set to zero
	rvsetflagtrue flagThrottleZero

rx33:	clr yh
	b16store RxThrottle


	;--- Yaw ---

	lds r0, MappedChannel4		;get rudder channel value
	rcall GetSafeChannelValue
	rcall Sanitize
	rcall DeadZone

	clr yh
	b16store RxYaw


	;--- AUX ---

	lds r0, MappedChannel5		;get aux channel value
	rcall GetSafeChannelValue
	rcall Sanitize

	clr yl				;position #1
	ldz -600
	cp xl, zl
	cpc xh, zh
	brlt rx35

	inc yl				;position #2
	ldz -200
	cp xl, zl
	cpc xh, zh
	brlt rx35

	inc yl				;position #3
	ldz 200
	cp xl, zl
	cpc xh, zh
	brlt rx35

	inc yl				;position #4
	ldz 600
	cp xl, zl
	cpc xh, zh
	brlt rx35

	inc yl				;position #5

rx35:	rvbrflagfalse flagAuxValid, rx24;won't update aux switch position while the input is invalid

	sts AuxSwitchPosition, yl
	clr yh
	b16store RxAux


rx24:	;--- AUX2 ---

	lds r0, MappedChannel6		;get aux2 channel value
	rcall GetSafeChannelValue
	rcall Sanitize

	clr yh
	b16store RxAux2


	;--- AUX3 ---

	lds r0, MappedChannel7		;get aux3 channel value
	rcall GetSafeChannelValue
	rcall Sanitize

	clr yh
	b16store RxAux3


	;--- AUX4 ---

	lds r0, MappedChannel8		;get aux4 channel value
	rcall GetSafeChannelValue
	rcall Sanitize

	clr yl				;position #1
	ldz -400
	cp xl, zl
	cpc xh, zh
	brlt rx38

	inc yl				;position #2
	ldz 400
	cp xl, zl
	cpc xh, zh
	brlt rx38

	inc yl				;position #3

rx38:	sts Aux4SwitchPosition, yl

	clr yh
	b16store RxAux4


	;--- Check RX ---

	lds t, StatusBits			;clear the upper status bits to tag the aileron, elevator, throttle and rudder inputs as OK
	andi t, 0x0F
	sts StatusBits, t

	lds xl, MappedChannel1			;aileron signal timed out?
	rcall CheckRxTimeout
	sts flagRollValid, xh
	brcc rx25

	rcall CutThrottle			;yes, cut throttle
	setstatusbit NoAileronInput

rx25:	lds xl, MappedChannel2			;elevator signal timed out?
	rcall CheckRxTimeout
	sts flagPitchValid, xh
	brcc rx26

	rcall CutThrottle			;yes, cut throttle
	setstatusbit NoElevatorInput

rx26:	lds xl, MappedChannel3			;throttle signal timed out?
	rcall CheckRxTimeout
	sts flagThrottleValid, xh
	brcc rx27

	rcall CutThrottle			;yes, cut throttle
	setstatusbit NoThrottleInput

rx27:	lds xl, MappedChannel4			;rudder signal timed out?
	rcall CheckRxTimeout
	sts flagYawValid, xh
	brcc rx28

	setstatusbit NoRudderInput		;yes, set rudder value to zero
	b16clr RxYaw
	rvbrflagfalse flagArmed, rx28

	setstatusbit RxSignalLost		;set status bit RxSignalLost and activate the Lost Model alarm when armed
	rvsetflagtrue flagAlarmOverride

rx28:	lds xl, MappedChannel5			;aux signal timed out?
	rcall CheckRxTimeout
	sts flagAuxValid, xh
	brcc rx29

	lds t, AuxSwitchPosition		;yes, select AUX function #3 (if not already selected)
	cpi t, 2
	breq rx29

	ldi t, 2
	sts AuxSwitchPosition, t
	ser t					;make sure the AUX switch function will be updated
	sts AuxSwitchPositionOld, t

rx29:	ret



	;--- Cut throttle and set the RxSignalLost status bit ---

CutThrottle:

	b16clr RxThrottle
	rvsetflagtrue flagThrottleZero
	rvbrflagfalse flagArmed, cth1

	setstatusbit RxSignalLost		;set status bit for "Signal Lost" and activate the Lost Model alarm only when armed
	rvsetflagtrue flagAlarmOverride

cth1:	ret



	;--- Check for RX timeout ---

CheckRxTimeout:

	ldy RollDcnt				;find the mapped timeout counter
	clr xh					;register XH (output value) will return the "valid" flag (0 = timeout)
	add yl, xl				;register XL (input parameter) holds the mapped channel ID
	adc yh, xh

	ld zl, y				;load and increment counter
	inc zl

	lds t, RxTimeoutLimit			;timeout?
	cp zl, t
	brlo rto2

	sec					;yes, timer won't be updated (to prevent wrap-around)
	ret

rto2:	ser xh					;no timeout. Set the "valid" flag (output value) and save timer value before leaving
	st y, zl
	clc
	ret



	;--- Get channel value (blocking interrupts) ---

GetSafeChannelValue:

	ldzarray Channel1L, 2, r0		;register R0 (input parameter) holds the mapped channel ID
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
	cp xl, zl
	cpc xh, zh
	brlt sa2

	ldz 1750	;X > 1750?
	cp xl, zl
	cpc xh, zh
	brge sa2

	ret		;no, exit

sa2:	ldx 0		;yes, set to zero
	ret



	;--- Abs(X) ---

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



	;--- Dead zone adjustment ---

DeadZone:

	b16loadz StickDeadZone

	tst xh
	brpl dz1

	add xl, zl		;stick input is negative
	adc xh, zh
	brpl dz2

	ret

dz1:	sub xl, zl		;stick input is positive
	sbc xh, zh
	brmi dz2

	ret

dz2:	clr xl			;set stick input to zero
	clr xh
	clr yh
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




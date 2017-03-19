


	;--- CPPM ISR ---

IsrCppm:

;	in SregSaver, sreg		;see readrx.asm

	push xl
	push xh
	push zl
	push zh

	clr treg			;used for clearing variables

	lds xl, tcnt1l			;calculate pulse length: X = TCNT1 - CppmPulseStart, CppmPulseStart = TCNT1
	lds xh, tcnt1h
	lds zl, CppmPulseStartL
	lds zh, CppmPulseStartH
	sts CppmPulseStartL, xl
	sts CppmPulseStartH, xh
	sub xl, zl
	sbc xh, zh
	brpl cppm8

	com xh				;X = ABS(X)
	neg xl
	sbci xh, 0xFF

cppm8:	ldz 6250			;pulse longer than 2.5ms?
	cp  xl, zl
	cpc xh, zh
	brlo cppm9

	ldz Channel1L			;yes, reset cppm sequence

	lds tt, CppmChannelCount	;CPPM pulse train is considered valid when minimum 4 channels have been detected
	sts CppmChannelCount, treg
	sts ChannelCount, tt
	cpi tt, 4
	brge cppm6

	rjmp cppm10			;invalid CPPM frame

cppm6:	ser tt				;set flag to indicate that a valid CPPM frame has been received
	sts flagRxBufferFull, tt

	sts TimeoutCounter, treg	;reset timeout counter
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

GetCppmChannels:

	lds t, RxSyncCounter		;wait for RX input to become stable (after FlightInit)
	dec t
	brmi gcc10

	sts RxSyncCounter, t
	ret

	;check buffer
gcc10:	clr kl

	cli
	lds kh, flagRxBufferFull
	sts flagRxBufferFull, kl
	sei

	tst kh				;buffer full?
	breq gcc11

	sts flagRxFrameValid, kh	;yes, the CPPM frame appears to be valid, but more tests will be performed below


	;--- Roll ---

gcc11:	lds r0, MappedChannel1
	call GetSafeChannelValue
	call Sanitize
	call DeadZone

	clr yh
	b16store RxRoll
	call IsChannelCentered
	sts flagAileronCentered, yl

	
	;--- Pitch ---

	lds r0, MappedChannel2
	call GetSafeChannelValue
	call Sanitize
	call DeadZone

	clr yh
	b16store RxPitch
	call IsChannelCentered
	sts flagElevatorCentered, yl


	;--- Throttle ---

	lds r0, MappedChannel3
	call GetSafeChannelValue

	rvsetflagfalse flagThrottleZero

	call Xabs			;X = ABS(X)

	ldz 2875			;X = X - 2875 (1.15ms)
	sub xl, zl
	sbc xh, zh

	ldz 0				;X < 0 ?
	cp xl, zl
	cpc xh, zh
	brge gcc8

	rjmp gcc30			;yes, set to zero

gcc8:	ldz 3125			;X > 3125? (1.25ms)
	cp xl, zl
	cpc xh, zh
	brlt gcc2

gcc30:	ldx 0				;yes, set to zero
	rvsetflagtrue flagThrottleZero

gcc2:	clr yh
	b16store RxThrottle


	;--- Yaw ---

	lds r0, MappedChannel4
	call GetSafeChannelValue
	call Sanitize
	call DeadZone

	clr yh
	b16store RxYaw

	
	;--- AUX ---

	lds r0, MappedChannel5
	call GetSafeChannelValue
	call Sanitize

	clr yl				;position #1
	ldz -600
	cp xl, zl
	cpc xh, zh
	brlt gcc35

	inc yl				;position #2
	ldz -200
	cp xl, zl
	cpc xh, zh
	brlt gcc35

	inc yl				;position #3
	ldz 200
	cp xl, zl
	cpc xh, zh
	brlt gcc35

	inc yl				;position #4
	ldz 600
	cp xl, zl
	cpc xh, zh
	brlt gcc35

	inc yl				;position #5

gcc35:	sts AuxSwitchPosition, yl

	clr yh
	b16store RxAux


	;--- AUX2 ---

	lds r0, MappedChannel6
	call GetSafeChannelValue
	call Sanitize

	clr yh
	b16store RxAux2


	;--- AUX3 ---

	lds r0, MappedChannel7
	call GetSafeChannelValue
	call Sanitize

	clr yh
	b16store RxAux3


	;--- AUX4 ---

	lds r0, MappedChannel8
	call GetSafeChannelValue
	call Sanitize

	clr yl				;position #1
	ldz -400
	cp xl, zl
	cpc xh, zh
	brlt gcc38

	inc yl				;position #2
	ldz 400
	cp xl, zl
	cpc xh, zh
	brlt gcc38

	inc yl				;position #3

gcc38:	sts Aux4SwitchPosition, yl

	clr yh
	b16store RxAux4


	;--- Check RX ---

	rvbrflagfalse flagRxFrameValid, gcc24
	rjmp gcc22

gcc23:	sts TimeoutCounter, t
	rvbrflagfalse flagArmed, gcc21

	lds t, ChannelCount		;CPPM sync lost while armed?
	lds xl, ChannelCountArmed
	cp t, xl
	breq gcc21

	ldi xl, ErrorCppmSyncLost	;yes
	call LogError

gcc21:	ret

gcc22:	lds t, TimeoutCounter		;timeout?
	inc t
	lds xl, RxTimeoutLimit
	cp t, xl
	brlo gcc23

	rvbrflagfalse flagArmed, gcc24	;yes

	setstatusbit RxSignalLost	;set status bit for "Signal Lost" and activate the Lost Model alarm only when armed
	rvsetflagtrue flagAlarmOverride

gcc24:	jmp ClearInputChannels		;will tag the received frame as invalid and clear all input channels



	;--- Scale AUX inputs (divide by 10) ---

ScaleAuxInputValues:

	b16ldi Temp, 0.1
	b16mul RxAux2, RxAux2, Temp
	b16mul RxAux3, RxAux3, Temp
	ret




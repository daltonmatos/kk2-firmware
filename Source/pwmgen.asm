


PwmStart:

//	sbi DebugOutputPin		// DEBUGGING

	;set OCR1A to current time + 0.5ms

	cli
	load xl, tcnt1l
	load xh, tcnt1h
	sei

	ldi t, low(1250)
	add xl, t
	ldi t, high(1250)
	adc xh, t

	cli
	store ocr1ah, xh
	store ocr1al, xl
	sei

	;set OCR1B to current time + 1.5ms

	ldi t, low(2500)
	add xl, t
	ldi t, high(2500)
	adc xh, t

	cli
	store ocr1bh, xh
	store ocr1bl, xl
	sei

	;turn on OC1a and b interrupt

	;       76543210
	ldi t,0b00000110
	store timsk1, t

	clr t
	sts flagPwmGen, t
	sts flagPwmEnd, t
	ret



IsrPwmStart:

	;generate the rising edge of servo/esc pulses

	load SregSaver, sreg

	lds tt, flagPwmGen		;check for PWM generator state
	tst tt
	breq pwm1a

	cbi OutputPin7			;set M7 output low
	rjmp pwm12

pwm1a:	lds tt, flagMutePwm
	tst tt
	brmi pwm12

	sec

	lds tt, OutputRateDividerCounter
	dec tt
	brne pwm1

	lds tt, OutputRateDivider
	clc	

pwm1:	sts OutputRateDividerCounter, tt
	
	ldi tt, 0xff			;bit pattern for fast and slow update rate
	brcc pwm2
	lds tt, OutputRateBitmask	;bit pattern for fast update rate

pwm2:	lsr tt				;stagger the pin switching to avoid up to 8 pins switching at the same time
	brcc pwm3
	sbi OutputPin1
pwm3:	lsr tt
	brcc pwm4
	sbi OutputPin2
pwm4:	lsr tt
	brcc pwm5
	sbi OutputPin3
pwm5:	lsr tt
	brcc pwm6
	sbi OutputPin4
pwm6:	lsr tt
	brcc pwm7
	sbi OutputPin5
pwm7:	lsr tt
	brcc pwm8
	sbi OutputPin6
pwm8:	lsr tt
	brcc pwm9
	sbi OutputPin7
pwm9:	lsr tt
	brcc pwm12
	sbi OutputPin8

pwm12:	store sreg, SregSaver
	reti





IsrPwmEnd:

	load SregSaver, sreg

	lds tt, flagPwmGen		;check for PWM generator state
	tst tt
	breq ipe1

	cbi OutputPin8			;set M8 output low
	rjmp ipe2

ipe1:	ldi tt, 0xff
	sts flagPwmEnd, tt

ipe2:	store sreg, SregSaver
	reti





PwmEnd:

	b16ldi Temp, 1001		;make sure the EscLowLimit is not too high. (hardcoded limit of 20%)
	b16cmp EscLowLimit, Temp
	brlt pwm58

	b16mov EscLowLimit, Temp

pwm58:	;loop setup

	lrv Index, 0		

	lds t, OutputTypeBitmask
	sts OutputTypeBitmaskCopy, t

	rvflagnot flagInactive, flagArmed	;flagInactive is set to true if outputs should be in inactive state
	rvflagor flagInactive, flagInactive, flagThrottleZero
	
	;loop body

pwm50:	b16load_array PwmOutput, Out1

	lds t, OutputTypeBitmaskCopy		;ESC or SERVO?
	lsr t
	sts OutputTypeBitmaskCopy, t
	brcc pwm51fix

	rjmp pwm51

pwm51fix:

	;---

	rvbrflagfalse flagInactive, pwm52fix	;SERVO, active or inactive?
	rjmp pwm52

pwm52fix:
	b16load_array Temp, FilteredOut1 	;servo active, apply low pass filter
	b16sub Error, PwmOutput, Temp

	b16mul Error, Error, ServoFilter

	b16add PwmOutput, Temp, Error
	b16store_array FilteredOut1, PwmOutput

	rjmp pwm55

pwm52:	b16load_array PwmOutput, Offset1	;servo inactive, set to offset value
	rjmp pwm55

	;---

pwm51:	rvbrflagtrue flagInactive, pwm54	;ESC, active or inactive?

	b16cmp PwmOutput, EscLowLimit		;ESC active, limit to EscLowLimit
	brge pwm56
	b16mov PwmOutput, EscLowLimit
pwm56:
	rjmp pwm55

pwm54:	b16clr PwmOutput			;ESC inactive, set to zero 

	;---

pwm55:	b16store_array Out1, PwmOutput


	;loop looper

	rvinc Index
	rvcpi Index, 8
	breq pwm57
	rjmp pwm50
pwm57:



.def O1L=r0
.def O1H=r1
.def O2L=r2
.def O2H=r3
.def O3L=r4
.def O3H=r5
.def O4L=r6
.def O4H=r7
.def O5L=r8
.def O5H=r17
.def O6L=r18
.def O6H=r19
.def O7L=r20
.def O7H=r21
.def O8L=r22
.def O8H=r23
	
	
	;condition the output values

	b16load Out1
	rcall PwmCond
	mov O1L, xl
	mov O1H, xh

	b16load Out2
	rcall PwmCond
	mov O2L, xl
	mov O2H, xh

	b16load Out3
	rcall PwmCond
	mov O3L, xl
	mov O3H, xh

	b16load Out4
	rcall PwmCond
	mov O4L, xl
	mov O4H, xh

	b16load Out5
	rcall PwmCond
	mov O5L, xl
	mov O5H, xh

	b16load Out6
	rcall PwmCond
	mov O6L, xl
	mov O6H, xh

	b16load Out7
	rcall PwmCondForTimer
	mov O7L, xl
	mov O7H, xh

	b16load Out8
	rcall PwmCondForTimer
	mov O8L, xl
	mov O8H, xh


//	cbi DebugOutputPin		// DEBUGGING


	;generate the end of the PWM signal, this part is blocking.

	rvbrflagfalse flagPwmEnd, pwm29
;	ldi t, 0				;if IsrPwmEnd is true here, the start of PWM pulse end generation is missed
;	call LogError				;log error
	ret					;and return without generating the end of pwm pulse

pwm29:	rvbrflagfalse flagPwmEnd, pwm29		;wait until IsrPwmEnd has run (flagPwmEnd == true)


	;prepare timer for jitter-free channels

	ser t
	sts flagPwmGen, t

	cli
	load xl, tcnt1l
	load xh, tcnt1h
	sei

	movw y, x

	add xl, O7L
	adc xh, O7H
	add yl, O8L
	adc yh, O8H

	cli
	store ocr1ah, xh
	store ocr1al, xl
	store ocr1bh, yh
	store ocr1bl, yl
	sei


	;generate the varying 1ms part of the pwm signal

	ldx 1
	ldy 626
	
pwm13:	sub O1L, xl
	sbc O1H, xh
	brcc pwm14
	cbi OutputPin1
pwm14:	sub O2L, xl
	sbc O2H, xh
	brcc pwm15
	cbi OutputPin2
pwm15:	sub O3L, xl
	sbc O3H, xh
	brcc pwm16
	cbi OutputPin3
pwm16:	sub O4L, xl
	sbc O4H, xh
	brcc pwm17
	cbi OutputPin4
pwm17:	sub O5L, xl
	sbc O5H, xh
	brcc pwm18
	cbi OutputPin5
pwm18:	sub O6L, xl
	sbc O6H, xh
	brcc pwm19
	cbi OutputPin6

pwm19:	nop
	nop
	nop
	nop
	sbiw y, 1
	brcc pwm13

	cbi OutputPin7	;for safety
	cbi OutputPin8
	ret




.undef O1L
.undef O1H
.undef O2L
.undef O2H
.undef O3L
.undef O3H
.undef O4L
.undef O4H
.undef O5L
.undef O5H
.undef O6L
.undef O6H
.undef O7L
.undef O7H
.undef O8L
.undef O8H




PwmCond:

	asr xh		;divide by 8
	ror xl
	asr xh
	ror xl
	asr xh
	ror xl

	ldy 0		;x < 0?
	cp  xl, yl
	cpc xh, yh
	brge pwc1

	ldx 0		;yes, set to zero

pwc1:	ldy 626		;x >= 626?
	cp  xl, yl
	cpc xh, yh
	brlt pwc2

	ldx 625		;yes, set to 625

pwc2:	ret



PwmCondForTimer:

	asr xh		;divide by 2
	ror xl

	ldy 3		;x < 3?
	cp  xl, yl
	cpc xh, yh
	brge pft1

	ldx 3		;yes, set to 3 (cannot use smaller values because then the timer won't trigger)

pft1:	ldy 2501	;x >= 2501?
	cp  xl, yl
	cpc xh, yh
	brlt pft2

	ldx 2500	;yes, set to 2500

pft2:	ret



	;--- Run ESCs at minimum output (1.0ms) while navigating the menus --- WARNING: THIS CODE IS NOT COMPATIBLE WITH KK2.1

StartPwmQuiet:

	clr t				;all PWM outputs are low
	sts flagPwmState, t

	call LoadMixerTable		;load the mixer table in case some settings were changed
	call UpdateOutputTypeAndRate
	lds t, OutputTypeBitmask
	clr xh

	lsr t				;M1
	brcc pms10

	ori xh, M1

pms10:	lsr t				;M2
	brcc pms11

	ori xh, M2

pms11:	lsr t				;M3
	brcc pms12

	ori xh, M3

pms12:	lsr t				;M4
	brcc pms13

	ori xh, M4

pms13:	lsr t				;M5
	brcc pms14

	ori xh, M5

pms14:	lsr t				;M6
	brcc pms15

	ori xh, M6

pms15:	lsr t				;M7
	brcc pms16

	ori xh, M7

pms16:	lsr t				;M8
	brcc pms17

	ori xh, M8

pms17:	sts PwmOutputMask, xh

	ldi t, 217			;set timer2 to generate an interrupt 0.5ms from now (256 - 39 = 217)
	store tcnt2, t

	;       76543210
	ldi t,0b00000000		;set timer2 to normal mode
	store tccr2a, t

	;       76543210
	ldi t,0b00000110		;clk/256 prescaler
	store tccr2b, t

	;       76543210
	ldi t,0b00000001		;enable timer2 overflow interrupt
	store timsk2, t
	ret



StopPwmQuiet:

	lds t, flagPwmState		;wait for PWM output state to become false
	tst t
	brne StopPwmQuiet

	;       76543210
	ldi t,0b00000000		;disable timer2 overflow interrupt
	store timsk2, t

	push yl				;wait 1.0ms to compensate for the "varying" part of the PWM pulse
	pushx
	ldx 1
	call WaitXms
	popx
	pop yl
	ret



IsrPwmQuiet:

	load SregSaver, sreg

	lds tt, flagPwmState		;toggle output state
	com tt
	sts flagPwmState, tt

	tst tt				;prepare for next interrupt. Set high or low output level?
	breq ipq10

	ldi tt, 178			;high. The next interrupt will occur in 1ms from now (256 - 78 = 178)
	lds treg, PwmOutputMask		;set outputs according to mask
	rjmp ipq11

ipq10:	ldi tt, 139			;low. The next interrupt will occur in 1.5ms from now (256 - 117 = 139)
	clr treg

ipq11:	store tcnt2, tt

	out portc, treg			;set outputs before leaving
	store sreg, SregSaver
	reti

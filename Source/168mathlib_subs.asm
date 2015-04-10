
	;--- 16.8 fixed point fast divide ---

.def	Op1_2=r22
.def	Op1_1=r23
.def	Op1_0=r24

b16fdiv_c:
	asr Op1_2
	ror Op1_1
	ror Op1_0
	dec t
	brne b16fdiv_c

	adc Op1_0, t		;round off
	adc Op1_1, t
	adc Op1_2, t
	
	ret

.undef	Op1_2
.undef	Op1_1
.undef	Op1_0


	;--- 16.8 fixed point fast multiply ---

.def	Op1_2=r22
.def	Op1_1=r23
.def	Op1_0=r24

b16fmul_c:		
	lsl Op1_0
	rol Op1_1
	rol Op1_2
	dec t
	brne b16fmul_c
	
	ret

.undef	Op1_2
.undef	Op1_1
.undef	Op1_0


	;--- 16.8 fixed point multiply ---

.def	Op1_2=r17
.def	Op1_1=r18
.def	Op1_0=r19

.def	Op2_2=r20
.def	Op2_1=r21
.def	Op2_0=r22

.def	Result2=r23
.def	Result1=r24
.def	Result0=r2
.def	Sign=r3


multc:	mov Sign, Op1_2		;calculate result sign
	eor Sign, Op2_2

	tst Op1_2		;Op1=ABS(Op1)
	brpl mul1
	com Op1_0
	com Op1_1
	com Op1_2
	ldi t,1
	add Op1_0, t
	clr t
	adc Op1_1, t
	adc Op1_2, t

mul1:	tst Op2_2		;Op2=ABS(Op2)
	brpl mul2
	com Op2_0
	com Op2_1
	com Op2_2
	ldi t,1
	add Op2_0, t
	clr t
	adc Op2_1, t
	adc Op2_2, t

mul2:	clr Result1
	clr Result2

	mul Op1_0, Op2_0	;Mul #1
	push r0
	mov Result0, r1
	clr t

	mul Op1_0, Op2_1	;mul #2
	add Result0, r0
	adc Result1, r1
	adc Result2, t

	mul Op1_0, Op2_2	;mul #3
	add Result1, r0
	adc Result2, r1

	mul Op1_1, Op2_0	;mul #4
	add Result0, r0
	adc Result1, r1
	adc Result2, t

	mul Op1_1, Op2_1	;mul #5
	add Result1, r0
	adc Result2, r1

	mul Op1_1, Op2_2	;mul #6
	add Result2, r0
	
	mul Op1_2, Op2_0	;mul #7
	add Result1, r0
	adc Result2, r1

	mul Op1_2, Op2_1	;mul #8
	add Result2, r0
		
	pop r0			;round off
	lsl r0

	adc Result0, t
	adc result1, t
	adc result2, t

	brpl mul4		;overflow?
	
	ldi t, 0xff		;yes, set result to max
	mov Result0, t	
	mov Result1, t
	ldi Result2, 0x7f	

mul4:	tst Sign		;negate result if sign set.
	brpl mul3
	com Result0
	com Result1
	com Result2
	ldi t,1
	add Result0, t
	clr t
	adc Result1, t
	adc Result2, t

mul3:	ret

.undef	Op1_2
.undef	Op1_1
.undef	Op1_0

.undef	Op2_2
.undef	Op2_1
.undef	Op2_0

.undef	Result2
.undef	Result1
.undef	Result0
.undef	Sign


	;--- 16.8 fixed point MAC ---


.def	A=r18

.def	Op1_2=r19
.def	Op1_1=r20
.def	Op1_0=r21

.def	Op2_0=r22

.def	Result2=r23
.def	Result1=r24
.def	Result0=r2
.def	Sign=r3

macc:	mov Op2_0, t

	mov Sign, Op1_2		;calculate result sign
	eor Sign, Op2_0

	tst Op1_2		;Op1=ABS(Op1)
	brpl mac1
	com Op1_0
	com Op1_1
	com Op1_2
	ldi t,1
	add Op1_0, t
	clr t
	adc Op1_1, t
	adc Op1_2, t

mac1:	tst Op2_0		;Op2=ABS(Op2)
	brpl pc + 2
	neg Op2_0

	clr Result1
	clr Result2
	clr t

	mul Op1_0, Op2_0	;Mul #1
	mov A, r0
	mov Result0, r1

	mul Op1_1, Op2_0	;mul #2
	add Result0, r0
	adc Result1, r1
	adc Result2, t

	mul Op1_2, Op2_0	;mul #3
	add Result1, r0
	adc Result2, r1

	lsl A			;round off

	adc Result0, t
	adc result1, t
	adc result2, t

	tst Sign		;accumulate
	brpl mac2

	sub yh, Result0
	sbc xl, Result1
	sbc xh, Result2

	ret

mac2:	add yh, Result0
	adc xl, Result1
	adc xh, Result2

	ret

.undef	Op1_2
.undef	Op1_1
.undef	Op1_0

.undef	Op2_0

.undef	Result2
.undef	Result1
.undef	Result0
.undef	Sign

.undef A


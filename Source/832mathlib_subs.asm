
	;--- 8.32 fixed point multiply ---

.undef	XH
.undef	XL
.undef	YH
.undef	YL
.undef	ZH
.undef	ZL

.def	Op1_4=r3
.def	Op1_3=r4
.def	Op1_2=r5
.def	Op1_1=r6
.def	Op1_0=r7

.def	op2_4=r18
.def	op2_3=r19
.def	Op2_2=r20
.def	Op2_1=r21
.def	Op2_0=r22

.def	Result4=r27
.def	Result3=r28
.def	Result2=r29
.def	Result1=r30
.def	Result0=r31
.def	Resultm1=r8
.def	Resultm2=r9
.def	Resultm3=r10

.def	Sign=r23


b832mul_c:
	mov Sign, Op1_4		;calculate result sign
	eor Sign, Op2_4

	tst Op1_4		;Op1=ABS(Op1)
	brpl mmm1a
	com Op1_0
	com Op1_1
	com Op1_2
	com Op1_3
	com Op1_4
	ldi t,1
	add Op1_0, t
	clr t
	adc Op1_1, t
	adc Op1_2, t
	adc Op1_3, t
	adc Op1_4, t


mmm1a:	tst Op2_4		;Op2=ABS(Op2)
	brpl mmm2a
	com Op2_0
	com Op2_1
	com Op2_2
	com Op2_3
	com Op2_4
	ldi t,1
	add Op2_0, t
	clr t
	adc Op2_1, t
	adc Op2_2, t
	adc Op2_3, t
	adc Op2_4, t


mmm2a:	clr Result4
	clr Result3
	clr Result2
	clr Result1
	clr Result0
	clr Resultm1
	clr Resultm2
	clr t
				
	; byte 0
	mul Op1_0, Op2_0
	mov resultm3, r1

	; byte 1
	mul Op1_0, Op2_1
	add resultm3, r0
	adc resultm2, r1
	adc resultm1, t

	mul Op1_1, Op2_0
	add resultm3, r0
	adc resultm2, r1
	adc resultm1, t

	;byte 2
	mul Op1_1, Op2_1
	add resultm2, r0
	adc resultm1, r1
	adc result0, t

	mul Op1_0, Op2_2
	add resultm2, r0
	adc resultm1, r1
	adc result0, t

	mul Op1_2, Op2_0
	add resultm2, r0
	adc resultm1, r1
	adc result0, t

	;byte 3
	mul Op1_0, Op2_3
	add resultm1, r0
	adc result0, r1
	adc result1, t

	mul Op1_3, Op2_0
	add resultm1, r0
	adc result0, r1
	adc result1, t

	mul Op1_1, Op2_2
	add resultm1, r0
	adc result0, r1
	adc result1, t

	mul Op1_2, Op2_1
	add resultm1, r0
	adc result0, r1
	adc result1, t

	; byte 4
	
	mul Op1_0, Op2_4
	add result0, r0
	adc result1, r1
	adc result2, t

	mul Op1_4, Op2_0
	add result0, r0
	adc result1, r1
	adc result2, t

	mul Op1_1, Op2_3
	add result0, r0
	adc result1, r1
	adc result2, t

	mul Op1_3, Op2_1
	add result0, r0
	adc result1, r1
	adc result2, t

	mul Op1_2, Op2_2
	add result0, r0
	adc result1, r1
	adc result2, t

	; byte 5
	mul Op1_1, Op2_4
	add result1, r0
	adc result2, r1
	adc result3, t
	
	mul Op1_4, Op2_1
	add result1, r0
	adc result2, r1
	adc result3, t

	mul Op1_2, Op2_3
	add result1, r0
	adc result2, r1
	adc result3, t

	mul Op1_3, Op2_2
	add result1, r0
	adc result2, r1
	adc result3, t

	; byte 6
	
	mul Op1_2, Op2_4
	add result2, r0
	adc result3, r1
	adc result4, t
	
	mul Op1_4, Op2_2
	add result2, r0
	adc result3, r1
	adc result4, t

	mul Op1_3, Op2_3
	add result2, r0
	adc result3, r1
	adc result4, t

	; byte 7
	mul Op1_3, Op2_4
	add result3, r0
	adc result4, r1

	mul Op1_4, Op2_3
	add result3, r0
	adc result4, r1
	
	; byte 8
	mul Op1_4, Op2_4
	add result4, r0


	lsl Resultm1		;round off
	adc Result0, t
	adc result1, t
	adc result2, t
	adc result3, t
	adc result4, t

	tst Sign		;negate result if sign set.
	brpl mmm3a
	com Result0
	com Result1
	com Result2
	com Result3
	com Result4
	ldi t,1
	add Result0, t
	clr t
	adc Result1, t
	adc Result2, t
	adc Result3, t
	adc Result4, t

mmm3a:	ret

.undef	Op1_4
.undef	Op1_3
.undef	Op1_2
.undef	Op1_1
.undef	Op1_0

.undef	op2_4
.undef	op2_3
.undef	Op2_2
.undef	Op2_1
.undef	Op2_0

.undef	Result4
.undef	Result3
.undef	Result2
.undef	Result1
.undef	Result0
.undef	Resultm1
.undef	Resultm2
.undef	Resultm3

.undef	Sign

.def	XH	= r27
.def	XL	= r26
.def	YH	= r29
.def	YL	= r28
.def	ZH	= r31
.def	ZL	= r30
	;--- 8.32 fast divide ---

.def	Op1_4=r3
.def	Op1_3=r4
.def	Op1_2=r5
.def	Op1_1=r6
.def	Op1_0=r7

b832fdiv_c:
	asr Op1_4
	ror Op1_3
	ror Op1_2
	ror Op1_1
	ror Op1_0
	dec t
	brne b832fdiv_c

	adc Op1_0, t		;round off
	adc Op1_1, t
	adc Op1_2, t
	adc Op1_3, t
	adc Op1_4, t
	
	ret

.undef	Op1_4
.undef	Op1_3
.undef	Op1_2
.undef	Op1_1
.undef	Op1_0

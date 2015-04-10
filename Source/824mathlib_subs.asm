
	;--- 8.24 fixed point multiply ---


.def	Op1_3=r2
.def	Op1_2=r3
.def	Op1_1=r4
.def	Op1_0=r5

.def	Op2_3=r6
.def	Op2_2=r7
.def	Op2_1=r8
.def	Op2_0=r9

.def	Result3=r17
.def	Result2=r18
.def	Result1=r19
.def	Result0=r20
.def	Resultm1=r21
.def	Resultm2=r22

.def	Sign=r23


b824mul_c:
	mov Sign, Op1_3		;calculate result sign
	eor Sign, Op2_3

	tst Op1_3		;Op1=ABS(Op1)
	brpl mmm1
	com Op1_0
	com Op1_1
	com Op1_2
	com Op1_3
	ldi t,1
	add Op1_0, t
	clr t
	adc Op1_1, t
	adc Op1_2, t
	adc Op1_3, t


mmm1:	tst Op2_3		;Op2=ABS(Op2)
	brpl mmm2
	com Op2_0
	com Op2_1
	com Op2_2
	com Op2_3
	ldi t,1
	add Op2_0, t
	clr t
	adc Op2_1, t
	adc Op2_2, t
	adc Op2_3, t


mmm2:	clr Result3
	clr Result2
	clr Result1
	clr Result0
	clr Resultm1
	clr t
				
	;byte #0
	mul Op1_0, Op2_0	;Mul #1
	mov Resultm2, r1
	
	;byte #1
	mul Op1_0, Op2_1	;mul #2
	add Resultm2, r0
	adc Resultm1, r1
	adc Result0, t

	mul Op1_1, Op2_0	;mul #3
	add Resultm2, r0
	adc Resultm1, r1
	adc Result0, t

	;byte #2
	mul Op1_0, Op2_2	;mul #4
	add Resultm1, r0
	adc Result0, r1
	adc Result1, t

	mul Op1_1, Op2_1	;mul #5
	add Resultm1, r0
	adc Result0, r1
	adc Result1, t

	mul Op1_2, Op2_0	;mul #6
	add Resultm1, r0
	adc Result0, r1
	adc Result1, t

	;byte #3
	mul Op1_0, Op2_3	;mul #7
	add Result0, r0
	adc Result1, r1
	adc Result2, t

	mul Op1_1, Op2_2	;mul #8
	add Result0, r0
	adc Result1, r1
	adc Result2, t

	mul Op1_2, Op2_1	;mul #9
	add Result0, r0
	adc Result1, r1
	adc Result2, t

	mul Op1_3, Op2_0	;mul #A
	add Result0, r0
	adc Result1, r1
	adc Result2, t

	;byte #4	
	mul Op1_1, Op2_3	;mul #B
	add Result1, r0
	adc Result2, r1
	adc Result3, t

	mul Op1_2, Op2_2	;mul #C
	add Result1, r0
	adc Result2, r1
	adc Result3, t

	mul Op1_3, Op2_1	;mul #D
	add Result1, r0
	adc Result2, r1
	adc Result3, t

	;byte #5
	mul Op1_2, Op2_3	;mul #E
	add Result2, r0
	adc Result3, r1

	mul Op1_3, Op2_2	;mul #F
	add Result2, r0
	adc Result3, r1

	;byte #6
	mul Op1_3, Op2_3	;mul #10
	add Result3, r0


	lsl Resultm1		;round off
	adc Result0, t
	adc result1, t
	adc result2, t
	adc result3, t

	tst Sign		;negate result if sign set.
	brpl mmm3
	com Result0
	com Result1
	com Result2
	com Result3
	ldi t,1
	add Result0, t
	clr t
	adc Result1, t
	adc Result2, t
	adc Result3, t

mmm3:	ret

.undef	Op1_3
.undef	Op1_2
.undef	Op1_1
.undef	Op1_0

.undef	Op2_3
.undef	Op2_2
.undef	Op2_1
.undef	Op2_0

.undef	Result3
.undef	Result2
.undef	Result1
.undef	Result0
.undef	Resultm1
.undef	Resultm2

.undef	Sign


	;--- 8.24 fast divide ---

.def	Op1_3=r21
.def	Op1_2=r22
.def	Op1_1=r23
.def	Op1_0=r24

b824fdiv_c:
	asr Op1_3
	ror Op1_2
	ror Op1_1
	ror Op1_0
	dec t
	brne b824fdiv_c

	adc Op1_0, t		;round off
	adc Op1_1, t
	adc Op1_2, t
	adc Op1_3, t
	
	ret

.undef	Op1_3
.undef	Op1_2
.undef	Op1_1
.undef	Op1_0

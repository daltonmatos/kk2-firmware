
.macro b832ldi

	ldi t, low(int(@1+0x100)-0x100)
	sts @0 + 0, t
	ldi t, high(int(frac(@1)*0x10000+0x10000)-0x10000)
	sts @0 + 1, t
	ldi t, low(int(frac(@1)*0x10000+0x10000)-0x10000)
	sts @0 + 2, t
	ldi t, high(int(frac(@1)*0x100000000+0x100000000)-0x100000000)
	sts @0 + 3, t
	ldi t, low(int(frac(@1)*0x100000000+0x100000000)-0x100000000)
	sts @0 + 4, t

.endmacro


.macro b832mov

	lds t, @1 + 0
	sts @0 + 0, t
	lds t, @1 + 1
	sts @0 + 1, t
	lds t, @1 + 2
	sts @0 + 2, t
	lds t, @1 + 3
	sts @0 + 3, t
	lds t, @1 + 4
	sts @0 + 4, t

.endmacro


.macro b832clr

	ldi t, 0
	sts @0 + 0, t
	sts @0 + 1, t
	sts @0 + 2, t
	sts @0 + 3, t
	sts @0 + 4, t

.endmacro.


.macro b832store		;X:Y  -> 8.32 register

	sts @0 + 0, xh
	sts @0 + 1, xl
	sts @0 + 2, yh
	sts @0 + 3, yl
	sts @0 + 4, zh

.endmacro


.macro b832load			;X:Y  <- 8.32 register

	lds xh, @0 + 0
	lds xl, @0 + 1
	lds yh, @0 + 2
	lds yl, @0 + 3
	lds zh, @0 + 4

.endmacro


.macro b832add

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

	lds Op1_4, @1 + 0
	lds Op1_3, @1 + 1
	lds Op1_2, @1 + 2
	lds Op1_1, @1 + 3
	lds Op1_0, @1 + 4

	lds Op2_4, @2 + 0
	lds Op2_3, @2 + 1
	lds Op2_2, @2 + 2
	lds Op2_1, @2 + 3
	lds Op2_0, @2 + 4

	add Op1_0, Op2_0
	adc Op1_1, Op2_1
	adc Op1_2, Op2_2
	adc Op1_3, Op2_3
	adc Op1_4, Op2_4
	
	sts @0 + 0, Op1_4
	sts @0 + 1, Op1_3
	sts @0 + 2, Op1_2
	sts @0 + 3, Op1_1
	sts @0 + 4, Op1_0

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

.endmacro


.macro b832sub

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

	lds Op1_4, @1 + 0
	lds Op1_3, @1 + 1
	lds Op1_2, @1 + 2
	lds Op1_1, @1 + 3
	lds Op1_0, @1 + 4

	lds Op2_4, @2 + 0
	lds Op2_3, @2 + 1
	lds Op2_2, @2 + 2
	lds Op2_1, @2 + 3
	lds Op2_0, @2 + 4

	sub Op1_0, Op2_0
	sbc Op1_1, Op2_1
	sbc Op1_2, Op2_2
	sbc Op1_3, Op2_3
	sbc Op1_4, Op2_4
	
	sts @0 + 0, Op1_4
	sts @0 + 1, Op1_3
	sts @0 + 2, Op1_2
	sts @0 + 3, Op1_1
	sts @0 + 4, Op1_0

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

.endmacro


.macro b832mul

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

	lds Op1_4, @1 + 0
	lds Op1_3, @1 + 1
	lds Op1_2, @1 + 2
	lds Op1_1, @1 + 3
	lds Op1_0, @1 + 4

	lds Op2_4, @2 + 0
	lds Op2_3, @2 + 1
	lds Op2_2, @2 + 2
	lds Op2_1, @2 + 3
	lds Op2_0, @2 + 4

	call b832mul_c

	sts @0 + 0, Result4
	sts @0 + 1, Result3
	sts @0 + 2, Result2
	sts @0 + 3, Result1
	sts @0 + 4, Result0

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

.endmacro



.macro b832fdiv

.def	Op1_4=r3
.def	Op1_3=r4
.def	Op1_2=r5
.def	Op1_1=r6
.def	Op1_0=r7


	lds Op1_4, @0 + 0
	lds Op1_3, @0 + 1
	lds Op1_2, @0 + 2
	lds Op1_1, @0 + 3
	lds Op1_0, @0 + 4
		
	ldi t, @1	

	call b832fdiv_c

	sts @0 + 0, Op1_4
	sts @0 + 1, Op1_3
	sts @0 + 2, Op1_2
	sts @0 + 3, Op1_1
	sts @0 + 4, Op1_0

.undef	Op1_4
.undef	Op1_3
.undef	Op1_2
.undef	Op1_1
.undef	Op1_0

.endmacro



.macro b824ldi

	ldi t, low(int(@1+0x100)-0x100)
	sts @0 + 0, t
	ldi t, high(int(frac(@1)*0x10000+0x10000)-0x10000)
	sts @0 + 1, t
	ldi t, low(int(frac(@1)*0x10000+0x10000)-0x10000)
	sts @0 + 2, t
	ldi t, (@1<0) ? 0xff : 0x00
	sts @0 + 3, t

.endmacro


.macro b824mov

	lds t, @1 + 0
	sts @0 + 0, t
	lds t, @1 + 1
	sts @0 + 1, t
	lds t, @1 + 2
	sts @0 + 2, t
	lds t, @1 + 3
	sts @0 + 3, t


.endmacro


.macro b824clr

	ldi t, 0
	sts @0 + 0, t
	sts @0 + 1, t
	sts @0 + 2, t
	sts @0 + 3, t

.endmacro.


.macro b824store		;X:Y  -> 8.24 register

	sts @0 + 0, xh
	sts @0 + 1, xl
	sts @0 + 2, yh
	sts @0 + 3, yl

.endmacro


.macro b824load			;X:Y  <- 8.24 register

	lds xh, @0 + 0
	lds xl, @0 + 1
	lds yh, @0 + 2
	lds yl, @0 + 3

.endmacro


.macro b824add

.def	Op1_3=r17
.def	Op1_2=r18
.def	Op1_1=r19
.def	Op1_0=r20

.def	op2_3=r21
.def	Op2_2=r22
.def	Op2_1=r23
.def	Op2_0=r24

	lds Op1_3, @1 + 0
	lds Op1_2, @1 + 1
	lds Op1_1, @1 + 2
	lds Op1_0, @1 + 3

	lds Op2_3, @2 + 0
	lds Op2_2, @2 + 1
	lds Op2_1, @2 + 2
	lds Op2_0, @2 + 3

	add Op1_0, Op2_0
	adc Op1_1, Op2_1
	adc Op1_2, Op2_2
	adc Op1_3, Op2_3
	
	sts @0 + 0, Op1_3
	sts @0 + 1, Op1_2
	sts @0 + 2, Op1_1
	sts @0 + 3, Op1_0

.undef	Op1_3
.undef	Op1_2
.undef	Op1_1
.undef	Op1_0

.undef	Op2_3
.undef	Op2_2
.undef	Op2_1
.undef	Op2_0

.endmacro


.macro b824sub

.def	Op1_3=r17
.def	Op1_2=r18
.def	Op1_1=r19
.def	Op1_0=r20

.def	op2_3=r21
.def	Op2_2=r22
.def	Op2_1=r23
.def	Op2_0=r24

	lds Op1_3, @1 + 0
	lds Op1_2, @1 + 1
	lds Op1_1, @1 + 2
	lds Op1_0, @1 + 3

	lds Op2_3, @2 + 0
	lds Op2_2, @2 + 1
	lds Op2_1, @2 + 2
	lds Op2_0, @2 + 3

	sub Op1_0, Op2_0
	sbc Op1_1, Op2_1
	sbc Op1_2, Op2_2
	sbc Op1_3, Op2_3
	
	sts @0 + 0, Op1_3
	sts @0 + 1, Op1_2
	sts @0 + 2, Op1_1
	sts @0 + 3, Op1_0

.undef	Op1_3
.undef	Op1_2
.undef	Op1_1
.undef	Op1_0

.undef	Op2_3
.undef	Op2_2
.undef	Op2_1
.undef	Op2_0

.endmacro


.macro b824mul

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

	lds Op1_3, @1 + 0
	lds Op1_2, @1 + 1
	lds Op1_1, @1 + 2
	lds Op1_0, @1 + 3

	lds Op2_3, @2 + 0
	lds Op2_2, @2 + 1
	lds Op2_1, @2 + 2
	lds Op2_0, @2 + 3

	call b824mul_c

	sts @0 + 0, Result3
	sts @0 + 1, Result2
	sts @0 + 2, Result1
	sts @0 + 3, Result0

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

.endmacro



.macro b824fdiv

.def	Op1_3=r21
.def	Op1_2=r22
.def	Op1_1=r23
.def	Op1_0=r24


	lds Op1_3, @0 + 0
	lds Op1_2, @0 + 1
	lds Op1_1, @0 + 2
	lds Op1_0, @0 + 3
		
	ldi t, @1	

	call b824fdiv_c

	sts @0 + 0, Op1_3
	sts @0 + 1, Op1_2
	sts @0 + 2, Op1_1
	sts @0 + 3, Op1_0

.undef	Op1_3
.undef	Op1_2
.undef	Op1_1
.undef	Op1_0

.endmacro


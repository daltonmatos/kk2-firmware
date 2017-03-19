
.macro b16ldi

	ldi t, high(int(@1+0x8000)-0x8000)
	sts @0 + 0, t
	ldi t, low(int(@1+0x8000)-0x8000)
	sts @0 + 1, t
	ldi t, int(frac(@1)*0x100+0x100)-0x100
	sts @0 + 2, t

.endmacro


.macro b16clr

	ldi t, 0
	sts @0 + 0, t
	sts @0 + 1, t
	sts @0 + 2, t

.endmacro


.macro b16set			;can be used to clear or set all three bytes to the same value

	sts @0 + 0, t
	sts @0 + 1, t
	sts @0 + 2, t

.endmacro


.macro b16neg

.def	Op1_2=r19
.def	Op1_1=r20
.def	Op1_0=r21

.def	Op2_2=r22
.def	Op2_1=r23
.def	Op2_0=r24

	lds Op2_2, @0 + 0
	lds Op2_1, @0 + 1
	lds Op2_0, @0 + 2

	clr Op1_0
	clr Op1_1
	clr Op1_2
	sub Op1_0, Op2_0
	sbc Op1_1, Op2_1
	sbc Op1_2, Op2_2

	sts @0 + 0, Op1_2
	sts @0 + 1, Op1_1
	sts @0 + 2, Op1_0

.undef	Op1_2
.undef	Op1_1
.undef	Op1_0

.undef	Op2_2
.undef	Op2_1
.undef	Op2_0

.endmacro


.macro b16nmov

.def	Op1_2=r19
.def	Op1_1=r20
.def	Op1_0=r21

.def	Op2_2=r22
.def	Op2_1=r23
.def	Op2_0=r24

	lds Op2_2, @1 + 0
	lds Op2_1, @1 + 1
	lds Op2_0, @1 + 2

	clr Op1_0
	clr Op1_1
	clr Op1_2
	sub Op1_0, Op2_0
	sbc Op1_1, Op2_1
	sbc Op1_2, Op2_2

	sts @0 + 0, Op1_2
	sts @0 + 1, Op1_1
	sts @0 + 2, Op1_0

.undef	Op1_2
.undef	Op1_1
.undef	Op1_0

.undef	Op2_2
.undef	Op2_1
.undef	Op2_0

.endmacro


.macro b16store			;X:Y  -> 16.8 register

	sts @0 + 0, xh
	sts @0 + 1, xl
	sts @0 + 2, yh

.endmacro


.macro b16storex		;X  -> 16.8 register (no fractions)

	sts @0 + 0, xh
	sts @0 + 1, xl

.endmacro


.macro b16load			;X:Y  <- 16.8 register

	lds xh, @0 + 0
	lds xl, @0 + 1
	lds yh, @0 + 2

.endmacro


.macro b16load2			;load two 16.8 registers

	lds xh, @0 + 0
	lds xl, @0 + 1
	lds yh, @0 + 2

	lds zh, @1 + 0
	lds zl, @1 + 1
	lds yl, @1 + 2

.endmacro


.macro b16loadx			;X  <- 16.8 register (no fractions)

	lds xh, @0 + 0
	lds xl, @0 + 1

.endmacro


.macro b16loadz			;Z  <- 16.8 register (no fractions)

	lds zh, @0 + 0
	lds zl, @0 + 1

.endmacro


.macro b16store_array		;reg -> reg[index]   b16store_array array, reg

.def	Op1_2=r19
.def	Op1_1=r20
.def	Op1_0=r21

.def	a=r22

	push zl
	push zh

	lds Op1_2, @1 + 0
	lds Op1_1, @1 + 1
	lds Op1_0, @1 + 2

	ldi zl, low(@0)
	ldi zh, high(@0)

	lds a, Index
	ldi t, 3
	mul a, t
	add zl, r0
	adc zh, r1

	st z+, Op1_2
	st z+, Op1_1
	st z+, Op1_0

	pop zh
	pop zl

.undef	Op1_2
.undef	Op1_1
.undef	Op1_0

.undef	a

.endmacro 


.macro b16load_array		;reg <- reg[index]   b16load_array reg, array

.def	Op1_2=r19
.def	Op1_1=r20
.def	Op1_0=r21

.def	a=r22

	push zl
	push zh

	ldi zl, low(@1)
	ldi zh, high(@1)

	lds a, Index
	ldi t, 3
	mul a, t
	add zl, r0
	adc zh, r1

	ld Op1_2, z+
	ld Op1_1, z+
	ld Op1_0, z+

	sts @0 + 0, Op1_2
	sts @0 + 1, Op1_1
	sts @0 + 2, Op1_0

	pop zh
	pop zl

.undef	Op1_2
.undef	Op1_1
.undef	Op1_0

.undef	a

.endmacro 



.macro b16add

.def	Op1_2=r19
.def	Op1_1=r20
.def	Op1_0=r21

.def	Op2_2=r22
.def	Op2_1=r23
.def	Op2_0=r24

	lds Op1_2, @1 + 0
	lds Op1_1, @1 + 1
	lds Op1_0, @1 + 2

	lds Op2_2, @2 + 0
	lds Op2_1, @2 + 1
	lds Op2_0, @2 + 2

	add Op1_0, Op2_0
	adc Op1_1, Op2_1
	adc Op1_2, Op2_2

	sts @0 + 0, Op1_2
	sts @0 + 1, Op1_1
	sts @0 + 2, Op1_0

.undef	Op1_2
.undef	Op1_1
.undef	Op1_0

.undef	Op2_2
.undef	Op2_1
.undef	Op2_0

.endmacro



.macro b16muli			;multiply XH:XL:YH (16.8 bit) with an 8.8 bit constant. DO NOT USE NEGATIVE NUMBERS!
				;WARNING: Result should not exceed 32767.99609375
.def	a1 = r22
.def	a2 = r23
.def	res1 = r2
.def	res2 = r3
.def	res3 = r4
.def	res4 = r6
.def	res5 = r7
.def	zero = r8

	ldi a2, low(int(@0+0x8000)-0x8000)
	ldi a1, int(frac(@0)*0x100+0x100)-0x100

	clr zero

	mul a2, xh		;MSB
	movw res5:res4, r1:r0

	mul a1, yh		;LSB
	movw res2:res1, r1:r0

	mul a2, xl
	mov res3, r0
	add res4, r1
//	adc res5, zero		;can be ignored since we'll only use res2, res3 and res4

	mul a2, yh
	add res2, r0
	adc res3, r1
	adc res4, zero
//	adc res5, zero		;can be ignored since we'll only use res2, res3 and res4

	mul a1, xh
	add res3, r0
	adc res4, r1
//	adc res5, zero		;can be ignored since we'll only use res2, res3 and res4

	mul a1, xl
	add res2, r0
	adc res3, r1
	adc res4, zero
//	adc res5, zero		;can be ignored since we'll only use res2, res3 and res4

	mov xh, res4		;result is divided by 256
	mov xl, res3
	mov yh, res2

.undef	a1
.undef	a2
.undef	res1
.undef	res2
.undef	res3
.undef	res4
.undef	res5
.undef	zero

.endmacro



.macro b16mul

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

	lds Op1_2, @1 + 0
	lds Op1_1, @1 + 1
	lds Op1_0, @1 + 2

	lds Op2_2, @2 + 0
	lds Op2_1, @2 + 1
	lds Op2_0, @2 + 2

	call multc		;code is moved out of the macro to optimize for size with very little speed penalty.

	sts @0 + 0, Result2
	sts @0 + 1, Result1
	sts @0 + 2, Result0

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

.endmacro


.macro b16sub
.def	Op1_2=r19
.def	Op1_1=r20
.def	Op1_0=r21

.def	Op2_2=r22
.def	Op2_1=r23
.def	Op2_0=r24

	lds Op1_2, @1 + 0
	lds Op1_1, @1 + 1
	lds Op1_0, @1 + 2

	lds Op2_2, @2 + 0
	lds Op2_1, @2 + 1
	lds Op2_0, @2 + 2

	sub Op1_0, Op2_0
	sbc Op1_1, Op2_1
	sbc Op1_2, Op2_2

	sts @0 + 0, Op1_2
	sts @0 + 1, Op1_1
	sts @0 + 2, Op1_0

.undef	Op1_2
.undef	Op1_1
.undef	Op1_0

.undef	Op2_2
.undef	Op2_1
.undef	Op2_0

.endmacro


.macro b16dec
.def	Op1_2=r19
.def	Op1_1=r20

	lds Op1_2, @0 + 0
	lds Op1_1, @0 + 1

	subi Op1_1, 1
	sbci Op1_2, 0

	sts @0 + 0, Op1_2
	sts @0 + 1, Op1_1

.undef	Op1_2
.undef	Op1_1

.endmacro


.macro b16inc
.def	Op1_2=r19
.def	Op1_1=r20

	lds Op1_2, @0 + 0
	lds Op1_1, @0 + 1

	ldi t,1
	add Op1_1, t
	clr t
	adc Op1_2, t

	sts @0 + 0, Op1_2
	sts @0 + 1, Op1_1

.undef	Op1_2
.undef	Op1_1

.endmacro


.macro b16fdivx

	ldi t, @0		;loop counter

	asr xh			;loop start
	ror xl
	dec t
	brne PC - 3

.endmacro


.macro b16fdiv

.def	Op1_2=r22
.def	Op1_1=r23
.def	Op1_0=r24

	lds Op1_2, @0 + 0
	lds Op1_1, @0 + 1
	lds Op1_0, @0 + 2

	ldi t, @1

	call b16fdiv_c

	sts @0 + 0, Op1_2
	sts @0 + 1, Op1_1
	sts @0 + 2, Op1_0

.undef	Op1_2
.undef	Op1_1
.undef	Op1_0

.endmacro


.macro b16fmul

.def	Op1_2=r22
.def	Op1_1=r23
.def	Op1_0=r24

	lds Op1_2, @0 + 0
	lds Op1_1, @0 + 1
	lds Op1_0, @0 + 2

	ldi t, @1

	call b16fmul_c

	sts @0 + 0, Op1_2
	sts @0 + 1, Op1_1
	sts @0 + 2, Op1_0

.undef	Op1_2
.undef	Op1_1
.undef	Op1_0

.endmacro


.macro b16mov

	lds t, @1 + 0
	sts @0 + 0, t
	lds t, @1 + 1
	sts @0 + 1, t
	lds t, @1 + 2
	sts @0 + 2, t

.endmacro


.macro b16mov2

	lds t, @2 + 0
	sts @0 + 0, t
	sts @1 + 0, t
	lds t, @2 + 1
	sts @0 + 1, t
	sts @1 + 1, t
	lds t, @2 + 2
	sts @0 + 2, t
	sts @1 + 2, t

.endmacro


.macro b16cmp

.def	Op1_2=r19
.def	Op1_1=r20
.def	Op1_0=r21

.def	Op2_2=r22
.def	Op2_1=r23
.def	Op2_0=r24

	lds Op1_2, @0 + 0
	lds Op1_1, @0 + 1
	lds Op1_0, @0 + 2

	lds Op2_2, @1 + 0
	lds Op2_1, @1 + 1
	lds Op2_0, @1 + 2

	cp  Op1_0, Op2_0
	cpc Op1_1, Op2_1
	cpc Op1_2, Op2_2

.undef	Op1_2
.undef	Op1_1
.undef	Op1_0

.undef	Op2_2
.undef	Op2_1
.undef	Op2_0

.endmacro


.macro b16mac8		;Multiply-and-accumulate    register T holds the signed (7 bit integer) factor and XH:XL:YH (16.8 bit) is the accumulator

.def	a1 = r21
.def	a2 = r22
.def	a3 = r23
.def	res1 = r2
.def	res2 = r3
.def	res3 = r4
.def	res4 = r5
.def	zero = r8

	lds a3, @0 + 0
	lds a2, @0 + 1
	lds a1, @0 + 2

	clr zero

	muls t, a3		;MSB
	movw res4:res3, r1:r0

	mulsu t, a1		;LSB
	sbc res4, zero
	movw res2:res1, r1:r0

	mulsu t, a2
	sbc res4, zero
	add res2, r0
	adc res3, r1
	adc res4, zero

	lsl res1		;round off
	adc res2, zero
	adc res3, zero
	adc res4, zero

	add yh, res2		;accumulate
	adc xl, res3
	adc xh, res4

.undef	a1
.undef	a2
.undef	a3
.undef	res1
.undef	res2
.undef	res3
.undef	res4
.undef	zero

.endmacro


.macro b16mac		;Multiply-and-accumulate    xh:xl.yh is the accumulator

.def	Op1_2=r19
.def	Op1_1=r20
.def	Op1_0=r21

	lds Op1_2, @0 + 0
	lds Op1_1, @0 + 1
	lds Op1_0, @0 + 2

	call macc	 ;code is moved out of the macro and into miscsubs.asm to optimize for size with very little speed penalty.

.undef	Op1_2
.undef	Op1_1
.undef	Op1_0

.endmacro


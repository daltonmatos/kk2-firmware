
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


.macro b16set		;can be used to clear or set all three bytes to the same value

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


.macro b16load			;X:Y  <- 16.8 register

	lds xh, @0 + 0
	lds xl, @0 + 1
	lds yh, @0 + 2

.endmacro


.macro b16loadz			;Z  <- 16.8 register (no decimals)

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

	cp  Op1_0,Op2_0
	cpc Op1_1,Op2_1
	cpc Op1_2,Op2_2

.undef	Op1_2
.undef	Op1_1
.undef	Op1_0

.undef	Op2_2
.undef	Op2_1
.undef	Op2_0

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




.global b168_pack
b168_pack:
  movw Z, r24
  ld r20, Z+ /* high */
  ld r19, Z+ /* low */
  ld r18, Z+ /* fraction */

  clr r25
  mov r24, r20 /* high */
  mov r23, r19 /* low */
  mov r22, r18 /* fraction */
  ret

.global b168fadd

b168fadd:
  movw r30, r24

  ld r20, Z+
  ld r19, Z+

  add r19, r22
  adc r20, r23

  movw r30, r24
  st Z+, r20
  st Z+, r19
  ret

.global b168_add
b168_add:

  push r17
  push r16
  push r15
  push r14
  push r13
  push r12

  movw r30, r22
  ld r17, Z+
  ld r16, Z+
  ld r15, Z+

  movw r30, r20
  ld r14, Z+
  ld r13, Z+
  ld r12, Z+
  
  add r17, r14
  adc r16, r13
  adc r15, r12

  movw r30, r24
  st Z+, r17
  st Z+, r16
  st Z+, r15

  pop r12
  pop r13
  pop r14
  pop r15
  pop r16
  pop r17

  ret


.global b168fmul
b168fmul:
  movw r30, r24
  ld r20, Z+
  ld r19, Z+
  ld r18, Z+
fmul_loop:
	lsl r18
	rol r19
	rol r20
	dec r22
	brne fmul_loop	

  movw r30, r24
  st Z+, r20
  st Z+, r19
  st Z+, r18
	ret

.global b168fdiv
b168fdiv:
  movw r30, r24
  ld r20, Z+
  ld r19, Z+
  ld r18, Z+

b16fdiv_loop:
	asr r20
	ror r19
	ror r18
	dec r22
	brne b16fdiv_loop

	adc r18, r22		;round off
	adc r19, r22
	adc r20, r22
  
  movw r30, r24
  st Z+, r20
  st Z+, r19
  st Z+, r18
	
	ret

.global b168_mul
b168_mul:
#define	Op1_2 r17
#define	Op1_1 r18
#define	Op1_0 r19

#define	Op2_2 r14
#define	Op2_1 r15
#define	Op2_0 r16

#define	Result2 r26
#define	Result1 r27
#define	Result0 r28

#define	Sign r3
#define t r29

  push r3
  push r14
  push r15
  push r16
  push r17
  push r28
  push r29

  movw r30, r22

  ld Op1_2, Z+
  ld Op1_1, Z+
  ld Op1_0, Z+


  movw r30, r20
  ld Op2_2, Z+
  ld Op2_1, Z+
  ld Op2_0, Z+

  call __multc		;code is moved out of the macro to optimize for size with very little speed penalty.

  movw r30, r24
  st Z+, Result2
  st Z+, Result1
  st Z+, Result0

  pop r29
  pop r28
  pop r17
  pop r16
  pop r15
  pop r14
  pop r3
#undef	Op1_2
#undef	Op1_1
#undef	Op1_0
#
#undef	Op2_2
#undef	Op2_1
#undef	Op2_0
#
#undef	Result2
#undef	Result1
#undef	Result0
#undef	Sign

  ret

__multc:	
#define	Op1_2 r17
#define	Op1_1 r18
#define	Op1_0 r19

#define	Op2_2 r14
#define	Op2_1 r15
#define	Op2_0 r16

#define	Result2 r26
#define	Result1 r27
#define	Result0 r28

#define	Sign r3
#define t r29
  mov Sign, Op1_2		;calculate result sign
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
	adc Result1, t
	adc Result2, t

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

mul3:	
#undef	Op1_2
#undef	Op1_1
#undef	Op1_0
#
#undef	Op2_2
#undef	Op2_1
#undef	Op2_0
#
#undef	Result2
#undef	Result1
#undef	Result0
#undef	Sign

  ret


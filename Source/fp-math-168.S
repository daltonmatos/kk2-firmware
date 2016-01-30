


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



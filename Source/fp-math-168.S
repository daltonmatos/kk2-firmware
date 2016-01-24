


.global b168_const_add

b168_const_add:
  movw r30, r24

  ld r20, Z+
  ld r19, Z+

  add r19, r22
  adc r20, r23

  movw r30, r24
  st Z+, r20
  st Z+, r19
  ret

; macros to save/restore the right registers when calling C and when called from C
; Details on the calling convention and rules: http://www.atmel.com/images/doc42055.pdf 

#ifndef BIND_WRAPPERS_ASM
#define BIND_WRAPPERS_ASM


.macro push_r18_to_r27_r30_r31
  push r18
  push r19
  push r20
  push r21
  push r22
  push r23
  push r24
  push r25
  push r26
  push r27
  push r30
  push r31
.endmacro

.macro pop_r18_to_r27_r30_r31
  pop r31
  pop r30
  pop r27
  pop r26
  pop r25
  pop r24
  pop r23
  pop r22
  pop r21
  pop r20
  pop r19
  pop r18
.endmacro


.macro safe_call_c
  push_all
  clr r1
  call @0
  pop_all
.endmacro


.macro push_r2_to_r17_r28_r29
  push r2
  push r3
  push r4
  push r5
  push r6
  push r7
  push r8
  push r9
  push r10
  push r11
  push r12
  push r13
  push r14
  push r15
  push r16
  push r17
  push r28
  push r29
.endmacro

.macro pop_r2_to_r17_r28_r29
  pop r29
  pop r28
  pop r17
  pop r16
  pop r15
  pop r14
  pop r13
  pop r12
  pop r11
  pop r10
  pop r9
  pop r8
  pop r7
  pop r6
  pop r5
  pop r4
  pop r3
  pop r2
.endmacro

.macro safe_called_from_c
  push_r2_to_r17_r28_r29
  call @0
  pop_r2_to_r17_r28_r29
  clr r1
.endmacro



.macro push_all
  push r0
  push r1
  push_r2_to_r17_r28_r29
  push_r18_to_r27_r30_r31
.endmacro

.macro pop_all
  pop_r18_to_r27_r30_r31
  pop_r2_to_r17_r28_r29
  pop r1
  pop r0
.endmacro

.macro push_for_call_return_value
  push r0
  push r1
  push r2
  push r3
  push r4
  push r5
  push r6
  push r7
  push r8
  push r9
  push r10
  push r11
  push r12
  push r13
  push r14
  push r15
  push r16
  push r17
  push r18
  push r19
  push r20
  push r21
  push r22
  push r23
  push r26
  push r27
  push r28
  push r29
  push r30
  push r31
.endmacro

.macro pop_for_call_return_value
  pop r31
  pop r30
  pop r29
  pop r28
  pop r27
  pop r26
  pop r23
  pop r22
  pop r21
  pop r20
  pop r19
  pop r18
  pop r17
  pop r16
  pop r15
  pop r14
  pop r13
  pop r12
  pop r11
  pop r10
  pop r9
  pop r8
  pop r7
  pop r6
  pop r5
  pop r4
  pop r3
  pop r2
  pop r1
  pop r0
.endmacro

#endif

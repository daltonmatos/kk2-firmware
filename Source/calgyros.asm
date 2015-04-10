

CalGyros:

	ldi zl, 16

	b16clr GyroRollZero
	b16clr GyroPitchZero
	b16clr GyroYawZero

caa1:	call AdcRead

	b16add GyroRollZero, GyroRollZero, GyroRoll
	b16add GyroPitchZero, GyroPitchZero, GyroPitch
	b16add GyroYawZero, GyroYawZero, GyroYaw

	dec zl
	breq caa2
	rjmp caa1

caa2:	b16fdiv GyroRollZero, 4
	b16fdiv GyroPitchZero, 4
	b16fdiv GyroYawZero, 4

	ret






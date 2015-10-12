

sin:	b832mov Sine, Theta		;Small-angle approximation of Sine
	ret

cos:	b832mul TempA, Theta, Theta	;Small-angle approximation of Cosine
	b832fdiv TempA, 1
	b832ldi TempB, 1
	b832sub Cosine, TempB, TempA
	ret


	;---

thetascale:
	b832store Theta			;store in 8.32

;	b832ldi TempA, 3.03		;scale with magic number to match integrated gyro angle with real world angle
	b832mul Theta, Theta, MagicNumber
	ret


	;--- transfer between 16.8 <--> 8.24 , right align, sign extend  ---

transfer168832:
	clr zh
transfer168824:
transfer824168:
transfer832168:

	mov yl, yh			;right align
	mov yh, xl
	mov xl, xh

	tst xh				;sign extend
	brpl tra1
	ser xh
	ret

tra1:	clr xh
	ret
	

	;--- Rotate vector[VectorA ,VectorB] with angle Theta

RotateVector:
	rcall sin
	rcall cos

	b832mul VectorNewA, VectorA, Cosine	;VectorNewA = VectorA * cos(Theta) - VectorB * sin(Theta)
	b832mul TempA, VectorB, Sine
	b832sub VectorNewA, VectorNewA, TempA

	b832mul VectorNewB, VectorA, Sine	;VectorNewB = VectorA * sin(Theta) + VectorB * cos(Theta)
	b832mul TempA, VectorB, Cosine
	b832add VectorNewB, VectorNewB, TempA

	ret



	;--- Rotate 3D vector vector[VectorX, VectorY, VectorZ]

Rotate3dVector:

	; Get the time since we were last here.  X = 6250 for 1/400sec = 2.5msecs
	cli
	lds xl, tcnt1l			;X = TCNT1 - TrigTimer, TrigTimer = TCNT1
	lds xh, tcnt1h
	sei
	lds zl, TrigTimerL
	lds zh, TrigTimerH
	sts TrigTimerL, xl
	sts TrigTimerH, xh
	sub xl, zl
	sbc xh, zh
	brpl trig1

	no_offset_ldz 0				;X = ABS(X)
	sub zl, xl
	sbc zh, xh
	movw x, z

trig1:	clr yh				;X = X / 16        
	lsr xh
	ror xl
	ror yh
	lsr xh
	ror xl
	ror yh
	lsr xh
	ror xl
	ror yh
	lsr xh
	ror xl
	ror yh
	clr yl
	clr zh				;now we have the delta time in an 8.32 format (Original Timer Value X/4096)

	b832store MagicNumberTime
	b832mul MagicNumber, MagicNumberTime, MagicNumberMult	;calculate the Magic Number based on the delta time


	b16load GyroPitchVC		;rotate around X axis (pitch)	
	rcall transfer168832
	rcall thetascale

	b832mov VectorA, VectorY
	b832mov VectorB, VectorZ
	rcall RotateVector
	b832mov VectorY, VectorNewA
	b832mov VectorZ, VectorNewB


	b16load GyroRollVC		;rotate around Y axis (roll)
	rcall transfer168832
	rcall thetascale

	b832mov VectorA, VectorX
	b832mov VectorB, VectorZ
	rcall RotateVector
	b832mov VectorX, VectorNewA
	b832mov VectorZ, VectorNewB


	b16load GyroYaw			;rotate around Z axis (yaw)
	rcall transfer168832
	rcall thetascale

	b832mov VectorA, VectorX
	b832mov VectorB, VectorY
	rcall RotateVector
	b832mov VectorX, VectorNewA
	b832mov VectorY, VectorNewB

	ret


	;--- Get length of 3D vector vector[VectorX, VectorY, VectorZ] ---

Lenght3dVector:
	
	b832mul TempA, VectorX, VectorX
	b832mul TempB, VectorY, VectorY
	b832add TempA, TempA, TempB
	b832mul TempB, VectorZ, VectorZ
	b832add LengthVector, TempA, TempB

	ret


	;--- extraxt Euler angles roll/pitch from 3D vector vector[VectorX, VectorY, VectorZ] ---

ExtractEulerAngles:

	b832mov TempD, VectorX
	rcall ext2
	b16mov EulerAngleRoll, Angle

	b832mov TempD, VectorY
	rcall ext2
	b16mov EulerAnglePitch, Angle

	ret


ext2:	;b824mul TempA, TempD, TempD		;approximation of a quarter circle (lol :-)

	b832ldi TempB, 90			;convert to degrees (0 to 90)
	b832mul TempA, TempD, TempB

	b832load TempA
	rcall transfer832168
	b16store Angle

;	b824load VectorZ			;mirror on X/Y plane (90 to 180)
;	tst xh
;	brpl ext3

;	b16ldi Temp, 180
;	b16sub Angle, Temp, Angle
;ext3:

;	b824load TempD				;mirror on the Z axis (0 to -180)
;	tst xh
;	brpl ext1
;	b16ldi Temp, -1
;	b16mul Angle, Angle, Temp
;ext1:

	ret






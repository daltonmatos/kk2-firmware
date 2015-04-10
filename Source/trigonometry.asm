

sin:	b824mov Sine, Theta		;Small-angle approximation of Sine
	ret

cos:	b824mul TempA, Theta, Theta	;Small-angle approximation of Cosine
	b824fdiv TempA, 1
	b824ldi TempB, 1
	b824sub Cosine, TempB, TempA
	ret


	;---

thetascale:
	b824store Theta			;store in 8.24

	b824ldi TempA, 3.03		;scale with magic number to match integrated gyro angle with real world angle
	b824mul Theta, Theta, TempA
	ret


	;--- transfer between 16.8 <--> 8.24 , right align, sign extend  ---

transfer168824:
transfer824168:

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

	b824mul VectorNewA, VectorA, Cosine	;VectorNewA = VectorA * cos(Theta) - VectorB * sin(Theta)
	b824mul TempA, VectorB, Sine
	b824sub VectorNewA, VectorNewA, TempA

	b824mul VectorNewB, VectorA, Sine	;VectorNewB = VectorA * sin(Theta) + VectorB * cos(Theta)
	b824mul TempA, VectorB, Cosine
	b824add VectorNewB, VectorNewB, TempA
	
	ret
	


	;--- Rotate 3D vector vector[VectorX, VectorY, VectorZ]
	
Rotate3dVector:
	
	b16load GyroPitchVC		;rotate around X axis (pitch)	
	rcall transfer168824
	rcall thetascale

	b824mov VectorA, VectorY
	b824mov VectorB, VectorZ
	rcall RotateVector
	b824mov VectorY, VectorNewA
	b824mov VectorZ, VectorNewB


	b16load GyroRollVC		;rotate around Y axis (roll)
	rcall transfer168824
	rcall thetascale

	b824mov VectorA, VectorX
	b824mov VectorB, VectorZ
	rcall RotateVector
	b824mov VectorX, VectorNewA
	b824mov VectorZ, VectorNewB


	b16load GyroYaw			;rotate around Z axis (yaw)
	rcall transfer168824
	rcall thetascale

	b824mov VectorA, VectorX
	b824mov VectorB, VectorY
	rcall RotateVector
	b824mov VectorX, VectorNewA
	b824mov VectorY, VectorNewB

	ret

	
	;--- Get length of 3D vector vector[VectorX, VectorY, VectorZ] ---

Lenght3dVector:
	
	b824mul TempA, VectorX, VectorX
	b824mul TempB, VectorY, VectorY
	b824add TempA, TempA, TempB
	b824mul TempB, VectorZ, VectorZ
	b824add LengthVector, TempA, TempB
	
	ret


	;--- extraxt Euler angles roll/pitch from 3D vector vector[VectorX, VectorY, VectorZ] ---

ExtractEulerAngles:
	
	b824mov TempD, VectorX
	rcall ext2
	b16mov EulerAngleRoll, Angle

	b824mov TempD, VectorY
	rcall ext2
	b16mov EulerAnglePitch, Angle

	ret


ext2:	;b824mul TempA, TempD, TempD		;approximation of a quarter circle (lol :-)

	b824ldi TempB, 90			;convert to degrees (0 to 90)
	b824mul TempA, TempD, TempB
	
	b824load TempA
	rcall transfer824168
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






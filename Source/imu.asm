
Imu:	;--- SL Stick Mixing ---

	rvbrflagtrue flagSlStickMixing, im50		;skip this section if SL Stick Mixing is off
	rjmp im55

im50:	b16clr Temp					;is the roll stick value positive?
	b16mov Temper, RxRoll
	b16cmp Temper, Temp
	brge im51

	b16neg Temper					;no, make it positive
im51:	b16cmp RxPitch, Temp				;is the pitch stick value positive?
	brlt im52

	b16mov Temp, RxPitch				;yes
	rjmp im53

im52:	b16mov Temp, RxPitch				;no, make it positive
	b16neg Temp

im53:	b16cmp Temper, Temp				;compare the absolute roll and pitch values
	brge im54
	
	b16mov Temper, Temp				;SL P gain will be reduced based on the highest value
im54:	b16mul Temp, Temper, SelflevelPgainRate
	b16sub SelfLevelPgain, SelfLevelPgainOrg, Temp
	brge im55

	b16clr SelfLevelPgain				;cannot use negative gain values
im55:


	;--- Get Sensor Data ---

	call AdcRead					;Calculate gyro output
	b16sub GyroRoll, GyroRoll, GyroRollZero
	b16sub GyroPitch, GyroPitch, GyroPitchZero
	b16sub GyroYaw, GyroYaw, GyroYawZero

	b16sub AccX, AccX, AccXZero			;remove offset from Acc
	b16sub AccY, AccY, AccYZero
	b16sub AccZ, AccZ, AccZZero

	b16add AccX, AccX, AccTrimPitch			;add trim
	b16add AccY, AccY, AccTrimRoll


	b16ldi Temper, 0.03				;SF LP filter the accerellometers

	b16sub Error, AccX, AccXfilter
	b16mul Error, Error, Temper
	b16add AccXfilter, AccXfilter, Error

	b16sub Error, AccY, AccYfilter
	b16mul Error, Error, Temper
	b16add AccYfilter, AccYfilter, Error

	b16sub Error, AccZ, AccZfilter
	b16mul Error, Error, Temper
	b16add AccZfilter, AccZfilter, Error


	;---  Calculate tilt angle with the acc. (this approximation is good to about 20 degrees) ---

	b16ldi Temp, 0.7
	b16mul AccAngleRoll, AccYfilter, Temp
	b16mul AccAnglePitch, AccXfilter, Temp


	;--- Add correction data to gyro inputs based on difference between Euler angles and acc angles ---

	b16mov GyroRollVC, GyroRoll			;fork gyrovalues to be used in 3D vector calc.
	b16mov GyroPitchVC, GyroPitch

	b16ldi Temp, 20					;skip correction at angles greater than +-20
	b16cmp AccAnglePitch, Temp
	longbrge im41
	b16cmp AccAngleRoll, Temp
	longbrge im41

	b16neg Temp
	b16cmp AccAnglePitch, Temp
	longbrlt im41
	b16cmp AccAngleRoll, Temp
	longbrlt im41

	b16ldi Temp, 60					;skip correction if vertical accelleration is outside 0.5 to 1.5 G
	b16cmp AccZfilter, Temp
	longbrge im41

	b16neg Temp
	b16cmp AccZfilter, Temp
	longbrlt im41
	 
	b16sub Temp, EulerAngleRoll, AccAngleRoll	;add roll correction
	b16fdiv Temp, 2
	b16add GyroRollVC, GyroRollVC, Temp

	b16sub Temp, EulerAnglePitch, AccAnglePitch	;add pitch correction
	b16fdiv Temp, 2
	b16add GyroPitchVC, GyroPitchVC, Temp

im41:

	;--- Rotate up-direction 3D vector with gyro inputs ---

	call Rotate3dVector

	call Lenght3dVector
	
	call ExtractEulerAngles



	;--- Calculate Stick and Gyro  ---

	rvbrflagfalse flagThrottleZero, im7	;reset integrals if throttle closed 
	b16clr IntegralRoll
	b16set IntegralPitch
	b16set IntegralYaw

im7:	b16fdiv RxRoll, 4			;right align to the 16.4 multiply usable bit limit
	b16fdiv RxPitch, 4
	b16fdiv RxYaw, 4

	b16mul RxRoll, RxRoll, StickScaleRoll	;scale stick inputs
	b16mul RxPitch, RxPitch, StickScalePitch
	b16mul RxYaw, RxYaw, StickScaleYaw
	b16mul RxThrottle, RxThrottle, StickScaleThrottle


	;----- Self level ----

	rvbrflagtrue flagSlOn, im60		;jump if normal SL mode is active
	rvbrflagtrue flagSlStickMixing, im31	;jump if SL Stick Mixing mode is active
	rjmp im30				;jump if both SL modes are inactive


im31:	;--- SL Stick Mixing, Pt. 2 ---

	b16mul CommandRoll, RxRoll, MixFactor	;manipulate pitch and roll inputs using the special "Stick Scaling" factor (1.0 = 100%)
	b16mul CommandPitch, RxPitch, MixFactor


im60:	;--- Roll Axis Self-level P ---

	b16neg RxRoll
	
	b16fdiv RxRoll, 1

	b16sub Error, EulerAngleRoll, RxRoll	;calculate error
	b16fdiv Error, 4

	b16mul Value, Error, SelflevelPgain	;Proportional gain

	b16mov LimitV, SelflevelPlimit		;Proportional limit
	rcall Limiter
	b16mov RxRoll, Value

	b16fdiv RxRoll, 1


	;--- Pitch Axis Self-level P ---

	b16neg RxPitch
	
	b16fdiv RxPitch, 1

	b16sub Error, EulerAnglePitch, RxPitch	;calculate error
	b16fdiv Error, 4

	b16mul Value, Error, SelflevelPgain	;Proportional gain

	b16mov LimitV, SelflevelPlimit		;Proportional limit
	rcall Limiter
	b16mov RxPitch, Value

	b16fdiv RxPitch, 1


	;--- SL Stick Mixing, Pt. 3 ---

	rvbrflagfalse flagSlStickMixing, im30
	b16add RxRoll, RxRoll, CommandRoll	;final SL stick mixing
	b16add RxPitch, RxPitch, CommandPitch


im30:	;--- Roll Axis PI ---

	b16sub Error, GyroRoll, RxRoll		;calculate error
	b16fdiv Error, 1

	b16mul Value, Error, PgainRoll		;Proportional gain

	b16mov LimitV, PlimitRoll		;Proportional limit
	rcall Limiter
	b16mov CommandRoll, Value

	b16fdiv Error, 3
	b16mul Temp, Error, IgainRoll		;Integral gain
	b16add Value, IntegralRoll, Temp

	b16mov LimitV, IlimitRoll 		;Integral limit
	rcall Limiter
	b16mov IntegralRoll, Value

	b16add CommandRoll, CommandRoll, IntegralRoll


	;--- Pitch Axis PI ---

	b16sub Error, RxPitch, GyroPitch	;calculate error
	b16fdiv Error, 1

	b16mul Value, Error, PgainPitch		;Proportional gain

	b16mov LimitV, PlimitPitch		;Proportional limit
	rcall Limiter
	b16mov CommandPitch, Value

	b16fdiv Error, 3
	b16mul Temp, Error, IgainPitch		;Integral gain
	b16add Value, IntegralPitch, Temp

	b16mov LimitV, IlimitPitch 		;Integral limit
	rcall Limiter
	b16mov IntegralPitch, Value

	b16add CommandPitch, CommandPitch, IntegralPitch


	;--- Yaw Axis PI ---

	b16sub Error, RxYaw, GyroYaw		;calculate error
	b16fdiv Error, 1

	b16mul Value, Error, PgainYaw		;Proportional gain

	b16mov LimitV, PlimitYaw		;Proportional limit
	rcall Limiter
	b16mov CommandYaw, Value

	b16fdiv Error, 3
	b16mul Temp, Error, IgainYaw		;Integral gain
	b16add Value, IntegralYaw, Temp

	b16mov LimitV, IlimitYaw 		;Integral limit
	rcall Limiter
	b16mov IntegralYaw, Value

	b16add CommandYaw, CommandYaw, IntegralYaw
	ret



	;--- Limiter ---

Limiter:

	b16cmp Value, LimitV	;high limit
	brlt lim5
	b16mov Value, LimitV

lim5:	b16neg LimitV		;low limit
	b16cmp Value, LimitV
	brge lim6
	b16mov Value, LimitV

lim6:	ret





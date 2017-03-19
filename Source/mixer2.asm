


Mixer:						;mixer ratio at 100% mixvalue is 0.390625. To give a full trottle signal the input must be 12800.0

	rvbrflagfalse flagArmed, mix11
	rvbrflagfalse flagMotorSpin, mix11

	b16load2 MotorSpinLevel, RxThrottle	;set minimum throttle input when the Motor Spin feature is active
	cp yl, yh
	cpc zl, xl
	cpc zh, xh
	brge mix11

	b16store RxThrottle

mix11:	ldi yl, 50				;will scale MixvalueOffset from [-100, 100] to [-5000, 5000]

	ldz RamMixerTable + 0			;channel 1
	rcall mix1
	b16store Out1
	b16mov Offset1, Mixvalue

	ldz RamMixerTable + 8			;channel 2
	rcall mix1
	b16store Out2
	b16mov Offset2, Mixvalue

	ldz RamMixerTable + 16			;channel 3
	rcall mix1
	b16store Out3
	b16mov Offset3, Mixvalue

	ldz RamMixerTable + 24			;channel 4
	rcall mix1
	b16store Out4
	b16mov Offset4, Mixvalue

	ldz RamMixerTable + 32			;channel 5
	rcall mix1
	b16store Out5
	b16mov Offset5, Mixvalue

	ldz RamMixerTable + 40			;channel 6
	rcall mix1
	b16store Out6
	b16mov Offset6, Mixvalue

	ldz RamMixerTable + 48			;channel 7
	rcall mix1
	b16store Out7
	b16mov Offset7, Mixvalue

	ldz RamMixerTable + 56			;channel 8
	rcall mix1
	b16store Out8
	b16mov Offset8, Mixvalue
	ret



mix1:	clr yh
	ldd xl, Z + MixvalueOffset
	muls xl, yl
	movw xh:xl, r1:r0
	b16store MixValue

	ldd t, Z + MixValueThrottle
	b16mac8 RxThrottle
	 
	ldd t, Z + MixValueRoll
	b16mac8 CommandRoll

	ldd t, Z + MixValuePitch
	b16mac8 CommandPitch

	ldd t, Z + MixValueYaw
	b16mac8 CommandYaw
	ret



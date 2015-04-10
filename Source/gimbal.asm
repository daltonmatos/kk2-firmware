
.def Item = r17

GimbalSettings:

	call LoadMixerTable		;display a warning if output type on M7/M8 is set to 'ESC'
	call UpdateOutputTypeAndRate
	lds t, OutputTypeBitmask
	andi t, 0xC0
	breq gbs11

	rcall ShowEscWarning

gbs11:	call LcdClear6x8

	ldz cam1*2			;roll gain
	call PrintString
	ldz eeCamRollGain
	rcall PrintGimbalValue

	ldz cam3*2			;pitch gain
	call PrintString
	ldz eeCamPitchGain
	rcall PrintGimbalValue

	ldz cam5*2			;mixing (none or differential)
	call PrintString
	lrv X1, 84
	call PrintColonAndSpace
	lds t, CamServoMixing
	andi t, 0x01
	ldz mix*2
	call PrintFromStringArray

	lrv X1, 0			;roll lock position
	rvadd Y1, 9
	ldz gbs4*2
	call PrintString
	ldz eeCamRollHomePos
	rcall PrintGimbalValue

	ldz gbs5*2			;pitch lock position
	call PrintString
	ldz eeCamPitchHomePos
	rcall PrintGimbalValue

	;footer
	call PrintStdFooter

	;print selector
	ldzarray gbs7*2, 4, Item
	call PrintSelector

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08			;BACK?
	brne gbs8
	ret	

gbs8:	cpi t, 0x04			;PREV?
	brne gbs9

	dec Item
	brpl gbs10

	ldi Item, 4
gbs10:	rjmp gbs11	

gbs9:	cpi t, 0x02			;NEXT?
	brne gbs12

	inc Item
	cpi Item, 5
	brlt gbs13

	clr Item

gbs13:	rjmp gbs11	

gbs12:	cpi t, 0x01			;CHANGE?
	brne gbs13

	cpi Item, 2
	brne gbs30

	lds xl, CamServoMixing		;toggle mixing mode
	ser t
	eor xl, t
	sts CamServoMixing, xl
	ldz eeCamServoMixing
	call StoreEePVariable8
	rjmp gbs11

gbs30:	tst Item
	brne gbs31

	ldz eeCamRollGain

gbs33:	ldy -9000			;edit gain value
	ldx 9000
	rcall EditGimbalValue
	rjmp gbs11

gbs31:	cpi Item, 1
	brne gbs32

	ldz eeCamPitchGain
	rjmp gbs33

gbs32:	cpi Item, 3
	brne gbs35

	ldz eeCamRollHomePos

gbs34:	ldy -1000			;edit 'Home' position value
	ldx 1000
	rcall EditGimbalValue
	rjmp gbs11

gbs35:	ldz eeCamPitchHomePos
	rjmp gbs34



	;--- Edit gimbal value ---

EditGimbalValue:			;input parameters: X=upper limit, Y=lower limit, Z=EEPROM variable

	pushz
	pushx
	call GetEePVariable16
	popz
	call NumberEdit
	mov xl, r0
	mov xh, r1
	popz
	call StoreEePVariable16
	ret



	;--- Print 16bit value and set cursor position ---

PrintGimbalValue:

	lrv X1, 84
	call PrintColonAndSpace
	call GetEePVariable16
	call Print16Signed
	lrv X1, 0
	rvadd Y1, 9
	ret




gbs4:	.db "Home Pos Roll", 0
gbs5:	.db "Home Pos Pitch", 0, 0

gbs7:	.db 95, 0, 122, 9
	.db 95, 9, 122, 18
	.db 95, 18, 122, 27
	.db 95, 27, 127, 36
	.db 95, 36, 127, 45



.undef Item






GimbalStab:

	b16clr Temp					;gimbal will be deactivated if both gains are zero. This allows OCTOs to be used
	b16cmp CamRollGain, Temp
	breq gbs26
	rjmp gbs22

gbs26:	b16cmp CamPitchGain, Temp
	brne gbs22
	ret

gbs22:	lds t, TuningMode				;use center offset position when tuning mode is active
	tst t
	breq gbs21

	b16clr RxAux2
	b16clr RxAux3

gbs21:	lds t, Aux4SwitchPosition			;go to home position if the AUX4 switch is in position #3
	cpi t, 2
	brne gbs27

	b16mov RxAux2, CamPitchHomePos
	b16mov RxAux3, CamRollHomePos
	b16clr CamPitch
	b16clr CamRoll

gbs27:	b16ldi Temp, 1000.0				;utilize the full input range.by adding 1000 and dividing by 2
	b16add RxAux2, RxAux2, Temp
	b16add RxAux3, RxAux3, Temp

	b16ldi Temp, 2.5				; = 5 / 2  (modified to utilize the full input range)
	b16mul CamPitchOffset, RxAux2, Temp
	b16mul CamRollOffset, RxAux3, Temp

	lds t, Aux4SwitchPosition			;update gimbal roll and pitch values only if the gimbal is unlocked (i.e. AUX4 switch position #2)
	cpi t, 1
	brne gbs25

	b16mul CamRoll, EulerAngleRoll, CamRollGain	;calculate camera angles
	b16mul CamPitch, EulerAnglePitch, CamPitchGain

gbs25:	rvbrflagtrue CamServoMixing, gbs20
	rjmp gbs24					;jump for regular output

gbs20:	b16mov Temp, CamRoll				;differential mixing
	b16sub CamRoll, CamRoll, CamPitch
	b16add CamPitch, CamPitch, Temp

	b16mov Temp, CamRollOffset
	b16sub CamRollOffset, CamRollOffset, CamPitchOffset
	b16add CamPitchOffset, CamPitchOffset, Temp

	b16ldi Temp, 2500.0				; = 1000 * 2.5 (compensate for differential offset)
	b16add CamRollOffset, CamRollOffset, Temp
	b16sub CamPitchOffset, CamPitchOffset, Temp

gbs24:	b16add Out7, CamRoll, CamRollOffset		;outputs will be set only when FC is armed and throttle is applied
	b16add Out8, CamPitch, CamPitchOffset

	b16mov Offset7, Out7				;makes it possible to adjust the gimbal in 'SAFE' mode also
	b16mov Offset8, Out8				;(offset is used in 'SAFE' mode and in 'ARMED' mode until throttle is applied)
	ret

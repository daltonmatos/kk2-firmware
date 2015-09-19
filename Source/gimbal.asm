
.def Item = r17
.def Xoffset = r18

GimbalSettings:

	call LoadMixerTable		;display a warning if output type on M7/M8 is set to 'ESC'
	call UpdateOutputTypeAndRate
	lds t, OutputTypeBitmask
	andi t, 0xC0
	breq gbs11

	rcall ShowEscWarning

gbs11:	call LcdClear6x8

	;labels
	ldi t, 5
	ldz cam6*2
	call PrintStringArray

	;values
	lrv Y1, 1
	ldi Xoffset, 72
	ldz eeCamRollGain
	rcall PrintGimbalValue		;roll gain
	rcall PrintGimbalValue		;roll offset
	rcall PrintGimbalValue		;pitch gain
	rcall PrintGimbalValue		;pitch offset

	sts X1, Xoffset			;mixing (none or differential)
	call PrintColonAndSpace
	ldz eeCamServoMixing
	call GetEePVariable8
	sts CamServoMixing, t
	andi t, 0x01
	ldz mix*2
	call PrintFromStringArray

	;footer
	lrv X1, 0
	lrv Y1, 57
	ldz bckmore*2
	call PrintString
	ldz nxtchng*2
	call PrintString

	;print selector
	ldzarray gbs7*2, 4, Item
	call PrintSelector

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08			;BACK?
	brne gbs10
	ret	

gbs10:	cpi t, 0x04			;MORE?
	brne gbs9

	rcall Gimbal2			;go to the second screen
	rjmp gbs11	

gbs9:	cpi t, 0x02			;NEXT?
	brne gbs12

	inc Item
	cpi Item, 5
	brlt gbs13

	clr Item

gbs13:	rjmp gbs11	

gbs12:	cpi t, 0x01			;CHANGE?
	brne gbs13

	cpi Item, 4
	brne gbs30

	lds xl, CamServoMixing		;toggle mixing mode
	com xl
	sts CamServoMixing, xl
	ldz eeCamServoMixing
	call StoreEePVariable8
	rjmp gbs11

gbs30:	ldzarray eeCamRollGain, 2, Item	;edit gain or offset value
	ldy -9000			;lower limit
	ldx 9000			;upper limit
	rcall EditGimbalValue
	rjmp gbs11



	;--- Second screen ---

Gimbal2:

	clr Item
	ldi Xoffset, 84

gbs201:	call LcdClear6x8

	ldi t, 2			;print all text labels first
	ldz gbs6*2
	call PrintStringArray

	lrv Y1, 1			;print values
	ldz eeCamRollHomePos
	rcall PrintGimbalValue		;roll home position
	rcall PrintGimbalValue		;pitch home position

	;footer
	call PrintStdFooter

	;print selector
	ldzarray gbs8*2, 4, Item
	call PrintSelector

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08			;BACK?
	brne gbs220

	clr Item			;return to the first screen
	ret

gbs220:	cpi t, 0x04			;PREV?
	brne gbs223

gbs221:	dec Item
	andi Item, 0x01

gbs222:	rjmp gbs201

gbs223:	cpi t, 0x02			;NEXT?
	breq gbs221

	cpi t, 0x01			;CHANGE?
	brne gbs222

	ldzarray eeCamRollHomePos, 2, Item
	ldy -1000			;lower limit
	ldx 1000			;upper limit
	rcall EditGimbalValue
	rjmp gbs201



cam1:	.db "Roll Gain", 0
cam2:	.db "Roll Offset", 0
cam3:	.db "Pitch Gain", 0, 0
cam4:	.db "Pitch Offset", 0, 0
cam5:	.db "Mixing", 0, 0

cam6:	.dw cam1*2, cam2*2, cam3*2, cam4*2, cam5*2

none:	.db "None", 0, 0
diff:	.db "Diff", 0, 0

mix:	.dw none*2, diff*2

gbs1:	.db "Home Pos Roll", 0
gbs2:	.db "Home Pos Pitch", 0, 0

gbs6:	.dw gbs1*2, gbs2*2


gbs7:	.db 83, 0, 115, 9
	.db 83, 9, 115, 18
	.db 83, 18, 115, 27
	.db 83, 27, 115, 36
	.db 83, 36, 115, 45

gbs8:	.db 95, 0, 127, 9
	.db 95, 9, 127, 18


sew1:	.db "Output type is set to", 0
sew2:	.db "ESC for M7 and/or M8.", 0
sew3:	.db "Check Mixer Editor.", 0

sew10:	.dw sew1*2, sew2*2, sew3*2



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

	sts X1, Xoffset
	call PrintColonAndSpace
	call GetEePVariable16
	call PrintNumberLF
	ret



	;--- ESC warning dialogue ---

ShowEscWarning:

	call LcdClear12x16

	call PrintWarningHeader

	ldi t, 3			;print warning text
	ldz sew10*2
	call PrintStringArray

	;footer
	call PrintOkFooter

	call LcdUpdate

	call WaitForOkButton
	ret



.undef Item
.undef Xoffset



	;--- Gimbal stabilization ---

GimbalStab:

	b16clr Temp					;gimbal will be deactivated if both gains are zero. This allows OCTOs to be used
	b16cmp CamRollGain, Temp
	breq gbs26
	rjmp gbs22

gbs26:	b16cmp CamPitchGain, Temp
	brne gbs22
	ret

gbs22:	lds t, Aux4SwitchPosition			;go to home position if the AUX4 switch is in position #3
	cpi t, 2
	brne gbs27

	b16mov RxAux2, CamPitchHomePos
	b16mov RxAux3, CamRollHomePos
	b16clr CamPitch
	b16set CamRoll

gbs27:	b16add RxAux2, RxAux2, CamPitchOffset		;add gimbal parameter offsets
	b16add RxAux3, RxAux3, CamRollOffset

	b16ldi Temp, 1000.0				;utilize the full input range.by adding 1000 and dividing by 2
	b16add RxAux2, RxAux2, Temp
	b16add RxAux3, RxAux3, Temp

	b16ldi Temp, 2.5				; = 5 / 2  (modified to utilize the full input range)
	b16mul NewCamPitchOffset, RxAux2, Temp
	b16mul NewCamRollOffset, RxAux3, Temp

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

	b16mov Temp, NewCamRollOffset
	b16sub NewCamRollOffset, NewCamRollOffset, NewCamPitchOffset
	b16add NewCamPitchOffset, NewCamPitchOffset, Temp

	b16ldi Temp, 2500.0				; = 1000 * 2.5 (compensate for differential offset)
	b16add NewCamRollOffset, NewCamRollOffset, Temp
	b16sub NewCamPitchOffset, NewCamPitchOffset, Temp

gbs24:	b16add Out7, CamRoll, NewCamRollOffset		;outputs will be set only when FC is armed and throttle is applied
	b16add Out8, CamPitch, NewCamPitchOffset

	b16mov Offset7, Out7				;makes it possible to adjust the gimbal in 'SAFE' mode also
	b16mov Offset8, Out8				;(offset is used in 'SAFE' mode and in 'ARMED' mode until throttle is applied)
	ret

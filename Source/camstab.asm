
.def Item = r17

CamStabSettings:

	call LoadMixerTable		;display a warning if output type on M7/M8 is set to 'ESC'
	call UpdateOutputTypeAndRate
	lds t, OutputTypeBitmask
	andi t, 0xC0
	breq cam11

	rcall ShowEscWarning

cam11:	call LcdClear6x8

	clr t				;print all text labels first

cam15:	push t
	ldz cam6*2
	call PrintFromStringArray
	lrv X1, 0
	rvadd Y1, 9
	pop t
	inc t
	cpi t, 5
	brne cam15

	lrv Y1, 1			;roll gain
	no_offset_ldz eeCamRollGain
	rcall PrintCamStabValue

	rcall PrintCamStabValue		;roll offset

	rcall PrintCamStabValue		;pitch gain

	rcall PrintCamStabValue		;pitch offset

	lrv X1, 72			;mixing (none or differential)
	call PrintColonAndSpace
	lds t, CamServoMixing
	andi t, 0x01
	ldz mix*2
	call PrintFromStringArray

	;footer
	call PrintStdFooter

	;print selector
	ldzarray cam7*2, 4, Item
	call PrintSelector

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08			;BACK?
	brne cam8
	ret

cam8:	cpi t, 0x04			;PREV?
	brne cam9

	dec Item
	brpl cam10

	ldi Item, 4
cam10:	rjmp cam11	

cam9:	cpi t, 0x02			;NEXT?
	brne cam12

	inc Item
	cpi item, 5
	brlt cam13

	clr Item
cam13:	rjmp cam11	

cam12:	cpi t, 0x01			;CHANGE?
	brne cam14

	cpi item, 4			;change mixing mode?
	brne cam30

	;toggle mixing mode
	lds xl, CamServoMixing
	ser t
	eor xl, t
	sts CamServoMixing, xl
	no_offset_ldz eeCamServoMixing
	call StoreEePVariable8
	rjmp cam11

cam30:	no_offset_ldzarray eeCamRollGain, 2, Item
	call GetEePVariable16
	ldy -32000			;lower limit
	no_offset_ldz 32000			;upper limit
	call NumberEdit
	mov xl, r0
	mov xh, r1
	no_offset_ldzarray eeCamRollGain, 2, Item
	call StoreEePVariable16
cam14:	rjmp cam11



	;--- Print 16bit value and set cursor position ---

PrintCamStabValue:

	lrv X1, 72
	call PrintColonAndSpace
	call GetEePVariable16
	call Print16Signed
	rvadd Y1, 9
	ret



	;--- ESC warning dialogue ---

ShowEscWarning:

	call LcdClear12x16

	lrv X1, 16			;warning
	ldz warning*2
	call PrintString

	lrv FontSelector, f6x8

	lrv X1, 0			;print warning text
	lrv Y1, 17
	clr t

sew12:	push t
	ldz sew10*2
	call PrintFromStringArray
	lrv X1, 0
	rvadd Y1, 9
	pop t
	inc t
	cpi t, 3
	brne sew12

	;footer
	call PrintOkFooter

	call LcdUpdate

sew11:	call GetButtonsBlocking
	cpi t, 0x01			;OK?
	brne sew11

	call Beep
	call ReleaseButtons
	ret




cam1:	.db "Roll gain", 0
cam2:	.db "Roll offset", 0
cam3:	.db "Pitch gain", 0, 0
cam4:	.db "Pitch offset", 0, 0
cam5:	.db "Mixing", 0, 0
cam5a:	.db "None", 0, 0
cam5b:	.db "Diff", 0, 0

cam6:	.dw cam1*2+offset, cam2*2+offset, cam3*2+offset, cam4*2+offset, cam5*2+offset
mix:	.dw cam5a*2+offset, cam5b*2+offset


cam7:	.db 83, 0, 110, 9
	.db 83, 9, 110, 18
	.db 83, 18, 110, 27
	.db 83, 27, 110, 36
	.db 83, 36, 110, 45


sew1:	.db "Output type is set to", 0
sew2:	.db "ESC for M7 and/or M8.", 0
sew3:	.db "Check Mixer Editor.", 0

sew10:	.dw sew1*2+offset, sew2*2+offset, sew3*2+offset


.undef Item






CameraStab:

	b16clr Temp					;gimbal will be deactivated if both gains are zero. This allows OCTOs to be used
	b16cmp CamRollGain, Temp
	breq cam26
	rjmp cam22

cam26:	b16cmp CamPitchGain, Temp
	brne cam22
	ret

cam22:	b16mul CamRoll, EulerAngleRoll, CamRollGain	;calculate camera angles
	b16mul CamPitch, EulerAnglePitch, CamPitchGain

	b16mov NewCamRollOffset, CamRollOffset		;camera offset
	b16mov NewCamPitchOffset, CamPitchOffset

	rvbrflagtrue CamServoMixing, cam20
	rjmp cam24					;jump for regular output

cam20:	b16mov Temp, CamRoll				;differential mixing
	b16sub CamRoll, CamRoll, CamPitch
	b16add CamPitch, CamPitch, Temp

	b16sub NewCamRollOffset, CamRollOffset, CamPitchOffset
	b16add NewCamPitchOffset, CamPitchOffset, CamRollOffset

	b16ldi Temp, 2500.0				; = 1000 * 2.5 (compensate for differential offset)
	b16add NewCamRollOffset, NewCamRollOffset, Temp
	b16sub NewCamPitchOffset, NewCamPitchOffset, Temp

cam24:	b16add Out7, CamRoll, NewCamRollOffset		;outputs will be set only when FC is armed and throttle is applied
	b16add Out8, CamPitch, NewCamPitchOffset

	b16mov Offset7, Out7				;makes it possible to adjust the gimbal in 'SAFE' mode also
	b16mov Offset8, Out8				;(offset is used in 'SAFE' mode and in 'ARMED' mode until throttle is applied)
	ret

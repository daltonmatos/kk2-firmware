
.def Item = r17

SatGimbalSettings:

	call LoadMixerTable		;display a warning if output type on M7/M8 is set to 'ESC'
	call UpdateOutputTypeAndRate
	lds t, OutputTypeBitmask
	andi t, 0xC0
	breq sgs11

	rcall ShowEscWarning

sgs11:	call LcdClear6x8

	ldz cam1*2			;roll gain
	call PrintString
	ldz eeCamRollGain
	rcall PrintSatCamStabValue

	ldz cam3*2			;pitch gain
	call PrintString
	ldz eeCamPitchGain
	rcall PrintSatCamStabValue

	ldz cam5*2			;mixing (none or differential)
	call PrintString
	lrv X1, 60
	call PrintColonAndSpace
	lds t, CamServoMixing
	andi t, 0x01
	ldz mix*2
	call PrintFromStringArray

	;footer
	call PrintStdFooter

	;print selector
	ldzarray sgs7*2, 4, Item
	call PrintSelector

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08			;BACK?
	brne sgs8
	ret	

sgs8:	cpi t, 0x04			;PREV?
	brne sgs9

	dec Item
	brpl sgs10

	ldi Item, 2
sgs10:	rjmp sgs11	

sgs9:	cpi t, 0x02			;NEXT?
	brne sgs12

	inc Item
	cpi Item, 3
	brlt sgs13

	clr Item
sgs13:	rjmp sgs11	

sgs12:	cpi t, 0x01			;CHANGE?
	brne sgs14

	cpi Item, 2			;change mixing mode?
	brne sgs30

	;toggle mixing mode
	lds xl, CamServoMixing
	ser t
	eor xl, t
	sts CamServoMixing, xl
	ldz eeCamServoMixing
	call StoreEeVariable8
	rjmp sgs11

	;edit selected gain value
sgs30:	tst Item
	brne sgs31

	ldz eeCamRollGain
	rjmp sgs32

sgs31:	ldz eeCamPitchGain
sgs32:	pushz
	call GetEePVariable16
	ldy -32000			;lower limit
	ldz 32000			;upper limit
	call NumberEdit
	mov xl, r0
	mov xh, r1
	popz
	call StoreEePVariable16
sgs14:	rjmp sgs11



	;--- Print 16bit value and set cursor position ---

PrintSatCamStabValue:

	lrv X1, 60
	call PrintColonAndSpace
	call GetEePVariable16
	call Print16Signed
	lrv X1, 0
	rvadd Y1, 9
	ret




sgs7:	.db 71, 0, 98, 9
	.db 71, 9, 98, 18
	.db 71, 18, 98, 27


.undef Item


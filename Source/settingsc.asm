
.def Item = r17


ModeSettings:

sux11:	call LcdClear6x8

	clr t					;print all text labels first

sux21:	push t
	ldz sux20*2
	call PrintFromStringArray
	lrv X1, 0
	rvadd Y1, 9
	pop t
	inc t
	cpi t, 5
	brne sux21

	lrv Y1, 1				;print values
	ldz eeLinkRollPitch
	rcall PrintYesNoValue

	ldz eeAutoDisarm
	rcall PrintYesNoValue

	ldz eeButtonBeep
	call PrintYesNoValue

	ldz eeArmingBeeps
	call PrintYesNoValue

	ldz eeQuietESCs
	call PrintYesNoValue

	;footer
	call PrintStdFooter

	;print selector
	ldzarray sux7*2, 4, Item
	call PrintSelector

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08				;BACK?
	brne sux8

	call ReadLinkRollPitchFlag		;read the "Link Roll Pitch" flag in case it was changed (this fixes a bug in the original firmware)
	ret

sux8:	cpi t, 0x04				;PREV?
	brne sux9
		
	dec Item
	brlt sux17

sux10:	rjmp sux11

sux17:	ldi Item, 4
	rjmp sux11

sux9:	cpi t, 0x02				;NEXT?
	brne sux12

	inc Item
	cpi Item, 5
	breq sux16

sux13:	rjmp sux11

sux16:	clr Item
	rjmp sux11

sux12:	cpi t, 0x01				;CHANGE?
	brne sux14

	call StopPwmQuiet			;stop PWM output while settings are changing
	ldzarray eeLinkRollPitch, 1, Item	;toggle flag
	call GetEeVariable8
	ser t
	eor xl, t
	ldzarray eeLinkRollPitch, 1, Item
	call StoreEeVariable8
	call StartPwmQuiet			;enable PWM output again

sux14:	rjmp sux11



	;--- Print yes/no value and update the cursor position ---

PrintYesNoValue:

	lrv X1, 90
	call PrintColonAndSpace	
	call GetEeVariable8			;Z is used as input variable
	mov t, xl
	andi t, 0x01
	ldz yesno*2
	call PrintFromStringArray
	rvadd Y1, 9
	ret



sux1:	.db "Link Roll Pitch", 0
sux2:	.db "Auto Disarm", 0
sux3:	.db "Button Beep", 0
sux4:	.db "Arming Beeps", 0, 0
sux5:	.db "Quiet ESCs", 0, 0

sux20:	.dw sux1*2, sux2*2, sux3*2, sux4*2, sux5*2

sux7:	.db 100, 0, 122, 9
	.db 100, 9, 122, 18
	.db 100, 18, 122, 27
	.db 100, 27, 122, 36
	.db 100, 36, 122, 45


.undef Item


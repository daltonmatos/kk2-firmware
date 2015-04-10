
.def Item = r17
.def OldLinkFlag = r18


ModeSettings:

	clr Item
	lds OldLinkFlag, flagRollPitchLink

sux11:	call LcdClear6x8

	ldi t, 5				;print all text labels first
	ldz sux20*2
	call PrintStringArray

	lrv Y1, 1				;print all values
	ldz eeLinkRollPitch
	rcall PrintYesNoValue			;eeLinkRollPitch
	rcall PrintYesNoValue			;eeAutoDisarm
	rcall PrintYesNoValue			;eeButtonBeep
	rcall PrintYesNoValue			;eeArmingBeeps
	rcall PrintYesNoValue			;eeQuietESCs

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

	cp OldLinkFlag, t			;changed from linked to unlinked?
	brge sux15

	ldz EeParameterTable			;yes, make elevator parameter values similar to aileron
	ldy 0x004C
	ldi Item, 4				;copy 4 words

sux18:	call GetEeVariable16
	pushz
	movw z, y
	call StoreEeVariable16
	movw y, z
	popz
	dec Item
	brne sux18

sux15:	ret

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
	call ReadEeprom
	com t
	call WriteEeprom

	call StartPwmQuiet			;enable PWM output again

sux14:	rjmp sux11



	;--- Print yes/no value and update the cursor position ---

PrintYesNoValue:

	lrv X1, 90
	call PrintColonAndSpace	
	call GetEeVariable8			;Z is used as input variable
	mov t, xl
	andi t, 0x01
	pushz
	ldz yesno*2
	call PrintFromStringArray
	popz
	call LineFeed
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
.undef OldLinkFlag

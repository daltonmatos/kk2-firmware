
.def Item = r17
.def OldLinkFlag = r18


ModeSettings:

	clr Item
	lds OldLinkFlag, flagRollPitchLink

sux11:	call LcdClear6x8

	rvbrflagfalse flagGimbalMode, sux22

	ldz sux3*2				;will only be able to edit button beep setting in gimbal controller mode
	call PrintString
	ldz eeButtonBeep
	rcall PrintYesNoValue
	call PrintBackFooter
	call PrintChangeFooter
	clr Item
	rjmp sux23

sux22:	;labels
	ldi t, 4
	ldz sux20*2
	call PrintStringArray

	;values
	lrv Y1, 1
	ldz eeLinkRollPitch
	rcall PrintYesNoValue			;eeLinkRollPitch
	rcall PrintYesNoValue			;eeAutoDisarm
	rcall PrintYesNoValue			;eeButtonBeep
	rcall PrintYesNoValue			;eeArmingBeeps

	;footer
	call PrintStdFooter

sux23:	;print selector
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

sux18:	call GetEePVariable16
	pushz
	movw z, y
	call StoreEePVariable16
	movw y, z
	popz
	dec Item
	brne sux18

sux15:	ret

sux8:	lds xl, flagGimbalMode			;skip navigation buttons in gimbal mode
	tst xl
	brne sux24

	cpi t, 0x04				;PREV?
	brne sux9
		
	dec Item
	brlt sux17

sux10:	rjmp sux11

sux17:	ldi Item, 3
	rjmp sux11

sux9:	cpi t, 0x02				;NEXT?
	brne sux12

	inc Item
	cpi Item, 4
	breq sux16

sux13:	rjmp sux11

sux16:	clr Item
	rjmp sux11

sux24:	ldi Item, 2				;for gimbal mode only

sux12:	cpi t, 0x01				;CHANGE?
	brne sux14

	ldzarray eeLinkRollPitch, 1, Item	;toggle flag
	call ReadEepromP
	com t
	call WriteEepromP

sux14:	rjmp sux11



	;--- Print yes/no value and update the cursor position ---

PrintYesNoValue:

	lrv X1, 90
	call PrintColonAndSpace	
	call GetEePVariable8			;Z is used as input variable
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

sux20:	.dw sux1*2, sux2*2, sux3*2, sux4*2

sux7:	.db 100, 0, 122, 9
	.db 100, 9, 122, 18
	.db 100, 18, 122, 27
	.db 100, 27, 122, 36
;	.db 100, 36, 122, 45


.undef Item
.undef OldLinkFlag




.def Item		= r17
.def Axis		= r18
.def ParameterIndex	= r19



PiEditor:

	clr Item
	clr Axis

pie1:	call LcdClear6x8			;clear the LCD, select the 6x8 font and go to screen coordinates (0, 1)

	;axis
	ldz pie2*2
	call PrintString
	rvbrflagfalse flagRollPitchLink, pie16

	cpi Axis, 2
	breq pie16

	ldz ailele*2				;aileron and elevator linked
	call PrintString
	rjmp pie17

pie16:	mov t, Axis
	ldz pie11*2
	call PrintFromStringArray

pie17:	;P Gain, P Limit, I Gain and I Limit
	lrv X1, 0
	lrv Y1, 10
	clr t

pie15:	push t
	ldz pie10*2
	call PrintFromStringArray
	lrv X1, 42
	call PrintColonAndSpace
	pop t
	push t
	mov ParameterIndex, t
	rcall GetParameter
	call PrintNumberLF
	lrv X1, 0
	pop t
	inc t
	cpi t, 4
	brlt pie15

	;footer
	call PrintStdFooter

	;print selector
	ldzarray pie7*2, 4, Item
	call PrintSelector

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08		;BACK?
	brne Pie30
	ret

pie30:	cpi t, 0x04		;PREV?
	brne pie31

	dec Item
	brpl pie34

	ldi Item, 4

pie34:	rjmp pie1

pie31:	cpi t, 0x02		;NEXT?
	brne pie32

	inc Item
	cpi item, 5
	brne pie35

	ldi Item, 0

pie35:	rjmp pie1

pie32:	cpi t, 0x01		;CHANGE?
	brne pie35

	cpi Item, 0		;change Axis
	brne pie40

	inc Axis
	cpi Axis, 3
	brne pie33

	clr Axis

pie33:	cpi Axis, 1
	brne pie36

	rvbrflagfalse flagRollPitchLink, pie36

	ldi Axis, 2

pie36:	rjmp pie1

pie40:	mov ParameterIndex, Item;edit parameter
	dec ParameterIndex
	rcall GetParameter
	ldy 0			;lower limit
	ldz 32000		;upper limit
	call NumberEdit
	mov xl, r0
	mov xh, r1
	rcall StoreParameter
	rjmp pie1



pie2:	.db "Axis   : ", 0

pie7:	.db 52, 0, 103, 9
	.db 52, 9, 79, 18
	.db 52, 18, 79, 27
	.db 52, 27, 79, 36
	.db 52, 36, 79, 45

pie10:	.dw pgain*2, plimit*2, igain*2, ilimit*2
pie11:	.dw ail*2, ele*2, rudd*2


GetParameter:
	rcall paradd
	call ReadEepromP
	mov xl, t
	adiw z, 1
	call ReadEepromP
	mov xh, t
	ret

StoreParameter:
	rcall paradd
	mov t, xl
	call WriteEepromP
	adiw z, 1
	mov t, xh
	call WriteEepromP
	ret

paradd:	ldz EeParameterTable	;Z = *EeParameterTable + Axis * 8 + ParameterIndex * 2
	mov t, Axis
	lsl t
	lsl t
	lsl t
	add zl, t
	clr t
	adc zh, t
	mov t, ParameterIndex
	lsl t
	add zl, t
	clr t
	adc zh, t
	
	ret
	


.undef Item
.undef Axis
.undef ParameterIndex

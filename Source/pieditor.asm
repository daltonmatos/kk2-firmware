


.def Item		= r17
.def Axis		= r18
.def ParameterIndex	= r19



PiEditor:

	clr Item
	clr Axis

pie1:	call LcdClear6x8			;clear the LCD, select the 6x8 font and go to screen coordinates (0, 1)

	;Axis
	ldz pie2*2
	call PrintString

	mov t, Axis
	ldz pie11*2
	call PrintFromStringArray

	;P Gain, P Limit, I Gain and I Limit
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
	call Print16Signed
	lrv X1, 0
	rvadd Y1, 9
	pop t
	inc t
	cpi t, 4
	brlt pie15

	;footer
	call PrintStdFooter

	;print selector
	ldzarray pie50*2, 4, Item
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
	brne pie63

	cpi Item, 0		;change Axis
	brne pie40

	inc Axis
	cpi Axis, 3
	brne pie33

	clr Axis

pie33:	rjmp pie1

pie40:	mov ParameterIndex, Item;Edit parameter
	dec ParameterIndex
	rcall GetParameter
	ldy 0			;lower limit
	ldz 32000		;upper limit
	call NumberEdit
	mov xl, r0
	mov xh, r1
	rcall StoreParameter
	cpi Axis, 2
	breq pie63

	rvbrflagfalse flagRollPitchLink, pie63

	push Axis
	ldi t, 1		;store both roll and pitch if flagRollPitchLink == true
	eor Axis, t
	rcall StoreParameter
	pop Axis

pie63:	rjmp pie1



pie50:	.db 52, 0, 103, 9
	.db 52, 9, 79, 18
	.db 52, 18, 79, 27
	.db 52, 27, 79, 36
	.db 52, 36, 79, 45



pie2:	.db "Axis   : ", 0

pie10:	.dw pgain*2, plimit*2, igain*2, ilimit*2
pie11:	.dw ail*2, ele*2, rudd*2


GetParameter:
	rcall paradd
	call ReadEeprom
	mov xl, t
	adiw z, 1
	call ReadEeprom
	mov xh, t
	ret

StoreParameter:
	rcall paradd
	mov t, xl
	call WriteEeprom
	adiw z, 1
	mov t, xh
	call WriteEeprom
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

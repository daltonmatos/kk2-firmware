


Contrast:


con11:	call LcdClear12x16

	lrv X1, 46			;header
	ldz con1*2
	call PrintString

	lrv X1, 0			;LCD contrast
	lrv Y1, 26
	lrv FontSelector, f6x8
	ldz con2*2
	call PrintString
	clr xh
	lds xl, LcdContrast
	clr yh
	call Print16Signed

	;footer
	lrv X1, 0
	lrv Y1, 57
	ldz con6*2
	call PrintString

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08			;BACK?
	brne con16

	ldz eeLcdContrast		;reload the LCD contrast setting
	call GetEeVariable8
	sts LcdContrast, xl
	ret

con16:	cpi t, 0x04			;UP?
	brne con17

	lds t, LcdContrast
	cpi t, 46			;upper limit reached?
	brge con20

	inc t				;no, increase
	sts LcdContrast, t
	rjmp con11

con17:	cpi t, 0x02			;DOWN?
	brne con18

	lds t, LcdContrast
	cpi t, 25			;lower limit reached?
	brlt con20

	dec t				;no, decrease
	sts LcdContrast, t
	rjmp con11

con18:	cpi t, 0x01			;SAVE?
	brne con20

	lds xl, LcdContrast
	ldz eeLcdContrast
	call StoreEeVariable8
	ret

con20:	rjmp con11






con1:	.db 65, 59, 60, 0		;the text "LCD" in the mangled 12x16 font
con2:	.db "LCD contrast: ", 0, 0
con6:	.db "BACK  UP   DOWN  SAVE", 0



	;--- Set default LCD contrast ---

SetDefaultLcdContrast:

	ldi t, 0x24
	sts LcdContrast, t
	ldz eeLcdContrast
	call WriteEeprom
	ret



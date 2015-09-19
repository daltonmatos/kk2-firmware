


Contrast:

	lds t, UserProfile		;refuse access unless user profile #1 is selected
	tst t
	breq con11

	ldz nadtxt2*2
	call ShowNoAccessDlg
	ret

con11:	call LcdClear12x16

	lrv X1, 46			;header
	ldz con1*2
	call PrintHeader

	lrv X1, 0			;LCD contrast
	lrv Y1, 26
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

	rcall LoadLcdContrast		;reload the LCD contrast setting
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
	call StoreEeVariable8		;save in profile #1 only
	ret

con20:	rjmp con11






con1:	.db 65, 59, 60, 0		;the text "LCD" in the mangled 12x16 font
con2:	.db "LCD Contrast: ", 0, 0
con6:	.db "BACK  UP   DOWN  SAVE", 0



	;--- Load LCD contrast ---

LoadLcdContrast:

	ldz eeLcdContrast
	call ReadEeprom			;read from profile #1 only
	sts LcdContrast, t
	ret



	;--- Set default LCD contrast ---

SetDefaultLcdContrast:

	ldi t, 0x24
	sts LcdContrast, t
	ldz eeLcdContrast
	call WriteEeprom		;save in profile #1 only
	ret



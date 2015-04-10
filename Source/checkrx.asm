

CheckRx:

	lds t, SatFrameValid			;set/clear RX error
	com t
	andi t, NoSatelliteInput
	lds xl, StatusBits
	cbr xl, NoSatelliteInput
	or t, xl
	sts StatusBits, t
	ret



pnd1:	.db 60, 58, 71, 58, 0, 0		;the text "DATA" in the mangled 12x16 font

pnd2:	.db "Please supply Sat", 0
pnd3:	.db "data to the throttle", 0, 0
pnd4:	.db "input connector.", 0, 0

pnd8:	.dw pnd2*2, pnd3*2, pnd4*2



	;---

ShowNoDataDlg:

	call LcdClear12x16

	lrv X1, 22
	ldi t, 67			;the character 'N' in the mangled 12x16 font
	call PrintChar
	ldi t, 68			;the character 'O' in the mangled 12x16 font
	call PrintChar

	lrv X1, 58			;print "DATA"
	ldz pnd1*2
	call PrintHeader

	ldi t, 3			;print "Please supply Sat data to the throttle input connector."
	ldz pnd8*2
	call PrintStringArray

	;footer
	call PrintBackFooter

	call LcdUpdate

pnd10:	call GetButtonsBlocking
	cpi t, 0x08			;BACK?
	brne pnd10

	ret


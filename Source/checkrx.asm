

CheckRx:

	lds t, flagCppmValid			;set/clear RX error
	com t
	andi t, NoCppmInput
	lds xl, StatusBits
	cbr xl, NoCppmInput
	or t, xl
	sts StatusBits, t
	ret



pns1:	.db 70, 64, 63, 67, 58, 65, 0, 0	;the text "SIGNAL" in the mangled 12x16 font

pns2:	.db "Please supply a CPPM", 0, 0
pns3:	.db "signal to the aileron", 0
pns4:	.db "input pin.", 0, 0

pns8:	.dw pns2*2, pns3*2, pns4*2



	;---

ShowNoSignalDlg:

	call LcdClear12x16

	lrv X1, 10
	ldi t, 67			;the character 'N' in the mangled 12x16 font
	call PrintChar
	ldi t, 68			;the character 'O' in the mangled 12x16 font
	call PrintChar

	lrv X1, 46			;print "SIGNAL"
	ldz pns1*2
	call PrintHeader

	ldi t, 3			;print "Please supply a CPPM signal to the aileron input pin."
	ldz pns8*2
	call PrintStringArray

	;footer
	call PrintBackFooter

	call LcdUpdate

pns10:	call GetButtonsBlocking
	cpi t, 0x08			;BACK?
	brne pns10

	ret


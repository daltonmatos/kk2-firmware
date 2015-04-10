

CheckCppmRx:

	lds t, RxFrameValid			;set/clear RX error
	com t
	andi t, NoCppmInput
	lds xl, StatusBits
	cbr xl, NoCppmInput
	or t, xl
	sts StatusBits, t
	ret



ncs1:	.db "NO SIGNAL", 0
ncs2:	.db "Please supply a CPPM", 0, 0
ncs3:	.db "signal to the aileron", 0
ncs4:	.db "input connector.", 0, 0

ncs8:	.dw ncs2*2, ncs3*2, ncs4*2



	;---

ShowNoCppmSignalDlg:

	call LcdClear12x16

	lrv X1, 10			;header
	ldz ncs1*2
	call PrintString

	lrv FontSelector, f6x8

	lrv X1, 0			;print "Please supply a CPPM signal to the aileron input connector."
	lrv Y1, 17
	clr t

ncs11:	push t
	ldz ncs8*2
	call PrintFromStringArray
	lrv X1, 0
	rvadd Y1, 9
	pop t
	inc t
	cpi t, 3
	brne ncs11

	;footer
	call PrintBackFooter

	call LcdUpdate

ncs10:	call GetButtonsBlocking
	cpi t, 0x08			;BACK?
	brne ncs10

	ret


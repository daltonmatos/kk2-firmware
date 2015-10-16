

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
ncs3:	.db "(PPM) signal to the", 0
ncs4:	.db "throttle input pin.", 0

ncs8:	.dw ncs2*2+offset, ncs3*2+offset, ncs4*2+offset



	;--- No CPPM input signal ---

ShowNoCppmSignalDlg:

	call LcdClear12x16

	lrv X1, 10			;header
	ldz ncs1*2
	call PrintHeader

	ldi t, 3			;print "Please supply a CPPM (PPM) signal to the throttle input pin."
	ldz ncs8*2
	call PrintStringArray

	;footer
	call PrintBackFooter

	call LcdUpdate

ncs10:	call GetButtonsBlocking
	cpi t, 0x08			;BACK?
	brne ncs10

	ret


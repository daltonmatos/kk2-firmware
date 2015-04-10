

CheckSatRx:

	lds t, RxFrameValid			;set/clear RX error
	com t
	andi t, NoSatelliteInput
	lds xl, StatusBits
	cbr xl, NoSatelliteInput
	or t, xl
	sts StatusBits, t
	ret



nsa1:	.db "NO DATA", 0

nsa2:	.db "Please supply Sat", 0
nsa3:	.db "data to the throttle", 0, 0
nsa4:	.db "input connector.", 0, 0

nsa8:	.dw nsa2*2, nsa3*2, nsa4*2



	;---

ShowNoSatDataDlg:

	call LcdClear12x16

	lrv X1, 22
	ldz nsa1*2
	call PrintString

	lrv FontSelector, f6x8

	lrv X1, 0			;print "Please supply Sat data to the throttle input connector."
	lrv Y1, 17
	clr t

nsa11:	push t
	ldz nsa8*2
	call PrintFromStringArray
	lrv X1, 0
	rvadd Y1, 9
	pop t
	inc t
	cpi t, 3
	brne nsa11

	;footer
	call PrintBackFooter

	call LcdUpdate

nsa10:	call GetButtonsBlocking
	cpi t, 0x08			;BACK?
	brne nsa10

	ret


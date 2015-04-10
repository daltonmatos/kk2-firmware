


	;--- No serial data ---

NoSerialDataDlg:

	call LcdClear12x16

	lrv X1, 22
	ldz nsd1*2
	call PrintHeader

	lrv X1, 0			;print the first instruction line according to selected RX mode
	lds t, RxMode
	cpi t, RxModeSBus
	brne nsd11

	ldz nosbus*2			;S.Bus
	rjmp nsd12

nsd11:	ldz nosat*2			;Satellite

nsd12:	call PrintString
	call LineFeed

	ldi t, 2			;print instructions
	ldz nsd8*2
	call PrintStringArray

	;footer
	call PrintBackFooter

	call LcdUpdate

nsd10:	call GetButtonsBlocking
	cpi t, 0x08			;BACK?
	brne nsd10

	ret



nsd1:	.db "NO DATA", 0

nosat:	.db "Please supply Sat", 0
nosbus:	.db "Please supply S.Bus", 0
nsd3:	.db "data to the throttle", 0, 0
nsd4:	.db "input pin.", 0, 0

nsd8:	.dw nsd3*2, nsd4*2


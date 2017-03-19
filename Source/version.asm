
ShowVersion:

	call LcdClear12x16

	;header
	lrv X1, 22
	ldz ver1*2
	call PrintHeader

	;version information
	ldi t, 4
	ldz ver10*2
	call PrintStringArray

	;RX mode
	lrv X1, 36
	lrv Y1, 26
	lds t, RxMode
	ldz modes*2
	call PrintFromStringArray

	;footer
	call PrintBackFooter

	call LcdUpdate

ver12:	call GetButtonsBlocking

	cpi t, 0x08				;BACK?
	brne ver12

	ret

	

ver1:	.db "VERSION", 0
ver2:	.db "KK2.1++ All-in-One R8", 0

ver10:	.dw ver2*2, srm2*2, null*2, motto*2

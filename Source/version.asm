
ShowVersion:

	call LcdClear12x16

	lrv X1, 22				;Header
	ldz ver1*2
	call PrintString

	lrv FontSelector, f6x8

	lrv X1, 10				;print version information
	lrv Y1, 20
	ldz ver2*2
	call PrintString

	lrv X1, 0
	rvadd Y1, 9
	ldz ver3*2
	call PrintString

	lrv Y1, 43
	call PrintMotto

	;footer
	call PrintBackFooter

	call LcdUpdate

ver12:	call GetButtonsBlocking
	cpi t, 0x08				;BACK?
	brne ver12
	ret

	

ver1:	.db "VERSION", 0
ver2:	.db "KK2.1++ All-in-One", 0, 0
ver3:	.db "for KK2.1 and KK2.1.5", 0


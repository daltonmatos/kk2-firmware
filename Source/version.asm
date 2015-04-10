
ShowVersion:

	call LcdClear12x16

	lrv X1, 22				;Header
	ldz ver1*2
	call PrintString

	lrv FontSelector, f6x8

	lrv X1, 0				;print version information
	lrv Y1, 17
	ldz ver2*2
	call PrintString

	lrv X1, 0
	rvadd Y1, 9
	ldz ver3*2
	call PrintString

	lrv Y1, 40
	call PrintMotto

	;footer
	call PrintBackFooter

	call LcdUpdate

ver12:	call GetButtonsBlocking
	cpi t, 0x08				;BACK?
	brne ver12
	ret

	

ver1:	.db 72, 61, 69, 70, 64, 68, 67, 0	;the text 'VERSION' in the mangled 12x16 font

ver2:	.db "KK2.0 v1.6++ S.Bus R3", 0
ver3:	.db "FASST & FASSTest mode", 0

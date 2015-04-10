
ShowVersion:

	call LcdClear12x16

	lrv X1, 22				;Header
	ldz ver1*2
	call PrintHeader

	ldi t, 4				;print version information
	ldz ver10*2
	call PrintStringArray

	;footer
	call PrintBackFooter

	call LcdUpdate

ver12:	call GetButtonsBlocking
	cpi t, 0x08				;BACK?
	brne ver12
	ret

	

ver1:	.db 72, 61, 69, 70, 64, 68, 67, 0	;the text 'VERSION' in the mangled 12x16 font

ver2:	.db "KK2.0 v1.6++ CPPM R5", 0, 0
ver3:	.db "CPPM (aka. PPM) only.", 0

ver10:	.dw ver2*2, ver3*2, null*2, motto*2

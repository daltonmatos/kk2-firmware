
.def Item = r17


BoardRotation:

	lds t, UserProfile		;refuse access unless user profile #1 is selected
	tst t
	breq brd10

	ldz nadtxt2*2
	call ShowNoAccessDlg
	ret

brd10:	ldz eeBoardOrientation
	call ReadEeprom
	andi t, 0x03
	mov Item, t

brd11:	call LcdClear12x16

	;text
	lrv X1, 34
	lrv Y1, 19
	ldz brd1*2
	call PrintString

	;arrow
	lrv FontSelector, s16x16
	ldzarray brd8*2, 2, Item
	lpm xl, z+
	lpm yl, z
	sts X1, xl
	sts Y1, yl
	ldi t, 5
	add t, Item
	call PrintChar

	;footer
	lrv FontSelector, f6x8
	call PrintSelectFooter

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08			;BACK?
	brne brd30

	ret

brd30:	cpi t, 0x04			;PREV?
	brne brd35

	inc Item

brd31:	andi Item, 0x03
	rjmp brd11

brd35:	cpi t, 0x02			;NEXT?
	brne brd36

	dec Item
	rjmp brd31

brd36:	cpi t, 0x01			;SELECT?
	brne brd11

	sts BoardOrientation, Item
	mov t, Item
	ldz eeBoardOrientation
	call WriteEeprom


	;--- Board rotation reminder ---

	call LcdClear12x16

	;header
	lrv X1, 34
	ldz saved*2
	call PrintHeader

	;text
	ldi t, 4
	ldz brr10*2
	call PrintStringArray

	;footer
	call PrintOkFooter

	call LcdUpdate

	call WaitForOkButton
	rjmp brd11



brd1:	.db "Front", 0

brd8:	.db 56, 0			;arrow positions
	.db 0, 20
	.db 56, 38
	.db 112, 20


brr1:	.db "Mount your KK2 board", 0, 0
brr2:	.db "so that the on-screen", 0
brr3:	.db "arrow points to the", 0
brr4:	.db "front of your model.", 0, 0

brr10:	.dw brr1*2, brr2*2, brr3*2, brr4*2



.undef Item



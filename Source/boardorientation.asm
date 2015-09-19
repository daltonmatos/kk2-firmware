

.def Item = r17

BoardOrientation:

	lds t, UserProfile		;refuse access unless user profile #1 is selected
	tst t
	breq brd10

	ldz nadtxt2*2
	call ShowNoAccessDlg
	ret

brd10:	lds Item, flagBoardOffset90

brd11:	call LcdClear12x16

	;text
	lrv X1, 34
	lrv Y1, 19
	ldz front*2
	call PrintHeader

	;arrow
	lrv FontSelector, s16x16
	andi Item, 0x01
	ldzarray brd8*2, 2, Item
	lpm xl, z+
	lpm yl, z
	sts X1, xl
	sts Y1, yl
	ldi t, 4
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

brd31:	inc Item
	rjmp brd11

brd35:	cpi t, 0x02			;NEXT?
	breq brd31

	cpi t, 0x01			;SELECT?
	brne brd20

	mov t, Item			;save state
	dec t
	com t
	sts flagBoardOffset90, t
	ldz eeBoardOffset90
	call WriteEeprom


	;--- Board orientation reminder ---

	call LcdClear12x16

	;header
	lrv X1, 34
	ldz saved*2
	call PrintHeader

	;text
	ldi t, 3
	ldz brr10*2
	call PrintStringArray

	;footer
	call PrintOkFooter

	call LcdUpdate

	call WaitForOkButton

brd20:	rjmp brd11



front:	.db 62, 70, 68, 67, 72, 0	;the text "FRONT" in the mangled 12x16 font

brd8:	.db 56, 0			;arrow positions
	.db 0, 20


brr1:	.db "On-screen arrow must", 0, 0
brr2:	.db "point to the front of", 0
brr3:	.db "your model.", 0

brr10:	.dw brr1*2, brr2*2, brr3*2


.undef Item


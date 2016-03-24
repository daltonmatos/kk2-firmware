
.def Item = r17



StickScaling:

	clr Item

set11:	call LcdClear6x8

	;labels and values
	clr t
	ldz eeStickScaleRoll

set16:	push t
	pushz
	ldz set20*2
	call PrintFromStringArray
	popz
	call GetEePVariable16
	lrv X1, 54
	call PrintColonAndSpace
 	call PrintNumberLF
	lrv X1, 0
	pop t
	inc t
	cpi t, 4
	brne set16

	;footer
	call PrintStdFooter

	;selector
	ldzarray set7*2, 4, Item
	call PrintSelector

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08		;BACK?
	brne set8

	ret	

set8:	cpi t, 0x04		;PREV?
	brne set9
		
	dec Item

set10:	andi Item, 0x03
	rjmp set11

set9:	cpi t, 0x02		;NEXT?
	brne set12

	inc Item
	rjmp set10

set12:	cpi t, 0x01		;CHANGE?
	brne set14

	ldzarray eeStickScaleRoll, 2, Item
	pushz
	call GetEePVariable16
	ldy 0			;lower limit
	ldz 500			;upper limit
	call NumberEdit
	mov xl, r0
	mov xh, r1
	popz
	call StoreEePVariable16

set14:	rjmp set11





set20:	.dw ail*2, ele*2, rudd*2, thr*2


set7:	.db 65, 0, 92, 9
	.db 65, 9, 92, 18
	.db 65, 18, 92, 27
	.db 65, 27, 92, 36


.undef Item



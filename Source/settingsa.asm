
.def Item = r17



StickScaling:

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
	lds xl, X1
	lrv X1, 0
	pop t
	inc t
	cpi t, 5
	brne set16

	sts X1, xl		;print '%' behind the last value (SL Mixing)
	rvsub Y1, 9
	ldi t, '%'
	call PrintChar

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
	brpl set10

	ldi Item, 4

set10:	rjmp set11

set9:	cpi t, 0x02		;NEXT?
	brne set12

	inc Item
	cpi item, 5
	brne set13

	ldi Item, 0

set13:	rjmp set11

set12:	cpi t, 0x01		;CHANGE?
	brne set14

	ldzarray eeStickScaleRoll, 2, Item
	call GetEePVariable16
	ldy 0			;lower limit
	ldz 500			;upper limit
	call NumberEdit
	mov xl, r0
	mov xh, r1
	ldzarray eeStickScaleRoll, 2, Item
	call StoreEePVariable16

set14:	rjmp set11





set20:	.dw ail*2, ele*2, rudd*2, thr*2, slmix*2


set7:	.db 65, 0, 92, 9
	.db 65, 9, 92, 18
	.db 65, 18, 92, 27
	.db 65, 27, 92, 36
	.db 65, 36, 92, 45


.undef Item



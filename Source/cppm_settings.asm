
.def Item		= r17



CppmSettings:

cpp11:	call LcdClear6x8

	clr t				;print all text labels and values
	ldz eeCppmRoll

cpp15:	push t
	pushz
	ldz cpp6*2
	call PrintFromStringArray
	popz
	call GetEePVariable8 
	lrv X1, 54
	call PrintColonAndSpace
	clr xh
 	call Print16Signed 
	lrv X1,0
	rvadd Y1, 9
	pop t
	inc t
	cpi t, 5
	brne cpp15

	;footer
	call PrintStdFooter

	;print selector
	ldzarray cpp7*2, 4, Item
	call PrintSelector

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08			;BACK?
	brne cpp8
	ret	

cpp8:	cpi t, 0x04			;PREV?
	brne cpp9

	dec Item
	brpl cpp10

	ldi Item, 4
cpp10:	rjmp cpp11	

cpp9:	cpi t, 0x02			;NEXT?
	brne cpp12

	inc Item
	cpi item, 5
	brne cpp13

	ldi Item, 0
cpp13:	rjmp cpp11	

cpp12:	cpi t, 0x01			;CHANGE?
	brne cpp14

	ldzarray eeCppmRoll, 1, Item
	call GetEePVariable8
	ldy 1				;lower limit
	ldz 5				;upper limit
	ldi xh, 0
	call NumberEdit
	mov xl, r0
	mov xh, r1
	ldzarray eeCppmRoll, 1, Item
	call StoreEePVariable8

cpp14:	rjmp cpp11




cpp6:	.dw ail*2, ele*2, thr*2, rudd*2, aux*2


cpp7:	.db 65, 0, 73, 9
	.db 65, 9, 73, 18
	.db 65, 18, 73, 27
	.db 65, 27, 73, 36
	.db 65, 36, 73, 45




.undef Item


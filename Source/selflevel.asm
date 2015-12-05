


.def Item = r17

selflevel_settings:
  nop

SelflevelSettings:
  safe_call_c selflevel_settings
  ret

	clr Item

sqz11:	call LcdClear6x8

	;labels
	ldi t, 5
	ldz sqz6*2
	call PrintStringArray

	;values
	lrv Y1, 1
	ldz  eeSelflevelPgain
	ldi t, 5

sqz16:	push t
	lrv X1, 84
	call PrintColonAndSpace
	call GetEePVariable16
 	call PrintNumberLF
	pop t
	dec t
	brne sqz16

	;footer
	call PrintStdFooter

	;print selector
	ldzarray sqz7*2, 4, Item
	call PrintSelector

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08			;BACK?
	brne sqz8
	ret	

sqz8:	cpi t, 0x04			;PREV?
	brne sqz9

	dec Item
	brpl sqz10

	ldi Item, 4

sqz10:	rjmp sqz11	

sqz9:	cpi t, 0x02			;NEXT?
	brne sqz12

	inc Item
	cpi Item, 5
	brne sqz13

	ldi Item, 0

sqz13:	rjmp sqz11	

sqz12:	cpi t, 0x01			;CHANGE?
	brne sqz14

	ldzarray eeSelflevelPgain, 2, Item
	push zl
	push zh
	call GetEePVariable16
	ldzarray sqz15*2, 4, Item
	lpm yl, Z+
	lpm yh, Z+
	lpm r0, Z+
	lpm r1, Z+
	mov zl, r0
	mov zh, r1
	call NumberEdit
	mov xl, r0
	mov xh, r1
	pop zh
	pop zl
	call StoreEePVariable16

sqz14:	rjmp sqz11




sqz3:	.db "ACC Trim Roll", 0
sqz4:	.db "ACC Trim Pitch", 0, 0
sqz5:	.db "SL Mixing Rate", 0, 0

sqz6:	.dw pgain*2, plimit*2, sqz3*2, sqz4*2, sqz5*2


sqz7:	.db 95, 0, 121, 9
	.db 95, 9, 121, 18
	.db 95, 18, 121, 27
	.db 95, 27, 121, 36
	.db 95, 36, 121, 45


sqz15:	.dw 0, 900
	.dw 0, 900
	.dw -900, 900
	.dw -900, 900
	.dw 5, 50



.undef Item


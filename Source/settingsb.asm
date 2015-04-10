
.def Item		= r17



MiscSettings:

stt11:	call LcdClear6x8
	clr t
	ldz eeEscLowLimit

stt21:	push t			;the T register is a loop counter, but it also acts as a parameter to the 'PrintFromStringArray' function
	pushz			;the Z register must be saved here since it is also used to print text
	ldz stt20*2
	call PrintFromStringArray
	popz
	call GetEeVariable16
 	call Print16Signed
	lrv X1, 0
	rvadd Y1, 9
	pop t
	inc t
	cpi t, 5		;number of text lines printed
	brne stt21

	;footer
	call PrintStdFooter

	;print selector
	ldzarray stt7*2, 4, Item
	call PrintSelector

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08		;BACK?
	brne stt8
	ret	

stt8:	cpi t, 0x04		;PREV?
	brne stt9	
	dec Item
	brpl stt10
	ldi Item, 4
stt10:	rjmp stt11	

stt9:	cpi t, 0x02		;NEXT?
	brne stt12
	inc Item
	cpi item, 5
	brne stt13
	ldi Item, 0
stt13:	rjmp stt11	

stt12:	cpi t, 0x01		;CHANGE?
	brne stt14

	ldzarray eeEscLowLimit, 2, Item
	push zl
	push zh
	call GetEeVariable16
	ldzarray stt15*2, 4, Item
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
	call StoreEeVariable16

stt14:	rjmp stt11




stt1:	.db "Minimum Throttle: ", 0, 0
stt3:	.db "Height Dampening: ", 0, 0
stt4:	.db "Height D. Limit : ", 0, 0
stt5:	.db "Alarm 1/10 volts: ", 0, 0
stt6:	.db "Servo Filter    : ", 0, 0

stt20:	.dw stt1*2, stt3*2, stt4*2, stt5*2, stt6*2


stt7:	.db 107, 0, 127, 9	;hilight screen coordinates
	.db 107, 9, 127, 18
	.db 107, 18, 127, 27
	.db 107, 27, 127, 36
	.db 107, 36, 127, 45

stt15:	.dw 0, 20		;edit number lower and upper limits
	.dw 0, 500
	.dw 0, 30
	.dw 0, 900
	.dw 0, 100




.undef Item


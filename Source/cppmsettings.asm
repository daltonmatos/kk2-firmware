
.def Item		= r17



CppmSettings:

cpp11:	call LcdClear
	
	lrv PixelType, 1
	lrv FontSelector, f6x8



	lrv X1,0
	lrv Y1,1
	mPrintString cpp1
	ldz eeCppmRoll
	call GetEeVariable8 
	clr xh
 	call Print16Signed 

	lrv X1,0
	rvadd Y1, 9
	mPrintString cpp2
	call GetEeVariable8 
 	call Print16Signed 

	lrv X1,0
	rvadd Y1, 9
	mPrintString cpp3
	call GetEeVariable8 
 	call Print16Signed 

	lrv X1,0
	rvadd Y1, 9
	mPrintString cpp4
	call GetEeVariable8 
 	call Print16Signed 

	lrv X1,0
	rvadd Y1, 9
	mPrintString cpp5
	call GetEeVariable8 
 	call Print16Signed 




	;footer
	lrv X1, 0
	lrv Y1, 57
	mPrintString cpp6

	;print selector
	ldzarray cpp7*2, 4, Item
	lpm t, z+
	sts X1, t
	lpm t, z+
	sts Y1, t
	lpm t, z+
	sts X2, t
	lpm t, z
	sts Y2, t
	lrv PixelType, 0
	call HilightRectangle

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08		;BACK?
	brne cpp8
	ret	

cpp8:	cpi t, 0x04		;PREV?
	brne cpp9	
	dec Item
	brpl cpp10
	ldi Item, 4
cpp10:	rjmp cpp11	

cpp9:	cpi t, 0x02		;NEXT?
	brne cpp12
	inc Item
	cpi item, 5
	brne cpp13
	ldi Item, 0
cpp13:	rjmp cpp11	

cpp12:	cpi t, 0x01		;CHANGE?
	brne cpp14

	ldzarray eeCppmRoll, 1, Item
	call GetEeVariable8
	ldy 1			;lower limit
	ldz 8			;upper limit
	ldi xh, 0
	call NumberEdit
	mov xl, r0
	mov xh, r1
	ldzarray eeCppmRoll, 1, Item
	call StoreEeVariable8

cpp14:	rjmp cpp11




cpp1:	.db "Roll (Ail)  :", 0
cpp2:	.db "Pitch (Ele) :", 0
cpp3:	.db "Throttle    :", 0
cpp4:	.db "Yaw (Rud)   :", 0
cpp5:	.db "AUX         :", 0
cpp6:	.db "BACK PREV NEXT CHANGE", 0


cpp7:	.db 77, 0, 85, 9
	.db 77, 9, 85, 18
	.db 77, 18, 85, 27
	.db 77, 27, 85, 36
	.db 77, 36, 85, 45




.undef Item


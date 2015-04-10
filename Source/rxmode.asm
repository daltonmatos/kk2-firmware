
.def Item = r17
.def Lock = r18

SelectRxMode:

	lds t, UserProfile		;refuse access unless user profile #1 is selected
	tst t
	breq srm10

	ldi t, 2
	call ShowNoAccessDlg
	ret

srm10:	lds Item, RxMode
	clr Lock

srm11:	call LcdClear12x16

	lrv X1, 22			;header
	ldz srm1*2
	call PrintString

	lrv X1, 0			;mode
	lrv Y1, 26
	lrv FontSelector, f6x8
	ldz srm2*2
	call PrintString
	mov t, Item
	ldz modes*2
	call PrintFromStringArray

	tst Lock			;print "Restart is required!" only when a mode is selected
	breq srm15

	mov t, Lock
	andi t, 0x01
	breq srm16

	lrv X1, 3
	lrv Y1, 44
	ldz srm4*2
	call PrintString
	rjmp srm16

srm15:	;footer
	call PrintSelectFooter

srm16:	call LcdUpdate

	tst Lock			;make the "Restart..." message flash at a fixed rate
	breq srm18

	ldx 600				;delay
	call WaitXms

	inc Lock
	breq srm17

	rjmp srm11

srm17:	ldi Lock, 2			;avoid zero as this would abort "Lock" mode
	rjmp srm11

srm18:	call GetButtonsBlocking

	cpi t, 0x08			;BACK?
	brne srm12

	ret

srm12:	cpi t, 0x04			;PREV?
	brne srm13

	dec Item
	brpl srm20

	ldi Item, 3
	rjmp srm11

srm13:	cpi t, 0x02			;NEXT?
	brne srm14

	inc Item
	cpi Item, 4
	brlt srm20

	clr Item
	rjmp srm11

srm14:	ldi Lock, 1			;SAVE
	mov xl, Item
	ldz eeRxMode
	call StoreEeVariable8		;save in user profile #1 only

srm20:	rjmp srm11



srm1:	.db "RX MODE", 0
srm2:	.db "Mode: ", 0, 0
srm4:	.db "Restart is required!", 0, 0

stdrx:	.db "Standard RX", 0
cppm:	.db "CPPM (aka. PPM)", 0
sbus:	.db "Futaba S.Bus", 0, 0
sat:	.db "Satellite DSM2", 0, 0

modes:	.dw stdrx*2, cppm*2, sbus*2, sat*2


.undef Item
.undef Lock


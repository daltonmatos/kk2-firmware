
.def Item = r17
.def Xoffset = r18
.def OldValue = r19


SBusDG2SwitchSetup:

	clr Item
	call LoadDG2Settings
	lds OldValue, DG2Functions
	ldi Xoffset, 96

dgs11:	call LcdClear6x8

	ldi t, 4			;labels
	ldz dgs10*2
	call PrintStringArray

	lrv Y1, 1			;status
	lds yl, DG2Functions
	rcall PrintDG2Function		;stay armed and spin motors
	rcall PrintDG2Function		;set digital outputs (rudder & aux)
	rcall PrintDG2Function		;increase aileron and elevator stick scaling by 20
	rcall PrintDG2Function		;increase aileron and elevator stick scaling by 30

	;footer
	call PrintStdFooter

	;print selector
	ldzarray stt7*2, 4, Item
	call PrintSelector

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08			;BACK?
	brne dgs8

	lds t, DG2Functions		;save to EEPROM if the value was modified
	cp t, OldValue
	breq dgs7

	ldz eeDG2Functions
	mov xl, t
	call StoreEePVariable8

dgs7:	ret	

dgs8:	cpi t, 0x04			;PREV?
	brne dgs9

	dec Item

dgs15:	andi Item, 0x03
	rjmp dgs11	

dgs9:	cpi t, 0x02			;NEXT?
	brne dgs12

	inc Item
	rjmp dgs15	

dgs12:	cpi t, 0x01			;CHANGE?
	brne dgs14

	mov t, Item			;toggle selected bit in DG2Functions
	clr xl
	sec

dgs13:	rol xl
	dec t
	brpl dgs13

	lds t, DG2Functions
	eor t, xl
	sts DG2Functions, t

dgs14:	rjmp dgs11



dgs1:	.db "Stay Armed/Spin", 0
dgs2:	.db "Digital Output", 0, 0
dgs3:	.db "Ail/Ele Rate +20", 0, 0
dgs4:	.db "Ail/Ele Rate +30", 0, 0

dgs10:	.dw dgs1*2, dgs2*2, dgs3*2, dgs4*2



	;--- Print DG2 funtion value ---

PrintDG2Function:

	sts X1, Xoffset
	call PrintColonAndSpace
	mov t, yl
	ldz yesno*2
	andi t, 0x01
	call PrintFromStringArray

	call LineFeed			;prepare for the next line
	lsr yl
	ret



.undef Item
.undef Xoffset
.undef OldValue


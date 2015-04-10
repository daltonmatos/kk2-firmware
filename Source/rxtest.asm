
.set xoff = 85				;X position for the channel value texts


RxTest:

rxt1:	call GetSBusFlags
	lds t, flagSBusFrameValid
	tst t
	brne rxt2

	call ShowNoDataDlg
	ret

rxt2:	call GetRxChannels

	lds t, RxBufferState		;update the display only when we have new data
	cpi t, 3
	breq rxt8

	ldi yl, 25			;wait 2.5ms
	call wms
	rjmp rxt30			;skip display update

rxt8:	b16ldi Temp, 0.1
	b16mul RxRoll, RxRoll, Temp
	b16mul RxPitch, RxPitch, Temp
	b16mul RxYaw, RxYaw, Temp
	b16mul RxAux, RxAux, Temp

	b16ldi Temp, 0.053
	b16mul RxThrottle, RxThrottle, Temp

	call LcdClear6x8

	clr t				;print all channel labels first

rxt3:	push t
	ldz rxch*2
	call PrintFromStringArray
	lrv X1, 48
	call PrintColonAndSpace
	lrv X1, 0
	rvadd Y1, 9
	pop t
	inc t
	cpi t, 5
	brne rxt3

	lrv X1, 57			;aileron
	lrv Y1, 1
	b16load RxRoll
	ldz ailtxt*2
	rcall PrintRxValue

	b16load RxPitch			;elevator
	ldz eletxt*2
	rcall PrintRxValue

	b16load RxThrottle		;throttle (needs special attention)
	call Print16Signed
	lrv X1, xoff
	rvbrflagfalse flagThrottleZero, rxt4

	clr t				;idle
	rjmp rxt6

rxt4:	ldz 90
	rcall CompareXZ
	brge rxt5

	ldi t, 1			;1 - 90%
	rjmp rxt6

rxt5:	ldi t, 2			;full
	
rxt6:	ldz thrtxt*2
	rcall PrintRxText

	b16load RxYaw			;rudder
	ldz rudtxt*2
	rcall PrintRxValue

	b16load RxAux			;aux (needs special attention)
	call Print16Signed
	lrv X1, xoff
	lds t, AuxSwitchPosition
	ldz auxtxt*2
	call PrintFromStringArray

	;footer
	lrv X1, 0
	lrv Y1, 57
	ldz rxt10*2
	call PrintString

	call LcdUpdate

rxt30:	call GetButtons

	cpi t, 0x08			;BACK?
	brne rxt35

	ret	

rxt35:	cpi t, 0x04			;MORE?
	brne rxt7

	call Beep
	rcall RxTest2

rxt7:	rjmp rxt1




	;--- Second screen ---

RxTest2:

	call GetRxChannels
	call GetSBusFlags

	lds t, RxBufferState		;update the display only when we have new data
	cpi t, 3
	breq rxt204

	ldi yl, 25			;wait 2.5ms
	call wms
	rjmp rxt203			;skip display update

rxt204:	call ScaleAuxInputValues
	b16mul RxAux4, RxAux4, Temp	;TEMP was set to 0.1 in ScaleAuxInputValues

	call LcdClear6x8

	ldi xl, '2'			;print all AUX channel labels first

rxt201:	ldz aux*2
	call PrintString
	mov t, xl
	call PrintChar
	lrv X1, 48
	call PrintColonAndSpace
	lrv X1, 0
	rvadd Y1, 9
	inc xl
	cpi xl, '5'
	brne rxt201

	lrv X1, 57			;aux2
	lrv Y1, 1
	b16load RxAux2
	call Print16Signed

	rcall UpdateRxCursorPos		;aux3
	b16load RxAux3
	call Print16Signed

	rcall UpdateRxCursorPos		;aux4
	b16load RxAux4
	call Print16Signed
	lrv X1, xoff
	lds t, Aux4SwitchPosition
	ldz aux4txt*2
	call PrintFromStringArray

	lrv X1, 0			;digital channel 1
	rvadd Y1, 9
	ldz dg1*2
	call PrintString
	lrv X1, 48
	call PrintColonAndSpace
	lrv X1, 57
	ldi t, '0'
	lds xl, Channel17
	add t, xl
	call PrintChar
	lrv X1, xoff
	lds t, Channel17
	ldz dg1txt*2
	call PrintFromStringArray

	;footer
	call PrintBackFooter

	call LcdUpdate

rxt203:	call GetButtons

	cpi t, 0x08			;BACK?
	brne rxt202

	call Beep
	call ReleaseButtons
	ret				;return to the first RX test screen

rxt202:	rjmp rxTest2




rxt10:	.db "BACK MORE", 0

rxch:	.dw ail*2, ele*2, thr*2, rudd*2, aux*2

dg1:	.db "DG1", 0

null:	.db 0, 0
left:	.db "Left", 0, 0
right:	.db "Right", 0
fwd:	.db "Forward", 0
rev:	.db "Back", 0, 0
idle:	.db "Idle", 0, 0
full:	.db "Full", 0, 0
alarm:	.db "Alarm", 0

ailtxt:	.dw left*2, null*2, right*2
eletxt:	.dw fwd*2, null*2, rev*2
thrtxt:	.dw idle*2, null*2, full*2
rudtxt:	.dw right*2, null*2, left*2
dg1txt:	.dw off*2, alarm*2



	;--- Print RX channel value and text ---

PrintRxValue:

	pushz
	call Print16Signed
	lrv X1, xoff
	rcall CompareXZminus10
	brge prt1

	clr t
	rjmp prt3

prt1:	rcall CompareXZplus10
	brge prt2

	ldi t, 1			;center
	rjmp prt3

prt2:	ldi t, 2

prt3:	popz

PrintRxText:

	call PrintFromStringArray

UpdateRxCursorPos:

	lrv X1, 57
	rvadd Y1, 9
	ret



	;--- Compare if stick input exceeds 10% ---

CompareXZminus10:

	ldz -10
	rjmp CompareXZ

CompareXZplus10:

	ldz 10

CompareXZ:

	cp  xl, zl
	cpc xh, zh
	ret

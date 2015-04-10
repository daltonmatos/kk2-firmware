
.set xoff = 85				;X position for the channel value texts


RxTest:

	lrv RxTimeoutLimit, 2

rxt1:	call GetRxChannels

	b16ldi Temp, 0.1
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
	lds t, flagRollValid
	rcall PrintRxValue

	b16load RxPitch			;elevator
	ldz eletxt*2
	lds t, flagPitchValid
	rcall PrintRxValue

	rvbrflagtrue flagThrottleValid, rxt14

	ldz rxt8*2			;no throttle input
	call PrintString
	rcall UpdateRxCursorPos
	rjmp rxt13

rxt14:	b16load RxThrottle		;throttle (needs special attention)
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

rxt13:	b16load RxYaw			;rudder
	ldz rudtxt*2
	lds t, flagYawValid
	rcall PrintRxValue

	rvbrflagtrue flagAuxValid, rxt11

	ldz rxt8*2			;no aux input
	call PrintString
	rjmp rxt12

rxt11:	b16load RxAux			;aux (needs special attention)
	call Print16Signed
	lrv X1, xoff
	lds t, AuxSwitchPosition
	ldz auxtxt*2
	call PrintFromStringArray

rxt12:	;footer
	call PrintBackFooter

	call LcdUpdate

	rcall RxPollDelay

	call GetButtons
	cpi t, 0x08			;BACK?
	brne rxt35

	ret	

rxt35:	jmp rxt1




rxt8:	.db "No signal", 0

rxch:	.dw ail*2, ele*2, thr*2, rudd*2, aux*2

null:	.db 0, 0
left:	.db "Left", 0, 0
right:	.db "Right", 0
fwd:	.db "Forward", 0
rev:	.db "Back", 0, 0
idle:	.db "Idle", 0, 0
full:	.db "Full", 0, 0

ailtxt:	.dw left*2, null*2, right*2
eletxt:	.dw fwd*2, null*2, rev*2
thrtxt:	.dw idle*2, null*2, full*2
rudtxt:	.dw right*2, null*2, left*2



	;--- Print RX channel value and text ---

PrintRxValue:

	brflagtrue t, prt4		;register T holds the "Valid Signal" flag

	ldz rxt8*2			;no signal
	call PrintString
	rjmp UpdateRxCursorPos

prt4:	pushz
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



	;--- Delay for RX polling ---

RxPollDelay:

	ldi yh, 5
rpd1:	ldi yl, 0
	call wms
	dec yh
	brne rpd1

	ret



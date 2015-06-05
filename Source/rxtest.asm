
.set xoff = 85				;X position for the channel value texts


RxTest:

	call GetSBusFlags
	lds t, flagSBusFrameValid
	tst t
	brne rxt1

	call ShowNoDataDlg
	ret

rxt1:	call GetRxChannels
	call GetSBusFlags

	lds t, RxBufferState		;update the display only when we have new data
	cpi t, 3
	breq rxt8

	ldi yl, 25			;wait 2.5ms
	call wms

	rvbrflagfalse flagSBusFrameValid, rxt8	;update the display also when RX data has become invalid

	rjmp rxt30			;skip display update

rxt8:	b16ldi Temp, 0.1
	b16mul RxRoll, RxRoll, Temp
	b16mul RxPitch, RxPitch, Temp
	b16mul RxYaw, RxYaw, Temp
	b16mul RxAux, RxAux, Temp

	b16ldi Temp, 0.053
	b16mul RxThrottle, RxThrottle, Temp

	call LcdClear6x8

	ldi t, 5			;print all channel labels first
	ldz rxch*2
	call PrintStringArray

	lrv Y1, 1			;aileron
	b16load RxRoll
	ldz ailtxt*2
	rcall PrintRxValue

	b16load RxPitch			;elevator
	ldz eletxt*2
	rcall PrintRxValue

	rcall PrintRxColon		;throttle (needs special attention)
	b16load RxThrottle
	call Print16Signed
	lrv X1, xoff
	rvbrflagfalse flagThrottleZero, rxt4

	clr xl				;idle
	rjmp rxt6

rxt4:	ldz 90
	rcall CompareXZ
	brge rxt5

	ldi xl, 1			;1 - 90%
	rjmp rxt6

rxt5:	ldi xl, 2			;full
	
rxt6:	ldz thrtxt*2
	rcall PrintRxText

	b16load RxYaw			;rudder
	ldz rudtxt*2
	rcall PrintRxValue

	rcall PrintRxColon		;aux (needs special attention)
	b16load RxAux
	call Print16Signed
	lrv X1, xoff
	lds t, AuxSwitchPosition
	ldz auxtxt*2
	call PrintFromStringArray

	;footer
	lrv X1, 0
	lrv Y1, 57
	ldz bckmore*2
	call PrintString

	call LcdUpdate

rxt30:	call GetButtons

	cpi t, 0x08			;BACK?
	brne rxt35

	ret	

rxt35:	cpi t, 0x04			;MORE?
	brne rxt7

	call Beep			;go to the second screen
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

	rvbrflagfalse flagSBusFrameValid, rxt204	;update the display also when RX data has become invalid

	rjmp rxt203			;skip display update

rxt204:	call ScaleAuxInputValues
	b16mul RxAux4, RxAux4, Temp	;TEMP was set to 0.1 in ScaleAuxInputValues

	call LcdClear6x8

	clr xh				;print all AUX channel labels first
	rcall PrintAuxLabels

	lrv Y1, 1			;aux2
	b16load RxAux2
	ldz notext*2
	rcall PrintRxValue

	b16load RxAux3			;aux3
	ldz notext*2
	rcall PrintRxValue

	rcall PrintRxColon		;aux4
	b16load RxAux4
	call Print16Signed
	lrv X1, xoff
	lds t, Aux4SwitchPosition
	ldz aux4txt*2
	call PrintFromStringArray

	lds xl, Channel17		;digital channel 1
	ldz dg1*2
	ldy dg1txt*2
	rcall PrintDigitalChannel

	;footer
	call PrintBackFooter

	call LcdUpdate

rxt203:	call GetButtons

	cpi t, 0x08			;BACK?
	brne rxt202

	call Beep			;return to the first RX test screen
	call ReleaseButtons
	ret

rxt202:	rjmp rxTest2




dg1:	.db "DG1", 0

null:	.db 0, 0
left:	.db "Left", 0, 0
right:	.db "Right", 0
fwd:	.db "Forward", 0
rev:	.db "Back", 0, 0
idle:	.db "Idle", 0, 0
full:	.db "Full", 0, 0
alarm:	.db "Alarm", 0
center:	.db "Center", 0, 0

notext:	.dw null*2, null*2, null*2
ailtxt:	.dw left*2, null*2, right*2
eletxt:	.dw fwd*2, null*2, rev*2
thrtxt:	.dw idle*2, null*2, full*2
rudtxt:	.dw right*2, null*2, left*2
dg1txt:	.dw off*2, alarm*2



	;--- Print AUX labels at specified position offset ---

PrintAuxLabels:

	ldi xl, '2'

pal1:	sts X1, xh			;register XH (input parameter) holds the position offset
	ldz aux*2
	call PrintString
	mov t, xl
	call PrintChar
	call Linefeed
	inc xl
	cpi xl, '5'
	brne pal1

	ret



	;--- Print digital channel states (DG1/DG2) ---

PrintDigitalChannel:

	pushy				;register Y (input parameter) points to the string array
	push xl				;register XL (input parameter) holds the input value from DG1 or DG2
	lrv X1, 0
	call Linefeed
	call PrintString		;register Z (input parameter) points to the label
	lrv X1, 48
	call PrintColonAndSpace
	lrv X1, 57
	ldi t, '0'
	pop xl
	add t, xl
	call PrintChar
	lrv X1, xoff
	mov t, xl
	popz
	call PrintFromStringArray
	ret



	;--- Print RX channel value and text ---

PrintRxValue:

	pushz				;register Z (input parameter) points to the string array that will be used
	rcall PrintRxColon
	call Print16Signed		;register X and YH (input parameter) holds the RX channel value
	lrv X1, xoff

	tst xl				;print "Center" when value is zero
	brne prt5

	tst yh
	brne prt5

	ldz center*2
	call PrintString
	popz
	rjmp prt4

prt5:	rcall CompareXZminus10		;print specified text when value is below -10 and above 10
	brge prt1

	clr xl
	rjmp prt3

prt1:	rcall CompareXZplus10
	brge prt2

	ldi xl, 1			;close to center
	rjmp prt3

prt2:	ldi xl, 2

prt3:	popz

PrintRxText:

	mov t, xl
	call PrintFromStringArray

prt4:	call Linefeed
	ret



	;--- Print a colon (:) ---

PrintRxColon:

	lrv X1, 48
	ldi t, ':'
	call PrintChar
	lrv X1, 57
	ret



	;--- Check if stick input exceeds 10% ---

CompareXZminus10:

	ldz -10
	rjmp CompareXZ

CompareXZplus10:

	ldz 10

CompareXZ:

	cp  xl, zl
	cpc xh, zh
	ret

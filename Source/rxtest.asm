
.set xoff = 85					;X position for the channel value texts


RxTest:

	lds t, RxMode
	cpi t, RxModeCppm
	brne rxt2

	ser t					;CPPM mode
	sts flagRollValid, t
	sts flagPitchValid, t
	sts flagThrottleValid, t
	sts flagYawValid, t
	sts flagAuxValid, t

	rvbrflagtrue RxFrameValid, rxt2		;display a "NO SIGNAL" message if CPPM signal is absent

	call ShowNoCppmSignalDlg
	ret

rxt2:	lrv RxTimeoutLimit, 2

rxt1:	call GetRxChannels
	rcall ScaleInputValues			;divide RX values by 10

	call LcdClear6x8

	ldi t, 5				;print all channel labels first
	ldz rxch*2
	call PrintStringArray

	lrv Y1, 1				;aileron
	b16load RxRoll
	ldz ailtxt*2
	lds yl, flagRollValid
	rcall PrintRxValue

	b16load RxPitch				;elevator
	ldz eletxt*2
	lds yl, flagPitchValid
	rcall PrintRxValue

	rcall PrintRxColon			;throttle (needs special attention)
	rvbrflagtrue flagThrottleValid, rxt14

	ldz rxt8*2				;no throttle input
	call PrintString
	rcall UpdateRxCursorPos
	rjmp rxt13

rxt14:	b16load RxThrottle
	call Print16Signed
	lrv X1, xoff
	rvbrflagfalse flagThrottleZero, rxt4

	clr xl					;idle
	rjmp rxt6

rxt4:	no_offset_ldz 90
	rcall CompareXZ
	brge rxt5

	ldi xl, 1				;1 - 90%
	rjmp rxt6

rxt5:	ldi xl, 2				;full
	
rxt6:	ldz thrtxt*2
	rcall PrintRxText

rxt13:	b16load RxYaw				;rudder
	ldz rudtxt*2
	lds yl, flagYawValid
	rcall PrintRxValue

	rcall PrintRxColon			;aux (needs special attention)
	rvbrflagtrue flagAuxValid, rxt11

	ldz rxt8*2				;no aux input
	call PrintString
	rjmp rxt12

rxt11:	b16load RxAux
	call Print16Signed
	lrv X1, xoff
	lds t, AuxSwitchPosition
	ldz auxtxt*2
	call PrintFromStringArray

rxt12:	;footer
	lrv X1, 0
	lrv Y1, 57
	ldz bckmore*2
	call PrintString

	call LcdUpdate

	rcall RxPollDelay

	call GetButtons

	cpi t, 0x08				;BACK?
	brne rxt35

	ret

rxt35:	cpi t, 0x04				;MORE?
	brne rxt7

	call Beep				;go to the second screen
	rcall RxTest2

rxt7:	rjmp rxt1



	;--- Second screen ---

RxTest2:

	call GetRxChannels

	lds t, RxMode				;skip ahead if not serial input mode. This section is needed for Stand-alone Gimbal mode
	cpi t, RxModeSBus
	brlt rxt204

	lds t, RxBufferState			;update the display only when we have new data
	cpi t, 3
	breq rxt204

	ldi yl, 25				;wait 2.5ms
	call wms

	rvbrflagfalse RxFrameValid, rxt204	;update the display also when RX data has become invalid

	rjmp rxt203				;skip display update

rxt204:	call ScaleAuxInputValues		;divide RX values by 10
	b16mul RxAux4, RxAux4, Temp		;TEMP was set to 0.1 in ScaleAuxInputValues

	call LcdClear6x8

	clr xh					;print all channel labels first
	rcall PrintAuxLabels

	lrv Y1, 1				;aux2
	b16load RxAux2
	ldz notext*2
	ser yl
	call PrintRxValue

	b16load RxAux3				;aux3
	ldz notext*2
	ser yl
	call PrintRxValue

	rcall PrintRxColon			;aux4
	b16load RxAux4
	call Print16Signed
	lrv X1, xoff
	lds t, Aux4SwitchPosition
	ldz aux4txt*2
	call PrintFromStringArray

	;footer
	call PrintBackFooter

	call LcdUpdate

	lds t, RxMode				;skip delay if serial input mode. This is needed for Stand-alone Gimbal mode
	cpi t, RxModeSBus
	brge rxt203

	rcall RxPollDelay

rxt203:	call GetButtons

	cpi t, 0x08				;BACK?
	brne rxt202

	call Beep				;return to the first RX test screen
	call ReleaseButtons
	ret

rxt202:	rjmp rxTest2




rxt8:	.db "No signal", 0

null:	.db 0, 0
left:	.db "Left", 0, 0
right:	.db "Right", 0
fwd:	.db "Forward", 0
rev:	.db "Back", 0, 0
idle:	.db "Idle", 0, 0
full:	.db "Full", 0, 0
center:	.db "Center", 0, 0

notext:	.dw null*2+offset, null*2+offset, null*2+offset
ailtxt:	.dw left*2+offset, null*2+offset, right*2+offset
eletxt:	.dw fwd*2+offset, null*2+offset, rev*2+offset
thrtxt:	.dw idle*2+offset, null*2+offset, full*2+offset
rudtxt:	.dw right*2+offset, null*2+offset, left*2+offset



	;--- Print AUX labels at specified X offset ---

PrintAuxLabels:

	ldi xl, '2'

pal1:	sts X1, xh				;register XH (input parameter) holds the X offset
	ldz aux*2
	call PrintString
	mov t, xl
	call PrintChar
	call LineFeed
	inc xl
	cpi xl, '5'
	brne pal1

	ret



	;--- Print RX channel value and text ---

PrintRxValue:

	rcall PrintRxColon
	brflagtrue yl, prt6			;register YL (input parameter) holds the "Valid Signal" flag

	ldz rxt8*2				;no signal
	call PrintString
	rjmp UpdateRxCursorPos

prt6:	pushz					;register Z (input parameter) points to the string array that will be used
	call Print16Signed			;register X and YH (input parameter) holds the RX channel value
	lrv X1, xoff

	tst xl					;print "Center" when value is zero
	brne prt5

	tst yh
	brne prt5

	ldz center*2
	call PrintString
	popz
	rjmp prt4

prt5:	rcall CompareXZminus10			;print specified text when value is below -10 and above 10
	brge prt1

	clr xl
	rjmp prt3

prt1:	rcall CompareXZplus10
	brge prt2

	ldi xl, 1				;close to center
	rjmp prt3

prt2:	ldi xl, 2

prt3:	popz

PrintRxText:

	mov t, xl
	call PrintFromStringArray

UpdateRxCursorPos:

	lrv X1, 57

prt4:	call LineFeed
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

	no_offset_ldz -10
	rjmp CompareXZ

CompareXZplus10:

	no_offset_ldz 10

CompareXZ:

	cp  xl, zl
	cpc xh, zh
	ret



	;--- Delay for RX polling ---

RxPollDelay:

	ldi yh, 5				;128ms delay

rpd1:	ldi yl, 0
	call wms
	dec yh
	brne rpd1

	ret



	;--- Scale inputs (divide by 10) ---

ScaleInputValues:

	b16ldi Temp, 0.1
	b16mul RxRoll, RxRoll, Temp
	b16mul RxPitch, RxPitch, Temp
	b16mul RxYaw, RxYaw, Temp
	b16mul RxAux, RxAux, Temp

	b16ldi Temp, 0.053
	b16mul RxThrottle, RxThrottle, Temp
	ret


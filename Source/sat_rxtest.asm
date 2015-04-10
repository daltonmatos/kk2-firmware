
.set xoff = 85				;X position for the channel value texts


SatRxTest:

art1:	rvbrflagtrue RxFrameValid, art2	;display a "NO SIGNAL" message if Satelite signal is absent

	call ShowNoSatDataDlg
	ret

art2:	call GetSatChannels

	lds t, RxBufferState		;update the display only when we have new data
	cpi t, 3
	breq art8

	ldi yl, 25			;wait 2.5ms
	call wms
	rjmp art30			;skip display update

art8:	b16ldi Temp, 0.1
	b16mul RxRoll, RxRoll, Temp
	b16mul RxPitch, RxPitch, Temp
	b16mul RxYaw, RxYaw, Temp
	b16mul RxAux, RxAux, Temp

	b16ldi Temp, 0.053
	b16mul RxThrottle, RxThrottle, Temp

	call LcdClear6x8

	clr t				;print all channel labels first

art3:	push t
	ldz rxch*2
	call PrintFromStringArray
	lrv X1, 48
	call PrintColonAndSpace
	lrv X1, 0
	rvadd Y1, 9
	pop t
	inc t
	cpi t, 5
	brne art3

	lrv X1, 57			;aileron
	lrv Y1, 1
	b16load RxRoll
	ldz ailtxt*2
	ser t
	call PrintRxValue

	b16load RxPitch			;elevator
	ldz eletxt*2
	ser t
	call PrintRxValue

	b16load RxThrottle		;throttle (needs special attention)
	call Print16Signed
	lrv X1, xoff
	rvbrflagfalse flagThrottleZero, art4

	clr t				;idle
	rjmp art6

art4:	ldz 90
	call CompareXZ
	brge art5

	ldi t, 1			;1 - 90%
	rjmp art6

art5:	ldi t, 2			;full
	
art6:	ldz thrtxt*2
	call PrintRxText

	b16load RxYaw			;rudder
	ldz rudtxt*2
	ser t
	call PrintRxValue

	b16load RxAux			;aux (needs special attention)
	call Print16Signed
	lrv X1, xoff
	lds t, AuxSwitchPosition
	ldz auxtxt*2
	call PrintFromStringArray

	;footer
	lrv X1, 0
	lrv Y1, 57
	ldz rxt2m*2
	call PrintString

	call LcdUpdate

art30:	call GetButtons
	cpi t, 0x08			;BACK?
	brne art35

	ret	

art35:	cpi t, 0x04			;MORE?
	brne art7

	call Beep
	rcall SatRxTest2

art7:	rjmp art1




	;--- Second screen ---

SatRxTest2:

	call GetRxChannels

	lds t, RxBufferState		;update the display only when we have new data
	cpi t, 4
	breq art204

	ldi yl, 25			;wait 2.5ms
	call wms
	rjmp art203			;skip update

art204:	call ScaleAuxInputValues

	call LcdClear6x8

	ldi xl, '2'			;print all channel labels first

art201:	ldz aux*2
	call PrintString
	mov t, xl
	call PrintChar
	lrv X1, 48
	call PrintColonAndSpace
	lrv X1, 0
	rvadd Y1, 9
	inc xl
	cpi xl, '4'
	brne art201

	lrv X1, 57			;aux2
	lrv Y1, 1
	b16load RxAux2
	call Print16Signed

	call UpdateRxCursorPos		;aux3
	b16load RxAux3
	call Print16Signed

	;footer
	call PrintBackFooter

	call LcdUpdate

art203:	call GetButtons

	cpi t, 0x08			;BACK?
	brne art202

	call Beep
	call ReleaseButtons
	ret				;return to the first RX test screen

art202:	rjmp SatRxTest2




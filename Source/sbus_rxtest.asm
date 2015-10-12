
.set xoff = 85				;X position for the channel value texts


SBusRxTest:

srt1:	call GetSBusFlags
	lds t, RxFrameValid
	tst t
	brne srt2

	call ShowNoSBusDataDlg
	ret

srt2:	call GetSBusChannels

	lds t, RxBufferState		;update the display only when we have new data
	cpi t, 3
	breq srt8

	ldi yl, 25			;wait 2.5ms
	call wms
	rjmp srt30			;skip display update

srt8:	b16ldi Temp, 0.1
	b16mul RxRoll, RxRoll, Temp
	b16mul RxPitch, RxPitch, Temp
	b16mul RxYaw, RxYaw, Temp
	b16mul RxAux, RxAux, Temp

	b16ldi Temp, 0.053
	b16mul RxThrottle, RxThrottle, Temp

	call LcdClear6x8

	clr t				;print all channel labels first

srt3:	push t
	ldz rxch*2
	call PrintFromStringArray
	lrv X1, 48
	call PrintColonAndSpace
	lrv X1, 0
	rvadd Y1, 9
	pop t
	inc t
	cpi t, 5
	brne srt3

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
	rvbrflagfalse flagThrottleZero, srt4

	clr t				;idle
	rjmp srt6

srt4:	no_offset_ldz 90
	call CompareXZ
	brge srt5

	ldi t, 1			;1 - 90%
	rjmp srt6

srt5:	ldi t, 2			;full
	
srt6:	ldz thrtxt*2
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

srt30:	call GetButtons

	cpi t, 0x08			;BACK?
	brne srt35

	ret	

srt35:	cpi t, 0x04			;MORE?
	brne srt7

	call Beep
	rcall SBusRxTest2

srt7:	rjmp srt1




	;--- Second screen ---

SBusRxTest2:

	call GetSBusChannels

	lds t, RxBufferState		;update the display only when we have new data
	cpi t, 4
	breq srt204

	ldi yl, 25			;wait 2.5ms
	call wms
	rjmp srt203			;skip display update

srt204:	call ScaleAuxInputValues
	b16mul RxAux4, RxAux4, Temp	;TEMP was set to 0.1 in ScaleAuxInputValues

	call LcdClear6x8

	ldi xl, '2'			;print all channel labels first

srt201:	ldz aux*2
	call PrintString
	mov t, xl
	call PrintChar
	lrv X1, 48
	call PrintColonAndSpace
	lrv X1, 0
	rvadd Y1, 9
	inc xl
	cpi xl, '5'
	brne srt201

	lrv X1, 57			;aux2
	lrv Y1, 1
	b16load RxAux2
	call Print16Signed

	call UpdateRxCursorPos		;aux3
	b16load RxAux3
	call Print16Signed

	call UpdateRxCursorPos		;aux4
	b16load RxAux4
	call Print16Signed
	lrv X1, xoff
	lds t, Aux4SwitchPosition
	ldz aux4txt*2
	call PrintFromStringArray

	;footer
	call PrintBackFooter

	call LcdUpdate

srt203:	call GetButtons

	cpi t, 0x08			;BACK?
	brne srt202

	call Beep
	call ReleaseButtons
	ret				;return to the first RX test screen

srt202:	rjmp SBusRxTest2





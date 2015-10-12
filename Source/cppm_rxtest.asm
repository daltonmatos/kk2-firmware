
.set xoff = 85				;X position for the channel value texts


CppmRxTest:

	rvbrflagtrue RxFrameValid, crt2	;display a "NO SIGNAL" message if CPPM signal is absent

	call ShowNoCppmSignalDlg
	ret

crt2:	lrv CppmTimeoutLimit, 2

crt1:	call GetCppmChannels

	b16ldi Temp, 0.1
	b16mul RxRoll, RxRoll, Temp
	b16mul RxPitch, RxPitch, Temp
	b16mul RxYaw, RxYaw, Temp
	b16mul RxAux, RxAux, Temp

	b16ldi Temp, 0.053
	b16mul RxThrottle, RxThrottle, Temp

	call LcdClear6x8

	clr t				;print all channel labels first

crt3:	push t
	ldz rxch*2
	call PrintFromStringArray
	lrv X1, 48
	call PrintColonAndSpace
	lrv X1, 0
	rvadd Y1, 9
	pop t
	inc t
	cpi t, 5
	brne crt3

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
	rvbrflagfalse flagThrottleZero, crt4

	clr t				;idle
	rjmp crt6

crt4:	no_offset_ldz 90
	call CompareXZ
	brge crt5

	ldi t, 1			;1 - 90%
	rjmp crt6

crt5:	ldi t, 2			;full
	
crt6:	ldz thrtxt*2
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

	call RxPollDelay

	call GetButtons
	cpi t, 0x08			;BACK?
	brne crt35

	ret	

crt35:	cpi t, 0x04			;MORE?
	brne crt7

	call Beep
	rcall CppmRxTest2

crt7:	rjmp crt1




	;--- Second screen ---

CppmRxTest2:

	call GetCppmChannels
	call ScaleAuxInputValues
	b16mul RxAux4, RxAux4, Temp	;TEMP was set to 0.1 in ScaleAuxInputValues

	call LcdClear6x8

	ldi xl, '2'			;print all channel labels first

crt201:	ldz aux*2
	call PrintString
	mov t, xl
	call PrintChar
	lrv X1, 48
	call PrintColonAndSpace
	lrv X1, 0
	rvadd Y1, 9
	inc xl
	cpi xl, '5'
	brne crt201

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

	call RxPollDelay

	call GetButtons
	cpi t, 0x08			;BACK?
	brne crt202

	call Beep
	call ReleaseButtons
	ret				;return to the first RX test screen

crt202:	rjmp CppmRxTest2




rxt2m:	.db "BACK MORE", 0




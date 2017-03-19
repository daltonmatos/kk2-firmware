
.set xoff = 85					;X position for the channel value texts


SerialRxTest:

	lds t, RxMode
	cpi t, RxModeSBus
	brne srt2

	call GetSBusFlags			;S.Bus mode

srt2:	rvbrflagtrue flagRxFrameValid, srt3

	call NoSerialDataDlg
	ret

srt3:	ldi t, 5				;initial timeout value for LCD update
	mov ka, t

srt1:	call GetRxChannels

	rvbrflagtrue flagNewRxFrame, srt8	;update the display when we have new data

	ldi yl, 20				;wait 2ms
	call wms

	dec ka
	brpl srt1

srt8:	ldi t, 50
	mov ka, t

	call ScaleInputValues			;divide RX values by 10

	call LcdClear6x8

	ldi t, 5				;print all channel labels first
	ldz rxch*2
	call PrintStringArray

	lrv Y1, 1				;aileron
	b16load RxRoll
	ldz ailtxt*2
	ser yl
	call PrintRxValue

	b16load RxPitch				;elevator
	ldz eletxt*2
	ser yl
	call PrintRxValue

	call PrintRxColon			;throttle (needs special attention)
	b16load RxThrottle
	call Print16Signed
	lrv X1, xoff
	rvbrflagfalse flagThrottleZero, srt4

	clr xl					;idle
	rjmp srt6

srt4:	ldz 90
	call CompareXZ
	brge srt5

	ldi xl, 1				;1 - 90%
	rjmp srt6

srt5:	ldi xl, 2				;full
	
srt6:	ldz thrtxt*2
	call PrintRxText

	b16load RxYaw				;rudder
	ldz rudtxt*2
	ser yl
	call PrintRxValue

	call PrintRxColon			;aux (needs special attention)
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

	call GetButtons

	cpi t, 0x08				;BACK?
	brne srt35

	ret

srt35:	cpi t, 0x04				;MORE?
	brne srt7

	call Beep				;go to the second screen
	rcall SerialRxTest2

srt7:	rjmp srt1



	;--- Second screen ---

SerialRxTest2:

	ldi t, 5				;initial timeout value for LCD update
	mov ka, t

srt210:	call GetRxChannels

	lds t, RxMode				;read S.Bus flags in S.Bus mode only
	cpi t, RxModeSBus
	brne srt201

	call GetSBusFlags

srt201:	rvbrflagtrue flagNewRxFrame, srt204	;update the display when we have new data

	ldi yl, 20				;wait 2ms
	call wms

	dec ka
	brpl srt210

srt204:	ldi t, 50
	mov ka, t

	call ScaleAuxInputValues		;divide RX values by 10
	b16mul RxAux4, RxAux4, Temp		;TEMP was set to 0.1 in ScaleAuxInputValues

	call LcdClear6x8

	clr xh					;print all AUX channel labels first
	call PrintAuxLabels

	lrv Y1, 1				;aux2
	b16load RxAux2
	ldz notext*2
	ser yl
	call PrintRxValue

	b16load RxAux3				;aux3
	ldz notext*2
	ser yl
	call PrintRxValue

	call PrintRxColon			;aux4
	b16load RxAux4
	call Print16Signed
	lrv X1, xoff
	lds t, Aux4SwitchPosition
	ldz aux4txt*2
	call PrintFromStringArray

	lds t, RxMode				;print digital channels in S.Bus mode only
	cpi t, RxModeSBus
	brne srt205

	lds xl, Channel17			;digital channel 1
	ldz dg1*2
	ldy dg1txt*2
	rcall PrintDigitalChannel

	lds xl, Channel18			;digital channel 2
	ldz dg2*2
	ldy dg2txt*2
	call PrintDigitalChannel

srt205:	;footer
	call PrintBackFooter

	call LcdUpdate

	call GetButtons

	cpi t, 0x08				;BACK?
	brne srt202

	call Beep				;return to the first RX test screen
	call ReleaseButtons
	ret

srt202:	rjmp srt210



dg1:	.db "DG1", 0
dg2:	.db "DG2", 0

dg1txt:	.dw off*2, alarm*2
dg2txt:	.dw off*2, on*2



	;--- Print digital channel states (DG1/DG2) ---

PrintDigitalChannel:

	pushy					;register Y (input parameter) points to the string array
	push xl					;register XL (input parameter) holds the input value from DG1 or DG2
	lrv X1, 0
	call LineFeed
	call PrintString			;register Z (input parameter) points to the label
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



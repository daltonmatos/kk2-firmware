

ShowNoSBusDataDlg:

	call LcdClear12x16

	lrv X1, 22			;header
	ldz pnd1*2
	call PrintString

	lrv FontSelector, f6x8

	lrv X1, 0			;print "Please supply S.Bus data to the throttle input connector."
	lrv Y1, 17
	clr t

pnd11:	push t
	ldz pnd8*2
	call PrintFromStringArray
	lrv X1, 0
	rvadd Y1, 9
	pop t
	inc t
	cpi t, 3
	brne pnd11

	;footer
	call PrintBackFooter

	call LcdUpdate

pnd10:	call GetButtonsBlocking
	cpi t, 0x08			;BACK?
	brne pnd10

	ret



pnd1:	.db "NO DATA", 0
pnd2:	.db "Please supply S.Bus", 0
pnd3:	.db "data to the elevator", 0, 0
pnd4:	.db "input connector.", 0, 0

pnd8:	.dw pnd2*2, pnd3*2, pnd4*2


	;---

ClearSBusErrors:

	clr t
	sts FrameLossMax, t
	sts FrameLossCounter, t
	sts FrameCounter, t
	sts Failsafe, t

	lds t, StatusBits		;clear the S.Bus status bits
	andi t, 0x0F
	sts StatusBits, t
	ret


	;---

GetSBusFlags:

	lds t, RxBufferState		;RX timeout?
	cpi t, SBusTimeoutLimit
	brlt sbf7

	ldi t, SBusTimeoutLimit		;yes, prevent wrap-around
	sts RxBufferState, t

	clr t				;tag S.Bus frame as invalid
	sts RxFrameValid, t

	ser t				;sound the alarm
	sts flagAlarmOverride, t
	rjmp sbf6			;exit and set status bit to refuse arming

sbf7:	cpi t, 3			;no timeout. Is this a new frame?
	breq sbf3

	ret				;no, will wait for a new frame

sbf3:	lds t, FrameCounter		;yes, count new frames only
	inc t
	cpi t, 100
	brne sbf4

	lds t, FrameLossCounter		;check the frame loss counter every 100th frame
	lds xl, FrameLossMax
	cp xl, t
	brge sbf8

	sts FrameLossMax, t		;save the highest frame loss value

sbf8:	clr t
	sts FrameLossCounter, t

sbf4:	sts FrameCounter, t



	;--- Decode S.Bus flags ---

	;S.Bus flags (4 bit) are stored in SBusFlags:
	;S.Bus data received:	----4567

	lds xl, SBusFlags
	lds xh, RxFrameValid
	tst xh				;is S.Bus data frame valid?
	brne sbf5

sbf6:	setstatusbit NoSBusInput	;no, exit and refuse arming
	ret

sbf5:	lds t, StatusBits		;yes, clear the "No S.Bus data" error
	cbr t, NoSBusInput
	sts StatusBits, t

	mov t, xl			;read digital channel 17
	andi t, 0x01
	sts Channel17, t

	dec t				;activate alarm when channel 17 is on
	com t
	sts flagAlarmOverride, t

	lsr xl				;read digital channel 18
	mov t, xl
	andi t, 0x01
	sts Channel18, t

	lsr xl				;check the 'Frame Lost' flag
	mov t, xl
	andi t, 0x01
	breq sbf2

	lds t, FrameLossCounter		;increase the frame loss counter
	inc t
	sts FrameLossCounter, t

sbf2:	lsr xl				;set the 'Failsafe' flag if one or more failsafe situations occurred
	andi xl, 0x01
	breq sbf1

	sts Failsafe, xl
	setstatusbit SBusFailsafe
	ser t
	sts flagAlarmOverride, t	;activate the Lost Model alarm

sbf1:	ret



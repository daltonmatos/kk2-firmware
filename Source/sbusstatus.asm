

ShowNoDataDlg:

	call LcdClear12x16

	lrv X1, 22
	ldi t, 67			;the character 'N' in the mangled 12x16 font
	call PrintChar
	ldi t, 68			;the character 'O' in the mangled 12x16 font
	call PrintChar

	lrv X1, 58			;print "DATA"
	ldz pnd1*2
	call PrintHeader

	ldi t, 3			;print "Please supply S.Bus data to the throttle input connector."
	ldz pnd8*2
	call PrintStringArray

	;footer
	call PrintBackFooter

	call LcdUpdate

pnd10:	call GetButtonsBlocking
	cpi t, 0x08			;BACK?
	brne pnd10

	ret



pnd1:	.db 60, 58, 71, 58, 0, 0	;the text "DATA" in the mangled 12x16 font

pnd2:	.db "Please supply S.Bus", 0
pnd3:	.db "data to the throttle", 0, 0
pnd4:	.db "input connector.", 0, 0

pnd8:	.dw pnd2*2, pnd3*2, pnd4*2



	;--- Read S.Bus flags ---

GetSBusFlags:

	;S.Bus flags (4 bit) are stored in SBusFlags:
	;S.Bus data received:	----4567

	lds xl, SBusFlags
	lds xh, flagSBusFrameValid
	tst xh				;is S.Bus data frame valid?
	brne sbf5

	setstatusbit NoSBusInput	;no, exit and refuse arming
	ret

sbf5:	lds t, StatusBits		;yes, clear the "No S.Bus data" error
	cbr t, NoSBusInput
	sts StatusBits, t

	mov t, xl			;read digital channel 17
	andi t, 0x01
	sts Channel17, t

	dec t				;activate alarm when channel 17 is on
	com t
	lds xh, flagAlarmOn
	sts flagAlarmOn, t

	eor t, xh			;reset the delay counter when channel 17 changes state
	breq sbf9

	ldi t, 50
	sts AuxBeepDelay, t

sbf9:	lsr xl				;read digital channel 18
	mov t, xl
	andi t, 0x01
	sts Channel18, t

	lsr xl				;ignore the 'Frame Lost' flag

	lsr xl				;set the 'Failsafe' flag if one or more failsafe situations occurred
	andi xl, 0x01
	breq sbf1

	sts Failsafe, xl
	setstatusbit SBusFailsafe
	rvsetflagtrue flagAlarmOverride	;activate the Lost Model alarm

sbf1:	ret





UpdateFlightDisplay:

	rvsetflagtrue flagMutePwm

	call LcdClear12x16


	;--- Print armed status ---

	rvbrflagfalse flagArmed, udp3

	lrv X1, 34				;Armed
	lrv Y1, 22
	ldz armed*2
	call PrintHeader

	ldz udp7*2				;banner
	call PrintSelector

	lrv Y1, 45
	call PrintMotto
	rjmp udp21

udp3:	lrv X1, 38				;Safe
	ldz safe*2
	call PrintHeader


	;--- Flight timer ---

	lrv X1, 0
	lrv Y1, 1
	lds xl, Timer1min
	lds yl, Timer1sec
	rcall PrintTimer


	;--- Print status ---

	lrv X1, 0
	lrv Y1, 17
	rcall PrintStatusString

	lds t, StatusBits			;display the selected tuning mode if status is OK, throttle is idle and Tuning Mode is active
	cbr t, LvaWarning			;ignore the LVA warning bit
	lds xl, flagThrottleZero
	com xl					;the throttle zero flag must be inverted
	or t, xl
	brne udp25

	lds t, TuningMode
	tst t
	breq udp51

	ldz udp6*2				;Tuning
	call PrintString
	lds t, TuningMode
	cpi t, 1				;print "Ail+Ele" if tuning aileron when linked with elevator
	brne udp24

	lds xl, flagRollPitchLink
	tst xl
	breq udp24

	ldz ailele*2
	call PrintString
	rjmp udp51

udp24:	ldz tunmode*2
	call PrintFromStringArray
	rjmp udp51

udp25:	lds t, StatusCounter			;flashing status text banner
	inc t
	sts StatusCounter, t
	andi t, 0x01
	breq udp51

	ldz udp8*2				;highlight the status text
	call PrintSelector


udp51:	;--- Print flight mode ---

	lrv X1, 0				;mode
	lrv Y1, 27
	ldz flmode*2
	call PrintString

	clr t					;acro mode is assumed
	rvbrflagfalse flagSlOn, udp50

	ldi t, 2				;normal SL
	rjmp udp52

udp50:	rvbrflagfalse flagSlStickMixing, udp52

	ldi t, 1				;SL mix

udp52:	ldz auxfn*2
	call PrintFromStringArray


	;--- Print battery voltages ---

	lrv Y1, 36
	ldz batt*2
	b16mov Temper, BatteryVoltage
	rcall PrintVoltage

	ldz ublog*2
	b16mov Temper, BatteryVoltageLogged
	call PrintVoltage


	;--- Print footer ---

	lrv X1, 102				;footer
	lrv Y1, 57
	ldz upd1*2
	call PrintString

udp21:	call LcdUpdate

	rvsetflagfalse flagMutePwm
	ret



	;--- Print voltage value ---

PrintVoltage:

	lrv X1, 0				;label
	call PrintString

	b16ldi Temp, 6.875067139		;calculate value
	b16mul Temp, Temper, Temp
	b16fdiv Temp, 8

	b16load Temp				;print the integer part
 	call Print16Signed
	
	ldi t, '.'
	call PrintChar

	mov xl, yh				;print the fractional part (one digit)
	clr xh
	clr yh
	b16store Temp
	b16ldi Temper, 0.0390625
	b16mul Temp, Temp, Temper
	b16load Temp
	call Print16Signed

	ldi t, 'V'
	call PrintChar
	call LineFeed
	ret



	;--- Print timer value ---

PrintTimer:

	cpi xl, 10				;minutes
	brge ptim1

	ldi t, '0'				;print leading zero
	call PrintChar

ptim1:	clr xh
	call Print16Signed
	ldi t, ':'
	call PrintChar

	mov xl, yl				;seconds
	cpi xl, 10
	brge ptim2

	ldi t, '0'				;print leading zero
	call PrintChar

ptim2:	call Print16Signed
	ret



upd1:	.db "MENU", 0, 0
safe:	.db 70, 58, 62, 61, 0, 0		;the text "SAFE" in the mangled 12x16 font
armed:	.db 58, 69, 66, 61, 60, 0		;the text "ARMED" in the mangled 12x16 font

udp6:	.db ". Tuning ", 0

udp7:	.db 0, 19, 127, 40
udp8:	.db 0, 16, 127, 25

flmode:	.db "Mode   : ", 0
batt:	.db "Battery: ", 0
ublog:	.db "Logged : ", 0


// Status messages organized by priority (high to low)
sta1:	.db "No motor layout!", 0, 0
sta2:	.db "ACC not calibrated.", 0
sta3:	.db "Sanity check failed!", 0, 0
sta4:	.db "RX signal was lost!", 0
sta5:	.db "Bad channel mapping!", 0, 0
sta6:	.db "Sat protocol error!", 0
sta7:	.db "No Satellite input!", 0
sta8:	.db "Check throttle level.", 0

status:	.dw ok*2, sta8*2, sta7*2, sta6*2, sta5*2, sta4*2, sta3*2, sta2*2, sta1*2



	;--- Print status string ---

PrintStatusString:

	lds xl, StatusBits
	cbr xl, LvaWarning			;no error message displayed for LVA warning

	lds xh, flagThrottleZero		;the LvaWarning bit will be replaced by CheckThrottleLevel state
	com xh
	andi xh, CheckThrottleLevel
	or xl, xh

	ldi t, 8				;loop counter

pss1:	lsr xl
	brcs pss2

	dec t
	brne pss1

pss2:	ldz status*2				;print "OK" or one of the status messages above
	call PrintFromStringArray
	ret



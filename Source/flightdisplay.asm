

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
	call PrintString


	;--- Print user profile selection ---

	lrv X1, 102
	ldi t, 69				;character 'P' in the mangled 12x16 font
	call PrintChar
	ldi t, 49				;character '1' in the mangled 12x16 font
	lds xl, UserProfile
	add t, xl
	call PrintChar
	lrv FontSelector, f6x8


	;--- Flight timer ---

	lrv X1, 0
	lrv Y1, 1
	lds xl, Timer1min
	lds yl, Timer1sec
	rcall PrintTime


	;--- Print status ---

	lrv X1, 0
	lrv Y1, 17
	ldz ok*2				;default string is "OK"
	rcall LoadStatusString
	call PrintString

	lds t, StatusBits			;check status
	cbr t, LvaWarning			;ignore the LVA warning bit
	lds xl, flagThrottleZero
	com xl					;the throttle zero flag must be inverted
	or t, xl
	breq udp51

	lds t, StatusCounter			;flashing status text banner
	inc t
	sts StatusCounter, t
	andi t, 0x01
	breq udp51

	ldz udp8*2				;highlight the status text
	call PrintSelector


udp51:	;--- Print flight mode and alarm status ---

	lrv X1, 0				;flight mode
	lrv Y1, 27
	ldz flmode*2
	call PrintString
	rcall PrintFlightMode

	rvbrflagfalse flagAlarmOn, udp53	;alarm status

	ldi t, '+'				;alarm is active
	call PrintChar
	ldz alarm*2
	call PrintString


udp53:	;--- Print battery voltages ---

	call LineFeed				;live battery voltage
	ldz batt*2
	b16mov Temper, BatteryVoltage
	rcall PrintVoltage

	call LineFeed				;lowest battery voltage logged
	ldz ublog*2
	b16mov Temper, BatteryVoltageLogged
	rcall PrintVoltage


	;--- Print footer ---

	lrv X1, 36				;footer
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
	ret



	;--- Print timer value ---

PrintTime:

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



	;--- Print flight mode ---

PrintFlightMode:

	rvbrflagfalse flagSlOn, pfm1

	ldz normsl*2				;normal SL
	call PrintString
	ret

pfm1:	rvbrflagfalse flagSlStickMixing, pfm2

	ldz slmix*2				;SL mix
	call PrintString
	ret

pfm2:	ldz acro*2				;acro
	call PrintString
	ret



upd1:	.db "<PROFILE>  MENU", 0
safe:	.db 71, 58, 62, 61, 0, 0		;the text "SAFE" in the mangled 12x16 font
armed:	.db 58, 70, 66, 61, 60, 0		;the text "ARMED" in the mangled 12x16 font

udp7:	.db 0, 19, 127, 40
udp8:	.db 0, 16, 127, 25

flmode:	.db "Mode   : ", 0
batt:	.db "Battery: ", 0
ublog:	.db "Logged : ", 0

sta1:	.db "ACC not calibrated.", 0
sta2:	.db "No aileron input.", 0
sta3:	.db "No elevator input.", 0, 0
sta4:	.db "No throttle input.", 0, 0
sta5:	.db "No rudder input.", 0, 0
sta6:	.db "Sanity check failed.", 0, 0
sta7:	.db "No motor layout!", 0, 0
sta8:	.db "Check throttle level.", 0
sta9:	.db "RX signal was lost!", 0



	;--- Load status string ---

LoadStatusString:

	lds t, StatusBits
	cbr t, LvaWarning			;no error message displayed for LVA warning
	brne lss10

	rvbrflagtrue flagThrottleZero, lss8	;no critical flags are set so we'll display a warning if throttle is above idle

	ldz sta8*2				;check throttle level

lss8:	ret

lss10:	lds t, StatusBits
	andi t, RxSignalLost
	cpi t, RxSignalLost
	brne lss1

	ldz sta9*2				;RX signal was lost
	ret

lss1:	lds t, StatusBits
	andi t, NoMotorLayout
	breq lss2

	ldz sta7*2				;no motor layout
	ret

lss2:	lds t, StatusBits
	andi t, AccNotCalibrated
	breq lss3

	ldz sta1*2				;ACC not calibrated
	ret

lss3:	lds t, StatusBits
	andi t, SanityCheckFailed
	breq lss4

	ldz sta6*2				;sanity check failed
	ret

lss4:	lds t, StatusBits
	andi t, NoAileronInput
	breq lss5

	ldz sta2*2				;no aileron input
	ret

lss5:	lds t, StatusBits
	andi t, NoElevatorInput
	breq lss6

	ldz sta3*2				;no elevator input
	ret

lss6:	lds t, StatusBits
	andi t, NoThrottleInput
	breq lss7

	ldz sta4*2				;no throttle input
	ret

lss7:	ldz sta5*2				;no rudder input
	ret




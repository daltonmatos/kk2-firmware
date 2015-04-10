

UpdateFlightDisplay:

	rvsetflagtrue flagMutePwm

	call LcdClear12x16


	;--- Print armed status ---

	rvbrflagfalse flagArmed, udp3

	lrv X1, 34				;Armed
	lrv Y1, 22
	ldz upd5*2
	call PrintString

	ldz udp7*2				;banner
	call PrintSelector

	lrv Y1, 45
	lrv FontSelector, f6x8
	call PrintMotto
	rjmp udp21

udp3:	lrv X1, 38				;Safe
	ldz upd2*2
	call PrintString


	;--- Print footer ---

	lrv X1, 102				;footer
	lrv Y1, 57
	lrv FontSelector, f6x8
	ldz upd1*2
	call PrintString


	;--- Print status ---

	lrv X1, 0
	lrv Y1, 17
	ldz ok*2				;default string is "OK"
	rcall LoadStatusString
	call PrintString

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
	ldz udp9*2
	call PrintString
	lds t, AuxSwitchPosition
	ldz modetxt*2
	call PrintFromStringArray		;ACRO, SL MIXING or NORMAL SL



udp13:	;--- Print battery voltages ---

	lrv Y1, 36
	ldz batt*2
	b16mov Temper, BatteryVoltage
	rcall PrintVoltage

	ldz ublog*2
	b16mov Temper, BatteryVoltageLogged
	call PrintVoltage


	;---

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
	b16store Temp

	b16ldi Temper, 0.0390625
	b16mul Temp, Temp, Temper
	b16load Temp

	cpi xl, 10				;print a single digit only
	brlt pdc1

	ldi xl, 9

pdc1: 	call Print16Signed
	ldi t, 'V'
	call PrintChar

	rvadd Y1, 9
	ret



upd1:	.db "MENU", 0, 0
upd2:	.db 70, 58, 62, 61, 0, 0		;the text "SAFE" in the mangled 12x16 font
upd5:	.db 58, 69, 66, 61, 60, 0		;the text "ARMED" in the mangled 12x16 font

udp6:	.db ". Tuning ", 0

udp7:	.db 0, 19, 127, 40
udp8:	.db 0, 16, 127, 25

udp9:	.db "Mode   : ", 0
udp10:	.db "ACRO", 0, 0
udp11:	.db "SL MIXING", 0
udp12:	.db "NORMAL SL", 0

modetxt:.dw udp10*2, udp11*2, udp12*2

batt:	.db "Battery: ", 0
ublog:	.db "Logged : ", 0

sta1:	.db "ACC not calibrated.", 0
sta6:	.db "Sanity check failed.", 0, 0
sta7:	.db "No motor layout!", 0, 0
sta8:	.db "Check throttle level.", 0

sta31:	.db "No S.Bus input!", 0
sta32:	.db "FAILSAFE!", 0



	;--- Load status string ---

LoadStatusString:

	lds t, StatusBits
	cbr t, LvaWarning			;no error message displayed for LVA warning
	tst t
	brne lss1

	rvbrflagtrue flagThrottleZero, lss8	;no critical flags are set so we'll display a warning if throttle is above idle

	ldz sta8*2				;check throttle level

lss8:	ret

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
	andi t, NoSBusInput
	breq lss5

	ldz sta31*2				;no S.Bus input
	ret

lss5:	ldz sta32*2				;failsafe
	ret




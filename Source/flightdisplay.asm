

UpdateFlightDisplay:

	rvsetflagtrue flagMutePwm

	call LcdClear12x16


	;--- Logged error ---

	call ErrorLog				;will show the error log if any error has been logged
	brcc udp1

	rjmp udp21				;the error log is displayed so we'll just skip to the end


udp1:	;--- Print armed status ---

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
	ldi t, 'P'
	call PrintChar
	ldi t, '1'
	lds xl, UserProfile
	add t, xl
	call PrintChar
	lrv FontSelector, f6x8
	lrv X1, 0


	;--- Gimbal controller mode ---

	rvbrflagfalse flagGimbalMode, udp4

	lrv Y1, 17				;stand-alone gimbal controller mode
	ldi t, 2
	ldz gblmode*2
	call PrintStringArray

	lrv X1, 1				;camera icon
	lrv Y1, 0
	lrv FontSelector, s16x16
	ldi t, 4
	call PrintChar
	lrv FontSelector, f6x8

	lrv Y1, 44				;LVA setting and footer
	rjmp udp20


udp4:	;--- Flight timer ---

	lrv Y1, 1
	lds xl, Timer1min
	lds yl, Timer1sec
	rcall PrintTimer


	;--- Print status ---

	lrv X1, 0
	lrv Y1, 17
	ldz ok*2				;default string is "OK"
	rcall LoadStatusString
	call PrintString

	brts udp25				;skip ahead if status bits are set (T flag is set in LoadStatusString)

	lds t, TuningMode			;display the selected tuning mode
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


udp51:	;--- Print flight mode and stick scaling offset ---

	lrv X1, 0				;flight mode
	lrv Y1, 27
	ldz flmode*2
	rcall PrintFlightMode

	lrv X1, 84				;stick scaling offset selected from AUX switch position
	lds t, AuxStickScaling
	tst t					;skip printing when zero
	breq udp54

	ldz auxss*2
	call PrintFromStringArray


udp54:	;--- Print battery voltages ---

	lrv X1, 0				;live battery voltage
	call LineFeed
	ldz batt*2
	call PrintString
	b16mov Temper, BatteryVoltage
	rcall PrintVoltage

	lrv X1, 84				;lowest battery voltage logged
	b16mov Temper, BatteryVoltageLogged
	rcall PrintVoltage
	call LineFeed

udp20:	lrv X1, 0				;LVA setting
	ldz lvalbl*2
	call PrintString
	b16mov Temper, BattAlarmVoltage
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

	b16cmp Temper, BatteryVoltageOffset	;zero input voltage?
	brne pvv1

	b16clr Temper				;yes

pvv1:	b16ldi Temp, 2.5			;calculate value
	b16mul Temp, Temper, Temp
	call TempDiv100

	b16load Temp				;print the integer part
 	call Print16Signed

	rcall PrintDecimal
	ldi t, 'V'
	call PrintChar
	ret



	;--- Print decimal point and one digit ---

PrintDecimal:

	ldi t, '.'
	call PrintChar

	mov xl, yh				;print the fractional part (one digit)
	clr xh
	clr yh
	b16store Temp2
	b16ldi Temper, 0.0390625
	b16mul Temp2, Temp2, Temper
	b16load Temp2
	call Print16Signed
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



	;--- Print flight mode ---

PrintFlightMode:

	call PrintString			;register Z (input parameter) points to the label
	rvbrflagfalse flagSlOn, pfm1

	ldz selflvl*2				;(normal) SL
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
safe:	.db "SAFE", 0, 0
armed:	.db "ARMED", 0

upd2:	.db "Stand-alone Gimbal", 0, 0
upd3:	.db "Controller mode.", 0, 0

gblmode:.dw upd2*2, upd3*2

udp6:	.db ". Tuning ", 0

udp7:	.db 0, 19, 127, 40
udp8:	.db 0, 16, 127, 25

flmode:	.db "Mode: ", 0, 0
batt:	.db "Batt: ", 0, 0
lvalbl:	.db "LVA : ", 0, 0

sta1:	.db "ACC not calibrated.", 0
sta2:	.db "No aileron input.", 0
sta3:	.db "No elevator input.", 0, 0
sta4:	.db "No throttle input.", 0, 0
sta5:	.db "No rudder input.", 0, 0
sta6:	.db "Sanity check failed.", 0, 0
sta7:	.db "No motor layout!", 0, 0
sta8:	.db "Check throttle level.", 0
sta9:	.db "RX signal was lost!", 0

sta11:	.db "Check aileron level.", 0, 0
sta12:	.db "Check elevator level.", 0

sta21:	.db "No CPPM input!", 0, 0

sta31:	.db "No S.Bus input!", 0
sta32:	.db "FAILSAFE!", 0

sta41:	.db "No Satellite input!", 0
sta45:	.db "Sat protocol error!", 0



	;--- Load status string ---

LoadStatusString:

	set					;set the T flag to indicate error/warning (assuming that one or more status bits are set)

	lds t, StatusBits
	cbr t, LvaWarning			;no error message displayed for LVA warning
	brne lss11

	rvbrflagtrue flagThrottleZero, lss8	;no critical flags are set so we'll display a warning if throttle is above idle

	ldz sta8*2				;check throttle level
	ret

lss8:	rvbrflagtrue flagAileronCentered, lss9

	ldz sta11*2				;check aileron level
	ret

lss9:	rvbrflagtrue flagElevatorCentered, lss10

	ldz sta12*2				;check elevator level
	ret

lss10:	clt					;no errors/warnings (clear the T flag)
	ret

lss11:	lds t, StatusBits
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

lss4:	lds t, RxMode
	cpi t, RxModeStandard
	brne lss5

	rcall GetStdStatus			;standard RX mode
	ret

lss5:	cpi t, RxModeCppm
	brne lss6

	call GetCppmStatus			;CPPM RX mode
	ret

lss6:	cpi t, RxModeSBus
	brne lss7

	call GetSBusStatus			;S.Bus RX mode
	ret

lss7:	call GetSatStatus			;Satellite mode
	ret



	;--- Get status for standard mode ---

GetStdStatus:

	lds t, StatusBits
	andi t, NoAileronInput
	breq std6

	ldz sta2*2				;no aileron input
	ret

std6:	lds t, StatusBits
	andi t, NoElevatorInput
	breq std7

	ldz sta3*2				;no elevator input
	ret

std7:	lds t, StatusBits
	andi t, NoThrottleInput
	breq std8

	ldz sta4*2				;no throttle input
	ret

std8:	ldz sta5*2				;no rudder input
	ret



	;--- Get status for CPPM mode ---

GetCppmStatus:

	ldz sta21*2				;no CPPM input
	ret



	;--- Get status for S.Bus mode ---

GetSBusStatus:

	lds t, StatusBits
	andi t, NoSBusInput
	breq gsbs1

	ldz sta31*2				;no S.Bus input
	ret

gsbs1:	ldz sta32*2				;failsafe
	ret



	;--- Get status for Satellite mode ---

GetSatStatus:

	lds t, StatusBits
	andi t, SatProtocolError
	breq gss1

	ldz sta45*2				;Satellite protocol error
	ret

gss1:	ldz sta41*2				;no Satellite input
	ret





UpdateFlightDisplay:

	rvsetflagtrue flagMutePwm

	call LcdClear12x16



	;--- Print armed status ---

	rvbrflagfalse flagArmed, udp3

	lrv X1, 34				;Armed
	lrv Y1, 22
	ldz armed*2
	call PrintString

	ldz udp7*2				;banner
	call PrintSelector

	lrv Y1, 45
	lrv FontSelector, f6x8
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



	;--- Print footer ---

	lrv X1, 36				;footer
	lrv Y1, 57
	lrv FontSelector, f6x8
	ldz upd1*2
	call PrintString



	;--- Print status ---

	lrv X1, 0
	lrv Y1, 1
	lds t, RxMode
	ldz inptxt*2
	call PrintFromStringArray

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
	rcall PrintFlightMode



	;--- Print battery voltages ---

	lrv X1, 0				;batt
	lrv Y1, 36
	ldz batt*2
	call PrintString
	b16mov Temper, BatteryVoltage
	rcall PrintVoltage

	lrv X1, 84
	b16mov Temper, BatteryVoltageLogged
	rcall PrintVoltage



	;--- Print MPU temperature ---

	lrv X1, 0				;temperature in Celcius = MPU register value / 340 + 36.53
	rvadd Y1, 9
	ldz mputemp*2
	call PrintString

	b16ldi Temp, 12420.2			; = 36.53 * 340
	b16add Temp, MpuTemperature, Temp
	b16ldi Temper, 1.50588			; = 512 / 340
	b16mul Temp, Temp, Temper
	b16fdiv Temp, 9
	b16load Temp
	call Print16Signed
	rcall PrintDecimal
	ldz degc*2
	call PrintString

	lrv X1, 84				;temperature in Fahrenheit = Temperature in Celsius * 1.8 + 32
	b16ldi Temper, 1.8
	b16mul Temp, Temp, Temper
	b16load Temp
	ldi t, 32
	add xl, t				;temperature won't exceed 255 degrees Fahrenheit so we can safely ignore register XH
	call Print16Signed
	rcall PrintDecimal
	ldz degf*2
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
	b16store Temp2
	b16ldi Temper, 0.0390625
	b16mul Temp2, Temp2, Temper
	b16load Temp2

	cpi xl, 10				;print a single digit only
	brlt pdc1

	ldi xl, 9

pdc1:	call Print16Signed
	ret



	;--- Print flight mode ---

PrintFlightMode:

	ldz flmode*2
	call PrintString
	rvbrflagfalse flagSlOn, pfm1

	ldz selflvl*2				;normal SL
	call PrintString
	ret

pfm1:	rvbrflagfalse flagSlStickMixing, pfm3

	ldz slmix*2				;SL mix
	call PrintString
	rvbrflagfalse flagAlarmOn, pfm2

	rvadd X1, 12				;SL mix + alarm
	ldz alarm*2
	call PrintString

pfm2:	ret

pfm3:	ldz acro*2				;acro
	call PrintString
	ret



upd1:	.db "<PROFILE>  MENU", 0
safe:	.db "SAFE", 0, 0
armed:	.db "ARMED", 0

udp6:	.db ". Tuning ", 0

udp7:	.db 0, 19, 127, 40
udp8:	.db 0, 16, 127, 25

cppmid:	.db "CPPM", 0, 0
sbusid:	.db "S.Bus", 0
satid:	.db "DSM2", 0, 0

inptxt:	.dw null*2, cppmid*2, sbusid*2, satid*2

flmode:	.db "Mode: ", 0, 0
batt:	.db "Batt: ", 0, 0
mputemp:.db "Temp: ", 0, 0

degc:	.db "*C", 0, 0
degf:	.db "*F", 0, 0

sta1:	.db "ACC not calibrated.", 0
sta2:	.db "No aileron input.", 0
sta3:	.db "No elevator input.", 0, 0
sta4:	.db "No throttle input.", 0, 0
sta5:	.db "No rudder input.", 0, 0
sta6:	.db "Sanity check failed.", 0, 0
sta7:	.db "No motor layout!", 0, 0
sta8:	.db "Check throttle level.", 0

sta21:	.db "No CPPM input!", 0, 0

sta31:	.db "No S.Bus data! ", 0
sta32:	.db "FAILSAFE!", 0

sta41:	.db "No Satellite input!", 0
sta45:	.db "Sat protocol error!", 0



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
	andi t, NoSatelliteInput
	breq gss1

	ldz sta41*2				;no Satellite input
	ret

gss1:	ldz sta45*2				;Satellite protocol error
	ret



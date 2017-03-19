


BatteryLog:

	rvbrflagtrue flagBatteryLog, blog11

	clc					;not activated
	ret

blog11:	;header
	lrv X1, 10
	ldz battlog*2
	call PrintHeader

	;logged data
	lrv X1, 0				;lowest battery voltage
	ldz blog2*2
	call PrintString
	b16loadx BatteryVoltageLogged
	call PrintVoltage
	call LineFeed

	lrv X1, 0				;time stamp
	ldz time*2
	call PrintString
	lds xl, BattLogTimeMin
	lds yl, BattLogTimeSec
	call PrintTimer

	;additional data
	lrv X1, 0				;LVA setting
	lrv Y1, 35
	ldz lvalbl*2
	call PrintString
	b16loadx BattAlarmVoltage
	call PrintVoltage

	;footer
	call PrintBackFooter

	sec
	ret



battlog:.db "BATT. LOG", 0

blog2:	.db "Log : ", 0, 0



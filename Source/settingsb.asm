
.def Item		= r17



MiscSettings:

	clr Item

stt11:	call LcdClear6x8

	rvbrflagfalse flagGimbalMode, stt22

	;labels				;gimbal controller mode. Will only be able to edit LVA and servo filter values in this mode
	ldi t, 2
	ldz stt23*2
	call PrintStringArray

	;values
	lrv Y1, 1
	ldz eeBattAlarmVoltage
	ldi t, 2

	;item selection
	subi Item, 2
	brpl stt21

	clr Item
	rjmp stt21

stt22:	;labels				;normal mode
	ldi t, 4
	ldz stt20*2
	call PrintStringArray

	;values
	lrv Y1, 1
	ldz eeEscLowLimit
	ldi t, 4

stt21:	push t
	lrv X1, 96
	call PrintColonAndSpace	
	call GetEePVariable16
 	call PrintNumberLF
	pop t
	dec t
	brne stt21

	;footer
	call PrintStdFooter

	;selector
	ldzarray stt7*2, 4, Item
	call PrintSelector

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08			;BACK?
	brne stt8

	call LoadStickDeadZone
	ret

stt8:	cpi t, 0x04			;PREV?
	brne stt9

	dec Item
	andi Item, 0x03
	rjmp stt11

stt9:	lds xl, flagGimbalMode		;add offset (2) to Index value in gimbal mode
	andi xl, 0x02
	breq stt24

	add Item, xl

stt24:	cpi t, 0x02			;NEXT?
	brne stt12

	inc Item
	andi Item, 0x03
	rjmp stt11

stt12:	cpi t, 0x01			;CHANGE?
	brne stt14

	ldzarray eeEscLowLimit, 2, Item
	pushz
	call GetEePVariable16
	ldzarray stt15*2, 4, Item
	lpm yl, Z+
	lpm yh, Z+
	lpm r0, Z+
	lpm r1, Z+
	mov zl, r0
	mov zh, r1
	call NumberEdit
	mov xl, r0
	mov xh, r1
	popz
	call StoreEePVariable16

stt14:	rjmp stt11




stt1:	.db "Minimum Throttle", 0, 0	;also used in error message (sanity check)
stt2:	.db "Stick Dead Zone", 0
stt5:	.db "Alarm 1/10 Volts", 0, 0
stt6:	.db "Servo Filter", 0, 0

stt20:	.dw stt1*2, stt2*2
stt23:	.dw stt5*2, stt6*2		;gimbal controller mode


stt7:	.db 107, 0, 127, 9
	.db 107, 9, 127, 18
	.db 107, 18, 127, 27
	.db 107, 27, 127, 36


stt15:	.dw 0, 20
	.dw 0, 100
	.dw 0, 900
	.dw 0, 100



.undef Item



.def Item = r17


MiscSettings:

	clr Item

stt11:	call LcdClear6x8

	rvbrflagfalse flagGimbalMode, stt22

	;gimbal controller mode. Will only be able to edit the LVA value in this mode
	clr Item
	ldz stt3*2
	call PrintString
	ldz eeBattAlarmVoltage
	ldi t, 1
	rjmp stt21

stt22:	;labels (normal mode)
	ldi t, 4
	ldz stt10*2
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

	cpi t, 0x08				;BACK?
	brne stt8

	call LoadStickDeadZone
	ret

stt8:	cpi t, 0x04				;PREV?
	brne stt9

	dec Item
	brpl stt14

	ldi Item, 3
	rjmp stt11

stt9:	cpi t, 0x02				;NEXT?
	brne stt12

	inc Item
	cpi Item, 4
	brlt stt14

	clr Item
	rjmp stt11

stt12:	cpi t, 0x01				;CHANGE?
	brne stt14

	lds t, flagGimbalMode
	andi t, 0x02
	add Item, t

	ldzarray eeEscLowLimit, 2, Item
	pushz
	call GetEePVariable16
	ldzarray stt15*2, 4, Item
	lpm yl, Z+
	lpm yh, Z+
	lpm r0, Z+
	lpm r1, Z+
	movw z, r1:r0
	call NumberEdit
	movw x, r1:r0
	popz
	call StoreEePVariable16

stt14:	rjmp stt11




stt1:	.db "Minimum Throttle", 0, 0		;also used in error message (sanity check)
stt2:	.db "Stick Dead Zone", 0
stt3:	.db "Alarm 1/10 Volts", 0, 0
stt4:	.db "Motor Spin Level", 0, 0

stt10:	.dw stt1*2, stt2*2, stt3*2, stt4*2


stt7:	.db 107, 0, 127, 9
	.db 107, 9, 127, 18
	.db 107, 18, 127, 27
	.db 107, 27, 127, 36


stt15:	.dw 0, 20
	.dw 0, 100
	.dw 0, 900
	.dw 0, 50



.undef Item



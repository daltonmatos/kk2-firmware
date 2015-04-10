
.def Item = r17

AdjustBatteryVoltage:

	clr Item

	lds t, UserProfile		;refuse access unless user profile #1 is selected
	tst t
	breq abv11

	ldz nadtxt2*2
	call ShowNoAccessDlg
	ret

abv11:	push Item
	call ReadBatteryVoltage
	pop Item
	b16mov Temper, BatteryVoltage

	call LcdClear12x16

	lrv X1, 34			;centering the voltage value
	b16ldi Temp, 400
	b16cmp Temper, Temp
	brge abv15

	rvadd X1, 6			;less than 10V

abv15:	push Item
	call PrintVoltage
	pop Item

	lrv FontSelector, f6x8

	lrv Y1, 17			;print menu
	ldi t, 4
	ldz abv8*2
	call PrintStringArray

	;footer
	call PrintSelectFooter

	;print selector
	ldzarray abv7*2, 4, Item
	call PrintSelector

	call LcdUpdate

	call RxPollDelay

	call GetButtons
	tst t
	brne abv19

	rjmp abv11			;no button pushed

abv19:	call Beep

	cpi t, 0x08			;BACK?
	brne abv20
	ret

abv20:	cpi t, 0x04			;PREV?
	brne abv25

abv21:	dec Item

abv24:	andi Item, 0x03
	call ReleaseButtons
	rjmp abv11

abv25:	cpi t, 0x02			;NEXT?
	brne abv30

	inc Item
	rjmp abv24

abv30:	cpi t, 0x01			;SELECT?
	brne abv24

	cpi Item, 0
	brne abv31

	ldi xl, 10			;KK2.1 offset value
	rcall SaveBatteryVoltageOffset
	rjmp abv11

abv31:	cpi Item, 1
	brne abv32

	ldi xl, 2			;KK2.1.5 offset value
	rcall SaveBatteryVoltageOffset
	rjmp abv11

abv32:	cpi Item, 2
	breq abv33

	b16load BatteryVoltageOffset	;adjust offset value
	ldy -1023			;lower limit
	ldz 1023			;upper limit
	call NumberEdit
	mov xl, r0
	mov xh, r1
	clr yh
	b16store BatteryVoltageOffset
	rjmp abv34

abv33:	b16mov Temp, BatteryVoltage	;modify voltage
	b16fdiv Temp, 2
	b16load Temp
	ldy 20				;lower limit
	ldz 260				;upper limit
	call NumberEdit
	mov xl, r0
	mov xh, r1
	clr yh

	b16store Temp			;calculate offset value
	b16fmul Temp, 2
	b16sub Temp, Temp, BatteryVoltage
	b16add BatteryVoltageOffset, BatteryVoltageOffset, Temp
	b16load BatteryVoltageOffset

abv34:	ldz eeBatteryVoltageOffset	;save in EEPROM for profile #1 only
	call StoreEeVariable16
	rjmp abv24


.undef Item



abv2:	.db "Use KK2.1 Offset", 0, 0
abv3:	.db "Use KK2.1.5 Offset", 0, 0
abv4:	.db "Modify Voltage (1/10)", 0
abv5:	.db "Adjust Offset Value", 0

abv7:	.db 0, 16, 127, 25
	.db 0, 25, 127, 34
	.db 0, 34, 127, 43
	.db 0, 43, 127, 52

abv8:	.dw abv2*2, abv3*2, abv4*2, abv5*2

svo1:	.db "The battery voltage", 0
svo2:	.db "offset has been set", 0
svo3:	.db "according to selected", 0
svo4:	.db "KK2 board version.", 0, 0

svo8:	.dw svo1*2, svo2*2, svo3*2, svo4*2



	;--- Load battery voltage offset value from EEPROM ---

LoadBatteryVoltageOffset:

	ldz eeBatteryVoltageOffset
	call GetEeVariable16		;load from profile #1 only
	clr yh
	b16store BatteryVoltageOffset
	ret



	;--- Save battery voltage offset value to EEPROM ---

SaveBatteryVoltageOffset:

	clr xh				;store value in SRAM first (register XL has already been set as input variable)
	clr yh
	b16store BatteryVoltageOffset

	ldz eeBatteryVoltageOffset	;store in EEPROM for profile #1 only
	call StoreEeVariable16

	call LcdClear12x16		;show confirmation dialogue

	lrv X1, 34			;header
	ldz saved*2
	call PrintHeader

	ldi t, 4			;print information
	ldz svo8*2
	call PrintStringArray

	;footer
	call PrintOkFooter

	call LcdUpdate

svo12:	call GetButtonsBlocking
	cpi t, 0x01			;OK?
	brne svo12

	call ReleaseButtons
	ret



	;--- Write default battery voltage offset value to EEPROM ---

ResetBatteryVoltageOffset:

	ldx 2				;offset for KK2.1.5 = 2
	ldz eeBatteryVoltageOffset
	call StoreEeVariable16		;save in profile #1 only
	ret


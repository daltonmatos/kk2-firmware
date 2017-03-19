
.def Item = r17

AdjustBatteryVoltage:

	clr Item

abv11:	call LcdClear12x16

	;battery voltage
	call ReadBatteryVoltage
	b16loadx BatteryVoltage

	ldi t, 34				;centering the voltage value
	ldz 400
	cp xl, zl
	cpc xh, zh
	brge abv15

	ldi t, 40				;less than 10V

abv15:	sts X1, t
	call PrintVoltage

	;menu
	lrv FontSelector, f6x8
	lrv Y1, 17
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

	rjmp abv11				;no button pushed

abv19:	call Beep

	cpi t, 0x08				;BACK?
	brne abv20

	ret

abv20:	cpi t, 0x04				;PREV?
	brne abv25

abv21:	dec Item

abv24:	andi Item, 0x03
	call ReleaseButtons
	rjmp abv11

abv25:	cpi t, 0x02				;NEXT?
	brne abv30

	inc Item
	rjmp abv24

abv30:	cpi t, 0x01				;SELECT?
	brne abv24

	cpi Item, 0
	brne abv31

	ldi xl, 10				;KK2.1 offset value
	rcall SaveBatteryVoltageOffset
	rjmp abv11

abv31:	cpi Item, 1
	brne abv32

	ldi xl, 2				;KK2.1.5 offset value
	rcall SaveBatteryVoltageOffset
	rjmp abv11

abv32:	cpi Item, 2
	breq abv33

	rcall LoadBatteryVoltageOffset		;adjust offset value
	ldy -1023				;lower limit
	ldz 1023				;upper limit
	call NumberEdit
	mov xl, r0
	mov xh, r1
	clr yh
	b16store BatteryVoltageOffset
	rjmp abv34

abv33:	b16mov Temp, BatteryVoltage		;modify voltage
	b16fdiv Temp, 2
	b16load Temp
	ldy 20					;lower limit
	ldz 260					;upper limit
	call NumberEdit
	mov xl, r0
	mov xh, r1
	clr yh

	b16store Temp				;calculate offset value
	b16fmul Temp, 2
	b16sub Temp, Temp, BatteryVoltage
	b16add BatteryVoltageOffset, BatteryVoltageOffset, Temp
	b16load BatteryVoltageOffset

abv34:	ldz eeBatteryVoltageOffset		;store in EEPROM for the current user profile
	call StoreEePVariable16
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
	call GetEePVariable16
	clr yh
	b16store BatteryVoltageOffset

	b16loadz BatteryVoltageOffsetOrg	;reset logged battery voltage when the offset has changed
	cp xl, zl
	cpc xh, zh
	breq lbv1

	b16ldi BatteryVoltageLogged, 1023
	b16store BatteryVoltageOffsetOrg

lbv1:	ret



	;--- Save battery voltage offset value to EEPROM and display confirmation dialogue ---

SaveBatteryVoltageOffset:

	clr xh					;store value in SRAM first (register XL has already been set as input variable)
	clr yh
	b16store BatteryVoltageOffset

	ldz eeBatteryVoltageOffset		;store in EEPROM for the current user profile
	call StoreEePVariable16

	call LcdClear12x16

	;header
	lrv X1, 34
	ldz saved*2
	call PrintHeader

	;text
	ldi t, 4
	ldz svo8*2
	call PrintStringArray

	;footer
	call PrintOkFooter

	call LcdUpdate

	call WaitForOkButton
	ret



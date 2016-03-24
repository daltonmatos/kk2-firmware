
.def AuxItem = r17
.def Changes = r18

AuxSwitchSetup:

	lrv RxTimeoutLimit, 2

	clr AuxItem
	clr Changes
	rcall LoadAuxSwitchSetup	;load the AUX switch setup in case the user profile was modified (imported or cleared)

aux11:	push AuxItem			;get RX input to update the current AUX switch position
	push Changes
	call GetRxChannels
	pop Changes
	pop AuxItem

	lds t, RxBufferState		;update the display only when we have new data
	cpi t, 3
	breq aux10

	ldi yl, 25			;wait 2.5ms
	call wms

	rvbrflagfalse RxFrameValid, aux10	;update the display also when no valid frames are received

	rjmp aux18			;skip update

aux10:	call LcdClear6x8

	clr t				;print all text labels first

aux15:	push t
	lds xl, AuxSwitchPosition
	cp t, xl
	brne aux22

	ldi t, '@'			;show indicator for current AUX switch position
	rjmp aux23

aux22:	ldi t, ' '

aux23:	call PrintChar
	pop t
	push t
	ldi xl, '1'
	add t, xl
	call PrintChar
	lrv X1, 0
	call LineFeed
	pop t
	inc t
	cpi t, 5
	brne aux15

	;functions
	lrv Y1, 1
	ldy AuxPos1Function
	rcall PrintAuxFnValue
	rcall PrintAuxFnValue
	rcall PrintAuxFnValue
	rcall PrintAuxFnValue
	rcall PrintAuxFnValue

	;stick scaling offsets
	lrv Y1, 1
	ldy AuxPos1SS
	rcall PrintAuxSSValue
	rcall PrintAuxSSValue
	rcall PrintAuxSSValue
	rcall PrintAuxSSValue
	rcall PrintAuxSSValue

	;footer
	call PrintStdFooter

	;selector
	ldzarray aux7*2, 4, AuxItem
	call PrintSelector

	call LcdUpdate

	lds t, RxMode			;skip delay for digital input modes
	cpi t, RxModeSBus
	brge aux18

	call RxPollDelay

aux18:	call GetButtons

	cpi t, 0x08			;BACK?
	brne aux12

	mov t, Changes
	andi t, 0x01
	breq aux17

	ldy AuxPos1Function		;save AUX functions to EEPROM
	ldz eeAuxPos1Function
	rcall SaveAuxSwitchSetup

aux17:	andi Changes, 0x02
	breq aux24

	ldy AuxPos1SS			;save AUX stick scaling offsets to EEPROM
	ldz eeAuxPos1SS
	rcall SaveAuxSwitchSetup

aux24:	ret

aux12:	cpi t, 0x04			;PREV?
	brne aux13

	dec AuxItem
	brpl aux16

	ldi AuxItem, 9

aux16:	call Beep
	call ReleaseButtons
	rjmp aux11	

aux13:	cpi t, 0x02			;NEXT?
	brne aux14

	inc AuxItem
	cpi AuxItem, 10
	brne aux16

	clr AuxItem
	rjmp aux16	

aux14:	cpi t, 0x01			;CHANGE?
	brne aux19

	mov yl, AuxItem
	lsr yl
	mov yh, AuxItem
	andi yh, 0x01
	breq aux25

	ldx AuxPos1SS
	ori Changes, 0x02
	rjmp aux26

aux25:	ldx AuxPos1Function
	ori Changes, 0x01

aux26:	add xl, yl			;calculate variable's address
	brcc aux20

	inc xh

aux20:	ld t, x				;fetch and increase the variable
	inc t
	cpi t, 4
	brlt aux21

	mov yl, AuxItem
	andi yl, 0x01
	brne aux27

	cpi t, 7
	brlt aux21

aux27:	clr t

aux21:	st x, t
	rjmp aux16

aux19:	rjmp aux11



	;--- Print AUX function (string) ---

PrintAuxFnValue:

	lrv X1, 12
	call PrintColonAndSpace
	ld t, y+			;register Y (input parameter) points to the item index (RAM variable)
	push t
	andi t, 0x03
	ldz auxfn*2
	call PrintFromStringArray

	pop t				;print custom symbol when the Motor Spin feature is active
	andi t, 0x04
	breq paf1

	ldi t, 0x7F
	call PrintChar

paf1:	call LineFeed
	ret



	;--- Print AUX stick scaling offset (string) ---

PrintAuxSSValue:

	lrv X1, 91
	ldz ss*2
	call PrintString

	ld t, y+			;register Y (input parameter) points to the item index (RAM variable)
	andi t, 0x03
	ldz auxss*2
	call PrintFromStringArray
	call LineFeed
	ret



	;--- Load AUX switch setup from EEPROM ---

LoadAuxSwitchSetup:

	ldy AuxPos1Function
	ldz eeAuxPos1Function
	ldi xh, 10			;number of bytes to be read

lass1:	call GetEePVariable8
	st y+, xl
	dec xh
	brne lass1

	ret



	;--- Save AUX switch parameters to EEPROM ---

SaveAuxSwitchSetup:

	ldi xh, 5			;number of bytes to be written

sass1:	ld xl, y+			;register Y (input parameter) points to the RAM variable
	call StoreEePVariable8		;register Z (input parameter) points to the EEPROM variable
	dec xh
	brne sass1

	ret



aux7:	.db 23, 0, 85, 9
	.db 90, 0, 127, 9
	.db 23, 9, 85, 18
	.db 90, 9, 127, 18
	.db 23, 18, 85, 27
	.db 90, 18, 127, 27
	.db 23, 27, 85, 36
	.db 90, 27, 127, 36
	.db 23, 36, 85, 45
	.db 90, 36, 127, 45


.undef Changes
.undef AuxItem



	;--- AUX stick scaling offset ---

AddAuxStickScaling:

	clr xl
	clr xh
	clr yh

	lds yl, AuxStickScaling
	lsr yl
	brcc ass1

	adiw x, 20			;increase aileron and elevator stick scaling

ass1:	lsr yl
	brcc ass2

	adiw x, 30			;increase aileron and elevator stick scaling

ass2:	b16store Temp			;increase aileron, elevator and rudder stick scaling by 0 (off), 20, 30 or 50
	call TempDiv16
	b16add StickScaleRoll, StickScaleRollOrg, Temp
	b16add StickScalePitch, StickScalePitchOrg, Temp
	b16add StickScaleYaw, StickScaleYawOrg, Temp
	ret


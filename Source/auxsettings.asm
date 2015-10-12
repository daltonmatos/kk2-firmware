
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

	lrv Y1, 1			;aux position 1 function
	lds t, AuxPos1Function
	rcall PrintAuxFnValue

	lds t, AuxPos2Function		;aux position 2 function
	rcall PrintAuxFnValue

	lds t, AuxPos3Function		;aux position 3 function
	rcall PrintAuxFnValue

	lds t, AuxPos4Function		;aux position 4 function
	rcall PrintAuxFnValue

	lds t, AuxPos5Function		;aux position 5 function
	rcall PrintAuxFnValue

	lrv Y1, 1			;aux position 1 stick scaling
	lds t, AuxPos1SS
	rcall PrintAuxSSValue

	lds t, AuxPos2SS		;aux position 2 stick scaling
	rcall PrintAuxSSValue

	lds t, AuxPos3SS		;aux position 3 stick scaling
	rcall PrintAuxSSValue

	lds t, AuxPos4SS		;aux position 4 stick scaling
	rcall PrintAuxSSValue

	lds t, AuxPos5SS		;aux position 5 stick scaling
	rcall PrintAuxSSValue

	;footer
	call PrintStdFooter

	;print selector
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

	lds xl, AuxPos1Function		;save AUX functions to EEPROM
	no_offset_ldz eeAuxPos1Function
	call StoreEePVariable8

	lds xl, AuxPos2Function
	call StoreEePVariable8		;eeAuxPos2Function

	lds xl, AuxPos3Function
	call StoreEePVariable8		;eeAuxPos3Function

	lds xl, AuxPos4Function
	call StoreEePVariable8		;eeAuxPos4Function

	lds xl, AuxPos5Function
	call StoreEePVariable8		;eeAuxPos5Function

aux17:	andi Changes, 0x02
	breq aux24

	lds xl, AuxPos1SS		;save AUX stick scaling offsets to EEPROM
	no_offset_ldz eeAuxPos1SS
	call StoreEePVariable8

	lds xl, AuxPos2SS
	call StoreEePVariable8		;eeAuxPos2SS

	lds xl, AuxPos3SS
	call StoreEePVariable8		;eeAuxPos3SS

	lds xl, AuxPos4SS
	call StoreEePVariable8		;eeAuxPos4SS

	lds xl, AuxPos5SS
	call StoreEePVariable8		;eeAuxPos5SS

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

	clr t

aux21:	st x, t
	rjmp aux16

aux19:	rjmp aux11



	;--- Print AUX function (string) ---

PrintAuxFnValue:

	push t				;register T holds the item index
	lrv X1, 12
	call PrintColonAndSpace
	pop t
	ldz auxfn*2
	call PrintFromStringArray
	call LineFeed
	ret



	;--- Print AUX stick scaling offset (string) ---

PrintAuxSSValue:

	push t				;register T holds the item index
	lrv X1, 91
	pop t
	ldz auxss*2
	call PrintFromStringArray
	call LineFeed
	ret



	;--- Load AUX switch setup from EEPROM ---

LoadAuxSwitchSetup:

	no_offset_ldz eeAuxPos1SS
	call GetEePVariable8
	sts AuxPos1SS, xl

	call GetEePVariable8		;eeAuxPos2SS
	sts AuxPos2SS, xl

	call GetEePVariable8		;eeAuxPos3SS
	sts AuxPos3SS, xl

	call GetEePVariable8		;eeAuxPos4SS
	sts AuxPos4SS, xl

	call GetEePVariable8		;eeAuxPos5SS
	sts AuxPos5SS, xl

	call GetEePVariable8		;eeAuxPos1Function
	sts AuxPos1Function, xl

	call GetEePVariable8		;eeAuxPos2Function
	sts AuxPos2Function, xl

	call GetEePVariable8		;eeAuxPos3Function
	sts AuxPos3Function, xl

	call GetEePVariable8		;eeAuxPos4Function
	sts AuxPos4Function, xl

	call GetEePVariable8		;eeAuxPos5Function
	sts AuxPos5Function, xl
	ret




aux7:	.db 23, 0, 79, 9
	.db 90, 0, 127, 9
	.db 23, 9, 79, 18
	.db 90, 9, 127, 18
	.db 23, 18, 79, 27
	.db 90, 18, 127, 27
	.db 23, 27, 79, 36
	.db 90, 27, 127, 36
	.db 23, 36, 79, 45
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

ass2:	b16store Temp			;increase aileron and elevator stick scaling by 0 (off), 20, 30 or 50
	call TempDiv16
	b16add StickScaleRoll, StickScaleRollOrg, Temp
	b16add StickScalePitch, StickScalePitchOrg, Temp
	ret



.def AuxItem = r17
.def Changes = r18

AuxSwitchSetup:

	lrv RxTimeoutLimit, 2

	clr AuxItem
	clr Changes
	rcall LoadAuxSwitchSetup

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
	ldz auxtxt*2
	call PrintFromStringArray
	lrv X1, 0
	rvadd Y1, 9
	pop t
	inc t
	cpi t, 5
	brne aux15

	lrv Y1, 1			;aux position 1 function
	lds t, AuxPos1Function
	rcall PrintAuxValue

	lds t, AuxPos2Function		;aux position 2 function
	rcall PrintAuxValue

	lds t, AuxPos3Function		;aux position 3 function
	rcall PrintAuxValue

	lds t, AuxPos4Function		;aux position 4 function
	rcall PrintAuxValue

	lds t, AuxPos5Function		;aux position 5 function
	rcall PrintAuxValue

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

	tst Changes
	brne aux17

	ret	

aux17:	lds xl, AuxPos1Function		;save to EEPROM
	ldz eeAuxPos1Function
	call StoreEePVariable8

	lds xl, AuxPos2Function
	call StoreEePVariable8		;eeAuxPos2Function

	lds xl, AuxPos3Function
	call StoreEePVariable8		;eeAuxPos3Function

	lds xl, AuxPos4Function
	call StoreEePVariable8		;eeAuxPos4Function

	lds xl, AuxPos5Function
	call StoreEePVariable8		;eeAuxPos5Function
	ret

aux12:	cpi t, 0x04			;PREV?
	brne aux13

	dec AuxItem
	brpl aux16

	ldi AuxItem, 4

aux16:	call Beep
	call ReleaseButtons
	rjmp aux11	

aux13:	cpi t, 0x02			;NEXT?
	brne aux14

	inc AuxItem
	cpi AuxItem, 5
	brne aux16

	clr AuxItem
	rjmp aux16	

aux14:	cpi t, 0x01			;CHANGE?
	brne aux19

	ser Changes
	ldx AuxPos1Function		;calculate variable's address
	add xl, AuxItem
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

PrintAuxValue:

	push t				;register T holds the item index
	lrv X1, 36
	call PrintColonAndSpace
	pop t
	ldz auxfn*2
	call PrintFromStringArray
	rvadd Y1, 9
	ret



	;--- Load AUX switch setup from EEPROM ---

LoadAuxSwitchSetup:

	ldz eeAuxPos1Function
	call GetEePVariable8
	sts AuxPos1Function, xl

	call GetEePVariable8			;eeAuxPos2Function
	sts AuxPos2Function, xl

	call GetEePVariable8			;eeAuxPos3Function
	sts AuxPos3Function, xl

	call GetEePVariable8			;eeAuxPos4Function
	sts AuxPos4Function, xl

	call GetEePVariable8			;eeAuxPos5Function
	sts AuxPos5Function, xl
	ret




aux7:	.db 47, 0, 127, 9
	.db 47, 9, 127, 18
	.db 47, 18, 127, 27
	.db 47, 27, 127, 36
	.db 47, 36, 127, 45


.undef Changes
.undef AuxItem

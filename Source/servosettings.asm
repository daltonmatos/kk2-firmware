
.def Item = r17
.def OldOutputRate = r18


ServoSettings:

	clr Item

	ldz eeLowOutputRate			;load the Low PWM Rate setting from EEPROM. Will only be saved on exit (if modified)
	call GetEePVariable8
	dec xl
	andi xl, 0x07
	inc xl
	sts OutputRateDivider, xl
	mov OldOutputRate, xl

	call LoadMixerTable			;display a warning if output type on M7/M8 is set to 'ESC'
	call UpdateOutputTypeAndRate
	lds t, OutputTypeBitmask
	andi t, 0xC0
	breq srv11

	ldz sew11*2
	call ShowEscWarning

srv11:	call LcdClear6x8

	;labels
	ldi t, 5
	ldz srv10*2
	call PrintStringArray

	;values
	lrv Y1, 1
	ldz eeServoFilter
	rcall PrintServoParameter		;eeServoFilter
	rcall PrintServoParameter		;eeServoFilterDelay
	rcall PrintServoEndpoints		;eeServoLimitM7L and eeServoLimitM7H
	rcall PrintServoEndpoints		;eeServoLimitM8L and eeServoLimitM8H

	lrv X1, 84				;low PWM rate (Hz)
	lds t, OutputRateDivider
	subi t, 2
	clr xh
	ldz lowrate*2
	add zl, t
	adc zh, xh
	lpm xl, z
	call Print16Signed
	ldz hz*2
	call PrintString

	;footer
	call PrintStdFooter

	;selector
	ldzarray srv7*2, 4, Item
	call PrintSelector

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08				;BACK?
	brne srv20

	lds xl, OutputRateDivider
	cp xl, OldOutputRate
	breq srv19

	ldz eeLowOutputRate
	call StoreEePVariable8

srv19:	ret

srv20:	cpi t, 0x04				;PREV?
	brne srv25

	dec Item
	brpl srv11

	ldi Item, 6

srv24:	rjmp srv11

srv25:	cpi t, 0x02				;NEXT?
	brne srv30

	inc Item
	cpi Item, 7
	brlt srv24

	clr Item
	rjmp srv11

srv30:	cpi t, 0x01				;CHANGE?
	brne srv24

	cpi Item, 6
	breq srv32

	ldzarray eeServoFilter, 1, Item
	pushz
	call GetEePVariable8
	clr xh
	tst xl
	brpl srv31

	ser xh					;extend sign

srv31:	ldzarray srv15*2, 4, Item
	lpm yl, Z+
	lpm yh, Z+
	lpm r0, Z+
	lpm r1, Z+
	movw z, r1:r0
	call NumberEdit
	movw x, r1:r0
	popz
	call StoreEePVariable8
	rjmp srv11

srv32:	lds t, OutputRateDivider		;modify PWM rate 
	dec t
	cpi t, 2
	brge srv33

	ldi t, 8

srv33:	sts OutputRateDivider, t
	rjmp srv11



srv1:	.db "Servo Filter:", 0
srv2:	.db "Osc. Damping:", 0
srv3:	.db "M7 Endpoints:", 0
srv4:	.db "M8 Endpoints:", 0
srv5:	.db "Low PWM Rate:", 0

srv10:	.dw srv1*2, srv2*2, srv3*2, srv4*2, srv5*2


srv7:	.db 83, 0, 103, 9
	.db 83, 9, 97, 18
	.db 77, 18, 103, 27
	.db 107, 18, 127, 27
	.db 77, 27, 103, 36
	.db 107, 27, 127, 36
	.db 83, 36, 121, 45


srv15:	.dw 0, 100
	.dw 0, 10
	.dw -100, -10
	.dw 10, 100
	.dw -100, -10
	.dw 10, 100


lowrate:.db 200, 133, 100, 80, 67, 57, 50, 0	;low PWM rates (Hz)
hz:	.db " Hz", 0



	;--- Print servo setup parameter ---

PrintServoParameter:

	lrv X1, 84
	call GetEePVariable8
	clr xh
	tst xl
	brpl psp1

	ser xh					;extend sign

psp1:	call PrintNumberLF
	ret



	;--- Print servo endpoints ---

PrintServoEndpoints:

	lrv X1, 78				;low endpoint (will always be negative)
	call GetEePVariable8
	ser xh
	call Print16Signed

	lrv X1, 108				;high endpoint (will always be positive)
	call GetEePVariable8
	clr xh
	call PrintNumberLF
	ret



.undef Item
.undef OldOutputRate



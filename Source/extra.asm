
.def Item = r17

ExtraFeatures:

	clr Item

ef11:	call LcdClear12x16

	;header
	lrv X1, 34
	ldz ef1*2
	call PrintHeader

	;menu items
	ldi t, 3
	ldz ef10*2
	call PrintStringArray

	;footer
	call PrintMenuFooter

	;print selector
	ldzarray isp7*2, 4, Item
	call PrintSelector

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08			;BACK?
	brne ef15

	ret

ef15:	cpi t, 0x04			;PREV?
	brne ef20

	dec Item
	brpl ef11

	clr Item
	rjmp ef11

ef20:	cpi t, 0x02			;NEXT?
	brne ef25

	inc Item
	cpi Item, 3
	brlt ef11

	ldi Item, 2
	rjmp ef11

ef25:	cpi t, 0x01			;SELECT?
	brne ef11

	call ReleaseButtons
	push Item
	cpi Item, 0
	brne ef26

	call MotorCheck			;check motor outputs
	rjmp ef40

ef26:	cpi Item, 1
	brne ef27

	call GimbalMode			;stand-alone gimbal controller mode
	rjmp ef40

ef27:	call SerialDebug		;view/debug serial RX data

ef40:	pop Item
	rjmp ef11



ef1:	.db "EXTRA", 0
ef2:	.db "Check Motor Outputs", 0
ef3:	.db "Gimbal Controller", 0
ef4:	.db "View Serial RX Data", 0

ef10:	.dw ef2*2, ef3*2, ef4*2


.undef Item

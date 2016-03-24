
.def Item = r17

ExpertSettings:

	clr Item

xps11:	call LcdClear12x16

	;header
	lrv X1, 28
	ldz xps1*2
	call PrintHeader

	;menu items
	ldi t, 2
	ldz xps10*2
	call PrintStringArray

	;footer
	call PrintMenuFooter

	;print selector
	ldzarray isp7*2, 4, Item
	call PrintSelector

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08			;BACK?
	brne xps15

	ret

xps15:	cpi t, 0x04			;PREV?
	brne xps20

	dec Item

xps16:	andi Item, 0x01
	rjmp xps11

xps20:	cpi t, 0x02			;NEXT?
	brne xps25

	inc Item
	rjmp xps16

xps25:	cpi t, 0x01			;SELECT?
	brne xps11

	call ReleaseButtons
	push Item
	cpi Item, 0
	brne xps26

	call TpaSettings		;TPA settings
	rjmp xps40

xps26:	cpi Item, 1
	brne xps27

	call TssaSettings		;TSSA settings
;	rjmp xps40

xps27:;	cpi Item, 2
;	brne xps28

					;3rd item
;	rjmp xps40

;xps28:					;4th item

xps40:	pop Item
	rjmp xps11



xps1:	.db "EXPERT", 0, 0
xps2:	.db "TPA Settings", 0, 0	;also used in error message (sanity check)
xps3:	.db "TSSA Settings", 0		;also used in error message (sanity check)

xps10:	.dw xps2*2, xps3*2


.undef Item

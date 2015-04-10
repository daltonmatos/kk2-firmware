
.def Item = r17
.def Xoffset = r18


ChannelMapping:

	clr Item

map11:	call LcdClear6x8

	ldi t, 5			;print all text labels first
	ldz rxch*2
	call PrintStringArray
	lrv Y1, 1
	ldi xh, 78
	call PrintAuxLabels

	lrv Y1, 1			;print all values
	ldi Xoffset, 48
	ldy MappedChannel1
	ldz eeChannelRoll
	rcall PrintMappedChannel	;eeChannelRoll
	rcall PrintMappedChannel	;eeChannelPitch
	rcall PrintMappedChannel	;eeChannelThrottle
	rcall PrintMappedChannel	;eeChannelYaw
	rcall PrintMappedChannel	;eeChannelAux
	lrv Y1, 1
	ldi Xoffset, 102
	rcall PrintMappedChannel	;eeChannelAux2
	rcall PrintMappedChannel	;eeChannelAux3
	rcall PrintMappedChannel	;eeChannelAux4

	;footer
	call PrintStdFooter

	;print selector
	ldzarray map7*2, 4, Item
	call PrintSelector

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08			;BACK?
	brne map8

	rcall CheckChannelMapping
	ret

map8:	cpi t, 0x04			;PREV?
	brne map9

	dec Item

map10:	andi Item, 0x07
	rjmp map11	

map9:	cpi t, 0x02			;NEXT?
	brne map12

	inc Item
	rjmp map10

map12:	cpi t, 0x01			;CHANGE?
	brne map14

	ldz eeChannelRoll
	clr xh
	add zl, Item
	adc zh, xh
	pushz
	call GetEeVariable8

	dec xl				;make sure the value is within legal range (1 - 8)
	andi xl, 0x07
	inc xl

	ldy 1				;lower limit
	ldz 8				;upper limit
	call NumberEdit
	mov xl, r0
	popz
	call StoreEeVariable8

map14:	rjmp map11




map7:	.db 59, 0, 67, 9
	.db 59, 9, 67, 18
	.db 59, 18, 67, 27
	.db 59, 27, 67, 36
	.db 59, 36, 67, 45
	.db 113, 0, 121, 9
	.db 113, 9, 121, 18
	.db 113, 18, 121, 27



	;--- Print mapped channel (load from EEPROM and save in SRAM) ---

PrintMappedChannel:

	sts X1, Xoffset
	call PrintColonAndSpace
	call GetEeVariable8

	dec t
	st y+, t			;register Y (input parameter) points to SRAM location for storage

	andi t, 0xF8
	breq pmc1

	ldi t, '-'			;invalid value
	call PrintChar
	call Linefeed
	ret

pmc1:	clr xh				;value is OK
 	call PrintNumberLF
	ret



	;--- Check channel mapping ---

CheckChannelMapping:

	ldy MappedChannel1
	ldi xh, 8

ccm1:	ld xl, y
	andi xl, 0xF8			;check for invalid channel value
	breq ccm3

	setstatusbit ChannelMappingError;invalid channel mapping

ccm3:	adiw y, 1			;value is OK
	dec xh
	brne ccm1
	ret



.undef Item
.undef Xoffset


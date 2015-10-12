
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
	call GetEeChannelMapping
	rcall PrintMappedChannel	;eeChannelRoll		or eeSatChannelRoll
	rcall PrintMappedChannel	;eeChannelPitch		or eeSatChannelPitch
	rcall PrintMappedChannel	;eeChannelThrottle	or eeSatChannelThrottle
	rcall PrintMappedChannel	;eeChannelYaw		or eeSatChannelYaw
	rcall PrintMappedChannel	;eeChannelAux		or eeSatChannelAux
	lrv Y1, 1
	ldi Xoffset, 102
	rcall PrintMappedChannel	;eeChannelAux2		or eeSatChannelAux2
	rcall PrintMappedChannel	;eeChannelAux3		or eeSatChannelAux3
	rcall PrintMappedChannel	;eeChannelAux4		or eeSatChannelAux4

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
	brcc map13

	rcall ChannelMappingError	;invalid channel mapping
	rjmp map11			;cannot leave until all mistakes have been corrected

map13:	ret

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

	call GetEeChannelMapping
	clr xh
	add zl, Item
	adc zh, xh
	pushz
	call GetEePVariable8

	dec xl				;make sure the value is within legal range (1 - 8)
	andi xl, 0x07
	inc xl

	ldy 1				;lower limit
	no_offset_ldz 8				;upper limit
	call NumberEdit
	mov xl, r0
	popz
	call StoreEePVariable8

map14:	rjmp map11




map7:	.db 57, 0, 69, 9
	.db 57, 9, 69, 18
	.db 57, 18, 69, 27
	.db 57, 27, 69, 36
	.db 57, 36, 69, 45
	.db 111, 0, 123, 9
	.db 111, 9, 123, 18
	.db 111, 18, 123, 27


cmw1:	.db "Channel mapping is", 0, 0
cmw2:	.db "invalid. Duplicates", 0
cmw3:	.db "are not allowed.", 0, 0

cmw10:	.dw cmw1*2, cmw2*2, cmw3*2



	;--- Show channel mapping warning ---

ChannelMappingError:

	call LcdClear12x16

	lrv X1, 34			;critical error
	ldz cerror*2
	call PrintHeader

	ldi t, 3			;print "Channel mapping is invalid. Duplicates are not allowed."
	ldz cmw10*2
	call PrintStringArray

	;footer
	call PrintOkFooter

	call LcdUpdate

	call WaitForOkButton
	ret



	;--- Print mapped channel (load from EEPROM and save in SRAM) ---

PrintMappedChannel:

	sts X1, Xoffset
	call PrintColonAndSpace
	call GetEePVariable8

	dec t
	st y+, t			;register Y (input parameter) points to SRAM location for storage

	andi t, 0xF8
	breq pmc1

	ldi t, '-'			;invalid value
	call PrintChar
	call LineFeed
	ret

pmc1:	clr xh				;value is OK
 	call PrintNumberLF
	ret



	;--- Check channel mapping ---

CheckChannelMapping:

	ldy MappedChannel1
	clr zl
	ldi xh, 8

ccm1:	ld t, y+

	mov xl, t
	andi xl, 0xF8			;check for invalid channel value
	brne ccm3

	sec				;value is OK. Generate bit pattern

ccm2:	rol xl
	dec t
	brpl ccm2

	or zl, xl
	dec xh
	brne ccm1

	com zl				;inverting register ZL should return zero (duplicate channel IDs are not allowed)
	brne ccm3

	clc				;channel mapping is valid
	ret

ccm3:	sec				;invalid channel mapping
	ret



.undef Item
.undef Xoffset


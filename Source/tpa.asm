
.def Item = r17
.def Changes = r18
.def TPAValue = r19


TpaSettings:

	clr Item
	clr Changes
	rcall LoadTPASettings

	ldi t, 5				;initial timeout value for LCD update
	mov ka, t

tpa11:	push Item				;get RX input to update the current throttle position
	push Changes
	push TPAValue
	call GetRxChannels
	pop TPAValue
	pop Changes
	pop Item

	rvbrflagtrue flagNewRxFrame, tpa15	;update the display when we have new data

	ldi yl, 20				;wait 2ms
	call wms

	dec ka
	brpl tpa11

tpa15:	ldi t, 50
	mov ka, t

	call LcdClear6x8

	;throttle indicator
	rcall GetTPAFactors			;get throttle position index and make it go from 0 to 4 instead of 8 to 0
	lsr t
	ldi yl, 4
	sub yl, t

	ldi yh, 4				;loop counter

tpa16:	lrv X1, 0
	ldi t, ' '
	cp yh, yl
	brne tpa17

	ldi t, '@'				;indicator for current throttle position

tpa17:	call PrintChar

	;labels
	mov t, yh
	ldz tcp10*2
	call PrintFromStringArray
	call LineFeed

	dec yh
	brpl tpa16

	;values
	lrv Y1, 1
	ldx Tpa1P
	rcall PrintTPAValues
	rcall PrintTPAValues
	rcall PrintTPAValues
	rcall PrintTPAValues
	rcall PrintTPAValues

	;footer
	lrv X1, 0
	lrv Y1, 57
	ldz tcp6*2
	call PrintString

	;selector
	ldzarray tcp7*2, 4, Item
	call PrintSelector

	call LcdUpdate

	lds t, RxMode				;skip delay for digital input modes
	cpi t, RxModeSBus
	brge tpa18

	call RxPollDelay

tpa18:	call GetButtons

	cpi t, 0x08				;BACK?
	brne tpa20

	tst Changes
	breq tpa12

	rcall SaveTPAValue

tpa12:	call Beep
	ret

tpa20:	cpi t, 0x04				;NEXT?
	brne tpa25

	tst Changes
	breq tpa21

	rcall SaveTPAValue

tpa21:	inc Item
	cpi Item, 10
	brlt tpa40

	clr Item
	rjmp tpa40

tpa25:	cpi t, 0x02				;INC?
	brne tpa30

	ldx Tpa1P
	clr t
	add xl, Item
	adc xh, t
	rcall GetFactorIndex

	inc yh
	cpi yh, 16
	brge tpa40

	rcall StoreTPAValue
	rjmp tpa40

tpa30:	cpi t, 0x01				;DEC?
	brne tpa41

	ldx Tpa1P
	clr t
	add xl, Item
	adc xh, t
	rcall GetFactorIndex

	dec yh
	breq tpa40

	rcall StoreTPAValue

tpa40:	call Beep
	call ReleaseButtons

tpa41:	rjmp tpa11



tcp6:	.db "BACK NEXT   INC  DEC", 0, 0

tcp10:	.dw ratemin*2, ratel*2, ratem*2, rateh*2, ratemax*2

tcp7:	.db 59, 0, 91, 9
	.db 95, 0, 127, 9
	.db 59, 9, 91, 18
	.db 95, 9, 127, 18
	.db 59, 18, 91, 27
	.db 95, 18, 127, 27
	.db 59, 27, 91, 36
	.db 95, 27, 127, 36
	.db 59, 36, 91, 45
	.db 95, 36, 127, 45

factor:	.db 0, 13, 26, 39, 52, 64, 77, 90, 103, 116, 128, 141, 154, 167, 180, 192	;pre-calculated factors (0.0 to 1.5 in steps of 0.1)
pcfchk:	.db 128, 116, 103, 90, 77, 64, 141, 154, 167, 180, 192, 52, 39, 26, 13, 0	;rearranged for faster search. Last item must be zero!!!



	;--- Print one pair of TPA values ---

PrintTPAValues:

	lrv X1, 48
	call PrintColonAndSpace
	ldi t, 'P'
	call PrintChar
	rcall PrintTPAValue

	lrv X1, 96
	ldi t, 'I'
	call PrintChar
	rcall PrintTPAValue
	call LineFeed
	ret



	;--- Print a single TPA value ---

PrintTPAValue:

	ldi t, '='
	call PrintChar

	rcall GetFactorIndex
	adiw x, 1
	brtc ptpa1

	ldi t, '?'				;indicate TPA value error
	call PrintChar
	ret

ptpa1:	ldi t, '0'				;print number with one decimal
	cpi yh, 10
	brlt ptpa2

	subi yh, 10				;integer part is 1
	inc t

ptpa2:	call PrintChar
	ldi t, '.'
	call PrintChar
	ldi t, '0'
	add t, yh
	call PrintChar
	ret



	;--- Get array index for pre-calculated factor ---

GetFactorIndex:

	ld yl, x				;will search for the value pointed to by register X (Input parameter)
	tst yl					;zero is not accepted
	breq gfi2

	clr yh					;result will be stored in register YH
	ldz factor*2				;pre-calculated factors
	clt					;the T flag will be set in case of error

gfi1:	lpm t, z+
	cp t, yl
	breq gfi3

	inc yh
	cpi yh, 16
	brlt gfi1

gfi2:	ldi yh, 10				;ERROR: Value not found in array! Return default factor (1.0)
	set

gfi3:	ret



	;--- Store TPA value in SRAM variable ---

StoreTPAValue:

	ldz factor*2				;get pre-calculated factor
	clr t
	add zl, yh				;register YH holds the array index (Input parameter)
	add zh, t
	lpm t, z

	st x, t					;register X points to the SRAM variable (Input parameter)
	mov TPAValue, t				;the value is also kept in a temporary register to simplify the EEPROM write later
	ser Changes
	ret



	;--- Save modified TPA factor to EEPROM ---

SaveTPAValue:

	ldz eeTpa1P
	add zl, Item
	mov xl, TPAValue
	call StoreEePVariable8
	clr Changes
	ret



	;--- Load TPA factors from EEPROM ---

LoadTPASettings:

	ldi xh, 10
	ldy Tpa1P
	ldz eeTpa1P

ltpa1:	call GetEePVariable8
	st y+, xl
	dec xh
	brne ltpa1

	ret



	;--- Check TPA values ---

CheckTPAValues:

	ldx Tpa1P
	ldi yl, 10				;number of values to check against the pre-calculated factors
	clt					;the T flag will be set in case of error

ctpa1:	ld t, x+
	ldi yh, 15				;number of pre-calculated factors (Zero is not allowed)
	ldz pcfchk*2

ctpa2:	lpm Item, z+
	cp t, Item
	breq ctpa3

	dec yh
	brne ctpa2

	set					;ERROR: Value not found in array!
	ret

ctpa3:	dec yl
	brne ctpa1

	ret



	;--- Get TPA factors based on throttle position ---

GetTPAFactors:

	b16load RxThrottle
	ldz 376					;1880 / 5 = 376
	ldi t, 4				;lowest throttle position will return TPA factors at the highest indexes

gtf1:	sub xl, zl
	sbc xh, zh
	brmi gtf2

	dec t
	rjmp gtf1

gtf2:	tst t
	brpl gtf3

	clr t

gtf3:	ldx Tpa1P				;calculate SRAM address
	lsl t
	clr yh
	add xl, t
	adc xh, yh

	ld yh, x+				;get TPA P-factor
	ld yl, x				;get TPA I-factor

	clr xh					;multiply TPA P-factor by 2
	clr xl
	lsl yh
	rol xl
	b16store TPAFactorP

	clr xl					;multiply TPA I-factor by 2
	mov yh, yl
	lsl yh
	rol xl
	b16store TPAFactorI
	ret



.undef TPAValue
.undef Changes
.undef Item


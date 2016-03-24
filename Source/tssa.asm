
.def Item = r17
.def Changes = r18
.def TSSAValue = r19


TssaSettings:

	clr Item
	clr Changes
	rcall LoadTSSASettings

tssa11:	push Item				;get RX input to update the current throttle position
	push Changes
	push TSSAValue
	call GetRxChannels
	pop TSSAValue
	pop Changes
	pop Item

	lds t, RxBufferState			;update the display only when we have new data
	cpi t, 3
	breq tssa15

	ldi yl, 25				;wait 2.5ms
	call wms

	rvbrflagfalse RxFrameValid, tssa15	;update the display also when no valid frames are received

	rjmp tssa18				;skip update

tssa15:	call LcdClear6x8

	;throttle indicator
	rcall GetTPAFactors			;get throttle position index and make it go from 0 to 4 instead of 8 to 0
	lsr t
	ldi yl, 4
	sub yl, t

	ldi yh, 4				;loop counter

tssa16:	lrv X1, 0
	ldi t, ' '
	cp yh, yl
	brne tssa17

	ldi t, '@'				;indicator for current throttle position

tssa17:	call PrintChar

	;labels
	mov t, yh
	ldz tcp10*2
	call PrintFromStringArray
	call LineFeed

	dec yh
	brpl tssa16

	;values
	lrv Y1, 1
	ldx Tssa1
	rcall PrintTSSAValue
	rcall PrintTSSAValue
	rcall PrintTSSAValue
	rcall PrintTSSAValue
	rcall PrintTSSAValue

	;footer
	lrv X1, 0
	lrv Y1, 57
	ldz tcp6*2
	call PrintString

	;selector
	ldzarray tssa7*2, 4, Item
	call PrintSelector

	call LcdUpdate

	lds t, RxMode				;skip delay for S.Bus and Satellite input modes
	cpi t, RxModeSBus
	brge tssa18

	call RxPollDelay

tssa18:	call GetButtons

	cpi t, 0x08				;BACK?
	brne tssa20

	tst Changes
	breq tssa12

	rcall SaveTSSAValue

tssa12:	call Beep
	ret

tssa20:	cpi t, 0x04				;NEXT?
	brne tssa25

	tst Changes
	breq tssa21

	rcall SaveTSSAValue

tssa21:	inc Item
	cpi Item, 5
	brlt tssa40

	clr Item
	rjmp tssa40

tssa25:	cpi t, 0x02				;INC?
	brne tssa30

	ldx Tssa1
	clr t
	add xl, Item
	adc xh, t
	call GetFactorIndex

	inc yh
	cpi yh, 16
	brge tssa40

	rcall StoreTSSAValue
	rjmp tssa40

tssa30:	cpi t, 0x01				;DEC?
	brne tssa41

	ldx Tssa1
	clr t
	add xl, Item
	adc xh, t
	call GetFactorIndex

	dec yh
	breq tssa40

	rcall StoreTSSAValue

tssa40:	call Beep
	call ReleaseButtons

tssa41:	rjmp tssa11



tssa7:	.db 59, 0, 97, 9
	.db 59, 9, 97, 18
	.db 59, 18, 97, 27
	.db 59, 27, 97, 36
	.db 59, 36, 97, 45

tssa8:	.db "SS=", 0



	;--- Print TSSA value ---

PrintTSSAValue:

	lrv X1, 48
	call PrintColonAndSpace

	ldz tssa8*2
	call PrintString

	call GetFactorIndex
	adiw x, 1
	brtc ptssa1

	ldi t, '?'				;indicate TSSA value error
	call PrintChar
	rjmp ptssa3

ptssa1:	ldi t, '0'				;print number with one decimal
	cpi yh, 10
	brlt ptssa2

	subi yh, 10
	inc t

ptssa2:	call PrintChar
	ldi t, '.'
	call PrintChar
	ldi t, '0'
	add t, yh
	call PrintChar

ptssa3:	call LineFeed
	ret



	;--- Store TSSA value in SRAM variable ---

StoreTSSAValue:

	ldz factor*2				;get pre-calculated factor
	clr t
	add zl, yh				;register YH holds the array index (Input parameter)
	add zh, t
	lpm t, z

	st x, t					;register X points to the SRAM variable (Input parameter)
	mov TSSAValue, t			;the value is also kept in a temporary register to simplify the EEPROM write later
	ser Changes
	ret



	;--- Save modified TSSA factor to EEPROM ---

SaveTSSAValue:

	ldz eeTssa1
	add zl, Item
	mov xl, TSSAValue
	call StoreEePVariable8
	clr Changes
	ret



	;--- Load TSSA factors from EEPROM ---

LoadTSSASettings:

	ldi xh, 5
	ldy Tssa1
	ldz eeTssa1

ltssa1:	call GetEePVariable8
	st y+, xl
	dec xh
	brne ltssa1

	ret



	;--- Check TSSA values ---

CheckTSSAValues:

	ldx Tssa1
	ldi yl, 5				;number of values to check against the pre-calculated factors
	clt					;the T flag will be set in case of error

ctssa1:	ld t, x+
	ldi yh, 15				;number of pre-calculated factors (Zero is not allowed)
	ldz pcfchk*2

ctssa2:	lpm Item, z+
	cp t, Item
	breq ctssa3

	dec yh
	brne ctssa2

	set					;ERROR: Value not found in array!
	ret

ctssa3:	dec yl
	brne ctssa1

	ret



	;--- Get TSSA factor based on throttle position ---

GetTSSAFactor:

	lds xl, flagMotorSpin			;set TSSA factor to 1.0 when the Motor Spin feature is inactive
	tst xl
	brne gtssa1

	clr xh
	ldi xl, 1
	clr yh
	rjmp gtssa2

gtssa1:	ldx Tssa1				;calculate SRAM address
	clr yh
	add xl, t				;register T (input parameter) holds the throttle position (range = 0 to 4)
	adc xh, yh

	ld yh, x				;get TSSA factor and multiply by 2
	clr xh
	clr xl
	lsl yh
	rol xl

gtssa2:	b16store TSSAFactor
	ret



.undef TSSAValue
.undef Changes
.undef Item


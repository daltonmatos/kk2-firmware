



EscThrottleCalibration:

	rvsetflagtrue Mode		;true = 2ms output, false = 1.02ms output

esc1:	call LcdClear6x8

	lrv X1, 19			;print "ESC CALIBRATION"
	ldz esc10*2
	call PrintString

	rvbrflagtrue Mode, esc6		;will not print the footer while setting upper throttle limit

	lrv X1, 0			;print footer (i.e. 'EXIT')
	lrv Y1, 57
	ldz esc13*2
	call PrintString

	call LcdUpdate
	rjmp esc2

esc6:	lrv X1, 0			;print "Release button to set LOW throttle level." over two lines
	lrv Y1, 20
	ldz esc20*2
	call PrintString

	lrv X1, 0
	lrv Y1, 29
	ldz esc21*2
	call PrintString

	call LcdUpdate

	lrv OutputRateBitmask, 0x00	;low rate on all channels
	lrv OutputTypeBitmask, 0x00	;servo type on all channels
	lrv OutputRateDividerCounter, 1
	lrv OutputRateDivider, 8	;slow rate divider. f = 400 / OutputRateDivider
	rvsetflagtrue flagArmed
	b16ldi ServoFilter, 1

	LedOn

	;       76543210		;clear pending OCR1A and B interrupt
	ldi t,0b00000110
	store tifr1, t

	b16ldi Temp, 5000.0		;start with full throttle
	rvsetflagfalse flagThrottleZero

esc2:	call PwmStart
	b16mov Out1, Temp
	b16mov Out2, Temp
	b16mov Out3, Temp
	b16mov Out4, Temp
	b16mov Out5, Temp
	b16mov Out6, Temp
	b16mov Out7, Temp
	b16mov Out8, Temp
	call PwmEnd

	load t, pinb			;read buttons. Cannot use 'GetButtons' here because of delay
	com t
	swap t
	andi t, 0x0f
	push t				;must save register 't' since it is used by 'rvbrflagfalse' also

	rvbrflagfalse Mode, esc3
	pop t
	tst t				;button released?
	breq esc5
	b16ldi Temp, 5000.0		;no, keep full throttle
	rjmp esc2

esc3:	pop t
	cpi t, 0x08			;EXIT?
	breq esc4

	b16ldi Temp, 100.0		;no, set minimum throttle level
	rjmp esc2

esc5:	b16ldi Temp, 100.0		;mode is changing, set minimum throttle level
	rvsetflagfalse Mode
	rjmp esc1

esc4:	LedOff				;done
	call Beep
	ret



	;--- Disable ESC calibration ---

DisableEscCalibration:

	clr xl
	ldz eeEscCalibration
	call StoreEeVariable8
	ret



	;--- Warning displayed when enabling ESC calibration ---

EscCalWarning:

	ldz war9*2
	call ShowConfirmationDlg
	cpi t, 0x01			;OK?
	breq war13

	ret				;no, user cancelled

war13:	call LcdClear12x16

	lrv X1, 16			;warning
	ldz warning*2
	call PrintString

	lrv FontSelector, f6x8

	lrv X1, 0			;print text
	lrv Y1, 17
	clr t

war12:	push t
	ldz war10*2
	call PrintFromStringArray
	lrv X1, 0
	rvadd Y1, 9
	pop t
	inc t
	cpi t, 4
	brne war12

	call LcdUpdate

	ser xl				;enable ESC calibration for the next start-up only
	ldz eeEscCalibration
	call StoreEeVariable8

war11:	call GetButtonsBlocking		;infinite loop. Restart is required
	rjmp war11





esc10:	.db "ESC CALIBRATION", 0
esc13:	.db "EXIT", 0, 0
esc20:	.db "Release button to set", 0
esc21:	.db "LOW throttle level.", 0

war2:	.db "ESC calibration will", 0, 0
war3:	.db "be available on the", 0
war4:	.db "next start-up only.", 0
war5:	.db "REMOVE PROPS FIRST!", 0

war9:	.db "Do ESC calibration.", 0

war10:	.dw war2*2, war3*2, war4*2, war5*2


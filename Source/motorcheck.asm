

.def Motor = r17
.def Output = r18
.def OutputType = r21


MotorCheck:

	rcall DisplayPropWarning
	brcc mch11

	ret					;the BACK button was pushed

mch11:	call LoadEscLowLimit			;initialize variables that might have been modified without returning to the SAFE screen
	call LoadMixerTable
	call UpdateOutputTypeAndRate

	lds OutputType, OutputTypeBitmask
	clr Output
	ldi Motor, 0x01

	call Countdown				;5 second countdown

	call ReleaseButtons			;make sure buttons are released
	call StopPwmQuiet			;disable Quiet PWM output

	lrv OutputRateBitmask, 0x00		;low rate on all channels
	lrv OutputTypeBitmask, 0x00		;set servo type on all channels to bypass the "minimum throttle" setting
	lrv OutputRateDividerCounter, 1
	lrv OutputRateDivider, 8		;slow rate divider. f = 400 / OutputRateDivider
	rvsetflagtrue flagArmed
	rvsetflagfalse flagThrottleZero
	b16ldi ServoFilter, 1

	;       76543210			;clear pending OCR1A and B interrupt
	ldi t,0b00000110
	store tifr1, t

mch12:	;M1 - M8 sequence loop
	rcall ClearAllOutputValues
	b16ldi Temp2, 400

mch13:	mov t, OutputType			;servo or ESC?
	and t, Motor
	brne mch14

	inc Output				;servo will be skipped
	lsl Motor
	brcs mch16

	rjmp mch13				;try next output

mch14:	;update LCD
	call LcdClear12x16

	lrv X1, 52				;M1 - M8
	lrv Y1, 22
	ldi t, 'M'
	call PrintChar
	ldi t, '0'
	inc Output
	add t, Output
	call PrintChar

	ldz udp7*2				;banner
	call PrintSelector

	call LcdUpdate

	push Motor
	push OutputType

mch15:	;PWM loop
	push Output
	call PwmStart
	rcall SetMotorOutput
	call PwmEnd
	pop Output

	b16dec Temp2
	brne mch15

	pop OutputType
	pop Motor

	cpi Output, 8
	brge mch16

	lsl Motor				;select next output
	rjmp mch12

mch16:	;done
	rvsetflagfalse flagArmed
	rvsetflagtrue flagThrottleZero

	;        76543210			;disable OCR1A and B interrupt
	ldi tt,0b00000000
	store timsk1, tt

	call StartPwmQuiet			;enable Quiet PWM output again
	ret



	;--- Clear or set all output values ---

ClearAllOutputValues:

	b16clr Temp				;set all outputs to zero


SetAllOutputValues:

	b16mov Out1, Temp			;set all outputs to the same value (used in throttlecal.asm)
	b16mov Out2, Temp
	b16mov Out3, Temp
	b16mov Out4, Temp
	b16mov Out5, Temp
	b16mov Out6, Temp
	b16mov Out7, Temp
	b16mov Out8, Temp
	ret



	;--- Set motor output ---

SetMotorOutput:

	cpi Output, 1
	brne smo10

	b16mov Out1, EscLowLimit
	ret

smo10:	cpi Output, 2
	brne smo11

	b16mov Out2, EscLowLimit
	ret

smo11:	cpi Output, 3
	brne smo12

	b16mov Out3, EscLowLimit
	ret

smo12:	cpi Output, 4
	brne smo13

	b16mov Out4, EscLowLimit
	ret

smo13:	cpi Output, 5
	brne smo14

	b16mov Out5, EscLowLimit
	ret

smo14:	cpi Output, 6
	brne smo15

	b16mov Out6, EscLowLimit
	ret

smo15:	cpi Output, 7
	brne smo16

	b16mov Out7, EscLowLimit
	ret

smo16:	b16mov Out8, EscLowLimit
	ret



.undef OutputType
.undef Output
.undef Motor


dpw1:	.db "Motors will spin in", 0
dpw2:	.db "sequence M1 - M8", 0, 0
dpw3:	.db "after the countdown.", 0, 0
dpw4:	.db "PLEASE BE CAREFUL!", 0, 0

dpw10:	.dw dpw1*2, dpw2*2, dpw3*2, dpw4*2



	;--- Safety warning regarding spinning motors ---

DisplayPropWarning:

	call LcdClear12x16

	;header
	call PrintWarningHeader

	;text
	lrv X1, 0
	ldi t, 4
	ldz dpw10*2
	call PrintStringArray

	;footer
	call PrintBackFooter
	call PrintOkFooter

	call LcdUpdate

dpw11:	call GetButtonsBlocking

	cpi t, 0x08				;BACK?
	brne dpw12

	sec
	ret

dpw12:	cpi t, 0x01				;OK?
	brne dpw11

	clc
	ret



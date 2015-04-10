

.def Motor = r17
.def Output = r18
.def OutputType = r21


MotorCheck:

	ldz eeMotorLayoutOK			;refuse access if no motor layout is loaded
	call ReadEeprom				;read from user profile #1
	brflagtrue t, mch10

	ldz nadtxt1*2
	call ShowNoAccessDlg
	ret

mch10:	rcall DisplayPropWarning
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
	b16ldi Temp2, 400

mch13:	mov t, OutputType			;servo or ESC?
	and t, Motor
	brne mch14

	inc Output				;servo will be skipped
	lsl Motor
	brcc mch13

	rjmp mch16				;no more motors. Exit

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

mch15:	;PWM loop (run)
	push Output
	call PwmStart
	b16mov Temp, EscLowLimit
	rcall SetMotorOutput
	call PwmEnd
	pop Output

	b16dec Temp2
	brne mch15

	b16ldi Temp2, 200			;pause for 0.5 seconds

mch17:	;PWM loop (stop)
	push Output
	call PwmStart
	b16clr Temp
	rcall SetMotorOutput
	call PwmEnd
	pop Output

	b16dec Temp2
	brne mch17

	pop OutputType
	pop Motor

	lsl Motor				;select next output or leave
	brcs mch16

	rjmp mch12				;next 

mch16:	;done
	rvsetflagfalse flagArmed
	rvsetflagtrue flagThrottleZero

	;        76543210			;disable OCR1A and B interrupt
	ldi tt,0b00000000
	store timsk1, tt

	call StartPwmQuiet			;enable Quiet PWM output again
	ret



	;--- Set motor output ---

SetMotorOutput:

	cpi Output, 1
	brne smo10

	b16mov Out1, Temp
	ret

smo10:	cpi Output, 2
	brne smo11

	b16mov Out2, Temp
	ret

smo11:	cpi Output, 3
	brne smo12

	b16mov Out3, Temp
	ret

smo12:	cpi Output, 4
	brne smo13

	b16mov Out4, Temp
	ret

smo13:	cpi Output, 5
	brne smo14

	b16mov Out5, Temp
	ret

smo14:	cpi Output, 6
	brne smo15

	b16mov Out6, Temp
	ret

smo15:	cpi Output, 7
	brne smo16

	b16mov Out7, Temp
	ret

smo16:	b16mov Out8, Temp
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



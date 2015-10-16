
.def Item		= r17
.def Channel		= r18
.def MixvalueIndex	= r19

MixerEditor:

	no_offset_ldz eeMotorLayoutOK	;refuse access if no motor layout is loaded
	call ReadEeprom
	brflagtrue t, med2

	ldz nadtxt1*2
	rcall ShowNoAccessDlg
	ret

med2:	lds t, UserProfile	;refuse access unless user profile #1 is selected
	tst t
	breq med3

	ldz nadtxt2*2
	rcall ShowNoAccessDlg
	ret

med3:	ldi Item, 0
	clr Channel	

med1:	call LcdClear6x8

	;channel
	lrv X1,102
	ldz med7*2
	call PrintString

	mov xl, channel
	inc xl
	clr xh
	call Print16Signed 

	;Throttle, Aileron, Elevator, Rudder and Offset (with values)
	lrv X1, 0
	lrv Y1, 1
	clr t

med50:	push t
	ldz med10*2
	call PrintFromStringArray
	pop t
	push t
	mov MixvalueIndex, t
	rcall GetMixervalue
	rcall extend
	lrv X1, 48
	call PrintColonAndSpace
	call PrintNumberLF
	lrv X1, 0
	pop t
	inc t
	cpi t, 5
	brlt med50

	;Type
	lrv X1, 0
	ldz med13*2
	call PrintString
	ldi MixvalueIndex, 5
	rcall GetMixervalue	;get value with bit flags for type and rate
	push t
	andi t, 0x01
	ldz type*2
	call PrintFromStringArray

	;Rate
	lrv X1, 72
	ldz med14*2
	call PrintString
	pop t
	lsr t
	andi t, 0x01
	ldz rate*2
	call PrintFromStringArray

	;footer
	call PrintStdFooter

	;print selector
	ldzarray selx*2, 4, Item
	call PrintSelector

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08		;BACK?
	brne med30

	ret

med30:	cpi t, 0x04		;PREV?
	brne med31

	dec Item
	andi item, 0x07
	rjmp med1

med31:	cpi t, 0x02		;NEXT?
	brne med32

	inc Item
	andi Item, 0x07
	rjmp med1

med32:	cpi t, 0x01		;CHANGE?
	brne med33

	cpi Item, 0		;change channel
	brne med40

	inc Channel
	andi Channel, 0x07
	rjmp med1

med40:	cpi Item, 1		;edit mixer value
	brlo med41

	cpi Item, 6
	brsh med41

	mov MixvalueIndex, Item
	dec MixvalueIndex
	rcall GetMixerValue
	rcall Extend
	ldy -127		;lower limit
	no_offset_ldz 127			;upper limit
	call NumberEdit
	mov t, r0
	rcall StoreMixerValue
	rjmp med1

med41:	cpi Item, 6		;toggle Type
	brne med42

	call StopPwmQuiet	;stop PWM output when output type is toggled
	ldi MixvalueIndex,5
	rcall GetMixervalue
	ldi xl, 1 << bMixerFlagType
	eor t, xl
	sbrc t, bMixerFlagType	;set rate to high if selected type is ESC
	ori t, 1 << bMixerFlagRate
	rcall StoreMixervalue
	call StartPwmQuiet	;enable PWM output again
	rjmp med1

med42:	cpi Item, 7		;toggle Rate
	brne med33

	ldi MixvalueIndex,5
	rcall GetMixervalue
	ldi xl, 1 << bMixerFlagRate
	eor t, xl
	sbrc t, bMixerFlagType	;set rate to high if selected type is ESC
	ori t, 1 << bMixerFlagRate
	rcall StoreMixervalue

med33:	rjmp med1




selx:	.db 120, 0, 127, 9
	.db 58, 0, 86, 9
	.db 58, 9, 86, 18
	.db 58, 18, 86, 27
	.db 58, 27, 86, 36
	.db 58, 36, 86, 45
	.db 29, 45, 61, 54
	.db 102, 45, 126, 54




med7:	.db "Ch:",0
med13:	.db "Type:",0
med14:	.db "Rate:",0
med16:	.db "Servo",0
med17:	.db "ESC",0
med18:	.db "High",0,0
med19:	.db "Low",0


med10:	.dw thr*2+offset, ail*2+offset, ele*2+offset, rudd*2+offset, ofs*2+offset
type:	.dw med16*2+offset, med17*2+offset			;servo, ESC
rate:	.dw med19*2+offset, med18*2+offset			;low, high

nad1:	.db "NO ACCESS", 0
nad3:	.db "A Motor Layout must", 0
nad4:	.db "be loaded first.", 0, 0

nad5:	.db "User profile #1 must", 0, 0
nad6:	.db "be selected first.", 0, 0

nadtxt1:.dw nad3*2+offset, nad4*2+offset
nadtxt2:.dw nad5*2+offset, nad6*2+offset



	;--- Show the "No access" dialogue ---

ShowNoAccessDlg:

	pushz				;register Z (input parameter) points to the string array to be used

	call LcdClear12x16

	lrv X1, 10			;header
	ldz nad1*2
	call PrintHeader

	ldi t, 2			;print two message lines
	popz
	call PrintStringArray

	;footer
	call PrintOkFooter

	call LcdUpdate

	call WaitForOkButton
	ret



	;---

GetMixerValue:

	rcall mixc
	jmp ReadEeprom			;for user profile #1 only



	;---

StoreMixerValue:

	push t
	rcall mixc
	pop t
	jmp WriteEeprom			;for user profile #1 only



	;---

Mixc:

	no_offset_ldz EeMixerTable		;Z = *EeMixerTable + Channel * 8 + MixvalueIndex
	mov t, Channel
	lsl t
	lsl t
	lsl t
	add zl, t
	clr t
	adc zh, t
	add zl, MixvalueIndex
	adc zh, t
	ret



	;---

Extend:

	mov xl, t			;extend sign
	clr xh
	tst xl
	brpl med12
	ser xh
med12:	ret
	

.undef Item
.undef Channel
.undef MixvalueIndex


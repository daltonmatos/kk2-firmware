
.def Item		= r17
.def Channel		= r18
.def MixvalueIndex	= r19

MixerEditor:

	ldz eeMotorLayoutOK	;refuse access if no motor layout is loaded
	call ReadEeprom
	brflagtrue t, med2

	rcall ShowNoAccessDlg
	ret

med2:	ldi Item, 0
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
	call Print16Signed
	lrv X1, 0
	rvadd Y1, 9
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
	ldz 127			;upper limit
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


med10:	.dw thr*2, ail*2, ele*2, rudd*2, ofs*2
type:	.dw med16*2, med17*2			;servo, ESC
rate:	.dw med19*2, med18*2			;low, high

nad1:	.db 67, 68, 0, 0			;the text "NO" in the mangled 12x16 font
nad2:	.db 58, 59, 59, 61, 70, 70, 0, 0	;the text "ACCESS" in the mangled 12x16 font

nad3:	.db "A Motor Layout must", 0
nad4:	.db "be loaded first.", 0, 0



	;--- Show the "No access" dialogue ---

ShowNoAccessDlg:

	call LcdClear12x16
	lrv X1, 10
	ldz nad1*2
	call PrintString
	rvadd X1, 12
	ldz nad2*2
	call PrintString

	lrv FontSelector, f6x8
	lrv X1, 0
	lrv Y1, 17
	ldz nad3*2
	call PrintString

	lrv X1, 0
	lrv Y1, 26
	ldz nad4*2
	call PrintString

	;footer
	call PrintOkFooter

	call LcdUpdate

nad10:	call GetButtonsBlocking

	cpi t, 0x01			;OK?
	brne nad10

	ret



	;---

GetMixerValue:

	rcall mixc
	jmp ReadEeprom



	;---

StoreMixerValue:

	push t
	rcall mixc
	pop t
	jmp WriteEeprom



	;---

Mixc:

	ldz EeMixerTable		;Z = *EeMixerTable + Channel * 8 + MixvalueIndex
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


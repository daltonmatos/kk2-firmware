
.def	Item=r4
.def	Output=r5
.def	flagShowAll=r6
.def	flagUnused=r7
.def	Counter=r8

.set xoff = 96
.set yoff = 32


MotorLayout:

	ldz eeMotorLayoutOK	;refuse access if no motor layout is loaded
	call ReadEeprom		;read from user profile #1
	brflagtrue t, ml2

	ldz nadtxt1*2
	call ShowNoAccessDlg
	ret

ml2:	call LoadMixerTable	;load the mixer table to reflect changes made in the mixer editor (this fixes a bug in the original firmware)
	clr Item

mot1:	call LcdClear6x8

	ldz mot11*2
	call PrintString

	tst Item		;item == ALL?
	brne mot13

	ldz mot12*2		;yes, print "ALL"
	call PrintString

	setflagtrue flagShowAll

	ldi t, 8		;show all 8 outputs
	mov Counter, t
	clr Output

mot14:	call ShowMotor
	inc OutPut		 
	dec Counter
	tst Counter
	brne mot14

	rjmp mot15

mot13:	mov OutPut, Item	;no, show single motor.
	dec OutPut

	mov xl, Item
	clr xh
	call Print16Signed

	setflagfalse flagShowAll

	call ShowMotor

mot15:	lrv FontSelector, f6x8 	;footer
	lrv PixelType, 1
	lrv X1, 0
	lrv Y1, 57
	ldz mot21*2
	call PrintString

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08		;BACK?
	brne mot22

	ret			;yes, return

mot22:	cpi t, 0x04		;NEXT?
	brne mot25

	inc Item
	ldi t, 9
	cp Item, t
	brne mot25

	clr Item

mot25:	rjmp mot1



	;--- Show motor ---

ShowMotor:

	ldzarray RamMixerTable, 8, Output

	lrv PixelType, 1

	setflagtrue flagUnused	

	clr yh
	ldd xl, Z + MixvalueRoll
	clr xh
	tst xl		;extend sign
	brpl mot2

	ser yh
	ser xh

mot2:	b16store Mixvalue
	b16clr Temp
	b16cmp Mixvalue, Temp
	breq mot3

	setflagfalse flagUnused

mot3:	b16ldi Temp, 0.25
	b16mul Mixvalue, Mixvalue, Temp
	b16ldi Temp, xoff
	b16add Mixvalue, Mixvalue, Temp
	b16load Mixvalue
	sts X1, xl

	clr yh
	ldd xl, Z + MixvaluePitch
	clr xh
	tst xl		;extend sign
	brpl mot4

	ser yh
	ser xh

mot4:	b16store Mixvalue
	b16clr Temp
	b16cmp Mixvalue, Temp
	breq mot5

	setflagfalse flagUnused

mot5:	b16ldi Temp, -0.25
	b16mul Mixvalue, Mixvalue, Temp
	b16ldi Temp, yoff
	b16add Mixvalue, Mixvalue, Temp
	b16load Mixvalue
	sts Y1, xl

	clr yh
	ldd xl, Z + MixvalueThrottle
	clr xh
	tst xl		;extend sign
	brpl mot16

	ser yh
	ser xh

mot16:	b16store Mixvalue
	b16clr Temp
	b16cmp Mixvalue, Temp
	breq mot20

	setflagfalse flagUnused

mot20:	ldd xl, Z + MixvalueYaw
	tst xl
	breq mot6

	setflagfalse flagUnused

mot6:	brflagfalse flagUnused, mot7	;Output unused?

	brflagfalse flagShowAll, mot8   ;Yes, ShowAll true?
	ret				; Yes, skip drawing and return

mot8:	lrv X1, 66			; No, Print 'Not used' and return
	lrv Y1, 27
	ldz mot9*2
	call PrintString
	ret

mot7:	ldd xl, Z + MixvalueFlags	;No, Motor or servo Output?
	sbrc xl, bMixerFlagType
	rjmp mot17

	brflagtrue flagShowAll, mot18	;servo, ShowAll false?
	lrv X1, 66			;Yes, print "servo" and return
	lrv Y1, 27
	ldz mot19*2
	call PrintString

mot18:	ret

mot17:	lrv X2, xoff			;Motor
	lrv Y2, yoff

	call Bresenham			;draw line

	rvsub X1, 4			;print symbol
	rvsub Y1, 7
	lrv FontSelector, s16x16
	ldi t, 2
	ldd xl, Z + MixvalueYaw
	tst xl 
	brmi mot10

	ldi t, 3

mot10:	call PrintChar

	rvsub X1, 14			;print motor number in symbol
	rvadd Y1, 5
	lrv FontSelector, f4x6
	lrv PixelType, 0
	mov t, Output
	call PrintChar

	brflagfalse flagShowAll, mot35	;print CW or CCW if flagShowAll is false
	rjmp mot27

mot35:	lrv FontSelector, f6x8
	lrv PixelType, 1

	lrv Y1, 15			;print "Direction seen from above:" over three lines (starting at (0, 15))
	ldi t, 3
	pushz
	ldz mot34*2
	call PrintStringArray
	popz
	lrv Y1, 33

	ldd xl, Z + MixvalueYaw
	tst xl
	brmi mot30

	call PrintCW			;CW
	rjmp mot27

mot30:	call PrintCCW			;CCW

mot27:	ret



mot9:	.db "Unused.", 0

mot11:	.db "Motor: ", 0
mot12:	.db "ALL", 0

mot19:	.db "Servo.", 0, 0

mot21:	.db "BACK  NEXT", 0, 0

mot31:	.db "Direction", 0
mot32:	.db "seen from", 0
mot33:	.db "above:", 0, 0

mot34:	.dw mot31*2, mot32*2, mot33*2


.undef	Item
.undef	Output
.undef	flagShowAll
.undef	flagUnused
.undef	Counter


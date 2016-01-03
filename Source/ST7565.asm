.def TargetY		=r17

HilightRectangle:
;	PushAll
	push r17

	lds TargetY, Y2

Hili1:	lds t, Y1
	sts Y2, t

	call Bresenham

	lds t, Y1
	inc t
	sts Y1, t

	cp t, TargetY
	brlo Hili1

;	PopAll
	pop r17
	ret

.undef TargetY


PrintSelector:
	lpm t, z+
	sts X1, t
	lpm t, z+
	sts Y1, t
	lpm t, z+
	sts X2, t
	lpm t, z
	sts Y2, t
	lrv PixelType, 0
	rcall HilightRectangle
	ret


.def	X1r = r17
.def 	Y1r = r18
.def	X2r = r19
.def 	Y2r = r20

Rectangle:
;	PushAll
	push r17
	push r18
	push r19
	push r20

	lds X1r, X1
	lds Y1r, Y1
	lds X2r, X2
	lds Y2r, Y2

	sts Y2, Y1r
	call Bresenham

	sts X1, X2r
	sts Y1, Y2r
	call Bresenham

	sts X2, X1r
	sts Y2, Y2r
	call Bresenham

	sts X1, X1r
	sts Y1, Y1r
	call Bresenham

;	PopAll
	pop r20
	pop r19
	pop r18
	pop r17
	ret


.undef X1r
.undef Y1r
.undef X2r
.undef Y2r



.def flagLeadingZero	=r17
.def Counter		=r18
.def Digit		=r19

Print16Signed:
;	PushAll
	push xl
	push xh
	push yl
	push yh
	push zl
	push zh
	push r17
	push r18
	push r19

	mov t, xl
	or t, xh
	brne print14		;is X zero?

	ldi t, '0'		;yes, print a zero and exit
	call PrintChar
	rjmp print13

print14:clr flagLeadingZero	;no

	tst xh
	brpl print7		;negative?

	com xl			;yes, negate x
	com xh
	ldi t, 1
	add xl, t
	clr t
	adc xh, t

	ldi t, '-'		;print minus sign
	rcall PrintChar

print7: ldz convt*2
	ldi Counter, 5	

print8:	ldi Digit, 0xff
	lpm yl, Z+
	lpm yh, Z+

print9:	sub xl, yl		; digit = int(X / Y) ;  X = frac(X / Y)
	sbc xh, yh

	inc Digit	

	brcc print9	

	add xl, yl
	adc xh, yh

	tst Digit		;is digit zero?
	brne print10

	brflagfalse flagLeadingZero, print11	;yes, skip it if no nonzero digits have been printed
	rjmp print12

print10:ser flagLeadingZero	;no, set flag

print12:mov t, Digit		;Digit to ASCII
	subi t, -0x30

	rcall PrintChar		;print digit

print11:dec Counter		;more digits?
	brne print8

;print13:PopAll			;no, exit
print13:pop r19
	pop r18
	pop r17
	pop zh
	pop zl
	pop yh
	pop yl
	pop xh
	pop xl

	ret




convt:	.dw 10000
	.dw 1000
	.dw 100
	.dw 10
	.dw 1

.undef flagLeadingZero
.undef Counter
.undef Digit


PrintNumberLF:
	rcall Print16Signed

LineFeed:			;OBSERVE: This subroutine must follow immediately after 'PrintNumberLF'!
	rvadd Y1, 9
	ret


PrintHeader:
	rcall PrintString
	lrv FontSelector, f6x8
	lrv Y1, 17
	ret


PrintWarningHeader:

	lrv X1, 16
	ldz warning*2
	rcall PrintHeader
	ret


PrintMotto:
	lrv X1, 0
	ldz motto*2
	call PrintString
	ret


PrintColonAndSpace:
	ldi t, ':'
	rcall PrintChar
	ldi t, ' '
	rcall PrintChar
	ret


PrintCCW:
	ldi t, 'C'
	rcall PrintChar

PrintCW:			;OBSERVE: This subroutine must follow immediately after 'PrintCCW'!
	ldi t, 'C'
	rcall PrintChar
	ldi t, 'W'
	rcall PrintChar
	ret


PrintMenuFooter:
	lrv X1, 0
	lrv Y1, 57
	ldz updown*2
	rcall PrintString
	ret


PrintSelectFooter:
	lrv X1, 0
	lrv Y1, 57
	ldz bckprev*2
	rcall PrintString
	ldz nxtsel*2
	rcall PrintString
	ret


PrintStdFooter:
	lrv X1, 0
	lrv Y1, 57
	pushz
	ldz bckprev*2
	rcall PrintString
	ldz nxtchng*2
	rcall PrintString
	popz
	ret


PrintBackFooter:
	lrv X1, 0
	lrv Y1, 57
	pushz
	ldz back*2
	rcall PrintString
	popz
	ret


PrintChangeFooter:

	lrv X1, 90
	lrv Y1, 57
	ldz change*2
	rcall PrintString
	ret


PrintOkFooter:
	lrv X1, 114
	lrv Y1, 57
	pushz
	ldz ok*2
	rcall PrintString
	popz
	ret


PrintContinueFooter:
	lrv X1, 78
	lrv Y1, 57
	pushz
	ldz cont*2
	rcall PrintString
	popz
	ret


PrintFromStringArray:
	lsl t
	add zl, t
	clr t
	adc zh, t
	lpm xl, z+
	lpm xh, z
	movw z, x
	rcall PrintString
	ret


PrintStringArray:
	pushy
	mov yl, t			;register T = Array size (i.e. Number of strings)
	clr t

psa1:	push t
	pushz				;register Z = Array pointer (16 bit)
	clr yh
	sts X1, yh
	call PrintFromStringArray
	rcall LineFeed
	popz
	pop t
	inc t
	cp t, yl
	brlt psa1

	popy
	ret


PrintString:
print2:	lpm t, z+
	tst t
	breq print1
	rcall PrintChar
	rjmp print2

print1: ret

print_char:
  ret

PrintChar:
  push_all
  clr r25
  mov r24, t
  clr r1
  call print_char
  pop_all
  ret

Bresenham:		;line from (X1,Y1) to (Y2,Y2)

.def	prx1	=r17
.def	prx2	=r18
.def	pry1	=r19
.def	pry2	=r20
.def	xd	=r21
.def	yd	=r22
.def	step	=r23
.def	errorl	=r2
.def	errorh	=r3


	PushAll

	ldi prx1, 1
	ldi prx2, 1
	ldi pry1, 1
	ldi pry2, 1

	lds xd, X2	;xd=x2-x1
	lds t, X1
	sub xd, t

	brpl op1

	neg xd
	ldi prx1, -1
	ldi prx2, -1

op1:	lds yd, Y2
	lds t, Y1
	sub yd, t

	brpl op2

	neg yd
	ldi pry1, -1
	ldi pry2, -1

op2:	cp xd, yd
	brsh op3

	ldi prx1, 0

	mov t, xd
	mov xd, yd
	mov yd, t

	rjmp op4

op3:	ldi pry1, 0

op4:	mov step, xd
	add step, yd

	mov errorl, xd
	clr errorh

	lds t, X1
	sts Xpos, t

	lds t, Y1
	sts Ypos, t

	lsl xd

	lsl yd

op5:	rcall SetPixel

	tst step
	breq op6
	brmi op6

	sub errorl, yd
	clr t
	sbc errorh, t
	brpl op7

	lds t, Xpos
	add t, prx2
	sts Xpos, t

	lds t, Ypos
	add t, pry2
	sts Ypos, t

	add errorl, xd
	clr t
	adc errorh, t

	subi step, 2

	rjmp op5

op7:	lds t, Xpos
	add t, prx1
	sts Xpos, t

	lds t, Ypos
	add t, pry1
	sts Ypos, t

	subi step, 1

	rjmp op5

op6:	PopAll
	ret


.undef	prx1
.undef	prx2
.undef	pry1
.undef	pry2
.undef	xd
.undef	yd
.undef	step
.undef	errorl
.undef	errorh









SetPixel:				; Destroys: t
;	PushAll
	push zl
	push zh
	push xl
	push xh

	ldi zl, low(LcdBuffer)		;Z = LcdBuffer + int(Ypos/8)*128 + Xpos
	ldi zh, high(LcdBuffer)

	lds xl, Ypos
	ldi xh, 0
	andi xl, 0b00111000
	lsl xl
	lsl xl
	lsl xl
	rol xh
	lsl xl
	rol xh

	add zl, xl
	adc zh, xh

	lds t, Xpos
	andi t, 0x7f
	add zl, t
	clr t
	adc zh, t

	lds xl, Ypos			;xl = (Ypos mod 8) + 1
	andi xl, 0b00000111
	inc xl

	ldi xh,  0b00000000		;xh = 2 ^ (xl - 1)
	sec 	
qq7:	rol xh	
	dec xl
	brne qq7

	ld xl, z

	lds t, PixelType
	tst t
	breq qq8
	cpi t, 2
	breq qq10

	or xl, xh
	rjmp qq9

qq10:	com xh
	and xl, xh
	rjmp qq9

qq8: 	eor xl, xh

qq9:	st z, xl


;	PopAll
	pop xh
	pop xl
	pop zh
	pop zl

	ret



lcd_update:
  nop


LcdUpdate:
  safe_call_c lcd_update
  ret

LcdClear:
;	PushAll
	push xl
	push xh
	push zl
	push zh

	;ldi zl, low(LcdBuffer)
	;ldi zh, high(LcdBuffer)
  ldz LcdBuffer

	ldi xl, low(0x0400)
	ldi xh, high(0x0400)

	ldi t,0x00

qq5:	st z+, t
	sbiw xh:xl, 1 
	brne qq5

;	PopAll
	pop zh
	pop zl
	pop xh
	pop xl
	ret


LcdClear6x8:
	rcall LcdClear
	lrv PixelType, 1
	lrv FontSelector, f6x8
	lrv X1, 0
	lrv Y1, 1
	ret


LcdClear12x16:
	rcall LcdClear
	lrv PixelType, 1
	lrv FontSelector, f12x16
	lrv Y1, 0
	ret


	;headers

warning:.db "WARNING!", 0, 0
cerror:	.db "ERROR", 0
saved:	.db "SAVED", 0

	;footers
tunefn:	.db "BACK RATE SAVE CHANGE", 0
qtunefn:.db "BACK RATE NEXT CHANGE", 0
updown:	.db "BACK  UP  DOWN  ENTER", 0
cont:	.db "CONTINUE", 0, 0
clear:	.db "CLEAR", 0
back:	.db "BACK", 0, 0
bckprev:.db "BACK PREV", 0		;used in combination with other footers (e.g. "NEXT CHANGE")
bckmore:.db "BACK MORE", 0		;also used in combination with other footers (e.g. "NEXT CHANGE")
nxtchng:.db " NEXT CHANGE", 0, 0
nxtsel:	.db " NEXT SELECT", 0, 0
change:	.db "CHANGE", 0, 0
ok:	.db "OK", 0, 0			;also used as status text (in sensortest.asm and flightdisplay.asm)

	;other texts
motto:	.db "Fly safe!       RC911", 0
off:	.db "Off", 0
on:	.db "On", 0, 0
no:	.db "No", 0, 0
yes:	.db "Yes", 0
acro:	.db "Acro", 0, 0
alarm:	.db "Alarm", 0
normsl:	.db "Normal SL", 0
slmix:	.db "SL Mix", 0, 0
sltrim:	.db "ACC Trim", 0, 0
slgain:	.db "SL Gain", 0
selflvl:.db "SL", 0, 0
gimbal:	.db "Gimbal", 0, 0
ailele:	.db "Ail+Ele", 0
ail:	.db "Aileron", 0
ele:	.db "Elevator", 0, 0
rudd:	.db "Rudder", 0, 0
thr:	.db "Throttle", 0, 0
aux:	.db "Aux", 0
ofs:	.db "Offset", 0, 0
pgain:	.db "P Gain", 0, 0
plimit:	.db "P Limit", 0
igain:	.db "I Gain", 0, 0
ilimit:	.db "I Limit", 0
locked:	.db "Locked", 0, 0
home:	.db "Home", 0, 0
pos1:	.db "Pos 1", 0
pos2:	.db "Pos 2", 0
pos3:	.db "Pos 3", 0
pos4:	.db "Pos 4", 0
pos5:	.db "Pos 5", 0
rate1:	.db "LOW", 0
rate2:	.db "MEDIUM", 0, 0
rate3:	.db "HIGH", 0, 0
ss0:	.db "SS +0", 0
ss20:	.db "SS +20", 0, 0
ss30:	.db "SS +30", 0, 0
ss50:	.db "SS +50", 0, 0

	;arrays
yesno:	.dw no*2, yes*2
tunmode:.dw off*2, ail*2, ele*2, rudd*2, slgain*2, sltrim*2, gimbal*2
lmh:	.dw null*2, rate1*2, rate2*2, rate3*2
auxtxt:	.dw pos1*2, pos2*2, pos3*2, pos4*2, pos5*2
auxfn:	.dw acro*2, slmix*2, normsl*2, alarm*2
auxss:	.dw ss0*2, ss20*2, ss30*2, ss50*2
aux4txt:.dw locked*2, off*2, home*2
rxch:	.dw ail*2, ele*2, thr*2, rudd*2, aux*2

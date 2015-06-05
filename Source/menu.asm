
.def Counter		= r17
.def ListYpos		= r18
.def CursorYpos		= r19
.def NumberOfItems	= r20


Menu:	mov NumberOfItems, t
	mov ListYpos, xl
	mov CursorYpos, xh

men2:	call LcdClear

	lrv PixelType, 1
	lrv FontSelector, s16x16

	cpi ListYpos, 0		;print the 'up' symbol if not on the top of the list
	breq men3

	lrv X1, 58
	lrv Y1, 0
	ldi t, 0
	call PrintChar

men3:	mov t, ListYpos		;print the 'down' symbol if not on the bottom of the list
	subi t, -5
	cp t, NumberOfItems
	breq men4

	lrv X1, 58
	lrv Y1, 50
	ldi t, 1
	call PrintChar

men4:	lrv FontSelector, f6x8	;print the menu lines.

	lrv Y1, 8
	ldi counter, 5

	movw z, y
	ldi t, 20
	mul t, ListYpos
	add zl, r0
	adc zh, r1

men6:	lrv X1, 0 
	ldi xl, 20

men5:	lpm t, z+
	call PrintChar
	dec xl
	brne men5
	
	rvadd Y1, 8

	dec Counter
	brne men6

	ldi t, 8		;highligth the choosen line
	mul t, CursorYpos
	mov t, r0
	subi t, -7
	sts Y1, t
	subi t, -9
	sts Y2, t
	lrv X1, 0
	lrv X2, 127
	lrv PixelType, 0
	call HilightRectangle

	;footer
	lrv X1, 0
	lrv Y1, 57
	ldz updown*2
	call PrintString

	call LcdUpdate

	ldi xl, 30
men17:	call GetButtons		;wait until button released or time out
	cpi t, 0
	breq men7

	andi t, 0x09		;wait for BACK and ENTER buttons to be released
	brne men17

	dec xl
	brne men17

men7:	call WaitForKeypress

	cpi t, 0x08		;EXIT?
	brne men8

	clr xl
	clc
	rjmp men33

men8:	cpi t, 0x04		;UP?
	brne men9

	cpi CursorYpos, 0 	;on top of screen?
	breq men13

	dec CursorYpos		;no, decrement cursor position
	jmp men11

men13:	cpi ListYpos, 0		;yes, on top of list?
	breq men14

	dec ListYpos		;no, decrement list index
	jmp men11

men14:	jmp men11		;yes, do nothing

men9:	cpi t, 0x02		;DOWN?
	brne men10

	cpi CursorYpos, 4	;on bottom of screen?
	breq men15

	inc CursorYpos		;no, increment cursor position
	jmp men11

men15:	mov t, NumberOfItems	;yes, on bottom of list?
	subi t, 5
	cp ListYpos, t
	breq men16

	inc ListYpos		;no, increment list index
	jmp men11
	
men16:	jmp men11		;yes, do nothing

men10:	cpi t, 0x01		;ENTER?
	brne men11

	call LcdClear		;blank screen
	call LcdUpdate	

	call ReleaseButtons

	mov xl, ListYpos
	add xl, CursorYpos

	sec

men33:	mov yl, ListYpos
	mov yh, CursorYpos
	ret

men11:	rjmp men2



.undef Counter
.undef ListYpos
.undef CursorYpos
.undef NumberOfItems




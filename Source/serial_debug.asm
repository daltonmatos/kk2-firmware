


SerialDebug:

	call ClearSerialBuffer

sdb11:	call GetRxChannels

	;print the contents of the serial buffer
	call LcdClear6x8

	ldi zh, 5				;number of lines
	ldi zl, 5				;number of values per line
	ldy RxBuffer0

sdb12:	rcall PrintHex
	dec zl
	brne sdb12

	call LineFeed
	lrv X1, 0
	ldi zl, 5
	dec zh
	brne sdb12

	;footer
	call PrintBackFooter

	call LcdUpdate

	call RxPollDelay

	call GetButtons

	cpi t, 0x08				;BACK?
	brne sdb11

	call Beep
	ret



hex:	.db "0123456789ABCDEF"



	;--- Print hex value ---

PrintHex:

	pushz
	ldi t, ' ';
	call PrintChar

	ld t, y
	swap t
	andi t, 0x0F
	rcall ph1

	ld t, y+
	andi t, 0x0F
	rcall ph1

	popz
	ret

ph1:	ldz hex*2
	add zl, t
	clr t
	adc zh, t

	lpm t, z
	call PrintChar
	ret



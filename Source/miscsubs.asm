
WaitXms:ldi yl, 10
	rcall wms
	sbiw x, 1
	brne WaitXms
	ret
		

wms:	ldi t,250		;wait yl *0.1 ms at 20MHz
wm1:	dec t
	nop
	nop
	nop
	nop
	nop
	brne wm1
	dec yl
	brne wms
	ret


CmpXy:	cp xl, yl
	cpc xh, yh
	ret


GetButtons:
	push xl
	push yl

	load t, pinb	;read buttons
	com t
	swap t
	andi t, 0x0f
	breq get1	;any buttons pressed?
	
	ldi yl, 100	;yes, wait 10ms
	call wms

	load t, pinb	;read buttons again
	com t
	swap t
	andi t, 0x0f

get1:	pop yl		;no, exit
	pop xl
	ret


ReleaseButtons:
	rcall GetButtons	;wait until button released
	cpi t, 0x00
	brne ReleaseButtons
	ret


GetButtonsBlocking:
	rcall ReleaseButtons

WaitForKeypress:
	rcall GetButtons
	cpi t, 0x00
	breq WaitForKeypress
	
	call Beep

	ret





GetEeVariable16:
	rcall ReadEeprom
	adiw z, 1
	mov xl, t
	rcall ReadEeprom
	adiw z,1
	mov xh, t
	ret

StoreEeVariable16:
	mov t, xl
	rcall WriteEeprom
	adiw z, 1
	mov t, xh
	rcall WriteEeprom
	adiw z, 1
	ret


GetEeVariable8:
	rcall ReadEeprom
	adiw z, 1
	mov xl, t
	ret

StoreEeVariable8:
	mov t, xl
	rcall WriteEeprom
	adiw z, 1
	ret


GetEeVariable168:
	rcall ReadEeprom
	adiw z, 1
	mov yh, t
	rcall ReadEeprom
	adiw z, 1
	mov xl, t
	rcall ReadEeprom
	adiw z, 1
	mov xh, t
	ret

StoreEeVariable168:
	mov t, yh
	rcall WriteEeprom
	adiw z, 1
	mov t, xl
	rcall WriteEeprom
	adiw z, 1
	mov t, xh
	rcall WriteEeprom
	adiw z, 1
	ret


ReadEeprom:
re1:	skbc eecr,1, r0
	rjmp re1

	store eearl,zl	;(Z) -> t
	store eearh,zh

	ldi t,0x01
	store eecr,t

	load t, eedr
	ret


WriteEeprom:
	cli		;t -> (Z)

wr1:	skbc eecr,1, r0
	rjmp wr1

	store eearl,zl
	store eearh,zh

	store eedr,t

	;       76543210
	ldi t,0b00000100
	store eecr,t

	;       76543210
	ldi t,0b00000010
	store eecr,t

	sei
	ret



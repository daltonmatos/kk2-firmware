
.def Item = r17

AdvancedSettings:

	clr Item

adv11:	call LcdClear12x16

	;header
	lrv X1, 16
	ldz adv1*2
	call PrintHeader

	;menu items
	ldi t, 4
	ldz adv10*2
	call PrintStringArray

	;footer
	call PrintMenuFooter

	;print selector
	ldzarray isp7*2, 4, Item
	call PrintSelector

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08			;BACK?
	brne adv15

	ret

adv15:	cpi t, 0x04			;PREV?
	brne adv20

	dec Item

adv16:	andi Item, 0x03
	rjmp adv11

adv20:	cpi t, 0x02			;NEXT?
	brne adv25

	inc Item
	rjmp adv16

adv25:	cpi t, 0x01			;SELECT?
	brne adv11

	call ReleaseButtons
	push Item
	cpi Item, 0
	brne adv26

	call ChannelMapping		;channel mapping
	rjmp adv40

adv26:	cpi Item, 1
	brne adv27

	call SensorSettings		;MPU6050 settings
	rjmp adv40

adv27:	cpi Item, 2
	brne adv28

	call MixerEditor		;mixer editor
	rjmp adv40

adv28:	call BoardRotation		;board rotation

adv40:	pop Item
	rjmp adv11



adv1:	.db "ADVANCED", 0, 0
adv2:	.db "Channel Mapping", 0
adv3:	.db "Sensor Settings", 0
adv4:	.db "Mixer Editor", 0, 0
adv5:	.db "Board Orientation", 0

adv10:	.dw adv2*2, adv3*2, adv4*2, adv5*2


.undef Item

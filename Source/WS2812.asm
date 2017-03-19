
.def Item = r17
.def LedGroup = r18
.def Changes = r19


WS2812Setup:

	clr Item

	call LoadMixerTable			;reload EEPROM values that might have been modified
	call UpdateOutputTypeAndRate
	call LoadGimbalSettings

	rcall WS2812CheckOutputPin
	brcc wss11

	clr t					;output pin configuration error detected. Set value to "None"
	sts WS2812Pin, t

wss11:	call LcdClear12x16

	;header
	lrv X1, 28
	ldz wss1*2
	call PrintHeader

	;menu items
	ldi t, 4
	ldz wss10*2
	call PrintStringArray

	lrv X1, 78				;LED pattern
	lrv Y1, 17
	ldz eeWS2812Pattern
	call GetEePVariable8
	sts WS2812Pattern, xl
	inc xl
	clr xh
	call Print16Signed

	lrv X1, 72				;brightness
	lrv Y1, 35
	ldz eeWS2812Brightness
	call GetEePVariable8
	sts WS2812Brightness, xl
//	mov t, xl
	clr xh
	lsl t
	sbci xh, 0
	call PrintNumberLF

	lrv X1, 72				;output pin
	lds t, WS2812Pin
	ldz ledpin*2
	call PrintFromStringArray

	;footer
	cpi Item, 1
	breq wss12

	call PrintStdFooter
	rjmp wss13

wss12:	call PrintSelectFooter

	;print selector
wss13:	ldzarray isp7*2, 4, Item
	call PrintSelector

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08				;BACK?
	brne wss15

	ret

wss15:	cpi t, 0x04				;PREV?
	brne wss20

	dec Item

wss16:	andi Item, 0x03
	rjmp wss11

wss20:	cpi t, 0x02				;NEXT?
	brne wss25

	inc Item
	rjmp wss16

wss25:	cpi t, 0x01				;CHANGE/SELECT?
	brne wss30

	push Item
	cpi Item, 0
	brne wss26

	lds xl, WS2812Pattern			;select LED pattern
	inc xl
	clr xh
	ldy 1					;lower limit
	ldz 4					;upper limit
	call NumberEdit
	mov t, r0
	dec t
	sts WS2812Pattern, t
	ldz eeWS2812Pattern
	call WriteEepromP

	rcall WS2812LoadData			;update the RGB LED strip
	rcall WS2812SendData_Safe
	rjmp wss29

wss26:	cpi Item, 1
	brne wss27

	rcall WS2812RgbLedSetup			;edit RGB LED data
	rjmp wss29

wss27:	cpi Item, 2
	brne wss28

	rcall WS2812SetBrightness		;adjust brightness
	rjmp wss29

wss28:	rcall WS2812SelectOutputPin		;select output pin

wss29:	pop Item

wss30:	rjmp wss11



//	     123456789012345678901
wss1:	.db "WS2812", 0, 0
wss2:	.db "LED Pattern: ", 0
wss3:	.db "Edit RGB LED Data", 0
wss4:	.db "Brightness: ", 0, 0
wss5:	.db "Output Pin: ", 0, 0

wss10:	.dw wss2*2, wss3*2, wss4*2, wss5*2

//	     123456789012345678901
wso1:	.db "  WS2812 OUTPUT PIN", 0
wso2:	.db "Only M6 and M7 can be", 0
wso3:	.db "used for RGB LED data", 0
wso4:	.db "output. Select NONE", 0
wso5:	.db "to disable feature.", 0

wso6:	.db "BACK   M6   M7   NONE", 0

wso10:	.dw wso2*2, wso3*2, wso4*2, wso5*2

//	     123456789012345678901
wsb1:	.db "  WS2812 BRIGHTNESS", 0
wsb2:	.db "Adjust the brightness", 0
wsb3:	.db "of all active LEDs.", 0

wsb6:	.db "BACK   -10   +2   +10", 0

wsb10:	.dw wsb2*2, wsb3*2, null*2, wss4*2



	;--- Select output pin ---

WS2812SelectOutputPin:

	ldz eeWS2812Pin
	call ReadEeprom
	mov Item, t

wso11:	call LcdClear6x8

	;header
	ldz wso1*2
	call PrintString

	;text
	lrv Y1, 13
	ldi t, 4
	ldz wso10*2
	call PrintStringArray

	;footer
	lrv X1, 0
	lrv Y1, 57
	ldz wso6*2
	rcall PrintString

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08				;BACK?
	brne wso15

	ret

wso15:	cpi t, 0x04				;M6?
	brne wso20

	ldi t, 1
	rjmp wso30

wso20:	cpi t, 0x02				;M7?
	brne wso25

	ldi t, 2
	rjmp wso30

wso25:	cpi t, 0x01				;NONE?
	brne wso11

	clr t

wso30:	rcall WS2812CheckOutputState		;display error message if the selected pin is occupied
	brcc wso31

	rcall WS2812ErrorDlg
	rjmp wso11

wso31:	cp Item, t				;save pin selection, but only if it was changed
	breq wso40

	ldz eeWS2812Pin
	call WriteEeprom			;save in profile #1 only

wso40:	ret



	;--- Adjust brightness ---

WS2812SetBrightness:

	lds t, WS2812Brightness
	sts WS2812BrightnessOld, t

	rcall WS2812LoadData			;update the RGB LED strip
	rcall WS2812SendData_Safe

wsb11:	call LcdClear6x8

	;header
	ldz wsb1*2
	call PrintString

	;text
	lrv Y1, 13
	ldi t, 4
	ldz wsb10*2
	call PrintStringArray

	lrv X1, 72				;brightness
	lrv Y1, 40
	lds xl, WS2812Brightness
	andi xl, 0xFE
	mov t, xl
	clr xh
	lsl t
	sbci xh, 0
	call Print16Signed

	;footer
	lrv X1, 0
	lrv Y1, 57
	ldz wsb6*2
	rcall PrintString

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08				;BACK?
	brne wsb15

	lds xl, WS2812Brightness		;save brightness value, but only if modified
	lds xh, WS2812BrightnessOld
	cp xl, xh
	breq wsb14

	ldz eeWS2812Brightness
	call StoreEePVariable8

wsb14:	ret

wsb15:	cpi t, 0x04				;-10?
	brne wsb20

	ldi t, -10
	rjmp wsb30

wsb20:	cpi t, 0x02				;+2?
	brne wsb25

	ldi t, 2
	rjmp wsb30

wsb25:	cpi t, 0x01				;+10?
	brne wsb40

	ldi t, 10

wsb30:	lds xl, WS2812Brightness
	add xl, t
	cpi xl, 100
	brlt wsb31

	ldi xl, 100
	rjmp wsb32

wsb31:	cpi xl, -100
	brge wsb32

	ldi xl, -100

wsb32:	sts WS2812Brightness, xl

	rcall WS2812LoadData			;update the RGB LED strip
	rcall WS2812SendData_Safe

wsb40:	rjmp wsb11



	;--- Edit RGB LED data ---

WS2812RgbLedSetup:

	rcall WS2812CheckOutputPin
	brcc rls13

	ldz nadtxt4*2				;show a 'NO ACCESS' dialogue and exit when no output pin has been selected
	call ShowNoAccessDlg
	ret

rls13:	rcall WS2812CheckSignature		;initialize RGB data if the signature is unrecognized
	brcc rls10

	rcall WS2812ClearEeData

rls10:	call WS2812PatternWarning		;display a warning when the selected LED pattern is used in other user profiles

	clr Item
	clr LedGroup
	clr Changes

	lds t, WS2812Brightness			;set brightness value to zero to not affect the RGB values
	sts WS2812BrightnessOld, t
	sts WS2812Brightness, Item

	rcall WS2812LoadData			;update the RGB LED strip
	rcall WS2812SendData_Safe

	ldx 2					;clear registers R2 through R12. Used for keeping track of modified data bytes
	ldi yh, 10
	clr t

rls14:	st x+, t
	dec yh
	brne rls14

rls11:	call LcdClear6x8

	;header
	ldz rls1*2
	call PrintString
	call LineFeed

	;labels and values
	ldz WS2812Data				;calculate SRAM address (ZH:ZL)
	ldi yl, 5 * 3				;15 bytes per page/group
	mul yl, LedGroup
	add zl, r0

	ldi yl, 5				;register YL is the loop counter (5 LEDs per page)
	mul yl, LedGroup
	mov yh, r0				;register YH holds the LED index 

rls12:	lrv X1, 0				;label (LED index)
	inc yh
	mov xl, yh
	clr xh
	call Print16Signed
	lrv X1, 12
	ldi t, ':'
	call PrintChar

	lrv X1, 30				;R value
	ld xl, z+
	clr xh
	call Print16Signed

	lrv X1, 60				;G value
	ld xl, z+
	clr xh
	call Print16Signed

	lrv X1, 90				;B value
	ld xl, z+
	clr xh
	call PrintNumberLF

	dec yl
	brne rls12

	;footer
	lrv X1, 0
	lrv Y1, 57
	ldz rls6*2
	rcall PrintString

	;selector
	ldzarray rls7*2, 4, Item
	call PrintSelector

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08				;BACK?
	brne rls30

	tst Changes
	breq rls25

	rcall WS2812SaveData

rls25:	lds t, WS2812BrightnessOld		;restore brightness value
	sts WS2812Brightness, t

	rcall WS2812LoadData			;update the RGB LED strip
	rcall WS2812SendData_Safe
	ret

rls30:	cpi t, 0x04				;PAGE?
	brne rls35

	inc LedGroup
	cpi LedGroup, 5
	brlt rls31

	clr LedGroup

rls31:	clr Item
	rjmp rls11

rls35:	cpi t, 0x02				;NEXT?
	brne rls40

	inc Item
	cpi Item, 15
	brlt rls45

	clr Item
	rjmp rls11

rls40:	cpi t, 0x01				;CHANGE?
	brne rls45

	ldz WS2812Data				;calculate SRAM offset (15 bytes per page/group + Item value)
	ldi t, 5 * 3
	mul t, LedGroup
	add zl, r0
	add zl, Item

	pushz					;edit selected value
	ld xl, z
	clr xh
	ldy 0					;lower limit
	ldz 255					;upper limit
	call NumberEdit
	popz
	st z, r0
	ser Changes

	mov t, Item				;keep track of modified values
	ldz 1

rls41:	dec t
	brmi rls42

	lsl zl
	rol zh
	rjmp rls41

rls42:	mov xl, LedGroup
	inc xl
	lsl xl
	clr xh
	ld yh, x+
	ld yl, x+
	or yh, zh
	or yl, zl
	st -x, yl
	st -x, yh

	rcall WS2812SendData_Safe		;update the RGB LED strip

rls45:	rjmp rls11



	;--- Save RGB data ---

WS2812SaveData:

	call LcdClear12x16

	;header
	lrv X1, 34
	ldz wsd1*2
	call PrintHeader

	lrv X1, 0				;print "Save or discard the modified RGB values?"
	ldi t, 2
	ldz wsd10*2
	call PrintStringArray

	;footer
	lrv X1, 27
	lrv Y1, 57
	ldz wsd8*2
	call PrintString

	call LcdUpdate

wsd11:	rcall GetButtonsBlocking

	cpi t, 0x04				;SAVE?
	breq wsd12

	cpi t, 0x02				;DISCARD?
	brne wsd11

	rcall WS2812LoadData			;restore and update the RGB LED strip
	rcall WS2812SendData_Safe
	ret

wsd12:	ldx 2					;save modified bytes (based on bit pattern in registers R2 - R12)
	ldy WS2812Data
	ldz eeWS2812Data
	lds t, WS2812Pattern
	add zh, t
	ldi LedGroup, 5

wsd13:	ldi Item, 15
	ld r0, x+
	ld r1, x+

wsd14:	ld t, y+
	lsr r0
	ror r1
	brcc wsd15

	call WriteEeprom

wsd15:	adiw z, 1
	dec Item
	brne wsd14

	dec LedGroup
	brne wsd13	

	ret



rls1:	.db "LED  Red Green Blue", 0
rls6:	.db "BACK PAGE NEXT CHANGE", 0


rls7:	.db 29, 9, 48, 18
	.db 59, 9, 78, 18
	.db 89, 9, 108, 18
	.db 29, 18, 48, 27
	.db 59, 18, 78, 27
	.db 89, 18, 108, 27
	.db 29, 27, 48, 36
	.db 59, 27, 78, 36
	.db 89, 27, 108, 36
	.db 29, 36, 48, 45
	.db 59, 36, 78, 45
	.db 89, 36, 108, 45
	.db 29, 45, 48, 54
	.db 59, 45, 78, 54
	.db 89, 45, 108, 54

//	     123456789012345678901
wsd1:	.db "SAVE?", 0
wsd2:	.db "Save or discard the", 0
wsd3:	.db "modified RGB values?", 0, 0
wsd8:	.db "SAVE DISCARD", 0, 0

wsd10:	.dw wsd2*2, wsd3*2

//	     123456789012345678901
wed1:	.db "Selected pin is used", 0, 0
wed2:	.db "for ESC or servo.", 0

wed10:	.dw wed1*2, wed2*2


.undef Item
.undef LedGroup
.undef Changes



	;--- Show channel mapping warning ---

WS2812ErrorDlg:

	call LcdClear12x16

	;header
	lrv X1, 34				;critical error
	ldz cerror*2
	call PrintHeader

	;text
	ldi t, 2				;print "Selected pin is used for ESC or servo."
	ldz wed10*2
	call PrintStringArray

	;footer
	call PrintOkFooter

	call LcdUpdate

	call WaitForOkButton
	ret



	;--- Show a warning when the selected LED pattern is used in other user profiles ---

WS2812PatternWarning:

	lds xl, WS2812Pattern			;check all user profiles for the selected LED pattern (stored in register XL)
	clr xh
	ldz eeWS2812Pattern

wpw11:	call ReadEeprom
	cp t, xl
	brne wpw12

	inc xh					;count user profiles that has this LED pattern

wpw12:	inc zh
	cpi zh, 4
	brlt wpw11

	cpi xh, 2
	brge wpw13

	ret					;selected LED pattern is used only once. No need to display the warning message

wpw13:	call LcdClear12x16

	;header
	lrv X1, 16
	ldz remindr*2
	call PrintHeader

	;text
	ldi t, 4				;print "This LED pattern is used in more than one user profile. Editing will affect them all."
	ldz wpw10*2
	call PrintStringArray

	;footer
	call PrintOkFooter

	call LcdUpdate

	call WaitForOkButton
	ret



//	     123456789012345678901
wpw1:	.db "This LED pattern is", 0
wpw2:	.db "used in more than one", 0
wpw3:	.db "user profile. Editing", 0
wpw4:	.db "will affect them all.", 0

wpw10:	.dw wpw1*2, wpw2*2, wpw3*2, wpw4*2



	;--- Check output pin selection and state ---

WS2812CheckOutputPin:

	ldz eeWS2812Pin
	call ReadEeprom
	tst t
	breq wop1				;jump if feature is disabled

	cpi t, 3
	brsh wop1				;jump if configuration value is invalid

WS2812CheckOutputState:

	lds xl, OutputStateBitmask
	mov xh, t
	swap xh
	lsl xh
	and xh, xl
	breq wop2				;jump if output pin is available

wop1:	sec					;error or feature disabled
	ret

wop2:	sts WS2812Pin, t			;OK
	clc
	ret



	;--- Check EEPROM signature ---

WS2812CheckSignature:

	ldz E2Signature
	lds t, WS2812Pattern
	add zh, t
	call GetEeVariable8
	cpi xl, 0x28
	brne wcs1

	call GetEeVariable8
	cpi xl, 0x12
	brne wcs1

	call GetEeVariable8
	cpi xl, 0xAA
	brne wcs1

	call GetEeVariable8
	cpi xl, 0x19
	brne wcs1

	clc					;signature is OK
	ret

wcs1:	sec					;bad signature
	ret



	;--- Write EEPROM signature ---

WS2812WriteSignature:

	ldz E2Signature
	lds t, WS2812Pattern
	add zh, t
	ldi xl, 0x28
	call StoreEeVariable8
	ldi xl, 0x12
	call StoreEeVariable8
	ldi xl, 0xAA
	call StoreEeVariable8
	ldi xl, 0x19
	call StoreEeVariable8
	clr xl
	call StoreEeVariable8			;eeWS2812ID
	ret



	;--- Copy RGB LED data from EEPROM to SRAM ---

WS2812LoadData:

	rcall WS2812CheckOutputPin
	brcc wld1

	clr t					;output pin conflict or not defined!
	sts WS2812Pin, t
	sec
	ret

wld1:	rcall WS2812CheckSignature
	brcc wld2

	rcall WS2812ClearData			;unrecognized signature!
	clc
	ret

	;load data
wld2:	ldz eeWS2812Data
	lds t, WS2812Pattern
	add zh, t
	ldy WS2812Data
	ldi xh, 25 * 3

	lds r0, WS2812Brightness		;registers R1:R0 will hold the brightness value (extended from signed 8 bit)
	clr r1
	mov t, r0
	lsl t
	sbc r1, r1

wld3:	call ReadEeprom
	adiw z, 1
	tst t
	breq wld4

	clr xl					;registers XL:T will hold the LED value (extended from unsigned 8 bit)

	add t, r0				;add brightness (offset) and limit the result to [0, 255]
	adc xl, r1
	breq wld4

	clr t
	com xl
	lsl xl
	sbci t, 0

wld4:	st y+, t
	dec xh
	brne wld3

	clc					;data loaded
	ret



	;--- Send RGB value(s) ---

WS2812SendData_Safe:				;avoid disturbing the Quiet ESC PWM interrupts

	rvbrflagfalse flagPwmState, WS2812SendData_Safe

rgb22:	rvbrflagtrue flagPwmState, rgb22	;wait for PWM outputs to go low


WS2812SendData:					;alternative entry point (called from flightinit.asm)

	lds t, WS2812Pin			;check pin configuration
	tst t
	brne rgb21

rgb20:	ret					;abort

rgb21:	bst t, 1				;the T flag decides which output pin to use (0=M6, 1=M7)
	cpi t, 3
	brsh rgb20				;jump (abort) if configuration value is invalid

	rcall WS2812CheckOutputState
	brcs rgb20				;jump (abort) if the output pin is used for ESC or servo control

	;send 24 bit value (GRB, not RGB)
rgb10:	ldz WS2812Data
	ldi yl, 25				;number of RGB LEDs
	cli

rgb11:	ldi t, 24				;24 bit per LED
	ld xl, z+
	ld xh, z+
	ld yh, z+

rgb1:	lsl yh					;1
	rol xl					;1
	rol xh					;1
	brcs rgb2				;1/2

	;low bit (pin should stay high for 350ns and low for 800ns)
	brts rgb1a				;1/2

	sbi OutputPin6				;2
	rjmp rgb1b				;2

rgb1a:	sbi OutputPin7				;2
	nop

rgb1b:	nop
	nop
	brts rgb1c				;1/2

	cbi OutputPin6				;2
	rjmp rgb1d				;2

rgb1c:	cbi OutputPin7				;2
	nop

rgb1d:	nop
	nop
	rjmp rgb3				;2

	;high bit (pin should stay high for 700ns and low for 600ns)
rgb2:	brts rgb2a				;1/2

	sbi OutputPin6				;2
	rjmp rgb2b				;2

rgb2a:	sbi OutputPin7				;2
	nop

rgb2b:	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	brts rgb2c				;1/2

	cbi OutputPin6				;2
	rjmp rgb3				;2

rgb2c:	cbi OutputPin7				;2

rgb3:	dec t					;1
	brne rgb1				;1/2

	dec yl
	brne rgb11

	sei
	ret



	;--- Clear RGB LED data in EEPROM and SRAM ---

WS2812ClearEeData:

	rcall WS2812CheckSignature		;update signature if unrecognized
	brcc wce1

	rcall WS2812WriteSignature

	;erase data
wce1:	ldy WS2812Data
	ldz eeWS2812Data
	lds t, WS2812Pattern
	add zh, t
	ldi xh, 25 * 3
	clr xl

wce2:	call StoreEeVariable8
	st y+, xl
	dec xh
	brne wce2

	rcall WS2812SendData_Safe		;data was erased. Update the RGB LED strip
	ret



	;--- Clear RGB LED data in SRAM only ---

WS2812ClearData:

	ldy WS2812Data
	ldi xh, 25 * 3
	clr xl

wcd1:	st y+, xl
	dec xh
	brne wcd1

	ret



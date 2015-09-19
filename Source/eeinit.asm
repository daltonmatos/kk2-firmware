
.def	Counter = r17



	;--- Initialize EEPROM if the signature is bad ---

EeInit:

	ldx 0				;check EEPROM signature for user profile #1
	rcall CheckEeSignature
	brcc eei1

	clr t				;initialize user profile #1
	sts UserProfile, t
	rcall InitUserProfile

	clr xl				;set user profile #1 to be used as default
	ldz eeUserProfile
	call StoreEeVariable8
	call StoreEeVariable8		;eeUserAccepted (set to NO)
	call StoreEeVariable8		;eeBoardOffset90 (set to zero degrees)

	call DisableEscCalibration
	call SetDefaultLcdContrast

	rcall ShowDisclaimer
	rcall InitialSetup		;display initial setup menu
	ret

eei1:	ldz eeUserAccepted		;show the disclaimer if not yet accepted
	call ReadEeprom
	brflagtrue t, eei2

	rcall ShowDisclaimer

eei2:	lds xh, UserProfile		;check EEPROM signature for the current user profile (skipped for profile #1)
	tst xh
	breq eei3

	clr xl
	rcall CheckEeSignature
	brcc eei3

	rcall InitUserProfile		;initialize current user profile

eei3:	ret



	;--- Check EEPROM signature (register XH decides which user profile to check) ---

CheckEeSignature:

	ldy eesign*2			;register Y points to the data array
	ldi Counter, 4			;number of bytes to be checked

ces1:	movw z, y
	lpm t, z
	push t
	movw z, x			;register X (input parameter) points to the EEPROM location
	call ReadEeprom
	pop zl
	cp t, zl
	brne ces2

	adiw x, 1
	adiw y, 1
	dec Counter
	brne ces1

	clc				;signature is OK
	ret

ces2:	sec				;bad signature
	ret



	;--- Initialize the current user profile ---

InitUserProfile:

	ldz EeMixerTable		;mixer table
	ldx 0
	ldi Counter, 64
iup3:	call StoreEePVariable8
	dec Counter
	brne iup3

	ldx EeParameterTable		;parameter table (12 words)
	ldy eei5*2
	ldi Counter, 24
	rcall WriteEePArray

	ldx eeStickScaleRoll		;write the remaining parameters (64 bytes)
	ldi Counter, 64
	rcall WriteEePArray

	ldx 0				;EEPROM signature
	ldi Counter, 4
	rcall WriteEePArray

	ldi Counter, 5
iup6:	call Beep
	ldi yl, 0
	call wms
	dec Counter
	brne iup6

	ret



	;WARNING! The order of these data arrays is critical! Padding bytes must be added to EEPROM variables also!

eei5:	.dw 50, 100, 25, 20		;default PI gains and limits for aileron, elevator and rudder
	.dw 50, 100, 25, 20
	.dw 50, 20, 50, 10

	.dw 30, 30, 50, 90		;default stick scaling settings							 8 bytes

	.dw 60, 20, 0, 0, 10		;default self-level settings							10 bytes

	.dw 10, 0, 0, 50		;default misc settings								 8 bytes

	.db 0xFF, 0xFF, 0xFF, 0xFF	;default mode settings								 4 bytes

	.dw 0, 0, 0, 0, 0, 0		;default gimbal settings (plus padding)						14 bytes
	.db 0x00, 0x00

	.db 0, 3, 1, 3, 2, 0, 0, 0, 0, 0;default aux switch settings							10 bytes

	.db 1, 2, 3, 4, 5, 6, 7, 8	;default RX channel order							 8 bytes

	.db 0x00, 0x00			;eeSensorsCalibrated, eeMotorLayoutOk						 2 bytes

					;									TOTAL:	64 bytes

eesign:	.db 0x19, 0x03, 0x73, 0xB5	;EEPROM signature (must be the last item)



	;--- Write data array to EEPROM ---

WriteEePArray:

	movw z, y			;register Y (input parameter) points to the data array
	lpm t, z
	movw z, x			;register X (input parameter) points to the EEPROM location
	call WriteEepromP
	adiw x, 1
	adiw y, 1
	dec Counter			;register COUNTER (input parameter) holds the number of bytes to be written
	brne WriteEePArray

	ret



	;--- Disclaimer ---

ShowDisclaimer:

	call LcdClear12x16

	lrv X1, 16			;reminder
	ldz eew1*2
	call PrintHeader

	ldi t, 4			;print disclaimer text
	ldz eew10*2
	call PrintStringArray

	;footer
	call PrintOkFooter

	call LcdUpdate

	call WaitForOkButton

	ser t				;set flag to indicate that the user has accepted the disclaimer
	ldz eeUserAccepted
	call WriteEeprom
	ret



eew1:	.db 70, 61, 66, 64, 67, 60, 61, 70, 0, 0	;the text "REMINDER" in the mangled 12x16 font

eew2:	.db "YOU USE THIS FIRMWARE", 0
eew3:	.db "AT YOUR OWN RISK!", 0

eew10:	.dw eew2*2, eew3*2, null*2, motto*2


isp1:	.db 71, 61, 72, 73, 69, 0	;the text "SETUP" in the mangled 12x16 font
isp2:	.db "Load Motor Layout", 0
isp3:	.db "ACC Calibration", 0
isp4:	.db "Receiver Test", 0
isp5:	.db "Board Orientation", 0




isp7:	.db 0, 16, 127, 25
	.db 0, 25, 127, 34
	.db 0, 34, 127, 43
	.db 0, 43, 127, 52

isp10:	.dw isp2*2, isp3*2, isp4*2, isp5*2



	;--- Initial setup menu ---

InitialSetup:

	clr Counter
	sts LoadMenuListYposSave, Counter
	sts LoadMenuCursorYposSave, Counter

isp11:	call LcdClear12x16

	;header
	lrv X1, 34
	ldz isp1*2
	call PrintHeader

	;menu items
	ldi t, 4
	ldz isp10*2
	call PrintStringArray

	;footer
	call PrintMenuFooter

	;print selector
	ldzarray isp7*2, 4, Counter
	call PrintSelector

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08			;BACK?
	brne isp15

	ret

isp15:	cpi t, 0x04			;PREV?
	brne isp20

	dec Counter

isp16:	andi Counter, 0x03
	rjmp isp11

isp20:	cpi t, 0x02			;NEXT?
	brne isp25

	inc Counter
	rjmp isp16

isp25:	cpi t, 0x01			;SELECT?
	brne isp11

	call ReleaseButtons
	push Counter
	cpi Counter, 0
	brne isp26

	call LoadMixer			;load motor layout
	rjmp isp40

isp26:	cpi Counter, 1
	brne isp27

	call CalibrateSensors		;ACC calibration
	rjmp isp40

isp27:	cpi Counter, 2
	brne isp28
	
	call RxTest			;receiver Test
	rjmp isp40

isp28:	call BoardOrientation		;board offset

isp40:	pop Counter
	rjmp isp11


.undef Counter


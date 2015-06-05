
.def	Counter = r17



	;--- Initialize EEPROM if the signature is bad ---

EeInit:

	ldx 0				;check EEPROM signature
	ldy eesign*2			;register Y points to the data array
	ldi Counter, 4			;number of bytes to be checked

ces1:	movw z, y
	lpm t, z
	push t
	movw z, x			;register X points to the EEPROM location
	call ReadEeprom
	pop zl
	cp t, zl
	brne ces2

	adiw x, 1
	adiw y, 1
	dec Counter
	brne ces1

	ldz eeUserAccepted		;show the disclaimer unless it has already been accepted
	call ReadEeprom
	brflagtrue t, ces3

ces4:	rcall ShowDisclaimer

ces3:	ret

ces2:	rcall Init			;initalize
	call DisableEscCalibration
	call SetDefaultLcdContrast
	rjmp ces4



	;--- Initialize all EEPROM variables ---

Init:

	ldz EeMixerTable		;mixer table
	ldx 0
	ldi Counter, 64
eei3:	call StoreEeVariable8
	dec Counter
	brne eei3

	ldx EeParameterTable		;parameter table (12 words)
	ldy eei5*2
	ldi Counter, 24
	rcall WriteEeArray

	ldx eeStickScaleRoll		;stick scaling (5 words)
	ldi Counter, 10
	rcall WriteEeArray

	ldi Counter, 10			;self-level settings (5 words)
	rcall WriteEeArray

	ldi Counter, 10			;misc settings (5 words)
	rcall WriteEeArray

	ldi Counter, 6			;mode settings (5 bytes + padding)
	rcall WriteEeArray

	ldi Counter, 14			;gimbal settings (6 words + 1 byte + padding)
	rcall WriteEeArray

	ldi Counter, 8			;RX channel order (8 bytes) 
	rcall WriteEeArray

	ldi Counter, 4			;eeSensorsCalibrated, eeMotorLayoutOk, eeUserAccepted and eeTuningRate (4 bytes)
	rcall WriteEeArray

	ldx 0				;EEPROM signature
	ldi Counter, 4
	rcall WriteEeArray

	ldi Counter, 5
eei4:	call Beep
	ldi yl, 0
	call wms
	dec Counter
	brne eei4

	ret



	;WARNING! The order of these data arrays is critical! Padding bytes must be added to EEPROM variables also!

eei5:	.dw 50, 100, 25, 20		;default PI gains and limits for aileron, elevator and rudder
	.dw 50, 100, 25, 20
	.dw 50, 20, 50, 10

	.dw 30, 30, 50, 90, 100		;default stick scaling settings

	.dw 60, 20, 0, 0, 10		;default self-level settings

	.dw 10, 0, 30, 0, 50		;default misc settings

	.db 0xFF, 0xFF, 0xFF, 0xFF	;default mode settings (plus padding)
	.db 0x00, 0x00

	.dw 0, 0, 0, 0, 0, 0		;default gimbal settings (plus padding)
	.db 0x00, 0x00

	.db 1, 2, 3, 4, 5, 6, 7, 8	;default RX channel order

	.db 0x00, 0x00, 0x00, 0x02	;eeSensorsCalibrated, eeMotorLayoutOk, eeUserAccepted and eeTuningRate

eesign:	.db 0x19, 0x03, 0x73, 0xC4	;EEPROM signature (must be the last item)



	;--- Write data array to EEPROM ---

WriteEeArray:

	movw z, y			;register Y (input parameter) points to the data array
	lpm t, z
	movw z, x			;register X (input parameter) points to the EEPROM location
	call WriteEeprom
	adiw x, 1
	adiw y, 1
	dec Counter			;register COUNTER (input parameter) holds the number of bytes to be written
	brne WriteEeArray

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

eew11:	call GetButtonsBlocking
	cpi t, 0x01			;OK?
	brne eew11

	ser t				;set flag to indicate that the user has accepted the disclaimer
	ldz eeUserAccepted
	call WriteEeprom

	call ReleaseButtons		;make sure buttons are released
	ret



eew1:	.db 69, 61, 66, 64, 67, 60, 61, 69, 0, 0;the text "REMINDER" in the mangled 12x16 font

eew2:	.db "YOU USE THIS FIRMWARE", 0
eew3:	.db "AT YOUR OWN RISK!", 0
eew4:	.db "Read all included", 0
eew5:	.db "documents carefully.", 0, 0

eew10:	.dw eew2*2, eew3*2, eew4*2, eew5*2


.undef Counter


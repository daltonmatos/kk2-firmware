
CalibrateSensors:

	call LcdClear6x8

	ldi t, 6
	ldz cel10*2
	call PrintStringArray

	;footer
	call PrintContinueFooter

	call LcdUpdate

cel5:	call GetButtonsBlocking
	cpi t, 0x01			;CONTINUE?
	brne cel5

	ldi xl, 53			;53 is the character '5' in the mangled 12x16 font

	;countdown
cel15:	call LcdClear12x16

	lrv X1, 58
	lrv Y1, 22
	mov t, xl
	call PrintChar

	call LcdUpdate

	;one second delay
	ldi yh, 100
cel17:	ldi yl, 100
	call wms
	dec yh
	brne cel17

	;next character
	dec xl
	cpi xl, 47			;47 is the character '-' in the mangled 12x16 font
	breq cel21
	rjmp cel15

cel21:	call LcdClear6x8

	lrv X1, 25			;calibrating...
	lrv Y1, 25
	ldz cel19*2
	call PrintString

	call LcdUpdate

	ldi yl, 0
	call wms

	ldi zl, 16			;calibrate accerellometers, average of 16 readings

	b16clr AccXZero
	b16set AccYZero
	b16set AccZZero

caa1:	call AdcRead

	push zl				;register ZL is destroyed by 'b16add'!
	b16add AccXZero, AccXZero, AccX
	b16add AccYZero, AccYZero, AccY
	b16add AccZZero, AccZZero, AccZ
	pop zl

	ldi yl, 100
	call wms

	dec zl
	breq caa2
	rjmp caa1

caa2:	b16fdiv AccXZero, 4
	b16fdiv AccYZero, 4
	b16fdiv AccZZero, 4

	ldi yh, 40
cel22:	ldi yl, 0
	call wms
	dec yh
	brne cel22

	rvsetflagtrue flagSensorsOk

	call LcdClear6x8		;show and check result
	lrv Y1, 10
	ldi t, 3
	ldz accxyz*2
	call PrintStringArray

	lrv Y1, 10			;acc X
	b16load AccXZero
	call PrintAccValue

	b16load AccYZero		;acc Y
	call PrintAccValue

	b16load AccZZero		;acc Z
	call PrintAccValue

	;footer
	call PrintContinueFooter

	call LcdUpdate

	rvbrflagfalse flagSensorsOk, cel35

	ldz EeSensorCalData		;save calibration data if passed.
		
	b16load AccXZero
	call StoreEeVariable168
	b16load AccYZero
	call StoreEeVariable168
	b16load AccZZero
	call StoreEeVariable168

	ldz eeSensorsCalibrated		;OK
	setflagtrue t
	call WriteEeprom
	rjmp cel23

cel35:	ldz eeSensorsCalibrated		;Failed
	setflagfalse t
	call WriteEeprom
	setstatusbit AccNotCalibrated

cel23:	call GetButtonsBlocking
	cpi t, 0x01			;CONTINUE?
	brne cel23

	call LcdClear6x8		;print result (failed or succeeded)
	lrv Y1, 25

	lds t, flagSensorsOk
	andi t, 0x01
	ldz cal*2
	call PrintFromStringArray

cel30:	;footer
	call PrintContinueFooter

	call LcdUpdate

cel32:	call GetButtonsBlocking
	cpi t, 0x01			;CONTINUE?
	brne cel32

	ret



GyroCal:

	ldi zl, 16					;calibrate gyros, average of 16 readings

	b16clr GyroRollZero
	b16set GyroPitchZero
	b16set GyroYawZero

cna1:	call AdcRead

	push zl						;register ZL is destroyed by 'b16add'!
	b16add GyroRollZero, GyroRollZero, GyroRoll
	b16add GyroPitchZero, GyroPitchZero, GyroPitch
	b16add GyroYawZero, GyroYawZero, GyroYaw
	pop zl

	ldi yl, 100
	call wms

	dec zl
	breq cna2

	rjmp cna1

cna2:	b16fdiv GyroRollZero, 4
	b16fdiv GyroPitchZero, 4
	b16fdiv GyroYawZero, 4
	ret




cel2:	.db "Place the aircraft on", 0
cel3:   .db "a level surface and",0
cel4:	.db "press CONTINUE.",0
cel6:	.db "The FC will then wait", 0
cel7:	.db "a few sec to let the", 0, 0
cel8:	.db "aircraft settle down.", 0

cel10:	.dw cel2*2, cel3*2, cel4*2, cel6*2, cel7*2, cel8*2

cel19:	.db "Calibrating...", 0, 0
cel24:	.db "Calibration failed.", 0
cel31:	.db "Calibration succeeded", 0

cal:	.dw cel24*2, cel31*2				;failed, succeeded

accxyz:	.dw sen5*2, sen6*2, sen7*2			;ACC X, Y and Z





SensorTest:

	call GyroCal			;calibrate gyro since the gyro settings (MPU6050) may have been changed

sen1:	call ReadSensors

	call LcdClear6x8

	ldi t, 6			;print all text labels first
	ldz sen19*2
	call PrintStringArray

	lrv Y1, 1			;gyro X
	b16load GyroPitch
	rcall PrintGyroValue
	
	b16load GyroRoll		;gyro Y
	rcall PrintGyroValue

	b16load GyroYaw			;gyro Z
	rcall PrintGyroValue

	set				;set the T flag to indicate that sensor test is running

	b16load AccX			;acc X
	ldz sen21*2
	rcall PrintAccValue

	b16load AccY			;acc Y
	ldz sen22*2
	rcall PrintAccValue

	b16load AccZ			;acc Z
	ldz sen23*2
	rcall PrintAccValue

	;footer
	call PrintBackFooter

	call LcdUpdate

	ldi yh, 5
sen10:	ldi yl, 0
	call wms
	dec yh
	brne sen10
	
	call GetButtons
	cpi t, 0x08			;BACK?
	brne sen16

	ret	

sen16:	jmp sen1





GyroCheck:
	ldy GyroLowLimit
	rcall GetGyroLimit16		;compensate for selected gyro configuration
	call CmpXy
	brlt sen14

	ldy GyroHighLimit
	rcall GetGyroLimit16		;compensate for selected gyro configuration
	call CmpXy
	brge sen14

	ldi t, 1			;OK
	rjmp sen15

AccCheck:
	ldy AccLowLimit
	rcall GetAccLimit16		;compensate for selected ACC configuration
	call CmpXy
	brlt sen14

	brts sen11

	ldy AccZHighLimit		;calibrating ACC. Use higher limit due to gravity
	rjmp sen12

sen11:	ldy AccHighLimit		;testing ACC. Use lower limit

sen12:	rcall GetAccLimit16		;compensate for selected ACC configuration
	call CmpXy
	brge sen14

	ldi t, 1			;OK
	brtc sen15			;skip ahead when ACC calibration is running

	ldi yl, 40			;will print text (Forward, Back, Left and Right) when the board is slightly tilted
	rcall GetAccLimit8		;compensate for selected ACC configuration

	call CmpXy			;positive tilt limit (40, 20, 10 or 5, corresponding to 2g, 4g, 8g and 16g) for text display
	brge sen17

	neg yl				;negative tilt limit
	inc yl
	ser yh
	call CmpXy
	brlt sen18

	rjmp sen15			;OK

sen17:	clr t

sen18:	lds xl, BoardOrientation	;compensate for +/- 90 degrees board rotation
	andi xl, 0x01
	add t, xl

	ldi xl, 76
	sts X1, xl
	call PrintFromStringArray
	ret

sen14:	clr t				;not OK
	sts flagSensorsOk, t

sen15:	ldi xl, 76
	sts X1, xl
	ldz sen20*2
	call PrintFromStringArray
	ret



PrintGyroValue:
	lrv X1, 48
	call Print16Signed 
	rcall GyroCheck
	rjmp pav1

PrintAccValue:
	lrv X1, 48
	call Print16Signed 
	rcall AccCheck

pav1:	call LineFeed
	ret



	;--- Calculate 16 bit gyro limit based on the current configuration ---

GetGyroLimit16:

	lds t, MpuGyroCfg
	lsr t
	lsr t
	lsr t
	brne ggl10

	ret

ggl10:	asr yh				;register Y (input/output) initially holds the limit to be used for 250 degrees/s
	ror yl
	dec t
	brne ggl10

	ret				;register Y holds the output value



	;--- Calculate 16 bit accelerometer limit based on the current configuration ---

GetAccLimit16:

	lds t, MpuAccCfg
	lsr t
	lsr t
	lsr t
	brne gal10

	ret				;current ACC setting is 2g so no calculation is necessary

gal10:	asr yh				;register Y (input/output) initially holds the limit to be used for 2g
	ror yl
	dec t
	brne gal10

	ret				;register Y holds the output value



	;--- Calculate 8 bit accelerometer limit based on the current configuration ---

GetAccLimit8:

	lds yh, MpuAccCfg
	lsr yh
	lsr yh
	lsr yh
	brne gal1

	ret				;current ACC setting is 2g so no calculation is necessary

gal1:	lsr yl				;register YL (input/output) initially holds the limit to be used for 2g
	dec yh
	brne gal1

	ret				;register YL holds the output value



sen2:	.db "Gyro X:", 0
sen3:	.db "Gyro Y:", 0
sen4:	.db "Gyro Z:", 0
sen5:	.db "Acc X :", 0
sen6:	.db "Acc Y :", 0
sen7:	.db "Acc Z :", 0
sen13:	.db "Not OK", 0, 0

sen19:	.dw sen2*2, sen3*2, sen4*2, sen5*2, sen6*2, sen7*2
sen20:	.dw sen13*2, ok*2
sen21:	.dw fwd*2, rev*2, fwd*2
sen22:	.dw left*2, right*2, left*2
sen23:	.dw ok*2, ok*2, ok*2


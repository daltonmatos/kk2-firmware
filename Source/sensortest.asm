


SensorTest:

sen1:	call AdcRead
	call LcdClear6x8

	ldi t, 6		;print all text labels first
	ldz sen19*2
	call PrintStringArray

	lrv Y1, 1		;gyro X
	b16load GyroPitch
	rcall PrintGyroValue
	
	b16load GyroRoll	;gyro Y
	rcall PrintGyroValue

	b16load GyroYaw		;gyro Z
	rcall PrintGyroValue

	b16load AccX		;acc X
	rcall PrintAccValue

	b16load AccY		;acc Y
	rcall PrintAccValue

	b16load AccZ		;acc Z
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
	cpi t, 0x08		;BACK?
	brne sen16

	ret	

sen16:	jmp sen1





GyroCheck:
	ldy GyroLowlimit
	call CmpXy
	brlo sen14

	ldy GyroHighLimit
	call CmpXy
	brsh sen14

	rjmp sen12		;OK

AccCheck:
	ldy AccLowlimit
	call CmpXy
	brlo sen14

	ldy AccHighLimit
	call CmpXy
	brsh sen14

sen12:	ldi t, 1		;OK
	push t
	rjmp sen15

sen14:	clr t			;Not OK
	push t
	rvsetflagfalse flagSensorsOk

sen15:	lrv X1, 76
	pop t
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



sen2:	.db "Gyro X:", 0
sen3:	.db "Gyro Y:", 0
sen4:	.db "Gyro Z:", 0
sen5:	.db "Acc X :", 0
sen6:	.db "Acc Y :", 0
sen7:	.db "Acc Z :", 0
sen13:	.db "Not OK", 0, 0

sen19:	.dw sen2*2, sen3*2, sen4*2, sen5*2, sen6*2, sen7*2
sen20:	.dw sen13*2, ok*2


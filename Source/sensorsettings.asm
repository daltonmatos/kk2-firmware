
.def Item = r17
.def MpuAccOld = r19
.def MpuGyroOld = r20
.def MpuFilterOld = r21

SensorSettings:

//	call GetMpu6050Setup

	clr Item
	lds MpuAccOld, MpuAccCfg
	lds MpuGyroOld, MpuGyroCfg
	lds MpuFilterOld, MpuFilter

sse11:	call LcdClear6x8

	ldz sse1*2			;HW filter
	call PrintString
	ldz lpf*2
	lds t, MpuFilter
	andi t, 0x07
	rcall PrintSensorValue

	ldz sse2*2			;gyro
	call PrintString
	ldz gyro*2
	lds t, MpuGyroCfg
	lsr t
	lsr t
	lsr t
	andi t, 0x03
	rcall PrintSensorValue

	ldz sse3*2			;ACC
	call PrintString
	ldz acc*2
	lds t, MpuAccCfg
	lsr t
	lsr t
	lsr t
	andi t, 0x03
	rcall PrintSensorValue

	;footer
	call PrintStdFooter

	;selector
	ldzarray sse6*2, 4, Item
	call PrintSelector

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08			;BACK?
	brne sse20

	lds xl, MpuFilter		;save MPU parameters (if modified)
	cp xl, MpuFilterOld
	breq sse13

	ldz eeMpuFilter
	call StoreEePVariable8

sse13:	lds xl, MpuGyroCfg
	cp xl, MpuGyroOld
	breq sse14

	ldz eeMpuGyroCfg
	call StoreEePVariable8

sse14:	lds xl, MpuAccCfg
	cp xl, MpuAccOld
	breq sse15

	ldz eeMpuAccCfg
	call StoreEePVariable8

	clr xl				;ACC sensors must be re-calibrated
	ldz eeSensorsCalibrated
	call StoreEePVariable8

sse15:	call setup_mpu6050		;update the MPU before leaving
	ret

sse20:	cpi t, 0x04			;PREV?
	brne sse25

	dec Item
	brpl sse21

	ldi Item, 2

sse21:	rjmp sse11

sse25:	cpi t, 0x02			;NEXT?
	brne sse30

	inc Item
	cpi Item, 3
	brlt sse21

	clr Item
	rjmp sse11

sse30:	cpi t, 0x01			;CHANGE?
	brne sse21

	tst Item
	brne sse35

	lds t, MpuFilter		;HW filter
	inc t
	andi t, 0x07
	cpi t, 6
	brlt sse31

	clr t

sse31:	sts MpuFilter, t
	rjmp sse11

sse35:	cpi Item, 1
	brne sse40

	lds t, MpuGyroCfg		;gyro
	ldi xl, 8
	add t, xl
	andi t, 0x18
	sts MpuGyroCfg, t
	rjmp sse11

sse40:	lds t, MpuAccCfg		;ACC
	ldi xl, 8
	add t, xl
	andi t, 0x18
	sts MpuAccCfg, t
	rjmp sse11



sse1:	.db "HW Filter (Hz): ", 0, 0
sse2:	.db "Gyro (deg/s)  : ", 0, 0
sse3:	.db "ACC (g)       : ", 0, 0

sse6:	.db 95, 0, 121, 9
	.db 95, 9, 121, 18
	.db 95, 18, 121, 27


lpf:	.dw 256, 188, 98, 42, 20, 10, 5, 0
gyro:	.dw 250, 500, 1000, 2000
acc:	.dw 2, 4, 8, 16



	;--- Print sensor value ---

PrintSensorValue:

	lsl t				;calculate array index
	add zl, t
	clr t
	adc zh, t

	lpm xl, z+			;load array value
	lpm xh, z
	clr yh

	call PrintNumberLF		;print and update cursor position
	lrv X1, 0
	ret



.undef Item
.undef MpuAccOld
.undef MpuGyroOld
.undef MpuFilterOld

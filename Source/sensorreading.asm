


AdcRead:
ReadBatteryVoltage:

	;--- ADC, Pt. 1 ---

	ldi t, 3
	store admux, t				;channel to be read

	;        76543210
	ldi t, 0b11000111
	store adcsra, t				;start ADC


	;--- Read MPU6050 registers while waiting for ADC to complete ---	Suggestion by Steveis. Thanks!

	ldi t, 0x3B				;read MPU6050 from 0x3B
	sts TWI_address, t
	ldi yh, 14				;read 7 words
	ldx MpuBuffer0
	call I2C_readData

	b16loadx MpuBuffer0			;acc X value from MPU is divided by 64 and saved as AccY
	mov yh, xl
	lsl yh
	lsl yh
	b16fdivx 6
	b16store AccY

	b16loadx MpuBuffer2			;acc Y value from MPU is first negated, then divided by 64 and and saved as AccX
	com xh
	neg xl
	sbci xh, 0xFF
	mov yh, xl
	lsl yh
	lsl yh
	b16fdivx 6
	b16store AccX

	b16loadx MpuBuffer4			;acc Z value from MPU is divided by 64 and saved as AccZ
	mov yh, xl
	lsl yh
	lsl yh
	b16fdivx 6
	b16store AccZ

	b16loadx MpuBuffer8			;gyro X value from MPU is divided by 64 and saved as GyroPitch
	mov yh, xl
	lsl yh
	lsl yh
	b16fdivx 6
	b16store GyroPitch

	b16loadx MpuBuffer10			;gyro Y value from MPU is divided by 64 and saved as GyroRoll
	mov yh, xl
	lsl yh
	lsl yh
	b16fdivx 6
	b16store GyroRoll

	b16loadx MpuBuffer12			;gyro Z value from MPU is divided by 64 and saved as GyroYaw
	mov yh, xl
	lsl yh
	lsl yh
	b16fdivx 6
	b16store GyroYaw


	;--- ADC, Pt. 2 ---
	
	load xl, adcl				;X = ADC
	load xh, adch

	lds yh, BatteryVoltageOffset		;add offset
	lds yl, BatteryVoltageOffset + 1
	add xl, yl
	adc xh, yh
	brpl adc20

	clr xh					;negative battery voltages (due to negative offset) will cause LVA problems. Set to zero instead
	clr xl

adc20:	clr yh
	b16store BatteryVoltage
	ret



	;--- Read sensors and adjust sensor values ---

ReadSensors:

	rcall AdcRead

	b16sub GyroRoll, GyroRoll, GyroRollZero
	b16sub GyroPitch, GyroPitch, GyroPitchZero
	b16sub GyroYaw, GyroYaw, GyroYawZero

	b16sub AccX, AccX, AccXZero		;remove offset from Acc
	b16sub AccY, AccY, AccYZero
	b16sub AccZ, AccZ, AccZZero


	;--- Board orientation ---

	lds t, BoardOrientation
	cpi t, 1
	breq bo1

	rjmp bo2

bo1:	b16load GyroRoll			;90 degrees
//	b16neg GyroPitch
	b16nmov GyroRoll, GyroPitch
	b16store GyroPitch

	b16load AccX
//	b16neg AccY
	b16nmov AccX, AccY
	b16store AccY
	ret

bo2:	cpi t, 2
	breq bo3

	rjmp bo4

bo3:	b16neg GyroPitch			;180 degrees
	b16neg GyroRoll
	b16neg AccX
	b16neg AccY
	ret

bo4:	cpi t, 3
	breq bo5

	ret

bo5:	b16load GyroPitch			;270 degrees
//	b16neg GyroRoll
	b16nmov GyroPitch, GyroRoll
	b16store GyroRoll

	b16load AccY
//	b16neg AccX
	b16nmov AccY, AccX
	b16store AccX
	ret



	;--- MPU6050 setup ---

setup_mpu6050:	

	ldi t, 0x6B				
	sts TWI_address, t			;PWR_MGMT_1 -- DEVICE_RESET 1
	ldi t, 0x80
	sts TWI_data, t
	call I2C_writeData

	ldx 50
	call WaitXms

	ldi t, 0x6B				
	sts TWI_address, t			;PWR_MGMT_1 -- SLEEP 0; CYCLE 0; TEMP_DIS 0; CLKSEL 1 (PLL with X Gyro reference)
	ldi t, 0x01
	sts TWI_data, t
	call I2C_writeData

	ldi t, 0x1A				
	sts TWI_address,t			;CONFIG -- EXT_SYNC_SET 0 (disable input pin for data sync) ; default DLPF_CFG = 0 => ACC bandwidth = 260Hz
	ldz eeMpuFilter
	call ReadEepromP
	andi t, 0x07
	sts MpuFilter, t			;save to SRAM for later
	sts TWI_data, t
	call I2C_writeData

	ldi t, 0x1B
	sts TWI_address, t			;GYRO_CONFIG -- Default FS_SEL = 3: Full scale set to 2000 deg/sec
	ldz eeMpuGyroCfg
	call ReadEepromP
	andi t, 0x18
	sts MpuGyroCfg, t			;save to SRAM for later
	sts TWI_data, t
	call I2C_writeData

	ldi t,0x1C
	sts TWI_address,t			;write reg address to sensor ACCEL_CONFIG
	ldz eeMpuAccCfg
	call ReadEepromP
	andi t, 0x18
	sts MpuAccCfg, t			;save to SRAM for later
	sts TWI_data, t
	call I2C_writeData

	ldx 50
	call WaitXms

	ret



	;--- Read setup direct from MPU6050 ---

GetMpu6050Setup:

	ldi t, 0x1A
	sts TWI_address, t
	ldi yh, 3				;read 3 bytes (MpuFilter, MpuGyroCfg and MpuAccCfg)
	ldx MpuFilter
	call I2C_readData
	ret



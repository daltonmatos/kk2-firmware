.def	i	=r17
.def	twidata	=r18


AdcRead:

	ldi		t,0x3B
	sts		TWI_address,t		; Read MPU6050 from 0X3B
	ldi		twidata,14			; Read 14 addresses
	call 	i2c_read_adr_d


ReadBatteryVoltage:

	ldi t, 3
	rcall AdcReadChannel
	b16store BatteryVoltage
	b16add BatteryVoltage, BatteryVoltage, BatteryVoltageOffset
	ret



AdcReadChannel:
	store admux, t		;channel to be read

	;        76543210
	ldi t, 0b11000111
	store adcsra, t		;start ADC

	ldx 2500		;timeout limit (X * 8 cycles)
	
	clr yh

adc2:	sbiw x, 1		;wait until finished or timeout
	brcs adc1
	lds t, adcsra
	sbrc t, adsc
	rjmp adc2
	
	cli
	load xl, adcl		;X = ADC
	load xh, adch
	sei
	ret

adc1:	;log timeout error here


	ret


// i2c_start command==========================

i2c_start:
	ldi		i,2		// try 2times for test TWI communcation
i2c_start2:
	ldi		t, (1<<TWINT) | (1 << TWEN) | (1 << TWSTA)
	store	TWCR, t

    rcall   i2c_wait

	lds	t, TWSR

	andi   	t,0xF8   //Mask TWSR value
   	cpi   	t,0x08   //check if TW_START
    breq   	i2c_start3
   	cpi   	t,0x10   //check if TW_REP_START
    breq  	i2c_start3	
	clc
	ret				//leave if TWI not free

i2c_start3:
   	ldi 	t,0xD0   //device name with write command
   	store  	TWDR, t
 
   	ldi   	t,(1<<TWINT)|(1<<TWEN)
   	store   TWCR,t 
 
	rcall   i2c_wait

	lds		t,TWSR
	andi   	t,0xF8   //Mask
	cpi		t,0x18		//check if slave ack
	breq   	i2c_start_ok
	dec		i
	cpi		i,0
	breq	i2c_start_err    //leave if slave not ack for 2 times
	cpi		t,0x20     //try again if reply with slave not ack 
	breq	i2c_start2

i2c_start_err:	
	clc		// clear carry if error
	ret

i2c_start_ok:
	sec		// set carry if start ok
 	ret

// End i2c_start ==========================


// i2c_read_command =================
i2c_read:
	ldi		i,2		// try 2times for test TWI communcation
i2c_read2:
	ldi		t, (1<<TWINT) | (1 << TWEN) | (1 << TWSTA)
	store	TWCR, t

    rcall   i2c_wait

	lds		t, TWSR

	andi   	t,0xF8   //Mask TWSR value
    cpi   	t,0x08   //check if TW_START
    breq   	i2c_read3 
    cpi   	t,0x10   //check if TW_REP_START
    breq  	i2c_read3	
	clc
	ret				//leave if TWI not free

i2c_read3:
   	ldi 	t,0xD1   //device name with read command

   	store 	TWDR, t
 
   	ldi   	t,(1<<TWINT)|(1<<TWEN)
   	store    TWCR,t 
 
	rcall   i2c_wait

	lds		t,TWSR
	andi   	t,0xF8   	//Mask
	cpi		t,0x40		//check if read slave ack
	breq   	i2c_read_ok
	dec		i
	cpi		i,0
	breq	i2c_read_err    //leave if read slave not ack for 2 times
	cpi		t,0x48     	//try again if reply with read slave not ack 
	breq	i2c_read2

i2c_read_err:	
	clc		// clear carry if error
	ret

i2c_read_ok:
	sec		// set carry if start ok
	ret
// End i2c_read_command =================


// Send read with start command ================
i2c_read_adr:
	call	i2c_start
	brcs	i2c_read_adr2
	ret
	 
i2c_read_adr2:
	lds		t, TWI_address
	call	i2c_write_address
	brcs	go_read
	ret

go_read:
 	call	i2c_read
	brcs	go_load_data
	ret
    
go_load_data:
	ldi		i,2
	call	i2c_get_data
	brcc	no_data			
	lds		t,TWDR
	sec
	ret

no_data:
	clc
	ret
// End Send read with start command ================


// i2c_get_data_command =================
i2c_get_data:
	ldi   	t,(1<<TWINT)|(1<<TWEN)   // last data for read
   	
i2c_get_data2:	
	store   TWCR,t 
	rcall   i2c_wait

	lds		t,TWSR
	andi   	t,0xF8   //Mask
 	cpi   	t,0x50   // check if start
    breq   	i2c_data_ok
    cpi   	t,0x58   // check if restart
    breq  	i2c_data_ok
 	clc
	cpi		i,0
	brne	i2c_get_data
	ret

i2c_data_ok:
	call	i2c_stop
	sec
	ret
// End i2c_get_data_command =================


// i2c_write_address =================
i2c_write_address:
	store  	TWDR, t

	ldi   	t,(1<<TWINT)|(1<<TWEN)
   	store   TWCR,t 
 
	rcall   i2c_wait

	lds		t, TWSR
	andi   	t,0xF8   //Mask
	cpi		t,0x28	 //check if data ack
	breq   	i2c_write_address_ok
	clc		//false if data not ack
	ret

i2c_write_address_ok:
	sec
	ret
// End i2c_write_address =================


//Send_start ================
;**************************** 
;func: .cs = I2C_Start(void) // .cs if free 
;**************************** 
//I2C_Start: 
i2c_read_adr_d:
	call	i2c_start
	brcs	i2c_read_adr2_d
	ret
	 
i2c_read_adr2_d:
	lds		t, TWI_address
	call	i2c_write_address
	brcs	go_read_d
	ret

go_read_d:
 	call	i2c_read
	brcs	go_load_data_d
	ret
  
go_load_data_d:
	ldi		i,2
	rcall	i2c_get_data_d
	brcc	no_data_d			
	sec
	ret

no_data_d:
	clc
	ret
//Send_start ================


//i2c_get_data_command =================
i2c_get_data_d:
	dec		twidata
	cpi		twidata,0
	breq	last_data_d

	ldi   	t,(1<<TWINT)|(1<<TWEN)|(1<<TWEA)
	rjmp	i2c_get_data2_d

last_data_d:
	ldi   	t,(1<<TWINT)|(1<<TWEN)

   	
i2c_get_data2_d:	
	store   TWCR,t 
	call   i2c_wait

	lds		t,TWSR
	andi   	t,0xF8   //Mask
 	cpi   	t,0x50   // check if start
    breq   	I2C_data_ok_d
    cpi   	t,0x58   // check if restart
    breq  	I2C_data_ok_d
 	clc
	ret

I2C_data_ok_d:	

	clr		yh					; cleared for 16.8 register stores below

	cpi		twidata,13			; ACCY_H
	brne	data2
	load	xh,twdr				; data1 save
	rjmp	check_last

data2:
	cpi		twidata,12			; ACCY_L
	brne	data3a
	rjmp	data2_1
data3a:
	jmp		data3
data2_1:
	load	xl,twdr				; data2 save
	b16store AccY
	b16fdiv AccY,6				; shift 6 bits
	clr		yh
	ldx		512
	b16store	Temp2			; Used to offset values (this is half way between 0 and 1023)
	b16add	AccY,AccY,Temp2		; Offset by 512 (0g when steady)
	rjmp	check_last

data3:
	cpi		twidata,11			; ACCX_H
	brne	data4
	load	xh,twdr				; data3 save
	rjmp	check_last

data4:
	cpi		twidata,10			; ACCX_L
	brne	data5a
	rjmp	data4_1
data5a:
	jmp		data5
data4_1:
	load	xl,twdr				; data4 save
	b16store AccX
	b16neg	AccX		
	b16fdiv AccX,6				; shift 6 bits
	b16add	AccX,AccX,Temp2		; Offset by 512 (0g when steady)
	rjmp	check_last

data5:
	cpi		twidata,9			; ACCZ_H
	brne	data6
	load	xh,twdr				; data5 save
	rjmp	check_last

data6:
	cpi		twidata,8			; ACCZ_L
	brne	data7
	load	xl,twdr				; data6 save
	b16store AccZ
	b16fdiv AccZ,6				; shift 6 bits
	b16add	AccZ,AccZ,Temp2		; Offset by 512 (1g when steady)
	rjmp	check_last

data7:
	cpi		twidata,7			; Temp_H
	brne	data8
	load	xh,twdr				; data7 save
	rjmp	check_last

data8:
	cpi		twidata,6			; Temp_L
	brne	data9	
	load	xl,twdr				; data8 save
	b16store MpuTemperature
	rjmp	check_last

data9:
	cpi		twidata,5			; GyroPitch_H
	brne	data10
	load	xh,twdr				; data9 save
	rjmp	check_last

data10:
	cpi		twidata,4			; GyroPitch_L
	brne	data11
	load	xl,twdr				; data10 save
	b16store GyroPitch
	b16fdiv GyroPitch,6			; shift 6 bits
	b16add	GyroPitch,GyroPitch,Temp2 ; Offset by 512
	rjmp	check_last

data11:
	cpi		twidata,3			; GyroRoll_H
	brne	data12
	load	xh,twdr				; data11 save
	rjmp	check_last

data12:
	cpi		twidata,2			; GyroRoll_L
	brne	data13
	load	xl,twdr				; data12 save
	b16store GyroRoll
	b16fdiv GyroRoll,6			; shift 6 bits
	b16add	GyroRoll,GyroRoll,Temp2 ; Offset by 512
	rjmp	check_last

data13:
	cpi		twidata,1			; GyroYaw_H
	brne	data14
	load	xh,twdr				; data13 save
	rjmp	check_last

data14:							; Must be ; GyroYaw_L
	load	xl,twdr				; data14 save
	b16store GyroYaw
	b16fdiv GyroYaw,6			; shift 6 bits
	b16add	GyroYaw,GyroYaw,Temp2 ; Offset by 512

check_last:
	cpi		twidata,0
	breq	i2c_get_data_d_ok
	rjmp	i2c_get_data_d
	
i2c_get_data_d_ok:
	call	i2c_stop
	sec
	ret
//i2c_get_data_command =================


// Send data =====================
i2c_send_adr:
	rcall	i2c_start
	brcs	i2c_send_adr2
	ret
	 
i2c_send_adr2:
	lds		t,TWI_address		// write Address
	rcall	i2c_write_address
	brcs	go_write
	ret

go_write:
	mov 	t,twidata		// write data
   	rcall	i2c_write_address
	brcc	fail_write
	call	i2c_stop
	sec
	ret

fail_write:
	clc
	ret

// Send data =====================



// Wait_TWI_int ==============

i2c_wait: 
   lds   	t,TWCR   
   sbrs   	t,TWINT 
   rjmp   	i2c_wait 
   ret 

// Wait_TWI_int ==============

// Send_stop =================

i2c_stop:  
   ldi   	t,(1<<TWINT)|(1<<TWEN)|(1<<TWSTO) 
   store   	TWCR,t 
   ret 

// End Send_stop =================




setup_mpu6050:	

	ldi t, 0x6B				
	sts TWI_address, t		// PWR_MGMT_1    -- DEVICE_RESET 1
	ldi twidata, 0x80
	call i2c_send_adr
	ldx 50
	call WaitXms

	ldi t, 0x6B				
	sts TWI_address, t		// PWR_MGMT_1    -- SLEEP 0; CYCLE 0; TEMP_DIS 0; CLKSEL 1 (PLL with X Gyro reference)
	ldi twidata, 0x01
	call i2c_send_adr

	ldi t, 0x1A				
	sts TWI_address,t		// CONFIG        -- EXT_SYNC_SET 0 (disable input pin for data sync) ; default DLPF_CFG = 0 => ACC bandwidth = 260Hz
	ldz eeMpuFilter
	call ReadEepromP
	andi t, 0x07
	sts MpuFilter, t		// save to SRAM for later
	mov twidata, t
	call i2c_send_adr

	ldi t, 0x1B
	sts TWI_address, t		// GYRO_CONFIG   -- Default FS_SEL = 3: Full scale set to 2000 deg/sec
	ldz eeMpuGyroCfg
	call ReadEepromP
	andi t, 0x18
	sts MpuGyroCfg, t		// save to SRAM for later
	mov twidata, t
	call i2c_send_adr

	ldi t,0x1C
	sts TWI_address,t		// write reg address ro sensor  ACCEL_CONFIG
	ldz eeMpuAccCfg
	call ReadEepromP
	andi t, 0x18
	sts MpuAccCfg, t		// save to SRAM for later
	mov twidata, t
	call i2c_send_adr

	ldx 50
	call WaitXms

	ret



	;--- Read setup direct from MPU6050 ---
/*
GetMpu6050Setup:

	ldi t, 0x1A
	sts TWI_address, t
	call i2c_read_adr
	sts MpuFilter, t

	ldi t, 0x1B
	sts TWI_address, t
	call i2c_read_adr
	sts MpuGyroCfg, t

	ldi t, 0x1C
	sts TWI_address, t
	call i2c_read_adr
	sts MpuAccCfg, t

	ret
*/

.undef	i	
.undef	twidata	

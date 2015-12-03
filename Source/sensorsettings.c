#include <avr/io.h>
#include <avr/pgmspace.h>

#include "ramvariables.h"
#include "constants.h"
#include "eepromvariables.h"
#include "io.h"
#include "display/st7565.h"

extern const char sse1;
extern const char sse2;
extern const char sse3;

/* ranslation tables */
extern const char lpf; 
extern const char gyro; 
extern const char acc; 

extern const char updown;

extern uint8_t asm_get_mpu_register(uint8_t r);

void _sns_render(uint8_t selected, uint8_t lpf_cfg, uint8_t gyro_cfg, uint8_t acc_cfg){

  lcd_clear();

  print_string(&sse1, 0, 1);
  print_number_2(pgm_read_word(&lpf + (lpf_cfg * 2)), 100, 1, selected == 0 ? HIGHLIGHT_STRING : HIGHLIGHT_NONE);

  print_string(&sse2, 0, 10);
  print_number_2(pgm_read_word(&gyro + (gyro_cfg * 2)), 100, 10, selected == 1 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);

  print_string(&sse3, 0, 19);
  print_number_2(pgm_read_word(&acc + (acc_cfg * 2)), 100, 19, selected == 2 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);

  /* Debug values. Read directly from MPU6050 */
  /*
  print_number(asm_get_mpu_register(0x1A), 0, 40);
  print_number(asm_get_mpu_register(0x1B) >> 3, 40, 40);
  print_number(asm_get_mpu_register(0x1C) >> 3, 80, 40);
  */

  print_string(&updown, 0, 57); /* Footer */
}

/*
 * According to the Register map datasheet this are the 3 registers that controls these settings
 * Reg 26 (0x1A) Low Pass Filter. 3 least significat bits: ---[bit5:bit3][bit2:bit0]
 * Reg 27 (0x1B) Gyro Config. Bits 4 and 3. ---[bit4:bit3]--- : 0=250dg/s, 1=500deg/s, 2=1000deg/s, 3=2000deg/s
 * Reg 28 (0x1C) Accel Config. Bits 4 and 3. ---[bit4:bit3]---: 0=+-2g, 1=+-4g, 2=+-8g, 3=+-16g
 *
 * That's why we need to shitf (>> 3) Gyro and Accel Configs. We always save the fullregister value (1 byte). 
 * Low Pass Filter does not need shifting because the bits we need to set are already the least significant ones.
 * 
 */

void sensor_settings(){

  int8_t selected_item = 0;
  uint8_t pressed = 0;
  uint8_t lpf_cfg = 0;
  uint8_t gyro_cfg = 0;
  uint8_t acc_cfg = 0;

  /* See explanation for the shift (>> 3) above */
  lpf_cfg = MpuFilter;
  gyro_cfg = MpuGyroCfg >> 3;
  acc_cfg = MpuAccCfg >> 3;

  _sns_render(selected_item, lpf_cfg, gyro_cfg, acc_cfg);
  lcd_update();

  while ((pressed = wait_for_button(BUTTON_ANY)) != BUTTON_BACK){
 
    switch (pressed) {
      case BUTTON_UP:
        selected_item--;
        break;   
      case BUTTON_DOWN:
        selected_item++;
        break;
      case BUTTON_OK:
        selected_item = constrain(selected_item, 0, 2);
        lpf_cfg = selected_item == 0 ? lpf_cfg+1 : lpf_cfg;
        gyro_cfg = selected_item == 1 ? gyro_cfg+1 : gyro_cfg;
        acc_cfg = selected_item == 2 ? acc_cfg+1 : acc_cfg;
        break;
    }
    
    selected_item = constrain(selected_item, 0, 2);
    lpf_cfg = constrain(lpf_cfg, 0, 6);
    gyro_cfg &= 0x3;
    acc_cfg &= 0x3;

    _sns_render(selected_item, lpf_cfg, gyro_cfg, acc_cfg);
    lcd_update(); 
  }

  MpuFilter = lpf_cfg;
  MpuGyroCfg = gyro_cfg << 3;
  MpuAccCfg = acc_cfg << 3;

  MpuGyroCfg &= _BV(4) | _BV(3);
  MpuAccCfg &= _BV(4) | _BV(3);

  eepromP_update_byte(eeMpuFilter, MpuFilter);
  eepromP_update_byte(eeMpuGyroCfg, MpuGyroCfg);
  eepromP_update_byte(eeMpuAccCfg, MpuAccCfg);

  eepromP_update_byte(eeSensorsCalibrated, FLAG_OFF); /* Force sensors reclaibration */

  asm_setup_mpu6050();
}

//sse11:	call LcdClear6x8
//
//	ldz sse1*2			;HW filter
//	call PrintString
//	ldz lpf*2
//	lds t, MpuFilter
//	andi t, 0x07
//	rcall PrintSensorValue
//
//	ldz sse2*2			;gyro
//	call PrintString
//	ldz gyro*2
//	lds t, MpuGyroCfg
//	lsr t
//	lsr t
//	lsr t
//	andi t, 0x03
//	rcall PrintSensorValue
//
//	ldz sse3*2			;ACC
//	call PrintString
//	ldz acc*2
//	lds t, MpuAccCfg
//	lsr t
//	lsr t
//	lsr t
//	andi t, 0x03
//	rcall PrintSensorValue
//
//	;footer
//	call PrintStdFooter
//
//	;selector
//	ldzarray sse6*2, 4, Item
//	call PrintSelector
//
//	call LcdUpdate
//
//	call GetButtonsBlocking
//
//	cpi t, 0x08			;BACK?
//	brne sse20
//
//	lds xl, MpuFilter		;save MPU parameters (if modified)
//	cp xl, MpuFilterOld
//	breq sse13
//
//	ldz eeMpuFilter
//	call StoreEePVariable8
//
//sse13:	lds xl, MpuGyroCfg
//	cp xl, MpuGyroOld
//	breq sse14
//
//	ldz eeMpuGyroCfg
//	call StoreEePVariable8
//
//sse14:	lds xl, MpuAccCfg
//	cp xl, MpuAccOld
//	breq sse15
//
//	ldz eeMpuAccCfg
//	call StoreEePVariable8
//
//	clr xl				;ACC sensors must be re-calibrated
//	ldz eeSensorsCalibrated
//	call StoreEePVariable8
//
//sse15:	call setup_mpu6050		;update the MPU before leaving
//	ret
//
//sse20:	cpi t, 0x04			;PREV?
//	brne sse25
//
//	dec Item
//	brpl sse21
//
//	ldi Item, 2
//
//sse21:	rjmp sse11
//
//sse25:	cpi t, 0x02			;NEXT?
//	brne sse30
//
//	inc Item
//	cpi Item, 3
//	brlt sse21
//
//	clr Item
//	rjmp sse11
//
//sse30:	cpi t, 0x01			;CHANGE?
//	brne sse21
//
//	tst Item
//	brne sse35
//
//	lds t, MpuFilter		;HW filter
//	inc t
//	andi t, 0x07
//	cpi t, 6
//	brlt sse31
//
//	clr t
//
//sse31:	sts MpuFilter, t
//	rjmp sse11
//
//sse35:	cpi Item, 1
//	brne sse40
//
//	lds t, MpuGyroCfg		;gyro
//	ldi xl, 8
//	add t, xl
//	andi t, 0x18
//	sts MpuGyroCfg, t
//	rjmp sse11
//
//sse40:	lds t, MpuAccCfg		;ACC
//	ldi xl, 8
//	add t, xl
//	andi t, 0x18
//	sts MpuAccCfg, t
//	rjmp sse11
//
//
//
//sse1:	.db "HW Filter (Hz): ", 0, 0
//sse2:	.db "Gyro (deg/s)  : ", 0, 0
//sse3:	.db "ACC (g)       : ", 0, 0
//
//sse6:	.db 95, 0, 121, 9
//	.db 95, 9, 121, 18
//	.db 95, 18, 121, 27
//
//
//lpf:	.dw 256, 188, 98, 42, 20, 10, 5, 0
//gyro:	.dw 250, 500, 1000, 2000
//acc:	.dw 2, 4, 8, 16
//
// 0000 0000 + 8 = 0000 1000 
// 0000 1000     = 0001 0000
// 0001 0000     = 0001 1000
// 0001 1000     = 0010 0000
//
//	;--- Print sensor value ---
//
//PrintSensorValue:
//
//	lsl t				;calculate array index
//	add zl, t
//	clr t
//	adc zh, t
//
//	lpm xl, z+			;load array value
//	lpm xh, z
//	clr yh
//
//	call PrintNumberLF		;print and update cursor position
//	lrv X1, 0
//	ret
//
//
//
//.undef Item
//.undef MpuAccOld
//.undef MpuGyroOld
//.undef MpuFilterOld

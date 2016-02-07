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
  print_number_2(pgm_read_byte(&lpf + (lpf_cfg)) + 1, 100, 1, selected == 0 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);

  print_string(&sse2, 0, 10);
  print_number_2(pgm_read_word(&gyro + (gyro_cfg * 2)), 100, 10, selected == 1 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);

  print_string(&sse3, 0, 19);
  print_number_2(pgm_read_byte(&acc + (acc_cfg)), 100, 19, selected == 2 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);

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


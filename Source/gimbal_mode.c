#include <avr/io.h>
#include <avr/eeprom.h>

#include "constants.h"
#include "ramvariables.h"
#include "eepromvariables.h"
#include "io.h"
#include "display/st7565.h"

#define BUTTON_NO BUTTON_DOWN
#define BUTTON_YES BUTTON_UP

extern const char gbm1;
extern const char gbm2;
extern const char gbm3;
extern const char gbm4;
extern const char _yesno;

void gimbal_mode(){

  uint8_t current_setting = 0;
  uint8_t pressed = 0;
  uint8_t go_gimbal = 0;


  current_setting = eeprom_read_byte(uint8_t_prt(eeGimbalMode));

  lcd_clear12x16();
  print_string(&gbm1, 28, 0);

  Y1 = 17;
  FontSelector = f6x8;

  print_string(&gbm2, 0, Y1);
  print_string(&gbm3, 0, Y1+9);
  print_string(&gbm4, 0, Y1+9);

  print_string(&_yesno, 42, 57);

  lcd_update();
  pressed = wait_for_button(BUTTON_YES | BUTTON_NO);


  if (pressed == BUTTON_YES){
    go_gimbal = 0xFF;
  }

  eeprom_update_byte(uint8_t_prt(eeGimbalMode), go_gimbal);

  if (go_gimbal != current_setting){
    asm_EnforceRestart();  
  }

}
//	;--- Get gimbal controller mode from EEPROM ---
//
//GetGimbalControllerMode:
//
//	ldz eeGimbalMode
//	call ReadEeprom			;read from profile #1 only
//	sts flagGimbalMode, t
//	ret
//
//
//
//	;--- Reset gimbal controller mode ---
//
//ResetGimbalControllerMode:
//
//	clr t
//	ldz eeGimbalMode
//	call WriteEeprom		;save in profile #1 only
//	ret
//
//
//
//.undef OldSetting
//

#include <avr/eeprom.h>
#include <util/delay.h>
#include "flashvariables.h"
#include "ramvariables.h"
#include "eepromvariables.h"
#include "io.h"
#include "constants.h"
#include "display/st7565.h"


extern const char con1;
extern const char con2;
extern const char con6;

void _ctr_render(){

    lcd_clear();
    FontSelector = f12x16;
    print_string(&con1, 46, 0); /* LCD */

    FontSelector = f6x8;
    print_string(&con2, 0, 26); /* LCD Contrast: */

    print_string(&con6, 0, 57); /* Footer */

    print_number(LcdContrast, 14*16, 26);
}

void c_contrast(){

  uint8_t pressed = 0;

  if (UserProfile){
    asm_ShowNoAccessDlg(&nadtxt2);
    wait_for_button(BUTTON_OK);
    return;
  }

  _ctr_render();
  lcd_update();
  while ((pressed = wait_for_button(BUTTON_ANY)) != BUTTON_BACK) {

    switch (pressed){
      case BUTTON_UP:
        LcdContrast = (LcdContrast + 1) > 46 ? 46 : LcdContrast + 1;
        break;
      case BUTTON_DOWN:
        LcdContrast = (LcdContrast - 1) < 25 ? 25 : LcdContrast - 1;
        break;
      case BUTTON_OK:
        eeprom_write_byte(eeLcdContrast, LcdContrast);
        return;
        break;
    }
    _ctr_render();
    lcd_update();
  }

  LcdContrast = eeprom_read_byte(eeLcdContrast);

  return;
}

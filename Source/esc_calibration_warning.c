#include <avr/io.h>
#include <avr/eeprom.h>

#include "ramvariables.h"
#include "display/st7565.h"
#include "io.h"
#include "eepromvariables.h"
#include "constants.h"


extern const char warning;
extern const char war2;
extern const char war3;
extern const char war4;
extern const char war5;

extern const char war9;

void esc_calibration_warning(){

  uint8_t pressed = 0; 
  pressed = show_confirmation_dlg(&war9);


  if (pressed == BUTTON_OK){
    lcd_clear12x16();
    print_string(&warning, 16, 0);
    Y1 = 17;
    FontSelector = f6x8;
    print_string(&war2, 0, Y1);
    print_string(&war3, 0, Y1+9);
    print_string(&war4, 0, Y1+9);
    print_string(&war5, 0, Y1+9);
    lcd_update();
    eeprom_write_byte(uint8_t_prt(eeEscCalibration), 1);
    while (1) {}
  }
}

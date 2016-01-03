#include <avr/io.h>
#include <avr/pgmspace.h>

#include "display/st7565.h"
#include "io.h"
#include "eepromvariables.h"
#include "ramvariables.h"
#include "constants.h"
#include "fonts.h"

extern const char mode_settings_tittle;
void main(){

  setup_display();
  lcd_load_contrast();

  PixelType = 1;
  FontSelector = f6x8;
  print_title(&mode_settings_tittle);

  lcd_update();
  wait_for_button(BUTTON_ANY);
  
  while (1){}

}

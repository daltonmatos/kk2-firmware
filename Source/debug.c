#include <avr/io.h>
#include <avr/pgmspace.h>

#include "display/st7565.h"
#include "io.h"
#include "eepromvariables.h"
#include "ramvariables.h"
#include "constants.h"
#include "fonts.h"
#include "logo.h"
#include "b168.h"


void main(){

  setup_display();
  lcd_load_contrast();
  PixelType = 1;
  FontSelector = f6x8;

  StickDeadZone->hi = 0;
  StickDeadZone->lo = 0x20;
  StickDeadZone->decimal = ENCODE_TO_8BIT_PRECISION(0);

  X1 = 0; Y1 = 0;
  print_b168(StickDeadZone, 3);

  X1 = 0; Y1 = 10;
  b168_const_add(StickDeadZone, -32);
  print_b168(StickDeadZone, 3);

  lcd_update();
  wait_for_button(BUTTON_ANY);
  
  while (1){}

}

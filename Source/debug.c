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

extern void load_temp();

void main(){

  setup_display();
  lcd_load_contrast();
  PixelType = 1;
  FontSelector = f6x8;

  b168_load(Temp, 10.1);
  b168fadd(Temp, -11);
  b168_print(Temp, 3, 0, 10);

  lcd_update();
  while (1){}

}

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

  load_temp();
  //b168_print(Temp, 3, 0, 0);
  print_bits16(b168_pack(Temp), 0, 0);

  b168_load(Temp2, -12.77);
  //b168_print(Temp2, 3, 0, 10);
  print_bits16(b168_pack(Temp2), 0, 10);

  b168_mul(StickDeadZone, Temp, Temp2);

  b168_print(StickDeadZone, 3, 0, 30);
  lcd_update();
  while (1){}

}

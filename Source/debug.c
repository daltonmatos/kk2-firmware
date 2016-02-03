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

void setup_buttons(){
  DDRB = 0x0A;
  PORTB = 0xF5;
}

void main(){

  setup_display();
  lcd_load_contrast();
  PixelType = 1;
  FontSelector = f6x8;
  setup_buttons();

  /* Code to be debugged here */

  lcd_clear();
  lcd_update();
  while (1){}

}

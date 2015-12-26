#include <avr/io.h>
#include <avr/pgmspace.h>

#include "display/st7565.h"
#include "io.h"
#include "eepromvariables.h"
#include "ramvariables.h"
#include "constants.h"

void main(){

  setup_display();
  lcd_load_contrast();

  lcd_update();
  
  while (1){}

}

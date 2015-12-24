#include <avr/io.h>
#include <avr/pgmspace.h>

#include "display/st7565.h"
#include "io.h"

void main(){

  setup_display();
  lcd_load_contrast();

  print_number(eepromP_read_byte(eeChannelRoll), 20, 40);
  print_number(eepromP_read_byte(eeChannelThrottle), 30, 40);

  lcd_update();
  
  while (1){}

}

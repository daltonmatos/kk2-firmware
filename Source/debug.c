#include <avr/io.h>
#include <avr/pgmspace.h>

#include "display/st7565.h"
#include "io.h"
#include "eepromvariables.h"
#include "ramvariables.h"
#include "constants.h"
#include "fonts.h"
#include "logo.h"

extern const char ver2;

void main(){

  setup_display();
  lcd_load_contrast();

  PixelType = 1;
  _sprite(image_data_Font_k, 16, 0, 41, 10, 20);
  _sprite(image_data_Font_k, 16, 0, 41, 25, 20);  
  _sprite(image_data_Font_2, 16, 0, 28, 45, 25);

  _sprite(image_data_Font_n, 16, 0, 29, 65, 25);
  _sprite(image_data_Font_g, 16, 0, 52, 80, 20);

  lcd_update();
  wait_for_button(BUTTON_ANY);
  
  while (1){}

}

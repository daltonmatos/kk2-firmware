#include <avr/io.h>

#include "display/st7565.h"
#include "io.h"

void main(){

  setup_display();
  lcd_load_contrast();

  setpixel(LCD_BUFFER_ptr, 10, 10, 1);
  lcd_update();
  
  while (1){}

}

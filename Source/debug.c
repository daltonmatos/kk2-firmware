#include <avr/io.h>
#include <avr/pgmspace.h>

#include "display/st7565.h"
#include "io.h"


void main(){

  setup_display();
  lcd_load_contrast();

  PixelType = 1;
  __setpixel(10, 8);
  __setpixel(11, 8);
  __setpixel(12, 8);
  __setpixel(13, 8);
  __setpixel(14, 8);

  lcd_update();
  
  while (1){}

}

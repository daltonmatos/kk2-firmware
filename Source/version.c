
#include <avr/io.h>
#include <util/delay.h>
#include <avr/pgmspace.h>
#include "ramvariables.h"
#include "flashvariables.h"
#include "display/st7565.h"
#include "constants.h"
#include "io.h"


void show_version(){

  PixelType = 1;
  FontSelector = f12x16;
  print_string(&ver1, 22, 0);

  FontSelector = f6x8;
  print_string(&ver2, 0, 19);
  print_string(&srm2, 0, 30);
  print_string(&motto, 0, 46);

  print_string((uint8_t *) pgm_read_word(&modes + RxMode*2), 36, 30);
  
  print_string(&back, 0, 57);

  asm_LcdUpdate();

  while (asm_GetButtonsBlocking() != BUTTON_BACK){}
}


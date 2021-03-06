
#include <avr/io.h>
#include <util/delay.h>
#include <avr/pgmspace.h>
#include "ramvariables.h"
#include "flashvariables.h"
#include "display/st7565.h"
#include "constants.h"
#include "io.h"

extern const char  ver1;
extern const char  ver2;
extern const char  ver10;

void show_version(){

  print_title(&ver1);

  print_string(&ver2, 0, 19);
  print_string(&srm2, 0, 30);
  print_string(&motto, 0, 46);

  print_string((char *) pgm_read_word(&modes + RxMode*2), 36, 30);
  
  print_string(&back, 0, 57);

  lcd_update();

  wait_for_button(BUTTON_BACK);
}


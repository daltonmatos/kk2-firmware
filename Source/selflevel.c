#include <avr/eeprom.h>

#include "display/st7565.h"
#include "ramvariables.h"
#include "constants.h"
#include "io.h"
#include "eepromvariables.h"

extern const char pgain;
extern const char plimit;
extern const char sqz3;
extern const char sqz4;
extern const char sqz5;

extern const char nxtchng;
extern const char bckprev;

extern const char colon_and_space;


void _sl_render(uint8_t selected_item){

  lcd_clear();
  FontSelector = f6x8;

  print_string(&pgain, 0, 0);
  print_string(&plimit, 0, 9);
  print_string(&sqz3, 0, 18);
  print_string(&sqz4, 0, 27);
  print_string(&sqz5, 0, 36);

  print_string(&colon_and_space, 84, 1);
  print_string(&colon_and_space, 84, 10);
  print_string(&colon_and_space, 84, 19);
  print_string(&colon_and_space, 84, 28);
  print_string(&colon_and_space, 84, 37);

  print_number_2(eepromP_read_word(eeSelflevelPgain), 94, 1, selected_item == 0 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
  print_number_2(eepromP_read_word(eeSelflevelPlimit), 94, 10, selected_item == 1 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
  print_number_2(eepromP_read_word(eeAccTrimRoll), 94, 19, selected_item == 2 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
  print_number_2(eepromP_read_word(eeAccTrimPitch), 94, 28, selected_item == 3 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
  print_number_2(eepromP_read_word(eeSlMixRate), 94, 37, selected_item == 4 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);

  print_string(&bckprev, 0, 57);
  print_string(&nxtchng, 55, 57);
}


void selflevel_settings(){

  int8_t pressed = 0;
  uint8_t selected_item = 0;

  _sl_render(selected_item);
  lcd_update();

  while ((pressed = wait_for_button(BUTTON_ANY)) != BUTTON_BACK){

    switch (pressed){
      case BUTTON_DOWN:
        selected_item++;
        break;
      case BUTTON_UP:
        selected_item--;
        break;
    }

    selected_item = constrain(selected_item, 0, 4);
    _sl_render(selected_item);
    lcd_update();

  }

}

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
extern const char selflevel_title;

extern const char nxtchng;
extern const char bckprev;

extern const char colon_and_space;


void _sl_render(uint8_t selected_item){

  print_string(&pgain, 0, 11);
  print_string(&plimit, 0, 20);
  print_string(&sqz3, 0, 29);
  print_string(&sqz4, 0, 38);
  print_string(&sqz5, 0, 47);

  print_string(&colon_and_space, 84, 11);
  print_string(&colon_and_space, 84, 20);
  print_string(&colon_and_space, 84, 29);
  print_string(&colon_and_space, 84, 38);
  print_string(&colon_and_space, 84, 47);

  print_number_2(eepromP_read_word(eeSelflevelPgain), 94, 11, selected_item == 0 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
  print_number_2(eepromP_read_word(eeSelflevelPlimit), 94, 20, selected_item == 1 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
  print_number_2(eepromP_read_word(eeAccTrimRoll), 94, 29, selected_item == 2 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
  print_number_2(eepromP_read_word(eeAccTrimPitch), 94, 38, selected_item == 3 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
  print_number_2(eepromP_read_word(eeSlMixRate), 94, 47, selected_item == 4 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);

}

void _sl_ok_callback(uint8_t selected_item){

    int16_t min;
    int16_t max;
    switch (selected_item){
      case 0:
      case 1:
        min = 0; max = 900;
        break;
      case 2:
      case 3:
        min = -900; max = 900;
        break;
      case 4:
        min = 5; max = 50;
        break;
    }


    eepromP_update_word(uint16_t_ptr(((int16_t) eeSelflevelPgain + selected_item*2)), 
                        num_edit((int16_t) eepromP_read_word(uint16_t_ptr((int16_t) eeSelflevelPgain + selected_item*2)), min, max));

}

void selflevel_settings(){

  ScreenData->title = &selflevel_title;
  ScreenData->footer_callback = &print_std_footer;
  ScreenData->initial_option = 0;
  ScreenData->ok_callback = &_sl_ok_callback;
  ScreenData->render_callback = &_sl_render;
  ScreenData->total_options = 5;

  render_screen(ScreenData);

}

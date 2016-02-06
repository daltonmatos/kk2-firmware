#include <avr/io.h>

#include "menu.h"
#include "io.h"
#include "eepromvariables.h"
#include "ramvariables.h"

#define DG2_STAY_ARMED_BIT 0
#define DG2_DIGITAL_OUTPUT_BIT 1

extern const char colon_and_space;
extern const char dg2_settings_title;
extern const char dgs1;
extern const char dgs2;

extern const char yes;
extern const char no;

void _sbus_render(uint8_t selected_item){

  uint8_t dg2functions = eepromP_read_byte(eeDG2Functions);
  print_string(&dgs1, 0, 11);
  print_string(&dgs2, 0, 20);
  
  print_string_2(dg2functions & _BV(DG2_STAY_ARMED_BIT) ? &yes : &no, 102, 11, selected_item == 0 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
  print_string_2(dg2functions & _BV(DG2_DIGITAL_OUTPUT_BIT) ? &yes : &no, 102, 20, selected_item == 1 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
}


void _sbus_ok_callback(uint8_t selected_item){

  uint8_t dg2functions = eepromP_read_byte(eeDG2Functions);

  switch(selected_item){
    case 0:
      dg2functions ^= _BV(DG2_STAY_ARMED_BIT);
      break;
    case 1:
      dg2functions ^= _BV(DG2_DIGITAL_OUTPUT_BIT);
      break;
  }

  eepromP_update_byte(eeDG2Functions, dg2functions);
}

void sbus_dg2settings(){

  MenuData->title = &dg2_settings_title;
  MenuData->footer_callback = &print_std_footer;
  MenuData->options = 0;
  MenuData->ok_callback = &_sbus_ok_callback;
  MenuData->render_callback = &_sbus_render;
  MenuData->total_options = 2;
  MenuData->initial_option = 0;

  render_menu(MenuData);

}

#include <avr/io.h>

#include "display/st7565.h"
#include "constants.h"
#include "io.h"
#include "ramvariables.h"
#include "eepromvariables.h"
#include "menu.h"

extern const char ss_title;
extern const char percent;
extern const char ail;
extern const char ele;
extern const char rudd;
extern const char thr;
extern const char slmix;


extern const char colon_and_space;
extern const char backprev;
extern const char nxtchng;

void _ss_render(uint8_t selected_item){

  print_string(&ail, 0, 11);
  print_string(&ele, 0, 20);
  print_string(&rudd, 0, 29);
  print_string(&thr, 0, 38);
  print_string(&slmix, 0, 47);

  /* labels */
  print_string(&colon_and_space, 54, 11);
  print_string(&colon_and_space, 54, 20);
  print_string(&colon_and_space, 54, 29);
  print_string(&colon_and_space, 54, 38);
  print_string(&colon_and_space, 54, 47);

  /* values */
  print_number_2(eepromP_read_word(eeStickScaleRoll), 67, 11, selected_item == 0 ? 35 : HIGHLIGHT_NONE);
  print_number_2(eepromP_read_word(eeStickScalePitch), 67, 20, selected_item == 1 ? 35 : HIGHLIGHT_NONE);
  print_number_2(eepromP_read_word(eeStickScaleYaw), 67, 29, selected_item == 2 ? 35 : HIGHLIGHT_NONE);
  print_number_2(eepromP_read_word(eeStickScaleThrottle), 67, 38, selected_item == 3 ? 35 : HIGHLIGHT_NONE);
  uint8_t _x = print_number_2(eepromP_read_word(eeStickScaleSlMixing), 67, 47, selected_item == 4 ? 35 : HIGHLIGHT_NONE);
  X1 = 67 + (6*_x);  Y1 = 47; PixelType = 0;
  print_char('%');

  
}

void _ss_ok_callback(uint8_t selected_item){
      eepromP_update_word(uint16_t_ptr(((int16_t) eeStickScaleRoll + selected_item*2)), 
                          asm_NumEdit(eepromP_read_word(uint16_t_ptr((int16_t) eeStickScaleRoll + selected_item*2)), 0, 500));
}

void stick_scaling(){

  ScreenData->title = &ss_title;
  ScreenData->footer = 0;
  ScreenData->footer_callback = &print_std_footer;
  ScreenData->options = 0;
  ScreenData->initial_option = 0;
  ScreenData->ok_callback = &_ss_ok_callback;
  ScreenData->render_callback = &_ss_render;
  ScreenData->total_options = 5;

  render_screen(ScreenData);

}


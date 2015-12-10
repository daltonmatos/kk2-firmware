#include <avr/io.h>

#include "display/st7565.h"
#include "constants.h"
#include "io.h"
#include "ramvariables.h"
#include "eepromvariables.h"

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

  lcd_clear();
  FontSelector = f6x8;

  print_string_2(&ss_title, 21, 1, HIGHLIGHT_FULL_LINE);
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
  print_number_2(eepromP_read_word(eeStickScaleRoll), 67, 11, selected_item == 0 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
  print_number_2(eepromP_read_word(eeStickScalePitch), 67, 20, selected_item == 1 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
  print_number_2(eepromP_read_word(eeStickScaleYaw), 67, 29, selected_item == 2 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
  print_number_2(eepromP_read_word(eeStickScaleThrottle), 67, 38, selected_item == 3 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
  uint8_t _x = print_number_2(eepromP_read_word(eeStickScaleSlMixing), 67, 47, selected_item == 4 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
  X1 = 67 + (6*_x);  Y1 = 47; PixelType = 0;
  asm_PrintChar('%');

  print_string(&backprev, 0, 57);
  print_string(&nxtchng, 55, 57);
  
}

void stick_scaling(){

  uint8_t pressed = 0;
  int8_t selected_item = 0;

  _ss_render(selected_item);
  lcd_update();
  while ((pressed = wait_for_button(BUTTON_ANY)) != BUTTON_BACK){


    switch (pressed){
      case BUTTON_UP:
        selected_item--;
        break;
      case BUTTON_DOWN:
        selected_item++;
        break;
    }

    selected_item = constrain(selected_item, 0, 4);

    if (pressed == BUTTON_OK){
      eepromP_update_word(uint16_t_ptr(((int16_t) eeStickScaleRoll + selected_item*2)), 
                          asm_NumEdit(eepromP_read_word(uint16_t_ptr((int16_t) eeStickScaleRoll + selected_item*2)), 0, 500));
    }
    _ss_render(selected_item);
    lcd_update();

  }

}


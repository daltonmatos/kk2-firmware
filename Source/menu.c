#include <avr/io.h>
#include <avr/pgmspace.h>

#include "display/st7565.h"
#include "io.h"
#include "constants.h"

#include "menu.h"

uint8_t strlen_p(const char *str){
  uint8_t size = 0;
  while (pgm_read_byte(str++)){
    size++;
  }
  return size;
}


void __attribute__((optimize("O0"))) _menu_render_screen(menu_t *data, uint8_t selected_item){

  uint8_t op = 0;
  lcd_clear();
  FontSelector = f6x8;

  print_string_2(data->title, 72 - (strlen_p(data->title)*8 / 2), 1, HIGHLIGHT_FULL_LINE);

  if (data->render_callback){
    data->render_callback(selected_item);
  }else{
    for (op=0; op < data->total_options; op++){
      print_string_2((char *) pgm_read_word(data->options + op*2), 0, 11 + 9*op, op == selected_item ? HIGHLIGHT_FULL_LINE : HIGHLIGHT_NONE);  
    }
  }

  if (data->footer_callback){
    data->footer_callback();
  }
  lcd_update();
}


void __attribute__((optimize("O0"))) render_menu(menu_t *data){

  uint8_t selected_item = 0;
  uint8_t pressed = 0;

  _menu_render_screen(data, selected_item);
  
  while ((pressed = wait_for_button(BUTTON_ANY)) != BUTTON_BACK){

    switch (pressed){
      case BUTTON_DOWN:
          selected_item += 1;
          break;
      case BUTTON_UP:
          selected_item -= 1;
          break;  
    }
    selected_item = constrain(selected_item, 0, data->total_options - 1);

    if (pressed == BUTTON_OK){
      data->ok_callback(selected_item);
    }

    _menu_render_screen(data, selected_item);
  }

}


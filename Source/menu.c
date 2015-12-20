#include <avr/io.h>
#include <avr/pgmspace.h>

#include "display/st7565.h"
#include "io.h"
#include "constants.h"

uint8_t strlen_p(const char *str){
  uint8_t size = 0;
  while (pgm_read_byte(str++)){
    size++;
  }
  return size;
}


void __attribute__((optimize("O0"))) _menu_render_screen(
    const char *title,
    const char *footer,
    const char *options,
    uint8_t selected_item, 
    uint8_t total_options){

  uint8_t op = 0;
  lcd_clear();
  FontSelector = f6x8;

  print_string_2(title, 57 - ((strlen_p(title) / 2) * 7), 1, HIGHLIGHT_FULL_LINE);

  for (op=0; op < total_options; op++){
    print_string_2((char *) pgm_read_word(options + op*2), 0, 11 + 9*op, op == selected_item ? HIGHLIGHT_FULL_LINE : HIGHLIGHT_NONE);  
  }

  print_string(footer, 0, 57);
  lcd_update();
}


void __attribute__((optimize("O0"))) render_menu(
    const char *title,
    const char *footer,
    const char *options, 
    void (*callback)(uint8_t),
    uint8_t total_options){

  uint8_t selected_item = 0;
  uint8_t pressed = 0;

  _menu_render_screen(title, footer, options, selected_item, total_options);
  
  while ((pressed = wait_for_button(BUTTON_ANY)) != BUTTON_BACK){

    switch (pressed){
      case BUTTON_DOWN:
          selected_item += 1;
          break;
      case BUTTON_UP:
          selected_item -= 1;
          break;  
    }
    selected_item = constrain(selected_item, 0, total_options - 1);

    if (pressed == BUTTON_OK){
      lcd_clear();
      callback(selected_item);
    }

    _menu_render_screen(title, footer, options, selected_item, total_options);
  }

}


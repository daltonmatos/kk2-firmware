#include <avr/io.h>
#include <avr/pgmspace.h>

#include "display/st7565.h"
#include "io.h"
#include "constants.h"

#include "menu.h"

void __attribute__((optimize("O0"))) _menu_render_screen(menu_t *data, uint8_t selected_item){

  uint8_t op = 0;
  lcd_clear();
  FontSelector = f6x8;

  if (data->title){
    print_title(data->title);
  }

  if (data->footer_callback){
    data->footer_callback();
  }

  if (data->render_callback){
    data->render_callback(selected_item);
  }
  lcd_update();
}


void __read_input(uint8_t max_value){

    MenuState->key_pressed = wait_for_button(BUTTON_ANY);

    switch (MenuState->key_pressed){
      case BUTTON_DOWN:
        MenuState->selected_item += 1;
        break;
      case BUTTON_UP:
        MenuState->selected_item -= 1;
        break;  
    }
    MenuState->selected_item = constrain(MenuState->selected_item, 0, max_value - 1);
}


void __input_loop(menu_t *data){

    _menu_render_screen(data, MenuState->selected_item);

    while (MenuState->key_pressed != BUTTON_BACK){
      __read_input(data->total_options);

      if (MenuState->key_pressed == BUTTON_OK){
        data->ok_callback(MenuState->selected_item);
      }

      _menu_render_screen(data, MenuState->selected_item);
    }
}


void render_screen(menu_t *data){
  MenuState->key_pressed = 0;
  MenuState->selected_item = data->initial_option;
  __input_loop(data);
}

#define MAX_OPTIONS_PER_SCREEN 5

void /*__attribute__((optimize("O0")))*/ __render_options(uint8_t total, uint8_t volatile offset, const char* volatile title, char * volatile str_addr){
    uint8_t volatile op = 0;
    uint8_t volatile i = 0;

    FontSelector = f6x8;
    PixelType = 0;
    lcd_clear();
    print_title(title);
    print_std_footer();
    uint8_t volatile first_option = offset;
    
    if ((total - first_option) < MAX_OPTIONS_PER_SCREEN){
      first_option = (MAX_OPTIONS_PER_SCREEN - (total - offset + 1));
    }

    for (op=first_option; op < MAX_OPTIONS_PER_SCREEN + first_option; op++, i++){
      print_string_2((char *)pgm_read_word(str_addr + (op * 2)), 
          0, 
          11 + 9*i, 
          i == (MenuState->selected_item) ? HIGHLIGHT_FULL_LINE : HIGHLIGHT_NONE
      );
    }
    print_number(MenuState->selected_item, 60, 20);
    lcd_update();
}

uint8_t max(uint8_t a, uint8_t b){
  return a > b ? b : a;
}

void render_menu(uint8_t volatile total_options, const char* volatile title,  char * volatile str_addr, _ok_callback volatile cb){
  MenuState->key_pressed = 0;
  MenuState->selected_item = 0;
  uint8_t volatile offset = 0;
  __render_options(total_options, offset, title, str_addr);

  while (MenuState->key_pressed != BUTTON_BACK){
    __read_input(total_options);

    if (MenuState->key_pressed == BUTTON_OK){
      cb(MenuState->selected_item);
    }

    if (MenuState->selected_item >= MAX_OPTIONS_PER_SCREEN){
      MenuState->selected_item = MAX_OPTIONS_PER_SCREEN - 1;
      if (offset + MAX_OPTIONS_PER_SCREEN < total_options){
        offset++;
      }
    }else if (MenuState->key_pressed == BUTTON_UP && MenuState->selected_item == 0){
      offset--;
    }

    __render_options(total_options, offset, title, str_addr);
    print_number(total_options, 80, 20);
    print_number(offset, 80, 30);
    lcd_update();

  }

  return;
}

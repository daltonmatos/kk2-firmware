#include <avr/io.h>
#include "io.h"
#include "flashvariables.h"
#include "ramvariables.h"
#include "constants.h"
#include "display/st7565.h"

extern const char ef1; // "EXTRA", 0
extern const char ef2; // "Check Motor Outputs", 0
extern const char ef3; // "Gimbal Controller", 0
extern const char ef4; // "View Serial RX Data", 0
extern const char updown;

extern void asm_MotorCheck();
extern void asm_SerialDebug();

void _extra_make_call(uint8_t selected){
  switch (selected){
    case 0:
      asm_MotorCheck();
      break;
    case 1:
      gimbal_mode();
      break;
    case 2:
      asm_SerialDebug();
      break;
  }
}


void _extra_render(uint8_t selected){
    lcd_clear();

    FontSelector = f12x16;
    PixelType = 1;
    print_string(&ef1, 34, 0);

    FontSelector = f6x8;

    print_string_2(&ef2, 0, 17, selected == 0 ? HIGHLIGHT_FULL_LINE : HIGHLIGHT_NONE);
    print_string_2(&ef3, 0, 17 + 9, selected == 1 ? HIGHLIGHT_FULL_LINE : HIGHLIGHT_NONE);
    print_string_2(&ef4, 0, 17 + 9*2, selected == 2 ? HIGHLIGHT_FULL_LINE : HIGHLIGHT_NONE);

    print_string(&updown, 0, 57); /* Footer */
}


void extra_features(){
  
  int8_t selected_item = 0;
  uint8_t pressed = 0;

  _extra_render(selected_item);
  lcd_update();
  while ((pressed = wait_for_button(BUTTON_ANY)) != BUTTON_BACK){ 

    if (pressed == BUTTON_OK){
      _extra_make_call(selected_item);
    }
  
    switch (pressed){
      case BUTTON_UP:
        selected_item--;
        break;
      case BUTTON_DOWN:
        selected_item++;
        break;
      
    }
    selected_item  = selected_item > 2 ? 0 : selected_item;
    selected_item  = selected_item < 0 ? 2 : selected_item;
    _extra_render(selected_item);
    lcd_update();
  } 

}

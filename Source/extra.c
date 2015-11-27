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
extern void asm_GimbalMode();
extern void asm_SerialDebug();

/* Implemented in advanced.c
 * TODO: Will be moved to a central location
 */
extern void preapre_highlight_rectangle(uint8_t selected);
extern void _highlight(uint8_t selected_item);

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


void _extra_render(){
    lcd_clear();

    FontSelector = f12x16;
    PixelType = 1;
    print_string(&ef1, 34, 0);

    FontSelector = f6x8;

    print_string(&ef2, 0, 17);
    print_string(&ef3, 0, Y1 + 9);
    print_string(&ef4, 0, Y1 + 9);

    print_string(&updown, 0, 57); /* Footer */
}


void extra_features(){
  
  int8_t selected_item = 0;
  uint8_t pressed = 0;

  _extra_render();
  _highlight(selected_item);
  lcd_update();
  while ((pressed = wait_for_button(BUTTON_ANY)) != BUTTON_BACK){ 

    if (pressed == BUTTON_OK){
      _extra_make_call(selected_item);
    }
  
    _extra_render();
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
    _highlight(selected_item);
    lcd_update();
  } 

}

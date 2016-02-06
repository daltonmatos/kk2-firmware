#include <avr/io.h>
#include "io.h"
#include "flashvariables.h"
#include "ramvariables.h"
#include "constants.h"
#include "display/st7565.h"
#include "menu.h"

extern const char ef1; // "EXTRA", 0
extern const char updown;
extern char _extra_options;

extern void asm_MotorCheck();
extern void asm_SerialDebug();
extern void gimbal_mode();

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

void extra_features(){
  
  MenuData->title = &ef1;
  MenuData->footer_callback = &print_std_footer;
  MenuData->options = &_extra_options;
  MenuData->ok_callback = &_extra_make_call;
  MenuData->render_callback = 0;
  MenuData->total_options = 3;
  MenuData->initial_option = 0;
  
  render_menu(MenuData);
}

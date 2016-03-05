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
#ifdef STANDALONE_GIMBAL_CONTROLLER
    case 1:
      gimbal_mode();
      break;
    case 2:
#endif
#ifndef STANDALONE_GIMBAL_CONTROLLER
    case 1:
#endif
      asm_SerialDebug();
      break;
  }
}

void extra_features(){
  uint8_t options = 3;
#ifndef STANDALONE_GIMBAL_CONTROLLER
  options--;
#endif
  render_menu(options, &ef1, &_extra_options, &_extra_make_call);
}

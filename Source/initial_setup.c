#include <avr/io.h>
#include <avr/pgmspace.h>

#include "display/st7565.h"
#include "io.h"
#include "constants.h"
#include "menu.h"

extern char isp10;
extern const char isp1;
extern const char updown;

extern void asm_LoadMixer();
extern void asm_CalibrateSensors();
extern void asm_AdjustBatteryVoltage();
extern void asm_SelectRxMode();

void ok_callback(uint8_t item){
  switch (item){
    case 0:
      asm_LoadMixer();
      break;
    case 1:
      asm_CalibrateSensors();
      break;
    case 2:
      asm_AdjustBatteryVoltage();
      break;
    case 3:
      asm_SelectRxMode();
      break;
  
  }
}

void initial_setup(){

  MenuData->title = &isp1;
  MenuData->footer_callback = &print_std_footer;
  MenuData->options = &isp10;
  MenuData->ok_callback = &ok_callback;
  MenuData->render_callback = 0;
  MenuData->total_options = 4;
  MenuData->initial_option = 0;

  render_menu(MenuData);
}

#include <avr/io.h>
#include <avr/pgmspace.h>

#include "display/st7565.h"
#include "io.h"
#include "constants.h"
#include "menu.h"

extern const char isp10;
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

  menu_t data = {
    .title = &isp1,
    .footer_callback = &print_std_footer,
    .options = &isp10,
    .ok_callback = &ok_callback,
    .render_callback = 0,
    .total_options = 4,
    .up_callback = 0,
    .down_callback = 0
  };
  render_menu(&data);
}

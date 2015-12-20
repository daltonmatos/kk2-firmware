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

  render_menu(&isp1, &updown, &isp10, &ok_callback, 4);

}

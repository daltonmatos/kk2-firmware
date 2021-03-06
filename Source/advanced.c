#include <avr/io.h>

#include "io.h"
#include "flashvariables.h"
#include "ramvariables.h"
#include "constants.h"
#include "display/st7565.h"
#include "menu.h"
#include "channelmapping.h"

extern const char adv1; // [] PROGMEM = "ADVANCED"
extern char _adv_options;
extern const char updown;

extern void asm_MixerEditor();
extern void board_rotation();
extern void sensor_settings();


void _adv_make_call(uint8_t selected){
  switch (selected){
    case 0:
      channel_mapping();
      break;
    case 1:
      sensor_settings();
      break;
    case 2:
      asm_MixerEditor();
      break;
    case 3:
      board_rotation();
      break;  
  }
}

void advanced_settings(){

  render_menu(4, &adv1, &_adv_options, &_adv_make_call);

}

#include <avr/io.h>

#include "io.h"
#include "flashvariables.h"
#include "ramvariables.h"
#include "constants.h"
#include "display/st7565.h"
#include "menu.h"

extern const char adv1; // [] PROGMEM = "ADVANCED"
extern const char _adv_options;
extern const char updown;

extern void asm_ChannelMapping();
extern void asm_MixerEditor();
extern void board_rotation();
extern void sensor_settings();


void make_call(uint8_t selected){
  switch (selected){
    case 0:
      asm_ChannelMapping();     
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

  menu_t data = {
    .title = &adv1,
    .footer_callback = &print_std_footer,
    .options = &_adv_options,
    .ok_callback = &make_call,
    .render_callback = 0,
    .total_options = 4,
  };

  render_menu(&data);

}

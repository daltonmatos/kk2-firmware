#include <avr/io.h>
#include "io.h"
#include "flashvariables.h"
#include "ramvariables.h"
#include "constants.h"
#include "display/st7565.h"

extern const char adv1; // [] PROGMEM = "ADVANCED"
extern const char adv2; // [] PROGMEM = "Channel Mapping";
extern const char adv3; // [] PROGMEM = "Sensor Settings";
extern const char adv4; // [] PROGMEM = "Mixer Editor";
extern const char adv5; // [] PROGMEM = "Board Orientation";


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


void _render(uint8_t selected){
    lcd_clear();

    FontSelector = f12x16;
    PixelType = 1;
    print_string(&adv1, 16, 0);

    FontSelector = f6x8;

    print_string_2(&adv2, 0, 17, selected == 0 ? HIGHLIGHT_FULL_LINE : HIGHLIGHT_NONE);
    print_string_2(&adv3, 0, 17 + 9, selected == 1 ? HIGHLIGHT_FULL_LINE : HIGHLIGHT_NONE);
    print_string_2(&adv4, 0, 17 + 9*2, selected == 2 ? HIGHLIGHT_FULL_LINE : HIGHLIGHT_NONE);
    print_string_2(&adv5, 0, 17 + 9*3, selected == 3 ? HIGHLIGHT_FULL_LINE : HIGHLIGHT_NONE);

    print_string(&updown, 0, 57); /* Footer */
}

void advanced_settings(){
  
  uint8_t selected_item = 0;
  uint8_t pressed = 0;

  _render(selected_item);
  lcd_update();
  while ((pressed = wait_for_button(BUTTON_ANY)) != BUTTON_BACK){ 

    if (pressed == BUTTON_OK){
      make_call(selected_item);
    }
  
    switch (pressed){
      case BUTTON_UP:
        selected_item--;
        break;
      case BUTTON_DOWN:
        selected_item++;
        break;
      
    }
    selected_item &= 0x03; /* Limit to only 4 possible values */
    _render(selected_item);
    lcd_update();
  } 

}

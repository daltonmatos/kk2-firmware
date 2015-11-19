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
extern void asm_SensorSettings();
extern void asm_MixerEditor();
extern void asm_BoardRotation();


void preapre_highlight_rectangle(uint8_t selected){
/*  uint8_t rectangles[4][4] = {
    {0, 16, 127, 25},
    {0, 25, 127, 34},
    {0, 34, 127, 43},
    {0, 43, 127, 52}
  };
*/
  
  switch (selected){
    case 0:
      X1=0; Y1=16; X2=127; Y2=25;
      break;
    case 1:
      X1=0; Y1=25; X2=127; Y2=34;
      break;
    case 2:
      X1=0; Y1=34; X2=127; Y2=43;
      break;
    case 3:
      X1=0; Y1=43; X2=127; Y2=52;
      break;  
  }

}

void make_call(uint8_t selected){
  switch (selected){
    case 0:
      asm_ChannelMapping();     
      break;
    case 1:
      asm_SensorSettings();
      break;
    case 2:
      asm_MixerEditor();
      break;
    case 3:
      asm_BoardRotation();
      break;  
  }
}


void _render(){
    lcd_clear();

    FontSelector = f12x16;
    PixelType = 1;
    print_string(&adv1, 16, 0);

    FontSelector = f6x8;

    print_string(&adv2, 0, 17);
    print_string(&adv3, 0, 17 + 9);
    print_string(&adv4, 0, 17 + 9*2);
    print_string(&adv5, 0, 17 + 9*3);

    print_string(&updown, 0, 57); /* Footer */
}

void _highlight(uint8_t selected_item){
    preapre_highlight_rectangle(selected_item);
    asm_HighlightRectangle();  
}

void advanced_settings(){
  
  uint8_t selected_item = 0;
  uint8_t pressed = 0;

  _render();
  _highlight(selected_item);
  lcd_update();
  while ((pressed = wait_for_button(BUTTON_ANY)) != BUTTON_BACK){ 

    if (pressed == BUTTON_OK){
      make_call(selected_item);
    }
  
    _render();
    switch (pressed){
      case BUTTON_UP:
        selected_item--;
        break;
      case BUTTON_DOWN:
        selected_item++;
        break;
      
    }
    selected_item &= 0x03; /* Limit to only 4 possible values */
    _highlight(selected_item);
    lcd_update();
  } 

}

#include <avr/io.h>
#include <avr/eeprom.h>

#include "menu.h"
#include "io.h"
#include "constants.h"
#include "eepromvariables.h"
#include "display/st7565.h"

extern const char srm1; // RX MODE
extern const char srm2; // Mode
extern const char srm4; // Restart is required!

extern const char stdrx;
extern const char cppm; 
extern const char sbus; 
extern const char dsm2; 
extern const char dsmx; 
extern const char affects_all_profiles;

#define RXMODE_NONE 0xFF

void _rxmode_render(uint8_t selected_item){

  print_string(&srm2, 0, 20);

  switch (selected_item){
    case RxModeStandard:
      print_string(&stdrx, 35, 20);
      break;
    case RxModeCppm:
      print_string(&cppm, 35, 20);
      break;
    case RxModeSBus:
      print_string(&sbus, 35, 20);
      break;
    case RxModeSatDSM2:
      print_string(&dsm2, 35, 20);
      break;
    case RxModeSatDSMX:
      print_string(&dsmx, 35, 20);
      break;  
  }
  print_string_2(&affects_all_profiles, 3, 48, HIGHLIGHT_FULL_LINE);
}


void _rxmode_ok_callback(uint8_t selected_item){

  eeprom_update_byte(eeRxMode, selected_item);
  PixelType = 2;
  __fillrect(0, 33, 128, 64);
  PixelType = 1;
  print_string_2(&srm4, 4, 45, HIGHLIGHT_FULL_LINE);
  lcd_update();
  while(1){}

}

void select_rx_mode(){

  ScreenData->title = &srm1;
  ScreenData->footer_callback = &print_std_footer;
  ScreenData->options = 0;
  ScreenData->render_callback = &_rxmode_render;
  ScreenData->ok_callback = &_rxmode_ok_callback;
  ScreenData->total_options = 5;
  ScreenData->initial_option = RxMode;
  
  render_screen(ScreenData);
}

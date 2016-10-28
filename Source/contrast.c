#ifdef ADJUSTABLE_CONTRAST

#include <avr/eeprom.h>
#include <util/delay.h>
#include "flashvariables.h"
#include "ramvariables.h"
#include "eepromvariables.h"
#include "io.h"
#include "constants.h"
#include "display/st7565.h"


extern const char con1;
extern const char con2;
extern const char con6;
extern const char affects_all_profiles;

void _ctr_render(uint8_t volatile selected_item){

    constrain(selected_item, 25, 45);
    print_string(&con2, 0, 26); /* LCD Contrast: */

    print_string_2(&affects_all_profiles, 3, 48, HIGHLIGHT_FULL_LINE);
    print_number(selected_item, 90, 26);
}

void _c_ok_callback(uint8_t selected_item){

  LcdContrast = MenuState->selected_item;
  constrain(LcdContrast, 25, 46);
  eeprom_write_byte(eeLcdContrast, LcdContrast);
  _ctr_render(0);
  lcd_update();
}

void c_contrast(){

  ScreenData->title = &con1;
  ScreenData->footer_callback = &print_std_footer;
  ScreenData->ok_callback = &_c_ok_callback;
  ScreenData->render_callback = &_ctr_render;
  ScreenData->total_options = 45;
  ScreenData->initial_option = LcdContrast;

  render_screen(ScreenData);

  LcdContrast = eeprom_read_byte(eeLcdContrast);

}

#endif

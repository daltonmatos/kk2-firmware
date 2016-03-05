#include <avr/io.h>

#include "eepromvariables.h"
#include "io.h"
#include "constants.h"
#include "ramvariables.h"
#include "display/st7565.h"
#include "b168.h"

extern const char misc_settings_title;

extern const char stt1;
extern const char stt2;
extern const char stt5;
extern const char stt6;

extern const char bckprev;
extern const char nxtchng;

void _ms_render(uint8_t selected_item){

  if (flagGimbalMode){
    MenuState->selected_item = constrain(selected_item, 0, 1);
  }else {
    MenuState->selected_item = constrain(selected_item, 0, 3);
  }

  if (flagGimbalMode){
    print_string(&stt5, 0, 11);   
    print_string(&stt6, 0, 20);   
  }else {
    print_string(&stt1, 0, 11);   
    print_string(&stt2, 0, 20);   
    print_string(&stt5, 0, 29);   
    print_string(&stt6, 0, 38);   
  }

  if (flagGimbalMode){
    print_number_2(eepromP_read_word(eeBattAlarmVoltage), 108, 11, MenuState->selected_item == 0 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
    print_number_2(eepromP_read_word(eeServoFilter), 108, 20, MenuState->selected_item == 1 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
  }else {
    print_number_2(eepromP_read_word(eeEscLowLimit), 108, 11, MenuState->selected_item == 0 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
    print_number_2(eepromP_read_word(eeStickDeadZone), 108, 20, MenuState->selected_item == 1 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
    print_number_2(eepromP_read_word(eeBattAlarmVoltage), 108, 29, MenuState->selected_item == 2 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
    print_number_2(eepromP_read_word(eeServoFilter), 108, 38, MenuState->selected_item == 3 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
  }

}


uint16_t _ms_max(uint8_t selected_item){
      switch (selected_item){
        case 0:
          return 20;
        case 1:
          return 100;
        case 2:
          return 900;
        case 3:
          return 100;
      }
}

void _ms_oK_callback(uint8_t selected_item){
      if (flagGimbalMode){
        MenuState->selected_item += 2;
      }

      eepromP_update_word(uint16_t_ptr(((int16_t) eeEscLowLimit + MenuState->selected_item*2)), 
                          asm_NumEdit(eepromP_read_word(uint16_t_ptr((int16_t) eeEscLowLimit + MenuState->selected_item*2)), 0, _ms_max(MenuState->selected_item)));
      if (flagGimbalMode){
        MenuState->selected_item -= 2;
      }

}

void misc_settings(){

  ScreenData->title = &misc_settings_title;
  ScreenData->footer_callback = &print_std_footer;
  ScreenData->ok_callback = &_ms_oK_callback;
  ScreenData->render_callback = &_ms_render;
  ScreenData->total_options = 4;
  ScreenData->initial_option = 0;

  render_screen(ScreenData);

  /* Save StickDeadZone in RAM. It is 16.8 format encoded */
  uint16_t _eeStickDeadZone = eepromP_read_word(eeStickDeadZone);
  b168_unpack(StickDeadZone, ((int32_t) _eeStickDeadZone) << 8);
}


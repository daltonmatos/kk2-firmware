#include <avr/io.h>
#include <avr/eeprom.h>

#include "constants.h"
#include "ramvariables.h"
#include "eepromvariables.h"
#include "io.h"
#include "display/st7565.h"

extern const char mode_settings_tittle;


extern const char sux1; //"Link Roll Pitch", 0
extern const char sux2; //"Auto Disarm", 0
extern const char sux3; //"Button Beep", 0
extern const char sux4; //"Arming Beeps", 0, 0

extern const char no;
extern const char yes;

extern const char nxtchng;
extern const char backprev;

extern const char back;
extern const char change;

void _mds_render(uint8_t current_item){

  if (flagGimbalMode){
    MenuState->selected_item = 0;
  }else {
    MenuState->selected_item &= 0x03;
  }

  if (!flagGimbalMode){
    print_string(&sux1, 0, 12);
    print_string(&sux2, 0, 21);
    print_string(&sux3, 0, 30);
    print_string(&sux4, 0, 39);
  }else {
    print_string(&sux3, 0, 12);
  }

  if (!flagGimbalMode){
    print_string_2(eepromP_read_byte(eeLinkRollPitch) ? &yes : &no, 102, 12, current_item == 0 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
    print_string_2(eepromP_read_byte(eeButtonBeep) ? &yes : &no, 102, 30, current_item == 2 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
    print_string_2(eepromP_read_byte(eeAutoDisarm) ? &yes : &no, 102, 21, current_item == 1 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
    print_string_2(eepromP_read_byte(eeArmingBeeps) ? &yes : &no, 102, 39, current_item == 3 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
  }else {
    print_string_2(eepromP_read_byte(eeButtonBeep) ? &yes : &no, 102, 12, MenuState->selected_item == 0 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
  }

}

void _mds_ok_callback(uint8_t current_item){

  if (flagGimbalMode){
    eepromP_update_byte(eeButtonBeep, eepromP_read_byte(eeButtonBeep) ^ 0xff);
  }else {
    eepromP_update_byte(eeLinkRollPitch + current_item, eepromP_read_byte(eeLinkRollPitch + current_item) ^ 0xff);
  }
}

void mode_settings(){

  uint8_t current_item = 0;
  uint8_t pressed = 0;
  uint8_t old_roll_pitch_link = eepromP_read_byte(eeLinkRollPitch);

  ScreenData->title = &mode_settings_tittle;
  ScreenData->footer_callback = &print_std_footer;
  ScreenData->ok_callback = &_mds_ok_callback;
  ScreenData->render_callback = &_mds_render;
  ScreenData->total_options = 4;
  ScreenData->initial_option = 0;

  if (flagGimbalMode){
    ScreenData->footer_callback = print_back_chg_footer;
  }

  render_screen(ScreenData);

  flagRollPitchLink = eepromP_read_byte(eeLinkRollPitch);

  if (flagRollPitchLink != old_roll_pitch_link){
    /* Copy Elevator gains from Aileron gains */
    eepromP_copy_block(eeParameterTableAileron, eeParameterTableElevator, 8);
  }

}

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
  lcd_clear();
  FontSelector = f6x8;
  print_string_2(&mode_settings_tittle, 26, 1, HIGHLIGHT_FULL_LINE);

  if (!flagGimbalMode){
    print_string(&sux1, 0, 12);
    print_string(&sux2, 0, 21);
    print_string(&sux3, 0, 30);
    print_string(&sux4, 0, 39);
  }else {
    print_string(&sux3, 0, 12);
  }

  if (!flagGimbalMode){
    print_string_2(eeprom_read_byte(eeLinkRollPitch) ? &yes : &no, 102, 12, current_item == 0 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
    print_string_2(eeprom_read_byte(eeButtonBeep) ? &yes : &no, 102, 30, current_item == 2 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
    print_string_2(eeprom_read_byte(eeAutoDisarm) ? &yes : &no, 102, 21, current_item == 1 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
    print_string_2(eeprom_read_byte(eeArmingBeeps) ? &yes : &no, 102, 39, current_item == 3 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
  }else {
    print_string_2(eeprom_read_byte(eeButtonBeep) ? &yes : &no, 102, 12, current_item == 0 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
  }

  if (!flagGimbalMode){
    print_string(&backprev, 0, 57);
    print_string(&nxtchng, X1, 57);
  }else {
    print_string(&back, 0, 57);
    print_string(&change, 90, 57);
  }
}

void mode_settings(){

  uint8_t current_item = 0;
  uint8_t pressed = 0;

  _mds_render(current_item);
  lcd_update();
  while ((pressed = wait_for_button(BUTTON_ANY)) != BUTTON_BACK){

    switch (pressed){
      case BUTTON_UP:
        current_item--;
        break;
      case BUTTON_DOWN:
        current_item++;
        break;
      case BUTTON_OK:
        if (flagGimbalMode){
          eeprom_update_byte(eeButtonBeep, eeprom_read_byte(eeButtonBeep) ^ 0xff);
        }else {
          eeprom_update_byte(eeLinkRollPitch + current_item, eeprom_read_byte(eeLinkRollPitch + current_item) ^ 0xff);
        }
        break;
    }
    if (flagGimbalMode){
      current_item = 0;
    }else {
      current_item &= 0x03;
    }
    _mds_render(current_item);
    lcd_update();
  }

  flagRollPitchLink = eeprom_read_byte(eeLinkRollPitch);

}

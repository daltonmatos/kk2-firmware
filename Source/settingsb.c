#include <avr/io.h>

#include "eepromvariables.h"
#include "io.h"
#include "constants.h"
#include "ramvariables.h"
#include "display/st7565.h"

extern const char misc_settings_title;

extern const char stt1;
extern const char stt2;
extern const char stt5;
extern const char stt6;

extern const char bckprev;
extern const char nxtchng;

void _ms_render(uint8_t selected_item){

  lcd_clear();
  FontSelector = f6x8;

  print_string_2(&misc_settings_title, 18, 1, HIGHLIGHT_FULL_LINE);

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
    print_number_2(eepromP_read_word(eeBattAlarmVoltage), 108, 11, selected_item == 0 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
    print_number_2(eepromP_read_word(eeServoFilter), 108, 20, selected_item == 1 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
  }else {
    print_number_2(eepromP_read_word(eeEscLowLimit), 108, 11, selected_item == 0 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
    print_number_2(eepromP_read_word(eeStickDeadZone), 108, 20, selected_item == 1 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
    print_number_2(eepromP_read_word(eeBattAlarmVoltage), 108, 29, selected_item == 2 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
    print_number_2(eepromP_read_word(eeServoFilter), 108, 38, selected_item == 3 ? HIGHLIGHT_TO_THE_END_OF_LINE : HIGHLIGHT_NONE);
  }

  print_string(&bckprev, 0, 57);
  print_string(&nxtchng, 55, 57);

}


uint16_t _ms_max(selected_item){
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

void misc_settings(){

  int8_t selected_item = 0;
  uint8_t pressed = 0;

  _ms_render(selected_item);
  lcd_update();

  while ((pressed = wait_for_button(BUTTON_ANY)) != BUTTON_BACK){

    switch (pressed){
      case BUTTON_UP:
        selected_item--;
        break;
      case BUTTON_DOWN:
        selected_item++;
        break;
    }

    if (flagGimbalMode){
      selected_item = constrain(selected_item, 0, 1);
    }else {
      selected_item = constrain(selected_item, 0, 3);
    }

    if (pressed == BUTTON_OK){
      if (flagGimbalMode){
        selected_item += 2;
      }

      eepromP_update_word(uint16_t_ptr(((int16_t) eeEscLowLimit + selected_item*2)), 
                          asm_NumEdit(eepromP_read_word(uint16_t_ptr((int16_t) eeEscLowLimit + selected_item*2)), 0, _ms_max(selected_item)));
      if (flagGimbalMode){
        selected_item -= 2;
      }
    }

    _ms_render(selected_item);
    lcd_update();

  }

  /* Save StickDeadZone in RAM. It is 16.8 format encoded */
  StickDeadZone = eepromP_read_word(eeStickDeadZone); // 16 (integer part)
  *uint8_t_prt((uint16_t) _StickDeadZone + 2) = 0; // .8 (decimal part)

}


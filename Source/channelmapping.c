#include <avr/io.h>

#include "menu.h"
#include "ramvariables.h"
#include "constants.h"
#include "eepromvariables.h"
#include "io.h"
#include "display/st7565.h"


#define ADD_TO_U16(u16_t, n) (((uint16_t)(u16_t)) + (n))

extern char cm_title;
extern char updown;
extern char _ok;

extern char ail;
extern char ele;
extern char thr;
extern char rudd;
extern char aux;
extern char aux2;
extern char aux3;
extern char aux4;

extern char cmw1;
extern char cmw2;
extern char cmw3;
extern char cerror;

uint16_t _cm_eeprom_base_addr(){
  if (RxMode < RxModeSatDSM2){
    return (uint16_t) eeChannelRoll;
  }
  return (uint16_t) eeSatChannelRoll;
}

void _cm_copy_mapping_to_sram(){
  uint16_t eeprom_addr = _cm_eeprom_base_addr();

  for (uint8_t c=0; c < 8; c++){
    /* Mapped channels are stored in RAM from 0 to 7 */
    MappedChannelArray[c] = eepromP_read_byte(EEPROM_VARIABLE(ADD_TO_U16(eeprom_addr, c))) - 1;
  }

}

void _cm_render(uint8_t selected_item){
  uint8_t channel_value = 0;
  uint8_t channel_value_show = 0;
  uint8_t volatile ch = 0;
  uint8_t volatile item = selected_item;
  uint8_t x = 0;
  uint8_t y = 0;

  print_string(&ail, 0, 11);
  print_string(&ele, 0, 19);
  print_string(&thr, 0, 28);
  print_string(&rudd, 0, 37);
  print_string(&aux, 0, 46);

  print_string(&aux2, 70, 11);
  print_string(&aux3, 70, 19);
  print_string(&aux4, 70, 28);

  for(ch = 0; ch < 8; ch++){
    channel_value = MappedChannelArray[ch];
    channel_value_show = channel_value + 1;
    if (ch < 5){
      x = 55;
      y = (ch * 8) + 11;
    }else {
      x = 100;
      y = ((ch - 5) * 8) + 11;
    }
    print_number_2(channel_value_show, x, y, selected_item == ch ? HIGHLIGHT_STRING : HIGHLIGHT_NONE);
  }
}

void _cm_ok_cb(uint8_t selected_item){

  uint16_t ch = asm_NumEdit(MappedChannelArray[selected_item] + 1, 1, 8);

  MappedChannelArray[selected_item] = ((uint8_t) ch) - 1;
  eepromP_update_byte(EEPROM_VARIABLE(ADD_TO_U16(_cm_eeprom_base_addr(), selected_item)) , (uint8_t) ch);

}

uint8_t _cm_mapping_is_ok(){
  uint8_t bitmap = 0;
  uint16_t eeprom_addr = _cm_eeprom_base_addr();

  for (uint8_t ch=0; ch < 8; ch++){
    uint8_t ch_val = eepromP_read_byte(EEPROM_VARIABLE(ADD_TO_U16(eeprom_addr, ch)));
    if (ch_val){
      bitmap |= _BV(ch_val - 1);
    }
  }

  return !(bitmap ^ 0xFF);
}


void _cm_show_channelmaping_error(){
      lcd_clear();
      print_title(&cerror);

      print_string(&cmw1, 0, 20);
      print_string(&cmw2, 0, 29);
      print_string(&cmw3, 0, 38);
      print_string(&_ok, 114, 57);
      lcd_update();
      wait_for_button(BUTTON_OK);
}

void channel_mapping(){

  _cm_copy_mapping_to_sram();
  
  ScreenData->title = &cm_title;
  ScreenData->footer_callback = &print_std_footer;
  ScreenData->options = 0;
  ScreenData->ok_callback = &_cm_ok_cb;
  ScreenData->render_callback = &_cm_render;
  ScreenData->total_options = 8;
  ScreenData->initial_option = 0;

  while (1){
    render_screen(ScreenData);
    
    if (!_cm_mapping_is_ok()){
      _cm_show_channelmaping_error();
    }else{
      break;
    }
  }
  _cm_copy_mapping_to_sram();
}


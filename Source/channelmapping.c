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

  print_string(&ail, 0, 11);
  print_string(&ele, 0, 19);
  print_string(&thr, 0, 28);
  print_string(&rudd, 0, 37);
  print_string(&aux, 0, 46);

  print_number_2(MappedChannel1 + 1, 55, 11, selected_item == 0 ? HIGHLIGHT_STRING : HIGHLIGHT_NONE);
  print_number_2(MappedChannel2 + 1, 55, 19, selected_item == 1 ? HIGHLIGHT_STRING : HIGHLIGHT_NONE);
  print_number_2(MappedChannel3 + 1, 55, 28, selected_item == 2 ? HIGHLIGHT_STRING : HIGHLIGHT_NONE);
  print_number_2(MappedChannel4 + 1, 55, 37, selected_item == 3 ? HIGHLIGHT_STRING : HIGHLIGHT_NONE);
  print_number_2(MappedChannel5 + 1, 55, 46, selected_item == 4 ? HIGHLIGHT_STRING : HIGHLIGHT_NONE);

  print_string(&aux2, 70, 11);
  print_string(&aux3, 70, 19);
  print_string(&aux4, 70, 28);
  
  print_number_2(MappedChannel6 + 1, 100, 11, selected_item == 5 ? HIGHLIGHT_STRING : HIGHLIGHT_NONE);
  print_number_2(MappedChannel7 + 1, 100, 19, selected_item == 6 ? HIGHLIGHT_STRING : HIGHLIGHT_NONE);
  print_number_2(MappedChannel8 + 1, 100, 28, selected_item == 7 ? HIGHLIGHT_STRING : HIGHLIGHT_NONE);

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
  
  MenuData->title = &cm_title;
  MenuData->footer_callback = &print_std_footer;
  MenuData->options = 0;
  MenuData->ok_callback = &_cm_ok_cb;
  MenuData->render_callback = &_cm_render;
  MenuData->total_options = 8;
  MenuData->initial_option = 0;

  while (1){
    render_menu(MenuData);
    
    if (!_cm_mapping_is_ok()){
      _cm_show_channelmaping_error();
    }else{
      break;
    }
  }
  _cm_copy_mapping_to_sram();
}


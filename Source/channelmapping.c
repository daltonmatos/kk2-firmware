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
    RAM_VARIABLE(ADD_TO_U16(MappedChannel1_addr, c)) = eepromP_read_byte(EEPROM_VARIABLE(ADD_TO_U16(eeprom_addr, c)));
  }

}

void _cm_render(uint8_t selected_item){

  print_string(&ail, 0, 11);
  print_string(&ele, 0, 19);
  print_string(&thr, 0, 28);
  print_string(&rudd, 0, 37);
  print_string(&aux, 0, 46);

  print_number_2(MappedChannel1, 55, 11, selected_item == 0 ? HIGHLIGHT_STRING : HIGHLIGHT_NONE);
  print_number_2(MappedChannel2, 55, 19, selected_item == 1 ? HIGHLIGHT_STRING : HIGHLIGHT_NONE);
  print_number_2(MappedChannel3, 55, 28, selected_item == 2 ? HIGHLIGHT_STRING : HIGHLIGHT_NONE);
  print_number_2(MappedChannel4, 55, 37, selected_item == 3 ? HIGHLIGHT_STRING : HIGHLIGHT_NONE);
  print_number_2(MappedChannel5, 55, 46, selected_item == 4 ? HIGHLIGHT_STRING : HIGHLIGHT_NONE);

  print_string(&aux2, 70, 11);
  print_string(&aux3, 70, 19);
  print_string(&aux4, 70, 28);
  
  print_number_2(MappedChannel6, 100, 11, selected_item == 5 ? HIGHLIGHT_STRING : HIGHLIGHT_NONE);
  print_number_2(MappedChannel7, 100, 19, selected_item == 6 ? HIGHLIGHT_STRING : HIGHLIGHT_NONE);
  print_number_2(MappedChannel8, 100, 28, selected_item == 7 ? HIGHLIGHT_STRING : HIGHLIGHT_NONE);

}

void _cm_ok_cb(uint8_t selected_item){

  uint16_t ch = asm_NumEdit(RAM_VARIABLE(ADD_TO_U16(MappedChannel1_addr, selected_item)) , 1, 8);

  RAM_VARIABLE(ADD_TO_U16(MappedChannel1_addr, selected_item)) = (uint8_t) ch;
  eepromP_update_byte(EEPROM_VARIABLE(ADD_TO_U16(_cm_eeprom_base_addr(), selected_item)) , (uint8_t) ch);

}

uint8_t _cm_mapping_is_ok(){
  uint8_t bitmap = 0;

  for (uint8_t ch=0; ch < 8; ch++){
    uint8_t ch_val = RAM_VARIABLE(ADD_TO_U16(MappedChannel1_addr, ch));
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

  uint8_t mapping_ok = 1;
  _cm_copy_mapping_to_sram();

  
  menu_t data = {
    .title = &cm_title,
    .footer_callback = &print_std_footer,
    .options = 0,
    .ok_callback = &_cm_ok_cb,
    .render_callback = &_cm_render,
    .total_options = 8,
    .initial_option = 0,
  };

  while (1){
    render_menu(&data);
    
    if (!_cm_mapping_is_ok()){
      _cm_show_channelmaping_error();
    }else{
      break;
    }
  }
}


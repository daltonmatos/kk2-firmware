#include <avr/io.h>
#include <avr/pgmspace.h>
#include <string.h>
#include <avr/eeprom.h>

#include "io.h"
#include "ramvariables.h"
#include "display/st7565.h"
#include "constants.h"

uint8_t __get_buttons(){
  return PINB;
}


uint8_t __wait_for_keypress(){

  uint8_t buttons = __get_buttons();

  while (!buttons){
    buttons = __get_buttons();
  }

  // call _beep();
  
  return buttons;
}




void __release_buttons(){

  while (__get_buttons() != 0){
  }

}

uint8_t __get_buttons_blocking(){

  __release_buttons();
  return __wait_for_keypress();

}


uint8_t print_string(const uint8_t *str_addr, uint8_t x, uint8_t y){
  X1 = x;
  Y1 = y;
  char ch = 0;
  uint8_t count = 0;
  while ((ch = pgm_read_byte(str_addr++))){
    asm_PrintChar(ch);
    count++;
  }
  return count;
}

void print_number(int8_t number, uint8_t x, uint8_t y){
  X1 = x;
  Y1 = y;
  asm_Print16Signed(number);
}

extern const uint16_t convt;

uint8_t print16_signed(uint16_t n){
  if (!n){
    asm_PrintChar('0');
    return 1;
  }

  if (n < 0){
    asm_PrintChar('-');
    n = -n;
  }

  uint8_t digit_4, digit_3, digit_2, digit_1, digit_0 = 0;
  /*
  while (n){
    digit = n % 10;
    asm_PrintChar(digit + 16);
    n /= 10;
  }*/
  digit_4 = n / 10000;
  if (digit_4) asm_PrintChar(digit_4 + 16);

  n = (n - digit_4 * 10000);
  digit_3 = (n / 1000);
  if (digit_3) asm_PrintChar(digit_3 + 16);

  n = (n - (digit_3 * 1000));
  digit_2 = (n / 100);
  if (digit_2) asm_PrintChar(digit_2 + 16);

  n = (n - digit_2 * 100);
  digit_1 = (n / 10);
  if (digit_1) asm_PrintChar(digit_1 + 16);
  
  n = (n - digit_1 * 10);
  digit_0 = (n / 1);
  if (digit_0) asm_PrintChar(digit_0 + 16);
  
  return 5;
}


uint8_t wait_for_button(uint8_t button_mask){
  uint8_t pressed = 0;
  while ( !((pressed = asm_GetButtonsBlocking()) & button_mask)) {}
  return pressed;
}

extern const char confirm;
extern const char conf;
extern const char rusure;

/* This holds info about each font. We will need CharWidth and CharHeight */
extern const char TabCh;

uint8_t show_confirmation_dlg(const uint8_t *str){
  
  uint8_t pressed = 0;

  lcd_clear12x16();

  print_string(&confirm, 22, 0);
  Y1 = 17;
  FontSelector = f6x8;

  print_string(str, 0, 26);

  print_string(&rusure, 0, 35);

  print_string(&conf, 0, 57);

  lcd_update();

  return wait_for_button(BUTTON_BACK | BUTTON_OK);

}

void print_selector(uint8_t x1, uint8_t y1, uint8_t x2, uint8_t y2){
  X1 = x1;
  X2 = x2;
  Y1 = y1;
  Y2 = y2;
  PixelType = 0;
  asm_HighlightRectangle();
}

void print_string_2(const uint8_t *str_addr, uint8_t x, uint8_t y, uint8_t hilight_type){
  uint8_t len = print_string(str_addr, x, y);
  uint8_t char_width = pgm_read_byte(&TabCh + (FontSelector * 6) + 2);
  uint8_t char_height = pgm_read_byte(&TabCh + (FontSelector * 6) + 3);

  switch (hilight_type){
    case HIGHLIGHT_STRING:
      print_selector(x, y-1, x + (len * char_width), y + char_height);
      break;
    case HIGHLIGHT_FULL_LINE:
      print_selector(0, y-1, 127, y + char_height);
      break;
    case HIGHLIGHT_TO_THE_END_OF_LINE:
      print_selector(x, y-1, 127, y + char_height);
      break;
    case HIGHLIGHT_FROM_BEGINNING_OF_LINE:
      print_selector(0, y-1, x + (len * char_width), y + char_height);
      break;
  }
}


uint8_t eepromP_read_byte(const uint8_t *addr){
  return eeprom_read_byte(uint8_t_prt(SHIFT_ADDR_TO_CURRENT_PROFILE((uint16_t) addr)));
}

void eepromP_update_byte(const uint8_t * addr, uint8_t value){
  eeprom_update_byte(uint8_t_prt(SHIFT_ADDR_TO_CURRENT_PROFILE((uint16_t) addr)) , value);
}

void eepromP_copy_block(const uint8_t * src, const uint8_t *dest, uint8_t count){
    eeprom_copy_block(uint8_t_prt(SHIFT_ADDR_TO_CURRENT_PROFILE((uint16_t) src)), 
                      uint8_t_prt(SHIFT_ADDR_TO_CURRENT_PROFILE((uint16_t) dest)), 
                      count);
}

void eeprom_copy_block(uint8_t * src, uint8_t *dest, uint8_t count){
    for (uint8_t i = 0; i < count; i++){
      uint8_t b = eeprom_read_byte(src + i);
      eeprom_update_byte(dest + i, b);
    }
}

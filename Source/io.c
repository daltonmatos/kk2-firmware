#include <avr/io.h>
#include <avr/pgmspace.h>
#include <string.h>
#include <avr/eeprom.h>
#include <util/delay.h>
#include "io.h"
#include "ramvariables.h"
#include "display/st7565.h"
#include "constants.h"


/* This holds info about each font. We will need CharWidth and CharHeight */
extern const char TabCh;
extern const char _char_data[];

#define EXTRACT_BIT(n, bit) ((n) & _BV((bit)))

uint8_t get_buttons(){
  uint8_t _pinb = PINB;

  _pinb ^= 0xFF;
  _pinb >>= 4;
  _pinb &= 0x0F;

  if (!_pinb){
    return BUTTON_NONE;
  }
  _delay_us(250);
  _delay_us(250);

  _pinb = PINB;
  _pinb ^= 0xFF;
  _pinb >>= 4;
  _pinb &= 0x0F;

  if (BtnReversed){
    _pinb = (EXTRACT_BIT(_pinb, 0) << 3)
           |(EXTRACT_BIT(_pinb, 1) << 1)
           |(EXTRACT_BIT(_pinb, 2) >> 1)
           |(EXTRACT_BIT(_pinb, 3) >> 3);
  }

  return _pinb;
}

void release_buttons(){
  while (get_buttons() != BUTTON_NONE){}
}

uint8_t get_buttons_blocking(){
  uint8_t pressed = 0;
  release_buttons();
  while ((pressed = get_buttons()) == BUTTON_NONE){}
  //beep();
  return pressed;
}


uint8_t wait_for_button(uint8_t button_mask){
  uint8_t pressed = 0;
  while ( !((pressed = get_buttons_blocking()) & button_mask)) {}
  return pressed;
}

uint8_t constrain(int8_t value, uint8_t min, uint8_t max){
  if (value < min) value = max;
  if (value > max) value = min;
  return value;
}

void print_selector(uint8_t x1, uint8_t y1, uint8_t x2, uint8_t y2){
  PixelType = 0;
  __fillrect(x1, y1, x2, y2);
}

void _highlight_current_print(uint8_t len, uint8_t x, uint8_t y, uint8_t hilight_type){
  uint8_t offset = FontSelector * 3;
  uint8_t char_width = pgm_read_byte(&_char_data[offset]);
  uint8_t char_height = pgm_read_byte(&_char_data[offset + 1]);

  switch (hilight_type){
    case HIGHLIGHT_STRING:
      print_selector(x-2, y-1, x + (len * char_width) + 2, y + char_height);
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

extern char backprev;
extern char _nxtchng;

void print_std_footer(){
    print_string(&backprev, 0, 57);
    print_string(&_nxtchng, X1, 57);
}

uint8_t strlen_p(const char *str){
  uint8_t size = 0;
  while (pgm_read_byte(str++)){
    size++;
  }
  return size;
}

void print_title(const char *title){

  print_string_2(title, 72 - (strlen_p(title)*8 / 2), 1, HIGHLIGHT_FULL_LINE);
}

uint8_t print_string(const char *str_addr, uint8_t x, uint8_t y){
  X1 = x;
  Y1 = y;
  char ch = 0;
  uint8_t count = 0;
  while ((ch = pgm_read_byte(str_addr++))){
    print_char(ch);
    count++;
  }
  return count;
}

uint8_t print_number(int16_t number, uint8_t x, uint8_t y){
  X1 = x;
  Y1 = y;
  return _print16_signed(number);
}

uint8_t _print16_signed(int16_t n){
  uint8_t digit = 0;
  uint8_t print_zeroes = 0;
  uint8_t total_digits = 0;
  uint16_t _div = 0;


  if (!n){
    print_char('0');
    return 1;
  }

  if (n < 0){
    print_char('-');
    n = -n;
  }
  
  _div = 10000;
  for (uint8_t i=0; i < 5; i++){
    digit = 0;
    while (n >= _div && n > 0){
      n -= _div;
      digit++;
    }
    _div /= 10;
    if (digit || print_zeroes){
      print_char(digit + 48);
      total_digits++;
      print_zeroes = 1;
    }
  }
  return total_digits;
}

uint8_t print_number_2(int16_t number, uint8_t x, uint8_t y, uint8_t hilight_type){
  X1 = x;
  Y1 = y;
  uint8_t digits = _print16_signed(number);
  _highlight_current_print(digits, x, y, hilight_type);
  return digits;
}

void print_bits32(int32_t number, uint8_t x, uint8_t y){
  uint8_t volatile bits = 0;
  uint8_t volatile _x = x;
  X1 = x;
  Y1 = y;
  FontSelector = f6x8;
  for (bits = 0; bits < 32; bits++){
    if (number & 0x80000000){
      PixelType = 1;
      __setpixel(_x, Y1);
    }else{
      PixelType = 1;
      __setpixel(_x, Y1 + 1);
    }
    number <<= 1;
    _x+=2;
  }

}

void print_bits16(int16_t number, uint8_t x, uint8_t y){
  uint8_t volatile bits = 0;
  X1 = x;
  Y1 = y;
  FontSelector = f6x8;
  PixelType = 1;
  for (bits = 0; bits < 16; bits++){
    if (number & 0x8000){
      print_char('1');
    }else{
      print_char('0');
    }
    number <<= 1;
  }

}

void print_bits8(int8_t number, uint8_t x, uint8_t y){
  uint8_t volatile bits = 0;
  X1 = x;
  Y1 = y;
  FontSelector = f6x8;
  PixelType = 1;
  for (bits = 0; bits < 8; bits++){
    if (number & 0x80){
      print_char('1');
    }else{
      print_char('0');
    }
    number <<= 1;
  }

}

extern const char confirm;
extern const char conf;
extern const char rusure;


uint8_t show_confirmation_dlg(const char *str){
  
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





void print_string_2(const char *str_addr, uint8_t x, uint8_t y, uint8_t hilight_type){
  uint8_t len = print_string(str_addr, x, y);
  _highlight_current_print(len, x, y, hilight_type);
}


uint8_t eepromP_read_byte(const uint8_t *addr){
  return eeprom_read_byte(uint8_t_prt(SHIFT_ADDR_TO_CURRENT_PROFILE((uint16_t) addr)));
}

void eepromP_update_byte(const uint8_t * addr, uint8_t value){
  eeprom_update_byte(uint8_t_prt(SHIFT_ADDR_TO_CURRENT_PROFILE((uint16_t) addr)) , value);
}

int16_t eepromP_read_word(const uint16_t *addr){
  return eeprom_read_word(uint16_t_ptr(SHIFT_ADDR_TO_CURRENT_PROFILE((uint16_t) addr)));
}

void eepromP_update_word(const uint16_t * addr, uint16_t value){
  eeprom_update_word(uint16_t_ptr(SHIFT_ADDR_TO_CURRENT_PROFILE((uint16_t) addr)), value);
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


extern const char font4x6[]; 
extern const char font6x8[]; 
extern const char font12x16[]; 
extern const char symbols16x16[]; 

const char* _get_font_address(){
  switch(FontSelector){
    case f4x6:
      return font4x6;
      break;
    case f6x8:
      return font6x8;
      break;
    case f12x16:
      return font12x16;
      break;
    case s16x16:
      return symbols16x16;
      break;
  }
}

void _sprite(const char *bitmap, uint8_t w, uint8_t h, uint8_t bytes, uint8_t x, uint8_t y){

  uint8_t b = 0;
  uint8_t _x1_original = x;
  uint8_t _y1_original = y;
  uint8_t volatile char_data = 0;
  uint8_t volatile bits = 0;

  for (b = 0; b < bytes; b++){
    char_data = pgm_read_byte(bitmap + b);
    for (bits = 0; bits < 8; bits++){
      if (char_data & 0x80){
        __setpixel(x, y);
      }
      x++;
      char_data <<= 1;

      if ((x - _x1_original) == w) {
        y++;
        x = _x1_original;
      }

    }
  }
}

void print_char(const char ch){

  uint8_t table_offset = 32;
  const char *font_address = _get_font_address();
  uint8_t offset = FontSelector * 3;
  uint8_t char_width = pgm_read_byte(&_char_data[offset]);
  uint8_t char_height = pgm_read_byte(&_char_data[offset + 1]);
  uint8_t char_bytes = pgm_read_byte(&_char_data[offset + 2]);
  
  if (ch < 32){
    table_offset = 0;
  }
  uint16_t char_offset = (ch - table_offset) * char_bytes;
  _sprite(font_address + char_offset, char_width, char_height, char_bytes, X1, Y1);
  X1 = X1 + char_width;
}

#include <avr/io.h>
#include <avr/pgmspace.h>
#include "io.h"
#include "ramvariables.h"
#include "display/st7565.h"

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


void print_string(const uint8_t *str_addr, uint8_t x, uint8_t y){
  X1 = x;
  Y1 = y;
  char ch = 0;
  while ((ch = pgm_read_byte(str_addr++))){
    asm_PrintChar(ch);
  }
}

void print_number(int8_t number, uint8_t x, uint8_t y){
  X1 = x;
  Y1 = y;
  asm_Print16Signed(number);
}

uint8_t wait_for_button(uint8_t button_mask){
  uint8_t pressed = 0;
  while ( !((pressed = asm_GetButtonsBlocking()) & button_mask)) {}
  return pressed;
}

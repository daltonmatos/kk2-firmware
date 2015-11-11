#include <avr/io.h>
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
  asm_PrintString(str_addr);
}

void wait_for_button(uint8_t button){
  while (asm_GetButtonsBlocking() != button){}
}

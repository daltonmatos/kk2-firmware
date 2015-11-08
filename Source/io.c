#ifndef IO_H
#define IO_H

#include <avr/io.h>



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

#endif


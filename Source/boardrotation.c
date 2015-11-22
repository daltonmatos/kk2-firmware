#include <avr/io.h>
#include <avr/eeprom.h>

#include "display/st7565.h"
#include "io.h"
#include "flashvariables.h"
#include "ramvariables.h"
#include "eepromvariables.h"
#include "constants.h"

extern const char brd1;
extern const char backprev;
extern const char nextsel;
extern const uint8_t brd_up;
extern const uint8_t brd_right;
extern const uint8_t brd_down;
extern const uint8_t brd_left;

extern const uint8_t _saved;
extern const uint8_t brr1;
extern const uint8_t brr2;
extern const uint8_t brr3;
extern const uint8_t brr4;
extern const uint8_t _ok;


void _print_arrow(uint8_t board_orientation){
  FontSelector = s16x16;

  switch (board_orientation){
    case 0:
      print_string(&brd_up, 56, 0);
      break;
    case 1:
      print_string(&brd_right, 0, 20);
      break;
    case 2:
      print_string(&brd_down, 56, 38);
      break;
    case 3:
      print_string(&brd_left, 112, 20);
      break;  
  }

}

void _brd_render(uint8_t board_orientation){
    lcd_clear12x16();

    print_string(&brd1, 34, 19);

    _print_arrow(board_orientation);

    FontSelector = f6x8;
    print_string(&backprev, 0, 57);
    print_string(&nextsel, X1, 57); 
}

void _brd_print_warning(){

  lcd_clear12x16();
  print_string(&_saved, 34, 0);

  FontSelector = f6x8;
  Y1 = 17;
  print_string(&brr1, 0, Y1);
  print_string(&brr2, 0, Y1+9);
  print_string(&brr3, 0, Y1+9);
  print_string(&brr4, 0, Y1+9);


  print_string(&_ok, 114, 57);
  lcd_update(); 
  
  wait_for_button(BUTTON_OK);
}

void board_rotation(){
  
  uint8_t pressed = 0;

  if (UserProfile){
    asm_ShowNoAccessDlg(&nadtxt2);
    wait_for_button(BUTTON_OK);
    return;
  }

  uint8_t board_orientation = eeprom_read_byte(eeBoardOrientation);
  board_orientation &= 0x03;

  _brd_render(board_orientation);
  lcd_update();
  while ((pressed = wait_for_button(BUTTON_ANY)) != BUTTON_BACK){
    if (pressed == BUTTON_OK){
      eeprom_write_byte(eeBoardOrientation, board_orientation);
      BoardOrientation = board_orientation;
      _brd_print_warning();
    }

    switch (pressed){
      case BUTTON_UP:
        board_orientation++;
        break;
      case BUTTON_DOWN:
        board_orientation--;
        break;   
    }
    board_orientation &= 0x03;
    _brd_render(board_orientation);
    lcd_update();
  }

}

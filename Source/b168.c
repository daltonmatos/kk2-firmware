
#include "b168.h"
#include "io.h"


uint8_t __print8_decimal(b168_t *number, uint8_t precision){

  uint16_t frac = number->decimal;
  uint16_t digits = 0;
  while (frac && precision){
    frac &= 0x00ff;
    frac *= 10;
    asm_PrintChar((frac >> 8) + 16);
    precision--;
    digits++;
  }
  return digits;
}

uint8_t print_b168(b168_t *number, uint8_t precision){
  uint8_t digits = 0;
  X1 = 10;
  Y1 = 1;
  digits = _print16_signed((number->hi << 8) | number->lo);
  asm_PrintChar('.');
  digits += __print8_decimal(number, precision);
  return ++digits;
}

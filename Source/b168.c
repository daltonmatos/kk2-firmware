
#include "b168.h"
#include "io.h"


uint8_t __print8_decimal(b168_t *number, uint8_t precision){

  uint16_t frac = number->decimal;
  uint16_t digits = 0;
  while (frac && precision){
    frac &= 0x00ff;
    frac *= 10;
    print_char((frac >> 8) + 48);
    precision--;
    digits++;
  }
  return digits;
}

uint8_t print_b168(b168_t *number, uint8_t precision){
  uint8_t digits = 0;
  digits = _print16_signed((number->hi << 8) | number->lo);
  print_char('.');
  digits += __print8_decimal(number, precision);
  if (!number->decimal){
    _print16_signed(0);
  }
  return ++digits;
}


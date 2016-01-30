
#include "b168.h"
#include "io.h"

b168_t *b168_unpack(int32_t _v, b168_t *dest){
  dest->hi = (_v >> 16);
  dest->lo = (_v >> 8);
  dest->decimal = _v;
  return dest;
}

uint8_t __print8_decimal(uint16_t frac, uint8_t precision){

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

uint8_t b168_print(b168_t *number, uint8_t precision, uint8_t x, uint8_t y){
  uint8_t digits = 0;
  int32_t packed = b168_pack(number);

  X1 = x;
  Y1 = y;
  if (packed < 0){
    print_char('-');
    packed = -packed;
  }

  digits = _print16_signed(packed >> 8);
  print_char('.');
  digits += __print8_decimal(packed, precision);
  if (!number->decimal){
    _print16_signed(0);
  }
  return ++digits;
}

b168_t *b168_neg(b168_t *v){
  b168_unpack(-b168_pack(v), v);
}

void b168clr(b168_t *number){
  number->hi = 0;
  number->lo = 0;
  number->decimal = 0;
}

void b168set(b168_t *n, uint8_t c){
  n->hi = c;
  n->lo = c;
  n->decimal = c;
}

void b168mov(b168_t *dest, b168_t *src){
  dest->hi = src->hi;
  dest->lo = src->lo;
  dest->decimal = src->decimal;
}


void b168nmov(b168_t *dest, b168_t *src){
  b168mov(dest, b168_neg(src));
}

#ifndef _B168_H
#define _B168_H

#include <avr/io.h>

typedef struct {
  //int16_t integer;
  int8_t hi;
  uint8_t lo;
  uint8_t decimal;
} b168_t;

#define ENCODE_TO_8BIT_PRECISION(value) ((value) / (1.0/(256.0)))

uint8_t print_b168(b168_t *number, uint8_t precision);

#endif

#ifndef _B168_H
#define _B168_H

#include <avr/io.h>

typedef struct {
  int8_t hi;
  int8_t lo;
  uint8_t decimal;
} b168_t;

#define PRECISION 0.00390625
#define ENCODE3(value) ((int32_t) ((value) / (PRECISION)))
#define b168_load(b168_prt, value) b168_unpack(ENCODE3(value), b168_prt)

#define ENCODE_TO_8BIT_PRECISION(value) ((uint8_t) ((value) / (PRECISION)))

int32_t b168_pack(b168_t *v);
b168_t *b168_unpack(int32_t _v, b168_t *dest);

uint8_t b168_print(b168_t *number, uint8_t precision, uint8_t x, uint8_t y);

void b168fadd(b168_t *a, int16_t value);

b168_t *b168_neg(b168_t *v);
void b168clr(b168_t *v);
void b168set(b168_t *n, uint8_t c);
void b168mov(b168_t *dest, b168_t *src); 
void b168nmov(b168_t *dest, b168_t *src); /* Negate src and move to dest */

/* Implemented in Assembly*/
void b168_add(b168_t *dest, b168_t *a, b168_t *b); /* a + b, stores result inside dest */
/* _mul must receive 3 parameters. Signature must be: (b168_t *dest, b168_t *a, b168_t *b)*/
void b168_mul(b168_t *a, b168_t *b); /* a * b, stores result inside a */

void b168fmul(b168_t *number, uint8_t value); /* multiply number by 2^value */
void b168fdiv(b168_t *number, uint8_t value); /* divide number by 2^value */

/* TODO: Implement */
void b168sub(b168_t *dest, b168_t *a, b168_t *b); /* dest = a -b */
void b168dec(b168_t *number);
void b168inc(b168_t *number);
void b168mov2(b168_t *dest1, b168_t *dest2, b168_t *src); /*moves src to dest1 and dest2 . Will be implemented in C*/
void b168cmp(b168_t *a, b168_t *b);
void b168mac(b168_t *acc, b168_t *n); /* acc = acc * n */

void b168load(b168_t *number); /* xh:xl.yh <- number */
void b168store(b168_t *number); /* number <- xh:xl.yh */

void b168loadz(b168_t *number); /* Z = int(number) */

#endif

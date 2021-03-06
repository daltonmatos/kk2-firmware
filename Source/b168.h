#ifndef _B168_H
#define _B168_H

#include <avr/io.h>

typedef struct {
  int8_t hi;
  int8_t lo;
  uint8_t decimal;
} b168_t;

#define b168_MAX_PRECISION 0.00390625 /* This is the maximum precision represented in 16.8 format. 1/2^8 */
#define ENCODE_TO_b168(value) ((int32_t) ((value) / (b168_MAX_PRECISION)))
#define b168ldi(b168_prt, value) b168_unpack(b168_prt, ENCODE_TO_b168(value))

int32_t b168_pack(b168_t *v);
b168_t *b168_unpack(b168_t *dest, int32_t _v);

uint8_t b168_print(b168_t *number, uint8_t precision, uint8_t x, uint8_t y);

b168_t *b168fadd(b168_t *a, int16_t value);

b168_t *b168_neg(b168_t *v);
void b168clr(b168_t *v);
void b168set(b168_t *n, uint8_t c);
void b168mov(b168_t *dest, b168_t *src); 
void b168nmov(b168_t *dest, b168_t *src); /* Negate src and move to dest */

/* Implemented in Assembly*/
void b168_add(b168_t *dest, b168_t *a, b168_t *b); /* a + b, stores result inside dest */
void b168_mul(b168_t *dest, b168_t *a, b168_t *b); /* a * b, stores result inside dest */

void b168fmul(b168_t *number, uint8_t value); /* multiply number by 2^value */
void b168fdiv(b168_t *number, uint8_t value); /* divide number by 2^value */

b168_t *b168dec(b168_t *number);
b168_t *b168inc(b168_t *number);

/*
 * Returns: 
 *   0 if a == b
 *   1 if a > b
 *  -1 if a < b
 *
 */
int8_t b168cmp(b168_t *a, b168_t *b);
/* TODO: Implement */
void b168sub(b168_t *dest, b168_t *a, b168_t *b); /* dest = a -b */
void b168mov2(b168_t *dest1, b168_t *dest2, b168_t *src); /*moves src to dest1 and dest2 . Will be implemented in C*/
void b168mac(b168_t *acc, b168_t *n); /* acc = acc * n */
void b168load(b168_t *number); /* xh:xl.yh <- number */
void b168store(b168_t *number); /* number <- xh:xl.yh */

void b168loadz(b168_t *number); /* Z = int(number) */

#endif

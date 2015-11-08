#ifndef IO_H
#define IO_H

#define BUTTON_BACK 0x08

extern void asm_PrintString(uint8_t *str_addr);
extern uint8_t asm_GetButtonsBlocking();

void print_string(uint8_t *str_addr, uint8_t x, uint8_t y);


#endif

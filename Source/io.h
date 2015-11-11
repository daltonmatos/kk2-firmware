#ifndef IO_H
#define IO_H

#define BUTTON_OK 0x01
#define BUTTON_DOWN 0x02
#define BUTTON_UP 0x04
#define BUTTON_BACK 0x08

extern void asm_PrintString(const uint8_t *str_addr);
extern uint8_t asm_GetButtonsBlocking();
extern void asm_ShowNoAccessDlg(uint8_t *str);

void print_string(const uint8_t *str_addr, uint8_t x, uint8_t y);
void wait_for_button(uint8_t button);


#endif

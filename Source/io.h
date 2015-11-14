#ifndef IO_H
#define IO_H

#define BUTTON_OK 0x01
#define BUTTON_DOWN 0x02
#define BUTTON_UP 0x04
#define BUTTON_BACK 0x08
#define BUTTON_ANY BUTTON_OK | BUTTON_DOWN | BUTTON_UP | BUTTON_BACK

extern void asm_PrintString(const uint8_t *str_addr);
extern uint8_t asm_GetButtonsBlocking();
extern void asm_ShowNoAccessDlg(uint8_t *str);
extern void asm_Print16Signed(int8_t number);

void print_string(const uint8_t *str_addr, uint8_t x, uint8_t y);
void print_number(int8_t number, uint8_t x, uint8_t y);
uint8_t wait_for_button(uint8_t button_mask);


#endif

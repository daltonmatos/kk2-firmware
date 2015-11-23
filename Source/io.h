#ifndef IO_H
#define IO_H

#define BUTTON_OK 0x01
#define BUTTON_DOWN 0x02
#define BUTTON_UP 0x04
#define BUTTON_BACK 0x08
#define BUTTON_ANY BUTTON_OK | BUTTON_DOWN | BUTTON_UP | BUTTON_BACK

enum {
  HIGHLIGHT_NONE = 1,
  HIGHLIGHT_STRING,
  HIGHLIGHT_FULL_LINE,
  HIGHLIGHT_TO_THE_END_OF_LINE,
  HIGHLIGHT_FROM_BEGINNING_OF_LINE
};

extern void asm_PrintChar(const char ch);
extern uint8_t asm_GetButtonsBlocking();
extern void asm_ShowNoAccessDlg(uint8_t *str);
extern void asm_Print16Signed(int8_t number);
extern void asm_HighlightRectangle();
extern void asm_EnforceRestart();

uint8_t print_string(const uint8_t *str_addr, uint8_t x, uint8_t y);
void print_string_2(const uint8_t *str_addr, uint8_t x, uint8_t y, uint8_t hilight);
void print_number(int8_t number, uint8_t x, uint8_t y);
uint8_t wait_for_button(uint8_t button_mask);
uint8_t show_confirmation_dlg(const uint8_t *str);
void print_selector(uint8_t x1, uint8_t y1, uint8_t x2, uint8_t y2);



#endif

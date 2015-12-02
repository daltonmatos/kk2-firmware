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

uint8_t constrain(int8_t value, uint8_t min, uint8_t max);

uint8_t print_string(const uint8_t *str_addr, uint8_t x, uint8_t y);
void print_string_2(const uint8_t *str_addr, uint8_t x, uint8_t y, uint8_t hilight);
uint8_t print_number(int16_t number, uint8_t x, uint8_t y);
void print_number_2(int16_t number, uint8_t x, uint8_t y, uint8_t hilight);

uint8_t wait_for_button(uint8_t button_mask);
uint8_t show_confirmation_dlg(const uint8_t *str);
uint8_t print16_signed(int16_t n);

#define SHIFT_ADDR_TO_PROFILE(profile, addr) ((addr) | (profile << 8))
#define SHIFT_ADDR_TO_CURRENT_PROFILE(addr) SHIFT_ADDR_TO_PROFILE(UserProfile, addr)

/* UserProfile-aware eeprom functions. Always use the current profile */
uint8_t eepromP_read_byte(const uint8_t *addr);
void eepromP_update_byte(const uint8_t * addr, uint8_t value);
void eepromP_copy_block(const uint8_t * src, const uint8_t *dest, uint8_t count);


void eeprom_copy_block(uint8_t * src, uint8_t *dest, uint8_t count);

#endif

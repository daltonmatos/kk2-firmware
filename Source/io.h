#ifndef IO_H
#define IO_H

#define BUTTON_NONE 0x00
#define BUTTON_OK 0x01
#define BUTTON_DOWN 0x02
#define BUTTON_UP 0x04
#define BUTTON_BACK 0x08
#define BUTTON_ANY BUTTON_OK | BUTTON_DOWN | BUTTON_UP | BUTTON_BACK

#include "ramvariables.h"


enum {
  HIGHLIGHT_NONE = 1,
  HIGHLIGHT_STRING,
  HIGHLIGHT_FULL_LINE,
  HIGHLIGHT_TO_THE_END_OF_LINE,
  HIGHLIGHT_FROM_BEGINNING_OF_LINE
};

extern void asm_ShowNoAccessDlg(const char *str);
extern void asm_EnforceRestart();
extern uint8_t asm_get_mpu_register(uint8_t r);
extern void asm_setup_mpu6050();
extern int16_t asm_NumEdit(int16_t number, int16_t min, int16_t max);

uint8_t constrain(int8_t value, uint8_t min, uint8_t max);

void _sprite(const char *bitmap, uint8_t w, uint8_t h, uint8_t bytes, uint8_t x, uint8_t y);
uint8_t print_string(const char *str_addr, uint8_t x, uint8_t y);
void print_string_2(const char *str_addr, uint8_t x, uint8_t y, uint8_t hilight);
uint8_t print_number(int16_t number, uint8_t x, uint8_t y);
uint8_t print_number_2(int16_t number, uint8_t x, uint8_t y, uint8_t hilight);

uint8_t wait_for_button(uint8_t button_mask);
uint8_t show_confirmation_dlg(const char *str);
uint8_t _print16_signed(int16_t n);

void print_char(const char ch);
void print_bits32(int32_t n, uint8_t x, uint8_t y);
void print_bits16(int16_t n, uint8_t x, uint8_t y);
void print_bits8(int8_t n, uint8_t x, uint8_t y);
#define SHIFT_ADDR_TO_PROFILE(profile, addr) ((addr) | (profile << 8))
#define SHIFT_ADDR_TO_CURRENT_PROFILE(addr) SHIFT_ADDR_TO_PROFILE(UserProfile, addr)

/* UserProfile-aware eeprom functions. Always use the current profile */
uint8_t eepromP_read_byte(const uint8_t *addr);
void eepromP_update_byte(const uint8_t * addr, uint8_t value);

int16_t eepromP_read_word(const uint16_t *addr);
void eepromP_update_word(const uint16_t * addr, uint16_t value);

void eepromP_copy_block(const uint8_t * src, const uint8_t *dest, uint8_t count);


void eeprom_copy_block(uint8_t * src, uint8_t *dest, uint8_t count);

int16_t numedit(int16_t initial_value, int16_t min, int16_t max);

void print_std_footer();
void print_ok_footer();
void print_back_chg_footer();
void print_back_nxt_ok_footer();
void print_title(const char *title);

#endif

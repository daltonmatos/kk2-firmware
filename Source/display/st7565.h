#ifndef ST7565_H
#define ST7565_H

#include <avr/io.h>

#define LCDWIDTH 128
#define LCDHEIGHT 64

/*#define lcd_cs1		portd, 5
#define lcd_res		portd, 6
#define lcd_a0		portd, 7
#define	lcd_scl		portd, 4
#define	lcd_si		portd, 1
*/

#define CMD_DISPLAY_OFF   0xAE
#define CMD_DISPLAY_ON    0xAF

#define CMD_SET_DISP_START_LINE  0x40
#define CMD_SET_PAGE  0xB0

#define CMD_SET_COLUMN_UPPER  0x10
#define CMD_SET_COLUMN_LOWER  0x00

#define CMD_SET_ADC_NORMAL  0xA0
#define CMD_SET_ADC_REVERSE 0xA1

#define CMD_SET_DISP_NORMAL 0xA6
#define CMD_SET_DISP_REVERSE 0xA7

#define CMD_SET_ALLPTS_NORMAL 0xA4
#define CMD_SET_ALLPTS_ON  0xA5
#define CMD_SET_BIAS_9 0xA2 
#define CMD_SET_BIAS_7 0xA3

#define CMD_RMW  0xE0
#define CMD_RMW_CLEAR 0xEE
#define CMD_INTERNAL_RESET  0xE2
#define CMD_SET_COM_NORMAL  0xC0
#define CMD_SET_COM_REVERSE  0xC8
#define CMD_SET_POWER_CONTROL  0x28
#define CMD_SET_RESISTOR_RATIO  0x20
#define CMD_SET_VOLUME_FIRST  0x81
#define CMD_SET_VOLUME_SECOND  0
#define CMD_SET_STATIC_OFF  0xAC
#define CMD_SET_STATIC_ON  0xAD
#define CMD_SET_STATIC_REG  0x0
#define CMD_SET_BOOSTER_FIRST  0xF8
#define CMD_SET_BOOSTER_234  0
#define CMD_SET_BOOSTER_5  1
#define CMD_SET_BOOSTER_6  3
#define CMD_NOP  0xE3
#define CMD_TEST  0xF0

#define LCD_BUFFER 0x0100
#define LCD_BUFFER_ptr ((uint8_t *) LCD_BUFFER)


#define swap(a, b) { uint8_t t = a; a = b; b = t; }
void setpixel(uint8_t *buff, uint8_t x, uint8_t y, uint8_t color);
void __setpixel(uint8_t x, uint8_t y);

void drawrect(uint8_t *buff,
	      uint8_t x, uint8_t y, uint8_t w, uint8_t h, 
	      uint8_t color);
void __drawline(uint8_t x0, uint8_t y0, uint8_t x1, uint8_t y1);


void drawbitmap(uint8_t *buff, uint8_t x, uint8_t y, 
		const uint8_t bitmap, uint8_t w, uint8_t h,
		uint8_t color);
void drawchar(uint8_t *buff, uint8_t x, uint8_t line, uint8_t c);
void drawcircle(uint8_t *buff,
	      uint8_t x0, uint8_t y0, uint8_t r, 
		uint8_t color);

void fillrect(uint8_t *buff,
	      uint8_t x, uint8_t y, uint8_t w, uint8_t h, 
	      uint8_t color);

void __fillrect(uint8_t x1, uint8_t y1, uint8_t x2, uint8_t y2);

void setup_display();
void lcd_clear();
void lcd_update();
void lcd_command(uint8_t command);

void lcd_clear12x16();
void lcd_load_contrast();

#endif

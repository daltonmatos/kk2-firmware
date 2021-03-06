/*
$Id:$

ST7565 LCD library!

Copyright (C) 2010 Limor Fried, Adafruit Industries

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/

#include <avr/io.h>
#include <avr/eeprom.h>
#include <stdlib.h>
#include <avr/pgmspace.h> 
#include <string.h>
#include <util/delay.h>

#include "st7565.h"
#include "../ramvariables.h"
#include "../constants.h"
#include "../eepromvariables.h"
#include "../io.h"

#define LCD_CS1		5
#define LCD_RES		6
#define LCD_A0		7
#define	LCD_SCL		4
#define	LCD_SI		1

void setup_display(){
	
  DDRD = 0xF2; //0b11110010

	//ldi t,0b00001101	;turn on pull ups on thr, ele and ail
  PORTD = 0x0D;

  PORTD |= _BV(LCD_CS1);
	PORTD |= _BV(LCD_SCL);
  PORTD &= ~_BV(LCD_RES);
  PORTD |= _BV(LCD_RES);
}

void lcd_clear(){
  memset((uint8_t *) LCD_BUFFER, 0, 1024);
}

void lcd_clear12x16(){
  lcd_clear();
  PixelType = 1;
  FontSelector = f12x16;
  Y1 = 0;
}

void lcd_load_contrast(){
  LcdContrast = eeprom_read_byte(eeLcdContrast);
}

void SetDefaultLcdContrast(){
  LcdContrast = 0x24;
  eeprom_write_byte(eeLcdContrast, 0x24);
}

void lcd_raw(uint8_t comm){

  PORTD &= ~_BV(LCD_CS1);
  //_delay_us(4);
  for (uint8_t i=0; i < 8; i++){
   (comm & 0x80) ? (PORTD |= _BV(LCD_SI)) : (PORTD &= ~_BV(LCD_SI));
   //_delay_us(4);
   PORTD &= ~_BV(LCD_SCL); // cbi lcd_scl
   //_delay_us(4);
   PORTD |= _BV(LCD_SCL);
   comm <<= 1;    
  }

  PORTD |= _BV(LCD_CS1);
}

void lcd_data(uint8_t data){
  PORTD |= _BV(LCD_A0);
  lcd_raw(data);
  //spiwrite(data);
}

void lcd_command(uint8_t command){
  PORTD &= ~_BV(LCD_A0);
  lcd_raw(command);
  //spiwrite(command);
}

void lcd_update_commands(){

  lcd_command(CMD_DISPLAY_ON); // 0xaf
  lcd_command(CMD_SET_DISP_START_LINE); // 0x40		;LCD ON		Display start line set
	lcd_command(CMD_SET_ADC_NORMAL); // 0xa0
  lcd_command(CMD_SET_DISP_NORMAL); // 0xa6		;ADC		nor/res
	lcd_command(CMD_SET_ALLPTS_NORMAL); // 0xa4
  lcd_command(CMD_SET_BIAS_9); // 0xa2		;disp normal	bias 1/9
	lcd_command(CMD_RMW_CLEAR); // 0xee, 
  lcd_command(CMD_SET_COM_REVERSE); // 0xc8		;end		COM
	lcd_command(0x2f); // 
  lcd_command(0x24); //		;power control	Vreg int res ratio
	lcd_command(CMD_SET_STATIC_OFF); // 0xac
  lcd_command(CMD_SET_COLUMN_LOWER); // 0x00		;static off
	lcd_command(CMD_SET_BOOSTER_FIRST); // 0xf8
  lcd_command(CMD_SET_COLUMN_LOWER); // 0x00		;booster ratio
	lcd_command(CMD_NOP); // 0xe3 
  
  /* Set contrast */
  lcd_command(0x81);
  lcd_command(LcdContrast);
}

void lcd_update(){

  lcd_update_commands();
  
  uint16_t volatile buffer_base = LCD_BUFFER;

	/* Transfer image data */
  for (uint8_t page = 0xb0; page < 0xb8; page++){
    lcd_command(page); /* set page address */
    
    /* Set column address */
    lcd_command(0x10);
    lcd_command(0x00);

    /* Transfer one page */
    for (uint8_t page_bit = 0; page_bit < 128; page_bit++){
      lcd_data(*(uint8_t_prt(buffer_base++)));
    }
  }
}


// the most basic function, set a single pixel
void __setpixel(uint8_t x, uint8_t y) {
  if ((x >= LCDWIDTH) || (y >= LCDHEIGHT))
    return;

  uint8_t xl = (y % 8) + 1;
  uint8_t xh = (_BV(0) << (xl - 1));
  uint16_t buff_pos = x + (y/8)*128;
  switch (PixelType){
    case 0: // XOR
      LCD_BUFFER_ptr[buff_pos] ^= xh;
      break;
    case 1: // OR
      //LCD_BUFFER_ptr[x+ (y/8)*128] |= _BV(7-(y%8));  
      LCD_BUFFER_ptr[buff_pos] |= xh; 
      break;
    case 2: // AND
      //LCD_BUFFER_ptr[x+ (y/8)*128] &= ~_BV(7-(y%8)); 
      LCD_BUFFER_ptr[buff_pos] &= (xh ^ 0xFF); 
      break;
  
  }
}

/*
void drawbitmap(uint8_t *buff, uint8_t x, uint8_t y, 
		const uint8_t bitmap, uint8_t w, uint8_t h,
		uint8_t color) {
  for (uint8_t j=0; j<h; j++) {
    for (uint8_t i=0; i<w; i++ ) {
      if (pgm_read_byte(bitmap + i + (j/8)*w) & _BV(j%8)) {
	      setpixel(buff, x+i, y+j, color);
      }
    }
  }


}
*/

/*void drawstring(uint8_t *buff, uint8_t x, uint8_t line, uint8_t *c) {
  while (c[0] != 0) {
    uart_putchar(c[0]);
    drawchar(buff, x, line, c[0]);
    c++;
    x += 6; // 6 pixels wide
    if (x + 6 >= LCDWIDTH) {
      x = 0;    // ran out of this line
      line++;
    }
    if (line >= (LCDHEIGHT/8))
      return;        // ran out of space :(
  }

}

*/
/*
void drawchar(uint8_t *buff, uint8_t x, uint8_t line, uint8_t c) {
  for (uint8_t i =0; i<5; i++ ) {
    buff[x + (line*128) ] = pgm_read_byte(font+(c*5)+i);
    x++;
  }
}
*/

// bresenham's algorithm - thx wikpedia
void __drawline(uint8_t x0, uint8_t y0, uint8_t x1, uint8_t y1) {

  uint8_t steep = abs(y1 - y0) > abs(x1 - x0);
  if (steep) {
    swap(x0, y0);
    swap(x1, y1);
  }

  if (x0 > x1) {
    swap(x0, x1);
    swap(y0, y1);
  }

  uint8_t dx, dy;
  dx = x1 - x0;
  dy = abs(y1 - y0);

  int8_t err = dx / 2;
  int8_t ystep;

  if (y0 < y1) {
    ystep = 1;
  } else {
    ystep = -1;}

  for (; x0<x1; x0++) {
    if (steep) {
      __setpixel(y0, x0);
    } else {
      __setpixel(x0, y0);
    }
    err -= dy;
    if (err < 0) {
      y0 += ystep;
      err += dx;
    }
  }
}

void __attribute__((optimize("O0"))) __fillrect(uint8_t x, uint8_t y, uint8_t w, uint8_t h) {
  uint8_t i = 0;
  uint8_t j = 0;

  // stupidest version - just pixels - but fast with internal buffer!
  for (i=x; i<w; i++) {
    for (j=y; j<h; j++) {
      __setpixel(i, j);
    }
  }
}

// filled rectangle
/*
void fillrect(uint8_t *buff,
	      uint8_t x, uint8_t y, uint8_t w, uint8_t h, 
	      uint8_t color) {

  // stupidest version - just pixels - but fast with internal buffer!
  for (uint8_t i=x; i<x+w; i++) {
    for (uint8_t j=y; j<y+h; j++) {
      setpixel(buff, i, j, color);
    }
  }
}
*/

void __drawrect(uint8_t x, uint8_t y, uint8_t w, uint8_t h) {
  // stupidest version - just pixels - but fast with internal buffer!
  for (uint8_t i=x; i<x+w; i++) {
    __setpixel(i, y);
    __setpixel(i, y+h-1);
  }
  for (uint8_t i=y; i<y+h; i++) {
    __setpixel(x, i);
    __setpixel(x+w-1, i);
  } 
}

// draw a rectangle
/*
void drawrect(uint8_t *buff,
	      uint8_t x, uint8_t y, uint8_t w, uint8_t h, 
	      uint8_t color) {
  // stupidest version - just pixels - but fast with internal buffer!
  for (uint8_t i=x; i<x+w; i++) {
    setpixel(buff, i, y, color);
    setpixel(buff, i, y+h-1, color);
  }
  for (uint8_t i=y; i<y+h; i++) {
    setpixel(buff, x, i, color);
    setpixel(buff, x+w-1, i, color);
  } 
}
*/

// draw a circle
/*
void drawcircle(uint8_t *buff,
	      uint8_t x0, uint8_t y0, uint8_t r, 
	      uint8_t color) {
  int8_t f = 1 - r;
  int8_t ddF_x = 1;
  int8_t ddF_y = -2 * r;
  int8_t x = 0;
  int8_t y = r;

  setpixel(buff, x0, y0+r, color);
  setpixel(buff, x0, y0-r, color);
  setpixel(buff, x0+r, y0, color);
  setpixel(buff, x0-r, y0, color);

  while (x<y) {
    if (f >= 0) {
      y--;
      ddF_y += 2;
      f += ddF_y;
    }
    x++;
    ddF_x += 2;
    f += ddF_x;
  
    setpixel(buff, x0 + x, y0 + y, color);
    setpixel(buff, x0 - x, y0 + y, color);
    setpixel(buff, x0 + x, y0 - y, color);
    setpixel(buff, x0 - x, y0 - y, color);
    
    setpixel(buff, x0 + y, y0 + x, color);
    setpixel(buff, x0 - y, y0 + x, color);
    setpixel(buff, x0 + y, y0 - x, color);
    setpixel(buff, x0 - y, y0 - x, color);
    
  }
}
*/

// draw a circle
/*
void fillcircle(uint8_t *buff,
	      uint8_t x0, uint8_t y0, uint8_t r, 
	      uint8_t color) {
  int8_t f = 1 - r;
  int8_t ddF_x = 1;
  int8_t ddF_y = -2 * r;
  int8_t x = 0;
  int8_t y = r;

  for (uint8_t i=y0-r; i<=y0+r; i++) {
    setpixel(buff, x0, i, color);
  }

  while (x<y) {
    if (f >= 0) {
      y--;
      ddF_y += 2;
      f += ddF_y;
    }
    x++;
    ddF_x += 2;
    f += ddF_x;
  
    for (uint8_t i=y0-y; i<=y0+y; i++) {
      setpixel(buff, x0+x, i, color);
      setpixel(buff, x0-x, i, color);
    } 
    for (uint8_t i=y0-x; i<=y0+x; i++) {
      setpixel(buff, x0+y, i, color);
      setpixel(buff, x0-y, i, color);
    }    
  }
}
*/


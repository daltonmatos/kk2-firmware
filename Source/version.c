
#include <avr/io.h>
#include <util/delay.h>
#include <avr/pgmspace.h>
#include "ramvariables.h"
#include "flashvariables.h"
#include "display/st7565.h"
#include "constants.h"

extern void asm_PrintString();
extern void asm_LcdUpdate();

void show_version(){

  //lcd_clear();
  
  PixelType = 1;
  FontSelector = f12x16;
  Y1 = 0;
  X1 = 22;

  /* Address of uint8_t ver1; */  
  __asm__ ("ldi r31, 0x55");
  __asm__ ("ldi r30, 0x4C");

  asm_PrintString();


  Y1 = 17;
  FontSelector = f12x16;
  Y1 = 0;

  /* Print version info */
//	ldi t, 4				;print version information
//	ldz ver10*2
//	call PrintStringArray

//	lrv X1, 36				;print RX mode
//	lrv Y1, 26
//	lds t, RxMode
//	ldz modes*2
//	call PrintFromStringArray
//
//	;footer
//	call PrintBackFooter

  //lcd_update();
  asm_LcdUpdate();

//ver12:	call GetButtonsBlocking
//	cpi t, 0x08				;BACK?
//	brne ver12
//	ret

/*  uint8_t button = __get_buttons_blocking();
  while (button != 0x08){
    button = __get_buttons_blocking();
  }
*/

  while (1){}

}


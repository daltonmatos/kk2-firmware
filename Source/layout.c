#include <avr/io.h>
#include <avr/pgmspace.h>
#include <avr/eeprom.h>

#include "display/st7565.h"
#include "io.h"
#include "eepromvariables.h"
#include "ramvariables.h"
#include "constants.h"
#include "b168.h"
#include "menu.h"
#include "layout.h"


void load_mixer_table(){
  uint8_t count= 0;
  int8_t byte = 0;

  for (count = 0; count < 64; count++){
    byte = eeprom_read_byte(EeMixerTable + count);
    RamMixerTable[count] = byte;
  } 

}

#define IS_HIGH(flag)  ((flag) & 0x02)
#define IS_ESC(flag)   ((flag) & 0x01)

#define X_OFFSET 96
#define Y_OFSET  32


int8_t calculate_position(int16_t mixvalue, b168_t *mult_factor, uint8_t pos_offset){
      b168_unpack(Temp, mixvalue);
      b168_mul(Temp, Temp, mult_factor);
      b168fadd(Temp, pos_offset);
      return (b168_pack(Temp) >> 8);
}

void show_motor(uint8_t motor, uint8_t volatile showing_all){
    /*
     * x1 = (roll * .25) + xoff
     * y1 = (pitch * -.25) + yoff
     * x2 = xoff (96)
     * y2 = yoff (32)
     * symbol: (symbol16x16)
     *  yaw < 0 ? s=2 : s=3
     *  x1 = x1 - 4
     *  y1 = y1 - 7
     */ 
    uint8_t volatile x1 = 0;
    uint8_t volatile y1 = 0;
    /* bit0 (ESC=1 or Servo=0) 
     * bit1 (high=1 ow low=0) If ESC, always high. 
     * flag is a byte. Only uses 2 lowest bits ......b1b0
     **/
    uint8_t m_flags = 0;
    uint8_t volatile current_motor = motor;

    int8_t thr = RamMixerTable[(motor * 8) + RamTableThrotleOffset];
    int8_t roll = RamMixerTable[(motor * 8) + RamTableRollOffset];
    int8_t pitch = RamMixerTable[(motor * 8) + RamTablePitchOffset];
    int8_t volatile yaw = RamMixerTable[(motor * 8) + RamTableYawOffset];
    int8_t used = thr | roll | pitch | yaw;

    m_flags = RamMixerTable[(motor * 8) + RamTableMotorFlagsOffset];

    FontSelector = f6x8;
    PixelType = 1;
    
    if (showing_all && !IS_ESC(m_flags)){
      return;
    }

    if (used && IS_ESC(m_flags)){
      b168ldi(Temp2, 0.25);
      x1 = calculate_position(roll << 8, Temp2, X_OFFSET);


      b168_neg(Temp2);
      y1 = calculate_position(pitch << 8, Temp2, Y_OFSET);

      if (!showing_all){
        print_string(&direction_label0, 0, 15);
        print_string(&direction_label1, 0, 24);
        print_string(&direction_label2, 0, 33);
        yaw < 0 ? print_string(&_CCW, 36, 33) : print_string(&_CW, 36, 33);
      }

      FontSelector = s16x16;
      uint8_t motor_number_x = x1 - 4;
      uint8_t motor_number_y = y1 - 7;

      X1 = motor_number_x;
      Y1 = motor_number_y;
      if (yaw < 0){
        print_char(2); //CCW
      }else{
        print_char(3); //CW
      }

      __drawline(x1, y1, 96, 32);
      
      FontSelector = f4x6;
      X1 = motor_number_x + 2; Y1 = motor_number_y + 5;
      PixelType = 0;
      print_char(current_motor); // Motor number inside symbol

      FontSelector = f6x8;
      PixelType = 1;
    }else if (used && !IS_ESC(m_flags)){
      print_string(&servo, 66, 27);
    }else if (!used){
      print_string(&unused_motor, 66, 27);
    }
    print_string(&motor_label, 0, 0);
    if (showing_all){
      print_string(&_all, 40, 0);
    }else{
      print_number(current_motor + 1, 40, 0);
    }
}



void layout_render(uint8_t selected_motor){
  uint8_t motor = 0;

  if (selected_motor <= 7){
    lcd_clear();
    show_motor(selected_motor, 0);
  }else{
    for (motor = 0; motor < 8; motor++){
      show_motor(motor, 1);
    }
  }
}


void show_layout(){
  
  ScreenData->title = 0;
  ScreenData->footer_callback = &print_back_nxt_ok_footer;
  ScreenData->options = 0;
  ScreenData->ok_callback = &layout_render;
  ScreenData->render_callback = &layout_render;
  ScreenData->total_options = 9;
  ScreenData->initial_option = 9;

  int8_t layout_loaded = eeprom_read_byte(eeMotorLayoutOK);

  if (!layout_loaded){
    lcd_clear();
    FontSelector = f6x8;
    PixelType = 1;
    print_title(&noaccess);
    print_string(&no_motor_layout0, 0, 30);
    print_string(&no_motor_layout1, 0, 40);
    print_string(&_ok, 114, 57);
    lcd_update();
    wait_for_button(BUTTON_OK);
    return;
  }

  load_mixer_table();
  render_screen(ScreenData);
}

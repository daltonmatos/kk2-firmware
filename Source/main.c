#include <avr/io.h>
#include <avr/eeprom.h>
#include <avr/pgmspace.h>

#include "constants.h"
#include "ramvariables.h"
#include "eepromvariables.h"
#include "flashvariables.h"
#include "display/st7565.h"
#include "channelmapping.h"

typedef void (*entrypoint_ptr)();

int c_main(){

  RxMode = eeprom_read_byte(eeRxMode);

  UserProfile = eeprom_read_byte(eeUserProfile);
  UserProfile &= 0x03;

  flagGimbalMode = eeprom_read_byte(eeGimbalMode);

  setup_display();
  lcd_load_contrast();

  /* Setup input buttons.
   * This is here for now, until we have a full setup_hardware() function
   */
  DDRB = 0x0A;
  PORTB = 0xF5;
  
  _cm_copy_mapping_to_sram();
  FontSelector = f6x8;
  if (!_cm_mapping_is_ok()){
    _cm_show_channelmaping_error();
    channel_mapping();
  }
  
  ((entrypoint_ptr) pgm_read_word(&entrypoints + RxMode*2))();

}

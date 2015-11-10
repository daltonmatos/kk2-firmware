#include <avr/io.h>
#include <avr/eeprom.h>
#include <avr/pgmspace.h>

#include "constants.h"
#include "ramvariables.h"
#include "eepromvariables.h"
#include "flashvariables.h"

typedef void (*entrypoint_ptr)();

int c_main(){

  RxMode = eeprom_read_byte((uint8_t *) eeRxMode);

  UserProfile = eeprom_read_byte((uint8_t *) eeUserProfile);
  UserProfile &= 0x03;

  ((entrypoint_ptr) pgm_read_word(&entrypoints + RxMode*2))();

}

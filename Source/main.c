#include <avr/io.h>
#include <avr/eeprom.h>
#include <avr/pgmspace.h>

#include "constants.h"
#include "ramvariables.h"
#include "eepromvariables.h"

/* These calls do not need any reg saving since until now 
 * no original assembly code has not run, so we are not
 * trashing any registers 
 */ 
extern void Main();
extern void CppmMain();
extern void SBusMain();
extern void SatelliteMain();

/*void safe_call_from_c(){
  __asm__ ("push r24\n\t"
           "push r25\n\t");
  Main();
}*/

void write_to_ram_address(uint8_t *address, uint8_t data){
  (*(uint8_t *) address) = data;
}

int c_main(){

  uint8_t rx_mode;
  rx_mode = eeprom_read_byte((uint8_t *) eeRxMode);
  write_to_ram_address((uint8_t *) RxMode, rx_mode);

  uint8_t user_profile = eeprom_read_byte((uint8_t *) eeUserProfile);
  user_profile &= 0x03;
  write_to_ram_address((uint8_t *) UserProfile, user_profile);

  switch (rx_mode){
    case RxModeStandard:
      Main();
      break;
    case RxModeCppm:
      CppmMain();
      break;
    case RxModeSBus:
      SBusMain();
      break;
    case RxModeSatDSMX:
    case RxModeSatDSM2:
      SatelliteMain();
      break;  
  }

}

#include <avr/io.h>
#include <avr/eeprom.h>

#define	RxModeStandard 0
#define	RxModeCppm 1
#define	RxModeSBus 2
#define	RxModeSatDSM2 3
#define	RxModeSatDSMX 4

#define eeRxMode 0x0071

#define RxMode 0x074D

extern void Main();
extern void CppmMain();
extern void SBusMain();
extern void SatelliteMain();


void write_to_ram_address(uint8_t *address, uint8_t data){
  (*(uint8_t *) address) = data;
}


int c_main(){

 
  uint8_t rx_mode;
  rx_mode = eeprom_read_byte((uint8_t *) eeRxMode);
  write_to_ram_address((uint8_t *) RxMode, rx_mode);

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

#ifndef EEPROM_VARIABLES_H
#define EEPROM_VARIABLES_H

#define uint8_t_prt(a) ((uint8_t *) (a))
#define EEPROM_VARIABLE(addr) ((uint8_t_prt(addr)))

#define eeLcdContrast EEPROM_VARIABLE(0x0070)
#define eeRxMode      EEPROM_VARIABLE(0x0071)
#define eeUserProfile EEPROM_VARIABLE(0x0073)
#define eeEscCalibration EEPROM_VARIABLE(0x0074)
#define eeGimbalMode EEPROM_VARIABLE(0x0077)





#define eeBoardOrientation EEPROM_VARIABLE(0x0079)

#define eeLinkRollPitch EEPROM_VARIABLE(0x00AC)
#define eeAutoDisarm EEPROM_VARIABLE(0x00AD)
#define eeButtonBeep EEPROM_VARIABLE(0x00AE)
#define eeArmingBeeps EEPROM_VARIABLE(0x00AF)

#define eeButtonBeep EEPROM_VARIABLE(0x00AE)

#endif


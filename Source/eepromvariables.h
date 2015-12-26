#ifndef EEPROM_VARIABLES_H
#define EEPROM_VARIABLES_H

#define uint8_t_prt(a) ((uint8_t *) (a))
#define EEPROM_VARIABLE(addr) ((uint8_t_prt(addr)))

#define uint16_t_ptr(a) ((uint16_t *) (a))
#define EEPROM16_VARIABLE(addr) ((uint16_t_ptr(addr)))


/* 
* Aileron gains EEProm address: 0x44 to 0x4B
* Elevator gains address: 0x4C to 0x53
* Rudder gains address: 0x54 to 0x5B
* Each gain is 1 word (2 bytes each), with this order:
* P Gain
* P Limit
* I Gain
* I Limit
*/
#define	eeParameterTable 0x0044
#define	eeParameterTableAileron EEPROM_VARIABLE(eeParameterTable)
#define	eeParameterTableElevator EEPROM_VARIABLE(eeParameterTable + 8)
#define	eeParameterTableRudder EEPROM_VARIABLE(eeParameterTable + 16)


#define eeLcdContrast EEPROM_VARIABLE(0x0070)
#define eeRxMode      EEPROM_VARIABLE(0x0071)
#define eeUserProfile EEPROM_VARIABLE(0x0073)
#define eeEscCalibration EEPROM_VARIABLE(0x0074)
#define eeGimbalMode EEPROM_VARIABLE(0x0077)





#define eeBoardOrientation EEPROM_VARIABLE(0x0079)

#define eeStickScaleRoll      EEPROM16_VARIABLE(0x007e)
#define eeStickScalePitch     EEPROM16_VARIABLE(0x0080)
#define eeStickScaleYaw       EEPROM16_VARIABLE(0x0082)
#define eeStickScaleThrottle  EEPROM16_VARIABLE(0x0084)
#define eeStickScaleSlMixing  EEPROM16_VARIABLE(0x0086)
#define eeSelflevelPgain  EEPROM16_VARIABLE(0x0088)
#define eeSelflevelPlimit EEPROM16_VARIABLE(0x008a)
#define eeAccTrimRoll     EEPROM16_VARIABLE(0x008c)
#define eeAccTrimPitch    EEPROM16_VARIABLE(0x008e)
#define eeSlMixRate       EEPROM16_VARIABLE(0x0090)
#define eeEscLowLimit       EEPROM16_VARIABLE(0x0092)
#define eeStickDeadZone     EEPROM16_VARIABLE(0x0094)
#define eeBattAlarmVoltage  EEPROM16_VARIABLE(0x0096)
#define eeServoFilter       EEPROM16_VARIABLE(0x0098)
#define eeUnused              EEPROM16_VARIABLE(0x009a)

#define eeChannelRoll_addr    0x009c
#define eeChannelRoll         EEPROM_VARIABLE(eeChannelRoll_addr)
#define eeChannelPitch        EEPROM_VARIABLE(0x009d)
#define eeChannelThrottle     EEPROM_VARIABLE(0x009e)
#define eeChannelYaw          EEPROM_VARIABLE(0x009f)
#define eeChannelAux          EEPROM_VARIABLE(0x00a0)
#define eeChannelAux2         EEPROM_VARIABLE(0x00a1)
#define eeChannelAux3         EEPROM_VARIABLE(0x00a2)
#define eeChannelAux4         EEPROM_VARIABLE(0x00a3)

#define eeSatChannelRoll_addr 0x00a4
#define eeSatChannelRoll      EEPROM_VARIABLE(eeSatChannelRoll_addr)
#define eeSatChannelPitch     EEPROM_VARIABLE(0x00a5)
#define eeSatChannelThrottle  EEPROM_VARIABLE(0x00a6)
#define eeSatChannelYaw       EEPROM_VARIABLE(0x00a7)
#define eeSatChannelAux       EEPROM_VARIABLE(0x00a8)
#define eeSatChannelAux2      EEPROM_VARIABLE(0x00a9)
#define eeSatChannelAux3      EEPROM_VARIABLE(0x00aa)
#define eeSatChannelAux4      EEPROM_VARIABLE(0x00ab)

#define eeLinkRollPitch EEPROM_VARIABLE(0x00AC)
#define eeAutoDisarm EEPROM_VARIABLE(0x00AD)
#define eeButtonBeep EEPROM_VARIABLE(0x00AE)
#define eeArmingBeeps EEPROM_VARIABLE(0x00AF)

#define eeButtonBeep EEPROM_VARIABLE(0x00AE)

#define eeSensorsCalibrated EEPROM_VARIABLE(0x00BE)

#define eeMpuFilter EEPROM_VARIABLE(0x00CA)
#define eeMpuGyroCfg EEPROM_VARIABLE(0x00CB)
#define eeMpuAccCfg EEPROM_VARIABLE(0x00CC)

#endif


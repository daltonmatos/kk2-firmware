#ifndef RAM_VARIABLES_H
#define RAM_VARIABLES_H

#include "b168.h"
#include "menu.h"

#define uint8_t_prt(a) ((uint8_t *) (a))
#define RAM_VARIABLE(addr) (*(uint8_t_prt(addr)))

#define uint16_t_ptr(a) ((uint16_t *) (a))
#define RAM16_VARIABLE(addr) (*(uint16_t_ptr(addr)))

#define RamMixerTable_addr 0x0500
#define RamMixerTable ((int8_t *)(RamMixerTable_addr))

#define Temp          ((b168_t *) 0x0540)
#define Temp2         ((b168_t *) 0x0543)
#define Temper        ((b168_t *) 0x0546)
#define StickDeadZone ((b168_t *) 0x0606) // 16.8 format (3 bytes)

#define MpuFilter  RAM_VARIABLE(0x073A) 
#define MpuAccCfg  RAM_VARIABLE(0x073B) 
#define MpuGyroCfg RAM_VARIABLE(0x073C) 
#define XPos RAM_VARIABLE(0x073D)
#define YPos RAM_VARIABLE(0x073E)
#define X1 RAM_VARIABLE(0x073F)
#define Y1 RAM_VARIABLE(0x0740)
#define X2 RAM_VARIABLE(0x0741)
#define Y2 RAM_VARIABLE(0x0742)

#define PixelType RAM_VARIABLE(0x0743)
#define FontSelector RAM_VARIABLE(0x0744)

#define BoardOrientation RAM_VARIABLE(0x0749)

#define RxMode RAM_VARIABLE(0x074D)

#define flagRollPitchLink RAM_VARIABLE(0x076C)

#define flagGimbalMode RAM_VARIABLE(0x077A)

#define LcdContrast RAM_VARIABLE(0x07A3)

#define BtnReversed RAM_VARIABLE(0x0791)


#define MappedChannel1_addr 0x07c2
#define MappedChannelArray ((uint8_t *) (MappedChannel1_addr))
#define MappedChannel1 RAM_VARIABLE(MappedChannel1_addr)
#define MappedChannel2 RAM_VARIABLE(0x07c3)
#define MappedChannel3 RAM_VARIABLE(0x07c4)
#define MappedChannel4 RAM_VARIABLE(0x07c5)
#define MappedChannel5 RAM_VARIABLE(0x07c6)
#define MappedChannel6 RAM_VARIABLE(0x07c7)
#define MappedChannel7 RAM_VARIABLE(0x07c8)
#define MappedChannel8 RAM_VARIABLE(0x07c9)

#define DG2Functions RAM_VARIABLE(0x07d9)
#define UserProfile RAM_VARIABLE(0x0803)

#define MenuState ((menu_state_t *) 0x0807)
#define ScreenData ((menu_t *) 0x0809)

#endif

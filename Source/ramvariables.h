#ifndef RAM_VARIABLES_H
#define RAM_VARIABLES_H

#define uint8_t_prt(a) ((uint8_t *) (a))
#define RAM_VARIABLE(addr) (*(uint8_t_prt(addr)))

#define XPos RAM_VARIABLE(0x073D)
#define YPos RAM_VARIABLE(0x073E)
#define X1 RAM_VARIABLE(0x073F)
#define Y1 RAM_VARIABLE(0x0740)
#define X2 RAM_VARIABLE(0x0741)
#define Y2 RAM_VARIABLE(0x0742)

#define PixelType RAM_VARIABLE(0x0743)
#define FontSelector RAM_VARIABLE(0x0744)

#define RxMode RAM_VARIABLE(0x074D)

#define LcdContrast RAM_VARIABLE(0x07A3)

#define UserProfile RAM_VARIABLE(0x0803)

#endif

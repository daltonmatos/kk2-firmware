#ifndef RAM_VARIABLES_H
#define RAM_VARIABLES_H

#define uint8_t_prt(a) ((uint8_t *) (a))
#define RAM_VARIABLE(addr) (*(uint8_t_prt(addr)))

#define XPos RAM_VARIABLE(0x073D)
#define YPos RAM_VARIABLE(0x073E)
#define X1 RAM_VARIABLE(0x073F)
#define Y1 RAM_VARIABLE(0x0740)

#define PixelType RAM_VARIABLE(0x0743)
#define FontSelector RAM_VARIABLE(0x0744)

#define RxMode 0x074D
#define UserProfile 0x0803

#endif

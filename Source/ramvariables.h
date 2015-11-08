#ifndef RAM_VARIABLES_H
#define RAM_VARIABLES_H

#define uint8_t_prt(a) ((uint8_t *) (a))

#define __XPos 0x073D
#define XPos (*(uint8_t_prt(__XPos)))

#define __YPos 0x073E
#define YPos (*(uint8_t_prt(__YPos)))

#define __PixelType 0x0743
#define PixelType (*(uint8_t_prt(__PixelType)))

#define __X1 0x073F
#define X1 (*(uint8_t_prt(__X1)))

#define __Y1 0x0740
#define Y1 (*(uint8_t_prt(__Y1)))

#define __FontSelector 0x0744
#define FontSelector (*(uint8_t_prt(__FontSelector)))

#define RxMode 0x074D
#define UserProfile 0x0803

#endif

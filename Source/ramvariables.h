#ifndef RAM_VARIABLES_H
#define RAM_VARIABLES_H

#define XPos 0x073D
#define YPos 0x073E
#define PixelType 0x0746

#define X1 0x073F
#define Y1 0x0740
#define FontSelector 0x0744


#define RxMode 0x074D
#define UserProfile 0x0803

#define uint8_t_prt(a) ((uint8_t *) (a))

#define XPos_ptr uint8_t_prt(XPos)
#define YPos_prt uint8_t_prt(YPos)


#endif

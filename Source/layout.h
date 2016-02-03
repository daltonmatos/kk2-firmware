#ifndef LAYOUT_H
#define LAYOUT_H


#define RamTableThrotleOffset 0
#define RamTableRollOffset 1
#define RamTablePitchOffset 2
#define RamTableYawOffset 3
#define RamTableOffsetOffset 4 /* Bad, Bad name... =`( */
#define RamTableMotorFlagsOffset 5 /* byte to indicate if it's Servo/ESC and Rate High/Low */

#define IS_HIGH(flag)  ((flag) & 0x02)
#define IS_ESC(flag)   ((flag) & 0x01)

#define X_OFFSET 96
#define Y_OFSET  32

extern const char servo;
extern const char unused_motor;
extern const char _high;
extern const char _low;
extern const char _all;
extern const char esc;
extern const char motor_label;
extern const char direction_label0;
extern const char direction_label1;
extern const char direction_label2;
extern const char _CCW;
extern const char _CW;
extern const char back_next;
extern const char noaccess;
extern const char no_motor_layout0;
extern const char no_motor_layout1;
extern const char _ok;

void show_motor(uint8_t m, uint8_t showing_all);
void load_mixer_table();
int8_t calculate_position(int16_t mixvalue, b168_t *mult_factor, uint8_t pos_offset);
void show_motor(uint8_t motor, uint8_t volatile showing_all);
void show_layout();

#endif

#include <avr/pgmspace.h>



const char _char_data[] PROGMEM = {
  4, 6, 4, //font4x6
  6, 8, 6, //font6x8
  8, 12, 12, //font8x12
  12, 16, 24, //font12x16
  16, 16, 32 //symbols16x16
};

const char _nxtchng[] PROGMEM = " NEXT CHANGE";
const char _nxt[] PROGMEM = " NEXT";
const char _back[] PROGMEM = "BACK";
const char _change[] PROGMEM = "CHANGE";
const char numedit_footer[] PROGMEM = "CLR  DOWN   UP   DONE";

const char ver1[] PROGMEM = "VERSION";
const char ver2[] PROGMEM = "KK2.1.x AiO";

const char con1[] PROGMEM = "LCD";
const char con2[] PROGMEM = "LCD Contrast: ";

const char affects_all_profiles[] PROGMEM = "AFFECTS ALL PROFILES";
const char colon_and_space[] PROGMEM = ": ";

/* Advanced Settings Menu */
const char adv1[] PROGMEM = "ADVANCED";

/* Board Rotation screen */
const char brd1[] PROGMEM = "Front";
const char brr1[] PROGMEM = "Mount your KK2 board";
const char brr2[] PROGMEM = "so that the on-screen";
const char brr3[] PROGMEM = "arrow points to the";
const char brr4[] PROGMEM = "front of your model.";
/* It's an array because we use print_string to print one char */
const uint8_t brd_up[] PROGMEM = {5, 0};
const uint8_t brd_right[] PROGMEM = {6, 0};
const uint8_t brd_down[] PROGMEM = {7, 0};
const uint8_t brd_left[] PROGMEM = {8, 0};

/* Extra screen */
const char ef1[] PROGMEM = "EXTRA";

/* ESC Calibration Warning Screen */
const char war2[] PROGMEM = "ESC calibration will";
const char war3[] PROGMEM = "be available on the";
const char war4[] PROGMEM = "next start-up only.";
const char war5[] PROGMEM = "REMOVE PROPS FIRST!";
const char war9[] PROGMEM = "Do ESC calibration.";

/* will be used by every screen that need this menu footer */
const char backprev[] PROGMEM = "BACK PREV"; /* original name: bckprev */
const char nextsel[] PROGMEM = " NEXT SELECT"; /* original name: nxtsel */
const char _saved[] PROGMEM = "SAVED"; /* original name: saved */
const char _ok[] PROGMEM = "OK"; /* original name: ok */

#ifdef STANDALONE_GIMBAL_CONTROLLER
/* Gimbal Mode Confirmation Screen */
const char gbm1[] PROGMEM = "GIMBAL";
const char gbm2[] PROGMEM = "Use this board as a";
const char gbm3[] PROGMEM = "stand-alone (servo)";
const char gbm4[] PROGMEM = "gimbal controller?";
const char _yesno[] PROGMEM = "YES  NO";
#endif

/* Confirmation Dialog */
const char confirm[] PROGMEM = "CONFIRM";
const char rusure[] PROGMEM = "Are you sure?";
const char conf[] PROGMEM = "CANCEL            YES";

/* Mode Settings (settingsc.c) screen */
const char mode_settings_tittle[] PROGMEM = "MODE SETTINGS";
const char sux1[] PROGMEM = "Link Roll Pitch";
const char sux2[] PROGMEM = "Auto Disarm";
const char sux3[] PROGMEM = "Button Beep";
const char sux4[] PROGMEM = "Arming Beeps";


/* Sensor Settings Screen */
const char sse1[] PROGMEM = "HW Filter (Hz): ";
const char sse2[] PROGMEM = "Gyro (deg/s)  : ";
const char sse3[] PROGMEM = "ACC (g)       : ";

const uint8_t lpf[]  PROGMEM = {255, 187, 97, 41, 19, 9, 4};
const uint16_t gyro[] PROGMEM = {250, 500, 1000, 2000};
const uint8_t acc[]  PROGMEM = {2, 4, 8, 16};

/* Self-level Settings Screen */
const char sqz3[] PROGMEM = "ACC Trim Roll";
const char sqz4[] PROGMEM = "ACC Trim Pitch";
const char sqz5[] PROGMEM = "SL Mixing Rate";
const char selflevel_title[] PROGMEM = "SELF-LEVEL";

/* Stick-scaling Screen */
const char ss_title[] PROGMEM = "STICK SCALING";

/* Misc. Settings screen */
const char misc_settings_title[] PROGMEM = "MISC. SETTINGS";

const char _stt1[] PROGMEM = "Minimum Throttle: ";
const char stt2[] PROGMEM = "Stick Dead Zone : ";
const char stt5[] PROGMEM = "Alarm 1/10 Volts: ";
const char stt6[] PROGMEM = "Servo Filter    : ";

/* Channel Mapping scren */
const char cm_title[] PROGMEM = "CHANNEL MAPPING";
const char aux4[] PROGMEM = "Aux4";

const char cmw1[] PROGMEM = "Channel mapping is";
const char cmw2[] PROGMEM = "invalid. Duplicates";
const char cmw3[] PROGMEM = "are not allowed.";

/* Rx Mode screen */
const char srm1[] PROGMEM = "RX MODE";
const char srm2[] PROGMEM = "Mode: ";

/* DG2 Switch Setup */
const char dg2_settings_title[] PROGMEM = "DG2 SWITCH SETUP";
const char dgs1[] PROGMEM = "Stay Armed/Spin:";
const char dgs2[] PROGMEM = "Digital Output :";

/* Show Motor Layout */
const char servo[] PROGMEM = "Servo.";
const char esc[] PROGMEM = "ESC";
const char unused_motor[] PROGMEM = "Unused.";
const char _high[] PROGMEM = "HIGH";
const char _low[] PROGMEM = "LOW";
const char _all[] PROGMEM = "ALL";
const char motor_label[] PROGMEM = "Motor:";
const char direction_label0[] PROGMEM = "Direction";
const char direction_label1[] PROGMEM = "seen from";
const char direction_label2[] PROGMEM = "above:";
const char _CCW[] PROGMEM = "CCW";
const char _CW[] PROGMEM = "CW";

const char back_next[] PROGMEM = "BACK  NEXT";

const char noaccess[] PROGMEM = "NO ACCESS";
const char no_motor_layout0[] PROGMEM = "A Motor Layout must";
const char no_motor_layout1[] PROGMEM = "be loaded first.";

/* Log Error Screen */

const char _log_error_title[] PROGMEM = "ERROR LOG";

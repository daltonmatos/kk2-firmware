#include <avr/pgmspace.h>

const char ver1[] PROGMEM = "VERSION";
const char ver2[] PROGMEM = "KK2.1.x AiO";

const char con1[] PROGMEM = "LCD";
const char con2[] PROGMEM = "LCD Contrast: ";
const char con6[] PROGMEM = "BACK  UP   DOWN  SAVE";


/* Advanced Settings Menu */
const char adv1[] PROGMEM = "ADVANCED";
const char adv2[] PROGMEM = "Channel Mapping";
const char adv3[] PROGMEM = "Sensor Settings";
const char adv4[] PROGMEM = "Mixer Editor";
const char adv5[] PROGMEM = "Board Orientation";

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
const char ef2[] PROGMEM = "Check Motor Outputs";
const char ef3[] PROGMEM = "Gimbal Controller";
const char ef4[] PROGMEM = "View Serial RX Data";

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


/* Confirmation Dialog */
const char confirm[] PROGMEM = "CONFIRM";
const char rusure[] PROGMEM = "Are you sure?";
const char conf[] PROGMEM = "CANCEL            YES";


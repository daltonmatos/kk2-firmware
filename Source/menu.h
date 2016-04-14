#ifndef MENU_H
#define MENU_H

#include "ramvariables.h"

typedef struct {
  const char* title;
  const char* footer;
  void (*footer_callback)();
  char *options;
  uint8_t initial_option;
  uint8_t total_options;
  void (*render_callback)(uint8_t);
  void (*ok_callback)(uint8_t);
} menu_t;


typedef void (*_ok_callback)(uint8_t);

typedef struct {
  uint8_t key_pressed;
  int8_t selected_item;
} menu_state_t;


void _menu_render_screen(menu_t *data, uint8_t selected_item);
void render_screen(menu_t *data);
void render_menu(uint8_t total_options, const char * volatile title, char * volatile str_addr, _ok_callback cb);



#endif

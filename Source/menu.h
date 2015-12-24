#ifndef MENU_H
#define MENU_H


typedef struct {
  const char* title;
  const char* footer;
  void (*footer_callback)();
  const char *options;
  uint8_t total_options;
  void (*render_callback)(uint8_t);
  void (*ok_callback)(uint8_t);
} menu_t;



void _menu_render_screen(menu_t *data, uint8_t selected_item);
void render_menu(menu_t *data);



#endif

#ifndef MENU_H
#define MENU_H


typedef struct {
  const char* title;
  const char* footer;
  const char *options;
  void (*ok_callback)(uint8_t);
  uint8_t total_options;
  void (*up_callback)(uint8_t);
  void (*down_callback)(uint8_t);
} menu_t;



void _menu_render_screen(
    const char *title,
    const char *footer,
    const char *options,
    uint8_t selected_item, 
    uint8_t total_options);

void render_menu(
    const char *title,
    const char *footer,
    const char *options, 
    void (*callback)(uint8_t),
    uint8_t total_options);


void render_menu2(menu_t *data);


#endif

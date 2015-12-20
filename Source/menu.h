#ifndef MENU_H
#define MENU_H


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


#endif

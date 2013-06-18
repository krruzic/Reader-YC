
#ifndef _FONTS_H
#define _FONTS_H

#include <EGL/egl.h>

typedef struct font_t font_t;


font_t * bbutil_load_font(const char * font_file, int point_size, int dpi);
void bbutil_destroy_font(font_t * font);
void bbutil_render_text(font_t * font, const char * msg, float x, float y,
    float angle,
    float r, float g, float b, float a);
void bbutil_measure_text(font_t * font, const  char * msg, float * width, float * height);


#endif

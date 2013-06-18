/*
 * Copyright (c) 2011-2012 Research In Motion Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <stdbool.h>
#include <math.h>

#include "fonts.h"

#include <GLES2/gl2.h>

#include <ft2build.h>
#include FT_FREETYPE_H

#include "debug.h"

EGLint surface_width, surface_height;

// TODO: move all this out to Python
static GLuint text_rendering_program;
static int text_program_initialized = 0;
static GLint transformLoc;
static GLint positionLoc;
static GLint texcoordLoc;
static GLint textureLoc;
static GLint colorLoc;

struct font_t {
    unsigned int font_texture;
    float pt;
    float advance[128];
    float width[128];
    float height[128];
    float tex_x1[128];
    float tex_x2[128];
    float tex_y1[128];
    float tex_y2[128];
    float offset_x[128];
    float offset_y[128];
    int initialized;
};



//-----------------------------------------------
// Finds the next power of 2
//
static inline int
nextp2(int x)
{
    int val = 1;
    while (val < x)
        val <<= 1;
    return val;
}


//-----------------------------------------------
//
font_t * bbutil_load_font(const char * path, int point_size, int dpi) {
    FT_Library library;
    FT_Face face;
    int c;
    int i, j;
    font_t * font;

    log_debug("bbutil_load_font %s %d %d", path, point_size, dpi);

    if (!path){
        fprintf(stderr, "Invalid path to font file\n");
        return NULL;
    }

    if (FT_Init_FreeType(&library)) {
        fprintf(stderr, "Error loading Freetype library\n");
        return NULL;
    }
    if (FT_New_Face(library, path, 0, &face)) {
        fprintf(stderr, "Error loading font %s\n", path);
        return NULL;
    }

    if (FT_Set_Char_Size ( face, point_size * 64, point_size * 64, dpi, dpi)) {
        fprintf(stderr, "Error initializing character parameters\n");
        return NULL;
    }

    font = (font_t *) malloc(sizeof(font_t));

    if (!font) {
        fprintf(stderr, "Unable to allocate memory for font structure\n");
        return NULL;
    }

    font->initialized = 0;
    font->pt = point_size;

    glGenTextures(1, &(font->font_texture));

    //Let each glyph reside in 32x32 section of the font texture
    int segment_size_x = 0, segment_size_y = 0;
    int num_segments_x = 16;
    int num_segments_y = 8;

    FT_GlyphSlot slot;
    FT_Bitmap bmp;
    int glyph_width, glyph_height;

    //First calculate the max width and height of a character in a passed font
    for (c = 0; c < 128; c++) {
        if(FT_Load_Char(face, c, FT_LOAD_RENDER)) {
            fprintf(stderr, "FT_Load_Char failed\n");
            free(font);
            return NULL;
        }

        slot = face->glyph;
        bmp = slot->bitmap;

        glyph_width = bmp.width;
        glyph_height = bmp.rows;

        if (glyph_width > segment_size_x)
            segment_size_x = glyph_width;

        if (glyph_height > segment_size_y)
            segment_size_y = glyph_height;
    }

    int font_tex_width = nextp2(num_segments_x * segment_size_x);
    int font_tex_height = nextp2(num_segments_y * segment_size_y);

    int bitmap_offset_x = 0, bitmap_offset_y = 0;

    GLubyte * font_tex_data = (GLubyte *)
        calloc(2 * font_tex_width * font_tex_height, sizeof(GLubyte));

    if (!font_tex_data) {
        fprintf(stderr, "Failed to allocate memory for font texture\n");
        free(font);
        return NULL;
    }

    // Fill font texture bitmap with individual bmp data and record appropriate size,
    // texture coordinates and offsets for every glyph
    for (c = 0; c < 128; c++) {
        if (FT_Load_Char(face, c < 127 ? c : 0x2113, FT_LOAD_RENDER)) {
            fprintf(stderr, "FT_Load_Char failed\n");
            free(font);
            return NULL;
        }

        slot = face->glyph;
        bmp = slot->bitmap;

        glyph_width = bmp.width;
        glyph_height = bmp.rows;

        div_t temp = div(c, num_segments_x);

        bitmap_offset_x = segment_size_x * temp.rem;
        bitmap_offset_y = segment_size_y * temp.quot;

        for (j = 0; j < glyph_height; j++) {
            for (i = 0; i < glyph_width; i++) {
                GLubyte data = (i >= bmp.width || j >= bmp.rows)
                    ? 0
                    : bmp.buffer[i + bmp.width * j];

                int offset = 2 * ((bitmap_offset_x + i)
                    + (j + bitmap_offset_y) * font_tex_width);

                font_tex_data[offset] = font_tex_data[offset + 1] = data;
            }
        }

        font->advance[c] = (float)(slot->advance.x >> 6);
        font->tex_x1[c] = (float)bitmap_offset_x / (float) font_tex_width;
        font->tex_x2[c] = (float)(bitmap_offset_x + bmp.width) / (float)font_tex_width;
        font->tex_y1[c] = (float)bitmap_offset_y / (float) font_tex_height;
        font->tex_y2[c] = (float)(bitmap_offset_y + bmp.rows) / (float)font_tex_height;
        font->width[c] = bmp.width;
        font->height[c] = bmp.rows;
        font->offset_x[c] = (float)slot->bitmap_left;
        font->offset_y[c] = (float)((slot->metrics.horiBearingY
            - face->glyph->metrics.height) >> 6);
    }

    glBindTexture(GL_TEXTURE_2D, font->font_texture);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);

    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE_ALPHA, font_tex_width, font_tex_height, 0,
        GL_LUMINANCE_ALPHA , GL_UNSIGNED_BYTE, font_tex_data);

    free(font_tex_data);

    FT_Done_Face(face);
    FT_Done_FreeType(library);

    font->initialized = 1;
    return font;
}


//-----------------------------------------------
//
void bbutil_render_text(font_t * font,
    const char * msg,
    float x, float y,
    float rotation,
    float r, float g, float b, float a)
    {
    int i, c;
    GLfloat * vertices;
    GLfloat * matrix;
    GLfloat * texture_coords;
    GLushort * indices;

    // log_debug("render '%s' %.1f x %.1f (%.2f,%.2f,%.2f,%.2f)",
    //     msg, x, y, r, g, b, a);

    float pen_x = 0.0f;

    if (!font) {
        fprintf(stderr, "Font must not be null\n");
        return;
    }

    if (!font->initialized) {
        fprintf(stderr, "Font has not been loaded\n");
        return;
    }

    if (!msg) {
        return;
    }

    // x = y = 0.0f;
    const int msg_len = strlen(msg);

    vertices = (GLfloat*) malloc(sizeof(GLfloat) * 8 * msg_len);
    texture_coords = (GLfloat*) malloc(sizeof(GLfloat) * 8 * msg_len);
    indices = (GLushort*) malloc(sizeof(GLushort) * 6 * msg_len);

    matrix = (GLfloat*) malloc(sizeof(GLfloat) * 16);
    for(i = 0; i < msg_len; ++i) {
        c = msg[i];

        vertices[8 * i + 0] = pen_x + font->offset_x[c];
        vertices[8 * i + 1] = font->offset_y[c];
        vertices[8 * i + 2] = vertices[8 * i + 0] + font->width[c];
        vertices[8 * i + 3] = vertices[8 * i + 1];
        vertices[8 * i + 4] = vertices[8 * i + 0];
        vertices[8 * i + 5] = vertices[8 * i + 1] + font->height[c];
        vertices[8 * i + 6] = vertices[8 * i + 2];
        vertices[8 * i + 7] = vertices[8 * i + 5];

        texture_coords[8 * i + 0] = font->tex_x1[c];
        texture_coords[8 * i + 1] = font->tex_y2[c];
        texture_coords[8 * i + 2] = font->tex_x2[c];
        texture_coords[8 * i + 3] = font->tex_y2[c];
        texture_coords[8 * i + 4] = font->tex_x1[c];
        texture_coords[8 * i + 5] = font->tex_y1[c];
        texture_coords[8 * i + 6] = font->tex_x2[c];
        texture_coords[8 * i + 7] = font->tex_y1[c];

        indices[i * 6 + 0] = 4 * i + 0;
        indices[i * 6 + 1] = 4 * i + 1;
        indices[i * 6 + 2] = 4 * i + 2;
        indices[i * 6 + 3] = 4 * i + 2;
        indices[i * 6 + 4] = 4 * i + 1;
        indices[i * 6 + 5] = 4 * i + 3;

        //Assume we are only working with typewriter fonts
        pen_x += font->advance[c];
    }

    if (!text_program_initialized) {
        GLint status;

        // Create shaders if this hasn't been done already
        const char * v_source =
                "precision mediump float;"
                "uniform mat4 u_transform;"
                "attribute vec2 a_position;"
                "attribute vec2 a_texcoord;"
                "varying vec2 v_texcoord;"
                "void main()"
                "{"
                "    gl_Position = u_transform * vec4(a_position, 0.0, 1.0);"
                "    v_texcoord = a_texcoord;"
                "}";

        const char * f_source =
                "precision lowp float;"
                "varying vec2 v_texcoord;"
                "uniform sampler2D u_font_texture;"
                "uniform vec4 u_col;"
                "void main()"
                "{"
                "    vec4 temp = texture2D(u_font_texture, v_texcoord);"
                "    gl_FragColor = u_col * temp;"
                "}";

        // Compile the vertex shader
        GLuint vs = glCreateShader(GL_VERTEX_SHADER);

        if (!vs) {
            fprintf(stderr, "Failed to create vertex shader: %d\n", glGetError());
            return;
        } else {
            glShaderSource(vs, 1, &v_source, 0);
            glCompileShader(vs);
            glGetShaderiv(vs, GL_COMPILE_STATUS, &status);
            if (GL_FALSE == status) {
                GLchar log[256];
                glGetShaderInfoLog(vs, 256, NULL, log);

                fprintf(stderr, "Failed to compile vertex shader: %s\n", log);

                glDeleteShader(vs);
            }
        }

        // log_debug("created vshader %d", vs);

        // Compile the fragment shader
        GLuint fs = glCreateShader(GL_FRAGMENT_SHADER);

        if (!fs) {
            fprintf(stderr, "Failed to create fragment shader: %d\n", glGetError());
            return;
        } else {
            glShaderSource(fs, 1, &f_source, 0);
            glCompileShader(fs);
            glGetShaderiv(fs, GL_COMPILE_STATUS, &status);
            if (GL_FALSE == status) {
                GLchar log[256];
                glGetShaderInfoLog(fs, 256, NULL, log);

                fprintf(stderr, "Failed to compile fragment shader: %s\n", log);

                glDeleteShader(vs);
                glDeleteShader(fs);

                return;
            }
        }

        // Create and link the program
        text_rendering_program = glCreateProgram();
        if (text_rendering_program)
        {
            glAttachShader(text_rendering_program, vs);
            glAttachShader(text_rendering_program, fs);
            glLinkProgram(text_rendering_program);

            glGetProgramiv(text_rendering_program, GL_LINK_STATUS, &status);
            if (status == GL_FALSE)    {
                GLchar log[256];
                glGetProgramInfoLog(fs, 256, NULL, log);

                fprintf(stderr, "Failed to link text rendering shader program: %s\n", log);

                glDeleteProgram(text_rendering_program);
                text_rendering_program = 0;

                return;
            }
        } else {
            fprintf(stderr, "Failed to create a shader program\n");

            glDeleteShader(vs);
            glDeleteShader(fs);
            return;
        }

        // We don't need the shaders anymore - the program is enough
        glDeleteShader(fs);
        glDeleteShader(vs);

        glUseProgram(text_rendering_program);

        // Store the locations of the shader variables we need later
        positionLoc = glGetAttribLocation(text_rendering_program, "a_position");
        texcoordLoc = glGetAttribLocation(text_rendering_program, "a_texcoord");
        textureLoc = glGetUniformLocation(text_rendering_program, "u_font_texture");
        colorLoc = glGetUniformLocation(text_rendering_program, "u_col");
        transformLoc = glGetUniformLocation(text_rendering_program, "u_transform");

        text_program_initialized = 1;
    }

    // log_debug("will it blend?");
    glEnable(GL_BLEND);

    // EGLint surface_width, surface_height;

    // eglQuerySurface(egl_disp, egl_surf, EGL_WIDTH, &surface_width);
    // eglQuerySurface(egl_disp, egl_surf, EGL_HEIGHT, &surface_height);

    // log_debug("swidth %d, sheight %d", surface_width, surface_height);

    // for(i = 0; i < 4 * msg_len; ++i) {
    //     vertices[2 * i + 0] = vertices[2 * i + 0]; // / surface_width;
    //     vertices[2 * i + 1] = vertices[2 * i + 1]; // / surface_height;
    // }

    // Render text
    glUseProgram(text_rendering_program);

    float angle = rotation * M_PI / 180.0f;

    // Map text coordinates from (0...surface width, 0...surface height) to
    // (-1...1, -1...1).  This make our vertex shader very simple and also
    // works irrespective of orientation changes.
    matrix[0] = 2.0 / surface_width * cos(angle);
    matrix[1] = 2.0 / surface_height * -sin(angle);
    matrix[2] = 0.0f;
    matrix[3] = 0.0f;
    matrix[4] = 2.0 / surface_width * sin(angle);
    matrix[5] = 2.0 / surface_height * cos(angle);
    matrix[6] = 0.0f;
    matrix[7] = 0.0f;
    matrix[8] = 0.0f;
    matrix[9] = 0.0f;
    matrix[10] = 1.0f;
    matrix[11] = 0.0f;
    matrix[12] = -1.0f + 2 * x / surface_width;
    matrix[13] = -1.0f + 2 * y / surface_height;
    matrix[14] = 0.0f;
    matrix[15] = 1.0f;
    glUniformMatrix4fv(transformLoc, 1, false, matrix);

    // log_debug("rendering %.2f,%.2f to %.2f,%.2f",
    //     vertices[0], vertices[1], vertices[i-2], vertices[i-1]);

    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

    glBindBuffer(GL_ARRAY_BUFFER, 0);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, font->font_texture);
    glUniform1i(textureLoc, 0);

    glUniform4f(colorLoc, r, g, b, a);

    glEnableVertexAttribArray(positionLoc);
    glVertexAttribPointer(positionLoc, 2, GL_FLOAT, GL_FALSE, 0, vertices);

    glEnableVertexAttribArray(texcoordLoc);
    glVertexAttribPointer(texcoordLoc, 2, GL_FLOAT, GL_FALSE, 0, texture_coords);

    // Draw the string
    glDrawElements(GL_TRIANGLES, 6 * msg_len, GL_UNSIGNED_SHORT, indices);

    glDisableVertexAttribArray(positionLoc);
    glDisableVertexAttribArray(texcoordLoc);

    free(vertices);
    free(texture_coords);
    free(indices);
    free(matrix);
}


//-----------------------------------------------
//
void bbutil_destroy_font(font_t * font) {
    if (!font) {
        return;
    }

    glDeleteTextures(1, &(font->font_texture));

    free(font);
}


//-----------------------------------------------
//
void bbutil_measure_text(font_t * font,
    const char * msg, float * width, float * height) {

    int i, c;

    if (!font || !msg) {
        log_debug("no font/msg");
        return;
    }

    const int msg_len = strlen(msg);

    if (width) {
        // Width of a text rectangle is a sum advances for every glyph in a string
        *width = 0.0f;

        for (i = 0; i < msg_len; ++i) {
            c = msg[i];
            *width += font->advance[c];
        }
    }

    if (height) {
        // Height of a text rectangle is a high of a tallest glyph in a string
        *height = 0.0f;

        for (i = 0; i < msg_len; ++i) {
            c = msg[i];

            if (*height < font->height[c]) {
                *height = font->height[c];
            }
        }
    }
}


// EOF

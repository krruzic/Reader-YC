
from bb.gles import (GLint, GLfloat, GLboolean,
    glGetIntegerv, glGetFloatv, glGetBooleanv)


def gl_dump():
    integers = (gl.GLint * 10)()
    floats = (gl.GLfloat * 10)()
    booleans = (gl.GLboolean * 10)()

    for i, (tag, array, size) in enumerate([
        ('GL_ACTIVE_TEXTURE', integers, 1),
        ('GL_ALIASED_LINE_WIDTH_RANGE', floats, 2),
        ('GL_ALIASED_POINT_SIZE_RANGE', floats, 2),
        ('GL_ALPHA_BITS', integers, 1),
        ('GL_ARRAY_BUFFER_BINDING', integers, 1),
        ('GL_BLEND', booleans, 1),
        ('GL_BLEND_COLOR', floats, 4),
        ('GL_BLEND_DST_ALPHA', integers, 1),
        ('GL_BLEND_DST_RGB', integers, 1),
        ('GL_BLEND_EQUATION_ALPHA', integers, 1),
        ('GL_BLEND_EQUATION_RGB', integers, 1),
        ('GL_BLEND_SRC_ALPHA', integers, 1),
        ('GL_BLEND_SRC_RGB', integers, 1),
        ('GL_BLUE_BITS', integers, 1),
        ('GL_COLOR_CLEAR_VALUE', floats, 4),
        ('GL_COLOR_WRITEMASK', booleans, 4),

        # GL_NUM_COMPRESSED_TEXTURE_FORMATS
        # ('GL_COMPRESSED_TEXTURE_FORMATS', integers, len comes from ^^),

        ('GL_CULL_FACE', booleans, 1),
        ('GL_CULL_FACE_MODE', integers, 1),
        ('GL_CURRENT_PROGRAM', integers, 1),
        ('GL_DEPTH_BITS', integers, 1),
        ('GL_DEPTH_CLEAR_VALUE', floats, 1),
        ('GL_DEPTH_FUNC', integers, 1),
        ('GL_DEPTH_RANGE', floats, 2),
        ('GL_DEPTH_TEST', booleans, 1),
        ('GL_DEPTH_WRITEMASK', booleans, 1),
        ('GL_DITHER', booleans, 1),
        ('GL_ELEMENT_ARRAY_BUFFER_BINDING', integers, 1),
        ('GL_FRAMEBUFFER_BINDING', integers, 1),
        ('GL_FRONT_FACE', integers, 1),
        ('GL_GENERATE_MIPMAP_HINT', integers, 1),
        ('GL_GREEN_BITS', integers, 1),
        ('GL_IMPLEMENTATION_COLOR_READ_FORMAT', integers, 1),
        ('GL_IMPLEMENTATION_COLOR_READ_TYPE', integers, 1),
        ('GL_LINE_WIDTH', floats, 1),
        ('GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS', integers, 1),
        ('GL_MAX_CUBE_MAP_TEXTURE_SIZE', integers, 1),
        ('GL_MAX_FRAGMENT_UNIFORM_VECTORS', integers, 1),
        ('GL_MAX_RENDERBUFFER_SIZE', integers, 1),
        ('GL_MAX_TEXTURE_IMAGE_UNITS', integers, 1),
        ('GL_MAX_TEXTURE_SIZE', integers, 1),
        ('GL_MAX_VARYING_VECTORS', integers, 1),
        ('GL_MAX_VERTEX_ATTRIBS', integers, 1),
        ('GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS', integers, 1),
        ('GL_MAX_VERTEX_UNIFORM_VECTORS', integers, 1),
        ('GL_MAX_VIEWPORT_DIMS', integers, 2),
        ('GL_NUM_COMPRESSED_TEXTURE_FORMATS', integers, 1),
        ('GL_NUM_SHADER_BINARY_FORMATS', integers, 1),
        ('GL_PACK_ALIGNMENT', integers, 1),
        ('GL_POLYGON_OFFSET_FACTOR', floats, 1),
        ('GL_POLYGON_OFFSET_FILL', booleans, 1),
        ('GL_POLYGON_OFFSET_UNITS', floats, 1),
        ('GL_RED_BITS', integers, 1),
        ('GL_RENDERBUFFER_BINDING', integers, 1),
        ('GL_SAMPLE_ALPHA_TO_COVERAGE', booleans, 1),
        ('GL_SAMPLE_BUFFERS', integers, 1),
        ('GL_SAMPLE_COVERAGE', booleans, 1),
        ('GL_SAMPLE_COVERAGE_INVERT', booleans, 1),
        ('GL_SAMPLE_COVERAGE_VALUE', floats, 1),
        ('GL_SAMPLES', integers, 1),
        ('GL_SCISSOR_BOX', floats, 4),
        ('GL_SCISSOR_TEST', booleans, 1),
        # GL_NUM_SHADER_BINARY_FORMATS
        # ('GL_SHADER_BINARY_FORMATS', integers, len from ^^),
        ('GL_SHADER_COMPILER', booleans, 1),
        ('GL_STENCIL_BACK_FAIL', integers, 1),
        ('GL_STENCIL_BACK_FUNC', integers, 1),
        ('GL_STENCIL_BACK_PASS_DEPTH_FAIL', integers, 1),
        ('GL_STENCIL_BACK_PASS_DEPTH_PASS', integers, 1),
        ('GL_STENCIL_BACK_REF', integers, 1),
        ('GL_STENCIL_BACK_VALUE_MASK', integers, 1),
        ('GL_STENCIL_BACK_WRITEMASK', integers, 1),
        ('GL_STENCIL_BITS', integers, 1),
        ('GL_STENCIL_CLEAR_VALUE', integers, 1),
        ('GL_STENCIL_FAIL', integers, 1),
        ('GL_STENCIL_FUNC', integers, 1),
        ('GL_STENCIL_PASS_DEPTH_FAIL', integers, 1),
        ('GL_STENCIL_PASS_DEPTH_PASS', integers, 1),
        ('GL_STENCIL_REF', integers, 1),
        ('GL_STENCIL_TEST', booleans, 1),
        ('GL_STENCIL_VALUE_MASK', integers, 1),
        ('GL_STENCIL_WRITEMASK', integers, 1),
        ('GL_SUBPIXEL_BITS', integers, 1),
        ('GL_TEXTURE_BINDING_2D', integers, 1),
        ('GL_TEXTURE_BINDING_CUBE_MAP', integers, 1),
        ('GL_UNPACK_ALIGNMENT', integers, 1),
        ('GL_VIEWPORT', integers, 4),
        ]):
        code = globals()[tag]
        if array is integers:
            gl.glGetIntegerv(code, integers)
        elif array is floats:
            gl.glGetFloatv(code, floats)
        elif array is booleans:
            gl.glGetBooleanv(code, booleans)

        # dumping this much out through slog2 will overflow the buffers
        # unless you pace it a bit or have many buffer
        if (i % 20) == 0:
            import time
            time.sleep(0.4)

        print('0x{:04x} {}: {}'.format(code, tag, list(array)[:size]))



# EOF

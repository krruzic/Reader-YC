
import os
from ctypes import (byref, c_int, cast, c_void_p, c_float, c_char_p,
    Structure, POINTER)

from bb._wrap import _func, _register_funcs
from .drawing import _dll
from .color import Color


SYS_FONTS = '/usr/fonts/font_repository/monotype'


class Font:
    # https://developer.blackberry.com/devzone/design/devices_and_screen_sizes.html
    dpi = int(round(25.4 / 0.07125))
    DEFAULT_SIZE = 16

    __cache = {}

    def __init__(self, path, point_size=DEFAULT_SIZE):
        _orig_path = path
        if not self.dpi:
            raise Exception('Font.dpi must be set before creating fonts')

        if point_size > 28:
            print('Warning: sizes above 28 may not be supported')

        if not os.path.isfile(path):
            trypath = os.path.join(SYS_FONTS, path)
            if os.path.isfile(trypath):
                path = trypath

        self.font = bbutil_load_font(path.encode('ascii', 'ignore'), point_size, self.dpi)
        # print('font', _orig_path, point_size)


    def __del__(self):
        bbutil_destroy_font(self.font)
        del self.font


    @classmethod
    def get_font(cls, path, point_size=DEFAULT_SIZE):
        try:
            font = cls.__cache[path, point_size]
        except KeyError:
            font = Font(path, point_size)

            # cache for easier reuse
            cls.__cache[path, point_size] = font

        return font


    def measure(self, text):
        text = text.encode('ascii', 'replace')
        w = c_float()
        h = c_float()
        bbutil_measure_text(self.font, text, byref(w), byref(h))
        return w.value, h.value


    def render(self, text, x, y, color, rotation=0):
        if isinstance(color, Color):
            color = color.tuple()
        text = text.encode('ascii', 'replace')
        # print('render', text, x, y, color)
        bbutil_render_text(self.font, text, x, y, -rotation, *color)



class font_t(Structure):
    _fields_ = []

bbutil_load_font = _func(POINTER(font_t), c_char_p, c_int, c_int)
bbutil_destroy_font = _func(None, POINTER(font_t))
bbutil_measure_text = _func(None, POINTER(font_t), c_char_p,
    POINTER(c_float), POINTER(c_float))
bbutil_render_text = _func(None, POINTER(font_t), c_char_p, c_float, c_float,
    c_float, c_float, c_float, c_float, c_float)


#----------------------------
# apply argtypes/restype to all functions
#
_register_funcs(_dll, globals())


# EOF

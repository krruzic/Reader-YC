'''Wrappers for libclipboard routines'''

import ctypes
from ctypes import (c_bool, c_float, c_double, c_int, c_char, c_char_p, c_void_p, c_uint,
    POINTER, Structure, CFUNCTYPE)

from ._wrap import _func, _register_funcs

get_clipboard_path = _func(c_int, c_char_p, c_uint)
set_clipboard_path = _func(c_int, c_char_p, c_uint)
set_clipboard_check_perimeters = _func(None, c_int)
get_clipboard_can_write = _func(c_int)
set_clipboard_data = _func(c_int, c_char_p, c_uint, POINTER(c_char))
get_clipboard_data = _func(c_uint, c_char_p, POINTER(POINTER(c_char)))
empty_clipboard = _func(c_int)
empty_clipboard_by = _func(c_int, c_char_p)
is_clipboard_format_present = _func(c_int, c_char_p)
get_clipboard_format_path = _func(c_int, c_char_p, c_char_p, c_int)

_register_funcs('libclipboard.so', globals(), True)

'''Images loaded from file.'''

from ctypes import (byref, cast, sizeof, c_int, c_void_p, POINTER,
    addressof, c_char, CDLL)

from bb.img import *
from tart.util import ascii_bytes


class Image:
    def __init__(self):
        self.img = None
        self.data = None


    def load(self, filepath):
        ilib = img_lib_t()
        rc = img_lib_attach(byref(ilib))
        if rc: raise RuntimeError(rc)

        try:
            img = img_t()

            # 24-bits/pixel BGRA format, little-endian
            img.format = IMG_FMT_RGBA8888
            img.flags |= IMG_FORMAT

            rc = img_load_file(ilib, ascii_bytes(filepath), None, byref(img))
            if rc: raise RuntimeError(rc)
            #~ print('img is %d x %d x %d' % (img.w, img.h, IMG_FMT_BPP(img.format)))

            self.img = img
            self.width = img.w
            self.height = img.h

            size = img.access.direct.stride * img.h
            self.data = (c_char * size).from_address(
                addressof(img.access.direct.data.contents))

        finally:
            img_lib_detach(ilib)


    def __del__(self):
        libc = CDLL('libc.so')
        libc.free(addressof(self.data))


# EOF

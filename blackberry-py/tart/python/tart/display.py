'''Manage libscreen displays.'''

import math
from ctypes import (byref, cast, c_void_p, c_int, POINTER)

from bb import screen as s

MM_PER_INCH = 25.4  # exact, since 1959


class DisplayError(Exception):
    '''Problem occurred during libscreen call.'''


class Display:
    def __init__(self, handle):
        self._disp = handle


    def _get_property_iv(self, num, count):
        cints = (c_int * count)()
        rc = s.screen_get_display_property_iv(self._disp, num,
            cast(cints, POINTER(c_int)))
        if rc < 0:
            raise DisplayError('get property failed')
        return cints


    @property
    def physical_size(self):
        size = self._get_property_iv(s.SCREEN_PROPERTY_PHYSICAL_SIZE, 2)
        return (size[0], size[1])


    @property
    def size(self):
        size = self._get_property_iv(s.SCREEN_PROPERTY_SIZE, 2)
        return (size[0], size[1])


    def get_dpi(self):
        '''Calculate DPI for this display, as an integer.
        (Why integer? because bbutil.c originally did and this is based on it.)
        Note: could also just read /pps/services/deviceproperties and get
        screen_dpi::355 or
        '''
        pw, ph = self.physical_size
        # print('dpi: physical size', pw, ph)

        # Simulator will return 0,0 for physical size of the screen, so use default dpi
        if pw == ph == 0:
            # https://developer.blackberry.com/devzone/design/devices_and_screen_sizes.html
            return int(round(25.4 / 0.07125)) # dev alpha, 1280x768

        else:
            w, h = self.size
            # print('dpi: res', w, h)

            # Use combination of width and height to approximate DPI
            # because the physical size values are not exact (being integers).
            # For example, on the 1280x768 Dev Alpha the pixel size is
            # actually 0.07125mm, so it's 54.72mm by 91.20mm but reports
            # as 54 and 91.  Using the diagonal removes some of the error.
            diag_px = math.sqrt(w * w + h * h)
            diag_mm = math.sqrt(pw * pw + ph * ph)
            # print('dpi: diag_px', diag_px, 'diag_inches', diag_inches)

            dpi = int(round(diag_px / diag_mm * MM_PER_INCH))
            return dpi

        # dpi: physical size 54 91
        # dpi: res 768 1280
        # dpi: diag_px 1492.723685080397 diag_inches 4.165979441952327
        # dpi: dpi 358


# EOF

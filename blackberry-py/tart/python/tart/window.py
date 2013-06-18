'''Windowing support, for use with Cascades' ForeignWindowControl.'''

from ctypes import (byref, cast, c_void_p, c_int, POINTER)

from bb import screen as s

from .util import ascii_bytes


class WindowError(Exception):
    '''Problem occurred during libscreen call.'''


DEFAULT_WIDTH = 500
DEFAULT_HEIGHT = 200


class NativeWindow:
    def __init__(self, group, id, width, height):
        self._ctx = s.screen_context_t()

        if s.screen_create_context(byref(self._ctx),
            s.SCREEN_APPLICATION_CONTEXT) < 0:
            raise WindowError('window context creation failed')
        # print('context', self._ctx)

        self.group = ascii_bytes(group)
        self.id = ascii_bytes(id)

        self._create_child_window()

        # The window size is specified in QML so we need to set up the buffer size to
        # correspond to that, the default size would be the full screen.
        self.buffer_size = (width or DEFAULT_WIDTH, height or DEFAULT_HEIGHT)

        self.position = (0, 0)

        # Use negative Z order so that the window appears under the main window.
        # (required by the ForeignWindow functionality)
        self._set_zorder(-5)

        self._set_format(s.SCREEN_FORMAT_RGBX8888)
        self._set_usage(s.SCREEN_USAGE_OPENGL_ES2 | s.SCREEN_USAGE_ROTATION)

        # with OpenGL use two, for double-buffering
        self._create_buffers(2)


    def __del__(self):
        if self.handle:
            s.screen_destroy_window(self.handle)
            self.handle = 0

        # clean up screen context
        s.screen_destroy_context(self._ctx)


    @property
    def display(self):
        '''Retrieve this window's display, caching the result.'''
        try:
            return self._display
        except AttributeError:
            disp = s.screen_display_t()
            rc = s.screen_get_window_property_pv(self.handle, s.SCREEN_PROPERTY_DISPLAY,
                cast(byref(disp), POINTER(c_void_p)))
            if rc < 0:
                raise WindowError('get property failed')
            # print('display', disp)

            from .display import Display
            self._display = Display(disp)
            return self._display


    def _create_child_window(self):
        self.handle = s.screen_window_t()

        # Create a child window of the current window group, join the window group and set
        # a window ID.
        rc = s.screen_create_window_type(byref(self.handle), self._ctx,
            s.SCREEN_CHILD_WINDOW)
        if rc < 0:
            raise WindowError('child window creation failed')
        # print('window', self.handle)

        rc = s.screen_join_window_group(self.handle, self.group)
        if rc < 0:
            raise WindowError('window group join failed')

        rc = s.screen_set_window_property_cv(self.handle, s.SCREEN_PROPERTY_ID_STRING,
            len(self.id), self.id)
        if rc < 0:
            raise WindowError('set property failed')


    def _get_property_iv(self, pnum, count):
        cints = (c_int * count)()
        rc = s.screen_get_window_property_iv(self.handle, pnum,
            cast(cints, POINTER(c_int)))
        if rc < 0:
            raise WindowError('get property failed')
        return cints


    def _set_property_iv(self, pnum, count, *values):
        # print('set prop_iv', pnum, count, *values)
        cints = (c_int * count)(*[int(x) for x in values])
        rc = s.screen_set_window_property_iv(self.handle, pnum,
            cast(cints, POINTER(c_int)))
        if rc < 0:
            raise WindowError('set property failed')


    @property
    def size(self):
        size = self._get_property_iv(s.SCREEN_PROPERTY_SIZE, 2)
        return size

    @size.setter
    def size(self, value):
        # print('window: set size', size)
        self._set_property_iv(s.SCREEN_PROPERTY_SIZE, 2, *value)


    def _get_source_size(self):
        size = self._get_property_iv(s.SCREEN_PROPERTY_SOURCE_SIZE, 2)
        return (size[0], size[1])

    def _get_buffer_size(self):
        size = self._get_property_iv(s.SCREEN_PROPERTY_BUFFER_SIZE, 2)
        return (size[0], size[1])

    def _set_buffer_size(self, size):
        # print('window: set buffer_size', size)
        self._set_property_iv(s.SCREEN_PROPERTY_BUFFER_SIZE, 2, *size)
        # TODO: figure out if we need to set source size too. A reading of
        # http://developer.blackberry.com/native/reference/bb10/screen_libref/topic/manual/cscreen_windows.html
        # suggests it would be redundant.
        # self._set_property_iv(s.SCREEN_PROPERTY_SOURCE_SIZE, 2, *size)
        self.width, self.height = size

    buffer_size = property(_get_buffer_size, _set_buffer_size)


    def _set_zorder(self, value):
        self._set_property_iv(s.SCREEN_PROPERTY_ZORDER, 1, value)


    def _get_position(self):
        pos = self._get_property_iv(s.SCREEN_PROPERTY_POSITION, 2)
        return (pos[0], pos[1])

    def _set_position(self, pos):
        self._set_property_iv(s.SCREEN_PROPERTY_POSITION, 2, *pos)

    position = property(_get_position, _set_position)


    def _set_format(self, format):
        self._set_property_iv(s.SCREEN_PROPERTY_FORMAT, 1, s.SCREEN_FORMAT_RGBX8888)


    def _set_usage(self, usage):
        self._set_property_iv(s.SCREEN_PROPERTY_USAGE, 1,
            s.SCREEN_USAGE_OPENGL_ES2 | s.SCREEN_USAGE_ROTATION)


    def _create_buffers(self, count):
        rc = s.screen_create_window_buffers(self.handle, count)
        if rc < 0:
            raise WindowError('buffer creation failed')
        self._buffer_count = count


    def _get_buffers(self):
        bufs = (c_void_p * self._buffer_count)()
        rc = s.screen_get_window_property_pv(self.handle,
            s.SCREEN_PROPERTY_RENDER_BUFFERS, cast(bufs, POINTER(c_void_p)))
        if rc < 0:
            raise WindowError('get buffers failed')
        return bufs


# EOF


from ctypes import (byref, c_int)

from bb.egl import *


#-----------------------------------------------
#
class EglError(Exception):
    ERRMSG = [
        "function succeeded",
        "EGL is not initialized, or could not be initialized, for the specified display",
        "cannot access a requested resource",
        "failed to allocate resources for the requested operation",
        "an unrecognized attribute or attribute value was passed in an attribute list",
        "an EGLConfig argument does not name a valid EGLConfig",
        "an EGLContext argument does not name a valid EGLContext",
        "the current surface of the calling thread is no longer valid",
        "an EGLDisplay argument does not name a valid EGLDisplay",
        "arguments are inconsistent",
        "an EGLNativePixmapType argument does not refer to a valid native pixmap",
        "an EGLNativeWindowType argument does not refer to a valid native window",
        "one or more argument values are invalid",
        "an EGLSurface argument does not name a valid surface configured for rendering",
        "a power management event has occurred",
        "unknown error code",
        ]


    def __init__(self, msg):
        self.msg = msg
        self.error = eglGetError()


    def __str__(self):
        i = self.error - EGL_SUCCESS
        if i < 0 or i >= len(self.ERRMSG):
            i = len(self.ERRMSG) - 1

        return '{}: 0x{:04x} {}'.format(self.msg, self.error, self.ERRMSG[i])



class EglContext:
    SWAP_INTERVAL = 1

    #-----------------------------------------------
    #
    def __init__(self):
        self.disp = EGLDisplay()
        self.surf = EGLSurface()
        self.conf = EGLConfig()
        self.ctx = EGLContext()


    #-----------------------------------------------
    #
    def __del__(self):
        self.terminate()


    #-----------------------------------------------
    #
    def get_surface_size(self):
        '''Query width and height of the current window surface.'''
        sw = EGLint()
        sh = EGLint()

        rc = eglQuerySurface(self.disp, self.surf, EGL_WIDTH, byref(sw))
        if not rc:
            raise EglError('eglQuerySurface')

        rc = eglQuerySurface(self.disp, self.surf, EGL_HEIGHT, byref(sh))
        if not rc:
            raise EglError('eglQuerySurface')

        # print('EGL get_surface_size', sw.value, sh.value)
        return sw.value, sh.value


    #-----------------------------------------------
    #
    def initialize(self, native_win):
        def make_array(type, data):
            array_type = type * len(data)
            return array_type(*data)

        attrib_list = make_array(EGLint, [
            EGL_RED_SIZE,        8,
            EGL_GREEN_SIZE,      8,
            EGL_BLUE_SIZE,       8,
            EGL_ALPHA_SIZE,      8,
            EGL_SURFACE_TYPE,    EGL_WINDOW_BIT,
            EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,
            EGL_NONE,
            ])
        attributes = make_array(EGLint, [EGL_CONTEXT_CLIENT_VERSION, 2, EGL_NONE])

        self.disp = eglGetDisplay(EGL_DEFAULT_DISPLAY)
        if not self.disp:
            raise EglError('eglGetDisplay')

        # print('eglGetDisplay', self.disp)

        major = c_int()
        minor = c_int()
        rc = eglInitialize(self.disp, byref(major), byref(minor))
        if rc != EGL_TRUE:
            raise EglError('eglInitialize')
        print("EGL v%d.%d" % (major.value, minor.value))   # v1.4

        # acquires per-thread resources
        rc = eglBindAPI(EGL_OPENGL_ES_API)
        if rc != EGL_TRUE:
            raise EglError('eglBindApi')

        num_configs = c_int()
        if not eglChooseConfig(self.disp, attrib_list, byref(self.conf), 1, byref(num_configs)):
            raise EglError('eglChooseConfig')

        self.ctx = eglCreateContext(self.disp, self.conf, EGL_NO_CONTEXT, attributes)
        if not self.ctx:
            raise EglError('eglCreateContext')
        # print('eglCreateContext', self.ctx)

        self.create_surface(native_win.handle)


    def create_surface(self, native_win):
        self.surf = eglCreateWindowSurface(self.disp, self.conf, native_win, None)
        if not self.surf:
            raise EglError('eglCreateWindowSurface')
        # print('eglCreateWindowSurface', self.surf)

        rc = eglMakeCurrent(self.disp, self.surf, self.surf, self.ctx)
        if rc != EGL_TRUE:
            raise EglError('eglMakeCurrent')

        # must come after eglMakeCurrent()
        rc = eglSwapInterval(self.disp, self.SWAP_INTERVAL)
        if rc != EGL_TRUE:
            raise EglError('eglSwapInterval')


    def destroy_surface(self):
        print('destroy_surface', self.surf)
        if self.surf:
            eglMakeCurrent(self.disp, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT)
            eglDestroySurface(self.disp, self.surf)
            self.surf = EGL_NO_SURFACE


    # TODO: fix this, since in the past at least it would never let us
    # recreate the window or EGL context and continue drawing, after we'd
    # executed this. Seems to be an issue in the original bbutil.c and
    # it maybe wasn't designed to be restartable.
    #-----------------------------------------------
    #
    def terminate(self, chart=None):
        # typical EGL cleanup
        if self.disp:
            eglMakeCurrent(self.disp, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT)
            self.destroy_surface()

            if self.ctx:
                eglDestroyContext(self.disp, self.ctx)
                self.ctx = EGL_NO_CONTEXT

            if chart:
                import chart as c
                c.destroy_window(chart)

            eglTerminate(self.disp)
            self.disp = EGL_NO_DISPLAY

        eglReleaseThread()


    #-----------------------------------------------
    #
    def swap(self):
        rc = eglSwapBuffers(self.disp, self.surf)
        if rc != EGL_TRUE:
            raise EglError('eglSwapBuffers')
            # print('self.disp', self.disp, 'self.surf', self.surf)



# EOF

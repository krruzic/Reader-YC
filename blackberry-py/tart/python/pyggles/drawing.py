
import sys
import os
import threading
import queue
import traceback
import functools
from ctypes import (byref, c_int, cast, c_void_p, c_float, CDLL)

from bb import gles
from bb.egl import EGLint, EGL_BAD_NATIVE_WINDOW
from tart import dynload
from . import egl, timing, timer, color

# support library
_dll = dynload('_opengl')
# _dll.setup_logging()

# thread-local storage, basically acts as per-thread globals
context = threading.local()


class ContextError(Exception):
    '''Operation performed in/with wrong context.'''


def external(func):
    '''Decorator that redirects external calls through a message
    passed into the context's own thread, if called from a different
    thread, but which transparently calls the handler routine if
    called from within the context's own thread.
    '''
    @functools.wraps(func)
    def wrapped(self, *args, **kwargs):
        if getattr(context, 'drawing', None) is self:
            print('calling {} with {}, {}'.format(func.__name__, args, kwargs))
            func(self, *args, **kwargs)
        else:
            print('sending {} with {}, {}'.format(func.__name__, args, kwargs))
            self.send((func.__get__(self), args, kwargs))
    return wrapped



class Drawing:
    def __init__(self, bgcolor='black'):
        self.bgcolor = color.Color(bgcolor)

        self.queue = queue.Queue()
        self.visible = True
        self.active = False

        self.egl = None
        self.window = None
        self.items = [] # list of Drawables
        self.resize = True
        self.redraw = True
        self.size = (0, 0)

        self.render_thread = threading.Thread(target=self.run)
        self.render_thread.daemon = True


    def define_window(self, group, id, width, height):
        from tart.window import NativeWindow
        self.window = NativeWindow(group, id, width, height)

        # FIXME: ultimately would want the Font.dpi to be set
        # on a per-font basis, or at least not just globally here.
        disp = self.window.display
        # print('DWG: disp', disp)

        dpi = disp.get_dpi()
        print('DWG: dpi', dpi)

        from .font import Font
        Font.dpi = dpi

        # this being here is wartish
        self.active = True
        self.render_thread.start()


    #-----------------------------------------------
    #
    def setup(self):
        self.egl = egl.EglContext()
        self.egl.initialize(self.window)

        self.size = self.window.buffer_size
        self.sync_surface_size(*self.size)

        self.timing = timing.TimingService(debug=False)

        print('DWG: set up')


    #-----------------------------------------------
    #
    def cleanup(self):
        print('DWG: cleaned up')


    #-----------------------------------------------
    #
    def send(self, args):
        self.queue.put(args)


    #-----------------------------------------------
    #
    def quit(self):
        print('active = False')
        self.active = False # ask loop to tomorrow
        self.queue.put(None)


    #-----------------------------------------------
    #
    @external
    def add(self, dw):
        self.items.append(dw)
        dw.drawing = self
        dw.init()
        dw.valid = True
        self.redraw = True


    #-----------------------------------------------
    #
    @external
    def refresh(self):
        self.redraw = True


    #-----------------------------------------------
    #
    def run(self):
        print('DWG: running')

        # set ourselves up as the sole context for this thread
        try:
            context.drawing
            raise ContextError('context already exists in this thread')
        except AttributeError:
            context.drawing = self

        try:
            self.setup()

            while self.active:
                try:
                    self.process_messages()
                    self.timing.check_timers()

                    if self.visible:
                        if self.resize:
                            self.do_resize()

                        if self.redraw:
                            self.do_redraw()
                    else:
                        print('not visible')

                except SystemExit:
                    raise

                except:
                    traceback.print_exception(*sys.exc_info())

            print('DWG: quitting')

        finally:
            self.cleanup()


    #-----------------------------------------------
    #
    def process_messages(self):
        # print('DWG: process_messages')
        count = 0
        while True:
            try:
                timeout = self.timing.get_timeout()
            except:
                timeout = 0 if (self.resize or self.redraw) else None

            try:
                # print('===== get msg, timeout', timeout)
                msg = self.queue.get(timeout=timeout)
            except queue.Empty:
                # self._window.redraw = True
                break

            try:
                handler, pargs, kwargs = msg
            except TypeError:
                break
            except ValueError:
                kwargs = {}
                try:
                    handler, pargs = msg
                except ValueError:
                    pargs = ()
                    handler, = msg

            # print('DWG: call {} {} {}'.format(handler.__name__, pargs, kwargs))
            handler(*pargs, **kwargs)
            count += 1

        # print('DWG: processed {} messages'.format(count))


    #-----------------------------------------------
    #
    @external
    def set_size(self, w, h):
        print('DWG: set_size {},{}'.format(w, h))
        self.size = w, h

        oldsize = self.window.buffer_size
        if oldsize != self.size:
            print('size changed {} -> {}'.format(oldsize, self.size))

            self.window.buffer_size = self.size
            self.sync_surface_size(*self.size)

        else:
            print('size unchanged {}'.format(oldsize))

        self.resize = True



    #-----------------------------------------------
    #
    def do_resize(self):
        print('DWG: do_resize')

        for dw in self.items:
            if dw.valid:
                try:
                    dw.resize()
                except Exception:
                    dw.valid = False
                    raise

        self.resize = False
        self.redraw = True


    #-----------------------------------------------
    #
    def sync_surface_size(self, w, h):
        print('sync_surface_size', w, h)

        # FIXME: this is an ugly wart... need to study the connections
        # between libscreen and EGL better so we can figure out how
        # best to handle this, since it will change if we let the onscreen
        # window change size.

        # update sizes of "surface" (same as libscreen source viewport?)
        # so the fonts will be scaled and positioned properly
        swidth = egl.EGLint.in_dll(_dll, 'surface_width')
        swidth.value = w

        sheight = egl.EGLint.in_dll(_dll, 'surface_height')
        sheight.value = h


    #-----------------------------------------------
    #
    def do_redraw(self):
        # print('DWG: do_redraw')

        self.paint_background()

        for dw in self.items:
            if dw.valid:
                try:
                    dw.draw()
                except Exception:
                    dw.valid = False
                    raise

        self.redraw = False

        try:
            self.egl.swap()
        except egl.EglError as ex:
            # TODO: can probably just destroy/recreate surface in the
            # size-changing function, since we know we'll need to then
            # and don't have to wait for the error, and do redundant
            # resize/draw cycle.
            if ex.error == egl.EGL_BAD_NATIVE_WINDOW:
                try:
                    self.egl.get_surface_size()
                except:
                    print('failed to get surface size')
                self.egl.destroy_surface()
                self.egl.create_surface(self.window.handle)
                try:
                    self.egl.get_surface_size()
                except:
                    print('failed to get surface size')

                self.resize = True
            else:
                raise

        # print('do_redraw done')


    def paint_background(self):
        gles.glDisable(gles.GL_SCISSOR_TEST)
        gles.glClearColor(*self.bgcolor.tuple())
        gles.glClear(gles.GL_COLOR_BUFFER_BIT | gles.GL_DEPTH_BUFFER_BIT)


# EOF

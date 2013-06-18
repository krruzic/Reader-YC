'''BlackBerry-Tart support code.'''

from .core import send, log
from .app import Application


def dynload(name):
    '''Load platform-specific .so file from tart/lib-dynload folder,
    using the form .../lib-dynload/{name}-'''
    import os, platform, ctypes
    TARTDIR = os.path.dirname(os.path.dirname(__file__))

    # FIXME: under some circumstances, the platform.uname() call, which
    # calls os.popen(), will fail with a segfault in wsegl-screen.so,
    # which is whacked.  For now just work around that. :-(
    ARCH = 'arm' # platform.processor()[:3]
    path = os.path.join(TARTDIR, 'lib-dynload', '{}-{}.so'.format(name, ARCH))
    return ctypes.CDLL(path)


# EOF

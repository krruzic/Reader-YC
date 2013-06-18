'''Initialization script for BlackBerry-Tart framework.'''

import os
import sys
from threading import current_thread, Lock


def _install_slogger2():
    from bb import slog2
    import ctypes

    appid = os.path.basename(os.getcwd())

    buffers = (slog2.slog2_buffer_t * 1)()

    cfg = slog2.slog2_buffer_set_config_t()
    cfg.num_buffers = 1
    cfg.buffer_set_name = appid.encode('ascii', 'ignore')
    cfg.verbosity_level = slog2.SLOG2_INFO

    cfg.buffer_config[0].buffer_name = b"python"
    cfg.buffer_config[0].num_pages = 2

    rc = slog2.slog2_register(cfg, buffers, 0)
    sys.stdout.flush()

    buffer = buffers[0]

    class Redirector:
        lock = Lock()

        def __init__(self):
            self.pending = b''
        def write(self, text):
            ascii = text.encode('ascii', 'ignore')
            with self.lock:
                while b'\n' in ascii:
                    now, ascii = ascii.split(b'\n', 1)
                    if self.pending:
                        now = self.pending + now
                        self.pending = b''
                    slog2.slog2c(buffer, current_thread().ident, slog2.SLOG2_INFO, now)
                self.pending += ascii
        def flush(self):
            pass

    sys.stderr = Redirector()
    sys.stdout = Redirector()

    sys.__stdout__.flush()
    sys.__stderr__.flush()


# The following code is the main entry point for the Python code
# in a Tart application, at least if the correct command line
# arguments are provided in the MANIFEST.MF file in your .bar.
#
if __name__ == '__main__':
    _install_slogger2()

    try:
        import app
        a = app.App()
        a.start()
        # we don't return until the app terminates or raises an exception

    # The Python runtime will terminate the entire process if we allow
    # SystemExit to rise from here, when it calls PyErr_Print().  It's
    # possible to suppress that with Py_InspectFlag=1 but then we get
    # a traceback even with a clean SystemExit.  For simplicity we just
    # swallow it here to convert to a simple clean exit without killing
    # the whole process.
    except SystemExit:
        pass

    # other exceptions will result in a traceback from the cleanup in
    # PyRun_SimpleFileExFlags() so we can ignore them here


# EOF

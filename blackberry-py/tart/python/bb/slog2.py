'''Ctypes-based wrapper for the slog2 routines. See slog2.h.'''

# These routines are borrowed from the wrap.py code, but until we
# improve the Tart packaging/deployment support it's easier to
# just clone the code here rather than rely on wrap.py to be present.

from ._wrap import _func, _register_funcs

from ctypes import (POINTER, c_int, c_uint8, c_uint16, c_uint32, c_char_p,
    Structure)


SLOG2_MAX_BUFFERS = 4

# Severity level definitions
SLOG2_SHUTDOWN  = 0   # Shut down the system NOW. eg: for OEM use
SLOG2_CRITICAL  = 1   # Unexpected unrecoverable error. eg: hard disk error
SLOG2_ERROR     = 2   # Unexpected recoverable error. eg: needed to reset a hw controller
SLOG2_WARNING   = 3   # Expected error. eg: parity error on a serial port
SLOG2_NOTICE    = 4   # Warnings. eg: Out of paper
SLOG2_INFO      = 5   # Information. eg: Printing page 3
SLOG2_DEBUG1    = 6   # Debug messages eg: Normal detail
SLOG2_DEBUG2    = 7   # Debug messages eg: Fine detail

SLOG2_NOTIFICATION_PATH = "/pps/services/slogger2/notify"

# Enum for the state of the buffer_set
NOTIFY_STATE_CONNECTED  = 0
NOTIFY_STATE_DISCONNECT = 1
NOTIFY_STATE_REMOVE     = 2

class slog2_buffer_meta(Structure):
    pass

# Slog2 buffer is an opaque handle
slog2_buffer_t = POINTER(slog2_buffer_meta)


class slog2_buffer_config_t(Structure):
    _fields_ = [
        ('buffer_name', c_char_p),  # What we want to name the buffer
        ('num_pages', c_int),       # The number of 4K pages this buffer contains
        ]

class slog2_buffer_set_config_t(Structure):
    _fields_ = [
        ('num_buffers', c_int),         # Number of buffers to configure
        ('buffer_set_name', c_char_p),  # Process name, or other descriptor
        ('verbosity_level', c_uint8),   # The minimum severity to log
        ('buffer_config', slog2_buffer_config_t * SLOG2_MAX_BUFFERS), # Buffer configuration for num_buffers
        ]

slog2c = _func(c_int, slog2_buffer_t, c_uint16, c_uint8, c_char_p)
slog2_set_verbosity = _func(c_int, slog2_buffer_t, c_uint8)
slog2_get_verbosity = _func(c_uint8, slog2_buffer_t)
slog2_register = _func(c_int, POINTER(slog2_buffer_set_config_t), POINTER(slog2_buffer_t), c_uint32)
slog2_set_default_buffer = _func(slog2_buffer_t, slog2_buffer_t)
slog2_reset = _func(c_int)

_register_funcs('libslog2.so', globals())


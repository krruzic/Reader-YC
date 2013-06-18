'''Wrappers for libscreen routines'''

import ctypes
from ctypes import (c_bool, c_float, c_double, c_int, c_char_p, c_void_p, c_uint, c_longlong, c_ulonglong,
    POINTER, Structure, CFUNCTYPE)

from ._wrap import _func, _register_funcs


class _screen_context(Structure):
    _fields_ = []
screen_context_t = POINTER(_screen_context)

class _screen_display(Structure):
    _fields_ = []
screen_display_t = POINTER(_screen_display)

class _screen_window(Structure):
    _fields_ = []
screen_window_t = POINTER(_screen_window)

class _screen_pixmap(Structure):
    _fields_ = []
screen_pixmap_t = POINTER(_screen_pixmap)

class _screen_buffer(Structure):
    _fields_ = []
screen_buffer_t = POINTER(_screen_buffer)

class _screen_event(Structure):
    _fields_ = []
screen_event_t = POINTER(_screen_event)

class _screen_group(Structure):
    _fields_ = []
screen_group_t = POINTER(_screen_group)

SCREEN_APPLICATION_CONTEXT             = 0
SCREEN_WINDOW_MANAGER_CONTEXT          = (1 << 0)
SCREEN_INPUT_PROVIDER_CONTEXT          = (1 << 1)
SCREEN_POWER_MANAGER_CONTEXT           = (1 << 2)

SCREEN_APPLICATION_WINDOW              = 0
SCREEN_CHILD_WINDOW                    = 1
SCREEN_EMBEDDED_WINDOW                 = 2
SCREEN_ROOT_WINDOW                     = 3

#  buffer properties
SCREEN_PROPERTY_BUFFER_SIZE            = 5
SCREEN_PROPERTY_EGL_HANDLE             = 12
SCREEN_PROPERTY_FORMAT                 = 14
SCREEN_PROPERTY_INTERLACED             = 22
SCREEN_PROPERTY_PHYSICALLY_CONTIGUOUS  = 32
SCREEN_PROPERTY_PLANAR_OFFSETS         = 33
SCREEN_PROPERTY_POINTER                = 34
SCREEN_PROPERTY_PROTECTED              = 36
SCREEN_PROPERTY_STRIDE                 = 44
SCREEN_PROPERTY_PHYSICAL_ADDRESS       = 55

#  context properties
SCREEN_PROPERTY_DISPLAY_COUNT          = 59
SCREEN_PROPERTY_DISPLAYS               = 60
SCREEN_PROPERTY_IDLE_STATE             = 81
SCREEN_PROPERTY_IDLE_TIMEOUT           = 83
SCREEN_PROPERTY_KEYBOARD_FOCUS         = 84
SCREEN_PROPERTY_MTOUCH_FOCUS           = 85
SCREEN_PROPERTY_POINTER_FOCUS          = 86

#  display properties
SCREEN_PROPERTY_GAMMA                  = 2
SCREEN_PROPERTY_ID_STRING              = 20
SCREEN_PROPERTY_ROTATION               = 38
SCREEN_PROPERTY_SIZE                   = 40
SCREEN_PROPERTY_TRANSPARENCY           = 46
SCREEN_PROPERTY_TYPE                   = 47
SCREEN_PROPERTY_MIRROR_MODE            = 58
SCREEN_PROPERTY_ATTACHED               = 64
SCREEN_PROPERTY_DETACHABLE             = 65
SCREEN_PROPERTY_NATIVE_RESOLUTION      = 66
SCREEN_PROPERTY_PROTECTION_ENABLE      = 67
SCREEN_PROPERTY_PHYSICAL_SIZE          = 69
SCREEN_PROPERTY_FORMAT_COUNT           = 70
SCREEN_PROPERTY_FORMATS                = 71
# SCREEN_PROPERTY_IDLE_STATE          = 81
SCREEN_PROPERTY_KEEP_AWAKES            = 82
# SCREEN_PROPERTY_IDLE_TIMEOUT        = 83
# SCREEN_PROPERTY_KEYBOARD_FOCUS      = 84
SCREEN_PROPERTY_ID                     = 87
SCREEN_PROPERTY_POWER_MODE             = 88
SCREEN_PROPERTY_MODE_COUNT             = 89
SCREEN_PROPERTY_MODE                   = 90
SCREEN_PROPERTY_CONTEXT                = 95

#  event properties
SCREEN_PROPERTY_BUTTONS                = 6
SCREEN_PROPERTY_DEVICE_INDEX           = 10
SCREEN_PROPERTY_DISPLAY                = 11
SCREEN_PROPERTY_GROUP                  = 18
SCREEN_PROPERTY_INPUT_VALUE            = 21
SCREEN_PROPERTY_JOG_COUNT              = 23
SCREEN_PROPERTY_KEY_CAP                = 24
SCREEN_PROPERTY_KEY_FLAGS              = 25
SCREEN_PROPERTY_KEY_MODIFIERS          = 26
SCREEN_PROPERTY_KEY_SCAN               = 27
SCREEN_PROPERTY_KEY_SYM                = 28
SCREEN_PROPERTY_NAME                   = 30
SCREEN_PROPERTY_POSITION               = 35
# SCREEN_PROPERTY_SIZE                = 40
SCREEN_PROPERTY_SOURCE_POSITION        = 41
SCREEN_PROPERTY_SOURCE_SIZE            = 42
# SCREEN_PROPERTY_TYPE                = 47
SCREEN_PROPERTY_USER_DATA              = 49
SCREEN_PROPERTY_WINDOW                 = 52
# SCREEN_PROPERTY_MIRROR_MODE         = 58
SCREEN_PROPERTY_EFFECT                 = 62
# SCREEN_PROPERTY_ATTACHED            = 64
# SCREEN_PROPERTY_PROTECTION_ENABLE   = 67
SCREEN_PROPERTY_TOUCH_ID               = 73
SCREEN_PROPERTY_TOUCH_ORIENTATION      = 76
SCREEN_PROPERTY_TOUCH_PRESSURE         = 77
SCREEN_PROPERTY_TIMESTAMP              = 78
SCREEN_PROPERTY_SEQUENCE_ID            = 79
# SCREEN_PROPERTY_IDLE_STATE          = 81
# SCREEN_PROPERTY_MODE                = 90
SCREEN_PROPERTY_MOUSE_WHEEL            = 94

#  group properties
# SCREEN_PROPERTY_NAME                = 30
SCREEN_PROPERTY_USER_HANDLE            = 50
# SCREEN_PROPERTY_IDLE_STATE          = 81
# SCREEN_PROPERTY_IDLE_TIMEOUT        = 83
# SCREEN_PROPERTY_KEYBOARD_FOCUS      = 84
# SCREEN_PROPERTY_CONTEXT             = 95

#  pixmap properties
SCREEN_PROPERTY_ALPHA_MODE             = 1
# SCREEN_PROPERTY_BUFFER_SIZE         = 5
SCREEN_PROPERTY_COLOR_SPACE            = 8
# SCREEN_PROPERTY_FORMAT              = 14
# SCREEN_PROPERTY_ID_STRING           = 20
SCREEN_PROPERTY_RENDER_BUFFERS         = 37
SCREEN_PROPERTY_USAGE                  = 48
# SCREEN_PROPERTY_CONTEXT             = 95

#  window properties
# SCREEN_PROPERTY_ALPHA_MODE          = 1
SCREEN_PROPERTY_BRIGHTNESS             = 3
SCREEN_PROPERTY_BUFFER_COUNT           = 4
# SCREEN_PROPERTY_BUFFER_SIZE         = 5
SCREEN_PROPERTY_CLASS                  = 7
# SCREEN_PROPERTY_COLOR_SPACE         = 8
SCREEN_PROPERTY_CONTRAST               = 9
# SCREEN_PROPERTY_DISPLAY             = 11
SCREEN_PROPERTY_FLIP                   = 13
# SCREEN_PROPERTY_FORMAT              = 14
SCREEN_PROPERTY_FRONT_BUFFER           = 15
SCREEN_PROPERTY_GLOBAL_ALPHA           = 16
SCREEN_PROPERTY_PIPELINE               = 17
# SCREEN_PROPERTY_GROUP               = 18
SCREEN_PROPERTY_HUE                    = 19
# SCREEN_PROPERTY_ID_STRING           = 20
SCREEN_PROPERTY_MIRROR                 = 29
SCREEN_PROPERTY_OWNER_PID              = 31
# SCREEN_PROPERTY_POSITION            = 35
# SCREEN_PROPERTY_RENDER_BUFFERS      = 37
# SCREEN_PROPERTY_ROTATION            = 38
SCREEN_PROPERTY_SATURATION             = 39
# SCREEN_PROPERTY_SIZE                = 40
# SCREEN_PROPERTY_SOURCE_POSITION     = 41
# SCREEN_PROPERTY_SOURCE_SIZE         = 42
SCREEN_PROPERTY_STATIC                 = 43
SCREEN_PROPERTY_SWAP_INTERVAL          = 45
# SCREEN_PROPERTY_TRANSPARENCY        = 46
# SCREEN_PROPERTY_TYPE                = 47
# SCREEN_PROPERTY_USAGE               = 48
# SCREEN_PROPERTY_USER_HANDLE         = 50
SCREEN_PROPERTY_VISIBLE                = 51
SCREEN_PROPERTY_RENDER_BUFFER_COUNT    = 53
SCREEN_PROPERTY_ZORDER                 = 54
SCREEN_PROPERTY_SCALE_QUALITY          = 56
SCREEN_PROPERTY_SENSITIVITY            = 57
SCREEN_PROPERTY_CBABC_MODE             = 61
SCREEN_PROPERTY_FLOATING               = 63
SCREEN_PROPERTY_SOURCE_CLIP_POSITION   = 68
SCREEN_PROPERTY_SOURCE_CLIP_SIZE       = 72
SCREEN_PROPERTY_VIEWPORT_POSITION      = 74
SCREEN_PROPERTY_VIEWPORT_SIZE          = 75
SCREEN_PROPERTY_IDLE_MODE              = 80
SCREEN_PROPERTY_CLIP_POSITION          = 91
SCREEN_PROPERTY_CLIP_SIZE              = 92
SCREEN_PROPERTY_COLOR                  = 93
# SCREEN_PROPERTY_CONTEXT             = 95

SCREEN_MODE_PREFERRED                  = 0x1

SCREEN_MODE_PREFERRED_INDEX = -1

class screen_display_mode_t(Structure):
    _fields_ = [
        ('width', c_uint),
        ('height', c_uint),
        ('refresh', c_uint),
        ('interlaced', c_uint),
        ('aspect_ratio', c_uint * 2),
        ('flags', c_uint),
        ('index', c_uint),
        ('reserved', c_uint * 6),
        ]

SCREEN_POWER_MODE_OFF                 = 0x7680
SCREEN_POWER_MODE_SUSPEND             = 0x7681
SCREEN_POWER_MODE_LIMITED_USE         = 0x7682
SCREEN_POWER_MODE_ON                  = 0x7683

SCREEN_IDLE_MODE_NORMAL                = 0
SCREEN_IDLE_MODE_KEEP_AWAKE            = 1

SCREEN_DISPLAY_TYPE_INTERNAL           = 0x7660
SCREEN_DISPLAY_TYPE_COMPOSITE          = 0x7661
SCREEN_DISPLAY_TYPE_SVIDEO             = 0x7662
SCREEN_DISPLAY_TYPE_COMPONENT_YPbPr    = 0x7663
SCREEN_DISPLAY_TYPE_COMPONENT_RGB      = 0x7664
SCREEN_DISPLAY_TYPE_COMPONENT_RGBHV    = 0x7665
SCREEN_DISPLAY_TYPE_DVI                = 0x7666
SCREEN_DISPLAY_TYPE_HDMI               = 0x7667
SCREEN_DISPLAY_TYPE_DISPLAYPORT        = 0x7668
SCREEN_DISPLAY_TYPE_OTHER              = 0x7669

SCREEN_MIRROR_DISABLED                 = 0
SCREEN_MIRROR_NORMAL                   = 1
SCREEN_MIRROR_STRETCH                  = 2
SCREEN_MIRROR_ZOOM                     = 3
SCREEN_MIRROR_FILL                     = 4

SCREEN_NON_PRE_MULTIPLIED_ALPHA        = 0
SCREEN_PRE_MULTIPLIED_ALPHA            = 1

SCREEN_FORMAT_BYTE                     = 1
SCREEN_FORMAT_RGBA4444                 = 2
SCREEN_FORMAT_RGBX4444                 = 3
SCREEN_FORMAT_RGBA5551                 = 4
SCREEN_FORMAT_RGBX5551                 = 5
SCREEN_FORMAT_RGB565                   = 6
SCREEN_FORMAT_RGB888                   = 7
SCREEN_FORMAT_RGBA8888                 = 8
SCREEN_FORMAT_RGBX8888                 = 9
SCREEN_FORMAT_YVU9                     = 10
SCREEN_FORMAT_YUV420                   = 11
SCREEN_FORMAT_NV12                     = 12
SCREEN_FORMAT_YV12                     = 13
SCREEN_FORMAT_UYVY                     = 14
SCREEN_FORMAT_YUY2                     = 15
SCREEN_FORMAT_YVYU                     = 16
SCREEN_FORMAT_V422                     = 17
SCREEN_FORMAT_AYUV                     = 18
SCREEN_FORMAT_NFORMATS = SCREEN_FORMAT_AYUV + 1

SCREEN_USAGE_DISPLAY                   = (1 << 0)
SCREEN_USAGE_READ                      = (1 << 1)
SCREEN_USAGE_WRITE                     = (1 << 2)
SCREEN_USAGE_NATIVE                    = (1 << 3)
SCREEN_USAGE_OPENGL_ES1                = (1 << 4)
SCREEN_USAGE_OPENGL_ES2                = (1 << 5)
SCREEN_USAGE_OPENVG                    = (1 << 6)
SCREEN_USAGE_VIDEO                     = (1 << 7)
SCREEN_USAGE_CAPTURE                   = (1 << 8)
SCREEN_USAGE_ROTATION                  = (1 << 9)
SCREEN_USAGE_OVERLAY                   = (1 << 10)

SCREEN_TRANSPARENCY_SOURCE             = 0
SCREEN_TRANSPARENCY_TEST               = 1
SCREEN_TRANSPARENCY_SOURCE_COLOR       = 2
SCREEN_TRANSPARENCY_SOURCE_OVER        = 3
SCREEN_TRANSPARENCY_NONE               = 4
SCREEN_TRANSPARENCY_DISCARD            = 5

SCREEN_SENSITIVITY_TEST                = 0
SCREEN_SENSITIVITY_ALWAYS              = 1
SCREEN_SENSITIVITY_NEVER               = 2
SCREEN_SENSITIVITY_NO_FOCUS            = 3
SCREEN_SENSITIVITY_FULLSCREEN          = 4

SCREEN_QUALITY_NORMAL                  = 0
SCREEN_QUALITY_FASTEST                 = 1
SCREEN_QUALITY_NICEST                  = 2

SCREEN_CBABC_MODE_NONE                 = 0x7671
SCREEN_CBABC_MODE_VIDEO                = 0x7672
SCREEN_CBABC_MODE_UI                   = 0x7673
SCREEN_CBABC_MODE_PHOTO                = 0x7674

SCREEN_EVENT_NONE                      = 0
SCREEN_EVENT_CREATE                    = 1
SCREEN_EVENT_PROPERTY                  = 2
SCREEN_EVENT_CLOSE                     = 3
SCREEN_EVENT_INPUT                     = 4
SCREEN_EVENT_JOG                       = 5
SCREEN_EVENT_POINTER                   = 6
SCREEN_EVENT_KEYBOARD                  = 7
SCREEN_EVENT_USER                      = 8
SCREEN_EVENT_POST                      = 9
SCREEN_EVENT_EFFECT_COMPLETE           = 10
SCREEN_EVENT_DISPLAY                   = 11
SCREEN_EVENT_IDLE                      = 12

SCREEN_EVENT_MTOUCH_TOUCH              = 100
SCREEN_EVENT_MTOUCH_MOVE               = 101
SCREEN_EVENT_MTOUCH_RELEASE            = 102

SCREEN_BLIT_END                        = 0
SCREEN_BLIT_SOURCE_X                   = 1
SCREEN_BLIT_SOURCE_Y                   = 2
SCREEN_BLIT_SOURCE_WIDTH               = 3
SCREEN_BLIT_SOURCE_HEIGHT              = 4
SCREEN_BLIT_DESTINATION_X              = 5
SCREEN_BLIT_DESTINATION_Y              = 6
SCREEN_BLIT_DESTINATION_WIDTH          = 7
SCREEN_BLIT_DESTINATION_HEIGHT         = 8
SCREEN_BLIT_GLOBAL_ALPHA               = 9
SCREEN_BLIT_TRANSPARENCY               = 10
SCREEN_BLIT_SCALE_QUALITY              = 11
SCREEN_BLIT_COLOR                      = 12

SCREEN_WAIT_IDLE                       = (1 << 0)
SCREEN_PROTECTED                       = (1 << 1)
# SCREEN_DONT_FLUSH                      = (1 << 2) /* internal use only */
# SCREEN_POST_RESUME                     = (1 << 3) /* internal use only */

SCREEN_LEFT_MOUSE_BUTTON               = (1 << 0)
SCREEN_MIDDLE_MOUSE_BUTTON             = (1 << 1)
SCREEN_RIGHT_MOUSE_BUTTON              = (1 << 2)

SCREEN_REQUEST_PACKET                  = 0
SCREEN_BLIT_PACKET                     = 1
SCREEN_INPUT_PACKET                    = 2

# Blits
screen_blit = _func(c_int, screen_context_t, screen_buffer_t, screen_buffer_t, POINTER(c_int))
screen_fill = _func(c_int, screen_context_t, screen_buffer_t, POINTER(c_int))
screen_flush_blits = _func(c_int, screen_context_t, c_int)

# Buffers
screen_create_buffer = _func(c_int, POINTER(screen_buffer_t))
screen_destroy_buffer = _func(c_int, screen_buffer_t)
screen_get_buffer_property_cv = _func(c_int, screen_buffer_t, c_int, c_int, c_char_p)
screen_get_buffer_property_iv = _func(c_int, screen_buffer_t, c_int, POINTER(c_int))
screen_get_buffer_property_llv = _func(c_int, screen_buffer_t, c_int, POINTER(c_longlong))
screen_get_buffer_property_pv = _func(c_int, screen_buffer_t, c_int, POINTER(c_void_p))
screen_set_buffer_property_cv = _func(c_int, screen_buffer_t, c_int, c_int, c_char_p)
screen_set_buffer_property_iv = _func(c_int, screen_buffer_t, c_int, POINTER(c_int))
screen_set_buffer_property_llv = _func(c_int, screen_buffer_t, c_int, POINTER(c_longlong))
screen_set_buffer_property_pv = _func(c_int, screen_buffer_t, c_int, POINTER(c_void_p))

# Contexts
screen_create_context = _func(c_int, POINTER(screen_context_t), c_int)
screen_destroy_context = _func(c_int, screen_context_t)
screen_flush_context = _func(c_int, screen_context_t, c_int)
screen_get_context_property_cv = _func(c_int, screen_context_t, c_int, c_int, c_char_p)
screen_get_context_property_iv = _func(c_int, screen_context_t, c_int, POINTER(c_int))
screen_get_context_property_llv = _func(c_int, screen_context_t, c_int, POINTER(c_longlong))
screen_get_context_property_pv = _func(c_int, screen_context_t, c_int, POINTER(c_void_p))
screen_set_context_property_cv = _func(c_int, screen_context_t, c_int, c_int, c_char_p)
screen_set_context_property_iv = _func(c_int, screen_context_t, c_int, POINTER(c_int))
screen_set_context_property_llv = _func(c_int, screen_context_t, c_int, POINTER(c_longlong))
screen_set_context_property_pv = _func(c_int, screen_context_t, c_int, POINTER(c_void_p))

# Displays
screen_get_display_property_cv = _func(c_int, screen_display_t, c_int, c_int, c_char_p)
screen_get_display_property_iv = _func(c_int, screen_display_t, c_int, POINTER(c_int))
screen_get_display_property_llv = _func(c_int, screen_display_t, c_int, POINTER(c_longlong))
screen_get_display_property_pv = _func(c_int, screen_display_t, c_int, POINTER(c_void_p))
screen_set_display_property_cv = _func(c_int, screen_display_t, c_int, c_int, c_char_p)
screen_set_display_property_iv = _func(c_int, screen_display_t, c_int, POINTER(c_int))
screen_set_display_property_llv = _func(c_int, screen_display_t, c_int, POINTER(c_longlong))
screen_set_display_property_pv = _func(c_int, screen_display_t, c_int, POINTER(c_void_p))
screen_get_display_modes = _func(c_int, screen_display_t, c_int, POINTER(screen_display_mode_t))
screen_read_display = _func(c_int, screen_display_t, screen_buffer_t, c_int, POINTER(c_int), c_int)
screen_wait_vsync = _func(c_int, screen_display_t)

# Effects
screen_prepare_effect = _func(c_int, screen_window_t, c_int)
screen_set_effect_property_iv = _func(c_int, screen_window_t, c_int, POINTER(c_int))
screen_set_effect_property_fv = _func(c_int, screen_window_t, c_int, POINTER(c_float))
screen_start_effect = _func(c_int, screen_window_t, c_float, c_int)
screen_stop_effect = _func(c_int, screen_window_t, c_float, c_int)

# Events
pid_t = c_int
screen_create_event = _func(c_int, POINTER(screen_event_t))
screen_destroy_event = _func(c_int, screen_event_t)
screen_get_event = _func(c_int, screen_context_t, screen_event_t, c_ulonglong)
screen_get_event_property_cv = _func(c_int, screen_event_t, c_int, c_int, c_char_p)
screen_get_event_property_iv = _func(c_int, screen_event_t, c_int, POINTER(c_int))
screen_get_event_property_llv = _func(c_int, screen_event_t, c_int, POINTER(c_longlong))
screen_get_event_property_pv = _func(c_int, screen_event_t, c_int, POINTER(c_void_p))
screen_inject_event = _func(c_int, screen_display_t, screen_event_t)
screen_send_event = _func(c_int, screen_context_t, screen_event_t, pid_t)
screen_set_event_property_cv = _func(c_int, screen_event_t, c_int, c_int, c_char_p)
screen_set_event_property_iv = _func(c_int, screen_event_t, c_int, POINTER(c_int))
screen_set_event_property_llv = _func(c_int, screen_event_t, c_int, POINTER(c_longlong))
screen_set_event_property_pv = _func(c_int, screen_event_t, c_int, POINTER(c_void_p))

# Pixmaps
screen_attach_pixmap_buffer = _func(c_int, screen_pixmap_t, screen_buffer_t)
screen_create_pixmap = _func(c_int, POINTER(screen_pixmap_t), screen_context_t)
screen_create_pixmap_buffer = _func(c_int, screen_pixmap_t)
screen_destroy_pixmap = _func(c_int, screen_pixmap_t)
screen_destroy_pixmap_buffer = _func(c_int, screen_pixmap_t)
screen_get_pixmap_property_cv = _func(c_int, screen_pixmap_t, c_int, c_int, c_char_p)
screen_get_pixmap_property_iv = _func(c_int, screen_pixmap_t, c_int, POINTER(c_int))
screen_get_pixmap_property_llv = _func(c_int, screen_pixmap_t, c_int, POINTER(c_longlong))
screen_get_pixmap_property_pv = _func(c_int, screen_pixmap_t, c_int, POINTER(c_void_p))
screen_set_pixmap_property_cv = _func(c_int, screen_pixmap_t, c_int, c_int, c_char_p)
screen_set_pixmap_property_iv = _func(c_int, screen_pixmap_t, c_int, POINTER(c_int))
screen_set_pixmap_property_llv = _func(c_int, screen_pixmap_t, c_int, POINTER(c_longlong))
screen_set_pixmap_property_pv = _func(c_int, screen_pixmap_t, c_int, POINTER(c_void_p))

# Groups
screen_create_group = _func(c_int, POINTER(screen_group_t), screen_context_t)
screen_destroy_group = _func(c_int, screen_group_t)
screen_get_group_property_cv = _func(c_int, screen_group_t, c_int, c_int, c_char_p)
screen_get_group_property_iv = _func(c_int, screen_group_t, c_int, POINTER(c_int))
screen_get_group_property_llv = _func(c_int, screen_group_t, c_int, POINTER(c_longlong))
screen_get_group_property_pv = _func(c_int, screen_group_t, c_int, POINTER(c_void_p))
screen_set_group_property_cv = _func(c_int, screen_group_t, c_int, c_int, c_char_p)
screen_set_group_property_iv = _func(c_int, screen_group_t, c_int, POINTER(c_int))
screen_set_group_property_llv = _func(c_int, screen_group_t, c_int, POINTER(c_longlong))
screen_set_group_property_pv = _func(c_int, screen_group_t, c_int, POINTER(c_void_p))

# Windows
screen_attach_window_buffers = _func(c_int, screen_window_t, c_int, POINTER(screen_buffer_t))
screen_create_window = _func(c_int, POINTER(screen_window_t), screen_context_t)
screen_create_window_type = _func(c_int, POINTER(screen_window_t), screen_context_t, c_int)
screen_create_window_buffers = _func(c_int, screen_window_t, c_int)
screen_create_window_group = _func(c_int, screen_window_t, c_char_p)
screen_destroy_window = _func(c_int, screen_window_t)
screen_destroy_window_buffers = _func(c_int, screen_window_t)
screen_discard_window_regions = _func(c_int, screen_window_t, c_int, POINTER(c_int))
screen_get_window_property_cv = _func(c_int, screen_window_t, c_int, c_int, c_char_p)
screen_get_window_property_iv = _func(c_int, screen_window_t, c_int, POINTER(c_int))
screen_get_window_property_llv = _func(c_int, screen_window_t, c_int, POINTER(c_longlong))
screen_get_window_property_pv = _func(c_int, screen_window_t, c_int, POINTER(c_void_p))
screen_join_window_group = _func(c_int, screen_window_t, c_char_p)
screen_leave_window_group = _func(c_int, screen_window_t)
screen_post_window = _func(c_int, screen_window_t, screen_buffer_t, c_int, POINTER(c_int), c_int)
screen_read_window = _func(c_int, screen_window_t, screen_buffer_t, c_int, POINTER(c_int), c_int)
screen_ref_window = _func(c_int, screen_window_t)
screen_set_window_property_cv = _func(c_int, screen_window_t, c_int, c_int, c_char_p)
screen_set_window_property_iv = _func(c_int, screen_window_t, c_int, POINTER(c_int))
screen_set_window_property_llv = _func(c_int, screen_window_t, c_int, POINTER(c_longlong))
screen_set_window_property_pv = _func(c_int, screen_window_t, c_int, POINTER(c_void_p))
screen_share_window_buffers = _func(c_int, screen_window_t, screen_window_t)
screen_unref_window = _func(c_int, screen_window_t)

# Debugging
#screen_print_packet = _func(c_int, int type, void *packet, FILE *fd)


#----------------------------
# apply argtypes/restype to all functions
#
_register_funcs('libscreen.so', globals())

# EOF

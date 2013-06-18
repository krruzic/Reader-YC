'''Wrappers for libbps routines'''

import ctypes
from ctypes import (c_bool, c_float, c_double, c_int, c_char_p, c_void_p, c_uint,
    POINTER, Structure, CFUNCTYPE)

from ._wrap import _func, _register_funcs

from .screen import screen_context_t, screen_event_t

class bps_event_t(Structure):
    _fields_ = []


#----------------------------
# from bps/accelerometer.h
#
def UPDATE_FREQ_MS(t): return t

FREQ_40_HZ      = UPDATE_FREQ_MS(25)
FREQ_20_HZ      = UPDATE_FREQ_MS(50)
FREQ_10_HZ      = UPDATE_FREQ_MS(100)
FREQ_5_HZ       = UPDATE_FREQ_MS(200)
FREQ_3PT3_HZ    = UPDATE_FREQ_MS(300)
FREQ_2PT5_HZ    = UPDATE_FREQ_MS(400)
FREQ_2_HZ       = UPDATE_FREQ_MS(500)
FREQ_1PT6_HZ    = UPDATE_FREQ_MS(600)
FREQ_1PT2_HZ    = UPDATE_FREQ_MS(800)
FREQ_1_HZ       = UPDATE_FREQ_MS(1000)
accelerometer_frequency_t = c_int

accelerometer_is_supported = _func(c_bool)
accelerometer_set_update_frequency = _func(c_int, accelerometer_frequency_t)
accelerometer_read_forces = _func(c_int, POINTER(c_double), POINTER(c_double))

from math import atan, sqrt
M_1_PI = 0.31830988618379067154
def ACCELEROMETER_CALCULATE_ROLL(x, y, z):
    return (atan(x / sqrt(y * y + z * z)) * 180 * M_1_PI)

def ACCELEROMETER_CALCULATE_PITCH(x, y, z):
    return (atan(y / sqrt(x * x + z * z)) * 180 * M_1_PI)


#----------------------------
# from bps/audiodevice.h
#
AUDIODEVICE_INFO             = 0x01

AUDIODEVICE_DEVICE_UNRECOGNIZED = 0
AUDIODEVICE_DEVICE_MAIN         = 1
AUDIODEVICE_DEVICE_HDMI         = 2
AUDIODEVICE_DEVICE_SPEAKER      = 3
AUDIODEVICE_DEVICE_HEADPHONE    = 4
AUDIODEVICE_DEVICE_HEADSET      = 5
AUDIODEVICE_DEVICE_HANDSET      = 6
AUDIODEVICE_DEVICE_A2DP         = 7
AUDIODEVICE_DEVICE_BTSCO        = 8
AUDIODEVICE_DEVICE_HAC          = 9
AUDIODEVICE_DEVICE_TOSLINK      = 10
AUDIODEVICE_DEVICE_TTY          = 11
AUDIODEVICE_NUM_DEVICES = AUDIODEVICE_DEVICE_TTY + 1
audiodevice_device_t = c_int

class audiodevice_details_t(Structure):
    _fields_ = [
        ('device', audiodevice_device_t),
        ('connected', c_bool),
        ('numchans', c_int),
        ('order', c_char_p),
        ('path', c_char_p),
        ('audioconfig', c_char_p),
        ('input', c_bool),
        ('volumecontrol', c_bool),
        ('dependency', audiodevice_device_t),
        ]

audiodevice_get_domain = _func(c_int)
audiodevice_get = _func(c_int, POINTER(audiodevice_device_t), POINTER(c_char_p))
audiodevice_get_details = _func(c_int, audiodevice_device_t, POINTER(audiodevice_details_t))
audiodevice_free_details = _func(None, POINTER(audiodevice_details_t))
audiodevice_request_events = _func(c_int, c_int)
audiodevice_event_get_device = _func(audiodevice_device_t, POINTER(bps_event_t))
audiodevice_event_get_path = _func(c_char_p, POINTER(bps_event_t))


#----------------------------
# from bps/bps.h
#
BPS_VERSION = 1000000
BPS_VERSION_STRING = "1.0.0"

BPS_SUCCESS = 0
BPS_FAILURE = -1

bps_exec_func = CFUNCTYPE(c_int, c_void_p)

bps_channel_create = _func(c_int, POINTER(c_int), c_int)
bps_channel_destroy = _func(c_int, c_int)
bps_channel_get_active = _func(c_int)
bps_channel_push_event = _func(c_int, c_int, POINTER(bps_event_t))
bps_channel_set_active = _func(c_int, c_int)
bps_get_version = _func(c_int)
bps_initialize = _func(c_int)
bps_shutdown = _func(None) # not sure None is legal restype
bps_get_event = _func(c_int, POINTER(POINTER(bps_event_t)), c_int)
bps_push_event = _func(c_int, POINTER(bps_event_t))
bps_register_domain = _func(c_int)
bps_set_verbosity = _func(None, c_uint) # not sure None is legal restype
bps_free = _func(None, c_void_p) # not sure None is legal restype
bps_channel_exec = _func(c_int, c_int, bps_exec_func, c_void_p)
# bps_register_shutdown_handler
# bps_register_channel_destroy_handler
# bps_add_fd
# bps_remove_fd
# bps_add_sigevent_handler
# bps_remove_sigevent_handler
# bps_set_domain_data
# bps_get_domain_data

#----------------------------
# from bps/clock.h
#
CLOCK_INFO        = 0x01

clock_request_events = _func(c_int, c_int)
clock_get_domain = _func(c_int)
clock_event_get_date_change = _func(c_int, POINTER(bps_event_t))
clock_event_get_time_zone_change = _func(c_char_p, POINTER(bps_event_t))


#----------------------------
# from bps/event.h
#
BPS_EVENT_DOMAIN_MAX = 0x00000FFF

bps_event_get_domain = _func(c_int, POINTER(bps_event_t))
bps_event_get_code = _func(c_uint, POINTER(bps_event_t))

uintptr_t = POINTER(c_uint)
class bps_event_payload_t(Structure):
    _fields_ = [
        ('data1', uintptr_t),
        ('data2', uintptr_t),
        ('data3', uintptr_t),
        ]

bps_event_completion_func = CFUNCTYPE(None, POINTER(bps_event_t))

bps_event_create = _func(c_int, POINTER(POINTER(bps_event_t)), c_uint, c_uint,
    POINTER(bps_event_payload_t), bps_event_completion_func)
bps_event_destroy = _func(None, POINTER(bps_event_t))
bps_event_get_payload = _func(POINTER(bps_event_payload_t), POINTER(bps_event_t))


#----------------------------
# from bps/locale.h
#
LOCALE_INFO        = 0x01

locale_request_events = _func(c_int, c_int)
locale_stop_events = _func(c_int, c_int)
locale_get_domain = _func(c_int)
# warning: caller must free POINTER(c_char_p) buffers with bps_free()
locale_get_locale = _func(c_int, POINTER(c_char_p))
locale_get = _func(c_int, POINTER(c_char_p), POINTER(c_char_p))
locale_event_get_language = _func(c_char_p, POINTER(bps_event_t))
locale_event_get_country = _func(c_char_p, POINTER(bps_event_t))
locale_event_get_locale = _func(c_char_p, POINTER(bps_event_t))
locale_event_get_script = _func(c_char_p, POINTER(bps_event_t))


#----------------------------
# from bps/navigator.h
#
NAVIGATOR_INVOKE              = 0x01
NAVIGATOR_EXIT                = 0x02
NAVIGATOR_WINDOW_STATE        = 0x03
NAVIGATOR_SWIPE_DOWN          = 0x04
NAVIGATOR_SWIPE_START         = 0x05
NAVIGATOR_LOW_MEMORY          = 0x06
NAVIGATOR_ORIENTATION_CHECK   = 0x07
NAVIGATOR_ORIENTATION         = 0x08
NAVIGATOR_BACK                = 0x09
NAVIGATOR_WINDOW_ACTIVE       = 0x0a
NAVIGATOR_WINDOW_INACTIVE     = 0x0b
NAVIGATOR_ORIENTATION_DONE    = 0x0c
NAVIGATOR_ORIENTATION_RESULT  = 0x0d
NAVIGATOR_WINDOW_LOCK         = 0x0e
NAVIGATOR_WINDOW_UNLOCK       = 0x0f
NAVIGATOR_INVOKE_TARGET               = 0x10
NAVIGATOR_INVOKE_QUERY_RESULT         = 0x11
NAVIGATOR_INVOKE_VIEWER               = 0x12
NAVIGATOR_INVOKE_TARGET_RESULT        = 0x13
NAVIGATOR_INVOKE_VIEWER_RESULT        = 0x14
NAVIGATOR_INVOKE_VIEWER_RELAY         = 0x15
NAVIGATOR_INVOKE_VIEWER_STOPPED       = 0x16
NAVIGATOR_KEYBOARD_STATE              = 0x17
NAVIGATOR_KEYBOARD_POSITION           = 0x18
NAVIGATOR_INVOKE_VIEWER_RELAY_RESULT  = 0x19
NAVIGATOR_DEVICE_LOCK_STATE           = 0x1a
NAVIGATOR_WINDOW_COVER                = 0x1b
NAVIGATOR_WINDOW_COVER_ENTER          = 0x1c
NAVIGATOR_WINDOW_COVER_EXIT           = 0x1d
NAVIGATOR_CARD_PEEK_STARTED           = 0x1e
NAVIGATOR_CARD_PEEK_STOPPED           = 0x1f
NAVIGATOR_CARD_RESIZE                 = 0x20
NAVIGATOR_CHILD_CARD_CLOSED           = 0x21
NAVIGATOR_CARD_CLOSED                 = 0x22
NAVIGATOR_INVOKE_GET_FILTERS_RESULT   = 0x23
NAVIGATOR_APP_STATE                   = 0x24
NAVIGATOR_INVOKE_SET_FILTERS_RESULT   = 0x25
NAVIGATOR_PEEK_STARTED                = 0x26
NAVIGATOR_PEEK_STOPPED                = 0x27
NAVIGATOR_CARD_READY_CHECK            = 0x28
NAVIGATOR_POOLED                      = 0x29
NAVIGATOR_ORIENTATION_SIZE            = 0x2A
NAVIGATOR_OTHER                       = 0xff



NAVIGATOR_WINDOW_FULLSCREEN   = 0
NAVIGATOR_WINDOW_THUMBNAIL    = 1
NAVIGATOR_WINDOW_INVISIBLE    = 2
navigator_window_state_t = c_int

NAVIGATOR_BADGE_SPLAT = 0
navigator_badge_t = c_int

navigator_request_events = _func(c_int, c_int)
navigator_get_domain = _func(c_int)
navigator_invoke = _func(c_int, c_char_p, POINTER(c_char_p))
navigator_open_file = _func(c_int, c_char_p, POINTER(c_char_p))
navigator_add_uri = _func(c_int, c_char_p, c_char_p, c_char_p, c_char_p, POINTER(c_char_p))
navigator_extend_timeout = _func(c_int, c_int, POINTER(c_char_p))
navigator_request_swipe_start = _func(c_int)
navigator_stop_swipe_start = _func(c_int)
navigator_rotation_lock = _func(c_int, c_bool)
navigator_set_orientation = _func(c_int, c_int, POINTER(c_char_p))
navigator_set_window_angle = _func(c_int, c_int)
navigator_set_close_prompt = _func(c_int, c_char_p, c_char_p)
navigator_clear_close_prompt = _func(c_int)
navigator_set_badge = _func(c_int, navigator_badge_t)
navigator_clear_badge = _func(c_int)
navigator_event_get_window_state = _func(navigator_window_state_t, POINTER(bps_event_t))
navigator_event_get_groupid = _func(c_char_p, POINTER(bps_event_t))
navigator_event_get_orientation_angle = _func(c_int, POINTER(bps_event_t))
navigator_event_get_data = _func(c_char_p, POINTER(bps_event_t))
navigator_event_get_id = _func(c_char_p, POINTER(bps_event_t))
navigator_event_get_err = _func(c_char_p, POINTER(bps_event_t))
navigator_orientation_check_response = _func(None, POINTER(bps_event_t), c_bool)
navigator_done_orientation = _func(None, POINTER(bps_event_t))
navigator_done_orientation_id = _func(c_int, c_char_p)
navigator_close_window = _func(c_int)
navigator_get_device_lock_state = _func(c_int)
# TODO: add the latest new functions including get_orientation_size_width/height


#----------------------------
# from bps/orientation.h
#
ORIENTATION_INFO        = 0x01

ORIENTATION_FACE_UP     = 0
ORIENTATION_TOP_UP      = 1
ORIENTATION_BOTTOM_UP   = 2
ORIENTATION_LEFT_UP     = 3
ORIENTATION_RIGHT_UP    = 4
ORIENTATION_FACE_DOWN   = 5
orientation_direction_t = c_int

orientation_request_events = _func(c_int, c_int)
orientation_get_domain = _func(c_int)
orientation_get = _func(c_int, POINTER(orientation_direction_t), POINTER(c_int))
orientation_event_get_direction = _func(orientation_direction_t, POINTER(bps_event_t))
orientation_event_get_angle = _func(c_int, POINTER(bps_event_t))


#----------------------------
# from bps/screen.h
#
BPS_SCREEN_EVENT       = 0x01

screen_request_events = _func(screen_context_t)
screen_get_domain = _func(c_int)
screen_stop_events = _func(c_int, screen_context_t)
screen_event_get_event = _func(screen_event_t, POINTER(bps_event_t))


#----------------------------
# from bps/virtualkeyboard.h
#
SENSOR_GRAVITY_EARTH = 9.80665

SENSOR_ACCELEROMETER_READING            = 0x00
SENSOR_MAGNETOMETER_READING             = 0x01
SENSOR_GYROSCOPE_READING                = 0x02
SENSOR_AZIMUTH_PITCH_ROLL_READING       = 0x03
SENSOR_ALTIMETER_READING                = 0x04
SENSOR_TEMPERATURE_READING              = 0x05
SENSOR_PROXIMITY_READING                = 0x06
SENSOR_LIGHT_READING                    = 0x07
SENSOR_GRAVITY_READING                  = 0x08
SENSOR_LINEAR_ACCEL_READING             = 0x09
SENSOR_ROTATION_VECTOR_READING          = 0x0A
SENSOR_ROTATION_MATRIX_READING          = 0x0B

SENSOR_TYPE_ACCELEROMETER               = 0
SENSOR_TYPE_MAGNETOMETER                = 1
SENSOR_TYPE_GYROSCOPE                   = 2
SENSOR_TYPE_AZIMUTH_PITCH_ROLL          = 3
SENSOR_TYPE_ALTIMETER                   = 4
SENSOR_TYPE_TEMPERATURE                 = 5
SENSOR_TYPE_PROXIMITY                   = 6
SENSOR_TYPE_LIGHT                       = 7
SENSOR_TYPE_GRAVITY                     = 8
SENSOR_TYPE_LINEAR_ACCEL                = 9
SENSOR_TYPE_ROTATION_VECTOR             = 10
SENSOR_TYPE_ROTATION_MATRIX             = 11
sensor_type_t = c_int

SENSOR_ACCURACY_UNRELIABLE              = 0
SENSOR_ACCURACY_LOW                     = 1
SENSOR_ACCURACY_MEDIUM                  = 2
SENSOR_ACCURACY_HIGH                    = 3
sensor_accuracy_t = c_int

sensor_request_events = _func(c_int, sensor_type_t)
sensor_stop_events = _func(c_int, sensor_type_t)
sensor_get_domain = _func(c_int)
sensor_is_supported = _func(c_bool, sensor_type_t)
sensor_set_calibration = _func(c_int, sensor_type_t, c_bool)
sensor_set_skip_duplicates = _func(c_int, sensor_type_t, c_bool)
sensor_set_rate = _func(c_int, sensor_type_t, c_uint)
sensor_event_get_xyz = _func(c_int, POINTER(bps_event_t), POINTER(c_float), POINTER(c_float), POINTER(c_float))
sensor_event_get_apr = _func(c_int, POINTER(bps_event_t), POINTER(c_float), POINTER(c_float), POINTER(c_float))
sensor_event_get_altitude = _func(c_float, POINTER(bps_event_t))
sensor_event_get_temperature = _func(c_float, POINTER(bps_event_t))
sensor_event_get_proximity = _func(c_float, POINTER(bps_event_t))
sensor_event_get_illuminance = _func(c_float, POINTER(bps_event_t))

class sensor_rotation_matrix_t(Structure):
    _fields_ = [
        ('matrix', c_float * 9)
        ]

sensor_event_get_rotation_matrix = _func(c_int, POINTER(bps_event_t), POINTER(sensor_rotation_matrix_t))

class sensor_rotation_vector_t(Structure):
    _fields_ = [
        ('vector', c_float * 4)
        ]

sensor_event_get_rotation_vector = _func(c_int, POINTER(bps_event_t), POINTER(sensor_rotation_vector_t))
sensor_event_get_accuracy = _func(sensor_accuracy_t, POINTER(bps_event_t))

class sensor_info_t(Structure):
    _fields_ = []

sensor_info = _func(c_int, sensor_type_t, POINTER(POINTER(sensor_info_t)))

sensor_info_get_resolution = _func(c_float, POINTER(sensor_info_t))
sensor_info_get_range_minimum = _func(c_float, POINTER(sensor_info_t))
sensor_info_get_range_maximum = _func(c_float, POINTER(sensor_info_t))
sensor_info_get_delay_mininum = _func(c_uint, POINTER(sensor_info_t))
sensor_info_get_delay_maximum = _func(c_uint, POINTER(sensor_info_t))
sensor_info_get_delay_default = _func(c_uint, POINTER(sensor_info_t))
sensor_info_get_power = _func(c_float, POINTER(sensor_info_t))
sensor_info_destroy = _func(c_int, POINTER(sensor_info_t))


#----------------------------
# from bps/soundplayer.h
#

input_keypress = b'input_keypress'
notification_general = b'notification_general'
notification_sapphire =  b'notification_sapphire'
alarm_battery = b'alarm_battery'
event_browser_start = b'event_browser_start'
event_camera_shutter = b'event_camera_shutter'
event_recording_start = b'event_recording_start'
event_recording_stop = b'event_recording_stop'
event_device_lock = b'event_device_lock'
event_device_unlock = b'event_device_unlock'
event_device_tether = b'event_device_tether'
event_device_untether = b'event_device_untether'
event_video_call = b'event_video_call'
event_video_call_outgoing = b'event_video_call_outgoing'
system_master_volume_reference = b'system_master_volume_reference'

soundplayer_prepare_sound = _func(c_int, c_char_p)
soundplayer_play_sound = _func(c_int, c_char_p)


#----------------------------
# from bps/virtualkeyboard.h
#
VIRTUALKEYBOARD_EVENT_VISIBLE   = 0x01
VIRTUALKEYBOARD_EVENT_HIDDEN    = 0x02
VIRTUALKEYBOARD_EVENT_INFO      = 0x03

VIRTUALKEYBOARD_LAYOUT_DEFAULT  = 0
VIRTUALKEYBOARD_LAYOUT_URL      = 1
VIRTUALKEYBOARD_LAYOUT_EMAIL    = 2
VIRTUALKEYBOARD_LAYOUT_WEB      = 3
VIRTUALKEYBOARD_LAYOUT_NUM_PUNC = 4
VIRTUALKEYBOARD_LAYOUT_SYMBOL   = 5
VIRTUALKEYBOARD_LAYOUT_PHONE    = 6
VIRTUALKEYBOARD_LAYOUT_PIN      = 7
virtualkeyboard_layout_t = c_int

VIRTUALKEYBOARD_ENTER_DEFAULT   = 0
VIRTUALKEYBOARD_ENTER_GO        = 1
VIRTUALKEYBOARD_ENTER_JOIN      = 2
VIRTUALKEYBOARD_ENTER_NEXT      = 3
VIRTUALKEYBOARD_ENTER_SEARCH    = 4
VIRTUALKEYBOARD_ENTER_SEND      = 5
VIRTUALKEYBOARD_ENTER_SUBMIT    = 6
VIRTUALKEYBOARD_ENTER_DONE      = 7
VIRTUALKEYBOARD_ENTER_CONNECT   = 8
virtualkeyboard_enter_t = c_int

virtualkeyboard_show = _func(None)
virtualkeyboard_hide = _func(None)
virtualkeyboard_change_options = _func(None, virtualkeyboard_layout_t, virtualkeyboard_enter_t)
virtualkeyboard_get_height = _func(c_int, POINTER(c_int))
virtualkeyboard_request_events = _func(c_int, c_int)
virtualkeyboard_get_domain = _func(c_int)
virtualkeyboard_event_get_height = _func(c_int, POINTER(bps_event_t))


#----------------------------
# apply argtypes/restype to all functions
#
_register_funcs('libbps.so', globals())

# EOF

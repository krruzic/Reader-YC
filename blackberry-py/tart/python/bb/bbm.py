
from ._wrap import _func, _register_funcs
from ctypes import (POINTER, c_int, c_uint, c_uint8, c_uint16, c_uint32, c_int32,
    c_char_p, c_void_p, Structure)

from .bps import bps_event_t


BBMSP_SUCCESS = 0
BBMSP_ASYNC = 1
BBMSP_FAILURE = -1

BBMSP_VERSION = 1000000
BBMSP_VERSION_STRING = "1.0.0"

bbmsp_result_t = c_int
class bbmsp_event_t(Structure):
    _fields_ = []

bbmsp_get_version = _func(c_int)
bbmsp_request_events = _func(bbmsp_result_t, c_int)
bbmsp_get_domain = _func(c_int)
bbmsp_event_get_category = _func(bbmsp_result_t, POINTER(bps_event_t), POINTER(c_int))
bbmsp_event_get_type = _func(bbmsp_result_t, POINTER(bps_event_t), POINTER(c_int))
bbmsp_event_get = _func(bbmsp_result_t, POINTER(bps_event_t), POINTER(POINTER(bbmsp_event_t)))
bbmsp_register = _func(bbmsp_result_t, c_char_p)

# categories
BBMSP_REGISTRATION = 0
BBMSP_USER_PROFILE = 1
BBMSP_CONNECTION = 2
BBMSP_CONTACT_LIST = 3
BBMSP_USER_PROFILE_BOX = 4

# event types
BBMSP_SP_EVENT_ACCESS_CHANGED = 0
BBMSP_SP_EVENT_PROFILE_CHANGED = 1
BBMSP_SP_EVENT_CONTACT_CHANGED = 2
BBMSP_SP_EVENT_CONTACT_LIST_FULL = 3
BBMSP_SP_EVENT_USER_PROFILE_BOX_ITEM_ADDED = 13
BBMSP_SP_EVENT_USER_PROFILE_BOX_ITEM_REMOVED = 14
BBMSP_SP_EVENT_USER_PROFILE_BOX_ICON_ADDED = 15
BBMSP_SP_EVENT_USER_PROFILE_BOX_ICON_RETRIEVED = 17

# access status
BBMSP_ACCESS_ALLOWED = 0
BBMSP_ACCESS_UNKNOWN = 1
BBMSP_ACCESS_UNREGISTERED = 2
BBMSP_ACCESS_PENDING = 3
BBMSP_ACCESS_BLOCKED_BY_USER = 4
BBMSP_ACCESS_BLOCKED_BY_RIM = 5
BBMSP_ACCESS_NO_DATA_CONNECTION = 6
BBMSP_ACCESS_UNEXPECTED_ERROR = 7
BBMSP_ACCESS_INVALID_UUID = 8
BBMSP_ACCESS_TEMPORARY_ERROR = 9
BBMSP_ACCESS_MAX_DOWNLOADS_REACHED = 10
BBMSP_ACCESS_EXPIRED = 11
BBMSP_ACCESS_CANCELLED_BY_USER = 12
BBMSP_ACCESS_MAX_APPS_REACHED = 13

bbmsp_event_access_changed_get_access_allowed = _func(c_int, POINTER(bbmsp_event_t))
bbmsp_event_access_changed_get_access_error_code = _func(c_int, POINTER(bbmsp_event_t))
bbmsp_is_access_allowed = _func(c_int)
bbmsp_get_access_code = _func(c_int)
bbmsp_can_show_profile_box = _func(c_int)
bbmsp_can_send_bbm_invite = _func(c_int)

bbmsp_send_download_invitation = _func(c_int)


#----------------------------
# from bbmsp/bbmsp_presence.h
#

bbmsp_presence_update_types_t = c_int

BBMSP_DISPLAY_NAME = 1 << 0
BBMSP_DISPLAY_PICTURE = 1 << 1
BBMSP_PERSONAL_MESSAGE = 1 << 2
BBMSP_STATUS = 1 << 3
BBMSP_INSTALL_APP = 1 << 4
BBMSP_UNINSTALL_APP = 1 << 5
BBMSP_INVITATION_RECEIVED = 1 << 6


bbmsp_presence_status_t = c_int

BBMSP_PRESENCE_STATUS_AVAILABLE = 0
BBMSP_PRESENCE_STATUS_BUSY = 1


#----------------------------
# from bbmsp/bbmsp_userprofile.h
#

BBMSP_PROFILE_DISPLAY_NAME_MAX = 256
BBMSP_PROFILE_PERSONAL_MSG_MAX = 161
BBMSP_PROFILE_STATUS_MSG_MAX = 161
BBMSP_PROFILE_PPID_MAX = 256
BBMSP_PROFILE_HANDLE_MAX = 256


class bbmsp_profile_t(Structure): _fields_ = []
bbmsp_image_t = c_void_p

size_t = c_int

bbmsp_get_user_profile = _func(bbmsp_result_t,
    POINTER(bbmsp_profile_t))
bbmsp_set_user_profile_status = _func(bbmsp_result_t,
    bbmsp_presence_status_t,
    c_char_p)
bbmsp_set_user_profile_personal_message = _func(bbmsp_result_t,
    c_char_p)
bbmsp_set_user_profile_display_picture = _func(bbmsp_result_t,
    POINTER(bbmsp_image_t))
bbmsp_profile_create = _func(bbmsp_result_t,
    POINTER(POINTER(bbmsp_profile_t)))
bbmsp_profile_destroy = _func(bbmsp_result_t,
    POINTER(POINTER(bbmsp_profile_t)))
bbmsp_profile_get_display_name = _func(bbmsp_result_t,
    POINTER(bbmsp_profile_t),
    c_char_p,
    size_t)
bbmsp_profile_get_personal_message = _func(bbmsp_result_t,
    POINTER(bbmsp_profile_t),
    c_char_p,
    size_t)
bbmsp_profile_get_status = _func(bbmsp_result_t,
    POINTER(bbmsp_profile_t),
    POINTER(bbmsp_presence_status_t))
bbmsp_profile_get_status_message = _func(bbmsp_result_t,
    POINTER(bbmsp_profile_t),
    c_char_p,
    size_t)
bbmsp_profile_get_ppid = _func(bbmsp_result_t,
    POINTER(bbmsp_profile_t),
    c_char_p,
    size_t)
bbmsp_profile_get_handle = _func(bbmsp_result_t,
    POINTER(bbmsp_profile_t),
    c_char_p,
    size_t)
bbmsp_profile_get_app_version = _func(bbmsp_result_t,
    POINTER(bbmsp_profile_t),
    c_char_p,
    size_t)
bbmsp_profile_get_platform_version = _func(bbmsp_result_t,
    POINTER(bbmsp_profile_t),
    POINTER(c_int))
bbmsp_profile_get_display_picture = _func(bbmsp_result_t,
    POINTER(bbmsp_profile_t),
    POINTER(bbmsp_image_t))
bbmsp_profile_set_status = _func(bbmsp_result_t,
    POINTER(bbmsp_profile_t),
    bbmsp_presence_status_t,
    c_char_p)
bbmsp_profile_set_personal_message = _func(bbmsp_result_t,
    POINTER(bbmsp_profile_t),
    c_char_p)
bbmsp_profile_set_display_picture = _func(bbmsp_result_t,
    POINTER(bbmsp_profile_t),
    POINTER(bbmsp_image_t))
bbmsp_event_profile_changed_get_profile = _func(bbmsp_result_t,
    POINTER(bbmsp_event_t),
    POINTER(POINTER(bbmsp_profile_t)))
bbmsp_event_profile_changed_get_presence_update_type = _func(bbmsp_result_t,
    POINTER(bbmsp_event_t),
    POINTER(bbmsp_presence_update_types_t))
bbmsp_profile_set_display_name = _func(bbmsp_result_t,
    POINTER(bbmsp_profile_t),
    c_char_p)


#----------------------------
# from bbmsp/bbmsp_util.h
#
BBMSP_IMAGE_TYPE_JPG = 0
BBMSP_IMAGE_TYPE_PNG = 1
BBMSP_IMAGE_TYPE_GIF = 2
BBMSP_IMAGE_TYPE_BMP = 3
bbmsp_image_type_t = c_int

bbmsp_image_create_empty = _func(c_int, POINTER(POINTER(bbmsp_image_t)))
bbmsp_image_create = _func(bbmsp_result_t,
    POINTER(POINTER(bbmsp_image_t)), bbmsp_image_type_t, c_char_p, c_uint32)
bbmsp_image_destroy = _func(c_int, POINTER(POINTER(bbmsp_image_t)))
bbmsp_image_get_type = _func(bbmsp_image_type_t, POINTER(bbmsp_image_t))
bbmsp_image_get_data = _func(c_void_p, POINTER(bbmsp_image_t))
bbmsp_image_get_data_size = _func(c_uint32, POINTER(bbmsp_image_t))


#----------------------------
# from bbmsp/bbmsp_user_profile_box.h
#
class bbmsp_user_profile_box_item_t(Structure):
    _fields_ = []
class bbmsp_user_profile_box_icon_t(Structure):
    _fields_ = []
class bbmsp_user_profile_box_item_list_t(Structure):
    _fields_ = []

bbmsp_user_profile_box_item_create = _func(bbmsp_result_t,
    POINTER(POINTER(bbmsp_user_profile_box_item_t)))
bbmsp_user_profile_box_item_destroy = _func(bbmsp_result_t,
    POINTER(POINTER(bbmsp_user_profile_box_item_t)))
bbmsp_user_profile_box_item_copy = _func(bbmsp_result_t,
    POINTER(bbmsp_user_profile_box_item_t), POINTER(bbmsp_user_profile_box_item_t))
bbmsp_user_profile_box_item_list_create = _func(bbmsp_result_t,
    POINTER(POINTER(bbmsp_user_profile_box_item_list_t)))
bbmsp_user_profile_box_item_list_destroy = _func(bbmsp_result_t,
    POINTER(POINTER(bbmsp_user_profile_box_item_list_t)))
bbmsp_user_profile_box_item_get_item_id = _func(bbmsp_result_t,
    POINTER(bbmsp_user_profile_box_item_t), c_char_p, size_t)
bbmsp_user_profile_box_item_get_cookie = _func(bbmsp_result_t,
    POINTER(bbmsp_user_profile_box_item_t), c_char_p, size_t)
bbmsp_user_profile_box_item_get_text = _func(bbmsp_result_t,
    POINTER(bbmsp_user_profile_box_item_t), c_char_p, size_t)
bbmsp_user_profile_box_item_get_icon_id = _func(bbmsp_result_t,
    POINTER(bbmsp_user_profile_box_item_t), POINTER(c_int32))
bbmsp_user_profile_box_add_item = _func(bbmsp_result_t,
    c_char_p, c_int32, c_char_p)
bbmsp_user_profile_box_add_item_no_icon = _func(bbmsp_result_t,
    c_char_p, c_char_p)
bbmsp_user_profile_box_get_item = _func(bbmsp_result_t,
    c_char_p, POINTER(bbmsp_user_profile_box_item_t))
bbmsp_user_profile_box_get_items = _func(bbmsp_result_t,
    POINTER(bbmsp_user_profile_box_item_list_t))
bbmsp_user_profile_box_items_size = _func(c_uint32,
    POINTER(bbmsp_user_profile_box_item_list_t))
bbmsp_user_profile_box_itemlist_get_at = _func(POINTER(bbmsp_user_profile_box_item_t),
    POINTER(bbmsp_user_profile_box_item_list_t), c_uint)
bbmsp_user_profile_box_itemlist_remove_at = _func(bbmsp_result_t,
    POINTER(bbmsp_user_profile_box_item_list_t), c_uint)
bbmsp_user_profile_box_remove_item = _func(bbmsp_result_t, c_char_p)
bbmsp_user_profile_box_remove_all_items = _func(bbmsp_result_t)
bbmsp_user_profile_box_register_icon = _func(bbmsp_result_t,
    c_int32, POINTER(bbmsp_image_t))
bbmsp_user_profile_box_retrieve_icon = _func(bbmsp_result_t, c_int32)
bbmsp_event_user_profile_box_item_added_get_item = _func(bbmsp_result_t,
    POINTER(bbmsp_event_t), POINTER(bbmsp_user_profile_box_item_t))
bbmsp_event_user_profile_box_item_removed_get_item = _func(bbmsp_result_t,
    POINTER(bbmsp_event_t), POINTER(bbmsp_user_profile_box_item_t))
bbmsp_event_user_profile_box_icon_retrieved_get_icon_id = _func(bbmsp_result_t,
    POINTER(bbmsp_event_t), POINTER(c_int32))
bbmsp_event_user_profile_box_icon_retrieved_get_icon_image = _func(bbmsp_result_t,
    POINTER(bbmsp_event_t), POINTER(POINTER(bbmsp_image_t)))


_register_funcs('libbbmsp.so', globals())

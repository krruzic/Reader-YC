
import os
from ctypes import (c_int, byref, POINTER, pointer,
    create_string_buffer, string_at, sizeof)
import string
import random

from bb import bps
from bb.bbm import *

import tart
from tart.fsm import StateMachine


class BbmError(Exception):
    '''represents failure in BBM call'''


class BbmEvent:
    CATEGORIES = {
        0: 'REGISTRATION',
        1: 'USER_PROFILE',
        2: 'CONNECTION',
        3: 'CONTACT_LIST',
        4: 'USER_PROFILE_BOX',
        }

    EVENT_TYPES = {
        0: 'EVENT_ACCESS_CHANGED',
        1: 'EVENT_PROFILE_CHANGED',
        2: 'EVENT_CONTACT_CHANGED',
        3: 'EVENT_CONTACT_LIST_FULL',
        13: 'EVENT_USER_PROFILE_BOX_ITEM_ADDED',
        14: 'EVENT_USER_PROFILE_BOX_ITEM_REMOVED',
        15: 'EVENT_USER_PROFILE_BOX_ICON_ADDED',
        17: 'EVENT_USER_PROFILE_BOX_ICON_RETRIEVED',
        }


    def __init__(self, code, category, type, bbm_event, fake=False):
        self.code = code
        self.category = category
        self.type = type
        self.bbm_event = bbm_event
        self.fake = fake


    def __repr__(self):
        r = ['<BbmEvent %d' % self.code]
        r.append(' ' + self.CATEGORIES.get(self.category, 'cat?'))
        r.append(' ' + self.EVENT_TYPES.get(self.type, 'type?'))
        if self.fake:
            r.append(' (fake!)')
        r.append('>')
        return ''.join(r)


    def is_reg_state_event(self):
        return (self.category == BBMSP_REGISTRATION
            and self.type == BBMSP_SP_EVENT_ACCESS_CHANGED)


    def is_user_profile_event(self):
        return (self.category == BBMSP_USER_PROFILE
            and self.type == BBMSP_SP_EVENT_PROFILE_CHANGED)



class BbmspHandler:
    def __init__(self, uuid, dispatcher):
        self.uuid = uuid
        self.fsm = StateMachine(stateOrigin=self,
            onStateChanged=self.onStateChanged,
            debug=True)

        # must call this only once, apparently (see native sample)
        rc = bbmsp_request_events(0)
        if rc == BBMSP_FAILURE:
            tart.send('bbmDisabled')
            raise BbmError('cannot use BBM, try restart')
        print('bbmsp_request_events(0), rc', rc)

        self.status = None
        self.status_message = None
        self.personal_message = None

        self.prev_access = -1

        dispatcher.add_handler(bbmsp_get_domain(), self.handle_event)

        self.send_flags_message()


    @property
    def registered(self):
        return self.fsm.state == 'allowed'


    def make_event(self, bps_event):
        code = bps.bps_event_get_code(bps_event)

        intval = c_int()
        rc = bbmsp_event_get_category(bps_event, byref(intval))
        if rc == BBMSP_FAILURE:
            raise BbmError('unable to get event category')
        category = intval.value

        rc = bbmsp_event_get_type(bps_event, byref(intval))
        if rc == BBMSP_FAILURE:
            raise BbmError('unable to get event type')
        type = intval.value

        bbm_event = POINTER(bbmsp_event_t)()
        rc = bbmsp_event_get(bps_event, byref(bbm_event))
        if rc == BBMSP_FAILURE:
            raise BbmError('unable to get bbmsp_event')

        return BbmEvent(code, category, type, bbm_event)


    def get_access_code(self):
        code = bbmsp_get_access_code()
        # print('-> get_access_code()', code)
        return code


    def send_flags_message(self):
        allowed = bbmsp_is_access_allowed()
        access = self.get_access_code()
        profile = bbmsp_can_show_profile_box()
        invite = bbmsp_can_send_bbm_invite()
        tart.send('bbmFlags', allowed=allowed, access=access,
            profile=profile, invite=invite)
        # tart.send('bbmFlagsTest', allowed=allowed, access=access,
        #     profile=profile, invite=invite)


    def query(self):
        print('BBM query')
        self.send_flags_message()


    def set_message(self, msg=None):
        print('BBM set_message {!r} (was {!r})'.format(msg, self.personal_message))
        if msg != self.personal_message:
            rc = bbmsp_set_user_profile_personal_message(
                None if msg is None else msg.encode('utf8'))
            print('set profile personal msg, rc', rc)


    def set_status(self, status=None, msg=None):
        print('BBM set_status {!r}, {!r}'.format(status, msg))
        if status != self.status or msg != self.status_message:
            print('setting status to', status, msg)
            rc = bbmsp_set_user_profile_status(status,
                None if msg is None else msg.encode('utf8'))
            print('set profile status, rc', rc)


    #---------------------------------------------
    #
    def handle_event(self, bps_event):
        '''Handle BPS events for bbmsp domain'''

        # print('domain', domain, 'bbm_domain', bbmsp_get_domain())
        event = self.make_event(bps_event)
        if event.is_reg_state_event():
            # TODO: build the code into the event somehow (can you
            # retrieve it from the event?)
            self.prev_access = code = self.get_access_code()
            tart.send('bbmAccess', state=code,
                text=self.REG_STATE_NAMES.get(code, '?unrecognized?'))
            # tart.send('bbmAccessTest', state=code,
            #     text=self.REG_STATE_NAMES.get(code, '?unrecognized?'))

        else:
            code = self.get_access_code()
            if code != self.prev_access:
                self.prev_access = code

                tart.send('bbmAccess', state=code,
                    text=self.REG_STATE_NAMES.get(code, '?unrecognized?'))
                # tart.send('bbmAccessTest', state=code,
                #     text=self.REG_STATE_NAMES.get(code, '?unrecognized?'))

                fake_event = BbmEvent(0,
                    BBMSP_REGISTRATION,
                    BBMSP_SP_EVENT_ACCESS_CHANGED,
                    None,
                    fake=True)
                self.fsm.execute(fake_event)

        if event.is_user_profile_event():
            self.check_user_profile_event(event)

        self.fsm.execute(event)


    def onStateChanged(self, oldState, newState):
        '''called after exiting old state and entering new state'''
        print('BBM: FSM', oldState, '-->', newState)


    REG_STATES = dict(
        Allowed = 0,
        Unknown = 1,
        Unregistered = 2,
        Pending = 3,
        BlockedByUser = 4,
        BlockedByRIM = 5,
        NoDataConnection = 6,
        UnexpectedError = 7,
        InvalidUuid = 8,
        TemporaryError = 9,
        MaxDownloadsReached = 10,
        Expired = 11,
        CancelledByUser = 12,
        MaxAppsReached = 13,
        BbmDisabled = 14,
        )
    REG_STATE_NAMES = {
        v: k for k, v in REG_STATES.items()
    }

    def map_state(self, rs):
        if rs <= self.REG_STATES['Pending']:
            name = self.REG_STATE_NAMES[rs].lower()
        else:
            name = 'other'

        print('map_state', rs, '->', name)
        return name


    def _state_init(self, event=None):
        if event.is_reg_state_event():
            return self.map_state(self.get_access_code())

    _state_unknown = _state_init


    def _enter_unregistered(self):
        self.send_flags_message()

    def _state_unregistered(self, event=None):
        if event.is_reg_state_event():
            return self.map_state(self.get_access_code())


    def _enter_pending(self):
        self.send_flags_message()

    def _state_pending(self, event=None):
        if event.is_reg_state_event():
            return self.map_state(self.get_access_code())


    def _enter_allowed(self):
        self.send_flags_message()
        # tart.send('canSendDownloadInvitationTest', state=True)

        profile = self.get_user_profile()
        app_version = self.get_app_version(profile)
        ppid = self.get_ppid(profile)
        print('BBM app_version', app_version, 'ppid', ppid)

        self.status = self.get_status(profile)
        self.status_message = self.get_status_message(profile)
        print('BBM status {} [{!r}]'.format(self.status, self.status_message))

        self.personal_message = self.get_personal_message(profile)
        print('BBM message {!r}'.format(self.personal_message))

        name = self.get_display_name(profile)
        print('BBM display_name', name)


    def _state_allowed(self, event=None):
        if event.is_reg_state_event():
            return self.map_state(self.get_access_code())

    def _exit_allowed(self):
        # tart.send('canSendDownloadInvitationTest', state=False)
        pass


    def _enter_other(self):
        self.send_flags_message()

    def _state_other(self, event=None):
        if event.is_reg_state_event():
            return self.map_state(self.get_access_code())


    def register(self):
        print('bbm register')
        rc = bbmsp_register(self.uuid)
        print('bbmsp_register({}), rc {}'.format(self.uuid, rc))


    def send_download_invitation(self):
        rc = bbmsp_send_download_invitation()
        print('send invitation', rc)
        pass


    def check_user_profile_event(self, event):
        profile = POINTER(bbmsp_profile_t)()
        rc = bbmsp_event_profile_changed_get_profile(
            event.bbm_event, byref(profile))
        # print('  get event profile, rc', rc, profile)
        profile = profile.contents
        # print('  profile', profile)

        update_type = bbmsp_presence_update_types_t()
        rc = bbmsp_event_profile_changed_get_presence_update_type(
            event.bbm_event, byref(update_type))
        update_type = update_type.value

        # print('  update type 0x{:02x}, rc'.format(update_type), rc)

        if update_type == BBMSP_DISPLAY_NAME:
            print('  == display_name', self.get_display_name(profile))

        elif update_type == BBMSP_DISPLAY_PICTURE:
            print('ignoring display picture change')
            # self.get_display_picture(profile)

        elif update_type == BBMSP_PERSONAL_MESSAGE:
            self.personal_message = self.get_personal_message(profile)
            print(' == personal message', self.personal_message)

        elif update_type == BBMSP_STATUS:
            self.status = self.get_status(profile)
            self.status_message = self.get_status_message(profile)
            print(' == status {} {!r}'.format(self.status, self.status_message))

        else:
            print('unhandled update type', update_type)


    def get_user_profile(self):
        profile = bbmsp_profile_t()
        rc = bbmsp_get_user_profile(byref(profile))
        if rc == BBMSP_FAILURE:
            raise BbmError('bbmsp_get_user_profile()')
        # print('  get profile, rc', rc, profile)
        return profile


    def _get_profile_string(self, profile, name, max_length):
        buf = create_string_buffer(max_length)
        func = globals()[name]
        rc = func(byref(profile), buf, len(buf))
        if rc == BBMSP_FAILURE:
            raise BbmError(name + '()')
        return buf.value.decode('utf-8')


    def get_app_version(self, profile):
        return self._get_profile_string(profile,
            'bbmsp_profile_get_app_version', 128)


    def get_personal_message(self, profile):
        return self._get_profile_string(profile,
            'bbmsp_profile_get_personal_message', BBMSP_PROFILE_PERSONAL_MSG_MAX)


    def get_ppid(self, profile):
        return self._get_profile_string(profile,
            'bbmsp_profile_get_ppid', BBMSP_PROFILE_PPID_MAX)


    def get_status(self, profile):
        status = bbmsp_presence_status_t()
        rc = bbmsp_profile_get_status(profile, byref(status))
        if rc == BBMSP_FAILURE:
            raise BbmError('bbmsp_profile_get_status()')
        return status.value


    def get_status_message(self, profile):
        return self._get_profile_string(profile,
            'bbmsp_profile_get_status_message', BBMSP_PROFILE_STATUS_MSG_MAX)


    def get_display_name(self, profile):
        return self._get_profile_string(profile,
            'bbmsp_profile_get_display_name', BBMSP_PROFILE_DISPLAY_NAME_MAX)


    def get_display_picture(self, profile):
        image = bbmsp_image_t()
        rc = bbmsp_profile_get_display_picture(profile, image)
        print('  == get picture', rc, image, sizeof(image))

        image_type = bbmsp_image_get_type(image)
        print('  == image type', image_type)
        fileext = {
            0: 'jpg',
            1: 'png',
            2: 'gif',
            3: 'bmp',
            }.get(image_type, '')

        image_size = bbmsp_image_get_data_size(image)
        print('  == image size', image_size)

        data = bbmsp_image_get_data(image)
        print('  == image data at 0x{:08X}'.format(data))

        buf = string_at(data, image_size)   # warning: don't keep reference!
        # print('image', buf[:60], '...', buf[-20:])
        # with open('/accounts/1000/shared/misc/bbmimage.' + fileext, 'wb') as f:
        #     f.write(buf)


# EOF

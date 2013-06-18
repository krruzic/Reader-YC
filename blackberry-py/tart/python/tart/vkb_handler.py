
from bb import bps
import tart


class VkbHandler:
    def __init__(self, dispatcher):
        rc = bps.virtualkeyboard_request_events(0)
        if rc == bps.BPS_FAILURE:
            raise Exception('vkb request events failed')

        dispatcher.add_handler(bps.virtualkeyboard_get_domain(), self.handle_event)


    KB_STATE_CODES = frozenset({
        bps.VIRTUALKEYBOARD_EVENT_VISIBLE,
        bps.VIRTUALKEYBOARD_EVENT_HIDDEN,
        })


    #---------------------------------------------
    #
    def handle_event(self, event):
        '''Handle BPS events for our domain'''
        code = bps.bps_event_get_code(event)
        if code in self.KB_STATE_CODES:
            tart.send('keyboardState',
                visible=(code == bps.VIRTUALKEYBOARD_EVENT_VISIBLE))


# EOF

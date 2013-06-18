
from bb import bps
import tart


class LocaleHandler:
    def __init__(self, dispatcher):
        rc = bps.locale_request_events(0)
        if rc == bps.BPS_FAILURE:
            raise Exception('locale request events failed')

        dispatcher.add_handler(bps.locale_get_domain(), self.handle_event)


    #---------------------------------------------
    #
    def handle_event(self, event):
        '''Handle BPS events for our domain'''
        code = bps.bps_event_get_code(event)

        # new event is issued when locale values change
        print('locale: event {}'.format(code))

        if code == bps.LOCALE_INFO:
            print('locale', bps.locale_event_get_locale(event))
            print('country', bps.locale_event_get_country(event))
            print('language', bps.locale_event_get_language(event))
            print('script', bps.locale_event_get_script(event))
            # e.g.: b'en_US', b'US', b'en', b''

# EOF

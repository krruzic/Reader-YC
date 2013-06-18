'''Event dispatcher for libbps events.'''

import _tart
from bb.bps import (bps_set_verbosity, bps_get_version,
    bps_event_t, bps_event_get_domain)


class BpsEventDispatcher:
    def __init__(self, debug=False):
        self.handlers = {}

        if debug:
            bps_set_verbosity(2)
            print('bps_version', bps_get_version())

        _tart.hook_events(self._handle_event)


    def add_handler(self, domain, handler):
        self.handlers[domain] = handler


    def remove_handler(self, domain):
        del self.handlers[domain]


    def _handle_event(self, addr):
        if addr:
            event = bps_event_t.from_address(addr)
            domain = bps_event_get_domain(event)
            try:
                handler = self.handlers[domain]
            except KeyError:
                print('BPS: unhandled event in domain', domain, event)
            else:
                handler(event)


# EOF

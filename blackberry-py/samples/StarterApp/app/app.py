import os

import tart
from tart import vkb_handler


class App(tart.Application):
    SETTINGS_FILE = 'data/app.state'

    def __init__(self):
        super().__init__(debug=False)   # set True for some extra debug output

        # To ensure obsolete and unrecognized settings are not restored in
        # later versions (if you change stuff and a user updates an older
        # version of the app) we restore only things that actually have
        # entries here.  Prepopulate this with default values, or use None
        # and make sure that case is handled in the QML to preserve its defaults.
        self.settings = {
            'metric': None,
        }
        self.restore_data(self.settings, self.SETTINGS_FILE)


    def onUiReady(self):
        # need to defer sending this, for now, until the event loop has started
        tart.send('restoreSettings', **self.settings)

        # install BPS event handler for vkb events, which for now reports
        # "keyboardState" events with boolean property "visible"
        vkb_handler.VkbHandler(self.bps_dispatcher)


    def onSaveSettings(self, settings):
        self.settings.update(settings)
        self.save_data(self.settings, self.SETTINGS_FILE)


    def onGetHelp(self):
        helppath = os.path.join(os.path.dirname(__file__), '../assets/help.html')
        with open(helppath, encoding='utf-8') as f:
            tart.send('gotHelp', text=f.read().strip().replace('\n', ' '))

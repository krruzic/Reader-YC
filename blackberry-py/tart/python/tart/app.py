'''BlackBerry-Tart support code including Application class.'''

import sys
import pickle
import json
import traceback

import _tart
import tart


class Application:
    '''Tart Application object for the Python backend.'''

    def __init__(self, debug=False):
        self.debug = debug
        if self.debug:
            tart.log('tart: app starting')


    def start(self):
        '''entry point to main loop'''
        if self.debug:
            print('calling _tart.event_loop()')

        # Call back into C++ so it can call QThread::exec() and process
        # the Qt event loop, handling incoming signals and events and such.
        # This should never return except via a SystemExit exception,
        # which will be caught by blackberry_tart.py.
        _tart.event_loop(self._handle_event)

        if self.debug:
            print('returned from _tart.event_loop() (should never see this)')


    def _handle_event(self, event=''):
        '''called from event loop to handle'''
        if self.debug:
            tart.log('tart: event', event)

        try:
            msg = json.loads(event)
        except ValueError:
            msg = []

        # extract message type and build handler name based on convention
        # shared with and adopted from QML
        try:
            msg_type = msg[0]
            # apply Qt-style case normalization
            name = 'on' + msg_type[0].upper() + msg_type[1:]
        except IndexError:
            tart.log('tart: ERROR, no type found in message')
            return

        else:
            # find a matching handler routine, if there is one
            try:
                handler = getattr(self, name)
            except AttributeError:
                if msg_type.startswith('on'):
                    tart.log('tart: WARNING, message starts with "on", maybe remove?')

                self.missing_handler(msg)
                return

        # tart.log('calling', handler)
        try:
            kwargs = msg[1] or {}
        except KeyError:
            kwargs = {}

        # Actually process the message in the handler: note that
        # results are ignored for now, and any exceptions will
        # result in a traceback from the calling code (in tart.cpp)
        result = handler(**kwargs)


    def missing_handler(self, msg):
        tart.log('tart: ERROR, missing handler for', msg[0])


    def restore_data(self, data, path):
        '''Utility function to retrieve persisted data,
        if any, and restore only those items we currently support.
        This should probably be broken out to an optional and separate
        support package but, for now, here it is...
        '''
        try:
            saved = pickle.load(open(path, 'rb'))
        except:
            saved = {}

        # restore only recognized items, which means we'll ignore the
        # version key for now
        for key in data:
            try:
                data[key] = saved[key]
                if self.debug:
                    print('{}: restored {} = {!r}'.format(
                        path,
                        key,
                        data[key],
                        ))
            except KeyError:
                pass


    def save_data(self, data, path):
        '''See restore_data() or samples that use this.'''
        # we can get fancier later when we need
        data['version'] = 1

        if self.debug:
            print('{}: persisting {!r}'.format(path, data))
        pickle.dump(data, open(path, 'wb'))


    def onUiReady(self):
        '''Sent when the QML has finished onCreationCompleted for the root
        component.  Override in subclasses as required.'''
        pass


    def onManualExit(self):
        '''Sent when the app is exiting, so we can save state etc.
        Override in subclasses as required.'''
        tart.send('continueExit')
        # sys.exit(1)


    #---------------------------------------------
    # Transparently create BPS event dispatcher when it's requested,
    # allowing us to hook into the event feed with a Qt event filter
    @property
    def bps_dispatcher(self):
        try:
            d = self._bps_dispatcher
        except AttributeError:
            from .bps_dispatcher import BpsEventDispatcher
            d = self._bps_dispatcher = BpsEventDispatcher()
        return d

    #---------------------------------------------
    # Transparently create Clipboard when it's requested,
    # allowing us to access the system clipboard data.
    @property
    def clipboard(self):
        try:
            d = self._clipboard
        except AttributeError:
            from .clipboard import Clipboard
            d = self._clipboard = Clipboard()
        return d


    #---------------------------------------------
    # Useful things with which to help JavaScript debugging.
    # These can be called from the command line interface via
    # telnet, or in some automated testing.  Not used but
    # left here for now, to inspire future ideas...

    def js(self, text):
        '''send to JavaScript for evaluation'''
        tart.send('evalJavascript', text=text)


    def onEvalResult(self, value=None):
        '''result from JavaScript eval sent from js()'''
        print('result', value)


# EOF

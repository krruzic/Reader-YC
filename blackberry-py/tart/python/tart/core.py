'''BlackBerry-Tart support code.'''

import json

import _tart


def send(type, **kwargs):
    '''Call from Python as tart.send(type, ...) with any keyword
    arguments you want packaged up to send to JavaScript.
    See also the implementation of Tart._onMessage in the tart.js file.
    '''
    _tart.send(json.dumps([type, kwargs]))


# TODO: remove this, and just have people call print()?  Or
# plug it into the standard Python logging module instead?
# Contributions are welcome.
def log(*args):
    '''Relies on the slogger2 configuration to send this to the right place.
    See blackberry_tart.py and its _install_slogger2().
    '''
    print(*args)



# EOF

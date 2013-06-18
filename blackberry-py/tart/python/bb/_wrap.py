'''Utility routines used in making ctypes wrapper functions.'''

import ctypes

class _func:
    '''Function definition, replaced by reference to function in library
    when register_functions() is called.'''
    def __init__(self, *args):
        self.args = args


def _register_funcs(lib, namespace, use_errno=False):
    # if path is given, load library, else treat lib as existing CDLL
    if isinstance(lib, (str, bytes)):
        lib = ctypes.CDLL(lib, use_errno=use_errno)

    for name, fdef in namespace.items():
        if isinstance(fdef, _func):
            try:
                func = getattr(lib, name)
                func.restype = fdef.args[0]
                func.argtypes = fdef.args[1:]
            except Exception as ex:
                print('Error wrapping', name, fdef.args)
                raise

            namespace[name] = func

    return lib

# EOF

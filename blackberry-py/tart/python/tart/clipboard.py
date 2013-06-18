from bb.clipboard import *
from ctypes import (c_int, byref, POINTER, pointer,
    create_string_buffer, string_at, sizeof, get_errno, cast)
import tart
import errno

PATH_MAX = 255
CLIPBOARD_BUFFER_SIZE = 16384

class ClipboardError(Exception):
    '''represents a failure in Clipboard call.'''

class Clipboard:
    def __init__(self, path=None):
        if path:
           print('Clipboard set_clipboard_path {!r}'.format(path)) 
           rc = set_clipboard_path(c_char_p(path.encode('utf-8')), len(path))
           print('set clipboard path, rc', rc)

        buf = create_string_buffer(PATH_MAX)
        rc = get_clipboard_path(buf, len(buf))
        if rc == -1:
            raise ClipboardError('get_clipboard_path')
        self.path = buf.value.decode('utf-8')

    def contains(self, mimeType):
        ''' 
        Returns True if the data exists in the clipboard for the specified type and accessible for the caller. False otherwise. 
        '''

        print('Clipboard contains type {!r}'.format(mimeType))
        rc = is_clipboard_format_present(c_char_p(mimeType.encode('utf-8')))
        exists = True if rc == 0 else False
        restricted = False
        if not exists:
            restricted = True if get_errno() == errno.EACCES else False
        print('contains exists = {!r}, restricted = {!r}'.format(exists, restricted))
        if restricted:
            raise ClipboardError('Access restricted.')

        return exists

    def value(self, mimeType):
        '''
        Returns data (byte string) from the clipboard for the specified type.

        Will return the data requested if it's able to be accessed. If not, it will be None.
        '''

        print('Clipboard get_clipboarddataa type {!r}'.format(mimeType))
        buf = (c_char * CLIPBOARD_BUFFER_SIZE)()
        t = cast(buf, POINTER(c_char))
        rc = get_clipboard_data(c_char_p(mimeType.encode('utf-8')), byref(t))
        if rc == 4294967295: # -1 in as unsigned int
            restricted = True if get_errno() == errno.EACCES else False
            size = 0
            data = None
        else:
            restricted = False
            size = rc
            data = b""
            for i in range(size):
                data += t[i]
        print('value restricted {!r}, size {!r}, data {!r}'.format(restricted, size, data))

        if restricted:
            raise ClipboardError('Access restricted.')

        return data

    def insert(self, mimeType, data):
        '''
        Adds new data to the clipboard for the specified type.

        If the data already exists for the type, it's replaced. Data for other types is unaffected.
        '''

        print('Clipboard set_clipboard_data type {!r}'.format(mimeType))
        if isinstance(data, str):
            buf = create_string_buffer(data.encode('utf-8'))
        elif isintance(data, bytes):
            buf = (c_char * len(data))()
            for i in range(len(data)):
                buf[i] = data[i]
        else:
            raise ClipboardError('Unsupported data type.')

        t = cast(buf, POINTER(c_char))
        rc = set_clipboard_data(mimeType.encode('utf-8'), len(data), t)
        size = 0 if rc == -1 else rc
        restricted = False
        if size == -1:
            restricted = True if get_errno() == errno.EACCES else False
        print('insert restricted {!r}, bytes written {!r}'.format(restricted, size))
        if restricted:
            raise ClipboardError('Access restricted.')
        return size

    def remove(self, mimeType):
        '''
        Deletes data from the clipboard for the specified type

        Returns True if the data was deleted successfully. False otherwise.
        '''

        print('Clipboard empty_clipboard_by type {!r}'.format(mimeType))
        rc = empty_clipboard_by(mimeType.encode('utf-8'))
        success = True if rc == -1 else False
        restricted = False
        if not success:
            restricted = True if get_errno() == errno.EACCES else False
        print('remove restricted {!r}, success {!r}'.format(restricted, success))
        if restricted:
            raise ClipboardError('Access restricted.')
        return success

    def clear(self):
        '''
        Deletes all data from the clipboard.

        Returns True if all data was deleted successfully. False otherwise.
        '''

        print('Clipboard empty_clipboard')
        rc = empty_clipboard()
        success = True if rc == -1 else False
        restricted = False
        if not success:
            restricted = True if get_errno() == errno.EACCES else False
        print('clear restricted {!r}, success {!r}'.format(restricted, success))
        if restricted:
            raise ClipboardError('Access restricted.')
        return success



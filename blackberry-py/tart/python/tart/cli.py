#!/usr/bin/env python

from __future__ import print_function
import sys
import socket
import traceback
import threading
from code import InteractiveConsole


DEFAULT_PORT = 1234
BUFSIZE = 1024


class MyConsole(InteractiveConsole):
    def __init__(self, client):
        self.client = client
        super().__init__()


    def push(self, line):
        line = line.rstrip()
        return super().push(line)


    def write(self, data):
        self.client.write(data)


    def raw_input(self, prompt):
        self.write(prompt)
        line = self.client.getline().rstrip()
        if line == '\x1a':
            raise EOFError

        return line


    def resetbuffer(self):
        super().resetbuffer()
        #~ self.client.resetbuffer()



class Client(threading.Thread):
    def __init__(self, sock, id=0, on_disconnect=None):
        super().__init__()
        self.id = id
        self.sock = sock
        self.daemon = True
        self.eol = b'\r\n'
        sys.stdout = self
        self.on_disconnect = on_disconnect
        self.resetbuffer()


    def resetbuffer(self):
        self.buffer = bytearray()


    def write(self, data):
        self.sock.send(data.encode('ascii').replace(b'\n', self.eol))


    def flush(self):
        pass


    def getline(self):
        eol_index = -1
        while True:
            data = self.sock.recv(BUFSIZE)
            if not data:
                break

            # BS backspace
            # cursor keys: \x1b[A or B or C or D (up, down, right, left)
            # ESC escape
            # various others e.g. function keys
            # control keys
            # ^U is \x15
            for c in data:
                #~ print('char {!r} {!r}'.format(c, chr(c)), file=sys.stderr)
                if chr(c) == '\b':
                    if self.buffer:
                        self.sock.send(b' \b')
                        del self.buffer[-1]
                    else:
                        self.sock.send(b' ')
                else:
                    self.buffer.append(c)

            eol_index = self.buffer.find(b'\n', -len(data) - 1)
            if eol_index >= 0:
                break

        line = self.buffer[:eol_index + 1].decode('ascii')
        self.buffer = self.buffer[eol_index + 1:]

        print('{}: got line {!r}'.format(self.id, line), file=sys.stderr)
        return line


    def run(self):
        try:
            self.console = MyConsole(self)
            self.console.interact()
        finally:
            print('{}: terminating'.format(self.id), file=sys.stderr)
            self.sock.close()

            try:
                self.on_disconnect()
            except:
                pass



class Server(object):
    def __init__(self, port=DEFAULT_PORT):
        self.done = False
        self.client = None  # only one client active at a time since only one stdout
        self.port = port


    def quit(self):
        self.done = True


    def client_disconnected(self):
        self.client = None
        sys.stdout = sys.__stdout__


    def run(self):
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.bind(('', self.port))
        s.listen(1)

        client_id = 0
        print('listening on port {}'.format(self.port))

        try:
            while not self.done:
                conn, client = s.accept()

                if self.client:
                    conn.send(b'Sorry, only client connection at a time.\r\n')
                    conn.close()

                else:
                    client_id += 1
                    print('connection from {}'.format(client))
                    self.client = Client(conn, id=client_id, on_disconnect=self.client_disconnected)
                    self.client.start()

        finally:
            s.close()


def run(port=DEFAULT_PORT):
    Server(port).run()


def threaded_run(**kwargs):
    t = threading.Thread(target=run, kwargs=kwargs)
    t.daemon = True
    t.start()


# for testing on PC
if __name__ == '__main__':
    run()


# EOF

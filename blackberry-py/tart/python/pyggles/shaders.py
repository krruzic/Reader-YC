
from ctypes import (byref, sizeof, c_int, c_float, c_char_p, cast,
    create_string_buffer)

from bb.gles import *
# TODO: remove this coupling between tart and pyggles
from tart.util import ascii_bytes


class OglError(Exception):
    def __init__(self, msg, log=''):
        self.error = glGetError()
        self.log = log
        if self.log:
            msg = '{} ({}):\n{}'.format(msg, self.error, self.log)
        else:
            msg = '{} ({})'.format(msg, self.error)

        super().__init__(msg)



# TODO: any point in making this just an int subclass since we mostly care
# only about the glCreateShader() return value?
class Shader:
    def __init__(self, source, stype=None):
        if source.endswith('.vert') or source.endswith('.frag'):
            text = self.load(source)
            stype = GL_VERTEX_SHADER if source.endswith('.vert') else GL_FRAGMENT_SHADER

        else:
            text = ascii_bytes(source)
            if stype is None:
                # try to auto-detect
                if 'gl_Frag' in source:
                    stype = GL_FRAGMENT_SHADER
                else:
                    stype = GL_VERTEX_SHADER

        self.create(stype, text)


    def __del__(self):
        if self.handle:
            glDeleteShader(self.handle)


    def load(self, path):
        with open(path) as f:
            return f.read().encode('ascii', errors='replace')


    def create(self, stype, source):
        # Compile the vertex shader
        h = self.handle = glCreateShader(stype)
        if not h:
            raise OglError('Failed to create shader')

        else:
            status = GLint()
            glShaderSource(h, 1, byref(c_char_p(source)), None)
            glCompileShader(h)
            glGetShaderiv(h, GL_COMPILE_STATUS, byref(status))
            if not status:
                loglen = c_int()
                glGetShaderiv(h, GL_INFO_LOG_LENGTH, byref(loglen))
                log = create_string_buffer(loglen.value + 1)
                glGetShaderInfoLog(h, sizeof(log), None, log)

                print("Failed to compile shader:", )

                glDeleteShader(h)
                raise OglError('Failed to compile shader', log.value.decode('ascii'))

        return h



class Program:
    def __init__(self, vs, fs):
        self.create(vs, fs)


    # TODO: restore this functionality, which ought to be a clean way to
    # exit but which instead leads to a segfault at shutdown:
    # (TartStart) terminated SIGSEGV code=1 fltno=11
    #   ip=782bb288(/base/usr/lib/libGLESv2.so.1@glDeleteProgram+0x1b)
    # def __del__(self):
    #     if self.handle:
    #         glDeleteProgram(self.handle)


    def create(self, vs, fs):
        status = GLint()
        h = self.handle = glCreateProgram()
        if not h:
            raise OglError('unable to create program')

        glAttachShader(h, vs.handle)
        glAttachShader(h, fs.handle)
        glLinkProgram(h)

        glGetProgramiv(h, GL_LINK_STATUS, byref(status))
        if not status:
            loglen = c_int()
            glGetProgramiv(h, GL_INFO_LOG_LENGTH, byref(loglen))
            log = create_string_buffer(loglen.value + 1)
            glGetProgramInfoLog(fs, sizeof(log), None, log)

            glDeleteProgram(h)
            raise OglError('unable to link program', log.value.decode('ascii'))

        # import ogl_dump
        # ogl_dump.program_dump(h)

        return h


    def use(self):
        glUseProgram(self.handle)


    def dump(self):
        max_index = c_int()
        glGetProgramiv(self.handle, GL_ACTIVE_ATTRIBUTES, byref(max_index))

        namebuf = create_string_buffer(128)
        length = GLsizei()
        size = GLint()
        type = GLenum()
        for index in range(max_index.value):
            err = glGetActiveAttrib(self.handle, index, sizeof(namebuf), byref(length),
                byref(size), byref(type), namebuf)
            if err:
                break
            print('#{}: {} ({}): 0x{:04x} {}'.format(
                index,
                namebuf.value.decode('ascii'), length.value,
                type.value, size.value))


    def uniform(self, name):
        if isinstance(name, str):
            name = name.encode('ascii')

        return glGetUniformLocation(self.handle, name)


    def attribute(self, name):
        if isinstance(name, str):
            name = name.encode('ascii')

        return glGetAttribLocation(self.handle, name)



# EOF

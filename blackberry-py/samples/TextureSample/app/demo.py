'''The code in this file was ported to Python and Pyggles from
the original JavaScript and WebGL code by emeric florence
at http://github.com/boblemarin/FLU and is covered under the
Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
See http://creativecommons.org/licenses/by-nc-sa/3.0/
'''


import os
import array
import math
from math import sin, cos
from random import random
import ctypes as ct

from bb.gles import *
from pyggles import shaders, drawable
from pyggles.rect import Rect
from pyggles.drawing import context, Drawing
from pyggles.timer import Timer
from pyggles.image import Image


FOLDER = os.path.dirname(__file__)


class OglDemo(drawable.Drawable):
    NUM_SPRITES = 25

    def init(self):
        '''Prepare for eventual drawing.
        Called from the rendering thread.'''
        vs = shaders.Shader(os.path.join(FOLDER, 'shader1.vert'))
        fs = shaders.Shader(os.path.join(FOLDER, 'shader1.frag'))

        self.prog = shaders.Program(vs, fs)
        self.prog.dump()

        # load texture
        img = Image()
        img.load(os.path.join(FOLDER, 'image.png'))

        self.textureId = GLuint()
        glGenTextures(1, byref(self.textureId))
        glBindTexture(GL_TEXTURE_2D, self.textureId)

        glActiveTexture(GL_TEXTURE0)

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
        # need these with non-power-of-two (NPOT) images
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)

        # print('image', img.width, 'x', img.height, img.data[:16])
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, img.width, img.height,
            0, GL_RGBA, GL_UNSIGNED_BYTE, img.data)

        # get texture name
        self.s_texture = self.prog.uniform('s_texture')

        self.touched = False
        sw, sh = self.drawing.size


    def onTouch(self, action, x, y):
        if action in {0, 1}:
            self.angle = x * 360 / self.drawing.size[0]
            self.touched = True
        else:
            self.touched = False

        self.drawing.redraw = True


    def resize(self):
        '''Initialises WebGL and creates the 3D scene.'''
        #    Set the viewport to the drawing width and height
        cw, ch = self.drawing.size
        glViewport(0, 0, cw, ch)

        # Install the program as part of the current rendering state
        self.prog.use()

        glDisable(GL_DEPTH_TEST)
        # src_alpha and 1-src_alpha to use alpha properly
        glEnable(GL_BLEND)
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

        #    Specify the vertex positions (x, y, z)
        self.verts = array.array('f')
        for i in range(self.NUM_SPRITES):
            self.verts.extend([random() * 2 - 1, random() * 2 - 1])

        #     Create the modelview matrix
        #     More info about the modelview matrix: http://3dengine.org/Modelview_matrix
        #     More info about the identity matrix: http://en.wikipedia.org/wiki/Identity_matrix
        angle = 0 / 180 * math.pi
        modelViewMatrix = self.make_vector([
            cos(angle), -sin(angle), 0, 0,
            sin(angle), cos(angle), 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1,
            ])

        # Get the vertex position attribute location from the shader program
        a_position = self.prog.attribute('a_position')
        glEnableVertexAttribArray(a_position)

        # Specify the location and format of the vertex position attribute
        addr, size = self.verts.buffer_info()
        glVertexAttribPointer(a_position, 2, GL_FLOAT, GL_FALSE, 0, addr)

        # Get the location of the "modelViewMatrix" uniform variable from the
        # shader program
        u_mvpMatrix = self.prog.uniform('u_mvpMatrix')

        glUniformMatrix4fv(u_mvpMatrix, 1, GL_FALSE, modelViewMatrix)

        self.redraw = True
        self.drawing.redraw = True


    def draw(self):
        if self.touched:
            self.touched = False
            angle = self.angle / 180 * math.pi
            modelViewMatrix = self.make_vector([
                cos(angle), -sin(angle), 0, 0,
                sin(angle), cos(angle), 0, 0,
                0, 0, 1, 0,
                0, 0, 0, 1,
                ])
            u_mvpMatrix = self.prog.uniform('u_mvpMatrix')
            glUniformMatrix4fv(u_mvpMatrix, 1, GL_FALSE, modelViewMatrix)

        glClearColor(1.0, 1.0, 1.0, 1.0)
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

        glEnable(GL_TEXTURE_2D)

        glActiveTexture(GL_TEXTURE0)
        glBindTexture(GL_TEXTURE_2D, self.textureId)

        glUniform1i(self.s_texture, 0)

        glDrawArrays(GL_POINTS, 0, self.NUM_SPRITES)
        glDisable(GL_TEXTURE_2D)


# EOF

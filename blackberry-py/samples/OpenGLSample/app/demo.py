'''The code in this file was ported to Python and Pyggles from
the original JavaScript and WebGL code by emeric florence
at http://github.com/boblemarin/FLU and is covered under the
Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
See http://creativecommons.org/licenses/by-nc-sa/3.0/
'''


import os
import array
import math
from random import random

from bb.gles import *
from pyggles import shaders, drawable
from pyggles.drawing import context, Drawing
from pyggles.timer import Timer


FOLDER = os.path.dirname(__file__)


class OglDemo(drawable.Drawable):
    NUM_LINES = 5000

    def init(self):
        '''Prepare for eventual drawing.
        Called from the rendering thread.'''
        print("setup()")
        vs = shaders.Shader(os.path.join(FOLDER, 'shader1.vert'))
        fs = shaders.Shader(os.path.join(FOLDER, 'shader1.frag'))
        self.prog = shaders.Program(vs, fs)
        self.prog.dump()

        self.touched = False
        sw, sh = self.drawing.size
        self.tw = sw / 2
        self.th = sh / 2
        self.tratio = sw / sh

        self.start_timer()


    def start_timer(self):
        def request_redraw(timer):
            self.drawing.redraw = True
        Timer(period=1/60, oneshot=False, callback=request_redraw).start()


    def onTouch(self, action, x, y):
        if action in {0, 1}:
            self.touchX = (x / self.tw - 1) * self.tratio
            self.touchY = -(y / self.th - 1)
            self.touched = True
        else:
            self.touched = False


    def resize(self):
        '''Initialises WebGL and creates the 3D scene.'''
        #    Set the viewport to the drawing width and height
        cw, ch = self.drawing.size
        glViewport(0, 0, cw, ch)

        #    Install the program as part of the current rendering state
        self.prog.use()

        #    Get the vertexPosition attribute from the linked shader program
        self.vertexPosition = self.prog.attribute('vertexPosition')

        #    Enable the vertexPosition vertex attribute array. If enabled, the array
        #    will be accessed an used for rendering when calls are made to commands like
        #    gl.drawArrays, gl.drawElements, etc.
        glEnableVertexAttribArray(self.vertexPosition)

        #    Clear the color buffer (r, g, b, a) with the specified color
        glClearColor(0.0, 0.0, 0.0, 1.0)

        #    Clear the depth buffer. The value specified is clamped to the range [0,1].
        #    More info about depth buffers: http://en.wikipedia.org/wiki/Depth_buffer
        glClearDepthf(1.0)

        glEnable(GL_BLEND)
        glDisable(GL_DEPTH_TEST)
        glBlendFunc(GL_SRC_ALPHA, GL_ONE)

        #    Now create a shape.

        #    Specify the vertex positions (x, y, z)
        self.vertices = array.array('f')
        self.ratio = cw / ch
        self.velocities = array.array('f')
        for i in range(self.NUM_LINES):
            self.vertices.extend([0, 0, 1.83])
            # (random() * 2 - 1)*ratio, random() * 2 - 1, 1.83 )
            self.velocities.extend([(random() * 2 - 1)*.05,
                (random() * 2 - 1)*.05,
                .93 + random()*.02])

        #    Clear the color buffer and the depth buffer
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

        #    Define the viewing frustum parameters
        #    More info: http://en.wikipedia.org/wiki/Viewing_frustum
        #    More info: http://knol.google.com/k/view-frustum
        fieldOfView = 30.0
        aspectRatio = cw / ch
        nearPlane = 1.0
        farPlane = 10000.0
        top = nearPlane * math.tan(fieldOfView * math.pi / 360.0)
        bottom = -top
        right = top * aspectRatio
        left = -right

        #     Create the perspective matrix. The OpenGL function that's normally used for this,
        #     glFrustum() is not included in the WebGL API. That's why we have to do it manually here.
        #     More info: http://www.cs.utk.edu/~vose/c-stuff/opengl/glFrustum.html
        a = (right + left) / (right - left)
        b = (top + bottom) / (top - bottom)
        c = (farPlane + nearPlane) / (farPlane - nearPlane)
        d = (2 * farPlane * nearPlane) / (farPlane - nearPlane)
        x = (2 * nearPlane) / (right - left)
        y = (2 * nearPlane) / (top - bottom)
        perspectiveMatrix = self.make_vector([
            x, 0, a, 0,
            0, y, b, 0,
            0, 0, c, d,
            0, 0, -1, 0
            ])

        #     Create the modelview matrix
        #     More info about the modelview matrix: http://3dengine.org/Modelview_matrix
        #     More info about the identity matrix: http://en.wikipedia.org/wiki/Identity_matrix
        modelViewMatrix = self.make_vector([
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1
            ])

        #     Get the vertex position attribute location from the shader program
        #     Specify the location and format of the vertex position attribute
        addr, size = self.vertices.buffer_info()
        glVertexAttribPointer(self.vertexPosition, 3, GL_FLOAT, GL_FALSE, 0, addr)
        #     Get the location of the "modelViewMatrix" uniform variable from the
        #     shader program
        uModelViewMatrix = self.prog.uniform('modelViewMatrix')
        #     Get the location of the "perspectiveMatrix" uniform variable from the
        #     shader program
        uPerspectiveMatrix = self.prog.uniform('perspectiveMatrix')
        #     Set the values
        glUniformMatrix4fv(uModelViewMatrix, 1, GL_FALSE, perspectiveMatrix)
        glUniformMatrix4fv(uPerspectiveMatrix, 1, False, modelViewMatrix)


    def draw(self):
        vertices = self.vertices
        velocities = self.velocities

        n = len(vertices)

        ratio = self.ratio
        sqrt = math.sqrt
        touched = self.touched
        if touched:
            touchX = self.touchX
            touchY = self.touchY

        for i in range(0, self.NUM_LINES, 2):
            bp = i*3
            # copy old positions
            vertices[bp] = vertices[bp+3]
            vertices[bp+1] = vertices[bp+4]

            # inertia
            velocities[bp] *= velocities[bp+2]
            velocities[bp+1] *= velocities[bp+2]

            # horizontal
            p = vertices[bp+3]
            p += velocities[bp]
            if p < -ratio:
                p = -ratio
                velocities[bp] = abs(velocities[bp])
            elif p > ratio:
                p = ratio
                velocities[bp] = -abs(velocities[bp])

            vertices[bp+3] = p

            # vertical
            p = vertices[bp+4]
            p += velocities[bp+1]
            if p < -1:
                p = -1
                velocities[bp+1] = abs(velocities[bp+1])
            elif p > 1:
                p = 1
                velocities[bp+1] = -abs(velocities[bp+1])

            vertices[bp+4] = p

            if touched:
                dx = touchX - vertices[bp]
                dy = touchY - vertices[bp+1]
                d = sqrt(dx * dx + dy * dy)

                if d < 1:
                    if d < .05:
                        vertices[bp+3] = (random() * 2 - 1) * ratio
                        vertices[bp+4] = random() * 2 - 1
                        velocities[bp] = 0
                        velocities[bp+1] = 0

                    else:
                        dx /= d
                        dy /= d
                        d = ( 2 - d ) / 2
                        d *= d
                        velocities[bp] += dx * d * .01
                        velocities[bp+1] += dy * d * .01

        glLineWidth(5)

        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

        glDrawArrays(GL_LINES, 0, self.NUM_LINES)
        # glDrawArrays(GL_TRIANGLES, 0, self.NUM_LINES)
        # glDrawArrays(GL_TRIANGLE_STRIP, 0, self.NUM_LINES)

        glFlush()


# EOF

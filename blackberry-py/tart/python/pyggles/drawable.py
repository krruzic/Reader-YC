
from bb import gles



class Drawable:
    '''Base class representing an item to be drawn onto a Drawing.'''

    #-----------------------------------------------
    #
    def __init__(self, drawing=None):
        self.drawing = drawing

        self.valid = False
        self.redraw = False
        self.rerender = False

        if self.drawing:
            self.drawing.add(self)


    #-----------------------------------------------
    #
    @staticmethod
    def make_vector(data, type=gles.GLfloat):
        '''Utility method to turn a sequence of data into a ctypes array
        of the given type, defaulting to GLfloat.'''
        vector = (type * len(data))(*data)
        return vector


    #-----------------------------------------------
    #
    @staticmethod
    def make_strip_vector(points):
        strip = []
        points = iter(points)
        for p in zip(points, points):
            strip.extend(p)
            strip.append(p[0])
            strip.append(0)

        return Drawable.make_vector(strip)


    #-----------------------------------------------
    # To be overridden in subclass.
    #
    def init(self):
        self.valid = True


    #-----------------------------------------------
    # To be overridden in subclass.
    #
    def resize(self):
        pass


    #-----------------------------------------------
    # To be overridden in subclass.
    #
    def draw(self):
        from random import random
        gles.glClearColor(random(), random(), random(), 1.0)
        gles.glClear(gles.GL_COLOR_BUFFER_BIT | gles.GL_DEPTH_BUFFER_BIT)


# EOF

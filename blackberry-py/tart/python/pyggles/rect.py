'''Rectangle class for Tart.'''

class Rect:
    '''Represent a position and size of a window/buffer rectangle
    with 0,0 at lower left corner.  The width and height are
    fixed once defined, and changes to either edge adjust the position
    instead of the size.  For example, setting rect.right = 0 would
    place the right edge at 0 and the left edge at -width.'''
    def __init__(self, x=0, y=0, width=0, height=0):
        self.x = x
        self.y = y
        self.width = width
        self.height = height

        if isinstance(x, tuple):
            self.x, self.y, self.width, self.height = x
        elif isinstance(x, Rect):
            self.x, self.y, self.width, self.height = x.as_tuple()


    def __repr__(self):
        r = ['<Rect'] # at 0x{:08x}'.format(id(self))]
        r.append(' @{},{} {}x{}'.format(self.x, self.y, self.width, self.height))
        r.append('>')
        return ''.join(r)


    @property
    def as_tuple(self):
        return (self.x, self.y, self.width, self.height)


    @property
    def size(self):
        return (self.width, self.height)

    @size.setter
    def size(self, v):
        self.width, self.height = v


    @property
    def pos(self):
        return (self.x, self.y)

    @pos.setter
    def pos(self, v):
        self.x, self.y = v


    @property
    def top(self):
        return self.y + self.height

    @top.setter
    def top(self, v):
        self.y = v - self.height


    @property
    def right(self):
        return self.x + self.width

    @right.setter
    def right(self, v):
        self.x = v - self.width


    # Aliases: I suggest not using these since I'm not convinced
    # there's value in having two ways to say the same thing.
    # Also not sure if using "x" and "y" is right though, so for
    # now these are here if you'd like to experiment.
    @property
    def left(self):
        return self.x

    @left.setter
    def left(self, v):
        self.x = v


    @property
    def bottom(self):
        return self.y

    @bottom.setter
    def bottom(self, v):
        self.y = v


# EOF

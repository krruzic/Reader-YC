
import os

import tart


class App(tart.Application):
    def __init__(self):
        super(App, self).__init__(debug=False)

        self.drawing = None
        self.demo = None


    def onUiReady(self):
        pass


    def onChartResized(self, width, height, group='', id=''):
        if not self.demo:
            print('onChartResized: create', width, height, group, id)
            from pyggles.drawing import Drawing
            self.drawing = Drawing()
            self.drawing.define_window(group, id, width, height)

            from .demo import OglDemo
            self.demo = OglDemo(self.drawing)


    def onTouch(self, action, x, y):
        self.drawing.send((self.demo.onTouch, (action, x, y)))



# EOF

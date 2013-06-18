
import tart

class App(tart.Application):
    def onUiReady(self):
        tart.send('msgFromPython', text='hello, world')

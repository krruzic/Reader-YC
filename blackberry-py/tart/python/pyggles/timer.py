'''Timing support for animations, one-shot or periodic events, or delays.'''


class Timer:
    '''Timers can be one-shot or periodic.  The same period value is used for
    either mode of operation.

    Timers can have names, though the system doesn't make any use of them.

    Timers can specify a callback routine which is called upon each expiry.

    Timers have a "running" property that indicates whether the timer is
    currently queued up for future expiry.
    '''

    def __init__(self, period=None, oneshot=True, callback=None, name=''):
        self.name = name
        self.period = period
        self.oneshot = oneshot
        self.callback = callback or (lambda *args: None)

        # Set thread-specific service, doing it in constructor so that
        # the various methods that use this will work faster, but with
        # the side-effect that Timers must be created in the thread in which
        # they will be used. (Or you could update the _service property.)
        from .drawing import context
        self._service = context.timing_service

        self.expiry = 0


    def __repr__(self):
        r = ['<' + self.__class__.__name__]
        if self.name:
            r.append(':' + self.name)
        else:
            r.append(':0x{:08X}'.format(id(self)))

        r.append(' {:.3f}s'.format(self.period))

        r.append(' once' if self.oneshot else ' repeat')
        r.append('>')
        return ''.join(r)


    def start(self, period=None):
        if period is not None:
            self.period = period

        self._service.insert_timer(self)


    def stop(self):
        '''stop running timer'''
        self._service.remove_timer(self)


    @property
    def running(self):
        return self._service.is_running(self)


    def trigger(self):
        '''executes the action associated with the timer, ignoring all errors'''
        try:
            self.callback(self)
        except Exception as ex:
            print('error expiring', self, ex)
            import sys, traceback
            traceback.print_exception(*sys.exc_info())

            self.stop()
            return

        # periodic timers restart themselves with a new delay but
        # they preserve the expiry value to ensure we don't gradually
        # lose time between when the timer expired and when we restart it
        if self.oneshot:
            self.stop()
        else:
            self.start()


# EOF


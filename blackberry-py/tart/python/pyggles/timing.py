'''Timer driver that provides simple one-shot and periodic timing services.'''

# standard library
import sys
import time

# on Windows (XP/NT), time.time() has resolution of only 15.625ms
# so use time.clock() instead
if sys.platform == 'win32':
    _time_func = time.clock
else:
    _time_func = time.time



class TimingService:
    def __init__(self,
        debug=False,
        time=_time_func,
        ):
        # time function can be overridden to allow using mock during testing
        self.time = time

        self.debug = debug

        # expiry-time-sorted list of Timers
        self.timers = []

        # map timer ids to expiry times: if a timer is not in this list
        # it is not considered to be running
        self.expiry = {}

        # record starting time so expiry times begin at 0, for
        # more readable debug logging output
        self._basetime = self.time()

        # register as the timing service for this thread
        from pyggles.drawing import context
        context.timing_service = self


    def get_timeout(self):
        '''return time delta between now and when next timer should be expired,
        clipping negative values to 0'''
        now = self.time()
        return max(0, self.get_next_expiry() - now)


    def get_next_expiry(self):
        '''return expiry time of next timer, or a "safe" value if no timers are present'''
        next = self.timers[0]
        return self.expiry[id(next)]


    def is_running(self, timer):
        return id(timer) in self.expiry


    def insert_timer(self, timer):
        '''insert timer in order by expiry time'''
        # see if we already know about this timer, so we can restart it as
        # a periodic timer
        expiry = self.expiry.get(id(timer))

        # if we know the expiry time, it should be in our timer list so it's
        # safe to remove it here, and we'll insert it again below
        if expiry is not None:
            self.remove_timer(timer)

        # start at current time, or last expiry time for timer if it's set,
        # so that we don't get cumulative errors if there are delays in restarting
        # a periodic timer
        reftime = expiry or self.time()

        # FIXME: if we were late enough for the last expiry time, we shouldn't
        # schedule the timer for an expiry in the past
        expiry = reftime + timer.period
        self.expiry[id(timer)] = expiry

        # find where to stick it...
        for i, test in enumerate(self.timers):
            # when we find an equal or later timer, insert new one ahead of it
            if expiry <= self.expiry[id(test)]:
                self.timers.insert(i, timer)
                break
        else:
            self.timers.append(timer)

        if self.debug:
            print('inserted {}, expiry {:.3f}s'.format(timer, expiry - self._basetime))


    def remove_timer(self, timer):
        '''remove timer from list'''
        self.timers.remove(timer)
        del self.expiry[id(timer)]
        if self.debug:
            print('removed', timer)


    def check_timers(self):
        '''check for and expire all expired timers, popping as required'''
        now = self.time()
        while self.timers:
            # calculate how late we are: negative values mean we're early
            past_expiry = now - self.get_next_expiry()

            if past_expiry < 0:
                break

            timer = self.timers[0]

            if self.debug:
                print('trigger {} at {}'.format(timer, now - self._basetime))

            # Note: this may reschedule it, even as the first timer,
            # but with an updated expiry time.  We should probably
            # check that we don't keep rescheduling a very short timer
            # in the past, or we could effectively busy-wait here.
            timer.trigger()


# EOF

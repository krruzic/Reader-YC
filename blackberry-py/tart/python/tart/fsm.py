'''finite state machine'''

PREFIXES = ['_enter_', '_state_', '_exit_']


class FsmError(Exception):
    '''base class for FSM errors'''


class StateMachine(object):
    def __init__(self, name='fsm',
        initialState='init',
        stateOrigin=None,
        onStateChanged=None,
        debug=False
        ):
        self._count = 0

        self.name = name
        self.debug = debug

        self._on_enter = {}
        self._on_state = {}
        self._on_exit = {}
        self.mapStates(stateOrigin or self)

        self._forceState(initialState)
        if onStateChanged:
            self.onStateChanged = onStateChanged


    def __repr__(self):
        return '<FSM {} {}>'.format(
            self._count,
            self.state if hasattr(self, 'state') else '(nostate)')


    def _forceState(self, state):
        '''force state machine into a specific state, bypassing enter/exit handling'''
        self.state = state
        self.handler = self._on_state[self.state]


    def mapStates(self, origin):
        '''scan object and map state handler methods'''

        states = {}
        # scan for transition handlers to find all states
        for key in dir(origin.__class__):
            for prefix in PREFIXES:
                if key.startswith(prefix):
                    states[key[len(prefix):]] = 1

        self.states = sorted(states.keys())

        # map handlers for all states
        for state in states:
            for prefix,map in zip(PREFIXES, [self._on_enter, self._on_state, self._on_exit]):
                try:
                    handler = getattr(origin, prefix + state)
                except AttributeError:
                    handler = None
                map[state] = handler


    def _dummy_handler(self):
        return


    def onStateChanged(self, oldState, newState):
        '''called after exiting old state and entering new state'''
        pass


    def execute(self, event=None):
        self._count += 1

        if self.debug:
            print('FSM.execute', event)

        results = self.handler(event)

        # allow states to return next state alone or with optional arguments in tuple
        if isinstance(results, tuple):
            nextState = results[0]
            args = results[1:]
        else:
            nextState = results
            args = ()

        if nextState is None:
            return
        elif nextState != self.state:
            on_exit = self._on_exit[self.state]
            try:
                on_enter = self._on_enter[nextState]
                self.handler  = self._on_state[nextState]
            except KeyError:
                raise FsmError('missing state %r' % nextState)

            if on_exit:
                on_exit()

            (oldState, self.state) = (self.state, nextState)

            self.onStateChanged(oldState, self.state)
            if on_enter:
                on_enter(*args)

            return self.state



# EOF

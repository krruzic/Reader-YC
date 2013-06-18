/* JavaScript "wedge" for Tart system, hiding various implementation
details so the QML can look cleaner. */

.pragma library // share a single instance of this file across all of QML

var debug = false;
var _tart = null;
var Application = null;
var _handlers = {}; // registered handlers, by name

var Tart = {};

// globals at this point are purely the standard JS ones, plus Qt and the translate stuff

function init(__tart, app) {
    _tart = __tart;
    Application = app;

    // install handler for messages arriving asynchronously from Python
    _tart.messageYielded.connect(Tart._onMessage);

    // temporary approach to doing this...
    Application.manualExit.connect(function () { dispatch('manualExit') });
    Application.thumbnail.connect(function () { dispatch('windowStateChanged', {state: 'thumbnail'}) });
    Application.invisible.connect(function () { dispatch('windowStateChanged', {state: 'invisible'}) });
    Application.fullscreen.connect(function () { dispatch('windowStateChanged', {state: 'fullscreen'}) });
    Application.asleep.connect(function () { dispatch('appStateChanged', {state: 'background'}) });
    Application.awake.connect(function () { dispatch('appStateChanged', {state: 'foreground'}) });
    Application.swipeDown.connect(function () { dispatch('swipeDown') });

    Application.autoExit = false;   // request onManualExit msg on shutdown
}


//-------------------------------------
// Send message from QML to Python.  The first argument describes the
// type of message, and the second is an object representing the various
// arguments, by convention.  The msg is JSON-encoded and passed through
// the C++ layer to the Python, where it's unwrapped again and handled
// in the tart.Application object, with automatic dispatch to handler
// routines.  For example, if the message type is "fooBar", then a method
// named "onFooBar" is expected.  Any properties in the data object
// are unwrapped and passed as keyword arguments so, for example, if
// we sent ('fooBar', {baz: 3, spam: 'Frank'}), it could be received by
// a method with the signature def onFooBar(self, spam, baz).
//
var send = Tart.send = function(type, data) {
    // someone may call this before we're initialized, e.g. from onValueChanged
    // handlers, if they use Tart.send()
    if (_tart)
        _tart.postMessage(JSON.stringify([type, data]));
}


//-------------------------------------
// Scan the provided object looking for functions that are named
// the way signal handlers are, as in "onSomeSignal", and install
// them to handle messages.  This whole aspect of Tart will need
// some improvements for complex apps, but for small to medium ones
// it appears mostly sufficient.  Call from the onCreationCompleted
// handler of the root object, most often.
//
function register(namespace) {
    if (debug)
        print('tart.register', typeof namespace, Object.keys(namespace).length);

    // scan all candidate items to check for those with a handler "signature"
    Object.keys(namespace).forEach(function (name) {
        // although testing the type (next test) is probably faster, we
        // do this one first to avoid spurious warnings that Cascades spits out
        // like ""WARNING: preferredHeight is NOT set, returned value cannot be trusted""
        // which occurs when we actually retrieve the property from the namespace
        // but also because we'll find far more functions than we'll find
        // non-functions with our handler naming convention.
        if (!/^on[A-Z]/.test(name))
            return;

        if (typeof namespace[name] !== 'function')
            return;

        _handlers[name] = namespace[name];
        if (debug)
            print('registered handler', name);
    });
}


//-------------------------------------
// Receive incoming messages from the Python backend, unpack
// it from JSON according to the convention, and dispatch
// to pre-registered routines based on the specified type of message.
//
Tart._onMessage = function(msg) {
    if (debug)
        console.log('_onMessage', msg);

    var parts = JSON.parse(msg);
    var type = parts[0];
    var data = parts[1];

    dispatch(type, data);
}


//-------------------------------------
// Look up a message handler in the registered handlers,
// or in the Tart support routines, and call it, passing
// the message data as a single argument.
//
function dispatch(type, data) {
    if (!type) {
        console.log('ERROR, empty type');
    } else {
        type = 'on' + type[0].toUpperCase() + type.substring(1);
        var signal = _handlers[type];
        if (!signal) {
            signal = Tart[type];
            if (!signal) {
                console.log('ERROR, signal not found', type);
                return;
            }
        }

        // console.log('signalling', typeof signal, type);
        signal(data);
    }
}


// debugging support, use with App.js() in app.py
Tart.onEvalJavascript = function(data) {
    console.log('eval this', data.text);
    var result = eval(data.text);
    console.log('.. result', result);
    Tart.send('evalResult', {value: result});
}


//-------------------------------------
// Use this by processing onManualExit() in the Python code,
// and then by calling tart.send('continueExit').
//
Tart.onContinueExit = function() {
    // everyone else is done, so let's blow this popsicle stand
    Application.quit();
}


//-------------------------------------
// Optional... backend code does tart.send('backendReady')
// when the event loop starts up, though a subclass of
// the Python tart.Application() could override that and
// not bother. Here we do nothing special with it, but code
// in one of the QML objects could implement this and do something useful.
//
Tart.onBackendReady = function() {
    if (debug)
        console.log('backend is ready, duh');
}


//-------------------------------------
// By default, we do nothing about this in the UI code but
// simply pass it down to the backend.  Override this by
// providing a function onManualExit() in your root QML object,
// and either send the same message down to Python when you're done,
// or call Application.quit() directly as Tart's default onContinueExit
// routine above does.
//
Tart.onManualExit = function() {
    if (debug)
        console.log('** onManualExit');
    Tart.send('manualExit');
}


// EOF

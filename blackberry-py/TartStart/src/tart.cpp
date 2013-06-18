/*
 * tart.cpp
 *
 *  Created on: 2012-09-16
 *      Author: phansen
 */

#include <assert.h>
#include <stdio.h>
#include <iconv.h>

#include <Python.h>

#include "tart.hpp"

#include <QObject>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QByteArray>
#include <QCoreApplication>
#include <QAbstractEventDispatcher>


//---------------------------------------------------------
//
TartThread::TartThread(QSemaphore * sem)
    : m_sem(sem)
    , m_loop_ran(false)
    {
    }


//---------------------------------------------------------
// Launch a Python interpreter, with control passed to it until it
// returns during app termination.  This routine is called in a
// separate thread created by Tart::start().
//
// Note that unhandled SystemExit will terminate the process unless
// Py_InspectFlag is set, so we need to handle that in blackberry_tart.py.
//
void TartThread::run() {
    qDebug() << QThread::currentThreadId() << "TartThread: running";

    // Make sure the GIL stuff is set up properly for when do_postMessage()
    // is called.  This may be required in the case where the tart app
    // doesn't actually create tertiary threads.
    PyEval_InitThreads();

    const char * path = Tart::instance()->getScriptPath();
    qDebug() << "script path" << path;
    if (path) {
        FILE * mainfile = fopen(path, "r");

        if (mainfile) {
            // We use the SimpleFileExFlags version so that we can pass closeit=1
            // (second argument) and to set flags to non-NULL so that the
            // code can specify "from __future__ import" if required.
            PyCompilerFlags flags;

            // Exceptions result in PyErr_Print() being called, and it
            // will terminate the process if Py_InspectFlag is not set.
            // If we don't want that to happen, we could either swallow
            // SystemExit exceptions in blackberry_tart.py, or set the
            // flag.  If we set the flag, however, even clean SystemExits
            // will result in a traceback being printed to sys.stderr.
            // Py_InspectFlag = 1; // ensure we return...
            int rc = PyRun_SimpleFileExFlags(mainfile, path, 1, &flags);

            // Note: docs say there is no way to get the exception info if
            // there is an error.
            // See http://docs.python.org/3.2/c-api/veryhigh.html#PyRun_SimpleStringFlags
            qDebug() << QThread::currentThreadId() << "PyRun returned" << rc;
        }
        else {
            qDebug() << path << "is missing!\n";
        }
    } else
        qDebug() << "no Python script specified\n";

    // will block until any non-daemon threads terminate
    qDebug() << "Python finalizing";
    Py_Finalize();

    // If we never got as far as actually running the tart event loop,
    // the main Qt thread will still be blocked on the semaphore
    // waiting for us to start, so release it.
    if (!ran_loop()) {
        qDebug() << QThread::currentThreadId() << "TartThread: loop never ran!";
        m_sem->release(1);
    }

    qDebug() << QThread::currentThreadId() << "TartThread: exiting";
}


//---------------------------------------------------------
//
int TartThread::do_exec() {
    // flag that we got this far, which means the Python interpreter
    // managed to get as far as calling _tart.event_loop() and we
    // released the main Qt thread to carry on with startup
    m_loop_ran = true;

    // qDebug() << QThread::currentThreadId() << "do_exec() releasing sema";
    m_sem->release(1);

    int rc = exec();
    // qDebug() << QThread::currentThreadId() << "do_exec() ->" << rc;

    return rc;
}


//---------------------------------------------------------
// Retrieve pointer (as integer) to the global Tart instance.
//
static PyObject *
tart_get_instance(PyObject *self, PyObject *args)
{
    PyObject * result;
    if(!PyArg_ParseTuple(args, ":get_instance"))
        return NULL;

    result = PyLong_FromLong((long) Tart::instance());
    return result;
}


//---------------------------------------------------------
// Implement asynchronous sending of messages from the Python
// side (any thread) to the main Application via the yieldMessage signal.
// The message data is expected to be JSON-encoded, but that's
// merely a convention shared between Python and JavaScript.
//
static PyObject *
tart_send(PyObject *self, PyObject *args)
{
    char * msg;

    if(!PyArg_ParseTuple(args, "s:send", &msg))
        return NULL;

    // qDebug() << QThread::currentThreadId() << "tart_send" << msg;

    Tart::instance()->yieldMessage(QString(msg));

    // qDebug() << QThread::currentThreadId() << "tart_send done";
    Py_RETURN_NONE;
}


//---------------------------------------------------------
// Blocking call for the Python main thread's Tart event loop
// where it should wait for incoming "events" from elsewhere
// (generally from the QML side).
// TODO: implement a timeout (?), and timer-support
//
static PyThreadState * tart_pystate;
static PyObject * event_callback = NULL;

static PyObject *
tart_event_loop(PyObject *self, PyObject *args)
{
    qDebug() << QThread::currentThreadId() << "_tart.event_loop()";

    // code for callback based on
    // http://docs.python.org/3.2/extending/extending.html#calling-python-functions-from-c
    PyObject * temp;

    if(!PyArg_ParseTuple(args, "O:event_loop", &temp))
        return NULL;

    if (!PyCallable_Check(temp)) {
        PyErr_SetString(PyExc_TypeError, "parameter must be callable");
        return NULL;
    }
    Py_XINCREF(temp);               // Add a reference to new callback
    event_callback = temp;          // Remember new callback
    // qDebug() << "event_loop: callback is" << event_callback;

    // exec() may block indefinitely, so we have to release the interpreter
    // to let other Python threads run until data arrives for us
    tart_pystate = PyEval_SaveThread();

    int rc = Tart::instance()->getThread()->do_exec();
    qDebug() << "event_loop: raising SystemExit(" << rc << ")";

    PyEval_RestoreThread(tart_pystate);

    Py_XDECREF(event_callback);     // Dispose of callback
    event_callback = NULL;          // Forget callback
    qDebug() << "event_loop: callback cleared";

    PyObject * exit_code = PyLong_FromLong(rc);
    PyErr_SetObject(PyExc_SystemExit, exit_code);
    return NULL;
}


//---------------------------------------------------------
// Install/uninstall a Qt event filter in the Tart thread.
//
static PyObject * event_hook_callback = NULL;

static QAbstractEventDispatcher::EventFilter orig_eventFilter = NULL;

void call_event_hook_callback(void * event)
    {
    // qDebug() << QThread::currentThreadId() << "call_event_hook_callback: begin";

    // PyGILState_STATE gil_state = PyGILState_Ensure();
    PyEval_RestoreThread(tart_pystate);

    PyObject * arglist = Py_BuildValue("(i)", event);
    // ran out of memory: fail!
    if (arglist == NULL)
        {
        qDebug() << "Py_BuildValue() returned NULL!";
        // should probably do something more significant here

        // PyGILState_Release(gil_state);
        tart_pystate = PyEval_SaveThread();
        return;
        }

    // call the callback to send message to Python
    PyObject * result = PyObject_CallObject(event_hook_callback, arglist);
    Py_DECREF(arglist);

    // TODO handle exceptions from the call, either by exiting the event
    // loop (maybe only during development?) or by dumping a traceback,
    // setting a flag, and continuing on.
    bool is_SystemExit = false;

    if (result == NULL)     // exception during call
        {
        // see http://computer-programming-forum.com/56-python/a81eae52ca74e6c1.htm
        // Calling PyErr_Print() will actually terminate the process if
        // SystemExit is the exception!
        if (PyErr_ExceptionMatches(PyExc_SystemExit))
            is_SystemExit = true;
        else
            PyErr_Print();
        }
    else
        Py_DECREF(result);

    // PyGILState_Release(gil_state);
    tart_pystate = PyEval_SaveThread();

    if (is_SystemExit)
        {
        qDebug() << "event_hook: SystemExit";
        QThread::currentThread()->exit(3);
        }

    // qDebug() << QThread::currentThreadId() << "call_event_hook_callback: end";

    return;
    }


bool Tart_eventFilter(void * event)
    {
    // qDebug() << QThread::currentThreadId() << "Tart_eventFilter [[";
    if (event_hook_callback)
        call_event_hook_callback(event);

    // Call replaced event filter so we deliever everything to Qt that runs in background
    if (orig_eventFilter)
        orig_eventFilter(event);

    // qDebug() << QThread::currentThreadId() << "Tart_eventFilter ]]";
    return false;
    }


static PyObject *
tart_hook_events(PyObject *self, PyObject *args)
{
    qDebug() << QThread::currentThreadId() << "_tart.hook_events()";

    // code for callback based on
    // http://docs.python.org/3.2/extending/extending.html#calling-python-functions-from-c
    PyObject * temp;

    if(!PyArg_ParseTuple(args, "O:hook_events", &temp))
        return NULL;

    // TODO: support None so we can unhook the filter.

    if (!PyCallable_Check(temp)) {
        PyErr_SetString(PyExc_TypeError, "parameter must be callable");
        return NULL;
    }
    Py_XINCREF(temp);               // Add a reference to new callback
    event_hook_callback = temp;     // Remember new callback
    // qDebug() << "event_loop: callback is" << event_callback;

    orig_eventFilter = QAbstractEventDispatcher::instance()->setEventFilter(Tart_eventFilter);
    qDebug() << "orig_eventFilter" << orig_eventFilter;

    Py_RETURN_NONE;
}


//---------------------------------------------------------
// Define callables for the "_tart" builtin module in Python.
//
static PyMethodDef TartMethods[] = {
    {"get_instance",tart_get_instance,  METH_VARARGS,
        PyDoc_STR("get_instance() -> int")},
    {"send",        tart_send,          METH_VARARGS,
        PyDoc_STR("Send msg/results to QML.")},
    {"event_loop",  tart_event_loop,    METH_VARARGS,
        PyDoc_STR("Enter Tart event loop.")},
    {"hook_events", tart_hook_events,   METH_VARARGS,
        PyDoc_STR("Install a Qt event filter.")},
    {NULL, NULL, 0, NULL}
};


//---------------------------------------------------------
// Define the "_tart" builtin module for Python code to use.
//
static PyModuleDef TartModule = {
    PyModuleDef_HEAD_INIT, "_tart", NULL, -1, TartMethods,
    NULL, NULL, NULL, NULL
};

//---------------------------------------------------------
// More boilerplate code to set up builtin module.
//
static PyObject*
PyInit_tart(void)
{
    return PyModule_Create(&TartModule);
}


//---------------------------------------------------------
// Singleton, so we can "find" Tart globally when required.
//
Tart * Tart::sm_instance;


Q_DECL_EXPORT
Tart * Tart::instance()
    {
    return sm_instance;
    }


//---------------------------------------------------------
// Construct the Tart object. This should be called from the
// main C++ code, probably after the Application is constructed.
// It prepares but does not yet launch the Python interpreter,
// as that has to be done in a separate thread.
// For now we do nothing with the arguments, but may want to
// extract useful info from them later.
//
Tart::Tart(int argc, char ** argv)
    : m_thread(NULL)
    , m_cleanup(false)
    {
    if (sm_instance)
        throw "Singleton already exists";

    sm_instance = this;

    // We may want to do stuff with these later... used to pass it
    // to the Python interpreter when it was the primary thing, but
    // now the Cascades Application gets it and maybe we don't care.
    m_argc = argc;
    m_argv = argv;

    PyImport_AppendInittab(TartModule.m_name, &PyInit_tart);

    // only Py_SetProgramName and Py_SetPath may come before this
    Py_Initialize();

    qDebug("Python initialized");

    //    m_wargv = args_to_wargv(args.size(), argv);
    //    m_wargc = argc;
    //    PySys_SetArgvEx(argc, m_wargv, 0);

    qDebug() << QThread::currentThreadId() << "Tart: initialized";
}


//---------------------------------------------------------
// Launch the secondary thread in which the Python interpreter
// is executed, since this call comes from the main Application thread.
//
void Tart::start() {
    if (m_thread)
        return;

    QSemaphore sem(0);

    // qDebug() << QThread::currentThreadId() << "Tart: starting TartThread";
    m_thread = new TartThread(&sem);

    this->moveToThread(m_thread);
    m_thread->start();

    connect(m_thread, SIGNAL(finished()),
        this, SLOT(thread_finished()));

    // being able to acquire this semaphore means the Python main thread
    // has succesfully started, and
    qDebug() << QThread::currentThreadId() << "Tart: wait for sema";
    sem.acquire(1);
    qDebug() << QThread::currentThreadId() << "Tart: got sema";

    // Only make the connection here if the interpreter entered the event loop.
    if (m_thread->ran_loop()) {
        // force postMessage() to result in a QueuedConnection for now
        // since the default doesn't appear to be picking the right method
        // TODO: investigate if that's a sign of a problem
        connect(this,
            SIGNAL(postMessage(QString)),
            this,
            SLOT(do_postMessage(QString)),
            Qt::QueuedConnection);
    }
}


//---------------------------------------------------------
//
void Tart::thread_finished() {
    // If we get here but haven't run the cleanup() routine,
    // it's an abnormal end so at least log it.
    // Also  terminate the entire process so we aren't left with
    // a GUI but nothing for it to talk to.
    if (!m_cleanup) {
        qDebug() << QThread::currentThreadId() << "Tart: ABEND";
        QCoreApplication::instance()->exit(1);
    }
}


//---------------------------------------------------------
// Shut down Tart, requesting and waiting for termination of the
// Python interpreter thread, and cleaning up.
// It may be best if this call comes via a connection to the
// Application::aboutToQuit() signal.
//
void Tart::cleanup() {
    // qDebug() << QThread::currentThreadId() << "Tart: cleanup";
    // qDebug() << "  m_thread" << m_thread << ", curThread" << QThread::currentThread();

    m_cleanup = true;

    if (m_thread) {
        // qDebug() << "  thread quit";
        m_thread->exit(2);

        if (m_thread != QThread::currentThread()) {
            // qDebug() << "  thread wait";
            m_thread->wait();
            // qDebug() << "  thread wait done";
        }

        delete m_thread;
        m_thread = NULL;
    }

//  free_wargv(m_wargc, m_wargv);

    sm_instance = NULL;
    qDebug() << QThread::currentThreadId() << "Tart: done cleanup";

    return;
}


//---------------------------------------------------------
// Signal that a message has been sent from the Python side,
// currently implemented using a handler for this signal in the
// tart.js JavaScript code that's used in the QML.
//
void Tart::yieldMessage(QString msg) {
    // qDebug() << QThread::currentThreadId() << "Tart: yieldMessage" << msg;
    emit messageYielded(msg);
    // qDebug() << QThread::currentThreadId() << "Tart: yieldMessage done";
}


//---------------------------------------------------------
// Pass messages into the Python interpreter main thread,
// which is expected to implement an event loop around calls
// to tart_wait() to retrieve these messages.
//
void Tart::do_postMessage(QString msg) {
    // qDebug() << QThread::currentThreadId() << "Tart: do_postMessage(" << msg << ")";

    QByteArray bytes = msg.toUtf8();

    // PyGILState_STATE gil_state = PyGILState_Ensure();
    PyEval_RestoreThread(tart_pystate);

    // qDebug() << "tart_wait bytes" << bytes.size();
    PyObject * arglist = Py_BuildValue("(s#)", bytes.constData(), bytes.size());
    // ran out of memory: fail!
    if (arglist == NULL) {
        qDebug() << "Py_BuildValue() returned NULL!";
        // should probably do something more significant here
        tart_pystate = PyEval_SaveThread();
        // PyGILState_Release(gil_state);
        return;
    } else {
        // qDebug() << "postMessage() built" << arglist;
    }

    // call the callback to send message to Python
    PyObject * result = PyObject_CallObject(event_callback, arglist);
    Py_DECREF(arglist);

    // qDebug() << "callback returned" << result;

    // TODO handle exceptions from the call, either by exiting the event
    // loop (maybe only during development?) or by dumping a traceback,
    // setting a flag, and continuing on.
    bool is_SystemExit = false;

    if (result == NULL) {   // exception during call
        // qDebug() << "exception during event delivery";

        // see http://computer-programming-forum.com/56-python/a81eae52ca74e6c1.htm
        // Calling PyErr_Print() will actually terminate the process if
        // SystemExit is the exception!
        if (PyErr_ExceptionMatches(PyExc_SystemExit))
            is_SystemExit = true;
        else
            PyErr_Print();
    }
    else
        Py_DECREF(result);

    // PyGILState_Release(gil_state);
    tart_pystate = PyEval_SaveThread();

    if (is_SystemExit) {
        qDebug() << "do_post: SystemExit from delivery";
        m_thread->exit(3);
    }

    // qDebug() << QThread::currentThreadId() << "Tart: do_postMessage done";
    return;
}


//---------------------------------------------------------
// Experimental utility routine to write image data to a file.
// This is intended to work with data retrieved from an HTML
// canvas running in a WebView, where canvas.toDataURL() retrieves
// the raw PNG data, so we can ultimately put this into an ImageView.
// Clearly there are numerous more direct and simpler paths possible.
//
QString Tart::writeImage(const QString & name, const QString & data)
{
    // qDebug() << "writeImage" << name;
    QString dataFolder = QDir::homePath();
    QFile file(dataFolder + '/' + name);
    // qDebug() << "path" << file.fileName();
    if (file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        file.write(QByteArray::fromBase64(data.toAscii()));
        file.close();
        return file.fileName();
    }
    else
        return QString();
}


// EOF

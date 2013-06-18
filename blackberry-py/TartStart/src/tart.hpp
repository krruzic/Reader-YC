/*
 * tart.hpp
 *
 *  Created on: 2012-09-16
 *      Author: phansen
 */

#ifndef TART_HPP_
#define TART_HPP_

#include <QObject>
#include <QThread>
#include <QSemaphore>


//---------------------------------------------------------
// Secondary thread used to run the Python interpreter,
// which can itself start any number of tertiary threads as required.
//
class TartThread : public QThread
{
    Q_OBJECT

public:
            TartThread(QSemaphore * sem);
    void    run();
    int     do_exec();
    bool    ran_loop() { return m_loop_ran; }

private:
    QSemaphore    * m_sem;
    bool            m_loop_ran;
};


//---------------------------------------------------------
// Main object that implements the mechanisms provided by
// Tart to allow a Cascades app to instantiate a Python interpreter
// and communicate asynchronously with it.  Provides additional
// supporting routines as required.
//
class Tart : public QObject
{
    Q_OBJECT

private:
    static Tart *   sm_instance;

public:
    static Tart *   instance();

    Tart(int argc, char ** argv);
//    ~Tart();

    const char *    getScriptPath() { return (m_argc && m_argv) ? m_argv[m_argc - 1] : NULL; }

    void            start();
    TartThread *    getThread() { return m_thread; }

    Q_INVOKABLE QString writeImage(const QString & name, const QString & data);

public slots:
    void cleanup();

signals:
    void postMessage(QString msg);
    void messageYielded(QString msg);
    void pythonTerminated(QString msg);

public:
    void yieldMessage(QString msg);

private slots:
    void do_postMessage(QString msg);
    void thread_finished();

private:
    // storage for argument list converted from multibyte to Unicode
    //    wchar_t ** m_wargv;
    //    int m_wargc;
    TartThread *    m_thread;
    bool            m_cleanup;
    int             m_argc;
    char **         m_argv;
};


#endif /* TART_HPP_ */

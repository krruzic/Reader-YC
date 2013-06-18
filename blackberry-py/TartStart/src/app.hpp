#ifndef APP_H
#define APP_H

#include <QObject>
#include <QString>

#include <bb/cascades/Application>
#include <bb/system/LocaleHandler>

#include "tart.hpp"

/*!
 * @brief Application GUI object
 */
class App : public QObject
{
    Q_OBJECT
public:
    App(bb::cascades::Application * app, Tart * tart, QString qmlpath);

    // This wasn't here before Gold SDK but the new Momentics project template
    // puts it in, so here it is for now.  Do we need it?  Something else?
    virtual ~App() {}

    Q_INVOKABLE QString getLocaleInfo(const QString & name);

private:
    bb::system::LocaleHandler * localeHandler;
};

#endif // ifndef APP_H

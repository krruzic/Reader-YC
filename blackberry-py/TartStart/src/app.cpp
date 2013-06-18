#include "app.hpp"
#include "tart.hpp"

#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>
#include <bb/cascades/AbstractPane>

#include <bb/cascades/pickers/ContactPicker>

#include <bb/cascades/pickers/FilePicker>
#include <bb/cascades/pickers/FilePickerMode>
#include <bb/cascades/pickers/FilePickerSortFlag>
#include <bb/cascades/pickers/FilePickerSortOrder>
#include <bb/cascades/pickers/FileType>
#include <bb/cascades/pickers/FilePickerViewMode>
#include <bb/cascades/advertisement/Banner>

#include <bb/cascades/SceneCover>
#include <bb/cascades/AbstractCover>
#include <bb/cascades/ActiveTextHandler>
#include <bb/platform/HomeScreen>
#include <bb/data/DataSource>
#include <bb/system/LocaleHandler>
#include <bb/system/LocaleType>

#include <QString>
#include <QTimer>
#include <QLocale>

using namespace bb::cascades;

//---------------------------------------------------------
// Set up a general-purpose object to hold stuff for the
// Cascades Application. Since we plan to implement all
// app-specific "backend" or business logic in Python, this
// object has a much lesser purpose than the equivalent in
// pure C++ Cascades apps, but for now we're keeping it here
// anyway.  It installs several names in the QML context,
// registers a bunch of types that aren't provided there by
// default, and does the usual QML-root object setup.
// Ideas for doing this differently are welcome.  It could
// probably be flipped around and done with calls from
// Python, maybe pushing all of these pieces into library
// routines that Tart makes available as separate packages,
// with the advantage that it wouldn't be so monolithic either.
//
App::App(bb::cascades::Application * app, Tart * tart, QString qmlpath)
: QObject(app)
{
	localeHandler = NULL;

    // Register the DataSource class as a QML type so that it's accessible in QML
    bb::data::DataSource::registerQmlTypes();

    // register lots of stuff that at least prior to beta 4 wasn't done for us
    // TODO: check this again now that Gold SDK is out
    qmlRegisterType<SceneCover>("bb.cascades", 1, 0, "SceneCover");
    qmlRegisterUncreatableType<AbstractCover>("bb.cascades", 1, 0, "AbstractCover", "");
    qmlRegisterType<bb::platform::HomeScreen>("bb.platform", 1, 0, "HomeScreen");
    qmlRegisterType<QTimer>("bb.cascades", 1, 0, "QTimer");
    qmlRegisterType<ActiveTextHandler>("bb.cascades", 1, 0, "ActiveTextHandler");

    // qmlRegisterType<pickers::FilePicker>("bb.cascades.pickers", 1, 0, "FilePicker");
    // qmlRegisterUncreatableType<pickers::FilePickerMode>("bb.cascades.pickers", 1, 0, "FilePickerMode", "");
    // qmlRegisterUncreatableType<pickers::FilePickerSortFlag>("bb.cascades.pickers", 1, 0, "FilePickerSortFlag", "");
    // qmlRegisterUncreatableType<pickers::FilePickerSortOrder>("bb.cascades.pickers", 1, 0, "FilePickerSortOrder", "");
    // qmlRegisterUncreatableType<pickers::FileType>("bb.cascades.pickers", 1, 0, "FileType", "");
    // qmlRegisterUncreatableType<pickers::FilePickerViewMode>("bb.cascades.pickers", 1, 0, "FilePickerViewMode", "");
    qmlRegisterType<advertisement::Banner>("bb.cascades.advertisement", 1, 0, "Banner");

    // create scene document from main.qml asset
    // set parent to created document to ensure it exists for the whole application lifetime
	QmlDocument *qml = QmlDocument::create(qmlpath).parent(this);

    //-- setContextProperty expose C++ object in QML as an variable
    qml->setContextProperty("app", this);
    if (tart)
    	qml->setContextProperty("_tart", tart);

    // create root object for the UI
    AbstractPane *root = qml->createRootObject<AbstractPane>();

    // set created root object as a scene
    app->setScene(root);
}


//---------------------------------------------------------
// A presumably provisional way to get at this info, until we find
// a better API for it.  Can be called from JavaScript as
// app.getLocaleInfo(somestring) to retrieve various bits as required.
//
QString App::getLocaleInfo(const QString & name) {
	if (!localeHandler)
		localeHandler = new bb::system::LocaleHandler(bb::system::LocaleType::Region, this);

	QLocale locale = localeHandler->locale();
	if (name == "currencySymbol")
		return locale.currencySymbol(QLocale::CurrencySymbol);
	else
	if (name == "currencyCode")
		return locale.currencySymbol(QLocale::CurrencyIsoCode);
	else
	if (name == "currencyName")
		return locale.currencySymbol(QLocale::CurrencyDisplayName);
	else
	if (name == "country")
		return QLocale::countryToString(locale.country());
	else
	if (name == "name")
		return locale.name();
	else
	if (name == "measurementSystem") {
		return QString(locale.measurementSystem() ? "imperial" : "metric");
	}
	else
		return QString("?");
}


import bb.cascades 1.0
import "../tart.js" as Tart

NavigationPane {
    id: root

    property variant settingsPage
    property variant helpPage

    signal settingsChanged()

    Page {
        id: mainPage

        Container {
            layout: DockLayout {}

            Label {
                id: kbmsg
                visible: false
                text: qsTr("Look out! It's the keyboard!!")
                horizontalAlignment: HorizontalAlignment.Left
                verticalAlignment: VerticalAlignment.Top
            }

            Label {
                id: label
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                multiline: true
                text: qsTr("Would you like to see the menu?\n(Swipe down from top.)")
                textStyle.fontSize: FontSize.PercentageValue
                textStyle.fontSizeValue: 150
                textStyle.textAlign: TextAlign.Center
            }
        }
    }

    attachedObjects: [
        ComponentDefinition {
            id: helpDef
            source: "HelpPage.qml"
        }
        ,
        ComponentDefinition {
            id: settingsDef
            source: "SettingsPage.qml"
        }
        ,
        QtObject {
            id: settings

            property bool metric: true

            onCreationCompleted: {
                // TODO: handle dynamic changes to this
                var system = app.getLocaleInfo('measurementSystem');
                metric = (system == 'metric');
            }

            onMetricChanged: {
                settingsChanged();
            }

            function restore(data) {
                print('restoring', Object.keys(data));
                if (data.metric != null) {
                    print('metric =', data.metric);
                    metric = data.metric;
                }
            }
        }
    ]

    Menu.definition: MenuDefinition {
        settingsAction: SettingsActionItem {
            onTriggered: {
                settingsPage = settingsDef.createObject();
                root.push(settingsPage);
                Application.menuEnabled = false;    // re-enable when popped
            }
        }
        helpAction: HelpActionItem {
            onTriggered: {
                Tart.send('getHelp');
            }
        }
    }

    function onRestoreSettings(data) {
        settings.restore(data);
    }

    function onGotHelp(data) {
        helpPage = helpDef.createObject();
        helpPage.text = data.text;
        root.push(helpPage);
        Application.menuEnabled = false;    // re-enable when popped
    }

    // handle keyboard state events from BPS
    function onKeyboardState(state) {
        kbmsg.visible = state.visible;
    }


    onSettingsChanged: {
        var data = {
            metric: settings.metric
        };

        Tart.send('saveSettings', {settings: data});
    }

    onPopTransitionEnded: {
        if (page == settingsPage)
            Application.menuEnabled = true;
        else
        if (page == helpPage)
            Application.menuEnabled = true;

        page.destroy();
    }

    onCreationCompleted: {
        // Tart.debug = true;
        Tart.init(_tart, Application);

        Tart.register(root);

        Tart.send('uiReady');
    }
}

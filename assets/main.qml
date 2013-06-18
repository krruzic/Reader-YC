import bb.cascades 1.0
import "../tart.js" as Tart

NavigationPane {
    id: root

    signal reloadList(string file)

    Menu.definition: AppMenuDefinition {
        id: appMenu
    }

    MainPage { id: mainPage }

    attachedObjects: [
        SettingsPage { id: settingsPage },
        HelpPage { id: helpPage }
    ]

    onCreationCompleted: {
        Tart.init(_tart, Application);

        Tart.register(root);
        Tart.send('uiReady');

        reloadList.connect(mainPage.reloadList);
        appMenu.triggerSettingsPage.connect(handleTriggerSettingsPage);
        appMenu.triggerHelpPage.connect(handleTriggerHelpPage);
    }

    onPopTransitionEnded: {
        page.destroy()
    }

    function onUpdateList(data) {
        reloadList(data.file);
    }

    function handleTriggerSettingsPage() {
        push(settingsPage);
    }

    function handleTriggerHelpPage() {
        push(helpPage);
    }
}
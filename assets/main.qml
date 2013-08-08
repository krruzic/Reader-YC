import bb.cascades 1.0
import "tart.js" as Tart

TabbedPane {
    id: tabbedPane

    Menu.definition: AppMenuDefinition {
        id: appMenu
    }

    Tab {
        id: topPosts
        title: qsTr("Top Posts")

        TopTab {
            id: top
            onCreationCompleted: {
                top.whichPage = 'topPage'
            }
        }

    }
    Tab {
        title: qsTr("Ask HN")
        AskTab {
            id: ask
            onCreationCompleted: {
                ask.whichPage = 'askPage'
            }
        }
    }
    Tab {
        title: qsTr("Newest Posts")

        NewTab {
            id: newest
            onCreationCompleted: {
                newest.whichPage = 'newPage'
            }
        }
    }
    Tab {
        title: qsTr("User Pages")

        UserPage {
            id: userPage
        }
    }
    onActiveTabChanged: {
        userPage.searchVisible = false;
    }
    onCreationCompleted: {
        Tart.init(_tart, Application);

        Tart.register(tabbedPane);
        Tart.send('uiReady');
    }
    showTabsOnActionBar: true
    activeTab: topPosts
}
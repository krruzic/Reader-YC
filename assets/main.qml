import bb.cascades 1.0
import "tart.js" as Tart

TabbedPane {
    id: tabbedPane

    Menu.definition: AppMenuDefinition {
        id: appMenu
    }

    Tab {
        id: topPosts
        title: qsTr("Top")
        imageSource: "asset:///images/icons/ic_top.png"
        TopTab {
            id: top
            onCreationCompleted: {
                top.whichPage = 'topPage'
            }
        }
    }
    Tab {
        title: qsTr("Ask HN")
        imageSource: "asset:///images/icons/ic_ask.png"

        AskTab {
            id: ask
            onCreationCompleted: {
                ask.whichPage = 'askPage'
            }
        }
    }
    Tab {
        title: qsTr("New")
        imageSource: "asset:///images/icons/ic_new.png"

        NewTab {
            id: newest
            onCreationCompleted: {
                newest.whichPage = 'newPage'
            }
        }
    }
    Tab {
        title: qsTr("User Pages")
        imageSource: "asset:///images/icons/ic_users.png"

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
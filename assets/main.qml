import bb.cascades 1.0
import "tart.js" as Tart

TabbedPane {
    id: root

    Menu.definition: MenuDefinition {
        actions: [
            ActionItem {
                imageSource: "asset:///images/icons/ic_info.png"
                title: "About"
                enabled: if (root.activePane != aboutPage){true}
                onTriggered: {
                    var np = aboutPage.createObject(activeTab.content);
                    activeTab.push(np)
                    Application.menuEnabled = !Application.menuEnabled;
                }
            },
            ActionItem {
                imageSource: "asset:///images/icons/ic_help.png"
                title: "Help"
                enabled: if (root.activePane != helpPage){true}
                onTriggered: {
                    var np = helpPage.createObject(activeTab.content);
                    activeTab.push(np)
                    Application.menuEnabled = !Application.menuEnabled;
                }
            }
        ]
    }

    Tab {
        id: topTab
        title: qsTr("Top Posts")
        imageSource: "asset:///images/icons/ic_top.png"

        TopTab { // All tab content is a navpPane
            id: top
            onCreationCompleted: {
                top.whichPage = 'topPage'
            }
        }
        onTriggered: {
            if (top.theModel.isEmpty() && top.busy == false) {
                top.busy = true;
                Tart.send('requestPage', {
                        source: top.whichPage,
                        sentBy: top.whichPage
                    });
            }
        }
        signal push(variant p)
        onPush: {
            top.push(p);
        }

    }
    Tab {
        title: qsTr("Ask HN")
        imageSource: "asset:///images/icons/ic_ask.png"
        id: askTab
        AskTab {
            id: ask
            onCreationCompleted: {
                ask.whichPage = 'askPage'
            }
        }
        onTriggered: {
            if (ask.theModel.isEmpty() && ask.busy == false) {
                ask.busy = true;
                Tart.send('requestPage', {
                        source: ask.whichPage,
                        sentBy: ask.whichPage
                    });
            }
        }

        signal push(variant p)
        onPush: {
            ask.push(p);
        }
    }
    Tab {
        title: qsTr("Newest")
        imageSource: "asset:///images/icons/ic_new.png"
        id: newTab
        NewTab {
            id: newest
            onCreationCompleted: {
                newest.whichPage = 'newestPage'
            }
        }
        onTriggered: {
            if (newest.theModel.isEmpty() && newest.busy == false) {
                newest.busy = true;
                Tart.send('requestPage', {
                        source: newest.whichPage,
                        sentBy: newest.whichPage
                    });
            }
        }
        signal push(variant p)
        onPush: {
            newest.push(p);
        }
    }
    Tab {
        title: qsTr("User Pages")
        imageSource: "asset:///images/icons/ic_users.png"
        id: userTab
        NavUserPage {
            id: userPage
        }
        signal push(variant p)
        onPush: {
            userPage.push(p);
        }
    }

    Tab {
        title: qsTr("Search HN")
        imageSource: "asset:///images/icons/ic_search.png"
        id: searchTab
        SearchPage {
            id: search
        }
        signal push(variant p)
        onPush: {
            search.push(p)
        }
    }
    Tab {
        title: qsTr("Favourites")
        imageSource: "asset:///images/icons/ic_star.png"
        id: favouritesTab
        FavouritesTab {
            id: favourites
        }
        signal push(variant p)
        onPush: {
            favourites.push(p)
        }
    }
    onActiveTabChanged: {
        userPage.searchVisible = false;
        if (activeTab == favouritesTab) {
            console.log("Loading favourites")
            //favourites.favouritesModel.clear();
            Tart.send('loadFavourites', {});
        }
    }
    onCreationCompleted: {
        top.busy = true;
        Tart.init(_tart, Application);

        Tart.register(root);
        Tart.send('uiReady');
    }
    showTabsOnActionBar: true
    activeTab: topTab

    attachedObjects: [
        ComponentDefinition {
            id: aboutPage
            AboutPage {
            }
        },
        ComponentDefinition {
            id: helpPage
            HelpPage {
            }
        }
    ]
}
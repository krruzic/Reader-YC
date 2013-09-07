import bb.cascades 1.0
import "tart.js" as Tart
import "global.js" as Global

TabbedPane {
    id: root
    property int numOfStories
    property string coverTitle: "No recent stories..."
    property string coverPoints: ""
    property string coverPoster: ""
    property string coverComments: ""
    property string coverTime: ""
    property int currStory: 0

    signal settingsChanged()

    Menu.definition: MenuDefinition {
        actions: [
            ActionItem {
                imageSource: "asset:///images/icons/ic_info.png"
                title: "About"

                onTriggered: {
                    var page = aboutPage.createObject(activeTab.content);
                    activeTab.push(page)
                    Application.menuEnabled = false;
                }
            },
            ActionItem {
                imageSource: "asset:///images/icons/ic_help.png"
                title: "Help"

                onTriggered: {
                    var page = helpPage.createObject(activeTab.content);
                    activeTab.push(page)
                    Application.menuEnabled = false;
                }
            },
            ActionItem {
                title: "Settings"

                onTriggered: {
                    var page = settingsPage.createObject(activeTab.content);
                    activeTab.push(page)
                    Application.menuEnabled = false;
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
            onPopTransitionEnded: {
                page.destroy();
                Application.menuEnabled = true;
            }
        }
        onTriggered: {
            if (top.theModel.isEmpty() && top.busy == false) {
                top.busy = true;
                top.loading = true;

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
            onPopTransitionEnded: {
                page.destroy();
                Application.menuEnabled = true;
            }
        }
        onTriggered: {
            if (ask.theModel.isEmpty() && ask.busy == false) {
                ask.busy = true;
                ask.loading = true;

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
            onPopTransitionEnded: {
                page.destroy();
                Application.menuEnabled = true;
            }
        }
        onTriggered: {
            if (newest.theModel.isEmpty() && newest.busy == false) {
                newest.busy = true;
                newest.loading = true;
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
            onPopTransitionEnded: {
                page.destroy();
                Application.menuEnabled = true;
            }
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
            onPopTransitionEnded: {
                page.destroy();
                Application.menuEnabled = true;
            }
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
            onPopTransitionEnded: {
                page.destroy();
                Application.menuEnabled = true;
            }
        }
        signal push(variant p)
        onPush: {
            favourites.push(p)
        }
    }
    onActiveTabChanged: {
        userPage.searchVisible = false;
        userPage.playAnim();
        if (activeTab == favouritesTab) {
            console.log("Loading favourites")
            Tart.send('loadFavourites', {
                });
        }
    }
    onCreationCompleted: {
        Application.fullscreen.connect(onFullscreen);
        Application.thumbnail.connect(onThumbnailed);
        //Application.invisible.connect(onInvisible);
        //Application.awake.connect(onVisible);

        top.busy = true;
        Tart.init(_tart, Application);

        Tart.register(root);
        Tart.send('uiReady');
    }
    showTabsOnActionBar: true
    activeTab: topTab

    function onThumbnailed() {
        if (Global.stories[0] != undefined) {
            if (currStory < numOfStories - 1) {
                currStory ++;
            } else {
                currStory = 0;
            }
            console.log(currStory + "   " + numOfStories);
            coverTitle = Global.stories[currStory]['title'];
            coverPoints = Global.stories[currStory]['score'];
            coverPoster = Global.stories[currStory]['author'];
            coverTime = Global.stories[currStory]['time'];
            coverComments = Global.stories[currStory]['commentCount'] + " Comments";
        } else {
            coverTitle = "No recent stories...";
        }
        switchTimer.start();
        Application.cover = appCover.createObject();
    }

    function onFullscreen() {
        switchTimer.stop();
        Application.cover = null;
    }

    //    function onInvisible() {
    //        console.log("INVISIBlE!!!");
    //        switchTimer.stop();
    //    }

    //    function onVisible() {
    //        console.log("VISIBLE!!!!");
    //        switchTimer.start();
    //    }

    function onAddCoverStories(data) {
        numOfStories = data.stories.length;
        Global.stories = data.stories;
        coverTitle = data.stories[0]['title'];
        coverPoints = data.stories[0]['score'];
        coverPoster = data.stories[0]['author'];
        coverTime = data.stories[0]['time'];
        coverComments = data.stories[0]['commentCount'] + " Comments";

    }

    function onRestoreSettings(data) {
        settings.restore(data);
    }
    
    onSettingsChanged: {
        var data = {
            openInBrowser: settings.openInBrowser
        };

        Tart.send('saveSettings', {
                settings: data
            });
    }
    
    

    attachedObjects: [
        ComponentDefinition {
            id: aboutPage
            source: "asset:///AboutPage.qml"
        },
        ComponentDefinition {
            id: helpPage
            source: "asset:///HelpPage.qml"
        },
        ComponentDefinition {
            id: appCover
            source: "asset:///AppCover.qml"
        },
        ComponentDefinition {
            id: settingsPage
            source: "asset:///SettingsPage.qml"
        },
        QTimer {
            id: switchTimer
            interval: 30000 // 30 second interval
            onTimeout: {
                if (Global.stories[0] != undefined) {
                    //console.log(currStory + "   " + numOfStories);
                    coverTitle = Global.stories[currStory]['title'];
                    coverPoints = Global.stories[currStory]['score'];
                    coverPoster = Global.stories[currStory]['author'];
                    coverTime = Global.stories[currStory]['time'];
                    coverComments = Global.stories[currStory]['commentCount'] + " Comments";
                    if (currStory < numOfStories - 1) {
                        currStory ++;
                    } else {
                        currStory = 0;
                    }
                } else {
                    coverTitle = "No recent stories...";
                }
            }
        },
        QtObject {
            id: settings

            property bool openInBrowser: false

            onOpenInBrowserChanged: {
                settingsChanged();
            }

            function restore(data) {
                print('restoring', Object.keys(data));
                if (data.openInBrowser != null) {
                    print('openInBrowser =', data.openInBrowser);
                    openInBrowser = data.openInBrowser;
                }
            }
        }
    ]
}
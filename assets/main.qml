import bb.cascades 1.2
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
        helpAction: HelpActionItem {
            imageSource: "asset:///images/icons/ic_help.png"
            title: "Help"

            onTriggered: {
                var page = helpDef.createObject(activeTab.content);
                activeTab.push(page)
                Application.menuEnabled = false;
            }

        }
        settingsAction: SettingsActionItem {
            title: "Settings"

            onTriggered: {
                var page = settingsDef.createObject(activeTab.content);
                activeTab.push(page)
                Application.menuEnabled = false;
            }
        }
        actions: [
            ActionItem {
                imageSource: "asset:///images/icons/ic_info.png"
                title: "About"
                onTriggered: {
                    var page = aboutDef.createObject(activeTab.content);
                    activeTab.push(page)
                    Application.menuEnabled = false;
                }
            },
            ActionItem {
                imageSource: "asset:///images/icons/ic_add_story.png"
                title: "Post"
                id: postMenuAction
                enabled: settings.loggedIn
                onTriggered: {
                    postSheet.open();
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
            onPopTransitionEnded: {
                page.destroy();
                Application.menuEnabled = true;
            }
            onCreationCompleted: {
                top.whichPage = 'news'
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
                ask.whichPage = 'ask'
            }
            onPopTransitionEnded: {
                page.destroy();
                Application.menuEnabled = true;
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
                newest.whichPage = 'newest'
            }
            onPopTransitionEnded: {
                page.destroy();
                Application.menuEnabled = true;
            }
        }
        signal push(variant p)
        onPush: {
            newest.push(p);
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
        if (activeTab == askTab) {
            if (ask.theModel.isEmpty()) {
                console.log("LOADING ASK PAGE")
                Tart.send('requestPage', {
                        source: 'ask',
                        sentBy: 'ask'
                    });
            }
        }
        if (activeTab == newTab) {
            if (newest.theModel.isEmpty()) {
                Tart.send('requestPage', {
                        source: 'newest',
                        sentBy: 'newest'
                    });
            }
        }
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
        //Tart.debug = true;
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
            openInBrowser: settings.openInBrowser,
            readerMode: settings.readerMode,
            loggedIn: settings.loggedIn,
            username: settings.username,
            legacyFetch: settings.legacyFetch
        };

        Tart.send('saveSettings', {
                settings: data
            });
    }

    attachedObjects: [
        PostSheet {
            id: postSheet
        },
        ComponentDefinition {
            id: aboutDef
            source: "asset:///AboutPage.qml"
        },
        ComponentDefinition {
            id: helpDef
            source: "asset:///HelpPage.qml"
        },
        ComponentDefinition {
            id: appCover
            source: "asset:///AppCover.qml"
        },
        ComponentDefinition {
            id: settingsDef
            source: "SettingsPage.qml"
        },
        QTimer {
            id: switchTimer
            interval: 30000 // 30 second interval
            onTimeout: {
                onThumbnailed();
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
            objectName: "settings"
            property bool openInBrowser: false
            property bool readerMode: false
            property bool loggedIn: false
            property string username: ""
            property bool legacyFetch: false
            onOpenInBrowserChanged: {
                settingsChanged();
            }
            onReaderModeChanged: {
                settingsChanged();
            }
            onLoggedInChanged: {
                console.log("Login value changed: " + loggedIn)
                settingsChanged();
            }
            onUsernameChanged: {
                Global.username = username;
                settingsChanged();
            }
            onLegacyFetchChanged: {
                settingsChanged();
            }
            function restore(data) {
                print('restoring', Object.keys(data));
                if (data.openInBrowser != null) {
                    print('openInBrowser =', data.openInBrowser);
                    openInBrowser = data.openInBrowser;
                    print('readerMode =', data.readerMode);
                    readerMode = data.readerMode;
                    print('logged in =', data.loggedIn);
                    loggedIn = data.loggedIn;
                    print('username = ', data.username);
                    username = data.username;
                    print('legacyFetch =', data.legacyFetch);
                    legacyFetch = data.legacyFetch;
                }
            }
        }
    ]
}
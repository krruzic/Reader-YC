import bb.cascades 1.0
import "tart.js" as Tart
import "global.js" as Global

TabbedPane {
    id: root
    property int numOfStories
    property string coverTitle: "No recent stories..."
    property string coverDetails: ""
    property string coverPoster: ""
    property string coverComments: ""
    property int currStory: 0


    Menu.definition: MenuDefinition {
        actions: [
            ActionItem {
                imageSource: "asset:///images/icons/ic_info.png"
                title: "About"
                enabled: if (root.activePane != aboutPage) {
                    true
                }
                onTriggered: {
                    var np = aboutPage.createObject(activeTab.content);
                    activeTab.push(np)
                    Application.menuEnabled = ! Application.menuEnabled;
                }
            },
            ActionItem {
                imageSource: "asset:///images/icons/ic_help.png"
                title: "Help"
                enabled: if (root.activePane != helpPage) {
                    true
                }
                onTriggered: {
                    var np = helpPage.createObject(activeTab.content);
                    activeTab.push(np)
                    Application.menuEnabled = ! Application.menuEnabled;
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
        function test() {
            console.log("TESTING JS STUFF")
        }
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
            Tart.send('loadFavourites', {
                });
        }
    }
    onCreationCompleted: {
        Application.fullscreen.connect(onFullscreen);
        Application.thumbnail.connect(onThumbnailed);
        Application.invisible.connect(onInvisible);
        //Application.awake.connect(onVisible);

        top.busy = true;
        Tart.init(_tart, Application);

        Tart.register(root);
        Tart.send('uiReady');
    }
    showTabsOnActionBar: true
    activeTab: topTab

    function onThumbnailed() {
        console.log("VISIBLE!!!");
        switchTimer.start();
        Application.cover = appCover.createObject();
    }

    function onFullscreen() {
        switchTimer.stop();
        Application.cover = null;
    }
    
    function onInvisible() {
        console.log("INVISIBlE!!!");
        switchTimer.stop();
    }
    
//    function onVisible() {
//        console.log("VISIBLE!!!!");
//        switchTimer.start();
//    }
    
    
    function onAddCoverStories(data) {
        Global.stories = data.stories;
        numOfStories = data.stories.length;
        coverTitle = data.stories[0][1];
        coverPoster = data.stories[0][4];
        coverDetails = data.stories[0][5] + "| " + data.stories[0][3];
        coverComments = data.stories[0][6] + " Comments";
    }
    
    
    
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
        },
        ComponentDefinition {
            id: appCover
            source: "asset:///AppCover.qml"
        },
        QTimer {
            id: switchTimer
            interval: 30000 // 30 second interval
            onTimeout: {
                console.log("FIRED, stories: " + Global.stories[0]);
                if (Global.stories[0] != undefined) {
                    console.log(currStory + "   " + numOfStories);
                    coverTitle = Global.stories[currStory][1];
                    coverPoster = Global.stories[currStory][4];
                    coverDetails = Global.stories[currStory][5] + "| " + Global.stories[currStory][3];
                    coverComments = Global.stories[currStory][6] + " Comments";
                    if (currStory < numOfStories - 1) {
                        currStory ++;
                    } else {
                        currStory = 0;
                    }
                } else {
                    coverTitle = "No recent stories...";
                }
            }
        }
    ]
}
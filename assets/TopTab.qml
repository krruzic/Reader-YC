import bb.cascades 1.0
import bb.data 1.0
import bb 1.0
import "tart.js" as Tart

NavigationPane {
    id: topPage
    property variant theModel: theModel
    property alias loading: loading.visible
    property string whichPage: ""
    property string morePage: ""
    property string errorText: ""
    property string lastItemType: ""
    property bool busy: true

    onCreationCompleted: {
        Tart.register(topPage)
    }

    onPopTransitionEnded: {
        page.destroy();
        Application.menuEnabled = ! Application.menuEnabled;
    }

    onPushTransitionEnded: {
        if (page.objectName == 'commentPage') {
            Tart.send('requestPage', {
                    source: page.commentLink,
                    sentBy: 'commentPage',
                    askPost: page.isAsk,
                    deleteComments: "False"
                });
        }
    }

    function onAddtopStories(data) {
        lastItemType = 'item'
        var stories = data.stories;
        morePage = data.moreLink;
        errorLabel.visible = false;
        var lastItem = theModel.size() - 1
        //console.log("LAST ITEM: " + lastItemType);
        if (lastItemType == 'error') {
            theModel.removeAt(lastItem)
        }
        theModel.append({
                type: 'item',
                title: data.story['title'],
                domain: data.story['domain'],
                points: data.story['score'],
                poster: data.story['author'],
                timePosted: data.story['time'],
                commentCount: data.story['commentCount'],
                articleURL: data.story['link'],
                commentsURL: data.story['commentURL'],
                hnid: data.story['hnid'],
                isAsk: data.story['askPost']
            });
        busy = false;
        loading.visible = false;
        titleBar.refreshEnabled = ! busy;
    }

    function onTopListError(data) {
        lastItemType = 'error'
        if (theModel.isEmpty() != true) {
            var lastItem = theModel.size() - 1
            //console.log(lastItemType);
            if (lastItemType == 'error') {
                theModel.removeAt(lastItem)
            }
            theModel.append({
                    type: 'error',
                    title: data.text
                });
        } else {
            errorLabel.text = data.text
            errorLabel.visible = true;
        }
        busy = false;
        loading.visible = false;
        titleBar.refreshEnabled = ! busy;
    }

    function showSpacer() {
        if (errorLabel.visible == true || loading.visible == true) {
            return true;
        } else {
            return false;
        }
    }

    Page {
        Container {
            HNTitleBar {
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Top
                id: titleBar
                text: "Reader|YC - Top Posts"
                onRefreshPage: {
                    if (busy != true) {
                        busy = true;
                        Tart.send('requestPage', {
                                source: whichPage,
                                sentBy: whichPage
                            });
                        console.log("pressed")
                        theModel.clear();
                        refreshEnabled = ! busy;
                        loading.visible = true;
                    }
                }
            }
            Container {
                id: spacer
                visible: showSpacer()
                minHeight: 200
                maxHeight: 200
            }
            Container {
                visible: errorLabel.visible
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                Label {
                    id: errorLabel
                    text: "<b><span style='color:#fe8515'>Error getting stories</span></b>\nCheck your connection and try again!"
                    textStyle.fontSize: FontSize.PointValue
                    textStyle.textAlign: TextAlign.Center
                    textStyle.fontSizeValue: 9
                    textStyle.color: Color.DarkGray
                    textFormat: TextFormat.Html
                    multiline: true
                    visible: false
                }
            }
            Container {
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                Container {
                    visible: loading.visible
                    ActivityIndicator {
                        id: loading
                        minHeight: 300
                        minWidth: 300
                        running: true
                        visible: true
                    }
                }
            }
            Container {
                ListView {
                    id: theList
                    dataModel: ArrayDataModel {
                        id: theModel
                    }
                    shortcuts: [
                        Shortcut {
                            key: "T"
                            onTriggered: {
                                theList.scrollToPosition(0, 0x2)
                            }
                        },
                        Shortcut {
                            key: "B"
                            onTriggered: {
                                theList.scrollToPosition(0, 0x2)
                            }
                        },
                        Shortcut {
                            key: "R"
                            onTriggered: {
                                if (! busy)
                                    refreshPage();
                            }
                        }
                    ]
                    function itemType(data, indexPath) {
                        if (data.type != 'error') {
                            lastItemType = 'item';
                            return 'item';
                        } else {
                            lastItemType = 'error';
                            return 'error';
                        }
                    }
                    listItemComponents: [
                        ListItemComponent {
                            type: 'item'
                            HNPage {
                                id: hnItem
                                property string type: ListItemData.type
                                postComments: ListItemData.commentCount
                                postTitle: ListItemData.title
                                postDomain: ListItemData.domain
                                postUsername: ListItemData.poster
                                postTime: ListItemData.timePosted + "| " + ListItemData.points
                                postArticle: ListItemData.articleURL
                                askPost: ListItemData.isAsk
                                commentSource: ListItemData.commentsURL
                                commentID: ListItemData.hnid
                            }
                            function openComments(ListItemData) {
                                var page = commentPage.createObject();
                                //console.log(ListItemData.commentsURL)
                                page.commentLink = ListItemData.hnid;
                                page.title = ListItemData.title;
                                page.titlePoster = ListItemData.poster;
                                page.titleTime = ListItemData.timePosted + "| " + ListItemData.points;
                                page.titleDomain = ListItemData.domain;
                                page.isAsk = ListItemData.isAsk;
                                page.articleLink = ListItemData.articleURL;
                                page.titleComments = ListItemData.commentCount;
                                page.titlePoints = ListItemData.points;
                                topPage.push(page);
                            }
                            function openArticle(ListItemData) {
                                var page = webPage.createObject();
                                page.htmlContent = selectedItem.articleURL;
                                page.text = selectedItem.title;
                                topPage.push(page);
                            }

                        },
                        ListItemComponent {
                            type: 'error'
                            Container {
                                layout: DockLayout {

                                }
                                horizontalAlignment: HorizontalAlignment.Center
                                verticalAlignment: VerticalAlignment.Center
                                ErrorItem {
                                    id: errorItem
                                    title: ListItemData.title
                                }
                            }

                        }
                    ]
                    onTriggered: {
                        if (dataModel.data(indexPath).type == 'error') {
                            return;
                        }

                        var selectedItem = dataModel.data(indexPath);
                        if (settings.openInBrowser == true) {
                            // will auto-invoke after re-arming
                            linkInvocation.query.uri = selectedItem.articleURL;
                            return;
                        }
                        console.log(selectedItem.isAsk);
                        if (selectedItem.isAsk == "true" && selectedItem.hnid != '-1') {
                            console.log("Ask post");
                            var page = commentPage.createObject();
                            topPage.push(page);
                            console.log(selectedItem.commentsURL)
                            page.commentLink = selectedItem.hnid;
                            page.title = selectedItem.title;
                            page.titlePoster = selectedItem.poster;
                            page.titleTime = selectedItem.timePosted + "| " + selectedItem.points
                            page.isAsk = selectedItem.isAsk;
                            page.articleLink = selectedItem.articleURL;
                            page.titleComments = selectedItem.commentCount;
                            page.titlePoints = selectedItem.points
                        } else {
                            console.log('Item triggered. ' + selectedItem.articleURL);
                            var page = webPage.createObject();
                            page.htmlContent = selectedItem.articleURL;
                            page.text = selectedItem.title;
                            topPage.push(page);
                        }
                    }
                    attachedObjects: [
                        ListScrollStateHandler {
                            onAtEndChanged: {
                                if (atEnd == true && theModel.isEmpty() == false && morePage != "" && busy == false) {
                                    console.log('end reached!')
                                    Tart.send('requestPage', {
                                            source: morePage,
                                            sentBy: whichPage
                                        });
                                    busy = true;
                                }
                            }
                        }
                    ]
                }
            }
            attachedObjects: [
                Invocation {
                    id: linkInvocation
                    property bool auto_trigger: false
                    query {
                        uri: "http://peterhansen.ca"

                        onUriChanged: {
                            linkInvocation.query.updateQuery();
                        }
                    }

                    onArmed: {
                        // don't auto-trigger on initial setup
                        if (auto_trigger)
                            trigger("bb.action.OPEN");
                        auto_trigger = true; // allow re-arming to auto-trigger
                    }
                },
                //                ApplicationInfo {
                //                    id: appInfo
                //                },
                ComponentDefinition {
                    id: webPage
                    source: "webArticle.qml"
                },
                ComponentDefinition {
                    id: commentPage
                    source: "CommentPage.qml"
                },
                ComponentDefinition {
                    id: userPage
                    source: "UserPage.qml"
                }
            ]
        }
    }
}
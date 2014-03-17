import bb.cascades 1.2
import bb.system 1.0
import "tart.js" as Tart
import "global.js" as Global

NavigationPane {
    id: favouritesPage
    property string readerURL: "http://www.readability.com/m?url="

    onPopTransitionEnded: {
        page.destroy();
        Application.menuEnabled = ! Application.menuEnabled;
        ActionBarAutoHideBehavior = ActionBarAutoHideBehavior.HideOnScroll;
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

    onCreationCompleted: {
        Tart.register(favouritesPage)
    }
    function onFillList(data) {
        console.log("Filling favourites")
        favouritesModel.clear();

        var stories = data.results;
        console.log("DASFASDF" + stories[0]);
        for (var i = 0; i < stories.length; i ++) {
            var story = stories[i];
            console.log(story);

            favouritesModel.append({
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
                
        }
        if (favouritesModel.isEmpty() == true) {
            emptyContainer.visible = true
        } else {
            emptyContainer.visible = false
        }
    }

    function onDeleteResult(data) {
        favouritesModel.removeAt(data.itemToRemove);
        deleteResultToast.cancel();
        deleteResultToast.show();
        if (favouritesModel.isEmpty() == true) {
            emptyContainer.visible = true
        } else {
            emptyContainer.visible = false
        }
    }

    Page {
        id: favourites
        titleBar: HNTitleBar {
            refreshEnabled: false
            id: titleBar
            listName: favouritesList
            text: "Reader YC - Favourites"

        }
        Container {
            background: Color.White
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            layout: DockLayout {
            }
            Container {
                id: emptyContainer
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                Label {
                    textStyle.base: lightStyle.style
                    text: "<b><span style='color:#ff8e00'>Nothing to see here</span></b>\nTry favouriting a story!"
                    textStyle.fontSize: FontSize.PointValue
                    textStyle.textAlign: TextAlign.Center
                    textStyle.fontSizeValue: 9
                    textStyle.color: Color.DarkGray
                    textFormat: TextFormat.Html
                    multiline: true
                }
            }
            ListView {
                id: favouritesList
                scrollRole: ScrollRole.Main
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                dataModel: ArrayDataModel {
                    id: favouritesModel
                }
                listItemComponents: [
                    ListItemComponent {
                        type: ''
                        SavedItem {
                            property string type: ListItemData.type
                            postComments: ListItemData.commentCount
                            postTitle: ListItemData.title
                            postDomain: ListItemData.domain
                            postUsername: ListItemData.poster
                            postTime: "Saved on: " + ListItemData.timePosted
                            postArticle: ListItemData.articleURL
                            askPost: ListItemData.isAsk
                            commentSource: ListItemData.commentsURL
                            commentID: ListItemData.hnid
                        }
                        function openComments(ListItemData) {
                            var page = commentPage.createObject();
                            console.log(ListItemData.commentsURL)
                            page.commentLink = ListItemData.hnid;
                            page.title = ListItemData.title;
                            page.titlePoster = ListItemData.poster;
                            page.titleTime = ListItemData.timePosted;
                            page.titleDomain = ListItemData.domain;
                            page.isAsk = ListItemData.isAsk;
                            page.articleLink = ListItemData.articleURL;
                            page.titleComments = ListItemData.commentCount;
                            page.titlePoints = ListItemData.points
                            favouritesPage.push(page);
                        }
                        function openArticle(ListItemData) {
                            var page = webPage.createObject();
                            page.htmlContent = ListItemData.articleURL;
                            if (settings.readerMode == true && ListItemData.isAsk != "true")
                                page.htmlContent = readerURL + ListItemData.articleURL;
                            page.text = selectedItem.title;
                            favouritesPage.push(page);
                        }

                    }
                ]
                onTriggered: {
                    var selectedItem = dataModel.data(indexPath);
                    if (settings.openInBrowser == true) {
                        // will auto-invoke after re-arming
                        console.log("OPENING IN BROWSER");
                        linkInvocation.query.uri = "";
                        linkInvocation.query.uri = selectedItem.articleURL;
                        return;
                    }
                    if (settings.readerMode == true && selectedItem.isAsk != "true") {
                        selectedItem.articleURL = readerURL + selectedItem.articleURL;
                        console.log('Item triggered. ' + selectedItem.articleURL);
                        var page = webPage.createObject();
                        page.htmlContent = selectedItem.articleURL;
                        page.text = selectedItem.title;
                        favouritesPage.push(page);
                        return;
                    }
                    console.log(selectedItem.isAsk);
                    if (selectedItem.isAsk == "true" && selectedItem.hnid != '-1') {
                        console.log("Ask post");
                        var page = commentPage.createObject();
                        favouritesPage.push(page);
                        console.log(selectedItem.commentsURL)
                        page.commentLink = selectedItem.hnid;
                        page.title = selectedItem.title;
                        page.titlePoster = selectedItem.poster;
                        page.titleTime = "Saved on: " + selectedItem.timePosted;
                        page.titleDomain = ListItemData.domain;
                        page.isAsk = selectedItem.isAsk;
                        Tart.send('requestPage', {
                                source: selectedItem.hnid,
                                sentBy: 'commentPage',
                                askPost: selectedItem.isAsk,
                                deleteComments: "false"
                            });
                    } else {
                        console.log('Item triggered. ' + selectedItem.articleURL);
                        var page = webPage.createObject();
                        favouritesPage.push(page);
                        page.htmlContent = selectedItem.articleURL;
                        page.text = selectedItem.title;
                    }
                }
            }
        }
    }
    attachedObjects: [
        TextStyleDefinition {
            id: lightStyle
            base: SystemDefaults.TextStyles.BodyText
            fontSize: FontSize.PointValue
            fontSizeValue: 7
            fontWeight: FontWeight.W300
        },
        Invocation {
            id: linkInvocation
            property bool auto_trigger: false
            query {
                uri: "http://peterhansen.ca"
                invokeTargetId: "sys.browser"

                onUriChanged: {
                    if (uri != "") {
                        linkInvocation.query.updateQuery();
                    }
                }
            }

            onArmed: {
                // don't auto-trigger on initial setup
                if (auto_trigger)
                    trigger("bb.action.OPEN");
                auto_trigger = true; // allow re-arming to auto-trigger
            }
        },
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
        },
        SystemToast {
            id: deleteResultToast
            body: "Favourite Removed!"
        }
    ]
}
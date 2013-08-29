import bb.cascades 1.0
import bb.system 1.0
import "tart.js" as Tart

NavigationPane {
    id: favouritesPage

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
    
    onCreationCompleted: {
        Tart.register(favouritesPage)
    }
    function onFillList(data) {
        favouritesModel.clear();

        var stories = data.list
        for (var i = 0; i < stories.length; i ++) {
            var story = stories[i];
            console.log(story);
            favouritesModel.append({
                    type: 'item',
                    title: story[0],
                    articleURL: story[1],
                    timePosted: story[2] + " ",
                    poster: story[3],
                    commentCount: story[4],
                    isAsk: story[5],
                    domain: story[6],
                    points: story[7],
                    commentsURL: story[8],
                    hnid: story[8]
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
        Container {
            layout: DockLayout {
            }

            HNTitleBar {
                text: "Reader|YC - Favourites"
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Top
            }
            Container {
                id: emptyContainer
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                layout: StackLayout {

                }
                Label {
                    text: "<b><span style='color:#fe8515'>Nothing to see here,</span></b>\nTry favouriting a story!"
                    textStyle.fontSize: FontSize.PointValue
                    textStyle.textAlign: TextAlign.Center
                    textStyle.fontSizeValue: 9
                    textStyle.color: Color.DarkGray
                    textFormat: TextFormat.Html
                    multiline: true
                }
            }
            Container {
                horizontalAlignment: horizontalAlignment.Center
                verticalAlignment: verticalAlignment.Center
                topPadding: 118
                layout: StackLayout {

                }
                ListView {
                    id: favouritesList
                    dataModel: ArrayDataModel {
                        id: favouritesModel
                    }
                    listItemComponents: [
                        ListItemComponent {
                            type: ''
                            SavedItem {
                                id: hnItem
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
                        }
                    ]
                    onTriggered: {
                        var selectedItem = dataModel.data(indexPath);
                        console.log(selectedItem.isAsk);
                        if (selectedItem.isAsk == "true" && selectedItem.hnid != '-1') {
                            console.log("Ask post");
                            var page = commentPage.createObject();
                            favouritesPage.push(page);
                            console.log(selectedItem.commentsURL)
                            page.commentLink = selectedItem.hnid;
                            page.title = selectedItem.title;
                            page.titlePoster = selectedItem.poster;
                            page.titleTime = "Saved on: " + selectedItem.timePosted
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
                    function pushPage(pageToPush) {
                        console.log(pageToPush)
                        var page = eval(pageToPush).createObject();
                        favouritesPage.push(page);
                        return page;
                    }
                }
            }
        }
        attachedObjects: [
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
}
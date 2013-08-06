import bb.cascades 1.0
import bb.data 1.0
import bb 1.0
import "tart.js" as Tart

NavigationPane {
    id: newestPage
    property string whichPage: ""
    property string morePage: ""
    property bool busy: false

    onCreationCompleted: {
        Tart.register(newestPage)
    }

    onPopTransitionEnded: {
        page.destroy()
    }

    //    function itemType(data) {
    //        console.log('TEST');
    //        return data.title ? '' : 'errorItem';
    //    }

    function onAddNewStories(data) {
        var stories = data.stories;
        morePage = data.moreLink;
        //refreshEnabled = true;
        for (var i = 0; i < stories.length; i ++) {
            var story = stories[i];
            theModel.append({
                    title: story[1],
                    domain: story[2],
                    points: story[3],
                    poster: story[4],
                    timePosted: story[5],
                    commentCount: story[6],
                    articleURL: story[7],
                    commentsURL: story[8],
                    isAsk: story[10]
                });
        }
        busy = false;
    }

    function onListError(data) {
        errorLabel.visible = true;
        errorLabel.text = data.text;
        //        theModel.append({
        //                text: data.text
        //            });
        busy = false;
    }
    Page {
        Container {
            HNTitleBar {
                text: "Reader|YC - Newest Posts"
                onRefreshPage: {
                    Tart.send('requestPage', {
                            source: "Newest Posts",
                            sentBy: whichPage
                        });
                    console.log("pressed")
                    theModel.clear();
                    errorLabel.text = "";
                    errorLabel.visible = false;
                    //refreshEnabled = false;
                    busy = true;
                }
                onTouch: {
                    theList.scrollToPosition(0, 0x2)
                }
            }
            Label {
                maxHeight: 20.0
                text: appInfo.version
                textStyle.fontSize: FontSize.Small
                textStyle.color: Color.Black
            }

            Container {
                Label {
                    id: errorLabel
                    text: ""
                    visible: false
                    multiline: true
                    autoSize.maxLineCount: 2
                    textStyle.fontSize: FontSize.Medium
                    textStyle.fontStyle: FontStyle.Italic
                    textStyle.color: Color.DarkGray
                    textStyle.textAlign: TextAlign.Center
                }

                ListView {
                    id: theList
                    dataModel: ArrayDataModel {
                        id: theModel
                    }
                    listItemComponents: [
                        ListItemComponent {
                            type: ''
                            HNPage {
                                postTitle: ListItemData.title
                                postDomain: ListItemData.domain
                                postUsername: ListItemData.poster
                                postTime: ListItemData.timePosted + "| " + ListItemData.points
                                postComments: ListItemData.commentCount
                                postArticle: ListItemData.articleURL
                                askPost: ListItemData.isAsk
                                commentSource: ListItemData.commentsURL
                                onCommentsClicked: {
                                    //console.log(ListItemData.commentsURL);
                                    var page = commentPage.createObject();
                                    newestPage.push(page);
                                    //page.test = ListItemData.commentsURL;
                                }
                            }
                        }
                    ]
                    onTriggered: {
                        var selectedItem = dataModel.data(indexPath);
                        console.log(selectedItem.isAsk);
                        if (selectedItem.isAsk == "true") {
                            console.log("Ask post");
                            var page = commentPage.createObject();
                            newestPage.push(page);
                            console.log(selectedItem.commentsURL)
                            page.commentLink = selectedItem.commentsURL;
                            page.title = selectedItem.title;
                            page.titlePoster = selectedItem.poster;
                            page.titleTime = selectedItem.timePosted + "| " + selectedItem.points
                        } else {
                            console.log('Item triggered. ' + selectedItem.articleURL);
                            var page = webPage.createObject();
                            newestPage.push(page);
                            page.htmlContent = selectedItem.articleURL;
                            page.text = selectedItem.title;
                        }
                    }
                    attachedObjects: [
                        ListScrollStateHandler {
                            onAtEndChanged: {
                                if (atEnd == true && theModel.isEmpty() == false) {
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
                ApplicationInfo {
                    id: appInfo
                },
                ComponentDefinition {
                    id: webPage
                    source: "webArticle.qml"
                },
                ComponentDefinition {
                    id: commentPage
                    source: "CommentPage.qml"
                }
            ]
        }
    }
}
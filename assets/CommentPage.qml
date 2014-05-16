import bb.cascades 1.2
import bb.system 1.2
import "tart.js" as Tart
import "global.js" as Global

Page {
    objectName: 'commentPage'
    id: commentPane
    property string isAsk: ""
    property string commentLink: ""
    property string articleLink: ""
    property string lastItemType: ""
    property bool busy: false
    property string title: ""
    property string titlePoster: ""
    property string titleDomain: ""
    property string titleTime: ""
    property string titleText: ""
    property string titleComments: ""
    property string titlePoints: ""
    property string readerURL: "http://www.readability.com/m?url="
    property variant prevItem: null
    property bool commentEnabled: true
    property int commentIndex: 0
    property int replyIndent: 0

    onCreationCompleted: {
        busy = true;
        Tart.register(commentPane);
        titleBar.refreshEnabled = false;
        ActionBarAutoHideBehavior = ActionBarAutoHideBehavior.HideOnScroll;
        TitleBarScrollBehavior = TitleBarScrollBehavior.NonSticky;
    }

    function onCommentPosted(data) {
        console.log("comment posted!!");
        commentEnabled = true;
        console.log(data.result);
        if (data.result == "true") {
            commentModel.removeAt(commentIndex);
            mainContainer.commentModel.insert(commentIndex, {
                    type: 'item',
                    poster: settings.username,
                    timePosted: "Just now",
                    indent: replyIndent,
                    text: data.comment,
                    link: ""
                });
            lastItemType = 'item';
        } else {
            //mainContainer.commentToast.body = "Posting comment failed!";
            console.log("Error sending comment!")
        }
    }

    function onCommentError(data) {
        if (commentLink == data.hnid && commentModel.size() <= 1) {
            commentList.visible = true;
            busy = false;
            titleBar.refreshEnabled = true;
            var lastItem = commentModel.size() - 1;
            console.log(lastItemType);
            if (lastItemType == 'error') {
                commentModel.removeAt(lastItem);
            }
            commentModel.append({
                    type: 'error',
                    title: data.text
                });
            lastItemType = 'error';
        }
    }

    function onAddText(data) {
        if (Global.username != "") {
            commentPane.removeAction(actionAt(4));
            var item = commentAction.createObject();
            commentPane.addAction(item);
        }
        commentList.visible = true;
        busy = false;
        titleBar.refreshEnabled = true;
        if (commentLink == data.hnid && commentModel.isEmpty() == true) {
            commentModel.append({
                    type: 'header',
                    hTitle: commentPane.title,
                    poster: commentPane.titlePoster,
                    domain: commentPane.titleDomain,
                    articleTime: commentPane.titleTime,
                    commentCount: commentPane.titleComments,
                    points: commentPane.titlePoints,
                    text: data.text
                });
            lastItemType = 'header';
        }
    }

    function onAddComments(data) {
        if (commentLink == data.hnid) {
            commentModel.append({
                    type: 'item',
                    poster: data.comment["author"],
                    timePosted: data.comment["time"],
                    indent: data.comment["indent"],
                    text: "<html>" + data.comment["text"] + "</html>",
                    link: data.comment["id"],
                    barColour: data.comment["barColour"]
                });
            lastItemType = 'item';
        }
        busy = false;
    }
    

    attachedObjects: [
        ComponentDefinition {
            id: commentAction
            ActionItem {
                title: "Comment"
                imageSource: "asset:///images/icons/ic_comments.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                onTriggered: {
                    onTriggered:
                    {
                        // insert new element into listview after selected item
                        // (Reply item)
                        Application.menuEnabled = false;
                        commentList.addComment(0, commentLink, -40);
                    }
                }
            }
        }
    ]
    actions: [
        InvokeActionItem {
            ActionBar.placement: ActionBarPlacement.OnBar
            title: "Share"
            query {
                mimeType: "text/plain"
                invokeActionId: "bb.action.SHARE"
            }
            onTriggered: {
                data = commentPane.title + "\n" + "https://news.ycombinator.com/item?id=" + commentLink + "\n" + "Shared using Reader YC "
            }
        },
        ActionItem {
            ActionBar.placement: ActionBarPlacement.OnBar
            title: "Open Article"
            imageSource: "asset:///images/icons/ic_story.png"
            onTriggered: {
                var page = webPage.createObject();
                if (isAsk == "true") {
                    page.htmlContent = "https://news.ycombinator.com/item?id=" + commentLink;
                } else {
                    page.htmlContent = articleLink;
                }
                if (settings.readerMode == true && isAsk != "true")
                    page.htmlContent = readerURL + articleLink;
                page.text = commentPane.title;
                root.activePane.push(page);
            }
        },
        InvokeActionItem {
            title: "Open in Browser"
            imageSource: "asset:///images/icons/ic_open_link.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            id: browserQuery
            //query.mimeType: "text/plain"
            query.invokeActionId: "bb.action.OPEN"
            query.uri: "https://news.ycombinator.com/item?id=" + commentPane.commentLink
            query.invokeTargetId: "sys.browser"
            query.onQueryChanged: {
                browserQuery.query.updateQuery();
            }
        },
        ActionItem {
            title: "Favourite"
            imageSource: "asset:///images/icons/ic_star_add.png"
            onTriggered: {
                var date = new Date();
                var formattedDate = Qt.formatDateTime(date, "dd-MM-yyyy"); //to format date
                var articleDetails = [ commentPane.title, commentPane.articleLink, String(formattedDate), commentPane.titlePoster,
                    commentPane.titleComments, commentPane.isAsk, commentPane.titleDomain, commentPane.titlePoints,
                    commentPane.commentLink ];

                Tart.send('saveArticle', {
                        article: articleDetails
                    });
            }
        }
    ]
    titleBar: HNTitleBar {
        id: titleBar
        text: commentPane.title
        listName: commentList
        onRefreshPage: {
            busy = true;
            Tart.send('requestPage', {
                    source: commentLink,
                    sentBy: 'commentPage',
                    askPost: isAsk,
                    deleteComments: "True"
                });
            console.log("pressed");
            commentModel.clear();
            titleBar.refreshEnabled = false;
        }
    }
    Container {
        id: mainContainer

        
        layout: DockLayout {
        }
        Container {
            visible: busy
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            ActivityIndicator {
                id: loading
                minHeight: 300
                minWidth: 300
                running: true
                visible: busy
            }
        }
        Container {
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            ListView {
                scrollRole: ScrollRole.Main
                id: commentList
                dataModel: ArrayDataModel {
                    id: commentModel
                }

                function itemType(data, indexPath) {
                    return data.type;
                }
                function addComment(index, link, indent) {
                    if (commentEnabled == false) {
                        return;
                    }
                    console.log("replying to comment at ....");
                    print(index, link);
                    commentEnabled = false;
                    commentIndex = index + 1;
                    replyIndent = indent + 40;
                    commentModel.insert(index + 1, {
                            'type': 'newComment',
                            'link': link,
                            'text': ""
                        });
                    commentList.scrollToItem([ index + 1 ], ScrollAnimation.Smooth);
                }
                function cancelComment(index) {
                    console.log("Cancelling comment...");
                    commentEnabled = true;
                    commentModel.removeAt(index);
                }
                function updateComment(result, data) {
                    if (result == "true") {

                        Application.menuEnabled = true;
                        commentEnabled = true;
                        commentModel.removeAt(commentIndex);
                        if (lastItemType = 'error') {
                            commentModel.removeAt(commentModel.size() - 1);
                        }
                        commentModel.insert(commentIndex, {
                                type: 'item',
                                poster: settings.username,
                                timePosted: "Just now",
                                indent: replyIndent,
                                text: data.comment,
                                link: ""
                            });
                    }
                }
                listItemComponents: [
                    ListItemComponent {
                        type: 'header'
                        CommentHeader {
                            id: commentHeader
                            topPadding: 10
                            leftPadding: 20
                            rightPadding: 20
                            property string type: ListItemData.type
                            bodyText: "<html>" + ListItemData.text + "</html>"
                            commentCount: ListItemData.commentCount
                            points: ListItemData.points
                        }
                    },
                    ListItemComponent {
                        type: 'item'
                        Comment {
                            id: commentItem
                            leftPadding: 20
                            rightPadding: 0
                            property string type: ListItemData.type
                            time: ListItemData.timePosted
                            indent: ListItemData.indent
                            text: ListItemData.text
                            link: ListItemData.link
                            barColour: ListItemData.barColour
                        }
                    },
                    ListItemComponent {
                        type: 'error'
                        ErrorItem {
                            property string type: ListItemData.type
                            title: ListItemData.title
                            id: errorItem
                        }
                    },
                    ListItemComponent {
                        type: 'newComment'
                        ReplyItem {
                            objectName: "replyItem"
                            id: replyItem
                            property string type: ListItemData.type
                            link: ListItemData.link
                            text: ListItemData.text
                        }
                    }
                ]
                function hideChildren(index) {
                    for (var i = index + 1; i < commentModel.size() - 1; i ++) {
                        var sentItem = commentModel.value(index)
                        var currentItem = commentModel.value(i)
                        console.log(currentItem.indent)
                        if (currentItem.indent > sentItem.indent) {
                            currentItem.commentContainer.visible = false;
                        } else {
                            break;
                        }
                    }
                }
                function showChildren(index) {
                    for (var i = index + 1; i < commentModel.size() - 1; i ++) {
                        var sentItem = commentModel.value(index)
                        var currentItem = commentModel.value(i)
                        console.log(currentItem.indent)
                        if (currentItem.indent > sentItem.indent) {
                            currentItem.commentContatiner.visible = true;
                        } else {
                            break;
                        }
                    }
                }
                function pushPage(pageToPush) {
                    console.log(pageToPush)
                    var page = eval(pageToPush).createObject();
                    root.activePane.push(page);
                    return page;
                }
            }
        }
    }
}
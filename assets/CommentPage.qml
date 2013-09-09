import bb.cascades 1.0
import "tart.js" as Tart

Page {
    objectName: 'commentPage'
    id: commentPane
    property string isAsk: ""
    property string commentLink: ""
    property string articleLink: ""
    property string errorText: ""
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

    onCreationCompleted: {
        busy = true;
        Tart.register(commentPane);
        titleBar.refreshEnabled = false;
    }

    function onCommentError(data) {
        if (commentLink == data.hnid && commentModel.size() <= 1) {
            commentList.visible = true;
            busy = false;
            titleBar.refreshEnabled = true;
            var lastItem = commentModel.size() - 1
            console.log(lastItemType);
            if (lastItemType == 'error') {
                commentModel.removeAt(lastItem)
            }
            commentModel.append({
                    type: 'error',
                    title: data.text
                });
            lastItemType = 'error';
        }
    }

    function onAddText(data) {
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
                    text: data.comment["text"],
                    link: "https://news.ycombinator.com/item?id=" + data.comment["link"]
                });
            lastItemType = 'item';
        }
    }

    actions: [
        InvokeActionItem {
            ActionBar.placement: ActionBarPlacement.OnBar
            title: "Share Comments"
            query {
                mimeType: "text/plain"
                invokeActionId: "bb.action.SHARE"
            }
            onTriggered: {
                data = commentPane.title + "\n" + "https://news.ycombinator.com/item?id=" + commentLink + "\n" + " Shared using Reader|YC "
            }
        },
        ActionItem {
            ActionBar.placement: ActionBarPlacement.OnBar
            title: "View Article"
            imageSource: "asset:///images/icons/ic_article.png"
            onTriggered: {
                var page = webPage.createObject();
                page.htmlContent = articleLink;
                if (settings.readerMode == true && isAsk != "true")
                    page.htmlContent = readerURL + ListItemData.articleURL;
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
            title: "Favourite Article"
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
                id: commentList
                dataModel: ArrayDataModel {
                    id: commentModel
                }

                function itemType(data, indexPath) {
                    return data.type
                }

                listItemComponents: [
                    ListItemComponent {
                        type: 'header'
                        CommentHeader {
                            id: commentHeader
                            topPadding: 10
                            leftPadding: 19
                            rightPadding: 19
                            property string type: ListItemData.type
                            hTitle: ListItemData.hTitle
                            poster: ListItemData.poster
                            domain: ListItemData.domain
                            articleTime: ListItemData.articleTime
                            text: ListItemData.text
                        }
                    },
                    ListItemComponent {
                        type: 'item'
                        Comment {
                            id: commentItem
                            leftPadding: 19
                            rightPadding: 19
                            property string type: ListItemData.type
                            poster: ListItemData.poster
                            time: ListItemData.timePosted
                            indent: ListItemData.indent
                            text: ListItemData.text
                        }
                    },
                    ListItemComponent {
                        type: 'error'
                        ErrorItem {
                            property string type: ListItemData.type
                            title: ListItemData.title
                            id: errorItem
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
                onTriggered: {
                    console.log("Comment triggered!")
                }
            }
        }
    }
}
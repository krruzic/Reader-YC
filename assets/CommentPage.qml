import bb.cascades 1.0
import "tart.js" as Tart

Page {
    id: commentPane
    property string isAsk: ""
    property string commentLink: ""
    property string articleLink: ""
    property string errorText: ""
    property string lastItemType: ""
    property bool busy: false
    property alias title: commentHeader.title
    property alias titlePoster: commentHeader.poster
    property alias titleDomain: commentHeader.domain
    property alias titleTime: commentHeader.articleTime

    onCreationCompleted: {
        busy = true;
        Tart.register(commentPane);

        commentList.scrollToPosition(-1, ScrollAnimation.Smooth)

    }

    function onCommentError(data) {
        var lastItem = commentModel.size() - 1
        console.log(lastItemType);
        if (lastItemType == 'error') {
            commentModel.removeAt(lastItem)
        }
        commentModel.append({
                type: 'error',
                title: data.text
            });
        busy = false;
        console.log(data.text)
    }

    function onAddComments(data) {
        commentModel.append({
                type: 'item',
                poster: data.comment["username"],
                timePosted: data.comment["time"],
                indent: data.comment["level"] * 40,
                text: data.comment["comment"]
            });
        busy = false;
        refreshEnabled = ! busy;
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
                data = commentPane.title + "\n" + commentLink + "\n" + " Shared using Reader|YC "
            }
        },
        ActionItem {
            ActionBar.placement: ActionBarPlacement.OnBar
            title: "View Article"
            imageSource: "asset:///images/icons/ic_article.png"
            onTriggered: {
                var page = webPage.createObject();
                topPage.push(page);
                page.htmlContent = articleLink;
                page.text = commentPane.title;
            }
        },
        InvokeActionItem {
            title: "Open in Browser"
            imageSource: "asset:///images/icons/ic_open_link.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            id: browserQuery
            query.mimeType: "text/plain"
            query.invokeActionId: "bb.action.OPEN"
            query.uri: commentPane.commentLink

            query.onQueryChanged: {
                browserQuery.query.updateQuery();
            }
        }
    ]

    Container {
        HNTitleBar {
            id: titleBar
            text: title
            onRefreshPage: {
                busy = true;
                Tart.send('requestComments', {
                        source: commentLink,
                        askPost: isAsk,
                        deleteComments: "True"
                    });
                console.log("pressed");
                commentModel.clear();
                refreshEnabled = ! busy;
            }
            onTouch: {
                commentList.scrollToPosition(0, 0x2);
            }
        }
        Container {
            topPadding: 10
            Container {
                visible: busy
                rightPadding: 220
                leftPadding: 220
                topPadding: 80
                ActivityIndicator {
                    minHeight: 300
                    minWidth: 300
                    running: true
                    visible: busy
                }
            }
            ListView {
                leadingVisual: CommentHeader {
                    leftPadding: 19
                    rightPadding: 19
                    id: commentHeader
                }
                id: commentList

                dataModel: ArrayDataModel {
                    id: commentModel
                }

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
                        Label {
                            id: errorItem
                            property string type: ListItemData.type
                            text: ListItemData.title
                            visible: true
                            multiline: true
                            autoSize.maxLineCount: 2
                            textStyle.fontSize: FontSize.Medium
                            textStyle.fontStyle: FontStyle.Italic
                            textStyle.textAlign: TextAlign.Center
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
                    topPage.push(page);
                    return page;
                }
                onTriggered: {
                    console.log("Comment triggered!")
                }
            }
        }
    }
}

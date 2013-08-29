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
        commentList.visible = true;
        if (commentModel.isEmpty() == true) {
            emptyContainer.visible = true
        } else {
            emptyContainer.visible = false
        }
        if (commentLink == data.hnid) {
            //            var lastItem = commentModel.size() - 1
            //            console.log(lastItemType);
            //            if (lastItemType == 'error') {
            //                commentModel.removeAt(lastItem)
            //            }
            //            commentModel.append({
            //                    type: 'error',
            //                    title: data.text
            //                });
            busy = false;
            console.log(data.text)
            titleBar.refreshEnabled = true;
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
            commentList.visible = true;
            busy = false;
            titleBar.refreshEnabled = true;
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
                console.log(articleLink);
                var page = webPage.createObject();
                root.activePane.push(page);
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
            query.uri: "https://news.ycombinator.com/item?id=" + commentPane.commentLink

            query.onQueryChanged: {
                browserQuery.query.updateQuery();
            }
        }
    ]

    Container {
        layout: DockLayout {
        }
        HNTitleBar {
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Top
            id: titleBar
            text: title
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
            id: emptyContainer
            visible: false
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            layout: StackLayout {

            }
            Label {
                text: "<b><span style='color:#fe8515'>No comments,</span></b>\nCheck back later!"
                textStyle.fontSize: FontSize.PointValue
                textStyle.textAlign: TextAlign.Center
                textStyle.fontSizeValue: 9
                textStyle.color: Color.DarkGray
                textFormat: TextFormat.Html
                multiline: true
            }
        }
        Container {
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            Container {
                visible: busy
                ActivityIndicator {
                    minHeight: 300
                    minWidth: 300
                    running: true
                    visible: busy
                }
            }
            Container {
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                topPadding: 118

                Container {
                    ListView {
                        leadingVisual: CommentHeader {
                            topPadding: 10
                            leftPadding: 19
                            rightPadding: 19
                            id: commentHeader
                        }
                        id: commentList
                        visible: false
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
                                Container {
                                    layout: DockLayout {
                                    }
                                    horizontalAlignment: horizontalAlignment.Center
                                    verticalAlignment: verticalAlignment.Center
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
    }
}
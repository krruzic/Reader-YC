import bb.cascades 1.0
import "tart.js" as Tart

Page {
    id: commentPane
    property string moreComments: ""
    property string commentLink: ""
    property string articleLink: ""
    property bool busy: false
    property alias title: commentHeader.title
    property alias titlePoster: commentHeader.poster
    property alias titleDomain: commentHeader.domain
    property alias titleTime: commentHeader.articleTime

    onCreationCompleted: {
        busy = true;
        Tart.register(commentPane);
    }

    function onCommentError(data) {
        console.log(data.text)
    }

    function onAddComments(data) {
        commentModel.append({
                poster: data.comment["username"],
                timePosted: data.comment["time"],
                indent: data.comment["level"] * 40,
                text: data.comment["comment"]
            });
        busy = false;
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
        }
//        InvokeActionItem {
//            title: "Open in Browser"
//            imageSource: "asset:///images/icons/ic_open_link.png"
//            ActionBar.placement: ActionBarPlacement.InOverflow
//            id: browserQuery
//            query {
//                mimeType: "text/plain"
//                invokeTargetId: "sys.browser"
//                invokeActionId: "bb.action.OPEN"
//                uri: ""
//            }
//            onTriggered: {
//                browserQuery.query.uri = commentLink;
//                browserQuery.query.updateQuery();
//            }
//        }
    ]

    Container {
        topPadding: 10

        CommentHeader {
            leftPadding: 19
            rightPadding: 19
            id: commentHeader
        }
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
            id: commentList

            dataModel: ArrayDataModel {
                id: commentModel
            }
            listItemComponents: [
                ListItemComponent {
                    type: ''
                    Comment {
                        id: commentItem
                        leftPadding: 19
                        rightPadding: 19
                        poster: ListItemData.poster
                        time: ListItemData.timePosted
                        indent: ListItemData.indent
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
                topPage.push(page);
                return page;
            }
            onTriggered: {
                console.log("Comment triggered!")
            }
            //            attachedObjects: [
            //                ListScrollStateHandler {
            //                    onAtBeginningChanged: {
            //                        if (atBeginning == false && !commentModel.isEmpty())
            //                        	commentHeader.visible = false;
            //                    }
            //                }
            //            ]
        }
    }
}

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
        data.comment.replace('__BR__', '\n')
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
    //        },
    //        InvokeActionItem {
    //            ActionBar.placement: ActionBarPlacement.OnBar
    //            title: "Open in Browser"
    //            query {
    //                mimeType: "sys.browser"
    //                invokeActionId: "bb.action.OPEN"
    //            }
    //            onTriggered: {
    //
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
        ActivityIndicator {
            minHeight: 300
            minWidth: 300
            running: true
            visible: busy
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
                        leftPadding: 19
                        rightPadding: 19
                        id: commentItem
                        poster: ListItemData.poster
                        time: ListItemData.timePosted
                        indent: ListItemData.indent
                        text: ListItemData.text
                    }

                }
            ]
            function hideChildren(index) {
                for (var i = index + 1; i < commentModel.size() - 1; i ++) {
                    var currentItem = commentModel.value(i)
                    console.log(index.indent)
                    if (currentItem.indent > index.indent) {
                        currentItem.visible = false;
                    } else {
                        break;
                    }
                }
            }
            function showChildren(index) {
                for (var i = index + 1; i < commentModel.size() - 1; i ++) {
                    var currentItem = commentModel.value(i)
                    console.log(currentItem.indent)
                    if (currentItem.indent > index.indent) {
                        currentItem.visible = true;
                    } else {
                        break;
                    }
                }
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

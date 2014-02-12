import bb.cascades 1.2
import bb.system 1.2
import "tart.js" as Tart
import "global.js" as Global

Container {
    id: commmentContainer
    visible: true
    property string time: ""
    property alias indent: commmentContainer.leftPadding
    property alias text: commentBox.text
    property string link: ""
    horizontalAlignment: HorizontalAlignment.Fill
    leftPadding: indent
    onCreationCompleted: {
        Tart.register(commmentContainer);
        if (Global.username != "") {
            replyAction.enabled = true;
        }
    }
    onContextMenuHandlerChanged: {
        if (link == "") {
            replyAction.enabled = false;	
        }
        if (Global.username == "") {
            replyAction.enabled = false;
        }
    }
//    onContextMenuHandlerChanged: {
//        if (contextMenuHandler) {
//            contextMenuHandlerChanged(contextMenuHandler)
//            controlAdded(control)
//            add(controls.)
//        }
//    }
    attachedObjects: [
        TextStyleDefinition {
            id: lightStyle
            base: SystemDefaults.TextStyles.BodyText
            fontSize: FontSize.PointValue
            fontSizeValue: 7
            fontWeight: FontWeight.W100
        },
        LayoutUpdateHandler {
            id: mainDimensions
        },
        SystemToast {
            id: copyResultToast
            body: ""
        }
    ]

    function setHighlight(highlighted) {
        if (highlighted) {
            comment.background = Color.create("#e0e0e0")
        } else {
            comment.background = Color.White
        }
    }

    // Connect the onActivedChanged signal to the highlight function
    ListItem.onActivationChanged: {
        setHighlight(ListItem.active);
    }

    // Connect the onSelectedChanged signal to the highlight function
    ListItem.onSelectionChanged: {
        setHighlight(ListItem.selected);
    }

    function onCopyResult(data) {
        copyResultToast.body = "Comment copied!";
        copyResultToast.cancel();
        copyResultToast.show();
    }
    contextActions: [
        ActionSet {
            title: commentBox.text
            subtitle: ListItemData.poster
            InvokeActionItem {
                title: "Share Comment"
                query {
                    mimeType: "text/plain"
                    invokeActionId: "bb.action.SHARE"
                }
                onTriggered: {
                    var selectedItem = commentItem.ListItem.view.dataModel.data(commentItem.ListItem.indexPath);
                    data = 'Comment by:  ' + selectedItem.poster + '\n' + "https://news.ycombinator.com/item?id=" + selectedItem.link + "\nShared using Reader YC "
                }
            }
            ActionItem {
                title: "Copy Comment"
                imageSource: "asset:///images/icons/ic_copy.png"
                onTriggered: {
                    Tart.send('copyLink', {
                            articleLink: commentBox.text
                        });
                }
            }
            ActionItem {
                id: replyAction
                title: "Reply to comment"
                imageSource: "asset:///images/icons/ic_comments.png"
                enabled: false
                onTriggered: {
                    // insert new element into listview after selected item
                    // (Reply item)
                    Application.menuEnabled = false;
                    commentItem.ListItem.view.addComment(commmentContainer.ListItem.indexInSection, link, indent);
                }
            }
        }
    ]
    Container {
        bottomPadding: 10
        leftPadding: 20
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }

        Container {
            id: commentLine
            background: Color.create("#ff8c00")
            horizontalAlignment: HorizontalAlignment.Fill
            minWidth: 6
            bottomMargin: 0
            topMargin: 0
            minHeight: bodyDimensions.layoutFrame.height
            visible: true
        }
        Container {
            rightPadding: 10
            id: comment
            Label {
                id: posterLabel
                translationX: 10
                text: ListItemData.poster + "  " + time
                textStyle.base: lightStyle.style
                textFormat: TextFormat.Html
                textStyle.color: Color.create("#7e7e7e")
                textStyle.fontSizeValue: 5
                bottomMargin: 0
                topMargin: 0
            }
            attachedObjects: [
                LayoutUpdateHandler {
                    id: bodyDimensions
                }
            ]
            background: Color.White
            Label {
                translationX: 10
                bottomMargin: 10
                topMargin: 0
                id: commentBox
                text: "This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, I know that it's short...."
                multiline: true
                enabled: true
                textStyle.fontSizeValue: 6
                textStyle.color: Color.Black
                textStyle.base: lightStyle.style
                textFormat: TextFormat.Html
            }
            Divider {
                topMargin: 0
            }

        }

    }
}
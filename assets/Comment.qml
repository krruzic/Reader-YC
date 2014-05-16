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
    property string barColour: "#ff8e00"

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
            fontWeight: FontWeight.W300
        },
        LayoutUpdateHandler {
            id: mainDimensions
        },
        SystemToast {
            id: copyResultToast
            body: ""
        },
        ImagePaintDefinition {
            id: background
            imageSource: "asset:///images/commentBox.png.amd"
            repeatPattern: RepeatPattern.XY
        }
    ]

    function setHighlight(highlighted) {
        if (highlighted) {
            comment.background = background.imagePaint
        } else {
            comment.background = null
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

    function onCommentCopied(data) {
        copyResultToast.body = "Comment by " + data.poster + " copied!";
        copyResultToast.cancel();
        copyResultToast.show();
    }
    contextActions: [
        ActionSet {
            title: "Comment by " + ListItemData.poster
            InvokeActionItem {
                title: "Share Comment"
                query {
                    mimeType: "text/plain"
                    invokeActionId: "bb.action.SHARE"
                }
                enabled: (commentBox.text == "[deleted]") ? false : true
                onTriggered: {
                    var selectedItem = commentItem.ListItem.view.dataModel.data(commentItem.ListItem.indexPath);
                    data = 'Comment by ' + selectedItem.poster + '\n' + "https://news.ycombinator.com/item?id=" + selectedItem.link + "\nShared using Reader YC"
                }
            }
            ActionItem {
                id: replyAction
                title: "Reply to Comment"
                imageSource: "asset:///images/icons/ic_comments.png"
                enabled: false
                onTriggered: {
                    // insert new element into listview after selected item
                    // (Reply item)
                    var selectedItem = commentItem.ListItem.view.dataModel.data(commentItem.ListItem.indexPath);
                    if (selectedItem.link != "") {
                        Application.menuEnabled = false;
                        commentItem.ListItem.view.addComment(commmentContainer.ListItem.indexInSection, link, indent);
                    }
                }
            }
            ActionItem {
                id: copyAction
                title: "Copy Comment"
                imageSource: "asset:///images/icons/ic_copy.png"
                enabled: true
                onTriggered: {
                    var selectedItem = commentItem.ListItem.view.dataModel.data(commentItem.ListItem.indexPath);
                    Tart.send('copyComment', {
                            'comment': selectedItem.text,
                            'poster': selectedItem.poster
                        });
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

        //        Container {
        //            id: commentLine
        //            background: Color.create(barColour)
        //            horizontalAlignment: HorizontalAlignment.Fill
        //            minWidth: 6
        //            bottomMargin: 0
        //            topMargin: 0
        //            minHeight: bodyDimensions.layoutFrame.height
        //            visible: true
        //        }
        Container {
            //rightPadding: 10
            id: comment
            //background: Color.create("#ff5d5d5d")
            Container {
                background: Color.create(barColour)
                horizontalAlignment: HorizontalAlignment.Fill
                minHeight: 45
                layout: DockLayout {

                }
                rightPadding: 10
                leftPadding: 10
                Label {
                    id: posterLabel
                    horizontalAlignment: HorizontalAlignment.Left
                    text: ListItemData.poster
                    textStyle.base: lightStyle.style
                    textFormat: TextFormat.Html
                    textStyle.color: Color.White
                    textStyle.fontSize: FontSize.PointValue
                    textStyle.fontSizeValue: 7
                    bottomMargin: 0
                    topMargin: 0
                }
                Label {
                    textStyle.base: lightStyle.style
                    textFormat: TextFormat.Html
                    textStyle.color: Color.White
                    textStyle.fontSize: FontSize.PointValue
                    textStyle.fontSizeValue: 7
                    bottomMargin: 0
                    topMargin: 0
                    text: time
                    horizontalAlignment: HorizontalAlignment.Right
                }
            }
            attachedObjects: [
                LayoutUpdateHandler {
                    id: bodyDimensions
                }
            ]
            Container {
                rightPadding: 20
                leftPadding: 10
                Label {
                    bottomMargin: 10
                    topMargin: 0
                    id: commentBox
                    text: "This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, I know that it's short...."
                    multiline: true
                    enabled: true
                    //                textStyle.fontSizeValue: 6
                    //textStyle.color: Color.Black
                    textStyle.base: lightStyle.style
                    textFormat: TextFormat.Html
                }
            }
            Divider {
                topMargin: 0
            }

        }

    }
}
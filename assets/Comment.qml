import bb.cascades 1.2
import bb.system 1.2
import "tart.js" as Tart
import "global.js" as Global

Container {
    id: commmentContainer
    property string time: ""
    property alias indent: commmentContainer.leftPadding
    property alias text: commentBox.text
    property string link: ""
    property alias poster: posterLabel.text
    property bool textVisible: true
    property bool commentVisible: true
    property string barColour: "#f99925"

    horizontalAlignment: HorizontalAlignment.Fill
    leftPadding: indent
    onCreationCompleted: {
        Tart.register(commmentContainer);
        if (Global.username != "") {
            actionSet.add(replyAction);
        }

    }

    onContextMenuHandlerChanged: {
        if (link == "") {
            replyAction.enabled = false;
        }
    }

    attachedObjects: [
        ActionItem {
            id: replyAction
            title: "Reply to Comment"
            imageSource: "asset:///images/icons/ic_comments.png"
            enabled: true
            onTriggered: {
                // insert new element into listview after selected item
                // (Reply item)
                var selectedItem = commentItem.ListItem.view.dataModel.data(commentItem.ListItem.indexPath);
                if (selectedItem.link != "") {
                    Application.menuEnabled = false;
                    commentItem.ListItem.view.addComment(commmentContainer.ListItem.indexInSection, link, indent);
                }
            }
        },
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
        setHighlight(ListItem.selelicted);
    }

    function onContenttCopied(data) {
        copyResultToast.body = "Comment by " + data.meta.toString().split(" ")[0] + " copied!";
        copyResultToast.cancel();
        copyResultToast.show();
    }
    contextActions: [
        ActionSet {
            id: actionSet
            title: "Comment by " + ListItemData.poster.toString().split(" ")[0]
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
                id: copyAction
                title: "Copy Comment"
                imageSource: "asset:///images/icons/ic_copy.png"
                enabled: true
                onTriggered: {
                    var selectedItem = commentItem.ListItem.view.dataModel.data(commentItem.ListItem.indexPath);
                    Tart.send('copyHTML', {
                            'content': selectedItem.text,
                            'meta': selectedItem.poster
                        });
                }
            }
            ActionItem {
                id: hideAction
                title: "Hide Children"
                imageSource: "asset:///images/icons/ic_hide.png"
                enabled: true
                onTriggered: {
                    console.log(poster.toString().split(" ").pop());
                    if (poster.toString().split(" ").pop() != ("children)")) {
                        hideAction.title = "Show Children";
                        hideAction.imageSource = "asset:///images/icons/ic_showC.png";
                        console.log("hiding children");
                        commentItem.ListItem.view.hideChildren(commmentContainer.ListItem.indexInSection);
                    } else {
                        hideAction.title = "Hide Children";
                        hideAction.imageSource = "asset:///images/icons/ic_hide.png";
                        console.log("showing children");
                        commentItem.ListItem.view.showChildren(commmentContainer.ListItem.indexInSection);

                    }

                }

            }
        }
    ]
    Container {
        visible: ListItemData.visible
        topPadding: 10
        bottomPadding: 10
        leftPadding: 15
        rightPadding: 10
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }

        Container {
            //rightPadding: 10
            id: comment
            background: Color.create("#ffffff")
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
                rightPadding: 10
                leftPadding: 10
                Label {
                    visible: ListItemData.textVisible
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
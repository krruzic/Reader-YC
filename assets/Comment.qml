import bb.cascades 1.2
import bb.system 1.2
//import "tart.js" as Tart
Container {
    id: commmentContainer
    visible: true
    property string time: ""
    property alias indent: commmentContainer.leftPadding
    property alias text: commentBox.text
    property string op: ""
    horizontalAlignment: HorizontalAlignment.Fill
    leftPadding: indent
    onCreationCompleted: {
        Tart.register(commmentContainer);
        if (ListItemData.poster == op) {
            posterLabel.text = "<span style='color:#ff7900'>" + ListItemData.poster + "</span>" + "   " + time
        }
    }
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
            InvokeActionItem {
                title: "Share Comment"
                query {
                    mimeType: "text/plain"
                    invokeActionId: "bb.action.SHARE"
                }
                onTriggered: {
                    var selectedItem = commentItem.ListItem.view.dataModel.data(commentItem.ListItem.indexPath);
                    data = 'Comment by:  ' + selectedItem.poster + '\n' + selectedItem.link + "\nShared using Reader YC "
                }
            }
            ActionItem {
                title: "View user page"
                imageSource: "asset:///images/icons/ic_users.png"
                onTriggered: {
                    console.log("Pushing user page");
                    var selectedItem = commentItem.ListItem.view.dataModel.data(commentItem.ListItem.indexPath);
                    console.log(selectedItem.poster);
                    var page = commentItem.ListItem.view.pushPage('userPage');
                    page.username = selectedItem.poster;
                    page.searchText = selectedItem.poster;
                    page.busy = true;
                    Tart.send('requestPage', {
                            source: selectedItem.poster,
                            sentBy: 'userPage'
                        });
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
            background: Color.create("#ff7900")
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
                textFormat: TextFormat.Html
                enabled: true
                textStyle.fontSizeValue: 6
                textStyle.color: Color.Black
                textStyle.base: lightStyle.style
            }
            Divider {
                topMargin: 0
            }

        }

    }
}
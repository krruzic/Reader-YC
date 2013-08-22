import bb.cascades 1.0
import "tart.js" as Tart
Container {
    id: commmentContainer
    visible: true
    property alias poster: posterLabel.text
    property alias time: timeLabel.text
    property alias indent: commmentContainer.leftPadding
    property alias text: commentBox.text

    horizontalAlignment: HorizontalAlignment.Right
    leftPadding: indent
    rightPadding: 20
    topPadding: 5.0
    bottomPadding: 5.0
    onCreationCompleted: {
        Tart.register(commmentContainer);
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
                    data = 'Comment by:  ' + selectedItem.poster + '\n' + selectedItem.link + "\nShared using Reader|YC "
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
                    page.busy = true;
                    Tart.send('requestPage', {
                            source: selectedItem.poster,
                            sentBy: 'userPage'
                        });
                }
            }
            //            ActionItem {
            //                title: "Hide Children"
            //                onTriggered: {
            //                    var selectedItem = commentItem.ListItem.indexInSection;
            //                    commentItem.ListItem.view.hideChildren(selectedItem);
            //                }
            //            }
        }
    ]
    Container {
        leftPadding: 6
        background: commentBackground.imagePaint
        Container {
            rightPadding: 10
            leftPadding: 6
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            Label {
                id: posterLabel
                textStyle.fontSize: FontSize.XSmall
                text: "Madkristoff"
                horizontalAlignment: horizontalAlignment.Left
                textStyle.color: Color.Black
            }
            Divider {
                opacity: 0.0

            }
            Label {
                id: timeLabel
                textStyle.fontSize: FontSize.XSmall
                text: "4 minutes ago"
                horizontalAlignment: horizontalAlignment.Right
                textStyle.color: Color.Black
            }
        }
        Container {
            layout: AbsoluteLayout {

            }
            Divider {
                translationX: -5
            }
            TextArea {
                translationY: -12
                id: commentBox
                text: "This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, I know that it's short...."
                editable: false
                backgroundVisible: true
                inputMode: TextAreaInputMode.Text
                textFormat: TextFormat.Html
                focusHighlightEnabled: true
                enabled: true
                scrollMode: TextAreaScrollMode.Stiff
                input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
                textStyle.fontSize: FontSize.XSmall
                textStyle.color: Color.Black
                bottomPadding: 30
                maximumLength: 10000000
            }

        }
        attachedObjects: [
            ImagePaintDefinition {
                id: commentBackground
                imageSource: "asset:///images/CommentBackground.amd"
                repeatPattern: RepeatPattern.XY
            }
        ]
    }
}
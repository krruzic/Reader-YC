import bb.cascades 1.2
//import "tart.js" as Tart
Container {
    id: commmentContainer
    visible: true
    property string time: ""
    property alias indent: commmentContainer.leftPadding
    property alias text: commentBox.text

    horizontalAlignment: HorizontalAlignment.Fill
    leftPadding: indent
    //rightPadding: 20
    onCreationCompleted: {
        Tart.register(commmentContainer);
    }
    attachedObjects: [
        TextStyleDefinition {
            id: lightStyle
            base: SystemDefaults.TextStyles.BodyText
            fontSize: FontSize.PointValue
            fontSizeValue: 7
            rules: [
                FontFaceRule {
                    source: "asset:///SlatePro-Light.ttf"
                    fontFamily: "MyFontFamily"
                }
            ]
            fontFamily: "MyFontFamily, sans-serif"
        },
        LayoutUpdateHandler {
            id: mainDimensions
        }
    ]
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
        }
    ]
    Container {
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }

        Container {
            background: Color.create("#ff7900")
            horizontalAlignment: HorizontalAlignment.Fill
            minWidth: 6
            bottomMargin: 0
            topMargin: 0
            minHeight: bodyDimensions.layoutFrame.height
        }
        Container {
            //leftPadding: 6
            Label {
                id: posterLabel
                translationX: 10
                text: ListItemData.poster + " | " + time
                textStyle.base: lightStyle.style
                textFormat: TextFormat.Html
                textStyle.color: Color.create("#7e7e7e")
                bottomMargin: 0
                topMargin: 0
            }
            attachedObjects: [
                LayoutUpdateHandler {
                    id: bodyDimensions
                }
            ]
            background: Color.White
            TextArea {
                bottomMargin: 0
                topMargin: 0
                id: commentBox
                text: "This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, I know that it's short...."
                editable: false
                backgroundVisible: true
                textFormat: TextFormat.Html
                focusHighlightEnabled: true
                enabled: true
                scrollMode: TextAreaScrollMode.Stiff
                input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
                textStyle.fontSizeValue: 6
                textStyle.color: Color.Black
                maximumLength: 10000000
                textStyle.base: lightStyle.style
            }
            Divider {
                topMargin: 0
            }
        }
    }
}
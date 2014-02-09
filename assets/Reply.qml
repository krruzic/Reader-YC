import bb.cascades 1.2
//import "tart.js" as Tart
import "global.js" as Global
Container {
    id: submitItem
    property string link: ""
    property alias text: commentText.text
    onCreationCompleted: {
        Tart.register(submitItem)
    }
    background: Color.White
    leftPadding: 10
    rightPadding: 10
    topPadding: 10
    attachedObjects: [
        TextStyleDefinition {
            id: lightStyle
            base: SystemDefaults.TextStyles.BodyText
            fontSize: FontSize.PointValue
            fontSizeValue: 7
            fontWeight: FontWeight.W100
        },
        ImagePaintDefinition {
            imageSource: "asset:///images/text.amd"
            id: background
        }
    ]

    Container {
        background: background.imagePaint

        TextArea {
            onCreationCompleted: {
                focused:
                true;
            }
            autoSize.maxLineCount: 10
            backgroundVisible: false
            enabled: true
            editable: true
            text: ""
            id: commentText
            verticalAlignment: VerticalAlignment.Fill
            hintText: "text surrounded by asterisks will be italized"

            onTextChanging: {
                if (text == "") {
                    replyButton.enabled = false;
                } else {
                    replyButton.enabled = true;
                }
            }
        }
    }
    Label {
        text: "Posting as: " + Global.username
        bottomMargin: 0
        topMargin: 0
        textStyle.base: lightStyle.style
    }
    Container {
        bottomPadding: 10
        topPadding: 10
        horizontalAlignment: HorizontalAlignment.Right
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }
        Button {
            id: replyButton
            enabled: false
            maxWidth: 100
            horizontalAlignment: HorizontalAlignment.Right
            rightMargin: 10
            imageSource: "asset:///images/icons/ic_comments_dk.png"
            onClicked: {
                enabled = false;
                Tart.send('sendComment', {
                        source: link,
                        text: commentText.text
                    });
            }
        }
        Button {
            maxWidth: 100
            imageSource: "asset:///images/icons/ic_cancel_dk.png"
            onClicked: {
                commentText.text = "";
                replyItem.ListItem.view.cancelComment(submitItem.ListItem.indexInSection)
            }
        }
    }
}

import bb.cascades 1.2
import bb.system 1.2
import "tart.js" as Tart
import "global.js" as Global
Container {
    id: submitItem
    property string link: ""
    property alias text: commentText.text
    onCreationCompleted: {
        Tart.register(submitItem)
    }

    function onCommentPosted(data) {
        console.log("comment posted!!");
        console.log(data.result);
        replyItem.ListItem.view.updateComment(data.result);
        if (data.result == "true") {
            commentToast.body = "Comment posted!";
            lastItemType = 'item';
        } else {
            commentToast.body = "Posting comment failed!";
            console.log("Error sending comment!")
        }
        commentToast.cancel();
        commentToast.show();
        replyButton.enabled = true;
    }

    background: Color.White
    leftPadding: 10
    rightPadding: 10
    topPadding: 10
    attachedObjects: [
        SystemToast {
            id: commentToast
            body: "COMMENT"
        },
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
            hintText: "Enter your comment"

            onTextChanging: {
                if (text == "") {
                    replyButton.enabled = false;
                } else {
                    replyButton.enabled = true;
                }
            }
        }
    }
    Container {
        horizontalAlignment: HorizontalAlignment.Right
        id: helpContainer
        visible: false
        Label {
            textStyle.textAlign: TextAlign.Right
            text: "Text surrounded by asterisks will be italicized"
            bottomMargin: 0
            topMargin: 0
            textStyle.base: lightStyle.style
            textStyle.fontStyle: FontStyle.Italic
        }
        Label {
            textStyle.textAlign: TextAlign.Right
            text: "Posting as: " + "<span style='color:#ff7900'>" + Global.username + "</span>"
            bottomMargin: 0
            topMargin: 0
            textStyle.base: lightStyle.style
            textFormat: TextFormat.Html
            textStyle.fontStyle: FontStyle.Italic
        }
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
            id: helpButton
            enabled: true
            maxWidth: 100
            horizontalAlignment: HorizontalAlignment.Right
            rightMargin: 10
            imageSource: "asset:///images/icons/ic_help_dk.png"
            onClicked: {
                if (helpContainer.visible) {
                    helpContainer.visible = false;
                } else {
                    helpContainer.visible = true;
                }
            }
        }
        Button {
            maxWidth: 100
            imageSource: "asset:///images/icons/ic_cancel_dk.png"
            onClicked: {
                Application.menuEnabled = true;
                helpContainer.visible = false;
                commentText.text = "";
                replyItem.ListItem.view.cancelComment(submitItem.ListItem.indexInSection)
            }
        }
    }
}

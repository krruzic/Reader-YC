import bb.cascades 1.2

Container {
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
            autoSize.maxLineCount: 10
            textStyle.base: lightStyle.style
            backgroundVisible: false
            enabled: false
            id: commentText
            verticalAlignment: VerticalAlignment.Fill
        }
    }
    Container {
        topPadding: 10
        horizontalAlignment: HorizontalAlignment.Right
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }
        Button {
            onTextChanged: {
                if (text != "") {
                    enabled = true;
                }
            }
            enabled: false;
            maxWidth: 200
            horizontalAlignment: HorizontalAlignment.Right
            rightMargin: 10
            text: "Reply"
            imageSource: "asset:///images/icons/ic_comments_dk.png"
        }
        Button {
            
            maxWidth: 200
            
            text: "Cancel"
            imageSource: "asset:///images/icons/ic_cancel_dk.png"
            onClicked: {
                
            }
        }
    }
}

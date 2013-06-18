import bb.cascades 1.0

Container {
    property alias text: count.text
    property alias normal: addButton.defaultImageSource
    property alias pressed: addButton.pressedImageSource
    id: account
    signal buttonClicked()
    layout: AbsoluteLayout {}
    ImageButton {
        id: addButton
        defaultImageSource: "images/Comment.png"
        pressedImageSource: "images/Comment.png"
        onClicked: {
            buttonClicked();
        }
    }
    Label {
        id: count
        text: ""
        textStyle.textAlign: TextAlign.Center
        minWidth: 74.0
        textStyle {
            base: SystemDefaults.TextStyles.BodyText
            fontSize: FontSize.XXSmall
            color: Color.White
            }
        touchPropagationMode: TouchPropagationMode.None
        layoutProperties: AbsoluteLayoutProperties {
            positionY: 4.0
        }
    }
}

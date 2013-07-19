import bb.cascades 1.0

Container {
    property alias text: buttonText.text
    property alias normal: addButton.defaultImageSource
    property alias pressed: addButton.pressedImageSource
    property variant textSize: FontSize.XXSmall
    id: account
    layout: DockLayout {}
    signal buttonClicked()
    ImageButton {
        id: addButton
        defaultImageSource: "images/Comment.png"
        pressedImageSource: "images/Comment.png"
        onClicked: {
            buttonClicked();
        }
        horizontalAlignment: HorizontalAlignment.Center
        verticalAlignment: VerticalAlignment.Center
    }
    Label {
        id: buttonText
        text: "9999"
        textStyle.textAlign: TextAlign.Center
        textStyle.fontSize: textSize
        textStyle {
            base: SystemDefaults.TextStyles.BodyText
            color: Color.White
            }
        touchPropagationMode: TouchPropagationMode.None
        verticalAlignment: VerticalAlignment.Center
        horizontalAlignment: HorizontalAlignment.Center
        translationX: 0.0
        translationY: -11.0

    }
}

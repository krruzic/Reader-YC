import bb.cascades 1.0

Container {
    property alias text: pageTitle.text
    property alias refreshEnabled: refreshButton.enabled
    property alias showButton: refreshButton.visible
    property alias buttonImage: refreshButton.defaultImageSource
    property alias buttonPressedImage: refreshButton.pressedImageSource
    minHeight: 120
    maxHeight: 120
    background: Color.create("#fffe8515")
    signal refreshPage()
    Container {
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        
        }
        topPadding: 20.0
        leftPadding: 0.0
        ScrollView {
            scrollViewProperties.scrollMode: ScrollMode.Horizontal
            scrollViewProperties.pinchToZoomEnabled: false
            scrollViewProperties.overScrollEffectMode: OverScrollEffectMode.OnScroll
            TextArea  {
                id: pageTitle
                text: "Reader|YC - Top Posts"
                textStyle.fontSize: FontSize.PointValue
                textStyle.textAlign: TextAlign.Left
                textStyle.color: Color.White
                textFormat: TextFormat.Plain
                enabled: false
                editable: false
                focusHighlightEnabled: false
                translationY: -10
                maximumLength: 1000
                input.masking: TextInputMasking.Default
                input.submitKey: SubmitKey.None
                textStyle.fontSizeValue: 10.0
            }
        }
        ImageButton {
            id: refreshButton
            translationX: -30
            defaultImageSource: "asset:///images/refresh.png"
            pressedImageSource: "asset:///images/refresh.png"
            onClicked: {
                refreshPage();
            }
        }
    }
}

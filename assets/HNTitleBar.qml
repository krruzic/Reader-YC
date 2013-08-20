import bb.cascades 1.0

Container {
    layout: DockLayout {
    }
    property alias text: pageTitle.text
    property alias refreshEnabled: refreshButton.enabled
    property alias showButton: refreshButton.visible
    property alias buttonImage: refreshButton.defaultImageSource
    property alias buttonPressedImage: refreshButton.pressedImageSource
    minHeight: 114
    maxHeight: 114
    background: background.imagePaint
    signal refreshPage()
    Container {
        topPadding: 20
        leftPadding: 10
        rightPadding: 20
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }
        Container {
            topPadding: 6
            ScrollView {
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 5
                }
                minWidth: 620
                maxWidth: 620
                horizontalAlignment: horizontalAlignment.Left
                scrollViewProperties.scrollMode: ScrollMode.Horizontal
                scrollViewProperties.pinchToZoomEnabled: false
                scrollViewProperties.overScrollEffectMode: OverScrollEffectMode.OnScroll
                Label {
                    id: pageTitle
                    text: "Reader|YC - Top Posts"
                    textStyle.fontSize: FontSize.PointValue
                    textStyle.textAlign: TextAlign.Left
                    textStyle.color: Color.White
                    textFormat: TextFormat.Plain
                    enabled: false
                    textStyle.fontSizeValue: 9.0
                }
            }
        }
        Divider {
            opacity: 0
        }
        ImageButton {
            translationY: -6
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1
            }
            horizontalAlignment: horizontalAlignment.Right
            id: refreshButton
            defaultImageSource: "asset:///images/refresh.png"
            pressedImageSource: "asset:///images/refresh.png"
            onClicked: {
                refreshPage();
            }
            minWidth: 86
            minHeight: 79
            maxWidth: 86
            maxHeight: 79

        }
        attachedObjects: [
            ImagePaintDefinition {
                id: background
                imageSource: "asset:///images/titlebar.png"
            }
        ]
    }
}

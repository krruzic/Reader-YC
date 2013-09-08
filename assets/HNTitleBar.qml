import bb.cascades 1.0

TitleBar {
    property alias text: pageTitle.text
    property alias refreshEnabled: refreshButton.enabled
    property alias showButton: refreshButton.visible
    property alias buttonImage: refreshButton.defaultImageSource
    property alias buttonPressedImage: refreshButton.pressedImageSource
    property variant listName: null
    signal refreshPage()
    kind: TitleBarKind.FreeForm
    scrollBehavior: TitleBarScrollBehavior.Sticky
    kindProperties: FreeFormTitleBarKindProperties {

        Container {
            id: topcontainer

            background: background.imagePaint
            horizontalAlignment: HorizontalAlignment.Fill
            //verticalAlignment: VerticalAlignment.Top
            
            gestureHandlers: [
                DoubleTapHandler {
                    onDoubleTapped: {
                        if (listName) {
                            listName.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
                        } else {
                            return;
                        }
                    }
                }
            ]
            Container { // Header
                id: titleContainer
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                //topPadding: 30
                leftPadding: 15
                //rightPadding: 15
                Container {
                    verticalAlignment: VerticalAlignment.Center
                    minWidth: 600
                    maxWidth: 600
                    ScrollView {
                        verticalAlignment: verticalAlignment.Center
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
                Container {
                    leftMargin: 35
                    topPadding: 10
                    verticalAlignment: VerticalAlignment.Center
                    horizontalAlignment: horizontalAlignment.Right

                    ImageButton {
                        id: refreshButton
                        enabled: false
                        horizontalAlignment: horizontalAlignment.Right
                        defaultImageSource: "asset:///images/refresh.png"
                        pressedImageSource: "asset:///images/refresh.png"
                        onClicked: {
                            refreshPage();
                        }
                    }
//                    minWidth: 86
//                    minHeight: 79
//                    maxWidth: 86
//                    maxHeight: 79

                }
                attachedObjects: [
                    ImagePaintDefinition {
                        id: background
                        imageSource: "asset:///images/titlebar.png"
                    }
                ]
            }
        }
    }
}
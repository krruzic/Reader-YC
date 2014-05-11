import bb.cascades 1.2

TitleBar {
    property alias text: pageTitle.text
    property alias refreshEnabled: refreshButton.enabled
    property alias showButton: refreshButton.visible
    property alias buttonImage: refreshButton.imageSource
    //    /property alias buttonPressedImage: refreshButton.pressedImageSource
    property variant listName: null
    signal refreshPage()
    kind: TitleBarKind.FreeForm
    scrollBehavior: TitleBarScrollBehavior.Sticky
    kindProperties: FreeFormTitleBarKindProperties {

        Container {
            attachedObjects: [
                TextStyleDefinition {
                    id: lightStyle
                    base: SystemDefaults.TextStyles.BodyText
                    fontSize: FontSize.PointValue
                    fontSizeValue: 7
                    fontWeight: FontWeight.W300
                },
                LayoutUpdateHandler {
                    id: mainDimensions
                }
            ]
            id: topcontainer
            layout: DockLayout {
                //orientation: LayoutOrientation.LeftToRight
            }

            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Center
            //topPadding: 15

            gestureHandlers: [
                DoubleTapHandler {
                    onDoubleTapped: {
                        if (listName) {
                            console.log("GESTURE TRIGGERED!");
                            if (listName.toString().indexOf("QmlScrollView") == -1) { // Checks if the object is a lsitview/scrollview
                                listName.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.None);
                            } else {
                                listName.scrollToPoint(0, 0, ScrollAnimation.None);
                            }
                        } else {
                            return;
                        }
                    }
                }
            ]
            background: Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark ? "" : background.imagePaint
            Container {
                leftPadding: 15
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Fill
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                ScrollView {
                    scrollRole: ScrollRole.None
                    verticalAlignment: VerticalAlignment.Center
                    horizontalAlignment: HorizontalAlignment.Fill
                    scrollViewProperties.scrollMode: ScrollMode.Horizontal
                    scrollViewProperties.pinchToZoomEnabled: false
                    scrollViewProperties.overScrollEffectMode: OverScrollEffectMode.OnScroll
                    Label {
                        id: pageTitle
                        text: "Reader YC - Top Postsgk jgjhgkjgk jgk jjkkgj kgj kgj "
                        //textStyle.base: SystemDefaults.TextStyles.BigText
                        textStyle.fontSize: FontSize.PointValue
                        textStyle.textAlign: TextAlign.Left
                        textStyle.color: Color.White
                        textFormat: TextFormat.Plain
                        enabled: false
                        textStyle.fontSizeValue: 8
                        textStyle.base: lightStyle.style
                    }
                }

                Container {
                    leftPadding: 10
                    leftMargin: 20
                    rightPadding: 20
                    verticalAlignment: VerticalAlignment.Center
                    horizontalAlignment: HorizontalAlignment.Right
                    visible: true
                    ImageView {
                        id: refreshButton
                        enabled: true
                        visible: enabled
                        imageSource: "asset:///images/refresh.png"
                        scalingMethod: ScalingMethod.AspectFit
                        gestureHandlers: [
                            TapHandler {
                                onTapped: {
                                    if (refreshButton.enabled)
                                        refreshPage();
                                }
                            }
                        ]
                    }
                }


            }
            //                ImageButton {
            //                    id: refreshButton
            //                    enabled: false
            //
            //                    defaultImageSource: "asset:///images/refresh.png"
            //                    pressedImageSource: "asset:///images/refresh.png"
            //                    onClicked: {
            //                        refreshPage();
            //                    }
            //                }
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

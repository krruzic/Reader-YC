import bb.cascades 1.2

TitleBar {
    property alias text: pageTitle.text
    property alias refreshEnabled: refreshButton.enabled
    property alias showButton: refreshButton.visible
    property variant listName: null
    signal refreshPage()
    kind: TitleBarKind.FreeForm
    scrollBehavior: TitleBarScrollBehavior.Sticky
    appearance: TitleBarAppearance.Plain
    kindProperties: FreeFormTitleBarKindProperties {

        Container {
            //opacity: 0.7
            attachedObjects: [
                TextStyleDefinition {
                    id: lightStyle
                    base: SystemDefaults.TextStyles.BodyText
                    fontSize: FontSize.PointValue
                    fontSizeValue: 7
                    fontWeight: FontWeight.W500
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
            verticalAlignment: VerticalAlignment.Fill
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
            background: Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark ? Color.create("#ff333333") : Color.create("#fff9f9f9")
            Container {
                leftPadding: 15
                //rightPadding: 15
                verticalAlignment: VerticalAlignment.Fill
                horizontalAlignment: HorizontalAlignment.Fill
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }

                ScrollView {
                    rightMargin: 10
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 12
                    }
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
                        textStyle.color: Color.create("#ff8e00")
                        textFormat: TextFormat.Plain
                        enabled: false
                        textStyle.fontSizeValue: 8
                        textStyle.base: lightStyle.style
                    }
                    accessibility.name: pageTitle.text

                }

                Container {
                    rightMargin: 0
                    leftMargin: 0
                    topMargin: 0
                    bottomMargin: 0
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 4

                    }
                    topPadding: 15
                    bottomPadding: 15
                    id: refreshButton
                    visible: refreshEnabled

                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    verticalAlignment: VerticalAlignment.Fill
                    horizontalAlignment: HorizontalAlignment.Fill

                    onTouch: {
                        refreshPage();
                    }
                    Divider {
                        horizontalAlignment: HorizontalAlignment.Left
                        verticalAlignment: VerticalAlignment.Center
                        rotationZ: 90
                        rightMargin: 0
                        leftMargin: 0
                        topMargin: 0
                        bottomMargin: 0
                        maxHeight: 5

                        //                    maxWidth: 5
                        //                        rightPadding: 10
                        //                        topPadding: 10
                        //                        bottomPadding: 10
                    }
                    Label {
                        text: "Refresh"
                        translationX: -30
                        verticalAlignment: VerticalAlignment.Center
                        horizontalAlignment: HorizontalAlignment.Center
                        //textStyle.base: SystemDefaults.TextStyles.BigText
                        textStyle.fontSize: FontSize.PointValue
                        textStyle.textAlign: TextAlign.Left
                        textStyle.color: Color.create("#ff8e00")
                        textFormat: TextFormat.Plain
                        enabled: false
                        textStyle.fontSizeValue: 6
                        textStyle.base: lightStyle.style

                    }
                }
            }

        }

    }
}

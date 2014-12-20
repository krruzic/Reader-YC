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
            topPadding: 15
            bottomPadding: 15

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
                verticalAlignment: VerticalAlignment.Fill
                horizontalAlignment: HorizontalAlignment.Fill
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                Container {
                    rightPadding: 10
                    leftPadding: 10
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 5
                    }
                    horizontalAlignment: HorizontalAlignment.Left
                    verticalAlignment: VerticalAlignment.Center
                    ScrollView {
                        rightMargin: 100
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
                            textStyle.color: Color.create("#f99925")
                            textFormat: TextFormat.Plain
                            enabled: false
                            textStyle.fontSizeValue: 8
                            textStyle.base: lightStyle.style
                        }
                        accessibility.name: pageTitle.text

                    }
                }
                Container {
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    id: refreshButton
                    visible: refreshEnabled
                    verticalAlignment: VerticalAlignment.Center
                    horizontalAlignment: HorizontalAlignment.Center

                    onTouch: {
                        refreshPage();
                    }
                    layout: DockLayout {
                    }
                    Container {
                        verticalAlignment: VerticalAlignment.Center
                        horizontalAlignment: HorizontalAlignment.Left
                        minWidth: 1
                        maxWidth: 1
                        background: Color.LightGray
                        minHeight: 100
                        rightMargin: 0
                        leftMargin: 0
                    }
                    Label {
                        rightMargin: 0
                        leftMargin: 0
                        text: "Refresh"
                        verticalAlignment: VerticalAlignment.Center
                        horizontalAlignment: HorizontalAlignment.Center
                        //textStyle.base: SystemDefaults.TextStyles.BigText
                        textStyle.fontSize: FontSize.PointValue
                        textStyle.textAlign: TextAlign.Center
                        textStyle.color: Color.create("#f99925")
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

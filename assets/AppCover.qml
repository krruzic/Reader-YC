import bb.cascades 1.2
import "tart.js" as Tart

SceneCover {

    attachedObjects: [
        TextStyleDefinition {
            id: lightStyle
            base: SystemDefaults.TextStyles.BodyText
            fontSize: FontSize.PointValue
            fontSizeValue: 7
            fontWeight: FontWeight.W300
        },
        ImagePaintDefinition {
            id: background
            imageSource: "asset:///images/coverBackground.png"
        }
    ]

    id: cover
    content: Container {
        background: background.imagePaint
        minHeight: 396
        minWidth: 334
        maxHeight: 396
        maxWidth: 334
        layout: StackLayout {

        }

        Container {
            leftPadding: 10
            rightPadding: 10
            minWidth: 334
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            Container {
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 2
                }
            }
            Label {
                id: titleLabel
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                textStyle.base: lightStyle.style
                text: root.coverTitle
                textStyle.fontSize: FontSize.PointValue
                textStyle.textAlign: TextAlign.Left
                textStyle.color: Color.White
                textFormat: TextFormat.Plain
                multiline: true
                textStyle.fontSizeValue: 6.0
                autoSize.maxLineCount: 3
            }
        }
        Container {
            bottomPadding: 15
            leftPadding: 10
            rightPadding: 10
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Bottom
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            Label {
                textStyle.base: lightStyle.style
                id: posterLabel
                text: root.coverPoster
                textStyle.fontSize: FontSize.PointValue
                textStyle.textAlign: TextAlign.Center
                textStyle.color: Color.White
                textFormat: TextFormat.Plain
                textStyle.fontSizeValue: 5.0

            }
            Divider {
                opacity: 0
            }
            Label {
                textStyle.base: lightStyle.style
                id: commentLabel
                text: root.coverComments
                textStyle.fontSize: FontSize.PointValue
                textStyle.textAlign: TextAlign.Center
                textStyle.color: Color.White
                textFormat: TextFormat.Plain
                textStyle.fontSizeValue: 5.0
            }
        }
    }
    //        Container {
    //            topMargin: 20
    //            bottomMargin: 20
    //            layout: DockLayout {
    //            }
    //            minHeight: 62
    //            maxHeight: 62
    //            background: header.imagePaint
    //            Container {
    //                topPadding: 10
    //                leftPadding: 10
    //                rightPadding: 20
    //                layout: StackLayout {
    //                    orientation: LayoutOrientation.LeftToRight
    //                }
    //                Container {
    //                    layoutProperties: StackLayoutProperties {
    //                        spaceQuota: 5
    //                    }
    //                    horizontalAlignment: horizontalAlignment.Left
    //                    Label {
    //                        id: pageTitle
    //                        text: "Reader YC"
    //                        textStyle.fontSize: FontSize.PointValue
    //                        textStyle.textAlign: TextAlign.Left
    //                        textStyle.color: Color.White
    //                        textFormat: TextFormat.Plain
    //                        enabled: false
    //                        textStyle.fontSizeValue: 6.0
    //                    }
    //                }
    //            }
    //        }
    //        Container {
    //            topMargin: 10
    //            bottomMargin: 10
    //            leftPadding: 10
    //            rightPadding: 10
    //            verticalAlignment: VerticalAlignment.Center
    //            horizontalAlignment: HorizontalAlignment.Center
    //            Label {
    //                id: titleLabel
    //                horizontalAlignment: horizontalAlignment.Center
    //                text: root.coverTitle
    //                textStyle.fontSize: FontSize.PointValue
    //                textStyle.textAlign: TextAlign.Center
    //                textStyle.color: Color.DarkGray
    //                textFormat: TextFormat.Plain
    //                textStyle.fontStyle: FontStyle.Italic
    //                multiline: true
    //                textStyle.fontSizeValue: 7.0
    //                autoSize.maxLineCount: 3
    //            }
    //            Divider {
    //                horizontalAlignment: horizontalAlignment.Center
    //                maxWidth: 320
    //            }
    //        }
    //        Container {
    //            leftPadding: 10
    //            rightPadding: 10
    //            maxWidth: 320
    //            minWidth: 320
    //            verticalAlignment: VerticalAlignment.Bottom
    //            horizontalAlignment: HorizontalAlignment.Center
    //            layout: StackLayout {
    //                orientation: LayoutOrientation.LeftToRight
    //            }
    //            Container {
    //                layoutProperties: StackLayoutProperties {
    //                    spaceQuota: 1
    //                }
    //                topMargin: 0
    //                bottomMargin: 0
    //                Label {
    //                    topMargin: 0
    //                    bottomMargin: 0
    //                    id: posterLabel
    //                    text: root.coverPoster
    //                    textStyle.fontSize: FontSize.PointValue
    //                    textStyle.textAlign: TextAlign.Center
    //                    textStyle.color: Color.DarkGray
    //                    textFormat: TextFormat.Plain
    //                    textStyle.fontStyle: FontStyle.Italic
    //                    textStyle.fontSizeValue: 6.0
    //                }
    //                Label {
    //                    topMargin: 0
    //                    bottomMargin: 0
    //                    id: commentLabel
    //                    text: root.coverComments
    //                    textStyle.fontSize: FontSize.PointValue
    //                    textStyle.color: Color.DarkGray
    //                    textStyle.textAlign: TextAlign.Center
    //                    textFormat: TextFormat.Plain
    //                    textStyle.fontSizeValue: 4.0
    //                }
    //            }
    //
    //            Container {
    //                layoutProperties: StackLayoutProperties {
    //                    spaceQuota: 2
    //                }
    //                maxHeight: 100
    //                minHeight: 100
    //                maxWidth: 2
    //                minWidth: 2
    //                background: Color.LightGray
    //                rightMargin: 20
    //                visible: if (commentLabel.text != "") {
    //                    true;
    //                } else {
    //                    false;
    //                }
    //            }
    //            Container {
    //                layoutProperties: StackLayoutProperties {
    //                    spaceQuota: 1
    //                }
    //                horizontalAlignment: HorizontalAlignment.Center
    //                topMargin: 0
    //                bottomMargin: 0
    //                Label {
    //                    id: pointsLabel
    //                    text: root.coverPoints
    //                    textStyle.fontSize: FontSize.PointValue
    //                    textStyle.textAlign: TextAlign.Center
    //                    textStyle.color: Color.DarkGray
    //                    textFormat: TextFormat.Plain
    //                    textStyle.fontStyle: FontStyle.Italic
    //                    textStyle.fontSizeValue: 6.0
    //                    topMargin: 0
    //                    bottomMargin: 0
    //                }
    //                Label {
    //                    id: timeLabel
    //                    text: root.coverTime
    //                    textStyle.fontSize: FontSize.PointValue
    //                    textStyle.color: Color.DarkGray
    //                    textFormat: TextFormat.Plain
    //                    textStyle.fontStyle: FontStyle.Italic
    //                    textStyle.textAlign: TextAlign.Center
    //                    textStyle.fontSizeValue: 4.0
    //                    topMargin: 0
    //                    bottomMargin: 0
    //                }
    //            }
    //        }
}

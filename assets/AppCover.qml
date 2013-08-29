import bb.cascades 1.0
import "tart.js" as Tart

SceneCover {
    attachedObjects: [
        ImagePaintDefinition {
            id: background
            imageSource: "asset:///images/titlebar.png"
        }
    ]

    id: cover

    content: Container {
        maxHeight: 360
        maxWidth: 300
        minHeight: 360
        minWidth: 300

        Container {
            topMargin: 20
            bottomMargin: 20
            layout: DockLayout {
            }
            minHeight: 60
            maxHeight: 60
            background: background.imagePaint
            Container {
                topPadding: 10
                leftPadding: 10
                rightPadding: 20
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                Container {
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 5
                    }
                    horizontalAlignment: horizontalAlignment.Left
                    Label {
                        id: pageTitle
                        text: "Reader|YC"
                        textStyle.fontSize: FontSize.PointValue
                        textStyle.textAlign: TextAlign.Left
                        textStyle.color: Color.White
                        textFormat: TextFormat.Plain
                        enabled: false
                        textStyle.fontSizeValue: 6.0
                    }
                }
            }
        }
        Container {
            topMargin: 10
            bottomMargin: 10
            leftPadding: 10
            rightPadding: 10
            verticalAlignment: VerticalAlignment.Center
            horizontalAlignment: HorizontalAlignment.Center
            Label {
                id: titleLabel
                text: root.coverTitle
                verticalAlignment: VerticalAlignment.Top
                horizontalAlignment: HorizontalAlignment.Center
                textStyle.fontSize: FontSize.PointValue
                textStyle.textAlign: TextAlign.Center
                textStyle.color: Color.DarkGray
                textFormat: TextFormat.Plain
                textStyle.fontStyle: FontStyle.Italic
                multiline: true
                textStyle.fontSizeValue: 7.0
                autoSize.maxLineCount: 2
            }
            Divider {
                maxWidth: 320
            }
        }
        Container {
            leftPadding: 10
            rightPadding: 10
            maxWidth: 320
            minWidth: 320
            verticalAlignment: VerticalAlignment.Bottom
            horizontalAlignment: HorizontalAlignment.Center
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            Container {
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                topMargin: 0
                bottomMargin: 0
                Label {
                    topMargin: 0
                    bottomMargin: 0
                    id: posterLabel
                    text: root.coverPoster
                    textStyle.fontSize: FontSize.PointValue
                    textStyle.textAlign: TextAlign.Center
                    textStyle.color: Color.DarkGray
                    textFormat: TextFormat.Plain
                    textStyle.fontStyle: FontStyle.Italic
                    textStyle.fontSizeValue: 6.0
                }
                Label {
                    topMargin: 0
                    bottomMargin: 0
                    id: commentLabel
                    text: root.coverComments
                    textStyle.fontSize: FontSize.PointValue
                    textStyle.color: Color.DarkGray
                    textStyle.textAlign: TextAlign.Center
                    textFormat: TextFormat.Plain
                    textStyle.fontSizeValue: 4.0
                }
            }

            Container {
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 2
                }
                maxHeight: 100
                minHeight: 100
                maxWidth: 2
                minWidth: 2
                background: Color.LightGray
                rightMargin: 20
                visible: if (commentLabel.text != "") {
                    true;
                } else {
                    false;
                }
            }
            Container {
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                horizontalAlignment: HorizontalAlignment.Center
                topMargin: 0
                bottomMargin: 0
                Label {
                    id: pointsLabel
                    text: root.coverPoints
                    textStyle.fontSize: FontSize.PointValue
                    textStyle.textAlign: TextAlign.Center
                    textStyle.color: Color.DarkGray
                    textFormat: TextFormat.Plain
                    textStyle.fontStyle: FontStyle.Italic
                    textStyle.fontSizeValue: 6.0
                    topMargin: 0
                    bottomMargin: 0
                }
                Label {
                    id: timeLabel
                    text: root.coverTime
                    textStyle.fontSize: FontSize.PointValue
                    textStyle.color: Color.DarkGray
                    textFormat: TextFormat.Plain
                    textStyle.fontStyle: FontStyle.Italic
                    textStyle.textAlign: TextAlign.Center
                    textStyle.fontSizeValue: 4.0
                    topMargin: 0
                    bottomMargin: 0
                }
            }
        }
    }
}
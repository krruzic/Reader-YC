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
        Container {
            topMargin: 20
            bottomMargin: 20
            layout: DockLayout {
            }
            minHeight: 56
            maxHeight: 56
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
        }
    }
}
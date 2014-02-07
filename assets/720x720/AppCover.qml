import bb.cascades 1.2
import "tart.js" as Tart

SceneCover {
    attachedObjects: [
        ImagePaintDefinition {
            id: header
            imageSource: "asset:///images/titlebar.png"
        },
        ImagePaintDefinition {
            id: background
            imageSource: "asset:///images/coverBackgroundSmall.png"
        }
    ]

    id: cover

    content: Container {
        background: background.imagePaint
        minHeight: 211
        minWidth: 310
        maxHeight: 211
        maxWidth: 310
        horizontalAlignment: HorizontalAlignment.Center
        verticalAlignment:VerticalAlignment.Center
        layout: StackLayout {

        }
        Container {
            leftPadding: 10
            rightPadding: 10
            minWidth: 310
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            Label {
                id: titleLabel
                text: root.coverTitle
                textStyle.fontSize: FontSize.PointValue
                textStyle.textAlign: TextAlign.Left
                textStyle.color: Color.White
                textFormat: TextFormat.Plain
                textStyle.fontStyle: FontStyle.Italic
                multiline: true
                textStyle.fontSizeValue: 8.0
                autoSize.maxLineCount: 3
            }
        }
        Container {
            leftPadding: 10
            rightPadding: 10
            bottomPadding: 15
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Bottom
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            Label {
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
}
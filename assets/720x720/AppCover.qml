import bb.cascades 1.0
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
        layout: StackLayout {

        }
        Container {
            leftPadding: 10
            rightPadding: 10
            topPadding: 20
            minWidth: 314
            horizontalAlignment: horizontalAlignment.Center
            verticalAlignment: verticalAlignment.Center
            Label {
                id: titleLabel
                minWidth: 290
                text: root.coverTitle
                textStyle.fontSize: FontSize.PointValue
                textStyle.textAlign: TextAlign.Left
                textStyle.color: Color.White
                textFormat: TextFormat.Plain
                textStyle.fontStyle: FontStyle.Italic
                multiline: true
                textStyle.fontSizeValue: 6.0
                autoSize.maxLineCount: 3
            }
        }
    }
}
import bb.cascades 1.2
import "tart.js" as Tart

SceneCover {
    attachedObjects: [
        TextStyleDefinition {
            id: lightStyle
            base: SystemDefaults.TextStyles.BodyText
            fontSize: FontSize.PointValue
            fontSizeValue: 7
            fontWeight: FontWeight.W100
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
        layout: DockLayout {

        }
        Container {
            topPadding: 120
            leftPadding: 10
            rightPadding: 10
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Top
            layout: DockLayout {
            }
            Label {
                id: titleLabel
                text: root.coverTitle
                textStyle.base: lightStyle.style
                textStyle.fontSize: FontSize.PointValue
                textStyle.textAlign: TextAlign.Left
                textStyle.color: Color.White
                textFormat: TextFormat.Plain
                multiline: true
                textStyle.fontSizeValue: 6.0
                autoSize.maxLineCount: 2
            }
        }
        Container {
            leftPadding: 10
            rightPadding: 10
            bottomPadding: 5
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Bottom
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            Label {
                textStyle.base: lightStyle.style
                id: posterLabel
                text: root.coverPoster
                textStyle.fontSize: FontSize.PointValue
                textStyle.textAlign: TextAlign.Left
                textStyle.color: Color.White
                textFormat: TextFormat.Plain
                textStyle.fontSizeValue: 5.0

            }
            Label {
                textStyle.base: lightStyle.style
                id: commentLabel
                text: root.coverComments
                textStyle.fontSize: FontSize.PointValue
                textStyle.textAlign: TextAlign.Left
                textStyle.color: Color.White
                textFormat: TextFormat.Plain
                textStyle.fontSizeValue: 5.0
            }
        }
    }
}
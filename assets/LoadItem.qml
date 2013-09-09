import bb.cascades 1.0
Container {
    layout: DockLayout {
    }
    minWidth: 720
    preferredWidth: 768
    Container {
        minHeight: 10
        maxHeight: 10
    }
    Container {
        bottomPadding: 40
        horizontalAlignment: HorizontalAlignment.Center
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }
        ActivityIndicator {
            minWidth: 100
            horizontalAlignment: HorizontalAlignment.Left
            verticalAlignment: VerticalAlignment.Center
            running: true
        }
        Label {
            id: loadItem
            //translationY: 10
            verticalAlignment: VerticalAlignment.Center
            text: "Loading more...."
            textStyle.fontSize: FontSize.PointValue
            textStyle.textAlign: TextAlign.Center
            textStyle.fontSizeValue: 10
            textStyle.color: Color.DarkGray
            textFormat: TextFormat.Html
        }
    }
}
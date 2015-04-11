import bb.cascades 1.2
Container {
    topPadding: 10
    layout: DockLayout {
    }
    horizontalAlignment: HorizontalAlignment.Fill
    Container {
        minHeight: 10
        maxHeight: 10
    }
    Container {
        bottomPadding: 20
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
    }
}
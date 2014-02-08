import bb.cascades 1.2
Container {
    topPadding: 10
    layout: DockLayout {
    }
    minWidth: 720
    preferredWidth: 768
    horizontalAlignment: HorizontalAlignment.Center
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
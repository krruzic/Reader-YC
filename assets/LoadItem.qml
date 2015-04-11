import bb.cascades 1.2
Container {
    topPadding: 10
    layout: DockLayout {

    }
    horizontalAlignment: HorizontalAlignment.Fill
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        bottomPadding: 20
        ActivityIndicator {
            horizontalAlignment: HorizontalAlignment.Center
            minWidth: 100
            running: true
        }
    }
}
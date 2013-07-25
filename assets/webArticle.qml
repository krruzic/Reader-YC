import bb.cascades 1.0

Page {
    property alias htmlContent: webDisplay.url
    Container {
        WebView {
            id: webDisplay
        }
    }
}

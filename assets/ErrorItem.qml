import bb.cascades 1.2
Container {
    property alias title: errorItem.text
    minWidth: 720
    preferredWidth: 768
    Container {
        horizontalAlignment: HorizontalAlignment.Center
        verticalAlignment: VerticalAlignment.Center
        Container {
            minHeight: 10
            maxHeight: 10
        }
        Label {
            id: errorItem
            text: "<b><span style='color:#ff8c00'>Error getting stories</span></b>\nCheck your connection and try again!"
            textStyle.fontSize: FontSize.PointValue
            textStyle.textAlign: TextAlign.Center
            textStyle.fontSizeValue: 7
            textStyle.color: Color.DarkGray
            textFormat: TextFormat.Html
            multiline: true
            visible: true
        }
        Container {
            minHeight: 30
            maxHeight: 30
        }
    }
}
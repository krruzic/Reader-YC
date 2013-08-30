import bb.cascades 1.0
Container {
    property alias title: errorItem.text
    Container {
        horizontalAlignment: HorizontalAlignment.Center
        verticalAlignment: VerticalAlignment.Center
        Container {
            minHeight: 30
            maxHeight: 30
        }
        Label {
            id: errorItem
            text: "<b><span style='color:#fe8515'>Error getting stories</span></b>\nCheck your connection and try again!"
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
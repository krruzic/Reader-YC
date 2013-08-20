import bb.cascades 1.0

SceneCover {
    property alias extraText: bottomText.text
    
    content: Container {
        layout: DockLayout {}
        
        ImageView {
            imageSource: "asset:///images/github.png"
            verticalAlignment: VerticalAlignment.Center
            horizontalAlignment: HorizontalAlignment.Center
        }
        
        Label {
            text: "Small text at top"
            verticalAlignment: VerticalAlignment.Top
            horizontalAlignment: HorizontalAlignment.Center
            textStyle.fontSize: FontSize.XSmall
            textStyle.color: Color.Black
        }
        
        Label {
            id: bottomText
            text: ""
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Bottom
            textStyle.fontSize: FontSize.XLarge
            textStyle.color: Color.Black
        }
    }
}
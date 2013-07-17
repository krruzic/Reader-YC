import bb.cascades 1.0

Container {
    maxWidth: 768.0
    maxHeight: 140.0
    
    property alias postTitle: labelPostTitle.text
    property alias postURL: labelPostURL.text
    property alias postUsername: labelUsername.text
    property alias postTime: labelTimePosted.text
    property alias postComments: labelNumComments.text
    property alias highlightOpacity: highlightContainer.opacity
    
    layout: DockLayout {}
    background: listBackground.imagePaint
    
    attachedObjects: [
        ImagePaintDefinition {
            id: listBackground
            imageSource: "asset:///images/Paper.png"
        }
    ]
    Container {
        minHeight: 150
        minWidth: 665
        id: highlightContainer
        opacity: 0.0
        background: Color.create("#b6b6b6")
    }
    Container {
        id: mainContainer
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }
        preferredWidth: 768.0
        preferredHeight: 150.0
        horizontalAlignment: HorizontalAlignment.Center
        
        Container {
            Container {
                layout: AbsoluteLayout {}
                bottomMargin: 10.0
                Label {
                    layoutProperties: AbsoluteLayoutProperties {
                        positionX: 0.0
                    }
                    
                    maxWidth: 640
                    id: labelPostTitle
                    text: "Secure Boot isn't the only problem facing Linux on Windows 8 hardware "
                    multiline: false
                    textStyle.fontSize: FontSize.Small
                    textStyle.color: Color.Black
                }
                
                Label {
                    id: labelPostURL
                    maxWidth: 400.0
                    text: "http://www.dailymail.com/"
                    multiline: false
                    textStyle.fontSize: FontSize.Small
                    textStyle.color: Color.create("#ff69696c")
                    textStyle.fontStyle: FontStyle.Italic
                    layoutProperties: AbsoluteLayoutProperties {
                        positionX: 10.0
                        positionY: 45.0
                    }
                }
            }
            
            Container {
                minWidth: 635.0
                layout: DockLayout {}
                Label {
                    id: labelUsername
                    preferredHeight: 30.0
                    maxWidth: 320.0
                    text: "username234"
                    multiline: false
                    textStyle.fontSize: FontSize.Small
                    textStyle.color: Color.create("#fe8515")
                    textFormat: TextFormat.Html
                    horizontalAlignment: HorizontalAlignment.Left
                }
                Label {
                    id: labelTimePosted
                    preferredHeight: 30.0
                    maxWidth: 300.0
                    text: "9000 Hours ago"
                    multiline: false
                    textStyle.fontSize: FontSize.Small
                    textStyle.color: Color.Gray
                    horizontalAlignment: HorizontalAlignment.Right
                }
            }
        }
        
        Container {
            topPadding: 40.0
            leftPadding: 38.0
            CustomActionButton {
                id: labelNumComments
                normal: "asset:///images/Comment.png"
                pressed: "asset:///images/Comment.png"
                text: "178"
            }
        }
    }
}
import bb.cascades 1.0

Container {
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
    	id: highlightContainer
    	background: Color.create("#b6b6b6")
    	opacity: 0.0
        preferredWidth: 768.0
        preferredHeight: 150.0
        horizontalAlignment: HorizontalAlignment.Center
    }
    Container {
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }
        preferredWidth: 768.0
        preferredHeight: 150.0
        horizontalAlignment: HorizontalAlignment.Center

        Container {
            maxWidth: 640.0
            preferredHeight: 135.0
            leftPadding: 6.0

            Container {
                layout: AbsoluteLayout {}
                bottomMargin: 10.0
                Label {
                    layoutProperties: AbsoluteLayoutProperties {
                        positionX: 0.0
                    }
                    id: labelPostTitle
                    text: "Secure Boot isn't the only problem facing Linux on Windows 8 hardware "
                    multiline: false
                    textStyle.fontSize: FontSize.Small
                    textStyle.color: Color.Black
                }

                Label {
                    id: labelPostURL
                    maxWidth: 400.0
                    text: "http://www.dailymail.com/testing/testing/testing/testing/"
                    multiline: false
                    textStyle.fontSize: FontSize.XSmall
                    textStyle.color: Color.create("#ff69696c")
                    textStyle.fontStyle: FontStyle.Italic
                    layoutProperties: AbsoluteLayoutProperties {
                        positionX: 10.0
                        positionY: 45.0

                    }
                }
            }

            Container {
                minWidth: 650.0
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                Label {
                    id: labelUsername
                    preferredHeight: 30.0
                    text: "username234"
                    multiline: false
                    textStyle.fontSize: FontSize.Small
                    textStyle.color: Color.create("#fe8515")
                    textFormat: TextFormat.Html
                }
                Label {
                    id: labelTimePosted
                    preferredHeight: 30.0
                    text: "9000 Hours ago"
                    multiline: false
                    textStyle.fontSize: FontSize.Small
                    textStyle.color: Color.Gray
                }
            }
        }

        Container {
            topPadding: 40.0
            leftPadding: 30.0
            CustomActionButton {
                id: labelNumComments
                normal: "asset:///images/Comment.png"
                pressed: "asset:///images/Comment.png"
                text: "178"
            }
        }
    }
}
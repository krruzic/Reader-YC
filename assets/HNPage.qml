import bb.cascades 1.0
Container {
    property variant postArticle: ''
    property alias postTitle: labelPostTitle.text
    property alias postURL: labelPostURL.text
    property alias postUsername: labelUsername.text
    property alias postTime: labelTimePosted.text
    property alias postComments: labelNumComments.text
    property alias highlightOpacity: highlightContainer.opacity
    property int padding: 19
    
    signal goTocomments()
    
    topPadding: 10
    bottomPadding: 9
    leftPadding: padding
    rightPadding: padding
    Container {
    	Label {
    	 id: hidden
         text: ""
         visible: false 
     }
        maxWidth: 730.0
        maxHeight: 130.0
        
        layout: DockLayout {}
        
        ImageView {
            imageSource: "asset:///images/Paper.png"
        }
        Container {
            minHeight: 150
            minWidth: 665
            id: highlightContainer
            opacity: 0.0
            background: Color.create("#b6b6b6")
            visible: false 
        }
        Container {
            id: mainContainer
            
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            preferredWidth: 730.0
            preferredHeight: 140.0
            horizontalAlignment: HorizontalAlignment.Center
            
            Container {
                //    property int padding: 25
                //    
                //    topPadding: padding
                //    bottomPadding: padding
                //    leftPadding: padding
                Container {
                    layout: AbsoluteLayout {}
                    Label {
                        id: labelPostTitle
                        maxWidth: 600
                        minWidth: 600
                        text: "Billing Incident Update"
                        textStyle.fontSize: FontSize.Small
                        textStyle.color: Color.Black
                        translationX: 6.0
                    }
                    
                    Label {
                        id: labelPostURL
                        maxWidth: 500.0
                        text: "http://www.dailymail.com/"
                        multiline: false
                        textStyle.fontSize: FontSize.Small
                        textStyle.color: Color.create("#ff69696c")
                        textStyle.fontStyle: FontStyle.Italic
                        layoutProperties: AbsoluteLayoutProperties {
                            positionX: 14.0
                            positionY: 45.0
                        }
                    }
                }
                
                Container {
                    minWidth: 530.0
                    preferredWidth: 630.0
                    layout: DockLayout {}
                    Label {
                        id: labelUsername
                        preferredHeight: 30.0
                        maxWidth: 280.0
                        text: "username234"
                        multiline: false
                        textStyle.fontSize: FontSize.Small
                        textStyle.color: Color.create("#fe8515")
                        textFormat: TextFormat.Html
                        horizontalAlignment: HorizontalAlignment.Left
                        translationX: 6.0
                    }
                    Label {
                        id: labelTimePosted
                        preferredHeight: 30.0
                        maxWidth: 400.0
                        text: "90 Hours ago | 178 points"
                        multiline: false
                        textStyle.fontSize: FontSize.Small
                        textStyle.color: Color.Gray
                        horizontalAlignment: HorizontalAlignment.Right
                    }
                }
            }
            
            Container {
                topPadding: 35.0
                leftPadding: 20.0
                CustomActionButton {
                    id: labelNumComments
                    normal: "asset:///images/Comment.png"
                    pressed: "asset:///images/Comment.png"
                    text: ""
                    onButtonClicked: {
                    	console.log('Comment button pressed! ' + labelNumComments.text + ' comments');
                    	goTocomments();
                    }                   
                }
                
            }
        }
    }
}
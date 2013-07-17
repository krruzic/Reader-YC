import bb.cascades 1.0

    Container {
        layout: DockLayout {
        }
        background: listBackground.imagePaint
        
        attachedObjects: [
            ImagePaintDefinition {
                id: listBackground
                imageSource: "asset:///images/Paper.png"
            }
        ]
        
        Container {
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            preferredWidth: 768.0
            preferredHeight: 113.0
            horizontalAlignment: HorizontalAlignment.Center
            
            Container {
                preferredWidth: 650.0
                preferredHeight: 135.0
                leftPadding: 6.0
                
                Container {
                    layout: AbsoluteLayout {}
                    bottomMargin: 10.0
                    minHeight: 90.0
                    
                    Label {
                        id: labelPostTitle
                        text: ListItemData.title
                        multiline: true
                        layoutProperties: AbsoluteLayoutProperties {
                            positionX: 0.0
                        }
                        autoSize {maxLineCount: 2}
                        textStyle.fontSize: FontSize.Small
                        textStyle.color: Color.Black
                    }
                }
                
                Container {
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    Label {
                        id: labelTimePosted
                        preferredHeight: 30.0
                        minWidth: 260.0
                        text: ListItemData.timePosted
                        multiline: false
                        textStyle.fontSize: FontSize.XSmall
                        textStyle.color: Color.create("#fe8515")
                    }
                    
                    Label {
                        id: labelUsername
                        preferredHeight: 30.0
                        minWidth: 260.0
                        text: ListItemData.poster
                        multiline: false
                        textStyle.fontSize: FontSize.XSmall
                        textStyle.color: Color.create("#fe8515")
                        textFormat: TextFormat.Html
                    }
                }
            }
            
            Container {
                topPadding: 40.0
                leftPadding: 30.0
                CustomActionButton {
                    id: labelNumComments
                    normal: "asset:///images/Article.png"
                    pressed: "asset:///images/Article.png"
                }
            }
        }
    }
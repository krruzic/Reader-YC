import bb.cascades 1.0
Container {
    contextActions: [
        ActionSet {
            title: ListItemData.title;
            subtitle: ListItemData.poster + "         " + ListItemData.points
            ActionItem {
                title: "Open Comments"
                onTriggered: {
                    console.log("Pushing comments page")
                }
            }
            ActionItem {
                title: "Copy URL"
            }
            ActionItem {
                title: "Share Article"
            }
        }
    ] 
    layout: DockLayout {
    
    }
    property string postArticle: ''
    property string askPost: ''
    property string commentSource: ''
    property string postComments: ''
    property alias postTitle: labelPostTitle.text
    property alias postDomain: labelPostDomain.text
    property alias postUsername: labelUsername.text
    property alias postTime: labelTimePosted.text
    
    property int padding: 19	
    topPadding: 6
    bottomPadding: 4
    leftPadding: padding
    rightPadding: padding
    
    signal commentsClicked()
    function setHighlight(highlighted) {
        if (highlighted) {
            highlightContainer.opacity = 0.9;
        } else {
            highlightContainer.opacity = 0.0;
        }
    }
    // Highlight function for the highlight Container
    
    // Connect the onActivedChanged signal to the highlight function
    
    ListItem.onActivationChanged: {
        setHighlight(ListItem.active);
    }
    
    // Connect the onSelectedChanged signal to the highlight function
    ListItem.onSelectionChanged: {
        setHighlight(ListItem.selected);
    }
    attachedObjects: [
        ImagePaintDefinition {
            id: itemBackground
            imageSource: "asset:///images/full.png.amd"
        }
    ]
    
    Container {
        horizontalAlignment: horizontalAlignment.Center
        id: mainContainer
        preferredWidth: 730
        preferredHeight: 155
        maxHeight: 155
        maxWidth: 730
        background: itemBackground.imagePaint
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }
        Container {
            topPadding: 5
            leftPadding: 10
            Label {
                id: labelPostTitle
                preferredWidth: 680
                maxWidth: 680
                text: "Billing Incident Update, from the makers of cheese"
                textStyle.fontSize: FontSize.Small
                bottomMargin: 1
                textStyle.color: Color.Black
            
            }
            Label {
                id: labelPostDomain
                topMargin: 1
                bottomMargin: 1
                translationX: 10
                maxWidth: 500.0
                text: "http://www.dailymail.com/"
                multiline: false
                textStyle.fontSize: FontSize.Small
                textStyle.color: Color.create("#ff69696c")
                textStyle.fontStyle: FontStyle.Italic
            }
            Container {
                topMargin: 0
                leftMargin: 1
                rightPadding: 15
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                Label {
                    id: labelUsername
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    text: "username"
                    multiline: false
                    textStyle.fontSize: FontSize.Small
                    textStyle.color: Color.create("#fe8515")
                    horizontalAlignment: HorizontalAlignment.Left
                    textStyle.textAlign: TextAlign.Left
                }
                
                Label {
                    id: labelTimePosted
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 2
                    }
                    text: "some time ago | some points"
                    multiline: false
                    textStyle.fontSize: FontSize.Small
                    textStyle.color: Color.Gray
                    horizontalAlignment: HorizontalAlignment.Right
                    textStyle.textAlign: TextAlign.Right
                }
            }
        }
    }
    ImageView {
        horizontalAlignment: horizontalAlignment.Center
        id: highlightContainer
        imageSource: "asset:///images/listHighlight.amd"
        preferredWidth: 730
        preferredHeight: 155
        maxHeight: 155
        maxWidth: 730
        opacity: 0
    }
}

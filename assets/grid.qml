import bb.cascades 1.0

Page {
    
    ScrollView {
        scrollViewProperties.pinchToZoomEnabled: false
        scrollViewProperties.scrollMode: ScrollMode.Vertical
        Container {
            layout: StackLayout {
                orientation: LayoutOrientation.TopToBottom
            }
            Container {
                ImageView {
                    imageSource: "asset:///images/HN_title.png"
                }
            }
            Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight

                }
                animations: [
                    ScaleTransition {
                    
                    }
                ]

                topPadding: 40.0
                leftPadding: 35.0
                CustomActionButton {
                    textSize: FontSize.Medium
                    text: "Top Posts"
                    normal: "asset:///images/gridIcon.png"
                    rightMargin: 50.0
                }
                CustomActionButton {
                    textSize: FontSize.Medium
                    text: "Ask HN"
                    normal: "asset:///images/gridIcon.png"
                }
            }            
            Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                
                }
                animations: [
                    ScaleTransition {
                    
                    }
                ]
                
                topPadding: 40.0
                leftPadding: 35.0
                CustomActionButton {
                    textSize: FontSize.Medium
                    text: "Newest"
                    normal: "asset:///images/gridIcon.png"
                    rightMargin: 50.0
                }
                CustomActionButton {
                    textSize: FontSize.Medium
                    text: "Saved"
                    normal: "asset:///images/gridIcon.png"
                }
            }
            Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                
                }
                animations: [
                    ScaleTransition {
                    
                    }
                ]
                
                topPadding: 40.0
                leftPadding: 35.0
                CustomActionButton {
                    textSize: FontSize.Medium
                    text: "Newest"
                    normal: "asset:///images/gridIcon.png"
                    rightMargin: 50.0
                }
                CustomActionButton {
                    textSize: FontSize.Medium
                    text: "Saved"
                    normal: "asset:///images/gridIcon.png"
                }
            }
        }
    }
}

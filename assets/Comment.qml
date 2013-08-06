import bb.cascades 1.0

Container {
    id: commmentContainer
    property alias poster: posterLabel.text
    property alias time: timeLabel.text
    property alias indent: commmentContainer.leftPadding
    property alias text: commentBox.text
    
    horizontalAlignment: HorizontalAlignment.Right
    leftPadding: 20 + indent
    rightPadding: 20.0
    topPadding: 5.0
    bottomPadding: 5.0
    Container {
        leftPadding: 7
        background: commentBackground.imagePaint
        Container {
            rightPadding: 10
            leftPadding: 6
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            Label {
                id: posterLabel
                textStyle.fontSize: FontSize.XSmall
                text: "Madkristoff"
                horizontalAlignment: horizontalAlignment.Left
            }
            Divider {
                opacity: 0.0

            }
            Label {
                id: timeLabel
                textStyle.fontSize: FontSize.XSmall
                text: "4 minutes ago"
                horizontalAlignment: horizontalAlignment.Right
            }
        }
        Container {
            layout: AbsoluteLayout {
            
            }
            Divider {
            }
            TextArea {
                id: commentBox
                text: "This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, This is a test comment, I know that it's short...."
                editable: false
                backgroundVisible: true
                inputMode: TextAreaInputMode.Text
                textFormat: TextFormat.Html
                focusHighlightEnabled: true
                enabled: true
                scrollMode: TextAreaScrollMode.Stiff
                input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
                textStyle.fontSize: FontSize.XSmall
                textStyle.color: Color.Black
            }
        }
        attachedObjects: [
            ImagePaintDefinition {
                id: commentBackground
                imageSource: "asset:///images/CommentBackground.amd"
                repeatPattern: RepeatPattern.XY
            }
        ]
    }
}
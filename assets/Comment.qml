import bb.cascades 1.0
    
Container {
    property alias text: commentBox.text
    property alias padding: commmentContainer.leftPadding
    horizontalAlignment: HorizontalAlignment.Right

    Container {
        id: commmentContainer
        preferredWidth: 768.0
        leftPadding: 10.0
        rightPadding: 20.0
        topPadding: 5.0
        bottomPadding: 5.0
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }

        Container {
            background: commentBackground.imagePaint
            TextArea {
                id: commentBox
	            text: ""
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
            attachedObjects: [
                ImagePaintDefinition {
                    id: commentBackground
                    imageSource: "asset:///images/CommentBackground.amd"
                    repeatPattern: RepeatPattern.XY
                }
            ]
        }
    }
}

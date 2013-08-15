import bb.cascades 1.0
Container {
    leftPadding: 20
    rightPadding: 20
    Container {
        layout: AbsoluteLayout {

        }
        TextArea {
            rightPadding: 100
            id: textBox
            text: ""
            maxHeight: 100
            inputMode: TextAreaInputMode.Text
            input {
                flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheckOff
            }
        }
        ImageButton {
            layoutProperties: AbsoluteLayoutProperties {
                id: buttonPlacement
                positionX: 590
            }
            id: expandImage
            defaultImageSource: "asset:///images/ic_expand.png"
            onClicked: {
                if (textBox.maxHeight == 100) { // Expand 
                    textBox.minHeight = 600;
                    textBox.maxHeight = 1000;
                    buttonPlacement.positionY = 520
                    rotateAnimationUp.play();
                } else { // Shrink
                    textBox.minHeight = 0;
                    textBox.maxHeight = 100;
                    buttonPlacement.positionY = 0
                    rotateAnimationDown.play();
                }
            }
            animations: [
                RotateTransition {
                    id: rotateAnimationUp
                    toAngleZ: 180.0
                    target: expandImage
                },
                RotateTransition {
                    id: rotateAnimationDown
                    toAngleZ: 0
                    target: expandImage
                }
            ]
        }
    }
}
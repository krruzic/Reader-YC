import bb.cascades 1.0
import "tart.js" as Tart

Container {
    id: headerPane
    onCreationCompleted: {
        Tart.register(headerPane)
    }
    property alias titleText: titleLabel.text
    property alias posterText: posterLabel.text
    property alias textPost: textBox.text
    property alias articleTime: timeLabel.text
    topPadding: 20
    bottomPadding: 10
    leftPadding: 19
    rightPadding: 19
    
    function onAddText(data) {
        console.log(data.text)
        textPost = data.text
    }
    Container {
        background: headerBackground.imagePaint
        //background: Color.Black
        topPadding: 10

        Container {
            id: mainContainer
            leftPadding: 10
            rightPadding: 10
            bottomPadding: if (textBox.text == "") {
                mainContainer.bottomPadding = 0;
            } else {
                mainContainer.bottomPadding = 20;
            }
            Label {
                id: titleLabel
                text: "TESTING this with an example title that hopefully spans multiple lines"
                multiline: true
                autoSize.maxLineCount: 3
            }
            Container {
                Container {
                    bottomPadding: 20
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    Label {
                        id: posterLabel
                        minWidth: 380

                        text: "Username234224"
                        textStyle.fontSize: FontSize.XSmall
                        textStyle.color: Color.create("#fffe8515")

                    }
                    Label {
                        id: timeLabel
                        textStyle.fontSize: FontSize.XSmall

                        text: "4 hours ago | 9000 points"
                        textStyle.color: Color.Gray
                    }
                }
            }
            Container {
                background: textBackground.imagePaint
                TextArea {
                    id: textBox
                    maxHeight: 700
                    onTextChanged: {
                        if (text != "")
                            visible = true
                    }
                    visible: if (textBox.text == "") {
                        textBox.visible = false
                    }
                    text: ""
                    editable: false
                    focusHighlightEnabled: false
                    textFormat: TextFormat.Html
                }
            }
        }
        attachedObjects: [
            ImagePaintDefinition {
                id: headerBackground
                imageSource: "asset:///images/HeaderBackground.amd"
                repeatPattern: RepeatPattern.XY
            },
            ImagePaintDefinition {
                id: textBackground
                imageSource: "asset:///images/text.amd"
                repeatPattern: RepeatPattern.XY
            }
        ]
    }
}
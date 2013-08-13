import bb.cascades 1.0
import "tart.js" as Tart
Container {
    id: headerPane
    property alias title: labelPostTitle.text
    property alias poster: labelUsername.text
    property alias text: textBox.text
    property alias domain: labelPostDomain.text
    property alias articleTime: labelTimePosted.text
    onCreationCompleted: {
        Tart.register(headerPane)
    }
    function onAddText(data) {
        console.log(data.text)
        text = data.text
    }
    Container {
        bottomPadding: 35
        background: itemBackground.imagePaint
        attachedObjects: [
            ImagePaintDefinition {
                id: itemBackground
                imageSource: "asset:///images/full.png.amd"
            },
            ImagePaintDefinition {
                id: textBackground
                imageSource: "asset:///images/text.amd"
                repeatPattern: RepeatPattern.XY
            }
        ]

        Container {
            horizontalAlignment: horizontalAlignment.Center
            id: mainContainer
            preferredWidth: 730
            maxWidth: 730
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
                    text: "Billing Incident Update for your idiotic product, from the makers of cheese"
                    textStyle.fontSize: FontSize.Small
                    bottomMargin: 1
                    textStyle.color: Color.Black
                    multiline: true
                    autoSize.maxLineCount: 3

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
                    leftMargin: 1
                    rightPadding: 15
                    bottomPadding: 10
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
        Container {
            background: textBackground.imagePaint
            TextArea {
                id: textBox
                text: ""
                onTextChanging: {
                    if (text != "")
                    	visible = true;
                }
                visible: false
                editable: false
                focusHighlightEnabled: false
                textFormat: TextFormat.Html
                textStyle.color: Color.Black
            }
        }
    }
}
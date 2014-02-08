import bb.cascades 1.2
import "tart.js" as Tart

Container {
    id: headerPane
    leftPadding: 10
    rightPadding: 10
    property alias text: textBox.text
    property string commentCount: ""
    property string points: ""
    onCreationCompleted: {
        Tart.register(headerPane)
    }

    Container {
        bottomPadding: 25

        attachedObjects: [
            ImagePaintDefinition {
                id: itemBackground
                imageSource: "asset:///images/unread.amd"
            },
            ImagePaintDefinition {
                id: textBackground
                imageSource: "asset:///images/text.amd"
                repeatPattern: RepeatPattern.XY
            },
            ImagePaintDefinition {
                id: background
                imageSource: "asset:///images/commentBox.png.amd"
                repeatPattern: RepeatPattern.XY
            }
        ]

        Container {
            attachedObjects: [
                TextStyleDefinition {
                    id: lightStyle
                    base: SystemDefaults.TextStyles.BodyText
                    fontSize: FontSize.PointValue
                    fontSizeValue: 7
                    fontWeight: FontWeight.W100
                },
                LayoutUpdateHandler {
                    id: mainDimensions
                }
            ]
            visible: true
            id: mainContainer
            background: Color.White
            horizontalAlignment: HorizontalAlignment.Fill

            Container {
                topPadding: 5
                leftPadding: 10
                rightPadding: 10
                rightMargin: 0
                bottomMargin: 0
                bottomPadding: 0
                horizontalAlignment: HorizontalAlignment.Fill
                Label {
                    id: labelPostTitle
                    verticalAlignment: VerticalAlignment.Top
                    text: ListItemData.hTitle
                    bottomMargin: 1
                    multiline: true
                    autoSize.maxLineCount: 2
                    textStyle.fontSizeValue: 7
                    textStyle.base: lightStyle.style
                }
                Container {
                    layout: DockLayout {
                    }
                    horizontalAlignment: HorizontalAlignment.Fill
                    Container {
                        horizontalAlignment: HorizontalAlignment.Left
                        verticalAlignment: VerticalAlignment.Center
                        Label {
                            topMargin: 5
                            id: labelPostDomain
                            horizontalAlignment: HorizontalAlignment.Left
                            text: ListItemData.domain
                            multiline: false
                            textStyle.color: Color.create("#ff7900")
                            textStyle.fontStyle: FontStyle.Italic
                            textStyle.base: lightStyle.style
                            bottomMargin: 0
                        }
                        Label {
                            topMargin: 5
                            text: ListItemData.articleTime
                            id: labelTimePosted
                            textStyle.fontSizeValue: 5
                            textStyle.base: lightStyle.style
                        }
                    }
                    Container {
                        id: storyinfo
                        horizontalAlignment: HorizontalAlignment.Right
                        verticalAlignment: VerticalAlignment.Center
                        //background: background.imagePaint
                        rightPadding: 10
                        Container {
                            horizontalAlignment: HorizontalAlignment.Right
                            verticalAlignment: VerticalAlignment.Center
                            layout: StackLayout {
                                orientation: LayoutOrientation.LeftToRight
                            }
                            leftPadding: 4
                            ImageView {
                                rightPadding: 0
                                leftMargin: 0
                                imageSource: "asset:///images/comment.png"
                                maxHeight: 26
                                maxWidth: 26
                                translationY: 2
                                verticalAlignment: VerticalAlignment.Center
                                horizontalAlignment: HorizontalAlignment.Right
                            }
                            Label {
                                leftMargin: 0
                                rightMargin: 0
                                text: "<html><i>" + commentCount + "</i></html>"
                                textStyle.fontSize: FontSize.PointValue
                                textStyle.fontSizeValue: 5
                                horizontalAlignment: HorizontalAlignment.Right
                                verticalAlignment: VerticalAlignment.Center
                                textStyle.color: Color.create("#7e7e7e")
                                textStyle.base: lightStyle.style
                                textFormat: TextFormat.Html
                            }
                            Label {
                                leftMargin: 0
                                text: "<html><i> | ▲ </i></html>" + points
                                textStyle.fontSize: FontSize.PointValue
                                textStyle.fontSizeValue: 5
                                horizontalAlignment: HorizontalAlignment.Right
                                verticalAlignment: VerticalAlignment.Center
                                textStyle.color: Color.create("#7e7e7e")
                                textStyle.base: lightStyle.style
                                textFormat: TextFormat.Html
                            }
                        }
                        Label {
                            topMargin: 0
                            textStyle.fontSizeValue: 5
                            text: ListItemData.poster
                            id: labelUsername
                            textStyle.color: Color.create("#ff7900")
                            textStyle.base: lightStyle.style
                            horizontalAlignment: HorizontalAlignment.Right
                        }
                    }
                }
                TextArea {
                    editable: false
                    textStyle.base: lightStyle.style
                    id: textBox
                    visible: false
                    onTextChanging: {
                        if (text == ""){
                            visible = false;
                        }
                        else {
                            visible = true;
                        }
                    }
                }
                Divider {
                    bottomMargin: 0
                    bottomPadding: 0
                }
            }
        }
    }
}
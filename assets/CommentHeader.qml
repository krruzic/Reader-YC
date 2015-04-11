import bb.cascades 1.4
import bb.system 1.2
import "tart.js" as Tart

Container {
    property variant baseColour: Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark ? Color.create("#ffdddddf") : Color.create("#434344")
    property variant secondaryColour: Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark ? "" : Color.create("#f99925")

    id: headerPane
    leftPadding: 10
    rightPadding: 10
    property alias poster: labelUsername.text
    property alias bodyText: textBox.text
    property string commentCount: ""
    property string points: ""
    onCreationCompleted: {
        Tart.register(headerPane)
    }

    Container {
        bottomPadding: 25
        attachedObjects: [
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
                    fontWeight: FontWeight.W300
                },
                LayoutUpdateHandler {
                    id: mainDimensions
                }
            ]
            visible: true
            id: mainContainer

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
                            textStyle.color: Color.create("#f99925")
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
                                leftMargin: 0
                                imageSource: "asset:///images/comment.png"
                                maxHeight: 26
                                maxWidth: 26
                                translationY: 2
                                verticalAlignment: VerticalAlignment.Center
                                horizontalAlignment: HorizontalAlignment.Right
                                filterColor: baseColour
                            }
                            Label {
                                leftMargin: 0
                                rightMargin: 0
                                text: "<html><i>" + commentCount + "</i></html>"
                                textStyle.fontSize: FontSize.PointValue
                                textStyle.fontSizeValue: 5
                                horizontalAlignment: HorizontalAlignment.Right
                                verticalAlignment: VerticalAlignment.Center
                                textStyle.color: baseColour
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
                                textStyle.color: baseColour
                                textStyle.base: lightStyle.style
                                textFormat: TextFormat.Html
                            }
                        }
                        Label {
                            topMargin: 0
                            textStyle.fontSizeValue: 5
                            text: ListItemData.poster
                            id: labelUsername
                            textStyle.color: Color.create("#f99925")
                            textStyle.base: lightStyle.style
                            horizontalAlignment: HorizontalAlignment.Right
                        }
                    }
                }
                Label {
                    textStyle.base: lightStyle.style
                    id: textBox
                    visible: false
                    multiline: true
                    enabled: true
                    textStyle.fontSizeValue: 6
                    onTextChanged: {
                        if (text == "<html></html>") {
                            visible = false;
                        } else {
                            visible = true;
                        }
                    }
                    textFormat: TextFormat.Html
                }
                Divider {
                    bottomMargin: 0
                }
            }
        }
    }
}
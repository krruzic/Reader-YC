import bb.cascades 1.0
import "tart.js" as Tart

SceneCover {
    attachedObjects: [
        ImagePaintDefinition {
            id: background
            imageSource: "asset:///images/titlebar.png"
        }
    ]

    id: cover
    onCreationCompleted: {
        Tart.register(cover);
    }
    content: Container {
        //property alias titleText: titleLabel.text

        Container {
            topMargin: 20
            bottomMargin: 20
            layout: DockLayout {
            }
            minHeight: 60
            maxHeight: 60
            background: background.imagePaint
            Container {
                topPadding: 10
                leftPadding: 10
                rightPadding: 20
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                Container {
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 5
                    }
                    horizontalAlignment: horizontalAlignment.Left
                    Label {
                        id: pageTitle
                        text: "Reader|YC"
                        textStyle.fontSize: FontSize.PointValue
                        textStyle.textAlign: TextAlign.Left
                        textStyle.color: Color.White
                        textFormat: TextFormat.Plain
                        enabled: false
                        textStyle.fontSizeValue: 6.0
                    }
                }
            }
        }
        Container {
            topMargin: 10
            bottomMargin: 10
            leftPadding: 10
            rightPadding: 10
            verticalAlignment: VerticalAlignment.Center
            horizontalAlignment: HorizontalAlignment.Center
            Label {
                id: titleLabel
                text: root.coverTitle
                verticalAlignment: VerticalAlignment.Top
                horizontalAlignment: HorizontalAlignment.Center
                textStyle.fontSize: FontSize.PointValue
                textStyle.textAlign: TextAlign.Left
                textStyle.color: Color.DarkGray
                textFormat: TextFormat.Plain
                textStyle.fontStyle: FontStyle.Italic
                multiline: true
                textStyle.fontSizeValue: 7.0
                autoSize.maxLineCount: 2
            }
            Divider {

            }
            Container {
                verticalAlignment: VerticalAlignment.Bottom
                horizontalAlignment: HorizontalAlignment.Center
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                Label {
                    id: posterLabel
                    text: root.coverPoster
                    textStyle.fontSize: FontSize.PointValue
                    textStyle.textAlign: TextAlign.Left
                    textStyle.color: Color.DarkGray
                    textFormat: TextFormat.Plain
                    textStyle.fontStyle: FontStyle.Italic
                    textStyle.fontSizeValue: 4.0
                }
                //                Divider {
                //                    visible: if (commentLabel.text != "") {
                //                        true;
                //                    } else {
                //                        false;
                //                    }
                //                    rotationZ: 90
                //                    minWidth: 200
                //                }
                Container {
                    maxHeight: 100
                    minHeight: 100
                    maxWidth: 2
                    minWidth: 2
                    background: Color.create("#878787")
                    rightMargin: 6
                    visible: if (commentLabel.text != "") {
                        true;
                    } else {
                        false;
                    }
                }
                Container {
                    topMargin: 0
                    bottomMargin: 0
                    Label {
                        id: commentLabel
                        text: root.coverComments
                        textStyle.fontSize: FontSize.PointValue
                        textStyle.color: Color.DarkGray
                        textFormat: TextFormat.Plain
                        textStyle.fontStyle: FontStyle.Italic
                        textStyle.fontSizeValue: 4.0
                        topMargin: 0
                        bottomMargin: 0
                    }
                    Label {
                        id: detailLabel
                        text: root.coverDetails
                        textStyle.fontSize: FontSize.PointValue
                        textStyle.textAlign: TextAlign.Left
                        textStyle.color: Color.DarkGray
                        textFormat: TextFormat.Plain
                        textStyle.fontStyle: FontStyle.Italic
                        textStyle.fontSizeValue: 4.0
                        topMargin: 0
                        bottomMargin: 0
                    }
                }
            }
        }
    }
}
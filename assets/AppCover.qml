import bb.cascades 1.0
import "tart.js" as Tart
import "global.js" as Global

SceneCover {
    id: cover

    content: Container {
        //property alias titleText: titleLabel.text

        onCreationCompleted: {
            Tart.register(cover);
        }
        ImageView {
            imageSource: "asset:///images/YC.png"
            visible: Global.showImgCover
            //        }
            //        Container {
            //            topMargin: 20
            //            bottomMargin: 20
            //            layout: DockLayout {
            //            }
            //            minHeight: 60
            //            maxHeight: 60
            //            background: background.imagePaint
            //            Container {
            //                topPadding: 10
            //                leftPadding: 10
            //                rightPadding: 20
            //                layout: StackLayout {
            //                    orientation: LayoutOrientation.LeftToRight
            //                }
            //                Container {
            //                    layoutProperties: StackLayoutProperties {
            //                        spaceQuota: 5
            //                    }
            //                    horizontalAlignment: horizontalAlignment.Left
            //                    Label {
            //                        id: pageTitle
            //                        text: "Reader|YC"
            //                        textStyle.fontSize: FontSize.PointValue
            //                        textStyle.textAlign: TextAlign.Left
            //                        textStyle.color: Color.White
            //                        textFormat: TextFormat.Plain
            //                        enabled: false
            //                        textStyle.fontSizeValue: 6.0
            //                    }
            //                }
            //            }
            //        }
            //        Container {
            //            topMargin: 10
            //            bottomMargin: 10
            //            leftPadding: 10
            //            rightPadding: 10
            //            verticalAlignment: VerticalAlignment.Center
            //            horizontalAlignment: HorizontalAlignment.Center
            //            Label {
            //                id: titleLabel
            //                text: Global.coverTitle
            //                verticalAlignment: VerticalAlignment.Top
            //                horizontalAlignment: HorizontalAlignment.Center
            //                textStyle.fontSize: FontSize.PointValue
            //                textStyle.textAlign: TextAlign.Left
            //                textStyle.color: Color.DarkGray
            //                textFormat: TextFormat.Plain
            //                textStyle.fontStyle: FontStyle.Italic
            //                multiline: true
            //                textStyle.fontSizeValue: 7.0
            //            }
            //            Divider {
            //
            //            }
            //        }
            //    }
        }
        attachedObjects: [
            ImagePaintDefinition {
                id: background
                imageSource: "asset:///images/titlebar.png"
            }
        ]
    }
}
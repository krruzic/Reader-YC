import bb.cascades 1.0

Page {
    Container {
        HNTitleBar {
            id: helpTitleBar
            text: "Reader|YC - Settings"
            showButton: false
        }
        Container {
            layout: StackLayout {
            }
            topPadding: 10
            leftPadding: 10
            rightPadding: 20
            Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                Container {
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 6
                    }
                    Label {
                        text: "<b>Article click Behaviour</b>"
                        textFormat: TextFormat.Html
                        textStyle.color: Color.create("#434344")
                    }
                    Label {
                        text: "Always open in browser"
                        textStyle.fontSize: FontSize.PointValue
                        textStyle.fontSizeValue: 6
                        textStyle.color: Color.create("#fe8a3e")
                    }
                }
                ToggleButton {
                    translationY: 10
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    onCheckedChanged: {
                        if (checked == true) {
                            console.log("Always open in browser..")
                        } else {
                            console.log("Open in app")
                        }
                    }

                }
            }
            Divider {

            }
            Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                Container {
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 6
                    }
                    Label {
                        text: "<b>Clear the cache</b>"
                        textFormat: TextFormat.Html
                        textStyle.color: Color.create("#434344")
                    }
                    Label {
                        text: "Delete cached comments and all favourites"
                        textStyle.fontSize: FontSize.PointValue
                        textStyle.fontSizeValue: 6
                        textStyle.color: Color.create("#fe8a3e")
                    }
                }
                Button {
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    imageSource: "asset:///images/trash.png"

                    onClicked: {
                        console.log("Clear Cache!")
                    }
                }
            }
            Divider {

            }
        }
        Label {
            text: "Reader|YC - Copyright © 2013 Surge Co."
            textStyle.fontSize: FontSize.PointValue
            textStyle.fontSizeValue: 5
            preferredWidth: 768
            layoutProperties: StackLayoutProperties {
            }
            horizontalAlignment: horizontalAlignment.Center
            textStyle.textAlign: TextAlign.Center
        }
    }
}
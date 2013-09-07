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
                    id: browserToggle
                    translationY: 10
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    onCheckedChanged: {
                        if (checked == true) {
                            settings.openInBrowser = true;
                            console.log("Always open in browser..")
                        } else {
                            settings.openInBrowser = false;
                            console.log("Open in app")
                        }
                    }

                }
            }
            Divider {

            }
            Container {
                //horizontalAlignment: horizontalAlignment.Center

                Container {
                    horizontalAlignment: horizontalAlignment.Center
                    Button {
                        horizontalAlignment: horizontalAlignment.Center
                        text: "Clear cache"
                        onClicked: {
                            console.log("Clear Cache!")
                        }
                    }
                    Label {
                        text: "This will delete cached comments and all favourited articles"
                        textFormat: TextFormat.Html
                        textStyle.color: Color.create("#434344")
                        multiline: true
                        textStyle.fontSize: FontSize.PointValue
                        textStyle.fontSizeValue: 5
                        horizontalAlignment: horizontalAlignment.Center
                        textStyle.textAlign: TextAlign.Center
                    }
                }
                Divider {

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
    }
    function precheckBrowser(value) {
        print("CURR VALUE: " + browserToggle.checked);
        print(value);
        if (browserToggle.checked == value) // skip if already selected
            return;
        else
        	browserToggle.checked = !browserToggle.checked;
    }

    onCreationCompleted: {
        precheckBrowser(settings.openInBrowser ? true : false);
    }
}
import bb.cascades 1.0
import bb.system 1.0
import "tart.js" as Tart

Page {
    id: settingsPage
    onCreationCompleted: {
        Tart.register(settingsPage);
        precheckBrowser(settings.openInBrowser ? true : false);
        precheckReader(settings.readerMode ? true : false);

    }
    titleBar: HNTitleBar {
        refreshEnabled: false
        id: titleBar
        text: "Reader|YC - Settings"

    }
    ScrollView {
        preferredWidth: 768
        scrollViewProperties {
            scrollMode: ScrollMode.Vertical
        }

        Container {
            preferredWidth: 768
            topPadding: 10
            leftPadding: 10
            rightPadding: 10
            Container {
                layout: DockLayout {
                }
                horizontalAlignment: HorizontalAlignment.Fill // Make full width
                Label {
                    horizontalAlignment: horizontalAlignment.Left
                    verticalAlignment: VerticalAlignment.Top
                    text: "<b>Article Click Behaviour</b>"
                    textFormat: TextFormat.Html
                    textStyle.fontSize: FontSize.PointValue
                    textStyle.fontSizeValue: 7
                    textStyle.color: Color.create("#434344")
                }
                Container {
                    maxHeight: 60
                    minHeight: 60
                    horizontalAlignment: horizontalAlignment.Left
                    verticalAlignment: VerticalAlignment.Center
                }
                Label {
                    horizontalAlignment: horizontalAlignment.Left
                    verticalAlignment: VerticalAlignment.Bottom
                    text: "Always open in browser"
                    textStyle.fontSize: FontSize.PointValue
                    textStyle.fontSizeValue: 6
                    textStyle.color: Color.create("#fe8a3e")
                }

                ToggleButton {
                    horizontalAlignment: HorizontalAlignment.Right

                    id: browserToggle
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
                layout: DockLayout {
                }
                horizontalAlignment: HorizontalAlignment.Fill // Make full width
                Label {
                    horizontalAlignment: horizontalAlignment.Left
                    verticalAlignment: VerticalAlignment.Top
                    text: "<b>Reader Mode</b>"
                    textFormat: TextFormat.Html
                    textStyle.fontSize: FontSize.PointValue
                    textStyle.fontSizeValue: 7
                    textStyle.color: Color.create("#434344")
                }
                Container {
                    maxHeight: 60
                    minHeight: 60
                    horizontalAlignment: horizontalAlignment.Left
                    verticalAlignment: VerticalAlignment.Center
                }
                Label {
                    horizontalAlignment: horizontalAlignment.Left
                    verticalAlignment: VerticalAlignment.Bottom
                    text: "Display URLs using Readability"
                    textStyle.fontSize: FontSize.PointValue
                    textStyle.fontSizeValue: 6
                    textStyle.color: Color.create("#fe8a3e")
                }
                
                ToggleButton {
                    horizontalAlignment: HorizontalAlignment.Right
                    
                    id: readerToggle
                    onCheckedChanged: {
                        if (checked == true) {
                            settings.readerMode = true;
                            console.log("Reader mode on..")
                        } else {
                            settings.readerMode = false;
                            console.log("Reader mode off")
                        }
                    }
                }
            }
            Divider {
            
            }
            Button {
                verticalAlignment: verticalAlignment.Top
                horizontalAlignment: HorizontalAlignment.Center

                id: cacheButton
                text: "Clear cache"
                onClicked: {
                    cacheButton.enabled = false;
                    Tart.send('deleteCache');
                }
            }
            Label {
                horizontalAlignment: horizontalAlignment.Center
                text: "This will delete all cached comments and favourited articles"
                textStyle.fontSize: FontSize.PointValue
                textStyle.fontSizeValue: 6
                textStyle.textAlign: TextAlign.Center
                preferredWidth: 768
            }
            Divider {

            }
            Label {
                text: "Reader|YC - Copyright © 2013 Surge Co."
                textStyle.fontSize: FontSize.PointValue
                textStyle.fontSizeValue: 5
                preferredWidth: 768
                horizontalAlignment: horizontalAlignment.Center
                textStyle.textAlign: TextAlign.Center
            }
        }
    }
    function onCacheDeleted(data) {
        cacheButton.enabled = true;
        cacheDeleteToast.body = data.text;
        cacheDeleteToast.cancel();
        cacheDeleteToast.show();
    }
    function precheckBrowser(value) {
        print("CURR BROWSER: " + browserToggle.checked);
        print(value);
        if (browserToggle.checked == value) // skip if already selected
            return;
        else
            browserToggle.checked = ! browserToggle.checked;
    }
    
    function precheckReader(value) {
        print("CURR READER: " + readerToggle.checked);
        print(value);
        if (readerToggle.checked == value) // skip if already selected
            return;
        else
            readerToggle.checked = ! readerToggle.checked;
    }

    attachedObjects: [
        SystemToast {
            id: cacheDeleteToast
            body: ""
        }
    ]
}

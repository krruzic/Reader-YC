import bb.cascades 1.0

Page {
    Container {
        HNTitleBar {
            id: aboutTitleBar
            text: "Reader|YC - About"
            showButton: false
            onRefreshPage: {
                aboutSheet.close();
            }
        }
        Container {
            leftPadding: 20
            Label {
                text: qsTr("<p>Reader|YC is one of the only Hacker News clients currently available for Blackberry 10. \nIt uses the opensource BlackBerryPy project and is hosted on Github, where contributions are welcome.</p><p>To use Reader|YC, just select the tab you want to view, and start reading!</p>")
                multiline: true
                textFormat: TextFormat.Html
                textStyle.color: Color.DarkGray
                textStyle.fontSize: FontSize.Small
            }
        }
        Container {
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            Button {
                horizontalAlignment: horizontalAlignment.Left
                text: "Contribute on Github!"
                attachedObjects: [
                    Invocation {
                        id: browserInvocation
                        query.mimeType: "text/plain"
                        query.invokeTargetId: "sys.browser"
                        query.invokeActionId: "bb.action.OPEN"
                        query.uri: "https://github.com/krruzic/Reader-YC/"
                    }
                ]
                onClicked: {
                    browserInvocation.trigger(browserInvocation.query.invokeActionId);
                }
            }
            Button {
                horizontalAlignment: horizontalAlignment.Right
                text: "Rate the app!"
                onClicked: {
                    console.log("HELLO");
                }
            }
        }
    }
}

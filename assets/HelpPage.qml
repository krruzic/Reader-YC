import bb.cascades 1.0

Page {
    Container {
        layout: StackLayout {
        }
        HNTitleBar {
            verticalAlignment: verticalAlignment.Top
            id: helpTitleBar
            text: "Reader|YC - Help"
            showButton: false
            onRefreshPage: {
                helpSheet.close();
            }
        }
        Container {
            leftPadding: 20
            Label {
                text: qsTr("<p>If you're having trouble using the app, or noticed a bug, feel free to send a bug report to the Developers!</p>")
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
                text: "Email the Developers!"
                attachedObjects: [
                    Invocation {
                        id: emailInvocation
                        query.mimeType: "text/plain"
                        query.invokeTargetId: "sys.pim.uib.email.hybridcomposer"
                        query.invokeActionId: "bb.action.SENDEMAIL"
                        query.uri: "mailto:krruzic@gmail.com?subject=Reader|YC Help"
                    }
                ]
                onClicked: {
                    emailInvocation.trigger(emailInvocation.query.invokeActionId);
                }
            }
            Button {
                text: "Request a bug fix!"
                horizontalAlignment: horizontalAlignment.Left
                text: "Contribute on Github!"
                attachedObjects: [
                    Invocation {
                        id: browserInvocation
                        query.mimeType: "text/plain"
                        query.invokeTargetId: "sys.browser"
                        query.invokeActionId: "bb.action.OPEN"
                        query.uri: "https://github.com/krruzic/Reader-YC/issues/new
                    }
                ]
                onClicked: {
                    browserInvocation.trigger(browserInvocation.query.invokeActionId);
                }
            }
        }
    }
}
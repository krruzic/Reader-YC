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
                        text: "<b>Reader|YC is Open Source</b>"
                        textFormat: TextFormat.Html
                    }
                    Label {
                        text: "Contribute on GitHub!"
                        textStyle.fontSize: FontSize.PointValue
                        textStyle.fontSizeValue: 6
                    }
                }
                Button {
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    imageSource: "asset:///images/github.png"
                    onClicked: {
                        browserInvocation.query.uri = "https://github.com/krruzic/Reader-YC/"
                        browserInvocation.trigger(browserInvocation.query.invokeActionId);
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
                        text: "<b>Bug?</b>"
                        textFormat: TextFormat.Html
                    }
                    Label {
                        text: "Email the devs!"
                        textStyle.fontSize: FontSize.PointValue
                        textStyle.fontSizeValue: 6
                    }
                }
                Button {
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    imageSource: "asset:///images/mail.png"

                    onClicked: {
                        emailInvocation.trigger(browserInvocation.query.invokeActionId);
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
                        text: "<b>Feature Request?</b>"
                        textFormat: TextFormat.Html
                    }
                    Label {
                        text: "Submit an issue!"
                        textStyle.fontSize: FontSize.PointValue
                        textStyle.fontSizeValue: 6
                    }
                }
                Button {
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    imageSource: "asset:///images/github.png"
                    onClicked: {
                        browserInvocation.query.uri = "https://github.com/krruzic/Reader-YC/issues"
                        browserInvocation.trigger(browserInvocation.query.invokeActionId);
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
                        text: "<b>Support Reader|YC Development</b>"
                        textFormat: TextFormat.Html
                    }
                    Label {
                        text: "Leave a Review on BlackBerry World!"
                        textStyle.fontSize: FontSize.PointValue
                        textStyle.fontSizeValue: 6
                    }
                }
                Button {
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    imageSource: "asset:///images/bbWorld.png"

                    onClicked: {
                        console.log("Invoke BB WORLD HERE")
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
                        text: "<b>Share the App</b>"
                        textFormat: TextFormat.Html
                    }
                    Label {
                        text: "Invite BBM Friends to download!"
                        textStyle.fontSize: FontSize.PointValue
                        textStyle.fontSizeValue: 6
                    }
                }
                Button {
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    imageSource: "asset:///images/BBM.png"

                    onClicked: {
                        console.log("Invoke BBM Invite HERE")
                    }
                }
            }
            Divider {

            }
            Label {
                text: "Reader|YC - Copyright © 2013 Surge Co."
                textStyle.fontSize: FontSize.PointValue
                textStyle.fontSizeValue: 5
                layoutProperties: StackLayoutProperties {
                }
                horizontalAlignment: horizontalAlignment.Center
                textStyle.textAlign: TextAlign.Center
            }
        }
    }
    attachedObjects: [
        Invocation {
            id: browserInvocation
            query.mimeType: "text/plain"
            query.invokeTargetId: "sys.browser"
            query.invokeActionId: "bb.action.OPEN"
            query.uri: "https://github.com/krruzic/Reader-YC/"
            query.onQueryChanged: {
                browserInvocation.query.updateQuery();
            }
        },
        Invocation {
            id: emailInvocation
            query.mimeType: "text/plain"
            query.invokeTargetId: "sys.pim.uib.email.hybridcomposer"
            query.invokeActionId: "bb.action.SENDEMAIL"
            query.uri: "mailto:krruzic@gmail.com?subject=Reader|YC Help"
        }
    ]
}

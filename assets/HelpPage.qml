import bb.cascades 1.2

Page {
    property variant baseColour: Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark ? Color.create("#ffdddddf") : Color.create("#434344")
    property variant secondaryColour: Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark ? Color.create("#ff8e00") : Color.create("#ff8e00")

    titleBar: HNTitleBar {
        id: helpTitleBar
        text: "Reader YC - Help"
        refreshEnabled: false
    }
    ScrollView {
        scrollViewProperties.scrollMode: ScrollMode.Vertical
        scrollViewProperties.overScrollEffectMode: OverScrollEffectMode.OnScroll

        Container {

            attachedObjects: [
                TextStyleDefinition {
                    id: lightStyle
                    base: SystemDefaults.TextStyles.BodyText
                    //                fontSize: FontSize.PointValue
                    //                fontSizeValue: 7
                    fontWeight: FontWeight.W300
                }
            ]
            Container {
                layout: StackLayout {
                }
                topPadding: 10
                leftPadding: 10
                rightPadding: 20
                Container {
                    topPadding: 10
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    Container {
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 6
                        }
                        Label {
                            textStyle.base: lightStyle.style
                            text: "<b>Reader YC is Open Source</b>"
                            textFormat: TextFormat.Html
                            textStyle.color: baseColour
                            bottomMargin: 0
                            topMargin: 0
                        }
                        Label {
                            textStyle.base: lightStyle.style
                            text: "Contribute on GitHub!"
                            textStyle.fontSize: FontSize.PointValue
                            textStyle.fontSizeValue: 6
                            textStyle.color: secondaryColour
                            bottomMargin: 0
                            topMargin: 0
                        }
                    }
                    Button {
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1
                        }
                        imageSource: Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark ? "asset:///images/github_lt.png" : "asset:///images/github.png"
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
                            textStyle.base: lightStyle.style
                            text: "<b>Found a Bug?</b>"
                            textFormat: TextFormat.Html
                            textStyle.color: baseColour
                            bottomMargin: 0
                            topMargin: 0
                        }
                        Label {
                            textStyle.base: lightStyle.style
                            text: "Email the devs!"
                            textStyle.fontSize: FontSize.PointValue
                            textStyle.fontSizeValue: 6
                            textStyle.color: secondaryColour
                            bottomMargin: 0
                            topMargin: 0
                        }
                    }
                    Button {
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1
                        }
                        imageSource: Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark ? "asset:///images/mail_lt.png" : "asset:///images/mail.png"

                        onClicked: {
                            emailInvocation.trigger(emailInvocation.query.invokeActionId);
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
                            textStyle.base: lightStyle.style
                            text: "<b>Have a Feature Request?</b>"
                            textFormat: TextFormat.Html
                            textStyle.color: baseColour
                            bottomMargin: 0
                            topMargin: 0
                        }
                        Label {
                            textStyle.base: lightStyle.style
                            text: "Submit an issue!"
                            textStyle.fontSize: FontSize.PointValue
                            textStyle.fontSizeValue: 6
                            textStyle.color: secondaryColour
                            bottomMargin: 0
                            topMargin: 0
                        }
                    }
                    Button {
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1
                        }
                        imageSource: Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark ? "asset:///images/feature_lt.png" : "asset:///images/feature.png"
                        attachedObjects: [
                            Invocation {
                                id: featureInvocation
                                query.mimeType: "text/plain"
                                query.invokeTargetId: "sys.browser"
                                query.invokeActionId: "bb.action.OPEN"
                                query.uri: "https://github.com/krruzic/Reader-YC/issues/"
                            }
                        ]
                        onClicked: {
                            featureInvocation.trigger(featureInvocation.query.invokeActionId);
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
                            textStyle.base: lightStyle.style
                            text: "<b>Support Reader YC Development</b>"
                            textFormat: TextFormat.Html
                            textStyle.color: baseColour
                            bottomMargin: 0
                            topMargin: 0
                        }
                        Label {
                            textStyle.base: lightStyle.style
                            text: "Leave a Review on BlackBerry World!"
                            textStyle.fontSize: FontSize.PointValue
                            textStyle.fontSizeValue: 6
                            textStyle.color: secondaryColour
                            bottomMargin: 0
                            topMargin: 0
                        }
                    }
                    Button {
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1
                        }
                        imageSource: Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark ? "asset:///images/bbWorld_lt.png" : "asset:///images/bbWorld.png"

                        attachedObjects: [
                            Invocation {
                                id: invoke
                                query.mimeType: "application/x-bb-appworld"
                                query.uri: "appworld://content/Reader00YC"
                            }
                        ]

                        onClicked: {
                            invoke.trigger("bb.action.OPEN")
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
                            textStyle.base: lightStyle.style
                            text: "<b>Join The Surge Co. BBM Channel</b>"
                            textFormat: TextFormat.Html
                            textStyle.color: baseColour
                            bottomMargin: 0
                            topMargin: 0
                        }
                        Label {
                            textStyle.base: lightStyle.style
                            text: "The latest news on everything we're working on!"
                            textStyle.fontSize: FontSize.PointValue
                            textStyle.fontSizeValue: 6
                            textStyle.color: secondaryColour
                            bottomMargin: 0
                            topMargin: 0
                        }
                    }
                    Button {
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1
                        }
                        imageSource: Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark ? "asset:///images/channel_lt.png" : "asset:///images/channel.png"

                        attachedObjects: [
                            Invocation {
                                id: invokeChannel
                                query.uri: "bbmc:C001213C9"
                                query.invokeTargetId: "sys.bbm.channels.card.previewer"
                                query.invokeActionId: "bb.action.OPENBBMCHANNEL"
                            }
                        ]

                        onClicked: {
                            invokeChannel.trigger("bb.action.OPENBBMCHANNEL")
                        }
                    }
                }
                Divider {

                }
            }
            Label {
                textStyle.base: lightStyle.style
                text: "Reader YC - Copyright © 2013 Surge Co."
                textStyle.fontSize: FontSize.PointValue
                textStyle.fontSizeValue: 5
                //preferredWidth: 768
                layoutProperties: StackLayoutProperties {
                }
                horizontalAlignment: HorizontalAlignment.Center
                textStyle.textAlign: TextAlign.Center
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
                query.uri: "mailto:krruzic@gmail.com?subject=Reader YC Help"
            }
        ]
    }
}

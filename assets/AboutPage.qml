import bb.cascades 1.2

Page {
    titleBar: HNTitleBar {
        id: aboutTitleBar
        text: "Reader YC - About"
        refreshEnabled: false
    }
    Container {
        background: Color.White
        attachedObjects: [
            TextStyleDefinition {
                id: lightStyle
                base: SystemDefaults.TextStyles.BodyText
                fontSize: FontSize.PointValue
                fontSizeValue: 7
                fontWeight: FontWeight.W100
            }
        ]
        ScrollView {
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
                            textStyle.base: lightStyle.style
                            topMargin: 0
                            bottomMargin: 0
                            text: "<b>What is Hacker News?</b>"
                            textFormat: TextFormat.Html
                            textStyle.color: Color.create("#434344")
                        }
                        Container {
                            leftPadding: 20
                            topPadding: 6
                            Label {
                                textStyle.base: lightStyle.style
                                bottomMargin: 0
                                text: '[from the Hacker News <a href="http://ycombinator.com/newswelcome.html"> welcome page</a>]'
                                textFormat: TextFormat.Html
                                textStyle.fontSize: FontSize.PointValue
                                textStyle.fontSizeValue: 6
                                textStyle.color: Color.create("#ff7900")
                                multiline: true
                            }
                            TextArea {
                                textStyle.base: lightStyle.style
                                bottomMargin: 0
                                topMargin: 0
                                editable: false
                                text: "HN is an experiment. As a rule, a community site that becomes popular will decline in quality. Our hypothesis is that this is not inevitable—that by making a conscious effort to resist decline, we can keep it from happening."
                                textStyle.fontSize: FontSize.PointValue
                                textStyle.fontSizeValue: 6
                                textStyle.color: Color.create("#ff303030")
                            }
                        }
                    }
                }
                Divider {
                    topMargin: 0
                    bottomMargin: 0

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
                                textStyle.base: lightStyle.style
                                bottomMargin: 0
                                topMargin: 0
                                text: "<b>What is Reader YC?</b>"
                                textFormat: TextFormat.Html
                                textStyle.color: Color.create("#434344")
                            }
                            Container {
                                leftPadding: 20
                                topPadding: 6
                                Label {
                                    textStyle.base: lightStyle.style
                                    text: 'Reader YC is client for Hacker News, allowing you to browse HN on your BlackBerry 10 device'
                                    textFormat: TextFormat.Html
                                    textStyle.fontSize: FontSize.PointValue
                                    textStyle.fontSizeValue: 6
                                    textStyle.color: Color.create("#ff7900")
                                    multiline: true
                                    bottomMargin: 0
                                }
                                TextArea {
                                    textStyle.base: lightStyle.style
                                    bottomMargin: 0
                                    topMargin: 0
                                    editable: false
                                    text: "After getting fed up with 'mobilized' versions of Hacker News and noticing the lack of a good BB10 client, Surge Co. decided to build Reader YC as a pet project. Reader YC is open source and <a href='http://github.com/krruzic/Reader-YC/'>contributions</a> are encouraged."
                                    textStyle.fontSize: FontSize.PointValue
                                    textStyle.fontSizeValue: 6
                                    textStyle.color: Color.create("#ff303030")
                                    textFormat: TextFormat.Html
                                }
                            }
                        }
                    }
                    Divider {
                        topMargin: 0
                        bottomMargin: 0
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
                                textStyle.base: lightStyle.style
                                text: "<b>Who is Surge Co.?</b>"
                                textFormat: TextFormat.Html
                                textStyle.color: Color.create("#434344")
                                bottomMargin: 0
                                topMargin: 0
                            }
                            Container {
                                leftPadding: 20
                                topPadding: 6

                                Label {
                                    textStyle.base: lightStyle.style
                                    text: 'Surge Co. is a small group of developers founded by David Dryden and Kristopher Ruzic'
                                    textFormat: TextFormat.Html
                                    textStyle.fontSize: FontSize.PointValue
                                    textStyle.fontSizeValue: 6
                                    textStyle.color: Color.create("#ff7900")
                                    multiline: true
                                    bottomMargin: 0
                                }
                                TextArea {
                                    textStyle.base: lightStyle.style
                                    bottomMargin: 0
                                    topMargin: 0
                                    editable: false
                                    text: "Reader YC is the first of many apps to come out of Surge Co. The Co-founders are huge BlackBerry fans and plan to continue supporting BB10 with native, beautiful apps."
                                    textStyle.fontSize: FontSize.PointValue
                                    textStyle.fontSizeValue: 6
                                    textStyle.color: Color.create("#ff303030")
                                }
                            }
                        }
                    }
                    Divider {
                        topMargin: 0
                        bottomMargin: 0
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
                                    textStyle.base: lightStyle.style
                                    text: "<b>Privacy Policy</b>"
                                    textFormat: TextFormat.Html
                                    textStyle.color: Color.create("#434344")
                                    bottomMargin: 0
                                    topMargin: 0
                                }
                                Container {
                                    leftPadding: 20
                                    topPadding: 6

                                    Label {
                                        textStyle.base: lightStyle.style
                                        text: 'Everything you wanted to know about private stuff'
                                        textFormat: TextFormat.Html
                                        textStyle.fontSize: FontSize.PointValue
                                        textStyle.fontSizeValue: 6
                                        textStyle.color: Color.create("#ff7900")
                                        multiline: true
                                        bottomMargin: 0
                                    }
                                    TextArea {
                                        textStyle.base: lightStyle.style
                                        bottomMargin: 0
                                        topMargin: 0
                                        editable: false
                                        text: "Reader YC literally sends no info to anyone. Why do you think there are NO permissions? PS: I had to write this. Your private and non-private information is safe on your phone.\nDon't believe me? The app is open source, check it out for yourself.\nFuture versions of this app may incorporate logging in to enable voting and posting. Still, this app will collect nothing, and all data will be sent to the Hackernews servers via HTTPS to ensure security"
                                        textStyle.fontSize: FontSize.PointValue
                                        textStyle.fontSizeValue: 6
                                        textStyle.color: Color.create("#ff303030")
                                    }
                                }
                            }
                        }
                        Divider {

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
                        Container {
                            minHeight: 20
                            maxHeight: 20
                        }
                    }
                }
            }
        }
    }
}
import bb.cascades 1.0

Page {
    Container {
        HNTitleBar {
            id: aboutTitleBar
            text: "Reader|YC - Help"
            showButton: false
            onRefreshPage: {
                aboutSheet.close();
            }
        }
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
                            text: "<b>What is Hacker News?</b>"
                            textFormat: TextFormat.Html
                            textStyle.color: Color.create("#434344")
                        }
                        Label {
                            text: '[from the Hacker News <a href="ycombinator.com/newswelcome.html"> welcome page</a>]'
                            textFormat: TextFormat.Html
                            textStyle.fontSize: FontSize.PointValue
                            textStyle.fontSizeValue: 6
                            textStyle.color: Color.create("#fe8a3e")
                            multiline: true
                            autoSize.maxLineCount: 15
                            bottomMargin: 0
                        }
                        TextArea {
                            topMargin: 0
                            editable: false
                            text: " HN is an experiment. As a rule, a community site that becomes popular will decline in quality. Our hypothesis is that this is not inevitable—that by making a conscious effort to resist decline, we can keep it from happening."
                            textStyle.fontSize: FontSize.PointValue
                            textStyle.fontSizeValue: 6
                            textStyle.color: Color.create("#ff303030")
                        }
                    }
                }
                Divider {

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
                                text: "<b>What is Reader|YC?</b>"
                                textFormat: TextFormat.Html
                                textStyle.color: Color.create("#434344")
                            }
                            Label {
                                text: 'Reader|YC is client for Hacker News, allowing you to browse HN on your BlackBerry 10 device'
                                textFormat: TextFormat.Html
                                textStyle.fontSize: FontSize.PointValue
                                textStyle.fontSizeValue: 6
                                textStyle.color: Color.create("#fe8a3e")
                                multiline: true
                                autoSize.maxLineCount: 15
                                bottomMargin: 0
                            }
                            TextArea {
                                topMargin: 0
                                editable: false
                                text: "Reader|YC was built mostly as a pet project, after getting fed up with 'mobilized' versions of Hacker News and noticing the lack of a good BB10 client. Reader|YC is open source and contributions are encouraged."
                                textStyle.fontSize: FontSize.PointValue
                                textStyle.fontSizeValue: 6
                                textStyle.color: Color.create("#ff303030")
                            }
                        }
                    }
                    Divider {

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
                                text: "<b>Who is Surge Co.?</b>"
                                textFormat: TextFormat.Html
                                textStyle.color: Color.create("#434344")
                                bottomMargin: 0
                            }
                            Label {
                                text: 'Surge Co. is a small group of developers founded by David Dryden and Kristopher Ruzic'
                                textFormat: TextFormat.Html
                                textStyle.fontSize: FontSize.PointValue
                                textStyle.fontSizeValue: 6
                                textStyle.color: Color.create("#fe8a3e")
                                multiline: true
                                autoSize.maxLineCount: 15
                                bottomMargin: 0

                            }
                            TextArea {
                                topMargin: 0
                                editable: false
                                text: "Reader|YC is the first of many apps to come out of Surge Co. The Co-founders are huge BlackBerry fans and plan to continue supporting BB10 with native, beautiful apps."
                                textStyle.fontSize: FontSize.PointValue
                                textStyle.fontSizeValue: 6
                                textStyle.color: Color.create("#ff303030")
                            }
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
    }
}
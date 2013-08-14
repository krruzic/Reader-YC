import bb.cascades 1.0
import "tart.js" as Tart

MenuDefinition {

    // Specify the actions that should be included in the menu
    actions: [
        ActionItem {
            title: "About"
            onTriggered: {
                aboutSheet.open();
            }
        },
        ActionItem {
            title: "Help"
            onTriggered: {
                helpSheet.open();
            }
        }
    ] // end of actions list
    attachedObjects: [
            Sheet {
            id: aboutSheet
            Page {
                Container {
                    HNTitleBar {
                        id: aboutTitleBar
                        buttonImage: "asset:///images/close.png"
                        buttonPressedImage: "asset:///images/close.png"
                        text: "Reader|YC - About"
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
                                    onArmed: {
                                    }
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
        },
        Sheet {
            id: helpSheet
            Page {
                Container {
                    layout: StackLayout {
                    }
                    HNTitleBar {
                        verticalAlignment: verticalAlignment.Top
                        id: helpTitleBar
                        text: "Reader|YC - Help"
                        buttonImage: "asset:///images/close.png"
                        buttonPressedImage: "asset:///images/close.png"
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
                }
            }
        }
    ]
}
